class window.FlightControls
  @getInterstitialModel: (distance) =>
    newShip = @playerShip.model.clone()
    newShip.translateZ(Math.sin(Math.PI/4)*distance)
    newShip.translateX(distance - Math.sin(Math.PI/4)*distance)
    newShip.position.clone()

  @getBezierControl1: (distance) =>
    newShip = @playerShip.model.clone()
    newShip.translateZ(distance*0.5522847498)
    newShip.position.clone()

  @getBezierControl2: (distance) =>
    newShip = @playerShip.model.clone()
    newShip.translateZ(distance)
    newShip.translateX(distance*0.5522847498)
    newShip.position.clone()

  @getUpdatedModel: (distance) =>
    newShip = @playerShip.model.clone()
    newShip.translateZ(distance)
    newShip.translateX(distance)
    newShip.position.clone()

  @getUpdateRotations: () =>
    newShip = @playerShip.model.clone()
    oldRot = newShip.rotation.clone()
    Util.rotObj(newShip, Util.yAxis, Math.PI/2);
    newRot = newShip.quaternion.clone()
    newRot

  @getNewTweens: =>
    newPos = @getUpdatedModel(100)
    ctrlPos1 = @getBezierControl1(100)
    ctrlPos2 = @getBezierControl2(100)
    startPos = @playerShip.model.position
    #console.log(ctrlPos1)
    #console.log(ctrlPos2)
    #console.log(newPos)

    #@rotTween = new TWEEN.Tween(@playerShip.model.rotation)
    #.to({x:0, y:[@playerShip.model.rotation.y+Math.PI/4, @playerShip.model.rotation.y+Math.PI/2], z:0}, 1000)
    #.easing(TWEEN.Easing.Linear.None)
    #.interpolation(TWEEN.Interpolation.CatmullRom)

    #newRot = @getUpdateRotations()
    newRot = @playerShip.model.quaternion.clone().multiply(new THREE.Quaternion(0, Math.sqrt(0.5), 0, Math.sqrt(0.5))).normalize()
    #console.log(@playerShip.model.quaternion)
    #console.log(newRot)
    toVals = {position:{x:[startPos.x, ctrlPos1.x, ctrlPos2.x, newPos.x], y:[startPos.y, ctrlPos1.y, ctrlPos2.y, newPos.y], z:[startPos.z, ctrlPos1.z, ctrlPos2.z, newPos.z]}, quaternion:{x:newRot.x, y:newRot.y, z:newRot.z, w:newRot.w}}
    #console.log(toVals)

    @pathTween = new TWEEN.Tween(@playerShip.model)
    .to(toVals, 1000)
    .easing(TWEEN.Easing.Linear.None)
    .interpolation(TWEEN.Interpolation.Bezier)
    .onComplete(() =>
      @getNewTweens()
      @pathTween.start()
      #@rotTween.start()
    )

  @init: (@playerShip) =>
    @leftIsDown = false
    @upIsDown = false
    @rightIsDown = false
    @downIsDown = false
    @rollRight = false
    @rollLeft = false
    @spaceIsDown = false

    @getNewTweens()

    document.addEventListener('keydown', @onDocumentKeyDown, false);
    document.addEventListener('keyup', @onDocumentKeyUp, false);

  @onDocumentKeyDown: (event) =>
    switch event.keyCode
      when 32
        if !@spaceIsDown
          #console.log("GEtting new tween")
          @getNewTweens()
          @pathTween.start()
          #@rotTween.start()
        @spaceIsDown = true
      when 65 then @leftIsDown = true
      when 37 then @leftIsDown = true
      when 87 then @upIsDown = true
      when 38 then @upIsDown = true
      when 68 then @rightIsDown = true
      when 39 then @rightIsDown = true
      when 83 then @downIsDown = true
      when 40 then @downIsDown = true
      when 69 then @rollRight = true
      when 81 then @rollLeft = true

  @onDocumentKeyUp: (event) =>
    switch event.keyCode
      when 32
        @spaceIsDown = false
        @pathTween.stop()
        #@rotTween.stop()
      when 65 then @leftIsDown = false
      when 37 then @leftIsDown = false
      when 87 then @upIsDown = false
      when 38 then @upIsDown = false
      when 68 then @rightIsDown = false
      when 39 then @rightIsDown = false
      when 83 then @downIsDown = false
      when 40 then @downIsDown = false
      when 69 then @rollRight = false
      when 81 then @rollLeft = false