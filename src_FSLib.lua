--[[
    ███████╗███████╗██╗     ██╗██████╗ 
    ██╔════╝██╔════╝██║     ██║██╔══██╗
    █████╗  ███████╗██║     ██║██████╔╝
    ██╔══╝  ╚════██║██║     ██║██╔══██╗
    ██║     ███████║███████╗██║██████╔╝
    ╚═╝     ╚══════╝╚══════╝╚═╝╚═════╝ 
    
    FSLib - Premium Roblox Script GUI Library
    Build 1.0.0 | Professional Edition
    
    Style: Skeet/Neverlose Inspired
--]]

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
local TextService = game:GetService("TextService")

local Player = Players.LocalPlayer

-- Theme System
local Themes = {
    Default = {
        Name = "Default",
        Primary = Color3.fromRGB(18, 18, 22),
        Secondary = Color3.fromRGB(24, 24, 30),
        Tertiary = Color3.fromRGB(32, 32, 40),
        Border = Color3.fromRGB(45, 45, 55),
        Text = Color3.fromRGB(220, 220, 225),
        TextDark = Color3.fromRGB(140, 140, 150),
        Accent = Color3.fromRGB(134, 148, 255),
        AccentDark = Color3.fromRGB(100, 115, 200),
        Success = Color3.fromRGB(98, 224, 158),
        Warning = Color3.fromRGB(255, 193, 99),
        Error = Color3.fromRGB(255, 99, 99),
        AccentGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 148, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 130, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 130, 180))
        })
    },
    Blood = {
        Name = "Blood",
        Primary = Color3.fromRGB(18, 15, 15),
        Secondary = Color3.fromRGB(25, 20, 20),
        Tertiary = Color3.fromRGB(35, 28, 28),
        Border = Color3.fromRGB(55, 40, 40),
        Text = Color3.fromRGB(225, 215, 215),
        TextDark = Color3.fromRGB(150, 130, 130),
        Accent = Color3.fromRGB(220, 60, 60),
        AccentDark = Color3.fromRGB(180, 50, 50),
        Success = Color3.fromRGB(98, 224, 158),
        Warning = Color3.fromRGB(255, 193, 99),
        Error = Color3.fromRGB(255, 99, 99),
        AccentGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 60, 60)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 100))
        })
    },
    Ocean = {
        Name = "Ocean",
        Primary = Color3.fromRGB(12, 18, 22),
        Secondary = Color3.fromRGB(18, 26, 32),
        Tertiary = Color3.fromRGB(25, 35, 45),
        Border = Color3.fromRGB(40, 55, 70),
        Text = Color3.fromRGB(215, 225, 230),
        TextDark = Color3.fromRGB(120, 145, 160),
        Accent = Color3.fromRGB(70, 180, 220),
        AccentDark = Color3.fromRGB(50, 150, 190),
        Success = Color3.fromRGB(98, 224, 158),
        Warning = Color3.fromRGB(255, 193, 99),
        Error = Color3.fromRGB(255, 99, 99),
        AccentGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 180, 220)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 200, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 220, 255))
        })
    },
    Mint = {
        Name = "Mint",
        Primary = Color3.fromRGB(14, 20, 18),
        Secondary = Color3.fromRGB(20, 28, 25),
        Tertiary = Color3.fromRGB(28, 40, 35),
        Border = Color3.fromRGB(45, 65, 55),
        Text = Color3.fromRGB(215, 230, 220),
        TextDark = Color3.fromRGB(120, 160, 140),
        Accent = Color3.fromRGB(98, 220, 160),
        AccentDark = Color3.fromRGB(70, 180, 130),
        Success = Color3.fromRGB(98, 224, 158),
        Warning = Color3.fromRGB(255, 193, 99),
        Error = Color3.fromRGB(255, 99, 99),
        AccentGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(98, 220, 160)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(130, 240, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 255, 220))
        })
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
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
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

-- Color Functions (HSV <-> RGB)
local function HSVtoRGB(h, s, v)
    h = h % 360
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    
    local r, g, b = 0, 0, 0
    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
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

-- Get text width helper
local function GetTextWidth(text, fontSize)
    local size = TextService:GetTextSize(text, fontSize, Enum.Font.GothamMedium, Vector2.new(math.huge, math.huge))
    return size.X
end

-- Main ScreenGui
local ScreenGui

-- Check for existing GUI
local function CreateScreenGui()
    if ScreenGui and ScreenGui.Parent then
        return ScreenGui
    end
    
    local success, gui = pcall(function()
        local gui = Create("ScreenGui", {
            Name = "FSLib_" .. tostring(math.random(100000, 999999)),
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset = true
        })
        
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
            gui.Parent = CoreGui
        elseif gethui then
            gui.Parent = gethui()
        else
            gui.Parent = CoreGui
        end
        
        return gui
    end)
    
    if not success then
        gui = Create("ScreenGui", {
            Name = "FSLib_" .. tostring(math.random(100000, 999999)),
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset = true,
            Parent = Player:WaitForChild("PlayerGui")
        })
    end
    
    ScreenGui = gui
    return gui
end

-- Notification System (Premium Quality)
local NotificationContainer

local function CreateNotificationContainer()
    if NotificationContainer and NotificationContainer.Parent then
        return NotificationContainer
    end
    
    NotificationContainer = Create("Frame", {
        Name = "NotificationContainer",
        Size = UDim2.new(0, 320, 1, -40),
        Position = UDim2.new(1, -340, 0, 20),
        BackgroundTransparency = 1,
        Parent = ScreenGui
    })
    
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Parent = NotificationContainer
    })
    
    return NotificationContainer
end

function FSLib:Notify(options)
    local title = options.Title or "Notification"
    local message = options.Message or ""
    local notifType = options.Type or "Info"
    local duration = options.Duration or 4
    
    CreateNotificationContainer()
    
    local typeColors = {
        Success = CurrentTheme.Success,
        Error = CurrentTheme.Error,
        Warning = CurrentTheme.Warning,
        Info = CurrentTheme.Accent
    }
    local accentColor = typeColors[notifType] or CurrentTheme.Accent
    
    local typeIcons = {
        Success = "✓",
        Error = "✕",
        Warning = "⚠",
        Info = "ℹ"
    }
    local icon = typeIcons[notifType] or "ℹ"
    
    -- Main notification frame
    local Notification = Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = CurrentTheme.Primary,
        BackgroundTransparency = 0,
        ClipsDescendants = true,
        Parent = NotificationContainer
    })
    AddCorner(Notification, 6)
    
    -- Outer stroke
    Create("UIStroke", {
        Color = CurrentTheme.Border,
        Thickness = 1,
        Parent = Notification
    })
    
    -- Inner glow frame for premium feel
    local InnerGlow = Create("Frame", {
        Name = "InnerGlow",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = Notification
    })
    AddCorner(InnerGlow, 6)
    
    -- Gradient overlay for depth
    local GradientOverlay = Create("Frame", {
        Name = "GradientOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.97,
        Parent = Notification
    })
    AddCorner(GradientOverlay, 6)
    
    Create("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Parent = GradientOverlay
    })
    
    -- Top accent line (inside notification)
    local TopAccent = Create("Frame", {
        Name = "TopAccent",
        Size = UDim2.new(1, -16, 0, 2),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Parent = Notification
    })
    AddCorner(TopAccent, 1)
    
    -- Accent glow
    Create("ImageLabel", {
        Size = UDim2.new(1, 20, 0, 12),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = accentColor,
        ImageTransparency = 0.7,
        Parent = TopAccent
    })
    
    -- Content container
    local Content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 16),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = Notification
    })
    
    -- Icon container
    local IconContainer = Create("Frame", {
        Name = "IconContainer",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.85,
        Parent = Content
    })
    AddCorner(IconContainer, 6)
    
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = icon,
        TextColor3 = accentColor,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = IconContainer
    })
    
    -- Text container
    local TextContainer = Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -38, 0, 0),
        Position = UDim2.new(0, 38, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = Content
    })
    
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = TextContainer
    })
    
    -- Title
    Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = CurrentTheme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = TextContainer
    })
    
    -- Message
    Create("TextLabel", {
        Name = "Message",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = CurrentTheme.TextDark,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LayoutOrder = 2,
        Parent = TextContainer
    })
    
    -- Bottom padding
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundTransparency = 1,
        LayoutOrder = 100,
        Parent = Content
    })
    
    -- Progress bar at bottom
    local ProgressContainer = Create("Frame", {
        Name = "ProgressContainer",
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = CurrentTheme.Tertiary,
        BorderSizePixel = 0,
        Parent = Notification
    })
    
    local ProgressBar = Create("Frame", {
        Name = "ProgressBar",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Parent = ProgressContainer
    })
    
    -- Animate in
    Notification.Size = UDim2.new(1, 0, 0, 0)
    Notification.BackgroundTransparency = 1
    
    task.spawn(function()
        Tween(Notification, {BackgroundTransparency = 0}, 0.3)
        task.wait(0.1)
        
        -- Animate progress bar
        Tween(ProgressBar, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
        
        task.wait(duration)
        
        -- Animate out
        Tween(Notification, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.35)
        Notification:Destroy()
    end)
    
    return Notification
end

-- Watermark (Draggable, Auto-width)
function FSLib:CreateWatermark(options)
    options = options or {}
    local title = options.Title or "FSLib"
    local theme = Themes[options.Theme] or CurrentTheme
    local showFPS = options.ShowFPS ~= false
    local showPing = options.ShowPing ~= false
    local showTime = options.ShowTime ~= false
    local showUser = options.ShowUser ~= false
    local position = options.Position or UDim2.new(0, 20, 0, 20)
    
    CreateScreenGui()
    
    local Watermark = {}
    local isDragging = false
    local dragStart, startPos
    
    local fps, ping = 60, 0
    
    -- Calculate initial width
    local function CalculateWidth()
        local parts = {title}
        if showUser then table.insert(parts, Player.Name) end
        if showFPS then table.insert(parts, fps .. " fps") end
        if showPing then table.insert(parts, ping .. " ms") end
        if showTime then table.insert(parts, os.date("%H:%M:%S")) end
        
        local totalWidth = 0
        for i, part in ipairs(parts) do
            totalWidth = totalWidth + GetTextWidth(part, 11) + 16 -- padding
            if i < #parts then
                totalWidth = totalWidth + 12 -- separator width
            end
        end
        return math.max(totalWidth, 100)
    end
    
    -- Main container
    local Container = Create("Frame", {
        Name = "FSLib_Watermark",
        Size = UDim2.new(0, CalculateWidth(), 0, 26),
        Position = position,
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    AddCorner(Container, 4)
    AddStroke(Container, theme.Border, 1)
    
    -- Top accent gradient (inside container)
    local TopGradient = Create("Frame", {
        Name = "TopGradient",
        Size = UDim2.new(1, -8, 0, 2),
        Position = UDim2.new(0, 4, 0, 4),
        BorderSizePixel = 0,
        Parent = Container
    })
    AddCorner(TopGradient, 1)
    
    Create("UIGradient", {
        Color = theme.AccentGradient,
        Parent = TopGradient
    })
    
    -- Content layout
    local ContentFrame = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -12, 0, 14),
        Position = UDim2.new(0, 6, 0, 10),
        BackgroundTransparency = 1,
        Parent = Container
    })
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 0),
        Parent = ContentFrame
    })
    
    local labels = {}
    local order = 0
    
    local function AddPart(name, text, isTitle)
        order = order + 1
        local label = Create("TextLabel", {
            Name = name,
            Size = UDim2.new(0, GetTextWidth(text, 11) + 12, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = isTitle and theme.Accent or theme.Text,
            TextSize = 11,
            Font = isTitle and Enum.Font.GothamBold or Enum.Font.Gotham,
            LayoutOrder = order,
            Parent = ContentFrame
        })
        labels[name] = label
        return label
    end
    
    local function AddSeparator()
        order = order + 1
        Create("TextLabel", {
            Name = "Sep" .. order,
            Size = UDim2.new(0, 12, 1, 0),
            BackgroundTransparency = 1,
            Text = "|",
            TextColor3 = theme.Border,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            LayoutOrder = order,
            Parent = ContentFrame
        })
    end
    
    -- Build content
    AddPart("Title", title, true)
    if showUser then AddSeparator() AddPart("User", Player.Name, false) end
    if showFPS then AddSeparator() AddPart("FPS", fps .. " fps", false) end
    if showPing then AddSeparator() AddPart("Ping", ping .. " ms", false) end
    if showTime then AddSeparator() AddPart("Time", os.date("%H:%M:%S"), false) end
    
    -- Dragging
    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = Container.Position
        end
    end)
    
    Container.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Container.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Update loop
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not Container or not Container.Parent then
            connection:Disconnect()
            return
        end
        
        fps = math.floor(1 / RunService.Heartbeat:Wait())
        pcall(function()
            ping = math.floor(Player:GetNetworkPing() * 1000)
        end)
        
        -- Update labels
        if labels.FPS and showFPS then
            local text = fps .. " fps"
            labels.FPS.Text = text
            labels.FPS.Size = UDim2.new(0, GetTextWidth(text, 11) + 12, 1, 0)
        end
        if labels.Ping and showPing then
            local text = ping .. " ms"
            labels.Ping.Text = text
            labels.Ping.Size = UDim2.new(0, GetTextWidth(text, 11) + 12, 1, 0)
        end
        if labels.Time and showTime then
            local text = os.date("%H:%M:%S")
            labels.Time.Text = text
            labels.Time.Size = UDim2.new(0, GetTextWidth(text, 11) + 12, 1, 0)
        end
        
        -- Recalculate width
        Container.Size = UDim2.new(0, CalculateWidth(), 0, 26)
    end)
    
    function Watermark:SetTitle(newTitle)
        title = newTitle
        if labels.Title then
            labels.Title.Text = newTitle
            labels.Title.Size = UDim2.new(0, GetTextWidth(newTitle, 11) + 12, 1, 0)
        end
    end
    
    function Watermark:Hide()
        Container.Visible = false
    end
    
    function Watermark:Show()
        Container.Visible = true
    end
    
    function Watermark:Destroy()
        connection:Disconnect()
        Container:Destroy()
    end
    
    return Watermark
end

-- Main Window
function FSLib:CreateWindow(options)
    options = options or {}
    local title = options.Title or "FSLib"
    local subtitle = options.Subtitle or "Build " .. self.Build
    local theme = Themes[options.Theme] or CurrentTheme
    local size = options.Size or UDim2.new(0, 580, 0, 420)
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    local statusBar = options.StatusBar or {
        Text = "ready",
        Status = "ready",
        Build = "build: " .. os.date("%Y%m%d"),
        Version = "v" .. self.Version,
        Visible = true
    }
    
    CurrentTheme = theme
    CreateScreenGui()
    
    local Window = {}
    local tabs = {}
    local currentTab = nil
    local isVisible = true
    local isDragging = false
    local dragStart, startPos
    
    -- Main Window Frame (ClipsDescendants for proper corner clipping)
    local MainFrame = Create("Frame", {
        Name = "FSLib_Window",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    AddCorner(MainFrame, 8)
    
    -- Outer border
    local OuterBorder = Create("UIStroke", {
        Color = theme.Border,
        Thickness = 1,
        Parent = MainFrame
    })
    
    -- Top gradient line (inside clipped container)
    local TopGradientLine = Create("Frame", {
        Name = "TopGradient",
        Size = UDim2.new(1, -16, 0, 2),
        Position = UDim2.new(0, 8, 0, 6),
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = MainFrame
    })
    AddCorner(TopGradientLine, 1)
    
    Create("UIGradient", {
        Color = theme.AccentGradient,
        Parent = TopGradientLine
    })
    
    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    -- Title
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Subtitle
    local SubtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 14 + GetTextWidth(title, 13) + 8, 0, 0),
        BackgroundTransparency = 1,
        Text = subtitle,
        TextColor3 = theme.TextDark,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Keybind indicator
    local KeybindLabel = Create("TextLabel", {
        Name = "Keybind",
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -110, 0, 0),
        BackgroundTransparency = 1,
        Text = "[" .. toggleKey.Name .. "]",
        TextColor3 = theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Header
    })
    
    -- Header bottom border
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Parent = Header
    })
    
    -- Tab bar (left side)
    local TabBar = Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(0, 100, 1, -36 - 24),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    -- Tab bar right border
    Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Parent = TabBar
    })
    
    local TabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, -1, 1, -8),
        Position = UDim2.new(0, 0, 0, 4),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = TabBar
    })
    
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = TabList
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = TabList
    })
    
    -- Content area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -100, 1, -36 - 24),
        Position = UDim2.new(0, 100, 0, 36),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = MainFrame
    })
    
    -- Status bar
    local StatusBar = Create("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 1, -24),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Visible = statusBar.Visible ~= false,
        Parent = MainFrame
    })
    
    -- Status bar top border
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Parent = StatusBar
    })
    
    -- Status indicator
    local StatusDot = Create("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 10, 0.5, -3),
        BackgroundColor3 = theme.Success,
        BorderSizePixel = 0,
        Parent = StatusBar
    })
    AddCorner(StatusDot, 3)
    
    local StatusText = Create("TextLabel", {
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(0, 22, 0, 0),
        BackgroundTransparency = 1,
        Text = statusBar.Text or "ready",
        TextColor3 = theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = StatusBar
    })
    
    local BuildText = Create("TextLabel", {
        Size = UDim2.new(1, -180, 1, 0),
        Position = UDim2.new(0, 90, 0, 0),
        BackgroundTransparency = 1,
        Text = statusBar.Build or "build: " .. os.date("%Y%m%d"),
        TextColor3 = theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = StatusBar
    })
    
    local VersionText = Create("TextLabel", {
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(1, -70, 0, 0),
        BackgroundTransparency = 1,
        Text = statusBar.Version or "v" .. self.Version,
        TextColor3 = theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = StatusBar
    })
    
    -- Dragging
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Toggle visibility
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey then
            isVisible = not isVisible
            MainFrame.Visible = isVisible
        end
    end)
    
    -- Set status bar
    function Window:SetStatusBar(opts)
        if opts.Text then StatusText.Text = opts.Text end
        if opts.Build then BuildText.Text = opts.Build end
        if opts.Version then VersionText.Text = opts.Version end
        if opts.Status then
            local statusColors = {
                ready = theme.Success,
                loading = theme.Warning,
                error = theme.Error,
                offline = theme.TextDark
            }
            StatusDot.BackgroundColor3 = statusColors[opts.Status] or theme.Success
        end
        if opts.Visible ~= nil then
            StatusBar.Visible = opts.Visible
        end
    end
    
    -- Notify
    function Window:Notify(options)
        FSLib:Notify(options)
    end
    
    -- Create Tab
    function Window:CreateTab(options)
        options = options or {}
        local tabName = options.Name or "Tab"
        local tabIcon = options.Icon or ""
        
        local Tab = {}
        local sections = {Left = {}, Right = {}}
        
        local tabIndex = #tabs + 1
        table.insert(tabs, Tab)
        
        -- Tab button
        local TabButton = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = theme.Tertiary,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = tabIndex,
            Parent = TabList
        })
        AddCorner(TabButton, 4)
        
        -- Active indicator
        local ActiveIndicator = Create("Frame", {
            Size = UDim2.new(0, 2, 0, 16),
            Position = UDim2.new(0, 0, 0.5, -8),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            Visible = false,
            Parent = TabButton
        })
        AddCorner(ActiveIndicator, 1)
        
        -- Tab icon
        if tabIcon ~= "" then
            Create("TextLabel", {
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = tabIcon,
                TextColor3 = theme.TextDark,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                Parent = TabButton
            })
        end
        
        -- Tab name
        local TabLabel = Create("TextLabel", {
            Size = UDim2.new(1, -(tabIcon ~= "" and 34 or 12), 1, 0),
            Position = UDim2.new(0, tabIcon ~= "" and 28 or 8, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = theme.TextDark,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = TabButton
        })
        
        -- Tab content (two columns)
        local TabContent = Create("ScrollingFrame", {
            Name = tabName .. "_Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentArea
        })
        
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            Parent = TabContent
        })
        
        -- Two column layout
        local ColumnsContainer = Create("Frame", {
            Name = "Columns",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = TabContent
        })
        
        -- Left column
        local LeftColumn = Create("Frame", {
            Name = "Left",
            Size = UDim2.new(0.5, -4, 0, 0),
            Position = UDim2.new(0, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = ColumnsContainer
        })
        
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = LeftColumn
        })
        
        -- Right column
        local RightColumn = Create("Frame", {
            Name = "Right",
            Size = UDim2.new(0.5, -4, 0, 0),
            Position = UDim2.new(0.5, 4, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = ColumnsContainer
        })
        
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = RightColumn
        })
        
        -- Tab button hover/click
        TabButton.MouseEnter:Connect(function()
            if currentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.8}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if currentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.15)
            end
        end)
        
        local function SelectTab()
            for _, t in ipairs(tabs) do
                if t.Content then t.Content.Visible = false end
                if t.Indicator then t.Indicator.Visible = false end
                if t.Label then t.Label.TextColor3 = theme.TextDark end
                if t.Button then Tween(t.Button, {BackgroundTransparency = 1}, 0.15) end
            end
            
            TabContent.Visible = true
            ActiveIndicator.Visible = true
            TabLabel.TextColor3 = theme.Text
            Tween(TabButton, {BackgroundTransparency = 0.7}, 0.15)
            currentTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        Tab.Content = TabContent
        Tab.Indicator = ActiveIndicator
        Tab.Label = TabLabel
        Tab.Button = TabButton
        
        -- Select first tab
        if tabIndex == 1 then
            SelectTab()
        end
        
        -- Create Section
        function Tab:CreateSection(options)
            options = options or {}
            local sectionName = options.Name or "Section"
            local side = options.Side or "Left"
            local sectionOrder = #sections[side] + 1
            
            local Section = {}
            table.insert(sections[side], Section)
            
            local parentColumn = side == "Left" and LeftColumn or RightColumn
            
            -- Section frame
            local SectionFrame = Create("Frame", {
                Name = sectionName,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Secondary,
                BorderSizePixel = 0,
                LayoutOrder = sectionOrder,
                Parent = parentColumn
            })
            AddCorner(SectionFrame, 6)
            AddStroke(SectionFrame, theme.Border, 1)
            
            -- Section header
            local SectionHeader = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                Parent = SectionFrame
            })
            
            Create("TextLabel", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName:lower(),
                TextColor3 = theme.TextDark,
                TextSize = 10,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            -- Section content
            local SectionContent = Create("Frame", {
                Name = "Content",
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 26),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = SectionFrame
            })
            
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
                Parent = SectionContent
            })
            
            -- Bottom padding
            Create("Frame", {
                Size = UDim2.new(1, 0, 0, 8),
                BackgroundTransparency = 1,
                LayoutOrder = 9999,
                Parent = SectionContent
            })
            
            local elementOrder = 0
            
            -- Create Toggle
            function Section:CreateToggle(options)
                options = options or {}
                local toggleName = options.Name or "Toggle"
                local default = options.Default or false
                local callback = options.Callback or function() end
                
                elementOrder = elementOrder + 1
                local Toggle = {}
                local enabled = default
                
                local ToggleFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    BackgroundTransparency = 1,
                    Text = toggleName,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })
                
                local ToggleButton = Create("TextButton", {
                    Size = UDim2.new(0, 32, 0, 16),
                    Position = UDim2.new(1, -32, 0.5, -8),
                    BackgroundColor3 = enabled and theme.Accent or theme.Tertiary,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = ToggleFrame
                })
                AddCorner(ToggleButton, 8)
                AddStroke(ToggleButton, theme.Border, 1)
                
                local ToggleCircle = Create("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = enabled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Parent = ToggleButton
                })
                AddCorner(ToggleCircle, 6)
                
                local function UpdateToggle()
                    Tween(ToggleButton, {BackgroundColor3 = enabled and theme.Accent or theme.Tertiary}, 0.15)
                    Tween(ToggleCircle, {Position = enabled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}, 0.15)
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    enabled = not enabled
                    UpdateToggle()
                    callback(enabled)
                end)
                
                function Toggle:Set(value)
                    enabled = value
                    UpdateToggle()
                    callback(enabled)
                end
                
                function Toggle:Get()
                    return enabled
                end
                
                return Toggle
            end
            
            -- Create Slider
            function Section:CreateSlider(options)
                options = options or {}
                local sliderName = options.Name or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local suffix = options.Suffix or ""
                local callback = options.Callback or function() end
                
                elementOrder = elementOrder + 1
                local Slider = {}
                local value = default
                local dragging = false
                
                local SliderFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                
                local SliderLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -50, 0, 16),
                    BackgroundTransparency = 1,
                    Text = sliderName,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame
                })
                
                local ValueLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 50, 0, 16),
                    Position = UDim2.new(1, -50, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value) .. suffix,
                    TextColor3 = theme.Accent,
                    TextSize = 11,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderFrame
                })
                
                local SliderTrack = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 4),
                    Position = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = theme.Tertiary,
                    BorderSizePixel = 0,
                    Parent = SliderFrame
                })
                AddCorner(SliderTrack, 2)
                
                local SliderFill = Create("Frame", {
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Parent = SliderTrack
                })
                AddCorner(SliderFill, 2)
                
                local SliderKnob = Create("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    Parent = SliderTrack
                })
                AddCorner(SliderKnob, 6)
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max - min) * pos)
                    ValueLabel.Text = tostring(value) .. suffix
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
                    callback(value)
                end
                
                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                SliderTrack.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input)
                    end
                end)
                
                function Slider:Set(val)
                    value = math.clamp(val, min, max)
                    local pos = (value - min) / (max - min)
                    ValueLabel.Text = tostring(value) .. suffix
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
                    callback(value)
                end
                
                function Slider:Get()
                    return value
                end
                
                return Slider
            end
            
            -- Create Button
            function Section:CreateButton(options)
                options = options or {}
                local buttonName = options.Name or "Button"
                local callback = options.Callback or function() end
                
                elementOrder = elementOrder + 1
                local Button = {}
                
                local ButtonFrame = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = theme.Tertiary,
                    Text = buttonName,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.GothamMedium,
                    AutoButtonColor = false,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                AddCorner(ButtonFrame, 4)
                AddStroke(ButtonFrame, theme.Border, 1)
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = theme.Accent}, 0.15)
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = theme.Tertiary}, 0.15)
                end)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    callback()
                end)
                
                return Button
            end
            
            -- Create Dropdown
            function Section:CreateDropdown(options)
                options = options or {}
                local dropdownName = options.Name or "Dropdown"
                local optionsList = options.Options or {}
                local default = options.Default or (optionsList[1] or "")
                local callback = options.Callback or function() end
                
                elementOrder = elementOrder + 1
                local Dropdown = {}
                local selected = default
                local isOpen = false
                
                local DropdownFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    ClipsDescendants = false,
                    Parent = SectionContent
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = dropdownName,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownFrame
                })
                
                local DropdownButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = theme.Tertiary,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = DropdownFrame
                })
                AddCorner(DropdownButton, 4)
                AddStroke(DropdownButton, theme.Border, 1)
                
                local SelectedLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = selected,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = DropdownButton
                })
                
                local Arrow = Create("TextLabel", {
                    Size = UDim2.new(0, 16, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = theme.TextDark,
                    TextSize = 8,
                    Font = Enum.Font.Gotham,
                    Parent = DropdownButton
                })
                
                -- Options container (rendered to ScreenGui to avoid clipping)
                local OptionsContainer = Create("Frame", {
                    Size = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = theme.Tertiary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 100,
                    Parent = ScreenGui
                })
                AddCorner(OptionsContainer, 4)
                AddStroke(OptionsContainer, theme.Border, 1)
                
                local OptionsScroll = Create("ScrollingFrame", {
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = theme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, #optionsList * 24),
                    ZIndex = 100,
                    Parent = OptionsContainer
                })
                
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2),
                    Parent = OptionsScroll
                })
                
                local function CreateOptions()
                    for _, child in pairs(OptionsScroll:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    
                    for i, option in ipairs(optionsList) do
                        local OptionButton = Create("TextButton", {
                            Size = UDim2.new(1, -4, 0, 22),
                            BackgroundColor3 = theme.Secondary,
                            BackgroundTransparency = option == selected and 0 or 1,
                            Text = option,
                            TextColor3 = option == selected and theme.Accent or theme.Text,
                            TextSize = 11,
                            Font = Enum.Font.Gotham,
                            AutoButtonColor = false,
                            LayoutOrder = i,
                            ZIndex = 100,
                            Parent = OptionsScroll
                        })
                        AddCorner(OptionButton, 4)
                        
                        OptionButton.MouseEnter:Connect(function()
                            if option ~= selected then
                                Tween(OptionButton, {BackgroundTransparency = 0.5}, 0.1)
                            end
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            if option ~= selected then
                                Tween(OptionButton, {BackgroundTransparency = 1}, 0.1)
                            end
                        end)
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            selected = option
                            SelectedLabel.Text = selected
                            isOpen = false
                            OptionsContainer.Visible = false
                            Arrow.Text = "▼"
                            callback(selected)
                            CreateOptions()
                        end)
                    end
                    
                    OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, #optionsList * 24)
                end
                
                CreateOptions()
                
                local function ToggleDropdown()
                    isOpen = not isOpen
                    if isOpen then
                        local btnPos = DropdownButton.AbsolutePosition
                        local btnSize = DropdownButton.AbsoluteSize
                        local optHeight = math.min(#optionsList * 24 + 4, 150)
                        
                        OptionsContainer.Position = UDim2.new(0, btnPos.X, 0, btnPos.Y + btnSize.Y + 2)
                        OptionsContainer.Size = UDim2.new(0, btnSize.X, 0, optHeight)
                        OptionsContainer.Visible = true
                        Arrow.Text = "▲"
                    else
                        OptionsContainer.Visible = false
                        Arrow.Text = "▼"
                    end
                end
                
                DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
                
                -- Close when clicking outside
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mousePos = UserInputService:GetMouseLocation()
                        local containerPos = OptionsContainer.AbsolutePosition
                        local containerSize = OptionsContainer.AbsoluteSize
                        local btnPos = DropdownButton.AbsolutePosition
                        local btnSize = DropdownButton.AbsoluteSize
                        
                        local inContainer = mousePos.X >= containerPos.X and mousePos.X <= containerPos.X + containerSize.X and
                                           mousePos.Y >= containerPos.Y and mousePos.Y <= containerPos.Y + containerSize.Y
                        local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
                                        mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
                        
                        if isOpen and not inContainer and not inButton then
                            isOpen = false
                            OptionsContainer.Visible = false
                            Arrow.Text = "▼"
                        end
                    end
                end)
                
                function Dropdown:Set(value)
                    if table.find(optionsList, value) then
                        selected = value
                        SelectedLabel.Text = selected
                        callback(selected)
                        CreateOptions()
                    end
                end
                
                function Dropdown:Get()
                    return selected
                end
                
                function Dropdown:Refresh(newOptions)
                    optionsList = newOptions
                    CreateOptions()
                end
                
                return Dropdown
            end
            
            -- Create MultiDropdown
            function Section:CreateMultiDropdown(options)
                options = options or {}
                local dropdownName = options.Name or "MultiDropdown"
                local optionsList = options.Options or {}
                local default = options.Default or {}
                local callback = options.Callback or function() end
                
                elementOrder = elementOrder + 1
                local MultiDropdown = {}
                local selected = {}
                for _, v in ipairs(default) do selected[v] = true end
                local isOpen = false
                
                local function GetDisplayText()
                    local count = 0
                    local names = {}
                    for name, sel in pairs(selected) do
                        if sel then
                            count = count + 1
                            table.insert(names, name)
                        end
                    end
                    if count == 0 then return "None"
                    elseif count <= 2 then return table.concat(names, ", ")
                    else return count .. " selected"
                    end
                end
                
                local DropdownFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    ClipsDescendants = false,
                    Parent = SectionContent
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = dropdownName,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownFrame
                })
                
                local DropdownButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = theme.Tertiary,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = DropdownFrame
                })
                AddCorner(DropdownButton, 4)
                AddStroke(DropdownButton, theme.Border, 1)
                
                local SelectedLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = GetDisplayText(),
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = DropdownButton
                })
                
                local Arrow = Create("TextLabel", {
                    Size = UDim2.new(0, 16, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = theme.TextDark,
                    TextSize = 8,
                    Font = Enum.Font.Gotham,
                    Parent = DropdownButton
                })
                
                local OptionsContainer = Create("Frame", {
                    Size = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = theme.Tertiary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 100,
                    Parent = ScreenGui
                })
                AddCorner(OptionsContainer, 4)
                AddStroke(OptionsContainer, theme.Border, 1)
                
                local OptionsScroll = Create("ScrollingFrame", {
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = theme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, #optionsList * 24),
                    ZIndex = 100,
                    Parent = OptionsContainer
                })
                
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2),
                    Parent = OptionsScroll
                })
                
                local function CreateOptions()
                    for _, child in pairs(OptionsScroll:GetChildren()) do
                        if child:IsA("Frame") then child:Destroy() end
                    end
                    
                    for i, option in ipairs(optionsList) do
                        local isSelected = selected[option] == true
                        
                        local OptionFrame = Create("Frame", {
                            Size = UDim2.new(1, -4, 0, 22),
                            BackgroundColor3 = theme.Secondary,
                            BackgroundTransparency = isSelected and 0 or 1,
                            LayoutOrder = i,
                            ZIndex = 100,
                            Parent = OptionsScroll
                        })
                        AddCorner(OptionFrame, 4)
                        
                        local Checkbox = Create("Frame", {
                            Size = UDim2.new(0, 14, 0, 14),
                            Position = UDim2.new(0, 4, 0.5, -7),
                            BackgroundColor3 = isSelected and theme.Accent or theme.Tertiary,
                            ZIndex = 100,
                            Parent = OptionFrame
                        })
                        AddCorner(Checkbox, 3)
                        AddStroke(Checkbox, theme.Border, 1)
                        
                        local Checkmark = Create("TextLabel", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = isSelected and "✓" or "",
                            TextColor3 = Color3.new(1, 1, 1),
                            TextSize = 10,
                            Font = Enum.Font.GothamBold,
                            ZIndex = 100,
                            Parent = Checkbox
                        })
                        
                        Create("TextLabel", {
                            Size = UDim2.new(1, -26, 1, 0),
                            Position = UDim2.new(0, 24, 0, 0),
                            BackgroundTransparency = 1,
                            Text = option,
                            TextColor3 = isSelected and theme.Accent or theme.Text,
                            TextSize = 11,
                            Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 100,
                            Parent = OptionFrame
                        })
                        
                        local ClickButton = Create("TextButton", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = "",
                            ZIndex = 101,
                            Parent = OptionFrame
                        })
                        
                        ClickButton.MouseButton1Click:Connect(function()
                            selected[option] = not selected[option]
                            SelectedLabel.Text = GetDisplayText()
                            
                            local values = {}
                            for name, sel in pairs(selected) do
                                if sel then table.insert(values, name) end
                            end
                            callback(values)
                            CreateOptions()
                        end)
                    end
                    
                    OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, #optionsList * 24)
                end
                
                CreateOptions()
                
                local function ToggleDropdown()
                    isOpen = not isOpen
                    if isOpen then
                        local btnPos = DropdownButton.AbsolutePosition
                        local btnSize = DropdownButton.AbsoluteSize
                        local optHeight = math.min(#optionsList * 24 + 4, 150)
                        
                        OptionsContainer.Position = UDim2.new(0, btnPos.X, 0, btnPos.Y + btnSize.Y + 2)
                        OptionsContainer.Size = UDim2.new(0, btnSize.X, 0, optHeight)
                        OptionsContainer.Visible = true
                        Arrow.Text = "▲"
                    else
                        OptionsContainer.Visible = false
                        Arrow.Text = "▼"
                    end
                end
                
                DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
                
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mousePos = UserInputService:GetMouseLocation()
                        local containerPos = OptionsContainer.AbsolutePosition
                        local containerSize = OptionsContainer.AbsoluteSize
                        local btnPos = DropdownButton.AbsolutePosition
                        local btnSize = DropdownButton.AbsoluteSize
                        
                        local inContainer = mousePos.X >= containerPos.X and mousePos.X <= containerPos.X + containerSize.X and
                                           mousePos.Y >= containerPos.Y and mousePos.Y <= containerPos.Y + containerSize.Y
                        local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
                                        mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
                        
                        if isOpen and not inContainer and not inButton then
                            isOpen = false
                            OptionsContainer.Visible = false
                            Arrow.Text = "▼"
                        end
                    end
                end)
                
                function MultiDropdown:Set(values)
                    selected = {}
                    for _, v in ipairs(values) do selected[v] = true end
                    SelectedLabel.Text = GetDisplayText()
                    callback(values)
                    CreateOptions()
                end
                
                function MultiDropdown:Get()
                    local values = {}
                    for name, sel in pairs(selected) do
                        if sel then table.insert(values, name) end
                    end
                    return values
                end
                
                return MultiDropdown
            end
            
            -- Create Input
            function Section:CreateInput(options)
                options = options or {}
                local inputName = options.Name or "Input"
                local placeholder = options.Placeholder or "Enter text..."
                local default = options.Default or ""
                local callback = options.Callback or function() end
                
                elementOrder = elementOrder + 1
                local Input = {}
                
                local InputFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = inputName,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = InputFrame
                })
                
                local TextBox = Create("TextBox", {
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = theme.Tertiary,
                    Text = default,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = theme.TextDark,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = InputFrame
                })
                AddCorner(TextBox, 4)
                AddStroke(TextBox, theme.Border, 1)
                AddPadding(TextBox, 8)
                
                TextBox.FocusLost:Connect(function(enterPressed)
                    callback(TextBox.Text, enterPressed)
                end)
                
                function Input:Set(value)
                    TextBox.Text = value
                end
                
                function Input:Get()
                    return TextBox.Text
                end
                
                return Input
            end
            
            -- Create Keybind
            function Section:CreateKeybind(options)
                options = options or {}
                local keybindName = options.Name or "Keybind"
                local default = options.Default or Enum.KeyCode.Unknown
                local callback = options.Callback or function() end
                
                elementOrder = elementOrder + 1
                local Keybind = {}
                local currentKey = default
                local listening = false
                
                local KeybindFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    BackgroundTransparency = 1,
                    Text = keybindName,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeybindFrame
                })
                
                local KeybindButton = Create("TextButton", {
                    Size = UDim2.new(0, 55, 0, 20),
                    Position = UDim2.new(1, -55, 0.5, -10),
                    BackgroundColor3 = theme.Tertiary,
                    Text = currentKey == Enum.KeyCode.Unknown and "None" or currentKey.Name,
                    TextColor3 = theme.Text,
                    TextSize = 10,
                    Font = Enum.Font.GothamMedium,
                    AutoButtonColor = false,
                    Parent = KeybindFrame
                })
                AddCorner(KeybindButton, 4)
                AddStroke(KeybindButton, theme.Border, 1)
                
                KeybindButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeybindButton.Text = "..."
                    Tween(KeybindButton, {BackgroundColor3 = theme.Accent}, 0.15)
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            KeybindButton.Text = currentKey.Name
                            Tween(KeybindButton, {BackgroundColor3 = theme.Tertiary}, 0.15)
                            listening = false
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                            -- Cancel
                            KeybindButton.Text = currentKey == Enum.KeyCode.Unknown and "None" or currentKey.Name
                            Tween(KeybindButton, {BackgroundColor3 = theme.Tertiary}, 0.15)
                            listening = false
                        end
                    else
                        if not processed and input.KeyCode == currentKey then
                            callback(currentKey)
                        end
                    end
                end)
                
                function Keybind:Set(key)
                    currentKey = key
                    KeybindButton.Text = currentKey == Enum.KeyCode.Unknown and "None" or currentKey.Name
                end
                
                function Keybind:Get()
                    return currentKey
                end
                
                return Keybind
            end
            
            -- Create ColorPicker (FULLY FUNCTIONAL)
            function Section:CreateColorPicker(options)
                options = options or {}
                local colorName = options.Name or "Color"
                local default = options.Default or Color3.fromRGB(255, 0, 0)
                local defaultAlpha = options.Alpha or 1
                local callback = options.Callback or function() end
                
                elementOrder = elementOrder + 1
                local ColorPicker = {}
                
                -- State
                local h, s, v = RGBtoHSV(default)
                local alpha = defaultAlpha
                local isOpen = false
                local draggingSV = false
                local draggingHue = false
                local draggingAlpha = false
                
                local ColorFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementOrder,
                    ClipsDescendants = false,
                    Parent = SectionContent
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, -50, 1, 0),
                    BackgroundTransparency = 1,
                    Text = colorName,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorFrame
                })
                
                local ColorButton = Create("TextButton", {
                    Size = UDim2.new(0, 40, 0, 18),
                    Position = UDim2.new(1, -40, 0.5, -9),
                    BackgroundColor3 = default,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = ColorFrame
                })
                AddCorner(ColorButton, 4)
                AddStroke(ColorButton, theme.Border, 1)
                
                -- Picker panel (rendered to ScreenGui)
                local PickerPanel = Create("Frame", {
                    Size = UDim2.new(0, 200, 0, 170),
                    BackgroundColor3 = theme.Primary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 100,
                    Parent = ScreenGui
                })
                AddCorner(PickerPanel, 6)
                AddStroke(PickerPanel, theme.Border, 1)
                
                -- SV Picker (Saturation-Value)
                local SVPicker = Create("Frame", {
                    Size = UDim2.new(0, 180, 0, 100),
                    Position = UDim2.new(0, 10, 0, 10),
                    BackgroundColor3 = HSVtoRGB(h, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 100,
                    Parent = PickerPanel
                })
                AddCorner(SVPicker, 4)
                
                -- White gradient (left to right)
                local WhiteGradient = Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 101,
                    Parent = SVPicker
                })
                AddCorner(WhiteGradient, 4)
                
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
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 102,
                    Parent = SVPicker
                })
                AddCorner(BlackGradient, 4)
                
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
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(s, -6, 1 - v, -6),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 103,
                    Parent = SVPicker
                })
                AddCorner(SVCursor, 6)
                AddStroke(SVCursor, Color3.new(0, 0, 0), 2)
                
                -- Hue slider
                local HueSlider = Create("Frame", {
                    Size = UDim2.new(0, 180, 0, 12),
                    Position = UDim2.new(0, 10, 0, 118),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 100,
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
                    Parent = HueSlider
                })
                
                -- Hue cursor
                local HueCursor = Create("Frame", {
                    Size = UDim2.new(0, 4, 1, 4),
                    Position = UDim2.new(h / 360, -2, 0, -2),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 101,
                    Parent = HueSlider
                })
                AddCorner(HueCursor, 2)
                AddStroke(HueCursor, Color3.new(0, 0, 0), 1)
                
                -- Alpha slider
                local AlphaSlider = Create("Frame", {
                    Size = UDim2.new(0, 180, 0, 12),
                    Position = UDim2.new(0, 10, 0, 136),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 100,
                    Parent = PickerPanel
                })
                AddCorner(AlphaSlider, 4)
                
                local AlphaGradient = Create("UIGradient", {
                    Color = ColorSequence.new(Color3.new(0, 0, 0), HSVtoRGB(h, s, v)),
                    Parent = AlphaSlider
                })
                
                -- Alpha cursor
                local AlphaCursor = Create("Frame", {
                    Size = UDim2.new(0, 4, 1, 4),
                    Position = UDim2.new(alpha, -2, 0, -2),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 101,
                    Parent = AlphaSlider
                })
                AddCorner(AlphaCursor, 2)
                AddStroke(AlphaCursor, Color3.new(0, 0, 0), 1)
                
                -- HEX display
                local HexLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 80, 0, 14),
                    Position = UDim2.new(0, 10, 0, 152),
                    BackgroundTransparency = 1,
                    Text = ColorToHex(HSVtoRGB(h, s, v)),
                    TextColor3 = theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 100,
                    Parent = PickerPanel
                })
                
                -- Alpha percent display
                local AlphaLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 50, 0, 14),
                    Position = UDim2.new(1, -60, 0, 152),
                    BackgroundTransparency = 1,
                    Text = math.floor(alpha * 100) .. "%",
                    TextColor3 = theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 100,
                    Parent = PickerPanel
                })
                
                local function UpdateColor()
                    local color = HSVtoRGB(h, s, v)
                    ColorButton.BackgroundColor3 = color
                    SVPicker.BackgroundColor3 = HSVtoRGB(h, 1, 1)
                    SVCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                    HueCursor.Position = UDim2.new(h / 360, -2, 0, -2)
                    AlphaCursor.Position = UDim2.new(alpha, -2, 0, -2)
                    AlphaGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), color)
                    HexLabel.Text = ColorToHex(color)
                    AlphaLabel.Text = math.floor(alpha * 100) .. "%"
                    callback(color, alpha)
                end
                
                -- SV Picker input
                local function UpdateSV(input)
                    local pos = input.Position
                    local svPos = SVPicker.AbsolutePosition
                    local svSize = SVPicker.AbsoluteSize
                    
                    s = math.clamp((pos.X - svPos.X) / svSize.X, 0, 1)
                    v = math.clamp(1 - (pos.Y - svPos.Y) / svSize.Y, 0, 1)
                    UpdateColor()
                end
                
                SVPicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSV = true
                        UpdateSV(input)
                    end
                end)
                
                SVPicker.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSV = false
                    end
                end)
                
                -- Hue slider input
                local function UpdateHue(input)
                    local pos = input.Position
                    local huePos = HueSlider.AbsolutePosition
                    local hueSize = HueSlider.AbsoluteSize
                    
                    h = math.clamp((pos.X - huePos.X) / hueSize.X, 0, 1) * 360
                    UpdateColor()
                end
                
                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingHue = true
                        UpdateHue(input)
                    end
                end)
                
                HueSlider.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingHue = false
                    end
                end)
                
                -- Alpha slider input
                local function UpdateAlpha(input)
                    local pos = input.Position
                    local alphaPos = AlphaSlider.AbsolutePosition
                    local alphaSize = AlphaSlider.AbsoluteSize
                    
                    alpha = math.clamp((pos.X - alphaPos.X) / alphaSize.X, 0, 1)
                    UpdateColor()
                end
                
                AlphaSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingAlpha = true
                        UpdateAlpha(input)
                    end
                end)
                
                AlphaSlider.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingAlpha = false
                    end
                end)
                
                -- Global input for dragging
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if draggingSV then UpdateSV(input) end
                        if draggingHue then UpdateHue(input) end
                        if draggingAlpha then UpdateAlpha(input) end
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSV = false
                        draggingHue = false
                        draggingAlpha = false
                    end
                end)
                
                -- Toggle picker
                ColorButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        local btnPos = ColorButton.AbsolutePosition
                        local btnSize = ColorButton.AbsoluteSize
                        local screenSize = workspace.CurrentCamera.ViewportSize
                        
                        local posX = btnPos.X + btnSize.X + 5
                        if posX + 200 > screenSize.X then
                            posX = btnPos.X - 205
                        end
                        
                        PickerPanel.Position = UDim2.new(0, posX, 0, btnPos.Y - 75)
                        PickerPanel.Visible = true
                    else
                        PickerPanel.Visible = false
                    end
                end)
                
                -- Close when clicking outside
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local panelPos = PickerPanel.AbsolutePosition
                        local panelSize = PickerPanel.AbsoluteSize
                        local btnPos = ColorButton.AbsolutePosition
                        local btnSize = ColorButton.AbsoluteSize
                        
                        local inPanel = mousePos.X >= panelPos.X and mousePos.X <= panelPos.X + panelSize.X and
                                       mousePos.Y >= panelPos.Y and mousePos.Y <= panelPos.Y + panelSize.Y
                        local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
                                        mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
                        
                        if not inPanel and not inButton then
                            isOpen = false
                            PickerPanel.Visible = false
                        end
                    end
                end)
                
                function ColorPicker:Set(color, newAlpha)
                    h, s, v = RGBtoHSV(color)
                    if newAlpha then alpha = newAlpha end
                    UpdateColor()
                end
                
                function ColorPicker:Get()
                    return HSVtoRGB(h, s, v), alpha
                end
                
                return ColorPicker
            end
            
            -- Create Label
            function Section:CreateLabel(text)
                elementOrder = elementOrder + 1
                
                local Label = {}
                
                local LabelFrame = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
                
                function Label:Set(newText)
                    LabelFrame.Text = newText
                end
                
                return Label
            end
            
            -- Create Separator
            function Section:CreateSeparator()
                elementOrder = elementOrder + 1
                
                Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = theme.Border,
                    BorderSizePixel = 0,
                    LayoutOrder = elementOrder,
                    Parent = SectionContent
                })
            end
            
            return Section
        end
        
        return Tab
    end
    
    function Window:Hide()
        MainFrame.Visible = false
        isVisible = false
    end
    
    function Window:Show()
        MainFrame.Visible = true
        isVisible = true
    end
    
    function Window:Destroy()
        MainFrame:Destroy()
    end
    
    return Window
end

-- Set Theme
function FSLib:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
    end
end

-- Get Themes
function FSLib:GetThemes()
    local themeNames = {}
    for name, _ in pairs(Themes) do
        table.insert(themeNames, name)
    end
    return themeNames
end

return FSLib
