-- ^^

graphics = include("lib/graphics")
music_util = require("musicutil")


function init()
  globals = {
    screen_dirty = true,
    message = "",
    trigger_default = "TRIGGER",
    generation = 0,
    volts = 0,
    slew = 0,
    mode = 0,
    current_note = 0,
    next_note = 0,
    mode_names = {}
  }

  globals.mode_names[1] = "SLEW/VOLTS TEST"
  globals.mode_names[2] = "ENVELOPE TEST"
  globals.mode_names[3] = "II: JF TEST"

  music = {
    scale_notes = {},
    root = 59,
    scale_name = "Minor Pentatonic",
    octaves = 2,
    current_note = false,
  }
  crow.ii.pullup(true)
  crow.ii.jf.mode(1)
  music.scale_notes = music_util.generate_scale(music.root, music.scale_name, music.octaves)
  music_clock_id = clock.run(music_clock)
  redraw_clock_id = clock.run(redraw_clock)
  cycle_test()
  redraw()
end



-- music



function music_clock()
  while true do
    clock.sync( 1 / 30 )
    globals.generation = globals.generation + 1
    if globals.next_note <= globals.generation then
      if globals.mode == 1 then
        crow.output[1].volts = globals.volts
        crow.output[1].slew = globals.slew
        globals.next_note = globals.generation + 15
      elseif globals.mode == 2 then
        globals.current_note = get_random_note()
        crow.output[1].volts = (globals.current_note - 60) / 12
        crow.output[2].action = "{ to(8, 1), to(0, 1) }"
        crow.output[2].execute()
        globals.next_note = globals.generation + 124
      elseif globals.mode == 3 then
        globals.current_note = get_random_note()
        crow.ii.jf.play_note((globals.current_note - 60) / 12, 5)
        globals.next_note = globals.generation + 15
      end
    end
  end
end

function get_random_note()
  return music.scale_notes[math.random(1, #music.scale_notes)]
end

function cycle_test()
  globals.mode = cycle(globals.mode + 1, 1, #globals.mode_names)
  globals.message = globals.mode_names[globals.mode]
end



-- graphics


function redraw_clock()
  while true do
    redraw()
    clock.sleep(1/30)
  end
end

function redraw()
  graphics:setup()
  graphics:text_right(20, 10, "K1:", 15)
  graphics:text(25, 10, "EXIT", 15)
  graphics:text_right(20, 20, "K2:", 15)
  graphics:text(25, 20, globals.message, 15)
  if globals.mode == 1 then
    graphics:text_right(20, 40, "E2:", 15)
    graphics:text(25, 40, "SLEW " .. globals.slew, 15)
    graphics:text_right(20, 50, "E3:", 15)
    graphics:text(25, 50, "VOLTS " .. globals.volts, 15)
    graphics:text(25, 60, "OUT 1 = V/OCT", 15)
  elseif globals.mode == 2 then
    graphics:mls(0, 33, globals.next_note - globals.generation, 33, 15)
    graphics:text_right(20, 40, "NOTE:", 15)
    graphics:text(25, 40, music_util.note_num_to_name(tonumber(globals.current_note)), 15)
    graphics:text(25, 50, "OUT 1 = V/OCT", 15)
    graphics:text(25, 60, "OUT 2 = LEVEL", 15)
  elseif globals.mode == 3 then
    graphics:text_right(20, 40, "NOTE:", 15)
    graphics:text(25, 40, music_util.note_num_to_name(tonumber(globals.current_note)), 15)
    graphics:text(25, 50, "I2C BUS", 15)
  end
  graphics:teardown()
end



-- ui



function enc(e, d)
  if e == 1 then

  elseif e == 2 then
    globals.slew = util.clamp(globals.slew + d * 0.25, 0, 10)
  elseif e == 3 then
    globals.volts = util.clamp(globals.volts + d, -5, 10)
  end
  globals.screen_dirty = true
end

function key(k, z)
  if k == 2 and z == 1 then
    cycle_test()
  end
  globals.screen_dirty = true
end



-- misc



function cycle(value, min, max)
  if value > max then
    return min
  elseif value < min then
    return max
  else
    return value
  end
end

function rerun()
  norns.script.load(norns.state.script)
end