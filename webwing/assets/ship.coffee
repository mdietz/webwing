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



