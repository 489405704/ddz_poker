local skynet = require "skynet"
local redis = require "skynet.db.redis"
require "skynet.manager"

local M = {}
local CMD = {}
local maxconnect = 10
local connect_pool = {}

local redis_conf = {
    host = "127.0.0.1",
    port = "6379",
    db = 0
}

function CMD.start(connect_num) 
    local connect_nums = connect_num or maxconnect 
    print(connect_nums)
    for i=1,connect_nums do
        local db = redis.connect(redis_conf)
        if not db then
            print("connect redisdb "..i.." error")
        end
        if db then
            --连接的两个参数，一个是连接，一个是表示是否被占用,true表示可以用
            local pool = {}
            pool.db = db
            pool.flag = true
            pool.id = i
            table.insert(connect_pool,i,pool)
        end
    end

end

function get_connect()
    print("-----get_connect-----")
    for i=1,5 do
        for i=1,#connect_pool do
            pool = connect_pool[i] 
            if pool.flag then
                connect_pool[i].flag = false
                print("get connect "..pool.id)
                return pool 
            end
            print("connect "..pool.id.." faild")
        end
       
        --全都被占用进行等待
        print("waiting for connect in 1s...")
        skynet.sleep(100) 
    end
    --没有拿到
    return nil 
end

function flush_connect(pool)
    print(connect_pool[1].flag)
    print("-----flush_connect-----")
    local index = pool.id
    connect_pool[index].flag = true
    print(connect_pool[1].flag)
end

--开启查询
function CMD.execute(subcmd,...)
    local pool = get_connect()
    
    local res = M[subcmd](pool.db,...)
    print(res)
    flush_connect(pool)
    return res
end
------------------------------------------------------
--具体redis执行方法   subcmd

--set
function M.set(db,key,value)
    return db:set(key,value)
end

--get
function M.get(db,key)
    return db:get(key)
end

--hset
function M.hset(db,key,field,value)
    return db:hset(key,field,value) 
end

--hmset
function M.hmset(db,t)
    return db:hmset(t)
end

--hget
function M.hget(db,key,field)
    return db:hget(key,field)
end

--hmget
function M.hmget(db,...)
    return db:hmget(...)
end

--hdel
function M.hdel(db,key,field)
    return db:hdel(key,field)
end

--hvals
function M.hvals(db,key)
    return db:hvals(key)
end

--hgetall
function M.hgetall(db,key)
    return db:hgetall(key)
end

--keys
function M.keys(db,key)
    return db:keys(key)
end

--del
function M.del(db,key)
    return db:del(key)
end

-----------------------------------------------------

function dispatch(session,source,cmd,...)
   local f = assert(CMD[cmd]) 
   local result = f(...)
   print("result is",result)

   if result ~= nil then
       skynet.error("-----reids be come result-----")
       skynet.ret(skynet.pack(result))
   end
end

skynet.start(function()
    skynet.error("-----start redis_pool-----")    
    skynet.dispatch("lua",dispatch)

    skynet.register "REDIS_POOLS"    
end)



