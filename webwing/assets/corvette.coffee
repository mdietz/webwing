class window.Corvette extends Ship
  targets: []
  cof = 0.0174532925/2

  constructor: (name, initPos, initRot) ->
    console.log("corvette const")
    super(name, initPos, initRot, "static/res/CORVETTA.dae", "", 0xff0000)
    @laserGeom = new THREE.CubeGeometry( 2, 2, 40 );
    @targetSprite = null

  addTarget: (ship) =>
    @targets.push(ship)

  load: (onLoaded) =>
    super (ship) =>
      @model.scale.set(0.2, 0.2, 0.2)
      @model.useQuaternion = true
      @addTargetSprite()
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
      Util.rotObj(laserContainer, Util.xAxis, cof - Math.random()*cof*2)
      Util.rotObj(laserContainer, Util.yAxis, cof - Math.random()*cof*2)
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
    if @targets.length == 0
      Util.rotObj(laserContainer, Util.xAxis, Math.random()*2*Math.PI)
      Util.rotObj(laserContainer, Util.yAxis, Math.random()*2*Math.PI)
      Util.rotObj(laserContainer, Util.zAxis, Math.random()*Math.PI)
    else
      laserContainer.lookAt(@targets[Math.floor(Math.random()*@targets.length)].model.position)
      Util.rotObj(laserContainer, Util.xAxis, cof - Math.random()*cof*2)
      Util.rotObj(laserContainer, Util.yAxis, cof - Math.random()*cof*2)
      Util.rotObj(laserContainer, Util.zAxis, Math.random()*Math.PI)

    scene.add(laserContainer)
    laserMesh1 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh1)
    laserMesh2 = new THREE.Mesh(@laserGeom, @laserMat)
    laserContainer.add(laserMesh2)
    laserMesh1.position.set(5,0,0)
    laserMesh2.position.set(-5,0,0)
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

  laserCleanup: (container) =>
    window.scene.remove(container)
