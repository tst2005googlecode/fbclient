
package.path = '../../lua/?.lua;'..package.path

local tuple = require 'fbclient.ds.tuple'

t1 = tuple(1,0/0,3)
t2 = tuple(1,0/0,3)
t3 = tuple(nil,2)
t4 = tuple(2,nil)
t5 = tuple()
t6 = tuple(nil)

assert(t1 ~= t2) --no matter how many times you compute it, 0/0 always ends up different :)
assert(t1 == t1) --Lua compares pointers first
assert(t1.n == 3, t1.n)
assert(t2.n == 3, t1.n)
assert(t3.n == 2, t3.n)
assert(t1 ~= t3, t1.n..'\t'..t3.n)
assert(t3 ~= t4, t3.n..'\t'..t4.n)
assert(t5 ~= t6)
assert(t5 == tuple())
assert(t6 == tuple(nil))

print(t1)
print(t2)
print(t3)
print(t4)
print(t5)
print(t6)

