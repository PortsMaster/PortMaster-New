#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "pmask.h"

//#define PMASK_USE_TABLE_EDGES


#ifdef PMASK_USE_ALLEGRO
#	include <allegro.h>
#endif

#ifdef main
#	undef main
#endif

#ifdef PMASK_USE_SDL
#	include <SDL_video.h>
#	include <SDL_endian.h>
#endif

#define MINI(a,b) ((a)<(b)?(a):(b))
//#define STOPZEROI(v) (((v)<0)?0:(v))
#define STOPZEROI(v) ((v) & ~(v>>(sizeof(int)*8-1)))


int get_pmask_pixel(PMASK_CONST struct PMASK *mask, int x, int y) {
	return 1 & (mask->mask[(mask->h * (x >> PMASK_WORD_BITBITS)) + y] >> (x & (PMASK_WORD_BITS-1)));
}
void set_pmask_pixel(struct PMASK *mask, int x, int y, int value) {
	if (value) {
		mask->mask[(mask->h * (x >> PMASK_WORD_BITBITS)) + y] |= 1 << (x & (PMASK_WORD_BITS-1));
	} else {
		mask->mask[(mask->h * (x >> PMASK_WORD_BITBITS)) + y] &=~(1 << (x & (PMASK_WORD_BITS-1)));
	}
}

static void pmask_dummy_function(){//doesn't do anything
#define COMPILE_TIME_ASSERT(condition) {typedef char _compile_time_assert__[(condition) ? 1 : -1];}
	//check to make sure we got the log-base-2-of-size-in-bits correct
	COMPILE_TIME_ASSERT((1 << PMASK_WORD_BITBITS) == PMASK_WORD_BITS);
	//check to make sure the type is unsigned
	COMPILE_TIME_ASSERT(
		(((PMASK_WORD_TYPE)(-1)) >> (PMASK_WORD_BITS-2)) == 3
	);
#undef COMPILE_TIME_ASSERT
}

#ifdef PMASK_USE_TABLE_EDGES
	static PMASK_WORD_TYPE clear_left_table[PMASK_WORD_BITS];
	static PMASK_WORD_TYPE clear_right_table[PMASK_WORD_BITS];
#	define CLEAR_LEFT_BITS(value,bits) (value & clear_left_table[bits])
#	define CLEAR_RIGHT_BITS(value,bits) (value & clear_right_table[bits])
#else
#	define CLEAR_LEFT_BITS(value,bits) ((value << (bits)) >> (bits))
#	define CLEAR_RIGHT_BITS(value,bits) ((value >> (bits)) << (bits))
#endif
static PMASK_CONST unsigned char bit_count_table[256] = {
	0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4,//0
	1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5,//1
	1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5,//2
	2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6,//3
	1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5,//4
	2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6,//5
	2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6,//6
	3,4,4,5,4,5,5,6,4,5,5,6,5,6,6,7,//7
	1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5,//8
	2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6,//9
	2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6,//10
	3,4,4,5,4,5,5,6,4,5,5,6,5,6,6,7,//11
	2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6,//12
	3,4,4,5,4,5,5,6,4,5,5,6,5,6,6,7,//13
	3,4,4,5,4,5,5,6,4,5,5,6,5,6,6,7,//14
	4,5,5,6,5,6,6,7,5,6,6,7,6,7,7,8,//15
};
void install_pmask() {
	int i;
#ifdef PMASK_USE_TABLE_EDGES
	for (i = 0; i < PMASK_WORD_BITS; i++) {
		clear_left_table[i] = (((PMASK_WORD_TYPE)(-1)) << i) >> i;
		clear_right_table[i] = (((PMASK_WORD_TYPE)(-1)) >> i) << i;
	}
#endif
	return;
}

void init_pmask (struct PMASK *mask, int w, int h)
{
	int words, total_words, x, error = 0;

	mask->w = w;
	mask->h = h;
	if ((mask->w != w) || (mask->h != h)) {
		mask->w = mask->h = 0;
#		ifndef PMASK_SINGLE_MEMORY_BLOCK
			mask->mask = NULL;
#		endif
		return;
	}

	words = 1 + ((w-1) >> PMASK_WORD_BITBITS);
	
	total_words = words * h;

#	ifdef PMASK_SINGLE_MEMORY_BLOCK

#	else 
		mask->mask = (PMASK_WORD_TYPE *) malloc(
			PMASK_WORD_SIZE * total_words);
		if (!mask->mask) {
			mask->w = mask->h = 0;
			return;
		}
#	endif

	//Now we initialize some of the fields of the structure...
	mask->w = w;
	mask->h = h;

#	ifdef CLEAR_pmask
		//Now we have a proper mask structure allocated and mostly initialized, but the mask data has garbage! We have to initialize it to 0's:
		for(x=0; x < total_words; x+=1) {
			maskt->mask[x] = 0;
		}
#	else
		//only clear right hand edge if CLEAR_MASK is not defined
		for(x=total_words-h; x < total_words; x+=1) {
			mask->mask[x] = 0;
		}
#	endif
	return;
}

void deinit_pmask(struct PMASK *mask) {
	mask->w = 0;
	mask->h = 0;
#	ifndef PMASK_SINGLE_MEMORY_BLOCK
		if (mask->mask) free(mask->mask);
		mask->mask = NULL;
#	endif
	return;
}

//BYTE_N and PUSH_BYTE would be unnecessary if we had an endianness 
//detection method.  But since we can't know which endianness detection 
//method to use without depending upon Allegro or SDL or unix, we don't 
//use any, and instead use these inefficient methods.  
#define BYTE_N(word,index) ((unsigned char)(((word)>>((index)*8)) & 255))
#define PUSH_BYTE(word,byte) ((word) = (word<<8) | (byte))

int get_serialized_pmask_size ( int w, int h ) {
	PMASK *mask = NULL;
	int bytes = 1 + ((w-1) >> 3);
	int words = 1 + ((w-1) >> PMASK_WORD_BITBITS);
	int size = sizeof(mask->w) + sizeof(mask->h) + bytes * h;
	return size;
}

int serialize_pmask(void *destination, int maxsize, PMASK_CONST PMASK *source) {
	unsigned char *dest = (unsigned char *) destination;
	int i, j, k;
	int bytes = 1 + ((source->w-1) >> 3);
	int words = 1 + ((source->w-1) >> PMASK_WORD_BITBITS);
	int size = get_serialized_pmask_size(source->w, source->h);
	if (size > maxsize) return -1;
	for (i = 0; i < sizeof(source->w); i += 1) {
		*dest = BYTE_N(source->w, i);
		dest += 1;
	}
	for (i = 0; i < sizeof(source->h); i += 1) {
		*dest = BYTE_N(source->h, i);
		dest += 1;
	}
	for (j = 0; j < words; j += 1) {
		int base = j * sizeof(PMASK_WORD_TYPE);
		for (k = 0; k < source->h; k += 1) {
			PMASK_WORD_TYPE tmp = source->mask[j * source->h + k];
			for (i = 0; i < sizeof(PMASK_WORD_TYPE); i += 1) {
				if ((int)(j*sizeof(PMASK_WORD_TYPE)+i) < bytes)
					dest[i+base] = BYTE_N(tmp, i);
			}
			base += bytes;
		}
	}
	return size;
}

int init_deserialize_pmask(PMASK_CONST void *source, int maxsize, PMASK *pmask) {
	unsigned char *src = (unsigned char *) source;
	int w = 0, h = 0;
	int i, j, k;
	int size, bytes, words;

	pmask->w = 0;
	pmask->h = 0;
#	ifndef PMASK_SINGLE_MEMORY_BLOCK
		pmask->mask = NULL;
#	endif
	size = sizeof(pmask->w) + sizeof(pmask->h);
	if (maxsize < size) return -1;

	for (i = sizeof(pmask->w)-1; i >= 0; i -= 1) {
		PUSH_BYTE(w, src[i]);
	}
	src += sizeof(pmask->w);
	for (i = sizeof(pmask->h)-1; i >= 0; i -= 1) {
		PUSH_BYTE(h, src[i]);
	}
	src += sizeof(pmask->h);

	bytes = 1 + ((w-1) >> 3);
	words = 1 + ((w-1) >> PMASK_WORD_BITBITS);
	size += bytes * h;
	if (maxsize < size) return -1;
	init_pmask(pmask, w, h);
	if (pmask->w != w) return -1;

	for (j = 0; j < words; j += 1) {
		int base = j * sizeof(PMASK_WORD_TYPE);
		for (k = 0; k < pmask->h; k += 1) {
			PMASK_WORD_TYPE tmp;
			for (i = sizeof(PMASK_WORD_TYPE)-1; i >= 0; i -= 1) {
				if ((int)(j*sizeof(PMASK_WORD_TYPE)+i) >= bytes) PUSH_BYTE(tmp,0);
				else PUSH_BYTE(tmp, src[base+i]);
			}
			base += bytes;
			pmask->mask[j * h + k] = tmp;
		}
	}
	return size;
}
PMASK *create_deserialize_pmask(PMASK_CONST void *source, int maxsize, int *ret_size) {
	int w = 0, h = 0;
	int i, j, k;
	int size, bytes, words;
	PMASK *pmask;
        unsigned char *src = (unsigned char *) source;

	*ret_size = -1;
	size = sizeof(pmask->w) + sizeof(pmask->h);
	if (maxsize < size) return NULL;

	for (i = sizeof(pmask->w)-1; i >= 0; i -= 1) {
		PUSH_BYTE(w, src[i]);
	}
	src += sizeof(pmask->w);
	for (i = sizeof(pmask->h)-1; i >= 0; i -= 1) {
		PUSH_BYTE(h, src[i]);
	}
	src += sizeof(pmask->h);

	bytes = 1 + ((w-1) >> 3);
	words = 1 + ((w-1) >> PMASK_WORD_BITBITS);
	size += bytes * h;
	if (maxsize < size) return NULL;
	pmask = create_pmask(w, h);
	if (!pmask) return NULL;
	*ret_size = size;

	for (j = 0; j < words; j += 1) {
		int base = j * sizeof(PMASK_WORD_TYPE);
		for (k = 0; k < pmask->h; k += 1) {
			PMASK_WORD_TYPE tmp;
			for (i = sizeof(PMASK_WORD_TYPE)-1; i >= 0; i -= 1) {
				if ((int)(j*sizeof(PMASK_WORD_TYPE)+i) >= bytes) PUSH_BYTE(tmp,0);
				else PUSH_BYTE(tmp, src[base+i]);
			}
			pmask->mask[j * h + k] = tmp;
			base += bytes;
		}
	}
	return pmask;
}


void destroy_pmask(struct PMASK *mask) {
	deinit_pmask(mask);
	free(mask);
	return;
}

PMASK *create_pmask (int w, int h) {
	struct PMASK *maskout;

#	ifdef PMASK_SINGLE_MEMORY_BLOCK
		int words, total_words;
		words = 1 + ((w-1) >> PMASK_WORD_BITBITS);
		total_words = words * h;
		maskout = (PMASK *) malloc(
			sizeof(PMASK) + 
			PMASK_WORD_SIZE * total_words );
		if(!maskout) return NULL;
#	else 
		maskout = (PMASK *) malloc(sizeof(PMASK));
		if(!maskout) return NULL;
#	endif

	init_pmask(maskout, w, h);

#	ifndef PMASK_SINGLE_MEMORY_BLOCK
		if (!maskout->mask) {
			destroy_pmask(maskout);
			return NULL;
		}
#	endif

	return maskout;
}
PMASK *create_copy_pmask (PMASK_CONST PMASK *original) {
	PMASK *r = create_pmask(original->w, original->h);
	memcpy(r->mask, original->mask, PMASK_WORD_SIZE * r->h * PMASK_WORD_WIDTH(r->w));
	return r;
}

void pmask_load_func (struct PMASK *mask, int _x, int _y, void *surface, int trans_color, int (*func)(void*,int,int))
{
	int words, x, y, x2, w, h;
	if(!mask) return;

	w = mask->w;
	h = mask->h;

	words = 1 + ((w-1) >> PMASK_WORD_BITBITS);

	//Now we have to create the bit mask array for the sprite:
	for(x=0; x < words; x+=1) {
		for(y=0; y < h; y+=1) {
			PMASK_WORD_TYPE m = 0;
			for (x2=PMASK_WORD_BITS-1; x2 >= 0; x2-=1) {
				int x3 = (x << PMASK_WORD_BITBITS) + x2 + _x;
				m <<= 1;
				if ( x3 < w ) {
					if ( func(surface, x3, y+_y) != trans_color ) {
						m |= 1;
					}
				}
			}
			mask->mask[y+x*h] = m;
		}
	}
	return;
}

void pmask_load_pixels (struct PMASK *mask, void *pixels, int pitch, int bytes_per_pixel, int trans_color) 
{
	int words, x, y, x2, w, h;
	if(!mask) return;

	w = mask->w;
	h = mask->h;

	words = 1 + ((w-1) >> PMASK_WORD_BITBITS);

	//Now we have to create the bit mask array for the sprite:
	for(x=0; x < words; x+=1) {
		for(y=0; y < h; y+=1) {
			PMASK_WORD_TYPE m = 0;
			for (x2=PMASK_WORD_BITS-1; x2 >= 0; x2-=1) {
				int x3 = (x << PMASK_WORD_BITBITS) + x2;
				m <<= 1;
				if ( x3<w ) {
					//beware of endianness!!!!!!!!!!
					if ( memcmp(((char*)pixels) + x3 * bytes_per_pixel + y * pitch, &trans_color, bytes_per_pixel) == 0 ) {
						m |= 1;
					}
				}
			}
			mask->mask[y+x*h] = m;
		}
	}
	return;
}

#ifdef PMASK_USE_ALLEGRO
	typedef char pmask_int_8;
	typedef short int pmask_int_16;
	typedef int pmask_int_32;
	static void load_allegro_pmask(PMASK *mask, BITMAP *sprite) {
		pmask_load_func (mask, 0, 0, sprite, bitmap_mask_color(sprite), (int (*)(void*,int,int))getpixel);
	}
	void init_allegro_pmask(struct PMASK *mask, struct BITMAP *sprite) {
		init_pmask(mask, sprite->w, sprite->h);
		load_allegro_pmask(mask, sprite);
	}
	PMASK *create_allegro_pmask(struct BITMAP *sprite) {
		PMASK *ret;
		ret = create_pmask(sprite->w, sprite->h);
		if (!ret) return NULL;
		load_allegro_pmask(ret, sprite);
		return ret;
	}
	void draw_allegro_pmask(PMASK_CONST PMASK *mask, BITMAP *destination, int dx, int dy, int color) {
/*		int mx, my;
		for (my = 0; my < mask->h; my += 1) {
			for (mx = 0; mx < mask->w; mx += 1) {
				if (_get_pmask_pixel(mask, mx, my))
					putpixel(destination, x+mx, y+my, color);
			}
		}*/
		int sx, sy, x, y, w, h;
		if (dx >= destination->w) return;
		if (dy >= destination->h) return;
		w = mask->w;
		h = mask->h;
		if (dx >= 0) sx = 0; else {
			sx = -dx;
			w += dx;
			dx = 0;
		}
		if (dy >= 0) sy = 0; else {
			sy = -dy;
			h += dy;
			dy = 0;
		}
		if (sx > mask->w) return;
		if (sy > mask->h) return;
		if (w > destination->w - dx) w = destination->w - dx;
		if (h > destination->h - dy) h = destination->h - dy;
		if (is_memory_bitmap(destination)) {
			//goto handle_special_case;
#			define BLAH_WRITE1(bpp) {for (y = 0; y < h; y += 1) 
#			define BLAH_WRITE2(bpp) {pmask_int_ ## bpp *line = &(((pmask_int_ ## bpp *)destination->line[dy+y])[dx]);
#			define BLAH_WRITE3(bpp) {for (x = 0; x < w; x += 1)
#			define BLAH_WRITE4(bpp) {if(_get_pmask_pixel(mask, sx+x, sy+y)) line[x] = color;}
#			define BLAH_WRITE5(bpp) }}}
#			define BLAH_WRITE(bpp) BLAH_WRITE1(bpp)BLAH_WRITE2(bpp)BLAH_WRITE3(bpp)BLAH_WRITE4(bpp)BLAH_WRITE5(bpp)
			switch (bitmap_color_depth(destination)) {
				case 8: BLAH_WRITE(8) break;
				case 15:
				case 16: BLAH_WRITE(16) break;
				case 32: BLAH_WRITE(32) break;
				default: goto handle_special_case;
			}
#			undef BLAH_WRITE1
#			undef BLAH_WRITE2
#			undef BLAH_WRITE3
#			undef BLAH_WRITE4
#			undef BLAH_WRITE5
#			undef BLAH_WRITE
		}
		else {
#			define BLAH_WRITE1(bpp) {bmp_select(destination); for (y = 0; y < h; y += 1) 
#			define BLAH_WRITE2(bpp) {unsigned long addr = bmp_write_line(destination, y+dy) + dx * ((bpp+7) / 8);
#			define BLAH_WRITE3(bpp) {for (x = 0; x < w; x += 1)
#			define BLAH_WRITE4(bpp) {if(_get_pmask_pixel(mask, sx+x, sy+y)) bmp_write ## bpp (addr + x*((bpp+7) / 8), color);}
#			define BLAH_WRITE5(bpp) }} bmp_unwrite_line(destination); }
#			define BLAH_WRITE(bpp) BLAH_WRITE1(bpp)BLAH_WRITE2(bpp)BLAH_WRITE3(bpp)BLAH_WRITE4(bpp)BLAH_WRITE5(bpp)
			switch (bitmap_color_depth(destination)) {
				case 8: BLAH_WRITE(8) break;
				case 15:
				case 16: BLAH_WRITE(16) break;
				case 32: BLAH_WRITE(32) break;
				default: goto handle_special_case;
			}
#			undef BLAH_WRITE1
#			undef BLAH_WRITE2
#			undef BLAH_WRITE3
#			undef BLAH_WRITE4
#			undef BLAH_WRITE5
#			undef BLAH_WRITE
		}
		return;
		handle_special_case: 
		{
			for (y = 0; y < h; y += 1) {
				for (x = 0; x < w; x += 1) {
					if (_get_pmask_pixel(mask, sx+x, sy+y)) {
						putpixel(destination, dx+x, dy+y, color);
					}
				}
			}
		}
		return;
	}
	void draw_allegro_pmask_stretch(PMASK_CONST PMASK *mask, BITMAP *destination, int x, int y, int w, int h, int color) {
		int _x, _xmin, _y, _w, _h;
		int scale;
		if (y >= 0) _y = 0; else _y = -y;
		if (y + h <= destination->h) _h = h; else _h = destination->h - y;
		if (x >= 0) _xmin = 0; else _xmin = -x;
		if (x + w <= destination->w) _w = w; else _w = destination->w - x;
		scale = (mask->w << 16) / w;

		bmp_select(destination);
		switch (bitmap_color_depth(destination)) {
			case 8: {
				while (_y < _h) {
					int ty, tx;
					unsigned long addr = bmp_write_line(destination, y + _y) + x * sizeof(char);
					//unsigned long *dat = mask->sp_mask[_y * mask->h / h];
					ty = _y * mask->h / h;
					_x = _xmin;
					tx = _x * scale;
					while (_x < _w) {
						//if ( (dat[(tx>>21)] << ((tx>>16) & 31)) & 0x80000000UL )
						if ( _get_pmask_pixel(mask,tx>>16,ty) )
							bmp_write8(addr+_x*sizeof(char), color);
						tx += scale;
						_x += 1;
					}
					_y += 1;
				}
			}
			break;
			case 15: {
				while (_y < _h) {
					int ty, tx;
					unsigned long addr = bmp_write_line(destination, y + _y) + x * sizeof(short);
					ty = _y * mask->h / h;
					_x = _xmin;
					tx = _x * scale;
					while (_x < _w) {
						//if ( (dat[(tx>>21)] << ((tx>>16) & 31)) & 0x80000000UL )
						if ( _get_pmask_pixel(mask,tx>>16,ty) )
							bmp_write15(addr+_x*sizeof(short), color);
						tx += scale;
						_x += 1;
					}
					_y += 1;
				}
			}
			break;
			case 16: {
				while (_y < _h) {
					int ty, tx;
					unsigned long addr = bmp_write_line(destination, y + _y) + x * sizeof(short);
					ty = _y * mask->h / h;
					_x = _xmin;
					tx = _x * scale;
					while (_x < _w) {
						//if ( (dat[(tx>>21)] << ((tx>>16) & 31)) & 0x80000000UL )
						if ( _get_pmask_pixel(mask,tx>>16,ty) )
							bmp_write16(addr+_x*sizeof(short), color);
						tx += scale;
						_x += 1;
					}
					_y += 1;
				}
			}
			break;
			case 24: {
				while (_y < _h) {
					int ty, tx;
					unsigned long addr = bmp_write_line(destination, y + _y) + x * 3;
					ty = _y * mask->h / h;
					_x = _xmin;
					tx = _x * scale;
					while (_x < _w) {
						//if ( (dat[(tx>>21)] << ((tx>>16) & 31)) & 0x80000000UL )
						if ( _get_pmask_pixel(mask,tx>>16,ty) )
							bmp_write24(addr+_x*3, color);
						tx += scale;
						_x += 1;
					}
					_y += 1;
				}
			}
			break;
			case 32: {
				while (_y < _h) {
					int ty, tx;
					unsigned long addr = bmp_write_line(destination, y + _y) + x * sizeof(long);
					ty = _y * mask->h / h;
					//unsigned long *dat = mask->mask + ty;
					_x = _xmin;
					tx = _x * scale;
					while (_x < _w) {
						//if ( (dat[(tx>>21)] << ((tx>>16) & 31)) & 0x80000000UL )
						if ( _get_pmask_pixel(mask,tx>>16,ty) )
							bmp_write32(addr+_x*sizeof(long), color);
						tx += scale;
						_x += 1;
					}
					_y += 1;
				}
			}
			break;
		}
		bmp_unwrite_line(destination);
		return;
	}

#endif

#ifdef PMASK_USE_SDL

	static int SDL_getpixel(void *_surface, int x, int y)
	{
		int bpp = ((SDL_Surface*)_surface)->format->BytesPerPixel;
		/* Here p is the address to the pixel we want to retrieve */
		Uint8 *p = (Uint8 *)((SDL_Surface*)_surface)->pixels + y * ((SDL_Surface*)_surface)->pitch + x * bpp;

		switch(bpp) {
		case 1:
			return *p;

		case 2:
			return *(Uint16 *)p;

		case 3:
#			if SDL_BYTEORDER == SDL_BIG_ENDIAN
				return p[0] << 16 | p[1] << 8 | p[2];
#			else
				return p[0] | p[1] << 8 | p[2] << 16;
#			endif
		case 4:
			return *(Uint32 *)p;

		default:
			return 0;       // shouldn't happen, but avoids warnings
		}
	}
	static void load_sdl_pmask(PMASK *mask, SDL_Surface *sprite, int trans_color) {
		pmask_load_func (mask, 0, 0, sprite, trans_color, SDL_getpixel);
		return;
	}
	void init_sdl_pmask(struct PMASK *mask, struct SDL_Surface *sprite, int trans_color) {
		init_pmask(mask, sprite->w, sprite->h);
		load_sdl_pmask(mask, sprite, trans_color);
		return;
	}
	PMASK *create_sdl_pmask(struct SDL_Surface *sprite, int trans_color) {
		PMASK *ret;
		ret = create_pmask(sprite->w, sprite->h);
		if (!ret) return NULL;
		load_sdl_pmask(ret, sprite, trans_color);
		return ret;
	}
#endif


int _check_pmask_collision(PMASK_CONST struct PMASK *mask1, PMASK_CONST struct PMASK *mask2, int dx, int dy1)
{
	PMASK_WORD_TYPE *raw1, *end1;
	PMASK_WORD_TYPE *raw2, *end2;
	int h1, h2, words1, words2;
	int dy2; //We will use these deltas...
	int py; //This will store the Y position...
	int maxh; //This will store the maximum height...
	int block1, block2;

	//First we do normal bounding box collision detection...
	if ( (dx >= mask1->w) || (dy1 > mask1->h) || (dx < -mask2->w) || (dy1 < -mask2->h) )
		return 0;
//	if( !check_bb_collision(mask1, mask2, x1,y1, x2,y2) ) //If there is not bounding box collision...
//		return 0; //return that there is not collision...

	//if (0) { //swap 1 & 2
	if (dx < 0) { //swap 1 & 2 to make sure mask1 is on the left
		PMASK_CONST PMASK *mtmp;
		dx = -dx;
		dy1 = -dy1;
		mtmp = mask1; mask1 = mask2; mask2 = mtmp;//swap masks
	}

	if(dy1<0) {
		dy2 = -dy1;
		dy1 = 0;
	} else {
		dy2 = 0;
	}

	block1 = dx>>PMASK_WORD_BITBITS;
	block2 = 0;
	dx &= PMASK_WORD_BITS-1;
	
	//This will calculate the maximum height that we will reach...
	h1 = mask1->h;
	h2 = mask2->h;
	if(h1-dy1 > h2-dy2) {
		maxh=h2-dy2-1;
	} else {
		maxh=h1-dy1-1;
	}

	words1 = 1 + ((mask1->w-1) >> PMASK_WORD_BITBITS);
	words2 = 1 + ((mask2->w-1) >> PMASK_WORD_BITBITS);
	block1 = block1 * h1 + dy1;
	block2 = block2 * h2 + dy2;

	raw1 = &mask1->mask[block1];
	end1 = &mask1->mask[words1 * h1];
	raw2 = &mask2->mask[block2];
	end2 = &mask2->mask[words2 * h2];

	if ( dx == 0 ) {//if perfectly aligned
		while((raw1<end1) && (raw2<end2) ) { //search horizantolly in the outer loop
			for(py=maxh;py>=0;py--) { //Search vertically
				if( raw1[py] & raw2[py] )
					return 1;
			}
			raw1 += h1;
			raw2 += h2;
		}
		return 0;
	}
	else {//if not perfectly aligned
		while( 1 ) { //search horizantolly in the outer loop
			for(py=maxh;py>=0;py--) { //Search vertically
				if( (raw1[py] >> dx) & raw2[py] ) return 1;
			}
			raw1 += h1;
			if (raw1>=end1) return 0;
			dx = PMASK_WORD_BITS - dx;
			//dx = -dx & (PMASK_WORD_BITS - 1);
			for(py=maxh;py>=0;py--) { //Search vertically
				if( raw1[py] & (raw2[py] >> dx) ) return 1;
			}
			raw2 += h2;
			if (raw2>=end2) return 0;
			dx = PMASK_WORD_BITS - dx;
			//dx = -dx & (PMASK_WORD_BITS - 1);
		}
	}
}

int bsf ( int a ) {
	int r = 0;
	if (!a) return -1;
	if (!(a & 0xFFFF)) {
		r += 16;
		a >>= 16;
	}
	if (!(a & 0xFF)) {
		r += 8;
		a >>= 8;
	}
	if (!(a & 0xF)) {
		r += 4;
		a >>= 4;
	}
	if (!(a & 0x3)) {
		r += 2;
		a >>= 2;
	}
	if (!(a & 0x1)) {
		r += 1;
		a >>= 1;
	}
	return r;
}

int _check_pmask_collision_position(PMASK_CONST struct PMASK *mask1, PMASK_CONST struct PMASK *mask2, int dx, int dy1, int *result)
{
	PMASK_WORD_TYPE *raw1, *end1;
	PMASK_WORD_TYPE *raw2, *end2;
	int h1, h2, words1, words2;
	int dy2; //We will use these deltas...
	int py; //This will store the Y position...
	int maxh; //This will store the maximum height...
	int block1, block2;
	int rx = 0, odx = dx;

	//First we do normal bounding box collision detection...
	if ( (dx >= mask1->w) || (dy1 > mask1->h) || (dx < -mask2->w) || (dy1 < -mask2->h) )
		return 0;
//	if( !check_bb_collision(mask1, mask2, x1,y1, x2,y2) ) //If there is not bounding box collision...
//		return 0; //return that there is not collision...

	if (dx < 0) { //swap 1 & 2 to make sure mask1 is on the left
		PMASK_CONST PMASK *mtmp;
		dx = -dx;
		dy1 = -dy1;
		mtmp = mask1; mask1 = mask2; mask2 = mtmp;//swap masks
	}

	if(dy1<0) {
		dy2 = -dy1;
		dy1 = 0;
	} else {
		dy2 = 0;
	}

	block1 = dx>>PMASK_WORD_BITBITS;
	block2 = 0;
	dx &= PMASK_WORD_BITS-1;
	
	//This will calculate the maximum height that we will reach...
	h1 = mask1->h;
	h2 = mask2->h;
	if(h1-dy1 > h2-dy2) {
		maxh=h2-dy2-1;
	} else {
		maxh=h1-dy1-1;
	}

	words1 = 1 + ((mask1->w-1) >> PMASK_WORD_BITBITS);
	words2 = 1 + ((mask2->w-1) >> PMASK_WORD_BITBITS);
	block1 = block1 * h1 + dy1;
	block2 = block2 * h2 + dy2;

	raw1 = &mask1->mask[block1];
	end1 = &mask1->mask[words1 * h1];
	raw2 = &mask2->mask[block2];
	end2 = &mask2->mask[words2 * h2];


	if ( dx == 0 ) {//if perfectly aligned
		while((raw1<end1) && (raw2<end2) ) { //search horizantolly in the outer loop
			for(py=maxh;py>=0;py--) { //Search vertically
				if( raw1[py] & raw2[py] ) {
					rx += bsf(raw1[py] & raw2[py]);
					goto found;
				}
			}
			rx += PMASK_WORD_BITS;
			raw1 += h1;
			raw2 += h2;
		}
		return 0;
	}
	else {//if not perfectly aligned
		while( 1 ) { //search horizantolly in the outer loop
			for(py=maxh;py>=0;py--) { //Search vertically
				if( (raw1[py] >> dx) & raw2[py] ) {
					rx += bsf((raw1[py] >> dx) & raw2[py]);
					goto found;
				}
			}
			raw1 += h1;
			if (raw1>=end1) return 0;
			dx = PMASK_WORD_BITS - dx;
			for(py=maxh;py>=0;py--) { //Search vertically
				if( raw1[py] & (raw2[py] >> dx) ) {
					rx += bsf(raw1[py] & (raw2[py] >> dx)) + dx;
					goto found;
				}
			}
			raw2 += h2;
			rx += PMASK_WORD_BITS;
			if (raw2>=end2) return 0;
			dx = PMASK_WORD_BITS - dx;
			//dx = -dx & (PMASK_WORD_BITS - 1);
		}
	}
found:
	if (result) {
		int ry = dy2 + py;
		if (odx < 0) {
			rx += (-odx)>>PMASK_WORD_BITBITS;
			}
		if (odx >= 0) {
			rx += odx>>PMASK_WORD_BITBITS;
			ry += dy1 - dy2;
			rx += odx;
		}
		result[0] = rx;
		result[1] = ry;
	}
	return 1;
}


int check_pmask_collision(PMASK_CONST struct PMASK *mask1, PMASK_CONST struct PMASK *mask2, int x1, int y1, int x2, int y2) {
	return _check_pmask_collision(mask1, mask2, x2-x1, y2-y1);
}

int check_pmask_collision_position(PMASK_CONST struct PMASK *mask1, PMASK_CONST struct PMASK *mask2, int x1, int y1, int x2, int y2, int *result) {
	if (_check_pmask_collision_position(mask1, mask2, x2-x1, y2-y1, result)) {
		result[0] += x1;
		result[1] += y1;
		return 1;
	}
	else return 0;
}

void clear_pmask ( PMASK *mask ) {
	int xw, y;
	int mxw = PMASK_WORD_WIDTH(mask->w);
	int my = mask->h;
	for (xw = 0; xw < mxw; xw++) {
		for (y = 0; y < my; y++) {
			mask->mask[ xw * mask->h + y ] = 0;
//			*_get_pmask_word(mask, xw, y) = 0;
		}
	}
}
void fill_pmask ( PMASK *mask, int value ) {
	int xw, y;
	int mxw = PMASK_WORD_WIDTH(mask->w);
	int my = mask->h;
	if (!value) {
		for (xw = 0; xw < mxw; xw++) {
			for (y = 0; y < my; y++) {
				mask->mask[ xw * mask->h + y ] = 0;
			}
		}
	}
	else {
		PMASK_WORD_TYPE v = (PMASK_WORD_TYPE)-1;
		for (xw = 0; xw < mxw-1; xw++) {
			for (y = 0; y < my; y++) {
				mask->mask[ xw * mask->h + y ] = v;
			}
		}
		v = CLEAR_LEFT_BITS(v, ((~mask->w) & (PMASK_WORD_BITS-1)));
		for (y = 0; y < my; y++) {
			mask->mask[ xw * mask->h + y ] = v;
		}
	}
}

void pmask_operation_or ( PMASK *dest, PMASK_CONST PMASK *source, int x, int y ) {
//todo: optimize this function
	int minx = STOPZEROI(x), miny = STOPZEROI(y);
	int maxx = MINI(dest->w,source->w+x), maxy = MINI(dest->h,source->h+y);
	int cx;
	if ((minx >= maxx) || (miny >= maxy)) return;

	for (; miny < maxy; miny++) {
		for (cx = minx; cx < maxx; cx++) {
			set_pmask_pixel(dest, cx, miny, 
				get_pmask_pixel(dest, cx, miny) | get_pmask_pixel(source, cx-x, miny-y)
			);
		}
	}
}
void pmask_operation_andnot ( PMASK *dest, PMASK_CONST PMASK *source, int x, int y ) {
//todo: optimize this function
	int minx = STOPZEROI(x), miny = STOPZEROI(y);
	int maxx = MINI(dest->w,source->w+x), maxy = MINI(dest->h,source->h+y);
	int cx;
	if ((minx >= maxx) || (miny >= maxy)) return;

	for (; miny < maxy; miny++) {
		for (cx = minx; cx < maxx; cx++) {
			set_pmask_pixel(dest, cx, miny, 
				get_pmask_pixel(dest, cx, miny) & (get_pmask_pixel(source, cx-x, miny-y) ^ 1)
			);
		}
	}
}
void pmask_operation_not ( PMASK *dest ) {
	int x, y, leftover, mx, i;
	mx = PMASK_WORD_WIDTH(dest->w);
	for (x = 0; x < mx-1; x++) {
		for (y = 0; y < dest->h; y++) {
			i = x * dest->h + y;
			dest->mask[i] = ~dest->mask[i];
		}
	}
	leftover = (~dest->w) & (PMASK_WORD_BITS-1);
	for (y = 0, i = mx-1; y < dest->h; y++, i+=dest->h) {
		dest->mask[i] = CLEAR_LEFT_BITS(~dest->mask[i], leftover);
	}
}
int pmask_count_solid_pixels ( PMASK_CONST PMASK *mask ) {
	int x, y, z, leftover, mx, i, r;
	mx = PMASK_WORD_WIDTH(mask->w);
	r = 0;
	for (x = 0; x < mx; x++) {
		for (y = 0; y < mask->h; y++) {
			PMASK_WORD_TYPE tmp = mask->mask[x * mask->h + y];
			while (tmp) {
				r += bit_count_table[tmp & 255];
				tmp >>= 8;
			}
		}
	}
	return r;
}
/*	int dh = dest->h;
	int sh = source->h;
	int mx = x + source->w;
	int my = y + source->h;
	int miny, endy, xw, endw, shift, xoff, yoff;
	PMASK_WORD_TYPE w = 0;
	xoff = 0;
	yoff = 0;
	if (x < 0) xoff = -x;
	if (y < 0) yoff = -y;
	if (mx > dest->w) mx = dest->w;
	if (my > dest->h) my = dest->h;
	miny = 0;
	if (x <= mx) return;
	if (y <= my) return;
	shift = x & (PMASK_WORD_BITS-1);
	xw = x >> PMASK_WORD_BITBITS;
	yoff = y;
	endy = my;
	endw = 1 + ((mx - 1) >> PMASK_WORD_BITBITS);
	if (!shift) while (xw != endw) {
		for (y = miny; y < endy; y++) {
			dest->mask[(xw+xoff) * dh + y + yoff] |= 
				source->mask[x * sh + y];
		}
		xw ++;
	}
	else while (xw != endw) {
		for (y = miny; y < endy; y++) {
			dest->mask[(xw +xoff+1)* dh + y + yoff] |= w >> (shift ^ 31);
			w = source->mask[x * sh + y];
			dest->mask[(xw + xoff) * dh + y + yoff] |= w << shift;
		}
		xw ++;
	}*/


