colorManager = {}
colorManager.__index = colorManager

-- Thanks to EmmanuelOga for this converters (https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua):
function colorManager.rgbToHsl(r, g, b, a)
	r, g, b = r / 255, g / 255, b / 255

	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, l

	l = (max + min) / 2

	if max == min then
		h, s = 0, 0 -- achromatic
	else
		local d = max - min
		--local s  <-- Causing problems.
		if l > 0.5 then
			s = d / (2 - max - min)
		else
			s = d / (max + min)
		end

		if max == r then
			h = (g - b) / d
			if g < b then h = h + 6 end
		elseif max == g then
			h = (b - r) / d + 2
		elseif max == b then
			h = (r - g) / d + 4
		end
		h = h / 6
	end

	return h, s, l, (a or 255)
end

function colorManager.hslToRgb(h, s, l, a)
	local r, g, b

	if s == 0 then
		r, g, b = l, l, l -- achromatic
	else
		function hue2rgb(p, q, t)
			if t < 0   then t = t + 1 end
			if t > 1   then t = t - 1 end
			if t < 1/6 then return p + (q - p) * 6 * t end
			if t < 1/2 then return q end
			if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
			return p
		end

		local q
		if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
		local p = 2 * l - q

		r = hue2rgb(p, q, h + 1/3)
		g = hue2rgb(p, q, h)
		b = hue2rgb(p, q, h - 1/3)
	end

	return r * 255, g * 255, b * 255, a * 255
end

function colorManager.setBrightness(c, v)
	local h, s, l, a = colorManager.rgbToHsl(c[1], c[2], c[3], c[4] or 255)
	l = v
	local r, g, b, a = colorManager.hslToRgb(h, s, l, a)
	
	local color = {r, g, b, 255 - a}
	return color
end