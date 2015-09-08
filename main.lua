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
		borderColor = "#7A147A",
		font = gr.newFont(dirFonts.."Grundschrift-Bold.otf", 16)
	}

	-- Choose one of them:

	gooi.setStyle(seriousBlack)
	--gooi.setStyle(roshita)

	gooi.newPanel("thePanel", w() / 2 - 250, h() / 2 - 150, 500, 300, "grid 10x3")
		:setRowspan(6, 1, 2)
		:setColspan(6, 2, 2)
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
			gooi.newCheck(16, "rowspan 2"),
			gooi.newText(17, "this text box has a colspan = 2"),
			gooi.newBar(18),
			gooi.newSpinner(19),
			gooi.newJoy(20),
			gooi.newPanel("panel_child"):add(
				gooi.newSlider("sli1"),
				gooi.newButton("btn2", "Btn"),
				gooi.newButton("btn3", "Btn")
			),
			gooi.newText(21, "this is editable"),
			gooi.newText(22, "this is editable"),
			gooi.newText(24, "this has a Tooltip"):setTooltip("A Tooltip")
		)


	-- Events:
	gooi.newCheck("chb_debug", "See grid layout"):onRelease(function(c)
		gooi.get("thePanel").layout.debug = c.checked
		gooi.get("panel_child").layout.debug = c.checked
	end)
	gooi.get("thePanel").layout.debug = gooi.get("chb_debug").checked
	gooi.get("panel_child").layout.debug = gooi.get("chb_debug").checked

	gr.setFont(seriousBlack.font)
end

function love.update(dt)
	gooi.update(dt)
	-- Fill in 10 seconds:
	gooi.get(18):increase(.1, dt)
end

function love.draw()
	gr.draw(imgBg1, 0, 0)
	gooi.draw()

	gr.setColor(255, 255, 255)
	gr.print("FPS: "..love.timer.getFPS(), 0, love.graphics.getHeight() - seriousBlack.font:getHeight())
end

-- Needed callbacks for this demo:
function love.textinput(key, code) gooi.textinput(key, code) end
function love.keypressed(key)      gooi.keypressed(key) if key == "escape" then love.event.quit() end end
function love.mousepressed(x, y, button)  gooi.pressed() end
function love.mousereleased(x, y, button) gooi.released() end