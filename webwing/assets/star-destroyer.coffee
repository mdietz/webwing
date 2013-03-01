class window.SD extends Ship
  cof: 0.0174532925

  constructor: (name, initPos, initRot) ->
    console.log("corvette const")
    super(name, initPos, initRot, "static/res/star-destroyer.dae", "", 0x00ff00)
    @targetSprite = null

  load: (onLoaded) =>
    super (ship) =>
      @model.scale.set(0.08, 0.08, 0.08)
      @model.useQuaternion = true
      Util.rotObj(@model.children[0], Util.yAxis, -Math.PI/2);
      @addTargetSprite()
      @createBoundingSphere(16000, new THREE.Vector3(0, 3000, 5000), new THREE.Vector3(1.3, 0.8, 2.2))
      @resetPos()
      @resetRot()
      onLoaded(ship)

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
      Util.rotObj(laserContainer, Util.xAxis, @cof - Math.random()*@cof*2)
      Util.rotObj(laserContainer, Util.yAxis, @cof - Math.random()*@cof*2)
    laserMesh = @laserGeom.clone()
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
      Util.rotObj(laserContainer, Util.xAxis, @cof - Math.random()*@cof*2)
      Util.rotObj(laserContainer, Util.yAxis, @cof - Math.random()*@cof*2)
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
