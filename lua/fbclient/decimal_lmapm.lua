--[=[
	lmapm binding for mapm decimal number support

	df(lo,hi,scale) -> d; to be used with getdecimal()
	sdf(d,scale)	-> lo,hi; to be used with setdecimal()
	ismapm(x)		-> true|false; the mapm library should provide this, but since it doesn't...

	xsqlvar:getmapm() -> d
	xsqlvar:setmapm(d)

	xsqlvar:set(d), extended to support mapm-type decimals
	xsqlvar:get() -> d, extended to support mapm-type decimals

	USAGE: just require this module if you have lmapm installed.

	LIMITATIONS:
	- the % operator doesn't have Lua semantics for decnumbers!
	- mapm is not thread-safe. it includes a lock-based thread-safe wrapper but you'll have to build it yourself.
	- assumes 2's complement signed int64 format (no byte order assumption though).

]=]

module(...,require 'fbclient.init')

local mapm = require 'mapm' -- yes, the module is called mapm, not lmapm!
local xsqlvar_class = require('fbclient.xsqlvar').xsqlvar_class
local MAPM_ZERO = mapm.number(0)
local MAPM_META = getmetatable(MAPM_ZERO)

-- convert the lo,hi dword pairs of a 64bit integer into a decimal number and scale it down.
function df(lo,hi,scale)
	return (mapm.number(hi)*2^32+lo)*10^scale
end

-- scale up a decimal number and convert it into the corresponding lo,hi dword pairs of its int64 representation.
function sdf(d,scale)
	local hi,lo = mapm.idiv(d*10^-scale,2^32) --idiv returns quotient,reminder.
	if d < MAPM_ZERO then
		hi = hi-1
		lo = lo + 2^32
	end
	return mapm.tonumber(lo), mapm.tonumber(hi)
end

function xsqlvar_class:getmapm()
	return self:getdecimal(df)
end

function xsqlvar_class:setmapm(d)
	self:setdecimal(d,sdf)
end

function ismapm(x)
	return getmetatable(x) == MAPM_META
end

--the setter and getter must be module-bound so they won't get garbage-collected
function setter(self,p,typ,opt)
	if ismapm(p) and (typ == 'int16' or typ == 'int32' or typ == 'int64') then
		self:setmapm(p)
		return true
	end
end

function getter(self,typ,opt)
	if typ == 'int16' or typ == 'int32' or typ == 'int64' then
		return true,self:getmapm()
	end
end

xsqlvar_class:add_set_handler(setter)
xsqlvar_class:add_get_handler(getter)

