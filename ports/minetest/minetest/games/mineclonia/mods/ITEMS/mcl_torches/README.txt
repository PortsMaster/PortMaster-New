Minetest mod "Torches"
======================

(c) Copyright BlockMen (2013-2015)
(C) Copyright sofar <sofar@foo-projects.org> (2016)


About this mod:
~~~~~~~~~~~~~~~
This mod changes the default torch drawtype from "torchlike" to "mesh",
giving the torch a three dimensional appearance. The mesh contains the
proper pixel mapping to make the animation appear as a particle above
the torch, while in fact the animation is just the texture of the mesh.

Originally, this mod created in-game alternatives with several
draw styles.  The alternatives have been removed and instead of
providing alternate nodes, this mod now directly modifies the existing
nodes. Conversion from the wallmounted style is done through an LBM.

Torches is meant for minetest-0.4.14, and does not directly support
older minetest releases. You'll need a recent git, or nightly build.

Changes for MineClone:
~~~~~~~~~~~~~~~~~~~~~~
- Torch does not generate light when wielding
- Torch drops when near water
- Torch can't be placed on ceiling
- Simple API (WIP)

License:
~~~~~~~~
(c) Copyright BlockMen (2013-2015)

Models:
CC-BY 3.0 by 22i

Code:
Licensed under the GNU LGPL version 2.1 or higher.
You can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License
as published by the Free Software Foundation;

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

See LICENSE.txt and http://www.gnu.org/licenses/lgpl-2.1.txt


Github:
~~~~~~~
https://github.com/BlockMen/torches

Forum:
~~~~~~
https://forum.minetest.net/viewtopic.php?id=6099


Changelog:
~~~~~~~~~~
see changelog.txt
