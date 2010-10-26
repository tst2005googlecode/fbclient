
package.path = '../../lua/?.lua;'..package.path

local dump = require 'fbclient.util'.dump
local index = require 'fbclient.ds.index'
local tuple = require 'fbclient.ds.tuple'.new

local idx = index()
local NaN = 0/0

for i,e in ipairs {
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
} do
	idx[e] = e
end

for e in idx:values() do
	print(e)
end

--[[
for k, e in idx:pairs() do
	print(e,k.n,unpack(k, 1, k.n))
end
]]
