root = "./skynet/"
thread = 8
harbor = 0
logger = nil
logpath = "."
start = "main"
bootstrap = "snlua bootstrap"
luaservice = root.."service/?.lua;"  --..root.."test/?.lua;"..root.."examples/?.lua"
lualoader = root.."lualib/loader.lua"
lua_path = "./lib/?.lua;"..root.."lualib/?.lua;"..root.."lualib/?/init.lua"
lua_cpath = root.."luaclib/?.so"

snax = "./service/?.lua;"..root.."examples/?.lua;"..root.."test/?.lua"

cpath = root.."cservice/?.so"

--our patch
luaservice = "./service/?.lua;./service/?/main.lua;"..luaservice
cluster = "./service/clustername.lua"
