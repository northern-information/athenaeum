-- k1: exit  e1: end
--
--      e2: end      e3: end
--
--    k2: reset    k3: reset
--
--
--  "splash study"

graphics, fn = {}, {}

function init()
  screen.aa(0)
  screen.font_face(0)
  screen.font_size(8)
  graphics.init()
  globals = {}
  globals.done = false
  globals.frame = 0
  globals.splash_break = false
  globals.screen_dirty = true
  globals.redraw_clock_id = clock.run(fn.redraw_clock)
  redraw()
end

function redraw()
  screen.clear()
  graphics:render()
  screen.update()
end

function cleanup()
  clock.cancel(globals.redraw_clock_id)
end

function enc(n, d)
  fn.break_splash(true)
  fn.dirty_screen(true)
end

function key(k, z)
  if z == 0 then return end
  if fn.break_splash() then
    fn.reset()
  else
    fn.break_splash(true)
    fn.dirty_screen(true)
  end
end

-- functions

function fn.redraw_clock()
  while true do
    fn.increment_frame()
    if fn.dirty_screen() then
      fn.dirty_screen(false)
      redraw()
    end
    clock.sleep(1/30)
  end
end

function fn.increment_frame()
  globals.frame = globals.frame + 1
end

function fn.break_splash(bool)
  if bool == nil then return globals.splash_break end
  globals.splash_break = bool
  return globals.splash_break
end

function fn.dirty_screen(bool)
  if bool == nil then return globals.screen_dirty end
  globals.screen_dirty = bool
  return globals.screen_dirty
end

function fn.reset()
  graphics.init()
  globals.frame = 0
  fn.break_splash(false)
  fn.dirty_screen(true)
end

-- graphics

function graphics.init()
  graphics.analysis_pixels = {}
  graphics.splash_lines_open = {}
  graphics.splash_lines_close = {}
  graphics.splash_lines_close_available = {}
  for i=1,45 do graphics.splash_lines_open[i] = i end
  for i=1,64 do graphics.splash_lines_close_available[i] = i end
end

function graphics:render()
  if fn.break_splash() then
    self:text_center(64, 32, "DONE", 15)
  else
    self:splash()
  end
end

function graphics:splash()
  local col_x = 34
  local row_x = 34
  local y = 45
  local l = globals.frame >= 49 and 0 or 15
  if globals.frame >= 49 then
    self:rect(0, 0, 128, 50, 15)
  end

  self:ni(col_x, row_x, y, l)

  if #self.splash_lines_open > 1 then 
    local delete = math.random(1, #self.splash_lines_open)
    table.remove(self.splash_lines_open, delete)
    for i = 1, #self.splash_lines_open do
      self:mlrs(1, self.splash_lines_open[i] + 4, 128, 1, 0)
    end
  end

  if globals.frame >= 49 then
    self:text_center(64, 60, "NORTHERN INFORMATION")
  end

  if globals.frame > 100 then
    if #self.splash_lines_close_available > 0 then 
      local add = math.random(1, #self.splash_lines_close_available)
      table.insert(self.splash_lines_close, self.splash_lines_close_available[add])
      table.remove(self.splash_lines_close_available, add)
    end
    for i = 1, #self.splash_lines_close do
      self:mlrs(1, self.splash_lines_close[i], 128, 1, 0)
    end
  end

  if #self.splash_lines_close_available == 0 then
    fn.break_splash(true)
  end

  fn.dirty_screen(true)

end

function graphics:ni(col_x, row_x, y, l)
  self:n_col(col_x, y, l)
  self:n_col(col_x+20, y, l)
  self:n_col(col_x+40, y, l)
  self:n_row_top(row_x, y, l)
  self:n_row_top(row_x+20, y, l)
  self:n_row_top(row_x+40, y, l)
  self:n_row_bottom(row_x+9, y+37, l)
  self:n_row_bottom(row_x+29, y+37, l)
end

function graphics:n_col(x, y, l)
  self:mls(x, y, x+12, y-40, l)
  self:mls(x+1, y, x+13, y-40, l)
  self:mls(x+2, y, x+14, y-40, l)
  self:mls(x+3, y, x+15, y-40, l)
  self:mls(x+4, y, x+16, y-40, l)
  self:mls(x+5, y, x+17, y-40, l)
end

function graphics:n_row_top(x, y, l)
  self:mls(x+20, y-39, x+28, y-39, l)
  self:mls(x+20, y-38, x+28, y-38, l)
  self:mls(x+19, y-37, x+27, y-37, l)
  self:mls(x+19, y-36, x+27, y-36, l)
end

function graphics:n_row_bottom(x, y, l)
  self:mls(x+21, y-40, x+29, y-40, l)
  self:mls(x+21, y-39, x+29, y-39, l)
  self:mls(x+20, y-38, x+28, y-38, l)
  self:mls(x+20, y-37, x+28, y-37, l)
end

-- graphics library

function graphics:text_center(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_center(s)
end

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

-- dev

function rerun()
  norns.script.load(norns.state.script)
end