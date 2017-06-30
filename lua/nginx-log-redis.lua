local redis = require("resty.redis")  
local cjson = require("cjson")  
local cjson_encode = cjson.encode  
local ngx_log = ngx.log  
local ngx_ERR = ngx.ERR  
local ngx_exit = ngx.exit  
local ngx_print = ngx.print  
local ngx_re_match = ngx.re.match  
local ngx_var = ngx.var  

local function close_redis(red)  
    if not red then  
        return  
    end  
    --释放连接(连接池实现)  
    local pool_max_idle_time = 10000 --毫秒  
    local pool_size = 100 --连接池大小  
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)  
  
    if not ok then  
        ngx_log(ngx_ERR, "set redis keepalive error : ", err)  
    end  
end  
local function wlist_redis(message)  
    local red = redis:new()  
    red:set_timeout(1000)  
    local ip = "192.168.10.243"  
    local port = 6379  
    local ok, err = red:connect(ip, port)  
    if not ok then  
        ngx_log(ngx_ERR, "connect to redis error : ", err)  
        return close_redis(red)  
    end  
  
    local resp, err = red:lpush("ngxlog",message)  
    if err then  
        ngx_log(ngx_ERR, "write redis content error : ", err)   
    end  
    close_redis(red)
end  
  
function isnil(value)
    if value == nil then
        value = "-"
    end
    return value
end

local arg

local request_method = ngx_var.request_method
if request_method == "GET" then
    arg = ngx.req.get_uri_args()["member_id"] or 0
elseif request_method == "POST" then
    ngx.req.read_body()
    arg = ngx.req.get_post_args() or 0
end

local body_json = cjson_encode(arg)

local log_json = {}  
log_json["uri"]=isnil(ngx_var.uri)
log_json["args"]=isnil(ngx_var.args) 
log_json["host"]=isnil(ngx_var.host)
--log_json["request_body"]=isnil(ngx_var.request_body)  
log_json["request_body"]=body_json
--log_json["remote_addr"] = ngx.var.remote_addr  
--log_json["remote_user"] = ngx.var.remote_user
log_json["time_local"] = isnil(ngx_var.time_local)
--log_json["status"] = ngx.var.status  
--log_json["body_bytes_sent"] = ngx.var.body_bytes_sent  
log_json["http_referer"] = isnil(ngx_var.http_referer)
log_json["http_user_agent"] = isnil(ngx_var.http_user_agent)
log_json["http_x_forwarded_for"] = isnil(ngx_var.http_x_forwarded_for)
log_json["upstream_response_time"] = isnil(ngx_var.upstream_response_time)
log_json["request_time"] = isnil(ngx_var.request_time)  
     
local message = cjson_encode(log_json)  

wlist_redis(message) 