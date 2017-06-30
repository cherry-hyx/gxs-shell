local redis2 = require("redis_iresty")
local red = redis2:new()
local re = ngx.req.get_body_data()
local ok, err = red:get(re)
if not ok then
        return
end
ngx.say(ok)

 upstream redis_cluster {
     server 127.0.0.1:26379;
     check interval=3000 rise=2 fall=5 timeout=1000;
     keepalive 1024;
 }

#在Lua中访问Redis  
# 需要HttpUpstreamKeepaliveModule  
location = /redis {  
    internal;   #只能内部访问  
    redis2_connect_timeout 5s;
    redis2_next_upstream error timeout invalid_response;
    #redis2_query select 8;
    redis2_query get $arg_key;  
    redis2_pass '127.0.0.1:6379';  
    

}   
location = /lua_redis { #需要LuaRedisParser  
    content_by_lua '  
        local parser = require("redis.parser")  
        local res = ngx.location.capture("/redis", {  
            args = { key = ngx.var.arg_key }  
        })  
        if res.status == 200 then  
            reply = parser.parse_reply(res.body)  
            ngx.say(reply)  
        end  
    ';  
}  


#在Lua中访问Redis  
location = /redis {  
    internal;   #只能内部访问  
  
    redis2_raw_queries $args $echo_request_body;  
    redis2_pass redis_cluster;  
}   
      
location = /pipeline {  
    content_by_lua 'conf/pipeline.lua';  
}   


-- conf/pipeline.lua file  
-- config example
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

local parser = require('redis.parser')
local reqs = { {comm,key,bin,endnum} }

local raw_reqs = {}  
for i, req in ipairs(reqs)  do  
      table.insert(raw_reqs, parser.build_query(req))  
end 
--ngx.say('/redis?' ..  #reqs)
--ngx.say(table.concat(raw_reqs, ‘’))
local res = ngx.location.capture('/redis?'..#reqs, { body = table.concat(raw_reqs, '') })  
      
if res.status and res.body then  
       -- 解析redis的原生响应  
       local replies = parser.parse_replies(res.body, #reqs)  
       for i, reply in ipairs(replies)  do   
          ngx.say(reply[1])  
       end  
end 

--http://120.76.180.146:9090/pipeline?comm=zrange&key1=stocksir:fs:bk121929&bin=0&end=10

<!-- lang: lua -->
function runAsyncFunc( func, ... )
    local current = coroutine.running
    func(function (  )
        coroutine.resume(current)
    end, ...)
    coroutine.yield()
end

coroutine.create(function (  )
    runAsyncFunc(bob.walkto, jane)
    runAsyncFunc(bob.say, "hello")
    jane.say("hello")
end)

coroutine.resume(co)