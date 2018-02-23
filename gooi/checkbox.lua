----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Checkbox creator  -----------------------------
----------------------------------------------------------------------------
function gooi.newCheck(params)
    params = params or {}
    local chb = {}

    local x, y, w, h = gooi.checkBounds(
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
        local mC = self.h / 6 -- Margin corner.
        local side = self.h - mC * 2
        love.graphics.setColor(0, 0, 0)

        if self.checked then
            love.graphics.setColor(fg)            
        end

        for k, v in pairs({"fill", "line"}) do
            gooi.drawInnerShape(self, v, mC, side)
        end
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
