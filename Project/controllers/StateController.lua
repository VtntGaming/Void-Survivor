local StateController = {}
StateController.__index = StateController

local STATES = {
    MENU = "menu",
    PLAYING = "playing",
    PAUSED = "paused",
    GAMEOVER = "gameover",
    SETTINGS = "settings"
}

StateController.STATES = STATES

function StateController.new(eventBus)
    local self = setmetatable({}, StateController)
    self.eventBus = eventBus
    self.current = STATES.MENU
    return self
end

function StateController:get()
    return self.current
end

function StateController:is(state)
    return self.current == state
end

function StateController:change(newState)
    local old = self.current
    self.current = newState
    self.eventBus:emit("state:change", old, newState)
end

return StateController
