-- simple REST stuff
-- depend on ssl, or just luasocket?
local socket = require "socket"
local http = require "socket.http"
local https = require "ssl.https"
local json = require "json"
local ltn12 = require "ltn12"

local rest = {
    _VERSION = "rest.lua v0.1.0",
    DESCRIPTION = "Simple RESTish stuff",
    _URL = "http://github.com/feilkin/rest.lua",
    _LICENSE = [[
Copyright 2019 Aatu Hieta

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
}

--[[
    example call API:

    ```
    local rest = require "rest"
    local api = rest.api("https://localhost/api/v1/")

    -- get a list of users
    api:GET("/users")

    -- get a user
    api:GET("/users", 1234) -- /users/1234
    ```
--]]
-- helper to construct query string from a table :)
local _construct_query_string = function(t)
    local parts = {}

    for k, v in pairs(t) do
        table.insert(parts, string.format("%s=%s", k, v))
    end

    return table.concat(parts, "&")
end

-- helper that constructs urls :)
local _construct_url = function(...)
    local args = {...}
    local query_string

    -- if the last arg is a table, that does not have tostring,
    -- assume it is the query string thingy
    local last = args[#args]
    if type(last) == "table" then
        -- check if it has metatable
        local mt = getmetatable(last)
        if not mt or mt.__tostring == nil then
            -- construct query string from it, and remove it from the table
            query_string = _construct_query_string(last)
            table.remove(args, #args)
        end
    end

    for i, arg in ipairs(args) do
        if type(arg) ~= "string" then
            args[i] = tostring(arg)
        end
    end

    local url = table.concat(args, "/")

    if query_string then
        url = string.format("%s?%s", url, query_string)
    end

    return url
end

-- helper that does requests
local _do_request = function(method, ...)
    local url = _construct_url(...)

    -- check if we have a body
    local body
    local headers = {}
    local args = {...}
    local maybe_body = args[1]
    if type(maybe_body) == "table" then
        print("is a table")
        if maybe_body.body then
            print("has a body")
            body = maybe_body.body
            headers["Content-Type"] = "application/json"
            headers["Content-Length"] = #body
        end
    end

    print(method .. " " .. url)
    if body then
        print(body)
    end

    local proto = http

    if url:sub(1, 8) == "https://" then
        proto = https
    end

    local respt = {}

    local ok, status, headers, statusline =
        proto.request {
        url = url,
        method = method,
        headers = headers,
        source = body and ltn12.source.string(body),
        sink = ltn12.sink.table(respt)
    }

    if ok == nil then
        return nil, status
    end

    local response = json.decode(table.concat(respt))

    return response, status, headers, statusline
end

local _method = function(m)
    return function(...)
        return _do_request(m, ...)
    end
end

-- add in the methods
for _, m in ipairs({"GET", "POST", "PUT", "PATCH", "DELETE"}) do
    rest[m] = _method(m)
end

function rest.api(base_url)
    return setmetatable(
        {
            _is_api = true,
            base_url = base_url
        },
        {
            __index = rest,
            __tostring = function(t)
                return t.base_url
            end
        }
    )
end

function rest.body(api_or_data, data)
    local body = {}
    local api

    if api_or_data._is_api then
        api = api_or_data
    else
        data = api_or_data
        api = rest
    end

    if type(data) == "table" then
        body.body = json.encode(data)
    else
        body.body = data
    end

    return setmetatable(
        body,
        {
            __index = api,
            __tostring = function()
                return tostring(api)
            end
        }
    )
end

return rest
