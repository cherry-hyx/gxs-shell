lua_package_path "/usr/local/share/luajit-2.0.2/jit?.lua;;";  
lua_shared_dict devicedb 45m;   
    location /query {  
       default_type 'text/plain';  
       content_by_lua '  
                local args = ngx.req.get_uri_args()  
                local devicetype = args["device"]  
                local devicedb = ngx.shared.devicedb  
                local res = devicedb:get(devicetype)  
                --cats:get("Marry") ===  cats.get(cats, "Marry")
                ngx.say(res)  
           ';  
    }  
  
    location /update {  
        default_type 'text/plain';  
        content_by_lua '  
                local devicedb = ngx.shared.devicedb  
                --等价：devicedb = ngx.shared["devicedb"]
  
                for item in io.lines("/usr/local/nginx-1.4.2/data/rule.txt") do  
                    _,_,device_type, device_rule = string.find(item, "^(%a+)--(%a+)$")  
                    devicedb:set(device_type,device_rule)  
                    --set(key, value, exptime?, flags?)
                end  
  
                ngx.say("ok")              
           ';  
    }  

--rule.txt:
--SAMSUNG--samRule  
--APPLE--appRule  
--XIAOMI--xiaRule  

--使用模块缓存静态数据
--利用 lua_code_cache 开启时模块会被缓存的特性，我们可以使用模块来缓存静态数据，其效率接近于将数据缓存在内存中。
--存储方法：
local exception = require("core.exception")
local mysql = require("core.driver.mysql")
 
--- 实现示例，可以根据项目情况，完善后封装在数据查询层
local function makeCityCache()
    local citys = mysql:query("SELECT * FROM `data_city` WHERE 1")
    local cityData = {}
 
    for _, city in ipairs(citys) do
        cityData[city.id] = city
    end
 
    package.loaded["cache.city"] = cityData
end
--读取方法：
--- 实现示例，可以根据项目情况，完善后封装在数据查询层
local function getCityCache(id)
    local ok, cacheData = pcall(require, "cache.city")
 
    if ok then
        return cacheData[id]
    end
 
    return nil
end
--清理方法：

--- 实现示例，可以根据项目情况，完善后封装在数据查询层
local function clearCityCache()
    package.loaded["cache.city"] = nil
end