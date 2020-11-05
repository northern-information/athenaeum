-- northern information
-- graphics library

graphics = {}

function graphics:mlrs(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line_rel(x2, y2)
  screen.stroke()
end

function graphics:mls(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line(x2, y2)
  screen.stroke()
end

function graphics:rect(x, y, w, h, l)
  screen.level(l or 15)
  screen.rect(x, y, w, h)
  screen.fill()
end

function graphics:circle(x, y, r, l)
  screen.level(l or 15)
  screen.circle(x, y, r)
  screen.fill()
end

function graphics:text(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text(s)
end

function graphics:text_right(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_right(s)
end

function graphics:text_center(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_center(s)
end

-- start athenaeum demo

function init()
  redraw_clock_id = clock.run(redraw_clock)
  redraw()
end

function redraw_clock()
  while true do
    redraw()
    clock.sleep(1 / 2)
  end
end

function redraw()
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

  screen.update()
end
