--[[
    SkeetUI v3.0.0 - Premium Roblox Script GUI Library
    Neverlose/Skeet Style with Industrial Aesthetics
    
    Fixed: Gradient bars, StatusBar corners, MultiDropdown, Keybind toggle, Watermark
]]

local SkeetUI = {}
SkeetUI.__index = SkeetUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Theme Configuration
local Themes = {
    Dark = {
        Primary = Color3.fromRGB(134, 148, 255),
        Secondary = Color3.fromRGB(255, 107, 182),
        Background = Color3.fromRGB(16, 16, 20),
        Surface = Color3.fromRGB(22, 22, 28),
        SurfaceHover = Color3.fromRGB(28, 28, 36),
        Border = Color3.fromRGB(40, 40, 50),
        Text = Color3.fromRGB(240, 240, 245),
        TextDim = Color3.fromRGB(140, 140, 160),
        Success = Color3.fromRGB(98, 224, 158),
        Warning = Color3.fromRGB(255, 193, 94),
        Error = Color3.fromRGB(255, 99, 99)
    },
    Midnight = {
        Primary = Color3.fromRGB(99, 179, 255),
        Secondary = Color3.fromRGB(168, 130, 255),
        Background = Color3.fromRGB(12, 15, 24),
        Surface = Color3.fromRGB(18, 22, 34),
        SurfaceHover = Color3.fromRGB(24, 30, 46),
        Border = Color3.fromRGB(36, 44, 66),
        Text = Color3.fromRGB(235, 240, 255),
        TextDim = Color3.fromRGB(130, 145, 180),
        Success = Color3.fromRGB(98, 224, 158),
        Warning = Color3.fromRGB(255, 193, 94),
        Error = Color3.fromRGB(255, 99, 99)
    },
    Blood = {
        Primary = Color3.fromRGB(255, 99, 99),
        Secondary = Color3.fromRGB(255, 150, 120),
        Background = Color3.fromRGB(18, 14, 14),
        Surface = Color3.fromRGB(26, 20, 20),
        SurfaceHover = Color3.fromRGB(36, 26, 26),
        Border = Color3.fromRGB(55, 40, 40),
        Text = Color3.fromRGB(255, 240, 240),
        TextDim = Color3.fromRGB(180, 140, 140),
        Success = Color3.fromRGB(98, 224, 158),
        Warning = Color3.fromRGB(255, 193, 94),
        Error = Color3.fromRGB(255, 99, 99)
    },
    Emerald = {
        Primary = Color3.fromRGB(98, 224, 158),
        Secondary = Color3.fromRGB(130, 200, 255),
        Background = Color3.fromRGB(12, 18, 16),
        Surface = Color3.fromRGB(18, 26, 22),
        SurfaceHover = Color3.fromRGB(24, 36, 30),
        Border = Color3.fromRGB(36, 55, 46),
        Text = Color3.fromRGB(235, 255, 245),
        TextDim = Color3.fromRGB(130, 180, 155),
        Success = Color3.fromRGB(98, 224, 158),
        Warning = Color3.fromRGB(255, 193, 94),
        Error = Color3.fromRGB(255, 99, 99)
    }
}

local CurrentTheme = Themes.Dark

-- Utility Functions
local function Tween(obj, props, duration)
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function CreateRoundedFrame(props)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = props.Color or CurrentTheme.Surface
    frame.BorderSizePixel = 0
    frame.Size = props.Size or UDim2.new(1, 0, 1, 0)
    frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
    frame.Name = props.Name or "Frame"
    
    if props.CornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, props.CornerRadius)
        corner.Parent = frame
    end
    
    if props.Parent then
        frame.Parent = props.Parent
    end
    
    return frame
end

local function CreateGradient(parent, colors)
    local gradient = Instance.new("UIGradient")
    local colorSeq = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colors[1]),
        ColorSequenceKeypoint.new(0.5, colors[2]),
        ColorSequenceKeypoint.new(1, colors[1])
    })
    gradient.Color = colorSeq
    gradient.Rotation = 0
    gradient.Parent = parent
    return gradient
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
    return Color3.new(r, g, b)
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
        math.floor(color.B * 255))
end

-- Main Window Creation
function SkeetUI:CreateWindow(options)
    options = options or {}
    local title = options.Title or "SkeetUI"
    local themeName = options.Theme or "Dark"
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    local statusBarConfig = options.StatusBar or {
        Text = "ready",
        Build = "build: " .. os.date("%Y%m%d"),
        Version = "v3.0.0",
        Visible = true
    }
    
    CurrentTheme = Themes[themeName] or Themes.Dark
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Visible = true
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkeetUI_" .. HttpService:GenerateGUID(false)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")
    
    Window.ScreenGui = ScreenGui
    
    -- Main Container - 这是最外层容器，有圆角和ClipsDescendants
    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "MainContainer"
    MainContainer.BackgroundColor3 = CurrentTheme.Background
    MainContainer.BorderSizePixel = 0
    MainContainer.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainContainer.Size = UDim2.new(0, 600, 0, 400)
    MainContainer.ClipsDescendants = true -- 关键：裁剪所有子元素
    MainContainer.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainContainer
    
    -- Border using UIStroke
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = CurrentTheme.Border
    MainStroke.Thickness = 1
    MainStroke.Parent = MainContainer
    
    -- Top Gradient Line - 直接放在MainContainer内，会被圆角裁剪
    local TopGradient = Instance.new("Frame")
    TopGradient.Name = "TopGradient"
    TopGradient.BackgroundColor3 = Color3.new(1, 1, 1)
    TopGradient.BorderSizePixel = 0
    TopGradient.Position = UDim2.new(0, 0, 0, 0)
    TopGradient.Size = UDim2.new(1, 0, 0, 2)
    TopGradient.ZIndex = 10
    TopGradient.Parent = MainContainer
    
    CreateGradient(TopGradient, {CurrentTheme.Primary, CurrentTheme.Secondary})
    
    -- Title Bar (在渐变线下方)
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.BackgroundColor3 = CurrentTheme.Surface
    TitleBar.BorderSizePixel = 0
    TitleBar.Position = UDim2.new(0, 0, 0, 2)
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.Parent = MainContainer
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "Title"
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0, 12, 0, 0)
    TitleText.Size = UDim2.new(0.5, 0, 1, 0)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Text = title
    TitleText.TextColor3 = CurrentTheme.Text
    TitleText.TextSize = 13
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Keybind Hint (右上角)
    local KeybindHint = Instance.new("TextLabel")
    KeybindHint.Name = "KeybindHint"
    KeybindHint.BackgroundTransparency = 1
    KeybindHint.Position = UDim2.new(1, -80, 0, 0)
    KeybindHint.Size = UDim2.new(0, 70, 1, 0)
    KeybindHint.Font = Enum.Font.GothamMedium
    KeybindHint.Text = "[" .. tostring(toggleKey.Name) .. "]"
    KeybindHint.TextColor3 = CurrentTheme.TextDim
    KeybindHint.TextSize = 11
    KeybindHint.TextXAlignment = Enum.TextXAlignment.Right
    KeybindHint.Parent = TitleBar
    
    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.BackgroundColor3 = CurrentTheme.Surface
    TabBar.BorderSizePixel = 0
    TabBar.Position = UDim2.new(0, 0, 0, 34)
    TabBar.Size = UDim2.new(0, 100, 1, -56) -- 56 = 34 top + 22 bottom
    TabBar.Parent = MainContainer
    
    local TabBarStroke = Instance.new("UIStroke")
    TabBarStroke.Color = CurrentTheme.Border
    TabBarStroke.Thickness = 1
    TabBarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    TabBarStroke.Parent = TabBar
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.Position = UDim2.new(0, 4, 0, 4)
    TabList.Size = UDim2.new(1, -8, 1, -8)
    TabList.ScrollBarThickness = 0
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.Parent = TabBar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 2)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabList
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.BackgroundColor3 = CurrentTheme.Background
    ContentArea.BorderSizePixel = 0
    ContentArea.Position = UDim2.new(0, 100, 0, 34)
    ContentArea.Size = UDim2.new(1, -100, 1, -56)
    ContentArea.Parent = MainContainer
    
    -- Status Bar - 在最底部，会被MainContainer的圆角裁剪
    local StatusBar = Instance.new("Frame")
    StatusBar.Name = "StatusBar"
    StatusBar.BackgroundColor3 = CurrentTheme.Surface
    StatusBar.BorderSizePixel = 0
    StatusBar.Position = UDim2.new(0, 0, 1, -22)
    StatusBar.Size = UDim2.new(1, 0, 0, 22)
    StatusBar.Visible = statusBarConfig.Visible ~= false
    StatusBar.Parent = MainContainer
    
    local StatusStroke = Instance.new("UIStroke")
    StatusStroke.Color = CurrentTheme.Border
    StatusStroke.Thickness = 1
    StatusStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    StatusStroke.Parent = StatusBar
    
    -- Status Left (状态点 + 文字)
    local StatusLeft = Instance.new("Frame")
    StatusLeft.Name = "StatusLeft"
    StatusLeft.BackgroundTransparency = 1
    StatusLeft.Position = UDim2.new(0, 10, 0, 0)
    StatusLeft.Size = UDim2.new(0.3, 0, 1, 0)
    StatusLeft.Parent = StatusBar
    
    local StatusDot = Instance.new("Frame")
    StatusDot.Name = "StatusDot"
    StatusDot.BackgroundColor3 = CurrentTheme.Success
    StatusDot.BorderSizePixel = 0
    StatusDot.Position = UDim2.new(0, 0, 0.5, -3)
    StatusDot.Size = UDim2.new(0, 6, 0, 6)
    StatusDot.Parent = StatusLeft
    
    local StatusDotCorner = Instance.new("UICorner")
    StatusDotCorner.CornerRadius = UDim.new(1, 0)
    StatusDotCorner.Parent = StatusDot
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.BackgroundTransparency = 1
    StatusText.Position = UDim2.new(0, 12, 0, 0)
    StatusText.Size = UDim2.new(1, -12, 1, 0)
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.Text = statusBarConfig.Text or "ready"
    StatusText.TextColor3 = CurrentTheme.TextDim
    StatusText.TextSize = 10
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = StatusLeft
    
    -- Status Center
    local StatusCenter = Instance.new("TextLabel")
    StatusCenter.Name = "StatusCenter"
    StatusCenter.BackgroundTransparency = 1
    StatusCenter.Position = UDim2.new(0.3, 0, 0, 0)
    StatusCenter.Size = UDim2.new(0.4, 0, 1, 0)
    StatusCenter.Font = Enum.Font.GothamMedium
    StatusCenter.Text = statusBarConfig.Build or "build: " .. os.date("%Y%m%d")
    StatusCenter.TextColor3 = CurrentTheme.TextDim
    StatusCenter.TextSize = 10
    StatusCenter.Parent = StatusBar
    
    -- Status Right
    local StatusRight = Instance.new("TextLabel")
    StatusRight.Name = "StatusRight"
    StatusRight.BackgroundTransparency = 1
    StatusRight.Position = UDim2.new(0.7, 0, 0, 0)
    StatusRight.Size = UDim2.new(0.3, -10, 1, 0)
    StatusRight.Font = Enum.Font.GothamMedium
    StatusRight.Text = statusBarConfig.Version or "v3.0.0"
    StatusRight.TextColor3 = CurrentTheme.TextDim
    StatusRight.TextSize = 10
    StatusRight.TextXAlignment = Enum.TextXAlignment.Right
    StatusRight.Parent = StatusBar
    
    Window.StatusDot = StatusDot
    Window.StatusText = StatusText
    Window.StatusCenter = StatusCenter
    Window.StatusRight = StatusRight
    Window.StatusBar = StatusBar
    
    -- SetStatusBar Method
    function Window:SetStatusBar(config)
        if config.Text then StatusText.Text = config.Text end
        if config.Build then StatusCenter.Text = config.Build end
        if config.Version then StatusRight.Text = config.Version end
        if config.Visible ~= nil then StatusBar.Visible = config.Visible end
        if config.Status then
            local colors = {
                ready = CurrentTheme.Success,
                loading = CurrentTheme.Warning,
                error = CurrentTheme.Error,
                offline = CurrentTheme.TextDim
            }
            StatusDot.BackgroundColor3 = colors[config.Status] or CurrentTheme.Success
        end
    end
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
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
    
    -- Toggle Keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == toggleKey then
            Window.Visible = not Window.Visible
            MainContainer.Visible = Window.Visible
        end
    end)
    
    -- Tab Creation
    function Window:CreateTab(options)
        options = options or {}
        local name = options.Name or "Tab"
        local icon = options.Icon or ""
        
        local Tab = {}
        Tab.Sections = {}
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.BackgroundColor3 = CurrentTheme.SurfaceHover
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 28)
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.Text = icon ~= "" and (icon .. "  " .. name) or name
        TabButton.TextColor3 = CurrentTheme.TextDim
        TabButton.TextSize = 11
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabList
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 4)
        TabButtonCorner.Parent = TabButton
        
        -- Active Indicator
        local ActiveIndicator = Instance.new("Frame")
        ActiveIndicator.Name = "ActiveIndicator"
        ActiveIndicator.BackgroundColor3 = CurrentTheme.Primary
        ActiveIndicator.BorderSizePixel = 0
        ActiveIndicator.Position = UDim2.new(0, 0, 0, 0)
        ActiveIndicator.Size = UDim2.new(0, 3, 1, 0)
        ActiveIndicator.Visible = false
        ActiveIndicator.Parent = TabButton
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 2)
        IndicatorCorner.Parent = ActiveIndicator
        
        -- Tab Content Container
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "_Content"
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Position = UDim2.new(0, 8, 0, 8)
        TabContent.Size = UDim2.new(1, -16, 1, -16)
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = CurrentTheme.Border
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentArea
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Parent = TabContent
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 16)
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.Indicator = ActiveIndicator
        
        -- Tab Selection
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.5}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.15)
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Content.Visible = false
                Window.CurrentTab.Indicator.Visible = false
                Window.CurrentTab.Button.TextColor3 = CurrentTheme.TextDim
                Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.15)
            end
            
            Window.CurrentTab = Tab
            TabContent.Visible = true
            ActiveIndicator.Visible = true
            TabButton.TextColor3 = CurrentTheme.Text
            Tween(TabButton, {BackgroundTransparency = 0}, 0.15)
        end)
        
        -- Auto-select first tab
        if #Window.Tabs == 0 then
            Window.CurrentTab = Tab
            TabContent.Visible = true
            ActiveIndicator.Visible = true
            TabButton.TextColor3 = CurrentTheme.Text
            TabButton.BackgroundTransparency = 0
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Section Creation
        function Tab:CreateSection(options)
            options = options or {}
            local sectionName = options.Name or "Section"
            
            local Section = {}
            Section.Elements = {}
            
            -- Section Container
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = sectionName
            SectionFrame.BackgroundColor3 = CurrentTheme.Surface
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Size = UDim2.new(1, 0, 0, 32)
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Parent = TabContent
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = SectionFrame
            
            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = CurrentTheme.Border
            SectionStroke.Thickness = 1
            SectionStroke.Parent = SectionFrame
            
            -- Section Header
            local SectionHeader = Instance.new("TextLabel")
            SectionHeader.Name = "Header"
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Position = UDim2.new(0, 10, 0, 0)
            SectionHeader.Size = UDim2.new(1, -20, 0, 28)
            SectionHeader.Font = Enum.Font.GothamBold
            SectionHeader.Text = sectionName
            SectionHeader.TextColor3 = CurrentTheme.Text
            SectionHeader.TextSize = 11
            SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
            SectionHeader.Parent = SectionFrame
            
            -- Section Content
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Content"
            SectionContent.BackgroundTransparency = 1
            SectionContent.Position = UDim2.new(0, 8, 0, 28)
            SectionContent.Size = UDim2.new(1, -16, 0, 0)
            SectionContent.AutomaticSize = Enum.AutomaticSize.Y
            SectionContent.Parent = SectionFrame
            
            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.Padding = UDim.new(0, 4)
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Parent = SectionContent
            
            local ContentPadding = Instance.new("UIPadding")
            ContentPadding.PaddingBottom = UDim.new(0, 8)
            ContentPadding.Parent = SectionContent
            
            Section.Frame = SectionFrame
            Section.Content = SectionContent
            
            -- Toggle
            function Section:CreateToggle(opts)
                opts = opts or {}
                local toggleName = opts.Name or "Toggle"
                local default = opts.Default or false
                local callback = opts.Callback or function() end
                
                local Toggle = { Value = default }
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = toggleName
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
                ToggleFrame.Parent = SectionContent
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
                ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.Text = toggleName
                ToggleLabel.TextColor3 = CurrentTheme.Text
                ToggleLabel.TextSize = 11
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame
                
                local ToggleButton = Instance.new("Frame")
                ToggleButton.Name = "Button"
                ToggleButton.BackgroundColor3 = default and CurrentTheme.Primary or CurrentTheme.SurfaceHover
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Position = UDim2.new(1, -38, 0.5, -8)
                ToggleButton.Size = UDim2.new(0, 38, 0, 16)
                ToggleButton.Parent = ToggleFrame
                
                local ToggleButtonCorner = Instance.new("UICorner")
                ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
                ToggleButtonCorner.Parent = ToggleButton
                
                local ToggleCircle = Instance.new("Frame")
                ToggleCircle.Name = "Circle"
                ToggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
                ToggleCircle.BorderSizePixel = 0
                ToggleCircle.Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                ToggleCircle.Size = UDim2.new(0, 12, 0, 12)
                ToggleCircle.Parent = ToggleButton
                
                local ToggleCircleCorner = Instance.new("UICorner")
                ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
                ToggleCircleCorner.Parent = ToggleCircle
                
                local ToggleClickArea = Instance.new("TextButton")
                ToggleClickArea.BackgroundTransparency = 1
                ToggleClickArea.Size = UDim2.new(1, 0, 1, 0)
                ToggleClickArea.Text = ""
                ToggleClickArea.Parent = ToggleFrame
                
                local function UpdateToggle()
                    Tween(ToggleButton, {BackgroundColor3 = Toggle.Value and CurrentTheme.Primary or CurrentTheme.SurfaceHover}, 0.2)
                    Tween(ToggleCircle, {Position = Toggle.Value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}, 0.2)
                    callback(Toggle.Value)
                end
                
                ToggleClickArea.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    UpdateToggle()
                end)
                
                function Toggle:Set(value)
                    Toggle.Value = value
                    UpdateToggle()
                end
                
                table.insert(Section.Elements, Toggle)
                return Toggle
            end
            
            -- Slider
            function Section:CreateSlider(opts)
                opts = opts or {}
                local sliderName = opts.Name or "Slider"
                local min = opts.Min or 0
                local max = opts.Max or 100
                local default = opts.Default or min
                local suffix = opts.Suffix or ""
                local callback = opts.Callback or function() end
                
                local Slider = { Value = default }
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = sliderName
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Size = UDim2.new(1, 0, 0, 36)
                SliderFrame.Parent = SectionContent
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Position = UDim2.new(0, 0, 0, 0)
                SliderLabel.Size = UDim2.new(0.7, 0, 0, 18)
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.Text = sliderName
                SliderLabel.TextColor3 = CurrentTheme.Text
                SliderLabel.TextSize = 11
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame
                
                local SliderValue = Instance.new("TextLabel")
                SliderValue.BackgroundTransparency = 1
                SliderValue.Position = UDim2.new(0.7, 0, 0, 0)
                SliderValue.Size = UDim2.new(0.3, 0, 0, 18)
                SliderValue.Font = Enum.Font.GothamMedium
                SliderValue.Text = tostring(default) .. suffix
                SliderValue.TextColor3 = CurrentTheme.Primary
                SliderValue.TextSize = 11
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Parent = SliderFrame
                
                local SliderBg = Instance.new("Frame")
                SliderBg.Name = "Background"
                SliderBg.BackgroundColor3 = CurrentTheme.SurfaceHover
                SliderBg.BorderSizePixel = 0
                SliderBg.Position = UDim2.new(0, 0, 0, 22)
                SliderBg.Size = UDim2.new(1, 0, 0, 10)
                SliderBg.Parent = SliderFrame
                
                local SliderBgCorner = Instance.new("UICorner")
                SliderBgCorner.CornerRadius = UDim.new(1, 0)
                SliderBgCorner.Parent = SliderBg
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.BackgroundColor3 = CurrentTheme.Primary
                SliderFill.BorderSizePixel = 0
                SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                SliderFill.Parent = SliderBg
                
                local SliderFillCorner = Instance.new("UICorner")
                SliderFillCorner.CornerRadius = UDim.new(1, 0)
                SliderFillCorner.Parent = SliderFill
                
                CreateGradient(SliderFill, {CurrentTheme.Primary, CurrentTheme.Secondary})
                
                local SliderKnob = Instance.new("Frame")
                SliderKnob.Name = "Knob"
                SliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
                SliderKnob.BorderSizePixel = 0
                SliderKnob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
                SliderKnob.Size = UDim2.new(0, 12, 0, 12)
                SliderKnob.ZIndex = 2
                SliderKnob.Parent = SliderBg
                
                local SliderKnobCorner = Instance.new("UICorner")
                SliderKnobCorner.CornerRadius = UDim.new(1, 0)
                SliderKnobCorner.Parent = SliderKnob
                
                local dragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    Slider.Value = math.floor(min + (max - min) * pos)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
                    SliderValue.Text = tostring(Slider.Value) .. suffix
                    callback(Slider.Value)
                end
                
                SliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                function Slider:Set(value)
                    Slider.Value = math.clamp(value, min, max)
                    local pos = (Slider.Value - min) / (max - min)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
                    SliderValue.Text = tostring(Slider.Value) .. suffix
                    callback(Slider.Value)
                end
                
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            -- Button
            function Section:CreateButton(opts)
                opts = opts or {}
                local buttonName = opts.Name or "Button"
                local callback = opts.Callback or function() end
                
                local Button = {}
                
                local ButtonFrame = Instance.new("TextButton")
                ButtonFrame.Name = buttonName
                ButtonFrame.BackgroundColor3 = CurrentTheme.Primary
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.Size = UDim2.new(1, 0, 0, 28)
                ButtonFrame.Font = Enum.Font.GothamMedium
                ButtonFrame.Text = buttonName
                ButtonFrame.TextColor3 = Color3.new(1, 1, 1)
                ButtonFrame.TextSize = 11
                ButtonFrame.AutoButtonColor = false
                ButtonFrame.Parent = SectionContent
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 4)
                ButtonCorner.Parent = ButtonFrame
                
                CreateGradient(ButtonFrame, {CurrentTheme.Primary, CurrentTheme.Secondary})
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundTransparency = 0.1}, 0.15)
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundTransparency = 0}, 0.15)
                end)
                
                ButtonFrame.MouseButton1Click:Connect(callback)
                
                table.insert(Section.Elements, Button)
                return Button
            end
            
            -- Dropdown
            function Section:CreateDropdown(opts)
                opts = opts or {}
                local dropdownName = opts.Name or "Dropdown"
                local options = opts.Options or {}
                local default = opts.Default or (options[1] or "")
                local callback = opts.Callback or function() end
                
                local Dropdown = { Value = default, Open = false }
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = dropdownName
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Size = UDim2.new(1, 0, 0, 48)
                DropdownFrame.ClipsDescendants = false
                DropdownFrame.ZIndex = 10
                DropdownFrame.Parent = SectionContent
                
                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Position = UDim2.new(0, 0, 0, 0)
                DropdownLabel.Size = UDim2.new(1, 0, 0, 18)
                DropdownLabel.Font = Enum.Font.Gotham
                DropdownLabel.Text = dropdownName
                DropdownLabel.TextColor3 = CurrentTheme.Text
                DropdownLabel.TextSize = 11
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.Parent = DropdownFrame
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Name = "Button"
                DropdownButton.BackgroundColor3 = CurrentTheme.SurfaceHover
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Position = UDim2.new(0, 0, 0, 20)
                DropdownButton.Size = UDim2.new(1, 0, 0, 26)
                DropdownButton.Font = Enum.Font.Gotham
                DropdownButton.Text = "  " .. default
                DropdownButton.TextColor3 = CurrentTheme.Text
                DropdownButton.TextSize = 11
                DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                DropdownButton.AutoButtonColor = false
                DropdownButton.ZIndex = 11
                DropdownButton.Parent = DropdownFrame
                
                local DropdownButtonCorner = Instance.new("UICorner")
                DropdownButtonCorner.CornerRadius = UDim.new(0, 4)
                DropdownButtonCorner.Parent = DropdownButton
                
                local DropdownButtonStroke = Instance.new("UIStroke")
                DropdownButtonStroke.Color = CurrentTheme.Border
                DropdownButtonStroke.Thickness = 1
                DropdownButtonStroke.Parent = DropdownButton
                
                local DropdownArrow = Instance.new("TextLabel")
                DropdownArrow.BackgroundTransparency = 1
                DropdownArrow.Position = UDim2.new(1, -20, 0, 0)
                DropdownArrow.Size = UDim2.new(0, 16, 1, 0)
                DropdownArrow.Font = Enum.Font.GothamBold
                DropdownArrow.Text = "▼"
                DropdownArrow.TextColor3 = CurrentTheme.TextDim
                DropdownArrow.TextSize = 8
                DropdownArrow.ZIndex = 12
                DropdownArrow.Parent = DropdownButton
                
                local OptionsContainer = Instance.new("Frame")
                OptionsContainer.Name = "Options"
                OptionsContainer.BackgroundColor3 = CurrentTheme.Surface
                OptionsContainer.BorderSizePixel = 0
                OptionsContainer.Position = UDim2.new(0, 0, 0, 48)
                OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
                OptionsContainer.ClipsDescendants = true
                OptionsContainer.Visible = false
                OptionsContainer.ZIndex = 50
                OptionsContainer.Parent = DropdownFrame
                
                local OptionsCorner = Instance.new("UICorner")
                OptionsCorner.CornerRadius = UDim.new(0, 4)
                OptionsCorner.Parent = OptionsContainer
                
                local OptionsStroke = Instance.new("UIStroke")
                OptionsStroke.Color = CurrentTheme.Border
                OptionsStroke.Thickness = 1
                OptionsStroke.Parent = OptionsContainer
                
                local OptionsLayout = Instance.new("UIListLayout")
                OptionsLayout.Padding = UDim.new(0, 2)
                OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionsLayout.Parent = OptionsContainer
                
                local OptionsPadding = Instance.new("UIPadding")
                OptionsPadding.PaddingTop = UDim.new(0, 4)
                OptionsPadding.PaddingBottom = UDim.new(0, 4)
                OptionsPadding.PaddingLeft = UDim.new(0, 4)
                OptionsPadding.PaddingRight = UDim.new(0, 4)
                OptionsPadding.Parent = OptionsContainer
                
                local function CreateOption(optionText)
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Name = optionText
                    OptionButton.BackgroundColor3 = CurrentTheme.SurfaceHover
                    OptionButton.BackgroundTransparency = 1
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Size = UDim2.new(1, 0, 0, 24)
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.Text = optionText
                    OptionButton.TextColor3 = CurrentTheme.Text
                    OptionButton.TextSize = 11
                    OptionButton.AutoButtonColor = false
                    OptionButton.ZIndex = 51
                    OptionButton.Parent = OptionsContainer
                    
                    local OptionCorner = Instance.new("UICorner")
                    OptionCorner.CornerRadius = UDim.new(0, 4)
                    OptionCorner.Parent = OptionButton
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 0}, 0.1)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 1}, 0.1)
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Dropdown.Value = optionText
                        DropdownButton.Text = "  " .. optionText
                        Dropdown.Open = false
                        OptionsContainer.Visible = false
                        Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        DropdownArrow.Text = "▼"
                        callback(optionText)
                    end)
                    
                    return OptionButton
                end
                
                for _, opt in ipairs(options) do
                    CreateOption(opt)
                end
                
                local totalHeight = #options * 26 + 8
                
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    OptionsContainer.Visible = true
                    if Dropdown.Open then
                        DropdownArrow.Text = "▲"
                        Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.15)
                    else
                        DropdownArrow.Text = "▼"
                        Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        task.delay(0.15, function()
                            if not Dropdown.Open then
                                OptionsContainer.Visible = false
                            end
                        end)
                    end
                end)
                
                function Dropdown:Set(value)
                    if table.find(options, value) then
                        Dropdown.Value = value
                        DropdownButton.Text = "  " .. value
                        callback(value)
                    end
                end
                
                function Dropdown:Refresh(newOptions, newDefault)
                    options = newOptions
                    for _, child in ipairs(OptionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    for _, opt in ipairs(options) do
                        CreateOption(opt)
                    end
                    totalHeight = #options * 26 + 8
                    if newDefault then
                        Dropdown:Set(newDefault)
                    end
                end
                
                table.insert(Section.Elements, Dropdown)
                return Dropdown
            end
            
            -- Multi Dropdown
            function Section:CreateMultiDropdown(opts)
                opts = opts or {}
                local dropdownName = opts.Name or "Multi Dropdown"
                local options = opts.Options or {}
                local default = opts.Default or {}
                local callback = opts.Callback or function() end
                
                local MultiDropdown = { Values = {}, Open = false }
                for _, v in ipairs(default) do
                    MultiDropdown.Values[v] = true
                end
                
                local function GetDisplayText()
                    local selected = {}
                    for opt, isSelected in pairs(MultiDropdown.Values) do
                        if isSelected then
                            table.insert(selected, opt)
                        end
                    end
                    if #selected == 0 then
                        return "None"
                    elseif #selected <= 2 then
                        return table.concat(selected, ", ")
                    else
                        return #selected .. " selected"
                    end
                end
                
                local MultiDropdownFrame = Instance.new("Frame")
                MultiDropdownFrame.Name = dropdownName
                MultiDropdownFrame.BackgroundTransparency = 1
                MultiDropdownFrame.Size = UDim2.new(1, 0, 0, 48)
                MultiDropdownFrame.ClipsDescendants = false
                MultiDropdownFrame.ZIndex = 10
                MultiDropdownFrame.Parent = SectionContent
                
                local MultiDropdownLabel = Instance.new("TextLabel")
                MultiDropdownLabel.BackgroundTransparency = 1
                MultiDropdownLabel.Position = UDim2.new(0, 0, 0, 0)
                MultiDropdownLabel.Size = UDim2.new(1, 0, 0, 18)
                MultiDropdownLabel.Font = Enum.Font.Gotham
                MultiDropdownLabel.Text = dropdownName
                MultiDropdownLabel.TextColor3 = CurrentTheme.Text
                MultiDropdownLabel.TextSize = 11
                MultiDropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                MultiDropdownLabel.Parent = MultiDropdownFrame
                
                local MultiDropdownButton = Instance.new("TextButton")
                MultiDropdownButton.Name = "Button"
                MultiDropdownButton.BackgroundColor3 = CurrentTheme.SurfaceHover
                MultiDropdownButton.BorderSizePixel = 0
                MultiDropdownButton.Position = UDim2.new(0, 0, 0, 20)
                MultiDropdownButton.Size = UDim2.new(1, 0, 0, 26)
                MultiDropdownButton.Font = Enum.Font.Gotham
                MultiDropdownButton.Text = "  " .. GetDisplayText()
                MultiDropdownButton.TextColor3 = CurrentTheme.Text
                MultiDropdownButton.TextSize = 11
                MultiDropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                MultiDropdownButton.AutoButtonColor = false
                MultiDropdownButton.ZIndex = 11
                MultiDropdownButton.Parent = MultiDropdownFrame
                
                local MultiDropdownButtonCorner = Instance.new("UICorner")
                MultiDropdownButtonCorner.CornerRadius = UDim.new(0, 4)
                MultiDropdownButtonCorner.Parent = MultiDropdownButton
                
                local MultiDropdownButtonStroke = Instance.new("UIStroke")
                MultiDropdownButtonStroke.Color = CurrentTheme.Border
                MultiDropdownButtonStroke.Thickness = 1
                MultiDropdownButtonStroke.Parent = MultiDropdownButton
                
                local MultiDropdownArrow = Instance.new("TextLabel")
                MultiDropdownArrow.BackgroundTransparency = 1
                MultiDropdownArrow.Position = UDim2.new(1, -20, 0, 0)
                MultiDropdownArrow.Size = UDim2.new(0, 16, 1, 0)
                MultiDropdownArrow.Font = Enum.Font.GothamBold
                MultiDropdownArrow.Text = "▼"
                MultiDropdownArrow.TextColor3 = CurrentTheme.TextDim
                MultiDropdownArrow.TextSize = 8
                MultiDropdownArrow.ZIndex = 12
                MultiDropdownArrow.Parent = MultiDropdownButton
                
                local MultiOptionsContainer = Instance.new("Frame")
                MultiOptionsContainer.Name = "Options"
                MultiOptionsContainer.BackgroundColor3 = CurrentTheme.Surface
                MultiOptionsContainer.BorderSizePixel = 0
                MultiOptionsContainer.Position = UDim2.new(0, 0, 0, 48)
                MultiOptionsContainer.Size = UDim2.new(1, 0, 0, 0)
                MultiOptionsContainer.ClipsDescendants = true
                MultiOptionsContainer.Visible = false
                MultiOptionsContainer.ZIndex = 50
                MultiOptionsContainer.Parent = MultiDropdownFrame
                
                local MultiOptionsCorner = Instance.new("UICorner")
                MultiOptionsCorner.CornerRadius = UDim.new(0, 4)
                MultiOptionsCorner.Parent = MultiOptionsContainer
                
                local MultiOptionsStroke = Instance.new("UIStroke")
                MultiOptionsStroke.Color = CurrentTheme.Border
                MultiOptionsStroke.Thickness = 1
                MultiOptionsStroke.Parent = MultiOptionsContainer
                
                local MultiOptionsLayout = Instance.new("UIListLayout")
                MultiOptionsLayout.Padding = UDim.new(0, 2)
                MultiOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                MultiOptionsLayout.Parent = MultiOptionsContainer
                
                local MultiOptionsPadding = Instance.new("UIPadding")
                MultiOptionsPadding.PaddingTop = UDim.new(0, 4)
                MultiOptionsPadding.PaddingBottom = UDim.new(0, 4)
                MultiOptionsPadding.PaddingLeft = UDim.new(0, 4)
                MultiOptionsPadding.PaddingRight = UDim.new(0, 4)
                MultiOptionsPadding.Parent = MultiOptionsContainer
                
                local function CreateMultiOption(optionText)
                    local OptionFrame = Instance.new("TextButton")
                    OptionFrame.Name = optionText
                    OptionFrame.BackgroundColor3 = CurrentTheme.SurfaceHover
                    OptionFrame.BackgroundTransparency = 1
                    OptionFrame.BorderSizePixel = 0
                    OptionFrame.Size = UDim2.new(1, 0, 0, 24)
                    OptionFrame.Font = Enum.Font.Gotham
                    OptionFrame.Text = ""
                    OptionFrame.AutoButtonColor = false
                    OptionFrame.ZIndex = 51
                    OptionFrame.Parent = MultiOptionsContainer
                    
                    local OptionCorner = Instance.new("UICorner")
                    OptionCorner.CornerRadius = UDim.new(0, 4)
                    OptionCorner.Parent = OptionFrame
                    
                    local Checkbox = Instance.new("Frame")
                    Checkbox.BackgroundColor3 = MultiDropdown.Values[optionText] and CurrentTheme.Primary or CurrentTheme.SurfaceHover
                    Checkbox.BorderSizePixel = 0
                    Checkbox.Position = UDim2.new(0, 4, 0.5, -7)
                    Checkbox.Size = UDim2.new(0, 14, 0, 14)
                    Checkbox.ZIndex = 52
                    Checkbox.Parent = OptionFrame
                    
                    local CheckboxCorner = Instance.new("UICorner")
                    CheckboxCorner.CornerRadius = UDim.new(0, 3)
                    CheckboxCorner.Parent = Checkbox
                    
                    local CheckboxStroke = Instance.new("UIStroke")
                    CheckboxStroke.Color = CurrentTheme.Border
                    CheckboxStroke.Thickness = 1
                    CheckboxStroke.Parent = Checkbox
                    
                    local CheckMark = Instance.new("TextLabel")
                    CheckMark.BackgroundTransparency = 1
                    CheckMark.Size = UDim2.new(1, 0, 1, 0)
                    CheckMark.Font = Enum.Font.GothamBold
                    CheckMark.Text = MultiDropdown.Values[optionText] and "✓" or ""
                    CheckMark.TextColor3 = Color3.new(1, 1, 1)
                    CheckMark.TextSize = 10
                    CheckMark.ZIndex = 53
                    CheckMark.Parent = Checkbox
                    
                    local OptionLabel = Instance.new("TextLabel")
                    OptionLabel.BackgroundTransparency = 1
                    OptionLabel.Position = UDim2.new(0, 24, 0, 0)
                    OptionLabel.Size = UDim2.new(1, -28, 1, 0)
                    OptionLabel.Font = Enum.Font.Gotham
                    OptionLabel.Text = optionText
                    OptionLabel.TextColor3 = CurrentTheme.Text
                    OptionLabel.TextSize = 11
                    OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                    OptionLabel.ZIndex = 52
                    OptionLabel.Parent = OptionFrame
                    
                    OptionFrame.MouseEnter:Connect(function()
                        Tween(OptionFrame, {BackgroundTransparency = 0}, 0.1)
                    end)
                    
                    OptionFrame.MouseLeave:Connect(function()
                        Tween(OptionFrame, {BackgroundTransparency = 1}, 0.1)
                    end)
                    
                    OptionFrame.MouseButton1Click:Connect(function()
                        MultiDropdown.Values[optionText] = not MultiDropdown.Values[optionText]
                        Checkbox.BackgroundColor3 = MultiDropdown.Values[optionText] and CurrentTheme.Primary or CurrentTheme.SurfaceHover
                        CheckMark.Text = MultiDropdown.Values[optionText] and "✓" or ""
                        MultiDropdownButton.Text = "  " .. GetDisplayText()
                        
                        local selected = {}
                        for opt, isSelected in pairs(MultiDropdown.Values) do
                            if isSelected then
                                table.insert(selected, opt)
                            end
                        end
                        callback(selected)
                    end)
                    
                    return OptionFrame
                end
                
                for _, opt in ipairs(options) do
                    CreateMultiOption(opt)
                end
                
                local totalHeight = #options * 26 + 8
                
                MultiDropdownButton.MouseButton1Click:Connect(function()
                    MultiDropdown.Open = not MultiDropdown.Open
                    MultiOptionsContainer.Visible = true
                    if MultiDropdown.Open then
                        MultiDropdownArrow.Text = "▲"
                        Tween(MultiOptionsContainer, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.15)
                    else
                        MultiDropdownArrow.Text = "▼"
                        Tween(MultiOptionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        task.delay(0.15, function()
                            if not MultiDropdown.Open then
                                MultiOptionsContainer.Visible = false
                            end
                        end)
                    end
                end)
                
                function MultiDropdown:Set(values)
                    MultiDropdown.Values = {}
                    for _, v in ipairs(values) do
                        MultiDropdown.Values[v] = true
                    end
                    MultiDropdownButton.Text = "  " .. GetDisplayText()
                    -- Update checkboxes
                    for _, child in ipairs(MultiOptionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            local checkbox = child:FindFirstChild("Frame")
                            local checkmark = checkbox and checkbox:FindFirstChild("TextLabel")
                            if checkbox and checkmark then
                                local isSelected = MultiDropdown.Values[child.Name] or false
                                checkbox.BackgroundColor3 = isSelected and CurrentTheme.Primary or CurrentTheme.SurfaceHover
                                checkmark.Text = isSelected and "✓" or ""
                            end
                        end
                    end
                    callback(values)
                end
                
                function MultiDropdown:Get()
                    local selected = {}
                    for opt, isSelected in pairs(MultiDropdown.Values) do
                        if isSelected then
                            table.insert(selected, opt)
                        end
                    end
                    return selected
                end
                
                table.insert(Section.Elements, MultiDropdown)
                return MultiDropdown
            end
            
            -- Input
            function Section:CreateInput(opts)
                opts = opts or {}
                local inputName = opts.Name or "Input"
                local placeholder = opts.Placeholder or "Enter text..."
                local default = opts.Default or ""
                local callback = opts.Callback or function() end
                
                local Input = { Value = default }
                
                local InputFrame = Instance.new("Frame")
                InputFrame.Name = inputName
                InputFrame.BackgroundTransparency = 1
                InputFrame.Size = UDim2.new(1, 0, 0, 48)
                InputFrame.Parent = SectionContent
                
                local InputLabel = Instance.new("TextLabel")
                InputLabel.BackgroundTransparency = 1
                InputLabel.Position = UDim2.new(0, 0, 0, 0)
                InputLabel.Size = UDim2.new(1, 0, 0, 18)
                InputLabel.Font = Enum.Font.Gotham
                InputLabel.Text = inputName
                InputLabel.TextColor3 = CurrentTheme.Text
                InputLabel.TextSize = 11
                InputLabel.TextXAlignment = Enum.TextXAlignment.Left
                InputLabel.Parent = InputFrame
                
                local InputBox = Instance.new("TextBox")
                InputBox.Name = "TextBox"
                InputBox.BackgroundColor3 = CurrentTheme.SurfaceHover
                InputBox.BorderSizePixel = 0
                InputBox.Position = UDim2.new(0, 0, 0, 20)
                InputBox.Size = UDim2.new(1, 0, 0, 26)
                InputBox.Font = Enum.Font.Gotham
                InputBox.PlaceholderText = placeholder
                InputBox.PlaceholderColor3 = CurrentTheme.TextDim
                InputBox.Text = default
                InputBox.TextColor3 = CurrentTheme.Text
                InputBox.TextSize = 11
                InputBox.TextXAlignment = Enum.TextXAlignment.Left
                InputBox.ClearTextOnFocus = false
                InputBox.Parent = InputFrame
                
                local InputPadding = Instance.new("UIPadding")
                InputPadding.PaddingLeft = UDim.new(0, 8)
                InputPadding.PaddingRight = UDim.new(0, 8)
                InputPadding.Parent = InputBox
                
                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 4)
                InputCorner.Parent = InputBox
                
                local InputStroke = Instance.new("UIStroke")
                InputStroke.Color = CurrentTheme.Border
                InputStroke.Thickness = 1
                InputStroke.Parent = InputBox
                
                InputBox.Focused:Connect(function()
                    Tween(InputStroke, {Color = CurrentTheme.Primary}, 0.15)
                end)
                
                InputBox.FocusLost:Connect(function(enterPressed)
                    Tween(InputStroke, {Color = CurrentTheme.Border}, 0.15)
                    Input.Value = InputBox.Text
                    callback(InputBox.Text, enterPressed)
                end)
                
                function Input:Set(value)
                    Input.Value = value
                    InputBox.Text = value
                end
                
                table.insert(Section.Elements, Input)
                return Input
            end
            
            -- Keybind
            function Section:CreateKeybind(opts)
                opts = opts or {}
                local keybindName = opts.Name or "Keybind"
                local default = opts.Default or Enum.KeyCode.Unknown
                local callback = opts.Callback or function() end
                
                local Keybind = { Value = default, Listening = false }
                
                local KeybindFrame = Instance.new("Frame")
                KeybindFrame.Name = keybindName
                KeybindFrame.BackgroundTransparency = 1
                KeybindFrame.Size = UDim2.new(1, 0, 0, 24)
                KeybindFrame.Parent = SectionContent
                
                local KeybindLabel = Instance.new("TextLabel")
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.Position = UDim2.new(0, 0, 0, 0)
                KeybindLabel.Size = UDim2.new(1, -70, 1, 0)
                KeybindLabel.Font = Enum.Font.Gotham
                KeybindLabel.Text = keybindName
                KeybindLabel.TextColor3 = CurrentTheme.Text
                KeybindLabel.TextSize = 11
                KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                KeybindLabel.Parent = KeybindFrame
                
                local KeybindButton = Instance.new("TextButton")
                KeybindButton.Name = "Button"
                KeybindButton.BackgroundColor3 = CurrentTheme.SurfaceHover
                KeybindButton.BorderSizePixel = 0
                KeybindButton.Position = UDim2.new(1, -65, 0.5, -11)
                KeybindButton.Size = UDim2.new(0, 65, 0, 22)
                KeybindButton.Font = Enum.Font.GothamMedium
                KeybindButton.Text = default.Name or "None"
                KeybindButton.TextColor3 = CurrentTheme.TextDim
                KeybindButton.TextSize = 10
                KeybindButton.AutoButtonColor = false
                KeybindButton.Parent = KeybindFrame
                
                local KeybindButtonCorner = Instance.new("UICorner")
                KeybindButtonCorner.CornerRadius = UDim.new(0, 4)
                KeybindButtonCorner.Parent = KeybindButton
                
                local KeybindButtonStroke = Instance.new("UIStroke")
                KeybindButtonStroke.Color = CurrentTheme.Border
                KeybindButtonStroke.Thickness = 1
                KeybindButtonStroke.Parent = KeybindButton
                
                KeybindButton.MouseButton1Click:Connect(function()
                    Keybind.Listening = true
                    KeybindButton.Text = "..."
                    Tween(KeybindButtonStroke, {Color = CurrentTheme.Primary}, 0.15)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if Keybind.Listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Keybind.Value = input.KeyCode
                            KeybindButton.Text = input.KeyCode.Name
                            Keybind.Listening = false
                            Tween(KeybindButtonStroke, {Color = CurrentTheme.Border}, 0.15)
                        end
                    else
                        if input.KeyCode == Keybind.Value and not gameProcessed then
                            callback(Keybind.Value)
                        end
                    end
                end)
                
                function Keybind:Set(key)
                    Keybind.Value = key
                    KeybindButton.Text = key.Name
                end
                
                table.insert(Section.Elements, Keybind)
                return Keybind
            end
            
            -- ColorPicker (完整HSV + Alpha)
            function Section:CreateColorPicker(opts)
                opts = opts or {}
                local pickerName = opts.Name or "Color"
                local default = opts.Default or Color3.fromRGB(134, 148, 255)
                local defaultAlpha = opts.Alpha or 1
                local callback = opts.Callback or function() end
                
                local h, s, v = RGBtoHSV(default)
                local ColorPicker = { Color = default, Alpha = defaultAlpha, H = h, S = s, V = v, Open = false }
                
                local PickerFrame = Instance.new("Frame")
                PickerFrame.Name = pickerName
                PickerFrame.BackgroundTransparency = 1
                PickerFrame.Size = UDim2.new(1, 0, 0, 24)
                PickerFrame.ClipsDescendants = false
                PickerFrame.ZIndex = 20
                PickerFrame.Parent = SectionContent
                
                local PickerLabel = Instance.new("TextLabel")
                PickerLabel.BackgroundTransparency = 1
                PickerLabel.Position = UDim2.new(0, 0, 0, 0)
                PickerLabel.Size = UDim2.new(1, -50, 1, 0)
                PickerLabel.Font = Enum.Font.Gotham
                PickerLabel.Text = pickerName
                PickerLabel.TextColor3 = CurrentTheme.Text
                PickerLabel.TextSize = 11
                PickerLabel.TextXAlignment = Enum.TextXAlignment.Left
                PickerLabel.Parent = PickerFrame
                
                local ColorPreview = Instance.new("TextButton")
                ColorPreview.Name = "Preview"
                ColorPreview.BackgroundColor3 = default
                ColorPreview.BorderSizePixel = 0
                ColorPreview.Position = UDim2.new(1, -40, 0.5, -9)
                ColorPreview.Size = UDim2.new(0, 40, 0, 18)
                ColorPreview.Text = ""
                ColorPreview.AutoButtonColor = false
                ColorPreview.Parent = PickerFrame
                
                local PreviewCorner = Instance.new("UICorner")
                PreviewCorner.CornerRadius = UDim.new(0, 4)
                PreviewCorner.Parent = ColorPreview
                
                local PreviewStroke = Instance.new("UIStroke")
                PreviewStroke.Color = CurrentTheme.Border
                PreviewStroke.Thickness = 1
                PreviewStroke.Parent = ColorPreview
                
                -- Color Picker Panel
                local PickerPanel = Instance.new("Frame")
                PickerPanel.Name = "Panel"
                PickerPanel.BackgroundColor3 = CurrentTheme.Surface
                PickerPanel.BorderSizePixel = 0
                PickerPanel.Position = UDim2.new(1, -200, 0, 28)
                PickerPanel.Size = UDim2.new(0, 200, 0, 170)
                PickerPanel.Visible = false
                PickerPanel.ZIndex = 100
                PickerPanel.Parent = PickerFrame
                
                local PanelCorner = Instance.new("UICorner")
                PanelCorner.CornerRadius = UDim.new(0, 6)
                PanelCorner.Parent = PickerPanel
                
                local PanelStroke = Instance.new("UIStroke")
                PanelStroke.Color = CurrentTheme.Border
                PanelStroke.Thickness = 1
                PanelStroke.Parent = PickerPanel
                
                -- SV Picker (主色彩区域)
                local SVPicker = Instance.new("ImageLabel")
                SVPicker.Name = "SVPicker"
                SVPicker.BackgroundColor3 = HSVtoRGB(h, 1, 1)
                SVPicker.BorderSizePixel = 0
                SVPicker.Position = UDim2.new(0, 8, 0, 8)
                SVPicker.Size = UDim2.new(1, -50, 0, 100)
                SVPicker.Image = "rbxassetid://4155801252" -- 白到透明渐变
                SVPicker.ZIndex = 101
                SVPicker.Parent = PickerPanel
                
                local SVPickerCorner = Instance.new("UICorner")
                SVPickerCorner.CornerRadius = UDim.new(0, 4)
                SVPickerCorner.Parent = SVPicker
                
                -- 黑色渐变叠加层
                local SVBlack = Instance.new("ImageLabel")
                SVBlack.Name = "BlackOverlay"
                SVBlack.BackgroundTransparency = 1
                SVBlack.Size = UDim2.new(1, 0, 1, 0)
                SVBlack.Image = "rbxassetid://4155801252"
                SVBlack.ImageColor3 = Color3.new(0, 0, 0)
                SVBlack.Rotation = -90
                SVBlack.ZIndex = 102
                SVBlack.Parent = SVPicker
                
                local SVCursor = Instance.new("Frame")
                SVCursor.Name = "Cursor"
                SVCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                SVCursor.BorderSizePixel = 0
                SVCursor.Position = UDim2.new(s, -5, 1 - v, -5)
                SVCursor.Size = UDim2.new(0, 10, 0, 10)
                SVCursor.ZIndex = 103
                SVCursor.Parent = SVPicker
                
                local SVCursorCorner = Instance.new("UICorner")
                SVCursorCorner.CornerRadius = UDim.new(1, 0)
                SVCursorCorner.Parent = SVCursor
                
                local SVCursorStroke = Instance.new("UIStroke")
                SVCursorStroke.Color = Color3.new(0, 0, 0)
                SVCursorStroke.Thickness = 1
                SVCursorStroke.Parent = SVCursor
                
                -- Hue Slider (色相条)
                local HueSlider = Instance.new("Frame")
                HueSlider.Name = "HueSlider"
                HueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
                HueSlider.BorderSizePixel = 0
                HueSlider.Position = UDim2.new(1, -34, 0, 8)
                HueSlider.Size = UDim2.new(0, 18, 0, 100)
                HueSlider.ZIndex = 101
                HueSlider.Parent = PickerPanel
                
                local HueCorner = Instance.new("UICorner")
                HueCorner.CornerRadius = UDim.new(0, 4)
                HueCorner.Parent = HueSlider
                
                local HueGradient = Instance.new("UIGradient")
                HueGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })
                HueGradient.Rotation = 90
                HueGradient.Parent = HueSlider
                
                local HueCursor = Instance.new("Frame")
                HueCursor.Name = "Cursor"
                HueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                HueCursor.BorderSizePixel = 0
                HueCursor.Position = UDim2.new(0, -2, h, -3)
                HueCursor.Size = UDim2.new(1, 4, 0, 6)
                HueCursor.ZIndex = 102
                HueCursor.Parent = HueSlider
                
                local HueCursorCorner = Instance.new("UICorner")
                HueCursorCorner.CornerRadius = UDim.new(0, 2)
                HueCursorCorner.Parent = HueCursor
                
                local HueCursorStroke = Instance.new("UIStroke")
                HueCursorStroke.Color = Color3.new(0, 0, 0)
                HueCursorStroke.Thickness = 1
                HueCursorStroke.Parent = HueCursor
                
                -- Alpha Slider
                local AlphaSlider = Instance.new("Frame")
                AlphaSlider.Name = "AlphaSlider"
                AlphaSlider.BackgroundColor3 = Color3.new(1, 1, 1)
                AlphaSlider.BorderSizePixel = 0
                AlphaSlider.Position = UDim2.new(0, 8, 0, 114)
                AlphaSlider.Size = UDim2.new(1, -50, 0, 14)
                AlphaSlider.ZIndex = 101
                AlphaSlider.Parent = PickerPanel
                
                local AlphaCorner = Instance.new("UICorner")
                AlphaCorner.CornerRadius = UDim.new(0, 4)
                AlphaCorner.Parent = AlphaSlider
                
                local AlphaGradient = Instance.new("UIGradient")
                AlphaGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                    ColorSequenceKeypoint.new(1, default)
                })
                AlphaGradient.Parent = AlphaSlider
                
                local AlphaCursor = Instance.new("Frame")
                AlphaCursor.Name = "Cursor"
                AlphaCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                AlphaCursor.BorderSizePixel = 0
                AlphaCursor.Position = UDim2.new(defaultAlpha, -3, 0, -2)
                AlphaCursor.Size = UDim2.new(0, 6, 1, 4)
                AlphaCursor.ZIndex = 102
                AlphaCursor.Parent = AlphaSlider
                
                local AlphaCursorCorner = Instance.new("UICorner")
                AlphaCursorCorner.CornerRadius = UDim.new(0, 2)
                AlphaCursorCorner.Parent = AlphaCursor
                
                local AlphaCursorStroke = Instance.new("UIStroke")
                AlphaCursorStroke.Color = Color3.new(0, 0, 0)
                AlphaCursorStroke.Thickness = 1
                AlphaCursorStroke.Parent = AlphaCursor
                
                -- HEX Display
                local HexDisplay = Instance.new("TextLabel")
                HexDisplay.Name = "Hex"
                HexDisplay.BackgroundColor3 = CurrentTheme.SurfaceHover
                HexDisplay.BorderSizePixel = 0
                HexDisplay.Position = UDim2.new(0, 8, 0, 136)
                HexDisplay.Size = UDim2.new(1, -50, 0, 24)
                HexDisplay.Font = Enum.Font.GothamMedium
                HexDisplay.Text = ColorToHex(default)
                HexDisplay.TextColor3 = CurrentTheme.Text
                HexDisplay.TextSize = 11
                HexDisplay.ZIndex = 101
                HexDisplay.Parent = PickerPanel
                
                local HexCorner = Instance.new("UICorner")
                HexCorner.CornerRadius = UDim.new(0, 4)
                HexCorner.Parent = HexDisplay
                
                -- Alpha Value Display
                local AlphaDisplay = Instance.new("TextLabel")
                AlphaDisplay.Name = "AlphaValue"
                AlphaDisplay.BackgroundColor3 = CurrentTheme.SurfaceHover
                AlphaDisplay.BorderSizePixel = 0
                AlphaDisplay.Position = UDim2.new(1, -34, 0, 136)
                AlphaDisplay.Size = UDim2.new(0, 26, 0, 24)
                AlphaDisplay.Font = Enum.Font.GothamMedium
                AlphaDisplay.Text = math.floor(defaultAlpha * 100) .. "%"
                AlphaDisplay.TextColor3 = CurrentTheme.Text
                AlphaDisplay.TextSize = 9
                AlphaDisplay.ZIndex = 101
                AlphaDisplay.Parent = PickerPanel
                
                local AlphaDisplayCorner = Instance.new("UICorner")
                AlphaDisplayCorner.CornerRadius = UDim.new(0, 4)
                AlphaDisplayCorner.Parent = AlphaDisplay
                
                local function UpdateColor()
                    ColorPicker.Color = HSVtoRGB(ColorPicker.H, ColorPicker.S, ColorPicker.V)
                    ColorPreview.BackgroundColor3 = ColorPicker.Color
                    SVPicker.BackgroundColor3 = HSVtoRGB(ColorPicker.H, 1, 1)
                    AlphaGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, ColorPicker.Color)
                    })
                    HexDisplay.Text = ColorToHex(ColorPicker.Color)
                    AlphaDisplay.Text = math.floor(ColorPicker.Alpha * 100) .. "%"
                    callback(ColorPicker.Color, ColorPicker.Alpha)
                end
                
                ColorPreview.MouseButton1Click:Connect(function()
                    ColorPicker.Open = not ColorPicker.Open
                    PickerPanel.Visible = ColorPicker.Open
                end)
                
                -- SV Picker Interaction
                local svDragging = false
                SVPicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = true
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relX = math.clamp((input.Position.X - SVPicker.AbsolutePosition.X) / SVPicker.AbsoluteSize.X, 0, 1)
                        local relY = math.clamp((input.Position.Y - SVPicker.AbsolutePosition.Y) / SVPicker.AbsoluteSize.Y, 0, 1)
                        ColorPicker.S = relX
                        ColorPicker.V = 1 - relY
                        SVCursor.Position = UDim2.new(relX, -5, relY, -5)
                        UpdateColor()
                    end
                end)
                
                -- Hue Slider Interaction
                local hueDragging = false
                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = true
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relY = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                        ColorPicker.H = relY
                        HueCursor.Position = UDim2.new(0, -2, relY, -3)
                        UpdateColor()
                    end
                end)
                
                -- Alpha Slider Interaction
                local alphaDragging = false
                AlphaSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        alphaDragging = true
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if alphaDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relX = math.clamp((input.Position.X - AlphaSlider.AbsolutePosition.X) / AlphaSlider.AbsoluteSize.X, 0, 1)
                        ColorPicker.Alpha = relX
                        AlphaCursor.Position = UDim2.new(relX, -3, 0, -2)
                        UpdateColor()
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = false
                        hueDragging = false
                        alphaDragging = false
                    end
                end)
                
                function ColorPicker:Set(color, alpha)
                    ColorPicker.Color = color
                    ColorPicker.Alpha = alpha or ColorPicker.Alpha
                    ColorPicker.H, ColorPicker.S, ColorPicker.V = RGBtoHSV(color)
                    SVCursor.Position = UDim2.new(ColorPicker.S, -5, 1 - ColorPicker.V, -5)
                    HueCursor.Position = UDim2.new(0, -2, ColorPicker.H, -3)
                    AlphaCursor.Position = UDim2.new(ColorPicker.Alpha, -3, 0, -2)
                    UpdateColor()
                end
                
                table.insert(Section.Elements, ColorPicker)
                return ColorPicker
            end
            
            -- Label
            function Section:CreateLabel(text)
                local Label = {}
                
                local LabelFrame = Instance.new("TextLabel")
                LabelFrame.Name = "Label"
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Size = UDim2.new(1, 0, 0, 20)
                LabelFrame.Font = Enum.Font.Gotham
                LabelFrame.Text = text
                LabelFrame.TextColor3 = CurrentTheme.TextDim
                LabelFrame.TextSize = 11
                LabelFrame.TextXAlignment = Enum.TextXAlignment.Left
                LabelFrame.Parent = SectionContent
                
                function Label:Set(newText)
                    LabelFrame.Text = newText
                end
                
                table.insert(Section.Elements, Label)
                return Label
            end
            
            -- Separator
            function Section:CreateSeparator()
                local Separator = Instance.new("Frame")
                Separator.Name = "Separator"
                Separator.BackgroundColor3 = CurrentTheme.Border
                Separator.BorderSizePixel = 0
                Separator.Size = UDim2.new(1, 0, 0, 1)
                Separator.Parent = SectionContent
                
                return Separator
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        return Tab
    end
    
    -- Notification
    function Window:Notify(opts)
        opts = opts or {}
        local title = opts.Title or "Notification"
        local message = opts.Message or ""
        local duration = opts.Duration or 4
        local notifType = opts.Type or "Info"
        
        local typeColors = {
            Success = CurrentTheme.Success,
            Error = CurrentTheme.Error,
            Warning = CurrentTheme.Warning,
            Info = CurrentTheme.Primary
        }
        
        local NotifContainer = ScreenGui:FindFirstChild("NotifContainer")
        if not NotifContainer then
            NotifContainer = Instance.new("Frame")
            NotifContainer.Name = "NotifContainer"
            NotifContainer.BackgroundTransparency = 1
            NotifContainer.Position = UDim2.new(1, -280, 0, 20)
            NotifContainer.Size = UDim2.new(0, 260, 1, -40)
            NotifContainer.Parent = ScreenGui
            
            local NotifLayout = Instance.new("UIListLayout")
            NotifLayout.Padding = UDim.new(0, 8)
            NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
            NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            NotifLayout.Parent = NotifContainer
        end
        
        local Notif = Instance.new("Frame")
        Notif.Name = "Notification"
        Notif.BackgroundColor3 = CurrentTheme.Surface
        Notif.BorderSizePixel = 0
        Notif.Size = UDim2.new(1, 0, 0, 60)
        Notif.ClipsDescendants = true
        Notif.Parent = NotifContainer
        
        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 6)
        NotifCorner.Parent = Notif
        
        local NotifStroke = Instance.new("UIStroke")
        NotifStroke.Color = CurrentTheme.Border
        NotifStroke.Thickness = 1
        NotifStroke.Parent = Notif
        
        local NotifAccent = Instance.new("Frame")
        NotifAccent.BackgroundColor3 = typeColors[notifType] or CurrentTheme.Primary
        NotifAccent.BorderSizePixel = 0
        NotifAccent.Size = UDim2.new(0, 3, 1, 0)
        NotifAccent.Parent = Notif
        
        local NotifTitle = Instance.new("TextLabel")
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.Position = UDim2.new(0, 14, 0, 8)
        NotifTitle.Size = UDim2.new(1, -20, 0, 18)
        NotifTitle.Font = Enum.Font.GothamBold
        NotifTitle.Text = title
        NotifTitle.TextColor3 = CurrentTheme.Text
        NotifTitle.TextSize = 12
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
        NotifTitle.Parent = Notif
        
        local NotifMessage = Instance.new("TextLabel")
        NotifMessage.BackgroundTransparency = 1
        NotifMessage.Position = UDim2.new(0, 14, 0, 28)
        NotifMessage.Size = UDim2.new(1, -20, 0, 24)
        NotifMessage.Font = Enum.Font.Gotham
        NotifMessage.Text = message
        NotifMessage.TextColor3 = CurrentTheme.TextDim
        NotifMessage.TextSize = 11
        NotifMessage.TextXAlignment = Enum.TextXAlignment.Left
        NotifMessage.TextWrapped = true
        NotifMessage.Parent = Notif
        
        -- Animate in
        Notif.Position = UDim2.new(1, 0, 0, 0)
        Tween(Notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        task.delay(duration, function()
            Tween(Notif, {Position = UDim2.new(1, 0, 0, 0)}, 0.3)
            task.delay(0.3, function()
                Notif:Destroy()
            end)
        end)
    end
    
    -- Destroy
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    return Window
end

-- Watermark
function SkeetUI:CreateWatermark(options)
    options = options or {}
    local title = options.Title or "skeet.cc"
    local themeName = options.Theme or "Dark"
    local position = options.Position or UDim2.new(0, 20, 0, 20)
    local showFPS = options.ShowFPS ~= false
    local showPing = options.ShowPing ~= false
    local showTime = options.ShowTime ~= false
    local showUser = options.ShowUser ~= false
    
    CurrentTheme = Themes[themeName] or Themes.Dark
    
    local Watermark = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkeetUI_Watermark_" .. HttpService:GenerateGUID(false)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Main Container
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.BackgroundColor3 = CurrentTheme.Surface
    Container.BorderSizePixel = 0
    Container.Position = position
    Container.AutomaticSize = Enum.AutomaticSize.X
    Container.Size = UDim2.new(0, 0, 0, 24)
    Container.ClipsDescendants = true
    Container.Parent = ScreenGui
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 6)
    ContainerCorner.Parent = Container
    
    local ContainerStroke = Instance.new("UIStroke")
    ContainerStroke.Color = CurrentTheme.Border
    ContainerStroke.Thickness = 1
    ContainerStroke.Parent = Container
    
    -- Top Gradient
    local TopGradient = Instance.new("Frame")
    TopGradient.Name = "TopGradient"
    TopGradient.BackgroundColor3 = Color3.new(1, 1, 1)
    TopGradient.BorderSizePixel = 0
    TopGradient.Position = UDim2.new(0, 0, 0, 0)
    TopGradient.Size = UDim2.new(1, 0, 0, 2)
    TopGradient.ZIndex = 10
    TopGradient.Parent = Container
    
    CreateGradient(TopGradient, {CurrentTheme.Primary, CurrentTheme.Secondary})
    
    -- Content Container
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 0, 0, 2)
    Content.Size = UDim2.new(1, 0, 1, -2)
    Content.AutomaticSize = Enum.AutomaticSize.X
    Content.Parent = Container
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.FillDirection = Enum.FillDirection.Horizontal
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ContentLayout.Padding = UDim.new(0, 0)
    ContentLayout.Parent = Content
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingLeft = UDim.new(0, 10)
    ContentPadding.PaddingRight = UDim.new(0, 10)
    ContentPadding.Parent = Content
    
    local function CreateTextItem(text, order, color)
        local Item = Instance.new("TextLabel")
        Item.BackgroundTransparency = 1
        Item.AutomaticSize = Enum.AutomaticSize.X
        Item.Size = UDim2.new(0, 0, 1, 0)
        Item.Font = Enum.Font.GothamMedium
        Item.Text = text
        Item.TextColor3 = color or CurrentTheme.Text
        Item.TextSize = 11
        Item.LayoutOrder = order
        Item.Parent = Content
        return Item
    end
    
    local function CreateSeparator(order)
        local Sep = Instance.new("TextLabel")
        Sep.BackgroundTransparency = 1
        Sep.Size = UDim2.new(0, 20, 1, 0)
        Sep.Font = Enum.Font.Gotham
        Sep.Text = "|"
        Sep.TextColor3 = CurrentTheme.Border
        Sep.TextSize = 11
        Sep.LayoutOrder = order
        Sep.Parent = Content
        return Sep
    end
    
    local TitleLabel = CreateTextItem(title, 1, CurrentTheme.Primary)
    local items = {TitleLabel}
    local order = 2
    
    local UserLabel, FPSLabel, PingLabel, TimeLabel
    
    if showUser then
        CreateSeparator(order)
        order = order + 1
        UserLabel = CreateTextItem(Player.Name, order)
        order = order + 1
        table.insert(items, UserLabel)
    end
    
    if showFPS then
        CreateSeparator(order)
        order = order + 1
        FPSLabel = CreateTextItem("0 fps", order)
        order = order + 1
        table.insert(items, FPSLabel)
    end
    
    if showPing then
        CreateSeparator(order)
        order = order + 1
        PingLabel = CreateTextItem("0 ms", order)
        order = order + 1
        table.insert(items, PingLabel)
    end
    
    if showTime then
        CreateSeparator(order)
        order = order + 1
        TimeLabel = CreateTextItem("00:00:00", order)
        table.insert(items, TimeLabel)
    end
    
    -- Update Loop
    local lastTick = tick()
    local frameCount = 0
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        if tick() - lastTick >= 1 then
            if FPSLabel then
                FPSLabel.Text = tostring(frameCount) .. " fps"
            end
            frameCount = 0
            lastTick = tick()
        end
        
        if TimeLabel then
            TimeLabel.Text = os.date("%H:%M:%S")
        end
        
        if PingLabel then
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            PingLabel.Text = tostring(math.floor(ping)) .. " ms"
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
        ScreenGui:Destroy()
    end
    
    return Watermark
end

return SkeetUI
