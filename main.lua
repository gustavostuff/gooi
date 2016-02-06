require "gooi"

function love.load()
	gr = love.graphics
	kb = love.keyboard
	ma = love.math
	function w() return gr.getWidth() end
	function h() return gr.getHeight() end

	dirFonts = "/fonts/"
	dirImgs = "/imgs/"
	timerBomb = 0
	timerExplosion = 0

	imgBg1 = gr.newImage(dirImgs.."bg.png")
	-- Create styles:
	seriousBlack = {
		bgColor = {0, 0, 0, 127},
		fgColor = {255, 255, 255},
		howRound = 0,
		howRoundInternally = 0,
		font = gr.newFont(dirFonts.."ProggySquare.ttf", 16)
	}
	roshita = {
		bgColor = "#AD00AD",
		fgColor = "#ffffff",
		howRound = 1,
		howRoundInternally = 1,
		showBorder = true,
		borderColor = "#990044",
		font = gr.newFont(dirFonts.."Grundschrift-Bold.otf", 16)
	}

	-- Choose one of them:

	--gooi.setStyle(seriousBlack)
	--gooi.setStyle(roshita)

	-- Panel with grid layout:
	pGrid = gooi.newPanel("panelGrid", 10, 10, 500, 400, "grid 13x3")
		:setRowspan(6, 1, 2)-- rowspan for 'checkbox!' checkbox.
		:setColspan(6, 2, 2)-- colspan for the 'xxx' text field.
		:setRowspan(10, 1, 4)-- For the giant slider.
		:setColspan(10, 1, 3)-- For the giant slider.
		:add(
			gooi.newLabel(1, "Left Label"):setOrientation("left"),
			gooi.newLabel(2, "Center Label"):setOrientation("center"),
			gooi.newLabel(3, "Right Label"),
			gooi.newLabel(4, "Left Label"):setOrientation("left"):setImage(dirImgs.."h.png"),
			gooi.newLabel(5, "Center Label"):setOrientation("center"):setImage(dirImgs.."h.png"),
			gooi.newLabel(6, "Right Label"):setImage(dirImgs.."h.png"),
			gooi.newButton(7, "Left Button"):setOrientation("left"),
			gooi.newButton(8, "Center Button"),
			gooi.newButton(9, "Right Button"):setOrientation("right"),
			gooi.newButton(10, ""):setOrientation("left"):setImage(dirImgs.."coin.png"),
			gooi.newButton(11, "Center Button"):setImage(dirImgs.."coin.png"),
			gooi.newButton(12, "Right Button"):setOrientation("right"):setImage(dirImgs.."coin.png"),
			gooi.newSlider(13),
			gooi.newRadio(14, "Radio 1"):setRadioGroup("g1"):select(),
			gooi.newRadio(15, "Radio 2"):setRadioGroup("g1"),
			gooi.newCheck(16, "checkbox"),
			gooi.newText(17, "xxx"),
			gooi.newBar(18),
			gooi.newSpinner(19),
			gooi.newJoy(20),
			gooi.newPanel("panel_child"):add(
				gooi.newSlider("sli1"),
				gooi.newButton("btn2", "Btn"),
				gooi.newButton("btn3", "Btn")
			)
		)

		-- Add component in a given cell:
		pGrid:add(gooi.newButton("btn_x", "Button in 9,2"), "9,2")
		pGrid:add(gooi.newSlider("sli_x"), "10,1")
		gooi.removeComponent("btn2")



	-- Panel with Game layout:

	pGame = gooi.newPanel("panelGameLayout", 520, 10, 500, 400, "game")

	pGame:add(gooi.newButton("btn_shot", "Shot", 0, 0, 80, 50):onRelease(function() shotBullet() end), "b-r")-- Bottom-right
	pGame:add(gooi.newButton("btn_bomb", "Bomb", 0, 0, 80, 50):onRelease(function() shotBomb() end), "b-r")-- Bottom-right
	pGame:add(gooi.newJoy("joy_1"), "b-l")-- Bottom-left
	pGame:add(gooi.newLabel("lbl_score", "Score: 0"), "t-l")-- Top-left
	pGame:add(gooi.newBar("bar_1"):setLength(pGame.w / 3):increase(1), "t-r")-- Top-right
	pGame:add(gooi.newLabel("lbl_life", "Life:"), "t-r")-- Top-right

	-- Mini game in the game panel:

	imgShip = gr.newImage(dirImgs.."ship.png")
	imgBullet = gr.newImage(dirImgs.."bullet.png")
	imgBomb = gr.newImage(dirImgs.."bomb.png")
	imgBoom = gr.newImage(dirImgs.."boom.png")
	
	ship =
	{
		x = pGame.x + pGame.w / 2,
		y = pGame.y + pGame.h / 2
	}
	bullets = {}
	bomb = nil
	explosion = nil
	function shotBullet()
		table.insert(bullets,
			{
				x = ship.x,
				y = ship.y
			})
	end
	function shotBomb()
		if not bomb then
			bomb =
			{
				x = ship.x,
				y = ship.y - imgShip:getHeight()
			}
		end
	end

	-- Events:
	gooi.newCheck("chb_debug", "See grid layout", 10, 440):onRelease(function(c)
		pGrid.layout.debug = c.checked
		gooi.get("panel_child").layout.debug = c.checked
	end)
	pGrid.layout.debug = gooi.get("chb_debug").checked
	gooi.get("panel_child").layout.debug = gooi.get("chb_debug").checked
end

function love.update(dt)
	gooi.update(dt)
	-- Fill in 10 seconds:
	gooi.get(18):increase(.1, dt)
	
	-- Mini game:
	ship.x = ship.x + 300 * gooi.get("joy_1"):xValue() * dt
	ship.y = ship.y + 300 * gooi.get("joy_1"):yValue() * dt
	if ship.x + imgShip:getWidth() > pGame.x + pGame.w then
		ship.x = pGame.x + pGame.w - imgShip:getWidth()
	end
	if ship.x < pGame.x then ship.x = pGame.x end
	if ship.y + imgShip:getHeight() > pGame.y + pGame.h then
		ship.y = pGame.y + pGame.h - imgShip:getHeight()
	end
	if ship.y < pGame.y then ship.y = pGame.y end

	for i = #bullets, 1, -1 do
		bullets[i].y = bullets[i].y - 1000 * dt
		if bullets[i].y < 0 then table.remove(bullets, i) end
	end

	if bomb then
		bomb.y = bomb.y - 100 * dt
		timerBomb = timerBomb + dt
		if timerBomb >= 0.9 then
			timerBomb = 0
			explosion = 
			{
				x = bomb.x + imgBomb:getWidth() / 2,
				y = bomb.y + imgBomb:getHeight() / 2
			}
			bomb = nil
		end
	end
	if explosion then
		timerExplosion = timerExplosion + dt
		if timerExplosion > 0.8 then
			timerExplosion = 0
			explosion = nil
		end
	end
end

function love.draw()
	-- Draw panel shapes:--[[
	gr.draw(imgBg1, 0, 0)
	gr.setColor(0, 0, 0, 63)
	gr.rectangle("fill", pGrid.x, pGrid.y, pGrid.w, pGrid.h)
	gr.rectangle("fill", pGame.x, pGame.y, pGame.w, pGame.h)
	-- Draw mini game:
	gr.setColor(255, 255, 255)
	gr.draw(imgShip, ship.x, ship.y)
	for i = 1, #bullets do
		local b = bullets[i]
		gr.draw(imgBullet, b.x, b.y)
	end
	if bomb then gr.draw(imgBomb, bomb.x, bomb.y) end
	if explosion then
		gr.draw(imgBoom, explosion.x, explosion.y, 0,
			love.math.random(75, 100) / 25, love.math.random(75, 100) / 25,
			imgBoom:getWidth() / 2,
			imgBoom:getHeight() / 2)
	end

	gooi.draw()

	gr.setColor(255, 255, 255)
	gr.print("FPS: "..love.timer.getFPS(), 0, love.graphics.getHeight() - gooi.font:getHeight())
end

-- Needed callbacks for this demo:
function love.textinput(key, code) gooi.textinput(key, code) end
function love.keypressed(key)
	gooi.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end
function love.mousereleased(x, y, button) gooi.released() end
function love.mousepressed(x, y, button)  gooi.pressed() end
--[[
function love.touchpressed(id, x, y, pressure) gooi.pressed(id, x, y) end
function love.touchreleased(id, x, y, pressure) gooi.released(id, x, y) end
function love.touchmoved(id, x, y, pressure) gooi.moved(id, x, y) end

]]