local redis = require "skynet.db.redis"
local mysql = require "skynet.db.mysql"

local M = {}

local redis_conf = {
    host = "127.0.0.1",
    port = 6379,
    db = 0
}

local mysql_conf = {
    host = "127.0.0.1",
    port = "3306",
    database = "poker",
    user = "yc",
    password = "yc@123456",
    max_packet_size = 1024,
    on_connect = on_connect
}


local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    --返回key的值
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    --返回value的值
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

local function on_connect(db)
    db:query("set charset utf8")
end

local function get_redis_username(usernamefirst)
    
    local db = redis.connect(redis_conf)
    if not db then
        print("failed to connect redis")
    end
    --alias key flat1 flat2 ...
    local res = db:hmget("yc","username","pass")
    for k,v in ipairs(res) do
        print("k "..k)
        print("v "..v)
    end
    if res ~= nil then
        db:disconnect()
        return res[1],res[2]
    end
    print("redis is nil")
    db:disconnect()
    return nil
end

--当调用这个函数表示在redis中找不到，所以顺便写入redis
local function get_mysql_username(usernamefirst)
    
   local db = mysql.connect(mysql_conf) 
    if not db then
        print("failed to connect mysql")
    end

    querystr = "select * from user where username=\'"..usernamefirst.."\'"
    print(querystr)
    local res = db:query(querystr)

    if res == nil then
        --mysql中也不存在直接返回
        return nil 
    end
    for k,v in pairs(res) do
        for k1,v1 in pairs(v) do
            id = v["id"]
            username = v["username"]
            pass = v["pass"]
            name = v["name"]
        end
    end
    
    --write in redis
    local redis_db = redis.connect(redis_conf)

    local t = {}
    for k,v in pairs(res) do
        for k1,v1 in pairs(v) do 
            table.insert(t,k1)
            table.insert(t,v1)
        end
    end
    --[[for _,v in ipairs(t) do
        print(v)
    end]]
    redis_db:hmset(username,table.unpack(t))
    return username,pass 

end

function M.login(username,passwd)
    print(username)
    local username1,pass1 = get_redis_username(username)
    print("redis result:",username1,pass1)
    if username1 == nil and pass1 == nil then
       local username1,pass1 = get_mysql_username(username)
       print("mysql result:",username1,pass1)
    end
end


return M
