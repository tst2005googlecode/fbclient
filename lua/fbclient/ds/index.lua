--[[
	Indexing values by tuple keys, implemented as a search tree
	Any array works as a key, even arrays with holes, provided keys.n is set
	or n is passed as parameter to get() and set().
	Interface is the same as for Lua tables.

	Procedural interface:
		set(t, keys, e, [n])
		get(t, keys, [n]) -> e

		pairs(t) -> iterator -> keys, e
		values(t) -> iterator -> e

	Objectual interface:
		() -> new()
		new() -> idx		use for both instantiation and derivation
		idx() -> new()

		idx[keys] = e		idx:set(keys, e, [n])
		idx[keys] -> e		idx:get(keys, [n]) -> e

		idx:pairs() -> iterator -> keys, e
		idx:values() -> iterator -> e

]]

local print = print

local coroutine, pairs, next, select, setmetatable =
	  coroutine, pairs, next, select, setmetatable

module(...)

local function const(name)
	return setmetatable({}, {__tostring = function() return name end})
end

local NIL = const'NIL'
local NAN = const'NAN'
local ELEM = const'ELEM'

local function tokey(k)
	return (k == nil and NIL) or (k ~= k and NAN) or k
end

local function fromkey(k)
	return (k == NAN and 0/0) or (k ~= NIL and k) or nil
end

local function add(t, keys, e, n)
	n = n or keys.n or #keys
	for i=1,n do
		local k = tokey(keys[i])
		t[k] = t[k] or {}
		t = t[k]
	end
	t[ELEM] = e
end

local function remove(t, keys, n)
	n = n or keys.n or #keys
	local cleart, cleark
	for i=1,n do
		local k = tokey(keys[i])
		local tt = t[k]
		if not tt then return end
		if i < n and next(tt,next(tt)) then
			cleart, cleark = nil,nil
		elseif not cleart then
			cleart, cleark = t,k
		end
		t = tt
	end
	cleart[cleark] = nil
end

function set(t, keys, e, n)
	if e ~= nil then
		add(t, keys, e, n)
	else
		remove(t, keys, n)
	end
end

function get(t, keys, n)
	print(t,keys,n)
	n = n or keys.n or #keys
	for i=1,n do
		t = t[tokey(keys[i])]
		if not t then return end
	end
	return t[ELEM]
end

do
	local function walk(t)
		for k,t in pairs(t) do
			if k == ELEM then
				coroutine.yield(t)
			else
				walk(t)
			end
		end
	end

	function values(t)
		return coroutine.wrap(walk), t
	end
end

do
	local function walk(t,...)
		for k,e in pairs(t) do
			if k == ELEM then
				coroutine.yield({...,n=select('#',...)},e)
			else
				--print('...',k)
				walk(e,fromkey(k),...)
			end
		end
	end

	function _M.pairs(t)
		return coroutine.wrap(walk), t
	end
end

function new()
	return setmetatable({}, meta)
end

meta = {
	__call = new,
	__index = get,
	__newindex = set,
}

setmetatable(_M, meta)

