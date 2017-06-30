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
	ngx.say( [[{"status":"-1","data":"post"}]])  
	ngx.exit(ngx.HTTP_FORBIDDEN)
end

if not keys["col"] or keys["col"] == "*" then
	ngx.say( [[{"status":"-1","data":"col"}]]) 
	ngx.exit(ngx.HTTP_FORBIDDEN)
end

if not keys["values"] or keys["values"] == "*" then
	ngx.say( [[{"status":"-1","data":"values"}]]) 
	ngx.exit(ngx.HTTP_FORBIDDEN)
end

sql = "insert into " .. table .. "(" .. keys["col"] .. ") values(" .. keys["values"] .. ");" 


--ngx.say(sql)
local res = ngx.location.capture("/my_lua", {
	method = ngx.HTTP_POST, body = sql})

if res.status == 200 then  
	ngx.say([[{"status":"1","data":"]] .. res.body .."\"}" )
else
	ngx.say( [[{"status":"-1","data":"]] .. res.status .."\"}")  
end
