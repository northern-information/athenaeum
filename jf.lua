function init()
  crow.init()
  crow.clear()
  crow.reset()
  crow.ii.pullup(true)
  crow.ii.jf.mode(1)
end

function key(k, z)
  if k == 2 and z == 1 then
    crow.ii.jf.play_note((math.random(62, 80) - 60) / 12, 5)
  end
end
