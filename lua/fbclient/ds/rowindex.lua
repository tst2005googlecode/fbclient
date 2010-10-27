--[[
	Indexing tables by a fixed set of keys with optimization for one key

	(lookup_key1,...) -> idx

	idx:set(e)
	idx:lookup(lookup_e, [lookup_key1,...]) -> e
	idx:remove(lookup_e, [lookup_key1,...])
	idx:values() -> iterator -> e

	idx.index -> t

]]

local index = require 'fbclient.ds.index'

local setmetatable, select, assert, next =
	  setmetatable, select, assert, next

setfenv(1, {})

local class = {}
local meta = {__type = 'rowindex', __index = class}

local function const(name)
	return setmetatable({}, {__tostring = function() return name end})
end

local NIL = const'NIL'
local NAN = const'NAN'

local function tokey(k)
	return (k == nil and NIL) or (k ~= k and NAN) or k
end

local function extract(t, keys)
	local e = {n=#keys}
	for i=1,#keys do
		e[i] = t[keys[i]]
	end
	return e
end

local function new(...)
	local n = select('#',...)
	assert(n > 0)
	for i=1,n do assert(select(i,...) ~= nil) end --keys can't be nil
	for i=1,n do assert(select(i,...) ~= 0/0) end --keys can't be NaN
	local multikey = n > 1
	return setmetatable({
		multikey = multikey,
		index = multikey and index() or {},
		keys = multikey and {...} or (...),
	}, meta)
end

function class:set(e)
	if self.multikey then
		self.index[extract(e, self.keys)] = e
	else
		self.index[tokey(e[self.keys])] = e
	end
end

function class:lookup(e,...)
	local keys = (...) and (self.multikey and {...} or (...)) or self.keys
	if self.multikey then
		return self.index[extract(e, keys)]
	else
		return self.index[tokey(e[keys])]
	end
end

function class:remove(e,...)
	local keys = (...) and (self.multikey and {...} or (...)) or self.keys
	if self.multikey then
		self.index[extract(e, keys)] = nil
	else
		self.index[tokey(e[keys])] = nil
	end
end

function class:values()
	if self.multikey then
		return self.index:values()
	else
		local t,k,v = self.index
		return function()
			k,v = next(t,k)
			return v
		end
	end
end

return new


