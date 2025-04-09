## Copyright 2000, 2001  Alexandre Duret-Lutz <duret_g@epita.fr>
##
## This file is part of Heroes.
##
## Heroes is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free
## Software Foundation; either version 2 of the License, or (at your
## option) any later version.
##
## Heroes is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##
## You should have received a copy of the GNU General Public License along
## with this program; if not, write to the Free Software Foundation, Inc.,
## 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

tilesetsdir  = $(datadir)/heroes/tilesets

tilesets_DATA = tilesets/level01.glz \
tilesets/level01.pcx \
tilesets/level01.pie \
tilesets/level02.glz \
tilesets/level02.pcx \
tilesets/level02.pie \
tilesets/level03.glz \
tilesets/level03.pcx \
tilesets/level03.pie \
tilesets/level04.glz \
tilesets/level04.pcx \
tilesets/level04.pie \
tilesets/level05.glz \
tilesets/level05.pcx \
tilesets/level05.pie \
tilesets/level06.glz \
tilesets/level06.pcx \
tilesets/level06.pie \
tilesets/level07.glz \
tilesets/level07.pcx \
tilesets/level07.pie \
tilesets/level08.glz \
tilesets/level08.pcx \
tilesets/level08.pie \
tilesets/level09.glz \
tilesets/level09.pcx \
tilesets/level09.pie \
tilesets/level10.glz \
tilesets/level10.pcx \
tilesets/level10.pie

EXTRA_DIST += $(tilesets_DATA)
