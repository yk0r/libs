--[[
    SkeetUI - Premium Roblox Script GUI Library
    Version: 2.2.0
    Style: Neverlose/Skeet/Gamesense
    
    Features:
    - Modern minimalist design
    - Fully functional HSV+Alpha ColorPicker
    - Multi-Select Dropdown
    - Customizable Status Bar
    - Keyboard toggle (no close/minimize buttons)
    - Watermark with proper separators
]]

local SkeetUI = {}
SkeetUI.__index = SkeetUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Themes
local Themes = {
    Dark = {
        Primary = Color3.fromRGB(134, 148, 255),
        Secondary = Color3.fromRGB(255, 134, 194),
        Background = Color3.fromRGB(16, 16, 20),
        Surface = Color3.fromRGB(22, 22, 28),
        SurfaceHover = Color3.fromRGB(28, 28, 36),
        SurfaceActive = Color3.fromRGB(35, 35, 45),
        Border = Color3.fromRGB(40, 40, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(140, 140, 160),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100)
    },
    Midnight = {
        Primary = Color3.fromRGB(99, 179, 255),
        Secondary = Color3.fromRGB(168, 131, 255),
        Background = Color3.fromRGB(12, 15, 22),
        Surface = Color3.fromRGB(18, 22, 32),
        SurfaceHover = Color3.fromRGB(24, 30, 44),
        SurfaceActive = Color3.fromRGB(32, 40, 56),
        Border = Color3.fromRGB(35, 45, 65),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(130, 150, 180),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100)
    },
    Blood = {
        Primary = Color3.fromRGB(255, 99, 99),
        Secondary = Color3.fromRGB(255, 150, 120),
        Background = Color3.fromRGB(18, 12, 12),
        Surface = Color3.fromRGB(26, 18, 18),
        SurfaceHover = Color3.fromRGB(36, 24, 24),
        SurfaceActive = Color3.fromRGB(48, 32, 32),
        Border = Color3.fromRGB(55, 35, 35),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 140, 140),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100)
    },
    Emerald = {
        Primary = Color3.fromRGB(98, 224, 158),
        Secondary = Color3.fromRGB(130, 200, 255),
        Background = Color3.fromRGB(12, 18, 14),
        Surface = Color3.fromRGB(18, 26, 20),
        SurfaceHover = Color3.fromRGB(24, 36, 28),
        SurfaceActive = Color3.fromRGB(32, 48, 38),
        Border = Color3.fromRGB(35, 55, 42),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(140, 180, 155),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100)
    }
}

-- Utility Functions
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function Tween(obj, props, duration, style, direction)
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

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
    return Color3.fromRGB(r * 255, g * 255, b * 255)
end

local function RGBtoHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max
    local d = max - min
    if max == 0 then s = 0 else s = d / max end
    if max == min then
        h = 0
    else
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    return h, s, v
end

local function RGBtoHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255), 
        math.floor(color.G * 255), 
        math.floor(color.B * 255))
end

-- ScreenGui
local function CreateScreenGui()
    local gui = Create("ScreenGui", {
        Name = "SkeetUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    pcall(function()
        gui.Parent = CoreGui
    end)
    if not gui.Parent then
        gui.Parent = Player:WaitForChild("PlayerGui")
    end
    
    return gui
end

local ScreenGui = CreateScreenGui()

-- Watermark Class
function SkeetUI:CreateWatermark(options)
    options = options or {}
    local theme = Themes[options.Theme or "Dark"]
    local title = options.Title or "skeet.cc"
    local showFPS = options.ShowFPS ~= false
    local showPing = options.ShowPing ~= false
    local showTime = options.ShowTime ~= false
    local showUser = options.ShowUser ~= false
    local position = options.Position or UDim2.new(0, 20, 0, 20)
    
    local Watermark = {}
    
    -- Main Container with rounded corners
    local Container = Create("Frame", {
        Name = "Watermark",
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = position,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 28),
        Parent = ScreenGui
    })
    
    -- Corner for main container
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Container
    })
    
    -- Border
    Create("UIStroke", {
        Color = theme.Border,
        Thickness = 1,
        Parent = Container
    })
    
    -- Gradient line container (clips to rounded corners)
    local GradientContainer = Create("Frame", {
        Name = "GradientContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true,
        Parent = Container
    })
    
    -- Top corner clip
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = GradientContainer
    })
    
    -- Gradient line
    local GradientLine = Create("Frame", {
        Name = "GradientLine",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = GradientContainer
    })
    
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Primary),
            ColorSequenceKeypoint.new(1, theme.Secondary)
        }),
        Parent = GradientLine
    })
    
    -- Content container
    local Content = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = Container
    })
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
        Parent = Content
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = Content
    })
    
    -- Title
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = theme.Primary,
        TextSize = 12,
        LayoutOrder = 1,
        Parent = Content
    })
    
    local function CreateSeparator(order)
        return Create("TextLabel", {
            Name = "Sep" .. order,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 1, 0),
            Font = Enum.Font.Gotham,
            Text = "|",
            TextColor3 = theme.Border,
            TextSize = 12,
            LayoutOrder = order,
            Parent = Content
        })
    end
    
    local function CreateInfoLabel(name, order)
        return Create("TextLabel", {
            Name = name,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.Gotham,
            Text = "",
            TextColor3 = theme.TextDim,
            TextSize = 11,
            LayoutOrder = order,
            Parent = Content
        })
    end
    
    local orderIndex = 2
    local UserLabel, FPSLabel, PingLabel, TimeLabel
    
    if showUser then
        CreateSeparator(orderIndex)
        orderIndex = orderIndex + 1
        UserLabel = CreateInfoLabel("User", orderIndex)
        UserLabel.Text = Player.Name
        orderIndex = orderIndex + 1
    end
    
    if showFPS then
        CreateSeparator(orderIndex)
        orderIndex = orderIndex + 1
        FPSLabel = CreateInfoLabel("FPS", orderIndex)
        orderIndex = orderIndex + 1
    end
    
    if showPing then
        CreateSeparator(orderIndex)
        orderIndex = orderIndex + 1
        PingLabel = CreateInfoLabel("Ping", orderIndex)
        orderIndex = orderIndex + 1
    end
    
    if showTime then
        CreateSeparator(orderIndex)
        orderIndex = orderIndex + 1
        TimeLabel = CreateInfoLabel("Time", orderIndex)
        orderIndex = orderIndex + 1
    end
    
    -- Update loop
    local lastFPSUpdate = 0
    local frameCount = 0
    local currentFPS = 60
    
    RunService.RenderStepped:Connect(function(dt)
        frameCount = frameCount + 1
        lastFPSUpdate = lastFPSUpdate + dt
        
        if lastFPSUpdate >= 0.5 then
            currentFPS = math.floor(frameCount / lastFPSUpdate)
            frameCount = 0
            lastFPSUpdate = 0
            
            if FPSLabel then
                FPSLabel.Text = currentFPS .. " fps"
            end
        end
        
        if PingLabel then
            local ping = math.floor(Player:GetNetworkPing() * 1000)
            PingLabel.Text = ping .. " ms"
        end
        
        if TimeLabel then
            TimeLabel.Text = os.date("%H:%M:%S")
        end
    end)
    
    function Watermark:SetTitle(newTitle)
        TitleLabel.Text = newTitle
    end
    
    function Watermark:Hide()
        Container.Visible = false
    end
    
    function Watermark:Show()
        Container.Visible = true
    end
    
    function Watermark:Destroy()
        Container:Destroy()
    end
    
    return Watermark
end

-- Window Class
function SkeetUI:CreateWindow(options)
    options = options or {}
    local theme = Themes[options.Theme or "Dark"]
    local title = options.Title or "Skeet"
    local size = options.Size or UDim2.new(0, 580, 0, 420)
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    local statusBarOptions = options.StatusBar or {}
    
    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Visible = true
    }
    
    -- Main Container
    local MainContainer = Create("Frame", {
        Name = "SkeetWindow",
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        Size = size,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = MainContainer
    })
    
    Create("UIStroke", {
        Color = theme.Border,
        Thickness = 1,
        Parent = MainContainer
    })
    
    -- Top Gradient Line (inside rounded container)
    local TopGradient = Create("Frame", {
        Name = "TopGradient",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 10,
        Parent = MainContainer
    })
    
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Primary),
            ColorSequenceKeypoint.new(1, theme.Secondary)
        }),
        Parent = TopGradient
    })
    
    -- Title Bar
    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 2),
        Parent = MainContainer
    })
    
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })
    
    -- Toggle key hint
    local KeyHint = Create("TextLabel", {
        Name = "KeyHint",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0, 0),
        Size = UDim2.new(0, 90, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "[" .. toggleKey.Name .. "]",
        TextColor3 = theme.TextDim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = TitleBar
    })
    
    -- Dragging
    local dragging, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainContainer.Position
        end
    end)
    
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
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
    
    -- Toggle key handler
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey then
            Window.Visible = not Window.Visible
            MainContainer.Visible = Window.Visible
        end
    end)
    
    -- Tab Container
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 38),
        Size = UDim2.new(0, 100, 1, -60),
        Parent = MainContainer
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = TabContainer
    })
    
    -- Position adjustment for tab container (inside main container)
    TabContainer.Position = UDim2.new(0, 8, 0, 42)
    TabContainer.Size = UDim2.new(0, 100, 1, -68)
    
    local TabList = Create("ScrollingFrame", {
        Name = "TabList",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        Parent = TabContainer
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabList
    })
    
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = TabList
    })
    
    -- Content Area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 116, 0, 42),
        Size = UDim2.new(1, -124, 1, -68),
        ClipsDescendants = true,
        Parent = MainContainer
    })
    
    -- Status Bar (bottom, with bottom rounded corners)
    local StatusBar = Create("Frame", {
        Name = "StatusBar",
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -22),
        Size = UDim2.new(1, 0, 0, 22),
        ZIndex = 5,
        Parent = MainContainer
    })
    
    -- Cover for top corners of status bar (make them square)
    local StatusBarTopCover = Create("Frame", {
        Name = "TopCover",
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 8),
        ZIndex = 4,
        Parent = StatusBar
    })
    
    -- Status bar content
    local StatusContent = Create("Frame", {
        Name = "StatusContent",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 6,
        Parent = StatusBar
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = StatusContent
    })
    
    -- Status indicator
    local StatusDot = Create("Frame", {
        Name = "StatusDot",
        BackgroundColor3 = theme.Success,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, -3),
        Size = UDim2.new(0, 6, 0, 6),
        ZIndex = 6,
        Parent = StatusContent
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = StatusDot
    })
    
    local StatusText = Create("TextLabel", {
        Name = "StatusText",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 60, 1, 0),
        Font = Enum.Font.Gotham,
        Text = statusBarOptions.Text or "ready",
        TextColor3 = theme.TextDim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = StatusContent
    })
    
    local BuildText = Create("TextLabel", {
        Name = "BuildText",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -50, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Font = Enum.Font.Gotham,
        Text = statusBarOptions.Build or "build: " .. os.date("%Y%m%d"),
        TextColor3 = theme.TextDim,
        TextSize = 10,
        ZIndex = 6,
        Parent = StatusContent
    })
    
    local VersionText = Create("TextLabel", {
        Name = "VersionText",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 60, 1, 0),
        Font = Enum.Font.Gotham,
        Text = statusBarOptions.Version or "v2.2.0",
        TextColor3 = theme.TextDim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 6,
        Parent = StatusContent
    })
    
    -- Set status bar visibility
    if statusBarOptions.Visible == false then
        StatusBar.Visible = false
        ContentArea.Size = UDim2.new(1, -124, 1, -50)
        TabContainer.Size = UDim2.new(0, 100, 1, -50)
    end
    
    -- Update status bar method
    function Window:SetStatusBar(opts)
        if opts.Text then StatusText.Text = opts.Text end
        if opts.Build then BuildText.Text = opts.Build end
        if opts.Version then VersionText.Text = opts.Version end
        if opts.Visible ~= nil then StatusBar.Visible = opts.Visible end
        if opts.Status then
            local colors = {
                ready = theme.Success,
                loading = theme.Warning,
                error = theme.Error,
                offline = theme.TextDim
            }
            StatusDot.BackgroundColor3 = colors[opts.Status] or theme.Success
        end
    end
    
    -- Notification system
    local NotificationContainer = Create("Frame", {
        Name = "Notifications",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 0, 20),
        Size = UDim2.new(0, 300, 1, -40),
        Parent = ScreenGui
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Parent = NotificationContainer
    })
    
    function Window:Notify(opts)
        local notifType = opts.Type or "Info"
        local typeColors = {
            Success = theme.Success,
            Warning = theme.Warning,
            Error = theme.Error,
            Info = theme.Primary
        }
        local accentColor = typeColors[notifType] or theme.Primary
        
        local Notif = Create("Frame", {
            Name = "Notification",
            BackgroundColor3 = theme.Background,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundTransparency = 1,
            Parent = NotificationContainer
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = Notif
        })
        
        Create("UIStroke", {
            Color = theme.Border,
            Thickness = 1,
            Transparency = 1,
            Parent = Notif
        })
        
        local NotifAccent = Create("Frame", {
            Name = "Accent",
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundTransparency = 1,
            Parent = Notif
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = NotifAccent
        })
        
        local NotifTitle = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 10),
            Size = UDim2.new(1, -24, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = opts.Title or "Notification",
            TextColor3 = theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1,
            Parent = Notif
        })
        
        local NotifMessage = Create("TextLabel", {
            Name = "Message",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 28),
            Size = UDim2.new(1, -24, 0, 24),
            Font = Enum.Font.Gotham,
            Text = opts.Message or "",
            TextColor3 = theme.TextDim,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextTransparency = 1,
            Parent = Notif
        })
        
        -- Animate in
        Tween(Notif, {BackgroundTransparency = 0}, 0.3)
        Tween(Notif:FindFirstChild("UIStroke"), {Transparency = 0}, 0.3)
        Tween(NotifAccent, {BackgroundTransparency = 0}, 0.3)
        Tween(NotifTitle, {TextTransparency = 0}, 0.3)
        Tween(NotifMessage, {TextTransparency = 0}, 0.3)
        
        -- Auto dismiss
        task.delay(opts.Duration or 4, function()
            Tween(Notif, {BackgroundTransparency = 1}, 0.3)
            Tween(Notif:FindFirstChild("UIStroke"), {Transparency = 1}, 0.3)
            Tween(NotifAccent, {BackgroundTransparency = 1}, 0.3)
            Tween(NotifTitle, {TextTransparency = 1}, 0.3)
            Tween(NotifMessage, {TextTransparency = 1}, 0.3)
            task.wait(0.3)
            Notif:Destroy()
        end)
    end
    
    -- Tab Class
    function Window:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local Tab = {
            Sections = {}
        }
        
        local tabIndex = #self.Tabs + 1
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = tabOptions.Name or "Tab",
            BackgroundColor3 = theme.SurfaceHover,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.Gotham,
            Text = tabOptions.Name or "Tab",
            TextColor3 = theme.TextDim,
            TextSize = 11,
            AutoButtonColor = false,
            LayoutOrder = tabIndex,
            Parent = TabList
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = TabButton
        })
        
        -- Left accent bar (hidden by default)
        local AccentBar = Create("Frame", {
            Name = "Accent",
            BackgroundColor3 = theme.Primary,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.15, 0),
            Size = UDim2.new(0, 0, 0.7, 0),
            Parent = TabButton
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 2),
            Parent = AccentBar
        })
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = "TabContent",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.Border,
            Visible = false,
            Parent = ContentArea
        })
        
        local ContentLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent
        })
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab selection
        local function SelectTab()
            -- Deselect all tabs
            for _, t in ipairs(self.Tabs) do
                Tween(t.Button, {BackgroundColor3 = theme.SurfaceHover})
                t.Button.TextColor3 = theme.TextDim
                Tween(t.AccentBar, {Size = UDim2.new(0, 0, 0.7, 0)})
                t.Content.Visible = false
            end
            
            -- Select this tab
            Tween(TabButton, {BackgroundColor3 = theme.SurfaceActive})
            TabButton.TextColor3 = theme.Text
            Tween(AccentBar, {Size = UDim2.new(0, 3, 0.7, 0)})
            TabContent.Visible = true
            self.ActiveTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        TabButton.MouseEnter:Connect(function()
            if self.ActiveTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = theme.SurfaceActive})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if self.ActiveTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = theme.SurfaceHover})
            end
        end)
        
        Tab.Button = TabButton
        Tab.AccentBar = AccentBar
        Tab.Content = TabContent
        
        -- Section Class
        function Tab:CreateSection(sectionOptions)
            sectionOptions = sectionOptions or {}
            local Section = {}
            
            local SectionFrame = Create("Frame", {
                Name = sectionOptions.Name or "Section",
                BackgroundColor3 = theme.Surface,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #self.Sections + 1,
                Parent = TabContent
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = SectionFrame
            })
            
            Create("UIStroke", {
                Color = theme.Border,
                Thickness = 1,
                Parent = SectionFrame
            })
            
            local SectionTitle = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -24, 0, 32),
                Font = Enum.Font.GothamBold,
                Text = sectionOptions.Name or "Section",
                TextColor3 = theme.Text,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionFrame
            })
            
            local SectionContent = Create("Frame", {
                Name = "Content",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 32),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionFrame
            })
            
            Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = SectionContent
            })
            
            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                Parent = SectionContent
            })
            
            -- Toggle
            function Section:CreateToggle(opts)
                opts = opts or {}
                local enabled = opts.Default or false
                
                local Toggle = {}
                
                local ToggleFrame = Create("Frame", {
                    Name = opts.Name or "Toggle",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    Parent = SectionContent
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = opts.Name or "Toggle",
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })
                
                local ToggleButton = Create("Frame", {
                    Name = "Switch",
                    BackgroundColor3 = enabled and theme.Primary or theme.SurfaceHover,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -40, 0.5, -9),
                    Size = UDim2.new(0, 40, 0, 18),
                    Parent = ToggleFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleButton
                })
                
                local ToggleKnob = Create("Frame", {
                    Name = "Knob",
                    BackgroundColor3 = theme.Text,
                    BorderSizePixel = 0,
                    Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14),
                    Parent = ToggleButton
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleKnob
                })
                
                local function UpdateToggle()
                    enabled = not enabled
                    Tween(ToggleButton, {BackgroundColor3 = enabled and theme.Primary or theme.SurfaceHover})
                    Tween(ToggleKnob, {Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                    if opts.Callback then
                        opts.Callback(enabled)
                    end
                end
                
                local ToggleClick = Create("TextButton", {
                    Name = "Click",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = ToggleFrame
                })
                
                ToggleClick.MouseButton1Click:Connect(UpdateToggle)
                
                function Toggle:Set(value)
                    if value ~= enabled then
                        UpdateToggle()
                    end
                end
                
                function Toggle:Get()
                    return enabled
                end
                
                return Toggle
            end
            
            -- Slider
            function Section:CreateSlider(opts)
                opts = opts or {}
                local min = opts.Min or 0
                local max = opts.Max or 100
                local value = opts.Default or min
                local suffix = opts.Suffix or ""
                
                local Slider = {}
                
                local SliderFrame = Create("Frame", {
                    Name = opts.Name or "Slider",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 42),
                    Parent = SectionContent
                })
                
                local SliderHeader = Create("Frame", {
                    Name = "Header",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Parent = SliderFrame
                })
                
                local SliderLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = opts.Name or "Slider",
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderHeader
                })
                
                local SliderValue = Create("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = tostring(value) .. suffix,
                    TextColor3 = theme.Primary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderHeader
                })
                
                local SliderTrack = Create("Frame", {
                    Name = "Track",
                    BackgroundColor3 = theme.SurfaceHover,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 26),
                    Size = UDim2.new(1, 0, 0, 6),
                    Parent = SliderFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderTrack
                })
                
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    Parent = SliderTrack
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderFill
                })
                
                Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, theme.Primary),
                        ColorSequenceKeypoint.new(1, theme.Secondary)
                    }),
                    Parent = SliderFill
                })
                
                local SliderKnob = Create("Frame", {
                    Name = "Knob",
                    BackgroundColor3 = theme.Text,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    ZIndex = 2,
                    Parent = SliderTrack
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderKnob
                })
                
                local draggingSlider = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max - min) * pos)
                    SliderValue.Text = tostring(value) .. suffix
                    Tween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                    Tween(SliderKnob, {Position = UDim2.new(pos, 0, 0.5, 0)}, 0.1)
                    if opts.Callback then
                        opts.Callback(value)
                    end
                end
                
                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                        UpdateSlider(input)
                    end
                end)
                
                SliderTrack.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                function Slider:Set(newValue)
                    value = math.clamp(newValue, min, max)
                    local pos = (value - min) / (max - min)
                    SliderValue.Text = tostring(value) .. suffix
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, 0, 0.5, 0)
                end
                
                function Slider:Get()
                    return value
                end
                
                return Slider
            end
            
            -- Button
            function Section:CreateButton(opts)
                opts = opts or {}
                
                local Button = {}
                
                local ButtonFrame = Create("TextButton", {
                    Name = opts.Name or "Button",
                    BackgroundColor3 = theme.SurfaceHover,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Enum.Font.GothamBold,
                    Text = opts.Name or "Button",
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    AutoButtonColor = false,
                    Parent = SectionContent
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ButtonFrame
                })
                
                Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, theme.Primary),
                        ColorSequenceKeypoint.new(1, theme.Secondary)
                    }),
                    Transparency = NumberSequence.new(0.8),
                    Parent = ButtonFrame
                })
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = theme.SurfaceActive})
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = theme.SurfaceHover})
                end)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    if opts.Callback then
                        opts.Callback()
                    end
                end)
                
                return Button
            end
            
            -- Dropdown (Single Select)
            function Section:CreateDropdown(opts)
                opts = opts or {}
                local options = opts.Options or {}
                local selected = opts.Default or (options[1] or "")
                local isOpen = false
                
                local Dropdown = {}
                
                local DropdownFrame = Create("Frame", {
                    Name = opts.Name or "Dropdown",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    ClipsDescendants = false,
                    ZIndex = 10,
                    Parent = SectionContent
                })
                
                local DropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = opts.Name or "Dropdown",
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                    Parent = DropdownFrame
                })
                
                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = theme.SurfaceHover,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.Gotham,
                    Text = "  " .. selected,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 10,
                    Parent = DropdownFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = DropdownButton
                })
                
                local DropdownArrow = Create("TextLabel", {
                    Name = "Arrow",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -24, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = "▼",
                    TextColor3 = theme.TextDim,
                    TextSize = 10,
                    ZIndex = 10,
                    Parent = DropdownButton
                })
                
                local OptionsContainer = Create("Frame", {
                    Name = "Options",
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 52),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 100,
                    Parent = DropdownFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = OptionsContainer
                })
                
                Create("UIStroke", {
                    Color = theme.Border,
                    Thickness = 1,
                    Parent = OptionsContainer
                })
                
                local OptionsList = Create("Frame", {
                    Name = "List",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ZIndex = 100,
                    Parent = OptionsContainer
                })
                
                Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = OptionsList
                })
                
                Create("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                    Parent = OptionsList
                })
                
                local function CreateOption(optionText, index)
                    local OptionButton = Create("TextButton", {
                        Name = "Option_" .. index,
                        BackgroundColor3 = theme.SurfaceHover,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 26),
                        Font = Enum.Font.Gotham,
                        Text = "  " .. optionText,
                        TextColor3 = selected == optionText and theme.Primary or theme.Text,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        LayoutOrder = index,
                        ZIndex = 101,
                        Parent = OptionsList
                    })
                    
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = OptionButton
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 0})
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 1})
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        selected = optionText
                        DropdownButton.Text = "  " .. selected
                        
                        -- Update option colors
                        for _, child in ipairs(OptionsList:GetChildren()) do
                            if child:IsA("TextButton") then
                                child.TextColor3 = child.Text == "  " .. selected and theme.Primary or theme.Text
                            end
                        end
                        
                        -- Close dropdown
                        isOpen = false
                        Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        task.wait(0.2)
                        OptionsContainer.Visible = false
                        DropdownArrow.Text = "▼"
                        
                        if opts.Callback then
                            opts.Callback(selected)
                        end
                    end)
                    
                    return OptionButton
                end
                
                -- Create initial options
                for i, opt in ipairs(options) do
                    CreateOption(opt, i)
                end
                
                local function ToggleDropdown()
                    isOpen = not isOpen
                    if isOpen then
                        local optionHeight = #options * 28 + 8
                        OptionsContainer.Visible = true
                        OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
                        Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, math.min(optionHeight, 150))}, 0.2)
                        DropdownArrow.Text = "▲"
                    else
                        Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        task.wait(0.2)
                        OptionsContainer.Visible = false
                        DropdownArrow.Text = "▼"
                    end
                end
                
                DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
                
                function Dropdown:Set(value)
                    if table.find(options, value) then
                        selected = value
                        DropdownButton.Text = "  " .. selected
                        for _, child in ipairs(OptionsList:GetChildren()) do
                            if child:IsA("TextButton") then
                                child.TextColor3 = child.Text == "  " .. selected and theme.Primary or theme.Text
                            end
                        end
                    end
                end
                
                function Dropdown:Get()
                    return selected
                end
                
                function Dropdown:Refresh(newOptions)
                    options = newOptions
                    for _, child in ipairs(OptionsList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    for i, opt in ipairs(options) do
                        CreateOption(opt, i)
                    end
                end
                
                return Dropdown
            end
            
            -- Multi Dropdown
            function Section:CreateMultiDropdown(opts)
                opts = opts or {}
                local options = opts.Options or {}
                local selectedItems = opts.Default or {}
                local isOpen = false
                
                local MultiDropdown = {}
                
                local function GetDisplayText()
                    if #selectedItems == 0 then
                        return "  None"
                    elseif #selectedItems <= 2 then
                        return "  " .. table.concat(selectedItems, ", ")
                    else
                        return "  " .. #selectedItems .. " selected"
                    end
                end
                
                local DropdownFrame = Create("Frame", {
                    Name = opts.Name or "MultiDropdown",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    ClipsDescendants = false,
                    ZIndex = 10,
                    Parent = SectionContent
                })
                
                local DropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = opts.Name or "Multi Dropdown",
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                    Parent = DropdownFrame
                })
                
                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = theme.SurfaceHover,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.Gotham,
                    Text = GetDisplayText(),
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 10,
                    Parent = DropdownFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = DropdownButton
                })
                
                local DropdownArrow = Create("TextLabel", {
                    Name = "Arrow",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -24, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = "▼",
                    TextColor3 = theme.TextDim,
                    TextSize = 10,
                    ZIndex = 10,
                    Parent = DropdownButton
                })
                
                local OptionsContainer = Create("Frame", {
                    Name = "Options",
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 52),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 100,
                    Parent = DropdownFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = OptionsContainer
                })
                
                Create("UIStroke", {
                    Color = theme.Border,
                    Thickness = 1,
                    Parent = OptionsContainer
                })
                
                local OptionsList = Create("Frame", {
                    Name = "List",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ZIndex = 100,
                    Parent = OptionsContainer
                })
                
                Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = OptionsList
                })
                
                Create("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                    Parent = OptionsList
                })
                
                local function CreateOption(optionText, index)
                    local isSelected = table.find(selectedItems, optionText) ~= nil
                    
                    local OptionButton = Create("TextButton", {
                        Name = "Option_" .. index,
                        BackgroundColor3 = theme.SurfaceHover,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 26),
                        Font = Enum.Font.Gotham,
                        Text = "",
                        AutoButtonColor = false,
                        LayoutOrder = index,
                        ZIndex = 101,
                        Parent = OptionsList
                    })
                    
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = OptionButton
                    })
                    
                    -- Checkbox
                    local Checkbox = Create("Frame", {
                        Name = "Checkbox",
                        BackgroundColor3 = isSelected and theme.Primary or theme.SurfaceActive,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 6, 0.5, -7),
                        Size = UDim2.new(0, 14, 0, 14),
                        ZIndex = 102,
                        Parent = OptionButton
                    })
                    
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 3),
                        Parent = Checkbox
                    })
                    
                    local CheckMark = Create("TextLabel", {
                        Name = "Check",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.GothamBold,
                        Text = isSelected and "✓" or "",
                        TextColor3 = theme.Text,
                        TextSize = 10,
                        ZIndex = 103,
                        Parent = Checkbox
                    })
                    
                    local OptionLabel = Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 26, 0, 0),
                        Size = UDim2.new(1, -30, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = optionText,
                        TextColor3 = isSelected and theme.Primary or theme.Text,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 102,
                        Parent = OptionButton
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 0})
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 1})
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        local idx = table.find(selectedItems, optionText)
                        if idx then
                            table.remove(selectedItems, idx)
                            isSelected = false
                        else
                            table.insert(selectedItems, optionText)
                            isSelected = true
                        end
                        
                        Tween(Checkbox, {BackgroundColor3 = isSelected and theme.Primary or theme.SurfaceActive})
                        CheckMark.Text = isSelected and "✓" or ""
                        OptionLabel.TextColor3 = isSelected and theme.Primary or theme.Text
                        DropdownButton.Text = GetDisplayText()
                        
                        if opts.Callback then
                            opts.Callback(selectedItems)
                        end
                    end)
                    
                    return OptionButton
                end
                
                -- Create initial options
                for i, opt in ipairs(options) do
                    CreateOption(opt, i)
                end
                
                local function ToggleDropdown()
                    isOpen = not isOpen
                    if isOpen then
                        local optionHeight = #options * 28 + 8
                        OptionsContainer.Visible = true
                        OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
                        Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, math.min(optionHeight, 150))}, 0.2)
                        DropdownArrow.Text = "▲"
                    else
                        Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        task.wait(0.2)
                        OptionsContainer.Visible = false
                        DropdownArrow.Text = "▼"
                    end
                end
                
                DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
                
                function MultiDropdown:Set(values)
                    selectedItems = values
                    DropdownButton.Text = GetDisplayText()
                    -- Update checkboxes
                    for _, child in ipairs(OptionsList:GetChildren()) do
                        if child:IsA("TextButton") then
                            local optText = child:FindFirstChild("Label").Text
                            local isSel = table.find(selectedItems, optText) ~= nil
                            child:FindFirstChild("Checkbox").BackgroundColor3 = isSel and theme.Primary or theme.SurfaceActive
                            child:FindFirstChild("Checkbox"):FindFirstChild("Check").Text = isSel and "✓" or ""
                            child:FindFirstChild("Label").TextColor3 = isSel and theme.Primary or theme.Text
                        end
                    end
                end
                
                function MultiDropdown:Get()
                    return selectedItems
                end
                
                return MultiDropdown
            end
            
            -- Input
            function Section:CreateInput(opts)
                opts = opts or {}
                
                local Input = {}
                
                local InputFrame = Create("Frame", {
                    Name = opts.Name or "Input",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    Parent = SectionContent
                })
                
                local InputLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = opts.Name or "Input",
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = InputFrame
                })
                
                local InputBox = Create("TextBox", {
                    Name = "Box",
                    BackgroundColor3 = theme.SurfaceHover,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = opts.Placeholder or "Enter text...",
                    PlaceholderColor3 = theme.TextDim,
                    Text = opts.Default or "",
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    ClearTextOnFocus = false,
                    Parent = InputFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = InputBox
                })
                
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    Parent = InputBox
                })
                
                InputBox.FocusLost:Connect(function(enterPressed)
                    if opts.Callback then
                        opts.Callback(InputBox.Text, enterPressed)
                    end
                end)
                
                function Input:Set(value)
                    InputBox.Text = value
                end
                
                function Input:Get()
                    return InputBox.Text
                end
                
                return Input
            end
            
            -- Keybind
            function Section:CreateKeybind(opts)
                opts = opts or {}
                local keybind = opts.Default or Enum.KeyCode.Unknown
                local listening = false
                
                local Keybind = {}
                
                local KeybindFrame = Create("Frame", {
                    Name = opts.Name or "Keybind",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    Parent = SectionContent
                })
                
                local KeybindLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = opts.Name or "Keybind",
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeybindFrame
                })
                
                local KeybindButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = theme.SurfaceHover,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -70, 0, 0),
                    Size = UDim2.new(0, 70, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = keybind == Enum.KeyCode.Unknown and "None" or keybind.Name,
                    TextColor3 = theme.TextDim,
                    TextSize = 10,
                    AutoButtonColor = false,
                    Parent = KeybindFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = KeybindButton
                })
                
                KeybindButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeybindButton.Text = "..."
                    KeybindButton.TextColor3 = theme.Primary
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        keybind = input.KeyCode
                        KeybindButton.Text = keybind.Name
                        KeybindButton.TextColor3 = theme.TextDim
                        if opts.Callback then
                            opts.Callback(keybind)
                        end
                    end
                end)
                
                -- Trigger keybind
                UserInputService.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    if not listening and input.KeyCode == keybind then
                        if opts.OnPress then
                            opts.OnPress()
                        end
                    end
                end)
                
                function Keybind:Set(key)
                    keybind = key
                    KeybindButton.Text = keybind.Name
                end
                
                function Keybind:Get()
                    return keybind
                end
                
                return Keybind
            end
            
            -- ColorPicker (Full HSV + Alpha)
            function Section:CreateColorPicker(opts)
                opts = opts or {}
                local color = opts.Default or Color3.fromRGB(255, 255, 255)
                local alpha = opts.Alpha or 1
                local h, s, v = RGBtoHSV(color)
                local isOpen = false
                
                local ColorPicker = {}
                
                local PickerFrame = Create("Frame", {
                    Name = opts.Name or "ColorPicker",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    ClipsDescendants = false,
                    ZIndex = 20,
                    Parent = SectionContent
                })
                
                local PickerLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = opts.Name or "Color",
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 20,
                    Parent = PickerFrame
                })
                
                -- Color preview button
                local ColorPreview = Create("TextButton", {
                    Name = "Preview",
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -70, 0, 2),
                    Size = UDim2.new(0, 70, 0, 24),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 20,
                    Parent = PickerFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ColorPreview
                })
                
                Create("UIStroke", {
                    Color = theme.Border,
                    Thickness = 1,
                    Parent = ColorPreview
                })
                
                -- Hex text
                local HexLabel = Create("TextLabel", {
                    Name = "Hex",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = RGBtoHex(color),
                    TextColor3 = Color3.new(1 - color.R, 1 - color.G, 1 - color.B),
                    TextSize = 10,
                    ZIndex = 21,
                    Parent = ColorPreview
                })
                
                -- Picker popup
                local PickerPopup = Create("Frame", {
                    Name = "Popup",
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 32),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 200,
                    Parent = PickerFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = PickerPopup
                })
                
                Create("UIStroke", {
                    Color = theme.Border,
                    Thickness = 1,
                    Parent = PickerPopup
                })
                
                local PopupContent = Create("Frame", {
                    Name = "Content",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 201,
                    Parent = PickerPopup
                })
                
                Create("UIPadding", {
                    PaddingTop = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    Parent = PopupContent
                })
                
                -- Saturation/Value box
                local SVBox = Create("ImageLabel", {
                    Name = "SVBox",
                    BackgroundColor3 = HSVtoRGB(h, 1, 1),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 120),
                    Image = "rbxassetid://4155801252",
                    ZIndex = 202,
                    Parent = PopupContent
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = SVBox
                })
                
                local SVCursor = Create("Frame", {
                    Name = "Cursor",
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(s, 0, 1 - v, 0),
                    Size = UDim2.new(0, 10, 0, 10),
                    ZIndex = 203,
                    Parent = SVBox
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SVCursor
                })
                
                Create("UIStroke", {
                    Color = Color3.new(0, 0, 0),
                    Thickness = 2,
                    Parent = SVCursor
                })
                
                -- Hue slider
                local HueSlider = Create("Frame", {
                    Name = "HueSlider",
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 130),
                    Size = UDim2.new(1, 0, 0, 16),
                    ZIndex = 202,
                    Parent = PopupContent
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = HueSlider
                })
                
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
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(h, 0, 0.5, 0),
                    Size = UDim2.new(0, 6, 0, 20),
                    ZIndex = 203,
                    Parent = HueSlider
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 2),
                    Parent = HueCursor
                })
                
                Create("UIStroke", {
                    Color = Color3.new(0, 0, 0),
                    Thickness = 1,
                    Parent = HueCursor
                })
                
                -- Alpha slider
                local AlphaSlider = Create("Frame", {
                    Name = "AlphaSlider",
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 152),
                    Size = UDim2.new(1, 0, 0, 16),
                    ZIndex = 202,
                    Parent = PopupContent
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = AlphaSlider
                })
                
                local AlphaGradient = Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, color)
                    }),
                    Parent = AlphaSlider
                })
                
                local AlphaCursor = Create("Frame", {
                    Name = "Cursor",
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(alpha, 0, 0.5, 0),
                    Size = UDim2.new(0, 6, 0, 20),
                    ZIndex = 203,
                    Parent = AlphaSlider
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 2),
                    Parent = AlphaCursor
                })
                
                Create("UIStroke", {
                    Color = Color3.new(0, 0, 0),
                    Thickness = 1,
                    Parent = AlphaCursor
                })
                
                -- Preset colors
                local PresetFrame = Create("Frame", {
                    Name = "Presets",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 176),
                    Size = UDim2.new(1, 0, 0, 24),
                    ZIndex = 202,
                    Parent = PopupContent
                })
                
                Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = PresetFrame
                })
                
                local presets = {
                    Color3.fromRGB(255, 255, 255),
                    Color3.fromRGB(255, 0, 0),
                    Color3.fromRGB(255, 128, 0),
                    Color3.fromRGB(255, 255, 0),
                    Color3.fromRGB(0, 255, 0),
                    Color3.fromRGB(0, 255, 255),
                    Color3.fromRGB(0, 128, 255),
                    Color3.fromRGB(0, 0, 255),
                    Color3.fromRGB(128, 0, 255),
                    Color3.fromRGB(255, 0, 255),
                    Color3.fromRGB(255, 0, 128),
                    Color3.fromRGB(128, 128, 128)
                }
                
                local function UpdateColor()
                    color = HSVtoRGB(h, s, v)
                    ColorPreview.BackgroundColor3 = color
                    HexLabel.Text = RGBtoHex(color)
                    HexLabel.TextColor3 = v > 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
                    SVBox.BackgroundColor3 = HSVtoRGB(h, 1, 1)
                    AlphaGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, color)
                    })
                    if opts.Callback then
                        opts.Callback(color, alpha)
                    end
                end
                
                for i, preset in ipairs(presets) do
                    local PresetButton = Create("TextButton", {
                        Name = "Preset" .. i,
                        BackgroundColor3 = preset,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 20, 0, 20),
                        Text = "",
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        ZIndex = 203,
                        Parent = PresetFrame
                    })
                    
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = PresetButton
                    })
                    
                    PresetButton.MouseButton1Click:Connect(function()
                        h, s, v = RGBtoHSV(preset)
                        SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                        HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                        UpdateColor()
                    end)
                end
                
                -- SV Box interaction
                local draggingSV = false
                
                SVBox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV = true
                        local pos = input.Position
                        s = math.clamp((pos.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                        v = math.clamp(1 - (pos.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                        SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                        UpdateColor()
                    end
                end)
                
                SVBox.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV = false
                    end
                end)
                
                -- Hue slider interaction
                local draggingHue = false
                
                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = true
                        local pos = input.Position
                        h = math.clamp((pos.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                        HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                        UpdateColor()
                    end
                end)
                
                HueSlider.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = false
                    end
                end)
                
                -- Alpha slider interaction
                local draggingAlpha = false
                
                AlphaSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingAlpha = true
                        local pos = input.Position
                        alpha = math.clamp((pos.X - AlphaSlider.AbsolutePosition.X) / AlphaSlider.AbsoluteSize.X, 0, 1)
                        AlphaCursor.Position = UDim2.new(alpha, 0, 0.5, 0)
                        UpdateColor()
                    end
                end)
                
                AlphaSlider.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingAlpha = false
                    end
                end)
                
                -- Global mouse move
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if draggingSV then
                            s = math.clamp((input.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                            v = math.clamp(1 - (input.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                            SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                            UpdateColor()
                        elseif draggingHue then
                            h = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                            HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                            UpdateColor()
                        elseif draggingAlpha then
                            alpha = math.clamp((input.Position.X - AlphaSlider.AbsolutePosition.X) / AlphaSlider.AbsoluteSize.X, 0, 1)
                            AlphaCursor.Position = UDim2.new(alpha, 0, 0.5, 0)
                            UpdateColor()
                        end
                    end
                end)
                
                -- Toggle popup
                ColorPreview.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        PickerPopup.Visible = true
                        Tween(PickerPopup, {Size = UDim2.new(1, 0, 0, 210)}, 0.2)
                    else
                        Tween(PickerPopup, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        task.wait(0.2)
                        PickerPopup.Visible = false
                    end
                end)
                
                function ColorPicker:Set(newColor, newAlpha)
                    color = newColor
                    alpha = newAlpha or alpha
                    h, s, v = RGBtoHSV(color)
                    ColorPreview.BackgroundColor3 = color
                    HexLabel.Text = RGBtoHex(color)
                    SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                    HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                    AlphaCursor.Position = UDim2.new(alpha, 0, 0.5, 0)
                    SVBox.BackgroundColor3 = HSVtoRGB(h, 1, 1)
                end
                
                function ColorPicker:Get()
                    return color, alpha
                end
                
                return ColorPicker
            end
            
            -- Label
            function Section:CreateLabel(text)
                local Label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = theme.TextDim,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SectionContent
                })
                
                return {
                    Set = function(self, newText)
                        Label.Text = newText
                    end
                }
            end
            
            -- Separator
            function Section:CreateSeparator()
                local Separator = Create("Frame", {
                    Name = "Separator",
                    BackgroundColor3 = theme.Border,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1),
                    Parent = SectionContent
                })
                
                return Separator
            end
            
            table.insert(self.Sections, Section)
            return Section
        end
        
        table.insert(self.Tabs, Tab)
        
        -- Auto select first tab
        if #self.Tabs == 1 then
            SelectTab()
        end
        
        return Tab
    end
    
    function Window:Hide()
        MainContainer.Visible = false
        self.Visible = false
    end
    
    function Window:Show()
        MainContainer.Visible = true
        self.Visible = true
    end
    
    function Window:Toggle()
        self.Visible = not self.Visible
        MainContainer.Visible = self.Visible
    end
    
    function Window:Destroy()
        MainContainer:Destroy()
    end
    
    return Window
end

return SkeetUI
