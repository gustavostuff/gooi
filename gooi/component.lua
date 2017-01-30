--[[

Copyright (c) 2015-2017 Gustavo Alberto Lara Gómez

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

component = {}
component.__index = component
component.style = {
    bgColor = {12, 183, 242, 170}, -- LOVE blue
    fgColor = {255, 255, 255, 255}, -- Foreground color
    tooltipFont = love.graphics.newFont(love.window.toPixels(11)), -- tooltips are smaller than the main font
    radius = 3, -- radius for the outer shapes of components
    innerRadius = 3, -- For the inner ones
    showBorder = false, -- border for components
    borderColor = {12, 183, 242, 255},
    borderWidth = 2, -- in pixels
    borderStyle = "rough", -- or "smooth"
    font = love.graphics.newFont(love.window.toPixels(13)),
    mode3d = false, -- gives that subtle gradient on the given color
    glass = false -- for a glass effect (horizon reflection)
}

local currId = -1
function genId()
	currId = currId + 1
	return currId;
end

----------------------------------------------------------------------------
--------------------------   Component creator  ----------------------------
----------------------------------------------------------------------------
function component.new(t, x, y, w, h, group)
	local c = {}
	c.id = genId()
	c.type = t
	c.x = x
	c.y = y
	c.w = w
	c.h = h
	c.enabled = true
	c.visible = true
	c.hasFocus = false
	c.pressed = false
	c.group = group or "default"
	c.tooltip = nil
	c.smallerSide = c.h
	if c.w < c.h then
		c.smallerSide = c.w
	end
	c.timerTooltip = 0
	c.showTooltip = false
	function c:setTooltip(text)
		self.tooltip = text
		return self
	end
	c.touch = nil-- Stores the touch which is on this component.
	c.opaque = true-- If false, the component base will never be drawn.
	c.events = {p = nil, r = nil, m = nil}
	function c:onPress(f)
		c.events.p = f
		return self
	end
	function c:onRelease(f)
		c.events.r = f
		return self
	end
	function c:onMoved(f)
		c.events.m = f
		return self
	end
	function c:bg(color)
		if not color then
			return self.style.bgColor
		end
		if type(color) == "string" then
			color = gooi.toRGBA(color)
		end
		self.style.bgColor = color
		self.style.borderColor = {color[1], color[2], color[3], 255}
		self:make3d()
		return self
	end
	function c:fg(color)
		if not color then
			return self.style.fgColor
		end
		self.style.fgColor = color
		if type(color) == "string" then
			self.style.fgColor = gooi.toRGBA(color)
		end
		return self
	end
	function c:setRadius(r, ri)
		if not r then return self.style.radius, self.style.innerRadius; end

		self.style.radius = r
		if ri then
			self.style.innerRadius = ri
		end

		return self
	end
	function c:border(w, color, style)
		if not w then return self.style.borderWidth, self.style.borderColor; end

		self.style.borderWidth = w
		self.style.borderColor = color or {12, 183, 242, 255}
		if type(color) == "string" then
			self.style.borderColor = gooi.toRGBA(color)
			self.style.borderColor[4] = 255
		end
		self.style.borderStyle = style or "smooth"
		self.style.showBorder = true
		return self
	end
	function c:noGlass()
		self.style.glass = false
		return self
	end
	function c:no3D()
		self.style.mode3d = false
		return self
	end
	
	c.style = gooi.deepcopy(component.style)

	function c:make3d()
		-- For a 3D look:
		self.colorTop = self.style.bgColor
		self.colorBot = self.style.bgColor

		self.colorTop = changeBrig(self.style.bgColor, 15)
		self.colorBot = changeBrig(self.style.bgColor, -15)

		self.colorTopHL = changeBrig(self.style.bgColor, 25)
		self.colorBotHL = changeBrig(self.style.bgColor, -5)

		self.imgData3D = love.image.newImageData(1, 2)
		self.imgData3D:setPixel(0, 0, self.colorTop[1], self.colorTop[2], self.colorTop[3], self.colorTop[4])
		self.imgData3D:setPixel(0, 1, self.colorBot[1], self.colorBot[2], self.colorBot[3], self.colorBot[4])

		self.imgData3DHL = love.image.newImageData(1, 2)
		self.imgData3DHL:setPixel(0, 0, self.colorTopHL[1], self.colorTopHL[2], self.colorTopHL[3], self.colorTopHL[4])
		self.imgData3DHL:setPixel(0, 1, self.colorBotHL[1], self.colorBotHL[2], self.colorBotHL[3], self.colorBotHL[4])

		self.img3D = love.graphics.newImage(self.imgData3D)
		self.img3DHL = love.graphics.newImage(self.imgData3DHL)

		self.img3D:setFilter("linear", "linear")
		self.img3DHL:setFilter("linear", "linear")

		self.imgDataGlass = love.image.newImageData(1, 2)
		self.imgDataGlass:setPixel(0, 0, 255, 255, 255, 80)
		self.imgDataGlass:setPixel(0, 1, 255, 255, 255, 40)
		self.imgGlass = love.graphics.newImage(self.imgDataGlass)
		self.imgGlass:setFilter("linear", "linear")
	end

	c:make3d()
	
	return setmetatable(c, component)
end


----------------------------------------------------------------------------
--------------------------   Draw the component  ---------------------------
----------------------------------------------------------------------------
function component:draw()-- Every component has the same base:
	love.graphics.setLineWidth(self.h / 25)
	local style = self.style
	if self.opaque and self.visible then
		local focusColorChange = 20
		local fs = - 1
		if not self.enabled then focusColorChange = 0 end
		local newColor = style.bgColor
		-- Generate bgColor for over and pressed:
		if self:overIt() and self.type ~= "label" then
			if not self.pressed then fs = 1 end
			newColor = changeBrig(newColor, 20 * fs)
			if self.tooltip then
				self.timerTooltip = self.timerTooltip + love.timer.getDelta()
				if self.timerTooltip >= 0.5 then
					self.showTooltip = true
				end
			end
		else
			self.timerTooltip = 0
			self.showTooltip = false
		end

		love.graphics.setColor(newColor)

		if not self.enabled then
			love.graphics.setColor(63, 63, 63, style.bgColor[4] or 255)
		end

		local radiusCorner = style.radius

		function mask()
			love.graphics.rectangle("fill",
				math.floor(self.x),
				math.floor(self.y),
				math.floor(self.w),
				math.floor(self.h),
				radiusCorner,
				radiusCorner,
				50)
		end
		love.graphics.stencil(mask, "replace", 1)
		love.graphics.setStencilTest("greater", 0)
		local scaleY = 1
		local img = self.img3D
		if self:overIt() then
			img = self.img3DHL
			if self.pressed then
				img = self.img3D
				if self.type == "button" then
					scaleY = scaleY * -1
				end
			end
		end
		-- Correct light effect when 2 modes are set:
		if style.mode3d and style.glass then
			scaleY = -1
		end

		if style.mode3d then
			love.graphics.setColor(255, 255, 255, style.bgColor[4] or 255)
			if not self.enabled then
				love.graphics.setColor(0, 0, 0, style.bgColor[4] or 255)
			end
			love.graphics.draw(img,
				self.x + self.w / 2,
				self.y + self.h / 2,
				0,
				math.floor(self.w),
				self.h / 2 * scaleY,
				img:getWidth() / 2,
				img:getHeight() / 2)

		else
			love.graphics.rectangle("fill",
				math.floor(self.x),
				math.floor(self.y),
				math.floor(self.w),
				math.floor(self.h),
				radiusCorner,
				radiusCorner,
				50)
		end

		if style.glass then
			love.graphics.setColor(255, 255, 255)
			love.graphics.draw(self.imgGlass,
				self.x,
				self.y,
				0,
				math.floor(self.w),
				self.h / 4)
		end
		love.graphics.setStencilTest()

		-- Border:
		love.graphics.setLineStyle(style.borderStyle)
		if style.showBorder then
			love.graphics.setColor(style.borderColor)
			if not self.enabled then
				love.graphics.setColor(63, 63, 63)
			end
			local prevLineW = love.graphics.getLineWidth()
			love.graphics.setLineWidth(style.borderWidth)
			love.graphics.rectangle("line",
				math.floor(self.x),
				math.floor(self.y),
				math.floor(self.w),
				math.floor(self.h),
				radiusCorner,
				radiusCorner,
				50)
			love.graphics.setLineWidth(prevLineW)
		end
		love.graphics.setLineStyle("rough")

		-- Restore paint:
		love.graphics.setColor(255, 255, 255)
	end
end

function component:setVisible(b)
	self.visible = b
	if self.sons then
		for i = 1, #self.sons do
			self.sons[i].ref.visible = b
		end
	end
end

function component:setEnabled(b)
	self.enabled = b
	if self.sons then
		for i = 1, #self.sons do
			local c = self.sons[i].ref
			c.enabled = b
			c.style.glass = b
			c.style.mode3d = b
		end
	end
end

function component:setGroup(g)
	self.group = g
	if self.sons then
		for i = 1, #self.sons do
			self.sons[i].ref.group = g
		end
	end
	return self
end

function component:wasReleased()
	local b = self:overIt() and self.enabled and self.visible
	if self.type == "text" then
		if b then
			love.keyboard.setTextInput(true) 
		end
	end
	return b
end

function component:overItAux(x, y)
	-- Scale:
	local xm = love.mouse.getX() / gooi.sx
	local ym = love.mouse.getY() / gooi.sy

	if self.touch then
		xm, ym = self.touch.x, self.touch.y-- Already scaled.
	end
	-- Scale:
	if x and y then
		xm, ym = x, y
	end

	local radiusCorner = self.style.radius

	local theX = self.x
	local theY = self.y
	local theW = self.w
	local theH = self.h

	-- Check if one of the "two" rectangles is on the mouse/finger:
	local b = not (
		xm < theX or
		ym < theY + radiusCorner or
		xm > theX + theW or
		ym > theY + theH - radiusCorner
	) or not (
		xm < theX + radiusCorner or
		ym < theY or
		xm > theX + theW - radiusCorner or
		ym > theY + theH
	)

	-- Check if mouse/finger is over one of the 4 "circles":

	local x1, x2, y1, y2 =
		theX + radiusCorner,
		theX + theW - radiusCorner,
		theY + radiusCorner,
		theY + theH - radiusCorner

	local hyp1 = math.sqrt(math.pow(xm - x1, 2) + math.pow(ym - y1, 2))
	local hyp2 = math.sqrt(math.pow(xm - x2, 2) + math.pow(ym - y1, 2))
	local hyp3 = math.sqrt(math.pow(xm - x1, 2) + math.pow(ym - y2, 2))
	local hyp4 = math.sqrt(math.pow(xm - x2, 2) + math.pow(ym - y2, 2))

	return (hyp1 < radiusCorner or
			hyp2 < radiusCorner or
			hyp3 < radiusCorner or
			hyp4 < radiusCorner or b), index, xm, ym
end

function component:overIt(x, y)-- x and y if it's the first time pressed (no touch defined yet).
	if self.type == "panel" or self.type == "label" then
		return false
	end

	-- Not applicable in this case:
	if not (self.enabled or self.visible) then return false end

	if self.noFlag or self.okFlag or self.yesFlag then
		return self:overItAux(x, y)
	else
		if gooi.showingDialog then
			return false
		else
			return self:overItAux(x, y)
		end
	end
end

function component:setBounds(x, y, w, h)
	local theX = x or self.x
	local theY = y or self.y
	local theW = w or self.w
	local theH = h or self.h

	self.x, self.y, self.w, self.h = theX, theY, theW, theH

	if self.type == "joystick" or self.type == "knob" then
		self.smallerSide = self.h
		if self.w < self.h then
			self.smallerSide = self.w
		end
		self.w, self.h = self.smallerSide, self.smallerSide
		self:rebuild()
	end

	return self
end

function component:setOpaque(b)
	self.opaque = b
	return self
end

-- Thanks to Boolsheet:
function roundRect(x, y, w, h, r)
	r = r or h / 4
	love.graphics.rectangle("fill", x, y + r, w, h - r * 2)
	love.graphics.rectangle("fill", x + r, y, w - r * 2, r)
	love.graphics.rectangle("fill", x + r, y + h - r, w - r * 2, r)
	love.graphics.arc("fill", x + r, y + r, r, left, top)
	love.graphics.arc("fill", x + w - r, y + r, r, -bottom, right)
	love.graphics.arc("fill", x + w - r, y + h - r, r, right, bottom)
	love.graphics.arc("fill", x + r, y + h - r, r, bottom, left)
end

function changeBrig(color, amount)
	if type(color) == "string" then
		color = gooi.toRGBA(color)
	end

	local r, g, b, a = color[1], color[2], color[3], color[4] or 255

	r = r + amount
	g = g + amount
	b = b + amount
	--a = a + amount

	if r < 0 then r = 0 end
	if r > 255 then r = 255 end

	if g < 0 then g = 0 end
	if g > 255 then g = 255 end

	if b < 0 then b = 0 end
	if b > 255 then b = 255 end

	--if a < 0 then a = 0 end
	--if a > 255 then a = 255 end

	return {r, g, b, a}
end