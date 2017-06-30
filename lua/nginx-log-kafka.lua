local cjson = require("cjson")  
local producer = require "resty.kafka.producer"  
local cjson_encode = cjson.encode  
local ngx_log = ngx.log  
local ngx_ERR = ngx.ERR  
local ngx_exit = ngx.exit  
local ngx_print = ngx.print  
local ngx_re_match = ngx.re.match  
local ngx_var = ngx.var  


-- 定义kafka broker地址，ip需要和kafka的host.name配置一致  
local broker_list = {  
    { host = "192.168.10.243", port = 9092 },  
}  

local function wlist_kafka(message)  
    local bp = producer:new(broker_list, { producer_type = "async" })  
    -- 发送日志消息,send第二个参数key,用于kafka路由控制:  
    -- key为nill(空)时，一段时间向同一partition写入数据  
    -- 指定key，按照key的hash写入到对应的partition  
    local ok, err = bp:send("test", nil, message)  
       
    if not ok then  
        ngx.log(ngx.ERR, "kafka send err:", err)  
        return  
    end  
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

wlist_kafka(message)