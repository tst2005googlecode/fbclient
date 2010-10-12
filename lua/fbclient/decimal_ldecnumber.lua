--[=[
	ldecnumber binding for decnumber decimal number support

	df(lo,hi,scale) -> d; to be used with getdecimal()
	sdf(d,scale)	-> lo,hi; to be used with setdecimal()
	isdecnumber(x)	-> true|false; the decnumber library should provide this but since it doesn't...

	xsqlvar:getdecnumber() -> d
	xsqlvar:setdecnumber(d)

	xsqlvar:set(d), extended to support decnumber-type decimals
	xsqlvar:get() -> d, extended to support decnumber-type decimals

	USAGE: just require this module if you have ldecnumber installed.

	LIMITATIONS:
	- assumes 2's complement signed int64 format (no byte order assumption though).

]=]

module(...,require 'fbclient.init')

local decNumber = require 'ldecNumber'
local xsqlvar_class = require('fbclient.xsqlvar').xsqlvar_class

-- convert the lo,hi dword pairs of a 64bit integer into a decimal number and scale it down.
function df(lo,hi,scale)
	return decNumber.fma(hi,2^32,lo):scaleb(scale) -- translation: (hi*2^32+lo)*10^scale
end

-- scale up a decimal number and convert it into the corresponding lo,hi dword pairs of its int64 representation.
function sdf(d,scale)
	d = d:scaleb(-scale) -- translation: d*10^-scale
	-- TODO: find a way to avoid temporary string creation: this is embarrasing and humiliating.
	-- TODO: find a faster way to divide than mod() and floor() which are combinations of multiple functions.
	local lo,hi = tonumber(d:mod(2^32):tostring()), tonumber(d:floor(2^32):tostring())
	return lo,hi
end

function xsqlvar_class:getdecnumber()
	return self:getdecimal(df)
end

function xsqlvar_class:setdecnumber(d)
	self:setdecimal(d,sdf)
end

function isdecnumber(p)
	return getmetatable(p) == decNumber.number_metatable
end

--the setter and getter must be module-bound so they won't get garbage-collected
function setter(self,p,typ,opt)
	if isdecnumber(p) and (typ == 'int16' or typ == 'int32' or typ == 'int64') then
		self:setdecnumber(p)
		return true
	end
end

function getter(self,typ,opt)
	if typ == 'int16' or typ == 'int32' or typ == 'int64' then
		return true,self:getdecnumber()
	end
end

xsqlvar_class:add_set_handler(setter)
xsqlvar_class:add_get_handler(getter)

