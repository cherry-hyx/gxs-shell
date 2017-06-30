local json = require("cjson")
local tmp = ngx.req.get_body_data()
local ok,data = pcall(json.decode,tmp )
if not ok then
        ngx.say(ok)
        ngx.say('code:-1,data: json code is wrong>>>')
        return
end
--local data = json.decode(tmp)
local data1 = data["data1"]

--ngx.say(data1)
if not type(data1) == "table" then
        ngx.say("errr!!")
        return
end

local parser = require('redis.parser')
local reqs = { data1 }

local raw_reqs = {}
for i, req in ipairs(reqs)  do
      table.insert(raw_reqs, parser.build_query(req))
end
--ngx.say('/redis?' ..  #reqs)
--ngx.say(table.concat(raw_reqs, ‘’))
local res = ngx.location.capture('/redis?'..#reqs, { body = table.concat(raw_reqs, ‘’) })

if res.status and res.body then
       -- 解析redis的原生响应
       local replies = parser.parse_replies(res.body, #reqs)
       for i, reply in ipairs(replies)  do
          ngx.say('"data' .. i .. '":"' .. reply[1] .. '"\n')
       end
end
--{
--"data1":["get","dog"]
--}

-------------------------------------------------------
-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function lua_string_split(str, split_char)
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end

    return sub_str_tab;
end