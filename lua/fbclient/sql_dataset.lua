--[[
	SQL-based Dataset

	Class fields:
		queries = {name = query_template | function(self, row) -> s, params... }
	Instance fields:
		options = {
			system_flag = true
		}
		transaction = firebird_transaction
	Methods:
		ds:query()
		ds:load()
		ds:exec(query_name, params...)

]]

local type =
	  type

local oo = require 'loop.simple'
local dataset = require 'fbclient.dataset'
local sql = require 'fbclient.sql'

module(...)
oo.class(_M, dataset)

function query(self, query_name, row)
	local query = self.queries[query_name]
	if type(query) == 'string' then
		return sql.parse_template(query, row)
	else
		return query(self, row)
	end
end

function exec(self,...)
	local q = self.queries[q]
	if type(q) == 'string' then
		for st in self.transaction:exec(format(q,(...))) do
			set(st:row())
		end
	else
		for st in self.transaction:exec(q(...)) do
			set(st:row())
		end
	end
end

function load(self, key, value)
	self:clear()
	for st in self.transaction:exec(self.queries.load(self)) do
		set(st:row())
	end
end

function update(self, e)
	self:reload(e)
	self:set(e)
end

function exec(self, q,...)
	local q = self.queries[q]
	if type(q) == 'string' then
		for st in self.transaction:exec(format(q,(...))) do
			set(st:row())
		end
	else
		for st in self.transaction:exec(q(...)) do
			set(st:row())
		end
	end
end

function load(self, key, value)
	self:clear()
	for st in self.transaction:exec(self.queries.load(self)) do
		set(st:row())
	end
end

function update(self, e)
	for st in self.transaction:exec(self.queries.update(self, e)) do
		set(st:row())
	end
end


