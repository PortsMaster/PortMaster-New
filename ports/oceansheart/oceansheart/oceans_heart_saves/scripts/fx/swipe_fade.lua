--[[ swipe_fade.lua
	version 1.0
	25 Apr 2020
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This effect script applies a left-to-right rolling fade out to a drawable object using
	shaders.
--]]

local shader_controller = {}

--// Shader that swipes left to rigt, fading out the target surface as it goes
	--the uniform position (float), range 0 to 1, specifies the sweep position (0=left-most, 1=right-most)
local shader = sol.shader.create{
	fragment_source = [[
#ifdef GL_ES
precision mediump float;
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

uniform float position;

uniform sampler2D sol_texture;
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor; //unused

void main() {
	vec4 unused = sol_vcolor; //supress silly warning about sol_vcolor not being used
	vec4 texel = COMPAT_TEXTURE(sol_texture, sol_vtex_coord).rgba;
	float alpha = 1.0 - 4.0*clamp(position - sol_vtex_coord.x, 0.0, 0.25);
	FragColor = vec4(texel*alpha);
}
]],
}

--// Applies the swipe fade-out effect to a drawable object
	--surface (sol.drawable) - the drawable object to apply the fade-out effect to
	--context (various) - the context to use for the timer created -- see sol.timer.start() for more info
	--duration (number, positive integer) - The total duration of the effect in milliseconds
	--callback (function, optional) - callback function for when the animation is finished
	--returns the sol.timer used for the animation. To abort the animation early, use timer:stop()
function shader_controller:start_effect(surface, context, duration, callback)
	duration = tonumber(duration)
	assert(duration, "Bad argument #4 to 'start_effect' (number expected)")
	assert(duration > 0, "Bad argument #4 to 'start_effect', number must be positive")
	duration = duration*4/5 --normalize duration, swipe really goes from 0 to 1.25
	
	local start_time = sol.main.get_elapsed_time()
	surface:set_shader(shader)
	
	return sol.timer.start(context, 10, function()
		local percent = (sol.main.get_elapsed_time() - start_time)/duration --calculate swipe position based on elapsed time
		if percent > 1.25 then --swipe travels 25% father than end to allow partially faded section to reach end
			surface:fade_out(0)
			--shader:set_uniform("position", 0) --reset shader position
			if callback then callback() end
			return false --stop repeating timer
		end
		shader:set_uniform("position", percent) --update swipe position of shader
		
		return true --repeat timer
	end)
end

return shader_controller

--[[ Copyright 2019-2020 Llamazing
   
   This program is free software: you can redistribute it and/or modify it under the
   terms of the GNU General Public License as published by the Free Software Foundation,
   either version 3 of the License, or (at your option) any later version.
   
   It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
   PURPOSE.  See the GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License along with this
   program.  If not, see <http://www.gnu.org/licenses/>.
  --]]
