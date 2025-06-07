local redis = require "resty.redis"
local fnv1a = require "fnv1a"

local _M = {}
local COORDINATES = {
    [1] = { primary = { host = "redis1", port = 6379 }, replica = { host = "redis1r", port = 6379 } },
    [2] = { primary = { host = "redis2", port = 6379 }, replica = { host = "redis2r", port = 6379 } },
    [3] = { primary = { host = "redis3", port = 6379 }, replica = { host = "redis3r", port = 6379 } },
}

function _M.get_shard(key)
    local hash_val = fnv1a.hash(key)
    local idx = (hash_val % 3) + 1
    return idx
end

function _M.connect(shard_idx)
    local coord = COORDINATES[shard_idx]
    if not coord then
        return nil, "Invalid shard index"
    end

    local red = redis:new()
    red:set_timeout(2000)
    local ok, err = red:connect(coord.primary.host, coord.primary.port)
    if ok then
        return red, nil
    end

    local fallback = redis:new()
    fallback:set_timeout(2000)
    local ok2, err2 = fallback:connect(coord.replica.host, coord.replica.port)
    if ok2 then
        return fallback, nil
    end

    return nil, "Redis unavailable (primary: " .. (err or "unknown") .. ", replica: " .. (err2 or "unknown") .. ")"
end

return _M