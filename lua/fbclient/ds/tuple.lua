--[=[
	Trivial n-tuple implementation
	Tuples containing NaN are only equal to themselves (the exact same instance).

	(...) -> tuple
	wrap(t, [n]) -> tuple

	tuple.n
	tuple[i] -> e_i

]=]

local setmetatable, select, table, tostring, assert, _unpack =
	  setmetatable, select, table, tostring, assert, unpack

setfenv(1, {})

local class = {}
local meta = {__type = 'tuple', __index = class}

local function new(...)
	return wrap({...}, select('#',...))
end

local function wrap(t, n)
	t.n = n or t.n or #t
	return setmetatable(t, meta)
end

function meta:__eq(other)
	if self.n ~= (other.n or #other) then
		return false
	end
	for i=1,self.n do
		if self[i] ~= other[i] then
			return false
		end
	end
	return true
end

function meta:__tostring()
	local t,n = {},self.n
	for i=1,n do
		t[i] = tostring(self[i])
	end
	return '('..table.concat(t, ', ', 1, n)..')'
end

local M = {
	meta = meta,
	class = class,
	wrap = wrap,
}

return setmetatable(M, {__call = function(_,...) return new(...) end})

