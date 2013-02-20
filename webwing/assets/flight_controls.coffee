class window.FlightControls

  @init: =>
    @leftIsDown = false
    @upIsDown = false
    @rightIsDown = false
    @downIsDown = false
    @rollRight = false
    @rollLeft = false
    @spaceIsDown = false
    document.addEventListener('keydown', @onDocumentKeyDown, false);
    document.addEventListener('keyup', @onDocumentKeyUp, false);

  @onDocumentKeyDown: (event) =>
    switch event.keyCode
      when 32 then @spaceIsDown = true
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
      when 32 then @spaceIsDown = false
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