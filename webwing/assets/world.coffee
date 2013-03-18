class window.World
  # Math.PI/2 = 1.5707963267948966
  # Math.PI   = 3.141592653589793

  defaultWorld:  {
                    ships: [
                      {
                        type: 'xwing',
                        name: 'Rogue Leader',
                        playerControlled: true,
                        pos: {
                          x: 0,
                          y: 0,
                          z: 0
                        },
                        rot: {
                          x: 0,
                          y: 0,
                          z: 0
                        }
                      },
                      {
                        type: 'tie-in',
                        name: 'Wrath Leader',
                        pos: {
                          x: 0,
                          y: 0,
                          z: 1000
                        },
                        rot: {
                          x: 0,
                          y: Math.PI,
                          z: 0
                        }
                      }
                    ],
                    views: [
                      {
                        left: 0,
                        bottom: 0,
                        center: false,
                        width: 1,
                        height: 1,
                        eye: [ 0, 5, -40 ],
                        up: [ 0, 1, 0 ],
                        rot: [ 0, Math.PI, 0 ],
                        depth: 200000,
                        fov: 60,
                        background: { r: 0.0, g: 0.0, b: 0.0, a: 1 },
                        updateCamera: ( camera, scene ) =>
                          return
                      }
                    ]
                  }

  constructor: (@name) ->
    console.log(@defaultWorld)
    @flightControls = null
    @animationToggle = false
    @windowWidth = window.innerWidth
    @windowHeight = window.innerHeight
    @initShips = @defaultWorld.ships
    @ships = []
    @views = @defaultWorld.views
    @allLoaded = false
    @scene = new THREE.Scene()
    @renderer = new THREE.WebGLRenderer({'antialias':true})
    @renderer.setSize( @windowWidth, @windowHeight );
    @sound = new window.Sound()
    @loadedShips = 0
    @wireframe = false
    @stats = new Stats()
    @initStats()
    @initCameras()
    @initLights()
    @initSkybox()
    @initOptions()
    @loadShips()
    document.body.appendChild( @renderer.domElement )
    document.body.appendChild( @stats.domElement )

  initStats: () =>
    @stats.domElement.style.position = 'absolute'
    @stats.domElement.style.top = '0px'

  initCameras: () =>
    for view, ii in @views
      console.log(view)
      camera = new THREE.PerspectiveCamera( view.fov, @windowWidth / @windowHeight, 1, view.depth );
      camera.position.x = view.eye[ 0 ];
      camera.position.y = view.eye[ 1 ];
      camera.position.z = view.eye[ 2 ];
      camera.up.x = view.up[ 0 ];
      camera.up.y = view.up[ 1 ];
      camera.up.z = view.up[ 2 ];
      camera.rotation.x = view.rot[ 0 ]
      camera.rotation.y = view.rot[ 1 ]
      camera.rotation.z = view.rot[ 2 ]
      view.camera = camera

  initLights: () =>
    @ambientLight = new THREE.AmbientLight( 0x333333 )
    @scene.add( @ambient )

    @directionalLight = new THREE.DirectionalLight( 0xaaaaaa )
    @directionalLight.position.set( 0, 1, -1 )
    @scene.add( @directionalLight )

    ###@pointLight = new THREE.PointLight( 0xaaaaaa )
    @pointLight.position.set( 0, 1, -1 )
    @scene.add( @pointLight )###

  initSkybox: () =>
    url = "static/img/starfield.png"
    urls = [ url, url, url, url, url, url ]
    @skyboxTextureCube = THREE.ImageUtils.loadTextureCube( urls, new THREE.CubeRefractionMapping() )

    cubeShader = THREE.ShaderLib["cube"]
    cubeUniforms = THREE.UniformsUtils.clone( cubeShader.uniforms )
    cubeUniforms['tCube'].value = @skyboxTextureCube
    cubeMaterial = new THREE.ShaderMaterial({
        fragmentShader: cubeShader.fragmentShader,
        vertexShader: cubeShader.vertexShader,
        uniforms: cubeUniforms,
        side: THREE.BackSide
    })

    @skyboxMesh = new THREE.Mesh( new THREE.CubeGeometry( 100000, 100000, 100000, 1, 1, 1), cubeMaterial )
    @scene.add( @skyboxMesh )

  initOptions: () =>
    document.addEventListener('webkitpointerlockchange', @pointerLockChange, false);

    @toggleAnimation = () =>
      if @animationToggle
        @animationToggle = false
      else
        @animationToggle = true
        @animate()

    @gui = new dat.GUI();
    @windowF = @gui.addFolder('Window')
    @windowF.open()
    @windowF.add(@sound, 'toggleSound')
    @windowF.add(this, 'toggleAnimation')
    @windowF.add(this, 'wireframeToggle')
    @windowF.add(@renderer.domElement, 'webkitRequestPointerLock')

  pointerLockChange: () =>
    if @flightControls.pointerLock
      @flightControls.pointerLock = false
    else
      @flightControls.pointerLock = true

  wireframeToggle: () =>
    if !@wireframe
      @wireframe = true
      @scene.overrideMaterial = new THREE.MeshBasicMaterial({ color: 0xffffff, wireframe: true })
    else
      @wireframe = false
      @scene.overrideMaterial = null

  loadShips: () =>
    for ship in @initShips
      if ship.type == "xwing"
        @ships.push(
          new XWing(
            ship.name,
            this,
            new THREE.Vector3(ship.pos.x,ship.pos.y,ship.pos.z),
            new THREE.Vector3(ship.rot.x,ship.rot.y,ship.rot.z)
          )
        )
      else if ship.type == "tie-in"
        @ships.push(
          new TieIn(
            ship.name,
            this,
            new THREE.Vector3(ship.pos.x,ship.pos.y,ship.pos.z),
            new THREE.Vector3(ship.rot.x,ship.rot.y,ship.rot.z)
          )
        )
      else if ship.type == "corvette"
        @ships.push(
          new Corvette(
            ship.name,
            this,
            new THREE.Vector3(ship.pos.x,ship.pos.y,ship.pos.z),
            new THREE.Vector3(ship.rot.x,ship.rot.y,ship.rot.z)
          )
        )
      else if ship.type == "stardestroyer"
        @ships.push(
          new SD(
            ship.name,
            this,
            new THREE.Vector3(ship.pos.x,ship.pos.y,ship.pos.z),
            new THREE.Vector3(ship.rot.x,ship.rot.y,ship.rot.z)
          )
        )
    for ship, i in @ships
      ship.load(@shipLoaded)

  shipLoaded: (ship) =>
    console.log(ship)
    @scene.add(ship.model)
    @loadedShips += 1
    console.log(@loadedShips)
    if ship.name == "Rogue Leader"
      #ship.model.add(@views[0].camera)
      #@views[0].camera.lookAt(ship.model)
      @flightControls = new FlightControls(ship)
    if @loadedShips >= @initShips.length
      @allLoaded = true
      @animate()

  updateSize: () =>
    if @windowWidth != window.innerWidth || @windowHeight != window.innerHeight
      @windowWidth  = window.innerWidth;
      @windowHeight = window.innerHeight;

      @renderer.setSize( @windowWidth, @windowHeight )

  animate: () =>
    @updateSize()

    if(@animationToggle)
      requestAnimationFrame( @animate )

    TWEEN.update()

    for view, ii in @views
      camera = view.camera

      view.updateCamera( camera, @scene )

      if view.center
        left   = Math.floor( @windowWidth/2 - (@windowWidth*view.width)/2 )
        bottom = Math.floor( @windowHeight * view.bottom )
      else
        left   = Math.floor( @windowWidth  * view.left )
        bottom = Math.floor( @windowHeight * view.bottom )

      width  = Math.floor( @windowWidth  * view.width )
      height = Math.floor( @windowHeight * view.height )

      @renderer.setViewport( left, bottom, width, height )
      @renderer.setScissor( left, bottom, width, height )
      @renderer.enableScissorTest ( true )
      @renderer.setClearColor( view.background, view.background.a )

      camera.aspect = width / height;
      camera.updateProjectionMatrix();

      @renderer.render( @scene, camera );

    @stats.update()

  loadJSON: (jsonString) =>
    return

  loadURL: (urlString) =>
    return

  dumpJson: () =>
    return