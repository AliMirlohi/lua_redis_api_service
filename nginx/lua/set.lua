local cjson = require "cjson.safe"
local redis_cluster = require "redis_cluster"
local ratelimit = require "ratelimit"

local ok_rl, err_rl = ratelimit.check()
if not ok_rl then
    ngx.status = 429
    ngx.header["Content-Type"] = "application/json"
    ngx.say(cjson.encode({ error = err_rl }))
    return ngx.exit(429)
end

local args = ngx.req.get_uri_args()
local key = args.key
local value = args.value
if not key then
    ngx.status = 400
    ngx.header["Content-Type"] = "application/json"
    ngx.say(cjson.encode({ error = "Missing 'key'" }))
    return ngx.exit(400)
end
if not value then
    ngx.status = 400
    ngx.header["Content-Type"] = "application/json"
    ngx.say(cjson.encode({ error = "Missing 'value'" }))
    return ngx.exit(400)
end

local shard_idx = redis_cluster.get_shard(key)
local shard_name = "shard" .. shard_idx

local red, err_conn = redis_cluster.connect(shard_idx)
if not red then
    ngx.status = 500
    ngx.header["Content-Type"] = "application/json"
    ngx.say(cjson.encode({ error = "Redis unavailable"}))
    return ngx.exit(500)
end

local ok_set, err_set = red:set(key, value)
if not ok_set then
    ngx.status = 500
    ngx.header["Content-Type"] = "application/json"
    ngx.say(cjson.encode({ error = "Redis unavailable: " .. (err_set or "unknown") }))
    return ngx.exit(500)
end

ngx.status = 200
ngx.header["Content-Type"] = "application/json"
ngx.say(cjson.encode({ key = key, value = value, status = "OK", shard = shard_name }))