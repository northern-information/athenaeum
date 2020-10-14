-- k1: exit  e1: test
--
--      e2: test      e3: test
--
--    k2: none    k3: none
--
--
--  "enc wait study"

function init()
  globals = {}
  globals.message = {"e1 ready","e2 ready","e3 ready"}
  globals.counters = {}
  globals.waiting_indicator_max = 100 -- pixels
  globals.wait_length_in_seconds = .5
  for e = 1, 3 do fn.reset_counter(e) end
  globals.indicator = metro.init()
  globals.indicator.time = globals.wait_length_in_seconds / globals.waiting_indicator_max
  globals.indicator.count = -1
  globals.indicator.play = 1
  globals.indicator.event = fn.update_lengths
  globals.indicator:start()
  clock.run(fn.screen_redraw_clock)
  globals.screen_dirty = true
  redraw()
end

function enc(e,d)
  if globals.counters[e]["this_clock"] ~= nil then
    clock.cancel(globals.counters[e]["this_clock"])
    fn.reset_counter(e)
  end
  globals.message[e] = "turning: e" .. e
  globals.counters[e]["length"] = globals.waiting_indicator_max
  fn.dirty_screen(true)
  if globals.counters[e]["this_clock"] == nil then
    globals.counters[e]["this_clock"] = clock.run(fn.wait, e)
  end
end

function redraw()
  screen.clear()
  screen.level(15)  
  for i = 1, 3 do
    local y =  22 + (12 * i)
    screen.move(0, y)
    screen.text(globals.message[i])
    screen.move(0, y + 4)
    screen.line_rel(globals.counters[i]["length"], 0)
    screen.stroke()
  end
  screen.update()
end

-- functions

fn = {}

function  fn.screen_redraw_clock()
  while true do
    if fn.dirty_screen() then
      fn.dirty_screen(false)
      redraw()
    end
    clock.sleep(1/30)
  end
end

function fn.dirty_screen(bool)
  if bool == nil then return globals.screen_dirty end
  globals.screen_dirty = bool
  return globals.screen_dirty
end

function fn.reset_counter(e)
  globals.counters[e] = {
    this_clock = nil,
    length = 0,
    waiting = false
  }
end

function fn.update_lengths()
  for e = 1, 3 do
    if globals.counters[e]["waiting"] then
      globals.counters[e]["length"] = globals.counters[e]["length"] - 1
      fn.dirty_screen(true)
    end
  end
end

function fn.wait(e)
  globals.counters[e]["waiting"] = true
  clock.sleep(globals.wait_length_in_seconds)
  globals.counters[e]["waiting"] = false
  globals.counters[e]["this_clock"] = nil
  globals.message[e] = "stopped: e" .. e
  fn.dirty_screen(true)
end

-- dev
function rerun()
  norns.script.load(norns.state.script)
end
