gooi = {}
gooi.__index = gooi
gooi.components = {}
gooi.dialogFOK = function() end
gooi.showingDialog = false
gooi.dialogMsg = ""
gooi.dialogH = 0
gooi.dialogW = 0
gooi.desktop = false
gooi.canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
gooi.sx = 1
gooi.sy = 1
gooi.defaultFont = love.graphics.newFont(love.window.toPixels(13))
gooi.font = defaultFont
gooi.unit = love.window.toPixels(25)
gooi.bs = "backspace"
gooi.del = "delete"
gooi.r = "right"
gooi.l = "left"
gooi.delayKey = 0.05
gooi.delayCursorBlink = 0.4
gooi.delayCanRepeat = 0.45

function gooi.desktopMode()
    gooi.desktop = true
end

gooi.smallerSide = function()
    local smallerSide = love.graphics.getWidth()

    if love.graphics.getHeight() < smallerSide then
        smallerSide = love.graphics.getHeight()
    end
    return smallerSide
end

local circleRes = 50

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Label creator  --------------------------------
----------------------------------------------------------------------------
--function gooi.newLabel(text, x, y, w, h)
function gooi.newLabel(params)
    params = params or {}
    local l = {}
    defaultText = "new label"

    x, y, w, h = gooi.checkBounds(
        params.text or defaultText,
        params.x or 10,
        params.y or 10,
        params.w or gooi.getFont():getWidth(params.text or defaultText),
        params.h or gooi.getFont():getHeight() * 2,
        "label"
    )

    l = component.new("label", x, y, w, h, params.group)
    l = gooi.setStyleComp(l)
    l.opaque = false
    l.text = params.text or defaultText
    l.icon = params.icon
    if l.icon then
        if type(l.icon) == "string" then
            l.icon = love.graphics.newImage(l.icon)
        end
        if l.text:len() > 0 then
            l.w = l.w + l.icon:getWidth()
        end
    end
    l.textParts = split(l.text, "\n")
    function l:rebuild()
        --self:generateBorder()
    end
    l:rebuild()
    function l:setText(value)
        if not value then value = "" end
        self.text = tostring(value)
        self.textParts = split(self.text, "\n")
        return self
    end
    function l:largerLine()
        local line = self.textParts[1] or ""

        for i = 2, #self.textParts do
            if #self.textParts[i] > #line then
                line = self.textParts[i]
            end
        end

        return line
    end
    function l:drawSpecifics(fg)
        local t = self:largerLine() or ""
        -- Right by default:
        local x = self.x + self.w - gooi.getFont(self):getWidth(t) - self.h / 2
        local y = (self.y + self.h / 2) - (gooi.getFont(self):getHeight() / 2)
        if self.align == gooi.l then
            x = self.x + self.h / 2
            if self.icon then
                x = x + self.h / 2
            end
        elseif self.align == "center" then
            x = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(t) / 2)
        end
        if self.icon then
            local xImg = math.floor(self.x + self.h / 2)
            love.graphics.setColor(255, 255, 255)
            if not self.enabled then love.graphics.setColor(63, 63, 63) end

            if t:len() == 0 then
                xImg = math.floor(self.x + self.w / 2)
            end
            love.graphics.draw(self.icon, xImg, math.floor(self.y + self.h / 2), 0, 1, 1,
                math.floor(self.icon:getWidth() / 2),
                math.floor(self.icon:getHeight() / 2))
        end
        love.graphics.setColor(fg)
        local yLine = self.y + self.h / 2
        yLine = yLine - (gooi.getFont(self):getHeight()) * #self.textParts / 2
        for i = 1, #self.textParts do
            local part = self.textParts[i]

            local xLine = self.x + self.w - gooi.getFont(self):getWidth(part) - self.h / 2
            if self.align == gooi.l then
                xLine = self.x + self.h / 2
                if self.icon then
                    xLine = xLine + self.h /2
                end
            elseif self.align == "center" then
                xLine = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(part) / 2)
            end
            love.graphics.print(part,
                math.floor(xLine),
                math.floor(yLine))

            yLine = yLine + (gooi.getFont(self):getHeight())
        end
        --love.graphics.print(self.text, math.floor(x), math.floor(y))
    end
    function l:left()
        self.align = gooi.l
        return self
    end
    function l:center()
        self.align = "center"
        return self
    end
    function l:right()
        self.align = gooi.r
        return self
    end
    l:right()
    function l:setIcon(icon)
        if type(icon) == "string" then
            icon = love.graphics.newImage(icon)
        end
        self.icon = icon
        --self.w = self.w + self.icon:getWidth()
        return self
        -- body
    end
    return gooi.storeComponent(l, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Button creator  -------------------------------
----------------------------------------------------------------------------
--function gooi.newButton(text, x, y, w, h)
function gooi.newButton(params)
    params = params or {}
    local b = {}
    local defaultText = "new button"
    local theH = gooi.getFont():getHeight()

    x, y, w, h = gooi.checkBounds(
        params.text or defaultText,
        params.x or 10,
        params.y or 10,
        params.w or gooi.getFont():getWidth(params.text or defaultText) + theH * 2,
        params.h or theH * 2,
        "button"
    )

    b = component.new("button", x, y, w, h, params.group)
    b = gooi.setStyleComp(b)
    b.text = params.text or defaultText
    b.icon = params.icon
    if b.icon then
        if type(b.icon) == "string" then
            b.icon = love.graphics.newImage(b.icon)
        end
        if b.text:len() > 0 then
            b.w = b.w + b.icon:getWidth()
        end
    end
    b.textParts = split(b.text, "\n")
    function b:rebuild()
        --self:generateBorder()
    end
    function b:setText(value)
        if not value then value = "" end
        self.text = tostring(value)
        self.textParts = split(self.text, "\n")
        return self
    end
    b:rebuild()
    function b:largerLine()
        local line = self.textParts[1] or ""

        for i = 2, #self.textParts do
            if #self.textParts[i] > #line then
                line = self.textParts[i]
            end
        end

        return line
    end
    function b:drawSpecifics(fg)
        -- Center text:
        local t = self:largerLine(self.textParts)
        local x = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(t) / 2)
        local y = (self.y + self.h / 2) - (gooi.getFont(self):getHeight() / 2)
        if self.align == gooi.l then
            x = self.x + self.h / 2
            if self.icon then
                x = x + self.h / 2
            end
        elseif self.align == gooi.r then
            x = self.x + self.w - self.h / 2 - gooi.getFont(self):getWidth(self.text)
        end
        if self.icon then
            local xImg = math.floor(self.x + self.h / 2)
            if t:len() == 0 then
                xImg = math.floor(self.x + self.w / 2)
            end
            love.graphics.setColor(255, 255, 255)
            if not self.enabled then love.graphics.setColor(63, 63, 63) end
            love.graphics.draw(self.icon, xImg, math.floor(self.y + self.h / 2), 0, 1, 1,
                math.floor(self.icon:getWidth() / 2),
                math.floor(self.icon:getHeight() / 2))
        end
        love.graphics.setColor(fg)
        local yLine = self.y + self.h / 2
        yLine = yLine - (gooi.getFont(self):getHeight()) * #self.textParts / 2
        for i = 1, #self.textParts do
            local part = self.textParts[i]

            local xLine = self.x + self.w - gooi.getFont(self):getWidth(part) - self.h / 2
            if self.align == gooi.l then
                xLine = self.x + self.h / 2
                if self.icon then
                    xLine = xLine + self.h /2
                end
            elseif self.align == "center" then
                xLine = (self.x + self.w / 2) - (gooi.getFont(self):getWidth(part) / 2)
            end
            love.graphics.print(part,
                math.floor(xLine),
                math.floor(yLine))

            yLine = yLine + (gooi.getFont(self):getHeight())
        end
    end
    function b:left()
        self.align = gooi.l
        return self
    end
    function b:center()
        self.align = "center"
        return self
    end
    function b:right()
        self.align = gooi.r
        return self
    end
    b:center()
    function b:setIcon(icon)
        if type(icon) == "string" then
            icon = love.graphics.newImage(icon)
        end
        self.icon = icon
        --self.w = self.w + self.icon:getWidth() * 2
        return self
        -- body
    end
    return gooi.storeComponent(b, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Slider creator  -------------------------------
----------------------------------------------------------------------------
--function gooi.newSlider(value, x, y, w, h)
function gooi.newSlider(params)
    params = params or {}
    local s = {}

    x, y, w, h = gooi.checkBounds(
        params.value or 0.5,
        params.x or 10,
        params.y or 10,
        params.w or gooi.unit * 5,
        params.h or gooi.getFont():getHeight() * 2,
        "slider"
    )

    s = component.new("slider", x, y, w, h, params.group)
    s = gooi.setStyleComp(s)
    s.value = params.value or 0.5
    s.mode = "h"-- Horizontal

    if s.value < 0 then s.value = 0 end
    if s.value > 1 then s.value = 1 end

    -- Correct slider bounds:
    --if s.h >= s.w then s.w = s.h * 1.1 end

    s.displacement = (s.w - s.h) * s.value
    function s:drawSpecifics(fg)
        if self.mode == "v" then
            local mC = self.w / 8 -- Margin corner.
            local rad = self.w * .4
            local side = self.w - mC * 2

            love.graphics.setColor(fg)
            if self.pressed or self.touch then rad = rad * .5 end

            local lineSpace = self.h - self.w
            local xPivotIndicator = self.x + self.w / 2 - side / 2
            local yPivotIndicator = self.y + self.h - (self.w / 2 +
                self.value * lineSpace + side / 2)


            love.graphics.circle("line",
                xPivotIndicator + side / 2,
                yPivotIndicator + side / 2,
                side / 2,
                circleRes)

            local x1Line = self.x + self.w / 2
            local y1Line = self.y + self.h - self.w / 2
            local x2Line = self.x + self.w / 2
            local y2Line = self.y + self.h - (
                self.w / 2 + self.value * lineSpace - side / 2
            )

            if y2Line < y1Line then
                love.graphics.line(x1Line, y1Line, x2Line, y2Line)
            end
        else
            local mC = self.h / 8 -- Margin corner.
            local rad = self.h * .4
            local side = self.h - mC * 2

            love.graphics.setColor(fg)
            if self.pressed or self.touch then rad = rad * .5 end
            local lineSpace = self.w - self.h

            local xPivotIndicator = self.x + self.h / 2 + self.value * lineSpace - side / 2
            local yPivotIndicator = self.y + mC

            love.graphics.circle("line",
                xPivotIndicator + side / 2,
                yPivotIndicator + side / 2,
                side / 2,
                circleRes)
            local x1Line = self.x + self.h / 2
            local y1Line = self.y + self.h / 2
            local x2Line = self.x + self.h / 2 + self.value * lineSpace - side / 2
            local y2Line = self.y + self.h / 2

            if x2Line > x1Line then
                love.graphics.line(x1Line, y1Line, x2Line, y2Line)
            end
        end
    end
    function s:vertical()
        self.mode = "v"-- Vertical
        return self
    end
    function s:updateGUI()
        local thePos = love.mouse.getX() / gooi.sx
        if self.mode == "v" then
            thePos = love.mouse.getY() / gooi.sy
        end

        if self.touch then
            thePos = self.touch.x
            if self.mode == "v" then
                thePos = self.touch.y
            end
        end

        self.displacement = (thePos - (self.x + self.h / 2))
        if self.displacement > (self.w - self.h) then self.displacement = self.w - self.h end
        if self.displacement < 0 then self.displacement = 0 end
        self.value = self.displacement / (self.w - self.h)

        if self.mode == "v" then
            self.displacement = (thePos - (self.y + self.w / 2))
            if self.displacement > (self.h - self.w) then self.displacement = self.h - self.w end
            if self.displacement < 0 then self.displacement = 0 end
            self.value = 1 - self.displacement / (self.h - self.w)
        end
    end
    function s:setValue(v)
        if v < 0 then v = 0 end
        if v > 1 then v = 1 end
        self.value = v
        return self
    end
    function s:getValue()
        return gooi.round(self.value, 2)
    end
    function s:rebuild()
        --self:generateBorder()
        self:setValue(params.value or 0.5)
    end
    s:rebuild()
    return gooi.storeComponent(s, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Checkbox creator  -----------------------------
----------------------------------------------------------------------------
--function gooi.newCheck(text, x, y, w, h)
function gooi.newCheck(params)
    params = params or {}
    local chb = {}

    x, y, w, h = gooi.checkBounds(
        params.text or "",
        params.x or 10,
        params.y or 10,
        params.w or gooi.getFont():getHeight() * 2,
        params.h or gooi.getFont():getHeight() * 2,
        "checkbox"
    )

    chb = component.new("checkbox", x, y, w, h, params.group)
    chb = gooi.setStyleComp(chb)
    chb.checked = params.checked or false
    chb.text = params.text or ""
    function chb:rebuild()
        --self:generateBorder()
    end
    chb:rebuild()
    function chb:drawSpecifics(fg)
        love.graphics.setColor(fg)
        love.graphics.circle("line",
            self.x + self.h / 2,
            self.y + self.h / 2,
            self.h / 3,
            circleRes
        )

        if self.checked then
            love.graphics.circle("fill",
                self.x + self.h / 2,
                self.y + self.h / 2,
                self.h / 3,
                circleRes
            )
        end

        -- text of the checkbox:
        love.graphics.setColor(fg)
        love.graphics.print(self.text,
            math.floor(self.x + self.h * 1.2),
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
--function gooi.newRadio(text, radioGroup, x, y, w, h)
function gooi.newRadio(params)
    params = params or {}
    local r = {}

    x, y, w, h = gooi.checkBounds(
        params.text or "",
        params.x or 10,
        params.y or 10,
        params.w or gooi.getFont():getHeight() * 2,
        params.h or gooi.getFont():getHeight() * 2,
        "radio"
    )

    r = component.new("radio", x, y, w, h, params.group)
    r = gooi.setStyleComp(r)
    r.selected = params.selected or false
    r.text = params.text or ""
    r.radioGroup = params.radioGroup or "default"
    function r:rebuild()
        --self:generateBorder()
        if self.text == "" then
            self.w = self.h
        end
    end
    r:rebuild()
    function r:drawSpecifics(fg)
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill",
            self.x + self.h / 2,
            self.y + self.h / 2,
            self.h / 3,
            circleRes
        )
        love.graphics.circle("line",
            self.x + self.h / 2,
            self.y + self.h / 2,
            self.h / 3,
            circleRes
        )

        love.graphics.setColor(fg)
        if self.selected then
            love.graphics.circle("line",
                self.x + self.h / 2,
                self.y + self.h / 2,
                self.h / 6,
                circleRes
            )
        end

        love.graphics.print(self.text,
            math.floor(self.x + self.h * 1.2),
            math.floor(self.y + self.h / 2 - gooi.getFont(self):getHeight() / 2))
    end
    function r:setRadioGroup(g)
        self.radioGroup = g
        return self
    end
    function r:select()
        self.selected = true
        gooi.deselectOtherRadios(self.radioGroup, self.id)
        self.selected = true
        return self
    end
    return gooi.storeComponent(r, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Textfield creator   ---------------------------
----------------------------------------------------------------------------
--function gooi.newText(id, text, x, y, w, h, group)
--function gooi.newText(text, x, y, w, h)
function gooi.newText(params)
    params = params or {}
    local f = {}
    local defaultText = "Type here"

    x, y, w, h = gooi.checkBounds(
        params.text or defaultText,
        params.x or 10,
        params.y or 10,
        params.w or gooi.getFont():getWidth(params.text or defaultText) + gooi.unit * 4,
        params.h or gooi.getFont():getHeight() * 2,
        "text"
    )

    f = component.new("text", x, y, w, h, params.group)
    f.letters = {}
    f.dispHiddenChar = 0
    f.mt = gooi.unit / 5 -- margin text
    f.timerRepeatKey = 0
    f.timerCanRepeat = 0
    f.timerCursorBlink = 0
    f.showingCursor = true
    function f:lettersWidth()
        local l = 0
        for i = 1, #self.letters do
            local char = self.letters[i].char
            l = l + gooi.getFont(self):getWidth(char)
        end
        return l
    end
    f.indexCursor = 0

    function f:drawSpecifics(fg)
        local mC = self.h / 8
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill",
            self.x + mC,
            self.y + mC,
            self.w - mC * 2,
            self.h - mC * 2,
            self.style.innerRadius,
            self.style.innerRadius,
            circleRes
        )

        love.graphics.setColor(fg)
        local charDisplacement = 0

        for i = 1, #self.letters do
            local letter = self.letters[i]
            love.graphics.stencil(function()
                love.graphics.rectangle("fill",
                    self.x + mC,
                    self.y + mC,
                    self.w - mC * 2,
                    self.h - mC * 2,
                    self.style.innerRadius,
                    self.style.innerRadius,
                    circleRes
                )
            end, "replace", 1)
            love.graphics.setStencilTest("greater", 0)
            local xChar = self.x + mC + charDisplacement + self.mt - self.dispHiddenChar
            local yChar = self.y + self.h / 2 - gooi.getFont(self):getHeight() / 2

            love.graphics.print(
                letter.char,
                math.floor(xChar),
                math.floor(yChar)
            )

            love.graphics.setStencilTest()
            charDisplacement = charDisplacement + letter.w
            if i == self.indexCursor then
                self:drawCursor(charDisplacement + self.mt, mC)
            end
        end
        if self.indexCursor == 0 then
            self:drawCursor(self.mt, mC)
        end

        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line",
            self.x + mC,
            self.y + mC,
            self.w - mC * 2,
            self.h - mC * 2,
            self.style.innerRadius,
            self.style.innerRadius,
            circleRes
        )
    end

    function f:drawCursor(disp, mC)
        if self.showingCursor then
            if self == gooi.focused then
                self.xCursor = self.x + mC + disp - self.dispHiddenChar

                love.graphics.line(
                    self.xCursor,
                    self.y + mC + gooi.unit / 15,
                    self.xCursor,
                    self.y + self.h - mC - gooi.unit / 15
                )
            end
        end
    end

    function f:updateCursor(key, dt)
        self.timerCursorBlink = self.timerCursorBlink + dt
        if self.timerCursorBlink > gooi.delayCursorBlink then
            self.timerCursorBlink = 0
            self.showingCursor = not self.showingCursor

            if self.keyToRepeat then
                self.showingCursor = true
            end
        end

        if self.keyToRepeat then
            self.timerCanRepeat = self.timerCanRepeat + dt
            if self.timerCanRepeat > gooi.delayCanRepeat then
                self.timerRepeatKey = self.timerRepeatKey + dt

                if self.timerRepeatKey >= gooi.delayKey then
                    self.timerRepeatKey = 0

                    if key == gooi.bs then
                        self:deleteBack()
                    elseif key == gooi.del then
                        self:deleteDel()
                    elseif key == gooi.r then
                        self:moveRight()
                    elseif key == gooi.l then
                        self:moveLeft()
                    end
                end
            end
        end
    end

    function f:setToRepeat(key)
        self.keyToRepeat = key
    end

    function f:typeText(text)
        if self:lettersWidth() <= self.w - self.mt * 4 then
            table.insert(self.letters, self.indexCursor + 1, {
                char = text,
                w = gooi.getFont(self):getWidth(text),
                h = gooi.getFont(self):getHeight()
            })
            self.indexCursor = self.indexCursor + 1
        end

        if self:lettersWidth() > self.w - self.mt * 2 then
            -- todo
            --local width = gooi.getFont(self):getWidth(text)
            --self.dispHiddenChar = self.dispHiddenChar + width
        end
        self:fixViewport()
    end

    function f:moveLeft()
        if self.indexCursor > 0 and gooi.desktop then
            self.indexCursor = self.indexCursor - 1
        end
        self:fixViewport()
    end

    function f:moveRight()
        if self.indexCursor < #self.letters and gooi.desktop then
            self.indexCursor = self.indexCursor + 1
        end
        self:fixViewport()
    end

    function f:deleteBack()
        if #self.letters > 0 and gooi.desktop then
            local letter = table.remove(self.letters, self.indexCursor)
            if letter then
                self.indexCursor = self.indexCursor - 1
                if self.dispHiddenChar > 0 then
                    self.dispHiddenChar = self.dispHiddenChar - letter.w
                end
            end
        end
        self:fixViewport()
    end

    function f:deleteDel()
        if #self.letters > 0 and gooi.desktop then
            table.remove(self.letters, self.indexCursor + 1)
        end
        self:fixViewport()
    end

    function f:fixViewport()
        -- todo
        --[[
        local currentLetter = self.letters[self.indexCursor + 1]
        if currentLetter then
            if self.xCursor <= self.x - self.mt then
                self.dispHiddenChar = self.dispHiddenChar - currentLetter.w
            end
        end
        ]]
    end

    function f:typeCode(key, scancode, isrepeat)
        if     key == gooi.l then   self:moveLeft()
        elseif key == gooi.r then   self:moveRight()
        elseif key == gooi.bs then  self:deleteBack()
        elseif key == gooi.del then self:deleteDel() end
    end

    function f:setText(text)
        for i = 1, string.utf8len(text) do
            local char = string.utf8sub(text, i, i)
            self:typeText(char)
        end
        return self
    end

    function f:specialKey(k)
        return k == gooi.bs or
               k == gooi.del or
               k == gooi.l or
               k == gooi.r
    end

    return gooi.storeComponent(f, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Progress bar creator   ------------------------
----------------------------------------------------------------------------
--function gooi.newBar(value, x, y, w, h)
function gooi.newBar(params)
    params = params or {}
    local p = {}

    x, y, w, h = gooi.checkBounds(
        "..........",
        params.x or 10,
        params.y or 10,
        params.w or gooi.unit * 5,
        params.h or gooi.getFont():getHeight() * 2,
        "progressbar"
    )

    p = component.new("progressbar", x, y, w, h, params.group)
    p = gooi.setStyleComp(p)
    p.value = params.value or 0.5
    p.changing = false
    p.speed = 0
    if p.value > 1 then p.value = 1 end
    if p.value < 0 then p.value = 0 end
    function p:rebuild()
        --self:generateBorder()
    end
    p:rebuild()
    function p:drawSpecifics(fg)
        love.graphics.setColor(self.style.bgColor)
        local marginBars = 0 -- (self.h / 8)
        local function maskBar()
            love.graphics.rectangle("fill",
                self.x + marginBars,
                self.y + marginBars,
                self.w - marginBars * 2,
                self.h - marginBars * 2,
                self.style.innerRadius,
                self.style.innerRadius,
                circleRes)
        end
        maskBar()

        love.graphics.setColor(self.style.bgColor)
        love.graphics.rectangle("fill",
            self.x + marginBars,
            self.y + marginBars,
            self.w,
            self.h,
            self.style.innerRadius,
            self.style.innerRadius,
            circleRes
        )

        love.graphics.setColor(self.style.fgColor)
        if not self.enabled then
            love.graphics.setColor(63, 63, 63)
        end

        local barWidth = self.value * (self.w - marginBars * 2)
        -- Mask for drawing:
        love.graphics.stencil(maskBar, "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        -- Value indicator bar:
        love.graphics.rectangle("fill",
            self.x + marginBars,
            self.y + marginBars,
            barWidth,
            self.h - marginBars * 2)
        love.graphics.setStencilTest()
        love.graphics.setColor(fg)
        love.graphics.rectangle("line",
                self.x + marginBars,
                self.y + marginBars,
                self.w - marginBars * 2,
                self.h - marginBars * 2,
                self.style.innerRadius,
                self.style.innerRadius,
                circleRes)
    end
    function p:changeValue(amount, dt)
        if amount > 1 then amount = 1 end
        if amount < 0 then amount = 0 end
        local delta = 1
        if dt then delta = dt end
        self.value = self.value + amount * delta
        if self.value > 1 then self.value = 1 end
        if self.value < 0 then self.value = 0 end
        return self
    end
    function p:getValue()
        return gooi.round(self.value, 2)
    end
    function p:decreaseAt(amount)
        self.changing = -1
        self.speed = amount or 0.1
        return self
    end
    function p:increaseAt(amount)
        self.changing = 1
        self.speed = amount or 0.1
        return self
    end
    function p:setWidth(l)
        self.w = l
        return self
    end
    return gooi.storeComponent(p, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Spinner creator   -----------------------------
----------------------------------------------------------------------------

--function gooi.newSpinner(min, max, value, x, y, w, h)
function gooi.newSpinner(params)
    params = params or {}
    local s = {}

    x, y, w, h = gooi.checkBounds(
        "..........",
        params.x or 10,
        params.y or 10,
        params.w or gooi.unit * 5,
        params.h or gooi.getFont():getHeight() * 2,
        "spinner"
    )

    local v = params.value or 5
    local maxv = params.max or 10
    s = component.new("spinner", x, y, w, h, params.group)
    s = gooi.setStyleComp(s)
    s.value = v
    s.realValue = s.value
    s.max = maxv
    s.min = params.min or 0
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
        love.graphics.circle("line",
            self.x + self.h / 2,
            self.y + self.h / 2,
            self.h / 6,
            circleRes
        )
        love.graphics.circle("line",
            self.x + self.w - self.h / 2,
            self.y + self.h / 2,
            self.h / 3,
            circleRes
        )

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
        return self:overIt() and x < (self.x + self.w / 2)
    end
    function s:overPlus(x, y)
        return self:overIt() and x >= (self.x + self.w / 2)
    end
    function s:plus()
        self:changeValue(1)
    end
    function s:minus()
        self:changeValue(-1)
    end
    function s:getValue()
        return gooi.round(self.value, 2)
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
--function gooi.newJoy(id, x, y, size, deadZone, group)
--function gooi.newJoy(x, y, size, deadZone, image)
function gooi.newJoy(params)
    params = params or {}
    local s = {}
    local defSize = gooi.unit * 4

    x, y, w, h = gooi.checkBounds(
        "..........",
        params.x or 10,
        params.y or 10,
        params.w or defSize,
        params.h or defSize,
        "joystick"
    )

    -- Note that the sitck has x and y on the center.
    s = component.new("joystick", x, y, params.size or defSize, params.size or defSize, params.group)
    s = gooi.setStyleComp(s)
    s.radiusCorner = s.h / 2
    s.deadZone = params.deadZone or 0 -- Given in percentage (0 to 1).
    if s.deadZone < 0  then s.deadZone = 0 end
    if s.deadZone > 1  then s.deadZone = 1 end
    s.stickPressed = false
    s.dx, s.dy = 0, 0
    s.spring = true
    s.sxImg, s.syImg = 1, 1
    s.digitalH, s.digitalV = "", ""
    function s:drawSpecifics(fg)
        love.graphics.setColor(fg)
        self:drawStick()
    end
    function s:rebuild()
        self.r = self.smallerSide / 2
        self.rStick = self.r / 2
        self.xStick = (self.x) + (self.r)
        self.yStick = (self.y) + (self.r)
        --self:generateBorder()
    end
    s:rebuild()
    function s:setImage(image)
        if image then
            if type(image) == "string" then
                image = love.graphics.newImage(image)
            end
            self.image = image
            self.image:setFilter("linear", "linear")
        end
        return self
    end
    s:setImage(params.image)
    function s:noScaling()
        self.notS = true
        return self
    end
    function s:anyPoint()
        self.anyP = true
        return self
    end
    function s:setDigital(directions)-- 4 or 8
        if directions and
        directions ~= "4" and
        directions ~= "8" then

        end
        self.digital = directions or "8"
        return self
    end
    function s:drawStick()
        local fg = self.style.fgColor
        if self.image then
            love.graphics.setColor(255, 255, 255, fg[4] or 255)
            local sx = self.rStick * 2 / self.image:getWidth()
            local sy = self.rStick * 2 / self.image:getHeight()
            local x, y = self.xStick, self.yStick
            if self.notS then
                sx, sy = 1, 1
                x, y = (self.xStick), (self.yStick)
            end

            if self.digital then
                x, y = self:computeDigital()
            end

            love.graphics.draw(self.image,
                x, y, 0, sx, sy,
                self.image:getWidth() / 2,
                self.image:getHeight() / 2)
        else
            local x = self.xStick
            local y = self.yStick

            if self.digital then
                x, y = self:computeDigital()
            end
            love.graphics.circle("line", x, y, self.rStick, circleRes)
        end
    end
    function s:computeDigital()
        -- horizontal directions:
        local xv = self:xValue()
        local yv = self:yValue()

        if self.digital == "8" then
            -- horizontal direction:
            if xv < -0.5 then
                self.digitalH = "l"
                x = self.x + self.rStick
            elseif xv > 0.5 then
                self.digitalH = "r"
                x = self.x + self.w - self.rStick
            else
                self.digitalH = ""
                x = self.x + self.w / 2
            end
            --vertical:
            if yv < -0.5 then
                self.digitalV = "t"
                y = self.y + self.rStick
            elseif yv > 0.5 then
                self.digitalV = "b"
                y = self.y + self.h - self.rStick
            else
                self.digitalV = ""
                y = self.y + self.h / 2
            end
        elseif self.digital == "4" then-- 4 directions joystick:
            --ToDo
        end

        return x, y
    end
    function s:move(direction)
        if (self.pressed or self.touch) and self.stickPressed then
            local daX, daY = love.mouse.getPosition()
            daX = daX / gooi.sx
            daY = daY / gooi.sy
            if self.touch then
                daX, daY = self.touch.x, self.touch.y
            end
            if self:butting() then
                local dX = self:theX() - daX - self.dx
                local dY = self:theY() - daY - self.dy
                local angle = (math.atan2(dY, dX) + math.rad(180));
                self.xStick = self.x + (self.r - self.rStick) * math.cos(angle) + self.r
                self.yStick = self.y + (self.r - self.rStick) * math.sin(angle) + self.r
            else
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
    function s:noSpring()
        self.spring = false
        return self
    end
    function s:butting()
        local hyp = 0
        local daX, daY = love.mouse.getPosition()
        daX = daX / gooi.sx
        daY = daY / gooi.sy
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
        return gooi.round((self.xStick - self:theX()) / (self.r - self.rStick), 2)
    end
    function s:yValue()
        if self:onDeadZone() then return 0 end
        return gooi.round((self.yStick - self:theY()) / (self.r - self.rStick), 2)
    end
    function s:direction()
        if self.digital then
            return self.digitalV..self.digitalH
        else
            return ""
        end
    end
    function s:overStick(x, y)
        local dx = (self.xStick - x)
        local dy = (self.yStick - y)
        return math.sqrt(math.pow(dx, 2) + math.pow(dy, 2)) < self.rStick * 1.1
    end
    function s:onDeadZone()
        local dx, dy = self:theX() - self.xStick, self:theY() - self.yStick
        return math.sqrt(math.pow(dx, 2) + math.pow(dy, 2)) <= self.deadZone * (self.r - self.rStick)
    end
    function s:theX() return (self.x) + (self.r) end
    function s:theY() return (self.y) + (self.r) end



    return gooi.storeComponent(s, id)
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Knob creator   -------------------------------
----------------------------------------------------------------------------

--function gooi.newKnob(value, x, y, size)
function gooi.newKnob(params)
    params = params or {}
    local k = {}
    local defSize = gooi.unit * 3

    x, y, w, h = gooi.checkBounds(
        "..........",
        params.x or 10,
        params.y or 10,
        params.size or defSize,
        params.size or defSize,
        "knob"
    )

    k = component.new("knob", x, y, w, h, params.group)
    k = gooi.setStyleComp(k)
    k.radKnob = (k.h * .4)
    k.xKnob = (k.x + k.w / 2)
    k.yKnob = (k.y + k.h / 2)
    k.pivotY = k.yKnob
    k.pivotValue = params.value or 0.5
    k.changedValue = params.value or 0.5
    k.value = k.pivotValue

    k.initialAngle = 0
    k.finalAngle = 360

    function k:getValue()
        return gooi.round(self.value, 2)
    end

    function k:setValue(v)
        if v > 1 then v = 1 end
        if v < 0 then v = 0 end

        k.pivotValue = v
        k.changedValue = v
        k.value = v
    end

    function k:drawSpecifics(fg)
        local bg = self.style.bgColor
        love.graphics.setColor(0, 0, 0)
        love.graphics.arc("line",
            "open",
            self.xKnob,
            self.yKnob,
            self.radKnob,
            math.rad(180 + self.finalAngle * self.value),
            math.rad(180 + self.finalAngle),
            circleRes)

        love.graphics.setColor(fg)
        if not self.enabled then
            love.graphics.setColor(63, 63, 63)
        end
        love.graphics.arc("line",
        "open",
        self.xKnob,
        self.yKnob,
        self.radKnob,
        math.rad(180 + self.initialAngle),
        math.rad(180 + self.finalAngle * self.value),
        circleRes)
    end

    function k:turn()
        local x, y = love.mouse.getX() / gooi.sx, love.mouse.getY() / gooi.sy
        local centerX, centerY = self.x + self.w / 2, self.y + self.h / 2

        local startAngle = self.value

        if self.touch then
            x, y = self.touch.x, self.touch.y
        end

        local angle = math.atan2((centerY - y), (centerX - x)) / 2 / math.pi

        --math.atan goes negative after 180 degrees
        if angle < 0 then
            angle = 1 + angle
        end

        --If it's at the start or the end, keep it there within the first and last quarter
        if startAngle < .25 and angle > .75 then
            self.changedValue = 0
        elseif angle < .25 and startAngle > .75 then
            self.changedValue = 1
        else
            self.changedValue = angle
        end

        if self.changedValue > 1 then self.changedValue = 1 end
        if self.changedValue < 0 then self.changedValue = 0 end

        self.value = self.changedValue
    end

    function k:rebuild()
        self.radKnob = (self.h * .4)
        self.xKnob = (self.x + self.w / 2)
        self.yKnob = (self.y + self.h / 2)
        self.pivotY = self.yKnob
    end
    k:rebuild()

    return gooi.storeComponent(k, id)
end



----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Panel creator   -------------------------------
----------------------------------------------------------------------------
--function gooi.newPanel(x, y, w, h, theLayout)
function gooi.newPanel(params)
    params = params or {}
    local p = {}
    local defLayout = "grid 3x3"

    x, y, w, h = gooi.checkBounds(
        "..........",
        params.x or 10,
        params.y or 10,
        params.w or gooi.unit * 5,
        params.h or gooi.unit * 5,
        "panel"
    )

    p = component.new("panel", x, y, w, h, params.group)
    p = gooi.setStyleComp(p)
    p.opaque = false
    p.x = x
    p.y = y
    p.w = w
    p.h = h
    p.sons = {}
    function p:setLayout(l)
        if l then
            if l:sub(0, 4) == "grid" then
                p.layout = layout.new(l)
                p.layout:init(p)
            elseif l:sub(0, 4) == "game" then
                p.layout = layout.new(l)
            else
                error("Layout definition must be 'grid NxM' or 'game'")
            end
            --print(unpack(split(theLayout, " ")))
        else
            p.layout = layout.new(defLayout)
            p.layout:init(p)
        end
        return self
    end
    p:setLayout(params.layout or defLayout)
    function p:debug()
        self.layout.debug = true
        return self
    end
    function p:drawSpecifics(fg)
        if self.layout.kind == "grid" then
            love.graphics.setColor(0, 0, 0, 127)
            self.layout:drawCells()
        end
    end
    function p:rebuild()
        if self.layout.kind == "grid" then
            self.layout:init(self)
        end
    end
    --p:rebuild()
    function p:add(...)
        local params = {...}
        if self.layout.kind == "grid" then
            if type(params[2]) == "string" then-- Add component in a given position:
                local row = split(params[2], ",")[1]
                local col = split(params[2], ",")[2]
                local cell = self.layout:getCell(tonumber(row), tonumber(col))

                if not cell then
                    error("Row "..row.." and Col "..col.." not defined")
                end

                local c = params[1]
                -- Set bounds according to the parent layout:
                c:setBounds(cell.x, cell.y, cell.w, cell.h)

                -- Save son:
                table.insert(self.sons,
                {
                    id = c.id,
                    parentId = self.id,
                    cellRow = cell.row,
                    cellCol = cell.col,
                    ref = c
                })

                c.ongrid = true
                cell.on = false

                -- Joysticks are always a square or cirle:
                if c.type == "joystick" then
                    c.w = c.smallerSide
                    c.h = c.smallerSide
                end

                if c.rebuild then c:rebuild() end
                if c.type == "joystick" then
                    -- Workaround for joysticks:
                    joy1.pressed = true
                    joy1.stickPressed = true
                    joy1:restore()
                    joy1.stickPressed = false
                    joy1.pressed = false
                end
            else-- Add component in the next available cell:
                for i = 1, #params do
                    local c = params[i]
                    local cell = self.layout:nextCell(c)



                    if not cell then
                        error("Insufficient cells in grid layout")
                    end

                    -- Set bounds according to the parent layout:
                    c:setBounds(cell.x, cell.y, cell.w, cell.h)
                    c.ongrid = true
                    --print("cell: ", c.x, c.y)

                    -- Save child:
                    table.insert(self.sons,
                    {
                        id = c.id,
                        parentId = self.id,
                        cellRow = cell.row,
                        cellCol = cell.col,
                        ref = c
                    })

                    -- Joysticks are always a square or cirle:
                    if c.type == "joystick" then
                        c.w = c.smallerSide
                        c.h = c.smallerSide
                    end

                    if c.rebuild then c:rebuild() end
                    if c.type == "joystick" then
                        -- Workaround for joysticks:
                        joy1.pressed = true
                        joy1.stickPressed = true
                        joy1:restore()
                        joy1.stickPressed = false
                        joy1.pressed = false
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
            -- Save son:
            ref.ongame = true
            table.insert(self.sons,
            {
                id = ref.id,
                parentId = self.id,
                cellRow = -1,
                cellCol = -1,
                ref = ref
            })
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

--*********************************************
--*********************************************
--            Special dialog widgets:           
--*********************************************
--*********************************************

--function gooi.alert(msg, fOK)
function gooi.alert(params)
    gooi.dialog(params, "alert")
end

--function gooi.confirm(msg, fYes, fNo)
function gooi.confirm(params)
    gooi.dialog(params, "confirm")
end

--function gooi.dialog(msg, fPositive, fNegative, kind)
function gooi.dialog(params, kind)
    if not gooi.showingDialog then
        gooi.showingDialog = true
        local positiveBtnTxt = "OK"
        local negativeBtnTxt = "Cancel"

        gooi.dialogMsg = params.text or "message"
        fPositive = params.ok
        fNegative = params.cancel
        positiveBtnTxt = params.okText or positiveBtnTxt
        negativeBtnTxt = params.cancelText or negativeBtnTxt

        local w, h = love.graphics.getWidth(), love.graphics.getHeight()

        local smaller = gooi.smallerSide()

        gooi.dialogW = math.floor(smaller * 0.8)
        gooi.dialogH = math.floor(gooi.dialogW * 0.6)

        if gooi.desktop then
            gooi.dialogW = math.floor(gooi.dialogW / 2)
            gooi.dialogH = math.floor(gooi.dialogH / 2)
        end

        gooi.panelDialog = gooi.newPanel({
            x = math.floor(w / 2 - gooi.dialogW / 2),
            y = math.floor(h / 2 - gooi.dialogH / 2),
            w = math.floor(gooi.dialogW),
            h = math.floor(gooi.dialogH),
            layout = "grid 3x3"}
        )

        gooi.panelDialog.layout.padding = 7-- Default = 3
        gooi.panelDialog.layout:init(gooi.panelDialog)

        gooi.panelDialog:setColspan(1, 1, 3)-- For the msg:
        gooi.panelDialog:setRowspan(1, 1, 2)

        gooi.lblDialog = gooi.newLabel({text = gooi.dialogMsg}):center()
            :setOpaque(false)
        gooi.lblDialog.lblFlag = true
        gooi.panelDialog:add(gooi.lblDialog, "1,1")

        if kind == "alert" then
            gooi.okButton  = gooi.newButton({text = positiveBtnTxt}):onRelease(function()
                gooi.closeDialog()
                if fPositive then
                    fPositive()
                end
            end)
            gooi.okButton.okFlag = true
            gooi.panelDialog:add(gooi.okButton,  "3,2")
            gooi.radCorner = gooi.okButton.style.radius
        else
            gooi.noButton  = gooi.newButton({text = negativeBtnTxt}):onRelease(function()
                gooi.closeDialog()
                if fNegative then
                    fNegative()
                end
            end)
            gooi.yesButton = gooi.newButton({text = positiveBtnTxt}):onRelease(function()
                gooi.closeDialog()
                if fPositive then
                    fPositive()
                end
            end)
            gooi.noButton.noFlag   = true
            gooi.yesButton.yesFlag = true
            gooi.panelDialog:add(gooi.noButton,  "3,1")
            gooi.panelDialog:add(gooi.yesButton, "3,3")
            gooi.radCorner = gooi.noButton.style.radius
        end
    end
end

function gooi.closeDialog()
    --print(#gooi.components)
    gooi.removeComponent(gooi.panelDialog)
    gooi.showingDialog = false
end













--**************************************************************************
--**************************************************************************

-- gooi functions:

--**************************************************************************
--**************************************************************************


function gooi.storeComponent(c, id)
    table.insert(gooi.components, c)
    return c
end

function gooi.setCanvas(c)
    gooi.canvas = c
    gooi.sx = love.graphics.getWidth() / gooi.canvas:getWidth()
    gooi.sy = love.graphics.getHeight() / gooi.canvas:getHeight()
end

function gooi.round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function gooi.removeComponent(comp)
    for k, v in pairs(gooi.components) do
        local c = gooi.components[k]

        if c == comp then
            --print("id father: "..c.id)
            if c.sons then
                for k2, v2 in pairs(c.sons) do
                    --print("text sons: "..(c.sons[k2].text or "(nil)"))
                    gooi.removeComponent(c.sons[k2].ref)
                    c.sons[k2] = nil
                end
                c.sons = nil
            end
            gooi.components[k] = nil
            return
        end
    end
end

function gooi.processStyle(style)
    if style.bgColor and type(style.bgColor) == "string" then
        style.bgColor = gooi.toRGBA(style.bgColor)
    end
    if style.fgColor and type(style.fgColor) == "string" then
        style.fgColor = gooi.toRGBA(style.fgColor)
    end
    if style.borderColor and type(style.borderColor) == "string" then
        style.borderColor = gooi.toRGBA(style.borderColor)
    end
    style.bgColor = style.bgColor or component.style.bgColor
    style.fgColor = style.fgColor or component.style.fgColor
    style.tooltipFont = style.tooltipFont or component.style.tooltipFont
    style.radius = style.radius or component.style.radius
    style.innerRadius = style.innerRadius or component.style.innerRadius
    style.showBorder = style.showBorder or false
    style.borderColor = style.borderColor or component.style.borderColor
    style.borderStyle = style.borderStyle or component.style.borderStyle
    style.borderWidth = style.borderWidth or component.style.borderWidth
    style.font = style.font or component.style.font

    return style
end

function gooi.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[gooi.deepcopy(orig_key)] = gooi.deepcopy(orig_value)
        end
        setmetatable(copy, gooi.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function gooi.setStyleComp(c)
    function c:setStyle(s)
        local style = gooi.processStyle(s)
        c.style = style

        if not (c.ongrid or c.ongame) then-- Ignore components in a grid layout:
            local s = c.style
            if c.type == "button" or c.type == "label" or c.type == "label" then
                c.w = s.font:getWidth(c.text) + s.font:getHeight() * 2
                c.h = s.font:getHeight() * 2
            end
            if c.type == "checkbox" or c.type == "radio" then
                c.w = s.font:getWidth(c.text) + s.font:getHeight() * 3
                c.h = s.font:getHeight() * 2
            end
            if c.type == "spinner" then
                c.w = s.font:getWidth(c.max) + s.font:getHeight() * 4
                c.h = s.font:getHeight() * 2
            end
            if c.type == "text" then
                c.w = s.font:getWidth(c.text) + s.font:getHeight() * 1.5
                c.h = s.font:getHeight() * 2
            end
        end

        if c.sons then
            for i = 1, #c.sons do
                c.sons[i].ref:setStyle(style)
            end
        end

        return c
    end

    return c
end

function gooi.setStyle(style)
    local s = gooi.processStyle(style)
    component.style = s
    gooi.font = s.font
end

-- Update what needs to be updated:
local timerBackspaceText = 0
local timerStepChar = 0
function gooi.update(dt)
    for k, c in pairs(gooi.components) do
        if c.type == "progressbar" and c.visible then
            if c.changing and c.enabled then
                c.value = c.value + c.speed * c.changing * dt
                if c.value > 1 then c.value = 1 end
                if c.value < 0 then c.value = 0 end
            end
        end
        if c.type == "text" and c.hasFocus then
            local key = c.keyToRepeat
            c:updateCursor(key, dt)
        end
        if c.enabled and c.visible and (c.pressed or c.touch) then
            if c.type == "slider" then
                local t = c.touch
                if t then
                    c:updateGUI()
                else
                    c:updateGUI()
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

function gooi.mode3d()
    component.mode3d = true
    component.shadow = false
    component.glass = false
end

function gooi.glass()
    component.mode3d = false
    component.glass = true
    component.shadow = false
end

function gooi.shadow()
    component.mode3d = false
    component.glass = false
    component.shadow = true
end

-- Draw the stuff:

function gooi.draw(group)
    local actualGroup = group or "default"

    local prevFont  = love.graphics.getFont()
    local prevLineW = love.graphics.getLineWidth()
    local prevLineS = love.graphics.getLineStyle()
    local prevR, prevG, prevB, prevA = love.graphics.getColor()

    local noButton, okButton, yesButton, msgLbl = nil, nil, nil, nil

    local compWithTooltip = nil -- Just for desktop.

    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(gooi.unit / 10)
    love.graphics.setLineStyle("smooth")

    for k, comp in pairs(gooi.components) do

        if comp.noFlag then
            noButton = comp
        end

        if comp.okFlag then
            okButton = comp
        end

        if comp.yesFlag then
            yesButton = comp
        end

        if comp.lblFlag then
            msgLbl = comp
        end

        if not comp.noFlag and not comp.okFlag and not comp.yesFlag
        and not comp.lblFlag then
            if actualGroup == comp.group and comp.visible then
                if comp.type ~= "progressbar" then
                    comp:draw()-- Draw the base.
                end

                love.graphics.setFont(gooi.getFont(comp))-- Specific or a common font.

                local fg = comp.style.fgColor
                if not comp.enabled then
                    fg = {31, 31, 31}
                end

                ------------------------------------------------------------
                ------------------------------------------------------------
                ------------------------------------------------------------


                comp:drawSpecifics(fg)
                comp:drawShadowPressed()


                ------------------------------------------------------------
                ------------------------------------------------------------
                ------------------------------------------------------------

            else
                --comp:setVisible(false)
            end

            if comp.showTooltip then
                compWithTooltip = comp
            end

        end
    end

    -- Check if a tooltip was generated, just for desktop:¡
    local os = love.system.getOS()
    if compWithTooltip and os ~= "Android" and os ~= "iOS" and gooi.desktop then
        local disp = love.graphics.getWidth() / 100

        local ttf = compWithTooltip.style.tooltipFont

        local unit = compWithTooltip.style.tooltipFont:getHeight() / 5
        love.graphics.setColor(0, 0, 0, 180)
        love.graphics.setFont(ttf)
        local xRect = love.mouse.getX() + disp - unit
        local yRect = love.mouse.getY() - disp * 2 - unit
        local xText = love.mouse.getX() + disp
        local yText = love.mouse.getY() - disp * 2
        local wRect = ttf:getWidth(compWithTooltip.tooltip) + unit * 2
        local hRect = ttf:getHeight() + unit * 2
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

    if gooi.showingDialog then
        love.graphics.setFont(gooi.getFont(self))-- Specific or a common font.
        local w, h = love.graphics.getWidth(), love.graphics.getHeight()

        love.graphics.setColor(0, 0, 0, 127)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(component.style.bgColor)
        love.graphics.rectangle("fill",
            gooi.panelDialog.x,
            gooi.panelDialog.y,
            gooi.panelDialog.w,
            gooi.panelDialog.h,
            gooi.radCorner,
            gooi.radCorner
        )

        if component.style.showBorder then
            love.graphics.rectangle("line",
                gooi.panelDialog.x,
                gooi.panelDialog.y,
                gooi.panelDialog.w,
                gooi.panelDialog.h,
                gooi.radCorner,
                gooi.radCorner
            )
        end

        msgLbl:draw()
        msgLbl:drawSpecifics(msgLbl.style.fgColor)

        if okButton then
            okButton:draw()
            okButton:drawSpecifics(okButton.style.fgColor)
        else
            noButton:draw()
            noButton:drawSpecifics(noButton.style.fgColor)

            yesButton:draw()
            yesButton:drawSpecifics(yesButton.style.fgColor)
        end

    end

    love.graphics.setFont(prevFont)
    love.graphics.setLineWidth(prevLineW)
    love.graphics.setLineStyle(prevLineS)
    love.graphics.setColor(prevR, prevG, prevB, prevA)
end

function gooi.toRGBA(hex)
    hex = hex:gsub("#","")
    color = {tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))}
    if string.len(hex) >= 8 then
        table.insert(color, tonumber("0x"..hex:sub(7, 8)))
    end
    return color
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

function gooi.setGroupVisible(group, b)
    for k, c in pairs(gooi.components) do
        if c.group == group then
            c:setVisible(b)
        end
    end
end

function gooi.setGroupEnabled(group, b)
    for k, c in pairs(gooi.components) do
        if c.group == group then
            c:setEnabled(b)
        end
    end
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
        if  radios[i].radioGroup == group then
            radios[i].selected = false
        end
    end
end

---------------------------------------------------------------------------------------------
function gooi.pressed(id, xt, yt)
    local x = xt or love.mouse.getX()
    local y = yt or love.mouse.getY()
    x = x / gooi.sx
    y = y / gooi.sy
    gooi.focused = nil
    for k, c in pairs(gooi.components) do
        if c.enabled and c.visible then
            if c.type == "joystick" then
                if c:overIt(x, y) then
                    gooi.focused = c
                    if c.anyP then
                        c.stickPressed = true
                        c.dx = 0
                        c.dy = 0
                    elseif c:overStick(x, y) then
                        c.stickPressed = true
                        c.dx = c.xStick - x
                        c.dy = c.yStick - y
                    end
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
            if c:overIt(x, y) then
                gooi.focused = c
                if id and x and y then
                    c.touch = {
                        id = id,
                        x = x,
                        y = y
                    }-- Touch used on touchscreens only.
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
function gooi.moved(id, xt, yt)
    local comp = gooi.getCompWithTouch(id)
    if comp and comp.touch then-- Update touch for every component which has it.
        comp.touch.x = xt / gooi.sx
        comp.touch.y = yt / gooi.sy
        if comp.events.m then
            comp.events.m(comp)-- Moven event.
        end
    end
end
---------------------------------------------------------------------------------------------
function gooi.released(id, xt, yt)
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
            if c.pressed then comp = c; break; end
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

function gooi.keypressed(key, scancode, isrepeat)
    if gooi.showingDialog then
        gooi.closeDialog()
    end

    local fields = gooi.getByType("text")
    for i = 1, #fields do
        local f = fields[i]
        if f == gooi.focused then
            f:typeCode(key)
            f:setToRepeat(key)
        end
    end
end

function gooi.keyreleased(key, scancode)
    local fields = gooi.getByType("text")
    for i = 1, #fields do
        local f = fields[i]
        f.keyToRepeat = nil
        f.timerRepeatKey = 0
        f.timerCanRepeat = 0
    end
end

function gooi.textinput(text)
    local fields = gooi.getByType("text")
    for i = 1, #fields do
        local f = fields[i]
        if f == gooi.focused then
            f:typeText(text)
            if f:specialKey(text) then
                f:setToRepeat(key)
            end
        end
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
        if t == "check" or t == "text" or t == "radio" then
            newW = newH
        end
        if t == "spinner" then
            newW = gooi.getFont(self):getWidth(text)
            newW = newW + newH * 2.5
        end
        if not (x and y) then
            newX, newY = 10, 10
        end
    end
    return newX, newY, newW, newH
end

function gooi.getFont(comp)
    if comp and comp.style.font then
        return comp.style.font
    end
    return gooi.font or gooi.defaultFont
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

function invert(color)
    local r, g, b, a = color[1], color[2], color[3], color[4] or 255
    return {255 - r, 255 - g, 255 - b, a}
end
