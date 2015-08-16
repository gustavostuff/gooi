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


gooi = {}
gooi.__index = gooi
gooi.font = love.graphics.getFont()
gooi.viewPortMode = false
gooi.components = {}

local circleRes = 50

function gooi.storeComponent(c, id)
	if gooi.components[id] ~= nil then
		error("Component '"..id.."' already defined!")
	else
		gooi.components[id] = c
		return c
	end
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Label creator  --------------------------------
----------------------------------------------------------------------------
function gooi.newLabel(id, label, x, y, w, h, image, orientation,  group)
	local l = {}
	x, y, w, h = gooi.checkBounds(label, x, y, w, h, "label")
	l = component.new(id, "label", x, y, w, h, group)
	l.opaque = false
	l.label = label
	l.image = image
	l.orientation = orientation
	if type(image) == "string" then
		l.image = love.graphics.newImage(image)
	end
	function l:drawLabel(fg)
		local t = self.label or ""
		-- Middel by default:
		local x = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(t) / 2)
		local y = (self.y + self.h / 2) - (gooi.getFont(self):getHeight() / 2)
		if self.orientation == "left" then
			x = self.x + self.h / 2 
		elseif self.orientation == "right" then
			x = self.x + self.w - self.h / 2 - gooi.getFont(self):getWidth(t)
		end
		if self.image then
			local xImg = math.floor(x)
			love.graphics.setColor(255, 255, 255)
			if not self.enabled then gr.setColor(0, 0, 0) end
			
			if self.orientation ~= "right" then
				x = x + self.image:getWidth()
			else
				xImg = xImg - self.image:getWidth()
			end
			if t:len() == 0 then
				xImg = self.x + self.w / 2
			end
			
			love.graphics.draw(self.image, xImg, math.floor(self.y + self.h / 2), 0, 1, 1,
				self.image:getWidth() / 2, self.image:getHeight() / 2)
		end
		love.graphics.setColor(fg)
		love.graphics.print(self.label, x, y)
	end
	return gooi.storeComponent(l, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Button creator  -------------------------------
----------------------------------------------------------------------------
function gooi.newButton(id, label, x, y, w, h, image, group)
	local b = {}
	x, y, w, h = gooi.checkBounds(label, x, y, w, h, "button")
	b = component.new(id, "button", x, y, w, h, group)
	b.label = label
	b.image = image
	if type(image) == "string" then
		b.image = love.graphics.newImage(image)
	end
	b.pressedMove = 0
	function b:drawButton(fg)
		self.pressedMove = 0
		if self.pressed or self.touch then
			self.pressedMove = self.h / 20
		end
		-- Center label:
		local t = self.label or ""
		local x = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(t) / 2)
		local y = (self.y + self.h / 2) - (gooi.getFont(self):getHeight() / 2)
		if self.image then
			local xImg = math.floor(self.x + self.h / 2)
			if t:len() == 0 then
				xImg = self.x + self.w / 2
			end
			love.graphics.setColor(255, 255, 255)
			if not self.enabled then gr.setColor(0, 0, 0) end
			love.graphics.draw(self.image,
				xImg,
				math.floor(self.y + self.h / 2) + self.pressedMove, 0, 1, 1,
				self.image:getWidth() / 2, self.image:getHeight() / 2)
			x = x + self.image:getWidth()
		end
		love.graphics.setColor(fg)
		love.graphics.print(t, x, y + self.pressedMove)
	end
	return gooi.storeComponent(b, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Slider creator  -------------------------------
----------------------------------------------------------------------------
function gooi.newSlider(id, x, y, w, h, value, group)
	local s = {}
	x, y, w, h = gooi.checkBounds("12345678", x, y, w, h, "slider")
	s = component.new(id, "slider", x, y, w, h, group)
	s.value = value or 0.5

	if s.value < 0 then s.value = 0 end
	if s.value > 1 then s.value = 1 end

	-- Correct slider bounds:
	if s.h >= s.w then s.w = s.h * 1.1 end

	s.displacement = (s.w - s.h) * s.value

	function s:drawSlider(fg)
		local rad = self.h * .4 -- Normal radius for the white circles.
		love.graphics.setColor(fg)
		love.graphics.line(self.x + self.h / 2, self.y + self.h / 2, self.x + self.w - self.h / 2, self.y + self.h / 2)
		local fill = "fill"
		if self.pressed or self.touch then rad = rad * .5 end
		love.graphics.circle("fill", self.x + self.h / 2 + self.displacement, self.y + self.h / 2, rad, circleRes)
		love.graphics.circle("line", self.x + self.h / 2 + self.displacement, self.y + self.h / 2, rad, circleRes)
	end
	function s:updateValue(theX)
		self.displacement = (theX - (self.x + self.h / 2))
		if self.displacement > (self.w - self.h) then self.displacement = self.w - self.h end
		if self.displacement < 0 then self.displacement = 0 end
		self.value = self.displacement / (self.w - self.h)
	end
	function s:setValue(v)
		self:updateValue((self.x + self.w / 2))
	end
	return gooi.storeComponent(s, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Checkbox creator  -----------------------------
----------------------------------------------------------------------------
function gooi.newCheckbox(id, label, x, y, w, h, checked, group)
	local chb = {}
	x, y, w, h = gooi.checkBounds(label, x, y, w, h, "checkbox")
	chb = component.new(id, "checkbox", x, y, w, h, group)
	chb.checked = checked or false
	chb.label = label
	function chb:drawCheckbox(fg)
		local rad = .4 -- Normal radius for the white circles.
		love.graphics.setColor(0, 0, 0)
		love.graphics.circle("fill", self.x + self.h / 2, self.y + self.h / 2, self.h * rad, circleRes)
		--rad = rad * .7
		local fill = "line"
		if self.checked then
			fill = "fill"
		end
		love.graphics.setColor(fg)
		love.graphics.circle(fill, self.x + self.h / 2, self.y + self.h / 2, self.h * rad, circleRes)
		love.graphics.circle("line", self.x + self.h / 2, self.y + self.h / 2, self.h * rad, circleRes)
		-- Label of the checkbox:
		love.graphics.setColor(fg)
		love.graphics.print(self.label, self.x + self.h, self.y + self.h / 2 - gooi.getFont(self):getHeight() / 2)
	end
	function chb:change()
		self.checked = not self.checked
	end
	return gooi.storeComponent(chb, id)
end




----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Radio button creator   ------------------------
----------------------------------------------------------------------------
function gooi.newRadio(id, label, x, y, w, h, selected, radioGroup, group)
	local r = {}
	x, y, w, h = gooi.checkBounds(label, x, y, w, h, "radio")
	r = component.new(id, "radio", x, y, w, h, group)
	r.selected = selected or false
	r.label = label
	r.radioGroup = radioGroup or "default"
	function r:drawRadio(fg)
		local rad = .4 -- Normal radius for the white circles.
		love.graphics.setColor(0, 0, 0)
		love.graphics.circle("fill", self.x + self.h / 2, self.y + self.h / 2, self.h * rad, circleRes)
		love.graphics.circle("line", self.x + self.h / 2, self.y + self.h / 2, self.h * rad, circleRes)
		love.graphics.setColor(fg)
		if self.selected then
			love.graphics.circle("fill", self.x + self.h / 2, self.y + self.h / 2, self.h * rad / 2, circleRes)
			love.graphics.circle("line", self.x + self.h / 2, self.y + self.h / 2, self.h * rad / 2, circleRes)
		end
		love.graphics.print(self.label, self.x + self.h, self.y + self.h / 2 - gooi.getFont(self):getHeight() / 2)
	end
	function r:select()
		self.selected = true
		gooi.deselectOtherRadios(self.radioGroup, self.id)
	end
	return gooi.storeComponent(r, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Textfield creator   ---------------------------
----------------------------------------------------------------------------
function gooi.newTextfield(id, text, x, y, w, h, group)
	local f = {}
	x, y, w, h = gooi.checkBounds(text, x, y, w, h, "text")
	f = component.new(id, "text", x, y, w, h, group)
	f.text = text or ""
	f.timerCursor = 0
	f.delayCursor = 0.5
	f.showingCursor = true
	f.accentuationComing = false -- Support for typing á, é, í, ó, ú and Á, É, Í, Ó, Ú (on PC).
	f.indexCursor = string.utf8len(f.text)
	f.displacementCursor = f.x + f.h / 2 * 1.1 + gooi.getFont(self):getWidth(f.text)
	
	function f:drawTextField(fg)
		local rad = .4 -- Normal radius for the white circles.
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", self.x + self.h / 2, self.y + self.h * .1, self.w - self.h, self.h * .8)
		love.graphics.setColor(fg)
		love.graphics.rectangle("line", self.x + self.h / 2, self.y + self.h * .1, self.w - self.h, self.h * .8)
		if self.hasFocus then
			self:drawCursor()
		end
		self:drawText()
	end

	function f:drawCursor()
		if self.hasFocus then
			if self.showingCursor then
				love.graphics.line(
					self.displacementCursor,
					self.y + self.h / 5, 
					self.displacementCursor,
					self.y + self.h - self.h / 5)
			end
		end
	end

	function f:updateFlashingCursor(dt)
		self.timerCursor = self.timerCursor + dt
		if self.timerCursor > self.delayCursor then
			self.timerCursor = 0
			self.showingCursor = not self.showingCursor
		end
	end

	function f:moveCursor(key)
		if key then
			--[[
			if key == "left" then
				self.indexCursor = self.indexCursor - 1
			elseif key == "right" then
				self.indexCursor = self.indexCursor + 1
			end
			]]
			if key == "backspace" then
				self.text = string.utf8sub(self.text, 1, string.utf8len(self.text) - 1)
			end

			if self.indexCursor > string.utf8len(self.text) then
				self.indexCursor = string.utf8len(self.text)
			end
			if self.indexCursor < 0 then
				self.indexCursor = 0
			end

			self.displacementCursor = self.x + self.h / 2 * 1.1 + gooi.getFont(self):getWidth(string.utf8sub(self.text, 1, self.indexCursor))
		else
			self.indexCursor = self.indexCursor + 1
			self.displacementCursor = self.x + self.h / 2 * 1.1 + gooi.getFont(self):getWidth(self.text)
		end
	end

	function f:drawText()
		love.graphics.print(self.text, self.x + self.h / 2 * 1.1, self.y + self.h / 2 - gooi.getFont(self):getHeight() / 2)
	end

	return gooi.storeComponent(f, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Progress bar creator   ------------------------
----------------------------------------------------------------------------
function gooi.newProgressBar(id, x, y, w, h, value, color1, color2, group)
	local p = {}
	x, y, w, h = gooi.checkBounds("12345678", x, y, w, h, "progressbar")
	p = component.new(id, "progressbar", x, y, w, h, group)
	p.value = value or 0
	if p.value > 1 then p.value = 1 end
	if p.value < 0 then p.value = 0 end
	function p:drawProgressBar(fg)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", self.x + self.h / 2, self.y + self.h * .1, self.w - self.h, self.h * .8)
		love.graphics.setColor(self.fgColor)
		love.graphics.rectangle("fill", self.x + self.h / 2, self.y + self.h * .1, self.value * (self.w - self.h), self.h * .8)
		love.graphics.setColor(self.bgColor)
		love.graphics.rectangle("line", self.x + self.h / 2, self.y + self.h * .1, self.w - self.h, self.h * .8)
	end
	function p:changeValue(amount, dt, sense)
		if amount > 1 then amount = 1 end
		if amount < 0 then amount = 0 end
		local delta = 1
		if dt then delta = dt end
		self.value = self.value + amount * delta * sense
		if self.value > 1 then self.value = 1 end
		if self.value < 0 then self.value = 0 end
	end
	function p:increase(amount, dt)
		self:changeValue(amount, dt, 1)
	end
	function p:decrease(amount, dt)
		self:changeValue(amount, dt, -1)
	end
	return gooi.storeComponent(p, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Spinner creator  ------------------------------
----------------------------------------------------------------------------
function gooi.newSpinner(id, x, y, w, h, value, min, max, step, group)
	local s = {}
	local v = value or 0
	local maxv = max or 10
	x, y, w, h = gooi.checkBounds(tostring(maxv), x, y, w, h, "spinner")
	s = component.new(id, "spinner", x, y, w, h, group)
	s.value = v
	s.realValue = s.value
	s.max = maxv
	s.min = min or 0
	s.minPressed, s.plusPressed = false, false
	s.amountChange = .1
	s.timerChange = 0
	s.timerPreChange = 0
	if s.value > s.max or s.value < s.min then
		error("Error in gooi.newSpinner(), value out of range.")
	end
	if s.min > s.max then
		error("Error in gooi.newSpinner(), min value it's greater than max value")
	end
	-- Coords for minus and plus buttons:
	s.step = step or 1
	s.xMin = s.x + s.h / 2
	s.yMin = s.y + s.h / 2
	s.xPlus = s.x + s.w - s.h / 2
	s.yPlus = s.y + s.h / 2
	s.radCirc = s.h * .4
	-- Correct bounds:
	if s.h >= s.w then s.w = s.h * 1.1 end
	function s:drawSpinner(fg)
		love.graphics.setColor(fg)
		love.graphics.circle("fill", self.xMin, self.yMin, self.radCirc, circleRes)
		love.graphics.circle("line", self.xMin, self.yMin, self.radCirc, circleRes)
		love.graphics.circle("fill", self.xPlus, self.yPlus, self.radCirc, circleRes)
		love.graphics.circle("line", self.xPlus, self.yPlus, self.radCirc, circleRes)

		love.graphics.setColor(self:fixColor(self.bgColor[1], self.bgColor[2], self.bgColor[3]))
		if not self.enabled then
			love.graphics.setColor(0, 0, 0)
		end
		love.graphics.setLineWidth(self.h / 8)
		love.graphics.line(self.xMin - self.radCirc / 2, self.y + self.h / 2, self.xMin + self.radCirc / 2, self.y + self.h / 2)
		love.graphics.line(self.xPlus - self.radCirc / 2, self.y + self.h / 2, self.xPlus + self.radCirc / 2, self.y + self.h / 2)
		love.graphics.line(self.xPlus, self.yPlus - self.radCirc / 2, self.xPlus, self.yPlus + self.radCirc / 2)
		local t = tostring(self.value)
		local x = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(t) / 2)
		local y = (self.y + self.h / 2) - (gooi.getFont(self):getHeight() / 2)

		love.graphics.setColor(fg)
		love.graphics.print(t, x, y)
	end
	function s:overMinus(x, y)
		local dx, dy = self.xMin - love.mouse.getX(), self.yMin - love.mouse.getY()
		if x and y then dx, dy = self.xMin - x, self.yMin - y end
		return math.sqrt(math.pow(dx, 2) + math.pow(dy, 2)) < self.radCirc * 1.1
	end
	function s:overPlus(x, y)
		local dx, dy = self.xPlus - love.mouse.getX(), self.yPlus - love.mouse.getY()
		if x and y then dx, dy = self.xPlus - x, self.yPlus - y end
		return math.sqrt(math.pow(dx, 2) + math.pow(dy, 2)) < self.radCirc * 1.1
	end
	function s:changeValue(sense)
		local newV = self.value + self.step * sense
		if newV <= self.max and newV >= self.min then
			self.value = newV
		end
		self.realValue = self.value

		if self.value > self.max then self.value = self.max end
		if self.value < self.min then self.value = self.min end
	end
	function s:update(dt)
		self.timerPreChange = self.timerPreChange + dt
		if self.timerPreChange > .4 then
			self.timerChange = self.timerChange + dt

			self.amountChange = self.amountChange - dt / 30
			if self.amountChange < .02 then self.amountChange = .02 end
			if self.timerChange >= self.amountChange then
				local sense = 1
				if self.minPressed then sense = -1 end
				self:changeValue(sense)
				self.timerChange = 0
			end
		end
	end
	return gooi.storeComponent(s, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Stick creator   -------------------------------
----------------------------------------------------------------------------
function gooi.newJoystick(id, x, y, size, deadZone, group)
	local s = {}
	x, y, size, size = gooi.checkBounds(text, x, y, size, size, "joystick")
	-- Note that the sitck has x and y on the center.
	s = component.new(id, "joystick", x, y, size or 100, size or 100, group)
	s.r = s.w / 2
	s.deadZone = deadZone or 0 -- Given in percentage (0 to 1).
	if s.deadZone < 0  then s.deadZone = 0 end
	if s.deadZone > 1  then s.deadZone = 1 end
	s.stickPressed = false
	s.rStick = s.r / 2-- radius of the Stick.
	s.xStick, s.yStick = s.x + s.r, s.y + s.r
	s.dx, s.dy = 0, 0
	s.spring = true
	function s:drawJoy(fg)
		love.graphics.setColor(fg)
		self:drawStick()
	end

	function s:drawStick()
		love.graphics.circle("fill", self.xStick, self.yStick, self.rStick, circleRes)
		love.graphics.circle("line", self.xStick, self.yStick, self.rStick, circleRes)
	end
	function s:move()
		if (self.pressed or self.touch) and self.stickPressed then
			local daX, daY = love.mouse.getPosition()
			if self:butting() then
				if self.touch then
					daX, daY = self.touch.x, self.touch.y
				end
				local dX, dY = self:theX() - daX - self.dx, self:theY() - daY - self.dy
				local angle = (math.atan2(dY, dX) + math.rad(180));
				self.xStick = self.x + (self.r - self.rStick) * math.cos(angle) + self.r
				self.yStick = self.y + (self.r - self.rStick) * math.sin(angle) + self.r
			else
				--self.xStick, self.yStick = love.mouse.getX() + self.dx, love.mouse.getY() + self.dy
				if self.touch then
					daX, daY = self.touch.x, self.touch.y
				end
				self.xStick, self.yStick = daX + self.dx, daY + self.dy
			end
		end
	end
	function s:restore()
		if self.spring then
			self.xStick, self.yStick = self:theX(), self:theY()
		end
		self.stickPressed = false
		self.dx = 0
		self.dy = 0
	end
	function s:butting()
		local hyp = 0
		local daX, daY = love.mouse.getPosition()
		if self.touch then
			daX, daY = self.touch.x, self.touch.y
		end
		hyp = math.sqrt(
			math.pow(self:theX() - daX - self.dx, 2) +
			math.pow(self:theY() - daY - self.dy, 2))
		return hyp >= self.r - self.rStick
	end
	-- Get numbers with presicion of two decimals:
	function s:xValue()
		if self:onDeadZone() then return 0 end
		return tonumber(string.format("%.2f",(self.xStick - self:theX()) / (self.r - self.rStick)))
	end
	function s:yValue()
		if self:onDeadZone() then return 0 end
		return tonumber(string.format("%.2f",(self.yStick - self:theY()) / (self.r - self.rStick)))
	end
	function s:overStick(x, y)-- x and y are sent in case of a touch.
		dx, dy = self.xStick - love.mouse.getX(), self.yStick - love.mouse.getY()
		if x and y then dx, dy = self.xStick - x, self.yStick - y end
		return math.sqrt(math.pow(dx, 2) + math.pow(dy, 2)) < self.rStick * 1.1
	end
	function s:onDeadZone()
		local dx, dy = self:theX() - self.xStick, self:theY() - self.yStick
		return math.sqrt(math.pow(dx, 2) + math.pow(dy, 2)) <= self.deadZone * (self.r - self.rStick)
	end
	function s:theX() return self.x + self.r end
	function s:theY() return self.y + self.r end

	return gooi.storeComponent(s, id)
end




--**************************************************************************
--**************************************************************************

-- gooi functions:

--**************************************************************************
--**************************************************************************



-- Update what needs to be updated:
function gooi.update(dt)
	for k, c in pairs(gooi.components) do
		if c.type == "text" and c.hasFocus then
			c:updateFlashingCursor(dt)
		end
		if c.enabled and c.visible and (c.pressed or c.touch) then
			if c.type == "slider" then
				local t = c.touch
				if t then
					c:updateValue(t.x)
				else
					c:updateValue(love.mouse.getX())
				end
			elseif c.type == "joystick" then
				c:move()
			elseif c.type == "spinner" then
				c:update(dt)
			end
		end
	end
end

-- Draw the stuff:

function gooi.draw(group)
	local actualGroup = group or "default"

	local compWithToolTip = nil -- Just for desktop.

	for k, comp in pairs(gooi.components) do

		love.graphics.setLineStyle("smooth")
		if actualGroup == comp.group and comp.visible then
			comp:draw()-- Draw the base.

			love.graphics.setFont(comp.font or gooi.getFont())-- Specific or a common font.

			local fg = comp.fgColor
			if not comp.enabled then
				fg = {31, 31, 31}
			end

			------------------------------------------------------------
			------------------------------------------------------------
			------------------------------------------------------------
			--For a label:
			if comp.type == "label" then comp:drawLabel(fg)
			--Draw the stuff for a button:
			elseif comp.type == "button" then comp:drawButton(fg)
			--For a slider:
			elseif comp.type == "slider" then comp:drawSlider(fg)
			-- For a checkbox:
			elseif comp.type == "checkbox" then comp:drawCheckbox(fg)
			-- Radio button:
			elseif comp.type == "radio" then comp:drawRadio(fg)
			-- Text field:
			elseif comp.type == "text" then comp:drawTextField(fg)
			-- Progress bar:
			elseif comp.type == "progressbar" then comp:drawProgressBar(fg)
			-- Spinner:
			elseif comp.type == "spinner" then comp:drawSpinner(fg)
			-- Joystick:
			elseif comp.type == "joystick" then comp:drawJoy(fg)
			end
			------------------------------------------------------------
			------------------------------------------------------------
			------------------------------------------------------------

		end

		if comp.showToolTip then
			compWithToolTip = comp
		end

		-- Restore line and paint:
		love.graphics.setLineWidth(1)
		love.graphics.setColor(255, 255, 255)
	end

	-- Check if a tooltip was generated:

	if compWithToolTip then
		local disp = love.graphics.getWidth() / 100
		local unit = component.toolTipFont:getHeight() / 5
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.setFont(component.toolTipFont)
		local xRect = love.mouse.getX() + disp - unit
		local yRect = love.mouse.getY() - disp * 2 - unit
		local xText = love.mouse.getX() + disp
		local yText = love.mouse.getY() - disp * 2
		local wRect = component.toolTipFont:getWidth(compWithToolTip.toolTip) + unit * 2
		local hRect = component.toolTipFont:getHeight() + unit * 2
		if xRect + wRect > love.graphics.getWidth() then
			xRect = xRect - wRect
			xText = xText - wRect
		end
		if yRect < 0 then
			yRect = yRect + hRect * 2
			yText = yText + hRect * 2
		end
		love.graphics.rectangle("fill", xRect, yRect, wRect, hRect)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(compWithToolTip.toolTip, xText, yText)
	end
end

function gooi.toRGB(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function gooi.setGroupVisible(group, b)
	local group = gooi.getByGroup(group)
	for i=1, #group do
		group[i]:setVisible(b)
	end
end

function gooi.setGroupEnabled(group, b)
	local group = gooi.getByGroup(group)
	for i=1, #group do
		group[i]:setEnabled(b)
	end
end

function gooi.getByType(theType)
	g = {}-- Group.
	for k, c in pairs(gooi.components) do
		if c.type == theType then
			table.insert(g, c)
		end
	end
	return g
end

-- Get any component by its id:
function gooi.get(id)
	return gooi.components[id]
end

function gooi.getByGroup(group)
	g = {}-- Group.
	for k, c in pairs(gooi.components) do
		if c.group == group then
			table.insert(g, c)
		end
	end
	return g
end

function gooi.getByGroupAndType(group, theType)
	g = {}-- Group.
	for k, c in pairs(gooi.components) do
		if c.group == group and c.type == theType then
			table.insert(g, c)
		end
	end
	return g
end

function gooi.deselectOtherRadios(group, id)
	local radios = gooi.getByType("radio")-- Type.
	for i=1, #radios do
		if radios[i].id ~= id and radios[i].radioGroup == group then
			radios[i].selected = false
		end
	end
end

function gooi.setViewportMode(b)
	gooi.viewPortMode = b
end
---------------------------------------------------------------------------------------------
function gooi.pressed(id, x, y)
	if id and x and y then
		x = x * love.graphics.getWidth()
		y = y * love.graphics.getHeight()
	end
	for k, c in pairs(gooi.components) do
		if c.enabled and c.visible then
			if c.type == "joystick" then
				if c:overStick(x, y) then 
					c.stickPressed = true
					c.dx = c.xStick - (x or love.mouse.getX())
					c.dy = c.yStick - (y or love.mouse.getY())
				end
			elseif c.type == "spinner" then
				if c:overMinus(x, y) then
					c:changeValue(-1)
					c.minPressed = true
					c.plusPressed = false
				elseif c:overPlus(x, y) then
					c:changeValue(1)
					c.minPressed = false
					c.plusPressed = true
				end
			end
		end
		if c.enabled and c.visible then
			if c:overIt(x, y) then
				if id and x and y then
					c.touch = {id = id, x = x, y = y}-- Touch used on touchscreens only.
				else
					c.pressed = true-- Pressed just on PC (one pressed at once).
				end
				if c.events.p then
					c.events.p(c)
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------
function gooi.moved(id, x, y)
	local comp = gooi.getCompWithTouch(id)
	if comp and comp.touch then-- Update touch for every component which has it.
		comp.touch.x = x * love.graphics.getWidth()
		comp.touch.y = y * love.graphics.getHeight()
	end
end
---------------------------------------------------------------------------------------------
function gooi.released(id, x, y)
	local c = gooi.getCompWithTouch(id)
	gooi.updateFocus()
	if c then
		if c.type == "joystick" then
			c:restore()
		end
		if c:wasReleased() then
			if c.type == "radio" then
				c:select()
			elseif c.type == "checkbox" then
				c:change()
			elseif c.type == "spinner" then
				if c.minPressed then c.minPressed = false end
				if c.plusPressed then c.plusPressed = false end
				c.timerChange, c.timerPreChange, c.amountChange = 0, 0, .1
			end
			if c.events.r then
				c.events.r(c)-- Release.
			end
		end
		c.pressed = false
		c.touch = nil
	end
end
---------------------------------------------------------------------------------------------
function gooi.getCompWithTouch(id)
	local comp = nil
	for k, c in pairs(gooi.components) do
		if c.touch then
			if c.touch.id == id then
				comp = c
				break
			end
		else
			if c.pressed then comp = c break end
		end
	end
	return comp
end

function gooi.updateFocus()
	local comp = nil
	for k, c in pairs(gooi.components) do
		if c:overIt() and (c.pressed or c.touch) then
			c.hasFocus = true
			comp = c
			break
		end
	end

	for k, c in pairs(gooi.components) do
		if c ~= comp then
			c.hasFocus = false
			if c.type == "text" then
				c.timerCursor = 0
				c.showingCursor = true
			end
		end
	end

	local tf = gooi.getByType("text")
	local b = false
	for i = 1, #tf do
		if tf[i].hasFocus then b = true end
	end
	if not b then love.keyboard.setTextInput(false) end
end

function gooi.changeFont(font)-- Update font of every component:
	for k, c in pairs(gooi.components) do
		c.font = font
	end
end

function gooi.keypressed(key)
	local fields = gooi.getByType("text")
	for i = 1, #fields do
		local f = fields[i]
		if f.hasFocus then
			if key == "left" or key == "right" or key == "backspace" then
				f:moveCursor(key)
			end
		end
	end
end

function gooi.textinput(key, code)
	local fields = gooi.getByType("text")
	for i = 1, #fields do
		local f = fields[i]
		if f.hasFocus then
			if key == "left" or key == "right" then
				f:moveCursor(key)
			else
				gooi.checkAndSetCode(f, key, code)
			end
		end
	end
end

function gooi.checkAndSetCode(f, key, code)
	local theText = nil
	if code then
		if pcall(string.char, code) and code > 0 then
			theText = gooi.get(f.id).text..(string.char(code))
		end
    else
    	if string.byte(key) >= 32 then-- Printable chars:
    		local s = ''
    		local c = gooi.get(f.id)
    		-- Trick for the accentuation on vowels:
    		if key == '´' then
    			if c.accentuationComing then
    				s = key
    				c.accentuationComing = false
    			else
    				c.accentuationComing = true
    			end
    		else
    			if c.accentuationComing then
    				if key == 'a' then s = 'á' end
    				if key == 'e' then s = 'é' end
    				if key == 'i' then s = 'í' end
    				if key == 'o' then s = 'ó' end
    				if key == 'u' then s = 'ú' end

    				if key == 'A' then s = 'Á' end
    				if key == 'E' then s = 'É' end
    				if key == 'I' then s = 'Í' end
    				if key == 'O' then s = 'Ó' end
    				if key == 'U' then s = 'Ú' end
    				c.accentuationComing = false
    			else
    				s = key
	    		end
    		end
	    	theText = c.text..s
	    end
    end
	if gooi.getFont(self):getWidth(theText or f.text) <= f.w - f.h * 1.1 then
    	f.text = theText or f.text
    	f:moveCursor()
	end
end

-- Get the focused component (for non touchscreens):
function gooi.getFocused()
	local comp = nil
	for k, c in pairs(gooi.components) do
		if c.hasFocus then
			comp = c
		end
	end
	return comp
end

function gooi.checkBounds(text, x, y, w, h, t)
	local newX, newY, newW, newH = x, y, w, h
	if not (w and h) then
			newW = gooi.getFont(self):getWidth(text) + gooi.getFont(self):getHeight()
			newH = gooi.getFont(self):getHeight() * 2
			if t == "checkbox" or t == "text" then
				newW = newW + newH
			end
			if t == "spinner" then
				newW = newW + newH * 2
			end
		if not (x and y) then
			newX, newY = 10, 10
		end
	end
	if gooi.viewPortMode then
		if newX > 1 then newX = 1 end   if newX < 0 then newX = 0 end
		if newY > 1 then newY = 1 end   if newY < 0 then newY = 0 end
		if newW > 1 then newW = 1 end   if newW < 0 then newW = 0 end
		if newH > 1 then newH = 1 end   if newH < 0 then newH = 0 end

		newX = newX * love.graphics.getWidth()
		newY = newY * love.graphics.getHeight()
		newW = newW * love.graphics.getWidth()
		newH = newH * love.graphics.getHeight()
	end
	return newX, newY, newW, newH
end

function gooi.getFont(comp)
	if comp and comp.font then
		return comp.font
	end
	return gooi.font or love.graphics.getFont()
end