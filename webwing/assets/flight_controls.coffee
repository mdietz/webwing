class window.FlightControls

  @getUpdatedPosition: () =>
    newShip = @playerShip.model.clone()
    newShip.translateZ(@playerShip.speed/10)
    newShip.position.clone()

  @getUpdatedRotation: () =>
    newShip = @playerShip.model.clone()
    if @leftIsDown
      if @upIsDown or @downIsDown
        Util.rotObj(newShip, Util.zAxis, -Math.PI/60)
      else
        Util.rotObj(newShip, Util.yAxis, Math.PI/60)
    if @rightIsDown
      if @upIsDown or @downIsDown
        Util.rotObj(newShip, Util.zAxis, Math.PI/60)
      else
        Util.rotObj(newShip, Util.yAxis, -Math.PI/60)
    if @rollRight
      Util.rotObj(newShip, Util.zAxis, Math.PI/60)
    if @rollLeft
      Util.rotObj(newShip, Util.zAxis, -Math.PI/60)
    if @upIsDown
      Util.rotObj(newShip, Util.xAxis, Math.PI/60)
    if @downIsDown
      Util.rotObj(newShip, Util.xAxis, -Math.PI/60)
    newRot = newShip.quaternion.clone()
    newRot

  @getNewTweens: =>
    newPos = @getUpdatedPosition()
    startPos = @playerShip.model.position
    newRot = @getUpdatedRotation().normalize()
    toVals = {position:{x:newPos.x, y:newPos.y, z:newPos.z}, quaternion:{x:newRot.x, y:newRot.y, z:newRot.z, w:newRot.w}}

    @pathTween = new TWEEN.Tween(@playerShip.model)
    .to(toVals, 100)
    .easing(TWEEN.Easing.Linear.None)
    .interpolation(TWEEN.Interpolation.Bezier)
    .onComplete(() =>
      @getNewTweens()
      @pathTween.start()
    )

  @init: (@playerShip) =>
    @leftIsDown = false
    @upIsDown = false
    @rightIsDown = false
    @downIsDown = false
    @rollRight = false
    @rollLeft = false
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
          @playerShip.fireDouble()
      when 65, 37
        if !@leftIsDown
          #console.log("Left down")
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
        if !@rollLeft
          @rollLeft = true
          @recomputeTweens()
      when 187
        @speedUp = true
        if @playerShip.speed < 200
          @playerShip.speed += 20
          @recomputeTweens()
      when 189
        @speedDown = true
        if @playerShip.speed > 0
          @playerShip.speed -= 20
          @recomputeTweens()

  @onDocumentKeyUp: (event) =>
    switch event.keyCode
      when 32
        @spaceIsDown = false
      when 65, 37
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
        @rollLeft = false
        @recomputeTweens()
    if !@upIsDown and !@downIsDown and !@rightIsDown and !@leftIsDown and !@rollRight and !@rollLeft and @playerShip.speed == 0
      @pathTween.stop()
