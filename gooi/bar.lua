----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--------------------------   Progress bar creator   ------------------------
----------------------------------------------------------------------------
function gooi.newBar(params)
    params = params or {}
    local p = {}

    local x, y, w, h = gooi.checkBounds(
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
        local mC = self.h / 6 -- Margin corner.
        local side = self.h - mC * 2

        local function stencilBar()
            love.graphics.rectangle("fill",
                self.x + mC,
                self.y + mC,
                self.w - mC * 2,
                self.h - mC * 2,
                self.style.innerRadius,
                self.style.innerRadius)
        end


        love.graphics.stencil(stencilBar, "replace", 1)
        love.graphics.setStencilTest("greater", 0)

        love.graphics.setColor(fg)
        for k, v in pairs({"fill", "line"}) do
            love.graphics.rectangle(v,
                (self.x + mC),
                (self.y + mC),
                math.floor((self.w - mC * 2) * self.value),
                (self.h - mC * 2))
        end
        love.graphics.setStencilTest()
        love.graphics.rectangle("line",
            self.x + mC,
            self.y + mC,
            math.floor(self.w - mC * 2),
            self.h - mC * 2,
            self.style.innerRadius,
            self.style.innerRadius)
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
