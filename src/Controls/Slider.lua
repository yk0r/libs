--[[
    Slider
    A range slider with value output and gradient progress bar
]]

local Theme = require(script.Parent.Parent.Theme)

local Slider = {}
Slider.__index = Slider

function Slider.new(interface, config)
    local self = setmetatable({}, Slider)

    self.interface = interface
    self.config = config
    self.dragging = false

    -- Load saved state or use default
    local savedValue = interface:getState(config.path)
    if savedValue ~= nil then
        self.value = math.clamp(savedValue, 0, 100)
    else
        self.value = config.default or 50
    end

    self:_build()

    return self
end

function Slider:_build()
    -- Container
    local container = Instance.new("Frame")
    container.Name = "SliderRow"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    self.container = container

    -- Top border
    local border = Instance.new("Frame")
    border.Name = "Border"
    border.Size = UDim2.new(1, 0, 0, 1)
    border.BackgroundColor3 = Theme.colors.border
    border.BackgroundTransparency = 0.92
    border.BorderSizePixel = 0
    border.Parent = container

    -- Content wrapper
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Position = UDim2.new(0, 0, 0, 14)
    content.BackgroundTransparency = 1
    content.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = content

    -- Header (label + value)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 15)
    header.BackgroundTransparency = 1
    header.LayoutOrder = 1
    header.Parent = content

    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = self.config.label
    label.TextColor3 = Theme.colors.text
    label.TextSize = Theme.typography.size.base
    label.Font = Theme.typography.font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = header

    -- Value output
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0, 45, 1, 0)
    valueLabel.Position = UDim2.new(1, -45, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = math.floor(self.value) .. "%"
    valueLabel.TextColor3 = Theme.blend(Theme.colors.accent, Theme.colors.white, 0.8)
    valueLabel.TextSize = Theme.typography.size.sm
    valueLabel.Font = Theme.typography.font
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = header
    self.valueLabel = valueLabel

    -- Slider track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 20)
    track.BackgroundTransparency = 1
    track.LayoutOrder = 2
    track.Parent = content

    -- Track background (thin line)
    local trackBg = Instance.new("Frame")
    trackBg.Name = "TrackBg"
    trackBg.Size = UDim2.new(1, 0, 0, 3)
    trackBg.Position = UDim2.new(0, 0, 0.5, -1.5)
    trackBg.BackgroundColor3 = Theme.colors.border
    trackBg.BackgroundTransparency = 0.87
    trackBg.BorderSizePixel = 0
    trackBg.Parent = track

    local trackBgRadius = Instance.new("UICorner")
    trackBgRadius.CornerRadius = UDim.new(0, 3)
    trackBgRadius.Parent = trackBg

    -- Progress fill
    local progress = Instance.new("Frame")
    progress.Name = "Progress"
    progress.Size = UDim2.new(self.value / 100, 0, 0, 3)
    progress.Position = UDim2.new(0, 0, 0.5, -1.5)
    progress.BackgroundColor3 = self.interface.config.accent
    progress.BorderSizePixel = 0
    progress.Parent = track

    local progressRadius = Instance.new("UICorner")
    progressRadius.CornerRadius = UDim.new(0, 3)
    progressRadius.Parent = progress

    self.progress = progress

    -- Thumb (draggable knob)
    local thumb = Instance.new("TextButton")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 11, 0, 11)
    thumb.Position = UDim2.new(self.value / 100, -5.5, 0.5, -5.5)
    thumb.BackgroundColor3 = Theme.colors.white
    thumb.BorderSizePixel = 0
    thumb.AutoButtonColor = false
    thumb.Text = ""
    thumb.Parent = track

    local thumbRadius = Instance.new("UICorner")
    thumbRadius.CornerRadius = UDim.new(1, 0)
    thumbRadius.Parent = thumb

    local thumbBorder = Instance.new("UIStroke")
    thumbBorder.Color = self.interface.config.accent
    thumbBorder.Thickness = 2
    thumbBorder.Parent = thumb

    self.thumb = thumb
    self.track = track

    -- Drag handling
    local UserInputService = game:GetService("UserInputService")

    thumb.MouseButton1Down:Connect(function()
        self.dragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not self.dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local mouseX = input.Position.X

        local ratio = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
        local newValue = math.floor(ratio * 100)

        self:setValue(newValue)
    end)

    -- Click on track to jump
    trackBg.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local mouseX = input.Position.X

        local ratio = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
        local newValue = math.floor(ratio * 100)

        self:setValue(newValue)
    end)

    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 17)
    padding.Parent = container
end

function Slider:setValue(value)
    value = math.clamp(value, 0, 100)
    if self.value == value then return end

    self.value = value

    -- Update visual
    local ratio = value / 100
    self.progress.Size = UDim2.new(ratio, 0, 0, 3)
    self.thumb.Position = UDim2.new(ratio, -5.5, 0.5, -5.5)
    self.valueLabel.Text = math.floor(value) .. "%"

    -- Notify change
    if self.config.path then
        self.interface:_notifyChange(self.config.path, value)
    end
end

function Slider:getContainer()
    return self.container
end

return Slider
