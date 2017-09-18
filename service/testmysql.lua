local skynet = require "skynet"

function testsql()
    local querystr = "select * from user where username=\'yc\'"
    local res = skynet.call("MYSQL_POOLS","lua","execute",querystr)
    print(res)
    for _,v in pairs(res) do
        for k,v in pairs(v) do
            print(k,v)
        end
    end
end

function testsql1(i,j)
    for a=i,j do
        local querystr = "insert into testuser(number,time) values("..a..",\'"..os.date("%Y-%m-%d %H:%M:%S").."\')"
        local res = skynet.send("MYSQL_POOLS","lua","execute",querystr)
        --skynet.sleep(10)是中断该服务进程的？所以全中断了，而不是中断一个fork:
    end
end

skynet.start(function()
--    skynet.send("MYSQL_POOLS","lua","insert100")
--    testsql1(1,500)
--    skynet.exit()
end)
