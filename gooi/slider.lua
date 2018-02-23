----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Slider creator  -------------------------------
----------------------------------------------------------------------------
function gooi.newSlider(params)
    params = params or {}
    local s = {}

    local x, y, w, h = gooi.checkBounds(
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
            local mC = self.w / 6 -- Margin corner.
            local side = self.w - mC * 2

            love.graphics.setColor(fg)
            local ls = self.h - self.w -- line space

            local x1Line = self.x + self.w / 2
            local y1Line = self.y + self.h - self.w / 2
            local x2Line = self.x + self.w / 2
            local y2Line = self.y + self.h - (
                self.w / 2 + self.value * ls
            )

            if y2Line < y1Line then
                love.graphics.line(x1Line, y1Line, x2Line, y2Line)
            end
            local compSide = (side / (2 - self.value))
            for k, v in pairs({"fill", "line"}) do
                love.graphics.rectangle(v,
                    x1Line - compSide / 2,
                    math.floor((y1Line - ls * self.value) - compSide / 2),
                    compSide,
                    compSide,
                    self.style.innerRadius,
                    self.style.innerRadius,
                    circleRes
                )
            end
        else
            local mC = self.h / 6 -- Margin corner.
            local side = self.h - mC * 2

            love.graphics.setColor(fg)
            local ls = self.w - self.h -- line space

            local x1Line = self.x + self.h / 2
            local y1Line = self.y + self.h / 2
            local x2Line = self.x + self.h / 2 + self.value * ls
            local y2Line = self.y + self.h / 2

            if x2Line > x1Line then
                love.graphics.line(x1Line, y1Line, x2Line, y2Line)
            end
            local compSide = (side / (2 - self.value))
            for k, v in pairs({"fill", "line"}) do
                love.graphics.rectangle(v,
                    math.floor((x1Line + ls * self.value) - compSide / 2),
                    y1Line - compSide / 2,
                    compSide,
                    compSide,
                    self.style.innerRadius,
                    self.style.innerRadius,
                    circleRes
                )
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
