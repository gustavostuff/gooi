--[[

Copyright (c) 2015 Gustavo Alberto Lara Gomez

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
	bgColor = {12, 183, 242, 127}, -- LOVE blue
	fgColor = {255, 255, 255, 255},
	tooltipFont = love.graphics.newFont(love.graphics.getWidth() / 60),
	round = .25,
	roundInside = .25,
	showBorder = false,
	borderColor = {12, 183, 242, 255},
	borderWidth = 2,
	font = love.graphics.newFont(love.graphics.getWidth() / 70),
	mode3d = false,
	glass = false
}

local currId = -1
function genId()
	currId = currId + 1
	return currId;
end

----------------------------------------------------------------------------
--------------------------   Component creator  ----------------------------
----------------------------------------------------------------------------
function component.new(id, t, x, y, w, h, group)
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
			return self.bgColor
		end
		if type(color) == "string" then
			color = gooi.toRGBA(color)
		end
		self.bgColor = color
		self.borderColor = {color[1], color[2], color[3], 255}
		self:make3d()
		return self
	end
	function c:fg(color)
		if not color then
			return self.fgColor
		end
		self.fgColor = color
		if type(color) == "string" then
			self.fgColor = gooi.toRGBA(color)
		end
		return self
	end
	function c:roundness(r, ri)
		if not r then return self.round, self.roundInside; end

		if r < 0 then r = 0 end
		if r > 1 then r = 1 end
		self.round = r
		if ri then
			if ri < 0 then ri = 0 end
			if ri > 1 then ri = 1 end
			self.roundInside = ri
		end

		return self
	end
	function c:border(w, color, style)
		if not w then return self.borderWidth, self.borderColor; end

		self.borderWidth = w
		self.borderColor = color or {12, 183, 242, 255}
		if type(color) == "string" then
			self.borderColor = gooi.toRGBA(color)
			self.borderColor[4] = 255
		end
		self.borderStyle = style or "smooth"
		self.showBorder = true
		return self
	end
	function c:noGlass()
		self.glass = false
		return self
	end
	function c:no3D()
		self.mode3d = false
		return self
	end
	function c:setStyle(style)
		self.borderWidth = style.borderWidth
		self.round = style.round
		self.roundInside = style.roundInside
		self.showBorder = style.showBorder
		self.borderColor = style.borderColor
		self.mode3d = style.mode3d
		self.glass = style.glass
		self.bgColor = style.bgColor
		self.fgColor = style.fgColor
		self.tooltipFont = style.tooltipFont
		self.font = style.font

		if self.sons then
			for k, v in pairs(self.sons) do
				v.ref:setStyle(style)
			end
		end
		
		return self
	end
	c:setStyle(component.style)

	function c:make3d()
		-- For a 3D look:
		self.colorTop = self.bgColor
		self.colorBot = self.bgColor

		self.colorTop = changeBrig(self.bgColor, 15)--colorManager.setBrightness(self.colorTop, 0.5)
		self.colorBot = changeBrig(self.bgColor, -15)--colorManager.setBrightness(self.colorBot, 0.5)

		self.colorTopHL = changeBrig(self.bgColor, 25)--colorManager.setBrightness(self.colorTop, 0.5)
		self.colorBotHL = changeBrig(self.bgColor, -5)--colorManager.setBrightness(self.colorBot, 0.5)

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
	if self.opaque and self.visible then
		local r, g, b, a  = self.bgColor[1], self.bgColor[2], self.bgColor[3], self.bgColor[4]
		local focusColorChange = 20
		local fs = - 1
		if not self.enabled then focusColorChange = 0 end
		local newColor = self.bgColor
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
			love.graphics.setColor(63, 63, 63, self.bgColor[4])
		end

		local radiusCorner = self.round * self.h / 2

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
		if self.mode3d and self.glass then
			scaleY = -1
		end

		if self.mode3d then
			love.graphics.setColor(255, 255, 255, self.bgColor[4] or 255)
			if not self.enabled then
				love.graphics.setColor(0, 0, 0, self.bgColor[4] or 255)
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

		if self.glass then
			love.graphics.setColor(255, 255, 255)
			--[[
				if self.mode3d then
					love.graphics.draw(img,
					self.x + self.w / 2,
					self.y + self.h / 2,
					0,
					math.floor(self.w),
					self.h / 2 * -1,
					img:getWidth() / 2,
					img:getHeight() / 2)
				end
			]]
			love.graphics.draw(self.imgGlass,
				self.x,
				self.y,
				0,
				math.floor(self.w),
				self.h / 4)
		end
		love.graphics.setStencilTest()

		-- Border:
		love.graphics.setLineStyle(self.borderStyle or "smooth")
		if self.showBorder then
			love.graphics.setColor(self.borderColor)
			if not self.enabled then
				love.graphics.setColor(63, 63, 63)
			end
			local prevLineW = love.graphics.getLineWidth()
			love.graphics.setLineWidth(self.borderWidth)
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

		if self.hasFocus then
			--love.graphics.setColor(255,0,0)
			--love.graphics.rectangle("fill", self.x,self.y,5,5)
		end

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
			self.sons[i].ref.enabled = b
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
	local xm = love.mouse.getX()
	local ym = love.mouse.getY()

	if self.touch then
		xm, ym = self.touch.x, self.touch.y
	end

	if x and y then
		xm, ym = x, y
	end

	local radiusCorner = self.round * self.h / 2

	-- Check if one of the "two" rectangles is on the mouse/finger:
	local b = not (
		xm < self.x or
		ym < self.y + radiusCorner or
		xm > self.x + self.w or
		ym > self.y + self.h - radiusCorner
	) or not (
		xm < self.x + radiusCorner or
		ym < self.y or
		xm > self.x + self.w - radiusCorner or
		ym > self.y + self.h
	)

	-- Check if mouse/finger is over one of the 4 "circles":

	local x1, x2, y1, y2 =
		self.x + radiusCorner,
		self.x + self.w - radiusCorner,
		self.y + radiusCorner,
		self.y + self.h - radiusCorner

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
	love.graphics.rectangle("fill", x, y+r, w, h-r*2)
	love.graphics.rectangle("fill", x+r, y, w-r*2, r)
	love.graphics.rectangle("fill", x+r, y+h-r, w-r*2, r)
	love.graphics.arc("fill", x+r, y+r, r, left, top)
	love.graphics.arc("fill", x + w-r, y+r, r, -bottom, right)
	love.graphics.arc("fill", x + w-r, y + h-r, r, right, bottom)
	love.graphics.arc("fill", x+r, y + h-r, r, bottom, left)
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