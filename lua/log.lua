local cjson = require "cjson"  
--local arg
--                        local request_method = ngx.var.request_method
--                        if request_method == "GET" then
--                                arg = ngx.req.get_uri_args() or 0
--                        elseif request_method == "POST" then
--                                ngx.req.read_body()
--                                arg = ngx.req.get_post_args() or 0
--
--                        end
--local body_json = cjson.encode(arg)
--ngx.say(body_json)
local log_json = {}  
log_json["uri"]=ngx.var.uri  
log_json["args"]=ngx.var.args  
log_json["host"]=ngx.var.host  
log_json["request_body"]=ngx.var.request_body  
--log_json["request_body"]=body_json
--log_json["remote_addr"] = ngx.var.remote_addr  
--log_json["remote_user"] = ngx.var.remote_user  
log_json["time_local"] = ngx.var.time_local  
--log_json["status"] = ngx.var.status  
--log_json["body_bytes_sent"] = ngx.var.body_bytes_sent  
log_json["http_referer"] = ngx.var.http_referer  
log_json["http_user_agent"] = ngx.var.http_user_agent  
log_json["http_x_forwarded_for"] = ngx.var.http_x_forwarded_for  
log_json["upstream_response_time"] = ngx.var.upstream_response_time  
log_json["request_time"] = ngx.var.request_time  
 
local message = cjson.encode(log_json)
 
--ngx.say(message);
local function writefile(filename, info)  
    local wfile=io.open(filename, "a+") 
    --local wfile=io.output(filename, "a") 
    if not wfile then 
        --ngx.say(" open file err!!");
    return
    end        
    wfile:write(info)  
    wfile:write("\r\n")
    wfile:close()  
end  
  

local function is_dir(sPath)  
    if type(sPath) ~= "string" then return false end  
  
    local response = os.execute( "cd " .. sPath )  
    if response == 0 then  
        return true  
    end  
    return false  
end  
  

local file_exists = function(name)  
    local f=io.open(name,"r")  
    if f~=nil then io.close(f) return true else return false end  
end

writefile("/tmp/t.log",message)
