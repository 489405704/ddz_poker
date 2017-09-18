local skynet = require "skynet"
local sprotoluader = require "sprotoloader"
local snax = require "skynet.snax"

-- to test sanxtest server
function testsanx()

end

skynet.start(function()
    
    skynet.error("-----server start-----")
    
   --[[ local console = skynet.newservice("console")
    skynet.newservice("debug_console",8000)
]]
    local watchdog = skynet.newservice("mywatchdog")
    skynet.call(watchdog,"lua","start",{
        port = 8888,
        maxclient = 64,
        nodelay = true,
    })

    skynet.error("watchdog listen on",8888)
--    skynet.newservice("testlogin")
    --local mysql_pools = skynet.newservice("mysql_pools")
    --skynet.send(mysql_pools,"lua","start")
    --skynet.newservice("testmysql")
    --skynet.newservice("redis_pools")
    --skynet.send("REDIS_POOLS","lua","start")
    skynet.sleep(100)
    --skynet.newservice("testredis")
    
    --[[ps = snax.newservice("testsnax1","hello world")
    print(ps.req.hello("I'm YC"))
    local sqlstr = "select * from testuser where number=500"
    local res = ps.req.sql(sqlstr)
    for _,v in pairs(res) do
        for k1,v1 in pairs(v) do
            print(k1,v1)
        end
    end
    ps.post.hello()

    --exit
    ps.post.exit()
]]
    skynet.newservice("login")
    skynet.exit()
end)
