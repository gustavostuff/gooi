require "gooi"
function love.load()
	gr = love.graphics
	ma = love.math
	function w() return gr.getWidth() end
	function h() return gr.getHeight() end

	dirFonts = "/fonts/"
	dirImgs = "/imgs/"

	imgBg1 = gr.newImage(dirImgs.."bg.png")
	-- Create styles:
	seriousBlack = {
		bgColor = {0, 0, 0, 127},
		fgColor = {255, 255, 255, 255},
		howRound = 0,
		showBorder = false,
		font = gr.newFont(dirFonts.."ProggySquare.ttf", 16)
	}
	roshita = {
		bgColor = "#AD00AD",
		fgColor = "#ffffff",
		howRound = 1,
		showBorder = true,
		borderColor = "#990044",
		font = gr.newFont(dirFonts.."Grundschrift-Bold.otf", 16)
	}

	-- Choose one of them:

	gooi.setStyle(seriousBlack)
	--gooi.setStyle(roshita)

	gooi.newPanel("thePanel", 10, 10, 500, 400, "grid 13x3")
		:setRowspan(6, 1, 2)-- rowspan for 'super check' checkbox.
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
			gooi.newButton(10, "Left Button"):setOrientation("left"):setImage(dirImgs.."coin.png"),
			gooi.newButton(11, "Center Button"):setImage(dirImgs.."coin.png"),
			gooi.newButton(12, "Right Button"):setOrientation("right"):setImage(dirImgs.."coin.png"),
			gooi.newSlider(13),
			gooi.newRadio(14, "Radio 1"):setRadioGroup("g1"):select(),
			gooi.newRadio(15, "Radio 2"):setRadioGroup("g1"),
			gooi.newCheck(16, "super check"),
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

		-- Add component in that row, col:
		gooi.get("thePanel"):add(gooi.newButton("btn_x", "Button in 9,2"), "9,2")
		gooi.get("thePanel"):add(gooi.newSlider("sli_x"), "10,1")


	-- Events:
	gooi.newCheck("chb_debug", "See grid layout", 600, 10):onRelease(function(c)
		gooi.get("thePanel").layout.debug = c.checked
		gooi.get("panel_child").layout.debug = c.checked
	end)
	gooi.get("thePanel").layout.debug = gooi.get("chb_debug").checked
	gooi.get("panel_child").layout.debug = gooi.get("chb_debug").checked

	gr.setFont(gooi.font)
end

function love.update(dt)
	gooi.update(dt)
	-- Fill in 10 seconds:
	--gooi.get(18):increase(.1, dt)
end

function love.draw()
	gr.draw(imgBg1, 0, 0)
	gooi.draw()

	gr.setColor(255, 255, 255)
	gr.print("FPS: "..love.timer.getFPS(), 0, love.graphics.getHeight() - gooi.font:getHeight())
end

-- Needed callbacks for this demo:
function love.textinput(key, code) gooi.textinput(key, code) end
function love.keypressed(key)      gooi.keypressed(key) if key == "escape" then love.event.quit() end end
function love.mousepressed(x, y, button)  gooi.pressed() end
function love.mousereleased(x, y, button) gooi.released() end