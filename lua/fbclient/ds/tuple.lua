--[[
	Trivial tuple implementation

	meta -> metatable for all tuples

	new(...) -> tuple
	wrap(t, [n]) -> tuple

	__eq
	__tostring

	TODO: more operators if useful

]]

local setmetatable, select, table, tostring =
	  setmetatable, select, table, tostring

module(...)

meta = {__type = 'tuple'}

function new(...)
	return wrap({n=select('#',...),...})
end

function wrap(t, n)
	t.n = n or t.n or #t
	setmetatable(t, meta)
	return t
end

local function naneq(x,y)
	return x == y or (x ~= x and y ~= y)
end

function meta:__eq(other)
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

function meta:__tostring()
	local t = {}
	for i=1,self.n do
		t[i] = tostring(self[i])
	end
	return '('..table.concat(t, ', ', 1, self.n)..')'
end

setmetatable(_M, {__call = function(t,...) return new(...) end})

