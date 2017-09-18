local mysql = require "skynet.db.mysql"

local M = {}

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

function M:execute(db,sql)
    return db:query(sql)
end






