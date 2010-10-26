
package.path = '../../lua/?.lua;'..package.path

local dump = require 'fbclient.util'.dump
local index = require 'fbclient.ds.index'
local tuple = require 'fbclient.ds.tuple'

local idx = index()
local NaN = 0/0

t1 = tuple(1,2,3,4)
t2 = tuple(1,2,3)
idx[t1] = t1
idx[t2] = t2
idx[t1] = nil
idx[t2] = nil
assert(next(idx.index) == nil)

local tuples = {
	tuple(1,NaN,3),
	tuple(1,NaN),
	tuple(1),
	tuple(1,3,NaN),
	tuple(1,nil,3),
	tuple(nil,nil),
	tuple(nil,NaN),
	tuple(nil),
	tuple(NaN),
	tuple(),
	tuple(2,3,4,5,6),
}

for i,e in ipairs(tuples) do
	idx[e] = e
end

for i,e in ipairs(tuples) do
	assert(idx[e] == e)
end

for e in idx:values() do
	print(e)
end

dump(idx.index)

for i,e in ipairs(tuples) do
	idx[e] = nil
end

assert(next(idx.index) == nil)

