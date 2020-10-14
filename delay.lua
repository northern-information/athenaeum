-- k1: exit  e1: bpm
--
--      e2: delay    e3: decay
--
--    k2: play      k3: note
--
--
-- "delay study"

music_util = require("musicutil")
device = midi.connect(1)
params:add{ type = "number", id = "delay_time", name = "delay_time", min = 1, max = 16, default = 6 }
params:add{ type = "number", id = "delay_decay", name = "delay_decay", min = 1, max = 100, default = 42 }

function init()
  globals = {
    playback = false,
    generation = 0,
    numerator = 4,
    denominator = 16,
    screen_dirty = true,
    is_monophonic_midi_device = false,
    playback_message = "",
    trigger_default = "TRIGGER",
    id_counter = 0
  }

  music = {
    notes = {},
    scale_notes = {},
    root = 59,
    scale_name = "Minor Pentatonic",
    octaves = 2,
    current_note = false,
    default_note_velocity = 127,
    default_note_duration = 4
  }
  music.scale_notes = music_util.generate_scale(music.root, music.scale_name, music.octaves)

  music_clock_id = clock.run(music_clock)
  redraw_clock_id = clock.run(redraw_clock)

  redraw()
  toggle_playback()
end

-- sound

function music_clock()
  while true do
    clock.sync( 1 / globals.denominator)
    if globals.playback then
      globals.generation = globals.generation + 1
      advance()
      globals.screen_dirty = true
    end
  end
end

function advance()
  local generation = globals.generation
  for k, note in pairs(music.notes) do
    if note.note_type == "dry" then
      if note.duration == music.default_note_duration then
        register_delay(note)
      end
      note.duration = note.duration - 1
      if note.duration <= 0 then
        device:note_off(note.note)
        music.notes[note.id] = nil
      end
    elseif note.note_type == "wet" then
      if note.generation <= generation then
        note.note_type = "dry"
        play_note(note)
      end
    end
  end
end

function play_note(note)
  if globals.is_monophonic_midi_device then
    device:note_off(note.note)
    note.is_on = false
  end
  device:note_on(note.note, note.velocity)
  note.step_played = get_step()
  note.is_on = true
end

function get_step()
  return globals.generation % globals.denominator
end

function get_id()
  globals.id_counter = globals.id_counter + 1
  return globals.id_counter
end

function note_factory(note, note_type, velocity, generation, duration)
  return {
    id = get_id(),
    note = note,
    note_type = note_type,
    note_name = music_util.note_num_to_name(note),
    velocity = velocity,
    generation = generation,
    duration = duration,
    is_on = false,
    step_played = 0
  }
end

function register_note(note)
  music.notes[note.id] = note
end

function register_delay(note)
  -- send the note into the future based on the delay time
  local delay_generation = (math.floor(util.linlin(1, 16, 16, 1, params:get("delay_time"))) * globals.numerator) + note.generation
  -- decay the velocity of the future note. subtract an extra 1 to make sure it decays.
  local delay_velocity = note.velocity - math.floor(note.velocity * (params:get("delay_decay") / 100)) - 1
  if delay_velocity > 1 then -- 1 is an arbitrary threshold for silence
    local new_note = note_factory(note.note, "wet", delay_velocity, delay_generation, music.default_note_duration)
    register_note(new_note)
  end
end

function all_off()
  for note = 1, 127 do
    device:note_off(note)
  end
end

function get_random_note()
  return music.scale_notes[math.random(1, #music.scale_notes)]
end

function toggle_playback()
  globals.playback = not globals.playback
  globals.playback_message = globals.playback and "PLAYING" or "STOPPED"
  if not globals.playback then
    music.notes = {}
    all_off()
  end
end

function trigger()
  local note = note_factory(
    get_random_note(),
    "dry",
    music.default_note_velocity,
    globals.generation,
    music.default_note_duration
  )
  music.current_note = note.note_name
  register_note(note)
  play_note(note)
end

-- screen

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
  draw_metronome()
  draw_notes()
  local x = 40
  screen.level(15)
  screen.move(x, 10)
  screen.text_right(globals.playback_message)
  screen.level(5)
  screen.move(x + 5, 10)
  screen.text(device.name)
  screen.level(15)
  screen.move(x, 20)
  screen.text_right((music.current_note or globals.trigger_default))
  screen.move(x, 30)
  screen.text_right(params:get("clock_tempo") .. " BPM")
  screen.move(x, 40)
  screen.text_right(params:get("delay_time"))
  screen.move(x, 50)
  screen.text_right(params:get("delay_decay") .. "%")
  screen.level(5)
  screen.move(x, 60)
  screen.text_right(globals.generation)
  screen.update()
end

function draw_metronome()
  local x = 46
  local y = 26
  for i = 1, globals.denominator do
      screen.level((get_step() == i - 1) and 15 or 5)
      screen.rect(x + ((i-1) * 4), y, 1, 1)
      screen.stroke()
    if get_step() <= globals.denominator / globals.numerator then -- this is just to show the indicator for longer than a single tick
      screen.level(15)
      screen.rect(x-1, y-1, 3, 3)
      screen.stroke()
    end
  end
end

function draw_notes()
  local x = 46
  local y = 30
  for k, note in pairs(music.notes) do
    if note.is_on then
      local note_x = x + ((note.step_played) * globals.numerator)
      screen.level(math.floor(util.linlin(0, 127, 1, 15, note.velocity)))
      screen.move(note_x - 1, 20)
      screen.text(note.note_name)
      screen.rect(note_x, 30, 1, 30)
      screen.stroke()
    end
  end
end

-- ui

function enc(e, d)
  if e == 1 then
    params:set("clock_tempo", params:get("clock_tempo") + d)
  elseif e == 2 then
    params:set("delay_time", params:get("delay_time") + d)
  elseif e == 3 then
    params:set("delay_decay", params:get("delay_decay") + d)
  end
  globals.screen_dirty = true
end

function key(k, z)
  if k == 2 and z == 1 then
    toggle_playback()
  elseif k == 3 and z == 1 then
    trigger()
  end
  globals.screen_dirty = true
end

-- etc

function cleanup()
  all_off()
end

function rerun()
  norns.script.load(norns.state.script)
end