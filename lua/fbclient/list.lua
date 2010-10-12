--[[
	IndexedList -> a list of table elements with one or more unique keys to index by and optional foreign keys.
	DetailList -> a proxy list, elements are actually kept in child lists in a master list.
	IndexedDetailList -> a detail list that can also be indexed.
	SelectedList -> a list you can load with the resulted rows of an sql statement.
]]

module(...,require 'fbclient.init')

local oo = require 'loop.multiple'

IndexedList = oo.class()

--IndexedListDerivate.keys = {key1_name = true,...}
--IndexedListDerivate.primary_key = key_name
--IndexedListDerivate.foreign_keys = {{key=, list=, lookup_key=},...}

function IndexedList:__init()
	local self = oo.rawnew(self,{})
	self:clear()
	return self
end

function IndexedList:clear()
	for key in pairs(self.keys) do
		self['by_'..key] = {}
	end
end

function IndexedList:set(e)
	for key in pairs(self.keys) do
		self['by_'..key][e[key]] = e
	end
end

function IndexedList:get(e)
	local key = self.primary_key
	return self['by_'..key][e[key]]
end

function IndexedList:remove(e)
	for key in pairs(self.keys) do
		self['by_'..key][e[key]] = nil
	end
end

DetailList = oo.class({})

--DetailListDerivate.parent_key = the key in the detail element to match against master_key in the master list
--DetailListDerivate.master_key = the unique key in the master list to match the value of parent_key against to find the parent element
--DetailListDerivate.detail_list_name = the key in the parent element holding the detail list
--DetailListDerivate.detail_list_ref_name = the key in the detail element holding a reference to the detail list (optional)
function DetailList:__init(master_list)
	return oo.rawnew(self,{
		master_list = master_list
	})
end

function DetailList:get_detail_list(e)
	if self.detail_list_ref_name and e[detail_list_ref_name] then
		return e[detail_list_ref_name]
	else
		local parent_e = assert(self.master_list['by_'..self.master_key][e[self.parent_key]], 'parent element not found')
		local detail_list = assert(parent_e[self.detail_list_name], 'detail list not found')
		if self.detail_list_ref_name then
			e[detail_list_ref_name] = detail_list
		end
	end
end

function DetailList:clear()
	for k,parent_e in pairs(self.master_list['by_'..self.master_key]) do
		parent_e[self.detail_list_name]:clear()
	end
end
function DetailList:get(e) return self:get_detail_list(e):get(e) end
function DetailList:set(e) self:get_detail_list(e):set(e) end
function DetailList:remove(e) self:get_detail_list(e):remove(e) end

IndexedDetailList = oo.class({}, IndexedList)

function IndexedDetailList:clear()
	IndexedList.clear(self)
	DetailList.clear(self)
end

function IndexedDetailList:set(e)
	IndexedList.set(self,e)
	DetailList.set(self,e)
end

function IndexedDetailList:remove(e)
	IndexedList.remove(self,e)
	DetailList.remove(self,e)
end

TreeList = oo.class({}, List)
--TreeList.

SelectedList = oo.class({}, List)
--SelectedList.select_query = function(p1,p2,...) -> query_string,...

function SelectedList:load(tr,...)
	for st in tr:exec(self.select_query(...)) do
		local row = {}
		for i,col in ipairs(st.columns) do
			row[col.column_alias_name:lower()] = col:get()
		end
		self:set(row)
	end
end

