![GOOi logo](http://s16.postimg.org/4pvm3xvr9/logo.png)

GOOi (Good-sized Optional Open interface) is a simple Android-oriented [LÖVE](https://love2d.org/) library which helps you to create _cute_ GUI's, it has events support (pressing, releasing and movement events). GOOi works in desktop computers as well, it currently features:

* Buttons
* Check boxes
* Joysticks
* Labels
* Progress bars
* Radio buttons
* Sliders
* Spinners
* Text fields
* Tooltips

### Examples

With this code you get a nice button which actually does something:

```lua
require "gooi"
function love.load()
	gooi.newButton("btn_1", "The button"):onPress(function()
		love.graphics.setBackgroundColor(0, 127, 0)
	end)
end
function love.draw()
	gooi.draw()
end
function love.mousepressed(button, x, y) gooi.pressed() end
function love.mousereleased(button, x, y) gooi.released() end
```
In the code above we're creating a button with the minimum required parameters, an ID and a label, bounds and other properties will be set by default. Just after creating the button, we set its _press_ event, sending a function. The result will be something like this:

![button image](http://s23.postimg.org/8q4x64zyz/Captura_de_pantalla_2015_08_12_21_40_32.png)

### More parameters

```lua
gooi.newButton("btn_nice", "A nice button!", 100, 150, 200, 40, "image.png", "niceButtonsGroup")
```

The above _builder_ will generate a button with the given bounds (x, y, w, and h), an image to the left of the label and it will be clasified in the "niceButtonsGroup" group, which means you'll need to draw it with `gooi.draw("niceButtonsGroup")` because `gooi.draw()` will only draw the components in the "default" group (which is set automatically).

Using this values and changing some of GOOi's default settings in component.lua you can easily make fancy components, like this (a button):

![button image](http://s10.postimg.org/ud0xk95ih/image.png)

The demo on this repository it's around 100 lines, and creates an event-rich and dynamic GUI, just play with it:

![button image](http://s23.postimg.org/dt6060hln/image.png)

***

**GOOi is still in development and if you find any issue (you will), suggestion or comment please feel free to tell me!**
