--[[
	Index -> a list of table elements with one or more unique keys to index by.
	Detail -> a proxy list, elements are actually kept in child lists of a master list.
	Ref -> adds fix_refs([e])
	Select -> adds load(params...)
	Query -> adds query(name,e)

]]

module(...,require 'fbclient.init')

local oo = require 'loop.base'

--[[
Class attributes:
	keys = {key1_name = true,...}
]]
Index = oo.class()

function Index:__init()
	local self = oo.rawnew(self,{})
	self:clear()
	return self
end

function Index:clear()
	for key in pairs(self.keys) do
		self['by_'..key] = {}
	end
end

function Index:set(e)
	for key in pairs(self.keys) do
		self['by_'..key][e[key]] = e
	end
end

function Index:get(e,key)
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

function Index:remove(e)
	for key in pairs(self.keys) do
		self['by_'..key][e[key]] = nil
	end
end

Detail = oo.class()

--[[
Class attributes:
	parent_key = the key in the detail element to match against master_key in the master list
	master_key = the unique key in the master list to match the value of parent_key against to find the parent element
	detail_list_name = the key in the parent element holding the detail list
	detail_list_ref_name = the key in the detail element for setting a reference to the detail list (optional)
]]
function Detail:__init(master_list)
	if t then
		t.master_list = master_list
	else
		return oo.rawnew(self,{
			master_list = master_list
		})
	end
end

function Detail:get_detail_list(e)
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

function Detail:clear()
	for k,parent_e in pairs(self.master_list['by_'..self.master_key]) do
		parent_e[self.detail_list_name]:clear()
	end
end

function Detail:get(e) return self:get_detail_list(e):get(e) end
function Detail:set(e) self:get_detail_list(e):set(e) end
function Detail:remove(e) self:get_detail_list(e):remove(e) end

IndexDetail = oo.class()

function IndexDetail:__init(master_list)
	local self = oo.rawnew(self,{
		master_list = maser_list,
	})
	Index.clear(self)
end

function IndexDetail:clear()
	Index.clear(self)
	Detail.clear(self)
end

function IndexDetail:get(e)
	Index.get(self,e)
end

function IndexDetail:set(e)
	Index.set(self,e)
	Detail.set(self,e)
	Ref.set(self,e)
end

function IndexDetail:remove(e)
	Index.remove(self,e)
	Detail.remove(self,e)
end

--[[
Class attributes:
	foreign_keys = {key = {list=, key=},...}
]]
Ref = oo.class()

function Ref:__init(foreign_keys)
	return oo.rawnew(self,{
		foreign_keys = foreign_keys
	})
end

function Ref:set(e)
	for key,fk in pairs(self.foreign_keys) do
		e[key] = fk.list:get(e,fk.key)
	end
end

--[[
Class attributes:
	select_query = function(p1,p2,...) -> query_string,...
]]
Select = oo.class()

function Select:load(tr,...)
	for st in tr:exec(self:select_query(...)) do
		local e = self:create_element(st)
		for i,col in ipairs(st.columns) do
			e[col.column_alias_name] = col:get()
		end
		self:set(e)
	end
end

--[[
Class attributes:
	queries = {name = sql,...}
]]
Query = oo.class()

function Query:query(e,name)
	local sql = queries[name]
	return sql
end

List = oo.class({}, Index, Proxy, Ref, Select, Query)

function List:__init(master_list, foreign_keys)
	local self = oo.rawnew(self,{
		master_list = maser_list,
		foreign_keys = foreign_keys,
	})
	Index.clear(self)
end

function List:clear()
	Index.clear(self)
	Proxy.clear(self)
end

function List:set(e)
	Index.set(self,e)
	Proxy.set(self,e)
	Ref.set(self,e)
end

function List:remove(e)
	Index.remove(self,e)
	Proxy.remove(self,e)
end

