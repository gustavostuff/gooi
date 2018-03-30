----------------------------------------------------------------------------
--------------------------   Knob creator   --------------------------------
----------------------------------------------------------------------------
function gooi.newKnob(params)
    params = params or {}
    local k = {}
    local defSize = gooi.unit * 3

    local x, y, w, h = gooi.checkBounds(
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
            math.floor(self.xKnob),
            math.floor(self.yKnob),
            self.radKnob,
            math.rad(180 + self.finalAngle * self.value),
            math.rad(180 + self.finalAngle),
            circleRes * 2)

        love.graphics.setColor(fg)
        if not self.enabled then
            love.graphics.setColor(1/4, 1/4, 1/4)
        end
        love.graphics.arc("line",
        "open",
        math.floor(self.xKnob),
        math.floor(self.yKnob),
        self.radKnob,
        math.rad(180 + self.initialAngle),
        math.rad(180 + self.finalAngle * self.value),
        circleRes * 2)
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
