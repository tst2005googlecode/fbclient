--[[
	Test unit for class.lua

	TODO:
	- test at:cancel_operation()

]]

local config = require 'test_config'

local function map(t,f)
	local tt = {}
	for i=1,#t do
		tt[#tt+1] = f(t[i])
	end
	return tt
end

local function asserteq(a,b,s)
	assert(a==b,s or string.format('%s ~= %s', tostring(a), tostring(b)))
end

local function test_everything(env)

	local api = require 'fbclient.class'
	local util = require 'fbclient.util'
	require 'fbclient.blob' --blob support is not loaded automatically
	require 'fbclient.error_codes' --error codes are not loaded automatically
	local count = util.count
	local dump = util.dump

	--drop the test database in case it's still hanging around
	pcall(function()
		local db = api.attach(env.database, env.username, env.password, nil, nil, nil, env.libname)
		db:drop()
	end)
	--alternative drop method without attachment :)
	os.remove(env.database_file)

	--db creation
	local db = api.create_database_sql(string.format("create database '%s' user '%s' password '%s'",
										env.database, env.username, env.password), env.libname)
	print('db created (sql) '..env.database)

	--server diagnostics
	print('db version') dump(db:database_version())
	print('db server version',db:server_version())
	pcall(function()
		for st, s in db:exec("select rdb$get_context('SYSTEM','ENGINE_VERSION') from rdb$database") do
			print('engine version',s)
		end
	end)

	db:drop()
	print('db dropped')

	local db = api.create_database(env.database, env.username, env.password, nil, nil, nil, nil, nil, env.libname)
	print('db created (dpb)',db)
	print('db attachment id',db:id())

	local db2 = api.attach(env.database, env.username, env.password, nil, nil, nil, env.libname)
	print('db2 attached',db2)

	local db3 = db2:clone()
	print('db2 cloned to db3',db3,db2)

	print('db page counts'); dump(db:page_counts())
	print('db page size',db:page_size())
	print('db page count',db:page_count())
	print('db buffer count',db:buffer_count())
	print('db memory',db:memory())
	print('db max memory',db:max_memory())
	print('db sweep interval',db:sweep_interval())
	print('db no reserve',db:no_reserve())
	print('db ods version',table.concat(db:ods_version(),'.'))
	print('db forced writes',db:forced_writes())
	print('db connected users',unpack(db:connected_users()))
	print('db read only',db:read_only())
	print('db creation date',db:creation_date())
	print('db page contents(1)',pcall(function() db:page_contents(1) end))
	print('db table counts'); dump(db:table_counts())

	db:exec_immediate('create table t(id integer primary key, name blob)')
	print('table t created')

	local tr2 = db2:start_transaction_sql('SET TRANSACTION')
	print('tr2 started (sql)',tr2)
	asserteq(count(tr2.attachments),1)
	print('tr2 transaction id: '..tr2:id())

	for st,id,name in tr2:exec('insert into t values (?,?) returning id, name',1,'hello') do
		print('inserted id, name',id,name)
	end
	tr2:exec('insert into t values (?,?)',2,'hello again')
	asserteq(count(tr2.statements),0)
	tr2:commit_retaining()

	local tr = api.start_transaction_ex{[db] = true, [db3] = true}
	print('tr started (multi-database)',tr)
	asserteq(count(tr.attachments),2)
	print('tr transaction id: '..tr:id())

	for st,id,name in tr:exec_on(db3, 'select * from t for update of name') do
		st:set_cursor_name('cr')
		tr:exec_on(db3, 'update t set name = ? where current of cr', name..' updated')
	end

	local st = tr:prepare_on(db3, 'select * from t where name = ?')
	print('st prepared',st)
	asserteq(count(tr.statements),1)
	st:setparams('hello again updated')
	st:run()
	print('st executed')
	print('statement type: '..st:type())
	print('execution plan: '..st:plan())
	print('affected rows: ')
	dump(st:affected_rows())

	print(unpack(map(st.columns,function(c) return c.column_alias_name end)))
	while st:fetch() do
		print(st:values('ID','NAME'))
		assert(st.values.NAME == 'hello again updated')
	end

	st:close()
	print('st closed')
	asserteq(count(tr.statements),0)

	tr2:rollback()
	print('tr2 rolled back')
	asserteq(count(tr2.statements),0)

	tr:commit_retaining()
	print('tr commited retaining')
	asserteq(count(tr.statements),0)

	db3:close()
	print('db3 closed')
	asserteq(count(db3.statements),0)
	asserteq(count(db3.transactions),0)

	db2:close()
	print('db2 closed')
	asserteq(count(db2.statements),0)
	asserteq(count(db2.transactions),0)

	db:drop()
	print('db dropped')
	asserteq(count(db.transactions),0)
	asserteq(count(db.statements),0)

	return 1,0
end

--local comb = {lib='fbclient',ver='2.5rc3',server_ver='2.1.3'}
config.run(test_everything,comb,nil,...)


