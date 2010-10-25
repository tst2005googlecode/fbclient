--[[
	Trivial tuple implementation

	meta -> metatable for all tuples

	new(...) -> new tuple
	wrap(t, [n]) -> tuple(t)

	t1 == t2 test, where NaN == NaN

	Usage:
		require 'tuple'.import()
		t = tuple(1,2,3)
	or
		local tuple = require 'tuple'
		t = tuple.new(1,2,3)

	TODO: more operators if useful

]]

local meta = {__type = 'tuple'}

local wrap

local function new(...)
	return wrap({..., n=select('#',...)})
end

function wrap(t, n)
	t.n = n or t.n or #t
	setmetatable(t, meta)
	return t
end

local function naneq(x,y)
	return x == y or (x ~= x and y ~= y)
end

local function eq(self, other)
	if self.n ~= other.n then
		return false
	end
	for i=1,self.n do
		if not naneq(self[i], other[i]) then
			return false
		end
	end
	return true
end

meta.__eq = eq

local M

local function import(env)
	env = env or _G
	env.tuple = setmetatable({}, {__index = M, __call = function(t,...) return new(...) end})
end

M = {
	meta = meta,
	new = new,
	wrap = wrap,
	import = import,
}

return M

