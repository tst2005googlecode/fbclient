--[[
	Indexing tables by a fixed set of keys with optimization for one key

	(...) -> new(...)
	new(key1,...) -> idx

	idx:set(e)
	idx:get(lookup_e, [lookup_key1,...]) -> e
	idx:remove(lookup_e, [lookup_key1,...]) -> e
	idx:values() -> iterator -> e

	idx.index -> t

]]

local index = require 'fbclient.ds.index'
local tuple = require 'fbclient.ds.tuple'

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

local extract = tuple.extract

local function new(...)
	local n = select('#',...)
	assert(n > 0)
	local multikey = n > 1
	return setmetatable({
		multikey = multikey,
		index = multikey and index() or {},
		key = multikey and tuple(...) or (...),
	}, meta)
end

function class:set(e)
	if self.multikey then
		self.index[extract(e, self.key)] = e
	else
		self.index[tokey(e[self.key])] = e
	end
end

function class:get(e, key)
	key = key or self.key
	if self.multikey then
		return self.index[extract(e, key)]
	else
		return self.index[tokey(e[key])]
	end
end

function class:remove(e, keys)
	keys = keys or self.keys
	if self.multikey then
		self.index[extract(e, key)] = nil
	else
		self.index[tokey(e[key])] = nil
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

