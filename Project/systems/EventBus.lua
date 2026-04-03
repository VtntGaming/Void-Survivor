local EventBus = {}
EventBus.__index = EventBus

function EventBus.new()
    local self = setmetatable({}, EventBus)
    self.listeners = {}
    return self
end

function EventBus:on(event, callback)
    if not self.listeners[event] then
        self.listeners[event] = {}
    end
    table.insert(self.listeners[event], callback)
end

function EventBus:off(event, callback)
    if not self.listeners[event] then return end
    for i = #self.listeners[event], 1, -1 do
        if self.listeners[event][i] == callback then
            table.remove(self.listeners[event], i)
        end
    end
end

function EventBus:emit(event, ...)
    if not self.listeners[event] then return end
    for _, callback in ipairs(self.listeners[event]) do
        callback(...)
    end
end

function EventBus:clear()
    self.listeners = {}
end

return EventBus
