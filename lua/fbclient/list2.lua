--[[
	Class fields:

	indexing:
		keys = {key1_name = true,...}
	master-detail:
		parent_key = the key in the detail element to match against master_key in the master list
		master_key = the unique key in the master list to match the value of parent_key against to find the parent element
		detail_list_name = the key in the parent element holding the detail list
		detail_list_ref_name = the key in the detail element for setting a reference to the detail list (optional)
	foreign keys:
		foreign_keys = {key = {local_key, foreign_key},...}
	loading:
		select_query = function(p1,p2,...) -> query_string,params,...
		create_element = function(statement) ... return new_element end
	saving:
		queries = {query_name = function(e) ... return query_string,params end}

	Instance fields:

	master-detail:
		master_list = list
	foreign keys:
		foreign_lists = {key = list,...}

]]

local oo = require 'loop.base'

local List = oo.class()

function List:__init(t)
	t = t or {}
	local self = oo.rawnew(self,t)
	self:clear_indexes()
	return self
end

function List:clear_detail_lists()
	if not self.master_list then return end
	for k,parent_e in pairs(self.master_list['by_'..self.master_key]) do
		parent_e[self.detail_list_name]:clear()
	end
end

function List:clear_indexes()
	if not self.keys then return end
	for key in pairs(self.keys) do
		self['by_'..key] = {}
	end
end

function List:clear()
	self:clear_indexes()
	self:clear_detail_lists()
end

function List:set_indexes(e)
	if not self.keys then return end
	for key in pairs(self.keys) do
		self['by_'..key][e[key]] = e
	end
end

function List:set_detail(e)
	local dlist = self:get_detail_list(e)
	if dlist ~= nil then
		dlist:set(e)
	end
end

function List:set_refs(e)
	if not self.foreign_keys then return end
	for key,fkdef in pairs(self.foreign_keys) do
		local lk,fk = unpack(fkdef)
		local fe = self.foreign_lists[key]:get(e,fk)
		if fe ~= nil then
			e[key] = fe
		end
	end
end

function List:set(e)
	self:set_indexes(e)
	self:set_detail(e)
	self:set_refs(e)
end

function List:get(e,key)
	if key then
		local v = e[key]
		if v ~= nil then
			return self['by_'..key][v]
		end
	elseif self.keys then
		for key in pairs(self.keys) do
			local v = e[key]
			if v ~= nil then
				return self['by_'..key][v]
			end
		end
	elseif self.master_list then
		local dlist = self:get_detail_list(e)
		if dlist ~= nil then
			return dlist:get(e,key)
		end
	end
end

function List:remove(e)
	if self.keys then
		for key in pairs(self.keys) do
			self['by_'..key][e[key]] = nil
		end
	elseif self.master_list then
		local dlist = self:get_detail_list(e)
		if dlist ~= nil then
			dlist:remove(e)
		end
	end
end

function List:fix_refs()
	if not self.foreign_keys then return end
	local key = next(self.keys)
	for key,e in pairs(self['by_'..key]) do
		self:set_refs(e)
	end
end

function List:fix_detail_lists()
	if not self.master_list then return end
	local key = next(self.keys)
	for e in pairs(self['by_'..key]) do
		self:set_detail(e)
	end
end

function List:get_detail_list(e)
	if not self.master_list then return end
	if self.detail_list_ref_name and e[detail_list_ref_name] then
		return e[detail_list_ref_name]
	else
		local parent_e = self.master_list['by_'..self.master_key][e[self.parent_key]]
		if not parent_e then return end
		local detail_list = parent_e[self.detail_list_name]
		if not detail_list then return end
		if self.detail_list_ref_name then
			e[self.detail_list_ref_name] = detail_list
		end
		return detail_list
	end
end

function List:load(tr,...)
	for st in tr:exec(self:select_query(...)) do
		local e = self:create_element(st)
		for i,col in ipairs(st.columns) do
			e[col.column_alias_name] = col:get()
		end
		self:set(e)
	end
end

function List:query(e,name)
	return self.queries[name](e)
end

if false then
	local oo = require 'loop.simple'
	local dump = require('util').dump
	FList = oo.class({
		keys = {id = true, name = true},
	}, List)
	MList = oo.class({
		keys = {id = true, name = true},
		foreign_keys = {f = {'f_id','id'}}
	}, List)
	DList = oo.class({
		parent_key = 'parent_id',
		master_key = 'id',
		detail_list_name = 'detail',
		detail_list_ref_name = 'parent',
	}, List)
	DSList = oo.class({
		keys = {name = true}
	}, List)

	flist = FList()
	mlist = MList{foreign_lists = {f = flist}}
	dlist = DList{master_list = mlist}

	mlist:set{id=1,name='X',f_id=2,detail=DSList()}
	mlist:set{id=2,name='Y',f_id=1,detail=DSList()}
	dlist:set{id=1,name='a',parent_id=1}
	dlist:set{id=2,name='b',parent_id=1}
	dlist:set{id=3,name='c',parent_id=2}
	dlist:set{id=4,name='d',parent_id=2}
	flist:set{id=1,name='A'}
	flist:set{id=2,name='B'}
	mlist:fix_refs()
	dump(mlist)
end

return List

