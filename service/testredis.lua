local skynet = require "skynet"

function testredis() 
    --keys
    local res1 = skynet.call("REDIS_POOLS","lua","execute","keys","*")
    print("-----print keys-----")
    for _,v in pairs(res1) do
        print(v)
    end

    --hmset
    local t = {}
    t[1] = "username"
    t[2] = "id"
    t[3] = 1
    t[4] = "username"
    t[5] = "yc"
    t[6] = "pass"
    t[7] = "123"
    t[8] = "name"
    t[9] = "yc"
    skynet.call("REDIS_POOLS","lua","execute","hmset",t)

    --hmget
    local t1 = {"username","pass","username","id","name"}
    local res2 = skynet.call("REDIS_POOLS","lua","execute","hmget",t1)
    print("-----print res2-----")
    for k,v in pairs(res2) do
        print(k,v)
    end

    --del
    skynet.call("REDIS_POOLS","lua","execute","del","username")
    

    skynet.exit()
end

skynet.start(testredis)

    

