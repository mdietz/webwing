class window.StarDestroyer extends Ship
  laserBolts: []
  nextLaser: 0

  constructor: (name, initPos, initRot) ->
    console.log("star_destroyer const")
    super(name, initPos, initRot, "static/res/star_destroyer/star-wars-star-destroyer.obj", "static/res/star_destroyer/star-wars-star-destroyer.mtl", 0xff0000)
