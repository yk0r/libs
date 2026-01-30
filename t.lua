--[[
    ███████╗██████╗ ██╗███████╗███╗   ██╗██████╗ ███████╗██╗  ██╗██╗██████╗    ██╗     ██╗   ██╗ █████╗ 
    ██╔════╝██╔══██╗██║██╔════╝████╗  ██║██╔══██╗██╔════╝██║  ██║██║██╔══██╗   ██║     ██║   ██║██╔══██╗
    █████╗  ██████╔╝██║█████╗  ██╔██╗ ██║██║  ██║███████╗███████║██║██████╔╝   ██║     ██║   ██║███████║
    ██╔══╝  ██╔══██╗██║██╔══╝  ██║╚██╗██║██║  ██║╚════██║██╔══██║██║██╔═══╝    ██║     ██║   ██║██╔══██║
    ██║     ██║  ██║██║███████╗██║ ╚████║██████╔╝███████║██║  ██║██║██║        ███████╗╚██████╔╝██║  ██║
    ╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚══════╝ ╚═════╝ ╚═╝  ╚═╝
    
    FriendShip.Lua UI Library v1.0.0
    Created by FS Team
    
    Features:
    - Window with drag support
    - Tabs with icons (Lucide compatible)
    - Groups/Sections
    - Toggle (no white dot style)
    - Slider with keyboard input
    - Dropdown (single & multi-select)
    - ColorPicker with RGB sliders
    - TextBox
    - Button
    - Label
    - Keybind
    - Notification system
    - Watermark system
--]]

local FSLibrary = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Theme Configuration
local Theme = {
    Background = Color3.fromRGB(12, 12, 14),
    Sidebar = Color3.fromRGB(17, 17, 19),
    Header = Color3.fromRGB(12, 12, 14),
    Element = Color3.fromRGB(17, 17, 19),
    ElementHover = Color3.fromRGB(22, 22, 26),
    Accent = Color3.fromRGB(59, 130, 246),
    AccentDark = Color3.fromRGB(29, 78, 216),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(161, 161, 170),
    TextDarker = Color3.fromRGB(113, 113, 122),
    Border = Color3.fromRGB(39, 39, 42),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(234, 179, 8),
    Error = Color3.fromRGB(239, 68, 68)
}

-- Lucide Icon Map (Roblox Asset IDs)
local Icons = {
    Home = "rbxassetid://7733960981",
    Settings = "rbxassetid://7734053495",
    Shield = "rbxassetid://7734053495",
    Crosshair = "rbxassetid://7733715052",
    Eye = "rbxassetid://7733717504",
    Zap = "rbxassetid://7734068530",
    Layers = "rbxassetid://7733942155",
    Code = "rbxassetid://7733715052",
    User = "rbxassetid://7734057859",
    Save = "rbxassetid://7734007876",
    RefreshCw = "rbxassetid://7733990134",
    X = "rbxassetid://7734068530",
    ChevronDown = "rbxassetid://7734053495",
    Check = "rbxassetid://7733715052"
}

-- Utility Functions
local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
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

local function Tween(object, properties, duration, style, direction)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function GetIcon(iconName)
    return Icons[iconName] or Icons.Home
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    
    handle = handle or frame
    
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

-- Main Library
function FSLibrary.new(config)
    config = config or {}
    local windowName = config.Name or "FriendShip.Lua"
    local windowSize = config.Size or UDim2.new(0, 900, 0, 600)
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    
    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "FSLibrary",
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Container
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -450, 0.5, -300),
        Size = windowSize,
        ClipsDescendants = true
    })
    
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 0)})
    
    -- Top Accent Line
    local AccentLine = Create("Frame", {
        Name = "AccentLine",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 1)
    })
    
    Create("UIGradient", {
        Parent = AccentLine,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
    })
    
    -- Border
    Create("UIStroke", {
        Parent = MainFrame,
        Color = Theme.Border,
        Thickness = 1
    })
    
    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 180, 1, 0)
    })
    
    Create("UIStroke", {
        Parent = Sidebar,
        Color = Theme.Border,
        Thickness = 1
    })
    
    -- Sidebar Header (Title)
    local SidebarHeader = Create("Frame", {
        Name = "SidebarHeader",
        Parent = Sidebar,
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 60)
    })
    
    Create("UIStroke", {
        Parent = SidebarHeader,
        Color = Theme.Border,
        Thickness = 1
    })
    
    -- Title: FRIENDSHIP.LUA (Not Italic!)
    local TitleContainer = Create("Frame", {
        Parent = SidebarHeader,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0)
    })
    
    local TitleMain = Create("TextLabel", {
        Name = "TitleMain",
        Parent = TitleContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0.5, -10),
        Size = UDim2.new(0, 100, 0, 20),
        Font = Enum.Font.GothamBold, -- NOT italic
        Text = "FRIENDSHIP",
        TextColor3 = Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local TitleSub = Create("TextLabel", {
        Name = "TitleSub",
        Parent = TitleContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 115, 0.5, -10),
        Size = UDim2.new(0, 40, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = ".LUA",
        TextColor3 = Theme.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Tab Container
    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -140),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.TextDarker,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })
    
    Create("UIPadding", {
        Parent = TabContainer,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8)
    })
    
    -- Sidebar Footer (Game Info)
    local SidebarFooter = Create("Frame", {
        Name = "SidebarFooter",
        Parent = Sidebar,
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -80),
        Size = UDim2.new(1, 0, 0, 80)
    })
    
    Create("UIStroke", {
        Parent = SidebarFooter,
        Color = Theme.Border,
        Thickness = 1
    })
    
    -- Game Name (NO ICON)
    local GameName = Create("TextLabel", {
        Parent = SidebarFooter,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0.5, -14),
        Size = UDim2.new(1, -32, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "Unknown Game",
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
    
    -- Try to get game name safely
    pcall(function()
        GameName.Text = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    
    local UserRank = Create("TextLabel", {
        Parent = SidebarFooter,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0.5, 4),
        Size = UDim2.new(1, -32, 0, 14),
        Font = Enum.Font.GothamBold,
        Text = "Developer",
        TextColor3 = Theme.Accent,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Content Area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(9, 9, 11),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 180, 0, 0),
        Size = UDim2.new(1, -180, 1, 0)
    })
    
    -- Content Header
    local ContentHeader = Create("Frame", {
        Name = "ContentHeader",
        Parent = ContentArea,
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 60)
    })
    
    Create("UIStroke", {
        Parent = ContentHeader,
        Color = Theme.Border,
        Thickness = 1
    })
    
    local TabTitle = Create("TextLabel", {
        Name = "TabTitle",
        Parent = ContentHeader,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0.5, -8),
        Size = UDim2.new(0.5, 0, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "LEGIT",
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local ToggleHint = Create("Frame", {
        Parent = ContentHeader,
        BackgroundColor3 = Theme.Element,
        Position = UDim2.new(1, -160, 0.5, -12),
        Size = UDim2.new(0, 140, 0, 24)
    })
    
    Create("UICorner", {Parent = ToggleHint, CornerRadius = UDim.new(0, 2)})
    Create("UIStroke", {Parent = ToggleHint, Color = Theme.Border, Thickness = 1})
    
    Create("TextLabel", {
        Parent = ToggleHint,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Code,
        Text = "[RShift Toggle UI]",
        TextColor3 = Theme.TextDarker,
        TextSize = 10
    })
    
    -- Content Container
    local ContentContainer = Create("ScrollingFrame", {
        Name = "ContentContainer",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -92),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.TextDarker,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    Create("UIPadding", {
        Parent = ContentContainer,
        PaddingLeft = UDim.new(0, 24),
        PaddingRight = UDim.new(0, 24),
        PaddingTop = UDim.new(0, 24),
        PaddingBottom = UDim.new(0, 24)
    })
    
    -- Status Bar
    local StatusBar = Create("Frame", {
        Name = "StatusBar",
        Parent = ContentArea,
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -32),
        Size = UDim2.new(1, 0, 0, 32)
    })
    
    Create("UIStroke", {
        Parent = StatusBar,
        Color = Theme.Border,
        Thickness = 1
    })
    
    Create("TextLabel", {
        Parent = StatusBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Enum.Font.Code,
        Text = "Made by FS Team",
        TextColor3 = Theme.TextDarker,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Create("TextLabel", {
        Parent = StatusBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0.5, -16, 1, 0),
        Font = Enum.Font.Code,
        Text = "BUILD: " .. os.date("%y%m%d") .. ".release",
        TextColor3 = Theme.TextDarker,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    -- Make Draggable
    MakeDraggable(MainFrame, ContentHeader)
    MakeDraggable(MainFrame, SidebarHeader)
    
    -- Toggle UI Visibility
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    -- Notification System
    local NotificationContainer = Create("Frame", {
        Name = "NotificationContainer",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -300, 0, 20),
        Size = UDim2.new(0, 280, 1, -40),
        ClipsDescendants = false
    })
    
    Create("UIListLayout", {
        Parent = NotificationContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Right
    })
    
    -- Watermark
    local Watermark = Create("Frame", {
        Name = "Watermark",
        Parent = ScreenGui,
        BackgroundColor3 = Color3.fromRGB(12, 12, 14),
        BackgroundTransparency = 0.1,
        Position = UDim2.new(0, 20, 0, 20),
        Size = UDim2.new(0, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.X
    })
    
    Create("UICorner", {Parent = Watermark, CornerRadius = UDim.new(0, 2)})
    Create("UIStroke", {Parent = Watermark, Color = Theme.Border, Thickness = 1})
    
    local WatermarkAccent = Create("Frame", {
        Parent = Watermark,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 2, 1, 0)
    })
    
    local WatermarkLayout = Create("UIListLayout", {
        Parent = Watermark,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0)
    })
    
    local function AddWatermarkItem(text, color)
        local item = Create("Frame", {
            Parent = Watermark,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X
        })
        
        Create("UIPadding", {
            Parent = item,
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        })
        
        local label = Create("TextLabel", {
            Name = "TextLabel",
            Parent = item,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamBold,
            Text = text,
            TextColor3 = color or Theme.Text,
            TextSize = 11
        })
        
        -- Separator
        Create("Frame", {
            Parent = item,
            BackgroundColor3 = Theme.Border,
            Position = UDim2.new(1, 0, 0.2, 0),
            Size = UDim2.new(0, 1, 0.6, 0)
        })
        
        item.Label = label
        return item
    end
    
    -- Default watermark items
    AddWatermarkItem("FRIENDSHIP.LUA", Theme.Text)
    AddWatermarkItem("Dev", Theme.Accent)
    
    local fpsItem = AddWatermarkItem("0 FPS", Theme.Success)
    local pingItem = AddWatermarkItem("0 MS", Theme.Accent)
    
    -- Update watermark
    task.spawn(function()
        while ScreenGui and ScreenGui.Parent do
            local success, fps = pcall(function()
                return math.floor(1 / RunService.RenderStepped:Wait())
            end)
            if success and fpsItem and fpsItem.Label then
                fpsItem.Label.Text = tostring(fps) .. " FPS"
            end
            
            local pingSuccess, ping = pcall(function()
                return math.floor(Player:GetNetworkPing() * 1000)
            end)
            if pingSuccess and pingItem and pingItem.Label then
                pingItem.Label.Text = tostring(ping) .. " MS"
            end
            
            task.wait(0.1)
        end
    end)
    
    -- Window Object
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    
    -- Notification Method
    function Window:Notify(config)
        config = config or {}
        local title = config.Title or "Notification"
        local message = config.Message or ""
        local duration = config.Duration or 4
        local notifType = config.Type or "info"
        
        local typeColors = {
            info = Theme.Accent,
            success = Theme.Success,
            warn = Theme.Warning,
            error = Theme.Error
        }
        
        local notif = Create("Frame", {
            Parent = NotificationContainer,
            BackgroundColor3 = Color3.fromRGB(17, 17, 19),
            BackgroundTransparency = 0.05,
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(1, 0, 0, 0)
        })
        
        Create("UICorner", {Parent = notif, CornerRadius = UDim.new(0, 2)})
        Create("UIStroke", {Parent = notif, Color = Theme.Border, Thickness = 1})
        
        Create("Frame", {
            Parent = notif,
            BackgroundColor3 = typeColors[notifType] or Theme.Accent,
            Size = UDim2.new(0, 2, 1, 0)
        })
        
        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 10),
            Size = UDim2.new(1, -20, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = title:upper(),
            TextColor3 = Theme.Text,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 28),
            Size = UDim2.new(1, -20, 0, 24),
            Font = Enum.Font.Code,
            Text = message,
            TextColor3 = Theme.TextDark,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })
        
        -- Animate in
        Tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        -- Remove after duration
        task.delay(duration, function()
            Tween(notif, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1}, 0.3)
            task.wait(0.3)
            notif:Destroy()
        end)
    end
    
    -- Add Tab Method
    function Window:AddTab(config)
        config = config or {}
        local tabName = config.Name or "Tab"
        local tabIcon = config.Icon or "Home"
        
        local Tab = {}
        Tab.Groups = {}
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Font = Enum.Font.GothamBold,
            Text = "",
            AutoButtonColor = false
        })
        
        Create("UICorner", {Parent = TabButton, CornerRadius = UDim.new(0, 4)})
        
        local TabIndicator = Create("Frame", {
            Parent = TabButton,
            BackgroundColor3 = Theme.Accent,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 2, 1, 0),
            Visible = false
        })
        
        local TabIconImg = Create("ImageLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = GetIcon(tabIcon),
            ImageColor3 = Theme.TextDarker
        })
        
        local TabLabel = Create("TextLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 36, 0, 0),
            Size = UDim2.new(1, -44, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = tabName:upper(),
            TextColor3 = Theme.TextDarker,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Tab Content Frame
        local TabContent = Create("Frame", {
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false
        })
        
        local ContentGrid = Create("UIGridLayout", {
            Parent = TabContent,
            CellPadding = UDim2.new(0, 16, 0, 16),
            CellSize = UDim2.new(0.5, -8, 0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        -- Tab Selection Logic
        local function SelectTab()
            -- Deselect all tabs
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundTransparency = 1
                tab.Indicator.Visible = false
                tab.Icon.ImageColor3 = Theme.TextDarker
                tab.Label.TextColor3 = Theme.TextDarker
                tab.Content.Visible = false
            end
            
            -- Select this tab
            TabButton.BackgroundTransparency = 0.9
            TabButton.BackgroundColor3 = Theme.Accent
            TabIndicator.Visible = true
            TabIconImg.ImageColor3 = Theme.Accent
            TabLabel.TextColor3 = Theme.Text
            TabContent.Visible = true
            TabTitle.Text = tabName:upper()
            
            Window.ActiveTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        TabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.95}, 0.1)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.1)
            end
        end)
        
        -- Store tab data
        Tab.Button = TabButton
        Tab.Indicator = TabIndicator
        Tab.Icon = TabIconImg
        Tab.Label = TabLabel
        Tab.Content = TabContent
        Tab.Select = SelectTab
        
        table.insert(Window.Tabs, Tab)
        
        -- Select first tab by default
        if #Window.Tabs == 1 then
            SelectTab()
        end
        
        -- Add Group Method
        function Tab:AddGroup(groupName)
            local Group = {}
            
            local GroupFrame = Create("Frame", {
                Parent = TabContent,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0.5, -8, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            Create("UICorner", {Parent = GroupFrame, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = GroupFrame, Color = Theme.Border, Thickness = 1})
            
            local GroupTitle = Create("Frame", {
                Parent = GroupFrame,
                BackgroundColor3 = Theme.Element,
                Position = UDim2.new(0, 12, 0, -10),
                Size = UDim2.new(0, 0, 0, 20),
                AutomaticSize = Enum.AutomaticSize.X
            })
            
            Create("UIPadding", {
                Parent = GroupTitle,
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6)
            })
            
            Create("UIStroke", {Parent = GroupTitle, Color = Theme.Border, Thickness = 1})
            
            Create("TextLabel", {
                Parent = GroupTitle,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                Font = Enum.Font.GothamBold,
                Text = groupName:upper(),
                TextColor3 = Theme.TextDark,
                TextSize = 10
            })
            
            local GroupContent = Create("Frame", {
                Parent = GroupFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 16),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            Create("UIPadding", {
                Parent = GroupContent,
                PaddingLeft = UDim.new(0, 16),
                PaddingRight = UDim.new(0, 16),
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 16)
            })
            
            Create("UIListLayout", {
                Parent = GroupContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 12)
            })
            
            -- Toggle (No White Dot Style)
            function Group:AddToggle(config)
                config = config or {}
                local toggleName = config.Name or "Toggle"
                local default = config.Default or false
                local callback = config.Callback or function() end
                
                local value = default
                
                local ToggleFrame = Create("Frame", {
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -24, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = toggleName,
                    TextColor3 = value and Theme.Text or Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ToggleBox = Create("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = value and Theme.Accent or Theme.Background,
                    Position = UDim2.new(1, -14, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14)
                })
                
                Create("UICorner", {Parent = ToggleBox, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {
                    Parent = ToggleBox, 
                    Color = value and Theme.Accent or Theme.TextDarker, 
                    Thickness = 1
                })
                
                -- NO white dot inside - just solid fill
                
                local ToggleButton = Create("TextButton", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                ToggleButton.MouseButton1Click:Connect(function()
                    value = not value
                    
                    Tween(ToggleBox, {BackgroundColor3 = value and Theme.Accent or Theme.Background}, 0.15)
                    ToggleBox:FindFirstChildOfClass("UIStroke").Color = value and Theme.Accent or Theme.TextDarker
                    ToggleLabel.TextColor3 = value and Theme.Text or Theme.TextDark
                    
                    callback(value)
                end)
                
                local Toggle = {}
                function Toggle:Set(newValue)
                    value = newValue
                    Tween(ToggleBox, {BackgroundColor3 = value and Theme.Accent or Theme.Background}, 0.15)
                    ToggleBox:FindFirstChildOfClass("UIStroke").Color = value and Theme.Accent or Theme.TextDarker
                    ToggleLabel.TextColor3 = value and Theme.Text or Theme.TextDark
                    callback(value)
                end
                function Toggle:Get() return value end
                
                return Toggle
            end
            
            -- Slider with Keyboard Input
            function Group:AddSlider(config)
                config = config or {}
                local sliderName = config.Name or "Slider"
                local min = config.Min or 0
                local max = config.Max or 100
                local default = config.Default or min
                local suffix = config.Suffix or ""
                local callback = config.Callback or function() end
                
                local value = default
                
                local SliderFrame = Create("Frame", {
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36)
                })
                
                local SliderLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -60, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = sliderName,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Input Box for direct value entry
                local ValueInput = Create("TextBox", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.Background,
                    Position = UDim2.new(1, -50, 0, 0),
                    Size = UDim2.new(0, 50, 0, 16),
                    Font = Enum.Font.Code,
                    Text = tostring(value) .. suffix,
                    TextColor3 = Theme.Text,
                    TextSize = 10,
                    ClearTextOnFocus = false
                })
                
                Create("UICorner", {Parent = ValueInput, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = ValueInput, Color = Theme.Border, Thickness = 1})
                
                local SliderBG = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.Background,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 6)
                })
                
                Create("UICorner", {Parent = SliderBG, CornerRadius = UDim.new(0, 2)})
                
                local SliderFill = Create("Frame", {
                    Parent = SliderBG,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                })
                
                Create("UICorner", {Parent = SliderFill, CornerRadius = UDim.new(0, 2)})
                
                local SliderButton = Create("TextButton", {
                    Parent = SliderBG,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                local function UpdateSlider(newValue)
                    newValue = math.clamp(newValue, min, max)
                    value = math.floor(newValue)
                    local percentage = (value - min) / (max - min)
                    Tween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
                    ValueInput.Text = tostring(value) .. suffix
                    callback(value)
                end
                
                local dragging = false
                
                SliderButton.MouseButton1Down:Connect(function()
                    dragging = true
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percentage = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                        local newValue = min + (max - min) * percentage
                        UpdateSlider(newValue)
                    end
                end)
                
                -- Keyboard input handling
                ValueInput.FocusLost:Connect(function(enterPressed)
                    local inputText = ValueInput.Text:gsub(suffix, "")
                    local num = tonumber(inputText)
                    if num then
                        UpdateSlider(num)
                    else
                        ValueInput.Text = tostring(value) .. suffix
                    end
                end)
                
                local Slider = {}
                function Slider:Set(newValue) UpdateSlider(newValue) end
                function Slider:Get() return value end
                
                return Slider
            end
            
            -- Dropdown (Single Select)
            function Group:AddDropdown(config)
                config = config or {}
                local dropdownName = config.Name or "Dropdown"
                local options = config.Options or {}
                local default = config.Default or (options[1] or "")
                local callback = config.Callback or function() end
                
                local value = default
                local open = false
                
                local DropdownFrame = Create("Frame", {
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 38),
                    ClipsDescendants = false
                })
                
                Create("TextLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = dropdownName,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local DropdownButton = Create("TextButton", {
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.Background,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    AutoButtonColor = false
                })
                
                Create("UICorner", {Parent = DropdownButton, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = DropdownButton, Color = Theme.Border, Thickness = 1})
                
                local SelectedLabel = Create("TextLabel", {
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -30, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = value,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                Create("TextLabel", {
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20, 0, 0),
                    Size = UDim2.new(0, 14, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Theme.TextDarker,
                    TextSize = 8
                })
                
                local OptionsContainer = Create("Frame", {
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.Background,
                    Position = UDim2.new(0, 0, 0, 48),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    ZIndex = 10
                })
                
                Create("UICorner", {Parent = OptionsContainer, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = OptionsContainer, Color = Theme.Border, Thickness = 1})
                
                local OptionsLayout = Create("UIListLayout", {
                    Parent = OptionsContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                for _, option in ipairs(options) do
                    local OptionButton = Create("TextButton", {
                        Parent = OptionsContainer,
                        BackgroundColor3 = Theme.Element,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 26),
                        Font = Enum.Font.Gotham,
                        Text = option,
                        TextColor3 = Theme.TextDark,
                        TextSize = 11,
                        ZIndex = 11
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 0.5}, 0.1)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 1}, 0.1)
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        value = option
                        SelectedLabel.Text = option
                        open = false
                        Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        callback(value)
                    end)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    open = not open
                    local targetSize = open and UDim2.new(1, 0, 0, #options * 26) or UDim2.new(1, 0, 0, 0)
                    Tween(OptionsContainer, {Size = targetSize}, 0.2)
                end)
                
                local Dropdown = {}
                function Dropdown:Set(newValue)
                    value = newValue
                    SelectedLabel.Text = newValue
                    callback(value)
                end
                function Dropdown:Get() return value end
                
                return Dropdown
            end
            
            -- Multi Dropdown
            function Group:AddMultiDropdown(config)
                config = config or {}
                local dropdownName = config.Name or "Multi Dropdown"
                local options = config.Options or {}
                local default = config.Default or {}
                local callback = config.Callback or function() end
                
                local selected = {}
                for _, v in ipairs(default) do
                    selected[v] = true
                end
                local open = false
                
                local function GetSelectedText()
                    local items = {}
                    for _, opt in ipairs(options) do
                        if selected[opt] then
                            table.insert(items, opt)
                        end
                    end
                    if #items == 0 then return "None" end
                    return table.concat(items, ", ")
                end
                
                local MultiDropFrame = Create("Frame", {
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 38),
                    ClipsDescendants = false
                })
                
                Create("TextLabel", {
                    Parent = MultiDropFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = dropdownName,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local DropdownButton = Create("TextButton", {
                    Parent = MultiDropFrame,
                    BackgroundColor3 = Theme.Background,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    AutoButtonColor = false
                })
                
                Create("UICorner", {Parent = DropdownButton, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = DropdownButton, Color = Theme.Border, Thickness = 1})
                
                local SelectedLabel = Create("TextLabel", {
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -30, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = GetSelectedText(),
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                })
                
                Create("TextLabel", {
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20, 0, 0),
                    Size = UDim2.new(0, 14, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Theme.TextDarker,
                    TextSize = 8
                })
                
                local OptionsContainer = Create("Frame", {
                    Parent = MultiDropFrame,
                    BackgroundColor3 = Theme.Background,
                    Position = UDim2.new(0, 0, 0, 48),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    ZIndex = 10
                })
                
                Create("UICorner", {Parent = OptionsContainer, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = OptionsContainer, Color = Theme.Border, Thickness = 1})
                
                Create("UIListLayout", {
                    Parent = OptionsContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                for _, option in ipairs(options) do
                    local OptionFrame = Create("Frame", {
                        Parent = OptionsContainer,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 26),
                        ZIndex = 11
                    })
                    
                    local OptionCheck = Create("Frame", {
                        Parent = OptionFrame,
                        BackgroundColor3 = selected[option] and Theme.Accent or Theme.Background,
                        Position = UDim2.new(0, 8, 0.5, -6),
                        Size = UDim2.new(0, 12, 0, 12),
                        ZIndex = 12
                    })
                    
                    Create("UICorner", {Parent = OptionCheck, CornerRadius = UDim.new(0, 2)})
                    Create("UIStroke", {
                        Parent = OptionCheck, 
                        Color = selected[option] and Theme.Accent or Theme.TextDarker, 
                        Thickness = 1
                    })
                    
                    local OptionLabel = Create("TextLabel", {
                        Parent = OptionFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 28, 0, 0),
                        Size = UDim2.new(1, -36, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = option,
                        TextColor3 = Theme.TextDark,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 12
                    })
                    
                    local OptionButton = Create("TextButton", {
                        Parent = OptionFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = "",
                        ZIndex = 13
                    })
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        selected[option] = not selected[option]
                        Tween(OptionCheck, {BackgroundColor3 = selected[option] and Theme.Accent or Theme.Background}, 0.1)
                        OptionCheck:FindFirstChildOfClass("UIStroke").Color = selected[option] and Theme.Accent or Theme.TextDarker
                        SelectedLabel.Text = GetSelectedText()
                        
                        local result = {}
                        for opt, sel in pairs(selected) do
                            if sel then table.insert(result, opt) end
                        end
                        callback(result)
                    end)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    open = not open
                    local targetSize = open and UDim2.new(1, 0, 0, #options * 26) or UDim2.new(1, 0, 0, 0)
                    Tween(OptionsContainer, {Size = targetSize}, 0.2)
                end)
                
                local MultiDrop = {}
                function MultiDrop:Set(newSelected)
                    selected = {}
                    for _, v in ipairs(newSelected) do selected[v] = true end
                    SelectedLabel.Text = GetSelectedText()
                    callback(newSelected)
                end
                function MultiDrop:Get()
                    local result = {}
                    for opt, sel in pairs(selected) do
                        if sel then table.insert(result, opt) end
                    end
                    return result
                end
                
                return MultiDrop
            end
            
            -- Color Picker
            function Group:AddColorPicker(config)
                config = config or {}
                local pickerName = config.Name or "Color"
                local default = config.Default or Color3.fromRGB(59, 130, 246)
                local callback = config.Callback or function() end
                
                local r, g, b = math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)
                local open = false
                
                local PickerFrame = Create("Frame", {
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    ClipsDescendants = false
                })
                
                Create("TextLabel", {
                    Parent = PickerFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -30, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = pickerName,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ColorPreview = Create("TextButton", {
                    Parent = PickerFrame,
                    BackgroundColor3 = default,
                    Position = UDim2.new(1, -24, 0.5, -6),
                    Size = UDim2.new(0, 24, 0, 12),
                    Text = "",
                    AutoButtonColor = false
                })
                
                Create("UICorner", {Parent = ColorPreview, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = ColorPreview, Color = Theme.Border, Thickness = 1})
                
                local PickerPanel = Create("Frame", {
                    Parent = PickerFrame,
                    BackgroundColor3 = Theme.Background,
                    Position = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    ZIndex = 20
                })
                
                Create("UICorner", {Parent = PickerPanel, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = PickerPanel, Color = Theme.Border, Thickness = 1})
                
                Create("UIPadding", {
                    Parent = PickerPanel,
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingTop = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 10)
                })
                
                local function CreateColorSlider(name, value, max, color, yPos)
                    local SliderFrame = Create("Frame", {
                        Parent = PickerPanel,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, yPos),
                        Size = UDim2.new(1, 0, 0, 20),
                        ZIndex = 21
                    })
                    
                    Create("TextLabel", {
                        Parent = SliderFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 20, 1, 0),
                        Font = Enum.Font.GothamBold,
                        Text = name,
                        TextColor3 = color,
                        TextSize = 10,
                        ZIndex = 22
                    })
                    
                    local SliderBG = Create("Frame", {
                        Parent = SliderFrame,
                        BackgroundColor3 = Theme.Element,
                        Position = UDim2.new(0, 28, 0.5, -3),
                        Size = UDim2.new(1, -70, 0, 6),
                        ZIndex = 22
                    })
                    
                    Create("UICorner", {Parent = SliderBG, CornerRadius = UDim.new(0, 2)})
                    
                    local SliderFill = Create("Frame", {
                        Parent = SliderBG,
                        BackgroundColor3 = color,
                        Size = UDim2.new(value / max, 0, 1, 0),
                        ZIndex = 23
                    })
                    
                    Create("UICorner", {Parent = SliderFill, CornerRadius = UDim.new(0, 2)})
                    
                    local ValueInput = Create("TextBox", {
                        Parent = SliderFrame,
                        BackgroundColor3 = Theme.Element,
                        Position = UDim2.new(1, -35, 0, 0),
                        Size = UDim2.new(0, 35, 1, 0),
                        Font = Enum.Font.Code,
                        Text = tostring(value),
                        TextColor3 = Theme.Text,
                        TextSize = 10,
                        ClearTextOnFocus = false,
                        ZIndex = 22
                    })
                    
                    Create("UICorner", {Parent = ValueInput, CornerRadius = UDim.new(0, 2)})
                    
                    return {
                        Fill = SliderFill,
                        Input = ValueInput,
                        BG = SliderBG
                    }
                end
                
                local rSlider = CreateColorSlider("R", r, 255, Color3.fromRGB(239, 68, 68), 0)
                local gSlider = CreateColorSlider("G", g, 255, Color3.fromRGB(34, 197, 94), 26)
                local bSlider = CreateColorSlider("B", b, 255, Color3.fromRGB(59, 130, 246), 52)
                
                local function UpdateColor()
                    local newColor = Color3.fromRGB(r, g, b)
                    ColorPreview.BackgroundColor3 = newColor
                    rSlider.Fill.Size = UDim2.new(r / 255, 0, 1, 0)
                    gSlider.Fill.Size = UDim2.new(g / 255, 0, 1, 0)
                    bSlider.Fill.Size = UDim2.new(b / 255, 0, 1, 0)
                    rSlider.Input.Text = tostring(r)
                    gSlider.Input.Text = tostring(g)
                    bSlider.Input.Text = tostring(b)
                    callback(newColor)
                end
                
                local function SetupSlider(slider, getValue, setValue)
                    local dragging = false
                    
                    local SliderButton = Create("TextButton", {
                        Parent = slider.BG,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = "",
                        ZIndex = 24
                    })
                    
                    SliderButton.MouseButton1Down:Connect(function()
                        dragging = true
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local percentage = math.clamp((input.Position.X - slider.BG.AbsolutePosition.X) / slider.BG.AbsoluteSize.X, 0, 1)
                            setValue(math.floor(255 * percentage))
                            UpdateColor()
                        end
                    end)
                    
                    slider.Input.FocusLost:Connect(function()
                        local num = tonumber(slider.Input.Text)
                        if num then
                            setValue(math.clamp(math.floor(num), 0, 255))
                            UpdateColor()
                        else
                            slider.Input.Text = tostring(getValue())
                        end
                    end)
                end
                
                SetupSlider(rSlider, function() return r end, function(v) r = v end)
                SetupSlider(gSlider, function() return g end, function(v) g = v end)
                SetupSlider(bSlider, function() return b end, function(v) b = v end)
                
                ColorPreview.MouseButton1Click:Connect(function()
                    open = not open
                    Tween(PickerPanel, {Size = UDim2.new(1, 0, 0, open and 86 or 0)}, 0.2)
                end)
                
                local Picker = {}
                function Picker:Set(color)
                    r = math.floor(color.R * 255)
                    g = math.floor(color.G * 255)
                    b = math.floor(color.B * 255)
                    UpdateColor()
                end
                function Picker:Get()
                    return Color3.fromRGB(r, g, b)
                end
                
                return Picker
            end
            
            -- Button
            function Group:AddButton(config)
                config = config or {}
                local buttonName = config.Name or "Button"
                local callback = config.Callback or function() end
                
                local ButtonFrame = Create("TextButton", {
                    Parent = GroupContent,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.GothamBold,
                    Text = buttonName,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    AutoButtonColor = false
                })
                
                Create("UICorner", {Parent = ButtonFrame, CornerRadius = UDim.new(0, 4)})
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.AccentDark}, 0.1)
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, 0.1)
                end)
                
                ButtonFrame.MouseButton1Click:Connect(callback)
            end
            
            -- TextBox
            function Group:AddTextBox(config)
                config = config or {}
                local textboxName = config.Name or "TextBox"
                local default = config.Default or ""
                local placeholder = config.Placeholder or "Enter text..."
                local callback = config.Callback or function() end
                
                local TextBoxFrame = Create("Frame", {
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 38)
                })
                
                Create("TextLabel", {
                    Parent = TextBoxFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = textboxName,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Input = Create("TextBox", {
                    Parent = TextBoxFrame,
                    BackgroundColor3 = Theme.Background,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.Gotham,
                    Text = default,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Theme.TextDarker,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    ClearTextOnFocus = false
                })
                
                Create("UICorner", {Parent = Input, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = Input, Color = Theme.Border, Thickness = 1})
                Create("UIPadding", {Parent = Input, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
                
                Input.FocusLost:Connect(function(enterPressed)
                    callback(Input.Text, enterPressed)
                end)
                
                local TextBox = {}
                function TextBox:Set(text) Input.Text = text end
                function TextBox:Get() return Input.Text end
                
                return TextBox
            end
            
            -- Label
            function Group:AddLabel(text)
                Create("TextLabel", {
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDarker,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            -- Keybind
            function Group:AddKeybind(config)
                config = config or {}
                local keybindName = config.Name or "Keybind"
                local default = config.Default or Enum.KeyCode.Unknown
                local callback = config.Callback or function() end
                
                local key = default
                local listening = false
                
                local KeybindFrame = Create("Frame", {
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })
                
                Create("TextLabel", {
                    Parent = KeybindFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = keybindName,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local KeyButton = Create("TextButton", {
                    Parent = KeybindFrame,
                    BackgroundColor3 = Theme.Background,
                    Position = UDim2.new(1, -55, 0, 0),
                    Size = UDim2.new(0, 55, 1, 0),
                    Font = Enum.Font.Code,
                    Text = key.Name ~= "Unknown" and key.Name or "None",
                    TextColor3 = Theme.Text,
                    TextSize = 10,
                    AutoButtonColor = false
                })
                
                Create("UICorner", {Parent = KeyButton, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = KeyButton, Color = Theme.Border, Thickness = 1})
                
                KeyButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeyButton.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        key = input.KeyCode
                        KeyButton.Text = key.Name
                    elseif not processed and input.KeyCode == key then
                        callback()
                    end
                end)
                
                local Keybind = {}
                function Keybind:Set(newKey)
                    key = newKey
                    KeyButton.Text = key.Name
                end
                function Keybind:Get() return key end
                
                return Keybind
            end
            
            table.insert(Tab.Groups, Group)
            return Group
        end
        
        return Tab
    end
    
    -- Destroy Method
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    -- Set Game Info
    function Window:SetGameInfo(gameName, userRank)
        GameName.Text = gameName
        UserRank.Text = userRank
    end
    
    return Window
end

return FSLibrary
