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
	gooiFont = gr.newFont(fontDir.."ProggySquare.ttf", 16)
	style = {
		font = gooiFont,
		fgColor = "#ffffff",
		bgColor = "#218AB8ee",
        mode3d = false
	}
	gooi.setStyle(style)
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
	lbl2 = gooi.newLabel("0", 10, 40, 100, 25):setOpaque(true):setOrientation("center")
	btn1 = gooi.newButton("Exit", 120, 40, 150, 25):setIcon(imgDir.."coin.png"):bg({255, 0, 0})
	:onRelease(function()
		quit()
	end)
	sli1 = gooi.newSlider({ x = 10, w = 100, h = 25, y = 70, value = 0.2})
	spin1 = gooi.newSpinner({ min = -10, max = 50, value = 33, x = 120, y = 70, w = 150, h = 25})
	chb1 = gooi.newCheck("This is a cool check box", 10, 200, 200):onRelease(function(c)
		if c.checked then
			gr.setBackgroundColor(127, 63, 0)
		else
			gr.setBackgroundColor(0, 63, 127)
		end
	end)
	-- Radio group:
	rad1 = gooi.newRadio({ y = 100, text = "one", radioGroup = "g1", selected = true})
	rad2 = gooi.newRadio({ y = 130, text = "two", radioGroup = "g1"})
	rad3 = gooi.newRadio({ y = 160, text = "three", radioGroup = "g1"})
	knob1 = gooi.newKnob({ x = 120, y = 110, value = 0.9, size = 60})
	-- Anoher radio group:
	rad4 = gooi.newRadio({ y = 100, x = 200, text = "Apr", radioGroup = "g2", selected = true})
	rad5 = gooi.newRadio({ y = 130, x = 200, text = "May", radioGroup = "g2"})
	rad6 = gooi.newRadio({ y = 160, x = 200, text = "Jun", radioGroup = "g2"})

	txt1 = gooi.newText({ y = 260, w = 200})
	bar1 = gooi.newBar({ y = 230, w = 200, value = 0}):increaseAt(0.1)
	joy1 = gooi.newJoy({ x = 120, y = 420, size = 150}):bg("#00000000"):setImage(imgDir.."joystick.png")




	-----------------------------------------------
	-----------------------------------------------
	-- Game layout:
	-----------------------------------------------
	-----------------------------------------------

	joyShip = gooi.newJoy({size = 60})
	btnShot = gooi.newButton("Shot"):onRelease(function()
		table.insert(bullets, {
			x = ship.x,
			y = ship.y
		})
	end)

	pGame = gooi.newPanel(350, 10, 420, 270, "game")
	pGame:add(gooi.newButton("Bomb"), "b-r")
	pGame:add(btnShot, "b-r")
	pGame:add(joyShip, "b-l")
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
	pGrid:add(gooi.newRadio({text = "Radio 2"}):roundness(0):bg("#00000000"):fg("#00ff00"), "8,1")
	pGrid:add(gooi.newRadio({text = "Radio 3"}):roundness(0):bg("#00000000"):border(1, "#000000"):fg("#ff7700"), "9,1")
	pGrid
	:setColspan(1, 1, 3)
	:setRowspan(6, 3, 2)
	:setColspan(8, 2, 2)
	:setRowspan(8, 2, 3)
	:add(
		gooi.newLabel({text = "(Grid Layout demo)", orientation = "center"}),
		gooi.newLabel({text = "Left label", orientation = "left"}),
		gooi.newLabel({text = "Centered", orientation = "center"}),
		gooi.newLabel({text = "Right", orientation = "right"}),
		gooi.newButton({text = "Left button", orientation = "left"}),
		gooi.newButton("Centered"),
		gooi.newButton({text = "Right", orientation = "right"}),
		gooi.newLabel({text = "Left label", orientation = "left", icon = imgDir.."coin.png"}),
		gooi.newLabel({text = "Centered", orientation = "center", icon = imgDir.."coin.png"}),
		gooi.newLabel({text = "Right", orientation = "right", icon = imgDir.."coin.png"}),
		gooi.newButton({text = "Left button", orientation = "left", icon = imgDir.."medal.png"}),
		gooi.newButton({text = "Centered", orientation = "center", icon = imgDir.."medal.png"}),
		gooi.newButton({text = "Right", orientation = "right", icon = imgDir.."medal.png"}),
		gooi.newSlider({value = 0.75}):bg("#00000000"):border(3, "#00ff00"):fg({255, 0, 0}),
		gooi.newCheck("Debug"):roundness(1, 1):bg({127, 63, 0, 200}):fg("#00ffff"):border(1, "#ffff00")
		:onRelease(function(c)
			pGrid.layout.debug = not pGrid.layout.debug
		end),
		gooi.newBar(0):roundness(0, 1):bg("#77ff00"):fg("#8800ff"):increaseAt(0.05),
		gooi.newSpinner(-10, 30, 3):roundness(1, .8):bg("#ff00ff"),
		gooi.newJoy():roundness(0):border(1, "#000000", "rough"):bg({0, 0, 0, 0}),
		gooi.newKnob(0.2)
	)

	-- Salute:
	gooi.newLabel("This is a demonstration of the different\n"..
		"components, styles and layouts supported", 30, 400)

end

function love.update(dt)
	gooi.update(dt)
	lbl2:setText(string.sub(sli1:getValue(), 0, 4))

	chb1.x = math.floor(chb1.x + joy1:xValue() * dt * 200)
	chb1.y = math.floor(chb1.y + joy1:yValue() * dt * 200)

	ship.x = math.floor(ship.x + joyShip:xValue() * dt * 150)
	ship.y = math.floor(ship.y + joyShip:yValue() * dt * 150)
	
	if ship.x > width() then ship.x = width() end
	if ship.x < 0 then ship.x = width() end

	-- Move bullets:
	for i = #bullets, 1, -1 do
		bullets[i].y = bullets[i].y - dt * 800
		if bullets[i].y < -100 then
			table.remove(bullets, i)
		end
	end
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
--[[
]]

-- Android test:

--[[
require "gooi"

function love.load()
	gr = love.graphics

	ball = {
		x = 300,
		y = 300,
		color = {255, 255, 255},
		radius = 50
	}

	joy = gooi.newJoy({size = 200})
	panel = gooi.newPanel(0, 0, gr.getWidth(), gr.getHeight(), "game")
	panel:add(joy, "b-l")
	panel:add(gooi.newButton({text = "Color", w = 220, h = 70}):onRelease(function()
		ball.color = {r(), r(), r()}
	end), "b-r")
	panel:add(gooi.newButton({text = "Size", w = 220, h = 70}):onRelease(function()
		ball.radius = r() / 2
	end), "b-r")
end

function love.update(dt)
	gooi.update(dt)
	ball.x = ball.x + joy:xValue() * 200 * dt
	ball.y = ball.y + joy:yValue() * 200 * dt
end

function love.draw()
	gooi.draw()
	gr.setColor(ball.color)
	gr.circle("fill", ball.x, ball.y, ball.radius)
end

function r() return love.math.random(0, 255) end

function love.touchpressed(id, x, y)  gooi.pressed(id, x, y) end
function love.touchmoved(id, x, y)  gooi.moved(id, x, y) end
function love.touchreleased(id, x, y) gooi.released(id, x, y) end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end
]]