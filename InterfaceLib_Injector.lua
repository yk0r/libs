--[[
    InterfaceLib - Complete Single File for Executor
    Version: 0.1

    Usage:
        loadstring(game:HttpGet("YOUR_RAW_URL"))()

    Or copy-paste this entire file into your executor
]]

print("[InterfaceLib] Loading...")



-- ============================================================================
-- THEME MODULE
-- ============================================================================

    Theme
    Design tokens and color system

local Theme = {}

-- Color palette
Theme.colors = {
    background = Color3.fromRGB(27, 32, 40),      -- #1b2028
    surface = Color3.fromRGB(52, 64, 79),         -- #34404f
    surfaceLight = Color3.fromRGB(56, 70, 90),    -- #38465a

    text = Color3.fromRGB(228, 234, 245),         -- #e4eaf5
    textMuted = Color3.fromRGB(152, 171, 197),    -- #98abc5
    textDim = Color3.fromRGB(145, 161, 182),      -- #91a1b6

    accent = Color3.fromRGB(128, 173, 250),       -- #80adfa (default)
    accentDim = Color3.fromRGB(134, 152, 177),    -- #8698b1

    border = Color3.fromRGB(188, 207, 234),       -- #bccfea at 15% opacity
    borderBright = Color3.fromRGB(201, 218, 250), -- #c9dafa at 21% opacity

    white = Color3.fromRGB(255, 255, 255),
    black = Color3.fromRGB(0, 0, 0),
}

-- Opacity values (0-1)
Theme.opacity = {
    border = 0.15,
    borderBright = 0.21,
    muted = 0.85,
    dim = 0.6,
    subtle = 0.08,
}

-- Spacing
Theme.spacing = {
    xs = 5,
    sm = 8,
    md = 12,
    lg = 15,
    xl = 18,
    xxl = 22,
}

-- Typography
Theme.typography = {
    size = {
        xs = 9,
        sm = 10,
        md = 11,
        base = 12,
        lg = 13,
        title = 19,
        heading = 24,
    },
    weight = {
        regular = Enum.FontWeight.Regular,
        medium = Enum.FontWeight.Medium,
        semibold = Enum.FontWeight.SemiBold,
    },
    font = Enum.Font.GothamMedium,
}

-- Corner radius (configurable via config.radius)
Theme.radius = {
    sm = 3,
    md = 5,
    lg = 8,
    xl = 12,
}

-- Animation
Theme.animation = {
    -- Durations in seconds (scaled by config.speed)
    duration = {
        instant = 0.001,
        fast = 0.14,
        normal = 0.22,
        slow = 0.36,
        slower = 0.5,
    },
    -- Easing
    easing = Enum.EasingStyle.Cubic,
    direction = Enum.EasingDirection.Out,
}

-- Z-Index layers
Theme.zIndex = {
    background = 1,
    content = 2,
    overlay = 3,
    modal = 4,
    tooltip = 5,
}

-- Helper: Create color with transparency
function Theme.withAlpha(color, alpha)
        color.R * alpha,
        color.G * alpha,
        color.B * alpha
    )
end

-- Helper: Blend two colors
function Theme.blend(color1, color2, ratio)
        color1.R + (color2.R - color1.R) * ratio,
        color1.G + (color2.G - color1.G) * ratio,
        color1.B + (color2.B - color1.B) * ratio
    )
end



-- ============================================================================
-- ICONS MODULE
-- ============================================================================

    Icons
    Embedded lucide-icons subset for the interface

local Icons = {}

-- Icon data (SVG path strings)
local iconPaths = {
    settings = "M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z",

    grid = "M3 3h7v7H3z M14 3h7v7h-7z M14 14h7v7h-7z M3 14h7v7H3z",

    box = "M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z M3.3 7l8.7 5 8.7-5 M12 22V12",

    wrench = "M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z",

    layers = "M12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.9a1 1 0 0 0 0-1.83Z M22 17.65l-9.17 4.16a2 2 0 0 1-1.66 0L2 17.65 M22 12.65l-9.17 4.16a2 2 0 0 1-1.66 0L2 12.65",

    palette = "M13.73 4a2 2 0 0 0-3.46 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z M12 9v4 M12 17h.01",

    sliders = "M4 21v-7 M4 10V3 M12 21v-9 M12 8V3 M20 21v-5 M20 12V3 M2 14h4 M10 8h4 M18 16h4",

    zap = "M13 2L3 14h9l-1 8 10-12h-9l1-8z",

    crosshair = "M22 12h-4 M6 12H2 M12 6V2 M12 22v-4 M12 17a5 5 0 1 0 0-10 5 5 0 0 0 0 10z",

    layout = "M3 3h7v9H3z M14 3h7v5h-7z M14 12h7v9h-7z M3 16h7v5H3z",

    check = "M20 6L9 17l-5-5",

    minus = "M5 12h14",
}

-- Create an icon ImageLabel
function Icons.create(name, size)
    size = size or 16

    local pathData = iconPaths[name]
    if not pathData then
        warn("Icon not found:", name)
    end

    -- For Roblox, we'll use TextLabels with unicode symbols as a fallback
    -- In a real implementation, you'd use EditableImage or external icon service
    local symbolMap = {
        settings = "⚙",
        grid = "▦",
        box = "📦",
        wrench = "🔧",
        layers = "⧉",
        palette = "🎨",
        sliders = "⫼",
        zap = "⚡",
        crosshair = "⊕",
        layout = "▦",
        check = "✓",
        minus = "−",
    }

    local icon = Instance.new("TextLabel")
    icon.Name = "Icon_" .. name
    icon.Size = UDim2.new(0, size, 0, size)
    icon.BackgroundTransparency = 1
    icon.Text = symbolMap[name] or "●"
    icon.TextSize = size
    icon.Font = Enum.Font.GothamMedium
    icon.TextColor3 = Color3.fromRGB(134, 152, 177)

end

-- Get icon symbol only
function Icons.getSymbol(name)
    local symbolMap = {
        settings = "⚙",
        grid = "▦",
        box = "📦",
        wrench = "🔧",
        layers = "⧉",
        palette = "🎨",
        sliders = "⫼",
        zap = "⚡",
        crosshair = "⊕",
        layout = "▦",
        check = "✓",
        minus = "−",
    }
end



-- ============================================================================
-- TOGGLE MODULE
-- ============================================================================

    Toggle
    A switch control with smooth slider animation (33×19px)


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
end

function Toggle:getContainer()
end



-- ============================================================================
-- SLIDER MODULE
-- ============================================================================

    Slider
    A range slider with value output and gradient progress bar


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
end



-- ============================================================================
-- MATRIX MODULE
-- ============================================================================

    Matrix
    An expandable dropdown with 3-column grid layout and staggered animation


local Matrix = {}
Matrix.__index = Matrix

function Matrix.new(interface, config)
    local self = setmetatable({}, Matrix)

    self.interface = interface
    self.config = config
    self.expanded = false
    self.optionButtons = {}

    -- Load saved state or use default
    local savedValue = interface:getState(config.path)
    if savedValue ~= nil and table.find(config.options, savedValue) then
        self.value = savedValue
    else
        self.value = config.default or (config.options[1] or "")
    end

    self:_build()

end

function Matrix:_build()
    -- Container
    local container = Instance.new("Frame")
    container.Name = "MatrixRow"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    self.container = container

    -- Matrix wrapper
    local matrix = Instance.new("Frame")
    matrix.Name = "Matrix"
    matrix.Size = UDim2.new(1, 0, 0, 0)
    matrix.AutomaticSize = Enum.AutomaticSize.Y
    matrix.Position = UDim2.new(0, 0, 0, 14)
    matrix.BackgroundColor3 = Theme.colors.surface
    matrix.BorderSizePixel = 0
    matrix.Parent = container

    local matrixRadius = Instance.new("UICorner")
    matrixRadius.CornerRadius = UDim.new(0, 8)
    matrixRadius.Parent = matrix

    local matrixBorder = Instance.new("UIStroke")
    matrixBorder.Color = Theme.colors.border
    matrixBorder.Thickness = 1
    matrixBorder.Transparency = 0.87
    matrixBorder.Parent = matrix

    self.matrix = matrix
    self.matrixBorder = matrixBorder

    -- Trigger button
    local trigger = Instance.new("TextButton")
    trigger.Name = "Trigger"
    trigger.Size = UDim2.new(1, 0, 0, 47)
    trigger.BackgroundTransparency = 1
    trigger.BorderSizePixel = 0
    trigger.AutoButtonColor = false
    trigger.Text = ""
    trigger.Parent = matrix

    -- Trigger content
    local triggerContent = Instance.new("Frame")
    triggerContent.Name = "Content"
    triggerContent.Size = UDim2.new(1, -24, 1, 0)
    triggerContent.Position = UDim2.new(0, 12, 0, 0)
    triggerContent.BackgroundTransparency = 1
    triggerContent.Parent = trigger

    -- Icon placeholder
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 14, 0, 14)
    icon.Position = UDim2.new(0, 0, 0.5, -7)
    icon.BackgroundTransparency = 1
    icon.Text = "▦"
    icon.TextColor3 = Theme.colors.accentDim
    icon.TextSize = 14
    icon.Font = Theme.typography.font
    icon.Parent = triggerContent

    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -160, 1, 0)
    label.Position = UDim2.new(0, 23, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = self.config.label
    label.TextColor3 = Theme.colors.text
    label.TextSize = Theme.typography.size.base
    label.Font = Theme.typography.font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = triggerContent

    -- Selected value display
    local selected = Instance.new("TextLabel")
    selected.Name = "Selected"
    selected.Size = UDim2.new(0, 113, 1, 0)
    selected.Position = UDim2.new(1, -135, 0, 0)
    selected.BackgroundTransparency = 1
    selected.Text = self.value
    selected.TextColor3 = Theme.colors.textMuted
    selected.TextSize = Theme.typography.size.sm
    selected.Font = Theme.typography.font
    selected.TextXAlignment = Enum.TextXAlignment.Right
    selected.TextTruncate = Enum.TextTruncate.AtEnd
    selected.Parent = triggerContent
    self.selectedLabel = selected

    -- Expander icon
    local expander = Instance.new("Frame")
    expander.Name = "Expander"
    expander.Size = UDim2.new(0, 22, 0, 22)
    expander.Position = UDim2.new(1, -22, 0.5, -11)
    expander.BackgroundColor3 = Theme.colors.surfaceLight
    expander.BorderSizePixel = 0
    expander.Parent = triggerContent

    local expanderRadius = Instance.new("UICorner")
    expanderRadius.CornerRadius = UDim.new(0, 5)
    expanderRadius.Parent = expander

    local expanderBorder = Instance.new("UIStroke")
    expanderBorder.Color = Theme.colors.border
    expanderBorder.Thickness = 1
    expanderBorder.Transparency = 0.88
    expanderBorder.Parent = expander

    -- Plus icon (vertical and horizontal bars)
    local plusV = Instance.new("Frame")
    plusV.Name = "PlusV"
    plusV.Size = UDim2.new(0, 1, 0, 8)
    plusV.Position = UDim2.new(0.5, -0.5, 0.5, -4)
    plusV.BackgroundColor3 = Theme.colors.text
    plusV.BorderSizePixel = 0
    plusV.Parent = expander
    self.plusV = plusV

    local plusH = Instance.new("Frame")
    plusH.Name = "PlusH"
    plusH.Size = UDim2.new(0, 8, 0, 1)
    plusH.Position = UDim2.new(0.5, -4, 0.5, -0.5)
    plusH.BackgroundColor3 = Theme.colors.text
    plusH.BorderSizePixel = 0
    plusH.Parent = expander

    self.expander = expander
    self.expanderBorder = expanderBorder

    -- Options body (collapsed initially)
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 0, 0)
    body.BackgroundTransparency = 1
    body.ClipsDescendants = true
    body.Parent = matrix
    self.body = body

    -- Options grid
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "Options"
    optionsContainer.Size = UDim2.new(1, -18, 0, 0)
    optionsContainer.Position = UDim2.new(0, 9, 0, 0)
    optionsContainer.AutomaticSize = Enum.AutomaticSize.Y
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.Parent = body

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    gridLayout.CellSize = UDim2.new(0.333, -4, 0, 40)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = optionsContainer

    self.optionsContainer = optionsContainer

    -- Build option buttons
    for i, option in ipairs(self.config.options) do
        local optionButton = self:_createOption(option, i)
        optionButton.Parent = optionsContainer
        table.insert(self.optionButtons, optionButton)
    end

    -- Bottom padding
    local bottomPadding = Instance.new("Frame")
    bottomPadding.Name = "Padding"
    bottomPadding.Size = UDim2.new(1, 0, 0, 9)
    bottomPadding.BackgroundTransparency = 1
    bottomPadding.Parent = body

    -- Click handler
    trigger.MouseButton1Click:Connect(function()
        self:toggle()
    end)

    -- Container padding
    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 17)
    padding.Parent = container
end

function Matrix:_createOption(text, index)
    local button = Instance.new("TextButton")
    button.Name = "Option_" .. index
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Theme.colors.surfaceLight
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""

    local radius = Instance.new("UICorner")
    radius.CornerRadius = UDim.new(0, 5)
    radius.Parent = button

    local border = Instance.new("UIStroke")
    border.Color = Theme.colors.border
    border.Thickness = 1
    border.Transparency = 0.88
    border.Parent = button

    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.colors.text
    label.TextSize = Theme.typography.size.md
    label.Font = Theme.typography.font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = button

    -- Check icon
    local check = Instance.new("TextLabel")
    check.Name = "Check"
    check.Size = UDim2.new(0, 12, 0, 12)
    check.Position = UDim2.new(1, -18, 0.5, -6)
    check.BackgroundTransparency = 1
    check.Text = "✓"
    check.TextColor3 = self.interface.config.accent
    check.TextSize = 12
    check.Font = Theme.typography.font
    check.TextTransparency = 1
    check.Parent = button

    -- Store references
    button:SetAttribute("OptionText", text)
    button:SetAttribute("OptionBorder", border)
    button:SetAttribute("OptionCheck", check)

    -- Update initial state
    if text == self.value then
        button.BackgroundColor3 = Theme.blend(self.interface.config.accent, Theme.colors.surface, 0.3)
        border.Color = self.interface.config.accent
        border.Transparency = 0.5
        check.TextTransparency = 0
    end

    -- Hover
    button.MouseEnter:Connect(function()
        if text ~= self.value then
            self:_tween(button, "BackgroundColor3", Theme.blend(Theme.colors.surfaceLight, Theme.colors.accent, 0.1), 0.16)
            self:_tween(border, "Transparency", 0.65, 0.16)
        end
    end)

    button.MouseLeave:Connect(function()
        if text ~= self.value then
            self:_tween(button, "BackgroundColor3", Theme.colors.surfaceLight, 0.16)
            self:_tween(border, "Transparency", 0.88, 0.16)
        end
    end)

    -- Click
    button.MouseButton1Click:Connect(function()
        -- Pulse feedback animation
        local pulseTween = game:GetService("TweenService"):Create(
            button,
            TweenInfo.new(0.085 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.975, 0, 0.975, 0)}
        )
        pulseTween:Play()

        pulseTween.Completed:Connect(function()
            local restoreTween = game:GetService("TweenService"):Create(
                button,
                TweenInfo.new(0.17 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Size = UDim2.new(1, 0, 1, 0)}
            )
            restoreTween:Play()
        end)

        self:setValue(text)
    end)

end

function Matrix:setValue(value)
    if self.value == value then return end

    -- Update all option buttons
    for _, button in ipairs(self.optionButtons) do
        local text = button:GetAttribute("OptionText")
        local border = button:FindFirstChild("UIStroke")
        local check = button:FindFirstChild("Check")

        if text == value then
            -- Selected
            self:_tween(button, "BackgroundColor3", Theme.blend(self.interface.config.accent, Theme.colors.surface, 0.3), 0.17)
            if border then
                self:_tween(border, "Color", self.interface.config.accent, 0.17)
                self:_tween(border, "Transparency", 0.5, 0.17)
            end
            if check then
                self:_tween(check, "TextTransparency", 0, 0.17)
            end
        else
            -- Unselected
            self:_tween(button, "BackgroundColor3", Theme.colors.surfaceLight, 0.16)
            if border then
                self:_tween(border, "Color", Theme.colors.border, 0.16)
                self:_tween(border, "Transparency", 0.88, 0.16)
            end
            if check then
                self:_tween(check, "TextTransparency", 1, 0.16)
            end
        end
    end

    self.value = value
    self.selectedLabel.Text = value

    -- Notify change
    if self.config.path then
        self.interface:_notifyChange(self.config.path, value)
    end
end

function Matrix:toggle()
    self.expanded = not self.expanded

    if self.expanded then
        self:_expand()
    else
        self:_collapse()
    end
end

function Matrix:_expand()
    -- Update matrix appearance
    self:_tween(self.matrix, "BackgroundColor3", Theme.blend(Theme.colors.surface, Theme.colors.accent, 0.05), 0.22)
    self:_tween(self.matrixBorder, "Transparency", 0.65, 0.22)

    -- Update expander
    self:_tween(self.expander, "BackgroundColor3", Theme.blend(Theme.colors.surfaceLight, Theme.colors.accent, 0.2), 0.22)
    self:_tween(self.expanderBorder, "Transparency", 0.67, 0.22)
    self:_tween(self.plusV, "BackgroundTransparency", 1, 0.2)

    -- Expand body
    local targetHeight = self.optionsContainer.AbsoluteSize.Y + 9

    local tweenInfo = TweenInfo.new(
        0.36 * self.interface.config.speed,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(
        self.body,
        tweenInfo,
        {Size = UDim2.new(1, 0, 0, targetHeight)}
    )
    tween:Play()

    -- Staggered option animation
    local columns = 3
    for i, button in ipairs(self.optionButtons) do
        button.BackgroundTransparency = 1
        button.Position = UDim2.new(0, 10, 0, -5)

        local row = math.floor((i - 1) / columns)
        local col = (i - 1) % columns
        local delay = (row * columns - col) * 0.022

        task.delay(delay * self.interface.config.speed, function()
            self:_tween(button, "BackgroundTransparency", 0, 0.22)

            local positionTween = game:GetService("TweenService"):Create(
                button,
                TweenInfo.new(0.22 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, 0, 0, 0)}
            )
            positionTween:Play()
        end)
    end
end

function Matrix:_collapse()
    -- Update matrix appearance
    self:_tween(self.matrix, "BackgroundColor3", Theme.colors.surface, 0.22)
    self:_tween(self.matrixBorder, "Transparency", 0.87, 0.22)

    -- Update expander
    self:_tween(self.expander, "BackgroundColor3", Theme.colors.surfaceLight, 0.22)
    self:_tween(self.expanderBorder, "Transparency", 0.88, 0.22)
    self:_tween(self.plusV, "BackgroundTransparency", 0, 0.25)

    -- Collapse body
    local tweenInfo = TweenInfo.new(
        0.27 * self.interface.config.speed,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(
        self.body,
        tweenInfo,
        {Size = UDim2.new(1, 0, 0, 0)}
    )
    tween:Play()
end

function Matrix:_tween(instance, property, value, duration)
    local tweenInfo = TweenInfo.new(
        duration * self.interface.config.speed,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, {[property] = value})
    tween:Play()
end

function Matrix:getContainer()
end



-- ============================================================================
-- HOME MODULE
-- ============================================================================

    Home
    Module list scene with staggered fade-in animation


local Home = {}
Home.__index = Home

function Home.new(interface)
    local self = setmetatable({}, Home)

    self.interface = interface
    self.modules = {}

    self:_build()

end

function Home:_build()
    local root = self.interface.root

    -- Container
    local container = Instance.new("Frame")
    container.Name = "Home"
    container.Size = UDim2.new(0, 288, 0, 400)
    container.Position = UDim2.new(0.5, 0, 0.5, -90)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = root
    self.container = container

    -- Layout
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 0)
    layout.Parent = container
    self.layout = layout
end

function Home:addModule(config)
    local moduleRow = self:_createModuleRow(config, #self.modules + 1)
    table.insert(self.modules, {
        config = config,
        frame = moduleRow
    })
end

function Home:_createModuleRow(config, index)
    local row = Instance.new("TextButton")
    row.Name = "Module_" .. config.id
    row.Size = UDim2.new(1, 0, 0, 59)
    row.BackgroundColor3 = Theme.colors.background
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.AutoButtonColor = false
    row.Text = ""
    row.LayoutOrder = index
    row.Parent = self.container

    -- Hover background gradient
    local hoverBg = Instance.new("Frame")
    hoverBg.Name = "HoverBg"
    hoverBg.Size = UDim2.new(1, 0, 1, -10)
    hoverBg.Position = UDim2.new(0, 0, 0, 5)
    hoverBg.BackgroundColor3 = Theme.colors.accent
    hoverBg.BackgroundTransparency = 0.95
    hoverBg.BorderSizePixel = 0
    hoverBg.Visible = false
    hoverBg.Parent = row

    local hoverRadius = Instance.new("UICorner")
    hoverRadius.CornerRadius = UDim.new(0, 3)
    hoverRadius.Parent = hoverBg

    -- Left indicator bar
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 2, 0, 16)
    indicator.Position = UDim2.new(0, 0, 0.5, -8)
    indicator.BackgroundColor3 = self.interface.config.accent
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1
    indicator.Parent = row

    local indicatorRadius = Instance.new("UICorner")
    indicatorRadius.CornerRadius = UDim.new(0, 2)
    indicatorRadius.Parent = indicator

    -- Content frame
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -26, 1, 0)
    content.Position = UDim2.new(0, 13, 0, 0)
    content.BackgroundTransparency = 1
    content.Parent = row

    -- Icon
    local iconSymbol = Icons.getSymbol(config.icon or "grid")
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 17, 0, 17)
    icon.Position = UDim2.new(0, 0, 0.5, -8.5)
    icon.BackgroundTransparency = 1
    icon.Text = iconSymbol
    icon.TextColor3 = Theme.colors.accentDim
    icon.TextSize = Theme.typography.size.lg
    icon.Font = Theme.typography.font
    icon.Parent = content

    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 34, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.label
    label.TextColor3 = Theme.colors.text
    label.TextSize = Theme.typography.size.title
    label.Font = Theme.typography.font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content

    -- Number
    local number = Instance.new("TextLabel")
    number.Name = "Number"
    number.Size = UDim2.new(0, 40, 1, 0)
    number.Position = UDim2.new(1, -40, 0, 0)
    number.BackgroundTransparency = 1
    number.Text = string.format("%02d", index)
    number.TextColor3 = Theme.colors.textMuted
    number.TextSize = Theme.typography.size.sm
    number.Font = Theme.typography.font
    number.TextXAlignment = Enum.TextXAlignment.Right
    number.Parent = content

    -- Hover interaction
    row.MouseEnter:Connect(function()
        hoverBg.Visible = true
        self:_tweenProperty(hoverBg, "BackgroundTransparency", 0.85, 0.22)

        -- Indicator scale animation
        indicator.Visible = true
        local scaleTween = game:GetService("TweenService"):Create(
            indicator,
            TweenInfo.new(0.25 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {
                BackgroundTransparency = 0,
                Size = UDim2.new(0, 2, 0, 16)
            }
        )
        scaleTween:Play()

        -- Icon shift
        local iconShift = game:GetService("TweenService"):Create(
            icon,
            TweenInfo.new(0.3 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, 2, 0.5, -8.5)}
        )
        iconShift:Play()

        self:_tweenProperty(icon, "TextColor3", self.interface.config.accent, 0.2)
        self:_tweenProperty(label, "TextColor3", Theme.colors.white, 0.2)
        self:_tweenProperty(number, "TextColor3", Theme.blend(Theme.colors.accent, Theme.colors.white, 0.7), 0.2)
    end)

    row.MouseLeave:Connect(function()
        self:_tweenProperty(hoverBg, "BackgroundTransparency", 1, 0.22)
        task.wait(0.22 * self.interface.config.speed)
        hoverBg.Visible = false

        -- Indicator shrink
        local scaleTween = game:GetService("TweenService"):Create(
            indicator,
            TweenInfo.new(0.25 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 2, 0, 4)
            }
        )
        scaleTween:Play()
        scaleTween.Completed:Connect(function()
            indicator.Visible = false
            indicator.Size = UDim2.new(0, 2, 0, 16)
        end)

        -- Icon shift back
        local iconShift = game:GetService("TweenService"):Create(
            icon,
            TweenInfo.new(0.2 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, 0, 0.5, -8.5)}
        )
        iconShift:Play()

        self:_tweenProperty(icon, "TextColor3", Theme.colors.accentDim, 0.2)
        self:_tweenProperty(label, "TextColor3", Theme.colors.text, 0.2)
        self:_tweenProperty(number, "TextColor3", Theme.colors.textMuted, 0.2)
    end)

    -- Click handler with feedback
    row.MouseButton1Click:Connect(function()
        -- Click scale feedback
        local clickTween = game:GetService("TweenService"):Create(
            row,
            TweenInfo.new(0.08 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {Size = UDim2.new(1, 0, 0, 57)}
        )
        clickTween:Play()

        clickTween.Completed:Connect(function()
            local restoreTween = game:GetService("TweenService"):Create(
                row,
                TweenInfo.new(0.12 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Size = UDim2.new(1, 0, 0, 59)}
            )
            restoreTween:Play()
        end)

        self.interface:openModule(config.id)
    end)

end

function Home:show()
    self.container.Visible = true

    -- Staggered fade-in animation
    for i, module in ipairs(self.modules) do
        local frame = module.frame
        frame.BackgroundTransparency = 1
        frame.Position = UDim2.new(0, 0, 0, -8)

        local delay = (i - 1) * 0.048 * self.interface.config.speed

        task.delay(delay, function()
            self:_tweenProperty(frame, "BackgroundTransparency", 0, 0.32)
            local tween = game:GetService("TweenService"):Create(
                frame,
                TweenInfo.new(0.32 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, 0, 0, 0)}
            )
            tween:Play()
        end)
    end
end

function Home:hide()
    self:_tweenProperty(self.container, "BackgroundTransparency", 1, 0.18)
    task.wait(0.18 * self.interface.config.speed)
    self.container.Visible = false
end

function Home:_tweenProperty(instance, property, value, duration)
    local tweenInfo = TweenInfo.new(
        duration * self.interface.config.speed,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, {[property] = value})
    tween:Play()
end



-- ============================================================================
-- WINDOW MODULE
-- ============================================================================

    Window
    Modal window scene with header, tabs, panel, and footer


local Window = {}
Window.__index = Window

function Window.new(interface)
    local self = setmetatable({}, Window)

    self.interface = interface
    self.currentPage = 0

    self:_build()

end

function Window:_build()
    local root = self.interface.root

    -- Container
    local container = Instance.new("Frame")
    container.Name = "Window"
    container.Size = UDim2.new(0, 580, 0, 450)
    container.Position = UDim2.new(0.5, 0, 0.5, -88)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = root
    self.container = container

    -- Shell (background with gradient and border)
    local shell = Instance.new("Frame")
    shell.Name = "Shell"
    shell.Size = UDim2.new(1, 0, 1, 0)
    shell.BackgroundColor3 = Theme.colors.surface
    shell.BorderSizePixel = 0
    shell.Parent = container

    local shellRadius = Instance.new("UICorner")
    shellRadius.CornerRadius = UDim.new(0, self.interface.config.radius)
    shellRadius.Parent = shell

    local shellBorder = Instance.new("UIStroke")
    shellBorder.Color = Theme.colors.border
    shellBorder.Thickness = 1
    shellBorder.Transparency = 0.85
    shellBorder.Parent = shell

    self.shell = shell

    -- Content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Parent = container
    self.content = content

    -- Header
    self:_buildHeader()

    -- Tabs
    self:_buildTabs()

    -- Panel
    self:_buildPanel()

    -- Footer
    self:_buildFooter()
end

function Window:_buildHeader()
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, -44, 0, 48)
    header.Position = UDim2.new(0, 22, 0, 19)
    header.BackgroundTransparency = 1
    header.Parent = self.content

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -50, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = ""
    title.TextColor3 = Theme.colors.text
    title.TextSize = Theme.typography.size.heading
    title.Font = Theme.typography.font
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    self.title = title

    -- Minimize button
    local minimize = Instance.new("TextButton")
    minimize.Name = "Minimize"
    minimize.Size = UDim2.new(0, 29, 0, 29)
    minimize.Position = UDim2.new(1, -29, 0, 0)
    minimize.BackgroundColor3 = Theme.colors.surfaceLight
    minimize.BackgroundTransparency = 0.7
    minimize.BorderSizePixel = 0
    minimize.AutoButtonColor = false
    minimize.Text = "−"
    minimize.TextColor3 = Theme.colors.text
    minimize.TextSize = 16
    minimize.Font = Theme.typography.font
    minimize.Parent = header

    local minimizeRadius = Instance.new("UICorner")
    minimizeRadius.CornerRadius = UDim.new(0, 5)
    minimizeRadius.Parent = minimize

    local minimizeBorder = Instance.new("UIStroke")
    minimizeBorder.Color = Theme.colors.border
    minimizeBorder.Thickness = 1
    minimizeBorder.Transparency = 0.9
    minimizeBorder.Parent = minimize

    -- Minimize hover
    minimize.MouseEnter:Connect(function()
        self:_tweenProperty(minimize, "BackgroundTransparency", 0.5, 0.18)
        self:_tweenProperty(minimizeBorder, "Transparency", 0.7, 0.18)
    end)

    minimize.MouseLeave:Connect(function()
        self:_tweenProperty(minimize, "BackgroundTransparency", 0.7, 0.18)
        self:_tweenProperty(minimizeBorder, "Transparency", 0.9, 0.18)
    end)

    minimize.MouseButton1Click:Connect(function()
        -- Click scale feedback
        local clickTween = game:GetService("TweenService"):Create(
            minimize,
            TweenInfo.new(0.09 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 26, 0, 26)}
        )
        clickTween:Play()

        clickTween.Completed:Connect(function()
            local restoreTween = game:GetService("TweenService"):Create(
                minimize,
                TweenInfo.new(0.15 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Size = UDim2.new(0, 29, 0, 29)}
            )
            restoreTween:Play()
        end)

        self.interface:closeModule()
    end)
end

function Window:_buildTabs()
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "Tabs"
    tabsContainer.Size = UDim2.new(1, -44, 0, 36)
    tabsContainer.Position = UDim2.new(0, 22, 0, 67)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.Parent = self.content

    -- Bottom border
    local border = Instance.new("Frame")
    border.Name = "Border"
    border.Size = UDim2.new(1, 0, 0, 1)
    border.Position = UDim2.new(0, 0, 1, 0)
    border.BackgroundColor3 = Theme.colors.border
    border.BackgroundTransparency = 0.95
    border.BorderSizePixel = 0
    border.Parent = tabsContainer

    -- Tab buttons container
    local tabs = Instance.new("Frame")
    tabs.Name = "TabButtons"
    tabs.Size = UDim2.new(1, 0, 1, -1)
    tabs.BackgroundTransparency = 1
    tabs.Parent = tabsContainer

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabs

    self.tabs = tabs
    self.tabsContainer = tabsContainer

    -- Indicator
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 10, 0, 2)
    indicator.Position = UDim2.new(0, 0, 1, -1)
    indicator.BackgroundColor3 = self.interface.config.accent
    indicator.BorderSizePixel = 0
    indicator.Parent = tabsContainer

    local indicatorRadius = Instance.new("UICorner")
    indicatorRadius.CornerRadius = UDim.new(0, 2)
    indicatorRadius.Parent = indicator

    self.indicator = indicator
end

function Window:_buildPanel()
    local panel = Instance.new("ScrollingFrame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(1, -44, 1, -150)
    panel.Position = UDim2.new(0, 22, 0, 103)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel = 0
    panel.ScrollBarThickness = 4
    panel.ScrollBarImageColor3 = Theme.colors.accent
    panel.ScrollBarImageTransparency = 0.7
    panel.CanvasSize = UDim2.new(0, 0, 0, 0)
    panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    panel.Parent = self.content

    local panelLayout = Instance.new("UIListLayout")
    panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
    panelLayout.Padding = UDim.new(0, 19)
    panelLayout.Parent = panel

    self.panel = panel
end

function Window:_buildFooter()
    local footer = Instance.new("Frame")
    footer.Name = "Footer"
    footer.Size = UDim2.new(1, -44, 0, 35)
    footer.Position = UDim2.new(0, 22, 1, -48)
    footer.BackgroundTransparency = 1
    footer.Parent = self.content

    -- Top border
    local border = Instance.new("Frame")
    border.Name = "Border"
    border.Size = UDim2.new(1, 0, 0, 1)
    border.BackgroundColor3 = Theme.colors.border
    border.BackgroundTransparency = 0.95
    border.BorderSizePixel = 0
    border.Parent = footer

    -- Left text
    local leftText = Instance.new("TextLabel")
    leftText.Name = "LeftText"
    leftText.Size = UDim2.new(0.5, 0, 1, 0)
    leftText.BackgroundTransparency = 1
    leftText.Text = "INTERFACE.LUA"
    leftText.TextColor3 = Theme.colors.textMuted
    leftText.TextSize = Theme.typography.size.xs
    leftText.Font = Theme.typography.font
    leftText.TextXAlignment = Enum.TextXAlignment.Left
    leftText.Parent = footer

    -- Right text (version)
    local rightText = Instance.new("TextLabel")
    rightText.Name = "RightText"
    rightText.Size = UDim2.new(0.5, 0, 1, 0)
    rightText.BackgroundTransparency = 1
    rightText.Text = "0.1"
    rightText.TextColor3 = Theme.colors.textMuted
    rightText.TextSize = Theme.typography.size.xs
    rightText.Font = Theme.typography.font
    rightText.TextXAlignment = Enum.TextXAlignment.Right
    rightText.Parent = footer
end

function Window:open(moduleId)
    -- Find module config
    local moduleConfig = nil
    local sourceModule = nil
    for _, mod in ipairs(self.interface.modules) do
        if mod.id == moduleId then
            moduleConfig = mod
            -- Get source frame from home
            for _, homeModule in ipairs(self.interface.home.modules) do
                if homeModule.config.id == moduleId then
                    sourceModule = homeModule.frame
                    break
                end
            end
            break
        end
    end

    if not moduleConfig or not sourceModule then return end

    -- Prepare content
    self.title.Text = moduleConfig.label
    self:_buildTabsForModule(moduleConfig)
    self.currentPage = 0
    self:_showPage(moduleConfig, 0)

    -- Make visible but hide content initially
    self.container.Visible = true
    self.content.Visible = false
    self.shell.BackgroundTransparency = 1

    -- Get positions for FLIP animation
    local sourcePos = sourceModule.AbsolutePosition
    local sourceSize = sourceModule.AbsoluteSize
    local targetPos = self.container.AbsolutePosition
    local targetSize = self.container.AbsoluteSize

    -- Calculate scale
    local scaleX = sourceSize.X / targetSize.X
    local scaleY = sourceSize.Y / targetSize.Y
    local offsetX = sourcePos.X - targetPos.X
    local offsetY = sourcePos.Y - targetPos.Y

    -- Get label for flying animation
    local sourceLabel = sourceModule:FindFirstChild("Content") and sourceModule.Content:FindFirstChild("Label")
    local ghostLabel = nil

    if sourceLabel then
        -- Create ghost label
        ghostLabel = Instance.new("TextLabel")
        ghostLabel.Name = "GhostLabel"
        ghostLabel.Size = UDim2.new(0, sourceLabel.AbsoluteSize.X, 0, sourceLabel.AbsoluteSize.Y)
        ghostLabel.Position = UDim2.new(0, sourceLabel.AbsolutePosition.X - self.interface.root.AbsolutePosition.X, 0, sourceLabel.AbsolutePosition.Y - self.interface.root.AbsolutePosition.Y)
        ghostLabel.BackgroundTransparency = 1
        ghostLabel.Text = moduleConfig.label
        ghostLabel.TextColor3 = Theme.colors.text
        ghostLabel.TextSize = Theme.typography.size.title
        ghostLabel.Font = Theme.typography.font
        ghostLabel.TextXAlignment = Enum.TextXAlignment.Left
        ghostLabel.ZIndex = 10
        ghostLabel.Parent = self.interface.root

        -- Hide source label
        sourceLabel.TextTransparency = 1
        self.title.TextTransparency = 1
    end

    -- Hide home
    self.interface.home:hide()

    -- Shell morph animation
    self.shell.Size = UDim2.new(scaleX, 0, scaleY, 0)
    self.shell.Position = UDim2.new(0, offsetX, 0, offsetY)

    local shellTween = self:_tween(self.shell, "BackgroundTransparency", 0, 0.5, 0.035)

    local morphTween = game:GetService("TweenService"):Create(
        self.shell,
        TweenInfo.new(0.5 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0)
        }
    )
    morphTween:Play()

    -- Label flying animation
    if ghostLabel then
        local targetLabelPos = self.title.AbsolutePosition
        local targetX = targetLabelPos.X - self.interface.root.AbsolutePosition.X
        local targetY = targetLabelPos.Y - self.interface.root.AbsolutePosition.Y
        local targetScale = Theme.typography.size.heading / Theme.typography.size.title

        -- Bounce up slightly first
        local bounceTween = game:GetService("TweenService"):Create(
            ghostLabel,
            TweenInfo.new(0.12 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {
                Position = UDim2.new(0, ghostLabel.Position.X.Offset - 3, 0, ghostLabel.Position.Y.Offset - 4),
                TextSize = Theme.typography.size.title * 1.22
            }
        )
        bounceTween:Play()

        task.delay(0.12 * self.interface.config.speed, function()
            local flyTween = game:GetService("TweenService"):Create(
                ghostLabel,
                TweenInfo.new(0.42 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {
                    Position = UDim2.new(0, targetX, 0, targetY),
                    TextSize = Theme.typography.size.heading
                }
            )
            flyTween:Play()
        end)
    end

    -- Show content after morph
    task.delay(0.275 * self.interface.config.speed, function()
        self.content.Visible = true
        self.content.BackgroundTransparency = 1
        self.content.Position = UDim2.new(0, 0, 0, -5)

        local contentTween = game:GetService("TweenService"):Create(
            self.content,
            TweenInfo.new(0.24 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {
                BackgroundTransparency = 0,
                Position = UDim2.new(0, 0, 0, 0)
            }
        )
        contentTween:Play()
    end)

    -- Cleanup ghost label and restore source
    task.delay(0.54 * self.interface.config.speed, function()
        if ghostLabel then
            ghostLabel:Destroy()
        end
        if sourceLabel then
            sourceLabel.TextTransparency = 0
            self.title.TextTransparency = 0
        end
    end)
end

function Window:_buildTabsForModule(moduleConfig)
    -- Clear existing tabs
    for _, child in ipairs(self.tabs:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- Create new tabs
    for i, page in ipairs(moduleConfig.pages) do
        local tab = self:_createTab(page.name, i - 1)
        tab.Parent = self.tabs
    end

    -- Position indicator on first tab
    task.wait()
    self:_updateIndicator(0, false)
end

function Window:_createTab(text, index)
    local tab = Instance.new("TextButton")
    tab.Name = "Tab_" .. index
    tab.Size = UDim2.new(0, 0, 1, 0)
    tab.AutomaticSize = Enum.AutomaticSize.X
    tab.BackgroundTransparency = 1
    tab.BorderSizePixel = 0
    tab.AutoButtonColor = false
    tab.Text = ""
    tab.LayoutOrder = index

    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = tab

    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.colors.textMuted
    label.TextSize = Theme.typography.size.md
    label.Font = Theme.typography.font
    label.Parent = tab

    -- Click handler
    tab.MouseButton1Click:Connect(function()
        self:_selectPage(index)
    end)

    -- Hover
    tab.MouseEnter:Connect(function()
        if index ~= self.currentPage then
            self:_tweenProperty(label, "TextColor3", Theme.colors.text, 0.18)
        end
    end)

    tab.MouseLeave:Connect(function()
        if index ~= self.currentPage then
            self:_tweenProperty(label, "TextColor3", Theme.colors.textMuted, 0.18)
        end
    end)

end

function Window:_selectPage(index)
    if index == self.currentPage then return end

    -- Get old panel height before clearing
    local oldHeight = self.panel.AbsoluteSize.Y

    -- Update tab colors
    for i, tab in ipairs(self.tabs:GetChildren()) do
        if tab:IsA("TextButton") then
            local label = tab:FindFirstChild("Label")
            if label then
                local targetColor = (i - 1 == index) and Theme.colors.text or Theme.colors.textMuted
                self:_tweenProperty(label, "TextColor3", targetColor, 0.18)
            end
        end
    end

    -- Update indicator
    self:_updateIndicator(index, true)

    local oldPage = self.currentPage
    self.currentPage = index

    -- Find module and build new page content
    local moduleConfig = nil
    for _, mod in ipairs(self.interface.modules) do
        if mod.id == self.interface.current then
            moduleConfig = mod
            break
        end
    end

    if not moduleConfig then return end

    -- Clear and rebuild panel content
    for _, child in ipairs(self.panel:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    for _, section in ipairs(moduleConfig.pages[index + 1].sections or {}) do
        self:_buildSection(section)
    end

    -- Wait for layout to update
    task.wait()
    local newHeight = self.panel.AbsoluteSize.Y

    -- Get selected tab position for reveal animation
    local selectedTab = self.tabs:FindFirstChild("Tab_" .. index)
    if not selectedTab then return end

    local tabPos = selectedTab.AbsolutePosition
    local panelPos = self.panel.AbsolutePosition
    local panelSize = self.panel.AbsoluteSize

    -- Calculate clip-path style percentages
    local leftPercent = math.clamp((tabPos.X - panelPos.X) / panelSize.X * 100, 0, 100)
    local rightPercent = math.clamp((panelPos.X + panelSize.X - tabPos.X - selectedTab.AbsoluteSize.X) / panelSize.X * 100, 0, 100)

    -- Disable interactions during animation
    self.panel.Active = false

    -- Lock height and create reveal animation
    self.panel.Size = UDim2.new(1, -44, 0, oldHeight)
    self.panel.ClipsDescendants = true

    -- Initial state: hidden under tab
    self.panel.BackgroundTransparency = 0.35

    -- Keyframe animation: reveal from tab edge, then unfold downward
    local revealFrames = {}

    -- Frame 1: Start hidden at 0% from tab position
    table.insert(revealFrames, {
        time = 0,
        size = UDim2.new(1, -44, 0, oldHeight),
        transparency = 0.35
    })

    -- Frame 2: Peek out from tab (30% progress)
    local peekHeight = oldHeight + (newHeight - oldHeight) * 0.35
    table.insert(revealFrames, {
        time = 0.3,
        size = UDim2.new(1, -44, 0, peekHeight),
        transparency = 1
    })

    -- Frame 3: Fully revealed (100%)
    table.insert(revealFrames, {
        time = 1,
        size = UDim2.new(1, -44, 0, newHeight),
        transparency = 1
    })

    -- Animate through frames
    local duration = 0.43 * self.interface.config.speed
    local startTime = tick()

    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / duration, 1)

        -- Find current frame
        local frameIndex = 1
        for i = 1, #revealFrames do
            if progress >= revealFrames[i].time then
                frameIndex = i
            end
        end

        local nextIndex = math.min(frameIndex + 1, #revealFrames)
        local currentFrame = revealFrames[frameIndex]
        local nextFrame = revealFrames[nextIndex]

        if frameIndex == nextIndex then
            -- Final frame
            self.panel.Size = currentFrame.size
            self.panel.BackgroundTransparency = currentFrame.transparency
        else
            -- Interpolate between frames
            local frameProgress = (progress - currentFrame.time) / (nextFrame.time - currentFrame.time)
            local easedProgress = 1 - math.pow(1 - frameProgress, 3) -- Cubic ease out

            local interpHeight = currentFrame.size.Y.Offset + (nextFrame.size.Y.Offset - currentFrame.size.Y.Offset) * easedProgress
            local interpTransparency = currentFrame.transparency + (nextFrame.transparency - currentFrame.transparency) * easedProgress

            self.panel.Size = UDim2.new(1, -44, 0, interpHeight)
            self.panel.BackgroundTransparency = interpTransparency
        end

        if progress >= 1 then
            connection:Disconnect()
            -- Reset to auto size
            self.panel.Size = UDim2.new(1, -44, 1, -150)
            self.panel.BackgroundTransparency = 1
            self.panel.Active = true
        end
    end)
end

function Window:_updateIndicator(index, animate)
    local tab = self.tabs:FindFirstChild("Tab_" .. index)
    if not tab then return end

    local tabPos = tab.AbsolutePosition
    local tabSize = tab.AbsoluteSize
    local containerPos = self.tabsContainer.AbsolutePosition

    local targetX = tabPos.X - containerPos.X + 10
    local targetWidth = math.max(12, tabSize.X - 20)

    if animate then
        local tweenInfo = TweenInfo.new(0.25 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        local tween = game:GetService("TweenService"):Create(
            self.indicator,
            tweenInfo,
            {
                Position = UDim2.new(0, targetX, 1, -1),
                Size = UDim2.new(0, targetWidth, 0, 2)
            }
        )
        tween:Play()
    else
        self.indicator.Position = UDim2.new(0, targetX, 1, -1)
        self.indicator.Size = UDim2.new(0, targetWidth, 0, 2)
    end
end

function Window:_showPage(moduleConfig, pageIndex)
    -- Clear panel
    for _, child in ipairs(self.panel:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    -- Build page content (placeholder for now)
    local page = moduleConfig.pages[pageIndex + 1]
    if not page then return end

    for _, section in ipairs(page.sections or {}) do
        self:_buildSection(section)
    end
end

function Window:_buildSection(section)

    -- Section title
    local titleFrame = Instance.new("Frame")
    titleFrame.Name = "SectionTitle"
    titleFrame.Size = UDim2.new(1, 0, 0, 20)
    titleFrame.BackgroundTransparency = 1
    titleFrame.Parent = self.panel

    -- Dot prefix
    local dot = Instance.new("Frame")
    dot.Name = "Dot"
    dot.Size = UDim2.new(0, 3, 0, 3)
    dot.Position = UDim2.new(0, 0, 0.5, -1.5)
    dot.BackgroundColor3 = Theme.blend(Theme.colors.accent, Theme.colors.textMuted, 0.5)
    dot.BackgroundTransparency = 0.4
    dot.BorderSizePixel = 0
    dot.Parent = titleFrame

    local dotRadius = Instance.new("UICorner")
    dotRadius.CornerRadius = UDim.new(1, 0)
    dotRadius.Parent = dot

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -11, 1, 0)
    titleLabel.Position = UDim2.new(0, 11, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = section.title
    titleLabel.TextColor3 = Theme.colors.textMuted
    titleLabel.TextSize = Theme.typography.size.xs
    titleLabel.Font = Theme.typography.font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleFrame

    -- Build controls
    for controlIndex, control in ipairs(section.controls or {}) do
        -- Generate path for state management
        local moduleId = self.interface.current
        local pageName = self.interface.modules[1].pages[self.currentPage + 1].name
        local controlPath = string.format("%s.%s.%s", moduleId, pageName, control.label)
        control.path = controlPath

        local controlWidget = nil

        if control.type == "toggle" then
            controlWidget = Toggle.new(self.interface, control)
        elseif control.type == "slider" then
            controlWidget = Slider.new(self.interface, control)
        elseif control.type == "matrix" then
            controlWidget = Matrix.new(self.interface, control)
        end

        if controlWidget then
            controlWidget:getContainer().Parent = self.panel
        end
    end
end

function Window:close()
    -- Find source module frame
    local sourceModule = nil
    for _, homeModule in ipairs(self.interface.home.modules) do
        if homeModule.config.id == self.interface.current then
            sourceModule = homeModule.frame
            break
        end
    end

    if not sourceModule then
        self.container.Visible = false
    end

    -- Get positions for reverse FLIP
    local sourcePos = self.container.AbsolutePosition
    local sourceSize = self.container.AbsoluteSize
    local targetPos = sourceModule.AbsolutePosition
    local targetSize = sourceModule.AbsoluteSize

    local scaleX = targetSize.X / sourceSize.X
    local scaleY = targetSize.Y / sourceSize.Y
    local offsetX = targetPos.X - sourcePos.X
    local offsetY = targetPos.Y - sourcePos.Y

    -- Create ghost label
    local sourceLabel = sourceModule:FindFirstChild("Content") and sourceModule.Content:FindFirstChild("Label")
    local ghostLabel = nil

    if sourceLabel then
        ghostLabel = Instance.new("TextLabel")
        ghostLabel.Name = "GhostLabel"
        ghostLabel.Size = UDim2.new(0, self.title.AbsoluteSize.X, 0, self.title.AbsoluteSize.Y)
        ghostLabel.Position = UDim2.new(0, self.title.AbsolutePosition.X - self.interface.root.AbsolutePosition.X, 0, self.title.AbsolutePosition.Y - self.interface.root.AbsolutePosition.Y)
        ghostLabel.BackgroundTransparency = 1
        ghostLabel.Text = self.title.Text
        ghostLabel.TextColor3 = Theme.colors.text
        ghostLabel.TextSize = Theme.typography.size.heading
        ghostLabel.Font = Theme.typography.font
        ghostLabel.TextXAlignment = Enum.TextXAlignment.Left
        ghostLabel.ZIndex = 10
        ghostLabel.Parent = self.interface.root

        self.title.TextTransparency = 1
        sourceLabel.TextTransparency = 1
    end

    -- Hide content first
    local contentTween = game:GetService("TweenService"):Create(
        self.content,
        TweenInfo.new(0.14 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
        {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, -4)
        }
    )
    contentTween:Play()

    task.delay(0.14 * self.interface.config.speed, function()
        self.content.Visible = false
    end)

    -- Shell shrink animation
    task.delay(0, function()
        local shrinkTween = game:GetService("TweenService"):Create(
            self.shell,
            TweenInfo.new(0.405 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(scaleX, 0, scaleY, 0),
                Position = UDim2.new(0, offsetX, 0, offsetY)
            }
        )
        shrinkTween:Play()

        self:_tween(self.shell, "BackgroundTransparency", 1, 0.405)
    end)

    -- Label fly back
    if ghostLabel then
        local targetLabelPos = sourceLabel.AbsolutePosition
        local targetX = targetLabelPos.X - self.interface.root.AbsolutePosition.X
        local targetY = targetLabelPos.Y - self.interface.root.AbsolutePosition.Y

        local flyBackTween = game:GetService("TweenService"):Create(
            ghostLabel,
            TweenInfo.new(0.42 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {
                Position = UDim2.new(0, targetX, 0, targetY),
                TextSize = Theme.typography.size.title
            }
        )
        flyBackTween:Play()
    end

    -- Show home
    task.delay(0.175 * self.interface.config.speed, function()
        self.interface.home:show()
    end)

    -- Cleanup
    task.delay(0.42 * self.interface.config.speed, function()
        if ghostLabel then
            ghostLabel:Destroy()
        end
        if sourceLabel then
            sourceLabel.TextTransparency = 0
            self.title.TextTransparency = 0
        end

        self.container.Visible = false
        self.shell.Size = UDim2.new(1, 0, 1, 0)
        self.shell.Position = UDim2.new(0, 0, 0, 0)
        self.shell.BackgroundTransparency = 0
        self.content.Visible = true
        self.content.BackgroundTransparency = 0
        self.content.Position = UDim2.new(0, 0, 0, 0)
    end)
end

function Window:_tweenProperty(instance, property, value, duration)
    local tweenInfo = TweenInfo.new(
        duration * self.interface.config.speed,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, {[property] = value})
    tween:Play()
end



-- ============================================================================
-- INTERFACE MODULE
-- ============================================================================

    Interface Library
    A lightweight UI library with cold-tone aesthetics and fluid morphing animations.

    Usage:
        local window = UI.new(config)


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
