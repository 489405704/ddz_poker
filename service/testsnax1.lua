local skynet = require "skynet"
local snax = require "skynet.snax"

--[[
    response 带响应的
    accept 不带响应
    init 初始化
    exit 退出触发

]]

function response.hello(hello)
    skynet.sleep(100)
    return "snax server say "..hello
end

function response.sql(sql)
    return skynet.call("MYSQL_POOLS","lua","execute",sql)
end

function accept.hello()
    skynet.error("some server is say hello")
    skynet.sleep(100)
end

function accept.exit(...)
    snax.exit(...)
end

function init(str)
    skynet.error("-----testsnax is start and say "..str.."-----")
    snax.enablecluster()
end

function exit(...)
    skynet.error("-----testsnax is exit-----")
end
