--[[
    ███████╗███████╗██╗     ██╗██████╗ 
    ██╔════╝██╔════╝██║     ██║██╔══██╗
    █████╗  ███████╗██║     ██║██████╔╝
    ██╔══╝  ╚════██║██║     ██║██╔══██╗
    ██║     ███████║███████╗██║██████╔╝
    ╚═╝     ╚══════╝╚══════╝╚═╝╚═════╝ 
    
    FSLib - Premium Roblox Script GUI Library
    Build 1.0.0
    
    A professional, feature-complete GUI library for Roblox script hubs.
    Inspired by classic cheat UI aesthetics with modern functionality.
]]

local FSLib = {}
FSLib.__index = FSLib
FSLib.Version = "1.0.0"
FSLib.Build = "1.0.0"

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Theme System
local Themes = {
    Default = {
        Primary = Color3.fromRGB(15, 15, 20),
        Secondary = Color3.fromRGB(20, 20, 28),
        Tertiary = Color3.fromRGB(28, 28, 38),
        Hover = Color3.fromRGB(35, 35, 48),
        Accent = Color3.fromRGB(130, 80, 245),
        AccentDark = Color3.fromRGB(100, 60, 200),
        Text = Color3.fromRGB(240, 240, 245),
        TextDark = Color3.fromRGB(140, 140, 160),
        Border = Color3.fromRGB(45, 45, 60),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(245, 180, 60),
        Error = Color3.fromRGB(240, 80, 80),
        Offline = Color3.fromRGB(100, 100, 110)
    },
    Blood = {
        Primary = Color3.fromRGB(15, 12, 12),
        Secondary = Color3.fromRGB(22, 18, 18),
        Tertiary = Color3.fromRGB(32, 25, 25),
        Hover = Color3.fromRGB(45, 35, 35),
        Accent = Color3.fromRGB(200, 50, 60),
        AccentDark = Color3.fromRGB(160, 40, 50),
        Text = Color3.fromRGB(240, 235, 235),
        TextDark = Color3.fromRGB(160, 140, 140),
        Border = Color3.fromRGB(55, 40, 40),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(245, 180, 60),
        Error = Color3.fromRGB(240, 80, 80),
        Offline = Color3.fromRGB(100, 100, 110)
    },
    Ocean = {
        Primary = Color3.fromRGB(10, 15, 20),
        Secondary = Color3.fromRGB(15, 22, 30),
        Tertiary = Color3.fromRGB(20, 32, 45),
        Hover = Color3.fromRGB(30, 45, 60),
        Accent = Color3.fromRGB(40, 160, 220),
        AccentDark = Color3.fromRGB(30, 130, 180),
        Text = Color3.fromRGB(235, 245, 250),
        TextDark = Color3.fromRGB(130, 160, 180),
        Border = Color3.fromRGB(35, 55, 75),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(245, 180, 60),
        Error = Color3.fromRGB(240, 80, 80),
        Offline = Color3.fromRGB(100, 100, 110)
    },
    Mint = {
        Primary = Color3.fromRGB(12, 18, 15),
        Secondary = Color3.fromRGB(18, 26, 22),
        Tertiary = Color3.fromRGB(25, 38, 32),
        Hover = Color3.fromRGB(35, 52, 45),
        Accent = Color3.fromRGB(60, 210, 150),
        AccentDark = Color3.fromRGB(45, 170, 120),
        Text = Color3.fromRGB(235, 250, 245),
        TextDark = Color3.fromRGB(130, 170, 155),
        Border = Color3.fromRGB(40, 60, 52),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(245, 180, 60),
        Error = Color3.fromRGB(240, 80, 80),
        Offline = Color3.fromRGB(100, 100, 110)
    }
}

local CurrentTheme = Themes.Default

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

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or CurrentTheme.Border,
        Thickness = thickness or 1,
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

-- HSV to RGB conversion (correct implementation)
local function HSVtoRGB(h, s, v)
    h = h % 1
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

-- RGB to HSV conversion
local function RGBtoHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max
    
    local d = max - min
    if max == 0 then
        s = 0
    else
        s = d / max
    end
    
    if max == min then
        h = 0
    else
        if max == r then
            h = (g - b) / d
            if g < b then h = h + 6 end
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    
    return h, s, v
end

local function Color3ToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255), 
        math.floor(color.G * 255), 
        math.floor(color.B * 255))
end

-- ScreenGui Setup
local ScreenGui = Create("ScreenGui", {
    Name = "FSLib",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- Try to parent to CoreGui, fallback to PlayerGui
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Set Theme
function FSLib:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
    end
end

-- ═══════════════════════════════════════════════════════════════
-- WATERMARK (Draggable)
-- ═══════════════════════════════════════════════════════════════
function FSLib:CreateWatermark(options)
    options = options or {}
    local title = options.Title or "FSLib"
    local showFPS = options.ShowFPS ~= false
    local showPing = options.ShowPing ~= false
    local showTime = options.ShowTime ~= false
    local showUser = options.ShowUser ~= false
    local position = options.Position or UDim2.new(0, 15, 0, 15)
    
    if options.Theme and Themes[options.Theme] then
        CurrentTheme = Themes[options.Theme]
    end
    
    -- Calculate initial width
    local estimatedWidth = 12 -- padding
    if title then estimatedWidth = estimatedWidth + #title * 7 + 15 end
    if showUser then estimatedWidth = estimatedWidth + #LocalPlayer.Name * 6 + 20 end
    if showFPS then estimatedWidth = estimatedWidth + 55 end
    if showPing then estimatedWidth = estimatedWidth + 55 end
    if showTime then estimatedWidth = estimatedWidth + 65 end
    
    local Container = Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, estimatedWidth, 0, 28),
        Position = position,
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Parent = ScreenGui,
        ClipsDescendants = true
    })
    AddCorner(Container, 4)
    AddStroke(Container, CurrentTheme.Border, 1)
    
    -- Accent Line (inside container)
    local AccentLine = Create("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, -10, 0, 2),
        Position = UDim2.new(0, 5, 0, 4),
        BackgroundColor3 = CurrentTheme.Accent,
        BorderSizePixel = 0,
        Parent = Container
    })
    AddCorner(AccentLine, 1)
    
    -- Content Layout
    local ContentFrame = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -12, 0, 16),
        Position = UDim2.new(0, 6, 0, 9),
        BackgroundTransparency = 1,
        Parent = Container
    })
    
    local Layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
        Parent = ContentFrame
    })
    
    local function CreateText(text, order, isAccent)
        return Create("TextLabel", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = isAccent and CurrentTheme.Accent or CurrentTheme.Text,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            LayoutOrder = order,
            Parent = ContentFrame
        })
    end
    
    local function CreateSeparator(order)
        return Create("TextLabel", {
            Size = UDim2.new(0, 16, 1, 0),
            BackgroundTransparency = 1,
            Text = "|",
            TextColor3 = CurrentTheme.Border,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Center,
            LayoutOrder = order,
            Parent = ContentFrame
        })
    end
    
    local order = 0
    local TitleLabel = CreateText(title, order, true)
    order = order + 1
    
    local UserLabel, FPSLabel, PingLabel, TimeLabel
    
    if showUser then
        CreateSeparator(order)
        order = order + 1
        UserLabel = CreateText(LocalPlayer.Name, order, false)
        order = order + 1
    end
    
    if showFPS then
        CreateSeparator(order)
        order = order + 1
        FPSLabel = CreateText("0 fps", order, false)
        order = order + 1
    end
    
    if showPing then
        CreateSeparator(order)
        order = order + 1
        PingLabel = CreateText("0 ms", order, false)
        order = order + 1
    end
    
    if showTime then
        CreateSeparator(order)
        order = order + 1
        TimeLabel = CreateText("00:00:00", order, false)
    end
    
    -- Dragging functionality
    local dragging = false
    local dragStart, startPos
    
    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Container.Position
        end
    end)
    
    Container.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Container.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Update loop
    local lastFPSUpdate = 0
    local frameCount = 0
    
    RunService.RenderStepped:Connect(function(deltaTime)
        frameCount = frameCount + 1
        lastFPSUpdate = lastFPSUpdate + deltaTime
        
        if lastFPSUpdate >= 0.5 then
            if FPSLabel then
                FPSLabel.Text = math.floor(frameCount / lastFPSUpdate) .. " fps"
            end
            frameCount = 0
            lastFPSUpdate = 0
        end
        
        if PingLabel then
            local ping = LocalPlayer:GetNetworkPing() * 1000
            PingLabel.Text = math.floor(ping) .. " ms"
        end
        
        if TimeLabel then
            TimeLabel.Text = os.date("%H:%M:%S")
        end
    end)
    
    -- Adjust width after render
    task.defer(function()
        task.wait()
        local totalWidth = Layout.AbsoluteContentSize.X + 16
        Container.Size = UDim2.new(0, totalWidth, 0, 28)
    end)
    
    local WatermarkAPI = {}
    
    function WatermarkAPI:SetTitle(newTitle)
        TitleLabel.Text = newTitle
        task.defer(function()
            task.wait()
            local totalWidth = Layout.AbsoluteContentSize.X + 16
            Container.Size = UDim2.new(0, totalWidth, 0, 28)
        end)
    end
    
    function WatermarkAPI:Show()
        Container.Visible = true
    end
    
    function WatermarkAPI:Hide()
        Container.Visible = false
    end
    
    function WatermarkAPI:Destroy()
        Container:Destroy()
    end
    
    return WatermarkAPI
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN WINDOW
-- ═══════════════════════════════════════════════════════════════
function FSLib:CreateWindow(options)
    options = options or {}
    local title = options.Title or "FSLib"
    local subtitle = options.Subtitle or "Build " .. FSLib.Build
    local size = options.Size or UDim2.new(0, 580, 0, 420)
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    local statusBar = options.StatusBar or {
        Text = "ready",
        Status = "ready",
        Build = "build " .. FSLib.Build,
        Version = "v" .. FSLib.Version
    }
    
    if options.Theme and Themes[options.Theme] then
        CurrentTheme = Themes[options.Theme]
    end
    
    -- Main Container
    local MainContainer = Create("Frame", {
        Name = "FSLib_Window",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    AddCorner(MainContainer, 8)
    AddStroke(MainContainer, CurrentTheme.Border, 1)
    
    -- Accent Line (inside, at top)
    local AccentLine = Create("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, -16, 0, 2),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundColor3 = CurrentTheme.Accent,
        BorderSizePixel = 0,
        Parent = MainContainer
    })
    AddCorner(AccentLine, 1)
    
    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Parent = MainContainer
    })
    
    -- Title Container
    local TitleContainer = Create("Frame", {
        Name = "TitleContainer",
        Size = UDim2.new(0, 0, 0, 20),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.X,
        Parent = Header
    })
    
    local TitleLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = TitleContainer
    })
    
    local TitleLabel = Create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        LayoutOrder = 1,
        Parent = TitleContainer
    })
    
    local SubtitleLabel = Create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = subtitle,
        TextColor3 = CurrentTheme.TextDark,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        LayoutOrder = 2,
        Parent = TitleContainer
    })
    
    -- Toggle Key Display
    local KeyDisplay = Create("TextLabel", {
        Size = UDim2.new(0, 0, 0, 20),
        Position = UDim2.new(1, -12, 0, 12),
        AnchorPoint = Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "[" .. toggleKey.Name .. "]",
        TextColor3 = CurrentTheme.TextDark,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        Parent = Header
    })
    
    -- Dragging
    local dragging = false
    local dragStart, startPos
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainContainer.Position
        end
    end)
    
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainContainer.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Toggle Key
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            MainContainer.Visible = not MainContainer.Visible
        end
    end)
    
    -- Tab Bar
    local TabBar = Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(0, 95, 1, -60),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Parent = MainContainer
    })
    
    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = TabBar
    })
    
    local TabLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabContainer
    })
    
    -- Content Area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -100, 1, -60),
        Position = UDim2.new(0, 97, 0, 36),
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = MainContainer
    })
    AddCorner(ContentArea, 4)
    
    -- Status Bar
    local StatusBar = Create("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 1, -24),
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Parent = MainContainer
    })
    
    -- Status indicator
    local StatusDot = Create("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 10, 0.5, -3),
        BackgroundColor3 = CurrentTheme.Success,
        BorderSizePixel = 0,
        Parent = StatusBar
    })
    AddCorner(StatusDot, 3)
    
    local StatusTextLabel = Create("TextLabel", {
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(0, 22, 0, 0),
        BackgroundTransparency = 1,
        Text = statusBar.Text or "ready",
        TextColor3 = CurrentTheme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = StatusBar
    })
    
    local BuildLabel = Create("TextLabel", {
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0.5, -60, 0, 0),
        BackgroundTransparency = 1,
        Text = statusBar.Build or "build " .. FSLib.Build,
        TextColor3 = CurrentTheme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = StatusBar
    })
    
    local VersionLabel = Create("TextLabel", {
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(1, -70, 0, 0),
        BackgroundTransparency = 1,
        Text = statusBar.Version or "v" .. FSLib.Version,
        TextColor3 = CurrentTheme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = StatusBar
    })
    
    -- Tab System
    local Tabs = {}
    local CurrentTab = nil
    
    local WindowAPI = {}
    
    function WindowAPI:SetStatusBar(opts)
        if opts.Text then StatusTextLabel.Text = opts.Text end
        if opts.Build then BuildLabel.Text = opts.Build end
        if opts.Version then VersionLabel.Text = opts.Version end
        if opts.Status then
            local colors = {
                ready = CurrentTheme.Success,
                loading = CurrentTheme.Warning,
                error = CurrentTheme.Error,
                offline = CurrentTheme.Offline
            }
            StatusDot.BackgroundColor3 = colors[opts.Status] or CurrentTheme.Success
        end
        if opts.Visible ~= nil then
            StatusBar.Visible = opts.Visible
        end
    end
    
    function WindowAPI:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon or ""
        
        local TabButton = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = CurrentTheme.Tertiary,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = #Tabs + 1,
            Parent = TabContainer
        })
        AddCorner(TabButton, 4)
        
        -- Left accent indicator
        local TabIndicator = Create("Frame", {
            Size = UDim2.new(0, 3, 0, 18),
            Position = UDim2.new(0, 0, 0.5, -9),
            BackgroundColor3 = CurrentTheme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = TabButton
        })
        AddCorner(TabIndicator, 1)
        
        local TabLabel = Create("TextLabel", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = CurrentTheme.TextDark,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = tabName .. "_Content",
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = CurrentTheme.Accent,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentArea
        })
        
        -- Two columns layout
        local LeftColumn = Create("Frame", {
            Name = "LeftColumn",
            Size = UDim2.new(0.5, -4, 0, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = TabContent
        })
        
        local LeftLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = LeftColumn
        })
        
        local RightColumn = Create("Frame", {
            Name = "RightColumn",
            Size = UDim2.new(0.5, -4, 0, 0),
            Position = UDim2.new(0.5, 2, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = TabContent
        })
        
        local RightLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = RightColumn
        })
        
        local TabData = {
            Button = TabButton,
            Content = TabContent,
            Indicator = TabIndicator,
            Label = TabLabel,
            LeftColumn = LeftColumn,
            RightColumn = RightColumn
        }
        table.insert(Tabs, TabData)
        
        local function SelectTab()
            for _, tab in ipairs(Tabs) do
                tab.Content.Visible = false
                tab.Indicator.BackgroundTransparency = 1
                tab.Label.TextColor3 = CurrentTheme.TextDark
                tab.Button.BackgroundTransparency = 1
            end
            TabContent.Visible = true
            TabIndicator.BackgroundTransparency = 0
            TabLabel.TextColor3 = CurrentTheme.Text
            TabButton.BackgroundTransparency = 0.8
            CurrentTab = TabData
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        TabButton.MouseEnter:Connect(function()
            if CurrentTab ~= TabData then
                Tween(TabButton, {BackgroundTransparency = 0.9}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if CurrentTab ~= TabData then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.15)
            end
        end)
        
        if #Tabs == 1 then
            SelectTab()
        end
        
        -- Tab API
        local TabAPI = {}
        
        function TabAPI:CreateSection(sectionOptions)
            sectionOptions = sectionOptions or {}
            local sectionName = sectionOptions.Name or "Section"
            local side = sectionOptions.Side or "Left"
            
            local ParentColumn = side == "Left" and LeftColumn or RightColumn
            
            local Section = Create("Frame", {
                Name = sectionName,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = CurrentTheme.Tertiary,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = ParentColumn
            })
            AddCorner(Section, 6)
            AddStroke(Section, CurrentTheme.Border, 1)
            
            local SectionHeader = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                Parent = Section
            })
            
            local SectionTitle = Create("TextLabel", {
                Size = UDim2.new(1, -12, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = CurrentTheme.Text,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            local SectionContent = Create("Frame", {
                Name = "Content",
                Size = UDim2.new(1, -12, 0, 0),
                Position = UDim2.new(0, 6, 0, 26),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Section
            })
            
            local ContentLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = SectionContent
            })
            
            local BottomPadding = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 6),
                BackgroundTransparency = 1,
                LayoutOrder = 9999,
                Parent = SectionContent
            })
            
            -- Section API
            local SectionAPI = {}
            local elementOrder = 0
            
            -- ═══════════════════════════════════════════════════════════════
            -- TOGGLE
            -- ═══════════════════════════════════════════════════════════════
            function SectionAPI:CreateToggle(opts)
                opts = opts or {}
                elementOrder = elementOrder + 1
                local enabled = opts.Default or false
                
                local Container = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                
                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Name or "Toggle",
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })
                
                local ToggleBtn = Create("Frame", {
                    Size = UDim2.new(0, 32, 0, 16),
                    Position = UDim2.new(1, -32, 0.5, -8),
                    BackgroundColor3 = enabled and CurrentTheme.Accent or CurrentTheme.Primary,
                    BorderSizePixel = 0,
                    Parent = Container
                })
                AddCorner(ToggleBtn, 8)
                AddStroke(ToggleBtn, CurrentTheme.Border, 1)
                
                local ToggleCircle = Create("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = enabled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                    BackgroundColor3 = CurrentTheme.Text,
                    BorderSizePixel = 0,
                    Parent = ToggleBtn
                })
                AddCorner(ToggleCircle, 6)
                
                local ToggleButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = Container
                })
                
                local function UpdateVisual()
                    Tween(ToggleBtn, {BackgroundColor3 = enabled and CurrentTheme.Accent or CurrentTheme.Primary}, 0.2)
                    Tween(ToggleCircle, {Position = enabled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}, 0.2)
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    enabled = not enabled
                    UpdateVisual()
                    if opts.Callback then opts.Callback(enabled) end
                end)
                
                local API = {}
                function API:Set(value)
                    enabled = value
                    UpdateVisual()
                    if opts.Callback then opts.Callback(enabled) end
                end
                function API:Get() return enabled end
                return API
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- SLIDER
            -- ═══════════════════════════════════════════════════════════════
            function SectionAPI:CreateSlider(opts)
                opts = opts or {}
                elementOrder = elementOrder + 1
                local min = opts.Min or 0
                local max = opts.Max or 100
                local value = opts.Default or min
                local suffix = opts.Suffix or ""
                
                local Container = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                
                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, -50, 0, 18),
                    BackgroundTransparency = 1,
                    Text = opts.Name or "Slider",
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })
                
                local ValueLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 45, 0, 18),
                    Position = UDim2.new(1, -45, 0, 0),
                    BackgroundTransparency = 1,
                    Text = value .. suffix,
                    TextColor3 = CurrentTheme.Accent,
                    TextSize = 11,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Container
                })
                
                local SliderBG = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = CurrentTheme.Primary,
                    BorderSizePixel = 0,
                    Parent = Container
                })
                AddCorner(SliderBG, 3)
                AddStroke(SliderBG, CurrentTheme.Border, 1)
                
                local SliderFill = Create("Frame", {
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = CurrentTheme.Accent,
                    BorderSizePixel = 0,
                    Parent = SliderBG
                })
                AddCorner(SliderFill, 3)
                
                local SliderKnob = Create("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7),
                    BackgroundColor3 = CurrentTheme.Text,
                    BorderSizePixel = 0,
                    Parent = SliderBG
                })
                AddCorner(SliderKnob, 7)
                
                local isDragging = false
                
                local function Update(inputX)
                    local pos = SliderBG.AbsolutePosition.X
                    local size = SliderBG.AbsoluteSize.X
                    local relative = math.clamp((inputX - pos) / size, 0, 1)
                    value = math.floor(min + (max - min) * relative)
                    ValueLabel.Text = value .. suffix
                    SliderFill.Size = UDim2.new(relative, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(relative, -7, 0.5, -7)
                    if opts.Callback then opts.Callback(value) end
                end
                
                SliderBG.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = true
                        Update(input.Position.X)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(input.Position.X)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)
                
                local API = {}
                function API:Set(val)
                    value = math.clamp(val, min, max)
                    local relative = (value - min) / (max - min)
                    ValueLabel.Text = value .. suffix
                    SliderFill.Size = UDim2.new(relative, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(relative, -7, 0.5, -7)
                    if opts.Callback then opts.Callback(value) end
                end
                function API:Get() return value end
                return API
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- BUTTON
            -- ═══════════════════════════════════════════════════════════════
            function SectionAPI:CreateButton(opts)
                opts = opts or {}
                elementOrder = elementOrder + 1
                
                local Button = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = CurrentTheme.Primary,
                    BorderSizePixel = 0,
                    Text = opts.Name or "Button",
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 11,
                    Font = Enum.Font.GothamMedium,
                    AutoButtonColor = false,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                AddCorner(Button, 4)
                AddStroke(Button, CurrentTheme.Border, 1)
                
                Button.MouseEnter:Connect(function()
                    Tween(Button, {BackgroundColor3 = CurrentTheme.Hover}, 0.15)
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {BackgroundColor3 = CurrentTheme.Primary}, 0.15)
                end)
                
                Button.MouseButton1Click:Connect(function()
                    Tween(Button, {BackgroundColor3 = CurrentTheme.Accent}, 0.1)
                    task.wait(0.1)
                    Tween(Button, {BackgroundColor3 = CurrentTheme.Hover}, 0.1)
                    if opts.Callback then opts.Callback() end
                end)
                
                return Button
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- DROPDOWN
            -- ═══════════════════════════════════════════════════════════════
            function SectionAPI:CreateDropdown(opts)
                opts = opts or {}
                elementOrder = elementOrder + 1
                local options = opts.Options or {}
                local selected = opts.Default or (options[1] or "")
                local isOpen = false
                
                local Container = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    ClipsDescendants = false,
                    Parent = SectionContent
                })
                
                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = opts.Name or "Dropdown",
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })
                
                local DropdownBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = CurrentTheme.Primary,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Container
                })
                AddCorner(DropdownBtn, 4)
                AddStroke(DropdownBtn, CurrentTheme.Border, 1)
                
                local SelectedLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = selected,
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownBtn
                })
                
                local Arrow = Create("TextLabel", {
                    Size = UDim2.new(0, 16, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 8,
                    Font = Enum.Font.Gotham,
                    Parent = DropdownBtn
                })
                
                -- Options container on ScreenGui
                local OptionsContainer = Create("Frame", {
                    Size = UDim2.new(0, 100, 0, 0),
                    BackgroundColor3 = CurrentTheme.Primary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 100,
                    ClipsDescendants = true,
                    Parent = ScreenGui
                })
                AddCorner(OptionsContainer, 4)
                AddStroke(OptionsContainer, CurrentTheme.Border, 1)
                
                local OptionsScroll = Create("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = CurrentTheme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 101,
                    Parent = OptionsContainer
                })
                
                local OptionsLayout = Create("UIListLayout", {
                    Padding = UDim.new(0, 1),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = OptionsScroll
                })
                
                local function CreateOptions()
                    for _, child in ipairs(OptionsScroll:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    
                    for i, option in ipairs(options) do
                        local OptionBtn = Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 24),
                            BackgroundColor3 = CurrentTheme.Primary,
                            BackgroundTransparency = option == selected and 0.5 or 1,
                            BorderSizePixel = 0,
                            Text = option,
                            TextColor3 = option == selected and CurrentTheme.Accent or CurrentTheme.Text,
                            TextSize = 11,
                            Font = Enum.Font.Gotham,
                            AutoButtonColor = false,
                            LayoutOrder = i,
                            ZIndex = 102,
                            Parent = OptionsScroll
                        })
                        
                        OptionBtn.MouseEnter:Connect(function()
                            if option ~= selected then
                                Tween(OptionBtn, {BackgroundTransparency = 0.7}, 0.1)
                            end
                        end)
                        
                        OptionBtn.MouseLeave:Connect(function()
                            if option ~= selected then
                                Tween(OptionBtn, {BackgroundTransparency = 1}, 0.1)
                            end
                        end)
                        
                        OptionBtn.MouseButton1Click:Connect(function()
                            selected = option
                            SelectedLabel.Text = option
                            isOpen = false
                            OptionsContainer.Visible = false
                            Arrow.Rotation = 0
                            CreateOptions()
                            if opts.Callback then opts.Callback(option) end
                        end)
                    end
                end
                
                CreateOptions()
                
                local function ToggleDropdown()
                    isOpen = not isOpen
                    if isOpen then
                        local btnPos = DropdownBtn.AbsolutePosition
                        local btnSize = DropdownBtn.AbsoluteSize
                        local height = math.min(#options * 25, 150)
                        OptionsContainer.Position = UDim2.new(0, btnPos.X, 0, btnPos.Y + btnSize.Y + 2)
                        OptionsContainer.Size = UDim2.new(0, btnSize.X, 0, height)
                        OptionsContainer.Visible = true
                        Arrow.Rotation = 180
                    else
                        OptionsContainer.Visible = false
                        Arrow.Rotation = 0
                    end
                end
                
                DropdownBtn.MouseButton1Click:Connect(ToggleDropdown)
                
                -- Close on click outside
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local containerPos = OptionsContainer.AbsolutePosition
                        local containerSize = OptionsContainer.AbsoluteSize
                        local btnPos = DropdownBtn.AbsolutePosition
                        local btnSize = DropdownBtn.AbsoluteSize
                        
                        local inContainer = mousePos.X >= containerPos.X and mousePos.X <= containerPos.X + containerSize.X
                            and mousePos.Y >= containerPos.Y and mousePos.Y <= containerPos.Y + containerSize.Y
                        local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X
                            and mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
                        
                        if not inContainer and not inButton then
                            isOpen = false
                            OptionsContainer.Visible = false
                            Arrow.Rotation = 0
                        end
                    end
                end)
                
                local API = {}
                function API:Set(value)
                    if table.find(options, value) then
                        selected = value
                        SelectedLabel.Text = value
                        CreateOptions()
                        if opts.Callback then opts.Callback(value) end
                    end
                end
                function API:Get() return selected end
                function API:Refresh(newOptions)
                    options = newOptions
                    CreateOptions()
                end
                return API
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- MULTI DROPDOWN
            -- ═══════════════════════════════════════════════════════════════
            function SectionAPI:CreateMultiDropdown(opts)
                opts = opts or {}
                elementOrder = elementOrder + 1
                local options = opts.Options or {}
                local selected = opts.Default or {}
                local isOpen = false
                
                local Container = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    ClipsDescendants = false,
                    Parent = SectionContent
                })
                
                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = opts.Name or "Multi Dropdown",
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })
                
                local DropdownBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = CurrentTheme.Primary,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Container
                })
                AddCorner(DropdownBtn, 4)
                AddStroke(DropdownBtn, CurrentTheme.Border, 1)
                
                local function GetDisplayText()
                    if #selected == 0 then return "None"
                    elseif #selected == 1 then return selected[1]
                    elseif #selected <= 2 then return table.concat(selected, ", ")
                    else return #selected .. " selected"
                    end
                end
                
                local SelectedLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = GetDisplayText(),
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownBtn
                })
                
                local Arrow = Create("TextLabel", {
                    Size = UDim2.new(0, 16, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 8,
                    Font = Enum.Font.Gotham,
                    Parent = DropdownBtn
                })
                
                -- Options container on ScreenGui
                local OptionsContainer = Create("Frame", {
                    Size = UDim2.new(0, 100, 0, 0),
                    BackgroundColor3 = CurrentTheme.Primary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 100,
                    ClipsDescendants = true,
                    Parent = ScreenGui
                })
                AddCorner(OptionsContainer, 4)
                AddStroke(OptionsContainer, CurrentTheme.Border, 1)
                
                local OptionsScroll = Create("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = CurrentTheme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 101,
                    Parent = OptionsContainer
                })
                
                local OptionsLayout = Create("UIListLayout", {
                    Padding = UDim.new(0, 1),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = OptionsScroll
                })
                
                local function CreateOptions()
                    for _, child in ipairs(OptionsScroll:GetChildren()) do
                        if child:IsA("Frame") then child:Destroy() end
                    end
                    
                    for i, option in ipairs(options) do
                        local isSelected = table.find(selected, option) ~= nil
                        
                        local OptionFrame = Create("Frame", {
                            Size = UDim2.new(1, 0, 0, 24),
                            BackgroundColor3 = CurrentTheme.Primary,
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            LayoutOrder = i,
                            ZIndex = 102,
                            Parent = OptionsScroll
                        })
                        
                        local Checkbox = Create("Frame", {
                            Size = UDim2.new(0, 14, 0, 14),
                            Position = UDim2.new(0, 6, 0.5, -7),
                            BackgroundColor3 = isSelected and CurrentTheme.Accent or CurrentTheme.Primary,
                            BorderSizePixel = 0,
                            ZIndex = 103,
                            Parent = OptionFrame
                        })
                        AddCorner(Checkbox, 3)
                        AddStroke(Checkbox, CurrentTheme.Border, 1)
                        
                        local Checkmark = Create("TextLabel", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = isSelected and "✓" or "",
                            TextColor3 = CurrentTheme.Text,
                            TextSize = 10,
                            Font = Enum.Font.GothamBold,
                            ZIndex = 104,
                            Parent = Checkbox
                        })
                        
                        local OptionLabel = Create("TextLabel", {
                            Size = UDim2.new(1, -28, 1, 0),
                            Position = UDim2.new(0, 26, 0, 0),
                            BackgroundTransparency = 1,
                            Text = option,
                            TextColor3 = isSelected and CurrentTheme.Accent or CurrentTheme.Text,
                            TextSize = 11,
                            Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 103,
                            Parent = OptionFrame
                        })
                        
                        local OptionBtn = Create("TextButton", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = "",
                            ZIndex = 105,
                            Parent = OptionFrame
                        })
                        
                        OptionBtn.MouseEnter:Connect(function()
                            Tween(OptionFrame, {BackgroundTransparency = 0.7}, 0.1)
                        end)
                        
                        OptionBtn.MouseLeave:Connect(function()
                            Tween(OptionFrame, {BackgroundTransparency = 1}, 0.1)
                        end)
                        
                        OptionBtn.MouseButton1Click:Connect(function()
                            local idx = table.find(selected, option)
                            if idx then
                                table.remove(selected, idx)
                            else
                                table.insert(selected, option)
                            end
                            SelectedLabel.Text = GetDisplayText()
                            CreateOptions()
                            if opts.Callback then opts.Callback(selected) end
                        end)
                    end
                end
                
                CreateOptions()
                
                local function ToggleDropdown()
                    isOpen = not isOpen
                    if isOpen then
                        local btnPos = DropdownBtn.AbsolutePosition
                        local btnSize = DropdownBtn.AbsoluteSize
                        local height = math.min(#options * 25, 150)
                        OptionsContainer.Position = UDim2.new(0, btnPos.X, 0, btnPos.Y + btnSize.Y + 2)
                        OptionsContainer.Size = UDim2.new(0, btnSize.X, 0, height)
                        OptionsContainer.Visible = true
                        Arrow.Rotation = 180
                    else
                        OptionsContainer.Visible = false
                        Arrow.Rotation = 0
                    end
                end
                
                DropdownBtn.MouseButton1Click:Connect(ToggleDropdown)
                
                -- Close on click outside
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local containerPos = OptionsContainer.AbsolutePosition
                        local containerSize = OptionsContainer.AbsoluteSize
                        local btnPos = DropdownBtn.AbsolutePosition
                        local btnSize = DropdownBtn.AbsoluteSize
                        
                        local inContainer = mousePos.X >= containerPos.X and mousePos.X <= containerPos.X + containerSize.X
                            and mousePos.Y >= containerPos.Y and mousePos.Y <= containerPos.Y + containerSize.Y
                        local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X
                            and mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
                        
                        if not inContainer and not inButton then
                            isOpen = false
                            OptionsContainer.Visible = false
                            Arrow.Rotation = 0
                        end
                    end
                end)
                
                local API = {}
                function API:Set(values)
                    selected = values
                    SelectedLabel.Text = GetDisplayText()
                    CreateOptions()
                    if opts.Callback then opts.Callback(selected) end
                end
                function API:Get() return selected end
                return API
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- INPUT
            -- ═══════════════════════════════════════════════════════════════
            function SectionAPI:CreateInput(opts)
                opts = opts or {}
                elementOrder = elementOrder + 1
                
                local Container = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                
                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = opts.Name or "Input",
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })
                
                local InputFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = CurrentTheme.Primary,
                    BorderSizePixel = 0,
                    Parent = Container
                })
                AddCorner(InputFrame, 4)
                AddStroke(InputFrame, CurrentTheme.Border, 1)
                
                local Input = Create("TextBox", {
                    Size = UDim2.new(1, -12, 1, 0),
                    Position = UDim2.new(0, 6, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Default or "",
                    PlaceholderText = opts.Placeholder or "Enter text...",
                    PlaceholderColor3 = CurrentTheme.TextDark,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = InputFrame
                })
                
                Input.FocusLost:Connect(function(enterPressed)
                    if opts.Callback then opts.Callback(Input.Text, enterPressed) end
                end)
                
                local API = {}
                function API:Set(text)
                    Input.Text = text
                    if opts.Callback then opts.Callback(text, false) end
                end
                function API:Get() return Input.Text end
                return API
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- KEYBIND
            -- ═══════════════════════════════════════════════════════════════
            function SectionAPI:CreateKeybind(opts)
                opts = opts or {}
                elementOrder = elementOrder + 1
                local keybind = opts.Default or Enum.KeyCode.None
                local listening = false
                
                local Container = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                
                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Name or "Keybind",
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })
                
                local KeyBtn = Create("TextButton", {
                    Size = UDim2.new(0, 55, 0, 20),
                    Position = UDim2.new(1, -55, 0.5, -10),
                    BackgroundColor3 = CurrentTheme.Primary,
                    BorderSizePixel = 0,
                    Text = keybind.Name,
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.GothamMedium,
                    AutoButtonColor = false,
                    Parent = Container
                })
                AddCorner(KeyBtn, 4)
                AddStroke(KeyBtn, CurrentTheme.Border, 1)
                
                KeyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    KeyBtn.Text = "..."
                    KeyBtn.TextColor3 = CurrentTheme.Accent
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            keybind = input.KeyCode
                            KeyBtn.Text = keybind.Name
                            KeyBtn.TextColor3 = CurrentTheme.TextDark
                            listening = false
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                            task.wait()
                            if listening then
                                KeyBtn.Text = keybind.Name
                                KeyBtn.TextColor3 = CurrentTheme.TextDark
                                listening = false
                            end
                        end
                    elseif not processed and input.KeyCode == keybind then
                        if opts.Callback then opts.Callback(keybind) end
                    end
                end)
                
                local API = {}
                function API:Set(key)
                    keybind = key
                    KeyBtn.Text = keybind.Name
                end
                function API:Get() return keybind end
                return API
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- COLOR PICKER (FULLY FUNCTIONAL)
            -- ═══════════════════════════════════════════════════════════════
            function SectionAPI:CreateColorPicker(opts)
                opts = opts or {}
                elementOrder = elementOrder + 1
                local currentColor = opts.Default or Color3.fromRGB(130, 80, 245)
                local currentAlpha = opts.Alpha or 1
                
                -- Convert initial color to HSV
                local h, s, v = RGBtoHSV(currentColor)
                
                local Container = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                
                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Name or "Color",
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })
                
                local ColorBtn = Create("TextButton", {
                    Size = UDim2.new(0, 32, 0, 18),
                    Position = UDim2.new(1, -32, 0.5, -9),
                    BackgroundColor3 = currentColor,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Container
                })
                AddCorner(ColorBtn, 4)
                AddStroke(ColorBtn, CurrentTheme.Border, 1)
                
                -- Picker panel on ScreenGui
                local PickerPanel = Create("Frame", {
                    Size = UDim2.new(0, 200, 0, 180),
                    BackgroundColor3 = CurrentTheme.Primary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 100,
                    Parent = ScreenGui
                })
                AddCorner(PickerPanel, 6)
                AddStroke(PickerPanel, CurrentTheme.Border, 1)
                
                -- SV Picker (Saturation-Value)
                local SVPicker = Create("Frame", {
                    Size = UDim2.new(0, 180, 0, 100),
                    Position = UDim2.new(0, 10, 0, 10),
                    BackgroundColor3 = HSVtoRGB(h, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 101,
                    Parent = PickerPanel
                })
                AddCorner(SVPicker, 4)
                
                -- White gradient (left to right)
                local WhiteGradient = Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }),
                    Rotation = 0,
                    Parent = SVPicker
                })
                
                -- Black overlay (top to bottom)
                local BlackOverlay = Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 102,
                    Parent = SVPicker
                })
                AddCorner(BlackOverlay, 4)
                
                local BlackGradient = Create("UIGradient", {
                    Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }),
                    Rotation = 90,
                    Parent = BlackOverlay
                })
                
                -- SV Cursor
                local SVCursor = Create("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(s, -6, 1 - v, -6),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 104,
                    Parent = SVPicker
                })
                AddCorner(SVCursor, 6)
                AddStroke(SVCursor, Color3.new(0, 0, 0), 2)
                
                -- Hue Slider
                local HueSlider = Create("Frame", {
                    Size = UDim2.new(0, 180, 0, 14),
                    Position = UDim2.new(0, 10, 0, 118),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 101,
                    Parent = PickerPanel
                })
                AddCorner(HueSlider, 4)
                
                local HueGradient = Create("UIGradient", {
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
                
                -- Hue Cursor
                local HueCursor = Create("Frame", {
                    Size = UDim2.new(0, 6, 0, 18),
                    Position = UDim2.new(h, -3, 0.5, -9),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 102,
                    Parent = HueSlider
                })
                AddCorner(HueCursor, 2)
                AddStroke(HueCursor, Color3.new(0, 0, 0), 1)
                
                -- Alpha Slider
                local AlphaSlider = Create("Frame", {
                    Size = UDim2.new(0, 180, 0, 14),
                    Position = UDim2.new(0, 10, 0, 138),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 101,
                    Parent = PickerPanel
                })
                AddCorner(AlphaSlider, 4)
                
                local AlphaGradient = Create("UIGradient", {
                    Color = ColorSequence.new(Color3.new(0, 0, 0), currentColor),
                    Transparency = NumberSequence.new(0),
                    Parent = AlphaSlider
                })
                
                -- Alpha Cursor
                local AlphaCursor = Create("Frame", {
                    Size = UDim2.new(0, 6, 0, 18),
                    Position = UDim2.new(currentAlpha, -3, 0.5, -9),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 102,
                    Parent = AlphaSlider
                })
                AddCorner(AlphaCursor, 2)
                AddStroke(AlphaCursor, Color3.new(0, 0, 0), 1)
                
                -- Hex display
                local HexLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 80, 0, 18),
                    Position = UDim2.new(0, 10, 0, 158),
                    BackgroundTransparency = 1,
                    Text = Color3ToHex(currentColor),
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 101,
                    Parent = PickerPanel
                })
                
                -- Alpha percent display
                local AlphaLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 60, 0, 18),
                    Position = UDim2.new(1, -70, 0, 158),
                    BackgroundTransparency = 1,
                    Text = math.floor(currentAlpha * 100) .. "%",
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 101,
                    Parent = PickerPanel
                })
                
                local isOpen = false
                local draggingSV = false
                local draggingHue = false
                local draggingAlpha = false
                
                local function UpdateColor()
                    currentColor = HSVtoRGB(h, s, v)
                    ColorBtn.BackgroundColor3 = currentColor
                    SVPicker.BackgroundColor3 = HSVtoRGB(h, 1, 1)
                    AlphaGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), currentColor)
                    HexLabel.Text = Color3ToHex(currentColor)
                    AlphaLabel.Text = math.floor(currentAlpha * 100) .. "%"
                    if opts.Callback then opts.Callback(currentColor, currentAlpha) end
                end
                
                local function UpdateSV(input)
                    local pos = SVPicker.AbsolutePosition
                    local size = SVPicker.AbsoluteSize
                    s = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                    v = math.clamp(1 - (input.Position.Y - pos.Y) / size.Y, 0, 1)
                    SVCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                    UpdateColor()
                end
                
                local function UpdateHue(input)
                    local pos = HueSlider.AbsolutePosition
                    local size = HueSlider.AbsoluteSize
                    h = math.clamp((input.Position.X - pos.X) / size.X, 0, 0.999)
                    HueCursor.Position = UDim2.new(h, -3, 0.5, -9)
                    UpdateColor()
                end
                
                local function UpdateAlpha(input)
                    local pos = AlphaSlider.AbsolutePosition
                    local size = AlphaSlider.AbsoluteSize
                    currentAlpha = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                    AlphaCursor.Position = UDim2.new(currentAlpha, -3, 0.5, -9)
                    UpdateColor()
                end
                
                -- Input handling for SV Picker
                SVPicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV = true
                        UpdateSV(input)
                    end
                end)
                
                BlackOverlay.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV = true
                        UpdateSV(input)
                    end
                end)
                
                -- Input handling for Hue Slider
                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = true
                        UpdateHue(input)
                    end
                end)
                
                -- Input handling for Alpha Slider
                AlphaSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingAlpha = true
                        UpdateAlpha(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if draggingSV then UpdateSV(input) end
                        if draggingHue then UpdateHue(input) end
                        if draggingAlpha then UpdateAlpha(input) end
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV = false
                        draggingHue = false
                        draggingAlpha = false
                    end
                end)
                
                ColorBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        local btnPos = ColorBtn.AbsolutePosition
                        local btnSize = ColorBtn.AbsoluteSize
                        local screenSize = workspace.CurrentCamera.ViewportSize
                        
                        local posX = btnPos.X - 200 - 5
                        if posX < 0 then
                            posX = btnPos.X + btnSize.X + 5
                        end
                        
                        PickerPanel.Position = UDim2.new(0, posX, 0, btnPos.Y - 50)
                        PickerPanel.Visible = true
                    else
                        PickerPanel.Visible = false
                    end
                end)
                
                -- Close on click outside
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
                        if not draggingSV and not draggingHue and not draggingAlpha then
                            task.wait()
                            local mousePos = UserInputService:GetMouseLocation()
                            local panelPos = PickerPanel.AbsolutePosition
                            local panelSize = PickerPanel.AbsoluteSize
                            local btnPos = ColorBtn.AbsolutePosition
                            local btnSize = ColorBtn.AbsoluteSize
                            
                            local inPanel = mousePos.X >= panelPos.X and mousePos.X <= panelPos.X + panelSize.X
                                and mousePos.Y >= panelPos.Y and mousePos.Y <= panelPos.Y + panelSize.Y
                            local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X
                                and mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
                            
                            if not inPanel and not inButton then
                                isOpen = false
                                PickerPanel.Visible = false
                            end
                        end
                    end
                end)
                
                local API = {}
                function API:Set(color, alpha)
                    currentColor = color
                    if alpha then currentAlpha = alpha end
                    h, s, v = RGBtoHSV(color)
                    SVCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                    HueCursor.Position = UDim2.new(h, -3, 0.5, -9)
                    AlphaCursor.Position = UDim2.new(currentAlpha, -3, 0.5, -9)
                    UpdateColor()
                end
                function API:Get() return currentColor, currentAlpha end
                return API
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- LABEL
            -- ═══════════════════════════════════════════════════════════════
            function SectionAPI:CreateLabel(text)
                elementOrder = elementOrder + 1
                
                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = text or "Label",
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                
                local API = {}
                function API:Set(newText) Label.Text = newText end
                return API
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- SEPARATOR
            -- ═══════════════════════════════════════════════════════════════
            function SectionAPI:CreateSeparator()
                elementOrder = elementOrder + 1
                
                local Separator = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = CurrentTheme.Border,
                    BorderSizePixel = 0,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                
                return Separator
            end
            
            return SectionAPI
        end
        
        return TabAPI
    end
    
    -- ═══════════════════════════════════════════════════════════════
    -- NOTIFICATION SYSTEM
    -- ═══════════════════════════════════════════════════════════════
    function WindowAPI:Notify(opts)
        opts = opts or {}
        local title = opts.Title or "Notification"
        local message = opts.Message or ""
        local duration = opts.Duration or 4
        local notifType = opts.Type or "Info"
        
        local typeColors = {
            Success = CurrentTheme.Success,
            Warning = CurrentTheme.Warning,
            Error = CurrentTheme.Error,
            Info = CurrentTheme.Accent
        }
        
        local accentColor = typeColors[notifType] or CurrentTheme.Accent
        
        local NotifContainer = ScreenGui:FindFirstChild("NotifContainer")
        if not NotifContainer then
            NotifContainer = Create("Frame", {
                Name = "NotifContainer",
                Size = UDim2.new(0, 280, 1, -20),
                Position = UDim2.new(1, -290, 0, 10),
                BackgroundTransparency = 1,
                Parent = ScreenGui
            })
            
            Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                Parent = NotifContainer
            })
        end
        
        local Notif = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundColor3 = CurrentTheme.Primary,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = NotifContainer
        })
        AddCorner(Notif, 6)
        AddStroke(Notif, CurrentTheme.Border, 1)
        
        -- Accent line
        local NotifAccent = Create("Frame", {
            Size = UDim2.new(0, 3, 1, -12),
            Position = UDim2.new(0, 6, 0, 6),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Parent = Notif
        })
        AddCorner(NotifAccent, 1)
        
        local NotifTitle = Create("TextLabel", {
            Size = UDim2.new(1, -24, 0, 20),
            Position = UDim2.new(0, 16, 0, 8),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = CurrentTheme.Text,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notif
        })
        
        local NotifMessage = Create("TextLabel", {
            Size = UDim2.new(1, -24, 0, 30),
            Position = UDim2.new(0, 16, 0, 26),
            BackgroundTransparency = 1,
            Text = message,
            TextColor3 = CurrentTheme.TextDark,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Parent = Notif
        })
        
        -- Progress bar
        local ProgressBar = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Parent = Notif
        })
        
        -- Animate in
        Notif.Position = UDim2.new(1, 20, 0, 0)
        Tween(Notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        -- Progress animation
        Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration)
        
        -- Remove after duration
        task.delay(duration, function()
            Tween(Notif, {Position = UDim2.new(1, 20, 0, 0)}, 0.3)
            task.wait(0.3)
            Notif:Destroy()
        end)
    end
    
    return WindowAPI
end

-- Return Library
return FSLib
