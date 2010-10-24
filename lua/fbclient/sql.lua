--[[
	SQL parsing and formatting specific to Firebird

	format_name(s) -> s
	format_string(s) -> s

	parse_statements(s) -> t
	parse_template(s,f|t) -> s

]]

module(...,require 'fbclient.init')

--quote an object name
function format_name(s)
	return s
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
	if type(t) == 'table'
	s = s:gsub('%:([%w_]+)', function(s) return format_name(t(s)) end)
	s = s:gsub('%%([%w_]+)', function(s) return format_string(t(s)) end)
	return s
end

if __UNITTESTING then
	--...

end

