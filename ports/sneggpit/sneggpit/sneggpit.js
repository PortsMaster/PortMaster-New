const UI = app.require('ui');
const isSquare = app.width === app.height;
const is3to2 = app.width*2 === app.height*3;
const is4to3 = app.width*3 === app.height*4;
const arenaW = isSquare ? 24 : is4to3 ? 28 : is3to2 ? 30 :app.width>app.height ? 32 : 18;
const arenaH = isSquare ? 24 : is4to3 ? 21 : is3to2 ? 20 : app.width>app.height ? 18 : 32;
const tileSz=Math.floor(Math.min(app.width/arenaW,app.height/arenaH));
const tileImg = app.getResource('snegg_tiles.svg', {centerX:0.5, centerY:0.5, scale:8*tileSz/256});
const tiles = app.createTileResources(tileImg, 4,4, 0)
const fontSc = isSquare ? Math.max(1, Math.floor(app.width/360)) : app.width<1280 ? 1 : Math.floor(app.width/640);
const fontGame = fontSc==1 ? 0 : app.createImageFontResource(0, {scale:fontSc});
const FRAMES_PER_SEC = 60;
const engineVersion = 20231218;
const debug = false;

const texScanLines = new Uint32Array(app.height), texBg = new Uint32Array(app.height);
for(var i=0; i<texScanLines.length; ++i) {
	if(i%4 === 0)
		texScanLines[i] = 0xFFffFFff;
	texBg[i] = lerpRGBA(0x003355ff, 0x005533ff, i/(texScanLines.length-1));
}
const scanLines = app.createImageResource({width:1, height:texScanLines.length, data:texScanLines});
const bgGradient = app.createImageResource({width:1, height:texBg.length, data:texBg});

const audio = app.require('audio');
audio.volume(0.7);
const sfx = {
	start: audio.createSound('sin', 1760,.8,.05,0.1, 1760,0.1,.05,1, 1760,0.0,.05,1,
		1760,.8,0,0.1, 1760,.8,.05,1, 1760,0.1,.05,1, 1760,0.0,.05,1,
		1760,.8,0,0.1, 1760,.8,.05,1, 1760,0.1,.05,1, 1760,0.0,.6,1),
	harvest: audio.createSound('squ', 40,0.8,0,0.1, 800,0.4,0.07,0.5),
	step: audio.createSound('tri', 165,0.6,0.01,1),
	chomp: audio.createSound('squ', 60,0.8,0.0,0.5, 40,0.8,0.15,0.5, 40,.8,0.35,0.5),
	egg: audio.createSound('tri', 880,.8,.05,0.95, 880,0.1,.05,0.9, 880,0.0,.6,0.5),
	hatch: audio.createSound('squ', 440,0.5,0.0,0.8, 440,0.5,0.1,0.5, 660,0.7,0,0.5, 660,0.7,0.2,0.5, 660,0.15,0.1,0.5, 660,0,0.5,0.5),
};
const meloHighScoreVoc1 = '{w:squ a:.025 d:.025 s:.25 r:.05 b:270} C4/4 C4/8 G3/8 C4/4 D4/4 E4/4 D4/4 C4/4 E4/4 C4/4 G3/4 C4/4 G3/4 C4/2';
const meloHighScoreVoc2 = '{w:saw a:.025 d:.025 s:.25 r:.05 b:270} G3/4       -/4 G3/4  -/4 C4/4  -/4 G3/4  -/4 G3/4  -/4 E3/4  -/4 C3/2';

const TERRAIN_SAND=0, TERRAIN_ROCK=-1, PI2 = Math.PI/2;
const COLOR_HEAD = 0xffbb55cc, COLOR_TAIL=0xffbb557f, COLOR_EGG = 0xffFFff7f, COLOR_EGGHATCH = 0xffFFffcc;
const COLOR_SAND = 0x0000007f, COLOR_ROCK=0xaaaaaa00, COLOR_PLAYER0=0xff7f55ff, COLOR_PLAYER1 = 0x55aaFFff;

const Entities = {
	counter: 0,
	instances: {},
	register: function(ent) {
		const id = ++this.counter;
		this.instances[id] = ent;
		return id;
	},
	unregister: function(ent) {
		delete this.instances[ent.id];
	},
	reset: function() {
		this.counter = 0;
		this.instances = {};
	},
	get: function(id) { return this.instances[id]; },
	serialize: function() {
		ents = [];
		for(var id in this.instances)
			ents.push(this.instances[id].serialize());
		return ents;
	}
};

function Arena(tileMap, arenaW,arenaH) {
	const TILE_QUAD = 3;

	this.width = arenaW;
	this.height = arenaH;
	const terrain = new Int8Array(arenaW*arenaH);
	const tiles = new Uint32Array(arenaW*arenaH);
	tiles.fill(TILE_QUAD);
	const colors = new Uint32Array(arenaW*arenaH);
	colors.fill(COLOR_SAND);
	this.entities = new Array2d(arenaW, arenaH, Uint32Array);

	this.numEggs = 0;
	this.eggProbability = 0.5;
	this.eggProbabilityNoEggs = 0.9;
	this.currEggProbability = function() {
		return this.numEggs ? this.eggProbability : this.eggProbabilityNoEggs;
	}

	this.at = function(x,y) {
		if(y===undefined) {
			y = x%arenaW;
			x = Math.floor(x%arenaW);
		}
		if(x<0 || y<0 || x>=arenaW || y>=arenaH)
			return TERRAIN_ROCK;
		return terrain[y*arenaW+x];
	}
	this.nb = function(x,y,dir) {
		const pos = y*arenaW+x;
		switch(dir%4) {
		case 0: return {x:x, y:y-1};
		case 1: return {x:x+1, y:y};
		case 2: return {x:x, y:y+1};
		case 3: return {x:x-1, y:y};
		}
	}
	this.index = function(pos) { return pos.y*arenaW + pos.x; }
	this.set = function(x,y, value) {
		const idx = y*arenaW+x;
		terrain[idx] = value;
		colors[idx] = value == TERRAIN_SAND ? COLOR_SAND : COLOR_ROCK;
	}
	this.draw = function(gfx) {
		gfx.drawTiles(tileMap, arenaW,arenaH, tiles, colors);
	}
}

function Snake(arena, x,y,dir, id) {
	this.x = x;
	this.y = y;
	this.dir = dir;
	this.id = id ? id : Entities.register(this);
	this.prev = this.next = null;
	arena.entities.set(this.x, this.y, this.id);

	var tNextUpdate = id ? 0 : Math.floor(FRAMES_PER_SEC*0.25);
	var tHatch = id ? 0 : rnd.int(8*FRAMES_PER_SEC, 16*FRAMES_PER_SEC);

	this.serialize = function() {
		return {type:'Snake', id:this.id, x:this.x, y:this.y, dir:this.dir };
	}

	this.remove = function(entities) {
		if(!this.prev) {
			const idx = entities.indexOf(this);
			if(idx>=0)
				entities.splice(idx, 1);
			Entities.unregister(this);
		}
		if(arena.entities.at(this.x, this.y)==this.id)
			arena.entities.set(this.x, this.y, 0);
		if(this.next)
			this.next.remove();
	}
	this.update = function(events) {
		--tNextUpdate;
		--tHatch;
		const isEgg = this.is('egg');
		if(isEgg && tHatch>0) {
			arena.entities.set(this.x, this.y, this.id); // might be overwritten by parent
			return;
		}
		if(tNextUpdate>0)
			return;
		tNextUpdate = Math.floor(FRAMES_PER_SEC*0.2);

		const prevx = this.x, prevy = this.y;
		var entAt = null;
		if(rnd.int(8)===0) {
			this.dir += rnd.int(2) ? 5 : 3;
			this.dir %= 4;
		}
		else switch(this.dir) {
		case 0:
			entAt = Entities.get(arena.entities.at(this.x, this.y-1));
			if(this.y>0 && arena.at(this.x, this.y-1) >= 0 && (!entAt || entAt==this || entAt.is('player')))
				--this.y;
			else
				this.dir = 1 + 2*rnd.int(2);
			break;
		case 1:
			entAt = Entities.get(arena.entities.at(this.x+1, this.y));
			if(this.x<arena.width-1 && arena.at(this.x+1, this.y) >= 0 && (!entAt || entAt==this || entAt.is('player')))
				++this.x;
			else
				this.dir = 2*rnd.int(2);
			break;
		case 2:
			entAt = Entities.get(arena.entities.at(this.x, this.y+1));
			if(this.y<arena.height-1 && arena.at(this.x, this.y+1) >= 0 && (!entAt || entAt==this || entAt.is('player')))
				++this.y;
			else
				this.dir = 1 + 2*rnd.int(2);
			break;
		case 3:
			entAt = Entities.get(arena.entities.at(this.x-1, this.y));
			if(this.x>0 && arena.at(this.x-1, this.y) >= 0 && (!entAt || entAt==this || entAt.is('player')))
				--this.x;
			else
				this.dir = 2*rnd.int(2);
			break;
		}
		if(this.x === prevx && this.y === prevy)
			return;
		if(entAt && entAt.is('player') && entAt.state === 'alive')
			events.push({ type:'chomp', x:this.x, y:this.y, who:this.id, what:entAt.id});

		arena.entities.set(this.x, this.y, this.id);
		if(tHatch<=0) {
			if(isEgg)
				events.push({ type:'hatch', x:this.x, y:this.y, who:this.id });
			else if(rnd.num(1) < arena.currEggProbability()) {
				const evt = { type:'egg', x:prevx, y:prevy };
				const tail = this.tail();
				if(tail!=this) {
					evt.x = tail.x;
					evt.y = tail.y;
				}
				events.push(evt);
			}
			else {
				const tail = this.tail();
				events.push({ type:'grow', x:tail.x, y:tail.y, who:this.id });
			}
			tHatch = rnd.int(8*FRAMES_PER_SEC, 16*FRAMES_PER_SEC);
		}
		if(this.next)
			this.next.followTo(prevx, prevy);
		else if(arena.entities.at(prevx, prevy)==this.id)
			arena.entities.set(prevx, prevy, 0);
	}
	this.draw = function(gfx, numPrev) {
		if(numPrev === undefined)
			numPrev = 0;
		const numSucc = this.next ? this.next.draw(gfx, numPrev+1) : 0;
		const isEgg = this.is('egg'), isHatch = (!isEgg||tHatch>FRAMES_PER_SEC) ? false : (Math.floor(10*tHatch/FRAMES_PER_SEC)%2 == 1);
		if(!this.prev)
			gfx.color(isHatch ? COLOR_EGGHATCH : isEgg ? COLOR_EGG : COLOR_HEAD).drawImage(
				tiles+(isHatch ? 2 : isEgg ? 1 : this.dir===3 ? 0: 4), this.x*tileSz, this.y*tileSz, this.dir*PI2);
		else {
			const sz4 = tileSz*0.375;
			gfx.save().color((numPrev<2 || numSucc>2) ? COLOR_TAIL : (COLOR_TAIL-(3-numSucc)*16));
			gfx.transform(this.x*tileSz, this.y*tileSz,this.dir*PI2).fillRect(-sz4,sz4,2*sz4,-tileSz);
			gfx.restore();
		}
		return numSucc + 1;
	}

	this.tail = function() {
	var tail = this;
	while(tail.next)
		tail = tail.next;
	return tail;
	},
	this.followTo = function(x,y) {
		const prevx = this.x, prevy = this.y;
		this.x = x;
		this.y = y;
		this.dir = dirTo(this.x,this.y, this.prev.x,this.prev.y);
		if(this.next)
			this.next.followTo(prevx, prevy);
		else if(arena.entities.at(prevx, prevy)==this.id)
			arena.entities.set(prevx, prevy, 0);

	}
	this.grow = function(delta) {
		if(delta === undefined)
			delta = 1;
		var tail = this.tail();
		var nextSegPos = arena.nb(tail.x, tail.y, tail.dir+2);
		while(arena.at(nextSegPos.x, nextSegPos.y)===TERRAIN_SAND && --delta>=0) {
			const w = new Snake(arena, nextSegPos.x, nextSegPos.y, tail.dir, this.id);
			w.prev = tail;
			tail.next = w;
			nextSegPos = arena.nb(w.x, w.y, tail.dir+2);
			tail = w;
		}
	}
	this.is = function(what) { return what === 'egg' ? (!this.next && !this.prev) : what === 'snake'; }
}

function Player(arena, x,y, counter) {
	this.x = x;
	this.y = y;
	this.vel = this.score = 0;
	this.dir = 1;
	this.img = 11;
	this.id = Entities.register(this);
	this.color = (counter===0) ? COLOR_PLAYER0 : COLOR_PLAYER1;
	arena.entities.set(this.x, this.y, this.id);
	this.state = 'start';
	var tNextUpdate = FRAMES_PER_SEC/2;

	this.serialize = function() {
		return {type:'Player', id:this.id, x:this.x, y:this.y, score:this.score};
	}

	this.update = function(events) {
		if(--tNextUpdate>0)
			return;
		if(this.state === 'start')
			this.state = 'alive';
		if(!this.vel)
			return;
		tNextUpdate = Player.updateInterval;

		const prevx = this.x, prevy = this.y;
		var entAt = null;
		switch(this.dir) {
		case 0:
			entAt = Entities.get(arena.entities.at(this.x, this.y-1));
			if(this.y>0 && arena.at(this.x, this.y-1) >= 0 && (!entAt || entAt.is('egg')))
				--this.y;
			break;
		case 1:
			entAt = Entities.get(arena.entities.at(this.x+1, this.y));
			if(this.x<arena.width-1 && arena.at(this.x+1, this.y) >= 0 && (!entAt || entAt.is('egg')))
				++this.x;
			break;
		case 2:
			entAt = Entities.get(arena.entities.at(this.x, this.y+1));
			if(this.y<arena.height-1 && arena.at(this.x, this.y+1) >= 0 && (!entAt || entAt.is('egg')))
				++this.y;
			break;
		case 3:
			entAt = Entities.get(arena.entities.at(this.x-1, this.y));
			if(this.x>0 && arena.at(this.x-1, this.y) >= 0 && (!entAt || entAt.is('egg')))
				--this.x;
			break;
		}
		if(this.x === prevx && this.y === prevy)
			return;
		if(entAt && entAt.is('egg'))
			events.push({ type:'harvest', x:this.x, y:this.y, who:this.id, dir:this.dir, what:entAt.id});
		else
			events.push({ type:'step', x:this.x, y:this.y, who:this.id, dir:this.dir});
		arena.entities.set(this.x, this.y, this.id);
		arena.entities.set(prevx, prevy, 0);
	}

	this.draw = function(gfx) {
		const isBlink = this.state==='start' && (tNextUpdate%Math.floor(FRAMES_PER_SEC*0.3)) < FRAMES_PER_SEC*0.2;
		const color = isBlink ? 0xFFffFFff :
			tNextUpdate%FRAMES_PER_SEC < -0.85*FRAMES_PER_SEC ? this.color-0x55 : this.color;
		const tile = this.state==='start' ? this.img : this.state=='alive' ? this.img : 5;
		gfx.color(color).drawImage(tiles + tile, this.x*tileSz, this.y*tileSz, 0, isBlink ? 1.2  : 1);
	}

	this.setDir = function(dir) {
		if(dir>=0) {
			this.dir = dir%4;
			this.vel = 1;
			switch(this.dir) {
			case 0: this.img = (this.img%4==2) ? 6 : 7; break;
			case 1: this.img = 11; break;
			case 2: this.img = (this.img%4==2) ? 14 : 15; break;
			case 3: this.img = 10; break;
			}
		}
		else
			this.vel = 0;
	}
	this.is = function(what) { return what === 'player'; }
}
Player.updateInterval = Math.floor(FRAMES_PER_SEC*0.15);

var localHighscore = parseInt(localStorage.getItem("highscore")) || 0;
var arena = null, entities = [], players = [];

function LevelDefault(arena) {
	this.name = 'default';
	this.players = [];
	this.snakes = [];
	this.scoreAt = [{x:arena.width/2-3,y:0},{x:arena.width/2,y:0}];
	arena.eggProbability = 0.5;

	this.update = function(frame) {
		if(frame%(5*FRAMES_PER_SEC))
			return false;
		for(var i=0; i<5; ++i) { // 5 attempts
			var x = rnd.int(arena.width), y = rnd.int(arena.height);
			if(arena.at(x,y)!=TERRAIN_SAND || arena.entities.at(x,y))
				continue;
			arena.set(x, y, TERRAIN_ROCK);
			return {type:'rock', x:x, y:y};
		}
		return false;
	}

	for(var i=arena.width/2-3, end = arena.width/2+3; i<end; ++i)
		arena.set(i,0, TERRAIN_ROCK);
	for(var i=0, nRocks = Math.max(arena.width, arena.height); i<nRocks; ++i) {
		const x = rnd.int(arena.width), y = rnd.int(arena.height);
		if(arena.at(x,y)) {
			--i;
			continue;
		}
		arena.set(x,y, TERRAIN_ROCK);
	}

	const entAt = {};
	var numEggs = 0;
	while(this.snakes.length < 6) {
		const x = rnd.int(4, arena.width-4), y = rnd.int(4, arena.height-4), coord = x+':'+y;
		if(arena.at(x,y)!== TERRAIN_SAND || entAt[coord])
			continue;
		const len = numEggs === 0 ? 1 : numEggs>=3 ? rnd.int(2,7) : rnd.int(1,7);
		if(len === 1)
			++numEggs;
		const dir = rnd.int(4);
		this.snakes.push({x:x, y:y, dir:dir, length:len});
		entAt[coord] = true;

		var pos = arena.nb(x, y, dir+2);
		for(var i=1; i<len && arena.at(pos.x, pos.y)===TERRAIN_SAND; ++i) {
			entAt[pos.x+':'+pos.y] = true;
			pos = arena.nb(pos.x, pos.y, dir+2);
		}
	}

	while(this.players.length < 2) {
		const x = rnd.int(1, arena.width-2), y = rnd.int(1, arena.height-2), coord = x+':'+y;
		if(arena.at(x,y)!== TERRAIN_SAND || entAt[coord])
			continue;
		var snakeFound = false;
		for(var dir=0; dir<4 && !snakeFound; ++dir) {
			var pos = arena.nb(x,y, dir);
			for(var dist=0; dist<3 && !snakeFound; ++dist) {
				snakeFound = entAt[pos.x+':'+pos.y];
				if(!snakeFound)
					pos = arena.nb(pos.x,pos.y, dir);
			}
		}
		if(snakeFound)
			continue;
		this.players.push({ x:x, y:y });
		entAt[coord] = true;
	}
}

function ScreenGame(numPlayers, usePointerInput) {
	var touchStart = null;
	var touchEnd = null;
	var level = null;
	var state = 'init';
	var msg = '';
	var buttonState = {};
	var axisState = [[0,0], [0,0]];
	var frame = 0;
	var tLastFrame = 0;
	var journal = null;
	var ui = new UI({
		font: fontGame,
		fg: 0xFFffFF55,
		bg: 0,
		fgFocus: 0xFFffFFaa,
		bgFocus: 0,
		padding: 2,
		hLine: 32*fontSc,
		lineWidth:0
	});

	this.enter = function() {
		app.setPointer(0);
		frame = tLastFrame = 0;
		Entities.reset();
		entities.length = players.length = 0;
		const seed = Math.floor(Math.random()*Number.MAX_SAFE_INTEGER); // the only unknown random
		rnd.seed(seed);
		arena = new Arena(tiles, arenaW,arenaH);
		journal = numPlayers==1 ? [ engineVersion, seed, arena.width,arena.height ] : null;
		level = new LevelDefault(arena);

		for(var i=0; i<numPlayers; ++i) {
			var player = new Player(arena, level.players[i].x, level.players[i].y, i);
			entities.push(player);
			players.push(player);
		}
		audio.replay(sfx.hatch, 0.2, 0, 2);

		for(var i=0; i<level.snakes.length; ++i) {
			const w = level.snakes[i];
			var snake = new Snake(arena, w.x, w.y, w.dir);
			snake.grow(w.length-1);
			entities.push(snake);
			if(!snake.next)
				++arena.numEggs;
		}

		ui.reset([
			{ type:'button', x:app.width/2-120*fontSc, y:app.height/2-30*fontSc, w:240*fontSc, h:40*fontSc,
				label:'C O N T I N U E', callback:function() { togglePlayPause(); }},
			{ type:'button', x:app.width/2-120*fontSc, y:app.height/2+10*fontSc, w:240*fontSc, h:40*fontSc,
				label:'L E A V E   G A M E', callback:function() { app.on(ScreenAttract); }},
			{ type:'slider', x:app.width/2-120*fontSc, y:app.height/2+70*fontSc, w:240*fontSc, h:20*fontSc,
				label:'AUDIO VOLUME', style:{lineWidth:1}, value:audio.volume(),
				callback:function(value) { audio.volume(value); }},
		]);
		ui.select(true);

		if(typeof scores === 'object')
			scores.requestMin(level.name);
		state = 'running';
		msg = '';
	}
	const togglePlayPause = function() {
		if(state === 'running')
			state = 'pause';
		else if(state === 'pause')
			state = 'running';
	}

	this.keyboard = function(evt) {
		app.setPointer(0);
		app.emitAsGamepadEvent(evt, 0, ['ArrowLeft','ArrowRight', 'ArrowUp','ArrowDown'], ['Enter' ]);
		app.emitAsGamepadEvent(evt, 1, ['a','d', 'w','s'], ['Tab']);

		if(evt.type==='keydown') switch(evt.key) {
		case ' ':
			if(state==='over')
				return app.on(ScreenAttract);
			break;
		case 'GoBack':
		case 'Escape':
		case 'p':
		case 'MediaPlayPause':
			togglePlayPause();
			break;
		}
	}

	this.gamepad = function(evt) {
		if(evt.index === 0)
			gamepadMapping.apply(evt);

		if(evt.type==='button' && (evt.button in {6:true,7:true})) {
			buttonState[evt.button] = evt.value===1;
			if(buttonState[6] && buttonState[7])
				return app.close();
		}
		if(state === 'pause')
			return ui.handleGamepad(evt);

		var dir = -1;
		if(evt.type==='axis' && evt.index<players.length && state==='running') {
			if(evt.axis===0 || evt.axis===2) {
				if(evt.value>0.9) {
					dir = 1;
					axisState[evt.index][0] = 1.0;
				}
				else if(evt.value<-0.9) {
					dir = 3;
					axisState[evt.index][0] = -1.0;
				}
				else {
					axisState[evt.index][0] = 0;
					if(axisState[evt.index][1])
						dir = (axisState[evt.index][1]==1.0) ? 2 : 0;
				}
			}
			else if(evt.axis===1 || evt.axis===3) {
				if(evt.value>0.9) {
					dir = 2;
					axisState[evt.index][1] = 1.0;
				}
				else if(evt.value<-0.9) {
					dir = 0;
					axisState[evt.index][1] = -1.0;
				}
				else {
					axisState[evt.index][1] = 0;
					if(axisState[evt.index][0])
						dir = (axisState[evt.index][0]==1.0) ? 1 : 3;
				}
			}
			players[evt.index].setDir(dir);
		}
		else if(evt.type==='button') {
			if(state==='over')
				return app.on(ScreenAttract);
			if(evt.button in {6:true,7:true}) {
				buttonState[evt.button] = evt.value===1;
				if(evt.value===1)
					togglePlayPause();
			}
		}
	}

	this.pointer = function(evt) {
		app.setPointer(evt.pointerType==='mouse');
		if(state === 'pause')
			return ui.handlePointer(evt);

		touchEnd = {x:evt.x, y:evt.y};
		if(evt.type==='start') {
			touchStart = {x:evt.x, y:evt.y};
			app.emit('gamepad', {index:0, type:'axis', axis:0, value:0}); // stop immediately
			app.emit('gamepad', {index:0, type:'axis', axis:1, value:0});
			return;
		}
		if(!touchStart)
			return;

		const dx = touchEnd.x - touchStart.x;
		const dy = touchEnd.y - touchStart.y;
		const dxSqr = dx*dx, dySqr = dy*dy;
		if(evt.type==='move') {
			const quotSqr = dxSqr/dySqr;
			if(quotSqr > 1/16 && quotSqr < 16)
				return;
		}
		const deltaSqr = dxSqr+dySqr;
		if(deltaSqr<100) {
			const sc =  1.5*tileSz;
			if(evt.type==='end' && evt.x>=app.width-sc && evt.y<sc)
				togglePlayPause();
			return;
		}

			touchStart = null;
		if(dxSqr>dySqr)
			app.emit('gamepad', {index:0, type:'axis', axis:0, value:dx>0?1:-1});
		else
			app.emit('gamepad', {index:0, type:'axis', axis:1, value:dy>0?1:-1});
	}

	this.update = function(deltaT, now) {
		if(state==='pause')
			return ui.update(deltaT, now);
		if(state!=='running')
			return;
		tLastFrame += deltaT;
		if(tLastFrame < 0.95/FRAMES_PER_SEC)
			return;
		tLastFrame = 0;
		++frame;
		const events = [];
		for(var i = 0; i < entities.length; ++i)
			entities[i].update(events);

		for(var i=0; i<events.length; ++i) {
			const evt = events[i];
			if(debug && evt.type!=='step') {
				evt.frame = frame;
				console.log(evt);
			}
			switch(evt.type) {
			case 'egg':
				audio.replay(sfx.egg, 0.25, 2*evt.x/arena.width - 1, rnd.int(-6,7));
				entities.push(new Snake(arena, evt.x, evt.y, rnd.int(4)));
				++arena.numEggs;
				break;
			case 'harvest': {
				if(journal)
					journal.push(frame, evt.dir);
				const ent = Entities.get(evt.what), idx = entities.indexOf(ent);
				if(idx>=0) {
					Entities.get(evt.who).score += entities.length - players.length;
					ent.remove(entities);
					arena.entities.set(evt.x, evt.y, evt.who);
					--arena.numEggs;
				}
				if(entities.length <= players.length)
					gameOver(true);
				audio.replay(sfx.harvest, 0.25, 2*evt.x/arena.width - 1, rnd.int(13));
				break;
			}
			case 'hatch':
				audio.replay(sfx.hatch, 0.2, 2*evt.x/arena.width - 1);
				--arena.numEggs;
				// fallthrough
			case 'grow':
				Entities.get(evt.who).grow();
				break;
			case 'chomp':
				Entities.get(evt.what).state = 'dead';
				audio.replay(sfx.chomp, 0.25, 2*evt.x/arena.width - 1);
				gameOver(false);
				break;
			case 'step':
				if(journal)
					journal.push(frame, evt.dir);
				audio.replay(sfx.step, 0.125, 2*evt.x/arena.width - 1, evt.dir);
				break;
			}
		}
		if('update' in level) {
			const evt = level.update(frame);
			if(debug && evt) {
				evt.frame = frame;
				console.log(evt);
			}
		}
		if(debug && state==='running') console.log(Entities.serialize());
	}

	this.draw = function(gfx) {
		const sz2 = tileSz/2, ox = app.width/2-tileSz*arena.width/2+sz2;
		gfx.transform(ox, app.height/2-tileSz*arena.height/2+sz2);
		gfx.color(0xFFffFFff).stretchImage(bgGradient, -tileSz/2,-tileSz/2,arena.width*tileSz, arena.height*tileSz);
		arena.draw(gfx);
		for(var i=0; i<entities.length; ++i)
			entities[i].draw(gfx);

		for(var i=0; i<Math.max(2, players.length); ++i) {
			const score = lpad(i<players.length ? players[i].score : localHighscore, 4);
			const x = level.scoreAt[i].x*tileSz-tileSz/2, y = level.scoreAt[i].y*tileSz + 1-tileSz/2;
			gfx.color(i<players.length ? players[i].color : 0xFFff55aa);
			gfx.fillText(x,y, score, fontGame);
		}
		gfx.reset();
		if(state==='pause')
			ui.draw(gfx);
		if(usePointerInput) {
			const sc = 1.5*tileSz;
			gfx.save().transform(app.width-sc,0).color(0xffffff55).lineWidth(2*fontSc);
			gfx.drawLine(sc*0.25, sc*0.25, sc*0.75, sc*0.25);
			gfx.drawLine(sc*0.25, sc*0.5, sc*0.75, sc*0.5);
			gfx.drawLine(sc*0.25, sc*0.75, sc*0.75, sc*0.75);
			gfx.restore();
		}
		if(msg)
			gfx.fillText(app.width/2,app.height/2, msg, fontGame, gfx.ALIGN_CENTER_MIDDLE);
		if(tileSz>=32)
			gfx.color(0x00000055).stretchImage(scanLines, 0,0,app.width,app.height);
	}
	const finalize = function(bestScore, isGlobalHigh) {
		if(state!=='over')
			return;
		if(bestScore > localHighscore) {
			localHighscore = bestScore;
			localStorage.setItem("highscore", bestScore);
		}
		if(isGlobalHigh && journal)
			app.on(new ScreenSubmit(bestScore, level.name, journal));
		else
			app.on(ScreenAttract);
	}
	const gameOver = function(isVictory) {
		var bestScore=0;
		for(var i=0; i<players.length; ++i)
			if(players[i].score > bestScore)
				bestScore = players[i].score;
		if(journal)
			journal.push(frame, bestScore);
		const isLocalHigh = bestScore > localHighscore;
		const isGlobalHigh = (typeof scores === 'object' && scores.min>=0 && bestScore > scores.min && journal);
		msg = (isLocalHigh || isGlobalHigh) ? 'N E W   H I G H S C O R E' :
			isVictory ? 'V I C T O R Y' : 'G A M E   O V E R';
		state = 'over';
		if(isVictory || isLocalHigh || isGlobalHigh) setTimeout(function() {
			audio.melody(meloHighScoreVoc1, 0.25, +0.5);
			audio.melody(meloHighScoreVoc2, 0.25, -0.5);
		}, 600);
		setTimeout(function(score, isGlobalHigh) { finalize(score, isGlobalHigh) },
			(isVictory || isLocalHigh || isGlobalHigh) ? 5000 : 4000, bestScore, isGlobalHigh);
	}
};

function replay(journal, verbose) {
	const out = verbose ? function() { console.log([].slice.call(arguments)) } : function() { }; 
	if(!Array.isArray(journal) || journal.length<6) {
		out('invalid journal');
		return -5;
	}
	const frameCount = journal.pop();
	const version = journal[0], seed = journal[1],  arenaW = journal[2], arenaH = journal[3];
	const dbg = debug || verbose;
	if(dbg)
		console.log({version:version, seed:seed, arenaW:arenaW, arenaH:arenaH, frames:frameCount});

	rnd.seed(seed);
	Entities.reset();
	const arena = new Arena(0, arenaW,arenaH);
	const level = new LevelDefault(arena);
	const player = new Player(arena, level.players[0].x, level.players[0].y, i);
	const entities = [player];

	for(var i=0; i<level.snakes.length; ++i) {
		const w = level.snakes[i];
		var snake = new Snake(arena, w.x, w.y, w.dir);
		snake.grow(w.length-1);
		entities.push(snake);
	}

	var frame = 0, idx = 4, running = true;

	while(running && frame<=frameCount) {
		++frame;
		player.vel = 0;
		if(idx<journal.length) {
			const moveFrame = journal[idx];
			if(moveFrame === frame) {
				if(idx>4 && frame - journal[idx-2] < Player.updateInterval) {
					out('player moves too fast at frame', frame)
					return -4;
				}
				player.setDir(journal[++idx]);
				++idx;
			}
		}

		const events = [];
		for(var i = 0; i < entities.length; ++i)
			entities[i].update(events);

		for(var i=0; i<events.length; ++i) {
			const evt = events[i];
			if(dbg && evt.type!=='step') {
				evt.frame = frame;
				console.log(evt);
			}
			switch(evt.type) {
			case 'egg':
				++arena.numEggs;
				rnd.int(-6,7);
				entities.push(new Snake(arena, evt.x, evt.y, rnd.int(4)));
				break;
			case 'harvest': {
				const ent = Entities.get(evt.what), entIdx = entities.indexOf(ent);
				if(entIdx>=0) {
					player.score += entities.length - 1;
					ent.remove(entities);
					arena.entities.set(evt.x, evt.y, evt.who);
					--arena.numEggs;
				}
				if(entities.length <= 1)
					running = false;
				rnd.int(13);
				break;
			}
			case 'hatch':
				--arena.numEggs;
				// fallthrough
			case 'grow':
				Entities.get(evt.who).grow();
				break;
			case 'chomp':
				running = false;
				break;
			case 'step':
				break;
			}
		}
		if('update' in level) {
			const evt = level.update(frame);
			if(dbg && evt) {
				evt.frame = frame;
				console.log(evt);
			}
		}
		if(dbg && frame%1===0) console.log(Entities.serialize());
	}
	if(frame !== frameCount) {
		out('frame count mismatch', frame, frameCount);
		return -2;
	}
	out('calculated score:', player.score);
	return player.score;
}

if(typeof module == 'object' && module.exports) // node.js
	module.exports = { replay:replay };