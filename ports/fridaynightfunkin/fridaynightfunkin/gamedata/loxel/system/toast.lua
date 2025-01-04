local Toast = {instances = {}, width = 0, height = 0}
Toast.colors = {
	text = Color.fromString("#F5DCC4"),
	box = {0, 0, 0}
}

function Toast.init(width, height)
	Toast.width = width
	Toast.height = height
	Toast.scale = love.graphics.getFixedScale()
	Toast.font = love.graphics.newFont(16 * Toast.scale)
	Toast.bigfont = love.graphics.newFont(20 * Toast.scale)
	Toast.visibleToasts = 0
end

local clock = 0
function Toast.new(text, font)
	local n = #text
	font = font or (n < 14 and Toast.bigfont or Toast.font)

	local width = math.min(Toast.width - 24 * Toast.scale, font:getWidth(text))
	local _, lines = font:getWrap(text, width)
	local t = {
		text = text,
		font = font,
		timer = math.min(n * 0.11, 4),
		width = width,
		height = font:getHeight() * #lines,
		y = Toast.height + 8,
		lastclock = clock
	}

	Toast.visibleToasts = Toast.visibleToasts + 1
	table.insert(Toast.instances, t)
	return t
end

-- Though it isn't possible to resize in mobile but it's here for convenience
function Toast:resize(width, height)
	self.width = width
	self.height = height

	for _, t in ipairs(self.instances) do
		local twidth = math.min(width - 24 * self.scale, t.font:getWidth(t.text))
		local _, lines = t.font:getWrap(t.text, twidth)
		t.width, t.height = twidth, t.font:getHeight() * #lines
	end
end

local dt = 0
function Toast:update(_dt) dt = dt + _dt end

local fill, line = "fill", "line"
local lastVisibleToasts = 0
function Toast:__render()
	local r, g, b, a = love.graphics.getColor()
	local font = love.graphics.getFont()

	local instances, width, height, scale = self.instances, self.width, self.height, self.scale
	local bs1, bs2, offset = 8 * scale, 16 * scale, 24 * scale
	local y = height + bs1

	local visibleToasts, n, t = Toast.visibleToasts, #instances
	for i = n, n - visibleToasts + 1, -1 do
		t = instances[i]

		local timer = t.timer + t.lastclock - clock
		t.lastclock = clock
		if timer < -.3 then
			visibleToasts = visibleToasts - 1
			table.remove(instances, i)
		else
			y = y - t.height - offset
			local ty, th = math.lerp(y, t.y, math.exp(-dt * 6)), t.height
			if ty < -th then
				visibleToasts = n - i
				break
			end

			local tw, ta = t.width, math.min((t.timer + .3) / .3, 1)
			local tx = (width - tw) / 2

			local bx, by, bw, bh = tx - bs1, ty - bs1, tw + bs2, th + bs2
			local c1, c2 = 15 * scale, 36 * scale
			local color = self.colors.box
			love.graphics.setColor(color[1], color[2], color[3], ta * 0.7)
			love.graphics.rectangle(fill, bx, by, bw, bh, c1, c1, c2)
			love.graphics.rectangle(line, bx, by, bw, bh, c1, c1, c2)

			color = self.colors.text
			love.graphics.setColor(color[1], color[2], color[3], ta)
			love.graphics.setFont(t.font)
			love.graphics.printf(t.text, tx, ty, tw)

			t.timer, t.y = timer, ty
		end
	end

	clock = n == 0 and 0 or clock + dt

	self.visibleToasts, lastVisibleToasts, dt = visibleToasts, visibleToasts, 0
	love.graphics.setColor(r, g, b, a)
	love.graphics.setFont(font)
end

return Toast
