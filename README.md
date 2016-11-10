# _GÖÖi_ - an Android-Oriented GUI Library

[![License](http://img.shields.io/:license-MIT-blue.svg)](http://doge.mit-license.org)

GÖÖi (Good-sized Öptional Öpen interface) is an Android-oriented [LÖVE](https://love2d.org/) library to create Graphical User Interfaces. The components supported are:

* Labels
* Buttons
* Sliders
* Checkboxes
* Text fields
* Radio Buttons
* Progress bars
* Joysticks
* Spinners
* Tooltips
* Knobs
* Panels
* Modals

Important stuff:

* Multitouch support
* Multilingual support
* Grid layout and Game layouts
* Works in desktop as well
* Flexible API
* Flexible shapes and colors
* Easy theme system

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
	function love.touchmoved(id, x, y)    gooi.moved(id, x, y) end
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

![free components](https://s32.postimg.org/q97lzfso5/ss3.png)

![GÖÖi game layout](http://s32.postimg.org/yyy4cbbfp/the_game_layout.gif)

GÖÖi is highly customizable, it has a 3D mode, a Glossy mode and a "Canvas" mode to work in virtual resolutions:

![GÖÖi grid layout](https://s13.postimg.org/qshh1ky2f/Sin_nombre.png)

There are modals too:

![GÖÖi grid layout](https://s32.postimg.org/qii4w8jb9/confirm.png)

This is the demo right now:

![GÖÖi demo](https://s32.postimg.org/y7q4nne8l/image.png)

Style used:
```lua
style = {
	font = gr.newFont(fontDir.."ProggySquare.ttf", 16),
	fgColor = "#FFFFFF",
	bgColor = "#25AAE1F0",
    mode3d = true,
    glass = true,
    round = .18,
}
```
The code for these examples is in the repository.

### Limitations:

* A panel can't be added inside another panel
* In text fields, the text can't be larger than the component width
* There's no automatic responsiveness (yet)

GÖÖi is still a work in progress, thanks for you feedback!

Forum thread: https://love2d.org/forums/viewtopic.php?f=5&t=79751
