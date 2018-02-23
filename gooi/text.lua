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

    local x, y, w, h = gooi.checkBounds(
        params.text or defaultText,
        params.x or 10,
        params.y or 10,
        params.w or gooi.getFont():getWidth(params.text or defaultText) + gooi.unit * 4,
        params.h or gooi.getFont():getHeight() * 2,
        "text"
    )

    f = component.new("text", x, y, w, h, params.group)
    f.letters = {}
    f.text = params.text or defaultText
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
        local mC = self.h / 6 -- Margin corner.
        local side = self.h - mC * 2

        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill",
            (self.x + mC),
            (self.y + mC),
            math.floor(self.w - mC * 2),
            (self.h - mC * 2),
            self.style.innerRadius,
            self.style.innerRadius,
            circleRes
        )

        love.graphics.setColor(fg)
        local charDisplacement = 0

        for i = 1, #self.letters do
            local letter = self.letters[i]
            local xChar = self.x + mC + charDisplacement + self.mt - self.dispHiddenChar
            local yChar = self.y + self.h / 2 - gooi.getFont(self):getHeight() / 2

            love.graphics.print(
                letter.char,
                math.floor(xChar),
                math.floor(yChar)
            )

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
            (self.x + mC),
            (self.y + mC),
            math.floor(self.w - mC * 2),
            (self.h - mC * 2),
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
                    math.floor(self.xCursor),
                    math.floor(self.y + mC + gooi.unit / 15),
                    math.floor(self.xCursor),
                    math.floor(self.y + self.h - mC - gooi.unit / 15)
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
        local t = text or self.text
        self.indexCursor = 0
        self.letters = {}
        for i = 1, string.utf8len(t) do
            local char = string.utf8sub(t, i, i)
            self:typeText(char)
        end
        return self
    end
    f:setText()

    function f:getText()
      local text = ""
        for i = 1, #self.letters do
            text = text..self.letters[i].char
        end
      return text
    end

    function f:specialKey(k)
        return k == gooi.bs or
               k == gooi.del or
               k == gooi.l or
               k == gooi.r
    end

    return gooi.storeComponent(f, id)
end
