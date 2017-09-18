local skynet = require "skynet"
local socket = require "skynet.socket"
local mysql = require "util.loginutil"


local CMD = {}
local SOCKET = {}
local gate
local agent = {}




--新建的连接，先验证登录之后再给agent
function SOCKET.open(fd, addr)

    --[[socket.start(fd) 
    local res = socket.readline(fd)
    local username = list[1]
    local passwd = list[2]
    local flag = mysql.login(username,passwd)
    if not flag then
        socket.send(...)
        return
    end
]]
	skynet.error("New client from : " .. addr)
	agent[fd] = skynet.newservice("myagent")
	skynet.call(agent[fd], "lua", "start", { gate = gate, client = fd, watchdog = skynet.self() })
end

local function close_agent(fd)
	local a = agent[fd]
	agent[fd] = nil
	if a then
		skynet.call(gate, "lua", "kick", fd)
		-- disconnect never return
		skynet.send(a, "lua", "disconnect")
	end
end

function SOCKET.close(fd)
	print("socket close",fd)
	close_agent(fd)
end

function SOCKET.error(fd, msg)
	print("socket error",fd, msg)
	close_agent(fd)
end

function SOCKET.warning(fd, size)
	-- size K bytes havn't send out in fd
	print("socket warning", fd, size)
end

function SOCKET.data(fd, msg)
end

function CMD.start(conf)
	skynet.call(gate, "lua", "open" , conf)
end

function CMD.close(fd)
	close_agent(fd)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = SOCKET[subcmd]
			f(...)
			-- socket api don't need return
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)

	gate = skynet.newservice("gate")
end)
