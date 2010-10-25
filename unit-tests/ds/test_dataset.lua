
local dataset = require 'fbclient.ds.dataset'

local oo = require 'loop.simple'
local dump = require('util').dump
FDS = oo.class({
	keys = {id = true, name = true},
}, dataset)
MDS = oo.class({
	keys = {id = true, name = true},
	foreign_keys = {f = {'f_id','id'}}
}, dataset)
DDS = oo.class({
	keys = {id = true, name = true},
	lookup_key = 'parent_name',
	master_key = 'name',
	detail_key = 'detail',
	detail_index_keys = {id = true, name = true},
}, dataset)

flist = FDS()
mlist = MDS()
dlist = DDS()

mlist:set{id=1,name='X',f_id=2}
mlist:set{id=2,name='Y',f_id=1}
assert(mlist.by.id[1].name == 'X')
assert(mlist.by.id[2].name == 'Y')
assert(mlist.by.name.X.id == 1)
assert(mlist.by.name.Y.id == 2)
flist:set{id=1,name='A'}
flist:set{id=2,name='B'}
assert(mlist.by.id[1].f == nil)
mlist:setforeign('f', flist)
assert(mlist.by.id[1].f.id == 2)
assert(mlist.by.id[2].f.id == 1)
dlist:set{id=1,name='a',parent_name='X'}
dlist:set{id=2,name='b',parent_name='X'}
dlist:set{id=3,name='c',parent_name='Y'}
dlist:set{id=4,name='d',parent_name='Y'}
dlist:setmaster(mlist)
assert(mlist.by.name.X.detail.name.a.id == 1)
assert(mlist.by.name.X.detail.name.b.id == 2)
assert(mlist.by.name.Y.detail.name.c.id == 3)
assert(mlist.by.name.Y.detail.name.d.id == 4)
dump(mlist)
mlist:setforeign('f', nil)
assert(mlist.by.id[1].f == nil)
dlist:setmaster(nil)
assert(next(mlist.by.name.X.detail.name) == nil)
assert(dlist.by.name.d.id == 4)

