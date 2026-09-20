// Copyright (c) Mathias Kaerlev 2012.

// This file is part of Anaconda.

// Anaconda is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// Anaconda is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with Anaconda.  If not, see <http://www.gnu.org/licenses/>.

#ifndef _MMF2Builder_h
#define _MMF2Builder_h

// Build options

#define BUILDEROPTION_ZIP_CHUNKS				0x0001		// zip CCN chunks
#define BUILDEROPTION_SAVE_IMAGES_AS_FILES		0x0002		// save images as .PNG files in an Images sub-folder
#define BUILDEROPTION_SAVE_SOUNDS_AS_FILES		0x0004		// save sounds as (.WAV, .OGG, .MOD, .AIFF, etc) files in a Sounds sub-folder
#define	BUILDEROPTION_SAVE_MUSICS_AS_FILES		0x0008		// save musics as .MID files in a Music sub-folder
#define	BUILDEROPTION_PNG_WITH_ALPHA_ALWAYS		0x0010		// always add an alpha channel to PNG files

// Notes:
//
// - when images are saved as PNG files, the image bank chunk starts with :
//
//	 WORD = maximum image handle number + 1
//   WORD = number of images
//
//   and then each image starts with the following header :
//
//   typedef struct
//   {
//   	WORD handle;
//   	short width;
//   	short height;
//   	short xSpot;
//   	short ySpot;
//   	short xAP;
//   	short yAP;
//   } ImgHeader;
//
//   The filename of a given image is XXXX.png, XXXX = image handle
//	 Crap! the handle could be on 5 digits, it's a decimal number... why are there 4 digits only... I'll ask Francois... and probably we'll change that.
//
// - when sounds are saved as external files, the sound bank chunk starts with :
//
//	 WORD = maximum sound handle number + 1
//
//	 and that's all.
//
//   The filename of a given sound is XXXX.YYY, XXXX = sound handle, YYY = sound extension (WAV or OGG or AIF or MOD currently)
//   Same comment about the number of digits.
//	 Not sure if we should give a unique extension to the sound files (but if so, we would have to store their format in the CCN probably)
//
// - when music files are saved as external files, the mucis bank chunk starts with :
//
//	 WORD = maximum music handle number + 1
//
//	 and that's all.
//
//   The filename of a given mucis is XXXX.mid, XXXX = music handle
//   Same comment about the number of digits (although I doubt any application contains more than 10.000 MIDI files or sounds :)

#endif // _MMF2Builder_h
