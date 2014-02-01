class window.Ship
  autoRand: Math.PI/4

  constructor: (@name, @world, @initPos, @initRot, @objLoc, @mtlLoc, @laserColor) ->
    #@laserMat = new THREE.MeshBasicMaterial( { color: @laserColor, opacity: 0.5 } )
    @laserMat = new THREE.LineBasicMaterial( { color: @laserColor, opacity: 0.7, fog:false, linewidth: 2} )
    @rayMat = new THREE.MeshBasicMaterial( { color: @laserColor, linewidth: 0.1} )
    @explosionMaterial = new THREE.ShaderMaterial( {
      uniforms: {
        tExplosion: { type: "t", value: THREE.ImageUtils.loadTexture( 'static/img/explosion.png' ) },
        time: { type: "f", value: Math.random() },
        weight: { type: "f", value: 10.0 }
      },
      vertexShader: document.getElementById( 'perlin_vertex_shader' ).textContent,
      fragmentShader: document.getElementById( 'perlin_fragment_shader' ).textContent

    } )
    geometry = new THREE.Geometry();
    geometry.vertices.push( new THREE.Vector3(0,0,-20) )
    geometry.vertices.push( new THREE.Vector3(0,0,20) )
    @laserGeom = new THREE.Line(geometry, @laserMat)
    #@laserGeom = new THREE.CubeGeometry( .6, .6, 20 )
    @loaded = false
    @model = null
    @speed = 0
    @targets = []
    @focus = null
    @range = 1000
    @boundingSphere = null
    @shieldTimeout = 100
    @viewDist = 50
    @shieldOn = [false, false, false, false, false, false, false, false]
    @simpleShields = false
    @autoPilotEnabled = false
    @maxSpeed = 200
    @firing = false

  load: (onLoaded) =>
    if /.obj$/.test(@objLoc)
      loader = new THREE.OBJMTLLoader()
      loader.addEventListener('load', (event) =>
        object = event.content
        @model = new THREE.Object3D()
        @model.add(object)
        #scene.add(@model)
        @loaded = true
        onLoaded(this)
      )
      loader.load(@objLoc, @mtlLoc)
    else
      loader = new THREE.ColladaLoader()
      loader.options.convertUpAxis = true;
      loader.load(@objLoc, (event) =>
        object = event.scene
        while object.children.length == 1
          object = object.children[0]
        @model = new THREE.Object3D()
        @model.add(object)
        #scene.add(@model)
        @loaded = true
        onLoaded(this)
      )

  getUpdatedModel: (quat) =>
    newShip = @model.clone()
    newShip.quaternion = quat
    newShip.translateZ(@speed/10)
    newShip.position.clone()

  addTarget: (ship) =>
    @targets.push(ship)
    if @focus == null
      @focus = @targets[0]

  resetPos: () =>
    @model.position = @initPos.clone()

  resetRot: () =>
    @model.quaternion.set(0,0,0,1)
    Util.rotObj(@model, Util.xAxis, @initRot.x)
    Util.rotObj(@model, Util.yAxis, @initRot.y)
    Util.rotObj(@model, Util.zAxis, @initRot.z)

  reset: () =>
    if @autoPilotEnabled
      @pathTween.stop()
    @resetPos()
    @resetRot()
    @firing = false
    if @autoPilotEnabled
      @autoPilot()
    #@fireDouble()

  computeHit: (laserContainer) =>
    clonedLaser = laserContainer.clone()
    clonedLaser.translateZ(1)
    endPos = clonedLaser.position.clone()
    orientationVector = endPos.sub(laserContainer.position.clone()).normalize()
    raycaster = new THREE.Raycaster(laserContainer.position.clone(), orientationVector.clone(), 0, @range)
    boundingBoxes = []

    # TODO: Optimize this
    for ship in @world.ships
      if ship != this
        worldSphere = ship.boundingSphere.clone()
        worldSphere.useQuaternion = true
        dupModel = ship.model.clone()
        worldSphere.position = dupModel.position.clone()
        worldSphere.quaternion = dupModel.quaternion.clone()
        worldSphere.scale.multiply(dupModel.scale.clone())
        boundingBoxes.push(worldSphere)
        worldSphere.ship = ship

    intersection = null
    for intersect in raycaster.intersectObjects(boundingBoxes, true)
      intersection = intersect
      break
    return intersection

  # parameters: sphere_radius, mesh_offsets, scale
  createBoundingSphere: (radius, offset, scale) =>
    @radius = radius
    @boundingSphere = new THREE.Object3D()
    sphere = new THREE.SphereGeometry( radius, 8, 8 )
    perlinTex = THREE.ImageUtils.loadTexture("static/img/simplex_noise.png")
    simplex_vertex = document.getElementById( 'simplex_vertex_shader' ).textContent
    simplex_fragment = document.getElementById( 'simplex_fragment_shader' ).textContent
    shieldUniforms = {
      time: @world.simplexTime,
      scale:  { type: "f", value: 10.0/radius }
    }
    materials = []
    for face, i in sphere.faces
      if @simpleShields
        materials.push(new THREE.MeshPhongMaterial( { map: perlinTex, color: 0x0000ff, ambient: 0x0000ff, emissive: 0x0000ff, transparent: true, opacity: 0.4, side: THREE.BackSide, blending: THREE.AdditiveBlending, shading: THREE.SmoothShading, visible: false} ))
      else
        materials.push(new THREE.ShaderMaterial( { transparent: true, opacity: 0.01, side: THREE.BackSide, blending: THREE.AdditiveBlending, shading: THREE.SmoothShading, visible: false, uniforms: shieldUniforms, vertexShader: simplex_vertex, fragmentShader: simplex_fragment } ))
    sphere.materials = materials

    sphere2 = new THREE.SphereGeometry( radius, 8, 8 )
    materials2 = []
    for face, i in sphere.faces
      if @simpleShields
        materials2.push(new THREE.MeshPhongMaterial( { map: perlinTex, color: 0x0000ff, ambient: 0x0000ff, emissive: 0x0000ff, transparent: true, opacity: 0.4, side: THREE.FrontSide, blending: THREE.AdditiveBlending, shading: THREE.SmoothShading, visible: false} ))
      else
        materials2.push(new THREE.ShaderMaterial( { transparent: true, opacity: 0.01, side: THREE.FrontSide, blending: THREE.AdditiveBlending, shading: THREE.SmoothShading, visible: false, uniforms: shieldUniforms, vertexShader: simplex_vertex, fragmentShader: simplex_fragment } ))
    sphere2.materials = materials2

    for face, i in sphere.faces
      face.materialIndex = i

    for face, i in sphere2.faces
      face.materialIndex = i

    mesh = new THREE.Mesh( sphere, new THREE.MeshFaceMaterial(materials) )
    mesh2 = new THREE.Mesh( sphere2, new THREE.MeshFaceMaterial(materials2) )

    mesh.position = offset.clone()
    mesh2.position = offset.clone()

    @boundingSphere.add(mesh)
    @boundingSphere.add(mesh2)
    @boundingSphere.scale = scale.clone()
    @model.add(@boundingSphere)

  getSectorFromIndex: (i) =>
    ret = 0
    if i < 144/2
      if i%12 == 0 or i%12 == 1 or i%12 == 2
        ret = 0
      else if i%12 == 3 or i%12 == 4 or i%12 == 5
        ret = 1
      else if i%12 == 6 or i%12 == 7 or i%12 == 8
        ret = 2
      else if i%12 == 9 or i%12 == 10 or i%12 == 11
        ret = 3
    else
      if i%12 == 0 or i%12 == 1 or i%12 == 2
        ret = 4
      else if i%12 == 3 or i%12 == 4 or i%12 == 5
        ret = 5
      else if i%12 == 6 or i%12 == 7 or i%12 == 8
        ret = 6
      else if i%12 == 9 or i%12 == 10 or i%12 == 11
        ret = 7
    ret

  showShield: (index) =>
    i = index
    if !@shieldOn[index]
      @boundingSphere.children[0].geometry.materials[i].visible = true
      @boundingSphere.children[1].geometry.materials[i].visible = true
      @shieldOn[index] = true
      setTimeout(() =>
        @hideShield(index)
      , @shieldTimeout)

  hideShield: (index) =>
    i = index
    @boundingSphere.children[0].geometry.materials[i].visible = false
    @boundingSphere.children[1].geometry.materials[i].visible = false
    @shieldOn[index] = false

  showLaserHitParticles: (faceIndex, hittingShip) =>
    return

  addLaserRay: (startPos, orientationVector) =>
    _startPos = startPos.clone()
    endPos = _startPos.add(orientationVector.multiplyScalar(2000))
    geometry = new THREE.Geometry();
    geometry.vertices.push( startPos )
    geometry.vertices.push( endPos )
    line = new THREE.Line(geometry, @rayMat)
    window.scene.add(line)

  addTargetRay: () =>
    geometry = new THREE.Geometry();
    geometry.vertices.push( new THREE.Vector3(0, 0, 0 ) );
    geometry.vertices.push( new THREE.Vector3(0, 0, 2000 ) )
    line = new THREE.Line(geometry, @rayMat)
    @model.add(line)

  setSpeed: (newSpeed) =>
    @speed = newSpeed

  autoPilot: () =>
    @autoPilotEnabled = true
    modelClone = @model.clone()
    dist = modelClone.position.distanceTo(@focus.model.position)
    if dist < @minDist and @dir == 1
      @switch_near = true
    if dist > @minDist and @switch_near
      @dir = -1
      @firing = false
      @targetRot = null
      @switch_near = false
    if dist > @maxDist and @dir == -1
      @switch_far = true
    if dist < @maxDist and @switch_far
      @dir = 1
      @firing = true
      @fireDouble()
      @targetRot = null
      @switch_far = false
    else if dist < @maxDist and !@firing and @dir == 1
      @firing = true
      @fireDouble()
    @speed = Math.min(@maxSpeed, @focus.speed)
    if (@dir == 1 and !@switch_near) or (@dir == -1 and @switch_far)
      modelClone.lookAt(@focus.model.position)
    if @targetRot == null
      if @switch_near
        modelClone.lookAt(@focus.model.position)
        Util.rotObj(modelClone, Util.xAxis, Math.PI + (@autoRand - Math.random()*@autoRand*2))
        Util.rotObj(modelClone, Util.yAxis, (@autoRand - Math.random()*@autoRand*2))
        Util.rotObj(modelClone, Util.zAxis, (@autoRand - Math.random()*@autoRand*2))
        @targetRot = modelClone.quaternion.clone()
      if @switch_far
        modelClone.lookAt(@focus.model.position)
        @targetRot = modelClone.quaternion.clone()
    if @switch_near or @switch_far
      newRot = @targetRot
    else
      newRot = modelClone.quaternion.clone()
    newPos = @getUpdatedModel(newRot)
    toVals = {position:{x:newPos.x, y:newPos.y, z:newPos.z}, quaternion:{x:newRot.x, y:newRot.y, z:newRot.z, w:newRot.w}}
    @pathTween = new TWEEN.Tween(@model)
    .to(toVals, 100)
    .easing(TWEEN.Easing.Linear.None)
    .onComplete(() =>
      @autoPilot()
    )
    @pathTween.start()