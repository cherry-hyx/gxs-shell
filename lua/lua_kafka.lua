-- 引入lua所有api  
            local cjson = require "cjson"  
            local producer = require "resty.kafka.producer"  
            -- 定义kafka broker地址，ip需要和kafka的host.name配置一致  
            local broker_list = {  
                { host = "192.168.10.243", port = 9092 },  
            }  
            -- 定义json便于日志数据整理收集  
            local log_json = {}  
            log_json["uri"]=ngx.var.uri  
            log_json["args"]=ngx.var.args  
            log_json["host"]=ngx.var.host  
            log_json["request_body"]=ngx.var.request_body  
            log_json["remote_addr"] = ngx.var.remote_addr  
            log_json["remote_user"] = ngx.var.remote_user  
            log_json["time_local"] = ngx.var.time_local  
            log_json["status"] = ngx.var.status  
            log_json["body_bytes_sent"] = ngx.var.body_bytes_sent  
            log_json["http_referer"] = ngx.var.http_referer  
            log_json["http_user_agent"] = ngx.var.http_user_agent  
            log_json["http_x_forwarded_for"] = ngx.var.http_x_forwarded_for  
            log_json["upstream_response_time"] = ngx.var.upstream_response_time  
            log_json["request_time"] = ngx.var.request_time  
            -- 转换json为字符串  
            local message = cjson.encode(log_json);  
            -- 定义kafka异步生产者  
            local bp = producer:new(broker_list, { producer_type = "async" })  
            -- 发送日志消息,send第二个参数key,用于kafka路由控制:  
            -- key为nill(空)时，一段时间向同一partition写入数据  
            -- 指定key，按照key的hash写入到对应的partition  
            local ok, err = bp:send("test", nil, message)  
            -- test1 表示topic
            if not ok then  
                ngx.log(ngx.ERR, "kafka send err:", err)  
                return  
            end  



            local cjson = require "cjson"
                local client = require "resty.kafka.client"
                local producer = require "resty.kafka.producer"

                local broker_list = {
                    { host = "192.168.10.243", port = 9092 },
                }

                local key = "key"
                local message = "halo world"

                -- usually we do not use this library directly
                local cli = client:new(broker_list)
                local brokers, partitions = cli:fetch_metadata("test")
                if not brokers then
                    ngx.say("fetch_metadata failed, err:", partitions)
                end
                ngx.say("brokers: ", cjson.encode(brokers), "; partitions: ", cjson.encode(partitions))


                -- sync producer_type
                local p = producer:new(broker_list)

                local offset, err = p:send("test", key, message)
                if not offset then
                    ngx.say("send err:", err)
                    return
                end
                ngx.say("send success, offset: ", tonumber(offset))

                -- this is async producer_type and bp will be reused in the whole nginx worker
                local bp = producer:new(broker_list, { producer_type = "async" })

                local ok, err = bp:send("test", key, message)
                if not ok then
                    ngx.say("send err:", err)
                    return
                end

                ngx.say("send success, ok:", ok)


            lua_package_path "/usr/local/luajit/lib/?.lua;;";  #lua 模块  
            lua_package_cpath "/usr/local/luajit/lib/?.so;;";  #c模块

lua_need_request_body on;
ngx.req.get_post_args()只能在rewrite_by_lua, access_by_lua, content_by_lua*阶段使用，且在使用前需要先调用ngx.req.read_body()，或打开
lua_need_request_body 选项强制本模块读取请求体（此方法不推荐）
    rewrite_by_lua  '
                              local request_method = ngx.var.request_method
                        if request_method == "GET" then
                                local arg = ngx.req.get_uri_args()["service"] or 0
                                return arg
                        elseif request_method == "POST" then
                                ngx.req.read_body()
                                local arg = ngx.req.get_post_args()["service"] or 0
                                return arg
                        end;'




            log_by_lua '  
                -- 引入lua所有api  
                local cjson = require "cjson"  
                local producer = require "resty.kafka.producer"  
                -- 定义kafka broker地址，ip需要和kafka的host.name配置一致  
                local broker_list = {  
                    { host = "10.10.78.52", port = 9092 },  
                }  
                -- 定义json便于日志数据整理收集  
                local log_json = {}  
                log_json["uri"]=ngx.var.uri  
                log_json["args"]=ngx.var.args  
                log_json["host"]=ngx.var.host  
                log_json["request_body"]=ngx.var.request_body  
                log_json["remote_addr"] = ngx.var.remote_addr  
                log_json["remote_user"] = ngx.var.remote_user  
                log_json["time_local"] = ngx.var.time_local  
                log_json["status"] = ngx.var.status  
                log_json["body_bytes_sent"] = ngx.var.body_bytes_sent  
                log_json["http_referer"] = ngx.var.http_referer  
                log_json["http_user_agent"] = ngx.var.http_user_agent  
                log_json["http_x_forwarded_for"] = ngx.var.http_x_forwarded_for  
                log_json["upstream_response_time"] = ngx.var.upstream_response_time  
                log_json["request_time"] = ngx.var.request_time  
                -- 转换json为字符串  
                local message = cjson.encode(log_json);  
                -- 定义kafka异步生产者  
                local bp = producer:new(broker_list, { producer_type = "async" })  
                -- 发送日志消息,send第二个参数key,用于kafka路由控制:  
                -- key为nill(空)时，一段时间向同一partition写入数据  
                -- 指定key，按照key的hash写入到对应的partition   $request_body
                local ok, err = bp:send("test1", nil, message)  
   
                if not ok then  
                    ngx.log(ngx.ERR, "kafka send err:", err)  
                    return  
                end  
                local f=io.open("3.txt","a+")
f:write("Happy New Year!")
f:flush()
-- 写入文件  
local function writefile(filename, info)  
    local wfile=io.open(filename, "w") --写入文件(w覆盖)  
    assert(wfile)  --打开时验证是否出错        
    wfile:write(info)  --写入传入的内容  
    wfile:close()  --调用结束后记得关闭  
end  
  
-- 检测路径是否目录  
local function is_dir(sPath)  
    if type(sPath) ~= "string" then return false end  
  
    local response = os.execute( "cd " .. sPath )  
    if response == 0 then  
        return true  
    end  
    return false  
end  
  
-- 检测文件是否存在  
local file_exists = function(name)  
    local f=io.open(name,"r")  
    if f~=nil then io.close(f) return true else return false end  
end  
            ';  

    }  