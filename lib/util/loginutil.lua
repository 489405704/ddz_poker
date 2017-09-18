local mysql = require "skynet.db.mysql"

local M = {}

local CMD = {}
local db


function connect()

    local function on_connect(db)
        db:query("set charset utf8")
    end

    db = mysql.connect({
        host = "127.0.0.1",
        port = 3306,
        database = "poker",
        user = "yc",
        password = "yc@123465",
        on_connect = onconnect
    })

    if not db then
        print("connect mysql failed")
    end

end

function M.login(username,passwd)

    connect()
    res = db:query("select * from account where username="..username) 

    for _,v in ipairs(res) do
        username = v["username"]
        password = v["passwd"]
    end

    if passwd ~= password then
        db:disconnect()
        return false
    end
    
    db:disconnect()
    return true

end
