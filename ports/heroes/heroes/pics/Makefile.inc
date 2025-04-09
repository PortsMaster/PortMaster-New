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

picsdir  = $(datadir)/heroes/pics

pics_DATA = pics/arrow.pcx \
pics/background.pcx \
pics/bonusa.pcx \
pics/bonusb.pcx \
pics/edit.pcx \
pics/editp01.pcx \
pics/editp02.pcx \
pics/editp03.pcx \
pics/editp04.pcx \
pics/editp05.pcx \
pics/editp06.pcx \
pics/editp07.pcx \
pics/editp08.pcx \
pics/editp09.pcx \
pics/editp10.pcx \
pics/erase.pcx \
pics/fontbig.pcx \
pics/fontdeck.pcx \
pics/fontem.pcx \
pics/fontem2.pcx \
pics/fontread.pcx \
pics/helpics.pcx \
pics/heroes.pcx \
pics/intro.pcx \
pics/jukebox.pcx \
pics/newlevel.pcx \
pics/olympus.pcx \
pics/trail.pcx \
pics/typonus.pcx \
pics/vehic.pcx

EXTRA_DIST += $(pics_DATA) pics/arrow.fig
