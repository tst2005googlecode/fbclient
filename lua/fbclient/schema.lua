--[[
	Firebird schema loading

]]

module(...,require 'fbclient.init')

local oo = require 'loop.simple'
local sql = require 'fbclient.sql'
require 'fbclient.blob'

local function format(s, e)
	s = s:gsub('%$([%w_]+)', function(s) return sql.format_name(e[s]) end)
	s = s:gsub('%%([%w_]+)', function(s) return sql.format_string(e[s]) end)
	return s
end

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
	security_classes = oo.class({
		keys = {'NAME'},
		queries = {
			load = function(self) return query() end,
			update = function(self, e) return query(e.NAME) end,
		}
	}, objects)
end

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
	roles = oo.class({
		keys = {'NAME'},
		queries = {
			load = function(self) return query(nil, self.system_flag) end,
			update = function(self, e) return query(e.NAME, true) end,
			describe = function(self, e) return format('comment on sequence $NAME is %DESCRIPTION', e) end,
		}
	}, objects)
end

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
	generators = oo.class({
		keys = {'ID', 'NAME'},
		queries = {
			load		= function(self) return query(nil, self.options.system_flag) end,
			update		= function(self, e) return query(e.NAME, true) end,
			describe	= 'comment on generator $NAME is %DESCRIPTION',
			create		= 'create sequence $NAME", e)',
			alter		= 'alter sequence $NAME restart with %VALUE',
		},
		refresh = function(self)
			objects.refersh(self)
			for name, e in pairs(self.by.NAME) do
				for st, value in self.transaction:exec(format('select gen_id($NAME,0) from rdb$database', name)) do
					e.VALUE = value
				end
			end
		end,
		load = function(self)
			objects.load(self, e)
			for st, value in self.transaction:exec(format('select gen_id($NAME,0) from rdb$database', e.NAME)) do
				e.VALUE = value
			end
		end,
	}, objects)
end

--[=[
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

	function loaders.exceptions(tr, t,...)
		load(tr, newe, indexf(t, 'NUMBER', 'NAME'), query(...))
	end
end

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

	function charsets.load(tr, t, collations,...)
		local function add(e)
			index(e, t, 'ID', 'NAME')
			link(e, collations, 'default_collation', 'DEFAULT_COLLATE', 'NAME')
		end
		init_indices(t, 'ID', 'NAME')
		load(tr, new, add, query(...))
	end
end

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

	function loaders.collations(tr, t, charsets,...)
		local function add(e)
			index(e, t, 'NAME')
			route(e, charsets, 'CHARSET_ID', 'ID', 'collations', 'charset', 'NAME')
		end
		init_indices(t, 'NAME')
		init_routes(charsets, 'ID', 'collations')
		load(tr, newe, add, query(...))
	end
end

function queries.collations.create(e)
	return format_sql("create collation %NAME for charset %CHARSET_NAME from external ('%EXTNAME')",
		function(key) return e[key] or e.charset.NAME end)
end

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

	function loaders.domains(tr, t,...)
		load(tr, newe, indexf(t, 'NAME'), query(...))
	end
end

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

	function loaders.functions(tr, t,...)
		load(tr, newe, indexf(t, 'NAME'), query(...))
	end
end

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

	function loaders.function_args(tr, functions,...)
		local add = routef(functions, 'FUNCTION_NAME', 'NAME', 'args', 'function', 'NAME')
		load(tr, newe, add, query(...))
	end
end

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

	function loaders.procedures(tr, t,...)
		load(tr, newe, indexf(t, 'ID', 'NAME'), query(...))
	end
end

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

	function loaders.tables(tr, t,...)
		load(tr, newe, indexf(t, 'ID', 'NAME'), query(...))
	end
end

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

	function loaders.table_fields(tr, tables,...)
		local add = routef(tables, 'TABLE_NAME', 'NAME', 'fields', 'table', 'NAME')
		load(tr, newe, add, query(...))
	end
end

do
	local function query(name, system_flag)
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
	end

	function loaders.indices(tr,t,...)
		load(tr, newe, indexf(t, 'NAME'), query(...))
	end
end

do
	local function query(name)
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
	end

	function loaders.foreign_keys(tr,t,...)
		load(tr, newe, indexf(t, 'NAME'), query(...))
	end
end

function load(tr, opts)
	loaders.security_classes()

]=]

schema = oo.class()

function schema.__init(t)
	local self = oo.rawnew(self, t)
	self.security_classes = security_classes{options = t.options}
	return self
end

function schema:load()
	self.security_classes:load()
end

function new()
	return schema()
end

