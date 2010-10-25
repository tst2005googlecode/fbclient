--[[
	Simple class to index table elements by one or more keys in O(n)

	idx = index{key1,...}
	idx:index(e)
	idx:lookup(e, [keys])
	idx:remove(e)
	idx:list() -> iterator -> e

]]

local oo = require 'loop.base'

index = oo.class()

local NAN = {}

local function tokey(k)
	return k == k and k or NAN
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
	local t,n = self.elements, #self.keys
	for i=1,n do
		local k = e[tokey(self.keys[i])]
		t[k] = i == n and e or t[k] or {}
		t = t[k]
	end
end

function index:lookup(e, ekeys)
	ekeys = ekeys or self.keys
	assert(#ekeys == #self.keys)
	local t = self.elements
	for i=1,#ekeys do
		t = t[tokey(e[ekeys[i]])]
		if not t then return end
	end
	return t --the last t is the element itself
end

function index:remove(e)
	local t = self.elements
	local cleart, cleark
	for i=1,#self.keys do
		local k = e[tokey(self.keys[i])]
		local tt = t[k]
		if not tt then return end
		if i < #self.keys and next(tt,next(tt)) then
			cleart, cleark = nil,nil
		elseif not cleart then
			cleart, cleark = t,k
		end
		t = tt
	end
	cleart[cleark] = nil
end

local function walk(self,t,i,n)
	t = t or self.elements
	i = i or 1
	n = n or #self.keys
	if i < n then
		for k,t in pairs(t) do
			walk(self, t, i+1, n)
		end
	else
		for k,e in pairs(t) do
			coroutine.yield(e)
		end
	end
end

function index:list()
	return coroutine.wrap(walk), self
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
	assert(idx.elements.t1.f1 == nil)

	idx:remove(idx:lookup({tt = 't1', ff = 'f2'}, {'tt','ff'}))
	assert(idx:lookup({tt = 't1', ff = 'f2'}, {'tt','ff'}) == nil)
	assert(idx.elements.t1 == nil)
	assert(idx.elements.t2.f1 == act[3])
	assert(idx.elements.t2.f2 == act[4])

end

return index

