# Copyright (c) Mathias Kaerlev 2012.

# This file is part of Anaconda.

# Anaconda is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Anaconda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Anaconda.  If not, see <http://www.gnu.org/licenses/>.

from mmfparser.player.shaders.monochrome import *
from mmfparser.player.shader import Shader

cached = {}

def load_shader(name):
    name = name.split('.')[0]
    if name in cached:
        return cached[name]
    try:
        vert = [open('./shaders/%s.vert' % name, 'rb').read()]
    except:
        vert = []
    try:
        frag = [open('./shaders/%s.frag' % name, 'rb').read()]
    except:
        frag = []
    if not vert and not frag:
        shader = None
    else:
        shader = Shader(vert, frag)
        shader.initialize()
        shader = [shader]
    cached[name] = shader
    return shader