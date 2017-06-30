local mysql = require "resty.mysql"
local db, err = mysql:new()
local data = ngx.req.get_body_data()
if not data then
	ngx.say("bad request: : no sql!!!")
	return	
end
if not db then
    ngx.say("failed to instantiate mysql: ", err)
    return
end
function decodeURI(s)
    s = string.gsub(s, "%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

local function unicode_to_utf8(convertStr) 
	if type(convertStr)~="string" then 
		return convertStr end 
	local bit = require("bit") 
	local resultStr="" 
	local i=1 
	while true do 
		local num1=string.byte(convertStr,i) 
		local unicode 
		if num1~=nil and string.sub(convertStr,i,i+1)=="\\u" then 
			unicode=tonumber("0x"..string.sub(convertStr,i+2,i+5)) i=i+6 
		elseif num1~=nil then 
			unicode=num1 i=i+1 
		else
		 break 
		end 
		if unicode <= 0x007f then 
			resultStr=resultStr..string.char(bit.band(unicode,0x7f)) 
		elseif unicode >= 0x0080 and unicode <= 0x07ff then 
			resultStr=resultStr..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f))) 
			resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f))) 
		elseif unicode >= 0x0800 and unicode <= 0xffff then 
			resultStr=resultStr..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f))) 
			resultStr=resultStr..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f))) 
			resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f))) 
		end 
	end resultStr=resultStr..'\0'
	return resultStr 
end

db:set_timeout(1000) -- 1 sec

local ok, err, errcode, sqlstate = db:connect{
    host = "127.0.0.1",
    port = 3306,
    database = "db_temp",
    user = "root",
    password = "123456!@#",
    pool = "localpool",
    max_packet_size = 1024 * 1024 }

if not ok then
    ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    return
end
--SET character_set_client = utf8;
--SET character_set_results = utf8;
--SET character_set_connection = utf8;

res, err, errcode, sqlstate =
        db:query("SET NAMES UTF8", 10)
if not res then
    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    return
end

--local url = require "resty.core.uri.lua"
--ngx.say(ngx.var.arg_sql)
--ngx.say("ttt")

--ngx.say(ngx.unescape_uri(ngx.var.arg_sql))
--ngx.say("ttt")
--ngx.say(unicode_to_utf8(ngx.var.arg_sql))
--ngx.say("ttt")
res, err, errcode, sqlstate =
	db:query(data, 10)
if not res then
    res = {}
    --return
end
local cjson = require "cjson"
cjson.encode_empty_table_as_object(false)
ngx.say(cjson.encode(res))
-- put it into the connection pool of size 100,
-- with 10 seconds max idle timeout
local ok, err = db:set_keepalive(10000, 100)
if not ok then
    ngx.say(cjson.encode({}))
    return
end
