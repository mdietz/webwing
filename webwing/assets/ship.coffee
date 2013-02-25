class window.Ship
  loaded: false
  model: null
  speed: 0

  constructor: (@name, @initPos, @initRot, @objLoc, @mtlLoc, @laserColor) ->
    @laserMat = new THREE.MeshBasicMaterial( { color: @laserColor, opacity: 0.5 } )
    @laserGeom = new THREE.CubeGeometry( .6, .6, 20 );
    console.log("ship const")

  load: (onLoaded) =>
    console.log("inLoad")
    if /.obj$/.test(@objLoc)
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
    else
      loader = new THREE.ColladaLoader()
      loader.options.convertUpAxis = true;
      loader.load(@objLoc, (event) =>
        console.log("collada loading")
        object = event.scene
        while object.children.length == 1
          console.log(object)
          object = object.children[0]
        @model = new THREE.Object3D()
        @model.position = @initPos
        @model.rotation = @initRot
        @model.add(object)
        scene.add(@model)
        @loaded = true
        onLoaded(this)
        )

  setSpeed: (newSpeed) =>
    @speed = newSpeed


