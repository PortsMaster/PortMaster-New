const rnd = {
    rng: Math.random,
    seed: function(seed) {
        const seedrandom = (typeof require !== 'undefined') ?
            require('./seedrandom.min') : Math.seedrandom;
        this.rng = new seedrandom(seed);
        return seed;
    },
    int: function(v1, v2) {
        if(v2===undefined) { v2=v1; v1=0; }
        const value = Math.floor(v1) + Math.floor(this.rng()*(v2-v1));
        //console.log({rnd_int: value});
        return value;
    },
    num: function(v1) {
        const value = this.rng()*v1;
        //console.log({rnd_num: value});
        return value;
    }
};

function angleTo(x1,y1, x2,y2) {
    return Math.atan2(y2-y1, x2-x1);
}

function dirTo(x1,y1, x2,y2) {
    const PI2 = Math.PI/2;
    return (Math.round(angleTo(x1,y1, x2,y2)/PI2) + 5) % 4;
}

function lpad(value, numDigits, char) {
    if(char===undefined)
        char = '0';
    var s = ''+value;
    if((typeof value === 'string') || value>=0)
        while(s.length<numDigits)
            s = char+s;
    return s;
}

function rpad(value, numChars, char) {
    if(char===undefined)
        char = ' ';
    var s = ''+value;
    while(s.length<numChars)
        s += char;
    return s;
}

function clamp(v, min, max) {
    return v<min ? min : v>max ? max : v;
}

function lerp(v0, v1, t) {
    return (1-t)*v0 + t*v1;
}

function lerpRGBA(color0, color1, t) {
    const colors = new Uint32Array(2);
    colors[0] = color0 & 0xFFffFFff;
    colors[1] = color1 & 0xFFffFFff;
    const ui = new Uint8Array(colors.buffer);
    ui[0] = lerp(ui[0], ui[4], t);
    ui[1] = lerp(ui[1], ui[5], t);
    ui[2] = lerp(ui[2], ui[6], t);
    ui[3] = lerp(ui[3], ui[7], t);
    return ui[3] | (ui[2]<<8) | (ui[1]<<16) | (ui[0]<<24);
}

if(!('fill' in Uint8Array.prototype)) // polyfill for duktape
    Uint8Array.prototype.fill = Uint32Array.prototype.fill = function(value, begin, end) {
        if(typeof value === 'string')
            value = value.charCodeAt(0);
        if(begin === undefined)
            begin = 0;
        if(end === undefined)
            end = this.length;
        for(var i=begin; i<end; ++i)
            this[i] = value;
    }

function Array2d(width, height, array) {
    var data = new array(width*height);
    this.at = function(x,y) {
        if(y===undefined) {
            y = x%width;
            x = Math.floor(x%width);
        }
        if(x>=0 && y>=0 || x<width || y<height)
            return data[y*width+x];
    }
    this.nb = function(x,y,dir) {
        switch(dir%4) {
        case 0: return {x:x, y:y-1};
        case 1: return {x:x+1, y:y};
        case 2: return {x:x, y:y+1};
        case 3: return {x:x-1, y:y};
        }
    }
    this.set = function(x,y, value) {
        data[y*width+x] = value;
    }
}

function GamepadMapping(args) {
	var mapping = null;
	for(var i=1; i< args.length; ++i) {
		if(args[i-1] == '--buttonMapping') {
			if(!mapping)
				mapping = {};
			mapping.buttons = app.args[i].split(' ');
		}
		else if(args[i-1] == '--axisMapping') {
			if(!mapping)
				mapping = {};
			mapping.axes = app.args[i].split(' ');
		}
	}
	if(mapping) for(var key in mapping) {
		const arr = mapping[key];
		for(var i=0; i<arr.length; ++i)
			arr[i] = Number(arr[i]);
	}
    this.apply = function(evt) {
        if(!mapping)
            return;
        if(evt.type === 'button' && mapping.buttons)
            evt.button = evt.button<mapping.buttons.length ? mapping.buttons[evt.button] : -1;
        else if(evt.type === 'axis' && mapping.axes) {
            evt.axis = evt.axis<mapping.axes.length ? mapping.axes[evt.axis] : -1;
        }
    }
}
const gamepadMapping = new GamepadMapping(app.args);

if(typeof module == 'object' && module.exports) // node.js
	module.exports = { rnd:rnd, Array2d:Array2d, dirTo:dirTo };

