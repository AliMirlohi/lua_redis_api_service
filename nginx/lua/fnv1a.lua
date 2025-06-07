local _M = {}

function _M.hash(key)
    local FNV_OFFSET = 0x811c9dc5
    local FNV_PRIME  = 0x01000193
    local hash = FNV_OFFSET

    for i = 1, #key do
        local c = string.byte(key, i)
        hash = bit.bxor(hash, c)
        hash = (hash * FNV_PRIME) % 0x100000000
    end

    return hash
end

return _M