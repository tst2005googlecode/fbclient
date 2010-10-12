--[[
	semi-automated test suite for the fbclient Lua binding.
	before reporting a bug, make sure this script doesn't break for you.

	WARNING: look into test_config.lua before running this script

]]


local config = require 'test_config'

total_ok_num = 0
total_fail_num = 0

local function add(ok_num,fail_num)
	total_ok_num = total_ok_num + ok_num
	total_fail_num = total_fail_num + fail_num
end

--add(config.run('test_binding.lua')) --pass
--add(config.run('test_wrapper.lua')) --fail!!!
--add(config.run('test_class.lua')) --pass
--add(config.run('test_xsqlvar.lua')) --pass
add(config.run('test_blob.lua'))
--add(config.run('test_service_wrapper.lua')) --pass
--add(config.run('test_service_class.lua')) --pass

print(('Grand total for all tests: %d ok, %d failed'):format(total_ok_num,total_fail_num))

