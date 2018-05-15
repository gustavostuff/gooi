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

    local x, y, w, h = gooi.checkBounds(
        params.text or defaultText,
        params.x or 10,
        params.y or 10,
        params.w or gooi.getFont():getWidth(params.text or defaultText) + theH * 2,
        params.h or theH * 2,
        "button"
    )
    
	local yLocal = params.yLocal or 0
    
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
            love.graphics.setColor(1, 1, 1)
            if not self.enabled then love.graphics.setColor(1/4, 1/4, 1/4) end
            love.graphics.draw(self.icon, xImg, math.floor(self.y + self.h / 2), 0, 1, 1,
                math.floor(self.icon:getWidth() / 2),
                math.floor(self.icon:getHeight() / 2))
        end
        love.graphics.setColor(fg)
    
    
    
        local yLine = yLocal + self.y + self.h / 2
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
