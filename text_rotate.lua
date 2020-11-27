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

  -- rotation
  screen.text_rotate(16, 32, "ashes", degrees)
  screen.text_rotate(44, 32, "to", degrees)
  screen.text_rotate(56, 32, "ashes", degrees)
  screen.text_center_rotate(74, 48, "dust", degrees - 90)
  screen.text_center_rotate(90, 48, "to", degrees - 90)
  screen.text_center_rotate(106, 48, "dust", degrees - 90)
  screen.fill()

  -- make sure it reset
  screen.move(1, 10)
  screen.line_rel(20, 0)
  screen.stroke()

  -- update
  screen.update()
end

function key(k, z)
  if k == 2 and z == 0 then
    redraw()
  end
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

function enc(e, d)
  degrees = cycle(degrees + d, 0, 360)
  redraw()
end

-- dev
function rerun()
  norns.script.load(norns.state.script)
end