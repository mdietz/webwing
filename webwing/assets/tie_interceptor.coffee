class window.TieIn extends Ship
  autoRand: Math.PI/4

  constructor: (name, initPos, initRot) ->
    console.log("tiein const")
    super(name, initPos.clone(), initRot.clone(), "static/res/Tie-In-low.obj", "static/res/Tie-In-low.mtl", 0x00ff00)
    @nextLaser = 0
    @minDist = 400
    @maxDist = 2000
    @dir = 1
    @targetRot = null
    @switch_near = false
    @switch_far = false
    @range = 4000
    @targetSprite = null
    @shieldTimeout = 100

  onHit: (faceIndex) =>
    @explode()

  load: (onLoaded) =>
    super (ship) =>
      @model.useQuaternion = true
      @boundingBox = Util.getCompoundBoundingBox(@model)
      @addTargetSprite()
      @createBoundingSphere(15, new THREE.Vector3(0, 0, 4), new THREE.Vector3(0.8, 0.5, 1.0))
      @resetPos()
      @resetRot()
      onLoaded(ship)

  reset: () =>
    @pathTween.stop()
    @resetPos()
    @resetRot()
    @autoPilot()
    #@fireDouble()

  explode: () =>
    scale = 1.0
    explosionTexture = THREE.ImageUtils.loadTexture( "static/img/Explosion.png" )
    explosionMaterial = new THREE.SpriteMaterial( {map: explosionTexture, useScreenCoordinates: false, transparent:true, opacity:0.9} )
    explosionSprite = new THREE.Sprite(explosionMaterial)
    explosionSprite.scale.set(scale, scale, scale)
    explosionSprite.blending = THREE.AdditiveBlending
    @model.add(explosionSprite)
    tween = new TWEEN.Tween(explosionSprite.scale)
    .to({x:100.0, y:100.0, z:100.0}, 1000)
    .easing(TWEEN.Easing.Linear.None)
    .onComplete(() =>
      @model.remove(explosionSprite)
      @reset()
    )
    window.Sound.playSound(window.Sound.explodeSound, 0.45)
    tween.start()

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

  autoPilot: () =>
    modelClone = @model.clone()
    dist = modelClone.position.distanceTo(@focus.model.position)
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
    @speed = Math.max(220, @focus.speed-10)
    if @dir == 1 and !@switch_near
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
    laserMesh1 = @laserGeom.clone()
    laserContainer.add(laserMesh1)
    laserMesh2 = @laserGeom.clone()
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

    intersect = @computeHit(laserContainer)

    if intersect != null
      tgtDist = intersect.distance
      hitFace = intersect.face
      hitTarget = intersect.object.parent.ship
      faceIndex = intersect.faceIndex
      pctZ = intersect.distance/@range
      new TWEEN.Tween(laserMesh1.position)
      .to({x: 0, y: 0, z:tgtDist}, tweentime*pctZ)
      .easing(TWEEN.Easing.Linear.None)
      .start()
      new TWEEN.Tween(laserMesh2.position)
      .to({x: 0, y: 0, z:tgtDist}, tweentime*pctZ)
      .easing(TWEEN.Easing.Linear.None)
      .start()
      setTimeout(() =>
        hitTarget.onHit(faceIndex)
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

    window.Sound.playSound(window.Sound.blasterSound, 0.03)

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
