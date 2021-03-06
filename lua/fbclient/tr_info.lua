--[=[
	TR_INFO: request information about an active transaction
	this is the aux. library to encode the request buffer and decode the reply buffer.

	encode(options_t) -> encoded options string
	decode(info_buf, info_buf_len) -> decoded info table

	USAGE:
	- use it with isc_transaction_info() to encode the info request and decode the info result.
	- see info_codes table below for what you can request and the structure and meaning of the results.

]=]

module(...,require 'fbclient.module')

local info 	= require 'fbclient.info'

local info_codes = { --read doc\sql.extensions\README.isc_info_xxx from firebird 2.5 sources for more info!
	isc_info_tra_id						= 4,  --number: current tran ID number
	isc_info_tra_oldest_interesting		= 5,  --number: oldest interesting tran ID when current tran started (firebird 2.0+)
	isc_info_tra_oldest_snapshot		= 6,  --number: min. tran ID of tra_oldest_active (firebird 2.0+)
	isc_info_tra_oldest_active			= 7,  --number: oldest active tran ID when current tran started (firebird 2.0+)
	isc_info_tra_isolation				= 8,  --pair: {one of isc_info_tra_isolation_flags, [one of isc_info_tra_read_committed_flags]}: (firebird 2.0+)
	isc_info_tra_access					= 9,  --string: 'isc_info_tra_readonly' or 'isc_info_tra_readwrite' (firebird 2.0+)
	isc_info_tra_lock_timeout			= 10, --number: lock timeout value; fb 2.0+
}

local info_code_lookup = index(info_codes)

local info_buf_sizes = {
	isc_info_tra_id						= INT_SIZE,
	isc_info_tra_oldest_interesting		= INT_SIZE,
	isc_info_tra_oldest_snapshot		= INT_SIZE,
	isc_info_tra_oldest_active			= INT_SIZE,
	isc_info_tra_isolation				= 1+1, -- for read_commited, you also get rec_version/no_rec_version flag!
	isc_info_tra_access					= 1,
	isc_info_tra_lock_timeout			= INT_SIZE,
}

local isc_info_tra_isolation_flags = {
	isc_info_tra_consistency	= 1,
	isc_info_tra_concurrency	= 2,
	isc_info_tra_read_committed	= 3,
}

local isc_info_tra_read_committed_flags = {
	isc_info_tra_no_rec_version	= 0,
	isc_info_tra_rec_version	= 1,
}

local isc_info_tra_access_flags = {
	isc_info_tra_readonly	= 0,
	isc_info_tra_readwrite	= 1,
}

local decoders = {
	isc_info_tra_id = info.decode_unsigned,
	isc_info_tra_oldest_interesting = info.decode_unsigned,
	isc_info_tra_oldest_snapshot = info.decode_unsigned,
	isc_info_tra_oldest_active = info.decode_unsigned,
	isc_info_tra_isolation = function(s)
		local isolation = info.decode_enum(isc_info_tra_isolation_flags)(s:sub(1,1))
		local read_commited_flag
		if isolation == 'isc_info_tra_read_committed' then
			read_commited_flag = info.decode_enum(isc_info_tra_read_committed_flags)(s:sub(2,2))
		end
		return {isolation, read_commited_flag}
	end,
	isc_info_tra_access = info.decode_enum(isc_info_tra_access_flags),
	isc_info_tra_lock_timeout = info.decode_unsigned,
}

function encode(opts)
	return info.encode('TR_INFO', opts, info_codes, info_buf_sizes)
end

function decode(info_buf, info_buf_len)
	return info.decode('TR_INFO', info_buf, info_buf_len, info_code_lookup, decoders)
end

