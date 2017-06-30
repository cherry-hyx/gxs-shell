local json = require("cjson")
local method = ngx.var.request_method
local table = ngx.var.do_table
local data = ngx.req.get_body_data()

ngx.say(data)
local keys = json.decode(data)
local sql

ngx.say(keys["col"])
ngx.say(keys["where"])
ngx.say(method)
--for tmp in ipairs(keys)
if keys["col"] == "*" then
	ngx.exit(ngx.HTTP_FORBIDDEN)
end

if method == "POST" then
	ngx.say "asdf"
	sql = "select " .. col .. " from " .. table
	ngx.say(sql)
	if keys["where"] then
	sql = sql ..  "where " .. keys["where"] 
	end
	sql = sql .. ";"
elseif method == "delete" then
	sql = "delete from " .. table
	if not keys["where"] then
		ngx.exit(ngx.HTTP_FORBIDDEN)
	else
		sql = sql ..  "where " .. keys["where"] .. ";"
	end
elseif method == "put" then
	if keys["isupdate"] == "yes" then
		local cols = ""
		for k,v in keys["col"] do
			cols = cols .. v .. "='" .. keys["values"][k] .. "'," 
		end
		upcol = string.sub(cols,1,-2)
		sql = "update from " .. table .. "set " .. upcol 
		if keys["where"] then
			sql = sql ..  "where " .. keys["where"] 
		end
		sql = sql .. ";"
	else 
		local sql = "insert into " .. table .. "(" .. keys["col"] .. ") values(" .. keys["values"] .. ");" 
	end
end

ngx.say(sql)