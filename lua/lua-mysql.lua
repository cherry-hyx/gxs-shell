local request_method = ngx.var.request_method
local args = nil
local param = nil
local param2 = nil
--获取参数的值
if "GET" == request_method then
    args = ngx.req.get_uri_args()
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
end

--param = "/tmp/" .. args["code"] .. ".json"
comm = args["comm"]
key = args["key1"]
bin = args["bin"]
endnum = args["end"]

if pcall(function_name, ….) then
-- no error
ngx.say(ERR)
else
-- some error
    ngx.say(ERR)
end

local mysql = require "resty.mysql"
local db, err = mysql:new()
if not db then
    ngx.say("failed to instantiate mysql: ", err)
    return ngx.NGX_ERROR
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
    host = "10.172.40.203",
    port = 3306,
    database = "stocksir",
    user = "root",
    password = "123456!@#",
    max_packet_size = 1024 * 1024 }

if not ok then
    ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    return ngx.NGX_ERROR
end

--ngx.say("connected to mysql.")

res, err, errcode, sqlstate =
    db:query("SET NAMES UTF8", 10)
if not res then
    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    return ngx.NGX_ERROR
end
--res, err, errcode, sqlstate =
--    db:query("insert into cats (name) "
--            .. "values (\'Bob\'),(\'\'),(null)")
--if not res then
--    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
--    return
--end

--ngx.say(res.affected_rows, " rows inserted into table cats ",
--        "(last insert id: ", res.insert_id, ")")
-- run a select query, expected about 10 rows in
-- the result set:
res, err, errcode, sqlstate =
    db:query("select * from stock_version", 10)
if not res then
    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    return ngx.NGX_ERROR
end

local cjson = require "cjson"
cjson.encode_empty_table_as_object(false)
ngx.say("result: ", cjson.encode(res))
-- put it into the connection pool of size 100,
-- with 10 seconds max idle timeout
local ok, err = db:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return ngx.NGX_ERROR
end

-- or just close the connection right away:
-- local ok, err = db:close()
-- if not ok then
--     ngx.say("failed to close: ", err)
--     return
-- end
