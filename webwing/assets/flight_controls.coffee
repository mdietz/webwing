class window.FlightControls
  #@getInterstitialModel: (distance) =>
  #  newShip = @playerShip.model.clone()
  #  newShip.translateZ(Math.sin(Math.PI/4)*distance)
  #  newShip.translateX(distance - Math.sin(Math.PI/4)*distance)
  #  newShip.position.clone()

  @getBezierControl1: () =>
    newShip = @playerShip.model.clone()
    #speed = 2PIr/4
    r = 4*@playerShip.speed/(2*Math.PI)
    d1 = r
    d2 = Math.sqrt((r*r)/2.0)
    #d2 = Math.sqrt((d1*d1)/2.0)
    dist = d1*0.5522847498
    dist2 = d2*0.5522847498
    if !@leftIsDown and !@rightIsDown and !@upIsDown and !@downIsDown and !@rollLeft and !@rollRight
      newShip.translateZ(@playerShip.speed*(1.0/3.0))
    else if (@leftIsDown or @rightIsDown or @rollLeft or @rollRight) and (@upIsDown or @downIsDown)
      newShip.translateZ(dist2)
    else
      newShip.translateZ(dist)
    newShip.position.clone()

  @getBezierControl2: () =>
    newShip = @playerShip.model.clone()
    r = 4*@playerShip.speed/(2*Math.PI)
    d1 = r
    d2 = Math.sqrt((r*r)/2.0)
    #d2 = Math.sqrt((d1*d1)/2.0)
    dist = d1*0.5522847498
    dist2 = d2*0.5522847498
    if @leftIsDown or @rollRight
      if @downIsDown or @upIsDown
        newShip.translateX(d2-dist2)
      else
        newShip.translateX(d1-dist)
    if @rightIsDown or @rollLeft
      if @downIsDown or @upIsDown
        newShip.translateX(-1*(d2-dist2))
      else
        newShip.translateX(-1*(d1-dist))
    if @downIsDown
      if @leftIsDown or @rightIsDown or @rollLeft or @rollRight
        newShip.translateY(d2-dist2)
      else
        newShip.translateY(d1-dist)
    if @upIsDown
      if @leftIsDown or @rightIsDown or @rollLeft or @rollRight
        newShip.translateY(-1*(d2-dist2))
      else
        newShip.translateY(-1*(d1-dist))
    if !@leftIsDown and !@rightIsDown and !@upIsDown and !@downIsDown and !@rollLeft and !@rollLeft
      newShip.translateZ(@playerShip.speed*(2.0/3.0))
    else if (@leftIsDown or @rightIsDown or @rollLeft or @rollRight) and (@upIsDown or @downIsDown)
      newShip.translateZ(d2)
    else
      newShip.translateZ(r)
    newShip.position.clone()

  @getUpdatedModel: () =>
    newShip = @playerShip.model.clone()
    r = 4*@playerShip.speed/(2*Math.PI)
    dist = r
    dist2 = Math.sqrt((r*r)/2.0)
    #dist2 = Math.sqrt((dist*dist)/2.0)
    if @leftIsDown or @rollRight
      if @downIsDown or @upIsDown
        newShip.translateX(dist2)
      else
        newShip.translateX(dist)
    if @rightIsDown or @rollLeft
      if @downIsDown or @upIsDown
        newShip.translateX(-dist2)
      else
        newShip.translateX(-dist)
    if @downIsDown
      if @leftIsDown or @rightIsDown or @rollRight or @rollLeft
        newShip.translateY(dist2)
      else
        newShip.translateY(dist)
    if @upIsDown
      if @leftIsDown or @rightIsDown or @rollRight or @rollLeft
        newShip.translateY(-dist2)
      else
        newShip.translateY(-dist)
    if !@leftIsDown and !@rightIsDown and !@upIsDown and !@downIsDown and !@rollRight and !@rollLeft
      newShip.translateZ(@playerShip.speed)
    else if (@leftIsDown or @rightIsDown or @rollRight or @rollLeft) and (@upIsDown or @downIsDown)
      newShip.translateZ(dist2)
    else
      newShip.translateZ(dist)
    newShip.position.clone()

  @getUpdateRotations: () =>
    newShip = @playerShip.model.clone()
    if @yawLeft
      Util.rotObj(newShip, Util.zAxis, -Math.PI/2)
    if @rollRight
      Util.rotObj(newShip, Util.zAxis, Math.PI/2)
    if @upIsDown
      Util.rotObj(newShip, Util.xAxis, Math.PI/2)
    if @downIsDown
      Util.rotObj(newShip, Util.xAxis, -Math.PI/2)
    if @leftIsDown
        Util.rotObj(newShip, Util.yAxis, Math.PI/2)
    if @rightIsDown
      Util.rotObj(newShip, Util.yAxis, -Math.PI/2)
    newRot = newShip.quaternion.clone()
    newRot

  @getNewTweens: =>
    newPos = @getUpdatedModel()
    ctrlPos1 = @getBezierControl1()
    ctrlPos2 = @getBezierControl2()
    startPos = @playerShip.model.position
    #console.log(ctrlPos1)
    #console.log(ctrlPos2)
    #console.log(newPos)

    #@rotTween = new TWEEN.Tween(@playerShip.model.rotation)
    #.to({x:0, y:[@playerShip.model.rotation.y+Math.PI/4, @playerShip.model.rotation.y+Math.PI/2], z:0}, 1000)
    #.easing(TWEEN.Easing.Linear.None)
    #.interpolation(TWEEN.Interpolation.CatmullRom)

    newRot = @getUpdateRotations().normalize()
    #newRot = @playerShip.model.quaternion.clone().multiply(new THREE.Quaternion(0, Math.sqrt(0.5), 0, Math.sqrt(0.5))).normalize()
    #console.log(@playerShip.model.quaternion)
    console.log(newRot)
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
    @yawLeft = false
    @spaceIsDown = false
    @speedUp = false
    @speedDown = false

    @getNewTweens()

    document.addEventListener('keydown', @onDocumentKeyDown, false);
    document.addEventListener('keyup', @onDocumentKeyUp, false);

  @recomputeTweens: () =>
    @pathTween.stop()
    @getNewTweens()
    @pathTween.start()

  @onDocumentKeyDown: (event) =>
    switch event.keyCode
      when 32
        if !@spaceIsDown
          @spaceIsDown = true
          @recomputeTweens()
      when 65, 37
        if !@leftIsDown
          console.log("Left down")
          @leftIsDown = true
          @recomputeTweens()
      when 87, 38
        if !@upIsDown
          @upIsDown = true
          @recomputeTweens()
      when 68, 39
        if !@rightIsDown
          @rightIsDown = true
          @recomputeTweens()
      when 83, 40
        if !@downIsDown
          @downIsDown = true
          @recomputeTweens()
      when 69
        if !@rollRight
          @rollRight = true
          @recomputeTweens()
      when 81
        if !@yawLeft
          @yawLeft = true
          @recomputeTweens()
      when 187
        @speedUp = true
        if @playerShip.speed < 200
          @playerShip.speed += 20
          console.log("Speed: " + @playerShip.speed)
          @recomputeTweens()
      when 189
        @speedDown = true
        if @playerShip.speed > 0
          @playerShip.speed -= 20
          console.log("Speed: " + @playerShip.speed)
          @recomputeTweens()

  @onDocumentKeyUp: (event) =>
    switch event.keyCode
      when 32
        @spaceIsDown = false
        @pathTween.stop()
      when 65, 37
        console.log("Left lifted")
        @leftIsDown = false
        @recomputeTweens()
      when 87, 38
        @upIsDown = false
        @recomputeTweens()
      when 68, 39
        @rightIsDown = false
        @recomputeTweens()
      when 83, 40
        @downIsDown = false
        @recomputeTweens()
      when 69
        @rollRight = false
        @recomputeTweens()
      when 81
        @yawLeft = false
        @recomputeTweens()
