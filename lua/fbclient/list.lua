--[[
	IndexedList -> a list of table elements with one or more unique keys to index by.
	DetailList -> a proxy list, elements are actually kept in child lists in a master list.
	RefList -> a list with keys that are converted to references to elements in other lists.
	SelectedList -> a list in which you can store the resulted rows of an sql statement.
]]

module(...,require 'fbclient.init')

local oo = require 'loop.multiple'

--[[
Class attributes:
	keys = {key1_name = true,...}
]]
IndexedList = oo.class()

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

function IndexedList:get(e,key)
	if key then
		return self['by_'..key][e[key]]
	else
		for key in pairs(self.keys) do
			if e[key] ~= nil then
				return self['by_'..key][e[key]]
			end
		end
	end
end

function IndexedList:remove(e)
	for key in pairs(self.keys) do
		self['by_'..key][e[key]] = nil
	end
end

DetailList = oo.class()

--[[
Class attributes:
	parent_key = the key in the detail element to match against master_key in the master list
	master_key = the unique key in the master list to match the value of parent_key against to find the parent element
	detail_list_name = the key in the parent element holding the detail list
	detail_list_ref_name = the key in the detail element for setting a reference to the detail list (optional)
]]
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
		return detail_list
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

--[[
Class attributes:
	foreign_keys = {key = {list=, key=},...}
]]
RefList = oo.class()

RefList:__init(foreign_keys)
	return oo.rawnew(self,{
		foreign_keys = foreign_keys
	})
end

function RefList:set(e)
	for key,fk in pairs(self.foreign_keys) do
		e[key] = fk.list:get(e,fk.key)
	end
end

--[[
Class attributes:
	select_query = function(p1,p2,...) -> query_string,...
]]
SelectedList = oo.class()

function SelectedList:load(tr,...)
	for st in tr:exec(self:select_query(...)) do
		local e = self:create_element(st)
		for i,col in ipairs(st.columns) do
			e[col.column_alias_name] = col:get()
		end
		self:set(e)
	end
end

List = oo.class({}, IndexedList, SelectedList)

function List:__init(master_list, foreign_keys)
	local self = IndexedList()
end

function List:clear()
	IndexedList.clear(self)
	DetailList.clear(self)
end

function List:set(e)
	IndexedList.set(self,e)
	DetailList.set(self,e)
	ForeignKeysList.set(self,e)
end

function List:remove(e)
	IndexedList.remove(self,e)
	DetailList.remove(self,e)
end

Schema = oo.class()

function Schema:__init(lists)
	return oo.rawnew(self, {
		lists = lists
	})
end

function Schema:load_order()
	--
end


