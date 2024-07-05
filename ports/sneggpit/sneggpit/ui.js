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

if(!('copyWithin' in Uint8Array.prototype)) // polyfill for duktape
	Uint8Array.prototype.copyWithin = Uint32Array.prototype.copyWithin = function(dst, begin, end) {
		if(begin === undefined)
			begin = 0;
		if(end === undefined)
			end = this.length;
		if(dst<begin)
			for(; begin<end; ++begin, ++dst)
				this[dst] = this[begin];
		else {
			var count = Math.min(end-begin, this.length-dst);
			for(var i = dst+count, j=begin+count-1; i-->dst; --j)
				this[i] = this[j];
		}
	}

app.exports('ui', (function() {
	function alignStr2enum(str) {
		var ret = 0;
		if(typeof str === 'number')
			return str;
		if(typeof str === 'string') {
			if(str.indexOf('center')>=0)
				ret += 1;
			else if(str.indexOf('right')>=0)
				ret += 2;
			if(str.indexOf('middle')>=0)
				ret += 4;
			else if(str.indexOf('bottom')>=0)
				ret += 8;
		}
		return ret;
	}

	function mergeProperties(obj1, obj2) {
		const ret = Object.assign({}, obj1);
		if((typeof obj2 === 'object') && (obj2 !== null))
			for(var key in obj2)
				ret[key] = obj2[key];
		return ret;
	}

	const factories = {};
	var root = null;

	const Container = function(style, isNested) {
		this.items = [];
		this.itemsById = {};
		this.selIndex = -1;
		this.isSelected = !isNested;
		if(!isNested)
			root = this;

		var virtualKeyboard = null;
		this.requestVirtualKeyboard = function(target) {
			if(isNested)
				return false;
			if(!target.isSelected && virtualKeyboard && virtualKeyboard.target === target) {
				setTimeout(function() { virtualKeyboard = null; }, 0);
			}
			else if(target.isSelected) {
				if(virtualKeyboard && virtualKeyboard.target === target)
					return;
				const w = Math.min(app.width, 400);
				const h = 120;
				const x = app.width<400 ? 0 : (target.align & 2) ? target.x-w : (target.align & 1) ? target.x-w/2 : target.x;
				const y = target.x + target.h + h < app.height ? target.y + target.h : target.y - h;
				virtualKeyboard = factories['keyboard']({ x:x, y:y, w:w, h:h, target:target }, style);
			}
		}

		var hasSelItems = false;
		this.select = function(isSelected) {
			const isSelectLocked = this.selIndex >= 0 && this.items[this.selIndex].isSelectLocked;
			if(!isSelectLocked) {
				if(typeof isSelected === 'string') {
					this.selIndex = -1;
					const item = this.get(isSelected);
					if(item) {
						for(var i=this.items.length; i-->0 && this.selIndex<0; )
							if(item===this.items[i])
								this.selIndex = i;
						isSelected = true;
						item.select(true);
					}
				}
				else if(typeof isSelected === 'number' && isSelected < this.items.length) {
					this.selIndex = isSelected;
					isSelected = true;
					this.items[this.selIndex].select(true);
				}
				this.isSelected = isSelected;
			}
			if(!isSelected && this.selIndex >= 0 && this.items[this.selIndex].isSelected && !isSelectLocked) {
				this.items[this.selIndex].select(false);
				this.selIndex = -1;
			}
			else if(isSelected && this.selIndex<0 && !isSelectLocked) {
				do {
					this.selIndex = (this.selIndex+1)%this.items.length;
				} while(!('isSelected' in this.items[this.selIndex]));
				this.items[this.selIndex].select(true);
			}
			return isSelected && this.selIndex >= 0 ? this.items[this.selIndex] : null;
		}
		this.pointer = this.handlePointer = function(evt) {
			if(virtualKeyboard && virtualKeyboard.handlePointer(evt))
				return true;
			if(!hasSelItems)
				return false;
			var ret = false;
			for(var i=this.items.length; i-->0; ) {
				var item = this.items[i];
				if('handlePointer' in item)
					ret = item.handlePointer(evt);
				if(!ret)
					continue;
				const isSelectLocked = this.selIndex >= 0 && this.items[this.selIndex].isSelectLocked;
				if(i!=this.selIndex && !isSelectLocked) {
					if(this.selIndex >= 0 && this.items[this.selIndex].isSelected)
						this.items[this.selIndex].select(false, evt.pointerType === 'touch');
					this.selIndex = i;
					this.items[this.selIndex].select(true, evt.pointerType === 'touch');
				}
				break;
			}
			return ret;
		}
		this.gamepad = this.handleGamepad = function(evt) {
			if(evt.type==='button' && evt.value===1) {
				switch(evt.button) {
					case 0:
						return this.handleKeyboard({type:'keydown', key:'Enter'});
					case 1:
						return this.handleKeyboard({type:'keydown', key:'Escape'});
				}
			}
			else if(evt.type==='axis' && (evt.value===1 || evt.value===-1)) {
				if(evt.axis===0 || evt.axis===4 || evt.axis===6)
					return this.handleKeyboard({type:'keydown', key:(evt.value===1) ? 'ArrowRight' : 'ArrowLeft'}/*, evt.name!=='keyboard'*/);
				if(evt.axis===1 || evt.axis===5 || evt.axis===7)
					return this.handleKeyboard({type:'keydown', key:(evt.value===1) ? 'ArrowDown' : 'ArrowUp'}/*, evt.name!=='keyboard'*/);
			}
		}
		this.keyboard = this.handleKeyboard = function(evt, requestVirtualKeyboard) {
			//console.log('ui.handleKeyboard('+JSON.stringify(evt)+')');
			if(!hasSelItems)
				return false;
			if(this.selIndex >= 0 && this.items[this.selIndex].handleKeyboard && this.items[this.selIndex].handleKeyboard(evt))
				return true;
			const isSelectLocked = this.selIndex >= 0 && this.items[this.selIndex].isSelectLocked;
			const selectNext = function(self) {
				if(isSelectLocked)
					return false;
				if(self.selIndex >= 0 && self.items[self.selIndex].isSelected)
					self.items[self.selIndex].select(false, requestVirtualKeyboard);
				do {
					self.selIndex = (self.selIndex + 1) % self.items.length;
				} while(!('isSelected' in self.items[self.selIndex]));
				self.items[self.selIndex].select(true, requestVirtualKeyboard);
				return true;
			}
			const selectPrev = function(self) {
				if(isSelectLocked)
					return false;
				if(self.selIndex >= 0 && self.items[self.selIndex].isSelected)
					self.items[self.selIndex].select(false, requestVirtualKeyboard);
				do {
					self.selIndex = (self.selIndex + self.items.length - 1) % self.items.length;
				} while(!('isSelected' in self.items[self.selIndex]));
				self.items[self.selIndex].select(true, requestVirtualKeyboard);
				return true;
			}
			if(evt.type==='keydown') switch(evt.key) {
			case 'Tab':
				return isNested ? false : evt.shiftKey ? selectPrev(this) : selectNext(this);
			case 'ArrowDown':
				return selectNext(this);
			case 'ArrowUp':
				return selectPrev(this)
			case 'ArrowLeft':
				if((this.selIndex >= 0) && ('deltaValue' in this.items[this.selIndex])) {
					this.items[this.selIndex].deltaValue(-1);
					break;
				}
				return true;
			case 'ArrowRight':
				if((this.selIndex >= 0) && ('deltaValue' in this.items[this.selIndex])) {
					this.items[this.selIndex].deltaValue(+1);
					break;
				}
				return true;
			case 'Enter':
				if(this.selIndex>=0 && (typeof this.items[this.selIndex].callback === 'function'))
					this.items[this.selIndex].callback(this.items[this.selIndex].value, this.items[this.selIndex]);
				return true;
			case 'Escape':
			case 'GoBack':
				if(isNested)
					evt.key = 'Tab';
				return false;
			}
			return false;
		}
		this.update = function(deltaT, now) {
			for(var i=0; i<this.items.length; ++i) {
				var item = this.items[i];
				if('update' in item)
					item.update(deltaT, now);
			}
		}
		this.draw = function(gfx) {
			gfx.save();
			for(var i=0; i<this.items.length; ++i)
				this.items[i].draw(gfx);
			if(virtualKeyboard)
				virtualKeyboard.draw(gfx);
			gfx.restore();
		}
		this.get = function(id) {
			return (typeof id==='number') ? this.items[id] : this.itemsById[id];
		}
		this.insert = function(arg, index) {
			if(index===undefined)
				index = this.items.length;
			if(Array.isArray(arg)) {
				for(var i=0; i<arg.length; ++i)
					this.insert(arg[i], index+i);
				return;
			}
			if(!arg || !(arg.type in factories))
				return;

			const item = factories[arg.type](arg, style);
			if(index >= this.items.length)
				this.items.push(item)
			else
				this.items.splice(index, 0, item);

			if(arg.id)
				this.itemsById[arg.id] = item;
			if('isSelected' in item)
				hasSelItems = true;
			return item;
		}
		this.remove = function(id) {
			const item = this.get(id);
			if(!item)
				return;
			if(item.id)
				delete this.itemsById[id];
			const index = (typeof id==='number') ? id : this.items.indexOf(item);
			if(index == this.selIndex) {
				item.select(false);
				this.selIndex = -1;
			}
			else if(index < this.selIndex)
				--this.selIndex;
			this.items.splice(index, 1);
		}
		this.reset = function(arg) {
			this.items.length = 0;
			this.itemsById = {};
			virtualKeyboard = null;
			this.insert(arg);
		}
	};
	factories.group = function(items, defaultStyle) {
		const grp = new Container(defaultStyle, true);
		grp.insert(items);
		return grp;
	};
	factories.menu = function(args, defaultStyle) {
		const style = mergeProperties(defaultStyle, args.style), menu = new Container(style, true);
		const fontDim = app.queryFont(style.font,'_');
		const align = alignStr2enum(args.align),
			w = args.w||fontDim.width*16,
			hLine = style.hLine || fontDim.height*1.25;
		var x = args.x||0;
		if(align & 2)
			x-=w;
		else if (align & 1)
			x-=w/2;

		for(var i=0, y = args.y || 0; i<args.items.length; ++i, y+=hLine)
			menu.insert({ type:'button', x:x, y:y, w:w, h:hLine, label:args.items[i], value:i, callback:args.callback });
		return menu;
	};

	const Label = function(params, defaultStyle) {
		this.callback = params.callback;
		this.style = mergeProperties(defaultStyle, params.style);
		this.x = params.x;
		this.y = params.y;
		this.w = ('w' in params) ? params.w : 0;
		this.h = ('h' in params) ? params.h : 0;
		this.padding = ('padding' in params) ? params.padding : ('padding' in this.style) ? this.style.padding : 0;
		this.label = ('label' in params) ? params.label : '';
		this.align = alignStr2enum(params.align);
		this.alignContent = alignStr2enum(params.alignContent);

		this.draw = function(gfx) {
			var x = (this.align & 2) ? this.x-this.w : (this.align & 1) ? this.x-this.w/2 : this.x;
			var y = (this.align & 8) ? this.y-this.h : (this.align & 4) ? this.y-this.h/2 : this.y;
			if(this.w && this.h) {
				gfx.color(this.style.bg).fillRect(x, y, this.w, this.h);
				gfx.clipRect(x+this.padding , y+this.padding, this.w-2*this.padding, this.h-2*this.padding);
			}
			x += (this.alignContent & 2) ? (this.w - this.padding) : (this.alignContent & 1) ? this.w/2 : this.padding;
			y += (this.alignContent & 8) ? (this.h - this.padding) : (this.alignContent & 4) ? this.h/2 : this.padding;
			gfx.color(this.style.fg).fillText(x,y, this.label, this.style.font, this.alignContent);
			if(this.w && this.h)
				gfx.clipRect(false);
		}
	};
	factories.label = function(args, defaultStyle) { return new Label(args, defaultStyle); };

	const Button = function(params, defaultStyle) {
		this.callback = params.callback;
		this.style = mergeProperties(defaultStyle, params.style);
		this.x = params.x;
		this.y = params.y;
		this.w = ('w' in params) ? params.w : 100;
		this.h = ('h' in params) ? params.h : 20;
		this.padding = ('padding' in params) ? params.padding : ('padding' in this.style) ? this.style.padding : 0;
		this.align = alignStr2enum(params.align);
		this.label = ('label' in params) ? params.label : '';
		this.image = !('image' in params) ? null : (typeof params.image==='string') ? app.getResource(params.image) : params.image;
		this.imageSelected = !('imageSelected' in params) ? null : (typeof params.imageSelected==='string') ? app.getResource(params.imageSelected) : params.imageSelected;
		this.value = ('value' in params) ? params.value : this.label;
		this.animation = params.animation;
		this.isSelected = false;
		var timeStamp = -1;

		if(this.animation && this.animation.update) {
			this.update = function(deltaT, now) {
				this.animation.update(deltaT, now);
			}
		}

		this.select = function(isSelected) { this.isSelected = isSelected; }
		this.handlePointer = function(evt) {
			const x = (this.align & 2) ? this.x-this.w : (this.align & 1) ? this.x-this.w/2 : this.x;
			const y = (this.align & 8) ? this.y-this.h : (this.align & 4) ? this.y-this.h/2 : this.y;
			if(evt.x<x || evt.y<y || evt.x >= x+this.w || evt.y>=y+this.h)
				this.isSelected = false;
			else
				this.isSelected = true;
			if(this.isSelected && evt.type=='start' && this.callback) {
				if(evt.timeStamp && evt.timeStamp!=timeStamp) { // avoid multiple triggers within single frame
					this.callback(this.value, this);
					timeStamp = evt.timeStamp;
				}
			}
			return this.isSelected;
		}
		this.draw = function(gfx) {
			const style = this.style;
			const x = (this.align & 2) ? this.x-this.w : (this.align & 1) ? this.x-this.w/2 : this.x;
			const y = (this.align & 8) ? this.y-this.h : (this.align & 4) ? this.y-this.h/2 : this.y;
			if(this.imageSelected) {
				gfx.color(this.isSelected ? style.fgFocus : style.fg);
				if(this.isSelected)
					gfx.stretchImage(this.imageSelected, x,y, this.w, this.h);
				else
					gfx.stretchImage(this.image, x,y, this.w, this.h);
			}
			else if(this.animation) {
				const props = {
					isSelected: this.isSelected,
					image: this.image,
					bg: this.isSelected ? style.bgFocus : style.bg,
					fg: this.isSelected ? style.fgFocus : style.fg,
					lw: ('lineWidth' in style) ? style.lineWidth : 1,
					x: x,
					y: y,
					w:this.w,
					h:this.h
				};
				this.animation.apply(props);
				gfx.color(props.bg).fillRect(props.x,props.y,props.w,props.h);
				gfx.color(props.fg);
				if(props.lw>0)
					gfx.lineWidth(props.lw).drawRect(props.x,props.y,props.w,props.h);
				if(props.image)
					gfx.stretchImage(props.image, props.x,props.y,props.w,props.h);
				else {
					gfx.save().transform(props.x+props.w/2, props.y+props.h/2, 0, props.w/this.w);
					gfx.fillText(0,0, this.label, style.font, gfx.ALIGN_CENTER_MIDDLE);
					gfx.restore();
				}
			}
			else {
				gfx.color(this.isSelected ? style.bgFocus : style.bg).fillRect(x,y,this.w,this.h);
				gfx.color(this.isSelected ? style.fgFocus : style.fg);
				const lw = ('lineWidth' in style) ? style.lineWidth : 1;
				if(lw>0)
					gfx.lineWidth(lw).drawRect(x,y,this.w,this.h);
				if(this.image)
					gfx.stretchImage(this.image, x,y, this.w, this.h);
				else
					gfx.fillText(x+this.w/2, y+this.h/2, this.label, style.font, gfx.ALIGN_CENTER_MIDDLE);
			}
		}
	};
	factories.button = function(args, defaultStyle) { return new Button(args, defaultStyle); };

	const Progress = function(params, defaultStyle) {
		this.style = mergeProperties(defaultStyle, params.style);
		this.x = params.x;
		this.y = params.y;
		this.w = ('w' in params) ? params.w : 100;
		this.h = ('h' in params) ? params.h : 20;
		this.valueMin = ('valueMin' in params) ? params.valueMin : 0;
		this.valueMax = ('valueMax' in params) ? params.valueMax : 1.0;
		this.value = ('value' in params) ? params.value : this.valueMin;
		this.padding = ('padding' in params) ? params.padding : ('padding' in this.style) ? this.style.padding : 0;
		this.label = ('label' in params) ? params.label : '';
		this.labelRight = ('labelRight' in params) ? params.labelRight : '';

		this.draw = function(gfx) {
			const style = this.style, pad = this.padding;
			gfx.color(style.bg).fillRect(this.x, this.y, this.w, this.h);
			gfx.color(style.fg);
			gfx.lineWidth(('lineWidth' in style) ? style.lineWidth : 1);
			gfx.fillText(this.x, this.y-pad, this.label, style.font, gfx.ALIGN_BOTTOM);
			gfx.fillText(this.x+this.w, this.y-pad, this.labelRight, style.font, gfx.ALIGN_RIGHT_BOTTOM);
			gfx.drawRect(this.x, this.y, this.w, this.h);
			gfx.fillRect(this.x+pad, this.y+pad, (this.w-2*pad)*this.value/(this.valueMax-this.valueMin), this.h-2*pad);
		}
	};
	factories.progress = function(args, defaultStyle) { return new Progress(args, defaultStyle); };

	const Slider = function(params, defaultStyle) {
		this.callback = params.callback;
		this.style = mergeProperties(defaultStyle, params.style);
		this.x = params.x;
		this.y = params.y;
		this.w = ('w' in params) ? params.w : 100;
		this.h = ('h' in params) ? params.h : 20;
		this.padding = ('padding' in params) ? params.padding : ('padding' in this.style) ? this.style.padding : 0;
		this.handleW = ('handleW' in params) ? params.handleW : (this.h - 2*this.padding)/2;
		this.isSelected = false;
		this.valueMin = ('valueMin' in params) ? params.valueMin : 0;
		this.valueMax = ('valueMax' in params) ? params.valueMax : 1.0;
		this.value = ('value' in params) ? params.value : (this.valueMin + this.valueMax)/2;
		this.step = ('step' in params) ? params.step : 0.1;
		this.label = ('label' in params) ? params.label : '';
		this.labelRight = ('labelRight' in params) ? params.labelRight : '';

		function clamp(value, min, max) {
			return value<min ? min : value>max ? max : value;
		}

		this.select = function(isSelected) { this.isSelected = isSelected; }
		this.deltaValue = function(delta) {
			this.value += this.step*delta;
			this.value = clamp(this.value, this.valueMin, this.valueMax);
			if(this.callback)
				this.callback(this.value, this);
		}
		this.draw = function(gfx) {
			const style = this.style, pad = this.padding;
			gfx.color(this.isSelected ? style.bgFocus : style.bg).fillRect(this.x, this.y, this.w, this.h);
			gfx.color(this.isSelected ? style.fgFocus : style.fg);
			gfx.lineWidth(('lineWidth' in style) ? style.lineWidth : 1);
			gfx.fillText(this.x, this.y-pad, this.label, style.font, gfx.ALIGN_BOTTOM);
			gfx.fillText(this.x+this.w, this.y-pad, this.labelRight, style.font, gfx.ALIGN_RIGHT_BOTTOM);
			gfx.drawRect(this.x, this.y, this.w, this.h);
			const range = this.w-2*pad-this.handleW;
			gfx.fillRect(this.x+pad + range*(this.value-this.valueMin)/(this.valueMax-this.valueMin), this.y+pad, this.handleW, this.h-2*pad);
		}
		this.intersects = function(pos) {
			const x = this.x, y = this.y;
			return pos.x>=x && pos.x < x+this.w && pos.y>=y && pos.y < y+this.h;
		}
		this.handlePointer = function(evt) {
			this.isSelected = this.intersects({x:evt.x, y:evt.y});
			if(this.isSelected && (evt.type==='start' || evt.type==='move') && ('x' in evt)) {
 				const xRel = (evt.x-this.x-this.padding-this.handleW/2)/(this.w-2*this.padding-this.handleW);
				this.value = clamp(this.valueMin + xRel * (this.valueMax-this.valueMin), this.valueMin, this.valueMax);
				if(this.callback)
					this.callback(this.value, this);
			}
			return this.isSelected;
		}
	};
	factories.slider = function(args, defaultStyle) { return new Slider(args, defaultStyle); };

	const Choice = function(params, defaultStyle) {
		this.callback = params.callback;
		this.style = mergeProperties(defaultStyle, params.style);
		this.x = params.x;
		this.y = params.y;
		this.w = ('w' in params) ? params.w : 100;
		this.h = ('h' in params) ? params.h : 20;
		this.padding = ('padding' in params) ? params.padding : ('padding' in this.style) ? this.style.padding : 0;
		this.label = ('label' in params) ? params.label : '';
		this.labelLeft = ('labelLeft' in params) ? params.labelRight : 'O F F';
		this.labelRight = ('labelRight' in params) ? params.labelRight : 'O N';
		this.value = 0;
		this.isSelected = false;

		this.select = function(isSelected) { this.isSelected = isSelected; }

		this.draw = function(gfx) {
			const ox = this.x, oy = this.y;

			const style = this.style, pad = this.padding;
			gfx.color(this.isSelected ? style.bgFocus : style.bg).fillRect(ox, oy, this.w, this.h);
			gfx.color(this.isSelected ? style.fgFocus : style.fg);
			gfx.lineWidth(('lineWidth' in style) ? style.lineWidth : 1);

			gfx.drawRect(ox, oy, this.w, this.h);
			gfx.fillRect(ox+(this.value ? this.w/2 : 0)+this.padding, oy+this.padding,
				this.w/2-2*this.padding, this.h-2*this.padding);

			gfx.fillText(this.x, this.y-pad, this.label, style.font, gfx.ALIGN_LEFT_BOTTOM);

			gfx.color(this.isSelected ? (!this.value ? style.bgFocus : style.fgFocus) : (!this.value ? style.bg : style.fg));
			gfx.fillText(ox+this.w*0.25, oy+this.h/2, this.labelLeft, style.font, gfx.ALIGN_CENTER_MIDDLE);
			gfx.color(this.isSelected ? (this.value ? style.bgFocus : style.fgFocus) : (this.value ? style.bg : style.fg));
			gfx.fillText(ox+this.w*0.75, oy+this.h/2, this.labelRight, style.font, gfx.ALIGN_CENTER_MIDDLE);

		}
		this.intersects = function(pos) {
			const x = this.x, y = this.y;
			return pos.x>=x && pos.x < x+this.w && pos.y>=y && pos.y < y+this.h;
		}

		this.deltaValue = function(delta) {
			if(delta<0) {
				if(!this.value)
					return;
				this.value = 0;
			}
			else {
				if(this.value)
					return;
				this.value = 1;
			}
			if(this.callback)
				this.callback(this.value, this);
		}
		this.handlePointer = function(evt) {
			this.isSelected = this.intersects({x:evt.x, y:evt.y});
			if(this.isSelected && (evt.type==='start' || evt.type==='move') && ('x' in evt)) {
				const xRel = (evt.x-this.x-this.padding)/(this.w-2*this.padding);
				this.value = xRel<0.5 ? 0 : 1;
				if(this.callback)
					this.callback(this.value, this);
			}
			return this.isSelected;
		}
	};
	factories.choice = function(args, defaultStyle) { return new Choice(args, defaultStyle); };

	const Line = function(x1,y1, x2,y2, color, width) {
		this.draw = function(gfx) {
			gfx.color(color).lineWidth(width).drawLine(x1,y1,x2,y2);
		}
	};
	factories.line = function(args) {
		return new Line(args.x1, args.y1, args.x2, args.y2,
			('stroke' in args) ? args.stroke : 0xffffffff, ('lineWidth' in args) ? args.lineWidth : 1);
	};

	const Rectangle = function(x,y, w,h, fill, stroke, lineWidth) {
		this.draw = function(gfx) {
			if(fill!==undefined)
				gfx.color(fill).fillRect(x,y,w,h);
			if(stroke!==undefined)
				gfx.color(stroke).lineWidth(lineWidth).drawRect(x,y,w,h);
		}
	};
	factories.rect = function(args) {
		return new Rectangle(args.x, args.y, args.w, args.h, ('fill' in args) ? args.fill : undefined,
			('stroke' in args) ? args.stroke : undefined, ('lineWidth' in args) ? args.lineWidth : 1);
	};

	const Image = function(name, x,y, w,h, color) {
		var handle = (typeof name==='string') ? app.getResource(name) : name;
		this.draw = function(gfx) {
			gfx.color(color===undefined ? 0xffffffff : color);
			if(w!==undefined && h!==undefined)
				gfx.stretchImage(handle,x,y,w,h);
			else
				gfx.drawImage(handle,x,y);
		}
	};
	factories.img = function(args) {
		return new Image(args.name, args.x, args.y, ('w' in args) ? args.w : undefined,
			('h' in args) ? args.h : undefined, args.color);
	};

	factories.keyboard = function(args, defaultStyle) {
		const kbd = new Container(defaultStyle, true);
		kbd.target = args.target;

		const h=args.h || 120, w =args.w || app.width, x0 = args.x || 0, y0 = args.y || app.height-args.h;
		const layouts = args.layout ? args.layout : {
			abc:['q w e r t y u i o p', 'a s d f g h j k l', 'Shift z x c v b n m Backspace', '123 Space Enter'],
			"123":['1 2 3 4 5 6 7 8 9 0', '! @ # $ % ^ & * ( )', '+ - \' " : ; , . ? Backspace', 'abc Space Enter']
		};
		
		function setLayout(id, shift) {
			shift = shift ? true : false;
			kbd.reset({ type:'rect', x:x0, y:y0, w:w, h:h, fill:defaultStyle.bg});
			const layout = layouts[id];
			const numRows = layout.length;
			const hKey = h / numRows;
			for(var j=0; j<numRows; ++j) {
				const row = layout[j].split(" ");
				const numKeys = row.length;
				const wKey = w / numKeys;
				for(var i=0; i<numKeys; ++i) {
					const value = (row[i] == 'Space') ? ' ' : row[i];
					var callback;
					if(value in layouts)
						callback = function() { setTimeout(function() { setLayout(value); },0); };
					else if(value === 'Shift')
						callback = function() { setTimeout(function() { setLayout(id, !shift); },0);  };
					else {
						const evt = (value.length == 1) ? {char:shift ? value.toUpperCase() : value} : {key:value};
						callback = function() { kbd.target.handleTextInput(evt, true); };
					}
					const label = (value==='Backspace') ? 'BS' : (value==='Shift') ? 'SH' :
						(value.length == 1 && shift) ? value.toUpperCase() : value;
					kbd.insert({type:'button', label:label, x:x0+i*wKey,y:y0+j*hKey,w:wKey, h:hKey, callback:callback });
				}
			}
		}
		setLayout('abc');
		return kbd;
	};

	const TextArea = function(params, defaultStyle) {
		const style = this.style = mergeProperties(defaultStyle, params.style);
		this.x = params.x || 0;
		this.y = params.y || 0;
		this.w = ('w' in params) ? params.w : 320;
		this.h = ('h' in params) ? params.h : 80;

		const fontDim = app.queryFont(style.font,'_');
		const hLine = style.hLine ? style.hLine : fontDim.height, wChar = fontDim.width;
		this.numRows = Math.floor(this.h/hLine);
		this.numCols = Math.floor(this.w/wChar);
		const ox = Math.floor(0.5*(this.w-this.numCols*wChar));
		const oy = Math.floor(0.5*(this.h-this.numRows*hLine));

		this.textBuf = new Uint8Array(this.numRows*this.numCols);
		this.textBuf.fill(' ');
		this.fgCol = new Uint32Array(this.numRows*this.numCols);
		this.fgCol.fill(style.fg);
		this.bgCol = new Uint32Array(this.numRows*this.numCols);
		this.bgCol.fill(style.bg);
		var cursorY=0;

		this.draw = function(gfx) {
			gfx.save().transform(this);
			for(var y=0, i=0; y<this.numRows; ++y) for(var x=0; x<this.numCols; ++x, ++i)
				gfx.color(this.bgCol[i]).fillRect(ox+x*wChar, oy+y*hLine, wChar, hLine);
			for(var y=0, i=0; y<this.numRows; ++y) for(var x=0; x<this.numCols; ++x, ++i)
				gfx.color(this.fgCol[i]).fillText(
					ox+x*wChar, oy+y*hLine, String.fromCharCode(this.textBuf[i]), style.font);
			gfx.restore();
		}	

		this.set = function(x,y, text, fgCol, bgCol) {
			if(y>=this.numRows)
				return;
			if(typeof text !=='string')
				text = ''+text;
			for(var src=0, dest=y*this.numCols+x, end = Math.min(text.length+x, this.numCols); x<end; ++src, ++dest, ++x) {
				this.textBuf[dest] = text.charCodeAt(src);
				if(typeof fgCol=== 'number')
					this.fgCol[dest] = fgCol;
				if(typeof bgCol=== 'number')
					this.bgCol[dest] = fgCol;
			}
		}
		this.get = function(x,y) { 
			return (x<this.numRows && y<this.numCols) ? String.fromCharCode(this.textBuf[x+this.numCols*y]) : undefined;
		}

		this.push = function(text) {
			if(cursorY >= this.numRows) {
				this.textBuf.copyWithin(0, this.numCols);
				this.bgCol.copyWithin(0, this.numCols);
				this.fgCol.copyWithin(0, this.numCols);
				cursorY = this.numRows-1;
			}
			for(var x=0, i=cursorY*this.numCols; x<this.numCols; ++x, ++i) {
				this.textBuf[i] = x<text.length ? text.charCodeAt(x) : 32;
				this.bgCol[i] = style.bg;
				this.fgCol[i] = style.fg;
			}
			++cursorY;
		}

		this.clear = function() {
			this.textBuf.fill(' ');
			cursorY = 0;
		}
	};
	factories.textArea = function(args, defaultStyle) { return new TextArea(args, defaultStyle); };

	const TextInput = function(params, defaultStyle) {
		this.callback = params.callback;
		this.style = mergeProperties(defaultStyle, params.style);
		this.x = params.x;
		this.y = params.y;
		this.w = ('w' in params) ? params.w : 100;
		this.h = ('h' in params) ? params.h : 20;
		this.align = alignStr2enum(params.align);

		this.value = '';
		this.maxlength = ('maxlength' in params) ? params.maxlength : Math.pow(2,31);
		this.isSelected = false;
		this.isSelectLocked = false;
		var visibleBegin=0, visibleEnd = 1;
		var cursorVisible = true, cursorX=0, cursorPos=0;
		const fontDim = app.queryFont(this.style.font,'_');
		const cursorW = fontDim.width, cursorH = fontDim.height;
		const offset = Math.floor(0.5*(this.h-fontDim.height));
		var self = this;

		function updateCursor() {
			const font = self.style.font, v = self.value, spaceX = self.w-2*offset;
			var dim = app.queryFont(font,v);
			for(visibleBegin=0; dim.width+cursorW>spaceX && visibleBegin+1<cursorPos; ++visibleBegin)
				dim = app.queryFont(font, v.substring(visibleBegin+1));
			for(visibleEnd = v.length; app.queryFont(font, v.substring(visibleBegin, visibleEnd)).width>spaceX; --visibleEnd) { }
			cursorX = app.queryFont(font, v.substring(visibleBegin, cursorPos)).width;
		}

		this.handleTextInput = function(evt, isVirtual) {
			//console.log('textinput.handleTextInput('+JSON.stringify(evt)+')');
			if('char' in evt) {
				if(this.value.length<this.maxlength) {
					this.value = this.value.substring(0,cursorPos) + evt.char + this.value.substring(cursorPos);
					++cursorPos;
					updateCursor();
				}
			}
			else if(evt.key == 'Backspace') {
				if(this.value.length && cursorPos>0) {
					this.value = this.value.substring(0,cursorPos-1) + this.value.substring(cursorPos);
					--cursorPos;
					updateCursor();
				}
			}
			else if(evt.key == 'Delete') {
				this.value = this.value.substring(0,cursorPos) + this.value.substring(cursorPos+1);
			}
			else if(evt.key == 'Home') {
				cursorPos = 0;
				updateCursor();
			}
			else if(evt.key == 'End') {
				cursorPos = this.value.length;
				updateCursor();
			}
			else if(evt.key == 'Enter' && isVirtual && this.callback)
				this.callback(this.value, this);
		}
		function handleTextInsert(evt) {
			self.value  = self.value.substring(0,cursorPos) + evt.data + self.value.substring(cursorPos);
			if(self.value.length > self.maxlength)
				self.value = self.value.substring(0,self.maxlength);
			cursorPos += evt.data.length;
			updateCursor();
		}

		this.deltaValue = function(delta) {
			if(delta<0 && cursorPos>0)
				--cursorPos;
			else if(delta>0 && cursorPos<this.value.length)
				++cursorPos;
			updateCursor();
		}

		this.update = function(deltaT, now) {
			cursorVisible = (now%1.0 < 0.75);
		}

		this.select = function(isSelected, requestVirtualKeyboard) {
			if(!this.isSelectLocked && isSelected !== this.isSelected) {
				this.isSelected = isSelected;
				app.on('textinput', this.isSelected ? function(evt){ self.handleTextInput(evt); } : null);
				app.on('textinsert', this.isSelected ? handleTextInsert : null);
				if(requestVirtualKeyboard && root)
					root.requestVirtualKeyboard(this);
			}
			return this.isSelected;
		}
		this.selectLock = function(isLocked) { this.isSelectLocked = isLocked; }

		this.handlePointer = function(evt) {
			const x = (this.align & 2) ? this.x-this.w : (this.align & 1) ? this.x-this.w/2 : this.x;
			const y = (this.align & 8) ? this.y-this.h : (this.align & 4) ? this.y-this.h/2 : this.y;
			return this.select(evt.x>=x && evt.y>=y && evt.x < x+this.w && evt.y < y+this.h, evt.pointerType === 'touch');
		}

		this.reset = function(value) {
			this.value = (value===undefined) ? '' : String(value);
			cursorPos = 0;
			updateCursor();
		}

		this.draw = function(gfx) {
			const style = this.style;
			const x = (this.align & 2) ? this.x-this.w : (this.align & 1) ? this.x-this.w/2 : this.x;
			const y = (this.align & 8) ? this.y-this.h : (this.align & 4) ? this.y-this.h/2 : this.y;
			gfx.color(this.isSelected ? style.bgFocus : style.bg).fillRect(x,y,this.w,this.h);
			gfx.color(this.isSelected ? style.fgFocus : style.fg);
			gfx.lineWidth(('lineWidth' in style) ? style.lineWidth : 1);
			gfx.drawRect(x, y, this.w, this.h);
			const visibleText = this.value.substring(visibleBegin, visibleEnd);
			gfx.fillText(x+offset,y+offset, visibleText, this.style.font);
			if(cursorVisible && this.isSelected) {
				gfx.color(style.fgFocus, 127);
				gfx.fillRect(x+offset+cursorX, y+offset, cursorW, cursorH);
			}
		}
	};
	factories.textInput = function(args, defaultStyle) { return new TextInput(args, defaultStyle); };

	return Container;
})());
