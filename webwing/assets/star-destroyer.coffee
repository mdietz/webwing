class window.SD extends Ship
  laserBolts: []
  nextLaser: 0
  targets: []
  cof = 0.0174532925

  constructor: (name, initPos, initRot) ->
    console.log("corvette const")
    super(name, initPos, initRot, "static/res/star-destroyer.dae", "", 0x00ff00)
    @laserGeom = new THREE.CubeGeometry( 2, 2, 40 );
    @targetSprite = null
    @boundingSphere = null
    @shieldOn = [false, false, false, false, false, false, false, false]

  load: (onLoaded) =>
    super (ship) =>
      @model.scale.set(0.08, 0.08, 0.08)
      @model.useQuaternion = true
      Util.rotObj(@model.children[0], Util.yAxis, -Math.PI/2);
      @addTargetSprite()
      @addBoundingSphere()
      @resetPos()
      @resetRot()
      onLoaded(ship)

  addLaserRay: (startPos, orientationVector) =>
    _startPos = startPos.clone()
    endPos = _startPos.add(orientationVector.multiplyScalar(10000))
    geometry = new THREE.Geometry();
    geometry.vertices.push( startPos )
    geometry.vertices.push( endPos )
    #console.log(endPos)
    line = new THREE.Line(geometry, @rayMat)
    window.scene.add(line)

  addBoundingSphere: () =>
    @boundingSphere = new THREE.Object3D()
    sphere = new THREE.SphereGeometry( 16000, 12, 12 )
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
      new THREE.MeshLambertMaterial( { emissive: 0x0000ff, color: 0x0000ff, ambient: 0x0000ff, transparent: true, opacity: 0.05, side: THREE.BackSide } )
    ]
    sphere.materials = materials

    sphere2 = new THREE.SphereGeometry( 16000, 12, 12 )
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
      new THREE.MeshLambertMaterial( { emissive: 0x0000ff, color: 0x0000ff, ambient: 0x0000ff, transparent: true, opacity: 0.05, side: THREE.FrontSide } )
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

    mesh.position.set(0,3000,5000)
    mesh2.position.set(0,3000,5000)
    @boundingSphere.add(mesh)
    @boundingSphere.add(mesh2)
    @boundingSphere.scale.set(1.3, 0.8, 2.2)
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

  addTargetSprite: () =>
    scale = 400.0
    targetTexture = THREE.ImageUtils.loadTexture( "static/img/enemy_target.png" )
    targetMaterial = new THREE.SpriteMaterial( {map: targetTexture, useScreenCoordinates: false, transparent:true, opacity:0.7} )
    @targetSprite = new THREE.Sprite(targetMaterial)
    @targetSprite.scale.set(scale, scale, scale)
    @targetSprite.blending = THREE.AdditiveBlending
    @model.add(@targetSprite)

  addTarget: (ship) =>
    @targets.push(ship)

  fireSingle: () =>
    distance = 10000
    tweentime = 5000
    laserContainer = new THREE.Object3D()
    laserContainer.useQuaternion = true
    laserContainer.position = @model.position.clone()
    laserContainer.quaternion = @model.quaternion.clone()
    window.scene.add(laserContainer)
    if @targets.length == 0
      Util.rotObj(laserContainer, Util.xAxis, Math.random()*2*Math.PI)
      Util.rotObj(laserContainer, Util.yAxis, Math.random()*2*Math.PI)
    else
      laserContainer.lookAt(@targets[Math.floor(Math.random()*@targets.length)].model.position)
      Util.rotObj(laserContainer, Util.xAxis, cof - Math.random()*cof*2)
      Util.rotObj(laserContainer, Util.yAxis, cof - Math.random()*cof*2)
    laserMesh = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh)

    laserContainer.updateMatrix()
    clonedLaser = laserContainer.clone()
    clonedLaser.translateZ(1)
    endPos = clonedLaser.position.clone()
    orientationVector = endPos.sub(laserContainer.position.clone()).normalize()
    raycaster = new THREE.Raycaster(laserContainer.position.clone(), orientationVector.clone(), 0, 10000)
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

    toPoint = null
    for intersect in raycaster.intersectObjects(boundingBoxes, true)
      #console.log(intersect)
      toPoint = intersect.point
      toPoint.sub(@model.position.clone())
      tgtDist = intersect.distance
      hitTarget = intersect.object.parent.ship
      faceIndex = intersect.faceIndex
      pctZ = intersect.distance/10000.0
      break
    if toPoint != null
      #console.log(@model.position)
      #console.log({x: 0, y: 0, z:tgtDist, time:tweentime*pctZ})
      new TWEEN.Tween(laserMesh.position)
      .to({x: 0, y: 0, z:tgtDist}, tweentime*pctZ)
      .easing(TWEEN.Easing.Linear.None)
      .start()
      setTimeout(() =>
        @laserCleanup(laserContainer)
        hitTarget.showShield(faceIndex)
      , tweentime*pctZ)
    else
      new TWEEN.Tween(laserMesh.position)
      .to({x: 0, y: 0, z:distance}, tweentime)
      .easing(TWEEN.Easing.Linear.None)
      .start()
      setTimeout(() =>
        @laserCleanup(laserContainer)
      , tweentime)

    setTimeout(() =>
      @fireSingle()
    , tweentime/16);

  fireDouble: () =>
    distance = 10000
    tweentime = 5000
    laserContainer = new THREE.Object3D()
    laserContainer.useQuaternion = true
    laserContainer.position = @model.position.clone()
    laserContainer.quaternion = @model.quaternion.clone()
    window.scene.add(laserContainer)
    if @targets.length == 0
      Util.rotObj(laserContainer, Util.xAxis, Math.random()*2*Math.PI)
      Util.rotObj(laserContainer, Util.yAxis, Math.random()*2*Math.PI)
      Util.rotObj(laserContainer, Util.zAxis, Math.random()*Math.PI)
    else
      laserContainer.lookAt(@targets[Math.floor(Math.random()*@targets.length)].model.position)
      Util.rotObj(laserContainer, Util.xAxis, cof - Math.random()*cof*2)
      Util.rotObj(laserContainer, Util.yAxis, cof - Math.random()*cof*2)
      Util.rotObj(laserContainer, Util.zAxis, Math.random()*Math.PI)

    laserMesh1 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh1)
    laserMesh2 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh2)
    laserMesh1.position.set(10,0,0)
    laserMesh2.position.set(-10,0,0)
    new TWEEN.Tween(laserMesh1.position)
    .to({x: 0, y: 0, z:distance}, tweentime)
    .easing(TWEEN.Easing.Linear.None)
    .start()
    new TWEEN.Tween(laserMesh2.position)
    .to({x: 0, y: 0, z:distance}, tweentime)
    .easing(TWEEN.Easing.Linear.None)
    .start()

    setTimeout(() =>
      @fireDouble()
    , tweentime/8);

    setTimeout(() =>
      @laserCleanup(laserContainer)
    , tweentime);

  laserCleanup: (container) =>
    window.scene.remove(container)
