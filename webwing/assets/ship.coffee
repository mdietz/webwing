class window.Ship

  constructor: (@name, @initPos, @initRot, @objLoc, @mtlLoc, @laserColor) ->
    #@laserMat = new THREE.MeshBasicMaterial( { color: @laserColor, opacity: 0.5 } )
    @laserMat = new THREE.LineBasicMaterial( { color: @laserColor, opacity: 0.7, fog:false, linewidth: 3} )
    @rayMat = new THREE.MeshBasicMaterial( { color: @laserColor, linewidth: 0.1} )
    geometry = new THREE.Geometry();
    geometry.vertices.push( new THREE.Vector3(0,0,-20) )
    geometry.vertices.push( new THREE.Vector3(0,0,20) )
    @laserGeom = new THREE.Line(geometry, @laserMat)
    #@laserGeom = new THREE.CubeGeometry( .6, .6, 20 )
    @loaded = false
    @model = null
    @speed = 0
    @targets = []
    @focus = null
    @boundingSphere = null
    @shieldOn = [false, false, false, false, false, false, false, false]

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

  addTarget: (ship) =>
    @targets.push(ship)
    if @focus == null
      @focus = @targets[0]

  resetPos: () =>
    @model.position = @initPos

  resetRot: () =>
    @model.quaternion.set(0,0,0,1)
    Util.rotObj(@model, Util.xAxis, @initRot.x)
    Util.rotObj(@model, Util.yAxis, @initRot.y)
    Util.rotObj(@model, Util.zAxis, @initRot.z)

  # parameters: sphere_radius, mesh_offsets, scale
  createBoundingSphere: (radius, offset, scale) =>
    @boundingSphere = new THREE.Object3D()
    sphere = new THREE.SphereGeometry( radius, 12, 12 )
    materials = [
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { emissive: 0x0000ff, color: 0x0000ff, ambient: 0x0000ff, transparent: true, opacity: 0.1, side: THREE.BackSide } )
    ]
    sphere.materials = materials

    sphere2 = new THREE.SphereGeometry( radius, 12, 12 )
    materials2 = [
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { visible: false } ),
      new THREE.MeshLambertMaterial( { emissive: 0x0000ff, color: 0x0000ff, ambient: 0x0000ff, transparent: true, opacity: 0.1, side: THREE.FrontSide } )
    ]
    sphere2.materials = materials2
    for face, i in sphere.faces
      if i < 144/2
        if i%12 == 0 or i%12 == 1 or i%12 == 2
          face.materialIndex = 0
        else if i%12 == 3 or i%12 == 4 or i%12 == 5
          face.materialIndex = 1
        else if i%12 == 6 or i%12 == 7 or i%12 == 8
          face.materialIndex = 2
        else if i%12 == 9 or i%12 == 10 or i%12 == 11
          face.materialIndex = 3
      else
        if i%12 == 0 or i%12 == 1 or i%12 == 2
          face.materialIndex = 4
        else if i%12 == 3 or i%12 == 4 or i%12 == 5
          face.materialIndex = 5
        else if i%12 == 6 or i%12 == 7 or i%12 == 8
          face.materialIndex = 6
        else if i%12 == 9 or i%12 == 10 or i%12 == 11
          face.materialIndex = 7

    for face, i in sphere2.faces
      if i < 144/2
        if i%12 == 0 or i%12 == 1 or i%12 == 2
          face.materialIndex = 0
        else if i%12 == 3 or i%12 == 4 or i%12 == 5
          face.materialIndex = 1
        else if i%12 == 6 or i%12 == 7 or i%12 == 8
          face.materialIndex = 2
        else if i%12 == 9 or i%12 == 10 or i%12 == 11
          face.materialIndex = 3
      else
        if i%12 == 0 or i%12 == 1 or i%12 == 2
          face.materialIndex = 4
        else if i%12 == 3 or i%12 == 4 or i%12 == 5
          face.materialIndex = 5
        else if i%12 == 6 or i%12 == 7 or i%12 == 8
          face.materialIndex = 6
        else if i%12 == 9 or i%12 == 10 or i%12 == 11
          face.materialIndex = 7

    mesh = new THREE.Mesh( sphere, new THREE.MeshFaceMaterial(materials) )
    mesh2 = new THREE.Mesh( sphere2, new THREE.MeshFaceMaterial(materials2) )

    mesh.position = offset.clone()
    mesh2.position = offset.clone()

    @boundingSphere.add(mesh)
    @boundingSphere.add(mesh2)
    @boundingSphere.scale = scale.clone()
    @model.add(@boundingSphere)

  getSectorFromIndex: (i) =>
    ret = 0
    if i < 144/2
      if i%12 == 0 or i%12 == 1 or i%12 == 2
        ret = 0
      else if i%12 == 3 or i%12 == 4 or i%12 == 5
        ret = 1
      else if i%12 == 6 or i%12 == 7 or i%12 == 8
        ret = 2
      else if i%12 == 9 or i%12 == 10 or i%12 == 11
        ret = 3
    else
      if i%12 == 0 or i%12 == 1 or i%12 == 2
        ret = 4
      else if i%12 == 3 or i%12 == 4 or i%12 == 5
        ret = 5
      else if i%12 == 6 or i%12 == 7 or i%12 == 8
        ret = 6
      else if i%12 == 9 or i%12 == 10 or i%12 == 11
        ret = 7
    ret

  showShield: (index) =>
    i = @getSectorFromIndex(index)
    if !@shieldOn[index]
      @boundingSphere.children[0].geometry.materials[i] = @boundingSphere.children[0].geometry.materials[9]
      @boundingSphere.children[1].geometry.materials[i] = @boundingSphere.children[1].geometry.materials[9]
      @shieldOn[index] = true
      setTimeout(() =>
        @hideShield(index)
      , 100)

  hideShield: (index) =>
    i = @getSectorFromIndex(index)
    @boundingSphere.children[0].geometry.materials[i] = @boundingSphere.children[0].geometry.materials[8]
    @boundingSphere.children[1].geometry.materials[i] = @boundingSphere.children[1].geometry.materials[8]
    @shieldOn[index] = false

  addLaserRay: (startPos, orientationVector) =>
    _startPos = startPos.clone()
    endPos = _startPos.add(orientationVector.multiplyScalar(2000))
    geometry = new THREE.Geometry();
    geometry.vertices.push( startPos )
    geometry.vertices.push( endPos )
    line = new THREE.Line(geometry, @rayMat)
    window.scene.add(line)

  addTargetRay: () =>
    geometry = new THREE.Geometry();
    geometry.vertices.push( new THREE.Vector3(0, 0, 0 ) );
    geometry.vertices.push( new THREE.Vector3(0, 0, 2000 ) )
    line = new THREE.Line(geometry, @rayMat)
    @model.add(line)

  setSpeed: (newSpeed) =>
    @speed = newSpeed


