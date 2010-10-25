--[[
	Indexing by tuple keys (hash tree implementation)
	Keys with NaNs and nils allowed, provided you set t.n or pass n as last parameter.

	new() -> {}
	wrap(t) -> t

	index(t, keys, e, [n])
	lookup(t, keys, [n]) -> e
	remove(t, keys, [n]) -> e

	elements(t) -> iterator -> e
	pairs(t) -> iterator -> keys, e

]]

local print = print

local coroutine, pairs, next, select, setmetatable =
	  coroutine, pairs, next, select, setmetatable

module(...)

local function const(name)
	return setmetatable({}, {__tostring = function() return name end})
end

local NIL = const('NIL')
local NAN = const('NAN')
local ELEM = const('ELEM')

local function tokey(k)
	return (k == nil and NIL) or (k ~= k and NAN) or k
end

local function fromkey(k)
	return (k == NAN and 0/0) or (k ~= NIL and k) or nil
end

function new() return {} end
function wrap(t) return t end

function index(t, keys, e, n)
	n = n or keys.n or #keys
	e = e ~= nil and e or true
	for i=1,n do
		local k = tokey(keys[i])
		t[k] = t[k] or {}
		t = t[k]
	end
	t[ELEM] = e
end

function lookup(t, keys, n)
	n = n or keys.n or #keys
	for i=1,n do
		t = t[tokey(keys[i])]
		if not t then return end
	end
	return t[ELEM]
end

function remove(t, keys, n)
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

	function elements(t)
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

