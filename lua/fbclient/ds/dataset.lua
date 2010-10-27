--[[
	Dataset abstraction

	Usage:
		dataset = require 'fbclient.dataset'
		DS = oo.class({ ... class fields ... }, dataset)
		ds = DS{ ... instance fields ... }
	Class fields:
		Indexing:
			keys = {KEY...}
		Master-detail:
			lookup_key = KEY
			master_key = KEY
			detail_key = key_name
			detail_index_keys = {DETAIL_INDEX_KEY,...}
		Foreign-keys:
			foreign_keys = {key_name = {LOOKUP_KEY, INDEX_KEY},...}
	Instance fields:
		Master-detail:
			master = MASTER_DATASET
		Foreign-keys:
			foreigns = {key_name = FOREIGN_DATASET}
	Methods:
		ds:set(row)
		ds:unset(row)
		ds:rows() -> iterator -> row
		ds:clear(key)
		ds:setmaster(master_dataset)
		ds:setforeign(key, foreign_dataset)

]]

local oo = require 'loop.base'
local rowindex = require 'fbclient.ds.rowindex'

local dataset = oo.class()

local function unpack_keys(keys)
	if type(keys) == 'table' then
		return unpack(keys)
	else
		return keys
	end
end

local function equal_keys(self, other)
	if type(self) == 'table' and type(other) == 'table' then
		if #self ~= #other then return false end
		for i=1,#self do
			if self[i] ~= other[i] then
				return false
			end
		end
		return true
	else
		return self == other
	end
end

function dataset:find_index(keys)
	for idx in pairs(self.indices) do
		if equal_keys(idx.keys, keys) then
			return idx
		end
	end
end

function dataset:__init(t)
	local self = oo.rawnew(self, t or {})
	self.keys = self.keys or {}
	self.foreigns = self.foreigns or {}

	self.indices = {}
	for i,keys in ipairs(self.keys) do
		self.indices[rowindex(unpack_keys(keys))] = true
	end

	for fk in pairs(self.foreigns) do
		assert(self.foreign_keys[fk])
	end

	return self
end

function dataset:index(e)
	for idx in pairs(self.indices) do
		idx:set(e)
	end
end

function dataset:unindex(e)
	for idx in pairs(self.indices) do
		idx:remove(e)
	end
end

function dataset:lookup(e, keys, lookup_keys)
	local idx = assert(self:find_index(keys))
	return idx:lookup(e, unpack_keys(lookup_keys))
end

function dataset:link(e, fk)
	if not fk then
		for fk in pairs(self.foreigns) do
			self:link(e, fk)
		end
	else
		local ds = self.foreigns[fk]
		local def = self.foreign_keys[fk]
		if ds then
			local ek, tk = unpack(def)
			e[fk] = ds:lookup(e, ek)
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

function dataset:rows()
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

