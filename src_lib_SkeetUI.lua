--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                           SKEET UI LIBRARY                                ║
    ║                   Premium Roblox Script GUI Library                       ║
    ║                       Neverlose/Skeet Style v2.0                          ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
    
    Features:
    - Watermark with FPS/Ping/Time display
    - Fully functional Color Picker (HSV + Alpha)
    - Draggable window with proper rounded corners
    - Smooth animations & transitions
    - Multi-tab system
    - Notification system
    - Keybind system
]]

local SkeetUI = {}
SkeetUI.__index = SkeetUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

-- Theme Definitions
local Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(20, 20, 20),
        Tertiary = Color3.fromRGB(25, 25, 25),
        Surface = Color3.fromRGB(30, 30, 30),
        Border = Color3.fromRGB(45, 45, 45),
        BorderLight = Color3.fromRGB(55, 55, 55),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(140, 140, 140),
        TextDark = Color3.fromRGB(90, 90, 90),
        Accent = Color3.fromRGB(134, 148, 255),
        AccentDark = Color3.fromRGB(100, 115, 220),
        Success = Color3.fromRGB(98, 224, 158),
        Warning = Color3.fromRGB(255, 193, 99),
        Error = Color3.fromRGB(255, 107, 129),
        Gradient1 = Color3.fromRGB(134, 148, 255),
        Gradient2 = Color3.fromRGB(190, 130, 255)
    },
    Midnight = {
        Background = Color3.fromRGB(12, 14, 22),
        Secondary = Color3.fromRGB(16, 18, 28),
        Tertiary = Color3.fromRGB(20, 23, 35),
        Surface = Color3.fromRGB(26, 30, 45),
        Border = Color3.fromRGB(40, 45, 65),
        BorderLight = Color3.fromRGB(50, 55, 80),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(130, 140, 165),
        TextDark = Color3.fromRGB(80, 90, 115),
        Accent = Color3.fromRGB(99, 179, 255),
        AccentDark = Color3.fromRGB(70, 140, 220),
        Success = Color3.fromRGB(98, 224, 158),
        Warning = Color3.fromRGB(255, 193, 99),
        Error = Color3.fromRGB(255, 107, 129),
        Gradient1 = Color3.fromRGB(99, 179, 255),
        Gradient2 = Color3.fromRGB(165, 130, 255)
    },
    Blood = {
        Background = Color3.fromRGB(14, 12, 12),
        Secondary = Color3.fromRGB(18, 15, 15),
        Tertiary = Color3.fromRGB(24, 20, 20),
        Surface = Color3.fromRGB(32, 26, 26),
        Border = Color3.fromRGB(55, 40, 40),
        BorderLight = Color3.fromRGB(70, 50, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(160, 130, 130),
        TextDark = Color3.fromRGB(110, 85, 85),
        Accent = Color3.fromRGB(255, 99, 99),
        AccentDark = Color3.fromRGB(200, 70, 70),
        Success = Color3.fromRGB(98, 224, 158),
        Warning = Color3.fromRGB(255, 193, 99),
        Error = Color3.fromRGB(255, 107, 129),
        Gradient1 = Color3.fromRGB(255, 99, 99),
        Gradient2 = Color3.fromRGB(255, 150, 120)
    },
    Emerald = {
        Background = Color3.fromRGB(10, 14, 12),
        Secondary = Color3.fromRGB(13, 18, 15),
        Tertiary = Color3.fromRGB(18, 24, 20),
        Surface = Color3.fromRGB(24, 32, 27),
        Border = Color3.fromRGB(35, 55, 45),
        BorderLight = Color3.fromRGB(45, 70, 55),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(120, 160, 140),
        TextDark = Color3.fromRGB(75, 110, 90),
        Accent = Color3.fromRGB(98, 224, 158),
        AccentDark = Color3.fromRGB(70, 180, 120),
        Success = Color3.fromRGB(98, 224, 158),
        Warning = Color3.fromRGB(255, 193, 99),
        Error = Color3.fromRGB(255, 107, 129),
        Gradient1 = Color3.fromRGB(98, 224, 158),
        Gradient2 = Color3.fromRGB(130, 255, 200)
    }
}

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function Tween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 4),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function AddPadding(parent, padding)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = parent
    })
end

-- HSV Color Utilities
local function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    
    return Color3.new(r, g, b)
end

local function RGBtoHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max
    
    local d = max - min
    s = max == 0 and 0 or d / max
    
    if max == min then
        h = 0
    else
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    
    return h, s, v
end

local function ColorToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255), 
        math.floor(color.G * 255), 
        math.floor(color.B * 255)
    )
end

-- ═══════════════════════════════════════════════════════════════════════════
-- WATERMARK SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════
function SkeetUI:CreateWatermark(options)
    options = options or {}
    local title = options.Title or "skeet.cc"
    local theme = Themes[options.Theme or "Dark"]
    local position = options.Position or UDim2.new(0, 20, 0, 20)
    local showFPS = options.ShowFPS ~= false
    local showPing = options.ShowPing ~= false
    local showTime = options.ShowTime ~= false
    local showUser = options.ShowUser ~= false
    
    local Watermark = {}
    
    -- Screen GUI
    local ScreenGui = Create("ScreenGui", {
        Name = "SkeetUI_Watermark_" .. tostring(math.random(100000, 999999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
        Parent = CoreGui
    })
    
    Watermark.Gui = ScreenGui
    
    -- Main Container
    local Container = Create("Frame", {
        Name = "WatermarkContainer",
        Size = UDim2.new(0, 0, 0, 24),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = position,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    AddCorner(Container, 4)
    AddStroke(Container, theme.Border, 1)
    
    -- Top gradient line (matches window corner radius)
    local TopLine = Create("Frame", {
        Name = "TopLine",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = Container
    })
    
    -- Use UICorner to match container corners
    local TopLineCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = TopLine
    })
    
    -- Cover bottom of top line rounded corners
    local TopLineCover = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = TopLine
    })
    
    local TopGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Gradient1),
            ColorSequenceKeypoint.new(1, theme.Gradient2)
        }),
        Parent = TopLine
    })
    
    -- Content holder
    local ContentHolder = Create("Frame", {
        Size = UDim2.new(1, 0, 1, -2),
        Position = UDim2.new(0, 0, 0, 2),
        BackgroundTransparency = 1,
        Parent = Container
    })
    
    local ContentLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 0),
        Parent = ContentHolder
    })
    
    local ContentPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = ContentHolder
    })
    
    -- Title
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = theme.Accent,
        Parent = ContentHolder
    })
    
    local function CreateSeparator()
        local Sep = Create("TextLabel", {
            Size = UDim2.new(0, 20, 1, 0),
            BackgroundTransparency = 1,
            Text = "|",
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = theme.Border,
            Parent = ContentHolder
        })
        return Sep
    end
    
    local function CreateInfoLabel(name)
        local Label = Create("TextLabel", {
            Name = name,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = "",
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = theme.TextDim,
            Parent = ContentHolder
        })
        return Label
    end
    
    local labels = {}
    
    if showUser then
        CreateSeparator()
        labels.User = CreateInfoLabel("User")
        labels.User.Text = Player.Name
    end
    
    if showFPS then
        CreateSeparator()
        labels.FPS = CreateInfoLabel("FPS")
    end
    
    if showPing then
        CreateSeparator()
        labels.Ping = CreateInfoLabel("Ping")
    end
    
    if showTime then
        CreateSeparator()
        labels.Time = CreateInfoLabel("Time")
    end
    
    -- Update loop
    local lastTime = tick()
    local frameCount = 0
    local fps = 0
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        
        if tick() - lastTime >= 1 then
            fps = frameCount
            frameCount = 0
            lastTime = tick()
        end
        
        if labels.FPS then
            labels.FPS.Text = tostring(fps) .. " fps"
        end
        
        if labels.Ping then
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            labels.Ping.Text = tostring(ping) .. "ms"
        end
        
        if labels.Time then
            labels.Time.Text = os.date("%H:%M:%S")
        end
    end)
    
    -- Dragging
    local dragging, dragStart, startPos
    
    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Container.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Container.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    function Watermark:SetTitle(newTitle)
        TitleLabel.Text = newTitle
    end
    
    function Watermark:Show()
        Container.Visible = true
    end
    
    function Watermark:Hide()
        Container.Visible = false
    end
    
    function Watermark:Destroy()
        ScreenGui:Destroy()
    end
    
    return Watermark
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MAIN WINDOW CREATION
-- ═══════════════════════════════════════════════════════════════════════════
function SkeetUI:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Skeet"
    local subtitle = options.Subtitle or "premium"
    local size = options.Size or UDim2.new(0, 580, 0, 460)
    local theme = Themes[options.Theme or "Dark"]
    
    local Window = {}
    Window.Tabs = {}
    Window.Theme = theme
    Window.ActiveTab = nil
    
    -- Screen GUI
    local ScreenGui = Create("ScreenGui", {
        Name = "SkeetUI_" .. tostring(math.random(100000, 999999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    Window.Gui = ScreenGui
    
    -- Main Container (with clipping for rounded corners)
    local MainContainer = Create("Frame", {
        Name = "MainContainer",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    AddCorner(MainContainer, 8)
    
    -- Main border stroke
    local MainStroke = AddStroke(MainContainer, theme.Border, 1)
    
    -- Outer glow
    local OuterGlow = Create("ImageLabel", {
        Name = "OuterGlow",
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = theme.Accent,
        ImageTransparency = 0.85,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 0,
        Parent = MainContainer
    })
    
    -- Top gradient line (inside container, clipped by corner)
    local TopGradientLine = Create("Frame", {
        Name = "TopGradientLine",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = MainContainer
    })
    
    local TopGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Gradient1),
            ColorSequenceKeypoint.new(1, theme.Gradient2)
        }),
        Parent = TopGradientLine
    })
    
    -- Bottom Status Bar
    local StatusBar = Create("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 1, -22),
        BackgroundColor3 = theme.Tertiary,
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = MainContainer
    })
    
    -- Status bar top border
    local StatusBorder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Parent = StatusBar
    })
    
    -- Status dot (green = ready)
    local StatusDot = Create("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 12, 0.5, -3),
        BackgroundColor3 = theme.Success,
        BorderSizePixel = 0,
        Parent = StatusBar
    })
    AddCorner(StatusDot, 3)
    
    -- Status text
    local StatusText = Create("TextLabel", {
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = "ready",
        Font = Enum.Font.Code,
        TextSize = 10,
        TextColor3 = theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = StatusBar
    })
    
    -- Build info (center)
    local BuildText = Create("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0.5, -100, 0, 0),
        BackgroundTransparency = 1,
        Text = "build: " .. os.date("%Y%m%d"),
        Font = Enum.Font.Code,
        TextSize = 10,
        TextColor3 = theme.TextDark,
        Parent = StatusBar
    })
    
    -- Version (right side)
    local VersionText = Create("TextLabel", {
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -92, 0, 0),
        BackgroundTransparency = 1,
        Text = "v2.0.0",
        Font = Enum.Font.Code,
        TextSize = 10,
        TextColor3 = theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = StatusBar
    })
    
    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 2),
        BackgroundTransparency = 1,
        Parent = MainContainer
    })
    
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    local SubtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(0, 16 + TitleLabel.TextBounds.X + 6, 0, 0),
        BackgroundTransparency = 1,
        Text = subtitle,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextColor3 = theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Window Controls (FIXED: Minimize left, Close right)
    local Controls = Create("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 70, 0, 20),
        Position = UDim2.new(1, -82, 0, 10),
        BackgroundTransparency = 1,
        Parent = Header
    })
    
    local ControlsLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
        Parent = Controls
    })
    
    -- Minimize Button (comes first in layout = appears on left)
    local MinimizeBtn = Create("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = theme.Surface,
        Text = "",
        LayoutOrder = 1,
        Parent = Controls
    })
    AddCorner(MinimizeBtn, 4)
    AddStroke(MinimizeBtn, theme.Border, 1)
    
    local MinIcon = Create("Frame", {
        Size = UDim2.new(0, 10, 0, 2),
        Position = UDim2.new(0.5, -5, 0.5, -1),
        BackgroundColor3 = theme.TextDim,
        BorderSizePixel = 0,
        Parent = MinimizeBtn
    })
    AddCorner(MinIcon, 1)
    
    -- Close Button (comes second in layout = appears on right)
    local CloseBtn = Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = theme.Surface,
        Text = "",
        LayoutOrder = 2,
        Parent = Controls
    })
    AddCorner(CloseBtn, 4)
    AddStroke(CloseBtn, theme.Border, 1)
    
    local CloseIcon = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = theme.TextDim,
        Parent = CloseBtn
    })
    
    -- Tab Container
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -24, 0, 28),
        Position = UDim2.new(0, 12, 0, 42),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Parent = MainContainer
    })
    AddCorner(TabContainer, 6)
    AddStroke(TabContainer, theme.Border, 1)
    
    local TabHolder = Create("Frame", {
        Name = "TabHolder",
        Size = UDim2.new(1, -8, 1, -6),
        Position = UDim2.new(0, 4, 0, 3),
        BackgroundTransparency = 1,
        Parent = TabContainer
    })
    
    local TabLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        Parent = TabHolder
    })
    
    -- Content Container (adjusted for status bar)
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -24, 1, -106),
        Position = UDim2.new(0, 12, 0, 76),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = MainContainer
    })
    
    -- Notification Container
    local NotificationContainer = Create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 280, 1, -20),
        Position = UDim2.new(1, -290, 0, 10),
        BackgroundTransparency = 1,
        Parent = ScreenGui
    })
    
    local NotificationLayout = Create("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 8),
        Parent = NotificationContainer
    })
    
    -- Dragging
    local dragging, dragStart, startPos
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainContainer.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainContainer.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Control Buttons Logic
    local minimized = false
    local originalSize = size
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(MainContainer, {Size = UDim2.new(0, size.X.Offset, 0, 44)}, 0.3)
            ContentContainer.Visible = false
            TabContainer.Visible = false
            StatusBar.Visible = false
        else
            Tween(MainContainer, {Size = originalSize}, 0.3)
            task.wait(0.2)
            ContentContainer.Visible = true
            TabContainer.Visible = true
            StatusBar.Visible = true
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainContainer, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- Button Hover Effects
    for _, btn in ipairs({MinimizeBtn, CloseBtn}) do
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = theme.Tertiary}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = theme.Surface}, 0.15)
        end)
    end
    
    -- ═══════════════════════════════════════════════════════════════════
    -- NOTIFICATION FUNCTION
    -- ═══════════════════════════════════════════════════════════════════
    function Window:Notify(options)
        options = options or {}
        local notifTitle = options.Title or "Notification"
        local message = options.Message or ""
        local notifType = options.Type or "Info"
        local duration = options.Duration or 4
        
        local colors = {
            Success = theme.Success,
            Warning = theme.Warning,
            Error = theme.Error,
            Info = theme.Accent
        }
        
        local accentColor = colors[notifType] or theme.Accent
        
        local Notification = Create("Frame", {
            Name = "Notification",
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundColor3 = theme.Secondary,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = NotificationContainer
        })
        AddCorner(Notification, 6)
        AddStroke(Notification, theme.Border, 1)
        
        -- Top accent line
        local TopAccent = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Parent = Notification
        })
        
        -- Accent line (left side)
        local AccentLine = Create("Frame", {
            Size = UDim2.new(0, 3, 1, -8),
            Position = UDim2.new(0, 4, 0, 6),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Parent = Notification
        })
        AddCorner(AccentLine, 2)
        
        local NotifTitle = Create("TextLabel", {
            Size = UDim2.new(1, -50, 0, 20),
            Position = UDim2.new(0, 16, 0, 8),
            BackgroundTransparency = 1,
            Text = notifTitle,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notification
        })
        
        local NotifMessage = Create("TextLabel", {
            Size = UDim2.new(1, -24, 0, 30),
            Position = UDim2.new(0, 16, 0, 26),
            BackgroundTransparency = 1,
            Text = message,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = Notification
        })
        
        -- Progress bar
        local ProgressBg = Create("Frame", {
            Size = UDim2.new(1, -16, 0, 2),
            Position = UDim2.new(0, 8, 1, -6),
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0,
            Parent = Notification
        })
        AddCorner(ProgressBg, 1)
        
        local Progress = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Parent = ProgressBg
        })
        AddCorner(Progress, 1)
        
        -- Animation
        Notification.Position = UDim2.new(1, 50, 0, 0)
        Tween(Notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back)
        Tween(Progress, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
        
        task.delay(duration, function()
            Tween(Notification, {Position = UDim2.new(1, 50, 0, 0)}, 0.3)
            task.wait(0.3)
            Notification:Destroy()
        end)
    end
    
    -- ═══════════════════════════════════════════════════════════════════
    -- CREATE TAB FUNCTION
    -- ═══════════════════════════════════════════════════════════════════
    function Window:CreateTab(options)
        options = options or {}
        local tabName = options.Name or "Tab"
        local tabIcon = options.Icon or nil
        
        local Tab = {}
        Tab.Sections = {Left = {}, Right = {}}
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = theme.Tertiary,
            BackgroundTransparency = 1,
            Text = "",
            Parent = TabHolder
        })
        AddCorner(TabButton, 4)
        
        local TabPadding = Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            Parent = TabButton
        })
        
        local TabLabel = Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextColor3 = theme.TextDim,
            Parent = TabButton
        })
        
        -- Tab Content
        local TabContent = Create("Frame", {
            Name = tabName .. "_Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = ContentContainer
        })
        
        -- Left Column
        local LeftColumn = Create("ScrollingFrame", {
            Name = "LeftColumn",
            Size = UDim2.new(0.5, -6, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.Accent,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = TabContent
        })
        
        local LeftLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = LeftColumn
        })
        
        -- Right Column
        local RightColumn = Create("ScrollingFrame", {
            Name = "RightColumn",
            Size = UDim2.new(0.5, -6, 1, 0),
            Position = UDim2.new(0.5, 6, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.Accent,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = TabContent
        })
        
        local RightLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = RightColumn
        })
        
        -- Tab Selection
        local function SelectTab()
            for _, t in ipairs(Window.Tabs) do
                Tween(t.Button, {BackgroundTransparency = 1}, 0.2)
                Tween(t.Label, {TextColor3 = theme.TextDim}, 0.2)
                t.Content.Visible = false
            end
            
            Tween(TabButton, {BackgroundTransparency = 0, BackgroundColor3 = theme.Surface}, 0.2)
            Tween(TabLabel, {TextColor3 = theme.Text}, 0.2)
            TabContent.Visible = true
            Window.ActiveTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        TabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabLabel, {TextColor3 = theme.Text}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabLabel, {TextColor3 = theme.TextDim}, 0.15)
            end
        end)
        
        Tab.Button = TabButton
        Tab.Label = TabLabel
        Tab.Content = TabContent
        Tab.LeftColumn = LeftColumn
        Tab.RightColumn = RightColumn
        
        -- ═══════════════════════════════════════════════════════════════════
        -- CREATE SECTION FUNCTION
        -- ═══════════════════════════════════════════════════════════════════
        function Tab:CreateSection(options)
            options = options or {}
            local sectionName = options.Name or "Section"
            local side = options.Side or "Left"
            local parent = side == "Left" and LeftColumn or RightColumn
            
            local Section = {}
            Section.Elements = {}
            
            local SectionFrame = Create("Frame", {
                Name = sectionName,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Secondary,
                BorderSizePixel = 0,
                Parent = parent
            })
            AddCorner(SectionFrame, 6)
            AddStroke(SectionFrame, theme.Border, 1)
            
            -- Section Header
            local SectionHeader = Create("Frame", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = theme.Tertiary,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Parent = SectionFrame
            })
            
            local HeaderCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = SectionHeader
            })
            
            local CornerCover = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 8),
                Position = UDim2.new(0, 0, 1, -8),
                BackgroundColor3 = theme.Tertiary,
                BorderSizePixel = 0,
                Parent = SectionHeader
            })
            
            local SectionTitle = Create("TextLabel", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            -- Section Content
            local SectionContent = Create("Frame", {
                Name = "Content",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 28),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = SectionFrame
            })
            
            local ContentPadding = Create("UIPadding", {
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = SectionContent
            })
            
            local ContentLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                Parent = SectionContent
            })
            
            Section.Frame = SectionFrame
            Section.Content = SectionContent
            
            -- ═══════════════════════════════════════════
            -- TOGGLE COMPONENT
            -- ═══════════════════════════════════════════
            function Section:CreateToggle(options)
                options = options or {}
                local toggleName = options.Name or "Toggle"
                local default = options.Default or false
                local callback = options.Callback or function() end
                
                local toggled = default
                
                local ToggleFrame = Create("Frame", {
                    Name = toggleName,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    Parent = SectionContent
                })
                AddCorner(ToggleFrame, 4)
                
                local ToggleLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -50, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = toggleName,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = theme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })
                
                local ToggleBox = Create("Frame", {
                    Name = "Box",
                    Size = UDim2.new(0, 36, 0, 18),
                    Position = UDim2.new(1, -44, 0.5, -9),
                    BackgroundColor3 = theme.Tertiary,
                    BorderSizePixel = 0,
                    Parent = ToggleFrame
                })
                AddCorner(ToggleBox, 9)
                AddStroke(ToggleBox, theme.Border, 1)
                
                local ToggleCircle = Create("Frame", {
                    Name = "Circle",
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 2, 0.5, -7),
                    BackgroundColor3 = theme.TextDim,
                    BorderSizePixel = 0,
                    Parent = ToggleBox
                })
                AddCorner(ToggleCircle, 7)
                
                local function UpdateToggle()
                    if toggled then
                        Tween(ToggleBox, {BackgroundColor3 = theme.Accent}, 0.2)
                        Tween(ToggleCircle, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = theme.Text}, 0.2, Enum.EasingStyle.Back)
                        Tween(ToggleLabel, {TextColor3 = theme.Text}, 0.2)
                    else
                        Tween(ToggleBox, {BackgroundColor3 = theme.Tertiary}, 0.2)
                        Tween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = theme.TextDim}, 0.2, Enum.EasingStyle.Back)
                        Tween(ToggleLabel, {TextColor3 = theme.TextDim}, 0.2)
                    end
                end
                
                local ToggleButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = ToggleFrame
                })
                
                ToggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    UpdateToggle()
                    callback(toggled)
                end)
                
                ToggleButton.MouseEnter:Connect(function()
                    Tween(ToggleFrame, {BackgroundColor3 = theme.Tertiary}, 0.15)
                end)
                
                ToggleButton.MouseLeave:Connect(function()
                    Tween(ToggleFrame, {BackgroundColor3 = theme.Surface}, 0.15)
                end)
                
                if default then UpdateToggle() end
                
                return {
                    Set = function(value)
                        toggled = value
                        UpdateToggle()
                        callback(toggled)
                    end,
                    Get = function()
                        return toggled
                    end
                }
            end
            
            -- ═══════════════════════════════════════════
            -- SLIDER COMPONENT
            -- ═══════════════════════════════════════════
            function Section:CreateSlider(options)
                options = options or {}
                local sliderName = options.Name or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local suffix = options.Suffix or ""
                local decimals = options.Decimals or 0
                local callback = options.Callback or function() end
                
                local value = default
                
                local SliderFrame = Create("Frame", {
                    Name = sliderName,
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    Parent = SectionContent
                })
                AddCorner(SliderFrame, 4)
                
                local SliderLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 20),
                    Position = UDim2.new(0, 10, 0, 4),
                    BackgroundTransparency = 1,
                    Text = sliderName,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = theme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame
                })
                
                local ValueLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -56, 0, 4),
                    BackgroundTransparency = 1,
                    Text = tostring(value) .. suffix,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 11,
                    TextColor3 = theme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderFrame
                })
                
                local SliderBg = Create("Frame", {
                    Name = "Background",
                    Size = UDim2.new(1, -20, 0, 6),
                    Position = UDim2.new(0, 10, 0, 28),
                    BackgroundColor3 = theme.Tertiary,
                    BorderSizePixel = 0,
                    Parent = SliderFrame
                })
                AddCorner(SliderBg, 3)
                
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Parent = SliderBg
                })
                AddCorner(SliderFill, 3)
                
                local SliderKnob = Create("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
                    BackgroundColor3 = theme.Text,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    Parent = SliderBg
                })
                AddCorner(SliderKnob, 6)
                
                local sliderDragging = false
                
                local function UpdateSlider(input)
                    local pos = UDim2.new(
                        math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1),
                        0, 1, 0
                    )
                    
                    value = math.floor(((max - min) * pos.X.Scale + min) * (10 ^ decimals)) / (10 ^ decimals)
                    ValueLabel.Text = tostring(value) .. suffix
                    
                    Tween(SliderFill, {Size = UDim2.new(pos.X.Scale, 0, 1, 0)}, 0.05)
                    Tween(SliderKnob, {Position = UDim2.new(pos.X.Scale, -6, 0.5, -6)}, 0.05)
                    
                    callback(value)
                end
                
                SliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliderDragging = true
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliderDragging = false
                    end
                end)
                
                return {
                    Set = function(newValue)
                        value = math.clamp(newValue, min, max)
                        local scale = (value - min) / (max - min)
                        ValueLabel.Text = tostring(value) .. suffix
                        Tween(SliderFill, {Size = UDim2.new(scale, 0, 1, 0)}, 0.2)
                        Tween(SliderKnob, {Position = UDim2.new(scale, -6, 0.5, -6)}, 0.2)
                        callback(value)
                    end,
                    Get = function()
                        return value
                    end
                }
            end
            
            -- ═══════════════════════════════════════════
            -- BUTTON COMPONENT
            -- ═══════════════════════════════════════════
            function Section:CreateButton(options)
                options = options or {}
                local buttonName = options.Name or "Button"
                local callback = options.Callback or function() end
                
                local ButtonFrame = Create("TextButton", {
                    Name = buttonName,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = theme.Accent,
                    Text = "",
                    Parent = SectionContent
                })
                AddCorner(ButtonFrame, 4)
                
                local ButtonGradient = Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.new(0.85, 0.85, 0.85))
                    }),
                    Rotation = 90,
                    Parent = ButtonFrame
                })
                
                local ButtonLabel = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = buttonName,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 11,
                    TextColor3 = Color3.new(1, 1, 1),
                    Parent = ButtonFrame
                })
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    Tween(ButtonFrame, {Size = UDim2.new(1, -4, 0, 26)}, 0.1)
                    task.wait(0.1)
                    Tween(ButtonFrame, {Size = UDim2.new(1, 0, 0, 28)}, 0.1)
                    callback()
                end)
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = theme.AccentDark}, 0.15)
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = theme.Accent}, 0.15)
                end)
            end
            
            -- ═══════════════════════════════════════════
            -- DROPDOWN COMPONENT
            -- ═══════════════════════════════════════════
            function Section:CreateDropdown(options)
                options = options or {}
                local dropdownName = options.Name or "Dropdown"
                local optionsList = options.Options or {}
                local default = options.Default or (optionsList[1] or "")
                local callback = options.Callback or function() end
                
                local selected = default
                local opened = false
                
                local DropdownFrame = Create("Frame", {
                    Name = dropdownName,
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundColor3 = theme.Surface,
                    ClipsDescendants = true,
                    BorderSizePixel = 0,
                    Parent = SectionContent
                })
                AddCorner(DropdownFrame, 4)
                
                local DropdownLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -16, 0, 18),
                    Position = UDim2.new(0, 10, 0, 4),
                    BackgroundTransparency = 1,
                    Text = dropdownName,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = theme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownFrame
                })
                
                local SelectedFrame = Create("Frame", {
                    Name = "Selected",
                    Size = UDim2.new(1, -16, 0, 24),
                    Position = UDim2.new(0, 8, 0, 22),
                    BackgroundColor3 = theme.Tertiary,
                    BorderSizePixel = 0,
                    Parent = DropdownFrame
                })
                AddCorner(SelectedFrame, 4)
                AddStroke(SelectedFrame, theme.Border, 1)
                
                local SelectedLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = selected,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 11,
                    TextColor3 = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SelectedFrame
                })
                
                local Arrow = Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -24, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    Font = Enum.Font.Gotham,
                    TextSize = 8,
                    TextColor3 = theme.TextDim,
                    Parent = SelectedFrame
                })
                
                local OptionsContainer = Create("Frame", {
                    Name = "Options",
                    Size = UDim2.new(1, -16, 0, 0),
                    Position = UDim2.new(0, 8, 0, 50),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Parent = DropdownFrame
                })
                
                local OptionsLayout = Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = OptionsContainer
                })
                
                local function CreateOption(optionText)
                    local OptionButton = Create("TextButton", {
                        Name = optionText,
                        Size = UDim2.new(1, 0, 0, 24),
                        BackgroundColor3 = theme.Tertiary,
                        Text = "",
                        Parent = OptionsContainer
                    })
                    AddCorner(OptionButton, 4)
                    
                    local OptionLabel = Create("TextLabel", {
                        Size = UDim2.new(1, -20, 1, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        BackgroundTransparency = 1,
                        Text = optionText,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        TextColor3 = theme.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = OptionButton
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = theme.Surface}, 0.15)
                        Tween(OptionLabel, {TextColor3 = theme.Text}, 0.15)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = theme.Tertiary}, 0.15)
                        Tween(OptionLabel, {TextColor3 = theme.TextDim}, 0.15)
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        selected = optionText
                        SelectedLabel.Text = optionText
                        opened = false
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.2)
                        Tween(Arrow, {Rotation = 0}, 0.2)
                        callback(optionText)
                    end)
                end
                
                for _, opt in ipairs(optionsList) do
                    CreateOption(opt)
                end
                
                local DropdownButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = DropdownFrame
                })
                
                DropdownButton.MouseButton1Click:Connect(function()
                    opened = not opened
                    local optionsHeight = #optionsList * 26
                    
                    if opened then
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 54 + optionsHeight)}, 0.2)
                        Tween(Arrow, {Rotation = 180}, 0.2)
                    else
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.2)
                        Tween(Arrow, {Rotation = 0}, 0.2)
                    end
                end)
                
                return {
                    Set = function(value)
                        if table.find(optionsList, value) then
                            selected = value
                            SelectedLabel.Text = value
                            callback(value)
                        end
                    end,
                    Get = function()
                        return selected
                    end,
                    Refresh = function(newOptions)
                        for _, child in ipairs(OptionsContainer:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end
                        optionsList = newOptions
                        for _, opt in ipairs(optionsList) do
                            CreateOption(opt)
                        end
                    end
                }
            end
            
            -- ═══════════════════════════════════════════
            -- INPUT COMPONENT
            -- ═══════════════════════════════════════════
            function Section:CreateInput(options)
                options = options or {}
                local inputName = options.Name or "Input"
                local placeholder = options.Placeholder or "Enter text..."
                local default = options.Default or ""
                local callback = options.Callback or function() end
                
                local InputFrame = Create("Frame", {
                    Name = inputName,
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    Parent = SectionContent
                })
                AddCorner(InputFrame, 4)
                
                local InputLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -16, 0, 18),
                    Position = UDim2.new(0, 10, 0, 4),
                    BackgroundTransparency = 1,
                    Text = inputName,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = theme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = InputFrame
                })
                
                local InputBox = Create("TextBox", {
                    Name = "Input",
                    Size = UDim2.new(1, -16, 0, 24),
                    Position = UDim2.new(0, 8, 0, 22),
                    BackgroundColor3 = theme.Tertiary,
                    Text = default,
                    PlaceholderText = placeholder,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = theme.Text,
                    PlaceholderColor3 = theme.TextDark,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    BorderSizePixel = 0,
                    Parent = InputFrame
                })
                AddCorner(InputBox, 4)
                AddStroke(InputBox, theme.Border, 1)
                AddPadding(InputBox, 8)
                
                InputBox.Focused:Connect(function()
                    Tween(InputBox, {BackgroundColor3 = theme.Surface}, 0.15)
                end)
                
                InputBox.FocusLost:Connect(function(enterPressed)
                    Tween(InputBox, {BackgroundColor3 = theme.Tertiary}, 0.15)
                    callback(InputBox.Text, enterPressed)
                end)
                
                return {
                    Set = function(value)
                        InputBox.Text = value
                    end,
                    Get = function()
                        return InputBox.Text
                    end
                }
            end
            
            -- ═══════════════════════════════════════════
            -- KEYBIND COMPONENT
            -- ═══════════════════════════════════════════
            function Section:CreateKeybind(options)
                options = options or {}
                local keybindName = options.Name or "Keybind"
                local default = options.Default or Enum.KeyCode.Unknown
                local callback = options.Callback or function() end
                
                local currentKey = default
                local listening = false
                
                local KeybindFrame = Create("Frame", {
                    Name = keybindName,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    Parent = SectionContent
                })
                AddCorner(KeybindFrame, 4)
                
                local KeybindLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -80, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = keybindName,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = theme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeybindFrame
                })
                
                local KeyButton = Create("TextButton", {
                    Name = "KeyButton",
                    Size = UDim2.new(0, 60, 0, 20),
                    Position = UDim2.new(1, -68, 0.5, -10),
                    BackgroundColor3 = theme.Tertiary,
                    Text = currentKey.Name or "None",
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    TextColor3 = theme.Accent,
                    Parent = KeybindFrame
                })
                AddCorner(KeyButton, 4)
                AddStroke(KeyButton, theme.Border, 1)
                
                KeyButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeyButton.Text = "..."
                    Tween(KeyButton, {BackgroundColor3 = theme.Surface}, 0.15)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            KeyButton.Text = input.KeyCode.Name
                            listening = false
                            Tween(KeyButton, {BackgroundColor3 = theme.Tertiary}, 0.15)
                        end
                    else
                        if input.KeyCode == currentKey then
                            callback(currentKey)
                        end
                    end
                end)
                
                return {
                    Set = function(key)
                        currentKey = key
                        KeyButton.Text = key.Name
                    end,
                    Get = function()
                        return currentKey
                    end
                }
            end
            
            -- ═══════════════════════════════════════════
            -- FULL COLOR PICKER COMPONENT (HSV + ALPHA)
            -- ═══════════════════════════════════════════
            function Section:CreateColorPicker(options)
                options = options or {}
                local pickerName = options.Name or "Color"
                local default = options.Default or Color3.fromRGB(134, 148, 255)
                local defaultAlpha = options.Alpha or 1
                local callback = options.Callback or function() end
                
                local currentColor = default
                local currentAlpha = defaultAlpha
                local h, s, v = RGBtoHSV(default)
                local opened = false
                
                local ColorFrame = Create("Frame", {
                    Name = pickerName,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = theme.Surface,
                    ClipsDescendants = true,
                    BorderSizePixel = 0,
                    Parent = SectionContent
                })
                AddCorner(ColorFrame, 4)
                
                local ColorLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -50, 0, 28),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = pickerName,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = theme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorFrame
                })
                
                -- Color Preview with checkerboard for alpha
                local PreviewContainer = Create("Frame", {
                    Name = "PreviewContainer",
                    Size = UDim2.new(0, 32, 0, 16),
                    Position = UDim2.new(1, -42, 0, 6),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Parent = ColorFrame
                })
                AddCorner(PreviewContainer, 4)
                AddStroke(PreviewContainer, theme.Border, 1)
                
                local ColorPreview = Create("Frame", {
                    Name = "Preview",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = currentColor,
                    BackgroundTransparency = 1 - currentAlpha,
                    BorderSizePixel = 0,
                    Parent = PreviewContainer
                })
                AddCorner(ColorPreview, 4)
                
                -- ═══ PICKER PANEL ═══
                local PickerPanel = Create("Frame", {
                    Name = "PickerPanel",
                    Size = UDim2.new(1, -16, 0, 160),
                    Position = UDim2.new(0, 8, 0, 34),
                    BackgroundColor3 = theme.Tertiary,
                    Visible = false,
                    BorderSizePixel = 0,
                    Parent = ColorFrame
                })
                AddCorner(PickerPanel, 4)
                AddStroke(PickerPanel, theme.Border, 1)
                
                -- ═══ SATURATION/VALUE PICKER ═══
                local SVPicker = Create("Frame", {
                    Name = "SVPicker",
                    Size = UDim2.new(1, -50, 0, 100),
                    Position = UDim2.new(0, 8, 0, 8),
                    BackgroundColor3 = HSVtoRGB(h, 1, 1),
                    BorderSizePixel = 0,
                    Parent = PickerPanel
                })
                AddCorner(SVPicker, 4)
                
                -- White gradient (saturation)
                local WhiteGradient = Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Parent = SVPicker
                })
                AddCorner(WhiteGradient, 4)
                
                Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }),
                    Parent = WhiteGradient
                })
                
                -- Black gradient (value)
                local BlackGradient = Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    Parent = SVPicker
                })
                AddCorner(BlackGradient, 4)
                
                Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }),
                    Rotation = 90,
                    Parent = BlackGradient
                })
                
                -- SV Cursor
                local SVCursor = Create("Frame", {
                    Name = "Cursor",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(s, -6, 1 - v, -6),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = SVPicker
                })
                AddCorner(SVCursor, 6)
                AddStroke(SVCursor, Color3.new(0, 0, 0), 2)
                
                -- ═══ HUE SLIDER ═══
                local HueSlider = Create("Frame", {
                    Name = "HueSlider",
                    Size = UDim2.new(0, 16, 0, 100),
                    Position = UDim2.new(1, -32, 0, 8),
                    BorderSizePixel = 0,
                    Parent = PickerPanel
                })
                AddCorner(HueSlider, 4)
                
                Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    }),
                    Rotation = 90,
                    Parent = HueSlider
                })
                
                -- Hue Cursor
                local HueCursor = Create("Frame", {
                    Name = "Cursor",
                    Size = UDim2.new(1, 4, 0, 6),
                    Position = UDim2.new(0, -2, h, -3),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = HueSlider
                })
                AddCorner(HueCursor, 2)
                AddStroke(HueCursor, Color3.new(0, 0, 0), 1)
                
                -- ═══ ALPHA SLIDER ═══
                local AlphaContainer = Create("Frame", {
                    Name = "AlphaContainer",
                    Size = UDim2.new(1, -50, 0, 14),
                    Position = UDim2.new(0, 8, 0, 116),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Parent = PickerPanel
                })
                AddCorner(AlphaContainer, 4)
                
                local AlphaSlider = Create("Frame", {
                    Name = "AlphaSlider",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = currentColor,
                    BorderSizePixel = 0,
                    Parent = AlphaContainer
                })
                AddCorner(AlphaSlider, 4)
                
                Create("UIGradient", {
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }),
                    Parent = AlphaSlider
                })
                
                -- Alpha Cursor
                local AlphaCursor = Create("Frame", {
                    Name = "Cursor",
                    Size = UDim2.new(0, 6, 1, 4),
                    Position = UDim2.new(currentAlpha, -3, 0, -2),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = AlphaContainer
                })
                AddCorner(AlphaCursor, 2)
                AddStroke(AlphaCursor, Color3.new(0, 0, 0), 1)
                
                -- ═══ HEX DISPLAY ═══
                local HexLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 60, 0, 14),
                    Position = UDim2.new(1, -68, 0, 116),
                    BackgroundTransparency = 1,
                    Text = ColorToHex(currentColor),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    TextColor3 = theme.TextDim,
                    Parent = PickerPanel
                })
                
                -- ═══ PRESET COLORS ═══
                local PresetContainer = Create("Frame", {
                    Size = UDim2.new(1, -16, 0, 18),
                    Position = UDim2.new(0, 8, 0, 136),
                    BackgroundTransparency = 1,
                    Parent = PickerPanel
                })
                
                local PresetLayout = Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 4),
                    Parent = PresetContainer
                })
                
                local presetColors = {
                    Color3.fromRGB(255, 0, 0),
                    Color3.fromRGB(255, 127, 0),
                    Color3.fromRGB(255, 255, 0),
                    Color3.fromRGB(0, 255, 0),
                    Color3.fromRGB(0, 255, 255),
                    Color3.fromRGB(0, 127, 255),
                    Color3.fromRGB(0, 0, 255),
                    Color3.fromRGB(127, 0, 255),
                    Color3.fromRGB(255, 0, 255),
                    Color3.fromRGB(255, 255, 255),
                    Color3.fromRGB(128, 128, 128),
                    Color3.fromRGB(0, 0, 0)
                }
                
                -- ═══ UPDATE FUNCTIONS ═══
                local function UpdateColor()
                    currentColor = HSVtoRGB(h, s, v)
                    ColorPreview.BackgroundColor3 = currentColor
                    ColorPreview.BackgroundTransparency = 1 - currentAlpha
                    SVPicker.BackgroundColor3 = HSVtoRGB(h, 1, 1)
                    AlphaSlider.BackgroundColor3 = currentColor
                    HexLabel.Text = ColorToHex(currentColor)
                    callback(currentColor, currentAlpha)
                end
                
                -- Create preset buttons
                for _, presetColor in ipairs(presetColors) do
                    local PresetBtn = Create("TextButton", {
                        Size = UDim2.new(0, 18, 0, 18),
                        BackgroundColor3 = presetColor,
                        Text = "",
                        Parent = PresetContainer
                    })
                    AddCorner(PresetBtn, 4)
                    AddStroke(PresetBtn, theme.Border, 1)
                    
                    PresetBtn.MouseButton1Click:Connect(function()
                        h, s, v = RGBtoHSV(presetColor)
                        SVCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                        HueCursor.Position = UDim2.new(0, -2, h, -3)
                        UpdateColor()
                    end)
                end
                
                -- SV Picker interaction
                local svDragging = false
                
                SVPicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = true
                        local relativeX = math.clamp((input.Position.X - SVPicker.AbsolutePosition.X) / SVPicker.AbsoluteSize.X, 0, 1)
                        local relativeY = math.clamp((input.Position.Y - SVPicker.AbsolutePosition.Y) / SVPicker.AbsoluteSize.Y, 0, 1)
                        s = relativeX
                        v = 1 - relativeY
                        SVCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                        UpdateColor()
                    end
                end)
                
                -- Hue Slider interaction
                local hueDragging = false
                
                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = true
                        local relativeY = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                        h = relativeY
                        HueCursor.Position = UDim2.new(0, -2, h, -3)
                        UpdateColor()
                    end
                end)
                
                -- Alpha Slider interaction
                local alphaDragging = false
                
                AlphaContainer.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        alphaDragging = true
                        local relativeX = math.clamp((input.Position.X - AlphaContainer.AbsolutePosition.X) / AlphaContainer.AbsoluteSize.X, 0, 1)
                        currentAlpha = relativeX
                        AlphaCursor.Position = UDim2.new(currentAlpha, -3, 0, -2)
                        UpdateColor()
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if svDragging then
                            local relativeX = math.clamp((input.Position.X - SVPicker.AbsolutePosition.X) / SVPicker.AbsoluteSize.X, 0, 1)
                            local relativeY = math.clamp((input.Position.Y - SVPicker.AbsolutePosition.Y) / SVPicker.AbsoluteSize.Y, 0, 1)
                            s = relativeX
                            v = 1 - relativeY
                            SVCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                            UpdateColor()
                        elseif hueDragging then
                            local relativeY = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                            h = relativeY
                            HueCursor.Position = UDim2.new(0, -2, h, -3)
                            UpdateColor()
                        elseif alphaDragging then
                            local relativeX = math.clamp((input.Position.X - AlphaContainer.AbsolutePosition.X) / AlphaContainer.AbsoluteSize.X, 0, 1)
                            currentAlpha = relativeX
                            AlphaCursor.Position = UDim2.new(currentAlpha, -3, 0, -2)
                            UpdateColor()
                        end
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = false
                        hueDragging = false
                        alphaDragging = false
                    end
                end)
                
                -- Toggle picker
                local ToggleButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = ColorFrame
                })
                
                ToggleButton.MouseButton1Click:Connect(function()
                    opened = not opened
                    
                    if opened then
                        PickerPanel.Visible = true
                        Tween(ColorFrame, {Size = UDim2.new(1, 0, 0, 200)}, 0.25)
                    else
                        Tween(ColorFrame, {Size = UDim2.new(1, 0, 0, 28)}, 0.25)
                        task.wait(0.25)
                        PickerPanel.Visible = false
                    end
                end)
                
                return {
                    Set = function(color, alpha)
                        currentColor = color
                        currentAlpha = alpha or 1
                        h, s, v = RGBtoHSV(color)
                        SVCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                        HueCursor.Position = UDim2.new(0, -2, h, -3)
                        AlphaCursor.Position = UDim2.new(currentAlpha, -3, 0, -2)
                        UpdateColor()
                    end,
                    Get = function()
                        return currentColor, currentAlpha
                    end
                }
            end
            
            -- ═══════════════════════════════════════════
            -- LABEL COMPONENT
            -- ═══════════════════════════════════════════
            function Section:CreateLabel(text)
                local LabelFrame = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = text or "Label",
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = theme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SectionContent
                })
                
                return {
                    Set = function(newText)
                        LabelFrame.Text = newText
                    end
                }
            end
            
            -- ═══════════════════════════════════════════
            -- SEPARATOR COMPONENT
            -- ═══════════════════════════════════════════
            function Section:CreateSeparator()
                Create("Frame", {
                    Name = "Separator",
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = theme.Border,
                    BorderSizePixel = 0,
                    Parent = SectionContent
                })
            end
            
            table.insert(Tab.Sections[side], Section)
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            SelectTab()
        end
        
        return Tab
    end
    
    -- Entry animation
    MainContainer.Size = UDim2.new(0, 0, 0, 0)
    MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(MainContainer, {
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    }, 0.4, Enum.EasingStyle.Back)
    
    return Window
end

return SkeetUI
