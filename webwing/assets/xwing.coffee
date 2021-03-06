class window.XWing extends Ship

  constructor: (name, world, initPos, initRot) ->
    super(name, world, initPos.clone(), initRot.clone(), "static/res/XWing-low.obj", "static/res/XWing-low.mtl", 0xff0000)
    @type = "xwing"
    @crosshair = null
    @nextLaser = 0
    @range = 10000
    @minDist = 100
    @maxDist = 2000
    @dir = 1
    @targetRot = null
    @switch_near = false
    @switch_far = false
    @shieldTimeout = 100
    @speed = 200
    @maxSpeed = 200
    @hitCount = 0

  load: (onLoaded) =>
    super (ship) =>
      @model.useQuaternion = true
      @addThrust()
      #@addCrosshair()
      @createBoundingSphere(15, new THREE.Vector3(0, 0, 0), new THREE.Vector3(1.0, 0.5, 1.0))
      @resetPos()
      @resetRot()
      onLoaded(ship)

  onHit: (faceIndex) =>
    @hitCount += 1
    if @hitCount%50 != 0
      @showShield(faceIndex)
    else
      @explode2()

  explode2: () =>
    mesh = new THREE.Mesh( new THREE.IcosahedronGeometry( 20, 3 ), @explosionMaterial );
    mesh.scale.set(0.1, 0.1, 0.1)
    @model.add(mesh)
    explodeOut = new TWEEN.Tween(mesh.scale)
    .to({x: 0.1, y: 0.1, z:0.1}, 250)
    .easing(TWEEN.Easing.Exponential.In)
    .onComplete(() =>
      @model.remove(mesh)
      @reset()
    )

    explodeIn = new TWEEN.Tween(mesh.scale)
    .to({x: 3, y: 3, z:3}, 750)
    .easing(TWEEN.Easing.Back.Out)
    .onComplete(() =>
      @model.visible = false
      mesh.visible = true
    ).chain(explodeOut)
    .start()

    new TWEEN.Tween(@explosionMaterial.uniforms[ 'time' ])
    .to({value: @explosionMaterial.uniforms[ 'time' ].value + 1.0}, 1000)
    .easing(TWEEN.Easing.Linear.None)
    .start()

    @world.sound.playSound(@world.sound.explodeSound, 0.55)

  addCrosshair: () =>
    scale = 4.0
    crosshairTexture = THREE.ImageUtils.loadTexture( "static/img/crosshair_nohit.png" )
    crosshairMaterial = new THREE.SpriteMaterial( {map: crosshairTexture, useScreenCoordinates: false, transparent:true, opacity:0.7} )
    @crosshair = new THREE.Sprite(crosshairMaterial)
    @crosshair.scale.set(scale, scale, scale)
    @crosshair.position.set(0, 4.8, 100)
    @crosshair.blending = THREE.AdditiveBlending
    @model.add(@crosshair)

  addThrust: () =>
    thrustImage = THREE.ImageUtils.loadTexture( "static/img/thrust.png" )
    scale = 2.0

    material = new THREE.SpriteMaterial( {map: thrustImage, useScreenCoordinates: false} )

    thrust0 = new THREE.Sprite(material)
    thrust0.scale.set(scale, scale, scale)
    thrust0.position.set( 2.15, 2.5, -11 )
    thrust0.blending = THREE.AdditiveBlending
    @model.add( thrust0 )

    thrust1 = new THREE.Sprite( material)
    thrust1.scale.set(scale, scale, scale)
    thrust1.position.set( -2.15, 2.5, -11 )
    thrust1.blending = THREE.AdditiveBlending
    @model.add( thrust1 )

    thrust2 =  new THREE.Sprite( material)
    thrust2.scale.set(scale, scale, scale)
    thrust2.position.set( 2.2, -2.3, -11 )
    thrust2.blending = THREE.AdditiveBlending
    @model.add( thrust2 )

    thrust3 =  new THREE.Sprite( material)
    thrust3.scale.set(scale, scale, scale)
    thrust3.position.set( -2.2, -2.3, -11 )
    thrust3.blending = THREE.AdditiveBlending
    @model.add( thrust3 )

  fireSingle: () =>
    distance = 4000
    tweentime = 2000
    laserContainer = new THREE.Object3D()
    laserContainer.useQuaternion = true
    laserContainer.quaternion = @model.quaternion.clone()
    laserContainer.position = @model.position.clone()
    @world.scene.add(laserContainer)
    laserMesh = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh)
    switch @nextLaser
      when 0
        laserMesh.position.set(9.9,3.8,16.3)
        @nextLaser += 1
      when 1
        laserMesh.position.set(-9.9,-3.7,16.3)
        @nextLaser += 1
      when 2
        laserMesh.position.set(9.9,-3.7,16.3)
        @nextLaser += 1
      when 3
        laserMesh.position.set(-9.9,3.8,16.3)
        @nextLaser = 0
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
    @world.scene.add(laserContainer)
    laserMesh1 = @laserGeom.clone()
    laserContainer.add(laserMesh1)
    laserMesh2 = @laserGeom.clone()
    laserContainer.add(laserMesh2)
    switch @nextLaser
      when 0, 2
        laserMesh1.position.set(9.9,3.8,16.3)
        laserMesh2.position.set(-9.9,-3.7,16.3)
        @nextLaser = 1
      when 1, 3
        laserMesh1.position.set(9.9,-3.7,16.3)
        laserMesh2.position.set(-9.9,3.8,16.3)
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
        @laserCleanup(laserContainer)
        hitTarget.onHit(faceIndex)
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

    @world.sound.playSound(@world.sound.blasterSound, 0.2)

    setTimeout(() =>
      if @firing
        @fireDouble()
    , tweentime/4)

  fireQuad: () =>
    distance = 4000;
    tweentime = 2000;
    laserContainer = new THREE.Object3D()
    laserContainer.useQuaternion = true
    laserContainer.quaternion = @model.quaternion.clone()
    laserContainer.position = @model.position.clone()
    @world.scene.add(laserContainer)
    laserMesh1 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh1)
    laserMesh2 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh2)
    laserMesh3 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh3)
    laserMesh4 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh4)

    laserMesh1.position.set(9.9,3.8,16.3)
    laserMesh2.position.set(-9.9,-3.7,16.3)
    laserMesh3.position.set(9.9,-3.7,16.3)
    laserMesh4.position.set(-9.9,3.8,16.3)
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
    , tweentime/2)

    setTimeout(() =>
      @laserCleanup(laserContainer)
    , tweentime)

  laserCleanup: (container) =>
    @world.scene.remove(container)