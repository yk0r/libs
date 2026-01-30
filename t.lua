--[[
    ██████╗ ███████╗   ██╗     ██╗   ██╗ █████╗ 
    ██╔════╝ ██╔════╝   ██║     ██║   ██║██╔══██╗
    █████╗   ███████╗   ██║     ██║   ██║███████║
    ██╔══╝   ╚════██║   ██║     ██║   ██║██╔══██║
    ██║      ███████║██╗███████╗╚██████╔╝██║  ██║
    ╚═╝      ╚══════╝╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
    
    FriendShip.Lua UI Library v2.0
    Professional Roblox Script GUI
    
    Usage:
        local FS = loadstring(game:HttpGet("URL"))()
        local Window = FS:CreateWindow({ ... })
]]

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Theme Colors
local Theme = {
    Background = Color3.fromRGB(12, 12, 12),
    Sidebar = Color3.fromRGB(18, 18, 18),
    Container = Color3.fromRGB(22, 22, 22),
    Element = Color3.fromRGB(28, 28, 28),
    ElementHover = Color3.fromRGB(35, 35, 35),
    Border = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(59, 130, 246),
    AccentDark = Color3.fromRGB(40, 100, 200),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(150, 150, 150),
    TextDarker = Color3.fromRGB(100, 100, 100),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(234, 179, 8),
    Error = Color3.fromRGB(239, 68, 68)
}

-- Icon Map (Lucide-style)
local Icons = {
    Home = "rbxassetid://7733960981",
    Crosshair = "rbxassetid://7734010953",
    Eye = "rbxassetid://7734019851",
    Settings = "rbxassetid://7734053495",
    Code = "rbxassetid://7733968588",
    Sword = "rbxassetid://7734056902",
    Shield = "rbxassetid://7734052498",
    User = "rbxassetid://7734065992",
    Star = "rbxassetid://7734055483",
    Heart = "rbxassetid://7733985087",
    Zap = "rbxassetid://7734076175",
    Target = "rbxassetid://7734059218",
    Layers = "rbxassetid://7733996247",
    Box = "rbxassetid://7733758877",
    Circle = "rbxassetid://7733771904",
    Check = "rbxassetid://7733768677"
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

local function Tween(instance, properties, duration)
    local tween = TweenService:Create(instance, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), properties)
    tween:Play()
    return tween
end

local function GetIcon(name)
    return Icons[name] or Icons.Circle
end

local function Ripple(button)
    -- Simple hover effect
end

-- Library
local Library = {}
Library.__index = Library

function Library:CreateWindow(options)
    options = options or {}
    local windowName = options.Name or "FriendShip.Lua"
    local windowSubtitle = options.Subtitle or ".LUA"
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    local windowSize = options.Size or UDim2.new(0, 580, 0, 420)
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Visible = true
    Window.Watermark = nil
    Window.Notifications = {}
    
    -- Destroy old GUI
    if CoreGui:FindFirstChild("FSLibrary") then
        CoreGui:FindFirstChild("FSLibrary"):Destroy()
    end
    
    -- Create ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "FSLibrary",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    Window.ScreenGui = ScreenGui
    
    -- ==================== WATERMARK ====================
    local WatermarkFrame = Create("Frame", {
        Name = "Watermark",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(0, 280, 0, 32),
        Visible = false
    })
    
    -- Watermark Top Accent Line
    Create("Frame", {
        Name = "AccentLine",
        Parent = WatermarkFrame,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 2)
    })
    
    -- Watermark Border
    Create("UIStroke", {
        Parent = WatermarkFrame,
        Color = Theme.Border,
        Thickness = 1
    })
    
    local WatermarkContent = Create("Frame", {
        Name = "Content",
        Parent = WatermarkFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(1, 0, 1, -2)
    })
    
    local WatermarkText = Create("TextLabel", {
        Name = "Text",
        Parent = WatermarkContent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "FRIENDSHIP.LUA",
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Window.Watermark = {
        Frame = WatermarkFrame,
        TextLabel = WatermarkText,
        
        Show = function(self)
            WatermarkFrame.Visible = true
        end,
        
        Hide = function(self)
            WatermarkFrame.Visible = false
        end,
        
        SetText = function(self, text)
            WatermarkText.Text = text
        end,
        
        Update = function(self, data)
            -- data = { "FRIENDSHIP.LUA", "User", "60 FPS", "15ms" }
            if type(data) == "table" then
                WatermarkText.Text = table.concat(data, "  |  ")
            else
                WatermarkText.Text = tostring(data)
            end
        end
    }
    
    -- Auto-update watermark with FPS/Ping
    task.spawn(function()
        local fps = 60
        local frameCount = 0
        local lastTime = tick()
        
        RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            if tick() - lastTime >= 1 then
                fps = frameCount
                frameCount = 0
                lastTime = tick()
            end
        end)
        
        while ScreenGui and ScreenGui.Parent do
            if WatermarkFrame.Visible then
                local ping = 0
                pcall(function()
                    ping = math.floor(Player:GetNetworkPing() * 1000)
                end)
                
                local currentText = WatermarkText.Text
                if string.find(currentText, "|") then
                    local parts = string.split(currentText, "  |  ")
                    if #parts >= 1 then
                        local baseText = parts[1]
                        if #parts >= 2 then
                            baseText = parts[1] .. "  |  " .. parts[2]
                        end
                        WatermarkText.Text = baseText .. "  |  " .. fps .. " FPS  |  " .. ping .. "ms"
                    end
                end
            end
            task.wait(0.5)
        end
    end)
    
    -- ==================== NOTIFICATIONS ====================
    local NotificationContainer = Create("Frame", {
        Name = "Notifications",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 0, 15),
        Size = UDim2.new(0, 300, 1, -30),
        ClipsDescendants = false
    })
    
    Create("UIListLayout", {
        Parent = NotificationContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Right
    })
    
    function Window:Notify(options)
        options = options or {}
        local title = options.Title or "Notification"
        local message = options.Message or ""
        local duration = options.Duration or 4
        local notifyType = options.Type or "info"
        
        local accentColor = Theme.Accent
        if notifyType == "success" then
            accentColor = Theme.Success
        elseif notifyType == "warning" then
            accentColor = Theme.Warning
        elseif notifyType == "error" then
            accentColor = Theme.Error
        end
        
        local Notification = Create("Frame", {
            Name = "Notification",
            Parent = NotificationContainer,
            BackgroundColor3 = Theme.Background,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 300, 0, 70),
            ClipsDescendants = true
        })
        
        Create("UIStroke", {
            Parent = Notification,
            Color = Theme.Border,
            Thickness = 1
        })
        
        Create("UICorner", {
            Parent = Notification,
            CornerRadius = UDim.new(0, 4)
        })
        
        -- Left accent bar
        Create("Frame", {
            Name = "Accent",
            Parent = Notification,
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 3, 1, 0)
        })
        
        Create("UICorner", {
            Parent = Notification.Accent,
            CornerRadius = UDim.new(0, 4)
        })
        
        -- Title
        Create("TextLabel", {
            Name = "Title",
            Parent = Notification,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 10),
            Size = UDim2.new(1, -24, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = string.upper(title),
            TextColor3 = Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Message
        Create("TextLabel", {
            Name = "Message",
            Parent = Notification,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 30),
            Size = UDim2.new(1, -24, 0, 30),
            Font = Enum.Font.Gotham,
            Text = message,
            TextColor3 = Theme.TextDark,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true
        })
        
        -- Progress bar
        local ProgressBar = Create("Frame", {
            Name = "Progress",
            Parent = Notification,
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(1, 0, 0, 2)
        })
        
        -- Animate in
        Notification.Position = UDim2.new(1, 50, 0, 0)
        Tween(Notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        -- Animate progress
        Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration)
        
        -- Remove after duration
        task.delay(duration, function()
            Tween(Notification, {Position = UDim2.new(1, 50, 0, 0)}, 0.3)
            task.wait(0.3)
            Notification:Destroy()
        end)
    end
    
    -- ==================== MAIN WINDOW ====================
    local MainFrame = Create("Frame", {
        Name = "MainWindow",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -290, 0.5, -210),
        Size = windowSize,
        ClipsDescendants = true
    })
    
    -- Window Border
    Create("UIStroke", {
        Parent = MainFrame,
        Color = Theme.Border,
        Thickness = 1
    })
    
    -- Top Accent Bar (Blue Line)
    Create("Frame", {
        Name = "TopAccent",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 2)
    })
    
    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(0, 160, 1, -2)
    })
    
    -- Sidebar Right Border
    Create("Frame", {
        Name = "RightBorder",
        Parent = Sidebar,
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0)
    })
    
    -- Sidebar Header
    local SidebarHeader = Create("Frame", {
        Name = "Header",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 50)
    })
    
    -- Window Title (FRIENDSHIP.LUA)
    local TitleContainer = Create("Frame", {
        Name = "TitleContainer",
        Parent = SidebarHeader,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -15, 1, 0)
    })
    
    local TitleMain = Create("TextLabel", {
        Name = "TitleMain",
        Parent = TitleContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -8),
        Size = UDim2.new(0, 90, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "FRIENDSHIP",
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local TitleSub = Create("TextLabel", {
        Name = "TitleSub",
        Parent = TitleContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 90, 0.5, -8),
        Size = UDim2.new(0, 40, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = ".LUA",
        TextColor3 = Theme.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Header Border
    Create("Frame", {
        Name = "HeaderBorder",
        Parent = SidebarHeader,
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 1, -1),
        Size = UDim2.new(1, -20, 0, 1)
    })
    
    -- Tab Container
    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 55),
        Size = UDim2.new(1, 0, 1, -130),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    Create("UIPadding", {
        Parent = TabContainer,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 5)
    })
    
    -- Sidebar Footer (Game Info - Customizable)
    local SidebarFooter = Create("Frame", {
        Name = "Footer",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -75),
        Size = UDim2.new(1, 0, 0, 75)
    })
    
    -- Footer Border
    Create("Frame", {
        Name = "FooterBorder",
        Parent = SidebarFooter,
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 0, 1)
    })
    
    -- Game Info Container
    local GameInfoContainer = Create("Frame", {
        Name = "GameInfo",
        Parent = SidebarFooter,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 12),
        Size = UDim2.new(1, -30, 0, 50)
    })
    
    local GameNameLabel = Create("TextLabel", {
        Name = "GameName",
        Parent = GameInfoContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = "Unknown Game",
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
    
    local UserRankLabel = Create("TextLabel", {
        Name = "UserRank",
        Parent = GameInfoContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.GothamMedium,
        Text = "Free",
        TextColor3 = Theme.Accent,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Set default game name
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        if info and info.Name then
            GameNameLabel.Text = info.Name
        end
    end)
    
    -- Game Info API
    Window.GameInfo = {
        SetGame = function(self, gameName)
            GameNameLabel.Text = gameName or "Unknown Game"
        end,
        
        SetRank = function(self, rank)
            UserRankLabel.Text = rank or "Free"
        end,
        
        Set = function(self, gameName, rank)
            GameNameLabel.Text = gameName or "Unknown Game"
            UserRankLabel.Text = rank or "Free"
        end
    }
    
    -- Content Area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Container,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 160, 0, 2),
        Size = UDim2.new(1, -160, 1, -2)
    })
    
    -- Content Header (Toggle Key Hint)
    local ContentHeader = Create("Frame", {
        Name = "ContentHeader",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 35)
    })
    
    local ToggleKeyHint = Create("TextLabel", {
        Name = "ToggleHint",
        Parent = ContentHeader,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -150, 0, 0),
        Size = UDim2.new(0, 140, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = "[RShift Toggle UI]",
        TextColor3 = Theme.TextDarker,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    -- Header Border
    Create("Frame", {
        Name = "HeaderBorder",
        Parent = ContentHeader,
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 1, -1),
        Size = UDim2.new(1, -20, 0, 1)
    })
    
    -- Tab Content Container
    local TabContentContainer = Create("Frame", {
        Name = "TabContent",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 1, -65)
    })
    
    -- Status Bar
    local StatusBar = Create("Frame", {
        Name = "StatusBar",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -30),
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    -- Status Border
    Create("Frame", {
        Name = "StatusBorder",
        Parent = StatusBar,
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 0, 1)
    })
    
    local StatusText = Create("TextLabel", {
        Name = "StatusText",
        Parent = StatusBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "Made by FS Team",
        TextColor3 = Theme.TextDarker,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    -- Dragging
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    SidebarHeader.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
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
    
    -- Toggle Visibility
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == toggleKey then
            Window.Visible = not Window.Visible
            MainFrame.Visible = Window.Visible
        end
    end)
    
    -- ==================== ADD TAB ====================
    function Window:AddTab(options)
        options = options or {}
        local tabName = options.Name or "Tab"
        local tabIcon = options.Icon or "Circle"
        
        local Tab = {}
        Tab.Groups = {}
        Tab.Button = nil
        Tab.Content = nil
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = tabName,
            Parent = TabContainer,
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            Font = Enum.Font.Gotham,
            Text = "",
            AutoButtonColor = false
        })
        
        Create("UICorner", {
            Parent = TabButton,
            CornerRadius = UDim.new(0, 4)
        })
        
        -- Tab Icon
        local TabIcon = Create("ImageLabel", {
            Name = "Icon",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = GetIcon(tabIcon),
            ImageColor3 = Theme.TextDark
        })
        
        -- Tab Label
        local TabLabel = Create("TextLabel", {
            Name = "Label",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 34, 0, 0),
            Size = UDim2.new(1, -44, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = Theme.TextDark,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        Tab.Button = TabButton
        Tab.Icon = TabIcon
        Tab.Label = TabLabel
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            Parent = TabContentContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false
        })
        
        Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        Create("UIPadding", {
            Parent = TabContent,
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })
        
        Tab.Content = TabContent
        
        -- Tab Selection
        local function SelectTab()
            -- Deselect all tabs
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = Theme.Element
                tab.Icon.ImageColor3 = Theme.TextDark
                tab.Label.TextColor3 = Theme.TextDark
                tab.Content.Visible = false
            end
            
            -- Select this tab
            TabButton.BackgroundColor3 = Theme.Accent
            TabIcon.ImageColor3 = Theme.Text
            TabLabel.TextColor3 = Theme.Text
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.ElementHover}, 0.1)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.Element}, 0.1)
            end
        end)
        
        -- Auto select first tab
        if #Window.Tabs == 0 then
            SelectTab()
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- ==================== ADD GROUP ====================
        function Tab:AddGroup(groupName)
            local Group = {}
            
            local GroupFrame = Create("Frame", {
                Name = groupName or "Group",
                Parent = TabContent,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            Create("UICorner", {
                Parent = GroupFrame,
                CornerRadius = UDim.new(0, 6)
            })
            
            Create("UIStroke", {
                Parent = GroupFrame,
                Color = Theme.Border,
                Thickness = 1
            })
            
            -- Group Header
            local GroupHeader = Create("Frame", {
                Name = "Header",
                Parent = GroupFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 32)
            })
            
            Create("TextLabel", {
                Name = "Title",
                Parent = GroupHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -24, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = groupName or "Group",
                TextColor3 = Theme.Text,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Group Content
            local GroupContent = Create("Frame", {
                Name = "Content",
                Parent = GroupFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 32),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            Create("UIListLayout", {
                Parent = GroupContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2)
            })
            
            Create("UIPadding", {
                Parent = GroupContent,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            })
            
            table.insert(Tab.Groups, Group)
            
            -- ==================== ADD TOGGLE ====================
            function Group:AddToggle(options)
                options = options or {}
                local toggleName = options.Name or "Toggle"
                local default = options.Default or false
                local callback = options.Callback or function() end
                
                local Toggle = {}
                Toggle.Value = default
                
                local ToggleFrame = Create("Frame", {
                    Name = toggleName,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32)
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = toggleName,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ToggleButton = Create("TextButton", {
                    Name = "Button",
                    Parent = ToggleFrame,
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -40, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20),
                    Text = "",
                    AutoButtonColor = false
                })
                
                Create("UICorner", {
                    Parent = ToggleButton,
                    CornerRadius = UDim.new(0, 4)
                })
                
                Create("UIStroke", {
                    Parent = ToggleButton,
                    Color = Theme.Border,
                    Thickness = 1
                })
                
                local ToggleFill = Create("Frame", {
                    Name = "Fill",
                    Parent = ToggleButton,
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 2, 0, 2),
                    Size = UDim2.new(0, 0, 1, -4),
                    Visible = false
                })
                
                Create("UICorner", {
                    Parent = ToggleFill,
                    CornerRadius = UDim.new(0, 2)
                })
                
                local function UpdateToggle()
                    if Toggle.Value then
                        ToggleFill.Visible = true
                        Tween(ToggleFill, {Size = UDim2.new(1, -4, 1, -4)}, 0.15)
                        Tween(ToggleButton, {BackgroundColor3 = Theme.AccentDark}, 0.15)
                    else
                        Tween(ToggleFill, {Size = UDim2.new(0, 0, 1, -4)}, 0.15)
                        Tween(ToggleButton, {BackgroundColor3 = Theme.Background}, 0.15)
                        task.delay(0.15, function()
                            if not Toggle.Value then
                                ToggleFill.Visible = false
                            end
                        end)
                    end
                end
                
                if default then UpdateToggle() end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    UpdateToggle()
                    callback(Toggle.Value)
                end)
                
                function Toggle:Set(value)
                    Toggle.Value = value
                    UpdateToggle()
                    callback(Toggle.Value)
                end
                
                return Toggle
            end
            
            -- ==================== ADD SLIDER ====================
            function Group:AddSlider(options)
                options = options or {}
                local sliderName = options.Name or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local suffix = options.Suffix or ""
                local callback = options.Callback or function() end
                
                local Slider = {}
                Slider.Value = default
                
                local SliderFrame = Create("Frame", {
                    Name = sliderName,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 45)
                })
                
                local SliderLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -70, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = sliderName,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Value Input Box
                local ValueBox = Create("TextBox", {
                    Name = "ValueBox",
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -60, 0, 0),
                    Size = UDim2.new(0, 55, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    Text = tostring(default) .. suffix,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    ClearTextOnFocus = false
                })
                
                Create("UICorner", {
                    Parent = ValueBox,
                    CornerRadius = UDim.new(0, 4)
                })
                
                Create("UIStroke", {
                    Parent = ValueBox,
                    Color = Theme.Border,
                    Thickness = 1
                })
                
                local SliderBG = Create("Frame", {
                    Name = "Background",
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 28),
                    Size = UDim2.new(1, 0, 0, 12)
                })
                
                Create("UICorner", {
                    Parent = SliderBG,
                    CornerRadius = UDim.new(0, 4)
                })
                
                Create("UIStroke", {
                    Parent = SliderBG,
                    Color = Theme.Border,
                    Thickness = 1
                })
                
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    Parent = SliderBG,
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                })
                
                Create("UICorner", {
                    Parent = SliderFill,
                    CornerRadius = UDim.new(0, 4)
                })
                
                local function UpdateSlider(value)
                    value = math.clamp(value, min, max)
                    Slider.Value = value
                    local percent = (value - min) / (max - min)
                    Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                    ValueBox.Text = tostring(math.floor(value)) .. suffix
                    callback(value)
                end
                
                local sliding = false
                
                SliderBG.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        local percent = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                        local value = min + (max - min) * percent
                        UpdateSlider(value)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                        local value = min + (max - min) * percent
                        UpdateSlider(value)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)
                
                -- Text Input
                ValueBox.FocusLost:Connect(function()
                    local text = ValueBox.Text:gsub(suffix, "")
                    local num = tonumber(text)
                    if num then
                        UpdateSlider(num)
                    else
                        ValueBox.Text = tostring(Slider.Value) .. suffix
                    end
                end)
                
                function Slider:Set(value)
                    UpdateSlider(value)
                end
                
                return Slider
            end
            
            -- ==================== ADD DROPDOWN ====================
            function Group:AddDropdown(options)
                options = options or {}
                local dropdownName = options.Name or "Dropdown"
                local items = options.Items or {}
                local default = options.Default or (items[1] or "")
                local multi = options.Multi or false
                local callback = options.Callback or function() end
                
                local Dropdown = {}
                Dropdown.Open = false
                Dropdown.Value = multi and {} or default
                
                if multi and options.Default then
                    Dropdown.Value = options.Default
                end
                
                local DropdownFrame = Create("Frame", {
                    Name = dropdownName,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 52),
                    ClipsDescendants = false
                })
                
                local DropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = dropdownName,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    AutoButtonColor = false
                })
                
                Create("UICorner", {
                    Parent = DropdownButton,
                    CornerRadius = UDim.new(0, 4)
                })
                
                Create("UIStroke", {
                    Parent = DropdownButton,
                    Color = Theme.Border,
                    Thickness = 1
                })
                
                local DropdownValue = Create("TextLabel", {
                    Name = "Value",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -35, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = multi and "None" or default,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                })
                
                local DropdownArrow = Create("TextLabel", {
                    Name = "Arrow",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "v",
                    TextColor3 = Theme.TextDark,
                    TextSize = 10
                })
                
                local DropdownContainer = Create("Frame", {
                    Name = "Container",
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 52),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    ZIndex = 10,
                    Visible = false
                })
                
                Create("UICorner", {
                    Parent = DropdownContainer,
                    CornerRadius = UDim.new(0, 4)
                })
                
                Create("UIStroke", {
                    Parent = DropdownContainer,
                    Color = Theme.Border,
                    Thickness = 1
                })
                
                local DropdownScroll = Create("ScrollingFrame", {
                    Name = "Scroll",
                    Parent = DropdownContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, #items * 28),
                    ZIndex = 11
                })
                
                Create("UIListLayout", {
                    Parent = DropdownScroll,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2)
                })
                
                Create("UIPadding", {
                    Parent = DropdownScroll,
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4)
                })
                
                local function UpdateDisplay()
                    if multi then
                        if #Dropdown.Value == 0 then
                            DropdownValue.Text = "None"
                        else
                            DropdownValue.Text = table.concat(Dropdown.Value, ", ")
                        end
                    else
                        DropdownValue.Text = Dropdown.Value
                    end
                end
                
                local function CreateItem(itemName)
                    local ItemButton = Create("TextButton", {
                        Name = itemName,
                        Parent = DropdownScroll,
                        BackgroundColor3 = Theme.Element,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -4, 0, 26),
                        Font = Enum.Font.Gotham,
                        Text = "",
                        AutoButtonColor = false,
                        ZIndex = 12
                    })
                    
                    Create("UICorner", {
                        Parent = ItemButton,
                        CornerRadius = UDim.new(0, 4)
                    })
                    
                    local ItemLabel = Create("TextLabel", {
                        Name = "Label",
                        Parent = ItemButton,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -20, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = itemName,
                        TextColor3 = Theme.TextDark,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 12
                    })
                    
                    local function UpdateItemVisual()
                        local selected = false
                        if multi then
                            selected = table.find(Dropdown.Value, itemName) ~= nil
                        else
                            selected = Dropdown.Value == itemName
                        end
                        
                        if selected then
                            ItemButton.BackgroundColor3 = Theme.Accent
                            ItemLabel.TextColor3 = Theme.Text
                        else
                            ItemButton.BackgroundColor3 = Theme.Element
                            ItemLabel.TextColor3 = Theme.TextDark
                        end
                    end
                    
                    UpdateItemVisual()
                    
                    ItemButton.MouseButton1Click:Connect(function()
                        if multi then
                            local index = table.find(Dropdown.Value, itemName)
                            if index then
                                table.remove(Dropdown.Value, index)
                            else
                                table.insert(Dropdown.Value, itemName)
                            end
                            UpdateItemVisual()
                            UpdateDisplay()
                            callback(Dropdown.Value)
                        else
                            Dropdown.Value = itemName
                            UpdateDisplay()
                            callback(Dropdown.Value)
                            -- Close dropdown
                            Dropdown.Open = false
                            Tween(DropdownContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                            task.delay(0.2, function()
                                DropdownContainer.Visible = false
                            end)
                            DropdownArrow.Text = "v"
                        end
                        
                        -- Update all item visuals for single select
                        if not multi then
                            for _, child in pairs(DropdownScroll:GetChildren()) do
                                if child:IsA("TextButton") then
                                    local label = child:FindFirstChild("Label")
                                    if child.Name == itemName then
                                        child.BackgroundColor3 = Theme.Accent
                                        if label then label.TextColor3 = Theme.Text end
                                    else
                                        child.BackgroundColor3 = Theme.Element
                                        if label then label.TextColor3 = Theme.TextDark end
                                    end
                                end
                            end
                        end
                    end)
                    
                    ItemButton.MouseEnter:Connect(function()
                        if not (multi and table.find(Dropdown.Value, itemName)) and not (not multi and Dropdown.Value == itemName) then
                            Tween(ItemButton, {BackgroundColor3 = Theme.ElementHover}, 0.1)
                        end
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        local selected = multi and table.find(Dropdown.Value, itemName) or (not multi and Dropdown.Value == itemName)
                        if not selected then
                            Tween(ItemButton, {BackgroundColor3 = Theme.Element}, 0.1)
                        end
                    end)
                end
                
                for _, item in pairs(items) do
                    CreateItem(item)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        DropdownContainer.Visible = true
                        local height = math.min(#items * 30 + 8, 150)
                        Tween(DropdownContainer, {Size = UDim2.new(1, 0, 0, height)}, 0.2)
                        DropdownArrow.Text = "^"
                    else
                        Tween(DropdownContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        task.delay(0.2, function()
                            DropdownContainer.Visible = false
                        end)
                        DropdownArrow.Text = "v"
                    end
                end)
                
                UpdateDisplay()
                
                function Dropdown:Set(value)
                    Dropdown.Value = value
                    UpdateDisplay()
                    callback(value)
                end
                
                function Dropdown:Refresh(newItems)
                    items = newItems
                    for _, child in pairs(DropdownScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #items * 28)
                    for _, item in pairs(items) do
                        CreateItem(item)
                    end
                end
                
                return Dropdown
            end
            
            -- ==================== ADD COLORPICKER ====================
            function Group:AddColorPicker(options)
                options = options or {}
                local pickerName = options.Name or "Color Picker"
                local default = options.Default or Color3.fromRGB(59, 130, 246)
                local callback = options.Callback or function() end
                
                local ColorPicker = {}
                ColorPicker.Value = default
                ColorPicker.Open = false
                
                local r, g, b = math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)
                
                local PickerFrame = Create("Frame", {
                    Name = pickerName,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    ClipsDescendants = false
                })
                
                local PickerLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = PickerFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = pickerName,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ColorPreview = Create("TextButton", {
                    Name = "Preview",
                    Parent = PickerFrame,
                    BackgroundColor3 = default,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -40, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20),
                    Text = "",
                    AutoButtonColor = false
                })
                
                Create("UICorner", {
                    Parent = ColorPreview,
                    CornerRadius = UDim.new(0, 4)
                })
                
                Create("UIStroke", {
                    Parent = ColorPreview,
                    Color = Theme.Border,
                    Thickness = 1
                })
                
                local PickerPopup = Create("Frame", {
                    Name = "Popup",
                    Parent = PickerFrame,
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -200, 0, 35),
                    Size = UDim2.new(0, 200, 0, 0),
                    ClipsDescendants = true,
                    ZIndex = 20,
                    Visible = false
                })
                
                Create("UICorner", {
                    Parent = PickerPopup,
                    CornerRadius = UDim.new(0, 6)
                })
                
                Create("UIStroke", {
                    Parent = PickerPopup,
                    Color = Theme.Border,
                    Thickness = 1
                })
                
                local PopupContent = Create("Frame", {
                    Name = "Content",
                    Parent = PickerPopup,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -20, 1, -20),
                    ZIndex = 21
                })
                
                -- RGB Sliders
                local function CreateColorSlider(name, defaultVal, yPos, color)
                    local SliderBG = Create("Frame", {
                        Name = name,
                        Parent = PopupContent,
                        BackgroundColor3 = Theme.Element,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, yPos),
                        Size = UDim2.new(1, -45, 0, 16),
                        ZIndex = 22
                    })
                    
                    Create("UICorner", {
                        Parent = SliderBG,
                        CornerRadius = UDim.new(0, 4)
                    })
                    
                    local SliderFill = Create("Frame", {
                        Name = "Fill",
                        Parent = SliderBG,
                        BackgroundColor3 = color,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(defaultVal / 255, 0, 1, 0),
                        ZIndex = 23
                    })
                    
                    Create("UICorner", {
                        Parent = SliderFill,
                        CornerRadius = UDim.new(0, 4)
                    })
                    
                    local ValueBox = Create("TextBox", {
                        Name = "Value",
                        Parent = PopupContent,
                        BackgroundColor3 = Theme.Element,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -40, 0, yPos),
                        Size = UDim2.new(0, 40, 0, 16),
                        Font = Enum.Font.GothamMedium,
                        Text = tostring(defaultVal),
                        TextColor3 = Theme.Text,
                        TextSize = 10,
                        ZIndex = 22
                    })
                    
                    Create("UICorner", {
                        Parent = ValueBox,
                        CornerRadius = UDim.new(0, 4)
                    })
                    
                    return SliderBG, SliderFill, ValueBox
                end
                
                local RSlider, RFill, RBox = CreateColorSlider("R", r, 0, Color3.fromRGB(239, 68, 68))
                local GSlider, GFill, GBox = CreateColorSlider("G", g, 22, Color3.fromRGB(34, 197, 94))
                local BSlider, BFill, BBox = CreateColorSlider("B", b, 44, Color3.fromRGB(59, 130, 246))
                
                -- Hex Input
                local HexLabel = Create("TextLabel", {
                    Name = "HexLabel",
                    Parent = PopupContent,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 70),
                    Size = UDim2.new(0, 30, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    Text = "HEX",
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    ZIndex = 22
                })
                
                local HexBox = Create("TextBox", {
                    Name = "HexBox",
                    Parent = PopupContent,
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 35, 0, 70),
                    Size = UDim2.new(1, -35, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    Text = string.format("#%02X%02X%02X", r, g, b),
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    ZIndex = 22
                })
                
                Create("UICorner", {
                    Parent = HexBox,
                    CornerRadius = UDim.new(0, 4)
                })
                
                local function UpdateColor()
                    ColorPicker.Value = Color3.fromRGB(r, g, b)
                    ColorPreview.BackgroundColor3 = ColorPicker.Value
                    RFill.Size = UDim2.new(r / 255, 0, 1, 0)
                    GFill.Size = UDim2.new(g / 255, 0, 1, 0)
                    BFill.Size = UDim2.new(b / 255, 0, 1, 0)
                    RBox.Text = tostring(r)
                    GBox.Text = tostring(g)
                    BBox.Text = tostring(b)
                    HexBox.Text = string.format("#%02X%02X%02X", r, g, b)
                    callback(ColorPicker.Value)
                end
                
                local function SetupSlider(slider, fill, box, getValue, setValue)
                    local sliding = false
                    
                    slider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = true
                            local percent = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                            setValue(math.floor(percent * 255))
                            UpdateColor()
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local percent = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                            setValue(math.floor(percent * 255))
                            UpdateColor()
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = false
                        end
                    end)
                    
                    box.FocusLost:Connect(function()
                        local num = tonumber(box.Text)
                        if num then
                            setValue(math.clamp(math.floor(num), 0, 255))
                            UpdateColor()
                        else
                            box.Text = tostring(getValue())
                        end
                    end)
                end
                
                SetupSlider(RSlider, RFill, RBox, function() return r end, function(v) r = v end)
                SetupSlider(GSlider, GFill, GBox, function() return g end, function(v) g = v end)
                SetupSlider(BSlider, BFill, BBox, function() return b end, function(v) b = v end)
                
                HexBox.FocusLost:Connect(function()
                    local hex = HexBox.Text:gsub("#", "")
                    if #hex == 6 then
                        local newR = tonumber(hex:sub(1, 2), 16)
                        local newG = tonumber(hex:sub(3, 4), 16)
                        local newB = tonumber(hex:sub(5, 6), 16)
                        if newR and newG and newB then
                            r, g, b = newR, newG, newB
                            UpdateColor()
                        end
                    end
                end)
                
                ColorPreview.MouseButton1Click:Connect(function()
                    ColorPicker.Open = not ColorPicker.Open
                    
                    if ColorPicker.Open then
                        PickerPopup.Visible = true
                        Tween(PickerPopup, {Size = UDim2.new(0, 200, 0, 105)}, 0.2)
                    else
                        Tween(PickerPopup, {Size = UDim2.new(0, 200, 0, 0)}, 0.2)
                        task.delay(0.2, function()
                            PickerPopup.Visible = false
                        end)
                    end
                end)
                
                function ColorPicker:Set(color)
                    r = math.floor(color.R * 255)
                    g = math.floor(color.G * 255)
                    b = math.floor(color.B * 255)
                    UpdateColor()
                end
                
                return ColorPicker
            end
            
            -- ==================== ADD BUTTON ====================
            function Group:AddButton(options)
                options = options or {}
                local buttonName = options.Name or "Button"
                local callback = options.Callback or function() end
                
                local ButtonFrame = Create("Frame", {
                    Name = buttonName,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32)
                })
                
                local Button = Create("TextButton", {
                    Name = "Button",
                    Parent = ButtonFrame,
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 2),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.GothamMedium,
                    Text = buttonName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    AutoButtonColor = false
                })
                
                Create("UICorner", {
                    Parent = Button,
                    CornerRadius = UDim.new(0, 4)
                })
                
                Button.MouseButton1Click:Connect(function()
                    Tween(Button, {BackgroundColor3 = Theme.AccentDark}, 0.1)
                    task.wait(0.1)
                    Tween(Button, {BackgroundColor3 = Theme.Accent}, 0.1)
                    callback()
                end)
                
                Button.MouseEnter:Connect(function()
                    Tween(Button, {BackgroundColor3 = Theme.AccentDark}, 0.1)
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {BackgroundColor3 = Theme.Accent}, 0.1)
                end)
            end
            
            -- ==================== ADD LABEL ====================
            function Group:AddLabel(text)
                local Label = Create("TextLabel", {
                    Name = "Label",
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24),
                    Font = Enum.Font.Gotham,
                    Text = text or "Label",
                    TextColor3 = Theme.TextDark,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local LabelAPI = {}
                
                function LabelAPI:Set(newText)
                    Label.Text = newText
                end
                
                return LabelAPI
            end
            
            -- ==================== ADD TEXTBOX ====================
            function Group:AddTextBox(options)
                options = options or {}
                local textboxName = options.Name or "TextBox"
                local placeholder = options.Placeholder or "Enter text..."
                local default = options.Default or ""
                local callback = options.Callback or function() end
                
                local TextBoxComponent = {}
                TextBoxComponent.Value = default
                
                local TextBoxFrame = Create("Frame", {
                    Name = textboxName,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 52)
                })
                
                local TextBoxLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = TextBoxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = textboxName,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local TextBox = Create("TextBox", {
                    Name = "Input",
                    Parent = TextBoxFrame,
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.Gotham,
                    Text = default,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Theme.TextDarker,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    ClearTextOnFocus = false
                })
                
                Create("UICorner", {
                    Parent = TextBox,
                    CornerRadius = UDim.new(0, 4)
                })
                
                Create("UIStroke", {
                    Parent = TextBox,
                    Color = Theme.Border,
                    Thickness = 1
                })
                
                Create("UIPadding", {
                    Parent = TextBox,
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10)
                })
                
                TextBox.FocusLost:Connect(function()
                    TextBoxComponent.Value = TextBox.Text
                    callback(TextBox.Text)
                end)
                
                function TextBoxComponent:Set(text)
                    TextBox.Text = text
                    TextBoxComponent.Value = text
                end
                
                return TextBoxComponent
            end
            
            -- ==================== ADD KEYBIND ====================
            function Group:AddKeybind(options)
                options = options or {}
                local keybindName = options.Name or "Keybind"
                local default = options.Default or Enum.KeyCode.Unknown
                local callback = options.Callback or function() end
                
                local Keybind = {}
                Keybind.Value = default
                Keybind.Binding = false
                
                local KeybindFrame = Create("Frame", {
                    Name = keybindName,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32)
                })
                
                local KeybindLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = KeybindFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = keybindName,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local KeybindButton = Create("TextButton", {
                    Name = "Button",
                    Parent = KeybindFrame,
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -70, 0.5, -12),
                    Size = UDim2.new(0, 70, 0, 24),
                    Font = Enum.Font.GothamMedium,
                    Text = default.Name or "None",
                    TextColor3 = Theme.Text,
                    TextSize = 10,
                    AutoButtonColor = false
                })
                
                Create("UICorner", {
                    Parent = KeybindButton,
                    CornerRadius = UDim.new(0, 4)
                })
                
                Create("UIStroke", {
                    Parent = KeybindButton,
                    Color = Theme.Border,
                    Thickness = 1
                })
                
                KeybindButton.MouseButton1Click:Connect(function()
                    Keybind.Binding = true
                    KeybindButton.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input)
                    if Keybind.Binding then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Keybind.Value = input.KeyCode
                            KeybindButton.Text = input.KeyCode.Name
                            Keybind.Binding = false
                        end
                    else
                        if input.KeyCode == Keybind.Value then
                            callback(Keybind.Value)
                        end
                    end
                end)
                
                function Keybind:Set(key)
                    Keybind.Value = key
                    KeybindButton.Text = key.Name
                end
                
                return Keybind
            end
            
            return Group
        end
        
        return Tab
    end
    
    -- ==================== WINDOW API ====================
    function Window:SetVisible(visible)
        Window.Visible = visible
        MainFrame.Visible = visible
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    return Window
end

return Library
