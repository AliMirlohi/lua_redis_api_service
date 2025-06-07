local _M = {}
local cjson = require "cjson.safe"

local WINDOW_SIZE = 60
local REQUEST_LIMIT = 60
local BLOCK_DURATION = 15

local now = ngx.now
local shared_dict = ngx.shared.ratelimit_dict

function _M.check()
    local client_ip = ngx.var.remote_addr
    if not client_ip then
        return false, "Cannot determine client IP"
    end

    local record = shared_dict:get(client_ip)
    if record then
        local data = cjson.decode(record)
        local ts = data.ts
        local count = data.count
        local blocked_until = data.blocked_until or 0
        local current = now()

        if blocked_until > current then
            return false, "Rate limit exceeded"
        end

        if current - ts >= WINDOW_SIZE then
            data.ts = current
            data.count = 1
            data.blocked_until = 0
            shared_dict:set(client_ip, cjson.encode(data))
            return true
        else
            if count < REQUEST_LIMIT then
                data.count = count + 1
                shared_dict:set(client_ip, cjson.encode(data))
                return true
            else
                data.blocked_until = current + BLOCK_DURATION
                shared_dict:set(client_ip, cjson.encode(data))
                return false, "Rate limit exceeded"
            end
        end
    else
        local first = {
            ts = now(),
            count = 1,
            blocked_until = 0
        }
        shared_dict:set(client_ip, cjson.encode(first))
        return true
    end
end

return _M