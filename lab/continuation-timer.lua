local timer = lev.timer

local t = timer.new()
p('create timer', t)
local start_time = lev.now()
local st = t:start(100)
local end_time = lev.now()
p('timer', t, ' start: st ->', st)
p('start_time', start_time, 'end_time', end_time, 'diff', end_time - start_time)
assert(end_time -start_time >= 100)
st = t:stop()
p('timer', t, ' stop: st ->', st)
t:close()
p('timer', t, 'close')
