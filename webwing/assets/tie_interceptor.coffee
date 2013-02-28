class window.TieIn extends Ship
  laserBolts: []
  autoRand: Math.PI/4

  constructor: (name, initPos, initRot) ->
    console.log("tiein const")
    super(name, initPos, initRot, "static/res/Tie-In-low.obj", "static/res/Tie-In-low.mtl", 0x00ff00)
    @target = []
    @nextLaser = 0
    @minDist = 400
    @maxDist = 2000
    @dir = 1
    @targetRot = null
    @switch_near = false
    @switch_far = false
    @targetSprite = null
    @targetRay = null
    @boundingSphere = null
    @shieldOn = [false, false, false, false, false, false, false, false]

  load: (onLoaded) =>
    super (ship) =>
      @model.useQuaternion = true
      @boundingBox = Util.getCompoundBoundingBox(@model)
      @addTargetSprite()
      #@addTargetRay()
      @addBoundingSphere()
      @resetPos()
      @resetRot()
      onLoaded(ship)

  addBoundingSphere: () =>
    @boundingSphere = new THREE.Object3D()
    sphere = new THREE.SphereGeometry( 15, 12, 12 )
    materials = [
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { emissive: 0x0000ff, color: 0x0000ff, ambient: 0x0000ff, transparent: true, opacity: 0.2, side: THREE.BackSide } )
    ]
    sphere.materials = materials

    sphere2 = new THREE.SphereGeometry( 15, 12, 12 )
    materials2 = [
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      #new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { emissive: 0x0000ff, color: 0x0000ff, ambient: 0x0000ff, transparent: true, opacity: 0.2, side: THREE.FrontSide } )
    ]
    sphere2.materials = materials2
    for face, i in sphere.faces
      if i < 144/2
        if i%12 == 0 or i%12 == 1 or i%12 == 2
          face.materialIndex = 0
        else if i%12 == 3 or i%12 == 4 or i%12 == 5
          face.materialIndex = 1
        else if i%12 == 6 or i%12 == 7 or i%12 == 8
          face.materialIndex = 2
        else if i%12 == 9 or i%12 == 10 or i%12 == 11
          face.materialIndex = 3
      else
        if i%12 == 0 or i%12 == 1 or i%12 == 2
          face.materialIndex = 4
        else if i%12 == 3 or i%12 == 4 or i%12 == 5
          face.materialIndex = 5
        else if i%12 == 6 or i%12 == 7 or i%12 == 8
          face.materialIndex = 6
        else if i%12 == 9 or i%12 == 10 or i%12 == 11
          face.materialIndex = 7

    for face, i in sphere2.faces
      if i < 144/2
        if i%12 == 0 or i%12 == 1 or i%12 == 2
          face.materialIndex = 0
        else if i%12 == 3 or i%12 == 4 or i%12 == 5
          face.materialIndex = 1
        else if i%12 == 6 or i%12 == 7 or i%12 == 8
          face.materialIndex = 2
        else if i%12 == 9 or i%12 == 10 or i%12 == 11
          face.materialIndex = 3
      else
        if i%12 == 0 or i%12 == 1 or i%12 == 2
          face.materialIndex = 4
        else if i%12 == 3 or i%12 == 4 or i%12 == 5
          face.materialIndex = 5
        else if i%12 == 6 or i%12 == 7 or i%12 == 8
          face.materialIndex = 6
        else if i%12 == 9 or i%12 == 10 or i%12 == 11
          face.materialIndex = 7

    mesh = new THREE.Mesh( sphere, new THREE.MeshFaceMaterial(materials) )
    mesh2 = new THREE.Mesh( sphere2, new THREE.MeshFaceMaterial(materials2) )

    mesh2.position.set(0,0,4)
    mesh.position.set(0,0,4)
    @boundingSphere.add(mesh)
    @boundingSphere.add(mesh2)
    @boundingSphere.scale.set(0.8, 0.5, 1.0)
    @model.add(@boundingSphere)

  shieldShown: (index) =>
    shieldOn[index]

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
    i = @getSectorFromIndex(index)
    console.log(i)
    if !@shieldOn[index]
      @boundingSphere.children[0].geometry.materials[i] = @boundingSphere.children[0].geometry.materials[9]
      @boundingSphere.children[1].geometry.materials[i] = @boundingSphere.children[1].geometry.materials[9]
      @shieldOn[index] = true
      setTimeout(() =>
        @hideShield(index)
      , 100)

  hideShield: (index) =>
    i = @getSectorFromIndex(index)
    @boundingSphere.children[0].geometry.materials[i] = @boundingSphere.children[0].geometry.materials[8]
    @boundingSphere.children[1].geometry.materials[i] = @boundingSphere.children[1].geometry.materials[8]
    @shieldOn[index] = false

  addLaserRay: (startPos, orientationVector) =>
    _startPos = startPos.clone()
    endPos = _startPos.add(orientationVector.multiplyScalar(2000))
    geometry = new THREE.Geometry();
    geometry.vertices.push( startPos )
    geometry.vertices.push( endPos )
    #console.log(endPos)
    line = new THREE.Line(geometry, @rayMat)
    window.scene.add(line)

  addTargetRay: () =>
    @targetRay = new THREE.Ray( @model.position, new THREE.Vector3(0, 0, -1) )
    geometry = new THREE.Geometry();
    geometry.vertices.push( new THREE.Vector3(0, 0, 0 ) );
    geometry.vertices.push( new THREE.Vector3(0, 0, 2000 ) )
    line = new THREE.Line(geometry, @rayMat)
    @model.add(line)
    @model.add(@targetRay)

  addTargetSprite: () =>
    scale = 35.0
    targetTexture = THREE.ImageUtils.loadTexture( "static/img/enemy_target.png" )
    targetMaterial = new THREE.SpriteMaterial( {map: targetTexture, useScreenCoordinates: false, transparent:true, opacity:0.7} )
    @targetSprite = new THREE.Sprite(targetMaterial)
    @targetSprite.scale.set(scale, scale, scale)
    @targetSprite.blending = THREE.AdditiveBlending
    @model.add(@targetSprite)

  setAsPlayerTarget: () =>
    tween = new TWEEN.Tween(@targetSprite)
    .to({rotation:Math.PI}, 5000)
    .easing(TWEEN.Easing.Linear.None)
    .repeat(Infinity)
    tween.start()

  setTarget: (ship) =>
    @target.push(ship)

  autoPilot: () =>
    modelClone = @model.clone()
    dist = modelClone.position.distanceTo(@target[0].model.position)
    if dist < @minDist and @dir == 1
      @switch_near = true
    if dist > @minDist and @switch_near
      @dir = -1
      @targetRot = null
      @switch_near = false
    if dist > @maxDist and @dir == -1
      @switch_far = true
    if dist < @maxDist and @switch_far
      @dir = 1
      @fireDouble()
      @targetRot = null
      @switch_far = false
    @speed = Math.max(220, @target[0].speed-10)
    if @dir == 1 and !@switch_near
      modelClone.lookAt(@target[0].model.position)
    if @targetRot == null
      if @switch_near
        modelClone.lookAt(@target[0].model.position)
        Util.rotObj(modelClone, Util.xAxis, Math.PI + (@autoRand - Math.random()*@autoRand*2))
        Util.rotObj(modelClone, Util.yAxis, (@autoRand - Math.random()*@autoRand*2))
        Util.rotObj(modelClone, Util.zAxis, (@autoRand - Math.random()*@autoRand*2))
        @targetRot = modelClone.quaternion.clone()
      if @switch_far
        modelClone.lookAt(@target[0].model.position)
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

  getUpdatedModel: (quat) =>
    newShip = @model.clone()
    newShip.quaternion = quat
    newShip.translateZ(@speed/10)
    newShip.position.clone()

  fireSingle: () =>
    distance = 4000
    tweentime = 2000
    laserContainer = new THREE.Object3D()
    laserContainer.useQuaternion = true
    laserContainer.quaternion = @model.quaternion.clone()
    laserContainer.position = @model.position.clone()
    scene.add(laserContainer)
    laserMesh = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh)
    switch @nextLaser
      when 0
        laserMesh.position.set(6.6,2.3,23)
        @nextLaser += 1
      when 1
        laserMesh.position.set(-6.6,-3.7,23)
        @nextLaser += 1
      when 2
        laserMesh.position.set(6.6,-3.7,23)
        @nextLaser += 1
      when 3
        laserMesh.position.set(-6.6,2.3,23)
        @nextLaser = 0

    light = new THREE.PointLight(@laserColor, 1, 20)
    light.position = laserMesh.position.clone();
    laserContainer.add(light);

    new TWEEN.Tween(light.position)
    .to({x: 0, y: 0, z:distance}, tweentime)
    .easing(TWEEN.Easing.Linear.None)
    .start()

    new TWEEN.Tween(laserMesh.position)
    .to({x: 0, y: 0, z:distance}, tweentime)
    .easing(TWEEN.Easing.Linear.None)
    .start()

    setTimeout(() =>
      @fireSingle()
    , tweentime/8);

    setTimeout(() =>
      @laserCleanup(laserContainer)
    , tweentime);

  fireDouble: () =>
    distance = 4000;
    tweentime = 2000;
    laserContainer = new THREE.Object3D()
    laserContainer.useQuaternion = true
    laserContainer.quaternion = @model.quaternion.clone()
    laserContainer.position = @model.position.clone()
    window.scene.add(laserContainer)
    laserMesh1 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh1)
    laserMesh2 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh2)
    switch @nextLaser
      when 0, 2
        laserMesh1.position.set(6.6,2.3,23)
        laserMesh2.position.set(-6.6,-3.7,23)
        @nextLaser = 1
      when 1, 3
        laserMesh1.position.set(6.6,-3.7,23)
        laserMesh2.position.set(-6.6,2.3,23)
        @nextLaser = 0

    laserContainer.updateMatrix()
    clonedLaser = laserContainer.clone()
    clonedLaser.translateZ(1)
    endPos = clonedLaser.position.clone()
    orientationVector = endPos.sub(laserContainer.position.clone()).normalize()
    #@addLaserRay(@model.position.clone(), orientationVector.clone())
    raycaster = new THREE.Raycaster(laserContainer.position.clone(), orientationVector.clone(), 0, 4000)
    boundingBoxes = []

    # TODO: Optimize this
    for ship in window.ships
      if ship != this
        worldSphere = ship.boundingSphere.clone()
        worldSphere.useQuaternion = true
        dupModel = ship.model.clone()
        worldSphere.position = dupModel.position.clone()
        worldSphere.quaternion = dupModel.quaternion.clone()
        worldSphere.scale.multiply(dupModel.scale.clone())
        boundingBoxes.push(worldSphere)
        worldSphere.ship = ship
        #scene.add(worldSphere)

    #console.log(boundingBoxes)
    toPoint = null
    for intersect in raycaster.intersectObjects(boundingBoxes, true)
      #console.log(intersect)
      toPoint = intersect.point
      toPoint.sub(@model.position.clone())
      tgtDist = intersect.distance
      hitFace = intersect.face
      faceIndex = intersect.faceIndex
      hitTarget = intersect.object.parent.ship
      #console.log(hitTarget)
      pctZ = intersect.distance/4000.0
      break
    if toPoint != null
      #console.log({x: laserMesh1.position.x*pctZ, y: laserMesh1.position.y*pctZ, z:toPoint.z, time:tweentime*pctZ})
      new TWEEN.Tween(laserMesh1.position)
      .to({x: 0, y: 0, z:tgtDist}, tweentime*pctZ)
      .easing(TWEEN.Easing.Linear.None)
      .start()
      new TWEEN.Tween(laserMesh2.position)
      .to({x: 0, y: 0, z:tgtDist}, tweentime*pctZ)
      .easing(TWEEN.Easing.Linear.None)
      .start()
      setTimeout(() =>
        hitTarget.showShield(faceIndex)
        @laserCleanup(laserContainer)
      , tweentime*pctZ)
    else
      new TWEEN.Tween(laserMesh1.position)
      .to({x: 0, y: 0, z:distance}, tweentime)
      .easing(TWEEN.Easing.Linear.None)
      .start()
      new TWEEN.Tween(laserMesh2.position)
      .to({x: 0, y: 0, z:distance}, tweentime)
      .easing(TWEEN.Easing.Linear.None)
      .start()
      setTimeout(() =>
        @laserCleanup(laserContainer)
      , tweentime)

    setTimeout(() =>
      if @dir == 1
        @fireDouble()
    , tweentime/4);

  fireQuad: () =>
    distance = 4000;
    tweentime = 2000;
    laserContainer = new THREE.Object3D()
    laserContainer.useQuaternion = true
    laserContainer.quaternion = @model.quaternion.clone()
    laserContainer.position = @model.position.clone()
    window.scene.add(laserContainer)
    laserMesh1 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh1)
    laserMesh2 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh2)
    laserMesh3 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh3)
    laserMesh4 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh4)

    laserMesh1.position.set(6.6,2.3,23)
    laserMesh2.position.set(-6.6,-3.7,23)
    laserMesh3.position.set(6.6,-3.7,23)
    laserMesh4.position.set(-6.6,2.3,23)
    @nextLaser = 0

    new TWEEN.Tween(laserMesh1.position)
    .to({x: 0, y: 0, z:distance}, tweentime)
    .easing(TWEEN.Easing.Linear.None)
    .start()
    new TWEEN.Tween(laserMesh2.position)
    .to({x: 0, y: 0, z:distance}, tweentime)
    .easing(TWEEN.Easing.Linear.None)
    .start()
    new TWEEN.Tween(laserMesh3.position)
    .to({x: 0, y: 0, z:distance}, tweentime)
    .easing(TWEEN.Easing.Linear.None)
    .start()
    new TWEEN.Tween(laserMesh4.position)
    .to({x: 0, y: 0, z:distance}, tweentime)
    .easing(TWEEN.Easing.Linear.None)
    .start()

    #light = new THREE.PointLight(@laserColor, 5, 60)
    #light.position.set(0,0,23);
    #laserContainer.add(light);

    #new TWEEN.Tween(light.position)
    #.to({x: 0, y: 0, z:distance}, tweentime)
    #.easing(TWEEN.Easing.Linear.None)
    #.start()

    setTimeout(() =>
      @fireQuad()
    , tweentime/2);

    setTimeout(() =>
      @laserCleanup(laserContainer)
    , tweentime);

  laserCleanup: (container) =>
    scene.remove(container)

  laserCleanup: (container, mesh, light) =>
    scene.remove(light)
    scene.remove(mesh)
    scene.remove(container)
