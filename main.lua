require "gooi"
function love.load()
	-- Dimensions based on screen bounds for this demo.
	font = love.graphics.newFont("HussarPrintA.otf", love.graphics.getWidth() / 35)
	s = love.graphics.getWidth() / 320-- Scale.
	local r = love.math.random
	gooi.font = font-- Default font on the system.

	cat = {img = love.graphics.newImage("cat.png"), x = 100, y = 100, maxS = love.graphics.getWidth() / 4}

	-- Some components are created and get its event immediately:
	gooi.newButton("button3", "Image button", 10 * s, 10 * s, 90 * s, 15 * s, "Fabrizio.png"):onPress(function(c)
		for k, c in pairs(gooi.components) do
			c.fgColor = {r(0, 255), r(0, 255), r(0, 255)}
		end
	end)
	gooi.newButton("button1", "El botón español", 10 * s, 40 * s):onRelease(function(c)-- c = Component which triggers the event.
		for k, c in pairs(gooi.components) do
			c.bgColor = {r(0, 255), r(0, 255), r(0, 255)}
		end
	end)
	gooi.get("button1"):setToolTip("This is a tooltip")
	gooi.get("button3"):setToolTip("Another tooltip")
	gooi.newSlider("slider1", 10 * s, 70 * s)
	gooi.newCheckbox("chb1", "Show radios", 10 * s, 100 * s)
	gooi.newTextfield("text1", "dg45ÃдúñтвBć", 10 * s, 130 * s)-- Random unicode chars.

	gooi.newProgressBar("pb_1", 10 * s, 160 * s, 80 * s, 15 * s):onPress(function(c) gooi.get("pb_1"):decrease(.25) end)-- Remove 25% .
	gooi.newSpinner("spi1", 100 * s, 160 * s, 80 * s, 15 * s, 5, 0, 200, 2)
	gooi.newSlider("slider2", 190 * s, 160 * s, 80 * s, 15 * s, 1):onMoved(function(comp)
		for k, c in pairs(gooi.components) do
			c.radiusCorner = c.h / 2 * comp.value
			c:generateBorder()
		end
	end)
	gooi.newCheckbox("chbBorder", "", 270 * s, 70 * s):onRelease(function(c)
		for k, c in pairs(gooi.components) do
			c.showBorder = not c.showBorder
		end
	end)

	gooi.newCheckbox("chb2","Enable radios"):setBounds(130 * s, 10 * s)-- x, y, w and h (or less).
	gooi.newJoystick("joy1", 130 * s, 50 * s, love.graphics.getWidth() * .19, .25)-- With certain deadZone (percentaje).
	gooi.newJoystick("joy2", 200 * s, 50 * s, love.graphics.getWidth() * .19, 0).spring = false -- No spring on this one.

	gooi.newRadio("radio1", "Radio 1", 130 * s, 50 * s, 100 * s, 15 * s, true, "grpFont", "radios")
	gooi.newRadio("radio2", "Radio 2", 130 * s, 70 * s, 100 * s, 15 * s, false, "grpFont", "radios")
	gooi.newRadio("radio3", "Radio 3", 130 * s, 90 * s, 100 * s, 15 * s, false, "grpFont", "radios")

	gooi.newButton("button2", "выход", 270 * s, 10 * s, 45 * s, 45 * s):onRelease(function(c) love.event.quit() end)
	gooi.setGroupEnabled("radios", false)-- Change state.
	gooi.newLabel("label1", "This label is gonna change", 130 * s, 140 * s, 100 * s, 15 * s, "Fabrizio.png")-- Label.
	gooi.newLabel("lbl_j1", "0, 0", 130 * s, 115 * s)
	gooi.newLabel("lbl_j2", "0, 0", 200 * s, 115 * s)
end

function love.update(dt)
	gooi.update(dt)

	for k, c in pairs(gooi.components) do
		c.bgColor[4] = 255 * gooi.get("slider1").value
		c.radiusCorner = c.h / 2 * gooi.get("slider2").value
		c:generateBorder()
	end

	-- Set the other stuff:
	local flag = gooi.get("chb1").checked
	gooi.get("chb2"):setEnabled(flag)-- chb2 depends on chb1.
	local radios = gooi.getByGroup("radios")-- Get all radios (3 in this case).
	for i=1, #radios do radios[i]:setEnabled(gooi.get("chb2").checked) end-- Change their state.
	gooi.setGroupVisible("radios", flag)-- Change all "radios" group (instead of retrieve a table).
	gooi.get("pb_1"):increase(.1, dt)-- Progress bar, grows 10% every second.
	-- Hide or show joysticks:
	gooi.get("joy1"):setVisible(not flag)
	gooi.get("joy2"):setVisible(not flag)
	-- Labels for the joysticks:
	gooi.get("lbl_j1").label = gooi.get("joy1"):xValue()..", "..gooi.get("joy1"):yValue()
	gooi.get("lbl_j2").label = gooi.get("joy2"):xValue()..", "..gooi.get("joy2"):yValue()
	gooi.get("lbl_j1"):setVisible(not flag)
	gooi.get("lbl_j2"):setVisible(not flag)
	gooi.get("label1").label = "Label: "..string.upper(gooi.get("text1").text)
	-- Cat position:
	cat.x, cat.y = cat.x + cat.maxS * gooi.get("joy1"):xValue() * dt, cat.y + cat.maxS * gooi.get("joy1"):yValue() * dt
end

function love.draw()
	love.graphics.setColor(0, 200, 0)
	love.graphics.setFont(gooi.font)
	--love.graphics.print("FPS: "..love.timer.getFPS())
	-- Cat:
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(cat.img, cat.x, cat.y)
	------------
	gooi.draw()-- This draws the components with "default" as group.
	------------
	if gooi.get("chb1").checked then
		gooi.draw("radios")-- Draw this group.
	else
		gooi.draw("joysticks")-- Draw this group.
	end
end

-- Needed callbacks for this demo:
function love.textinput(key, code) gooi.textinput(key, code) end
function love.keypressed(key)      gooi.keypressed(key) end

function love.mousepressed(x, y, button)  gooi.pressed() end
function love.mousereleased(x, y, button) gooi.released() end

-- Android API:
function love.touchpressed(id, x, y, pressure)  gooi.pressed (id, x, y) end
function love.touchmoved(id, x, y, pressure)    gooi.moved   (id, x, y) end
function love.touchreleased(id, x, y, pressure) gooi.released(id, x, y) end