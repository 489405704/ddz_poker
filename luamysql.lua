package.path = "skynet/lualib/?.lua"

local mysql = require "skynet.db.mysql"


local mysql_conf = {
    host = "127.0.0.1",
    port = "3306",
    database = "test",
    user = "yc",
    password = "yc@123456",
    max_packet_size = 1024,
    on_connect = on_connect
}

function execute(first,last)
    local db = mysql.connect(mysql_conf)
    
    for i=first,last do
        local querystr = "insert into testuser(number,time) values("..i..",\'"..os.date("%Y-%m-%d %H:%M:%S").."\')"
        db:query(querystr)
        print(querystr)
    end
    db:disconnect()
end

function myThread()

    for i=1,10 do
        first = (i-1)*100000+1
        last = i*100000
        local co = coroutine.create(execute(first,last))
        coroutine.resume(co)
    end

end

myThread()
