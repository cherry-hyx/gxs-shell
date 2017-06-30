local t = {1, 3, 5, 8, 11, 18, 21}
local i
for i, v in ipairs(t) do
if 11 == v then
print("index[" .. i .. "] have right value[11]")
break
end
end