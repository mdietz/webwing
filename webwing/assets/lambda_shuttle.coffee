class window.LambdaShuttle extends Ship
  laserBolts: []
  nextLaser: 0

  constructor: (name, initPos, initRot) ->
    console.log("star_destroyer const")
    super(name, initPos, initRot, "static/res/lambda_shuttle/lambda_shuttle_new2.obj", "static/res/lambda_shuttle/lambda_shuttle_new2.mtl", 0xff0000)
