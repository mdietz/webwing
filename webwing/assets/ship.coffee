class window.Ship
  loaded: false
  model: null
  speed: 0

  constructor: (@name, @initPos, @initRot, @objLoc, @mtlLoc, @laserColor) ->
    @laserMat = new THREE.MeshBasicMaterial( { color: @laserColor, opacity: 0.5 } )
    @rayMat = new THREE.MeshBasicMaterial( { color: @laserColor, linewidth: 0.1} )
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
        @model.add(object)
        scene.add(@model)
        @loaded = true
        onLoaded(this)
        )

  resetPos: () =>
    @model.position = @initPos

  resetRot: () =>
    @model.quaternion.set(0,0,0,1)
    Util.rotObj(@model, Util.xAxis, @initRot.x)
    Util.rotObj(@model, Util.yAxis, @initRot.y)
    Util.rotObj(@model, Util.zAxis, @initRot.z)

  setSpeed: (newSpeed) =>
    @speed = newSpeed


