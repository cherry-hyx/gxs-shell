local json = require("cjson")
--local method = ngx.var.request_method
local table = ngx.var.do_table
local data = ngx.req.get_body_data()
--local args = ngx.req.get_uri_args()

ngx.header.content_type="application/json;charset=utf8"

--ngx.say(data)
local keys = json.decode(data)
local sql

if not method == "POST" then
	ngx.exit(ngx.HTTP_FORBIDDEN)
end

if not keys["col"] or keys["col"] == "*" then
	ngx.exit(ngx.HTTP_FORBIDDEN)
end

if not keys["values"] or keys["values"] == "*" then
	ngx.exit(ngx.HTTP_FORBIDDEN)
end

if not #(keys["col"]) == #(keys["values"]) then
	ngx.exit(ngx.HTTP_FORBIDDEN)
end	

function Split(szFullString, szSeparator)  
local nFindStartIndex = 1  
local nSplitIndex = 1  
local nSplitArray = {}  
while true do  
   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
   if not nFindLastIndex then  
    nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
    break  
   end  
   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
   nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
   nSplitIndex = nSplitIndex + 1  
end  
return nSplitArray  
end 

if not keys["where"] then
	ngx.exit(ngx.HTTP_FORBIDDEN)
else
	local cols = ""
	--ngx.say(keys["col"])
	--ngx.exit(ngx.HTTP_FORBIDDEN)
	local keycol = Split(keys["col"], ',')
	local keyval = Split(keys["values"], ',')
	for i=1, #keycol do
		cols = cols .. keycol[i] .. "=" .. keyval[i] .. ","
	end
	upcol = string.sub(cols,1,-2)
	sql = "update " .. table .. " set " .. upcol ..  " where " .. keys["where"] ..";"
end

--ngx.say(sql)
local res = ngx.location.capture("/my_lua", {
		method = ngx.HTTP_POST, body = sql})

if res.status == 200 then  
	ngx.say([[{"status":"1","data":"]] .. res.body .."\"}" )
else
	ngx.say( [[{"status":"-1","data":"]] .. res.status .."\"}")  
end
