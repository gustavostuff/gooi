# _GOOi_, an Android-Oriented GUI Library

![GOOi logo](http://s16.postimg.org/4pvm3xvr9/logo.png)

GOOi (Good-sized Optional Open interface) is a simple Android-oriented [LÖVE](https://love2d.org/) library which helps you to create _cute_ GUI's, it has events support (pressing, releasing and movement events). GOOi works in desktop computers as well.

### GOOi has:

* Labels
* Buttons
* Sliders
* Checkboxes
* Radio buttons
* Text fields
* Progress bars
* Spinners
* Joysticks
* Panels (_new_)

### This is how you create a Button set an event to it:

´´´lua
gooi.newButton("btn_1", "The button"):onRealease(function()
  foo();
end);´´´
