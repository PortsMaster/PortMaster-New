tga_encoder = {}

local image = setmetatable({}, {
	__call = function(self, ...)
		local t = setmetatable({}, {__index = self})
		t:constructor(...)
		return t
	end,
})

function image:constructor(pixels)
	self.pixels = pixels
	self.width = #pixels[1]
	self.height = #pixels
end

local pixel_depth_by_color_format = {
	["Y8"] = 8,
	["A1R5G5B5"] = 16,
	["B8G8R8"] = 24,
	["B8G8R8A8"] = 32,
}

function image:encode_colormap_spec(properties)
	local colormap = properties.colormap
	local colormap_pixel_depth = 0
	if 0 ~= #colormap then
		colormap_pixel_depth = pixel_depth_by_color_format[
			properties.color_format
		]
		-- ensure that each pixel references a legal colormap entry
		for _, row in ipairs(self.pixels) do
			for _, pixel in ipairs(row) do
				local colormap_index = pixel[1]
				if colormap_index >= #colormap then
					error(
						"colormap index " .. colormap_index ..
						" not in colormap of size " .. #colormap
					)
				end
			end
		end
	end
	local colormap_spec =
		string.char(0, 0) .. -- first entry index
		string.char(#colormap % 256, math.floor(#colormap / 256)) .. -- number of entries
		string.char(colormap_pixel_depth) -- bits per pixel
	self.data = self.data .. colormap_spec
end

function image:encode_image_spec(properties)
	local color_format = properties.color_format
	assert(
		"Y8" == color_format or -- (8 bit grayscale = 1 byte = 8 bits)
		"A1R5G5B5" == color_format or -- (A1R5G5B5 = 2 bytes = 16 bits)
		"B8G8R8" == color_format or -- (B8G8R8 = 3 bytes = 24 bits)
		"B8G8R8A8" == color_format -- (B8G8R8A8 = 4 bytes = 32 bits)
	)
	local pixel_depth
	if 0 ~= #properties.colormap then
		pixel_depth = self.pixel_depth
	else
		pixel_depth = pixel_depth_by_color_format[color_format]
	end
	assert( nil ~= pixel_depth)
	self.data = self.data
		.. string.char(0, 0) -- X-origin
		.. string.char(0, 0) -- Y-origin
		.. string.char(self.width  % 256, math.floor(self.width  / 256)) -- width
		.. string.char(self.height % 256, math.floor(self.height / 256)) -- height
		.. string.char(pixel_depth)
		.. string.char(0) -- image descriptor
end

function image:encode_colormap(properties)
	local colormap = properties.colormap
	if 0 == #colormap then
		return
	end
	local color_format = properties.color_format
	assert (
		"A1R5G5B5" == color_format or
		"B8G8R8" == color_format or
		"B8G8R8A8" == color_format
	)
	local colors = {}
	if "A1R5G5B5" == color_format then
		-- Sample depth rescaling is done according to the algorithm presented in:
		-- <https://www.w3.org/TR/2003/REC-PNG-20031110/#13Sample-depth-rescaling>
		local max_sample_in = math.pow(2, 8) - 1
		local max_sample_out = math.pow(2, 5) - 1
		for i = 1,#colormap,1 do
			local color = colormap[i]
			local colorword = 32768 +
				((math.floor((color[1] * max_sample_out / max_sample_in) + 0.5)) * 1024) +
				((math.floor((color[2] * max_sample_out / max_sample_in) + 0.5)) * 32) +
				((math.floor((color[3] * max_sample_out / max_sample_in) + 0.5)) * 1)
			local color_bytes = string.char(
				colorword % 256,
				math.floor(colorword / 256)
			)
			colors[#colors + 1] = color_bytes
		end
	elseif "B8G8R8" == color_format then
		for i = 1,#colormap,1 do
			local color = colormap[i]
			local color_bytes = string.char(
				color[3], -- B
				color[2], -- G
				color[1]  -- R
			)
			colors[#colors + 1] = color_bytes
		end
	elseif "B8G8R8A8" == color_format then
		for i = 1,#colormap,1 do
			local color = colormap[i]
			local color_bytes = string.char(
				color[3], -- B
				color[2], -- G
				color[1], -- R
				color[4]  -- A
			)
			colors[#colors + 1] = color_bytes
		end
	end
	assert( 0 ~= #colors )
	self.data = self.data .. table.concat(colors)
end

function image:encode_header(properties)
	local color_format = properties.color_format
	local colormap = properties.colormap
	local compression = properties.compression
	local colormap_type
	local image_type
	if "Y8" == color_format and "RAW" == compression then
		colormap_type = 0
		image_type = 3 -- grayscale
	elseif (
		"A1R5G5B5" == color_format or
		"B8G8R8" == color_format or
		"B8G8R8A8" == color_format
	) then
		if "RAW" == compression then
			if 0 ~= #colormap then
				colormap_type = 1
				image_type = 1 -- colormapped RGB(A)
			else
				colormap_type = 0
				image_type = 2 -- RAW RGB(A)
			end
		elseif "RLE" == compression then
			colormap_type = 0
			image_type = 10 -- RLE RGB
		end
	end
	assert( nil ~= colormap_type )
	assert( nil ~= image_type )
	self.data = self.data
		.. string.char(0) -- image id
		.. string.char(colormap_type)
		.. string.char(image_type)
	self:encode_colormap_spec(properties) -- color map specification
	self:encode_image_spec(properties) -- image specification
	self:encode_colormap(properties)
end

function image:encode_data(properties)
	local color_format = properties.color_format
	local colormap = properties.colormap
	local compression = properties.compression

	local data_length_before = #self.data
	if "Y8" == color_format and "RAW" == compression then
		if 8 == self.pixel_depth then
			self:encode_data_Y8_as_Y8_raw()
		elseif 24 == self.pixel_depth then
			self:encode_data_R8G8B8_as_Y8_raw()
		end
	elseif "A1R5G5B5" == color_format then
		if 0 ~= #colormap then
			if "RAW" == compression then
				if 8 == self.pixel_depth then
					self:encode_data_Y8_as_Y8_raw()
				end
			end
		else
			if "RAW" == compression then
				self:encode_data_R8G8B8_as_A1R5G5B5_raw()
			elseif "RLE" == compression then
				self:encode_data_R8G8B8_as_A1R5G5B5_rle()
			end
		end
	elseif "B8G8R8" == color_format then
		if 0 ~= #colormap then
			if "RAW" == compression then
				if 8 == self.pixel_depth then
					self:encode_data_Y8_as_Y8_raw()
				end
			end
		else
			if "RAW" == compression then
				self:encode_data_R8G8B8_as_B8G8R8_raw()
			elseif "RLE" == compression then
			   self:encode_data_R8G8B8_as_B8G8R8_rle()
			end
		end
	elseif "B8G8R8A8" == color_format then
		if 0 ~= #colormap then
			if "RAW" == compression then
				if 8 == self.pixel_depth then
					self:encode_data_Y8_as_Y8_raw()
				end
			end
		else
			if "RAW" == compression then
				self:encode_data_R8G8B8A8_as_B8G8R8A8_raw()
			elseif "RLE" == compression then
				self:encode_data_R8G8B8A8_as_B8G8R8A8_rle()
			end
		end
	end
	local data_length_after = #self.data
	assert(
		data_length_after ~= data_length_before,
		"No data encoded for color format: " .. color_format
	)
end

function image:encode_data_Y8_as_Y8_raw()
	assert(8 == self.pixel_depth)
	local raw_pixels = {}
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			local raw_pixel = string.char(pixel[1])
			raw_pixels[#raw_pixels + 1] = raw_pixel
		end
	end
	self.data = self.data .. table.concat(raw_pixels)
end

function image:encode_data_R8G8B8_as_Y8_raw()
	assert(24 == self.pixel_depth)
	local raw_pixels = {}
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			-- the HSP RGB to brightness formula is
			-- sqrt( 0.299 r² + .587 g² + .114 b² )
			-- see <https://alienryderflex.com/hsp.html>
			local gray = math.floor(
				math.sqrt(
					0.299 * pixel[1]^2 +
					0.587 * pixel[2]^2 +
					0.114 * pixel[3]^2
				) + 0.5
			)
			local raw_pixel = string.char(gray)
			raw_pixels[#raw_pixels + 1] = raw_pixel
		end
	end
	self.data = self.data .. table.concat(raw_pixels)
end

function image:encode_data_R8G8B8_as_A1R5G5B5_raw()
	assert(24 == self.pixel_depth)
	local raw_pixels = {}
	-- Sample depth rescaling is done according to the algorithm presented in:
	-- <https://www.w3.org/TR/2003/REC-PNG-20031110/#13Sample-depth-rescaling>
	local max_sample_in = math.pow(2, 8) - 1
	local max_sample_out = math.pow(2, 5) - 1
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			local colorword = 32768 +
				((math.floor((pixel[1] * max_sample_out / max_sample_in) + 0.5)) * 1024) +
				((math.floor((pixel[2] * max_sample_out / max_sample_in) + 0.5)) * 32) +
				((math.floor((pixel[3] * max_sample_out / max_sample_in) + 0.5)) * 1)
			local raw_pixel = string.char(colorword % 256, math.floor(colorword / 256))
			raw_pixels[#raw_pixels + 1] = raw_pixel
		end
	end
	self.data = self.data .. table.concat(raw_pixels)
end

function image:encode_data_R8G8B8_as_A1R5G5B5_rle()
	assert(24 == self.pixel_depth)
	local colorword
	local previous_r
	local previous_g
	local previous_b
	local raw_pixel
	local raw_pixels = {}
	local count = 1
	local packets = {}
	local raw_packet
	local rle_packet
	-- Sample depth rescaling is done according to the algorithm presented in:
	-- <https://www.w3.org/TR/2003/REC-PNG-20031110/#13Sample-depth-rescaling>
	local max_sample_in = math.pow(2, 8) - 1
	local max_sample_out = math.pow(2, 5) - 1
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			if pixel[1] ~= previous_r or pixel[2] ~= previous_g or pixel[3] ~= previous_b or count == 128 then
				if nil ~= previous_r then
					colorword = 32768 +
						((math.floor((previous_r * max_sample_out / max_sample_in) + 0.5)) * 1024) +
						((math.floor((previous_g * max_sample_out / max_sample_in) + 0.5)) * 32) +
						((math.floor((previous_b * max_sample_out / max_sample_in) + 0.5)) * 1)
					if 1 == count then
						-- remember pixel verbatim for raw encoding
						raw_pixel = string.char(colorword % 256, math.floor(colorword / 256))
						raw_pixels[#raw_pixels + 1] = raw_pixel
						if 128 == #raw_pixels then
							raw_packet = string.char(#raw_pixels - 1)
							packets[#packets + 1] = raw_packet
							for i=1, #raw_pixels do
								packets[#packets +1] = raw_pixels[i]
							end
							raw_pixels = {}
						end
					else
						-- encode raw pixels, if any
						if #raw_pixels > 0 then
							raw_packet = string.char(#raw_pixels - 1)
							packets[#packets + 1] = raw_packet
							for i=1, #raw_pixels do
								packets[#packets +1] = raw_pixels[i]
							end
							raw_pixels = {}
						end
						-- RLE encoding
						rle_packet = string.char(128 + count - 1, colorword % 256, math.floor(colorword / 256))
						packets[#packets +1] = rle_packet
					end
				end
				count = 1
				previous_r = pixel[1]
				previous_g = pixel[2]
				previous_b = pixel[3]
			else
				count = count + 1
			end
		end
	end
	colorword = 32768 +
		((math.floor((previous_r * max_sample_out / max_sample_in) + 0.5)) * 1024) +
		((math.floor((previous_g * max_sample_out / max_sample_in) + 0.5)) * 32) +
		((math.floor((previous_b * max_sample_out / max_sample_in) + 0.5)) * 1)
	if 1 == count then
		raw_pixel = string.char(colorword % 256, math.floor(colorword / 256))
		raw_pixels[#raw_pixels + 1] = raw_pixel
		raw_packet = string.char(#raw_pixels - 1)
		packets[#packets + 1] = raw_packet
		for i=1, #raw_pixels do
			packets[#packets +1] = raw_pixels[i]
		end
	else
		-- encode raw pixels, if any
		if #raw_pixels > 0 then
			raw_packet = string.char(#raw_pixels - 1)
			packets[#packets + 1] = raw_packet
			for i=1, #raw_pixels do
				packets[#packets +1] = raw_pixels[i]
			end
		end
		-- RLE encoding
		rle_packet = string.char(128 + count - 1, colorword % 256, math.floor(colorword / 256))
		packets[#packets +1] = rle_packet
	end
	self.data = self.data .. table.concat(packets)
end

function image:encode_data_R8G8B8_as_B8G8R8_raw()
	assert(24 == self.pixel_depth)
	local raw_pixels = {}
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			local raw_pixel = string.char(pixel[3], pixel[2], pixel[1])
			raw_pixels[#raw_pixels + 1] = raw_pixel
		end
	end
	self.data = self.data .. table.concat(raw_pixels)
end

function image:encode_data_R8G8B8_as_B8G8R8_rle()
	assert(24 == self.pixel_depth)
	local previous_r
	local previous_g
	local previous_b
	local raw_pixel
	local raw_pixels = {}
	local count = 1
	local packets = {}
	local raw_packet
	local rle_packet
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			if pixel[1] ~= previous_r or pixel[2] ~= previous_g or pixel[3] ~= previous_b or count == 128 then
				if nil ~= previous_r then
					if 1 == count then
						-- remember pixel verbatim for raw encoding
						raw_pixel = string.char(previous_b, previous_g, previous_r)
						raw_pixels[#raw_pixels + 1] = raw_pixel
						if 128 == #raw_pixels then
							raw_packet = string.char(#raw_pixels - 1)
							packets[#packets + 1] = raw_packet
							for i=1, #raw_pixels do
								packets[#packets +1] = raw_pixels[i]
							end
							raw_pixels = {}
						end
					else
						-- encode raw pixels, if any
						if #raw_pixels > 0 then
							raw_packet = string.char(#raw_pixels - 1)
							packets[#packets + 1] = raw_packet
							for i=1, #raw_pixels do
								packets[#packets +1] = raw_pixels[i]
							end
							raw_pixels = {}
						end
						-- RLE encoding
						rle_packet = string.char(128 + count - 1, previous_b, previous_g, previous_r)
						packets[#packets +1] = rle_packet
					end
				end
				count = 1
				previous_r = pixel[1]
				previous_g = pixel[2]
				previous_b = pixel[3]
			else
				count = count + 1
			end
		end
	end
	if 1 == count then
		raw_pixel = string.char(previous_b, previous_g, previous_r)
		raw_pixels[#raw_pixels + 1] = raw_pixel
		raw_packet = string.char(#raw_pixels - 1)
		packets[#packets + 1] = raw_packet
		for i=1, #raw_pixels do
			packets[#packets +1] = raw_pixels[i]
		end
	else
		-- encode raw pixels, if any
		if #raw_pixels > 0 then
			raw_packet = string.char(#raw_pixels - 1)
			packets[#packets + 1] = raw_packet
			for i=1, #raw_pixels do
				packets[#packets +1] = raw_pixels[i]
			end
		end
		-- RLE encoding
		rle_packet = string.char(128 + count - 1, previous_b, previous_g, previous_r)
		packets[#packets +1] = rle_packet
	end
	self.data = self.data .. table.concat(packets)
end

function image:encode_data_R8G8B8A8_as_B8G8R8A8_raw()
	assert(32 == self.pixel_depth)
	local raw_pixels = {}
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			local raw_pixel = string.char(pixel[3], pixel[2], pixel[1], pixel[4])
			raw_pixels[#raw_pixels + 1] = raw_pixel
		end
	end
	self.data = self.data .. table.concat(raw_pixels)
end

function image:encode_data_R8G8B8A8_as_B8G8R8A8_rle()
	assert(32 == self.pixel_depth)
	local previous_r
	local previous_g
	local previous_b
	local previous_a
	local raw_pixel
	local raw_pixels = {}
	local count = 1
	local packets = {}
	local raw_packet
	local rle_packet
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			if pixel[1] ~= previous_r or pixel[2] ~= previous_g or pixel[3] ~= previous_b or pixel[4] ~= previous_a or count == 128 then
				if nil ~= previous_r then
					if 1 == count then
						-- remember pixel verbatim for raw encoding
						raw_pixel = string.char(previous_b, previous_g, previous_r, previous_a)
						raw_pixels[#raw_pixels + 1] = raw_pixel
						if 128 == #raw_pixels then
							raw_packet = string.char(#raw_pixels - 1)
							packets[#packets + 1] = raw_packet
							for i=1, #raw_pixels do
								packets[#packets +1] = raw_pixels[i]
							end
							raw_pixels = {}
						end
					else
						-- encode raw pixels, if any
						if #raw_pixels > 0 then
							raw_packet = string.char(#raw_pixels - 1)
							packets[#packets + 1] = raw_packet
							for i=1, #raw_pixels do
								packets[#packets +1] = raw_pixels[i]
							end
							raw_pixels = {}
						end
						-- RLE encoding
						rle_packet = string.char(128 + count - 1, previous_b, previous_g, previous_r, previous_a)
						packets[#packets +1] = rle_packet
					end
				end
				count = 1
				previous_r = pixel[1]
				previous_g = pixel[2]
				previous_b = pixel[3]
				previous_a = pixel[4]
			else
				count = count + 1
			end
		end
	end
	if 1 == count then
		raw_pixel = string.char(previous_b, previous_g, previous_r, previous_a)
		raw_pixels[#raw_pixels + 1] = raw_pixel
		raw_packet = string.char(#raw_pixels - 1)
		packets[#packets + 1] = raw_packet
		for i=1, #raw_pixels do
			packets[#packets +1] = raw_pixels[i]
		end
	else
		-- encode raw pixels, if any
		if #raw_pixels > 0 then
			raw_packet = string.char(#raw_pixels - 1)
			packets[#packets + 1] = raw_packet
			for i=1, #raw_pixels do
				packets[#packets +1] = raw_pixels[i]
			end
		end
		-- RLE encoding
		rle_packet = string.char(128 + count - 1, previous_b, previous_g, previous_r, previous_a)
		packets[#packets +1] = rle_packet
	end
	self.data = self.data .. table.concat(packets)
end

function image:encode_footer()
	self.data = self.data
		.. string.char(0, 0, 0, 0) -- extension area offset
		.. string.char(0, 0, 0, 0) -- developer area offset
		.. "TRUEVISION-XFILE"
		.. "."
		.. string.char(0)
end

function image:encode(properties)
	local properties = properties or {}
	properties.colormap = properties.colormap or {}
	properties.compression = properties.compression or "RAW"

	self.pixel_depth = #self.pixels[1][1] * 8

	local color_format_defaults_by_pixel_depth = {
		[8] = "Y8",
		[24] = "B8G8R8",
		[32] = "B8G8R8A8",
	}
	if nil == properties.color_format then
		if 0 ~= #properties.colormap then
			properties.color_format =
				color_format_defaults_by_pixel_depth[
				#properties.colormap[1] * 8
				]
		else
			properties.color_format =
				color_format_defaults_by_pixel_depth[
					self.pixel_depth
				]
		end
	end
	assert( nil ~= properties.color_format )

	self.data = ""
	self:encode_header(properties) -- header
	-- no color map and image id data
	self:encode_data(properties) -- encode data
	-- no extension or developer area
	self:encode_footer() -- footer
end

function image:save(filename, properties)
	self:encode(properties)

	local f = assert(io.open(filename, "wb"))
	f:write(self.data)
	f:close()
end

tga_encoder.image = image
