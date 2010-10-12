--[[
	Test unit for tracing API

]]

local config = require 'test_config'

local fb = require 'fbclient.class'
local asserts = (require 'fbclient.util').asserts

function test_everything(env)

	local at = env:create_test_db()

	--

	at:close()

	return 1,0
end

config.run(test_everything,nil,nil,...)

