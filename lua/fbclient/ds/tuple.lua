--[[
	Trivial n-tuple implementation
	Tuples containing NaN are only equal to themselves (the exact same instance).

	(...) -> tuple
	wrap(t, [n]) -> tuple			tuple.n = n or t.n or #t

	tuple.n
	tuple[1..n] -> e

	extract(t, keys) -> tuple of values in t corresponding to the given keys

]]

local setmetatable, select, table, tostring =
	  setmetatable, select, table, tostring

setfenv(1, {})

local class = {}
local meta = {__type = 'tuple', __index = class}

local function wrap(t, n)
	if n then t.n = n else assert(t.n) end
	setmetatable(t, meta)
	return t
end

local function new(...)
	return wrap({n = select('#',...),...})
end

function meta:__eq(other)
	if other.n and self.n ~= other.n then
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

local function extract(t, keys)
	local e,n = {},keys.n
	for i=1,n do
		e[i] = t[keys[i]]
	end
	return wrap(e,n)
end

local M = {
	meta = meta,
	class = class,
	wrap = wrap,
	new = new,
	extract = extract,
}

return setmetatable(M, {__call = function(_,...) return new(...) end})

