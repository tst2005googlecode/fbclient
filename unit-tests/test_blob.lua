--[[
	Test unit for blob.lua

]]

local config = require 'test_config'

local fb = require 'fbclient.class'
local asserts = (require 'fbclient.util').asserts

function test_everything(env)

	local at = env:create_test_db()

	local function gen_s(len)
		local t = {}
		for i=1,len do
			t[#t+1] = string.char(math.random(('a'):byte(), ('z'):byte()))
		end
		return table.concat(t)
	end
	local blob_segments = {
		gen_s(2^16-1),
		gen_s(0),
		gen_s(1),
		gen_s(255),
		gen_s(3*(2^16-1)),
	}

	local s = table.concat(blob_segments)

	at:exec_immediate('create table test(c blob sub_type binary)')
	tr:exec('insert into test(c) values (?)')

	local trh = api.tr_start(fbapi, sv, dbh)
	local bpb = {
		isc_bpb_type = 'isc_bpb_type_segmented',
		isc_bpb_storage = 'isc_bpb_storage_main',
	}
	for i,v in ipairs(t) do
		fbclient.blob.write(fbapi,sv,bh,v,2048) -- write in 2K segments
	end
	fbclient.blob.close(fbapi,sv,bh)

	exec(trh, 'insert into test(c) values (?)',
		function(i,xs)
			xs:write('1234567890abcdefghijklmnopqrstuvwxyz')
			xs:close()
			assert(xs:closed())
		end
	)

	api.tr_commit(fbapi, sv, trh)

	local trh = api.tr_start(fbapi, sv, dbh)
	local rows = exec(trh,'select f from t_blob')
	local segments = {}
	for seg in rows[1][1]:segments() do
		segments[#segments+1] = seg
	end
	assert(rows[1][1]:closed())
	asserteq(s,table.concat(segments))
	local bid = rows[1][1]:getblobid()

	local bh = fbclient.blob.open(fbapi,sv,dbh,trh,bid)
	local binfo = fbclient.blob.info(fbapi,sv,bh,{
		isc_info_blob_total_length=true,
		isc_info_blob_max_segment=true,
		isc_info_blob_num_segments=true,
		isc_info_blob_type=true,
	})
	print'BLOB info:'; dump(binfo)
	asserteq(binfo['isc_info_blob_total_length'],#s)
	asserteq(binfo['isc_info_blob_max_segment'],2048)
	asserteq(binfo['isc_info_blob_num_segments'],130)
	asserteq(binfo['isc_info_blob_type'],'isc_bpb_type_segmented')

	local segments = {}
	for seg in fbclient.blob.segments(fbapi,sv,bh,1024) do --read in 1K chunks
		segments[#segments+1] = seg
	end
	asserteq(s,table.concat(segments))
	fbclient.blob.close(fbapi,sv,bh)
	api.tr_commit(fbapi, sv, trh)
end


local function test_stream_blobs()
	local s = '1234567890abcdefghijklmnopqrstuvwxyz'
	local max_seg = 1

	commit('create table t_stream_blob(f blob sub_type binary)')
	local trh = api.tr_start(fbapi, sv, dbh)
	local bpb = {
		isc_bpb_type = 'isc_bpb_type_stream',
		isc_bpb_storage = 'isc_bpb_storage_main',
	}
	local bh,bid = fbclient.blob.create(fbapi,sv,dbh,trh,bpb)
	fbclient.blob.write(fbapi,sv,bh,s,max_seg) --write in max_seg byte segments: prove later it don't matter.
	fbclient.blob.close(fbapi,sv,bh)

	bh = fbclient.blob.open(fbapi,sv,dbh,trh,bid)

	local binfo = fbclient.blob.info(fbapi,sv,bh,{
		isc_info_blob_total_length=true,
		isc_info_blob_max_segment=true,
		isc_info_blob_num_segments=true,
		isc_info_blob_type=true,
	})
	print'BLOB info:'; dump(binfo)
	asserteq(binfo['isc_info_blob_num_segments'],math.ceil(#s/max_seg))
	asserteq(binfo['isc_info_blob_total_length'],#s)
	asserteq(binfo['isc_info_blob_max_segment'],math.min(max_seg,#s))
	asserteq(binfo['isc_info_blob_type'],'isc_bpb_type_stream')

	--TODO: test seek() if it will ever work
	--[[
	asserteq(fbclient.blob.seek(fbapi,sv,bh,-37,'blb_seek_from_tail'),1)
	asserteq(fbclient.blob.seek(fbapi,sv,bh,0,'blb_seek_relative'),1)
	asserteq(fbclient.blob.read_segment(fbapi,sv,bh,10),'1234567890') --prove that segmentation don't matter!
	asserteq(fbclient.blob.seek(fbapi,sv,bh,11),11)
	asserteq(fbclient.blob.read_segment(fbapi,sv,bh,2),'ab')
	asserteq(fbclient.blob.seek(fbapi,sv,bh,3,'blb_seek_relative'),13)
	asserteq(fbclient.blob.read_segment(fbapi,sv,bh,3),'efg')
	asserteq(fbclient.blob.seek(fbapi,sv,bh,-26,'blb_seek_from_tail'),10)
	asserteq(fbclient.blob.seek(fbapi,sv,bh,-3,'blb_seek_from_tail'),33)
	asserteq(fbclient.blob.read_segment(fbapi,sv,bh,3),'xyz')
	print((fbclient.blob.read_segment(fbapi,sv,bh)))
	print((fbclient.blob.read_segment(fbapi,sv,bh)))

	asserteq(fbclient.blob.seek(fbapi,sv,bh,1),1)
	]]

	local segments = {}
	for seg in fbclient.blob.segments(fbapi,sv,bh,1024) do --read in 1024 byte chunks
		segments[#segments+1] = seg
	end
	fbclient.blob.close(fbapi,sv,bh)
	api.tr_commit(fbapi, sv, trh)
	asserteq(#segments,1) -- prove that a stream doesn't have segments should the buffer be long enough
	asserteq(table.concat(segments),s)

	at:close()
end

--local comb = {lib='fbclient',ver='2.5rc3',server_ver='2.1.3'}
config.run(test_everything,comb,nil,...)

