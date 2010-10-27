--[[
	Dataset abstraction

	Usage:
		dataset = require 'fbclient.dataset'
		DS = oo.class({ ... class fields ... }, dataset)
		ds = DS{ ... instance fields ... }
	Class fields:
		Indexing:
			keys = {KEY,...}
		Master-detail:
			lookup_key = LOOKUP_KEY
			master_key = MASTER_KEY
			detail_key = DETAIL_KEY
			detail_index_keys = {DETAIL_INDEX_KEY,...}
		Foreign-keys:
			foreign_keys = {FOREIGN_KEY = {LOOKUP_KEY, INDEX_KEY},...}
	Instance fields:
		Master-detail:
			master = MASTER_DATASET
		Foreign-keys:
			foreigns = {FOREIGN_KEY = FOREIGN_DATASET}
	Methods:
		ds:set(row)
		ds:unset(row)
		ds:list() -> iterator -> row
		ds:clear(key)
		ds:setmaster(master_dataset)
		ds:setforeign(key, foreign_dataset)

]]

local oo = require 'loop.base'
local rowindex = require 'fbclient.ds.rowindex'

local dataset = oo.class()

function dataset:__init(t)
	local self = oo.rawnew(self, t or {})

	for i,k in ipairs(self.keys) do
		self.indices[rowindex(unpack(k,1,k.n or #k))] = true
	end

	if self.foreigns then
		for fk in pairs(self.foreigns) do
			assert(self.foreign_keys[fk])
		end
	end

	assert(self.keys or self.master)
	if self.master then
		assert(self.master.by[self.master_key])
		assert(self.detail_key)
	end

	return self
end

function dataset:index(e)
	for idx in pairs(self.indices) do
		idx:index(e)
	end
end

function dataset:unindex(e)
	for idx in pairs(self.indices) do
		idx:remove(e)
	end
end

function dataset:lookup(e, key, lookup_key)
	return self.indices
end

function dataset:link(e, fk)
	if not fk then
		if self.foreigns then
			for fk in pairs(self.foreigns) do
				self:link(e, fk)
			end
		end
	else
		local t = self.foreigns[fk]
		local def = self.foreign_keys[fk]
		if t then
			local ek, tk = unpack(def)
			e[fk] = tk:lookup(e, ek)
		end
	end
end

function dataset:unlink(e, fk)
	if not fk then
		for kf in pairs(self.foreign_keys) do
			self:unlink(e, fk)
		end
	else
		unlink(e, fk)
	end
end

function dataset:route(e)
	if self.master then
		local fe = lookup(e, self.lookup_key, self.master.by, self.master_key)
		if fe then
			route(e, fe, self.detail_key, self.detail_index_keys or self.keys)
		end
	end
end

function dataset:unroute(e)
	if self.master then
		local fe = lookup(e, self.lookup_key, self.master.by, self.master_key)
		if fe then
			unroute(e, fe, self.detail_key, self.detail_index_keys or self.keys)
		end
	end
end

function dataset:set(e)
	self:index(e)
	self:route(e)
	self:link(e)
end

function dataset:unset(e)
	self:unlink(e)
	self:unroute(e)
	self:unindex(e)
end

function dataset:list()
	if self.keys then
		local t = self.by[next(self.keys)] --any key is as good as any
		local k,v
		return function()
			k,v = next(t,k)
			return v
		end
	elseif self.master then
		local miter = self.master:list()
		local diter
		return function()
			local de
			if diter then
				de = diter()
			else
				local me = miter()
				if me then
					diter = me[self.detail_key]:list()
					de = diter()
				end
			end
			return de
		end
	end
end

function dataset:setmaster(master)
	if self.master then
		for e in self:list() do self:unroute(e) end
	end
	self.master = master
	if master then
		for e in self:list() do self:route(e) end
	end
end

function dataset:setforeign(key, foreign)
	assert(self.foreign_keys[key])
	if self.foreigns and self.foreigns[key] then
		for e in self:list() do self:unlink(e, key) end
	end
	self.foreigns = self.foreigns or {}
	self.foreigns[key] = foreign
	if foreign then
		for e in self:list() do self:link(e, key) end
	end
end

function dataset:clear(key, value)
	for e in self:list() do
		if e[key] == value then
			self:unset(e)
		end
	end
end

if true then
	local oo = require 'loop.simple'
	local dump = require('util').dump
	FDS = oo.class({
		keys = {id = true, name = true},
	}, dataset)
	MDS = oo.class({
		keys = {id = true, name = true},
		foreign_keys = {f = {'f_id','id'}}
	}, dataset)
	DDS = oo.class({
		keys = {id = true, name = true},
		lookup_key = 'parent_name',
		master_key = 'name',
		detail_key = 'detail',
		detail_index_keys = {id = true, name = true},
	}, dataset)

	flist = FDS()
	mlist = MDS()
	dlist = DDS()

	mlist:set{id=1,name='X',f_id=2}
	mlist:set{id=2,name='Y',f_id=1}
	assert(mlist.by.id[1].name == 'X')
	assert(mlist.by.id[2].name == 'Y')
	assert(mlist.by.name.X.id == 1)
	assert(mlist.by.name.Y.id == 2)
	flist:set{id=1,name='A'}
	flist:set{id=2,name='B'}
	assert(mlist.by.id[1].f == nil)
	mlist:setforeign('f', flist)
	assert(mlist.by.id[1].f.id == 2)
	assert(mlist.by.id[2].f.id == 1)
	dlist:set{id=1,name='a',parent_name='X'}
	dlist:set{id=2,name='b',parent_name='X'}
	dlist:set{id=3,name='c',parent_name='Y'}
	dlist:set{id=4,name='d',parent_name='Y'}
	dlist:setmaster(mlist)
	assert(mlist.by.name.X.detail.name.a.id == 1)
	assert(mlist.by.name.X.detail.name.b.id == 2)
	assert(mlist.by.name.Y.detail.name.c.id == 3)
	assert(mlist.by.name.Y.detail.name.d.id == 4)
	dump(mlist)
	mlist:setforeign('f', nil)
	assert(mlist.by.id[1].f == nil)
	dlist:setmaster(nil)
	assert(next(mlist.by.name.X.detail.name) == nil)
	assert(dlist.by.name.d.id == 4)
end

return dataset


