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
local function read_redis(id)  
    local red = redis:new()  
    red:set_timeout(1000)  
    local ip = "192.168.10.243"  
    local port = 6379  
    local ok, err = red:connect(ip, port)  
    if not ok then  
        ngx_log(ngx_ERR, "connect to redis error : ", err)  
        return close_redis(red)  
    end  
  
    local resp, err = red:get(id)  
    if not resp then  
        ngx_log(ngx_ERR, "get redis content error : ", err)  
        return close_redis(red)  
    end  
        --得到的数据为空处理  
    if resp == ngx.null then  
        resp = nil  
    end  
    close_redis(red)  
  
    return resp  
end  
  
local function read_http(id)  
    local resp = ngx.location.capture("/backend/ad", {  
        method = ngx.HTTP_GET,  
        args = {id = id}  
    })  
  
    if not resp then  
        ngx_log(ngx_ERR, "request error :", err)  
        return  
    end  
  
    if resp.status ~= 200 then  
        ngx_log(ngx_ERR, "request error, status :", resp.status)  
        return  
    end  
  
    return resp.body  
end  

function isnil(value)
    if value == nil then
        value = "-"
    end
    return value
end

local function message()  
    local log_json = {}  
    log_json["uri"]=isnil(ngx.var.uri)
    log_json["args"]=isnil(ngx.var.args) 
    log_json["host"]=isnil(ngx.var.host)
    log_json["request_body"]=isnil(ngx.var.request_body)  
    --log_json["request_body"]=body_json
    --log_json["remote_addr"] = ngx.var.remote_addr  
    --log_json["remote_user"] = ngx.var.remote_user  
    log_json["time_local"] = isnil(ngx.var.time_local)
    --log_json["status"] = ngx.var.status  
    --log_json["body_bytes_sent"] = ngx.var.body_bytes_sent  
    log_json["http_referer"] = isnil(ngx.var.http_referer)
    log_json["http_user_agent"] = isnil(ngx.var.http_user_agent)
    log_json["http_x_forwarded_for"] = isnil(ngx.var.http_x_forwarded_for)
    log_json["upstream_response_time"] = isnil(ngx.var.upstream_response_time)
    log_json["request_time"] = isnil(ngx.var.request_time)  
     
    local message = cjson.encode(log_json) 
  
    return message
end  
  
  
--获取id  
local id = ngx_var.id  
  
--从redis获取  
local content = read_redis(id)  
  
--如果redis没有，回源到tomcat  
if not content then  
   ngx_log(ngx_ERR, "redis not found content, back to http, id : ", id)  
    content = read_http(id)  
end  
  
--如果还没有返回404  
if not content then  
   ngx_log(ngx_ERR, "http not found content, id : ", id)  
   return ngx_exit(404)  
end  
  
--输出内容  
ngx.print("show_ad(")  
ngx_print(cjson_encode({content = content}))  
ngx.print(")")  