#ifndef pmask_H
#define pmask_H

/*
This is the Pixel MASK library, which does pixel-perfect collisions using
bit masks.

There are several configuration options here, hope they aren't too
confusing.
*/

#define PMASK_VERSION          5

//#define PMASK_USE_ALLEGRO
//#define PMASK_USE_SDL

#ifdef PMASK_USE_ALLEGRO
	struct BITMAP;
#endif
#ifdef PMASK_USE_SDL
	struct SDL_Surface;
#endif

#ifdef __cplusplus
#	define PMASK_INLINE inline
	extern "C" {
#else
#	define PMASK_INLINE static
#endif

//PMASK_WORD_TYPE can be changed for your platform

//PMASK_WORD_TYPE should be the largest unsigned fast integer type available
#define PMASK_WORD_TYPE unsigned long int


//if PMASK_SINGLE_MEMORY_BLOCK is defined
//then each mask will be allocated as
//only a single memory block.  
//this means that masks will (in theory) 
//be ever-so-slightly faster and more memory efficient
//however, if in single memory block mode
//then the masks are variable-sized
//so you can not use an array of them
//#define PMASK_SINGLE_MEMORY_BLOCK

//trying to make portable const-ness easier
//if const doesn't work on your compiler, comment this out
#define PMASK_CONST const

typedef struct PMASK
{
	short int w;//width
	short int h;//height
#	ifdef PMASK_SINGLE_MEMORY_BLOCK
		PMASK_WORD_TYPE mask[1];//mask data (single memory block)
#	else
		PMASK_WORD_TYPE *mask;//mask data (pointer at second memory block)
#	endif
} PMASK;

#ifndef PMASK_CONST
#	define PMASK_CONST 
#endif

void install_pmask(); //sets up library

int _check_pmask_collision(PMASK_CONST struct PMASK *mask1, PMASK_CONST struct PMASK *mask2, int dx, int dy); //checks for collision (0 = no collision, 1 = collision)
int check_pmask_collision(PMASK_CONST struct PMASK *mask1, PMASK_CONST struct PMASK *mask2, int x1, int y1, int x2, int y2); //checks for collision (0 = no collision, 1 = collision)

//note: result[0] is set to the X coordinate of the collision, result[1] to the Y coordinate
int _check_pmask_collision_position(PMASK_CONST struct PMASK *mask1, PMASK_CONST struct PMASK *mask2, int dx, int dy, int *result);
int check_pmask_collision_position(PMASK_CONST struct PMASK *mask1, PMASK_CONST struct PMASK *mask2, int x1, int y1, int x2, int y2, int *result);

#ifndef PMASK_SINGLE_MEMORY_BLOCK
	void init_pmask        (struct PMASK *mask, int w, int h); //initializes a PMASK
	void deinit_pmask(PMASK *mask);//de-initializes a pmask
#endif
void pmask_load_pixels (struct PMASK *mask, void *pixels, int pitch, int bytes_per_pixel, int trans_color);//loads a pmask with pixel data from memory
void pmask_load_func   (struct PMASK *mask, int x, int y, void *surface, int trans_color, int (*func)(void*,int,int));//loads a pmask with pixel data from a function

PMASK *create_pmask  (int w, int h);//creates a new pmask and initializes it
PMASK *create_copy_pmask(PMASK_CONST PMASK *original);//creates a new pmask and initializes it with a copy of another pmask
void destroy_pmask(struct PMASK *mask);//destroys a pmask created by create_pmask

#if defined PMASK_USE_ALLEGRO
#	ifndef PMASK_SINGLE_MEMORY_BLOCK
		void init_allegro_pmask(struct PMASK *mask, struct BITMAP *sprite);
#	endif
	PMASK *create_allegro_pmask(struct BITMAP *sprite);
	void draw_allegro_pmask(PMASK_CONST struct PMASK *mask, struct BITMAP *destination, int x, int y, int color) ;
	void draw_allegro_pmask_stretch(PMASK_CONST struct PMASK *mask, struct BITMAP *destination, int x, int y, int w, int h, int color) ;
#endif

#if defined PMASK_USE_SDL
#	ifndef PMASK_SINGLE_MEMORY_BLOCK
		void init_sdl_pmask(struct PMASK *mask, struct SDL_Surface *sprite, int trans_color);
#	endif
	PMASK *create_sdl_pmask(struct SDL_Surface *sprite, int trans_color);
#endif


int serialize_pmask(void *destination, int maxsize, PMASK_CONST PMASK *source);
//serialize_pmask is a helper for sending a PMASK to a file or over a network
//it accepts a buffer to write to, and a maxime number of bytes to write
//it returns the number of bytes written, or -1 if an error occured
#ifndef PMASK_SINGLE_MEMORY_BLOCK
	int init_deserialize_pmask(PMASK_CONST void *source, int maxsize, PMASK *destination);
#endif
//init_deserialize_pmask is a helper for reading a PMASK from a file or over a network
//it accepts a buffer to read from, and a maximum number of bytes to read
//it also accepts a pointer at the PMASK to initialize
//it returns the number of bytes read
PMASK *create_deserialize_pmask(PMASK_CONST void *source, int maxsize, int *size);
//create_deserialize_pmask is a helper for reading a PMASK from a file or over a network
//it accepts a buffer to read from, and a maximum number of bytes to read
//it accepts a pointer at an integer to put the # of bytes read 
//it returns a newly allocated PMASK structure, or NULL if an error occured
int get_serialized_pmask_size ( int w, int h );
//simple helper to determine the serialized size of a PMASK


void fill_pmask ( PMASK *mask, int value );
void clear_pmask ( PMASK *mask );//equivalent to fill_pmask(mask, 0)
void pmask_operation_or ( PMASK *destination, PMASK_CONST PMASK *source, int x, int y );
void pmask_operation_andnot ( PMASK *destination, PMASK_CONST PMASK *source, int x, int y );
void pmask_operation_not ( PMASK *destination );
int pmask_count_solid_pixels ( PMASK_CONST PMASK *mask );

//no bounds checking
int get_pmask_pixel(PMASK_CONST struct PMASK *mask, int x, int y) ; //returns 0 if mask is clear at those coordinates, 1 if not clear
void set_pmask_pixel(struct PMASK *mask, int x, int y, int value) ;//makes mask clear at those coordinates if value is zero, otherwise makes mask not-clear at those coordinates

#ifdef __cplusplus
}
#endif

enum {
	PMASK_WORD_SIZE = sizeof(PMASK_WORD_TYPE),
	PMASK_WORD_BITS = (PMASK_WORD_SIZE*8),
//messy stuff to figure out log of the size of MASK_WORD_TYPE at compile time:
	PMASK_WORD_BITBITS  = ((PMASK_WORD_SIZE==32)?8:(PMASK_WORD_SIZE==16)?7:(PMASK_WORD_SIZE==8)?6:
			(PMASK_WORD_SIZE==4)?5:(PMASK_WORD_SIZE==2)?4:(PMASK_WORD_SIZE==1)?3:0)
};
#define PMASK_WORD_WIDTH(width) ((width + (PMASK_WORD_BITS - 1)) >> PMASK_WORD_BITBITS)

//no bounds checking
PMASK_INLINE PMASK_WORD_TYPE *_get_pmask_word(struct PMASK *mask, int xw, int y) {
	return &mask->mask[(mask->h * xw) + y];
}
PMASK_INLINE int _get_pmask_pixel(PMASK_CONST struct PMASK *mask, int x, int y) {
	return 1 & (mask->mask[(mask->h * (x >> PMASK_WORD_BITBITS)) + y] >> (x & (PMASK_WORD_BITS-1)));
}
PMASK_INLINE void _set_pmask_pixel(struct PMASK *mask, int x, int y, int value) {
	if (value) {
		mask->mask[(mask->h * (x >> PMASK_WORD_BITBITS)) + y] |= 1 << (x & (PMASK_WORD_BITS-1));
	} else {
		mask->mask[(mask->h * (x >> PMASK_WORD_BITBITS)) + y] &=~(1 << (x & (PMASK_WORD_BITS-1)));
	}
}


#endif          /* ifndef pmask_H */

