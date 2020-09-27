-- - draw scaled rings
-- - draw paginated rings
-- - wraping
-- - "snap" led aliasing
-- - variable min/max
-- - variable sensitivity
--
-- "arc study" @tyleretters

_arc = arc.connect()

function init()
  globals = {
    arc_dirty = true,
    screen_dirty = true,
    encs = {}
  }

  -- defaults
  for i = 1, 4 do
    globals.encs[i] = {
      value = 0,
      min = 0,
      max = 64,
      sensitivity = .25,
      wrap = false
    }
  end

  -- overrides
  globals.encs[1].min = 0
  globals.encs[1].max = 300
  globals.encs[1].sensitivity = 1
  globals.encs[2].wrap = true
  globals.encs[2].min = 50
  globals.encs[2].max = 100
  globals.encs[4].max = 127
  globals.encs[4].sensitivity = 1

  -- demo
  enc_1_items = 3
  enc_2_items = math.random(3, 20)
  
  arc_clock_id = clock.run(arc_redraw_clock)
  redraw_clock_id = clock.run(redraw_clock)
  redraw()
end



function draw_rings()
  -- ring 1
  local segs1 = divided_ring(globals.encs[1], 240, 240, enc_1_items, true)
  _arc:segment(1, segs1.from, segs1.to, 15)

  -- ring 2
  local segs2 = divided_ring(globals.encs[2], 360, 270, enc_2_items, false)
  _arc:segment(2, segs2.from, segs2.to, 15)

  -- ring 3
  local segs3 = scaled_ring(globals.encs[3], 360, 180, false)
  _arc:segment(3, segs3.from, segs3.to, 15)

  -- ring 4
  local segs4 = scaled_ring(globals.encs[4], 240, 240, true)
  _arc:segment(4, segs4.from, segs4.to, 15)

end


-- for creating a linear scale
-- enc      an enc table
-- max      [0-360] how much of the ring do you want to take up? 
-- offset   [0-360] where do you want the scale to start?
-- snap     [bool] do you want to snap to the arc leds?
function scaled_ring(enc, max, offset, snap)
  max = (max == 360) and 359.9 or max -- compensate for circles, 0 == 360, etc.
  local from = offset
  local to = cycle_degrees(util.linlin(0, 360, 0, max, scale_to_degrees(enc)) + offset)
  local segments = {}
  segments.from = degs_to_rads(from, snap)
  segments.to = degs_to_rads(to, snap)
  return segments
end

-- for creating a chunky linear pagination effect
-- enc      an enc table
-- max      [0-360] how much of the ring do you want to take up? 
-- offset   [0-360] where do you want the chunk to start?
-- divisor  [n] how many chunks do you want?
-- snap     [bool] do you want to snap to the arc leds?
function divided_ring(enc, max, offset, divisor, snap)
  local segment_size = max / divisor
  local segments = {}
  for i = 1, divisor do
    local from_raw = offset + (segment_size * (i - 1))
    local from = cycle_degrees(from_raw)
    local to =  cycle_degrees(from_raw + segment_size)
    segments[i] = {}
    segments[i].from = degs_to_rads(from, snap)
    segments[i].to = degs_to_rads(to, snap)
  end
  local current = map_to_segment(enc, divisor)
  return segments[current]
end

function map_to_segment(enc, divisor)
  local segment_size = 360 / divisor
  local test = util.linlin(enc.min, enc.max, 0, 360, enc.value)
  if test == 360 then -- compensate for circles, 0 == 360, etc.
    return divisor
  else
    local match = 1
    for i = 1, divisor do
        if (test >= segment_size * (i - 1)) and (test < segment_size * i) then
        match = i
      end
    end
    return match
  end
end

function arc_redraw_clock()
  while true do
    if globals.arc_dirty then
      _arc:all(0)
      draw_rings()
      _arc:refresh()
      globals.arc_dirty = false
    end
    clock.sleep(1/30)
  end
end

function scale_to_radians(enc)
  return degs_to_rads(scale_to_degrees(enc), false)
end

function scale_to_degrees(enc)
  return util.linlin(enc.min, enc.max, 0, 360, enc.value)
end

function degs_to_rads(d, snap)
    if snap then
      d = snap_degrees_to_leds(d)
    end
    return d * (3.14 / 180)
end

-- to stop arc anti-aliasing
function snap_degrees_to_leds(d)
  return util.linlin(0, 64, 0, 360, round(util.linlin(0, 360, 0, 64, d)))
end

function cycle_degrees(d)
  if d > 360 then
    return cycle_degrees(d - 360)
  elseif d < 0 then
    return cycle_degrees(360 - d)
  else
    return d
  end
end

function cycle(i, min, max)
  if i < min then
    return max
  elseif i > max then
    return min
  else
    return i
  end
end

function update_enc(n, delta)
  if globals.encs[n].wrap then
    globals.encs[n].value = util.clamp(
      cycle(
        globals.encs[n].value + (globals.encs[n].sensitivity * delta),
        globals.encs[n].min,
        globals.encs[n].max
      ),
      globals.encs[n].min,
      globals.encs[n].max
    )
  else
    globals.encs[n].value = util.clamp(
      globals.encs[n].value + (globals.encs[n].sensitivity * delta),
      globals.encs[n].min,
      globals.encs[n].max
    )
  end
  globals.screen_dirty = true
end

function round(f)
  return f > 0 and math.ceil(f) or math.floor(f)
end

function _arc.delta(n, delta)
  update_enc(n, delta)
  globals.arc_dirty = true
end

function redraw_clock()
  while true do
    if globals.screen_dirty then
      redraw()
      globals.screen_dirty = false
    end
    clock.sleep(1/30)
  end
end

function redraw()
  screen.clear()
  for i = 1, #globals.encs do
    local col = (i - 1) * 32
    screen.level(5)
    screen.move(col, 10)
    screen.text("ENC " .. i)
    screen.level(15)
    screen.move(col, 20)
    screen.text(globals.encs[i].value)
    screen.level(5)
    screen.move(col, 30)
    screen.text(globals.encs[i].min)
    screen.move(col, 40)
    screen.text(globals.encs[i].max)
    screen.move(col, 50)
    screen.text(globals.encs[i].sensitivity)
    screen.move(col, 60)
    if i == 1 then
      screen.text(map_to_segment(globals.encs[i], enc_1_items) .. "/" .. enc_1_items)
    elseif i == 2 then
      screen.text(map_to_segment(globals.encs[i], enc_2_items) .. "/" .. enc_2_items)
    end
    screen.update()
  end
end

function rerun()
  norns.script.load(norns.state.script)
end