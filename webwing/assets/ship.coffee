class window.Ship
  loaded: false
  model: null

  constructor: (@name, @initPos, @initRot, @objLoc, @mtlLoc, @laserColor) ->
    @laserMat = new THREE.MeshBasicMaterial( { color: @laserColor, opacity: 0.5 } )
    @laserGeom = new THREE.CubeGeometry( .6, .6, 20 );
    console.log("ship const")

  load: (onLoaded) =>
    console.log("inLoad")
    loader = new THREE.OBJMTLLoader()
    loader.addEventListener('load', (event) =>
      console.log("loading")
      object = event.content
      @model = new THREE.Object3D()
      @model.position = @initPos
      @model.rotation = @initRot
      @model.add(object)
      scene.add(@model)
      @loaded = true
      onLoaded(this)
    )
    loader.load(@objLoc, @mtlLoc)

  fireSingle: () =>
    distance = 500
    tweentime = 1000
    laserContainer = new THREE.Object3D()
    laserContainer.rotation = @model.rotation.clone()
    laserContainer.position = @model.position.clone()
    scene.add(laserContainer)
    laserMesh = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh)
    if @name == "xwing"
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
    if @name == "xwing"
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
    if @name == "xwing"
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

      setTimeout(() =>
        @laserCleanup(laserContainer)
        @fireQuad()
      , tweentime);

  laserCleanup: (container) =>
    window.scene.remove(container)




