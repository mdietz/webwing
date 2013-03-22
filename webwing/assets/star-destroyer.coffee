class window.SD extends Ship
  cof: 0.0174532925

  constructor: (name, world, initPos, initRot) ->
    super(name, world, initPos, initRot, "static/res/star-destroyer.dae", "", 0x00ff00)
    @type = "stardestroyer"
    @targetSprite = null
    @range = 10000
    @shieldTimeout = 2000

  load: (onLoaded) =>
    super (ship) =>
      @model.scale.set(0.08, 0.08, 0.08)
      @model.useQuaternion = true
      Util.rotObj(@model.children[0], Util.yAxis, -Math.PI/2);
      @addTargetSprite()
      @createBoundingSphere(17000, new THREE.Vector3(0, 3000, 5000), new THREE.Vector3(1.3, 0.8, 2.2))
      @resetPos()
      @resetRot()
      onLoaded(ship)

  onHit: (faceIndex) =>
    @showShield(faceIndex)

  addTargetSprite: () =>
    scale = 400.0
    targetTexture = THREE.ImageUtils.loadTexture( "static/img/enemy_target.png" )
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
    @world.scene.add(laserContainer)
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

    intersect = @computeHit(laserContainer)

    if intersect != null
      tgtDist = intersect.distance
      hitFace = intersect.face
      hitTarget = intersect.object.parent.ship
      faceIndex = intersect.faceIndex
      pctZ = intersect.distance/@range
      new TWEEN.Tween(laserMesh.position)
      .to({x: 0, y: 0, z:tgtDist}, tweentime*pctZ)
      .easing(TWEEN.Easing.Linear.None)
      .start()
      setTimeout(() =>
        @laserCleanup(laserContainer)
        hitTarget.onHit(faceIndex)
      , tweentime*pctZ)
    else
      new TWEEN.Tween(laserMesh.position)
      .to({x: 0, y: 0, z:distance}, tweentime)
      .easing(TWEEN.Easing.Linear.None)
      .start()
      setTimeout(() =>
        @laserCleanup(laserContainer)
      , tweentime)

    @world.sound.playSound(@world.sound.blasterSound, 0.03)

    setTimeout(() =>
      if @firing
        @fireSingle()
    , tweentime/16);

  fireDouble: () =>
    distance = 10000
    tweentime = 5000
    laserContainer = new THREE.Object3D()
    laserContainer.useQuaternion = true
    laserContainer.position = @model.position.clone()
    laserContainer.quaternion = @model.quaternion.clone()
    @world.scene.add(laserContainer)
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
    @world.scene.remove(container)
