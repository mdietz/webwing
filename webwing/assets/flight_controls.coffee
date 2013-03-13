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

  @getUpdatedRotation2: () =>
    newShip = @playerShip.model.clone()
    if @yMovement > 0
      Util.rotObj(newShip, Util.xAxis, Math.min((@yMovement*@yMovement/40000.0)*Math.PI/30, Math.PI/30))
    else
      Util.rotObj(newShip, Util.xAxis, Math.max((@yMovement*@yMovement*-1.0/40000.0)*Math.PI/30, -Math.PI/30))

    if @xMovement > 0
      Util.rotObj(newShip, Util.yAxis, Math.max((@xMovement*@xMovement*-1.0/40000.0)*Math.PI/30, -Math.PI/30))
    else
      Util.rotObj(newShip, Util.yAxis, Math.min((@xMovement*@xMovement/40000.0)*Math.PI/30, Math.PI/30))

    newRot = newShip.quaternion.clone()
    newRot

  @getNewTweens: =>
    newPos = @getUpdatedPosition()
    startPos = @playerShip.model.position
    newRot = @playerShip.model.quaternion.clone().normalize()
    if @pointerLock
      newRot = @getUpdatedRotation2().normalize()
    else
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
    @pointerLock = false
    @xMovement = 0
    @yMovement = 0

    @getNewTweens()
    @recomputeTweens()

    document.addEventListener('keydown', @onDocumentKeyDown, false);
    document.addEventListener('keyup', @onDocumentKeyUp, false)
    document.addEventListener("mousemove", @onMouseMove, false)

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

  @onMouseMove: (e) =>
    movementX = e.movementX       ||
                e.mozMovementX    ||
                e.webkitMovementX ||
                0
    movementY = e.movementY       ||
                e.mozMovementY    ||
                e.webkitMovementY ||
                0
    if @pointerLock
      @xMovement = Math.max(Math.min(@xMovement + movementX, 200), -200)
      @yMovement = Math.max(Math.min(@yMovement + movementY, 200), -200)
      console.log("movementX=" + movementX, "movementY=" + movementY)
      console.log("xVal=" + @xMovement, "yVal=" + @yMovement)
