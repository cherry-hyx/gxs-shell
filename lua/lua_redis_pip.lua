                local redis2 = require("redis_iresty")
                local red = redis2:new()
                local json = require("cjson")
                local data = ngx.req.get_body_data()
                --"{"row1":"{"set",key1,v1},{hset,k2,f2,v2}",{"get","hjb"}}"
                function stringToTable(str)  
                    local ret = loadstring("return "..str)()
                    return ret
                end
                red:init_pipeline()
                for setp in ipairs(data) do
                    if not type(setp) == "table" then
                        ngx.say("请求参数错误！！")
                        return
                    end
                    if setp[1] == "set" then
                        red:set(setp[2],setp[3])
                    end
                    if setp[1] == "get" do
                        red:get(setp[2])
                    end
                    if setp[1] == "hset" then
                        red:set(setp[2],setp[3],setp[4])
                    end
                    if setp[1] == "hget" do
                        red:get(setp[2],setp[3])
                    end
                end
                local results, err = red:commit_pipeline()
                if not results then
                ngx.say("failed: ", err)
                return
                end
                for i, res in ipairs(results) do
                ngx.say(i,res)
                end


 function serialize(obj)  
    local lua = ""  
    local t = type(obj)  
    if t == "number" then  
        lua = lua .. obj  
    elseif t == "boolean" then  
        lua = lua .. tostring(obj)  
    elseif t == "string" then  
        lua = lua .. string.format("%q", obj)  
    elseif t == "table" then  
        lua = lua .. "{\n"  
    for k, v in pairs(obj) do  
        lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
    end  
    local metatable = getmetatable(obj)  
        if metatable ~= nil and type(metatable.__index) == "table" then  
        for k, v in pairs(metatable.__index) do  
            lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
        end  
    end  
        lua = lua .. "}"  
    elseif t == "nil" then  
        return nil  
    else  
        error("can not serialize a " .. t .. " type.")  
    end  
    return lua  
end  
  
function unserialize(lua)  
    local t = type(lua)  
    if t == "nil" or lua == "" then  
        return nil  
    elseif t == "number" or t == "string" or t == "boolean" then  
        lua = tostring(lua)  
    else  
        error("can not unserialize a " .. t .. " type.")  
    end  
    lua = "return " .. lua  
    local func = loadstring(lua)  
    if func == nil then  
        return nil  
    end  
    return func()  
end  
  
data = {["a"] = "a", ["b"] = "b", [1] = 1, [2] = 2, ["t"] = {1, 2, 3}}  
local sz = serialize(data)  
print(sz)  
print("---------")  
print(serialize(unserialize(sz))) 