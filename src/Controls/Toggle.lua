--[[
    Toggle
    A switch control with smooth slider animation (33×19px)
]]

local Theme = require(script.Parent.Parent.Theme)

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(interface, config)
    local self = setmetatable({}, Toggle)

    self.interface = interface
    self.config = config

    -- Load saved state or use default
    local savedValue = interface:getState(config.path)
    if savedValue ~= nil then
        self.value = savedValue
    else
        self.value = config.default or false
    end

    self:_build()

    return self
end

function Toggle:_build()
    -- Container (full row)
    local container = Instance.new("Frame")
    container.Name = "ToggleRow"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    self.container = container

    -- Content wrapper
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 18)
    layout.Parent = content

    -- Left side (labels)
    local leftSide = Instance.new("Frame")
    leftSide.Name = "LeftSide"
    leftSide.Size = UDim2.new(1, -51, 0, 0)
    leftSide.AutomaticSize = Enum.AutomaticSize.Y
    leftSide.BackgroundTransparency = 1
    leftSide.LayoutOrder = 1
    leftSide.Parent = content

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding = UDim.new(0, 3)
    leftLayout.Parent = leftSide

    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.Text = self.config.label
    label.TextColor3 = Theme.colors.text
    label.TextSize = Theme.typography.size.base
    label.Font = Theme.typography.font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextWrapped = true
    label.LayoutOrder = 1
    label.Parent = leftSide

    -- Detail (if provided)
    if self.config.detail then
        local detail = Instance.new("TextLabel")
        detail.Name = "Detail"
        detail.Size = UDim2.new(1, 0, 0, 0)
        detail.AutomaticSize = Enum.AutomaticSize.Y
        detail.BackgroundTransparency = 1
        detail.Text = self.config.detail
        detail.TextColor3 = Theme.colors.textMuted
        detail.TextSize = Theme.typography.size.sm
        detail.Font = Theme.typography.font
        detail.TextXAlignment = Enum.TextXAlignment.Left
        detail.TextYAlignment = Enum.TextYAlignment.Top
        detail.TextWrapped = true
        detail.LayoutOrder = 2
        detail.Parent = leftSide
    end

    -- Right side (toggle switch)
    local rightSide = Instance.new("Frame")
    rightSide.Name = "RightSide"
    rightSide.Size = UDim2.new(0, 33, 0, 19)
    rightSide.BackgroundTransparency = 1
    rightSide.LayoutOrder = 2
    rightSide.Parent = content

    -- Toggle button
    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(1, 0, 1, 0)
    toggle.BackgroundColor3 = Theme.colors.surfaceLight
    toggle.BackgroundTransparency = 0.3
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Text = ""
    toggle.Parent = rightSide

    local toggleRadius = Instance.new("UICorner")
    toggleRadius.CornerRadius = UDim.new(0, 11)
    toggleRadius.Parent = toggle

    local toggleBorder = Instance.new("UIStroke")
    toggleBorder.Color = Theme.colors.border
    toggleBorder.Thickness = 1
    toggleBorder.Transparency = 0.85
    toggleBorder.Parent = toggle

    self.toggle = toggle
    self.toggleBorder = toggleBorder

    -- Slider knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 11, 0, 11)
    knob.Position = UDim2.new(0, 3, 0.5, -5.5)
    knob.BackgroundColor3 = Theme.colors.textMuted
    knob.BorderSizePixel = 0
    knob.Parent = toggle

    local knobRadius = Instance.new("UICorner")
    knobRadius.CornerRadius = UDim.new(1, 0)
    knobRadius.Parent = knob

    self.knob = knob

    -- Set initial state
    self:_updateVisual(false)

    -- Click handler
    toggle.MouseButton1Click:Connect(function()
        self:setValue(not self.value)
    end)

    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 0)
    padding.PaddingBottom = UDim.new(0, 17)
    padding.Parent = container
end

function Toggle:setValue(value)
    if self.value == value then return end
    self.value = value
    self:_updateVisual(true)

    -- Notify change
    if self.config.path then
        self.interface:_notifyChange(self.config.path, value)
    end
end

function Toggle:_updateVisual(animate)
    local duration = animate and 0.24 or 0.001
    local accent = self.interface.config.accent

    if self.value then
        -- On state
        self:_tween(self.toggle, "BackgroundColor3", accent, duration)
        self:_tween(self.toggleBorder, "Transparency", 0, duration)
        self:_tween(self.knob, "Position", UDim2.new(0, 19, 0.5, -5.5), duration)
        self:_tween(self.knob, "BackgroundColor3", Theme.colors.white, duration)
    else
        -- Off state
        self:_tween(self.toggle, "BackgroundColor3", Theme.colors.surfaceLight, duration)
        self:_tween(self.toggleBorder, "Transparency", 0.85, duration)
        self:_tween(self.knob, "Position", UDim2.new(0, 3, 0.5, -5.5), duration)
        self:_tween(self.knob, "BackgroundColor3", Theme.colors.textMuted, duration)
    end
end

function Toggle:_tween(instance, property, value, duration)
    local tweenInfo = TweenInfo.new(
        duration * self.interface.config.speed,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, {[property] = value})
    tween:Play()
    return tween
end

function Toggle:getContainer()
    return self.container
end

return Toggle
