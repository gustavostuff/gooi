# _GÖÖi_, an Android-Oriented GUI Library

GÖÖi (Good-sized Öptional Öpen interface) is an Android-oriented [LÖVE](https://love2d.org/) library which helps you to create GUI's, it has multitouch, multilingual and layout support. GÖÖi works in desktop computers as well.

[![License](http://img.shields.io/:license-MIT-blue.svg)](http://doge.mit-license.org)

### Examples:

This is how you create a button with an event:

```lua
require "gooi"
function love.load()
	gooi.newButton("Exit"):onRelease(function()
		love.event.quit()
	end)
end

function love.draw()
	gooi.draw()
end

function love.mousepressed(x, y, button)  gooi.pressed() end
function love.mousereleased(x, y, button) gooi.released() end

-- Use these for Android:
--[[
	function love.touchpressed(id, x, y)  gooi.pressed(id, x, y) end
	function love.touchreleased(id, x, y) gooi.released(id, x, y) end
]]
```

These are other ways of creating a button:

```lua
gooi.newButton()
gooi.newButton("A button")
gooi.newButton("A button", 100, 100)
gooi.newButton("A button", 100, 100, 150, 25)
gooi.newButton({
	text = "A button",
	x = 100,
	y = 100,
	w = 150,
	h = 25,
	orientation = "right",
	icon = "/imgs/icon.png"
})
```

### More Examples:

![free components](https://s31.postimg.org/5m9ak4gcr/free_elements.png)

Code:
```lua
lbl1 = gooi.newLabel("Free elements (no layout):", 10, 10)
lbl2 = gooi.newLabel("0", 10, 40, 100, 25):setOpaque(true):setOrientation("center")
btn1 = gooi.newButton("Exit with tooltip", 120, 40, 170, 25):setIcon(imgDir.."coin.png"):bg({255, 0, 0})
:setTooltip("This is a tooltip!")
:onRelease(function()
	quit()
end)
sli1 = gooi.newSlider({ x = 10, w = 100, h = 25, y = 70, value = 0.2})
spin1 = gooi.newSpinner({ min = -10, max = 50, value = 33, x = 120, y = 70, w = 170, h = 25})
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
joy1 = gooi.newJoy({ x = 120, y = 420, size = 150}):
```

![GÖÖi game layout](http://s32.postimg.org/yyy4cbbfp/the_game_layout.gif)

Code:
```lua
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
```

GÖÖi is highly customizable, it also has a "3D" mode and a "glossy" mode:

![GÖÖi grid layout](https://s31.postimg.org/or1zg4gtn/modes_gooi.png)

Code:
```lua
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
	gooi.newButton({text = "Left button", orientation = "left"}):bg("#ff8800"),
	gooi.newButton("Centered"):bg("#22aa22"),
	gooi.newButton({text = "Right", orientation = "right"}),
	gooi.newLabel({text = "Left label", orientation = "left", icon = imgDir.."coin.png"}),
	gooi.newLabel({text = "Centered", orientation = "center", icon = imgDir.."coin.png"}),
	gooi.newLabel({text = "Right", orientation = "right", icon = imgDir.."coin.png"}),
	gooi.newButton({text = "Left button", orientation = "left", icon = imgDir.."medal.png"}):bg("#888888"),
	gooi.newButton({text = "Alert btn", orientation = "center", icon = imgDir.."medal.png"})
	:bg("#880088"):onRelease(function()
		gr.setBackgroundColor(r2(), r2(), r2())
		gooi.alert("The background has changed!")
	end),
	gooi.newButton({text = "Confirm btn", orientation = "right", icon = imgDir.."medal.png"}):bg("#888800")
	:onRelease(function()
		gooi.confirm("Change background?", function()
			gr.setBackgroundColor(r2(), r2(), r2())
		end)
	end),
	gooi.newSlider({value = 0.75}):bg("#00000000"):border(3, "#00ff00"):fg({255, 0, 0}),
	gooi.newCheck("Debug"):roundness(1, 1):bg({127, 63, 0, 200}):fg("#00ffff"):border(1, "#ffff00")
	:onRelease(function(c)
		pGrid.layout.debug = not pGrid.layout.debug
	end),
	gooi.newBar(0):roundness(0, 1):bg("#77ff00"):fg("#8800ff"):increaseAt(0.05),
	gooi.newSpinner(-10, 30, 3):roundness(.7, .5):bg("#ff00ff"),
	gooi.newJoy():roundness(0):border(1, "#000000", "rough"):bg({0, 0, 0, 0}),
	gooi.newKnob(1)
)
```

There are modals too:

![GÖÖi grid layout](https://s32.postimg.org/qii4w8jb9/confirm.png)

Style used:
```lua
style = {
	font = gr.newFont(fontDir.."ProggySquare.ttf", 16),
	fgColor = "#FFFFFF",
	bgColor = "#226699f9",
    mode3d = true,
    glass = true,
    round = .18,
}
```

### Limitations:

* A panel can't be added inside another panel
* In text fields, the text can't be larger than the component width
* There's no automatic responsiveness (yet)

GÖÖi is still a work in progress, thanks for you feedback!

Forum thread: https://love2d.org/forums/viewtopic.php?f=5&t=79751
