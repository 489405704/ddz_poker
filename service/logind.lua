local login = require "snax.loginserver"
local skynet = require "skynet"


local server = {
    host = "127.0.0.1",
    port = "10001",
    --false   do not allowd login people more than 2
    multilogin = false,
    name = "login_master"

}


function server.auth_handler(token)
    
    local user,server,password = token:match("([^@]+)@([^:]+):(.+)")
    print(user,server,password)

    --simple auth, do better later
    assert(password == "password","Invalid password")
    return server, user

end

function server.login_handler(server,uid,secret)
    print(string.format("%s@%s is login, secret is %s",uid,server,crypt.hexencode(secret)))
    local gameserver = assert(server_list[server],"unknown server")
    local last = user_online[uid]
    --踢掉最后一个登录的用户
    if last then
        skynet.call(last.address,"lua","kick",uid,last.subid)
    end

    if user_online[uid] then
        --如果任然在线
        error(string.format("user %s is already online",uid))
    end

    local subid = tostring(skynet.call(gameserver,"lua","login",uid,secret))
    user_online[uid] = {address = gameserver,subid = subid,server = server}
    return subid
end

local CMD = {}

function CMD.register_gate(server,address)
    server_list[server] = address
end

--从msg中调用登出一个用户
function CMD.logout(uid,subid)
    local u = user_online[uid]
    if u then
        print(string.format("%s@%s is logout",uid,u.server))
        user_online[uid] = nil
    end
end

function server.command_handler(command,...)
    local f = CMD[command]
    return f(...)
end

login(server)
