-- k1: exit  e1: bpm
--
--      e2: bpm      e3: bpm
--
--    k2: start    k3: none
--
--
--  "ppqn"

function init()
  ppqn = 96
  micro_timer = ppqn
  micro_half_timer = ppqn * 2 -- allows tracks to be as slow as "half time"
  ppqn_grains = {}
  for i = 1, ppqn * 2 do
    ppqn_grains[i] = i / ppqn
  end
  dirty = true
  playback = true
  tracks = {}
  setup_tracks()
  tracker_clock_id = clock.run(tracker_clock)
end

function setup_tracks()
  for i = 1, 6 do
    tracks[i] = { 
      id = i,
      sync = 0,
      step = 1,
      length = 16,    -- interact via repl: tracks[1].length = 5
      enabled = true, -- interact via repl: tracks[1].enabled = false
      ppqn_table = {}
     }
  end
  -- snap the sync rates of each clock to a divisible value
  tracks[1].sync = snap_to_ppqn_grains(1)
  tracks[2].sync = snap_to_ppqn_grains(.5)
  tracks[3].sync = snap_to_ppqn_grains(.25)
  tracks[4].sync = snap_to_ppqn_grains(.125)
  tracks[5].sync = snap_to_ppqn_grains(.33)
  tracks[6].sync = snap_to_ppqn_grains(2)
  -- then build tables of matching values ahead of time
  for k, track in pairs(tracks) do
    track.ppqn_table = build_ppqn_table(track.sync)
  end
end

-- snap a value to to the grains of a the ppqn resolution
function snap_to_ppqn_grains(value)
  local nearest, index
  for i, grain in ipairs(ppqn_grains) do
    if not nearest or (math.abs(value - grain) < nearest) then
      nearest = math.abs(value - grain)
      index = i
    end
  end
  return ppqn_grains[index]
end

-- each track has a table of all grains in the resolution with boolean values
-- 1 = false
-- 2 = true
-- ...
-- 97 = false
-- 96 = true
function build_ppqn_table(sync)
  out = {}
  for i = 1, ppqn * 2 do
    local check = snap_to_ppqn_grains(i / ppqn) % sync
    out[i] = (check == 0 or (check <= .0000001)) -- account for 3rds, .999999, etc.
  end
  return out
end



function tracker_clock()
  while true do
    clock.sync(1 / ppqn)
    -- timers count down
    micro_timer = cycle(micro_timer - 1, 1, ppqn)
    micro_half_timer = cycle(micro_half_timer - 1, 1, ppqn * 2)
    if playback then
      for k, track in pairs(tracks) do
        if track.enabled and (track.ppqn_table[micro_timer] or track.ppqn_table[micro_half_timer]) then
          track.step = cycle(track.step + 1, 1, track.length)
        end
      end
    end
    if dirty then
      redraw()
    end
  end
end

function redraw()
  screen.clear()
  screen.font_size(8)
  screen.level(15)
  local y = 8
  for k, track in pairs(tracks) do
    screen.move(1, y)
    screen.level(15)
    screen.text("t" .. track.id .. ": " .. round(track.sync, 3))
    local x = 64
    for i = 1, track.length do
      if track.step == i then
        screen.level(15)
        screen.rect(x, y - 3, 3, 3, 15)
        screen.fill()
      end
      screen.level(1)
      screen.move(x, y)
      screen.line_rel(3, 0)
      screen.stroke()
      x = x + 4
    end
    y = y + 10
  end
  screen.update()
end

function key(n, z)
  if z == 0 then return end
  if n == 2 then playback = not playback end
  dirty = true
end

function enc(e, d)
  params:set("clock_tempo", params:get("clock_tempo") + d)
  dirty = true
end

function cycle(input, min, max)
  if input > max then return min
  elseif input < min then return max
  else return input end
end

function round(number, decimals)
  local mult = 10 ^ (decimals or 0)
  return math.floor(number * mult + 0.5) / mult
end

function rerun()
  norns.script.load(norns.state.script)
end