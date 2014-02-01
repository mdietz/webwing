class window.TieIn extends Ship

  constructor: (name, world, initPos, initRot) ->
    super(name, world, initPos.clone(), initRot.clone(), "static/res/Tie-In-low.obj", "static/res/Tie-In-low.mtl", 0x00ff00)
    @type = "tie-in"
    @nextLaser = 0
    @minDist = 100
    @maxDist = 2000
    @dir = 1
    @targetRot = null
    @switch_near = false
    @switch_far = false
    @range = 4000
    @targetSprite = null
    @shieldTimeout = 100
    @speed = 250
    @maxSpeed = 250
    @hitCount = 0

  onHit: (faceIndex) =>
    @hitCount += 1
    if @hitCount%25 == 0
      @explode2()

  load: (onLoaded) =>
    super (ship) =>
      @model.useQuaternion = true
      @addTargetSprite()
      @createBoundingSphere(15, new THREE.Vector3(0, 0, 4), new THREE.Vector3(0.8, 0.5, 1.0))
      @resetPos()
      @resetRot()
      onLoaded(ship)

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

  explode: () =>
    scale = 0.1
    explosionTexture = THREE.ImageUtils.loadTexture( "static/img/Explosion.png" )
    explosionMaterial = new THREE.SpriteMaterial( {map: explosionTexture, useScreenCoordinates: false, transparent:true, opacity:0.9} )
    explosionSprite = new THREE.Sprite(explosionMaterial)
    explosionSprite.scale.set(scale, scale, scale)
    #explosionSprite.blending = THREE.AdditiveBlending
    @model.add(explosionSprite)
    tween = new TWEEN.Tween(explosionSprite.scale)
    .to({x:100.0, y:100.0, z:100.0}, 500)
    .easing(TWEEN.Easing.Linear.None) 
    .onComplete(() =>
      @model.remove(explosionSprite)
      @reset()
    )
    @world.sound.playSound(@world.sound.explodeSound, 0.55)
    tween.start()

  addTargetSprite: () =>
    @targetMat = new THREE.LineBasicMaterial( { color: 0xff0000, opacity: 0.7, fog:false, linewidth: 1} )

    @targetContainer = new THREE.Object3D()

    # Upper Left
    geometry1 = new THREE.Geometry();
    geometry1.vertices.push( new THREE.Vector3(-1,1,0) )
    geometry1.vertices.push( new THREE.Vector3(-.5,1,0) )
    @targetContainer.add(new THREE.Line(geometry1, @targetMat))
    geometry2 = new THREE.Geometry();
    geometry2.vertices.push( new THREE.Vector3(-1,1,0) )
    geometry2.vertices.push( new THREE.Vector3(-1,.5,0) )
    @targetContainer.add(new THREE.Line(geometry2, @targetMat))

    # Upper Right
    geometry3 = new THREE.Geometry();
    geometry3.vertices.push( new THREE.Vector3(1,1,0) )
    geometry3.vertices.push( new THREE.Vector3(.5,1,0) )
    @targetContainer.add(new THREE.Line(geometry3, @targetMat))
    geometry4 = new THREE.Geometry();
    geometry4.vertices.push( new THREE.Vector3(1,1,0) )
    geometry4.vertices.push( new THREE.Vector3(1,.5,0) )
    @targetContainer.add(new THREE.Line(geometry4, @targetMat))

    # Lower Right
    geometry5 = new THREE.Geometry();
    geometry5.vertices.push( new THREE.Vector3(1,-1,0) )
    geometry5.vertices.push( new THREE.Vector3(.5,-1,0) )
    @targetContainer.add(new THREE.Line(geometry5, @targetMat))
    geometry6 = new THREE.Geometry();
    geometry6.vertices.push( new THREE.Vector3(1,-1,0) )
    geometry6.vertices.push( new THREE.Vector3(1,-.5,0) )
    @targetContainer.add(new THREE.Line(geometry6, @targetMat))

    # Lower Left
    geometry7 = new THREE.Geometry();
    geometry7.vertices.push( new THREE.Vector3(-1,-1,0) )
    geometry7.vertices.push( new THREE.Vector3(-.5,-1,0) )
    @targetContainer.add(new THREE.Line(geometry7, @targetMat))
    geometry8 = new THREE.Geometry();
    geometry8.vertices.push( new THREE.Vector3(-1,-1,0) )
    geometry8.vertices.push( new THREE.Vector3(-1,-.5,0) )
    @targetContainer.add(new THREE.Line(geometry8, @targetMat))

    @targetContainer.scale.set(15, 15, 15)
    @model.add(@targetContainer)

    ###scale = 35.0
    targetTexture = THREE.ImageUtils.loadTexture( "static/img/enemy_target.png" )
    targetMaterial = new THREE.SpriteMaterial( {map: targetTexture, useScreenCoordinates: false, transparent:true, opacity:0.7} )
    @targetSprite = new THREE.Sprite(targetMaterial)
    @targetSprite.scale.set(scale, scale, scale)
    @targetSprite.blending = THREE.AdditiveBlending
    @model.add(@targetSprite)###

  setAsPlayerTarget: () =>
    tween = new TWEEN.Tween(@targetSprite)
    .to({rotation:Math.PI}, 5000)
    .easing(TWEEN.Easing.Linear.None)
    .repeat(Infinity)
    tween.start()

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
    @world.scene.add(laserContainer)
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

    @world.sound.playSound(@world.sound.blasterSound, 0.03)

    setTimeout(() =>
      if @firing
        @fireDouble()
    , tweentime/4);

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
    @world.scene.remove(container)
