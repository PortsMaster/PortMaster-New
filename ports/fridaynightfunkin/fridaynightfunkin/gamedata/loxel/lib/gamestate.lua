--[[
Copyright (c) 2010-2013 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
-- Modified for FNF-LÖVE

local state_init = setmetatable({leave = __NULL__}, {
	__index = function()
		error("Use Gamestate.switch() to initialize")
	end
})
local stack, state_is_dirty = {state_init}, true
local initialized_states = setmetatable({}, {__mode = "kv"})
local errarg = "Missing argument: Gamestate to %s"

local GS = {stack = stack}

local function change_state(stack_offset, to, ...)
	assert(to, errarg:format(stack_offset > 0 and "push" or "switch to"))
	if stack_offset <= 0 then
		(stack[#stack].leave or __NULL__)(stack[#stack])
		state_is_dirty = true
	end

	local pre = stack[#stack]
	; (initialized_states[to] or to.init or __NULL__)(to)
	initialized_states[to] = __NULL__
	stack[#stack + stack_offset] = to

	if #stack > 2 then stack[#stack - 2] = nil end

	if to.enter then return to.enter(to, pre, ...) end
end

function GS.current() return stack[#stack] end
function GS.switch(to, ...) return change_state(0, to, ...) end
function GS.push(to, ...) return change_state(1, to, ...) end

function GS.pop(index, ...)
	assert(#stack > 1, "No more states to pop!")
	index = index or #stack
	local pre, to = stack[index], stack[index - 1]
	stack[index] = nil

	if index - 2 > 0 then stack[index - 2] = nil end
	; (pre.leave or __NULL__)(pre)

	return (to.resume or __NULL__)(to, pre, ...)
end

local all_callbacks = table.keys(love.handlers)
function GS.registerEvents(callbacks)
	callbacks = callbacks or all_callbacks
	local registry = {}

	for _, f in ipairs(callbacks) do
		registry[f] = love[f] or __NULL__
		love[f] = function(...)
			registry[f](...)
			return GS[f](...)
		end
	end
end

local function_cache = setmetatable({}, {__mode = "kv"})
setmetatable(GS, {
	__index = function(_, func)
		if func == "update" or not state_is_dirty then
			state_is_dirty = false
			function_cache[func] = function_cache[func] or function(...)
				return (stack[#stack][func] or __NULL__)(stack[#stack], ...)
			end
			return function_cache[func]
		end
		return __NULL__
	end
})

return GS
