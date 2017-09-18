local skynet = require "skynet"
local DB = require "util.logindbutil"

skynet.start(function()
   
    DB.login("yc","123456")


end)
