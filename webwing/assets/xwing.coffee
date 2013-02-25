class window.XWing extends Ship
  laserBolts: []
  nextLaser: 0

  constructor: (name, initPos, initRot) ->
    console.log("xwing const")
    super(name, initPos, initRot, "static/res/XWing-low.obj", "static/res/XWing-low.mtl", 0xff0000)
    @target = []
    @crosshair = null

  load: (onLoaded) =>
    super (ship) =>
      @model.useQuaternion = true
      #@addShield()
      @addThrust()
      @addCrosshair()
      onLoaded(ship)

  setTarget: (ship) =>
    @target.push(ship)
    ship.setAsPlayerTarget()

  addCrosshair: () =>
    scale = 4.0
    crosshairTexture = THREE.ImageUtils.loadTexture( "static/img/crosshair_nohit.png" )
    crosshairMaterial = new THREE.SpriteMaterial( {map: crosshairTexture, useScreenCoordinates: false, transparent:true, opacity:0.7} )
    @crosshair = new THREE.Sprite(crosshairMaterial)
    @crosshair.scale.set(scale, scale, scale)
    @crosshair.position.set(0, 0, 100)
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

  addShield: () =>
    shield = new THREE.SphereGeometry( 15, 12, 12 )

    SHADING = THREE.SmoothShading
    OPACITY = 0.2

    color = 0x0000ff

    material2Back = new THREE.MeshLambertMaterial( {
      color: color,
      ambient: color,
      side: THREE.BackSide,
      shading: SHADING,
      transparent: true,
      opacity: OPACITY
      } )

    material2Front = new THREE.MeshLambertMaterial( {
      color: color,
      ambient: color,
      side: THREE.FrontSide,
      shading: SHADING,
      transparent: true,
      opacity: OPACITY,
      depthTest:false
      } )

    mesh = new THREE.Mesh( shield, material2Back )
    mesh.scale.set(1.0, 0.5, 1.0)
    @model.add(mesh)

    mesh = new THREE.Mesh( shield, material2Front )
    mesh.scale.set(1.0, 0.5, 1.0)
    @model.add(mesh)


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
    window.scene.add(laserContainer)
    laserMesh1 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh1)
    laserMesh2 = new THREE.Mesh(@laserGeom, @laserMat)
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
    window.scene.remove(container)