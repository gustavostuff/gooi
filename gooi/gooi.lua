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
gooi.font = love.graphics.newFont(love.graphics.getWidth() / 80)
gooi.components = {}

local circleRes = 50

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Label creator  --------------------------------
----------------------------------------------------------------------------
function gooi.newLabel(id, text, x, y, w, h, image, orientation,  group)
	local l = {}
	x, y, w, h = gooi.checkBounds(text, x, y, w, h, "label")
	l = component.new(id, "label", x, y, w, h, group)
	l.opaque = false
	l.text = text
	l.image = image
	l.orientation = orientation
	if l.image then
		if type(image) == "string" then
			l.image = love.graphics.newImage(image)
		end
		if l.text:len() > 0 then
			l.w = l.w + l.image:getWidth()
		end
	end
	function l:rebuild()
		--self:generateBorder()
	end
	l:rebuild()
	function l:drawSpecifics(fg)
		local t = self.text or ""
		-- Right by default:
		local x = self.x + self.w - gooi.getFont(self):getWidth(t)
		local y = (self.y + self.h / 2) - (gooi.getFont(self):getHeight() / 2)
		if self.orientation == "left" then
			x = self.x
			if self.image then
				x = x + self.image:getWidth() + self.h / 4
			end
		elseif self.orientation == "center" then
			x = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(t) / 2)
		end
		if self.image then
			local xImg = math.floor(self.x + self.h / 2)
			love.graphics.setColor(255, 255, 255)
			if not self.enabled then love.graphics.setColor(63, 63, 63) end

			if t:len() == 0 then
				xImg = math.floor(self.x + self.w / 2)
			end
			love.graphics.draw(self.image, xImg, math.floor(self.y + self.h / 2), 0, 1, 1,
				self.image:getWidth() / 2, self.image:getHeight() / 2)
		end
		love.graphics.setColor(fg)
		love.graphics.print(self.text, math.floor(x), math.floor(y))
	end
	function l:setOrientation(o)
		if o == "left" then
			self.orientation = o
		elseif o == "right" then
			self.orientation = o
		elseif o == "center" then
			self.orientation = o
		else
			error("orientation '"..o.."' not valid")
		end
		return self
	end
	l:setOrientation("right")
	function l:setImage(image)
		if type(image) == "string" then
			image = love.graphics.newImage(image)
		end
		self.image = image
		self.w = self.w + self.image:getWidth()
		return self
		-- body
	end
	return gooi.storeComponent(l, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Button creator  -------------------------------
----------------------------------------------------------------------------
function gooi.newButton(id, text, x, y, w, h, image, group)
	local b = {}
	x, y, w, h = gooi.checkBounds(text or "", x, y, w, h, "button")
	b = component.new(id, "button", x, y, w, h, group)
	b.text = text or "" --todo
	b.image = image
	if b.image then
		if type(image) == "string" then
			b.image = love.graphics.newImage(image)
		end
		if b.text:len() > 0 then
			b.w = b.w + b.image:getWidth()
		end
	end
	b.pressedMove = 0
	function b:rebuild()
		--self:generateBorder()
	end
	b:rebuild()
	function b:drawSpecifics(fg)
		self.pressedMove = 0
		if self.pressed or self.touch then
			self.pressedMove = 2
		end
		-- Center text:
		local t = self.text
		local x = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(t) / 2)
		local y = (self.y + self.h / 2) - (gooi.getFont(self):getHeight() / 2)
		if self.orientation == "left" then
			x = self.x + self.h / 2
			if self.image then
				x = self.x + self.h / 2 + self.image:getWidth() / 2 + self.h / 4
			end
		elseif self.orientation == "right" then
			x = self.x + self.w - self.h / 2 - gooi.getFont(self):getWidth(self.text)
		end
		if self.image then
			local xImg = math.floor(self.x + self.h / 2)
			if t:len() == 0 then
				xImg = math.floor(self.x + self.w / 2)
			end
			love.graphics.setColor(255, 255, 255)
			if not self.enabled then love.graphics.setColor(63, 63, 63) end
			love.graphics.draw(self.image,
				xImg,
				math.floor(self.y + self.h / 2) + self.pressedMove, 0, 1, 1,
				self.image:getWidth() / 2, self.image:getHeight() / 2)
		end
		love.graphics.setColor(fg)
		love.graphics.print(t, math.floor(x), math.floor(y + self.pressedMove))
	end
	function b:setOrientation(o)
		if o == "left" then
			self.orientation = o
		elseif o == "right" then
			self.orientation = o
		elseif o == "center" then
			self.orientation = o
		else
			error("orientation '"..o.."' not valid")
		end
		return self
	end
	b:setOrientation("center")
	function b:setImage(image)
		if type(image) == "string" then
			image = love.graphics.newImage(image)
		end
		self.image = image
		self.w = self.w + self.image:getWidth() * 2
		return self
		-- body
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
	--if s.h >= s.w then s.w = s.h * 1.1 end

	s.displacement = (s.w - s.h) * s.value
	function s:drawSpecifics(fg)
		love.graphics.setLineStyle("smooth")
		local mC = math.floor(self.h / 8) -- Margin corner.
		local rad = self.h * .4 -- Normal radius for the white circles.
		local side = math.floor(self.h - mC * 2)
		love.graphics.setColor(fg)
		if self.pressed or self.touch then rad = rad * .5 end
		love.graphics.rectangle("fill",
			math.floor(self.x + mC + self.displacement),
			math.floor(self.y + mC),
			math.floor(side),
			math.floor(side),
			self.howRoundInternally * side / 2,
			self.howRoundInternally * side / 2,
			circleRes)
		local x1Line = self.x + self.h / 2
		local x2Line = self.x + self.h / 2 + (self.w - self.h) * self.value - side / 2
		if x2Line > x1Line then
			love.graphics.line(
				x1Line,
				self.y + self.h / 2 - 1,
				x2Line,
				self.y + self.h / 2 - 1)
		end
		love.graphics.setLineStyle("rough")
	end
	function s:updateValue(theX)
		self.displacement = (theX - (self.x + self.h / 2))
		if self.displacement > (self.w - self.h) then self.displacement = self.w - self.h end
		if self.displacement < 0 then self.displacement = 0 end
		self.value = self.displacement / (self.w - self.h)
	end
	function s:setValue(v)
		local newValue = self.w / 2
		if v then
			newValue = v * self.w
		end
		self:updateValue((self.x + newValue))
		return self
	end
	function s:rebuild()
		--self:generateBorder()
		self:setValue(0.5)
	end
	s:rebuild()
	return gooi.storeComponent(s, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Checkbox creator  -----------------------------
----------------------------------------------------------------------------
function gooi.newCheck(id, text, x, y, w, h, checked, group)
	local chb = {}
	x, y, w, h = gooi.checkBounds(text, x, y, w, h, "checkbox")
	chb = component.new(id, "checkbox", x, y, w, h, group)
	chb.checked = checked or false
	chb.text = text
	function chb:rebuild()
		--self:generateBorder()
	end
	chb:rebuild()
	function chb:drawSpecifics(fg)
		local rad = .4 -- Normal radius for the white circles.
		local mC = math.floor(self.h / 8) -- Margin corner.
		local side = math.floor(self.h - mC * 2)
		love.graphics.setColor(fg)
		local recWhite = {
			math.floor(self.x + mC),
			math.floor(self.y + mC),
			math.floor(side),
			math.floor(side),
		}
		love.graphics.rectangle("fill",
				recWhite[1],
				recWhite[2],
				recWhite[3],
				recWhite[4],
				self.howRoundInternally * side / 2,
				self.howRoundInternally * side / 2,
				circleRes)
		local fill = "line"
		love.graphics.setColor(fg)
		local marginRecWhite = math.floor(recWhite[3] / 6)
		if not self.checked then
			fill = "fill"
			love.graphics.setColor(0, 0, 0)
			love.graphics.rectangle("fill",
				recWhite[1] + marginRecWhite,
				recWhite[2] + marginRecWhite,
				recWhite[3] - marginRecWhite * 2,
				recWhite[4] - marginRecWhite * 2,
				self.howRoundInternally * side * .7 / 2,
				self.howRoundInternally * side * .7 / 2,
				circleRes)
		end
		-- text of the checkbox:
		love.graphics.setColor(fg)
		love.graphics.print(self.text, 
			math.floor(self.x + self.h * 1.1),
			math.floor(self.y + self.h / 2 - gooi.getFont(self):getHeight() / 2))
	end
	function chb:change()
		self.checked = not self.checked
		return self
	end
	return gooi.storeComponent(chb, id)
end




----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Radio button creator   ------------------------
----------------------------------------------------------------------------
function gooi.newRadio(id, text, x, y, w, h, selected, radioGroup, group)
	local r = {}
	x, y, w, h = gooi.checkBounds(text, x, y, w, h, "radio")
	r = component.new(id, "radio", x, y, w, h, group)
	r.selected = selected or false
	r.text = text
	r.radioGroup = radioGroup or "default"
	function r:rebuild()
		--self:generateBorder()
	end
	r:rebuild()
	function r:drawSpecifics(fg)
		local rad = .4 -- Normal radius for the white circles.
		local mC = math.floor(self.h / 8) -- Margin corner.
		local side = math.floor(self.h - mC * 2)
		love.graphics.setColor(0, 0, 0)
		local recBlack = {
			math.floor(self.x + mC),
			math.floor(self.y + mC),
			math.floor(side),
			math.floor(side),
		}
		love.graphics.rectangle("fill",
			recBlack[1],
			recBlack[2],
			recBlack[3],
			recBlack[4],
			self.howRoundInternally * side / 2,
			self.howRoundInternally * side / 2,
			circleRes)
		love.graphics.setColor(fg)
		local marginRecBlack = math.floor(recBlack[3] / 4)
		if self.selected then
			love.graphics.rectangle("fill",
			recBlack[1] + marginRecBlack,
			recBlack[2] + marginRecBlack,
			recBlack[3] - marginRecBlack * 2,
			recBlack[4] - marginRecBlack * 2,
			self.howRoundInternally * side / 2,
			self.howRoundInternally * side / 2,
			circleRes)
		end
		love.graphics.print(self.text,
			math.floor(self.x + self.h * 1.1),
			math.floor(self.y + self.h / 2 - gooi.getFont(self):getHeight() / 2))
	end
	function r:setRadioGroup(g)
		self.radioGroup = g
		return self
	end
	function r:select()
		self.selected = true
		gooi.deselectOtherRadios(self.radioGroup, self.id)
		return self
	end
	return gooi.storeComponent(r, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Textfield creator   ---------------------------
----------------------------------------------------------------------------
function gooi.newText(id, text, x, y, w, h, group)
	local f = {}
	x, y, w, h = gooi.checkBounds(text, x, y, w, h, "text")
	f = component.new(id, "text", x, y, w, h, group)
	f.text = text or ""
	f.timerCursor = 0
	f.delayCursor = 0.5
	f.showingCursor = true
	f.accentuationComing = false -- Support for typing á, é, í, ó, ú and Á, É, Í, Ó, Ú (on PC).
	f.indexCursor = string.utf8len(f.text)
	function f:rebuild()
		self.displacementCursor = self.x + self.h / 2 * 1.1 + gooi.getFont(self):getWidth(self.text)
		--self:generateBorder()
	end
	f:rebuild()
	
	function f:drawSpecifics(fg)
		local rad = .4 -- Normal radius for the white circles.
		love.graphics.setColor(0, 0, 0)
		local marginRecBlack = math.floor(self.h / 6)
		love.graphics.rectangle("fill",
			math.floor(self.x) + marginRecBlack,
			math.floor(self.y) + marginRecBlack,
			math.floor(self.w - marginRecBlack * 2),
			math.floor(self.h) - marginRecBlack * 2,
			self.howRoundInternally * self.h / 2,
			self.howRoundInternally * self.h / 2,
			circleRes)
		love.graphics.setColor(fg)
		if self.hasFocus then
			self:drawCursor()
		end
		self:drawChars()
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

	function f:drawChars()
		love.graphics.print(self.text,
			math.floor(self.x + self.h / 2 * 1.1),
			math.floor(self.y + self.h / 2 - gooi.getFont(self):getHeight() / 2))
	end

	return gooi.storeComponent(f, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Progress bar creator   ------------------------
----------------------------------------------------------------------------
function gooi.newBar(id, x, y, w, h, value, color1, color2, group)
	local p = {}
	x, y, w, h = gooi.checkBounds("12345678", x, y, w, h, "progressbar")
	p = component.new(id, "progressbar", x, y, w, h, group)
	p.value = value or 0
	if p.value > 1 then p.value = 1 end
	if p.value < 0 then p.value = 0 end
	function p:rebuild()
		--self:generateBorder()
	end
	p:rebuild()
	function p:drawSpecifics(fg)
		love.graphics.setColor(0, 0, 0)
		local marginBars = math.floor(self.h / 6)
		love.graphics.rectangle("fill",
			math.floor(self.x + marginBars),
			math.floor(self.y) + marginBars,
			math.floor(self.w - marginBars * 2), 
			math.floor(self.h) - marginBars * 2,
			self.howRoundInternally * self.h / 2,
			self.howRoundInternally * self.h / 2,
			circleRes)
		love.graphics.setColor(self.fgColor)
		if not self.enabled then
			love.graphics.setColor(63, 63, 63)
		end
		love.graphics.rectangle("fill",
			math.floor(self.x + marginBars),
			math.floor(self.y) + marginBars,
			math.floor(self.value * (self.w - marginBars * 2)),
			math.floor(self.h) - marginBars * 2,
			self.howRoundInternally * self.h / 2,
			self.howRoundInternally * self.h / 2,
			circleRes)
	end
	function p:changeValue(amount, dt, sense)
		if amount > 1 then amount = 1 end
		if amount < 0 then amount = 0 end
		local delta = 1
		if dt then delta = dt end
		self.value = self.value + amount * delta * sense
		if self.value > 1 then self.value = 1 end
		if self.value < 0 then self.value = 0 end
		return self
	end
	function p:increase(amount, dt)
		self:changeValue(amount, dt, 1)
		return self
	end
	function p:setLength(l)
		self.w = l
		return self
	end
	function p:decrease(amount, dt)
		self:changeValue(amount, dt, -1)
		return self
	end
	return gooi.storeComponent(p, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Spinner creator   -----------------------------
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
	function s:rebuild()
		-- Coords for minus and plus buttons:
		self.step = step or 1
		self.xMin = self.x + self.h / 2
		self.yMin = self.y + self.h / 2
		self.xPlus = self.x + self.w - self.h / 2
		self.yPlus = self.y + self.h / 2
		self.radCirc = self.h * .4
		-- Correct bounds:
		if self.h >= self.w then self.w = self.h * 1.1 end
	end
	s:rebuild()
	function s:drawSpecifics(fg)
		love.graphics.setColor(fg)
		local btnGap = math.floor(self.h / 6)
		local btnSize = btnGap * 4

		-- Minus button:
		love.graphics.rectangle("fill",
			math.floor(self.x) + btnGap,
			math.floor(self.y) + btnGap,
			btnSize, btnSize,
			self.howRoundInternally * self.h / 2,
			self.howRoundInternally * self.h / 2,
			circleRes)
		-- PLus button:
		love.graphics.rectangle("fill",
			math.floor(self.x) + math.floor(self.w) - btnGap - btnSize,
			math.floor(self.y) + btnGap,
			btnSize, btnSize,
			self.howRoundInternally * self.h / 2,
			self.howRoundInternally * self.h / 2,
			circleRes)

		love.graphics.setColor(self:fixColor(self.bgColor[1], self.bgColor[2], self.bgColor[3]))
		if not self.enabled then
			love.graphics.setColor(0, 0, 0)
		end
		local t = tostring(self.value)
		local x = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(t) / 2)
		local y = (self.y + self.h / 2) - (gooi.getFont(self):getHeight() / 2)

		love.graphics.setColor(fg)
		love.graphics.print(t, math.floor(x), math.floor(y))
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
		return self
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
function gooi.newJoy(id, x, y, size, deadZone, group)
	local s = {}
	local _ = "xxxx"
	x, y, size, size = gooi.checkBounds(_.._.._, x, y, size, size, "joystick")
	-- Note that the sitck has x and y on the center.
	s = component.new(id, "joystick", x, y, size or 100, size or 100, group)
	s.radiusCorner = s.h / 2
	s.deadZone = deadZone or 0 -- Given in percentage (0 to 1).
	if s.deadZone < 0  then s.deadZone = 0 end
	if s.deadZone > 1  then s.deadZone = 1 end
	s.stickPressed = false
	s.dx, s.dy = 0, 0
	s.spring = true
	function s:drawSpecifics(fg)
		love.graphics.setColor(fg)
		self:drawStick()
	end
	function s:rebuild()
		self.r = self.smallerSide / 2
		self.rStick = self.r / 2-- radius of the Stick.
		self.xStick = math.floor(self.x) + math.floor(self.r)
		self.yStick = math.floor(self.y) + math.floor(self.r)
		--self:generateBorder()
	end
	s:rebuild()
	function s:drawStick()
		love.graphics.circle("fill",
			math.floor(self.xStick),
			math.floor(self.yStick),
			math.floor(self.rStick),
			circleRes)
	end
	function s:move(direction)
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
	-- TODO this is a temporal fix for the joystick "moving" by itself when setting a style:
	function s:theX() return math.ceil(self.x) + math.floor(self.r) end
	function s:theY() return math.ceil(self.y) + math.floor(self.r) end

	return gooi.storeComponent(s, id)
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Knob creator   -------------------------------
----------------------------------------------------------------------------

function gooi.newKnob(id, x, y, w, h, group)
	local k = {}
	x, y, w, h = gooi.checkBounds("aNiceKnob", x, y, w, h, "knob")
	k = component.new(id, "knob", x, y, w, h, group)
	k.radKnob = math.floor(k.h * .4)
	k.xKnob = math.floor(k.x + k.w / 2)
	k.yKnob = math.floor(k.y + k.h / 2)
	k.pivotY = k.yKnob
	k.pivotValue = 0.5
	k.changedValue = 0.5
	k.value = k.pivotValue

	k.initialAngle = 0
	k.finalAngle = 180

	function k:setValue(v)
		if v > 1 then v = 1 end
		if v < 0 then v = 0 end

		k.pivotValue = v
		k.changedValue = v
		k.value = v
	end

	function k:drawSpecifics(fg)
		love.graphics.setColor(fg)
		if not self.enabled then
			love.graphics.setColor(63, 63, 63)
		end

		love.graphics.arc("fill",
			self.xKnob,
			self.yKnob,
			self.radKnob,
			math.rad(180 + self.initialAngle),
			math.rad(180 + self.finalAngle * 2 * self.value),
			circleRes
			)

		love.graphics.setColor(self.bgColor[1], self.bgColor[2], self.bgColor[3])
		if not self.enabled then
			love.graphics.setColor(63, 63, 63)
		end
		love.graphics.circle("fill",
			self.xKnob,
			self.yKnob,
			self.radKnob / 2,
			circleRes)
	end

	function k:insideKnob()
		local x = love.mouse.getX()
		local y = love.mouse.getY()
		
		if self.touch then
			x = self.touch.x
			y = self.touch.y
		end

		local dx = math.abs(x - self.xKnob)
		local dy = math.abs(y - self.yKnob)
		local hyp = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))
		local rad = self.radKnob

		return hyp < rad
	end

	function k:turn()
		local y = love.mouse.getY()
		
		if self.touch then
			y = self.touch.y
		end

		local dy = self.pivotY - y

		self.changedValue = self.pivotValue + dy / self.h / 3

		if self.changedValue > 1 then self.changedValue = 1 end
		if self.changedValue < 0 then self.changedValue = 0 end

		self.value = self.changedValue
	end

	function k:rebuild()
		self.radKnob = math.floor(self.h * .4)
		self.xKnob = math.floor(self.x + self.w / 2)
		self.yKnob = math.floor(self.y + self.h / 2)
	end
	k:rebuild()

	return gooi.storeComponent(k, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Panel creator   -------------------------------
----------------------------------------------------------------------------
function gooi.newPanel(id, x, y, w, h, theLayout, group)
	local p = {}
	x, y, w, h = gooi.checkBounds("aPanel", x, y, w, h, "panel")
	p = component.new(id, "panel", x, y, w, h, group)
	p.opaque = false
	p.x = x
	p.y = y
	p.w = w
	p.h = h
	p.childs = {}
	function p:setLayout(l)
		if l then
			if l:sub(0, 4) == "grid" then
				p.layout = layout.new(l)
				p.layout:init(p)
			elseif l:sub(0, 4) == "game" then
				p.layout = layout.new(l)
			else
				error("Layout definition must be 'grid NxM', 'game' or 'absolute'")
			end
			--print(unpack(split(theLayout, " ")))
		else
			p.layout = layout.new("grid 1x3")
			p.layout:init(p)
		end
		return self
	end
	p:setLayout(theLayout)
	function p:drawSpecifics(fg)
		--[[
		love.graphics.rectangle("line", self.x, self.y, self.w, self.h)]]
		if self.layout.kind == "grid" then
			love.graphics.setLineWidth(1)
			love.graphics.setColor(0, 0, 0, 127)
			self.layout:drawCells()
		end
		--[[
		love.graphics.setColor(0, 0, 0, 127)
		love.graphics.setLineWidth(1)
		love.graphics.setLineStyle("rough")
		love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
		]]
	end
	function p:rebuild()
		if self.layout.kind == "grid" then
			self.layout:init(self)
		end
	end
	p:rebuild()
	function p:add(...)
		local params = {...}
		if self.layout.kind == "grid" then
			if type(params[2]) == "string" then
				local row = split(params[2], ",")[1]
				local col = split(params[2], ",")[2]
				local cell = self.layout:getCell(tonumber(row), tonumber(col))

				if not cell then
					error("Row "..row.." and Col "..col.." not defined")
				end

				local c = params[1]
				-- Set bounds according to the parent layout:
				c:setBounds(cell.x, cell.y, cell.w, cell.h)

				-- Save child:
				table.insert(self.childs,
				{
					id = c.id,
					parentId = self.id,
					cellRow = cell.row,
					cellCol = cell.col
				})

				-- Joysticks are always a square or cirle:
				if c.type == "joystick" then
					c.w = c.smallerSide
					c.h = c.smallerSide
				end

				if c.rebuild then c:rebuild() end

				-- Set bounds to the childs:
				if c.childs then
					for n = 1, #c.childs do
						local ch = c.childs[n]
						--print("child id: "..ch.id)
						local comp = gooi.get(ch.id)
						local cell = c.layout:getCell(ch.cellRow, ch.cellCol)
						comp:setBounds(cell.x, cell.y, cell.w, cell.h)
						if comp.rebuild then comp:rebuild() end
					end
				end
			else
				for i = 1, #params do
					local c = params[i]
					local cell = self.layout:nextCell(c)

					if not cell then
						error("Insufficient cells in grid layout for, component id: "..c.id)
					end
					
					-- Set bounds according to the parent layout:
					c:setBounds(cell.x, cell.y, cell.w, cell.h)

					-- Save child:
					table.insert(self.childs,
					{
						id = c.id,
						parentId = self.id,
						cellRow = cell.row,
						cellCol = cell.col
					})

					-- Joysticks are always a square or cirle:
					if c.type == "joystick" then
						c.w = c.smallerSide
						c.h = c.smallerSide
					end

					if c.rebuild then c:rebuild() end

					-- Set bounds to the childs:
					if c.childs then
						for n = 1, #c.childs do
							local ch = c.childs[n]
							--print("child id: "..ch.id)
							local comp = gooi.get(ch.id)
							local cell = c.layout:getCell(ch.cellRow, ch.cellCol)
							comp:setBounds(cell.x, cell.y, cell.w, cell.h)
							if comp.rebuild then comp:rebuild() end
						end
					end
				end
			end
		elseif self.layout.kind == "game" then
			local ref = params[1]
			local position = params[2]
			if not(
				position == "t-l" or
				position == "t-r" or
				position == "b-l" or
				position == "b-r")
			then
				error("valid positions are: 't-l', 't-r', 'b-l' and 'b-r'")
			end
			self.layout:suit(self, ref, position)
			if ref.rebuild then ref:rebuild() end
		end
		return self
	end
	function p:changePadding(padding)
		-- body
	end
	function p:changeSpan(spanType, row, col, size)
		local l = self.layout
		if l.kind ~= "grid" then
			error("Panel "..self.id.." has not a grid layout")
		else
			local point, limit
			if spanType == "rowspan" then point, limit = row, l.gridRows end
			if spanType == "colspan" then point, limit = col, l.gridCols end
			-- Check for a valid size:
			if (point + size - 1) > limit then
				error("Invalid rowspan size, max allowed for this row index: "..(limit - point))
			else
				local cell = l:getCell(row, col)
				-- Resize cell according to the new span:
				if spanType == "rowspan"  then
					cell.h = cell.h * size + (cell.padding * 2 * (size - 1))
					cell.rowspan = size
				end
				if spanType == "colspan"  then
					cell.w = cell.w * size + (cell.padding * 2 * (size - 1))
					cell.colspan = size
				end
				-- Turn 'off' the cells which are in the way of the rowspan:
				l:offCellsInTheWay(spanType, row, col, size)
			end
			return self
		end
	end
	function p:setRowspan(row, col, size)
		return self:changeSpan("rowspan", row, col, size)
	end
	function p:setColspan(row, col, size)
		return self:changeSpan("colspan", row, col, size)
	end

	return gooi.storeComponent(p, id)
end







--**************************************************************************
--**************************************************************************

-- gooi functions:

--**************************************************************************
--**************************************************************************





function gooi.storeComponent(c, id)
	if gooi.components[id] ~= nil then
		error("Component '"..id.."' already defined!")
	else
		gooi.components[id] = c
		return c
	end
end


function gooi.removeComponent(id)
	if gooi.components[id] ~= nil then
		local c = gooi.components[id]
		if c.childs then
			for n = 1, #c.childs do
				local ch = c.childs[n]
				gooi.removeComponent(ch.id)
			end          
		end          
		gooi.components[id] = nil
	end
end


function gooi.setStyle(style)
	if style.bgColor and type(style.bgColor) == "string" then
		style.bgColor = gooi.toRGB(style.bgColor)
	end
	if style.fgColor and type(style.fgColor) == "string" then
		style.fgColor = gooi.toRGB(style.fgColor)
	end
	if style.borderColor and type(style.borderColor) == "string" then
		style.borderColor = gooi.toRGB(style.borderColor)
	end
	component.style.bgColor = style.bgColor or {12, 183, 242, 127}
	component.style.fgColor = style.fgColor or {255, 255, 255, 255}
	component.style.tooltipFont = style.tooltipFont or love.graphics.newFont(love.graphics.getWidth() / 85)
	component.style.howRound = style.howRound or .25
	component.style.howRoundInternally = style.howRoundInternally or .25
	component.style.showBorder = style.showBorder
	component.style.borderColor = style.borderColor or {12, 183, 242}
	component.style.borderWidth = style.borderWidth or 2
	component.style.font = style.font or love.graphics.newFont(love.graphics.getWidth() / 80)
	gooi.font = style.font or love.graphics.newFont(love.graphics.getWidth() / 80)
end


-- Update what needs to be updated:
local timerBackspaceText = 0
local timerStepChar = 0
function gooi.update(dt)
	for k, c in pairs(gooi.components) do
		if c.type == "text" and c.hasFocus then
			c:updateFlashingCursor(dt)
			if love.keyboard.isDown("backspace") then
				timerBackspaceText = timerBackspaceText + dt
				if timerBackspaceText >= 0.5 then
					timerStepChar = timerStepChar + dt
					if timerStepChar >= 0.025 then
						timerStepChar = 0
						c:moveCursor("backspace")
					end
				end
			else
				timerStepChar = 0
				timerBackspaceText = 0
			end
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
			elseif c.type == "knob" then
				c:turn()
			end
		end
	end
end

-- Draw the stuff:

function gooi.draw(group)
	local actualGroup = group or "default"

	local prevFont  = love.graphics.getFont()
	local lineW = love.graphics.getLineWidth()

	local compWithTooltip = nil -- Just for desktop.

	for k, comp in pairs(gooi.components) do
	--for i = 1, #gooi.components do
		--local comp = gooi.components[i]

		love.graphics.setLineStyle("rough")
		local lineW = comp.smallerSide / 10
		if lineW < 1 then lineW = 1 end
		love.graphics.setLineWidth(lineW)
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


			comp:drawSpecifics(fg)


			------------------------------------------------------------
			------------------------------------------------------------
			------------------------------------------------------------

		end

		if comp.showTooltip then
			compWithTooltip = comp
		end

		-- Restore line and paint:
		love.graphics.setLineWidth(1)
		love.graphics.setColor(255, 255, 255)
	end

	-- Check if a tooltip was generated, just for desktop:

	if compWithTooltip and not love.touch then
		local disp = love.graphics.getWidth() / 100
		local unit = compWithTooltip.tooltipFont:getHeight() / 5
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.setFont(compWithTooltip.tooltipFont)
		local xRect = love.mouse.getX() + disp - unit
		local yRect = love.mouse.getY() - disp * 2 - unit
		local xText = love.mouse.getX() + disp
		local yText = love.mouse.getY() - disp * 2
		local wRect = compWithTooltip.tooltipFont:getWidth(compWithTooltip.tooltip) + unit * 2
		local hRect = compWithTooltip.tooltipFont:getHeight() + unit * 2
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
		love.graphics.print(compWithTooltip.tooltip, math.floor(xText), math.floor(yText))
	end

	love.graphics.setFont(prevFont)
	love.graphics.setLineStyle("smooth")
end

function gooi.toRGB(hex)
    hex = hex:gsub("#","")
    return {tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))}
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
	if not gooi.components[id] then
		error("Component '"..id.."' does not exist!")
	end
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

---------------------------------------------------------------------------------------------
function gooi.pressed(id, x, y)
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
			elseif c.type == "knob" then
				c.pivotY = (y or love.mouse.getY())
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
					c.events.p(c)-- onPress event.
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------
function gooi.moved(id, x, y)
	local comp = gooi.getCompWithTouch(id)
	if comp and comp.touch then-- Update touch for every component which has it.
		comp.touch.x = x
		comp.touch.y = y
		if comp.events.m then
			comp.events.m(comp)-- Moven event.
		end
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
		if c.type == "knob" then
			c.pivotY = c.yKnob
			c.pivotValue = c.changedValue
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
				c.events.r(c)-- onRelease event.
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
			break
		end
	end
	return comp
end

function gooi.checkBounds(text, x, y, w, h, t)
	local newX, newY, newW, newH = x, y, w, h
	if not (w and h) then
		newW = gooi.getFont(self):getWidth(text) + gooi.getFont(self):getHeight()
		newH = gooi.getFont(self):getHeight() * 2
		if t == "checkbox" or t == "text" or t == "radio" then
			newW = newW + newH
		end
		if t == "spinner" then
			newW = newW + newH * 2
		end
		if not (x and y) then
			newX, newY = 10, 10
			if t == "panel" then-- Panel are screen-sized if bounds are not given:
				--newX, newY, newW, newH = 0, 0, love.graphics.getWidth(), love.graphics.getHeight()
			end
		end
	end
	return newX, newY, newW, newH
end

function gooi.getFont(comp)
	if comp and comp.font then
		return comp.font
	end
	return gooi.font or love.graphics.getFont()
end


-----------------------

function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end