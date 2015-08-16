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
component.defaultBg = {12, 183, 242, 127}
component.defaultFg = {255, 255, 255, 255}
component.toolTipFont = love.graphics.newFont(love.graphics.getWidth() / 75)

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
	c.bgColor = component.defaultBg
	c.fgColor = component.defaultFg
	c.group = group or "default"
	c.showToolTip = false
	c.font = nil
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
	c.borderW = c.h / 15
	c.radiusCorner = c.h / 8
	if c.w < c.h then
		c.borderW = c.w / 20
		c.radiusCorner = c.w / 8
	end
	-- Experimental:
	c.showBorder = true
	c.resCorner = 9
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
	c.toolTip = nil
	c.timerToolTip = 0
	function c:setToolTip(text)
		self.toolTip = text
	end
	function c:generateCurveCorner()
		local t = {}
		for i = 180, 270, self.resCorner do -- Generate left-upper arc of points:
			local x = self.x + self.radiusCorner + (self.radiusCorner * math.cos(math.rad(i)))
			local y = self.y + self.radiusCorner + (self.radiusCorner * math.sin(math.rad(i)))
			table.insert(t, x)
			table.insert(t, y)
		end
		return t
	end
	function c:generateBorder()
		-- Reset points:
		self.ptsCorner = self:generateCurveCorner()
		-- Generate mirror on X:
		local ptsXR = {}
		for i = #self.ptsCorner - 1, 1, - 2 do
			local newXP = self.ptsCorner[i] + (self.x + self.w / 2 - self.ptsCorner[i]) * 2
			table.insert(self.ptsCorner, newXP)
			table.insert(self.ptsCorner, self.ptsCorner[i + 1])
		end
		-- On Y:
		for i = #self.ptsCorner - 1, 1, - 2 do
			local newYP = self.ptsCorner[i + 1] + (self.y + self.h / 2 - self.ptsCorner[i + 1]) * 2
			table.insert(self.ptsCorner, self.ptsCorner[i])
			table.insert(self.ptsCorner, newYP)
		end
		-- Remove points causing problems with love.graphics.polygon:
		table.remove(self.ptsCorner, 1)
		table.remove(self.ptsCorner, 1)
		table.remove(self.ptsCorner, #self.ptsCorner / 4)
		table.remove(self.ptsCorner, #self.ptsCorner / 4)
		table.remove(self.ptsCorner, #self.ptsCorner / 2)
		table.remove(self.ptsCorner, #self.ptsCorner / 2)
		table.remove(self.ptsCorner, #self.ptsCorner / 2 + #self.ptsCorner / 4)
		table.remove(self.ptsCorner, #self.ptsCorner / 2 + #self.ptsCorner / 4)
		return self
	end
	
	-- Actually create the border:
	c:generateBorder()
	----------------------------------------------------------
	--print("points of "..c.id..": "..#c.ptsCorner / 2)
	function c:drawBorder()
		love.graphics.setLineWidth(self.borderW)
		if self.showBorder then
			love.graphics.setColor(self.bgColor[1], self.bgColor[2], self.bgColor[3])
			if not self.enabled then
				love.graphics.setColor(63, 63, 63)
			end
			if self.radiusCorner == 0 then
				love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
			else
				love.graphics.polygon("line", self.ptsCorner)
				love.graphics.setColor(255,255,0)
				--print(#self.ptsCorner)
				--love.graphics.setPointStyle("rough")
				--for i=1,#self.ptsCorner-1,2 do
				--	love.graphics.point(self.ptsCorner[i],self.ptsCorner[i+1])
				--end
			end
		end
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
			if self.toolTip then
				self.timerToolTip = self.timerToolTip + love.timer.getDelta()
				if self.timerToolTip >= 0.5 then
					self.showToolTip = true
				end
			end
		else
			self.timerToolTip = 0
			self.showToolTip = false
		end
		local newColor = self:fixColor(r, g, b, a)

		love.graphics.setColor(newColor)

		if not self.enabled then
			love.graphics.setColor(63, 63, 63, self.bgColor[4])
		end

		drawRoundRec(self.x, self.y, self.w, self.h, self.radiusCorner)-- Magic function (thanks to Boolsheet!)

		-- Border:
		self:drawBorder()

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
	if not (self.enabled or self.visible) then return false end

	local xm = love.mouse.getX()
	local ym = love.mouse.getY()

	if self.touch then
		xm, ym = self.touch.x, self.touch.y
	end

	if x and y then
		xm, ym = x, y
	end

	-- Check if one of the "two" rectangles is on the mouse/finger:
	local b = not (
		xm < self.x or
		ym < self.y + self.radiusCorner or
		xm > self.x + self.w or
		ym > self.y + self.h - self.radiusCorner
	) or not (
		xm < self.x + self.radiusCorner or
		ym < self.y or
		xm > self.x + self.w - self.radiusCorner or
		ym > self.y + self.h
	)

	-- Check if mouse/finger is over one of the 4 "circles":

	local x1, x2, y1, y2 =
		self.x + self.radiusCorner,
		self.x + self.w - self.radiusCorner,
		self.y + self.radiusCorner,
		self.y + self.h - self.radiusCorner

	local hyp1 = math.sqrt(math.pow(xm - x1, 2) + math.pow(ym - y1, 2))
	local hyp2 = math.sqrt(math.pow(xm - x2, 2) + math.pow(ym - y1, 2))
	local hyp3 = math.sqrt(math.pow(xm - x1, 2) + math.pow(ym - y2, 2))
	local hyp4 = math.sqrt(math.pow(xm - x2, 2) + math.pow(ym - y2, 2))

	return (hyp1 < self.radiusCorner or
			hyp2 < self.radiusCorner or
			hyp3 < self.radiusCorner or
			hyp4 < self.radiusCorner or b), index, xm, ym
end

function component:setBounds(x, y, w, h)
	local theX = x or self.x
	local theY = y or self.y
	local theW = w or self.w
	local theH = h or self.h

	self.x, self.y, self.w, self.h = theX, theY, theW, theH

	self:generateBorder()
end

function component:fixColor(...)
	local comps = {...}
	for i=1,#comps do
		if comps[i] > 255 then comps[i] = 255 end
		if comps[i] < 0   then comps[i] = 0   end
	end
	return comps
end

--------------------------------------------------------------------------
-- Useful stuff:
--------------------------------------------------------------------------

function component:setRadiusCorner(value)
	self.radiusCorner = value
	if self.radiusCorner > self.h / 2 then self.radiusCorner = self.h / 2 end
	if self.radiusCorner < 0 then self.radiusCorner = 0 end
end

function drawRoundRec(x, y, w, h, r)
	local right = 0
	local left = math.pi
	local bottom = math.pi * 0.5
	local top = math.pi * 1.5
	
	local r = r or h / 2
	if r > h / 2 then r = h / 2 end
	if r < 0 then r = 0 end

	love.graphics.rectangle("fill", x, y + r, w, h - r * 2)
	love.graphics.rectangle("fill", x + r, y, w - r * 2, r)
	love.graphics.rectangle("fill", x + r, y + h - r, w - r * 2, r)

	love.graphics.arc("fill", x + r, y + r, r, left, top)
	love.graphics.arc("fill", x + w - r, y + r, r, - bottom, right)
	love.graphics.arc("fill", x + w - r, y + h - r, r, right, bottom)
	love.graphics.arc("fill", x + r, y + h - r, r, bottom, left)
end