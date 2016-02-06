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
	--bgColor = {0, 0, 0, 127},
	fgColor = {255, 255, 255, 255},
	tooltipFont = love.graphics.newFont(love.graphics.getWidth() / 85),
	howRound = .25,
	howRoundInternally = .25,
	showBorder = false,
	borderColor = {12, 183, 242},
	borderWidth = 2,
	font = love.graphics.newFont(love.graphics.getWidth() / 80)
}

----------------------------------------------------------------------------
--------------------------   Component creator  ----------------------------
----------------------------------------------------------------------------
function component.new(id, t, x, y, w, h, group)
	local c = {}
	c.id = id
	c.type = t
	c.x = x
	c.y = y
	c.w = w
	c.h = h
	c.enabled = true
	c.visible = true
	c.hasFocus = false
	c.pressed = false
	c.bgColor = component.style.bgColor
	c.fgColor = component.style.fgColor
	c.group = group or "default"
	c.tooltip = nil
	c.smallerSide = c.h
	if c.w < c.h then
		c.smallerSide = c.w
	end
	c.tooltipFont = component.style.tooltipFont
	c.timerTooltip = 0
	c.showTooltip = false
	function c:setTooltip(text)
		self.tooltip = text
		return self
	end
	c.font = component.style.font
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
	c.borderWidth = component.style.borderWidth
	c.howRound = component.style.howRound
	c.howRoundInternally = component.style.howRoundInternally
	-- Experimental:
	c.showBorder = component.style.showBorder
	c.borderColor = component.style.borderColor
	function c:setBorderRes(mode)
		if mode == "high" then
			c.resCorner = 5
		elseif mode == "low" then
			c.resCorner = 19
		else
			c.resCorner = 5
			error("Invalid border resolution mode '"..mode.."', expecting 'high' or 'low'")
		end
		return self
	end
	
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
		-- Generate bgColor for over and pressed:
		if self:overIt() and self.type ~= "label" then
			if not self.pressed then fs = 1 end
			r, g, b = r + focusColorChange * fs, g + focusColorChange * fs, b + focusColorChange * fs
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
		local newColor = self:fixColor(r, g, b, a)

		love.graphics.setColor(newColor)

		if not self.enabled then
			love.graphics.setColor(63, 63, 63, self.bgColor[4])
		end

		local radiusCorner = self.howRound * self.h / 2

		--drawRoundRec(self.x, self.y, self.w, self.h, self.radiusCorner)-- Magic function (thanks to Boolsheet!)
		love.graphics.rectangle("fill",
			math.floor(self.x),
			math.floor(self.y),
			math.floor(self.w),
			math.floor(self.h),
			radiusCorner,
			radiusCorner,
			50)

		-- Border:
		love.graphics.setLineStyle("smooth")
		if self.showBorder then
			love.graphics.setColor(self.borderColor)
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

function component:setEnabled(b)
	self.enabled = b
end

function component:setVisible(b)
	self.visible = b
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

function component:overIt(x, y)-- x and y if it's the first time pressed (no touch defined yet).
	if self.type == "panel" or self.type == "label" then
		return false
	end
	if not (self.enabled or self.visible) then return false end

	local xm = love.mouse.getX()
	local ym = love.mouse.getY()

	if self.touch then
		xm, ym = self.touch.x, self.touch.y
	end

	if x and y then
		xm, ym = x, y
	end

	local radiusCorner = self.howRound * self.h / 2

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

function component:setBounds(x, y, w, h)
	local theX = x or self.x
	local theY = y or self.y
	local theW = w or self.w
	local theH = h or self.h

	self.x, self.y, self.w, self.h = theX, theY, theW, theH

	if self.type == "joystick" then
		self.smallerSide = self.h
		if self.w < self.h then
			self.smallerSide = self.w
		end
	end


	return self
end

function component:fixColor(...)
	local comps = {...}
	for i=1,#comps do
		if comps[i] > 255 then comps[i] = 255 end
		if comps[i] < 0   then comps[i] = 0   end
	end
	return comps
end