----------------------------------------------------------------------------
--------------------------   Stick creator   -------------------------------
----------------------------------------------------------------------------
function gooi.newJoy(params)
    params = params or {}
    local s = {}
    local defSize = gooi.unit * 4

    local x, y, w, h = gooi.checkBounds(
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
            love.graphics.setColor(1, 1, 1, fg[4] or 1)
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
                math.floor(x), math.floor(y),
                0, sx, sy,
                self.image:getWidth() / 2,
                self.image:getHeight() / 2)
        else
            local x = self.xStick
            local y = self.yStick

            if self.digital then
                x, y = self:computeDigital()
            end
            love.graphics.circle("line", math.floor(x), math.floor(y), self.rStick, circleRes)
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
