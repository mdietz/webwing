class window.Hyperspace

  constructor: (@world, @camera, @scene, @renderer) ->
    @renderer.setClearColor( new THREE.Vector3(0,0,0), 1 )
    white = 0xffffff
    # Starfield logic here
    @starMat = new THREE.LineBasicMaterial( { color: white, opacity: 0.0, fog:false, linewidth: 1} )
    @starGeom = new THREE.Geometry();
    @starGeom.vertices.push( new THREE.Vector3(0,0,0) )
    @starGeom.vertices.push( new THREE.Vector3(0,0,-1) )
    @starContainer = new THREE.Object3D()
    @starLines = []
    @stopAnimation = false

  start: () =>
    for elem in [0..1000]
      @addStarLine(true)
    @scene.add(@starContainer)
    @animate()

  stop: (models, callback) =>
    TWEEN.removeAll()
    time = 1000
    for elem in @starLines
      #console.log(elem.scale.clone())
      new TWEEN.Tween(elem.scale)
      .to({x: 1, y: 1, z:1}, time)
      .easing(TWEEN.Easing.Quartic.In)
      .onComplete(() =>
        @starContainer.remove(elem)
      )
      .start()
    for model in models
      console.log(model.position.clone())
      @scene.add(model)
      startPos = model.position.clone()
      model.position.set(startPos.x, startPos.y, startPos.z + 10000)
      moveTween = new TWEEN.Tween(model.position)
      .to({x:startPos.x, y:startPos.y, z:startPos.z}, time)
      .easing(TWEEN.Easing.Quartic.In)
      .start()

    setTimeout(() =>
      @stopAnimation = true
      #for elem in @starContainer
      #  @starContainer.remove(elem)
      @world.finishHyperspace()
    , time*2 + 100)

  addStarLine: (first) =>
    easing = TWEEN.Easing.Linear.None
    time = 100
    delay = 0
    if first
      easing = TWEEN.Easing.Quartic.In
      time = 1000
      delay = 1000
    starLine = new THREE.Line(@starGeom, @starMat)
    starLine.position.set(Math.random()*140000 - 70000, Math.random()*120000 - 60000, Math.random()*200000)
    dist = starLine.position.z + 1000
    moveTween = new TWEEN.Tween(starLine.position)
      .to({x: starLine.position.x, y: starLine.position.y, z:-1000}, (dist/10000)*100)
      .easing(TWEEN.Easing.Linear.None)
      .onComplete(() =>
        @starContainer.remove(starLine)
        @starLines.splice(@starLines.indexOf(starLine), 1);
        @addStarLine(false)
      )
    scaleTween = new TWEEN.Tween(starLine.scale)
      .to({x: 1, y: 1, z:10000}, time)
      .easing(easing)
      .delay(delay)
      .chain(moveTween)
      .start()
    @starLines.push(starLine)
    @starContainer.add(starLine)

  animate: () =>
    if !@stopAnimation
      requestAnimationFrame( @animate )
    TWEEN.update()
    @renderer.render( @scene, @camera )