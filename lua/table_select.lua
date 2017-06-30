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

comm = args["comm"]
col = args["col"]
where = args["where"]
limit = args["limit"]



--delete table 
local json = require("cjson")
--local method = ngx.var.request_method
local table = ngx.var.do_table
local data = ngx.req.get_body_data()
--local args = ngx.req.get_uri_args()

--ngx.say(data)
local keys = json.decode(data)
local sql

if not method == "POST" then
	ngx.exit(ngx.HTTP_FORBIDDEN)
end

if not keys["col"] or keys["col"] == "*" then
	ngx.exit(ngx.HTTP_FORBIDDEN)
end

if not keys["where"] then
	ngx.exit(ngx.HTTP_FORBIDDEN)
else
	sql =  "select " .. keys["col"] .. " from " .. table ..  " where " .. keys["where"] .. ";"
end

ngx.say(sql)
local res = ngx.location.capture("/my_lua", {
	method = ngx.HTTP_POST, body = sql})

if res.status == 200 then  
	ngx.say([[{"status":"1","data":"]] .. res.body .."\"}" )
else
	ngx.say( [[{"status":"-1","data":"]] .. res.status .."\"}")  
end
