local cjson = require "cjson.safe"
local redis_cluster = require "redis_cluster"

local args = ngx.req.get_uri_args()
local key = args.key
if not key then
    ngx.status = 400
    ngx.header["Content-Type"] = "application/json"
    ngx.say(cjson.encode({ error = "Missing 'key'" }))
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

local res, err_get = red:get(key)
if not res or res == ngx.null then
    ngx.status = 200
    ngx.header["Content-Type"] = "application/json"
    ngx.say(cjson.encode(
    { 
    key = key,
    found = false,
    value=cjson.null,
    shard = shard_name 
    }))
    return ngx.exit(200)
end

ngx.status = 200
ngx.header["Content-Type"] = "application/json"
ngx.say(cjson.encode(
    {
    key = key,
    found = true,
    value = res,
    shard = shard_name
    }))