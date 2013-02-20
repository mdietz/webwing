class window.TieIn extends Ship
  laserBolts: []
  nextLaser: 0

  constructor: (name, initPos, initRot) ->
    console.log("tiein const")
    super(name, initPos, initRot, "static/res/Tie-In-low.obj", "static/res/Tie-In-low.mtl", 0x00ff00)

  fireSingle: () =>
    distance = 500
    tweentime = 1000
    laserContainer = new THREE.Object3D()
    laserContainer.rotation = @model.rotation.clone()
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
    new TWEEN.Tween(laserMesh.position)
    .to({x: 0, y: 0, z:distance}, tweentime)
    .easing(TWEEN.Easing.Linear.None)
    .start()

    setTimeout(() =>
      @fireSingle()
    , tweentime/4);

    setTimeout(() =>
      @laserCleanup(laserContainer)
    , tweentime);

  fireDouble: () =>
    distance = 500;
    tweentime = 1000;
    laserContainer = new THREE.Object3D()
    laserContainer.rotation = @model.rotation.clone()
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
    , tweentime/2);

    setTimeout(() =>
      @laserCleanup(laserContainer)
    , tweentime);

  fireQuad: () =>
    distance = 500;
    tweentime = 1000;
    laserContainer = new THREE.Object3D()
    laserContainer.rotation = @model.rotation.clone()
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

    setTimeout(() =>
      @laserCleanup(laserContainer)
      @fireQuad()
    , tweentime);

  laserCleanup: (container) =>
    window.scene.remove(container)