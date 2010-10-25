--[[
	Indexing by tuple keys, OOP interface
	Keys with NaNs and nils allowed, provided you set keys.n or pass n as last parameter.

	idx = new()
	idx:index(keys, [e], [n])
	idx:lookup(keys, [n]) -> e
	idx:remove(keys, [n]) -> e

	idx:elements() -> iterator -> e
	idx:pairs() -> iterator -> keys, e

]]

local oo = require 'loop.base'
local idx = require 'index'

local index = oo.class()

function index:__init(t)
	self = oo.rawnew(self, t or {})
	self.t = idx.new()
	return self
end

function index:index(keys, e, n)
	return idx.index(self.t, keys, e, n)
end

function index:lookup(keys, n)
	return idx.lookup(self.t, keys, n)
end

function index:remove(keys, n)
	return idx.remove(self.t, keys, n)
end

function index:elements()
	return idx.elements(self.t)
end

function index:pairs()
	return idx.pairs(self.t)
end

return index

