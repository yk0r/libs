--[[
    FSLib - Premium Roblox Script GUI Library
    Build 1.0.0
    
    Features:
    - Horizontal Tab Layout (tabs on top)
    - Full-featured ColorPicker with HSV + Alpha
    - Draggable Window & Watermark
    - Multi-Dropdown support
    - Customizable StatusBar
    - 4 Premium Themes
]]

local FSLib = {}
FSLib.__index = FSLib
FSLib.Version = "1.0.0"

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Themes
local Themes = {
    Default = {
        Primary = Color3.fromRGB(18, 18, 22),
        Secondary = Color3.fromRGB(24, 24, 30),
        Tertiary = Color3.fromRGB(32, 32, 40),
        Accent = Color3.fromRGB(139, 92, 246),
        AccentDark = Color3.fromRGB(109, 62, 216),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(50, 50, 60),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68)
    },
    Blood = {
        Primary = Color3.fromRGB(18, 14, 14),
        Secondary = Color3.fromRGB(28, 20, 20),
        Tertiary = Color3.fromRGB(40, 28, 28),
        Accent = Color3.fromRGB(220, 38, 38),
        AccentDark = Color3.fromRGB(180, 28, 28),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(160, 140, 140),
        Border = Color3.fromRGB(60, 40, 40),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68)
    },
    Ocean = {
        Primary = Color3.fromRGB(12, 18, 24),
        Secondary = Color3.fromRGB(18, 26, 34),
        Tertiary = Color3.fromRGB(26, 36, 48),
        Accent = Color3.fromRGB(56, 189, 248),
        AccentDark = Color3.fromRGB(36, 159, 218),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(140, 160, 180),
        Border = Color3.fromRGB(40, 55, 70),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68)
    },
    Mint = {
        Primary = Color3.fromRGB(14, 20, 18),
        Secondary = Color3.fromRGB(20, 28, 26),
        Tertiary = Color3.fromRGB(28, 40, 36),
        Accent = Color3.fromRGB(52, 211, 153),
        AccentDark = Color3.fromRGB(32, 181, 123),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(140, 170, 160),
        Border = Color3.fromRGB(40, 60, 55),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68)
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
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function HSVtoRGB(h, s, v)
    h = h % 360
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    local r, g, b = 0, 0, 0
    
    if h < 60 then r, g, b = c, x, 0
    elseif h < 120 then r, g, b = x, c, 0
    elseif h < 180 then r, g, b = 0, c, x
    elseif h < 240 then r, g, b = 0, x, c
    elseif h < 300 then r, g, b = x, 0, c
    else r, g, b = c, 0, x
    end
    
    return Color3.new(r + m, g + m, b + m)
end

local function RGBtoHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min
    
    local h, s, v = 0, 0, max
    
    if max ~= 0 then
        s = delta / max
    end
    
    if delta ~= 0 then
        if max == r then
            h = 60 * (((g - b) / delta) % 6)
        elseif max == g then
            h = 60 * (((b - r) / delta) + 2)
        else
            h = 60 * (((r - g) / delta) + 4)
        end
    end
    
    if h < 0 then h = h + 360 end
    
    return h, s, v
end

local function ColorToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255), 
        math.floor(color.G * 255), 
        math.floor(color.B * 255))
end

local function Draggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Create Window
function FSLib:CreateWindow(options)
    options = options or {}
    local title = options.Title or "FSLib"
    local subtitle = options.Subtitle or "Build 1.0.0"
    local themeName = options.Theme or "Default"
    local theme = Themes[themeName] or Themes.Default
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    local statusBarConfig = options.StatusBar or {}
    
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Theme = theme
    
    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "FSLib",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = game:GetService("CoreGui")
    })
    Window.ScreenGui = ScreenGui
    
    -- Main Container - This clips everything
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 580, 0, 420),
        Position = UDim2.new(0.5, -290, 0.5, -210),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MainFrame })
    
    -- Border Frame (separate, behind main)
    local BorderFrame = Create("Frame", {
        Name = "Border",
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = MainFrame
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 9), Parent = BorderFrame })
    
    -- Inner container to cover border
    local InnerFrame = Create("Frame", {
        Name = "Inner",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 1,
        ClipsDescendants = true,
        Parent = MainFrame
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = InnerFrame })
    
    -- Accent Line (inside, at top)
    local AccentLine = Create("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, -16, 0, 2),
        Position = UDim2.new(0, 8, 0, 6),
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = InnerFrame
    })
    local AccentGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Accent),
            ColorSequenceKeypoint.new(0.5, theme.AccentDark),
            ColorSequenceKeypoint.new(1, theme.Accent)
        }),
        Parent = AccentLine
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 1), Parent = AccentLine })
    
    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = InnerFrame
    })
    
    -- Title
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = Header
    })
    
    -- Subtitle
    local SubtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 14 + TitleLabel.TextBounds.X + 8, 0, 0),
        BackgroundTransparency = 1,
        Text = subtitle,
        TextColor3 = theme.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = Header
    })
    
    TitleLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        SubtitleLabel.Position = UDim2.new(0, 14 + TitleLabel.TextBounds.X + 8, 0, 0)
    end)
    
    -- Keybind Hint
    local KeybindHint = Create("TextLabel", {
        Name = "KeybindHint",
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -110, 0, 0),
        BackgroundTransparency = 1,
        Text = "[" .. toggleKey.Name .. "]",
        TextColor3 = theme.TextDark,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 3,
        Parent = Header
    })
    
    -- Tab Bar (Horizontal - at top)
    local TabBar = Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, -20, 0, 32),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = InnerFrame
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabBar })
    Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = TabBar })
    
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -8, 1, -6),
        Position = UDim2.new(0, 4, 0, 3),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = TabBar
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = TabContainer
    })
    
    -- Content Area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -20, 1, -100),
        Position = UDim2.new(0, 10, 0, 78),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 2,
        ClipsDescendants = true,
        Parent = InnerFrame
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ContentArea })
    Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = ContentArea })
    
    -- Status Bar
    local StatusBar = Create("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 1, -24),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 2,
        Visible = statusBarConfig.Visible ~= false,
        Parent = InnerFrame
    })
    
    local StatusDot = Create("Frame", {
        Name = "StatusDot",
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 12, 0.5, -3),
        BackgroundColor3 = theme.Success,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = StatusBar
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = StatusDot })
    
    local StatusText = Create("TextLabel", {
        Name = "StatusText",
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = statusBarConfig.Text or "ready",
        TextColor3 = theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = StatusBar
    })
    
    local BuildText = Create("TextLabel", {
        Name = "BuildText",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = statusBarConfig.Build or "build: " .. os.date("%Y%m%d"),
        TextColor3 = theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3,
        Parent = StatusBar
    })
    
    local VersionText = Create("TextLabel", {
        Name = "VersionText",
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -112, 0, 0),
        BackgroundTransparency = 1,
        Text = statusBarConfig.Version or "v1.0.0",
        TextColor3 = theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 3,
        Parent = StatusBar
    })
    
    -- Draggable
    Draggable(MainFrame, Header)
    
    -- Toggle Key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    -- Set Status Bar
    function Window:SetStatusBar(config)
        if config.Text then StatusText.Text = config.Text end
        if config.Build then BuildText.Text = config.Build end
        if config.Version then VersionText.Text = config.Version end
        if config.Visible ~= nil then StatusBar.Visible = config.Visible end
        if config.Status then
            local colors = {
                ready = theme.Success,
                loading = theme.Warning,
                error = theme.Error,
                offline = theme.TextDark
            }
            StatusDot.BackgroundColor3 = colors[config.Status] or theme.Success
        end
    end
    
    -- Notify System
    local NotifyContainer = Create("Frame", {
        Name = "NotifyContainer",
        Size = UDim2.new(0, 280, 1, -20),
        Position = UDim2.new(1, -290, 0, 10),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Parent = ScreenGui
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Parent = NotifyContainer
    })
    
    function Window:Notify(options)
        local notifyTitle = options.Title or "Notification"
        local message = options.Message or ""
        local notifyType = options.Type or "Info"
        local duration = options.Duration or 4
        
        local typeColors = {
            Success = theme.Success,
            Warning = theme.Warning,
            Error = theme.Error,
            Info = theme.Accent
        }
        local typeIcons = {
            Success = "✓",
            Warning = "⚠",
            Error = "✕",
            Info = "ℹ"
        }
        
        local accentColor = typeColors[notifyType] or theme.Accent
        local icon = typeIcons[notifyType] or "ℹ"
        
        -- Container with everything grouped
        local NotifyFrame = Create("Frame", {
            Name = "Notify",
            Size = UDim2.new(1, 0, 0, 72),
            BackgroundColor3 = theme.Primary,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            ZIndex = 100,
            Parent = NotifyContainer
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = NotifyFrame })
        
        -- Background (will be faded in)
        local NotifyBg = Create("Frame", {
            Name = "Background",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = theme.Primary,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 100,
            Parent = NotifyFrame
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = NotifyBg })
        Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 1, Parent = NotifyBg })
        
        -- Accent line at top
        local NotifyAccent = Create("Frame", {
            Name = "Accent",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = accentColor,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 102,
            Parent = NotifyFrame
        })
        
        -- Icon
        local IconLabel = Create("TextLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(0, 12, 0, 14),
            BackgroundColor3 = accentColor,
            BackgroundTransparency = 1,
            Text = icon,
            TextColor3 = accentColor,
            TextTransparency = 1,
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            ZIndex = 101,
            Parent = NotifyFrame
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = IconLabel })
        
        -- Title
        local NotifyTitle = Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -56, 0, 18),
            Position = UDim2.new(0, 48, 0, 12),
            BackgroundTransparency = 1,
            Text = notifyTitle,
            TextColor3 = theme.Text,
            TextTransparency = 1,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 101,
            Parent = NotifyFrame
        })
        
        -- Message
        local NotifyMessage = Create("TextLabel", {
            Name = "Message",
            Size = UDim2.new(1, -56, 0, 28),
            Position = UDim2.new(0, 48, 0, 30),
            BackgroundTransparency = 1,
            Text = message,
            TextColor3 = theme.TextDark,
            TextTransparency = 1,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            ZIndex = 101,
            Parent = NotifyFrame
        })
        
        -- Progress bar
        local ProgressBar = Create("Frame", {
            Name = "Progress",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = accentColor,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 102,
            Parent = NotifyFrame
        })
        
        -- Animate in (all together)
        Tween(NotifyBg, {BackgroundTransparency = 0}, 0.3)
        Tween(NotifyBg:FindFirstChild("UIStroke"), {Transparency = 0}, 0.3)
        Tween(NotifyAccent, {BackgroundTransparency = 0}, 0.3)
        Tween(IconLabel, {BackgroundTransparency = 0.85, TextTransparency = 0}, 0.3)
        Tween(NotifyTitle, {TextTransparency = 0}, 0.3)
        Tween(NotifyMessage, {TextTransparency = 0}, 0.3)
        Tween(ProgressBar, {BackgroundTransparency = 0}, 0.3)
        
        -- Progress countdown
        Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)
        
        -- Fade out and destroy (all together)
        task.delay(duration, function()
            Tween(NotifyBg, {BackgroundTransparency = 1}, 0.3)
            Tween(NotifyBg:FindFirstChild("UIStroke"), {Transparency = 1}, 0.3)
            Tween(NotifyAccent, {BackgroundTransparency = 1}, 0.3)
            Tween(IconLabel, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
            Tween(NotifyTitle, {TextTransparency = 1}, 0.3)
            Tween(NotifyMessage, {TextTransparency = 1}, 0.3)
            Tween(ProgressBar, {BackgroundTransparency = 1}, 0.3)
            
            task.wait(0.35)
            NotifyFrame:Destroy()
        end)
    end
    
    -- Create Tab
    function Window:CreateTab(options)
        options = options or {}
        local tabName = options.Name or "Tab"
        local tabIcon = options.Icon or ""
        
        local Tab = {}
        Tab.Sections = { Left = {}, Right = {} }
        
        local tabIndex = #Window.Tabs + 1
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = theme.Tertiary,
            BackgroundTransparency = 1,
            Text = "",
            BorderSizePixel = 0,
            ZIndex = 4,
            LayoutOrder = tabIndex,
            Parent = TabContainer
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TabButton })
        Create("UIPadding", { 
            PaddingLeft = UDim.new(0, 12), 
            PaddingRight = UDim.new(0, 12),
            Parent = TabButton 
        })
        
        local TabLabel = Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = (tabIcon ~= "" and tabIcon .. "  " or "") .. tabName,
            TextColor3 = theme.TextDark,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            ZIndex = 5,
            Parent = TabButton
        })
        
        -- Tab Content (two columns side by side)
        local TabContent = Create("Frame", {
            Name = tabName .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 3,
            Parent = ContentArea
        })
        
        -- Left Column
        local LeftColumn = Create("ScrollingFrame", {
            Name = "LeftColumn",
            Size = UDim2.new(0.5, -5, 1, -10),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 3,
            Parent = TabContent
        })
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = LeftColumn
        })
        
        -- Right Column
        local RightColumn = Create("ScrollingFrame", {
            Name = "RightColumn",
            Size = UDim2.new(0.5, -5, 1, -10),
            Position = UDim2.new(0.5, 0, 0, 5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 3,
            Parent = TabContent
        })
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = RightColumn
        })
        
        Tab.Content = TabContent
        Tab.LeftColumn = LeftColumn
        Tab.RightColumn = RightColumn
        
        -- Tab Button Click
        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false
                t.Button.BackgroundTransparency = 1
                t.Label.TextColor3 = theme.TextDark
            end
            Tab.Content.Visible = true
            Tab.Button.BackgroundTransparency = 0
            Tab.Label.TextColor3 = theme.Text
            Window.ActiveTab = Tab
        end)
        
        Tab.Button = TabButton
        Tab.Label = TabLabel
        
        table.insert(Window.Tabs, Tab)
        
        -- Activate first tab
        if #Window.Tabs == 1 then
            Tab.Content.Visible = true
            Tab.Button.BackgroundTransparency = 0
            Tab.Label.TextColor3 = theme.Text
            Window.ActiveTab = Tab
        end
        
        -- Create Section
        function Tab:CreateSection(options)
            options = options or {}
            local sectionName = options.Name or "Section"
            local side = options.Side or "Left"
            
            local Section = {}
            local column = side == "Left" and LeftColumn or RightColumn
            
            local sectionIndex = #Tab.Sections[side] + 1
            
            local SectionFrame = Create("Frame", {
                Name = sectionName,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Tertiary,
                BorderSizePixel = 0,
                LayoutOrder = sectionIndex,
                ZIndex = 4,
                Parent = column
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SectionFrame })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = SectionFrame })
            Create("UIPadding", { 
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                Parent = SectionFrame 
            })
            
            local SectionTitle = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = sectionName:upper(),
                TextColor3 = theme.TextDark,
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 0,
                ZIndex = 5,
                Parent = SectionFrame
            })
            
            local ElementContainer = Create("Frame", {
                Name = "Elements",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                ZIndex = 5,
                Parent = SectionFrame
            })
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
                Parent = ElementContainer
            })
            
            table.insert(Tab.Sections[side], Section)
            
            local elementOrder = 0
            local function getOrder()
                elementOrder = elementOrder + 1
                return elementOrder
            end
            
            -- Toggle
            function Section:CreateToggle(options)
                options = options or {}
                local toggleName = options.Name or "Toggle"
                local default = options.Default or false
                local callback = options.Callback or function() end
                
                local Toggle = { Value = default }
                
                local ToggleFrame = Create("Frame", {
                    Name = toggleName,
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    LayoutOrder = getOrder(),
                    ZIndex = 5,
                    Parent = ElementContainer
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -40, 1, 0),
                    BackgroundTransparency = 1,
                    Text = toggleName,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                    Parent = ToggleFrame
                })
                
                local ToggleButton = Create("Frame", {
                    Name = "Button",
                    Size = UDim2.new(0, 32, 0, 16),
                    Position = UDim2.new(1, -32, 0.5, -8),
                    BackgroundColor3 = default and theme.Accent or theme.Secondary,
                    BorderSizePixel = 0,
                    ZIndex = 6,
                    Parent = ToggleFrame
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleButton })
                Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = ToggleButton })
                
                local ToggleCircle = Create("Frame", {
                    Name = "Circle",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                    BackgroundColor3 = theme.Text,
                    BorderSizePixel = 0,
                    ZIndex = 7,
                    Parent = ToggleButton
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleCircle })
                
                local ToggleClick = Create("TextButton", {
                    Name = "Click",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 8,
                    Parent = ToggleFrame
                })
                
                ToggleClick.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    Tween(ToggleButton, {BackgroundColor3 = Toggle.Value and theme.Accent or theme.Secondary}, 0.2)
                    Tween(ToggleCircle, {Position = Toggle.Value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}, 0.2)
                    callback(Toggle.Value)
                end)
                
                function Toggle:Set(value)
                    Toggle.Value = value
                    Tween(ToggleButton, {BackgroundColor3 = value and theme.Accent or theme.Secondary}, 0.2)
                    Tween(ToggleCircle, {Position = value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}, 0.2)
                    callback(value)
                end
                
                function Toggle:Get()
                    return Toggle.Value
                end
                
                if default then callback(default) end
                
                return Toggle
            end
            
            -- Slider
            function Section:CreateSlider(options)
                options = options or {}
                local sliderName = options.Name or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local suffix = options.Suffix or ""
                local callback = options.Callback or function() end
                
                local Slider = { Value = default }
                
                local SliderFrame = Create("Frame", {
                    Name = sliderName,
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1,
                    LayoutOrder = getOrder(),
                    ZIndex = 5,
                    Parent = ElementContainer
                })
                
                local SliderLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -50, 0, 18),
                    BackgroundTransparency = 1,
                    Text = sliderName,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                    Parent = SliderFrame
                })
                
                local SliderValue = Create("TextLabel", {
                    Name = "Value",
                    Size = UDim2.new(0, 50, 0, 18),
                    Position = UDim2.new(1, -50, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(default) .. suffix,
                    TextColor3 = theme.Accent,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 6,
                    Parent = SliderFrame
                })
                
                local SliderBar = Create("Frame", {
                    Name = "Bar",
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 26),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel = 0,
                    ZIndex = 6,
                    Parent = SliderFrame
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderBar })
                
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    ZIndex = 7,
                    Parent = SliderBar
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderFill })
                
                local SliderInput = Create("TextButton", {
                    Name = "Input",
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 8,
                    Parent = SliderFrame
                })
                
                local dragging = false
                
                local function updateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * pos)
                    Slider.Value = value
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderValue.Text = tostring(value) .. suffix
                    callback(value)
                end
                
                SliderInput.MouseButton1Down:Connect(function()
                    dragging = true
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                SliderInput.MouseButton1Click:Connect(function()
                    updateSlider({Position = Vector2.new(Mouse.X, Mouse.Y)})
                end)
                
                function Slider:Set(value)
                    value = math.clamp(value, min, max)
                    Slider.Value = value
                    local pos = (value - min) / (max - min)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderValue.Text = tostring(value) .. suffix
                    callback(value)
                end
                
                function Slider:Get()
                    return Slider.Value
                end
                
                return Slider
            end
            
            -- Button
            function Section:CreateButton(options)
                options = options or {}
                local buttonName = options.Name or "Button"
                local callback = options.Callback or function() end
                
                local Button = {}
                
                local ButtonFrame = Create("TextButton", {
                    Name = buttonName,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = theme.Accent,
                    Text = buttonName,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    LayoutOrder = getOrder(),
                    ZIndex = 6,
                    Parent = ElementContainer
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ButtonFrame })
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = theme.AccentDark}, 0.1)
                    task.wait(0.1)
                    Tween(ButtonFrame, {BackgroundColor3 = theme.Accent}, 0.1)
                    callback()
                end)
                
                return Button
            end
            
            -- Dropdown
            function Section:CreateDropdown(options)
                options = options or {}
                local dropdownName = options.Name or "Dropdown"
                local dropdownOptions = options.Options or {}
                local default = options.Default or (dropdownOptions[1] or "Select...")
                local callback = options.Callback or function() end
                
                local Dropdown = { Value = default, Open = false }
                
                local DropdownFrame = Create("Frame", {
                    Name = dropdownName,
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                    LayoutOrder = getOrder(),
                    ZIndex = 5,
                    ClipsDescendants = false,
                    Parent = ElementContainer
                })
                
                local DropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = dropdownName,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                    Parent = DropdownFrame
                })
                
                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = theme.Secondary,
                    Text = "",
                    BorderSizePixel = 0,
                    ZIndex = 6,
                    Parent = DropdownFrame
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = DropdownButton })
                Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = DropdownButton })
                
                local SelectedLabel = Create("TextLabel", {
                    Name = "Selected",
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = default,
                    TextColor3 = theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7,
                    Parent = DropdownButton
                })
                
                local Arrow = Create("TextLabel", {
                    Name = "Arrow",
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -22, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    ZIndex = 7,
                    Parent = DropdownButton
                })
                
                -- Options container (parented to ScreenGui)
                local OptionsContainer = Create("Frame", {
                    Name = "Options_" .. dropdownName,
                    Size = UDim2.new(0, 100, 0, 0),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 200,
                    Parent = ScreenGui
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = OptionsContainer })
                Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = OptionsContainer })
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2),
                    Parent = OptionsContainer
                })
                Create("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                    Parent = OptionsContainer
                })
                
                local function createOptions()
                    for _, child in pairs(OptionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    
                    for i, option in ipairs(dropdownOptions) do
                        local OptionButton = Create("TextButton", {
                            Name = option,
                            Size = UDim2.new(1, 0, 0, 22),
                            BackgroundColor3 = theme.Tertiary,
                            BackgroundTransparency = 1,
                            Text = option,
                            TextColor3 = option == Dropdown.Value and theme.Accent or theme.Text,
                            TextSize = 11,
                            Font = Enum.Font.Gotham,
                            LayoutOrder = i,
                            ZIndex = 201,
                            Parent = OptionsContainer
                        })
                        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = OptionButton })
                        
                        OptionButton.MouseEnter:Connect(function()
                            Tween(OptionButton, {BackgroundTransparency = 0}, 0.15)
                        end)
                        OptionButton.MouseLeave:Connect(function()
                            Tween(OptionButton, {BackgroundTransparency = 1}, 0.15)
                        end)
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            Dropdown.Value = option
                            SelectedLabel.Text = option
                            callback(option)
                            
                            for _, btn in pairs(OptionsContainer:GetChildren()) do
                                if btn:IsA("TextButton") then
                                    btn.TextColor3 = btn.Name == option and theme.Accent or theme.Text
                                end
                            end
                            
                            Dropdown.Open = false
                            OptionsContainer.Visible = false
                            Arrow.Text = "▼"
                        end)
                    end
                end
                
                createOptions()
                
                local function toggleDropdown()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        local btnPos = DropdownButton.AbsolutePosition
                        local btnSize = DropdownButton.AbsoluteSize
                        local optionHeight = #dropdownOptions * 24 + 10
                        
                        OptionsContainer.Position = UDim2.new(0, btnPos.X, 0, btnPos.Y + btnSize.Y + 4)
                        OptionsContainer.Size = UDim2.new(0, btnSize.X, 0, math.min(optionHeight, 200))
                        OptionsContainer.Visible = true
                        Arrow.Text = "▲"
                    else
                        OptionsContainer.Visible = false
                        Arrow.Text = "▼"
                    end
                end
                
                DropdownButton.MouseButton1Click:Connect(toggleDropdown)
                
                -- Close when clicking elsewhere
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and Dropdown.Open then
                        local mousePos = UserInputService:GetMouseLocation()
                        local optPos = OptionsContainer.AbsolutePosition
                        local optSize = OptionsContainer.AbsoluteSize
                        local btnPos = DropdownButton.AbsolutePosition
                        local btnSize = DropdownButton.AbsoluteSize
                        
                        local inOptions = mousePos.X >= optPos.X and mousePos.X <= optPos.X + optSize.X and
                                         mousePos.Y >= optPos.Y and mousePos.Y <= optPos.Y + optSize.Y
                        local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
                                        mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
                        
                        if not inOptions and not inButton then
                            Dropdown.Open = false
                            OptionsContainer.Visible = false
                            Arrow.Text = "▼"
                        end
                    end
                end)
                
                function Dropdown:Set(value)
                    if table.find(dropdownOptions, value) then
                        Dropdown.Value = value
                        SelectedLabel.Text = value
                        callback(value)
                    end
                end
                
                function Dropdown:Get()
                    return Dropdown.Value
                end
                
                function Dropdown:Refresh(newOptions)
                    dropdownOptions = newOptions
                    createOptions()
                end
                
                return Dropdown
            end
            
            -- MultiDropdown
            function Section:CreateMultiDropdown(options)
                options = options or {}
                local dropdownName = options.Name or "MultiDropdown"
                local dropdownOptions = options.Options or {}
                local default = options.Default or {}
                local callback = options.Callback or function() end
                
                local MultiDropdown = { Values = default, Open = false }
                
                local function getDisplayText()
                    if #MultiDropdown.Values == 0 then
                        return "None selected"
                    elseif #MultiDropdown.Values <= 2 then
                        return table.concat(MultiDropdown.Values, ", ")
                    else
                        return #MultiDropdown.Values .. " selected"
                    end
                end
                
                local DropdownFrame = Create("Frame", {
                    Name = dropdownName,
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                    LayoutOrder = getOrder(),
                    ZIndex = 5,
                    ClipsDescendants = false,
                    Parent = ElementContainer
                })
                
                local DropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = dropdownName,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                    Parent = DropdownFrame
                })
                
                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = theme.Secondary,
                    Text = "",
                    BorderSizePixel = 0,
                    ZIndex = 6,
                    Parent = DropdownFrame
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = DropdownButton })
                Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = DropdownButton })
                
                local SelectedLabel = Create("TextLabel", {
                    Name = "Selected",
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = getDisplayText(),
                    TextColor3 = theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7,
                    Parent = DropdownButton
                })
                
                local Arrow = Create("TextLabel", {
                    Name = "Arrow",
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -22, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    ZIndex = 7,
                    Parent = DropdownButton
                })
                
                local OptionsContainer = Create("Frame", {
                    Name = "MultiOptions_" .. dropdownName,
                    Size = UDim2.new(0, 100, 0, 0),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 200,
                    Parent = ScreenGui
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = OptionsContainer })
                Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = OptionsContainer })
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2),
                    Parent = OptionsContainer
                })
                Create("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                    Parent = OptionsContainer
                })
                
                local function createOptions()
                    for _, child in pairs(OptionsContainer:GetChildren()) do
                        if child:IsA("Frame") and child.Name ~= "UIListLayout" then child:Destroy() end
                    end
                    
                    for i, option in ipairs(dropdownOptions) do
                        local isSelected = table.find(MultiDropdown.Values, option) ~= nil
                        
                        local OptionFrame = Create("Frame", {
                            Name = option,
                            Size = UDim2.new(1, 0, 0, 22),
                            BackgroundColor3 = theme.Tertiary,
                            BackgroundTransparency = 1,
                            LayoutOrder = i,
                            ZIndex = 201,
                            Parent = OptionsContainer
                        })
                        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = OptionFrame })
                        
                        local Checkbox = Create("Frame", {
                            Name = "Checkbox",
                            Size = UDim2.new(0, 14, 0, 14),
                            Position = UDim2.new(0, 4, 0.5, -7),
                            BackgroundColor3 = isSelected and theme.Accent or theme.Secondary,
                            BorderSizePixel = 0,
                            ZIndex = 202,
                            Parent = OptionFrame
                        })
                        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Checkbox })
                        Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = Checkbox })
                        
                        local Checkmark = Create("TextLabel", {
                            Name = "Checkmark",
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = "✓",
                            TextColor3 = theme.Text,
                            TextTransparency = isSelected and 0 or 1,
                            TextSize = 10,
                            Font = Enum.Font.GothamBold,
                            ZIndex = 203,
                            Parent = Checkbox
                        })
                        
                        local OptionLabel = Create("TextLabel", {
                            Name = "Label",
                            Size = UDim2.new(1, -26, 1, 0),
                            Position = UDim2.new(0, 24, 0, 0),
                            BackgroundTransparency = 1,
                            Text = option,
                            TextColor3 = theme.Text,
                            TextSize = 11,
                            Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 202,
                            Parent = OptionFrame
                        })
                        
                        local OptionClick = Create("TextButton", {
                            Name = "Click",
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = "",
                            ZIndex = 204,
                            Parent = OptionFrame
                        })
                        
                        OptionClick.MouseEnter:Connect(function()
                            Tween(OptionFrame, {BackgroundTransparency = 0}, 0.15)
                        end)
                        OptionClick.MouseLeave:Connect(function()
                            Tween(OptionFrame, {BackgroundTransparency = 1}, 0.15)
                        end)
                        
                        OptionClick.MouseButton1Click:Connect(function()
                            local index = table.find(MultiDropdown.Values, option)
                            if index then
                                table.remove(MultiDropdown.Values, index)
                                Tween(Checkbox, {BackgroundColor3 = theme.Secondary}, 0.15)
                                Tween(Checkmark, {TextTransparency = 1}, 0.15)
                            else
                                table.insert(MultiDropdown.Values, option)
                                Tween(Checkbox, {BackgroundColor3 = theme.Accent}, 0.15)
                                Tween(Checkmark, {TextTransparency = 0}, 0.15)
                            end
                            SelectedLabel.Text = getDisplayText()
                            callback(MultiDropdown.Values)
                        end)
                    end
                end
                
                createOptions()
                
                local function toggleDropdown()
                    MultiDropdown.Open = not MultiDropdown.Open
                    
                    if MultiDropdown.Open then
                        local btnPos = DropdownButton.AbsolutePosition
                        local btnSize = DropdownButton.AbsoluteSize
                        local optionHeight = #dropdownOptions * 24 + 10
                        
                        OptionsContainer.Position = UDim2.new(0, btnPos.X, 0, btnPos.Y + btnSize.Y + 4)
                        OptionsContainer.Size = UDim2.new(0, btnSize.X, 0, math.min(optionHeight, 200))
                        OptionsContainer.Visible = true
                        Arrow.Text = "▲"
                    else
                        OptionsContainer.Visible = false
                        Arrow.Text = "▼"
                    end
                end
                
                DropdownButton.MouseButton1Click:Connect(toggleDropdown)
                
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and MultiDropdown.Open then
                        local mousePos = UserInputService:GetMouseLocation()
                        local optPos = OptionsContainer.AbsolutePosition
                        local optSize = OptionsContainer.AbsoluteSize
                        local btnPos = DropdownButton.AbsolutePosition
                        local btnSize = DropdownButton.AbsoluteSize
                        
                        local inOptions = mousePos.X >= optPos.X and mousePos.X <= optPos.X + optSize.X and
                                         mousePos.Y >= optPos.Y and mousePos.Y <= optPos.Y + optSize.Y
                        local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
                                        mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
                        
                        if not inOptions and not inButton then
                            MultiDropdown.Open = false
                            OptionsContainer.Visible = false
                            Arrow.Text = "▼"
                        end
                    end
                end)
                
                function MultiDropdown:Set(values)
                    MultiDropdown.Values = values
                    SelectedLabel.Text = getDisplayText()
                    createOptions()
                    callback(values)
                end
                
                function MultiDropdown:Get()
                    return MultiDropdown.Values
                end
                
                return MultiDropdown
            end
            
            -- Input
            function Section:CreateInput(options)
                options = options or {}
                local inputName = options.Name or "Input"
                local placeholder = options.Placeholder or "Enter text..."
                local default = options.Default or ""
                local callback = options.Callback or function() end
                
                local Input = { Value = default }
                
                local InputFrame = Create("Frame", {
                    Name = inputName,
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                    LayoutOrder = getOrder(),
                    ZIndex = 5,
                    Parent = ElementContainer
                })
                
                local InputLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = inputName,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                    Parent = InputFrame
                })
                
                local InputBox = Create("TextBox", {
                    Name = "Input",
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = theme.Secondary,
                    Text = default,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = theme.TextDark,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    BorderSizePixel = 0,
                    ZIndex = 6,
                    Parent = InputFrame
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = InputBox })
                Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = InputBox })
                Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = InputBox })
                
                InputBox.FocusLost:Connect(function()
                    Input.Value = InputBox.Text
                    callback(InputBox.Text)
                end)
                
                function Input:Set(value)
                    Input.Value = value
                    InputBox.Text = value
                    callback(value)
                end
                
                function Input:Get()
                    return Input.Value
                end
                
                return Input
            end
            
            -- Keybind
            function Section:CreateKeybind(options)
                options = options or {}
                local keybindName = options.Name or "Keybind"
                local default = options.Default or Enum.KeyCode.Unknown
                local callback = options.Callback or function() end
                
                local Keybind = { Value = default, Listening = false }
                
                local KeybindFrame = Create("Frame", {
                    Name = keybindName,
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    LayoutOrder = getOrder(),
                    ZIndex = 5,
                    Parent = ElementContainer
                })
                
                local KeybindLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -70, 1, 0),
                    BackgroundTransparency = 1,
                    Text = keybindName,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                    Parent = KeybindFrame
                })
                
                local KeybindButton = Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(0, 60, 0, 22),
                    Position = UDim2.new(1, -60, 0.5, -11),
                    BackgroundColor3 = theme.Secondary,
                    Text = default.Name or "None",
                    TextColor3 = theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.GothamMedium,
                    BorderSizePixel = 0,
                    ZIndex = 6,
                    Parent = KeybindFrame
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = KeybindButton })
                Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = KeybindButton })
                
                KeybindButton.MouseButton1Click:Connect(function()
                    Keybind.Listening = true
                    KeybindButton.Text = "..."
                    KeybindButton.TextColor3 = theme.Accent
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if Keybind.Listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Keybind.Value = input.KeyCode
                            KeybindButton.Text = input.KeyCode.Name
                            KeybindButton.TextColor3 = theme.TextDark
                            Keybind.Listening = false
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                               input.UserInputType == Enum.UserInputType.MouseButton2 then
                            KeybindButton.TextColor3 = theme.TextDark
                            Keybind.Listening = false
                        end
                    elseif input.KeyCode == Keybind.Value and not gameProcessed then
                        callback(Keybind.Value)
                    end
                end)
                
                function Keybind:Set(key)
                    Keybind.Value = key
                    KeybindButton.Text = key.Name
                end
                
                function Keybind:Get()
                    return Keybind.Value
                end
                
                return Keybind
            end
            
            -- ColorPicker
            function Section:CreateColorPicker(options)
                options = options or {}
                local pickerName = options.Name or "Color"
                local default = options.Default or Color3.fromRGB(255, 0, 0)
                local defaultAlpha = options.Alpha or 1
                local callback = options.Callback or function() end
                
                local h, s, v = RGBtoHSV(default)
                local ColorPicker = { Hue = h, Sat = s, Val = v, Alpha = defaultAlpha, Open = false }
                
                local function getColor()
                    return HSVtoRGB(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Val)
                end
                
                local PickerFrame = Create("Frame", {
                    Name = pickerName,
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    LayoutOrder = getOrder(),
                    ZIndex = 5,
                    Parent = ElementContainer
                })
                
                local PickerLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -36, 1, 0),
                    BackgroundTransparency = 1,
                    Text = pickerName,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                    Parent = PickerFrame
                })
                
                local ColorPreview = Create("TextButton", {
                    Name = "Preview",
                    Size = UDim2.new(0, 28, 0, 18),
                    Position = UDim2.new(1, -28, 0.5, -9),
                    BackgroundColor3 = default,
                    Text = "",
                    BorderSizePixel = 0,
                    ZIndex = 6,
                    Parent = PickerFrame
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ColorPreview })
                Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = ColorPreview })
                
                -- Picker Panel (parented to ScreenGui)
                local PickerPanel = Create("Frame", {
                    Name = "ColorPickerPanel_" .. pickerName,
                    Size = UDim2.new(0, 200, 0, 180),
                    BackgroundColor3 = theme.Primary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 300,
                    Parent = ScreenGui
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = PickerPanel })
                Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = PickerPanel })
                
                -- SV Picker
                local SVPicker = Create("Frame", {
                    Name = "SVPicker",
                    Size = UDim2.new(1, -16, 0, 100),
                    Position = UDim2.new(0, 8, 0, 8),
                    BackgroundColor3 = HSVtoRGB(ColorPicker.Hue, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 301,
                    Parent = PickerPanel
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = SVPicker })
                
                -- White gradient (left to right)
                local WhiteGradient = Create("Frame", {
                    Name = "White",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 302,
                    Parent = SVPicker
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = WhiteGradient })
                Create("UIGradient", {
                    Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }),
                    Parent = WhiteGradient
                })
                
                -- Black gradient (top to bottom)
                local BlackGradient = Create("Frame", {
                    Name = "Black",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 303,
                    Parent = SVPicker
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = BlackGradient })
                Create("UIGradient", {
                    Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
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
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(ColorPicker.Sat, -5, 1 - ColorPicker.Val, -5),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 305,
                    Parent = SVPicker
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SVCursor })
                Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = SVCursor })
                
                -- Hue Slider
                local HueSlider = Create("Frame", {
                    Name = "HueSlider",
                    Size = UDim2.new(1, -16, 0, 14),
                    Position = UDim2.new(0, 8, 0, 116),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 301,
                    Parent = PickerPanel
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = HueSlider })
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
                    Parent = HueSlider
                })
                
                local HueCursor = Create("Frame", {
                    Name = "Cursor",
                    Size = UDim2.new(0, 4, 1, 4),
                    Position = UDim2.new(ColorPicker.Hue / 360, -2, 0, -2),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 302,
                    Parent = HueSlider
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = HueCursor })
                Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = HueCursor })
                
                -- Alpha Slider
                local AlphaSlider = Create("Frame", {
                    Name = "AlphaSlider",
                    Size = UDim2.new(1, -16, 0, 14),
                    Position = UDim2.new(0, 8, 0, 136),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 301,
                    Parent = PickerPanel
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = AlphaSlider })
                
                local AlphaGradient = Create("UIGradient", {
                    Color = ColorSequence.new(Color3.new(0, 0, 0), getColor()),
                    Parent = AlphaSlider
                })
                
                local AlphaCursor = Create("Frame", {
                    Name = "Cursor",
                    Size = UDim2.new(0, 4, 1, 4),
                    Position = UDim2.new(ColorPicker.Alpha, -2, 0, -2),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 302,
                    Parent = AlphaSlider
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = AlphaCursor })
                Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = AlphaCursor })
                
                -- Hex Display
                local HexLabel = Create("TextLabel", {
                    Name = "Hex",
                    Size = UDim2.new(1, -16, 0, 18),
                    Position = UDim2.new(0, 8, 0, 156),
                    BackgroundTransparency = 1,
                    Text = ColorToHex(getColor()),
                    TextColor3 = theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.GothamMedium,
                    ZIndex = 302,
                    Parent = PickerPanel
                })
                
                local function updateColor()
                    local color = getColor()
                    ColorPreview.BackgroundColor3 = color
                    SVPicker.BackgroundColor3 = HSVtoRGB(ColorPicker.Hue, 1, 1)
                    AlphaGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), color)
                    HexLabel.Text = ColorToHex(color) .. " | " .. math.floor(ColorPicker.Alpha * 100) .. "%"
                    callback(color, ColorPicker.Alpha)
                end
                
                -- SV Picker Input
                local svDragging = false
                local SVInput = Create("TextButton", {
                    Name = "Input",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 306,
                    Parent = SVPicker
                })
                
                SVInput.MouseButton1Down:Connect(function()
                    svDragging = true
                end)
                
                -- Hue Slider Input
                local hueDragging = false
                local HueInput = Create("TextButton", {
                    Name = "Input",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 303,
                    Parent = HueSlider
                })
                
                HueInput.MouseButton1Down:Connect(function()
                    hueDragging = true
                end)
                
                -- Alpha Slider Input
                local alphaDragging = false
                local AlphaInput = Create("TextButton", {
                    Name = "Input",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 303,
                    Parent = AlphaSlider
                })
                
                AlphaInput.MouseButton1Down:Connect(function()
                    alphaDragging = true
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = false
                        hueDragging = false
                        alphaDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if svDragging then
                            local pos = SVPicker.AbsolutePosition
                            local size = SVPicker.AbsoluteSize
                            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                            
                            local saturation = math.clamp((mousePos.X - pos.X) / size.X, 0, 1)
                            local value = math.clamp(1 - (mousePos.Y - pos.Y) / size.Y, 0, 1)
                            
                            ColorPicker.Sat = saturation
                            ColorPicker.Val = value
                            SVCursor.Position = UDim2.new(saturation, -5, 1 - value, -5)
                            updateColor()
                        elseif hueDragging then
                            local pos = HueSlider.AbsolutePosition
                            local size = HueSlider.AbsoluteSize
                            local hue = math.clamp((Mouse.X - pos.X) / size.X, 0, 1) * 360
                            
                            ColorPicker.Hue = hue
                            HueCursor.Position = UDim2.new(hue / 360, -2, 0, -2)
                            updateColor()
                        elseif alphaDragging then
                            local pos = AlphaSlider.AbsolutePosition
                            local size = AlphaSlider.AbsoluteSize
                            local alpha = math.clamp((Mouse.X - pos.X) / size.X, 0, 1)
                            
                            ColorPicker.Alpha = alpha
                            AlphaCursor.Position = UDim2.new(alpha, -2, 0, -2)
                            updateColor()
                        end
                    end
                end)
                
                -- Toggle Picker
                ColorPreview.MouseButton1Click:Connect(function()
                    ColorPicker.Open = not ColorPicker.Open
                    
                    if ColorPicker.Open then
                        local previewPos = ColorPreview.AbsolutePosition
                        local previewSize = ColorPreview.AbsoluteSize
                        local screenSize = workspace.CurrentCamera.ViewportSize
                        
                        local panelX = previewPos.X + previewSize.X + 8
                        if panelX + 200 > screenSize.X then
                            panelX = previewPos.X - 208
                        end
                        
                        PickerPanel.Position = UDim2.new(0, panelX, 0, previewPos.Y - 60)
                        PickerPanel.Visible = true
                    else
                        PickerPanel.Visible = false
                    end
                end)
                
                -- Close picker when clicking outside
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and ColorPicker.Open then
                        local mousePos = UserInputService:GetMouseLocation()
                        local panelPos = PickerPanel.AbsolutePosition
                        local panelSize = PickerPanel.AbsoluteSize
                        local previewPos = ColorPreview.AbsolutePosition
                        local previewSize = ColorPreview.AbsoluteSize
                        
                        local inPanel = mousePos.X >= panelPos.X and mousePos.X <= panelPos.X + panelSize.X and
                                        mousePos.Y >= panelPos.Y and mousePos.Y <= panelPos.Y + panelSize.Y
                        local inPreview = mousePos.X >= previewPos.X and mousePos.X <= previewPos.X + previewSize.X and
                                         mousePos.Y >= previewPos.Y and mousePos.Y <= previewPos.Y + previewSize.Y
                        
                        if not inPanel and not inPreview and not svDragging and not hueDragging and not alphaDragging then
                            ColorPicker.Open = false
                            PickerPanel.Visible = false
                        end
                    end
                end)
                
                function ColorPicker:Set(color, alpha)
                    local hue, sat, val = RGBtoHSV(color)
                    ColorPicker.Hue = hue
                    ColorPicker.Sat = sat
                    ColorPicker.Val = val
                    ColorPicker.Alpha = alpha or ColorPicker.Alpha
                    
                    SVCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
                    HueCursor.Position = UDim2.new(hue / 360, -2, 0, -2)
                    AlphaCursor.Position = UDim2.new(ColorPicker.Alpha, -2, 0, -2)
                    updateColor()
                end
                
                function ColorPicker:Get()
                    return getColor(), ColorPicker.Alpha
                end
                
                return ColorPicker
            end
            
            -- Label
            function Section:CreateLabel(text)
                local LabelFrame = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = getOrder(),
                    ZIndex = 6,
                    Parent = ElementContainer
                })
                
                local Label = {}
                function Label:Set(newText)
                    LabelFrame.Text = newText
                end
                return Label
            end
            
            -- Separator
            function Section:CreateSeparator()
                Create("Frame", {
                    Name = "Separator",
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = theme.Border,
                    BorderSizePixel = 0,
                    LayoutOrder = getOrder(),
                    ZIndex = 6,
                    Parent = ElementContainer
                })
            end
            
            return Section
        end
        
        return Tab
    end
    
    return Window
end

-- Watermark
function FSLib:CreateWatermark(options)
    options = options or {}
    local title = options.Title or "FSLib"
    local themeName = options.Theme or "Default"
    local theme = Themes[themeName] or Themes.Default
    local showFPS = options.ShowFPS ~= false
    local showPing = options.ShowPing ~= false
    local showTime = options.ShowTime ~= false
    local showUser = options.ShowUser ~= false
    
    local Watermark = {}
    
    local ScreenGui = Create("ScreenGui", {
        Name = "FSLib_Watermark",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = game:GetService("CoreGui")
    })
    
    -- Fixed width calculation
    local baseWidth = 12 -- padding
    local separatorWidth = 16 -- " | " width
    local titleWidth = #title * 7 + 8
    local userWidth = showUser and (#Player.Name * 6 + 8) or 0
    local fpsWidth = showFPS and 50 or 0
    local pingWidth = showPing and 50 or 0
    local timeWidth = showTime and 60 or 0
    
    local separators = 0
    if showUser then separators = separators + 1 end
    if showFPS then separators = separators + 1 end
    if showPing then separators = separators + 1 end
    if showTime then separators = separators + 1 end
    
    local totalWidth = baseWidth + titleWidth + userWidth + fpsWidth + pingWidth + timeWidth + (separators * separatorWidth)
    
    local WatermarkFrame = Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, totalWidth, 0, 26),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = WatermarkFrame })
    Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = WatermarkFrame })
    
    -- Accent Line
    local AccentLine = Create("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, -12, 0, 2),
        Position = UDim2.new(0, 6, 0, 4),
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = WatermarkFrame
    })
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Accent),
            ColorSequenceKeypoint.new(0.5, theme.AccentDark),
            ColorSequenceKeypoint.new(1, theme.Accent)
        }),
        Parent = AccentLine
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 1), Parent = AccentLine })
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -12, 0, 16),
        Position = UDim2.new(0, 6, 0, 8),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = WatermarkFrame
    })
    
    -- Build text content
    local textContent = title
    if showUser then textContent = textContent .. " | " .. Player.Name end
    
    local StaticText = Create("TextLabel", {
        Name = "Static",
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = textContent,
        TextColor3 = theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = ContentContainer
    })
    
    local DynamicText = Create("TextLabel", {
        Name = "Dynamic",
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = theme.TextDark,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 3,
        Parent = ContentContainer
    })
    
    -- Draggable
    Draggable(WatermarkFrame)
    
    -- Update loop
    local lastFPS = 60
    local frameCount = 0
    local lastTime = tick()
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 0.5 then
            lastFPS = math.floor(frameCount / (now - lastTime))
            frameCount = 0
            lastTime = now
        end
        
        local dynamicParts = {}
        if showFPS then table.insert(dynamicParts, string.format("%03d fps", lastFPS)) end
        if showPing then 
            local ping = math.floor(Player:GetNetworkPing() * 1000)
            table.insert(dynamicParts, string.format("%03d ms", ping))
        end
        if showTime then table.insert(dynamicParts, os.date("%H:%M:%S")) end
        
        DynamicText.Text = table.concat(dynamicParts, " | ")
    end)
    
    function Watermark:SetTitle(newTitle)
        title = newTitle
        local content = newTitle
        if showUser then content = content .. " | " .. Player.Name end
        StaticText.Text = content
    end
    
    function Watermark:Hide()
        WatermarkFrame.Visible = false
    end
    
    function Watermark:Show()
        WatermarkFrame.Visible = true
    end
    
    function Watermark:Destroy()
        ScreenGui:Destroy()
    end
    
    return Watermark
end

return FSLib
