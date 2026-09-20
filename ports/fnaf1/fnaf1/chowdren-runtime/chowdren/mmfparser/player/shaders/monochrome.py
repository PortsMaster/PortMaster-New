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

from mmfparser.player.shader import Shader

MONOCHROME_SHADER = [
    Shader(["""
        varying vec2 texture_coordinate;
        void main()
        {
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
                gl_FrontColor = gl_Color;
                texture_coordinate = vec2(gl_MultiTexCoord0);
        }
        """], ["""
        varying vec2 texture_coordinate;
        uniform sampler2D Tex0;
        void main()
        {
                vec4 col = texture2D(Tex0, texture_coordinate);
                col *= vec4(0.299,0.587,0.114,1.0);
                col.rgb = vec3(col.r+col.g+col.b);
                gl_FragColor = col * gl_Color;
        }
        """])
]

__all__ = ['MONOCHROME_SHADER']