local Version = {
    current = "0.3.0"
}

function Version.load()
    if love and love.filesystem and love.filesystem.getInfo("version.txt") then
        local content = love.filesystem.read("version.txt")
        if content and #content > 0 then
            Version.current = content:gsub("%s+", "")
        end
    end
    return Version.current
end

function Version.get()
    return Version.current
end

function Version.getDisplay()
    return "v" .. Version.current
end

return Version
