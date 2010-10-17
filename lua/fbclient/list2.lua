
module(...,require 'fbclient.init')

local oo = require 'loop.multiple'

--[[
	Class fields:

	indexing:
		keys = {key1_name = true,...}
	child list:
		parent_key = the key in the detail element to match against master_key in the master list
		master_key = the unique key in the master list to match the value of parent_key against to find the parent element
		detail_list_name = the key in the parent element holding the detail list
		detail_list_ref_name = the key in the detail element for setting a reference to the detail list (optional)
	loading:
		select_query = function(p1,p2,...) -> query_string,...
		create_element = function(statement) ... return new_element end

]]

List = oo.class()

--foreign_keys = {key = {key=, list=}, ...}
function List:__init(master_list, foreign_keys)
	local self = oo.rawnew(self,{
		master_list = master_list,
		foreign_keys = foreign_keys,
	})
	self:clear()
	return self
end

function List:clear()
	for key in pairs(self.keys) do
		self['by_'..key] = {}
	end
	for k,parent_e in pairs(self.master_list['by_'..self.master_key]) do
		parent_e[self.detail_list_name]:clear()
	end
end

function List:set(e)
	for key in pairs(self.keys) do
		self['by_'..key][e[key]] = e
	end
	if self.master_list then
		self:get_detail_list(e):set(e)
	end
	for key,fk in pairs(self.foreign_keys) do
		e[key] = fk.list:get(fk.key)
	end
end

function List:get(e,key)
	if key then
		return self['by_'..key][e[key]]
	elseif self.keys then
		for key in pairs(self.keys) do
			if e[key] ~= nil then
				return self['by_'..key][e[key]]
			end
		end
	elseif self.master_list then
		return self:get_detail_list(e):get(e,key)
	end
end

function List:remove(e)
	for key in pairs(self.keys) do
		self['by_'..key][e[key]] = nil
	end
	if master_list then
		self:get_detail_list(e):remove(e)
	end
end

function List:get_detail_list(e)
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

function List:load(tr,...)
	for st in tr:exec(self:select_query(...)) do
		local e = self:create_element(st)
		for i,col in ipairs(st.columns) do
			e[col.column_alias_name] = col:get()
		end
		self:set(e)
	end
end

