--[[
    Interface Library
    A lightweight UI library with cold-tone aesthetics and fluid morphing animations.

    Usage:
        local UI = require(game.ReplicatedStorage.InterfaceLib)
        local window = UI.new(config)
]]

local Theme = require(script.Theme)
local Home = require(script.Home)
local Window = require(script.Window)

local Interface = {}
Interface.__index = Interface

function Interface.new(config)
    local self = setmetatable({}, Interface)

    -- Configuration
    self.config = {
        accent = config and config.accent or Color3.fromHex("80adfa"),
        radius = config and config.radius or 12,
        speed = config and config.speed or 1.0,
        parent = config and config.parent or game:GetService("CoreGui")
    }

    -- State
    self.modules = {}
    self.current = nil
    self.visible = false
    self.callbacks = {}
    self.state = {}  -- Persistent state storage

    -- Build UI
    self:_build()

    return self
end

function Interface:_build()
    -- Root container
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InterfaceLib"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = self.config.parent
    self.gui = screenGui

    -- Main frame
    local root = Instance.new("Frame")
    root.Name = "Root"
    root.Size = UDim2.new(1, 0, 1, 0)
    root.Position = UDim2.new(0, 0, 0, 0)
    root.BackgroundColor3 = Theme.colors.background
    root.BorderSizePixel = 0
    root.Parent = screenGui
    self.root = root

    -- Build Home scene
    self.home = Home.new(self)

    -- Build Window scene
    self.window = Window.new(self)

    -- Setup keyboard controls
    self:_setupInput()
end

function Interface:_setupInput()
    local UserInputService = game:GetService("UserInputService")

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        -- ESC key to close window or hide interface
        if input.KeyCode == Enum.KeyCode.Escape then
            if self.current then
                self:closeModule()
            elseif self.visible then
                self:hide()
            end
        end
    end)
end

function Interface:addModule(moduleConfig)
    table.insert(self.modules, moduleConfig)
    self.home:addModule(moduleConfig)
    return self
end

function Interface:show()
    if self.visible then return end
    self.visible = true
    self.gui.Enabled = true
    self.home:show()
    return self
end

function Interface:hide()
    if not self.visible then return end
    self.visible = false
    if self.current then
        self.window:close()
        self.current = nil
    end
    task.wait(0.5)
    self.gui.Enabled = false
    return self
end

function Interface:toggle()
    if self.visible then
        self:hide()
    else
        self:show()
    end
    return self
end

function Interface:destroy()
    -- Close any open windows
    if self.current then
        self.window:close()
    end

    -- Clear callbacks
    self.callbacks = {}

    -- Clear state
    self.state = {}

    -- Destroy GUI
    if self.gui then
        self.gui:Destroy()
        self.gui = nil
    end

    -- Clear references
    self.home = nil
    self.window = nil
    self.root = nil
    self.modules = {}
end

function Interface:onChanged(callback)
    table.insert(self.callbacks, callback)
    return self
end

function Interface:_notifyChange(path, value)
    -- Save to state
    self.state[path] = value

    -- Notify callbacks
    for _, callback in ipairs(self.callbacks) do
        task.spawn(callback, path, value)
    end
end

function Interface:getState(path)
    if path then
        return self.state[path]
    else
        -- Return full state copy
        local copy = {}
        for k, v in pairs(self.state) do
            copy[k] = v
        end
        return copy
    end
end

function Interface:setState(stateTable)
    if type(stateTable) ~= "table" then return self end

    for path, value in pairs(stateTable) do
        self.state[path] = value
    end

    -- Update UI if window is open
    if self.current and self.window.container.Visible then
        -- Rebuild current page to reflect new state
        local moduleConfig = nil
        for _, mod in ipairs(self.modules) do
            if mod.id == self.current then
                moduleConfig = mod
                break
            end
        end

        if moduleConfig then
            self.window:_showPage(moduleConfig, self.window.currentPage)
        end
    end

    return self
end

function Interface:openModule(moduleId)
    self.current = moduleId
    self.window:open(moduleId)
end

function Interface:closeModule()
    self.window:close()
    self.current = nil
end

return Interface
