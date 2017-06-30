local json = require("cjson")
local method = ngx.var.request_method
local table = ngx.var.do_table
local data = ngx.req.get_body_data()


                    --string.format([[select * from cats where id = '%s']],
					--ndk.set_var.set_quote_sql_str(req_id))
                local mysql = require "resty.mysql"
                local db, err = mysql:new()
                if not db then
                    ngx.say("failed to instantiate mysql: ", err)
                    return
                end

                db:set_timeout(1000) -- 1 sec

                -- or connect to a unix domain socket file listened
                -- by a mysql server:
                --     local ok, err, errcode, sqlstate =
                --           db:connect{
                --              path = "/path/to/mysql.sock",
                --              database = "ngx_test",
                --              user = "ngx_test",
                --              password = "ngx_test" }

                local ok, err, errcode, sqlstate = db:connect{
                    host = "127.0.0.1",
                    port = 3306,
                    database = "ngx_test",
                    user = "ngx_test",
                    password = "ngx_test",
                    max_packet_size = 1024 * 1024 }

                if not ok then
                    ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
                    return
                end

                ngx.say("connected to mysql.")

                local res, err, errcode, sqlstate =
                    db:query("drop table if exists cats")
                if not res then
                    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
                    return
                end

                res, err, errcode, sqlstate =
                    db:query("create table cats "
                             .. "(id serial primary key, "
                             .. "name varchar(5))")
                if not res then
                    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
                    return
                end

                ngx.say("table cats created.")

                res, err, errcode, sqlstate =
                    db:query("insert into cats (name) "
                             .. "values (\'Bob\'),(\'\'),(null)")
                if not res then
                    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
                    return
                end

                ngx.say(res.affected_rows, " rows inserted into table cats ",
                        "(last insert id: ", res.insert_id, ")")

                -- run a select query, expected about 10 rows in
                -- the result set:
                res, err, errcode, sqlstate =
                    db:query("select * from cats order by id asc", 10)
                if not res then
                    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
                    return
                end

                local cjson = require "cjson"
                ngx.say("result: ", cjson.encode(res))

                -- put it into the connection pool of size 100,
                -- with 10 seconds max idle timeout
                local ok, err = db:set_keepalive(10000, 100)
                if not ok then
                    ngx.say("failed to set keepalive: ", err)
                    return
                end

                -- or just close the connection right away:
                -- local ok, err = db:close()
                -- if not ok then
                --     ngx.say("failed to close: ", err)
                --     return
                -- end

ngx.say(data)
local keys = json.decode(data)
local sql

ngx.say(keys["col"])
ngx.say(keys["where"])
ngx.say(method)
--for tmp in ipairs(keys)
if keys["col"] == "*" then
	ngx.exit(ngx.HTTP_FORBIDDEN)
end

if method == "POST" then
	ngx.say "asdf"
	sql = "select " .. col .. " from " .. table
	ngx.say(sql)
	if keys["where"] then
	sql = sql ..  "where " .. keys["where"] 
	end
	sql = sql .. ";"
elseif method == "delete" then
	sql = "delete from " .. table
	if not keys["where"] then
		ngx.exit(ngx.HTTP_FORBIDDEN)
	else
		sql = sql ..  "where " .. keys["where"] .. ";"
	end
elseif method == "put" then
	if keys["isupdate"] == "yes" then
		local cols = ""
		for k,v in keys["col"] do
			cols = cols .. v .. "='" .. keys["values"][k] .. "'," 
		end
		upcol = string.sub(cols,1,-2)
		sql = "update from " .. table .. "set " .. upcol 
		if keys["where"] then
			sql = sql ..  "where " .. keys["where"] 
		end
		sql = sql .. ";"
	else 
		local sql = "insert into " .. table .. "(" .. keys["col"] .. ") values(" .. keys["values"] .. ");" 
	end
end

ngx.say(sql)