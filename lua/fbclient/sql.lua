--[[
	SQL parsing and formatting specific to Firebird

	format_name(s) -> s
	format_string(s) -> s

	parse_statements(s) -> t
	parse_template(s,f|t) -> s

]]

module(...,require 'fbclient.module')

local keywords = require 'fbclient.sql_keywords'
local lpeg = require 'lpeg'

--quote an object name
function format_name(s, quoting_mode)
	s = s:match('^%"([%u_]-)"$') or s --de-quote all-uppercase-and-no-spaces names
	return (not quoting_mode or keywords[quoting_mode][s]) and '"'..s..'"' or s
end

--quote a string constant
function format_string(s)
	return s
end

--splits a string containing multiple sql statements separated by ';'
--implements 'SET TERM'
function parse_statements(s)
	return {s}
end

--replace :NAME and %NAME placeholders from a text with values from a table or the result of a function
--:: and %% are replaced with : and % respectively
function parse_template(s,t)
	local f = t
	if type(t) == 'table' then
		function f(s)
			return t[s]
		end
	end
	s = s:gsub('%:("?[%w_%.]+"?)', function(s) return format_name(f(s)) end)
	s = s:gsub('%%("?[%w_%.]+"?)', function(s) return format_string(f(s)) end)
	return s
end

