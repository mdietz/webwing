class window.Corvette extends Ship
  cof: 0.0174532925/2

  constructor: (name, initPos, initRot) ->
    console.log("corvette const")
    super(name, initPos, initRot, "static/res/CORVETTA.dae", "", 0xff0000)
    @targetSprite = null

  load: (onLoaded) =>
    super (ship) =>
      @model.scale.set(0.2, 0.2, 0.2)
      @model.useQuaternion = true
      #@addTargetSprite()
      @createBoundingSphere(400, new THREE.Vector3(0, 0, -60), new THREE.Vector3(0.8, 0.6, 2.0))
      @resetPos()
      @resetRot()
      onLoaded(ship)

  addTargetSprite: () =>
    scale = 200.0
    targetTexture = THREE.ImageUtils.loadTexture( "static/img/allied_target.png" )
    targetMaterial = new THREE.SpriteMaterial( {map: targetTexture, useScreenCoordinates: false, transparent:true, opacity:0.7} )
    @targetSprite = new THREE.Sprite(targetMaterial)
    @targetSprite.scale.set(scale, scale, scale)
    @targetSprite.blending = THREE.AdditiveBlending
    @model.add(@targetSprite)

  fireSingle: () =>
    distance = 10000
    tweentime = 5000
    laserContainer = new THREE.Object3D()
    laserContainer.useQuaternion = true
    laserContainer.position = @model.position.clone()
    laserContainer.quaternion = @model.quaternion.clone()
    if @targets.length == 0
      Util.rotObj(laserContainer, Util.xAxis, Math.random()*2*Math.PI)
      Util.rotObj(laserContainer, Util.yAxis, Math.random()*2*Math.PI)
    else
      laserContainer.lookAt(@targets[Math.floor(Math.random()*@targets.length)].model.position)
      Util.rotObj(laserContainer, Util.xAxis, @cof - Math.random()*@cof*2)
      Util.rotObj(laserContainer, Util.yAxis, @cof - Math.random()*@cof*2)
    scene.add(laserContainer)
    laserMesh = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh)

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
      Util.rotObj(laserContainer, Util.xAxis, @cof - Math.random()*@cof*2)
      Util.rotObj(laserContainer, Util.yAxis, @cof - Math.random()*@cof*2)
      Util.rotObj(laserContainer, Util.zAxis, Math.random()*Math.PI)

    laserMesh1 = @laserGeom.clone()
    laserContainer.add(laserMesh1)
    laserMesh2 = @laserGeom.clone()
    laserContainer.add(laserMesh2)
    laserMesh1.position.set(5,0,0)
    laserMesh2.position.set(-5,0,0)

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
      hitFace = intersect.face
      hitTarget = intersect.object.parent.ship
      faceIndex = intersect.faceIndex
      pctZ = intersect.distance/10000.0
      break
    if toPoint != null
      #console.log({x: 0, y: 0, z:tgtDist.z, time:tweentime*pctZ})
      new TWEEN.Tween(laserMesh1.position)
      .to({x: 0, y: 0, z:tgtDist}, tweentime*pctZ)
      .easing(TWEEN.Easing.Linear.None)
      .start()
      new TWEEN.Tween(laserMesh2.position)
      .to({x: 0, y: 0, z:tgtDist}, tweentime*pctZ)
      .easing(TWEEN.Easing.Linear.None)
      .start()
      setTimeout(() =>
        @laserCleanup(laserContainer)
        hitTarget.showShield(faceIndex)
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
      @fireDouble()
    , tweentime/4);

  laserCleanup: (container) =>
    window.scene.remove(container)
