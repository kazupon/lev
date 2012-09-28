local timer = lev.timer
local co = _coroutine

t1 = co.create(function ()
  local t = timer.new()
  p('create timer:', t)
  local st = t:start(100)
  p('timer', t, ' start: st ->', st)
  st = t:stop()
  p('timer', t, ' stop: st ->', st)
  t:close()
  p('timer', t, 'close')
  lev.exit()
end)

p('thread1 resume from main thread ...')
co.resume(t1)
p('... thread1 resume done')
