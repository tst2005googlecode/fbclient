--[[
	Inspecting and changing the schema (metadata) of a Firebird database

	new(transaction) -> schema;
	schema:load()
	schema:close()

	Possible improvements:
	- keep prepared statements open for reuse

]]

module(...,require 'fbclient.init')

local oo = require 'loop.multiple'
local list = require 'fbclient.list'
require 'fbclient.blob'

SelectedList = list.SelectedList
IndexedList = list.IndexedList
DetailList = list.DetailList

Schema = oo.class()

function new(transaction)
	local self = Schema()
	self.security_classes = SecurityClassList()
	self.roles = RoleList()
	--self.priviledges = priviledges_class()
	self.generators = GeneratorList()
	self.exceptions = ExceptionList()
	self.charsets = CharsetList()
	self.collations = CollationSelectList(self.charsets)
	self.domains = DomainList()
	self.functions = FunctionList()
	self.procedures = ProcedureList()
	self.tables = TableList()
	--[[
	self.foreign_keys = foreign_keys_class()
	self.indices = indices_class()
	]]
	return self
end

function Schema:load(tr,opts)
	opts = opts or {}
	local system_flag = opts.system_objects and 1 or nil
	if opts.security then
		self.security_classes:load(tr)
		self.roles:load(tr,system_flag)
	end
	self.generators:load(tr,system_flag)
	self.exceptions:load(tr,system_flag)
	self.charsets:load(tr,system_flag,opts.charset_collations and 1 or nil)
	self.collations:load(tr,system_flag)
	self.domains:load(tr,system_flag)
	self.functions:load(tr,system_flag,opts.function_args and 1 or nil)
	self.procedures:load(tr,system_flag,opts.procedure_args and 1 or nil,opts.procedure_source and 1 or nil)
	self.tables:load(tr,system_flag,opts.table_fields and 1 or nil,opts.view_source and 1 or nil)
	if opts.security then
		--self.priviledges:load(nil)
	end
	--[[
	self.foreign_keys:load()
	self.indices:load()
	]]
end

SecurityClass = oo.class()

SecurityClassList = oo.class({
	keys = {name = true},
	primary_key = 'name',
	select_query = function(self,name)
		return [[
			select
				rdb$security_class as name,
				rdb$acl as acl,
				rdb$description as description
			from
				rdb$security_classes
			where
				rdb$security_class = ? or ? is null
			]], name, name
	end,
	create_element = function(self,st) return SecurityClass() end,
}, IndexedList, SelectedList)

Role = oo.class()

RoleList = oo.class({
	keys = {name = true},
	primary_key = 'name',
	select_query = function(self,name,system_flag)
		return [[
			select
				rdb$role_name as name,
				rdb$owner_name as owner,
				rdb$description as description,
				rdb$system_flag as system_flag
			from
				rdb$roles
			where
				(rdb$system_flag = ? or ? is null)
				and (rdb$role_name = ? or ? is null)
			]], system_flag, system_flag, name, name
	end,
	create_element = function(self,st) return Role() end,
}, IndexedList, SelectedList)

Generator = oo.class()

GeneratorList = oo.class({
	keys = {name = true, id = true},
	primary_key = 'name',
	select_query = function(self,name,system_flag)
		return [[
			select
				rdb$generator_id as id,
				rdb$generator_name as name,
				rdb$system_flag as system_flag,
				rdb$description as description
			from
				rdb$generators
			where
				(rdb$system_flag = ? or ? is null)
				and (rdb$generator_name = ? or ? is null)
			]], system_flag, system_flag, name, name
	end,
	create_element = function(self,st) return Generator() end,
}, IndexedList, SelectedList)

Exception = oo.class()

ExceptionList = oo.class({
	keys = {name = true, number = true},
	primary_key = 'name',
	select_query = function(self,name,system_flag)
		return [[
			select
				rdb$exception_number as number,
				rdb$exception_name as name,
				rdb$message as message,
				rdb$description as description,
				rdb$system_flag as system_flag
			from
				rdb$exceptions
			where
				(rdb$system_flag = ? or ? is null)
				and (rdb$exception_name = ? or ? is null)
			]], system_flag, system_flag, name, name
	end,
	create_element = function(self,st) return Exception() end,
}, IndexedList, SelectedList)

Charset = oo.class()

CollationList = oo.class({
	keys = {id = true, name = true},
}, IndexedList)

CharsetList = oo.class({
	keys = {name = true, id = true},
	primary_key = 'name',
	select_query = function(self,name,system_flag)
		return [[
			select
				c.rdb$character_set_id as id,
				c.rdb$character_set_name as name,
				c.rdb$default_collate_name as default_collate
			from
				rdb$character_sets c
			where
				(c.rdb$system_flag = ? or ? is null)
				and (c.rdb$character_set_name = ? or ? is null)
			]], system_flag, system_flag, name, name
	end,
	create_element = function(self,st)
		local c = Charset()
		c.collations = CollationList()
		return c
	end,
}, IndexedList, SelectedList)

Collation = oo.class()

CollationSelectList = oo.class({
	master_key = 'id',
	parent_key = 'charset_id',
	detail_list_name = 'collations',
	primary_key = 'id',
	select_query = function(self,charset_id,system_flag)
		return [[
			select
				c.rdb$collation_id as id,
				c.rdb$collation_name as name,
				c.rdb$character_set_id as charset_id
			from
				rdb$collations c
			where
				(c.rdb$system_flag = ? or ? is null)
				and (c.rdb$character_set_id = ? or ? is null)
		]], system_flag, system_flag, charset_id, charset_id
	end,
	create_element = function(self,st) return Collation() end,
}, DetailList, SelectedList)

Domain = oo.class()

DomainList = oo.class({
	keys = {name = true},
	primary_key = 'name',
	select_query = function(self,name,system_flag)
		return [[
			select
				f.rdb$field_name as name,
				f.rdb$validation_source as validation_source,
				f.rdb$computed_source as computed_source,
				f.rdb$default_value as default_value,
				f.rdb$default_source as default_source,
				f.rdb$field_length as field_length,
				f.rdb$field_scale as field_scale,
				t.rdb$type_name as type,
				st.rdb$type_name as subtype,
				f.rdb$description as description,
				f.rdb$system_flag as system_flag,
				f.rdb$segment_length as segment_length,
				f.rdb$external_length as external_length,
				f.rdb$external_scale as external_scale,
				et.rdb$type_name as external_type,
				f.rdb$dimensions as dimensions,
				f.rdb$null_flag as null_flag,
				f.rdb$character_length as ch_length,
				f.rdb$collation_id as collation_id,
				f.rdb$character_set_id as charset_id,
				f.rdb$field_precision as field_precision
			from
				rdb$fields f
				inner join rdb$types t on
					t.rdb$field_name = 'RDB$FIELD_TYPE'
					and t.rdb$type = f.rdb$field_type
				left join rdb$types st on
					st.rdb$field_name = 'RDB$FIELD_SUB_TYPE'
					and st.rdb$type = f.rdb$field_sub_type
				left join rdb$types et on
					et.rdb$field_name = 'RDB$FIELD_TYPE'
					and et.rdb$type = f.rdb$external_type
			where
				(f.rdb$system_flag = ? or ? is null)
				and (f.rdb$field_name = ? or ? is null)
			]], system_flag, system_flag, name, name
		end,
		create_element = function(self,st) return Domain() end,
		update_element = function(self,e,st)
			SelectedList.update_element(self,e,st)
		end,
}, IndexedList, SelectedList)

Function = oo.class()

FunctionList = oo.class({
	keys = {name = true},
	primary_key = 'name',
	select_query = function(self,name,system_flag)
		return [[
			select
				f.rdb$function_name as name,
				f.rdb$description as description,
				f.rdb$module_name as library,
				f.rdb$entrypoint as entry_point,
				f.rdb$return_argument as return_argument_position,
				f.rdb$system_flag as system_flag
			from
				rdb$functions f
			where
				(f.rdb$system_flag = ? or ? is null)
				and (f.rdb$function_name = ? or ? is null)
			]], system_flag, system_flag, name, name
	end,
	create_element = function(self,st) return Function() end,
	update_element = function(self,e,st)
		SelectedList.update_element(self,e,st)
		e.args = FunctionArgs(e)
	end,
}, IndexedList, SelectedList)

FunctionArgs = oo.class()

FunctionArgList = oo.class({
	primary_key = 'position',
	master_key = 'name',
	parent_key = 'function_name',
	detail_list_name = 'args',
	select_query = function(self,charset_id,system_flag)
		return [[
			select
				a.rdb$function_name as function_name,
				a.rdb$argument_position as position,
				tm.rdb$type_name as mechanism,
				tt.rdb$type_name as field_type,
				a.rdb$field_scale as field_scale,
				a.rdb$field_length as field_length,
				a.rdb$field_sub_type as subtype,
				a.rdb$character_set_id as charset_id,
				a.rdb$field_precision as field_precision,
				a.rdb$character_length as ch_length
			from
				rdb$function_arguments a
				inner join rdb$functions f on
					f.rdb$function_name = a.rdb$function_name
				left join rdb$types tm on
					tm.rdb$field_name = 'RDB$MECHANISM'
					and tm.rdb$type = a.rdb$mechanism
				inner join rdb$types tt on
					tt.rdb$field_name = 'RDB$FIELD_TYPE'
					and tt.rdb$type = a.rdb$field_type
			where
				(f.rdb$system_flag = ? or ? is null)
				and (a.rdb$function_name = ? or ? is null)
			]], system_flag, system_flag, name, name
		end,
		create_element = function(self,st) return FunctionArgs() end,
		update_element = function(self,e,st)
			SelectedList.update_element(self,e,st)
		end,
}, DetailList, SelectedList)

Procedure = oo.class()

ProcedureList = oo.class({
	keys = {name = true, id = true},
	primary_key = 'name',
	select_query = function(self,name,system_flag,with_source)
		return [[
			select
				p.rdb$procedure_id as id,
				p.rdb$procedure_name as name,
				p.rdb$description as description,
				case when ? is null then null else p.rdb$procedure_source end as source
			from
				rdb$procedures p
			where
				(p.rdb$system_flag = ? or ? is null)
				and (p.rdb$procedure_name = ? or ? is null)
			]], with_source, system_flag, system_flag, name, name
	end,
	create_element = function(self,st) return Procedure() end,
	update_element = function(self,e,st)
		SelectedList.update_element(self,e,st)
		e.args = ProcedureArgList(e)
	end,
}, IndexedList, SelectedList)

Table = oo.class()

TableList = oo.class({
	keys = {name = true, id = true},
	primary_key = 'name',
	select_query = function(self,name,system_flag)
		return [[
			select
				r.rdb$relation_id as id,
				r.rdb$relation_name as name,
				t.rdb$type_name as table_type,
				case when ? is null then null else r.rdb$view_source end as view_source,
				r.rdb$description as description,
				r.rdb$system_flag as system_flag,
				r.rdb$dbkey_length as dbkey_length,
				r.rdb$security_class as security_class,
				r.rdb$external_file as external_file,
				r.rdb$external_description as external_description,
				r.rdb$owner_name as owner_name,
				r.rdb$default_class as default_class
			from
				rdb$relations r
				inner join rdb$types t on
					t.rdb$type = r.rdb$relation_type
					and t.rdb$field_name ='RDB$RELATION_TYPE'
			where
				(r.rdb$system_flag = ? or ? is null)
				and (r.rdb$relation_name = ? or ? is null)
			]], system_flag, system_flag, name, name
	end,
	create_element = function(self,st) return Table() end,
	update_element = function(self,e,st)
		SelectedList.update_element(self,e,st)
		e.fields = TableFieldList(e)
	end,
}, IndexedList, SelectedList)

TableField = oo.class()

TableFieldList = oo.class({
	primary_key = 'name',
	master_key = 'name',
	parent_key = 'table_name',
	detail_list_name = 'fields',
	select_query = function(self,name,system_flag,table_name)
		return [[
			select
				rf.rdb$field_id as id, --doesn't survive backup/restore
				rf.rdb$field_name as name,
				rf.rdb$relation_name as table_name,
				rf.rdb$field_source as domain,
				rf.rdb$base_field as base_field, --for views; table field or proc arg name
				rf.rdb$field_position as position,
				vr.rdb$relation_name as base_table, --for views; table or proc name
				rf.rdb$description as description,
				rf.rdb$default_value as default_value,
				rf.rdb$system_flag as system_flag,
				rf.rdb$security_class as security_class,
				rf.rdb$null_flag as null_flag,
				rf.rdb$default_source as default_source,
				rf.rdb$collation_id as collation_id
			from
				rdb$relation_fields rf
				inner join rdb$relations r on
					r.rdb$relation_name = rf.rdb$relation_name
				left join rdb$view_relations vr on
					vr.rdb$view_name = rf.rdb$relation_name
					and vr.rdb$view_context = rf.rdb$view_context
			where
				(r.rdb$system_flag = ? or ? is null)
				and (rf.rdb$relation_name = ? or ? is null)
			]], system_flag, system_flag, name, name
	end,
	create_element = function(self,st) return TableField() end,
	update_element = function(self,e,st)
		SelectedList.update_element(self,e,st)
	end,
}, DetailList, SelectedList)

Index = oo.class()

IndexList = oo.class({
	keys = {name = true},
	primary_key = 'name',
	select_query = function(self,name,system_flag)
		return [[
			select
				i.rdb$index_name,
				i.rdb$relation_name,
				i.rdb$unique_flag,
				i.rdb$description,
				i.rdb$segment_count,
				i.rdb$index_inactive,
				i.rdb$foreign_key,
				i.rdb$system_flag,
				i.rdb$expression_source,
				i.rdb$statistics
			from
				rdb$indices i
		]]
	end,
	create_element = function(self,st) return Index() end,
}, IndexedList, SelectedList)

ForeignKey = oo.class()

ForeignKeyList = oo.class({
	select_query = function(self,name)
		return [[
			select
			i.rdb$index_name,
			i.rdb$relation_name,
			i.rdb$unique_flag,
			i.rdb$description,
			i.rdb$segment_count,
			i.rdb$index_inactive,
			i.rdb$foreign_key,
			i.rdb$system_flag,
			i.rdb$expression_source,
			i.rdb$statistics
		from
			rdb$
		]]
	end,
}, DetailList, SelectedList)

