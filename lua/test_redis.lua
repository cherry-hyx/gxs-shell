local redis = require "resty.redis_iresty"
local red = redis:new()

local ok, err = red:set("dog", "an animal")
if not ok then
    ngx.say("failed to set dog: ", err)
    return
end

ngx.say("set result: ", ok)


local red     = redis:new({timeout=1000})  
local func  = red:subscribe( "channel" )
if not func then
  return nil
end

while true do
    local res, err = func()
    if err then
        func(false)
    end
    ... ...
end

return cbfunc