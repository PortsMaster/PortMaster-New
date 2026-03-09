mcl_formspec = {}

mcl_formspec.label_color = "#313131"

---Get the background of inventory slots (formspec version = 1)
function mcl_formspec.get_itemslot_bg(x, y, w, h)
	local out = ""
	for i = 0, w - 1, 1 do
		for j = 0, h - 1, 1 do
			out = out .. "image[" .. x + i .. "," .. y + j .. ";1,1;mcl_formspec_itemslot.png]"
		end
	end
	return out
end

---This function will replace mcl_formspec.get_itemslot_bg then every formspec will be upgrade to version 4
local function get_slot(x, y, size, texture)
	local t = "image[" .. x - size .. "," .. y - size .. ";" .. 1 + (size * 2) ..
		"," .. 1 + (size * 2) .. ";" .. (texture and texture or "mcl_formspec_itemslot.png") .. "]"
	return t
end

mcl_formspec.itemslot_border_size = 0.05

---Get the background of inventory slots (formspec version > 1)
function mcl_formspec.get_itemslot_bg_v4(x, y, w, h, size, texture)
	if not size then
		size = mcl_formspec.itemslot_border_size
	end
	local out = ""
	for i = 0, w - 1, 1 do
		for j = 0, h - 1, 1 do
			out = out .. get_slot(x + i + (i * 0.25), y + j + (j * 0.25), size, texture)
		end
	end
	return out
end
