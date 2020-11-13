-- see lib/graphics.lua
-- for the library

graphics = include("lib/graphics")

function init()
  redraw_clock_id = clock.run(redraw_clock)
  redraw()
end

function redraw_clock()
  while true do
    redraw()
    clock.sleep(1 / 2) -- 2 frames per second
  end
end

function redraw()
  -- erase
  screen.clear()
  -- relative line
  graphics:mlrs(math.random(0, 128), math.random(0, 64), math.random(0, 16), math.random(0, 6), math.random(0, 15))  
  -- aboslute line
  graphics:mls(math.random(0, 128), math.random(0, 64), math.random(0, 128), math.random(0, 64), math.random(0, 15))  
  -- rectangle
  graphics:rect(math.random(0, 128), math.random(0, 64), math.random(1, 20), math.random(1, 20), math.random(0, 15))
 -- circle
  graphics:circle(math.random(0, 128), math.random(0, 64), math.random(1, 20), math.random(0, 15))
  -- text
  graphics:text(math.random(0, 128), math.random(0, 64), "ATH", math.random(0, 15))
  graphics:text_right(math.random(0, 128), math.random(0, 64), "ENA", math.random(0, 15))
  graphics:text_center(math.random(0, 128), math.random(0, 64), "EUM", math.random(0, 15))
  -- update!
  screen.update()
end
