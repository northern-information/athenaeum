-- build your chain in my_chain()
--
-- encs: tempo
-- keys: play/stop
--
--
--
-- "markov study"

engine.name = "PolyPerc"
music_util = require("musicutil")
chain = {}

-- build your chain here:
function my_chain()
  table.insert(chain, {
    "a", -- id (unique identifier) for this link
    "b", -- id of the next link
    "c", -- id of the previous link
    440, -- hertz of this note
    25,  -- probability this note repeats
    50,  -- probability of moving to the next link
    25   -- probability of moving to the previous link
         -- this algorithm assumes the three probability values add up to 100
  })
  table.insert(chain, { "b", "a", "c", 493.88, 25, 50, 25 })
  table.insert(chain, { "c", "b", "d", 261.626, 25, 50, 25 })
  table.insert(chain, { "d", "a", "c", 293.665, 10, 80, 10 })
end

function init()
  my_chain()
  globals = {
    playback = false,
    playback_message = "",
    generation = 0,
    screen_dirty = true,
    current = chain[1]
  }
  music_clock_id = clock.run(music_clock)
  redraw_clock_id = clock.run(redraw_clock)
  redraw()
  toggle_playback()
end

function advance()
  local prob_repeat = globals.current[5]
  local prob_next = globals.current[6]
  local prob_previous = globals.current[7]
  -- i think this is one right way to do it?
  if math.random(0, 100) <= prob_repeat then
    -- do nothing, we are repeating the same note
  elseif math.random(0, 100) <= prob_next then
    -- set the next link
    globals.current = get_link_by_id(globals.current[2])
  else
    -- set the previous link
    globals.current = get_link_by_id(globals.current[3])
  end
  play(globals.current[4])
end

function get_link_by_id(id)
  local link = {}
  for k, v in pairs(chain) do
    if v[1] == id then
      link = v
    end
  end
  return link
end

function redraw()
  screen.clear()
  local x = 40
  screen.level(15)
  screen.rect(0, 0, x + 5, 64)
  screen.fill()
  screen.level(0)
  screen.move(x, 10)
  screen.text_right(globals.playback_message)
  screen.move(x, 20)
  screen.text_right(params:get("clock_tempo") .. " BPM")
  screen.move(x, 30)
  screen.text_right(globals.generation .. " GEN")
  screen.move(x, 40)
  screen.text_right(#chain .. " LINKS")
  screen.level(15)
  screen.move(x + 10, 10)
  screen.text("NOW >> " .. globals.current[1] .. " " .. globals.current[4] .. "hz")
  screen.move(x + 10, 20)
  screen.text("PROB > " .. globals.current[1] .. " " .. globals.current[5] .. "%")
  screen.move(x + 10, 30)
  screen.text("PROB > " .. globals.current[2] .. " " .. globals.current[6] .. "%")
  screen.move(x + 10, 40)
  screen.text("PROB > " .. globals.current[3] .. " " .. globals.current[7] .. "%")
  screen.update()
end

function music_clock()
  while true do
    clock.sync(1)
    if globals.playback then
      globals.generation = globals.generation + 1
      advance()
      globals.screen_dirty = true
    end
  end
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

function play(note)
  engine.amp(100)
  engine.hz(note)
end

function toggle_playback()
  globals.playback = not globals.playback
  globals.playback_message = globals.playback and "PLAYING" or "STOPPED"
end

function key(k, z)
  -- all three keys toggle playback
  if z == 1 then
    toggle_playback()
  end
  globals.screen_dirty = true
end

function enc(e, d)
  -- all three encs change tempo
  params:set("clock_tempo", params:get("clock_tempo") + d)
  globals.screen_dirty = true
end

function rerun()
  norns.script.load(norns.state.script)
end

function r()
  rerun()
end