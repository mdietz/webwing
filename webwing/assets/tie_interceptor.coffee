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

  load: (onLoaded) =>
    super (ship) =>
      @model.useQuaternion = true
      @addTargetSprite()
      onLoaded(ship)

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
    , tweentime/4);

    setTimeout(() =>
      @laserCleanup(laserContainer)
    , tweentime);

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
