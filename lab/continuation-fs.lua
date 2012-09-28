local fs = lev.fs
p('hello')
local err1, fd1 = fs.open('AUTHORS', 'r', '0666')
p(err1, f1)
fs.close(fd1)
p(err1, f1)
