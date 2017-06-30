				local redis2 = require("redis_iresty")
                                local red = redis2:new()
                                --local json = require("cjson")
                                --local data = ngx.req.get_body_data()
                                --local keys = json.decode(data)
				local re = ngx.req.get_body_data()
                                function stringToTable(str)
                                        local ret = loadstring("return "..str)()
                                        return ret
                                end
                                keys = stringToTable(re)
                                local ok, err = red:hset(keys[1],keys[2],keys[3])
                                if not ok then
                                        return
                                end
                                ngx.say(ok)
