require "gooi"

function love.load()
  gr = love.graphics
  kb = love.keyboard
  mo = love.mouse

  gr.setBackgroundColor(0.5, 0.5, 0.5)

  function width() return gr.getWidth() end
  function height() return gr.getHeight() end

  imgDir = "/imgs/"
  fontDir = "/fonts/"

  style = {
    font = gr.newFont(fontDir.."Arimo-Bold.ttf", 13),
    showBorder = true,
    bgColor = {0.208, 0.220, 0.222}
  }
  gooi.setStyle(style)
  gooi.desktopMode()

  --gooi.shadow()
  --gooi.mode3d()
  --gooi.glass()

  gr.setDefaultFilter("nearest", "nearest")

  ship = {
    img = gr.newImage(imgDir.."ship.png"),
    x = 480,
    y = 200
  }

  bullets = {}
  imgBullet = gr.newImage(imgDir.."bullet.png")

  -----------------------------------------------
  -----------------------------------------------
  -- Free elements with no layout:
  -----------------------------------------------
  -----------------------------------------------

  lbl1 = gooi.newLabel({x = 30, text = "Free elements (no layout):"})
  lbl2 = gooi.newLabel({text = "0", x = 10, y = 40, w = 90, h = 22}):center()
  btn1 = gooi.newButton({text = "Exit with tooltip", x = 110, y = 40, w = 180, h = 22})
    :setIcon(imgDir.."coin.png"):danger()
    :setTooltip("This is a tooltip!")
    :onRelease(function()
      gooi.confirm({
        text = "Are you sure?",
        ok = function()
          quit()
        end
      })
    end)
  sli1 = gooi.newSlider({x = 10, w = 90, h = 22, y = 70, value = 0.2})
  spin1 = gooi.newSpinner(
    {
      min = -10,
      max = 50,
      value = 33,
      x = 110,
      y = 70,
      w = 180,
      h = 22
    }
  )

  chb1 = gooi.newCheck({text = "A Check Box", x = 10, y = 200, w = 180, h = 32, checked = true})

  -- Radio group:
  rad1 = gooi.newRadio(
    {y = 100, h = 22, w = 80, text = "one", radioGroup = "g1", selected = true}
  )

  rad2 = gooi.newRadio({y = 130, h = 22, w = 80, text = "two", radioGroup = "g1"})
  rad3 = gooi.newRadio({y = 160, h = 22, w = 80, text = "three", radioGroup = "g1"})
  knob1 = gooi.newKnob({x = 110, y = 100, value = 0.75, size = 82})

  -- Anoher radio group:
  rad4 = gooi.newRadio(
    {y = 100, x = 200, w = 80, h = 22,  text = "Apr", radioGroup = "g2", selected = true}
  )
  rad5 = gooi.newRadio(
    {y = 130, x = 200, w = 80, h = 22,  text = "May", radioGroup = "g2"}
  ):setBGImage("imgs/testBgComp.png"):fg({1, 0, 0})

  rad6 = gooi.newRadio(
    {y = 160, x = 200, w = 80, h = 22,  text = "Jun", radioGroup = "g2"}
  )

  txt1 = gooi.newText({y = 270, w = 180, h = 22}):setText("A text field")
  bar1 = gooi.newBar({y = 240, w = 180, h = 22, value = 0}):increaseAt(0.1)
  joy1 = gooi.newJoy({x = 120, y = 420, size = 150}):
    setImage(imgDir.."cat.png"):noSpring():noGlass():opacity(0.7)
  vertSlider =  gooi.newSlider(
    {x = 200, y = 200, w = 22, h = 90, value = 0}):vertical()
  vertSlider2 = gooi.newSlider(
    {x = 230, y = 200, w = 22, h = 90, value = 0.5}):vertical()
  vertSlider3 = gooi.newSlider(
    {x = 260, y = 200, w = 22, h = 90, value = 1}):vertical()

  -----------------------------------------------
  -----------------------------------------------
  -- Game layout:
  -----------------------------------------------
  -----------------------------------------------

  joyShip = gooi.newJoy({size = 60}):setStyle({showBorder = true})
  joyShipDigital = gooi.newJoy({size = 60}):setDigital():setImage(imgDir.."cat.png")
  btnShot = gooi.newButton({text = "Shot"}):onRelease(function()
    table.insert(bullets, {
      x = ship.x,
      y = ship.y
    })
  end)

  pGame = gooi.newPanel({x = 350, y = 10, w = 420, h = 270, layout = "game"})
  pGame:add(gooi.newButton({text = "<= shot"}), "b-r")
  pGame:add(btnShot, "b-r")
  pGame:add(joyShip, "b-l")
  pGame:add(joyShipDigital, "b-l")
  pGame:add(gooi.newLabel({w = 180, text = "(Game Layout demo)"}):left(), "t-l")
  pGame:add(gooi.newLabel({text = "Score: 702013"}):left(), "t-l")
  pGame:add(gooi.newBar({value = 1, w = 100})
  :decreaseAt(0.1), "t-r"):fg("#FFFFFF")

  -----------------------------------------------
  -----------------------------------------------
  -- Grid layout:
  -----------------------------------------------
  -----------------------------------------------

  pGrid = gooi.newPanel({x = 350, y = 290, w = 420, h = 290, layout = "grid 10x3"})

  -- Add in the specified cell:
  pGrid:add(gooi.newRadio({text = "Radio 1", selected = true}):setRadius(10, 8), "7,1")
  pGrid:add(gooi.newRadio({text = "Radio 2"}):setRadius(0):fg("#00ff00"), "8,1")
  pGrid:add(gooi.newRadio():setRadius(0):border(1, "#000000"):secondary()
    :fg("#ff7700"), "9,1")
  pGrid
    :setColspan(1, 1, 3)-- Row, column and span size
    :setRowspan(6, 3, 2)
    :setColspan(8, 2, 2)
    :setRowspan(8, 2, 3)
    :add(
      gooi.newLabel({text = "(Grid Layout demo)"}):center(),
      gooi.newLabel({text = "Left label"}):left(),
      gooi.newLabel():center(),
      gooi.newLabel({text = "Right"}):right(),
      gooi.newButton({text = "Left button"}):left():success(),
      gooi.newButton({text = "Centered"}):info(),
      gooi.newButton():right():warning(),
      gooi.newLabel({text = "Left label", icon = imgDir.."coin.png"}):left(),
      gooi.newLabel({text = "Centered", icon = imgDir.."coin.png"}):center(),
      gooi.newLabel({text = "Right", icon = imgDir.."coin.png"}):right(),
      gooi.newButton({text = "Left button", icon = imgDir.."medal.png"}):left():danger(),
      gooi.newButton({text = "Alert btn", icon = imgDir.."medal.png"}):center():secondary()
      :onRelease(function()
        gr.setBackgroundColor(randomColor())
        gooi.alert({text = "The background has changed!\ndeal with it!"})
      end):inverted(),
      gooi.newButton({text = "Confirm btn", icon = imgDir.."medal.png"}):right():secondary()
      :onRelease(function()
        gooi.confirm({
          text = "Change background?\nare you sure?\nREALLY!?",
          ok = function()
            gr.setBackgroundColor(randomColor())
          end,
          cancel = function()
            gooi.alert({text = "you chose Nope"})
          end,
          okText = "Yeah",
          cancelText = "Nope"
        })
      end),
      gooi.newSlider():border(3, "#00ff00"):fg({1, 1, 0}):danger(),
      gooi.newCheck({text = "Debug"})
        :setRadius(12, 10):bg(component.colors.orange)
        :fg("#00ffff"):border(1, "#ffff00")
        :onRelease(function(c)
          pGrid.layout.debug = not pGrid.layout.debug
        end),
      gooi.newBar({value = 0}):setRadius(0, 20):fg(component.colors.orange)
        :increaseAt(0.05),
      gooi.newSpinner():setRadius(0, 0),
      gooi.newLabel({text = "This is a\nmultiline\nlabel\ncentered"}):center(),
      gooi.newKnob()
  )

  -- Salute:
  lblCoords = gooi.newLabel({text = "", x = 30, y = 330, w = 300, h = 30}):left()
  gooi.newLabel({text = "This is a demonstration of the different\n"..
    "components, styles and layouts supported", x = 30, y = 360}):left()

  --gooi.removeComponent(pGrid)
end

function love.update(dt)
  gooi.update(dt)
  lbl2:setText(sli1:getValue())

  -- Move itself:
  joy1.x = (joy1.x + joy1:xValue() * dt * 200)
  joy1.y = (joy1.y + joy1:yValue() * dt * 200)

  -- move ship with analog joystick:
  ship.x = (ship.x + joyShip:xValue() * dt * 150)
  ship.y = (ship.y + joyShip:yValue() * dt * 150)
  if     kb.isDown("a") then ship.x = ship.x - dt * 150
  elseif kb.isDown("d") then ship.x = ship.x + dt * 150 end
  if     kb.isDown("w") then ship.y = ship.y - dt * 150
  elseif kb.isDown("s") then ship.y = ship.y + dt * 150 end
  
  -- with digital:
  local dir = joyShipDigital:direction()
  if dir:match("l") then
    ship.x = ship.x - dt * 150
  elseif dir:match("r") then
    ship.x = ship.x + dt * 150
  end

  if dir:match("t") then
    ship.y = ship.y - dt * 150
  elseif dir:match("b") then
    ship.y = ship.y + dt * 150
  end

  if ship.x > width() then ship.x = width() end
  if ship.x < 0 then ship.x = width() end

  -- Move bullets:
  for i = #bullets, 1, -1 do
    bullets[i].y = bullets[i].y - dt * 1400
    if bullets[i].y < -100 then
      table.remove(bullets, i)
    end
  end

  lblCoords:setText("coords: "..joy1:xValue()..", "..joy1:yValue())
  btnShot:setText(joyShipDigital:direction())
end

function love.draw()
  -- Bullets:
  for i = 1, #bullets do
    local b = bullets[i]
    gr.draw(imgBullet, b.x, b.y, 0, 4, 4,
      imgBullet:getWidth() / 2,
      imgBullet:getHeight() / 2)
  end

  gr.setColor(0, 0, 0, 0.5)
  gr.rectangle("line", pGame.x, pGame.y, pGame.w, pGame.h)
  gr.rectangle("line", pGrid.x, pGrid.y, pGrid.w, pGrid.h)

  gr.setColor(1, 1, 1)
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

function love.keypressed(key, scancode, isrepeat)
  gooi.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    quit()
  end
end

function love.keyreleased(key, scancode)
  gooi.keyreleased(key, scancode)
end

function quit()
  love.event.quit()
end

function randomColor()
  return love.math.random(0, 127) / 255,
         love.math.random(0, 127) / 255,
         love.math.random(0, 127) / 255
end
