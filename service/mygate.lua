local skynet = require "skynet"
local gateserver = require "gateserver"
local netpack = require "skynet.netpack"

local watchdog
local connection = {}
local forwarding = {}

skynet.register_protocol {
    name = "client",
    id = skynet.PTYPE_CLIENT,
}


function handler.connect(fd,ipaddr)
    skynet.error("------connect from [%d]-----",ipaddr)
    local c = {
        fd = fd,
        ip = addr,
    }
    connection[fd] = c
    skynet.send(watchdog,"lua","socket","open",fd,ipaddr)
end

local function unforward(c)
    if c.agent then
        forwarding[c.agent] = nil
        c.agent = nil
        c.client = nil
    end
end

local function close_fd(fd)
    local c = connection[fd]
    if c then
        unforward(c)
        connection[fd] = nil
    end
end

function handler.disconnect(fd)
    close_fd(fd)
    skynet.send(watchdog,"lua","socket","close",fd)
end

function handler.error(fd,msg)
    close_fd(fd)
    skynet.send(watchdog,"lua","socket","error",fd,msg)
end


--开启网关时触发
function handler.open(source,conf)
    watchdog = conf.watchdog or source
    skynet.error("-----Gateway open source[%d]-----",source)
end

function handler.message(fd,msg,sz)
    --拿到连接信息
    local c = connection[fd]
    local agent = c.agent
    if agent then
        --有代理转发到代理
        skynet.redirect(agent,client,"client",1,msg,size)
    else
        skynet.send(watchdog,"lua","socket","data",fd,netpack.tostring(msg,sz))
    end

end

function handler.warning(fd,size)
    skynet.send(watchdog,"lua","socket","warning",fd,size)
end

local CMD = {}

function CMD.forward(source,fd,client,address)
    local c = assert(connection[fd])
    unforward(c)
    c.client = client or 0
    c.agent = address or source
    forwarding[c.agent] = c

    --允许fd开始接收消息
    gateserver.openclient(fd)
end

function CMD.kick(source,fd)
    gateserver.closeclient(fd)
end

function handler.command(cmd,source,...)
    local f = assert(CMD[cmd])
    return f(source,...)
end

gateserver.start(handler)

