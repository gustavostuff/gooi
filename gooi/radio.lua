----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Radio button creator   ------------------------
----------------------------------------------------------------------------
function gooi.newRadio(params)
    params = params or {}
    local r = {}

    local x, y, w, h = gooi.checkBounds(
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
        local mC = self.h / 6 -- Margin corner.
        local side = self.h - mC * 2

        love.graphics.setColor(0, 0, 0)
        if self.selected then
            love.graphics.setColor(fg)
        end
        gooi.drawInnerShape(self, "fill", mC, side)

        love.graphics.setColor(fg)
        if self.selected then
            love.graphics.setColor(0, 0, 0)
        end
        gooi.drawInnerShape(self, "line", mC, side)

        love.graphics.setColor(fg)
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
