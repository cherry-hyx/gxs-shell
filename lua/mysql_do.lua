local mysql = require "resty.mysql"
local db, err = mysql:new()
if not db then
    ngx.say("failed to instantiate mysql: ", err)
    return
end
function decodeURI(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function SubUTF8String(s, n)    
    local dropping = string.byte(s, n+1)    
    if not dropping then return s end    
    if dropping >= 128 and dropping < 192 then    
        return SubUTF8String(s, n-1)    
    end    
    return string.sub(s, 1, n)    
end

function tounicode(decimal)
  local bytemarkers = { {0x7FF,192}, {0xFFFF,224}, {0x1FFFFF,240} }
  if decimal<128 then return string.char(decimal) end
  local charbytes = {}
  local charorder={}
  for bytes,vals in ipairs(bytemarkers) do
    if decimal<=vals[1] then
      for b=bytes+1,2,-1 do
        local mod = decimal%64
        decimal = (decimal-mod)/64
        charbytes[b] = string.char(128+mod)
        charorder[b]=128+mod
      end
      charbytes[1] = string.char(vals[2]+decimal)
      charorder[1]=vals[2]+decimal
      break
    end
  end
  return table.concat(charbytes)
end

db:set_timeout(1000) -- 1 sec

-- or connect to a unix domain socket file listened
-- by a mysql server:
--     local ok, err, errcode, sqlstate =
--           db:connect{
--              path = "/path/to/mysql.sock",
--              database = "ngx_test",
--              user = "ngx_test",
--              password = "ngx_test" }

local ok, err, errcode, sqlstate = db:connect{
    host = "127.0.0.1",
    port = 3306,
    database = "db_temp",
    user = "root",
    password = "123456!@#",
    charset = utf8,
    max_packet_size = 1024 * 1024 }

if not ok then
    ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    return
end

--ngx.say("connected to mysql.")

res, err, errcode, sqlstate =
    db:query(ngx.var.arg_sql, 10)
if not res then
    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    return
end

local cjson = require "cjson"
ngx.say("result: ", cjson.encode(res))

-- put it into the connection pool of size 100,
-- with 10 seconds max idle timeout
local ok, err = db:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end

-- or just close the connection right away:
-- local ok, err = db:close()
-- if not ok then
--     ngx.say("failed to close: ", err)
--     return
-- end