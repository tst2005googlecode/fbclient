
package.path = '../../lua/?.lua;'..package.path

local dump = require 'fbclient.util'.dump
local rowindex = require 'fbclient.ds.rowindex'
local tuple = require 'fbclient.ds.tuple'
local NaN = 0/0

local rowmeta = {}
function rowmeta:__tostring()
	t = {}
	for k,v in pairs(self) do
		t[#t+1] = tostring(k)..' = '..tostring(v)
	end
	return table.concat(t,', ')
end
local function row(t)
	return setmetatable(t, rowmeta)
end

local idx1 = rowindex('id')
local idx2 = rowindex('id','name')

local rows = {
	row{id = 1, name = 'A'},
	row{id = 2, name = 'B'},
	row{id = 3, name = 'C'},
	row{id = 4, name = 'D'},
}

for i,row in ipairs(rows) do
	idx1:set(row)
	idx2:set(row)
end

for row in idx1:values() do
	print(row)
	assert(idx1:lookup(row) == row)
	assert(idx2:lookup(row) == row)
end

print()

for row in idx2:values() do
	print(row)
	assert(idx1:lookup(row) == row)
	assert(idx2:lookup(row) == row)
end

for i,row in ipairs(rows) do
	idx1:remove(row)
	idx2:remove(row)
end

for e in idx1:values() do assert(false) end
for e in idx2:values() do assert(false) end

