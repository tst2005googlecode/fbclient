#!/usr/bin/lua

config = require 'test_config'

function test_everything(env)
	--require 'profiler'
	require 'socket'

	--profiler.start('test_metadata.profile.txt')

	local function newtrace(name)
		local tm
		return function(s,...)
			print(name,s,tm and socket.gettime()-tm or 0,...)
			tm = socket.gettime()
		end
	end

	traceall = newtrace('all')
	trace = newtrace('each')

	traceall('start')
	trace('start')

	local sch = require 'fbclient.schema'
	local dump = require('fbclient.util').dump

	trace('loadlib')

	local tr = env:create_test_db():start_transaction_ex()
	local schema = sch.new()

	trace('attach')

	schema:load(tr, {
		security = true,
		collations = true,
		function_args = true,
		table_fields = true,
		procedure_args = true,
		source_code = true,
		system_flag = true,
	})

	dump(schema)

	trace('load all')

	next(tr.attachments):close()

	traceall('end')

	--profiler.end()
end

local comb = {{lib='fbembed',ver='2.5.0'}}
config.run(test_everything,comb,nil,...)

