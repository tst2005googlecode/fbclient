--[[
	SQL-based Dataset

	Class fields:
		queries = {name = query_template | function(self, row) -> s }
	Instance fields:
		options = {
			system_flag = true
		}
		transaction = firebird_transaction

	Usage:
		sqlds = require 'fbclient.sql_dataset'
		DS = oo.class({ ... class fields ... }, sqlds)
		ds = DS{ ... instance fields ... }

		ds:load()
		ds:exec(query_name, params...)

]]

module(...,'fbclient.init')

local oo = require 'loop.simple'
local dataset = require 'fbclient.dataset'

local sql_dataset = oo.class({}, dataset)

_M = sql_dataset

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


