--[[
██╗   ██╗ ██████╗ ██╗██████╗     ██╗   ██╗██╗
██║   ██║██╔═══██╗██║██╔══██╗    ██║   ██║██║
██║   ██║██║   ██║██║██║  ██║    ██║   ██║██║
╚██╗ ██╔╝██║   ██║██║██║  ██║    ██║   ██║██║
 ╚████╔╝ ╚██████╔╝██║██████╔╝    ╚██████╔╝██║
  ╚═══╝   ╚═════╝ ╚═╝╚═════╝      ╚═════╝ ╚═╝

VoidUI - Premium Roblox Script GUI Library
Inspired by: Evrope, Weave, Fatality, Gamesense
Style: Industrial ImGui Aesthetic

Version: 3.0.0
--]]

local VoidUI = {}
VoidUI.__index = VoidUI
VoidUI.Version = "3.0.0"
VoidUI.Build = "2024.01"

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ══════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ══════════════════════════════════════════════════════════════════

local Config = {
    -- Animation
    TweenSpeed = 0.15,
    TweenSpeedFast = 0.08,
    TweenSpeedSlow = 0.25,
    EasingStyle = Enum.EasingStyle.Quad,
    EasingDirection = Enum.EasingDirection.Out,
    
    -- Sizing
    WindowWidth = 620,
    WindowHeight = 450,
    TabWidth = 90,
    HeaderHeight = 32,
    ElementHeight = 26,
    ElementSpacing = 2,
    SectionSpacing = 8,
    Padding = 8,
    
    -- Visual
    CornerRadius = 4,
    BorderWidth = 1,
    FontSize = 12,
    FontSizeSmall = 11,
    FontSizeTiny = 10,
}

-- ══════════════════════════════════════════════════════════════════
-- COLOR SCHEMES (Industrial/Cheat Style)
-- ══════════════════════════════════════════════════════════════════

local Themes = {
    Void = {
        -- Background
        Primary = Color3.fromRGB(10, 10, 12),
        Secondary = Color3.fromRGB(15, 15, 18),
        Tertiary = Color3.fromRGB(20, 20, 24),
        Surface = Color3.fromRGB(24, 24, 28),
        SurfaceHover = Color3.fromRGB(30, 30, 36),
        SurfaceActive = Color3.fromRGB(36, 36, 42),
        
        -- Borders
        Border = Color3.fromRGB(42, 42, 50),
        BorderSubtle = Color3.fromRGB(31, 31, 38),
        BorderAccent = Color3.fromRGB(99, 102, 241),
        
        -- Accent
        Accent = Color3.fromRGB(99, 102, 241),
        AccentHover = Color3.fromRGB(129, 132, 255),
        AccentDark = Color3.fromRGB(79, 82, 201),
        AccentMuted = Color3.fromRGB(49, 52, 131),
        
        -- Text
        Text = Color3.fromRGB(228, 228, 231),
        TextSecondary = Color3.fromRGB(161, 161, 170),
        TextMuted = Color3.fromRGB(82, 82, 91),
        TextAccent = Color3.fromRGB(165, 180, 252),
        
        -- Semantic
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
        Info = Color3.fromRGB(59, 130, 246),
        
        -- Special
        Header = Color3.fromRGB(18, 18, 22),
        Separator = Color3.fromRGB(38, 38, 46),
        Shadow = Color3.fromRGB(0, 0, 0),
        Glow = Color3.fromRGB(99, 102, 241),
    },
    
    Crimson = {
        Primary = Color3.fromRGB(10, 8, 8),
        Secondary = Color3.fromRGB(15, 12, 12),
        Tertiary = Color3.fromRGB(20, 16, 16),
        Surface = Color3.fromRGB(26, 20, 20),
        SurfaceHover = Color3.fromRGB(32, 24, 24),
        SurfaceActive = Color3.fromRGB(40, 30, 30),
        Border = Color3.fromRGB(50, 35, 35),
        BorderSubtle = Color3.fromRGB(38, 28, 28),
        BorderAccent = Color3.fromRGB(220, 38, 38),
        Accent = Color3.fromRGB(220, 38, 38),
        AccentHover = Color3.fromRGB(248, 68, 68),
        AccentDark = Color3.fromRGB(180, 28, 28),
        AccentMuted = Color3.fromRGB(100, 20, 20),
        Text = Color3.fromRGB(228, 220, 220),
        TextSecondary = Color3.fromRGB(170, 155, 155),
        TextMuted = Color3.fromRGB(100, 80, 80),
        TextAccent = Color3.fromRGB(252, 165, 165),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
        Info = Color3.fromRGB(59, 130, 246),
        Header = Color3.fromRGB(16, 12, 12),
        Separator = Color3.fromRGB(45, 32, 32),
        Shadow = Color3.fromRGB(0, 0, 0),
        Glow = Color3.fromRGB(220, 38, 38),
    },
    
    Matrix = {
        Primary = Color3.fromRGB(5, 10, 8),
        Secondary = Color3.fromRGB(8, 15, 12),
        Tertiary = Color3.fromRGB(12, 20, 16),
        Surface = Color3.fromRGB(16, 26, 20),
        SurfaceHover = Color3.fromRGB(20, 32, 26),
        SurfaceActive = Color3.fromRGB(26, 40, 32),
        Border = Color3.fromRGB(30, 55, 42),
        BorderSubtle = Color3.fromRGB(22, 40, 32),
        BorderAccent = Color3.fromRGB(34, 197, 94),
        Accent = Color3.fromRGB(34, 197, 94),
        AccentHover = Color3.fromRGB(74, 222, 128),
        AccentDark = Color3.fromRGB(22, 163, 74),
        AccentMuted = Color3.fromRGB(20, 83, 45),
        Text = Color3.fromRGB(220, 235, 228),
        TextSecondary = Color3.fromRGB(155, 185, 170),
        TextMuted = Color3.fromRGB(75, 110, 92),
        TextAccent = Color3.fromRGB(134, 239, 172),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
        Info = Color3.fromRGB(59, 130, 246),
        Header = Color3.fromRGB(10, 18, 14),
        Separator = Color3.fromRGB(28, 48, 38),
        Shadow = Color3.fromRGB(0, 0, 0),
        Glow = Color3.fromRGB(34, 197, 94),
    },
    
    Midnight = {
        Primary = Color3.fromRGB(3, 7, 18),
        Secondary = Color3.fromRGB(8, 14, 30),
        Tertiary = Color3.fromRGB(15, 23, 42),
        Surface = Color3.fromRGB(22, 33, 56),
        SurfaceHover = Color3.fromRGB(30, 41, 68),
        SurfaceActive = Color3.fromRGB(38, 52, 82),
        Border = Color3.fromRGB(51, 65, 95),
        BorderSubtle = Color3.fromRGB(38, 50, 75),
        BorderAccent = Color3.fromRGB(59, 130, 246),
        Accent = Color3.fromRGB(59, 130, 246),
        AccentHover = Color3.fromRGB(96, 165, 250),
        AccentDark = Color3.fromRGB(37, 99, 235),
        AccentMuted = Color3.fromRGB(30, 58, 138),
        Text = Color3.fromRGB(226, 232, 240),
        TextSecondary = Color3.fromRGB(148, 163, 184),
        TextMuted = Color3.fromRGB(71, 85, 105),
        TextAccent = Color3.fromRGB(147, 197, 253),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
        Info = Color3.fromRGB(59, 130, 246),
        Header = Color3.fromRGB(6, 11, 25),
        Separator = Color3.fromRGB(45, 58, 85),
        Shadow = Color3.fromRGB(0, 0, 0),
        Glow = Color3.fromRGB(59, 130, 246),
    },
}

-- ══════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ══════════════════════════════════════════════════════════════════

local function Create(className, properties, children)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = instance
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or Config.TweenSpeed,
        style or Config.EasingStyle,
        direction or Config.EasingDirection
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function Corner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or Config.CornerRadius),
        Parent = parent
    })
end

local function Stroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function Padding(parent, top, right, bottom, left)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        PaddingLeft = UDim.new(0, left or right or top or 0),
        Parent = parent
    })
end

local function GetTheme(name)
    return Themes[name] or Themes.Void
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function UUID()
    return HttpService:GenerateGUID(false)
end

-- ══════════════════════════════════════════════════════════════════
-- MAIN LIBRARY
-- ══════════════════════════════════════════════════════════════════

function VoidUI:CreateWindow(options)
    local theme = GetTheme(options.Theme or "Void")
    local windowId = UUID()
    
    local Window = {
        Id = windowId,
        Theme = theme,
        ThemeName = options.Theme or "Void",
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        Dragging = false,
    }
    
    -- ScreenGui
    local screenGui = Create("ScreenGui", {
        Name = "VoidUI_" .. windowId,
        DisplayOrder = 999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    })
    
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then
        screenGui.Parent = Player:WaitForChild("PlayerGui")
    end
    
    -- Main Container
    local mainFrame = Create("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, Config.WindowWidth, 0, Config.WindowHeight),
        Parent = screenGui
    })
    Corner(mainFrame, 6)
    Stroke(mainFrame, theme.Border, 1)
    
    -- Shadow
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 40, 1, 40),
        Image = "rbxassetid://5554236805",
        ImageColor3 = theme.Shadow,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = -1,
        Parent = mainFrame
    })
    
    -- ═══════════════════════════════════════════════════════════════
    -- HEADER BAR
    -- ═══════════════════════════════════════════════════════════════
    
    local header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = theme.Header,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Config.HeaderHeight),
        Parent = mainFrame
    })
    Corner(header, 6)
    
    -- Fix corner for bottom of header
    Create("Frame", {
        Name = "CornerFix",
        BackgroundColor3 = theme.Header,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = header
    })
    
    -- Header border bottom
    Create("Frame", {
        Name = "Border",
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = header
    })
    
    -- Title with accent indicator
    local titleContainer = Create("Frame", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Parent = header
    })
    
    -- Accent bar
    local accentBar = Create("Frame", {
        Name = "Accent",
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, -8),
        Size = UDim2.new(0, 3, 0, 16),
        Parent = titleContainer
    })
    Corner(accentBar, 2)
    
    local titleLabel = Create("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -12, 0.55, 0),
        Font = Enum.Font.GothamBold,
        Text = options.Title or "VoidUI",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleContainer
    })
    
    local subtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.new(1, -12, 0.5, 0),
        Font = Enum.Font.Gotham,
        Text = options.Subtitle or "v" .. VoidUI.Version,
        TextColor3 = theme.TextMuted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleContainer
    })
    
    -- Status indicator
    local statusContainer = Create("Frame", {
        Name = "Status",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -80, 0.5, 0),
        Size = UDim2.new(0, 60, 0, 16),
        Parent = header
    })
    
    local statusDot = Create("Frame", {
        Name = "Dot",
        BackgroundColor3 = theme.Success,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, -3),
        Size = UDim2.new(0, 6, 0, 6),
        Parent = statusContainer
    })
    Corner(statusDot, 3)
    
    local statusText = Create("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -10, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "READY",
        TextColor3 = theme.TextMuted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = statusContainer
    })
    
    -- Window Controls
    local controls = Create("Frame", {
        Name = "Controls",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.new(0, 54, 0, 20),
        Parent = header
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Parent = controls
    })
    
    local function CreateControlBtn(name, icon, hoverColor, callback)
        local btn = Create("TextButton", {
            Name = name,
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 22, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = "",
            Parent = controls
        })
        Corner(btn, 3)
        
        local iconLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = icon,
            TextColor3 = theme.TextMuted,
            TextSize = 11,
            Parent = btn
        })
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = hoverColor}, Config.TweenSpeedFast)
            Tween(iconLabel, {TextColor3 = theme.Text}, Config.TweenSpeedFast)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = theme.Surface}, Config.TweenSpeedFast)
            Tween(iconLabel, {TextColor3 = theme.TextMuted}, Config.TweenSpeedFast)
        end)
        btn.MouseButton1Click:Connect(callback)
        
        return btn
    end
    
    CreateControlBtn("Close", "×", theme.Error, function()
        Tween(mainFrame, {
            Size = UDim2.new(0, Config.WindowWidth, 0, 0),
            BackgroundTransparency = 1
        }, 0.2)
        task.delay(0.2, function()
            screenGui:Destroy()
        end)
    end)
    
    CreateControlBtn("Minimize", "−", theme.Warning, function()
        Window.Visible = not Window.Visible
        mainFrame.Visible = Window.Visible
    end)
    
    -- Dragging
    local dragStart, startPos
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Window.Dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Window.Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Window.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════════
    -- TAB SIDEBAR
    -- ═══════════════════════════════════════════════════════════════
    
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, Config.HeaderHeight),
        Size = UDim2.new(0, Config.TabWidth, 1, -Config.HeaderHeight),
        Parent = mainFrame
    })
    Corner(sidebar, 6)
    
    -- Fix corners
    Create("Frame", {
        Name = "Fix1",
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 6, 0, 6),
        Parent = sidebar
    })
    Create("Frame", {
        Name = "Fix2",
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -6, 0, 0),
        Size = UDim2.new(0, 6, 0, 6),
        Parent = sidebar
    })
    
    -- Right border
    Create("Frame", {
        Name = "Border",
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Parent = sidebar
    })
    
    local tabList = Create("ScrollingFrame", {
        Name = "Tabs",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 8),
        Size = UDim2.new(1, 0, 1, -16),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabList
    })
    Padding(tabList, 4, 6, 4, 6)
    
    -- ═══════════════════════════════════════════════════════════════
    -- CONTENT AREA
    -- ═══════════════════════════════════════════════════════════════
    
    local contentArea = Create("Frame", {
        Name = "Content",
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, Config.TabWidth, 0, Config.HeaderHeight),
        Size = UDim2.new(1, -Config.TabWidth, 1, -Config.HeaderHeight),
        ClipsDescendants = true,
        Parent = mainFrame
    })
    
    -- ═══════════════════════════════════════════════════════════════
    -- TAB CREATION
    -- ═══════════════════════════════════════════════════════════════
    
    function Window:CreateTab(tabOptions)
        local Tab = {
            Name = tabOptions.Name or "Tab",
            Icon = tabOptions.Icon,
            Sections = {},
            Visible = false,
        }
        
        -- Tab Button
        local tabBtn = Create("TextButton", {
            Name = Tab.Name,
            BackgroundColor3 = theme.Surface,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 28),
            Font = Enum.Font.Gotham,
            Text = "",
            AutoButtonColor = false,
            Parent = tabList
        })
        Corner(tabBtn, 4)
        
        -- Active indicator (left bar)
        local indicator = Create("Frame", {
            Name = "Indicator",
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.15, 0),
            Size = UDim2.new(0, 2, 0.7, 0),
            Visible = false,
            Parent = tabBtn
        })
        Corner(indicator, 1)
        
        -- Icon
        local iconLabel = Create("TextLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(0, 16, 1, 0),
            Font = Enum.Font.Gotham,
            Text = tabOptions.Icon or "◆",
            TextColor3 = theme.TextMuted,
            TextSize = 12,
            Parent = tabBtn
        })
        
        -- Name
        local nameLabel = Create("TextLabel", {
            Name = "Name",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 28, 0, 0),
            Size = UDim2.new(1, -32, 1, 0),
            Font = Enum.Font.Gotham,
            Text = Tab.Name,
            TextColor3 = theme.TextMuted,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = tabBtn
        })
        
        -- Tab Content Page
        local tabPage = Create("ScrollingFrame", {
            Name = Tab.Name .. "_Page",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Accent,
            ScrollBarImageTransparency = 0.5,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = contentArea
        })
        Padding(tabPage, 10, 10, 10, 10)
        
        -- Two column layout
        local columns = Create("Frame", {
            Name = "Columns",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = tabPage
        })
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            FillDirection = Enum.FillDirection.Horizontal,
            Parent = columns
        })
        
        local leftColumn = Create("Frame", {
            Name = "Left",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            Parent = columns
        })
        
        Create("UIListLayout", {
            Padding = UDim.new(0, Config.SectionSpacing),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = leftColumn
        })
        
        local rightColumn = Create("Frame", {
            Name = "Right",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 2,
            Parent = columns
        })
        
        Create("UIListLayout", {
            Padding = UDim.new(0, Config.SectionSpacing),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = rightColumn
        })
        
        Tab.Page = tabPage
        Tab.LeftColumn = leftColumn
        Tab.RightColumn = rightColumn
        Tab.Button = tabBtn
        Tab.Indicator = indicator
        Tab.IconLabel = iconLabel
        Tab.NameLabel = nameLabel
        
        local function SelectTab()
            for _, t in pairs(Window.Tabs) do
                t.Indicator.Visible = false
                t.Page.Visible = false
                Tween(t.Button, {BackgroundTransparency = 1}, Config.TweenSpeedFast)
                Tween(t.IconLabel, {TextColor3 = theme.TextMuted}, Config.TweenSpeedFast)
                Tween(t.NameLabel, {TextColor3 = theme.TextMuted}, Config.TweenSpeedFast)
            end
            
            Tab.Indicator.Visible = true
            Tab.Page.Visible = true
            Tween(tabBtn, {BackgroundTransparency = 0.5}, Config.TweenSpeedFast)
            Tween(iconLabel, {TextColor3 = theme.Accent}, Config.TweenSpeedFast)
            Tween(nameLabel, {TextColor3 = theme.Text}, Config.TweenSpeedFast)
            Window.CurrentTab = Tab
        end
        
        tabBtn.MouseButton1Click:Connect(SelectTab)
        tabBtn.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(tabBtn, {BackgroundTransparency = 0.7}, Config.TweenSpeedFast)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(tabBtn, {BackgroundTransparency = 1}, Config.TweenSpeedFast)
            end
        end)
        
        if #Window.Tabs == 0 then
            SelectTab()
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- ═══════════════════════════════════════════════════════════
        -- SECTION CREATION
        -- ═══════════════════════════════════════════════════════════
        
        function Tab:CreateSection(sectionOptions)
            local column = sectionOptions.Side == "Right" and rightColumn or leftColumn
            
            local section = Create("Frame", {
                Name = sectionOptions.Name or "Section",
                BackgroundColor3 = theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = column
            })
            Corner(section, 4)
            Stroke(section, theme.BorderSubtle, 1)
            
            -- Section Header
            local header = Create("Frame", {
                Name = "Header",
                BackgroundColor3 = theme.Tertiary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 24),
                Parent = section
            })
            Corner(header, 4)
            
            Create("Frame", {
                Name = "Fix",
                BackgroundColor3 = theme.Tertiary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -4),
                Size = UDim2.new(1, 0, 0, 4),
                Parent = header
            })
            
            Create("Frame", {
                Name = "Border",
                BackgroundColor3 = theme.BorderSubtle,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -1),
                Size = UDim2.new(1, 0, 0, 1),
                Parent = header
            })
            
            local sectionTitle = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -10, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = (sectionOptions.Name or "Section"):upper(),
                TextColor3 = theme.TextSecondary,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header
            })
            
            -- Section Content
            local content = Create("Frame", {
                Name = "Content",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 24),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = section
            })
            Padding(content, 6, 8, 8, 8)
            
            Create("UIListLayout", {
                Padding = UDim.new(0, Config.ElementSpacing),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = content
            })
            
            local Section = { Container = content }
            
            -- ═══════════════════════════════════════════════════════
            -- UI ELEMENTS
            -- ═══════════════════════════════════════════════════════
            
            -- Toggle (Checkbox style)
            function Section:CreateToggle(opts)
                local toggled = opts.Default or false
                
                local frame = Create("Frame", {
                    Name = opts.Name or "Toggle",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, Config.ElementHeight),
                    Parent = content
                })
                
                local btn = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = frame
                })
                
                local checkbox = Create("Frame", {
                    Name = "Checkbox",
                    BackgroundColor3 = toggled and theme.Accent or theme.Surface,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14),
                    Parent = btn
                })
                Corner(checkbox, 2)
                Stroke(checkbox, toggled and theme.Accent or theme.Border, 1)
                
                local checkmark = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = toggled and "✓" or "",
                    TextColor3 = theme.Text,
                    TextSize = 10,
                    Parent = checkbox
                })
                
                local label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 22, 0, 0),
                    Size = UDim2.new(1, -22, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = opts.Name or "Toggle",
                    TextColor3 = theme.Text,
                    TextSize = Config.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = btn
                })
                
                local function Update()
                    Tween(checkbox, {
                        BackgroundColor3 = toggled and theme.Accent or theme.Surface
                    }, Config.TweenSpeedFast)
                    checkbox:FindFirstChild("UIStroke").Color = toggled and theme.Accent or theme.Border
                    checkmark.Text = toggled and "✓" or ""
                    if opts.Callback then opts.Callback(toggled) end
                end
                
                btn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Update()
                end)
                
                btn.MouseEnter:Connect(function()
                    Tween(label, {TextColor3 = theme.TextAccent}, Config.TweenSpeedFast)
                end)
                btn.MouseLeave:Connect(function()
                    Tween(label, {TextColor3 = theme.Text}, Config.TweenSpeedFast)
                end)
                
                return {
                    Set = function(_, val)
                        toggled = val
                        Update()
                    end,
                    Get = function() return toggled end,
                    Frame = frame
                }
            end
            
            -- Slider
            function Section:CreateSlider(opts)
                local min = opts.Min or 0
                local max = opts.Max or 100
                local default = opts.Default or min
                local increment = opts.Increment or 1
                local suffix = opts.Suffix or ""
                local value = default
                
                local frame = Create("Frame", {
                    Name = opts.Name or "Slider",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36),
                    Parent = content
                })
                
                local label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.6, 0, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = opts.Name or "Slider",
                    TextColor3 = theme.Text,
                    TextSize = Config.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })
                
                local valueLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0.4, 0, 0, 16),
                    Font = Enum.Font.GothamMedium,
                    Text = tostring(value) .. suffix,
                    TextColor3 = theme.Accent,
                    TextSize = Config.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = frame
                })
                
                local track = Create("Frame", {
                    Name = "Track",
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 8),
                    Parent = frame
                })
                Corner(track, 2)
                Stroke(track, theme.BorderSubtle, 1)
                
                local fill = Create("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    Parent = track
                })
                Corner(fill, 2)
                
                local knob = Create("Frame", {
                    Name = "Knob",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = theme.Text,
                    BorderSizePixel = 0,
                    Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    Parent = track
                })
                Corner(knob, 6)
                
                local sliding = false
                
                local function UpdateSlider(newValue)
                    newValue = math.clamp(newValue, min, max)
                    newValue = math.floor(newValue / increment + 0.5) * increment
                    value = newValue
                    local percent = (value - min) / (max - min)
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    knob.Position = UDim2.new(percent, 0, 0.5, 0)
                    valueLabel.Text = tostring(value) .. suffix
                    if opts.Callback then opts.Callback(value) end
                end
                
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        UpdateSlider(min + (max - min) * percent)
                    end
                end)
                
                track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        UpdateSlider(min + (max - min) * percent)
                    end
                end)
                
                return {
                    Set = function(_, val) UpdateSlider(val) end,
                    Get = function() return value end,
                    Frame = frame
                }
            end
            
            -- Button
            function Section:CreateButton(opts)
                local frame = Create("Frame", {
                    Name = opts.Name or "Button",
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, Config.ElementHeight),
                    Parent = content
                })
                Corner(frame, 3)
                Stroke(frame, theme.BorderSubtle, 1)
                
                local btn = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = opts.Name or "Button",
                    TextColor3 = theme.Text,
                    TextSize = Config.FontSize,
                    Parent = frame
                })
                
                btn.MouseEnter:Connect(function()
                    Tween(frame, {BackgroundColor3 = theme.Accent}, Config.TweenSpeedFast)
                end)
                btn.MouseLeave:Connect(function()
                    Tween(frame, {BackgroundColor3 = theme.Surface}, Config.TweenSpeedFast)
                end)
                btn.MouseButton1Click:Connect(function()
                    if opts.Callback then opts.Callback() end
                end)
                
                return { Frame = frame }
            end
            
            -- Dropdown
            function Section:CreateDropdown(opts)
                local options = opts.Options or {}
                local selected = opts.Default or (options[1] or "Select...")
                local isOpen = false
                
                local frame = Create("Frame", {
                    Name = opts.Name or "Dropdown",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, Config.ElementHeight),
                    ClipsDescendants = false,
                    ZIndex = 5,
                    Parent = content
                })
                
                local label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = opts.Name or "Dropdown",
                    TextColor3 = theme.Text,
                    TextSize = Config.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = frame
                })
                
                local dropBtn = Create("TextButton", {
                    Name = "Button",
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0.55, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    ZIndex = 5,
                    Parent = frame
                })
                Corner(dropBtn, 3)
                Stroke(dropBtn, theme.BorderSubtle, 1)
                
                local selectedLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = selected,
                    TextColor3 = theme.TextSecondary,
                    TextSize = Config.FontSizeSmall,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 5,
                    Parent = dropBtn
                })
                
                local arrow = Create("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -6, 0.5, 0),
                    Size = UDim2.new(0, 10, 0, 10),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = theme.TextMuted,
                    TextSize = 8,
                    ZIndex = 5,
                    Parent = dropBtn
                })
                
                local optionsFrame = Create("Frame", {
                    Name = "Options",
                    BackgroundColor3 = theme.Tertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, 2),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 10,
                    Parent = dropBtn
                })
                Corner(optionsFrame, 3)
                Stroke(optionsFrame, theme.Border, 1)
                
                local optionsList = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ZIndex = 10,
                    Parent = optionsFrame
                })
                
                Create("UIListLayout", {
                    Padding = UDim.new(0, 1),
                    Parent = optionsList
                })
                Padding(optionsList, 4, 4, 4, 4)
                
                local function CreateOption(optName)
                    local optBtn = Create("TextButton", {
                        Name = optName,
                        BackgroundColor3 = theme.Surface,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 22),
                        Font = Enum.Font.Gotham,
                        Text = optName,
                        TextColor3 = theme.TextSecondary,
                        TextSize = Config.FontSizeSmall,
                        ZIndex = 11,
                        Parent = optionsList
                    })
                    Corner(optBtn, 2)
                    
                    optBtn.MouseEnter:Connect(function()
                        Tween(optBtn, {BackgroundTransparency = 0, BackgroundColor3 = theme.Accent}, Config.TweenSpeedFast)
                        Tween(optBtn, {TextColor3 = theme.Text}, Config.TweenSpeedFast)
                    end)
                    optBtn.MouseLeave:Connect(function()
                        Tween(optBtn, {BackgroundTransparency = 1}, Config.TweenSpeedFast)
                        Tween(optBtn, {TextColor3 = theme.TextSecondary}, Config.TweenSpeedFast)
                    end)
                    optBtn.MouseButton1Click:Connect(function()
                        selected = optName
                        selectedLabel.Text = optName
                        isOpen = false
                        Tween(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, Config.TweenSpeedFast)
                        task.delay(Config.TweenSpeedFast, function()
                            optionsFrame.Visible = false
                        end)
                        Tween(arrow, {Rotation = 0}, Config.TweenSpeedFast)
                        if opts.Callback then opts.Callback(optName) end
                    end)
                end
                
                for _, opt in ipairs(options) do
                    CreateOption(opt)
                end
                
                dropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        optionsFrame.Visible = true
                        local targetHeight = #options * 23 + 10
                        Tween(optionsFrame, {Size = UDim2.new(1, 0, 0, targetHeight)}, Config.TweenSpeed)
                        Tween(arrow, {Rotation = 180}, Config.TweenSpeedFast)
                    else
                        Tween(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, Config.TweenSpeedFast)
                        task.delay(Config.TweenSpeedFast, function()
                            optionsFrame.Visible = false
                        end)
                        Tween(arrow, {Rotation = 0}, Config.TweenSpeedFast)
                    end
                end)
                
                return {
                    Set = function(_, val)
                        selected = val
                        selectedLabel.Text = val
                        if opts.Callback then opts.Callback(val) end
                    end,
                    Get = function() return selected end,
                    Frame = frame
                }
            end
            
            -- Input/TextBox
            function Section:CreateInput(opts)
                local frame = Create("Frame", {
                    Name = opts.Name or "Input",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, Config.ElementHeight),
                    Parent = content
                })
                
                local label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.35, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = opts.Name or "Input",
                    TextColor3 = theme.Text,
                    TextSize = Config.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })
                
                local inputBox = Create("TextBox", {
                    Name = "Box",
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = opts.Placeholder or "Enter...",
                    PlaceholderColor3 = theme.TextMuted,
                    Text = opts.Default or "",
                    TextColor3 = theme.Text,
                    TextSize = Config.FontSizeSmall,
                    ClearTextOnFocus = false,
                    Parent = frame
                })
                Corner(inputBox, 3)
                Stroke(inputBox, theme.BorderSubtle, 1)
                Padding(inputBox, 0, 8, 0, 8)
                
                inputBox.Focused:Connect(function()
                    inputBox:FindFirstChild("UIStroke").Color = theme.Accent
                end)
                inputBox.FocusLost:Connect(function(enter)
                    inputBox:FindFirstChild("UIStroke").Color = theme.BorderSubtle
                    if opts.Callback then opts.Callback(inputBox.Text, enter) end
                end)
                
                return {
                    Set = function(_, val) inputBox.Text = val end,
                    Get = function() return inputBox.Text end,
                    Frame = frame
                }
            end
            
            -- Keybind
            function Section:CreateKeybind(opts)
                local currentKey = opts.Default
                local listening = false
                
                local frame = Create("Frame", {
                    Name = opts.Name or "Keybind",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, Config.ElementHeight),
                    Parent = content
                })
                
                local label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = opts.Name or "Keybind",
                    TextColor3 = theme.Text,
                    TextSize = Config.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })
                
                local keyBtn = Create("TextButton", {
                    Name = "Key",
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0, 60, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = currentKey and currentKey.Name or "None",
                    TextColor3 = theme.TextAccent,
                    TextSize = Config.FontSizeTiny,
                    Parent = frame
                })
                Corner(keyBtn, 3)
                Stroke(keyBtn, theme.BorderSubtle, 1)
                
                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "..."
                    keyBtn:FindFirstChild("UIStroke").Color = theme.Accent
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            keyBtn.Text = input.KeyCode.Name
                            listening = false
                            keyBtn:FindFirstChild("UIStroke").Color = theme.BorderSubtle
                        end
                    elseif not processed and currentKey and input.KeyCode == currentKey then
                        if opts.Callback then opts.Callback(currentKey) end
                    end
                end)
                
                return {
                    Set = function(_, key)
                        currentKey = key
                        keyBtn.Text = key and key.Name or "None"
                    end,
                    Get = function() return currentKey end,
                    Frame = frame
                }
            end
            
            -- Label
            function Section:CreateLabel(text)
                local label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = text or "Label",
                    TextColor3 = theme.TextSecondary,
                    TextSize = Config.FontSizeSmall,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = content
                })
                
                return {
                    Set = function(_, val) label.Text = val end,
                    Frame = label
                }
            end
            
            -- Separator
            function Section:CreateSeparator()
                local sep = Create("Frame", {
                    Name = "Separator",
                    BackgroundColor3 = theme.Separator,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1),
                    Parent = content
                })
                return { Frame = sep }
            end
            
            -- ColorPicker
            function Section:CreateColorPicker(opts)
                local currentColor = opts.Default or Color3.fromRGB(255, 255, 255)
                
                local frame = Create("Frame", {
                    Name = opts.Name or "ColorPicker",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, Config.ElementHeight),
                    Parent = content
                })
                
                local label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -30, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = opts.Name or "Color",
                    TextColor3 = theme.Text,
                    TextSize = Config.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })
                
                local colorBtn = Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = currentColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 24, 0, 16),
                    Text = "",
                    Parent = frame
                })
                Corner(colorBtn, 3)
                Stroke(colorBtn, theme.Border, 1)
                
                local presets = {
                    Color3.fromRGB(239, 68, 68),
                    Color3.fromRGB(249, 115, 22),
                    Color3.fromRGB(234, 179, 8),
                    Color3.fromRGB(34, 197, 94),
                    Color3.fromRGB(34, 211, 238),
                    Color3.fromRGB(99, 102, 241),
                    Color3.fromRGB(168, 85, 247),
                    Color3.fromRGB(236, 72, 153),
                    Color3.fromRGB(255, 255, 255),
                }
                
                local presetIndex = 1
                
                colorBtn.MouseButton1Click:Connect(function()
                    presetIndex = presetIndex + 1
                    if presetIndex > #presets then presetIndex = 1 end
                    currentColor = presets[presetIndex]
                    colorBtn.BackgroundColor3 = currentColor
                    if opts.Callback then opts.Callback(currentColor) end
                end)
                
                return {
                    Set = function(_, col)
                        currentColor = col
                        colorBtn.BackgroundColor3 = col
                    end,
                    Get = function() return currentColor end,
                    Frame = frame
                }
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- Window Methods
    function Window:SetTheme(themeName)
        Window.Theme = GetTheme(themeName)
        Window.ThemeName = themeName
    end
    
    function Window:Toggle()
        Window.Visible = not Window.Visible
        mainFrame.Visible = Window.Visible
    end
    
    function Window:Destroy()
        screenGui:Destroy()
    end
    
    function Window:SetStatus(text, status)
        statusText.Text = text:upper()
        local colors = {
            ready = theme.Success,
            loading = theme.Warning,
            error = theme.Error,
            info = theme.Info,
        }
        statusDot.BackgroundColor3 = colors[status:lower()] or theme.Success
    end
    
    -- Entry Animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundTransparency = 1
    
    Tween(mainFrame, {
        Size = UDim2.new(0, Config.WindowWidth, 0, Config.WindowHeight),
        BackgroundTransparency = 0
    }, 0.3, Enum.EasingStyle.Back)
    
    return Window
end

-- ══════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════════════

local NotificationContainer = nil

function VoidUI:Notify(options)
    local theme = GetTheme(options.Theme or "Void")
    
    if not NotificationContainer then
        local screenGui = Create("ScreenGui", {
            Name = "VoidUI_Notifications",
            DisplayOrder = 1000,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false,
        })
        pcall(function() screenGui.Parent = CoreGui end)
        if not screenGui.Parent then
            screenGui.Parent = Player:WaitForChild("PlayerGui")
        end
        
        NotificationContainer = Create("Frame", {
            Name = "Container",
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -20, 0, 20),
            Size = UDim2.new(0, 280, 1, -40),
            Parent = screenGui
        })
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = NotificationContainer
        })
    end
    
    local typeColors = {
        Success = theme.Success,
        Warning = theme.Warning,
        Error = theme.Error,
        Info = theme.Info,
    }
    
    local notifType = options.Type or "Info"
    local accentColor = typeColors[notifType] or theme.Accent
    
    local notif = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 60),
        Parent = NotificationContainer
    })
    Corner(notif, 4)
    Stroke(notif, theme.Border, 1)
    
    -- Accent bar
    local accent = Create("Frame", {
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0),
        Parent = notif
    })
    Corner(accent, 2)
    
    local title = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 10),
        Size = UDim2.new(1, -20, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = options.Title or notifType,
        TextColor3 = theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    local message = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 28),
        Size = UDim2.new(1, -20, 0, 24),
        Font = Enum.Font.Gotham,
        Text = options.Message or "",
        TextColor3 = theme.TextSecondary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = notif
    })
    
    -- Animation
    notif.Position = UDim2.new(1, 50, 0, 0)
    notif.BackgroundTransparency = 1
    
    Tween(notif, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, 0.2)
    
    local duration = options.Duration or 4
    task.delay(duration, function()
        Tween(notif, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.2)
        task.delay(0.2, function()
            notif:Destroy()
        end)
    end)
    
    return notif
end

return VoidUI
