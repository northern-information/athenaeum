-- k2 = refresh

local degrees = 0

function init()
  -- setup
  screen.aa(0)
  screen.font_face(0)
  screen.font_size(8)
  redraw()
end

function redraw()

  local center_x = 62
  local center_y = 32

  -- clear
  screen.clear()
  screen.level(15)
  screen.translate(0, 0)

  -- ui
  screen.move(1, 8)
  screen.text(degrees .. "*")

  -- save the screen state so we can reset the rotation
  screen.save()

  -- move the origin to the center of the screen
  screen.translate(center_x, center_y)

  -- rotation
  screen.rotate(degs_to_rads(degrees))

  draw_compass(50)

  -- translate the origin back
  screen.translate(-center_x, -center_y)

  -- update
  screen.update()

  -- restore the screen rotation
  screen.restore()
end

function key(k, z)
  if k == 2 and z == 0 then
    redraw()
  end
end

function degs_to_rads(degrees)
  return degrees * (math.pi / 180)
end

function cycle(value, min, max)
  if value > max then
    return min
  elseif value < min then
    return max
  else
    return value
  end
end

function draw_compass(line)
  screen.level(15)
  screen.circle(0, 0, math.floor((line - 13) / 2))
  screen.fill()
  screen.level(0)
  screen.circle(0, 0, math.floor((line - 15) / 2))
  screen.fill()
  -- horizontal line
  screen.level(15)
  screen.move(-line / 2, 0)
  screen.line_rel(line, 0)
  screen.stroke()
  -- vertical line
  screen.move(0, -line / 2)
  screen.line_rel(0, line)
  screen.stroke()
  -- arrow head
  screen.move(-2, (-line / 2) + 2)
  screen.line_rel(3, 0)
  screen.stroke()
  screen.move(-3, (-line / 2) + 3)
  screen.line_rel(5, 0)
  screen.stroke()
  screen.move(-4, (-line / 2) + 4)
  screen.line_rel(7, 0)
  screen.stroke()
  -- text
  screen.move(-3, (-line / 2) - 1)
  screen.text("N")
  screen.fill()
  screen.move((line / 2) + 1, 2)
  screen.text("E")
  screen.fill()
  screen.move(-3, (line / 2) + 6)
  screen.text("S")
  screen.fill()
  screen.move((-line / 2) - 6, 2)
  screen.text("W")
  screen.fill()
end

function enc(e, d)
  degrees = cycle(degrees + d, 0, 360)
  print(degrees)
  redraw()
end

-- dev
function rerun()
  norns.script.load(norns.state.script)
end