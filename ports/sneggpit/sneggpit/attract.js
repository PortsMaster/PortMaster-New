const screenAttractSprites = app.getResource('snegg_attract.svg',
	{centerX:0.5, centerY:0.5, scale:(app.width>app.height) ? (tileSz/24) : (tileSz/40)});
const titleImg = app.createTileResource(screenAttractSprites, 0,0,1,0.5);
const iconStart0 = app.createTileResource(screenAttractSprites, 0,0.5, 6/45,0.5);
const iconStart1 = app.createTileResource(screenAttractSprites, 21/45,0.5, 6/45,0.5);
const iconStart2 = app.createTileResource(screenAttractSprites, 27/45,0.5, 6/45,0.5);
const iconEludi = app.createTileResource(screenAttractSprites, 18/45,0.5, 3/45,3/12);
const iconClose = app.createTileResource(screenAttractSprites, 18/45,0.75, 3/45,3/12);
const iconMusicOff = app.createTileResource(screenAttractSprites, 33/45,0.5, 3/45,3/12);
const iconMusicOn = app.createTileResource(screenAttractSprites, 33/45,0.75, 3/45,3/12);
const iconStar = app.createTileResource(screenAttractSprites, 36/45,0.5, 3/45,3/12);

const marqueeText = "+++ oh no, your friend CURSY   has fallen into a pit full of dangerous snakes   "
  + "+++ steal the snakes' eggs   to prevent them from spawning "
  + "+++ use the arrow keys, a gamepad, or swipe gestures to move and evade "
  + "+++ how long can you survive? +++";
const titleTheme = app.getResource('snegg_theme.mp3');

function LevelAttract(arena) {
	this.name = 'attract';
	this.players = [{x:0,y:0},{x:5,y:0}];
	this.snakes = [];
	this.scoreAt = [{x:0,y:0},{x:5,y:0}];
	arena.eggProbability = 0.3;

	this.update = function(frame) {
		if(frame%(4*FRAMES_PER_SEC))
			return;
		while(true) {
			var x = rnd.int(arena.width), y = rnd.int(arena.height);
			if(arena.entities.at(x,y))
				continue;
			arena.set(x, y, arena.at(x,y)===TERRAIN_SAND ? TERRAIN_ROCK : TERRAIN_SAND);
			return;
		}
	}

	for(var i=0, nRocks = 2*Math.max(arena.width, arena.height); i<nRocks; ++i)
		arena.set(rnd.int(arena.width), rnd.int(arena.height), TERRAIN_ROCK);

	const entAt = {};
	while(this.snakes.length < 5) {
		const x = rnd.int(4, arena.width-4), y = rnd.int(4, arena.height-4), coord = x+':'+y;
		if(arena.at(x,y)!== TERRAIN_SAND || - entAt[coord])
			continue;
		this.snakes.push({x:x, y:y, dir:rnd.int(4), length:rnd.int(1,7)});
		entAt[coord] = true;
	}
}

function MarqueeInstructions() {
	const sz2 = tileSz/2;
	const ox = app.width/2-tileSz*arenaW/2+sz2;
	const oy = app.height/2 + tileSz*arenaH/2 + sz2 - 48*fontSc;

	this.x = app.width/2 + tileSz*arenaW/2 + 150;
	this.text = marqueeText;
	this.width = this.text.length * 12 * fontSc;
	this.type = 'instructions';

	this.update = function(deltaT) {
		this.x -= deltaT*60*fontSc;
		return this.x > -this.width;
	}
	this.draw = function(gfx) {
		gfx.clipRect(ox+24*fontSc-sz2, 0, arenaW*tileSz-48*fontSc, app.height);
		gfx.color(0x0000007f).fillText(this.x+2*fontSc, oy+2*fontSc, this.text, fontGame);
		gfx.color(0xffffff7f).fillText(this.x, oy, this.text, fontGame);
		gfx.color(COLOR_PLAYER0).drawImage(tiles+10, this.x+12*29.5*fontSc, oy+7*fontSc);
		gfx.color(COLOR_HEAD).drawImage(tiles+0, this.x+12*78.5*fontSc, oy+7*fontSc, 1.5*Math.PI);
		gfx.color(COLOR_EGG).drawImage(tiles+1, this.x+12*107.5*fontSc, oy+7*fontSc);
		gfx.clipRect(false);	
	}
}

function MarqueeHighscore() {
	const sz2 = tileSz/2;
	const ox = app.width/2-tileSz*arenaW/2+sz2;
	const oy = app.height/2 + tileSz*arenaH/2 + sz2 - 48*fontSc;

	this.x = app.width/2 + tileSz*arenaW/2 + 150;
	this.text = 'BEST SCORE: '+localHighscore;
	this.width = this.text.length * 12 * fontSc;
	this.type = 'highscore';

	this.update = function(deltaT) {
		this.x -= deltaT*60*fontSc;
		return this.x > -this.width;
	}
	this.draw = function(gfx) {
		gfx.clipRect(ox+24*fontSc-sz2, 0, arenaW*tileSz-48*fontSc, app.height);
		gfx.color(0x0000007f).fillText(this.x+2*fontSc, oy+2*fontSc, this.text, fontGame);
		gfx.color(0xffffff7f).fillText(this.x, oy, this.text, fontGame);
		gfx.color(0xffff55aa).drawImage(tiles+9,this.x-12*fontSc, oy+7*fontSc);
		gfx.drawImage(tiles+9,this.x+this.width+13*fontSc, oy+7*fontSc);
		gfx.clipRect(false);	
	}
}

const AnimationPulsate = {
	now: 0,
	update: function(deltaT, now) { this.now = now; },
	apply: function(props) {
		if(!props.isSelected)
			return;
		const sc = 0.8 + 0.4 * Math.abs(Math.sin(this.now*Math.PI));
		const cx = props.x + props.w/2, cy = props.y+props.h/2;
		props.w *= sc;
		props.h *= sc;
		props.x = cx - props.w/2;
		props.y = cy - props.h/2;
	}
}

function toggleMusic() {
	const vol = ScreenAttract.musicVolume;
	ScreenAttract.musicVolume = vol ? 0 : 0.4;
	audio.volume(ScreenAttract.music, ScreenAttract.musicVolume);
	ScreenAttract.ui.get('music').image = vol ? iconMusicOff : iconMusicOn;
}

var ScreenAttract = {
	level: null,
	frame: 0,
	marquee: null,
	usePointerInput: false,
	numPlayers: (Array.isArray(app.args) && app.args.indexOf('--players')>=0 && app.args.indexOf('--players') < app.args.length-1) ?
		parseInt(app.args[app.args.indexOf('--players')+1]) : 
		app.args.players ? parseInt(app.args.players) : 1,
	ui: new UI({
		font: fontGame,
		fg: 0xFFffFF68,
		bg: 0,
		fgFocus: 0xFFffFFaa,
		bgFocus: 0,
		padding: 2,
		hLine: 32*fontSc,
		lineWidth:0
	}),
	music: -1,
	musicVolume: 0.4,
	buttonState: {},

	enter: function() {
		const sSz = app.queryImage(iconStart0).width*0.9, sSz2=sSz/2;
		const uiData = [
			{ type:'button', id:'start1', x:app.width*(this.numPlayers===1?0.5:0.33)-sSz2, y:app.height*0.65-sSz2, w:sSz, h:sSz,
				image:this.numPlayers===1?iconStart0:iconStart1, animation: AnimationPulsate,
				callback:function() { app.on(new ScreenGame(1, this.usePointerInput)); }},
			{ type:'button',  id:'eludi', x:0, y:0, w:tileSz*1.5, h:tileSz*1.5, animation: AnimationPulsate,
				image:iconEludi, callback:function() { app.openURL('https://eludi.net'); }},
			{ type:'button',  id:'music', x:app.width-tileSz*3, y:0, w:tileSz*1.5, h:tileSz*1.5,
				image:this.musicVolume ? iconMusicOn : iconMusicOff, animation: AnimationPulsate, callback:toggleMusic },
			{ type:'button', id:'close', x:app.width-tileSz*1.5, y:0, w:tileSz*1.5, h:tileSz*1.5,
				image:iconClose, animation: AnimationPulsate, callback:function() { app.close(); }},
		];
		if(typeof scores === 'object')
			uiData.splice(2,0, { type:'button',  id:'scores', x:tileSz*1.5, y:0, w:tileSz*1.5, h:tileSz*1.5, animation: AnimationPulsate,
			image:iconStar, callback:function() { app.on(new ScreenScores()); }});
		this.ui.reset(uiData);
		if(this.numPlayers > 1)
			this.ui.insert({ type:'button',  id:'start2', x:app.width*0.67-sSz2, y:app.height*0.65-sSz2, w:sSz, h:sSz,
				image:iconStart2,  animation: AnimationPulsate, callback:function() { app.on(new ScreenGame(2)); }}, 1);

		this.ui.select(0);
		this.marquee = localHighscore ? new MarqueeHighscore() : new MarqueeInstructions();

		this.frame = 0;
		Entities.reset();
		entities.length = players.length = 0;
		arena = new Arena(tiles, arenaW,arenaH);
		this.level = new LevelAttract(arena);

		for(var i=0; i<this.level.snakes.length; ++i) {
			const w = this.level.snakes[i];
			var snake = new Snake(arena, w.x, w.y, w.dir);
			snake.grow(w.length-1);
			entities.push(snake);
		}
		//audio.melody("{w:saw a:.025 d:.025 s:.25 r:.05 b:170} B4/8 C5/8 B4/8 E5/8 D#5/8 C5/8 {w:saw a:.025 d:.025 s:.5 r:1 b:170} B4/2", 0.2);
		if(this.music === -1)
			this.music = audio.replay(titleTheme, this.musicVolume);
	},
	leave: function() {
		audio.fadeOut(this.music, 0.5);
		setTimeout(function(music) { audio.stop(music);}, 500, this.music);
		this.music = -1;
	},

	keyboard: function(evt) {
		app.setPointer(0);
		if(evt.key===' ')
			evt.key = 'Enter';
		this.ui.handleKeyboard(evt);
	},

	gamepad: function(evt) {
		gamepadMapping.apply(evt);
		if(evt.type==='button' && (evt.button in {6:true,7:true})) {
			this.buttonState[evt.button] = evt.value===1;
			if(this.buttonState[6] && this.buttonState[7])
				return app.close();
		}
		this.ui.handleGamepad(evt);
	},

	pointer: function(evt) {
		app.setPointer(evt.pointerType==='mouse');
		this.usePointerInput = true;
		this.ui.handlePointer(evt);
	},

	update: function(deltaT, now) {
		++this.frame;
		const events = [];
		for(var i = 0; i < entities.length; ++i)
			entities[i].update(events);

		for(var i=0; i<events.length; ++i) {
			const evt = events[i];
			switch(evt.type) {
			case 'egg':
				entities.push(new Snake(arena, evt.x, evt.y, rnd.int(4)));
				if(entities.length > 33)
					entities[rnd.int(entities.length)].remove(entities);
				break;
			case 'hatch':
			case 'grow':
				Entities.get(evt.who).grow();
				break;
			}
		}
		if('update' in this.level)
			this.level.update(this.frame);

		this.ui.update(deltaT, now);
		if(!this.marquee.update(deltaT))
			this.marquee = (!localHighscore || this.marquee.type === 'highscore') ? 
				new MarqueeInstructions() : new MarqueeHighscore();
		if(this.music>=0 && now > 30 && !audio.playing(this.music))
			this.music = audio.replay(titleTheme, this.musicVolume);
	},

	draw: function(gfx) {
		const sz2 = tileSz/2, ox = app.width/2-tileSz*arenaW/2+sz2;
		gfx.transform(ox, app.height/2-tileSz*arenaH/2+sz2);
		gfx.color(0xFFffFFff).stretchImage(bgGradient, -tileSz/2,-tileSz/2,arenaW*tileSz, arenaH*tileSz);
		arena.draw(gfx);
		for(var i=0; i<entities.length; ++i)
			entities[i].draw(gfx);
		gfx.reset();

		gfx.color(0xffffffaa).drawImage(titleImg, app.width/2, app.height*0.3);
		this.ui.draw(gfx);
		this.marquee.draw(gfx);

		if(tileSz>=32)
			gfx.color(0x00000055).stretchImage(scanLines, 0,0,app.width,app.height);
	}
};

app.on(ScreenAttract);
