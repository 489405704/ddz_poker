local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
require "skynet.manager"

local M = {}
local CMD = {}
local maxconnect = 5
--前两个用于写操作，其余的用于读操作
local connect_pool = {}
local poolTime
local mysql_conf = {
    host = "127.0.0.1",
    port = "3306",
    database = "test",
    user = "yc",
    password = "yc@123456",
    max_packet_size = 1024,
    on_connect = on_connect
}

function CMD.start(connect_num) 
    local connect_nums = connect_num or maxconnect 
    for i=1,connect_nums do
        local db = mysql.connect(mysql_conf)
        if not db then
            print("connect mysqldb "..i.." error")
        end
        if db then
            db:query("set charseet utf8")
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
    while true do
        for i=1,#connect_pool do
            pool = connect_pool[i] 
            if pool.flag then
                connect_pool[i].flag = false
                print("get connect "..pool.id)
                return pool 
            end
        end
       
        --全都被占用进行等待
        print("waiting for connect in 1s...")
        skynet.sleep(100) 
    end
    --没有拿到
    return nil 
end

function flush_connect(pool)
    print("-----flush_connect-----")
    local index = pool.id
    connect_pool[index].flag = true
end

--开启事务
function M:begin(db)
    db:query("begin")
end
--提交事务
function M:commit(db)
    db:query("commit")
end
--回滚事务
function M:rollback(db)
    db:query("rollback")
end

function testsql1(thread,i,j)
    for a=i,j do
        local querystr = "insert into testuser(number,time) values("..a..",\'"..os.date("%Y-%m-%d %H:%M:%S").."\')"
        local res = CMD.execute(querystr) 
        print("thread : "..thread.." "..querystr)
        --skynet.sleep(10)是中断该服务进程的？所以全中断了，而不是中断一个fork:
    end
end

function CMD.insert100()
    beginTime = os.date()
    for i=1,10 do
        first = (i-1)*100000+1
        last = i*100000
        skynet.fork(testsql1(i,first,last))
    end
    endTime = os.date()
    print("consuming time is :"..os.date("%M:%S",endTime-beginTime))
end

function CMD.execute(sql)
    skynet.error("-----sql begin-----")
    local pool = get_connect()
    --local pool2 = get_connect()
    --local pool3 = get_connect()
    local db = pool.db
    local res = db:query(sql)
    print(sql)
    flush_connect(pool) 
    return res
end

function dispatch(session,source,cmd,...)
   local f = assert(CMD[cmd]) 
   local result = f(...)

   if result ~= nil then
       skynet.error("-----mysql be come result-----")
       skynet.ret(skynet.pack(result))
   end
end


skynet.start(function()
    skynet.error("-----start mysql_pool-----")   
    skynet.dispatch("lua",dispatch)
    skynet.register "MYSQL_POOLS"    
end)
