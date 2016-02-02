# _GÖÖi_, an Android-Oriented GUI Library

GÖÖi (Good-sized Öptional Öpen interface) is an Android-oriented [LÖVE](https://love2d.org/) library which helps you to create GUI's, it has multitouch, multilingual and layout support. GÖÖi works in desktop computers as well.

This is the default GÖÖi look, using a _game_ layout:

![GÖÖi game layout](http://s22.postimg.org/854t5kv7l/game.gif)

Here's GÖÖi with a serious black theme, using a _grid_ layout:

![GÖÖi grid layout](http://s8.postimg.org/bt8vd9y4l/image.gif)

The code needed for the first image would be this: (omitting some things like the shot functions)

```lua
pGame = gooi.newPanel("panelGameLayout", 520, 10, 500, 400, "game")
pGame:add(gooi.newButton("btn_shot", "Shot", 0, 0, 80, 50):onRelease(function() shotBullet() end), "b-r")-- Bottom-right
pGame:add(gooi.newButton("btn_bomb", "Bomb", 0, 0, 80, 50):onRelease(function() shotBomb() end), "b-r")-- Bottom-right
pGame:add(gooi.newJoy("joy_1"), "b-l")-- Bottom-left
pGame:add(gooi.newLabel("lbl_score", "Score: 0"), "t-l")-- Top-left
pGame:add(gooi.newBar("bar_1"):setLength(pGame.w / 3):increase(1), "t-r")-- Top-right
pGame:add(gooi.newLabel("lbl_life", "Life:"), "t-r")-- Top-right
```

And for the _grid_ layout in the other image:

```lua
pGrid = gooi.newPanel("panelGrid", 10, 10, 500, 400, "grid 13x3")
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
		gooi.newButton(10, ""):setOrientation("left"):setImage(dirImgs.."coin.png"),
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

-- Add component in a given cell:
pGrid:add(gooi.newButton("btn_x", "Button in 9,2"), "9,2")
pGrid:add(gooi.newSlider("sli_x"), "10,1")
gooi.removeComponent("btn2")
```

Forum thread: https://love2d.org/forums/viewtopic.php?f=5&t=79751
