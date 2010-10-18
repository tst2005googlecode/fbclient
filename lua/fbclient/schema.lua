
module(...,require 'fbclient.init')

local oo = require 'loop.simple'
require 'fbclient.blob'

local function bool2int(b)
	return b and 1 or nil
end

local function format_sql(sql, e)
	return (sql:gsub('%%([%w_]+)', e))
end

local function newe(st,e)
	local e = e or {}
	for i,col in ipairs(st.columns) do
		e[col.column_alias_name] = col:get()
	end
	return e
end

local function load(tr,new,add,...)
	for st in tr:exec(...) do
		local e = new(st)
		add(e)
	end
	return t
end

local function index(e,t,...)
	for i=1,select('#',...) do
		local key = select(i,...)
		t['by_'..key][e[key]] = e
	end
end

local function index_all(t,indext,...)
	for i,e in ipairs(t) do
		index(e,indext,...)
	end
end

local function getfe(e, t, lk, fk)
	return t['by_'..fk][e[lk]]
end

local function link(e, t, key, lk, fk)
	e[key] = getfe(e, t, lk, fk) or e[key]
end

local function route(e, mt, lk, mk, dk, drefk,...)
	local fe = getfe(e, mt, lk, mk)
	if fe then
		local dt = fe[dk]
		if dt then
			if drefk then
				e[drefk] = fe
			end
			index(e,dt,...)
		end
	end
end

local function indexf(t,...)
	return function(e)
		index(e,t,...)
	end
end

local function routef(mt, lk, mk, dk, drefk,...)
	return function(e)
		route(e, mt, lk, mk, dk, drefk,...)
	end
end

local load_security_classes
do
	local function query(name)
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
	end

	function load_security_classes(tr,t,...)
		load(tr, newe, indexf(t, 'NAME'), query(...))
	end
end

local load_roles
do
	local function query(name, system_flag)
		system_flag = bool2int(system_flag)
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
	end

	function load_roles(tr,t,...)
		load(tr, newe, indexf(t, 'NAME'), query(...))
	end
end
local function describe_role_query(e)
	return format_sql("comment on sequence %NAME is '%DESCRIPTION'", e)
end

local load_generators
do
	local function query(name, system_flag)
		system_flag = bool2int(system_flag)
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
	end

	function load_generators(tr, t, name,...)
		load(tr, newe, indexf(t, 'ID', 'NAME'), query(name,...))
		if name then
			for st, value in tr:exec(format_sql("select gen_id(%NAME,0) from rdb$database", name)) do
				t.by_NAME[name].VALUE = value
			end
		else
			for name, e in pairs(t.by_NAME) do
				for st, value in tr:exec(format_sql("select gen_id(%NAME,0) from rdb$database", name)) do
					e.VALUE = value
				end
			end
		end
	end
end
local function create_generator_query(e) return format_sql("create sequence %NAME", e) end
local function describe_generator_query(e) return format_sql("comment on sequence %NAME% is '%DESCRIPTION'", e) end
local function set_generator_query(e) return format_sql("alter sequence %NAME restart with %VALUE", e) end

local load_exceptions
do
	local function query(name, system_flag)
		system_flag = bool2int(system_flag)
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
	end

	function load_exceptions(tr, t,...)
		load(tr, newe, indexf(t, 'NUMBER', 'NAME'), query(...))
	end
end

local load_charsets
do
	local function query(name, system_flag)
		system_flag = bool2int(system_flag)
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
	end

	local function new(st)
		local e = newe(st)
		e.collations = {}
		return e
	end

	function load_charsets(tr, t, collations,...)
		local function add(e)
			index(e, t, 'ID', 'NAME')
			link(e, collations, 'default_collation', 'DEFAULT_COLLATE', 'NAME')
		end
		load(tr, new, add, query(...))
	end
end

local load_collations
do
	local function query(name, charset_id, system_flag)
		system_flag = bool2int(system_flag)
		return [[
			select
				c.rdb$collation_id as id,
				c.rdb$collation_name as name,
				c.rdb$character_set_id as charset_id,
			from
				rdb$collations c
			where
				(c.rdb$system_flag = ? or ? is null)
				and (c.rdb$collation_name = ? or ? is null)
				and (c.rdb$character_set_id = ? or ? is null)
		]], system_flag, system_flag, name, name, charset_id, charset_id
	end

	function load_collations(tr, t, charsets,...)
		local function add(e)
			index(e, t, 'NAME')
			route(e, charsets, 'CHARSET_ID', 'ID', 'collations', 'charset', 'NAME')
		end
		load(tr, newe, add, query(...))
	end
end
local create_collation_query(e)
	return format_sql("create collation %NAME for charset %CHARSET_NAME from external ('%EXTNAME')",
		function(key) return e[key] or e.charset.NAME end)
end

local load_domains
do
	local function query(name, system_flag)
		system_flag = bool2int(system_flag)
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
	end

	function load_domains(tr, t,...)
		load(tr, newe, indexf(t, 'NAME'), query(...))
	end
end

local load_functions
do
	local function query(name, system_flag)
		system_flag = bool2int(system_flag)
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
	end

	function load_functions(tr, t,...)
		load(tr, newe, indexf(t, 'NAME'), query(...))
	end
end

local load_function_args
do
	local function query(function_name, system_flag)
		system_flag = bool2int(system_flag)
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
	end

	function load_function_args(tr, functions,...)
		local add = routef(functions, 'FUNCTION_NAME', 'NAME', 'args', 'function', 'NAME')
		load(tr, newe, add, query(...))
	end
end

local load_procedures
do
	local function query(name, with_source, system_flag)
		system_flag = bool2int(system_flag)
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
	end

	function load_procedures(tr, t,...)
		load(tr, newe, indexf(t, 'ID', 'NAME'), query(...))
	end
end

local load_tables
do
	local function query(name, system_flag)
		system_flag = bool2int(system_flag)
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
	end

	function load_tables(tr, t,...)
		load(tr, newe, indexf(t, 'ID', 'NAME'), query(...))
	end
end

local load_table_fields
do
	local function query(name, table_name, system_flag)
		system_flag = bool2int(system_flag)
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
	end

	function load_table_fields(tr, tables,...)
		local add = routef(tables, 'TABLE_NAME', 'NAME', 'fields', 'table', 'NAME')
		load(tr, newe, add, query(...))
	end
end

IndexList = oo.class({
	keys = {NAME = true},
	select_query = function(self,name,system_flag)
		system_flag = bool2int(system_flag)
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
}, List)

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
}, List)

Schema = oo.class()

function Schema:__init(lists)
	local self = oo.rawnew(self, {
		lists = lists
	})
	return self
end

function new(transaction)
	local self = Schema()
	self.security_classes = SecurityClassList()
	self.roles = RoleList()
	--self.priviledges = PriviledgeList()
	self.generators = GeneratorList()
	self.exceptions = ExceptionList()
	self.charsets = CharsetList()
	self.collations = CollationSelectList{master_list = self.charsets}
	self.charsets.foreign_lists = {default_collation = self.collations}
	self.domains = DomainList()
	self.functions = FunctionList()
	self.procedures = ProcedureList()
	self.tables = TableList()
	--[[
	self.foreign_keys = ForeignKeyList()
	self.indices = IndexList()
	]]
	return self
end

function Schema:load(tr,opts)
	opts = opts or {}
	self.generators:load(tr,nil,opts.system_flag)
	--[[
	if opts.security then
		self.security_classes:load(tr)
		self.roles:load(tr,nil,opts.system_flag)
	end
	self.charsets:load(tr,nil,opts.system_flag)
	if opts.collations then
		self.collations:load(tr,nil,nil,opts.system_flag)
	end
	self.charsets:fix_refs()
	self.exceptions:load(tr,nil,opts.system_flag)
	self.domains:load(tr,nil,opts.system_flag)
	self.functions:load(tr,system_flag,nil,opts.system_flag)
	if opts.function_args then
		self.function_args:load(tr,system_flag,nil,opts.system_flag)
	end
	self.procedures:load(tr,nil,opts.procedure_source,opts.system_flag)
	self.tables:load(tr,nil,opts.view_source,opts.system_flag)
	if opts.table_fields then
		self.table_fields:load(tr,nil,nil,opts.system_flag)
	end
	if opts.security then
		--self.priviledges:load(nil)
	end
	self.foreign_keys:load()
	self.indices:load()
	]]
end

