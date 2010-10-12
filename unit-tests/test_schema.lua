
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
		charset_collations = true,
		function_args = true,
		table_fields = true,
		procedure_args = true,
		procedure_source = true,
		view_source = true,
	})

	dump(schema)

	trace('load all')

	at:close()

	traceall('end')

	--profiler.end()
end

--local comb = {{lib='fbembed',ver='2.1.3'}}
config.run(test_everything,comb,nil,...)

