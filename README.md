# _GÖÖi_ ~ Android-Oriented GUI Library

[![License](http://img.shields.io/:license-MIT-blue.svg)](http://doge.mit-license.org)

GÖÖi (Good-sized Öptional Öpen interface) is an Android-oriented [LÖVE](https://love2d.org/) library to create Graphical User Interfaces. The supported components are:

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

Important things:

* [![touch_mini.png](https://s11.postimg.org/jyptsc1z7/touch_mini.png)](https://postimg.org/image/j971fz1fj/) Multitouch support
* [![multilang_mini.png](https://s17.postimg.org/gs69hvsdr/multilang_mini.png)](https://postimg.org/image/yi7y2x5yj/) Multilingual support
* [![canvas_mini.png](https://s22.postimg.org/mfctkzoy9/canvas_mini.png)](https://postimg.org/image/64cpoocgd/) Canvas support (virtual resolutions)
* [![grid_mini.png](https://s11.postimg.org/ndbg9r3k3/grid_mini.png)](https://postimg.org/image/rz7ki3p33/) Grid layout 
* [![game_mini.png](https://s13.postimg.org/4df2wj48n/game_mini.png)](https://postimg.org/image/kbnsmnygj/) Game layout
* [![desktop_mini.png](https://s15.postimg.org/7k03xbsiz/desktop_mini.png)](https://postimg.org/image/kbea3u2av/) Works in desktop as well
* [![api_mini.png](https://s11.postimg.org/qmudcpq83/api_mini.png)](https://postimg.org/image/99k2xuuwv/) Flexible API
* [![shapes_mini.png](https://s13.postimg.org/4oi73j13b/shapes_mini.png)](https://postimg.org/image/gqdkxoabn/) Flexible shapes and colors
* [![theme_mini.png](https://s3.postimg.org/3kob6oir7/theme_mini.png)](https://postimg.org/image/vkseqym7j/) Easy theme system

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

GÖÖi is highly customizable:

![GÖÖi grid layout](https://s13.postimg.org/qshh1ky2f/Sin_nombre.png)

Modals:

![GÖÖi grid layout](https://s32.postimg.org/qii4w8jb9/confirm.png)

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
