
local index = require 'index_class'
require('tuple').import()

local idx = index()
local NaN = 0/0

idx:index(tuple(1,NaN,3))
idx:index(tuple(1,NaN))
idx:index(tuple(1))
idx:index(tuple(1,3,NaN))
idx:index(tuple(1,nil,3))
idx:index(tuple(nil,nil))
idx:index(tuple(nil,NaN))
idx:index(tuple(nil))
idx:index(tuple(NaN))
idx:index(tuple())

for k, e in idx:pairs() do
	print(e,k.n,unpack(k, 1, k.n))
end

--assert(idx:lookup(tuple()) == tuple())

