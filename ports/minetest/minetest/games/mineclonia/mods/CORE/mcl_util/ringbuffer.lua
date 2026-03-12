local ringbuffer_class = {
	auto_update_node_meta_key = false,
	node_meta_private = false,
}
local ringbuffer = {}
ringbuffer_class.__index = ringbuffer_class

function ringbuffer.new(size, initial_values)
	local values = initial_values or {}
	-- use initial_values as is, unless number of entries exceeds size,
	-- then copy newest entries into new list
	-- assume index 0 is oldest entry
	if #values > size then
		values = {}
		for i = #initial_values - size, #initial_values do
			values[#values] = initial_values[i]
		end
	end
	return setmetatable({
		data = values,
		size = size,
		position = #values % size, -- insert after last value if buffer not yet full
	}, ringbuffer_class)
end

function ringbuffer_class:insert(record)
	assert(record ~= nil, "Trying to insert nil into ringbuffer")
	-- position is zero based, so increment first and wrap when reaching size
	self.position = self.position + 1
	self.data[self.position] = record
	if self.position >= self.size then
		self.position = 0
	end
	if self.auto_update_node_meta_key then
		local pos = core.get_position_from_hash(self.auto_update_node_meta_key:sub(1, 16))
		local key = self.auto_update_node_meta_key:sub(17)
		-- auto update node meta data
		local meta = core.get_meta(pos)
		meta:set_string(key, self:serialize())
		if self.node_meta_private then
			meta:mark_as_private(key)
		end
	end
end

function ringbuffer_class:indexof(val)
	local i = table.indexof(self.data, val)
	return i ~= -1 and i or false
end

function ringbuffer_class:insert_if_not_exists(record)
	local insert = not self:indexof(record)
	if insert then
		self:insert(record)
	end
	return insert
end

function ringbuffer_class:serialize()
	local data, wrap, offset = {}, self.size - self.position, 0
	-- the oldest entry is at position + 1
	for i = 1, wrap do
		if self.data[self.position + i] then
			data[i - offset] = self.data[self.position + i]
		else
			offset = offset + 1
		end
	end
	for i = 1, self.position do
		data[i + wrap - offset] = self.data[i]
	end
	return core.serialize(data)
end

function ringbuffer.deserialize(size, serialized_data)
	local rb_data = core.deserialize(serialized_data)
	return rb_data and ringbuffer.new(size, rb_data)
end

local node_meta_rb_cache = setmetatable({}, { __mode = "v" })

function ringbuffer.get_from_node_meta(pos, key, size, private)
	local node_meta_key = string.format("%0.16d", core.hash_node_position(pos)) .. key
	local rb = node_meta_rb_cache[node_meta_key]
	if not rb then
		-- read from node meta data or intialize new
		local meta = core.get_meta(pos)
		rb = ringbuffer.deserialize(size, meta:get_string(key)) or ringbuffer.new(size)
		rb.auto_update_node_meta_key = node_meta_key
		rb.node_meta_private = private
		node_meta_rb_cache[node_meta_key] = rb
	end
	return rb
end

return setmetatable(ringbuffer, ringbuffer_class)
