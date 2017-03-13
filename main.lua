require "gooi"

function love.load()
	gr = love.graphics
	kb = love.keyboard
	mo = love.mouse

	gr.setBackgroundColor(0, 63, 127)

	function width() return gr.getWidth() end
	function height() return gr.getHeight() end

	imgDir = "/imgs/"
	fontDir = "/fonts/"
	style = {
		font = gr.newFont(fontDir.."ProggySquare.ttf", 16),
		fgColor = "#ffffff",
		bgColor = "#111111EE",
		mode3d = true,
		glass = true,
		radius = 3,
		innerRadius = 3
	}
	gooi.setStyle(style)
	gooi.desktopMode()

	gr.setDefaultFilter("nearest", "nearest")

	ship = {
		img = gr.newImage(imgDir.."ship.png"),
		x = 480,
		y = 200
	}

	bullets = {}
	imgBullet = gr.newImage(imgDir.."bullet.png")
	imgBg = gr.newImage(imgDir.."bg.png")

	-----------------------------------------------
	-----------------------------------------------
	-- Free elements with no layout:
	-----------------------------------------------
	-----------------------------------------------

	lbl1 = gooi.newLabel("Free elements (no layout):", 10, 10)
	lbl2 = gooi.newLabel("0", 10, 40, 90, 22):setAlign("center")
	btn1 = gooi.newButton("Exit with tooltip", 110, 40, 180, 22):setIcon(imgDir.."coin.png"):bg({255, 0, 0})
		:setTooltip("This is a tooltip!")
		:onRelease(function()
			gooi.confirm("Are you sure?", function()
				quit()
			end)
		end)
	sli1 = gooi.newSlider({x = 10, w = 90, h = 22, y = 70, value = 0.2})
	spin1 = gooi.newSpinner({min = -10, max = 50, value = 33, x = 110, y = 70, w = 180, h = 22})
	chb1 = gooi.newCheck({text = "A Check Box", x = 10, y = 200, w = 180, h = 22}):onRelease(function(c)
		if c.checked then
			gr.setBackgroundColor(127, 63, 0)
		else
			gr.setBackgroundColor(0, 63, 127)
		end
	end)
	-- Radio group:
	rad1 = gooi.newRadio({y = 100, h = 22, w = 80, text = "one", radioGroup = "g1", selected = true})
	rad2 = gooi.newRadio({y = 130, h = 22, w = 80, text = "two", radioGroup = "g1"})
	rad3 = gooi.newRadio({y = 160, h = 22, w = 80, text = "three", radioGroup = "g1"})
	knob1 = gooi.newKnob({x = 110, y = 100, value = 0.9, size = 82})
	-- Anoher radio group:
	rad4 = gooi.newRadio({y = 100, x = 200, w = 80, h = 22,  text = "Apr", radioGroup = "g2", selected = true})
	rad5 = gooi.newRadio({y = 130, x = 200, w = 80, h = 22,  text = "May", radioGroup = "g2"})
	rad6 = gooi.newRadio({y = 160, x = 200, w = 80, h = 22,  text = "Jun", radioGroup = "g2"})

	txt1 = gooi.newText({y = 260, w = 180, h = 22,  text = "text box"})
	bar1 = gooi.newBar({y = 230, w = 180, h = 22, value = 0}):increaseAt(0.1)
	joy1 = gooi.newJoy({x = 120, y = 420, size = 150}):
		setImage(imgDir.."cat.png"):noSpring():noGlass():bg("#ff880088")
	vertSlider =  gooi.newSlider({x = 200, y = 200, w = 25, h = 82, value = 0}):vertical()
	vertSlider2 = gooi.newSlider({x = 230, y = 200, w = 25, h = 82, value = 0.5}):vertical()
	vertSlider3 = gooi.newSlider({x = 260, y = 200, w = 25, h = 82, value = 1}):vertical()




	-----------------------------------------------
	-----------------------------------------------
	-- Game layout:
	-----------------------------------------------
	-----------------------------------------------

	joyShip = gooi.newJoy({size = 60})
	joyShipDigital = gooi.newJoy({size = 60}):setDigital("8")
		:bg("#FF0000EE"):setImage(imgDir.."cat.png")
	btnShot = gooi.newButton("Shot"):onRelease(function()
		table.insert(bullets, {
			x = ship.x,
			y = ship.y
		})
	end)

	pGame = gooi.newPanel(350, 10, 420, 270, "game")
	pGame:add(gooi.newButton("<- shot"), "b-r")
	pGame:add(btnShot, "b-r")
	pGame:add(joyShip, "b-l")
	pGame:add(joyShipDigital, "b-l")
	pGame:add(gooi.newLabel("(Game Layout demo)"), "t-l")
	pGame:add(gooi.newLabel("Score: 702013"), "t-l")
	pGame:add(gooi.newBar({value = 1, w = 100}):decreaseAt(0.1), "t-r"):fg("#FFFFFF")

	-----------------------------------------------
	-----------------------------------------------
	-- Grid layout:
	-----------------------------------------------
	-----------------------------------------------

	pGrid = gooi.newPanel(350, 290, 420, 290, "grid 10x3")
	-- Add in the specified cell:
	pGrid:add(gooi.newRadio({text = "Radio 1", selected = true}), "7,1")
	pGrid:add(gooi.newRadio({text = "Radio 2"}):setRadius(0):bg("#00000000"):fg("#00ff00"), "8,1")
	pGrid:add(gooi.newRadio({text = "Radio 3"}):setRadius(0):bg("#00000000"):border(1, "#000000"):fg("#ff7700"), "9,1")
	pGrid
	:setColspan(1, 1, 3)-- Row, column and span size
	:setRowspan(6, 3, 2)
	:setColspan(8, 2, 2)
	:setRowspan(8, 2, 3)
	:add(
		gooi.newLabel({text = "(Grid Layout demo)", align = "center"}),
		gooi.newLabel({text = "Left label", align = "left"}),
		gooi.newLabel({text = "Centered", align = "center"}),
		gooi.newLabel({text = "Right", align = "right"}),
		gooi.newButton({text = "Left button", align = "left"}):bg("#ff8800"),
		gooi.newButton("Centered"):bg("#22aa22"),
		gooi.newButton({text = "Right", align = "right"}),
		gooi.newLabel({text = "Left label", align = "left", icon = imgDir.."coin.png"}),
		gooi.newLabel({text = "Centered", align = "center", icon = imgDir.."coin.png"}),
		gooi.newLabel({text = "Right", align = "right", icon = imgDir.."coin.png"}),
		gooi.newButton({text = "Left button", align = "left", icon = imgDir.."medal.png"}):bg("#888888"),
		gooi.newButton({text = "Alert btn", align = "center", icon = imgDir.."medal.png"})
		:bg("#880088"):onRelease(function()
			gr.setBackgroundColor(r2(), r2(), r2())
			gooi.alert("The background has changed!")
		end),
		gooi.newButton({text = "Confirm btn", align = "right", icon = imgDir.."medal.png"}):bg("#888800")
		:onRelease(function()
			gooi.confirm({
				msg = "Change background?\nare you sure?",
				ok = function()
					gr.setBackgroundColor(r2(), r2(), r2())
				end,
				cancel = function()
					gooi.alert("you chose Nope")
				end,
				okText = "Yeah",
				cancelText = "Nope"
			})
		end),
		gooi.newSlider({value = 0.75}):bg("#00000000"):border(3, "#00ff00"):fg({255, 0, 0}),
		gooi.newCheck("Debug"):setRadius(12, 10):bg({127, 63, 0, 200}):fg("#00ffff"):border(1, "#ffff00")
		:onRelease(function(c)
			pGrid.layout.debug = not pGrid.layout.debug
		end),
		gooi.newBar(0):setRadius(0, 10):bg("#77ff00"):fg("#8800ff"):increaseAt(0.05),
		gooi.newSpinner(-10, 30, 3):setRadius(0, 0):bg("#ff00ff"),
		gooi.newLabel("This is a\nmultiline\nlabel centered"):setAlign("center"),
		gooi.newKnob(1)
	)

	-- Salute:
	lblCoords = gooi.newLabel("", 30, 330, 300, 30):setAlign("left")
	gooi.newLabel("This is a demonstration of the different\n"..
		"components, styles and layouts supported", 30, 360):setAlign("left")

	--gooi.removeComponent(pGrid)
end

function love.update(dt)
	gooi.update(dt)
	lbl2:setText(sli1:getValue())

	-- Move itself:
	joy1.x = (joy1.x + joy1:xValue() * dt * 200)
	joy1.y = (joy1.y + joy1:yValue() * dt * 200)

	-- move ship with analog joystick:
	ship.x = (ship.x + joyShip:xValue() * dt * 150)
	ship.y = (ship.y + joyShip:yValue() * dt * 150)
	-- with digital:
	local dir = joyShipDigital:direction()
	if dir:match("l") then
		ship.x = ship.x - dt * 150
	elseif dir:match("r") then
		ship.x = ship.x + dt * 150
	end

	if dir:match("t") then
		ship.y = ship.y - dt * 150
	elseif dir:match("b") then
		ship.y = ship.y + dt * 150
	end


	
	if ship.x > width() then ship.x = width() end
	if ship.x < 0 then ship.x = width() end

	-- Move bullets:
	for i = #bullets, 1, -1 do
		bullets[i].y = bullets[i].y - dt * 800
		if bullets[i].y < -100 then
			table.remove(bullets, i)
		end
	end

	lblCoords:setText("coords: "..joy1:xValue()..", "..joy1:yValue())

	btnShot:setText(joyShipDigital:direction())
end

function love.draw()
	-- Background:
	gr.draw(imgBg, 0, 0, 0, width() / imgBg:getWidth(), height() / imgBg:getHeight())
	-- Bullets:
	for i = 1, #bullets do
		local b = bullets[i]
		gr.draw(imgBullet, b.x, b.y, 0, 4, 4,
			imgBullet:getWidth() / 2,
			imgBullet:getHeight() / 2)
	end

	gr.setColor(0, 0, 0, 127)
	gr.rectangle("line", pGame.x, pGame.y, pGame.w, pGame.h)
	gr.rectangle("line", pGrid.x, pGrid.y, pGrid.w, pGrid.h)
	
	gr.setColor(255, 255, 255)
	gr.draw(ship.img, ship.x, ship.y, 0, 4, 4,
		ship.img:getWidth() / 2,
		ship.img:getHeight() / 2)

	gooi.draw()
	gr.print("FPS: "..love.timer.getFPS())
end

function love.mousereleased(x, y, button) gooi.released() end
function love.mousepressed(x, y, button)  gooi.pressed() end

function love.textinput(text)
	gooi.textinput(text)
end
function love.keypressed(key)
	gooi.keypressed(key)
	if key == "escape" then
		quit()
	end
end

function quit()
	love.event.quit()
end

function r() return love.math.random(0, 255) end
function r2() return love.math.random(0, 127) end