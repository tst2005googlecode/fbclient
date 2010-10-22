--[[
	Dataset abstraction

	Class fields:
		keys = {ID = true, NAME = true}
		lookup_key = 'PARENT_ID'
		master_key = 'ID'
		detail_key = 'children'
		foreign_keys = {parent = {'PARENT_ID', 'ID'}}
	Instance fields:
		master = master_object_list
		foreigns = {parent = parents}
		options = {system_flag = true}
		transaction = firebird_transaction

	Usage:
		DS = oo.class({ ... class fields ... }, dataset)
		ds = DS{ ... instance fields ... }

]]

local function newindex(keys)
	local t = {}
	for tk in pairs(keys) do
		t[tk] = {}
	end
	return t
end

local function index(e, t, keys)
	for k in pairs(keys) do
		t[k][e[k]] = e
	end
end

local function unindex(e, t, keys)
	for k in pairs(keys) do
		t[k][e[k]] = nil
	end
end

local function getfe(e, ek, t, tk) --get a foreign element from an index
	return t[tk][e[ek]]
end

local function link(e, ek, t, tk, fk) --link to a foreign element
	e[fk] = getfe(e, ek, t, tk) or e[fk]
end

local function unlink(e, fk)
	e[fk] = nil
end

local function route(e, fe, dk, dkeys) --index an element in a child index in a parent element
	local dt = fe[dk]
	if not dt then
		dt = newindex(dkeys)
		fe[dk] = dt
	end
	index(e, dt, dkeys)
end

local function unroute(e, fe, dk, dkeys)
	local dt = fe[dk]
	if dt then
		unindex(e, dt, dkeys)
	end
end

dataset = oo.class()

function dataset:__init(t)
	local self = oo.rawnew(self, t)
	if self.keys then
		self.by = newindex(self.keys)
	end
	if self.master then
		assert(self.keys[self.lookup_key])
		assert(self.master[master_key])
		assert(self.detail_key)
	end
	if self.foreign_keys then
		for fk in pairs(self.foreign_keys) do
			assert(self.foreigns[fk])
		end
	end
	return self
end

function dataset:index(e)
	if self.keys then
		index(e, self.by, self.keys)
	end
end

function dataset:unindex(e)
	if self.keys then
		unindex(e, self.by, self.keys)
	end
end

function dataset:route(e)
	if self.master then
		local fe = getfe(e, self.lookup_key, self.master, self.master_key)
		if fe then
			route(e, fe, self.detail_key, self.parent_key, self.keys)
		end
	end
end

function dataset:unroute(e)
	if self.master then
		local fe = getfe(e, self.lookup_key, self.master, self.master_key)
		if fe then
			unroute(e, self.detail_key, self.parent_key, self.keys)
		end
	end
end

function dataset:link(e)
	if self.foreign_keys then
		for fk, def in pairs(self.foreign_keys) do
			local t = self.foreigns[fk]
			if t then
				local ek, tk = unpack(def)
				link(e, ek, t, tk, fk)
			end
		end
	end
end

function dataset:unlink(e)
	if self.foreign_keys then
		for fk in pairs(self.foreigns) do
			unlink(e, fk)
		end
	end
end

function dataset:set(e)
	self:index(e)
	self:route(e)
	self:link(e)
end

function dataset:unset(e)
	self:unindex(e)
	self:unroute(e)
	self:unlink(e)
end

local function values(t)
	return next(t)
end

function dataset:list()
	if self.keys then
		local t = self.by[next(self.keys)]
		return values(t)
	elseif self.master then
		local list =
		for self.master:list()
		return function()

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
	if self.foreigns then
		for e in self:list() do self:unlink(e) end
	end
	self.foreigns[key] = foreign
	if self.foreigns then
		for e in self:list() do self:link(e) end
	end
end

function dataset:clear(key, value)
	for k,v in pairs(self.by[key]) do
		--
	end
end

function dataset:exec(q,...)
	local q = self.queries[q]
	if type(q) == 'string' then
		for st in self.transaction:exec(format(q,(...))) do
			set(st:row())
		end
	else
		for st in self.transaction:exec(q(...)) do
			set(st:row())
		end
	end
end

function dataset:load(key, value)
	self:clear()
	for st in self.transaction:exec(self.queries.load(self)) do
		set(st:row())
	end
end

function dataset:update(e)
	for st in self.transaction:exec(self.queries.update(self, e)) do
		set(st:row())
	end
end

