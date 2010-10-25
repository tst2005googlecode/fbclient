--[[
	Simple class to index table elements by one or more keys in O(n)
	Alternative implementation using just Lua hashes.

	Limtations:
	Key values must have unique, normalized string representations via tostring().

	idx = index{key1,...}
	idx:index(e)
	idx:lookup(e, [keys])
	idx:remove(e)
	idx:list() -> iterator -> e

]]

local oo = require 'loop.base'

index = oo.class()

local function hash(e, keys)
	local t = {}
	for i,k in ipairs(keys) do
		local v = tostring(e[k])
		t[i] = ('%x'):format(#v)
		t[#keys+i] = v
	end
	return table.concat(t,' ')
end

function index:__init(t)
	self = oo.rawnew(self, t or {})
	self:init(self.keys)
	return self
end

function index:init(keys)
	assert(#keys > 0)
	self.keys = keys
	self.elements = {}
end

function index:index(e)
	self.elements[hash(e, self.keys)] = e
end

function index:lookup(e, ekeys)
	return self.elements[hash(e, ekeys or self.keys)]
end

function index:remove(e)
	local s = hash(e, self.keys)
	if s then
		self.elements[s] = nil
	end
end

function index:list()
	local k,v
	return function()
		k,v = next(self.elements,k)
		return v
	end
end

if __UNITTESTING then
	local oo = require 'loop.simple'
	local IDX = oo.class({keys = {'t','f'}}, index)
	local idx = IDX()
	local act = {}
	for i,t in ipairs{'t1','t2'} do
		for j,f in ipairs{'f1','f2'} do
			local tt = {t=t,f=f}
			act[#act+1] = tt
			idx:index(tt)
		end
	end

	local k=1
	for i,t in ipairs{'t1','t2'} do
		for j,f in ipairs{'f1','f2'} do
			assert(idx:lookup({tt=t,ff=f}, {'tt','ff'}) == act[k])
			k=k+1
		end
	end
	assert(idx:lookup({tt = 't3', ff = 'f2'}, {'tt','ff'}) == nil)

	i=0
	for e in idx:list() do
		print(e.t, e.f); i=i+1
	end
	assert(i==4)

	idx:remove(idx:lookup({tt = 't1', ff = 'f1'}, {'tt','ff'}))
	assert(idx:lookup({tt = 't1', ff = 'f1'}, {'tt','ff'}) == nil)
	assert(idx:lookup({tt = 't1', ff = 'f2'}, {'tt','ff'}) == act[2])

	idx:remove(idx:lookup({tt = 't1', ff = 'f2'}, {'tt','ff'}))
	assert(idx:lookup({tt = 't1', ff = 'f2'}, {'tt','ff'}) == nil)
end

return index

