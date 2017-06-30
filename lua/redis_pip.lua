                                local redis2 = require("redis_iresty")
                                local red = redis2:new()
                                local json = require("cjson")
                                local re = ngx.req.get_body_data()
                                function stringToTable(str)
                                        local ret = loadstring("return "..str)()
                                        return ret
                                end
                                data = stringToTable(re)
                                red:init_pipeline()
                                for _, setp in ipairs(data) do
                                        if not type(setp) == "table" then
                                                ngx.say("请求参数错误！！")
                                                return
                                        end
                                        if setp[1] == "set" then
                                                red:set(setp[2],setp[3])
                                        end
                                        if setp[1] == "get" then
                                                red:get(setp[2])
                                        end
                                        if setp[1] == "hset" then
                                                red:hset(setp[2],setp[3],setp[4])
                                        end
                                        if setp[1] == "hget" then
                                                red:hget(setp[2],setp[3])
                                        end
                                end
                                local results, err = red:commit_pipeline()
                                if not results then
                                        ngx.say("failed: ", err)
                                        return
                                end
                                for i, res in ipairs(results) do
                                        if type(res) == "string" then
                                                if res ~= "OK" then
                                                        ngx.say(string.format("\"values%d\":\"%s\"",i,res))
                                                end
                                        elseif type(res) == "table" then
                                                ngx.say(string.format("\"values%d\":\"%s___%s\"",i,res[1],res[2]))
                                        end
                                end

