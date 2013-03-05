# Coffeescript port of snd.js by OutsideOfSociety
# http://oos.moxiecode.com/js_webgl/xwing/snd.js

class window.Sound

  @init: () =>
  	@numOfChannels = 6
  	@audiochannels = []
  	for i in [0..@numOfChannels]
  		@audiochannels[i] = new Array()
  		if Audio != undefined
  			@audiochannels[i]["channel"] = new Audio()
  		@audiochannels[i]["finished"] = -1

    @soundOn = true
  	if Audio == undefined
  	  @soundOn = false

    if Audio != undefined
      @blasterSound = new Audio("static/snd/blaster.ogg");
      @explodeSound = new Audio("static/snd/explode.ogg");

      @worldMusic = new Audio("static/snd/music.ogg");
      @worldMusic.volume = 0.1;
      @worldMusic.loop = true;
      @worldMusic.play();

  @toggleSound: (bool) =>
	  @soundOn = bool

  	if (Audio == undefined)
  		@soundOn = false

  	if !@soundOn
  		@worldMusic.pause();
  	else
  		@worldMusic.play();

  @playSound: (id, vol) =>
  	if !@soundOn || Audio == undefined
  		return

  	volume = 1
  	if vol != undefined
  		volume = vol

  	for i in [0..@numOfChannels]
  		thistime = new Date()
  		if @audiochannels[i]["finished"] < thistime.getTime()
  			@audiochannels[i]["finished"] = thistime.getTime() + id.duration*1000
  			@audiochannels[i]["channel"].src = id.src
  			@audiochannels[i]["channel"].load()
  			@audiochannels[i]["channel"].volume = volume
  			@audiochannels[i]["channel"].play()
  			break