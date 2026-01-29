--[[
    ███████╗██████╗ ██╗███████╗███╗   ██╗██████╗ ███████╗██╗  ██╗██╗██████╗ 
    ██╔════╝██╔══██╗██║██╔════╝████╗  ██║██╔══██╗██╔════╝██║  ██║██║██╔══██╗
    █████╗  ██████╔╝██║█████╗  ██╔██╗ ██║██║  ██║███████╗███████║██║██████╔╝
    ██╔══╝  ██╔══██╗██║██╔══╝  ██║╚██╗██║██║  ██║╚════██║██╔══██║██║██╔═══╝ 
    ██║     ██║  ██║██║███████╗██║ ╚████║██████╔╝███████║██║  ██║██║██║     
    ╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝╚═╝     
    
    FriendShip.Lua (FSlib) - Premium Roblox GUI Library
    Version: 2.0.0
    
    Compatible with:
    - Synapse X
    - Script-Ware
    - Krnl
    - Fluxus
    - And most other executors
    
    Usage:
    local FSlib = loadstring(game:HttpGet("YOUR_RAW_URL"))()
    local Window = FSlib:CreateWindow({ Title = "My Script" })
]]

local FSlib = {}
FSlib.__index = FSlib
FSlib.Version = "2.0.0"
FSlib.Windows = {}
FSlib.Connections = {}
FSlib.Flags = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configuration
local Config = {
    Theme = {
        Primary = Color3.fromRGB(255, 75, 75),
        Secondary = Color3.fromRGB(45, 45, 45),
        Background = Color3.fromRGB(15, 15, 15),
        Surface = Color3.fromRGB(25, 25, 25),
        Border = Color3.fromRGB(40, 40, 40),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 150, 150),
        TextDarker = Color3.fromRGB(100, 100, 100),
        Success = Color3.fromRGB(75, 255, 75),
        Warning = Color3.fromRGB(255, 200, 75),
        Error = Color3.fromRGB(255, 75, 75),
        Accent = Color3.fromRGB(255, 75, 75),
    },
    Font = Enum.Font.Code,
    FontBold = Enum.Font.Code,
    ToggleKey = Enum.KeyCode.RightControl,
    AnimationSpeed = 0.15,
    CornerRadius = 0,
}

-- Utility Functions
local function Create(className, properties, children)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    for _, child in pairs(children or {}) do
        child.Parent = instance
    end
    return instance
end

local function Tween(instance, properties, duration)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or Config.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function Ripple(parent, x, y)
    local ripple = Create("Frame", {
        Name = "Ripple",
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Position = UDim2.new(0, x - parent.AbsolutePosition.X, 0, y - parent.AbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 999,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    
    local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    Tween(ripple, { Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1 }, 0.5)
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

local function DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function GetTextSize(text, size, font, bounds)
    return TextService:GetTextSize(text, size, font, bounds or Vector2.new(math.huge, math.huge))
end

-- Main ScreenGui
local ScreenGui = Create("ScreenGui", {
    Name = "FSlib_" .. HttpService:GenerateGUID(false),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999999,
})

-- Try to parent to CoreGui, fallback to PlayerGui
local success, err = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Notification Container
local NotificationHolder = Create("Frame", {
    Name = "Notifications",
    Parent = ScreenGui,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -10, 1, -10),
    Size = UDim2.new(0, 280, 1, -20),
    AnchorPoint = Vector2.new(1, 1),
}, {
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 5),
    })
})

--[[ 
    ==========================================
    NOTIFICATION SYSTEM
    ==========================================
]]

function FSlib:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local message = options.Message or ""
    local duration = options.Duration or 3
    local notifyType = options.Type or "Info" -- Info, Success, Warning, Error
    
    local colors = {
        Info = Config.Theme.TextDark,
        Success = Config.Theme.Success,
        Warning = Config.Theme.Warning,
        Error = Config.Theme.Error,
    }
    
    local accentColor = colors[notifyType] or colors.Info
    
    local notification = Create("Frame", {
        Name = "Notification",
        Parent = NotificationHolder,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
    }, {
        Create("Frame", {
            Name = "Accent",
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 1, 0),
        }),
        Create("Frame", {
            Name = "Border",
            BackgroundColor3 = Config.Theme.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
        }),
        Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 8),
            Size = UDim2.new(1, -50, 0, 16),
            Font = Config.FontBold,
            Text = title,
            TextColor3 = Config.Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Create("TextLabel", {
            Name = "Message",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 26),
            Size = UDim2.new(1, -20, 0, 26),
            Font = Config.Font,
            Text = message,
            TextColor3 = Config.Theme.TextDark,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
        }),
        Create("TextButton", {
            Name = "Close",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -25, 0, 5),
            Size = UDim2.new(0, 20, 0, 20),
            Font = Config.Font,
            Text = "×",
            TextColor3 = Config.Theme.TextDarker,
            TextSize = 16,
        }),
        Create("Frame", {
            Name = "Progress",
            BackgroundColor3 = accentColor,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(1, 0, 0, 2),
        }),
    })
    
    -- Animate in
    Tween(notification, { Position = UDim2.new(0, 0, 0, 0) }, 0.3)
    
    -- Progress bar animation
    local progress = notification:FindFirstChild("Progress")
    Tween(progress, { Size = UDim2.new(0, 0, 0, 2) }, duration)
    
    -- Close button
    local closeBtn = notification:FindFirstChild("Close")
    closeBtn.MouseButton1Click:Connect(function()
        Tween(notification, { Position = UDim2.new(1, 0, 0, 0) }, 0.3)
        task.delay(0.3, function()
            notification:Destroy()
        end)
    end)
    
    -- Auto close
    task.delay(duration, function()
        if notification and notification.Parent then
            Tween(notification, { Position = UDim2.new(1, 0, 0, 0) }, 0.3)
            task.delay(0.3, function()
                if notification then notification:Destroy() end
            end)
        end
    end)
    
    return notification
end

--[[ 
    ==========================================
    WATERMARK SYSTEM
    ==========================================
]]

function FSlib:CreateWatermark(options)
    options = options or {}
    local title = options.Title or "FSlib"
    local showFPS = options.ShowFPS ~= false
    local showPing = options.ShowPing ~= false
    local showTime = options.ShowTime ~= false
    local showUser = options.ShowUser ~= false
    
    local watermark = Create("Frame", {
        Name = "Watermark",
        Parent = ScreenGui,
        BackgroundColor3 = Config.Theme.Background,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 300, 0, 26),
        Active = true,
    }, {
        Create("Frame", {
            Name = "Accent",
            BackgroundColor3 = Config.Theme.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 1, 0),
        }),
        Create("Frame", {
            Name = "Border",
            BackgroundColor3 = Config.Theme.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
        }),
        Create("TextLabel", {
            Name = "Content",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Font = Config.Font,
            Text = title,
            TextColor3 = Config.Theme.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            RichText = true,
        }),
    })
    
    -- Dragging
    local dragging, dragStart, startPos
    
    watermark.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = watermark.Position
        end
    end)
    
    watermark.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            watermark.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Update content
    local fps = 0
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
    
    task.spawn(function()
        while watermark and watermark.Parent do
            local content = watermark:FindFirstChild("Content")
            if content then
                local parts = {}
                table.insert(parts, string.format('<font color="rgb(255,75,75)">%s</font>', title))
                
                if showUser then
                    table.insert(parts, string.format('<font color="rgb(100,100,100)">%s</font>', LocalPlayer.Name))
                end
                
                if showFPS then
                    local fpsColor = fps >= 50 and "rgb(75,255,75)" or fps >= 30 and "rgb(255,200,75)" or "rgb(255,75,75)"
                    table.insert(parts, string.format('<font color="%s">%d fps</font>', fpsColor, fps))
                end
                
                if showPing then
                    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
                    local pingColor = ping <= 50 and "rgb(75,255,75)" or ping <= 100 and "rgb(255,200,75)" or "rgb(255,75,75)"
                    table.insert(parts, string.format('<font color="%s">%dms</font>', pingColor, ping))
                end
                
                if showTime then
                    table.insert(parts, string.format('<font color="rgb(150,150,150)">%s</font>', os.date("%H:%M:%S")))
                end
                
                content.Text = table.concat(parts, " <font color=\"rgb(60,60,60)\">|</font> ")
                
                -- Auto resize
                local textSize = GetTextSize(content.ContentText, 11, Config.Font)
                watermark.Size = UDim2.new(0, textSize.X + 24, 0, 26)
            end
            task.wait(0.1)
        end
    end)
    
    local WatermarkObject = {}
    
    function WatermarkObject:SetVisible(visible)
        watermark.Visible = visible
    end
    
    function WatermarkObject:Destroy()
        watermark:Destroy()
    end
    
    return WatermarkObject
end

--[[ 
    ==========================================
    WINDOW SYSTEM
    ==========================================
]]

function FSlib:CreateWindow(options)
    options = options or {}
    local title = options.Title or "FriendShip.Lua"
    local subtitle = options.Subtitle or "Premium Build v2.0"
    local size = options.Size or UDim2.new(0, 580, 0, 420)
    local position = options.Position or UDim2.new(0.5, -290, 0.5, -210)
    local toggleKey = options.ToggleKey or Config.ToggleKey
    
    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Visible = true,
    }
    table.insert(FSlib.Windows, Window)
    
    -- Main Container
    local mainFrame = Create("Frame", {
        Name = "Window",
        Parent = ScreenGui,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Position = position,
        Size = size,
        ClipsDescendants = true,
    }, {
        -- Border
        Create("Frame", {
            Name = "Border",
            BackgroundColor3 = Config.Theme.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, 0),
        }),
        Create("Frame", {
            Name = "Border",
            BackgroundColor3 = Config.Theme.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
        }),
        Create("Frame", {
            Name = "Border",
            BackgroundColor3 = Config.Theme.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
        }),
        Create("Frame", {
            Name = "Border",
            BackgroundColor3 = Config.Theme.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, -1, 0, 0),
        }),
    })
    
    -- Title Bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = mainFrame,
        BackgroundColor3 = Config.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
    }, {
        Create("Frame", {
            Name = "Border",
            BackgroundColor3 = Config.Theme.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
        }),
        -- Logo
        Create("Frame", {
            Name = "Logo",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0.5, -12),
            Size = UDim2.new(0, 24, 0, 24),
        }, {
            Create("Frame", {
                BackgroundColor3 = Config.Theme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 4, 1, 0),
            }),
            Create("Frame", {
                BackgroundColor3 = Config.Theme.Primary,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 6, 0, 6),
                Size = UDim2.new(0, 3, 0, 18),
            }),
            Create("Frame", {
                BackgroundColor3 = Config.Theme.Primary,
                BackgroundTransparency = 0.7,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 11, 0, 12),
                Size = UDim2.new(0, 2, 0, 12),
            }),
        }),
        -- Title
        Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 42, 0, 6),
            Size = UDim2.new(0, 200, 0, 14),
            Font = Config.FontBold,
            Text = title,
            TextColor3 = Config.Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Create("TextLabel", {
            Name = "Subtitle",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 42, 0, 20),
            Size = UDim2.new(0, 200, 0, 12),
            Font = Config.Font,
            Text = subtitle,
            TextColor3 = Config.Theme.TextDarker,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        -- Controls
        Create("TextButton", {
            Name = "Minimize",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -60, 0, 0),
            Size = UDim2.new(0, 30, 1, 0),
            Font = Config.Font,
            Text = "—",
            TextColor3 = Config.Theme.TextDarker,
            TextSize = 14,
        }),
        Create("TextButton", {
            Name = "Close",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -30, 0, 0),
            Size = UDim2.new(0, 30, 1, 0),
            Font = Config.Font,
            Text = "×",
            TextColor3 = Config.Theme.TextDarker,
            TextSize = 18,
        }),
    })
    
    -- Dragging
    local dragging, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Close/Minimize buttons
    local closeBtn = titleBar:FindFirstChild("Close")
    local minBtn = titleBar:FindFirstChild("Minimize")
    
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, { TextColor3 = Config.Theme.Error }, 0.1)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, { TextColor3 = Config.Theme.TextDarker }, 0.1)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Window.Visible = false
        mainFrame.Visible = false
    end)
    
    minBtn.MouseEnter:Connect(function()
        Tween(minBtn, { TextColor3 = Config.Theme.Text }, 0.1)
    end)
    minBtn.MouseLeave:Connect(function()
        Tween(minBtn, { TextColor3 = Config.Theme.TextDarker }, 0.1)
    end)
    
    local minimized = false
    local originalSize = size
    
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(mainFrame, { Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 40) }, 0.2)
        else
            Tween(mainFrame, { Size = originalSize }, 0.2)
        end
    end)
    
    -- Tab Bar
    local tabBar = Create("Frame", {
        Name = "TabBar",
        Parent = mainFrame,
        BackgroundColor3 = Config.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 0, 32),
    }, {
        Create("Frame", {
            Name = "Border",
            BackgroundColor3 = Config.Theme.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
        }),
        Create("ScrollingFrame", {
            Name = "TabContainer",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 0,
            ScrollingDirection = Enum.ScrollingDirection.X,
        }, {
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 0),
            }),
        }),
    })
    
    -- Content Area
    local contentArea = Create("Frame", {
        Name = "Content",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 72),
        Size = UDim2.new(1, 0, 1, -100),
    })
    
    -- Footer
    local footer = Create("Frame", {
        Name = "Footer",
        Parent = mainFrame,
        BackgroundColor3 = Config.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -28),
        Size = UDim2.new(1, 0, 0, 28),
    }, {
        Create("Frame", {
            Name = "Border",
            BackgroundColor3 = Config.Theme.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
        }),
        Create("TextLabel", {
            Name = "Left",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(0.5, -10, 1, 0),
            Font = Config.Font,
            Text = "[RCTRL] toggle menu",
            TextColor3 = Config.Theme.TextDarker,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Create("TextLabel", {
            Name = "Right",
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(0.5, -10, 1, 0),
            Font = Config.Font,
            Text = "FSlib v" .. FSlib.Version,
            TextColor3 = Config.Theme.TextDarker,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right,
            RichText = true,
        }),
    })
    
    -- Toggle key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            Window.Visible = not Window.Visible
            mainFrame.Visible = Window.Visible
        end
    end)
    
    -- Create Tab function
    function Window:CreateTab(options)
        options = options or {}
        local name = options.Name or "Tab"
        local icon = options.Icon or ""
        
        local Tab = {
            Sections = {},
            Elements = {},
        }
        table.insert(Window.Tabs, Tab)
        
        local tabContainer = tabBar:FindFirstChild("TabContainer")
        local tabCount = #Window.Tabs
        
        -- Tab Button
        local tabButton = Create("TextButton", {
            Name = name,
            Parent = tabContainer,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 80, 1, 0),
            Font = Config.FontBold,
            Text = string.upper(name),
            TextColor3 = Config.Theme.TextDarker,
            TextSize = 10,
            LayoutOrder = tabCount,
        }, {
            Create("Frame", {
                Name = "Indicator",
                BackgroundColor3 = Config.Theme.Primary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -2),
                Size = UDim2.new(1, 0, 0, 2),
                Visible = false,
            }),
        })
        
        -- Tab Content
        local tabContent = Create("ScrollingFrame", {
            Name = name .. "_Content",
            Parent = contentArea,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Config.Theme.Border,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, {
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            }),
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Top,
            }),
        })
        
        Tab.Button = tabButton
        Tab.Content = tabContent
        
        -- Select tab function
        local function selectTab()
            for _, t in pairs(Window.Tabs) do
                t.Button.TextColor3 = Config.Theme.TextDarker
                t.Button:FindFirstChild("Indicator").Visible = false
                t.Content.Visible = false
            end
            tabButton.TextColor3 = Config.Theme.Primary
            tabButton:FindFirstChild("Indicator").Visible = true
            tabContent.Visible = true
            Window.ActiveTab = Tab
        end
        
        tabButton.MouseButton1Click:Connect(selectTab)
        tabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(tabButton, { TextColor3 = Config.Theme.TextDark }, 0.1)
            end
        end)
        tabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(tabButton, { TextColor3 = Config.Theme.TextDarker }, 0.1)
            end
        end)
        
        -- Auto select first tab
        if tabCount == 1 then
            selectTab()
        end
        
        -- Update tab container canvas size
        local layout = tabContainer:FindFirstChild("UIListLayout")
        tabContainer.CanvasSize = UDim2.new(0, layout.AbsoluteContentSize.X, 0, 0)
        
        -- Create Section function
        function Tab:CreateSection(options)
            options = options or {}
            local sectionName = options.Name or "Section"
            local side = options.Side or "Left"
            
            local Section = {
                Elements = {},
            }
            table.insert(Tab.Sections, Section)
            
            local sectionFrame = Create("Frame", {
                Name = sectionName,
                Parent = tabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -4, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = side == "Left" and 1 or 2,
            }, {
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 0),
                }),
            })
            
            -- Section Header
            local sectionHeader = Create("Frame", {
                Name = "Header",
                Parent = sectionFrame,
                BackgroundColor3 = Config.Theme.Surface,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 28),
            }, {
                Create("Frame", {
                    Name = "Accent",
                    BackgroundColor3 = Config.Theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 3, 1, 0),
                }),
                Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -12, 1, 0),
                    Font = Config.FontBold,
                    Text = string.upper(sectionName),
                    TextColor3 = Config.Theme.TextDark,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
            })
            
            -- Section Content
            local sectionContent = Create("Frame", {
                Name = "Content",
                Parent = sectionFrame,
                BackgroundColor3 = Config.Theme.Background,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
            }, {
                Create("Frame", {
                    Name = "LeftBorder",
                    BackgroundColor3 = Config.Theme.Border,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 1, 1, 0),
                }),
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 0),
                }),
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 1),
                }),
            })
            
            Section.Frame = sectionFrame
            Section.Content = sectionContent
            
            --[[ 
                ==========================================
                TOGGLE ELEMENT
                ==========================================
            ]]
            
            function Section:CreateToggle(options)
                options = options or {}
                local toggleName = options.Name or "Toggle"
                local default = options.Default or false
                local flag = options.Flag or toggleName
                local callback = options.Callback or function() end
                
                FSlib.Flags[flag] = default
                
                local Toggle = { Value = default, Type = "Toggle" }
                table.insert(Section.Elements, Toggle)
                
                local toggleFrame = Create("Frame", {
                    Name = toggleName,
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                }, {
                    Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 28, 0, 0),
                        Size = UDim2.new(1, -60, 1, 0),
                        Font = Config.Font,
                        Text = toggleName,
                        TextColor3 = default and Config.Theme.Text or Config.Theme.TextDark,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }),
                    Create("TextButton", {
                        Name = "Button",
                        BackgroundColor3 = default and Config.Theme.Primary or Config.Theme.Border,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 8, 0.5, -6),
                        Size = UDim2.new(0, 12, 0, 12),
                        Text = "",
                        AutoButtonColor = false,
                    }, {
                        Create("ImageLabel", {
                            Name = "Check",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0.5, -4, 0.5, -4),
                            Size = UDim2.new(0, 8, 0, 8),
                            Image = "rbxassetid://3926305904",
                            ImageRectOffset = Vector2.new(312, 4),
                            ImageRectSize = Vector2.new(24, 24),
                            ImageColor3 = Config.Theme.Text,
                            ImageTransparency = default and 0 or 1,
                        }),
                    }),
                })
                
                local button = toggleFrame:FindFirstChild("Button")
                local check = button:FindFirstChild("Check")
                local label = toggleFrame:FindFirstChild("Label")
                
                local function updateToggle(value)
                    Toggle.Value = value
                    FSlib.Flags[flag] = value
                    
                    Tween(button, { BackgroundColor3 = value and Config.Theme.Primary or Config.Theme.Border }, 0.15)
                    Tween(check, { ImageTransparency = value and 0 or 1 }, 0.15)
                    Tween(label, { TextColor3 = value and Config.Theme.Text or Config.Theme.TextDark }, 0.15)
                    
                    callback(value)
                end
                
                button.MouseButton1Click:Connect(function()
                    updateToggle(not Toggle.Value)
                end)
                
                toggleFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        updateToggle(not Toggle.Value)
                    end
                end)
                
                function Toggle:Set(value)
                    updateToggle(value)
                end
                
                function Toggle:Get()
                    return Toggle.Value
                end
                
                return Toggle
            end
            
            --[[ 
                ==========================================
                SLIDER ELEMENT
                ==========================================
            ]]
            
            function Section:CreateSlider(options)
                options = options or {}
                local sliderName = options.Name or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local increment = options.Increment or 1
                local suffix = options.Suffix or ""
                local flag = options.Flag or sliderName
                local callback = options.Callback or function() end
                
                FSlib.Flags[flag] = default
                
                local Slider = { Value = default, Type = "Slider" }
                table.insert(Section.Elements, Slider)
                
                local sliderFrame = Create("Frame", {
                    Name = sliderName,
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                }, {
                    Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 4),
                        Size = UDim2.new(0.5, -8, 0, 16),
                        Font = Config.Font,
                        Text = sliderName,
                        TextColor3 = Config.Theme.TextDark,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }),
                    Create("TextLabel", {
                        Name = "Value",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0, 4),
                        Size = UDim2.new(0.5, -8, 0, 16),
                        Font = Config.Font,
                        Text = tostring(default) .. suffix,
                        TextColor3 = Config.Theme.Primary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Right,
                    }),
                    Create("Frame", {
                        Name = "Track",
                        BackgroundColor3 = Config.Theme.Border,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 8, 0, 26),
                        Size = UDim2.new(1, -16, 0, 4),
                    }, {
                        Create("Frame", {
                            Name = "Fill",
                            BackgroundColor3 = Config.Theme.Primary,
                            BorderSizePixel = 0,
                            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                        }),
                        Create("Frame", {
                            Name = "Thumb",
                            BackgroundColor3 = Config.Theme.Surface,
                            BorderSizePixel = 0,
                            Position = UDim2.new((default - min) / (max - min), -5, 0.5, -5),
                            Size = UDim2.new(0, 10, 0, 10),
                            ZIndex = 2,
                        }, {
                            Create("Frame", {
                                Name = "Inner",
                                BackgroundColor3 = Config.Theme.Primary,
                                BorderSizePixel = 0,
                                Position = UDim2.new(0, 2, 0, 2),
                                Size = UDim2.new(1, -4, 1, -4),
                            }),
                        }),
                    }),
                })
                
                local track = sliderFrame:FindFirstChild("Track")
                local fill = track:FindFirstChild("Fill")
                local thumb = track:FindFirstChild("Thumb")
                local valueLabel = sliderFrame:FindFirstChild("Value")
                
                local dragging = false
                
                local function updateSlider(input)
                    local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    local rawValue = min + (max - min) * pos
                    local value = math.floor(rawValue / increment + 0.5) * increment
                    value = math.clamp(value, min, max)
                    
                    -- Round to avoid floating point errors
                    if increment < 1 then
                        value = tonumber(string.format("%." .. tostring(#tostring(increment):match("%.(%d+)") or 0) .. "f", value))
                    end
                    
                    Slider.Value = value
                    FSlib.Flags[flag] = value
                    
                    local percent = (value - min) / (max - min)
                    Tween(fill, { Size = UDim2.new(percent, 0, 1, 0) }, 0.05)
                    Tween(thumb, { Position = UDim2.new(percent, -5, 0.5, -5) }, 0.05)
                    valueLabel.Text = tostring(value) .. suffix
                    
                    callback(value)
                end
                
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                function Slider:Set(value)
                    value = math.clamp(value, min, max)
                    Slider.Value = value
                    FSlib.Flags[flag] = value
                    
                    local percent = (value - min) / (max - min)
                    Tween(fill, { Size = UDim2.new(percent, 0, 1, 0) }, 0.1)
                    Tween(thumb, { Position = UDim2.new(percent, -5, 0.5, -5) }, 0.1)
                    valueLabel.Text = tostring(value) .. suffix
                    
                    callback(value)
                end
                
                function Slider:Get()
                    return Slider.Value
                end
                
                return Slider
            end
            
            --[[ 
                ==========================================
                DROPDOWN ELEMENT
                ==========================================
            ]]
            
            function Section:CreateDropdown(options)
                options = options or {}
                local dropdownName = options.Name or "Dropdown"
                local optionsList = options.Options or {}
                local default = options.Default or (optionsList[1] or "")
                local flag = options.Flag or dropdownName
                local callback = options.Callback or function() end
                
                FSlib.Flags[flag] = default
                
                local Dropdown = { Value = default, Options = optionsList, Type = "Dropdown" }
                table.insert(Section.Elements, Dropdown)
                
                local dropdownFrame = Create("Frame", {
                    Name = dropdownName,
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 52),
                    ClipsDescendants = false,
                    ZIndex = 10,
                }, {
                    Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 4),
                        Size = UDim2.new(1, -8, 0, 16),
                        Font = Config.Font,
                        Text = dropdownName,
                        TextColor3 = Config.Theme.TextDark,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 10,
                    }),
                    Create("TextButton", {
                        Name = "Selected",
                        BackgroundColor3 = Config.Theme.Surface,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 8, 0, 22),
                        Size = UDim2.new(1, -16, 0, 24),
                        Font = Config.Font,
                        Text = "",
                        TextColor3 = Config.Theme.Text,
                        TextSize = 11,
                        AutoButtonColor = false,
                        ZIndex = 10,
                    }, {
                        Create("Frame", {
                            Name = "Border",
                            BackgroundColor3 = Config.Theme.Border,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 1),
                            Position = UDim2.new(0, 0, 1, -1),
                            ZIndex = 10,
                        }),
                        Create("TextLabel", {
                            Name = "Text",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 8, 0, 0),
                            Size = UDim2.new(1, -30, 1, 0),
                            Font = Config.Font,
                            Text = default,
                            TextColor3 = Config.Theme.Text,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 10,
                        }),
                        Create("TextLabel", {
                            Name = "Arrow",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(1, -20, 0, 0),
                            Size = UDim2.new(0, 16, 1, 0),
                            Font = Config.Font,
                            Text = "▼",
                            TextColor3 = Config.Theme.TextDarker,
                            TextSize = 8,
                            ZIndex = 10,
                        }),
                    }),
                    Create("Frame", {
                        Name = "OptionsList",
                        BackgroundColor3 = Config.Theme.Surface,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 8, 0, 46),
                        Size = UDim2.new(1, -16, 0, 0),
                        ClipsDescendants = true,
                        Visible = false,
                        ZIndex = 100,
                    }, {
                        Create("Frame", {
                            Name = "Border",
                            BackgroundColor3 = Config.Theme.Border,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 1),
                            Position = UDim2.new(0, 0, 0, 0),
                            ZIndex = 100,
                        }),
                        Create("ScrollingFrame", {
                            Name = "Scroll",
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, 0, 0, 1),
                            Size = UDim2.new(1, 0, 1, -1),
                            CanvasSize = UDim2.new(0, 0, 0, 0),
                            ScrollBarThickness = 2,
                            ScrollBarImageColor3 = Config.Theme.Border,
                            AutomaticCanvasSize = Enum.AutomaticSize.Y,
                            ZIndex = 100,
                        }, {
                            Create("UIListLayout", {
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = UDim.new(0, 0),
                            }),
                        }),
                    }),
                })
                
                local selectedBtn = dropdownFrame:FindFirstChild("Selected")
                local selectedText = selectedBtn:FindFirstChild("Text")
                local arrow = selectedBtn:FindFirstChild("Arrow")
                local optionsList = dropdownFrame:FindFirstChild("OptionsList")
                local scroll = optionsList:FindFirstChild("Scroll")
                
                local isOpen = false
                
                local function toggleDropdown()
                    isOpen = not isOpen
                    
                    if isOpen then
                        local height = math.min(#Dropdown.Options * 24, 120)
                        optionsList.Visible = true
                        Tween(optionsList, { Size = UDim2.new(1, -16, 0, height) }, 0.15)
                        Tween(arrow, { Rotation = 180 }, 0.15)
                        Tween(selectedBtn, { BackgroundColor3 = Config.Theme.Border }, 0.1)
                    else
                        Tween(optionsList, { Size = UDim2.new(1, -16, 0, 0) }, 0.15)
                        Tween(arrow, { Rotation = 0 }, 0.15)
                        Tween(selectedBtn, { BackgroundColor3 = Config.Theme.Surface }, 0.1)
                        task.delay(0.15, function()
                            if not isOpen then
                                optionsList.Visible = false
                            end
                        end)
                    end
                end
                
                local function refreshOptions()
                    for _, child in pairs(scroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for i, option in ipairs(Dropdown.Options) do
                        local optionBtn = Create("TextButton", {
                            Name = option,
                            Parent = scroll,
                            BackgroundColor3 = option == Dropdown.Value and Color3.fromRGB(255, 75, 75) or Config.Theme.Surface,
                            BackgroundTransparency = option == Dropdown.Value and 0.9 or 1,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 24),
                            Font = Config.Font,
                            Text = "",
                            TextColor3 = option == Dropdown.Value and Config.Theme.Primary or Config.Theme.Text,
                            TextSize = 11,
                            LayoutOrder = i,
                            AutoButtonColor = false,
                            ZIndex = 100,
                        }, {
                            Create("Frame", {
                                Name = "Accent",
                                BackgroundColor3 = Config.Theme.Primary,
                                BorderSizePixel = 0,
                                Size = UDim2.new(0, 2, 1, 0),
                                Visible = option == Dropdown.Value,
                                ZIndex = 100,
                            }),
                            Create("TextLabel", {
                                Name = "Text",
                                BackgroundTransparency = 1,
                                Position = UDim2.new(0, 10, 0, 0),
                                Size = UDim2.new(1, -10, 1, 0),
                                Font = Config.Font,
                                Text = option,
                                TextColor3 = option == Dropdown.Value and Config.Theme.Primary or Config.Theme.Text,
                                TextSize = 11,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                ZIndex = 100,
                            }),
                        })
                        
                        optionBtn.MouseEnter:Connect(function()
                            if option ~= Dropdown.Value then
                                Tween(optionBtn, { BackgroundTransparency = 0.95 }, 0.1)
                            end
                        end)
                        
                        optionBtn.MouseLeave:Connect(function()
                            if option ~= Dropdown.Value then
                                Tween(optionBtn, { BackgroundTransparency = 1 }, 0.1)
                            end
                        end)
                        
                        optionBtn.MouseButton1Click:Connect(function()
                            Dropdown.Value = option
                            FSlib.Flags[flag] = option
                            selectedText.Text = option
                            toggleDropdown()
                            refreshOptions()
                            callback(option)
                        end)
                    end
                end
                
                refreshOptions()
                
                selectedBtn.MouseButton1Click:Connect(toggleDropdown)
                
                selectedBtn.MouseEnter:Connect(function()
                    if not isOpen then
                        Tween(selectedBtn, { BackgroundColor3 = Config.Theme.Border }, 0.1)
                    end
                end)
                
                selectedBtn.MouseLeave:Connect(function()
                    if not isOpen then
                        Tween(selectedBtn, { BackgroundColor3 = Config.Theme.Surface }, 0.1)
                    end
                end)
                
                function Dropdown:Set(value)
                    if table.find(Dropdown.Options, value) then
                        Dropdown.Value = value
                        FSlib.Flags[flag] = value
                        selectedText.Text = value
                        refreshOptions()
                        callback(value)
                    end
                end
                
                function Dropdown:SetOptions(newOptions)
                    Dropdown.Options = newOptions
                    refreshOptions()
                end
                
                function Dropdown:Get()
                    return Dropdown.Value
                end
                
                return Dropdown
            end
            
            --[[ 
                ==========================================
                KEYBIND ELEMENT
                ==========================================
            ]]
            
            function Section:CreateKeybind(options)
                options = options or {}
                local keybindName = options.Name or "Keybind"
                local default = options.Default or Enum.KeyCode.Unknown
                local flag = options.Flag or keybindName
                local callback = options.Callback or function() end
                local changedCallback = options.ChangedCallback or function() end
                
                FSlib.Flags[flag] = default
                
                local Keybind = { Value = default, Type = "Keybind" }
                table.insert(Section.Elements, Keybind)
                
                local keybindFrame = Create("Frame", {
                    Name = keybindName,
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                }, {
                    Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        Size = UDim2.new(0.6, -8, 1, 0),
                        Font = Config.Font,
                        Text = keybindName,
                        TextColor3 = Config.Theme.TextDark,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }),
                    Create("TextButton", {
                        Name = "Button",
                        BackgroundColor3 = Config.Theme.Surface,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.6, 0, 0.5, -10),
                        Size = UDim2.new(0.4, -8, 0, 20),
                        Font = Config.Font,
                        Text = default == Enum.KeyCode.Unknown and "[None]" or "[" .. default.Name .. "]",
                        TextColor3 = Config.Theme.TextDark,
                        TextSize = 10,
                        AutoButtonColor = false,
                    }),
                })
                
                local button = keybindFrame:FindFirstChild("Button")
                local listening = false
                
                local function getKeyName(key)
                    if key == Enum.KeyCode.Unknown then
                        return "None"
                    end
                    return key.Name
                end
                
                button.MouseButton1Click:Connect(function()
                    listening = true
                    button.Text = "[...]"
                    Tween(button, { TextColor3 = Config.Theme.Primary }, 0.1)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening then
                        local newKey = Enum.KeyCode.Unknown
                        
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape then
                                newKey = Enum.KeyCode.Unknown
                            else
                                newKey = input.KeyCode
                            end
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                            newKey = Enum.KeyCode.Unknown -- Can't bind mouse1
                        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                            newKey = Enum.KeyCode.Unknown -- Treat as right click = unbind
                        end
                        
                        Keybind.Value = newKey
                        FSlib.Flags[flag] = newKey
                        button.Text = "[" .. getKeyName(newKey) .. "]"
                        Tween(button, { TextColor3 = Config.Theme.TextDark }, 0.1)
                        listening = false
                        changedCallback(newKey)
                    elseif not gameProcessed and input.KeyCode == Keybind.Value and Keybind.Value ~= Enum.KeyCode.Unknown then
                        callback(Keybind.Value)
                    end
                end)
                
                button.MouseEnter:Connect(function()
                    if not listening then
                        Tween(button, { BackgroundColor3 = Config.Theme.Border }, 0.1)
                    end
                end)
                
                button.MouseLeave:Connect(function()
                    if not listening then
                        Tween(button, { BackgroundColor3 = Config.Theme.Surface }, 0.1)
                    end
                end)
                
                function Keybind:Set(key)
                    Keybind.Value = key
                    FSlib.Flags[flag] = key
                    button.Text = "[" .. getKeyName(key) .. "]"
                    changedCallback(key)
                end
                
                function Keybind:Get()
                    return Keybind.Value
                end
                
                return Keybind
            end
            
            --[[ 
                ==========================================
                BUTTON ELEMENT
                ==========================================
            ]]
            
            function Section:CreateButton(options)
                options = options or {}
                local buttonName = options.Name or "Button"
                local callback = options.Callback or function() end
                
                local Button = { Type = "Button" }
                table.insert(Section.Elements, Button)
                
                local buttonFrame = Create("Frame", {
                    Name = buttonName,
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36),
                }, {
                    Create("TextButton", {
                        Name = "Button",
                        BackgroundColor3 = Config.Theme.Primary,
                        BackgroundTransparency = 0.9,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 8, 0, 4),
                        Size = UDim2.new(1, -16, 0, 28),
                        Font = Config.Font,
                        Text = buttonName,
                        TextColor3 = Config.Theme.Primary,
                        TextSize = 11,
                        AutoButtonColor = false,
                    }, {
                        Create("Frame", {
                            Name = "Border",
                            BackgroundColor3 = Config.Theme.Primary,
                            BackgroundTransparency = 0.7,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 1),
                            Position = UDim2.new(0, 0, 1, -1),
                        }),
                    }),
                })
                
                local btn = buttonFrame:FindFirstChild("Button")
                
                btn.MouseButton1Click:Connect(function()
                    Ripple(btn, Mouse.X, Mouse.Y)
                    callback()
                end)
                
                btn.MouseEnter:Connect(function()
                    Tween(btn, { BackgroundTransparency = 0.8 }, 0.1)
                end)
                
                btn.MouseLeave:Connect(function()
                    Tween(btn, { BackgroundTransparency = 0.9 }, 0.1)
                end)
                
                return Button
            end
            
            --[[ 
                ==========================================
                TEXTBOX ELEMENT
                ==========================================
            ]]
            
            function Section:CreateTextbox(options)
                options = options or {}
                local textboxName = options.Name or "Textbox"
                local default = options.Default or ""
                local placeholder = options.Placeholder or "Enter text..."
                local flag = options.Flag or textboxName
                local callback = options.Callback or function() end
                
                FSlib.Flags[flag] = default
                
                local Textbox = { Value = default, Type = "Textbox" }
                table.insert(Section.Elements, Textbox)
                
                local textboxFrame = Create("Frame", {
                    Name = textboxName,
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 52),
                }, {
                    Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 4),
                        Size = UDim2.new(1, -8, 0, 16),
                        Font = Config.Font,
                        Text = textboxName,
                        TextColor3 = Config.Theme.TextDark,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }),
                    Create("Frame", {
                        Name = "InputContainer",
                        BackgroundColor3 = Config.Theme.Surface,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 8, 0, 22),
                        Size = UDim2.new(1, -16, 0, 24),
                    }, {
                        Create("Frame", {
                            Name = "Border",
                            BackgroundColor3 = Config.Theme.Border,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 1),
                            Position = UDim2.new(0, 0, 1, -1),
                        }),
                        Create("TextBox", {
                            Name = "Input",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 8, 0, 0),
                            Size = UDim2.new(1, -16, 1, 0),
                            Font = Config.Font,
                            Text = default,
                            PlaceholderText = placeholder,
                            TextColor3 = Config.Theme.Text,
                            PlaceholderColor3 = Config.Theme.TextDarker,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ClearTextOnFocus = false,
                        }),
                    }),
                })
                
                local container = textboxFrame:FindFirstChild("InputContainer")
                local input = container:FindFirstChild("Input")
                local border = container:FindFirstChild("Border")
                
                input.Focused:Connect(function()
                    Tween(border, { BackgroundColor3 = Config.Theme.Primary }, 0.1)
                end)
                
                input.FocusLost:Connect(function(enterPressed)
                    Tween(border, { BackgroundColor3 = Config.Theme.Border }, 0.1)
                    Textbox.Value = input.Text
                    FSlib.Flags[flag] = input.Text
                    callback(input.Text, enterPressed)
                end)
                
                function Textbox:Set(value)
                    Textbox.Value = value
                    FSlib.Flags[flag] = value
                    input.Text = value
                end
                
                function Textbox:Get()
                    return Textbox.Value
                end
                
                return Textbox
            end
            
            --[[ 
                ==========================================
                COLORPICKER ELEMENT
                ==========================================
            ]]
            
            function Section:CreateColorPicker(options)
                options = options or {}
                local colorName = options.Name or "Color"
                local default = options.Default or Color3.fromRGB(255, 75, 75)
                local flag = options.Flag or colorName
                local callback = options.Callback or function() end
                
                FSlib.Flags[flag] = default
                
                local ColorPicker = { Value = default, Type = "ColorPicker" }
                table.insert(Section.Elements, ColorPicker)
                
                local h, s, v = default:ToHSV()
                
                local colorFrame = Create("Frame", {
                    Name = colorName,
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    ClipsDescendants = false,
                    ZIndex = 50,
                }, {
                    Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        Size = UDim2.new(0.7, -8, 1, 0),
                        Font = Config.Font,
                        Text = colorName,
                        TextColor3 = Config.Theme.TextDark,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 50,
                    }),
                    Create("TextButton", {
                        Name = "Preview",
                        BackgroundColor3 = default,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -38, 0.5, -8),
                        Size = UDim2.new(0, 30, 0, 16),
                        Text = "",
                        AutoButtonColor = false,
                        ZIndex = 50,
                    }, {
                        Create("Frame", {
                            Name = "Border",
                            BackgroundColor3 = Config.Theme.Border,
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, -1, 0, -1),
                            Size = UDim2.new(1, 2, 1, 2),
                            ZIndex = 49,
                        }),
                    }),
                    Create("Frame", {
                        Name = "Picker",
                        BackgroundColor3 = Config.Theme.Surface,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -168, 0, 32),
                        Size = UDim2.new(0, 160, 0, 140),
                        Visible = false,
                        ZIndex = 200,
                    }, {
                        Create("Frame", {
                            Name = "Border",
                            BackgroundColor3 = Config.Theme.Border,
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, -1, 0, -1),
                            Size = UDim2.new(1, 2, 1, 2),
                            ZIndex = 199,
                        }),
                        -- Saturation/Value picker
                        Create("ImageButton", {
                            Name = "SV",
                            BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, 8, 0, 8),
                            Size = UDim2.new(1, -36, 0, 100),
                            Image = "rbxassetid://4155801252",
                            AutoButtonColor = false,
                            ZIndex = 200,
                        }, {
                            Create("Frame", {
                                Name = "Cursor",
                                BackgroundColor3 = Color3.new(1, 1, 1),
                                BorderSizePixel = 0,
                                Position = UDim2.new(s, -4, 1 - v, -4),
                                Size = UDim2.new(0, 8, 0, 8),
                                ZIndex = 201,
                            }, {
                                Create("Frame", {
                                    BackgroundColor3 = Color3.new(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.new(0, 1, 0, 1),
                                    Size = UDim2.new(1, -2, 1, -2),
                                    ZIndex = 201,
                                }),
                            }),
                        }),
                        -- Hue slider
                        Create("ImageButton", {
                            Name = "Hue",
                            BackgroundColor3 = Color3.new(1, 1, 1),
                            BorderSizePixel = 0,
                            Position = UDim2.new(1, -20, 0, 8),
                            Size = UDim2.new(0, 12, 0, 100),
                            Image = "rbxassetid://4155801252",
                            ImageColor3 = Color3.new(0, 0, 0),
                            AutoButtonColor = false,
                            ZIndex = 200,
                        }, {
                            Create("UIGradient", {
                                Color = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                                }),
                                Rotation = 90,
                            }),
                            Create("Frame", {
                                Name = "Cursor",
                                BackgroundColor3 = Color3.new(1, 1, 1),
                                BorderSizePixel = 0,
                                Position = UDim2.new(0, -2, h, -2),
                                Size = UDim2.new(1, 4, 0, 4),
                                ZIndex = 201,
                            }),
                        }),
                        -- Hex input
                        Create("TextBox", {
                            Name = "HexInput",
                            BackgroundColor3 = Config.Theme.Background,
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, 8, 1, -24),
                            Size = UDim2.new(1, -16, 0, 16),
                            Font = Config.Font,
                            Text = "#" .. default:ToHex():upper(),
                            TextColor3 = Config.Theme.Text,
                            TextSize = 10,
                            ClearTextOnFocus = false,
                            ZIndex = 200,
                        }),
                    }),
                })
                
                local preview = colorFrame:FindFirstChild("Preview")
                local picker = colorFrame:FindFirstChild("Picker")
                local svPicker = picker:FindFirstChild("SV")
                local huePicker = picker:FindFirstChild("Hue")
                local svCursor = svPicker:FindFirstChild("Cursor")
                local hueCursor = huePicker:FindFirstChild("Cursor")
                local hexInput = picker:FindFirstChild("HexInput")
                
                local isOpen = false
                local draggingSV = false
                local draggingHue = false
                
                local function updateColor()
                    local color = Color3.fromHSV(h, s, v)
                    ColorPicker.Value = color
                    FSlib.Flags[flag] = color
                    preview.BackgroundColor3 = color
                    svPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    svCursor.Position = UDim2.new(s, -4, 1 - v, -4)
                    hueCursor.Position = UDim2.new(0, -2, h, -2)
                    hexInput.Text = "#" .. color:ToHex():upper()
                    callback(color)
                end
                
                preview.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    picker.Visible = isOpen
                end)
                
                svPicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV = true
                    end
                end)
                
                huePicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = true
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if draggingSV then
                            local pos = Vector2.new(input.Position.X, input.Position.Y)
                            local relX = math.clamp((pos.X - svPicker.AbsolutePosition.X) / svPicker.AbsoluteSize.X, 0, 1)
                            local relY = math.clamp((pos.Y - svPicker.AbsolutePosition.Y) / svPicker.AbsoluteSize.Y, 0, 1)
                            s = relX
                            v = 1 - relY
                            updateColor()
                        elseif draggingHue then
                            local pos = Vector2.new(input.Position.X, input.Position.Y)
                            local relY = math.clamp((pos.Y - huePicker.AbsolutePosition.Y) / huePicker.AbsoluteSize.Y, 0, 1)
                            h = relY
                            updateColor()
                        end
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV = false
                        draggingHue = false
                    end
                end)
                
                hexInput.FocusLost:Connect(function()
                    local hex = hexInput.Text:gsub("#", "")
                    local success, color = pcall(function()
                        return Color3.fromHex(hex)
                    end)
                    if success then
                        h, s, v = color:ToHSV()
                        updateColor()
                    else
                        hexInput.Text = "#" .. ColorPicker.Value:ToHex():upper()
                    end
                end)
                
                function ColorPicker:Set(color)
                    h, s, v = color:ToHSV()
                    updateColor()
                end
                
                function ColorPicker:Get()
                    return ColorPicker.Value
                end
                
                return ColorPicker
            end
            
            --[[ 
                ==========================================
                LABEL ELEMENT
                ==========================================
            ]]
            
            function Section:CreateLabel(text)
                local Label = { Type = "Label" }
                table.insert(Section.Elements, Label)
                
                local labelFrame = Create("Frame", {
                    Name = "Label",
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24),
                }, {
                    Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        Size = UDim2.new(1, -16, 1, 0),
                        Font = Config.Font,
                        Text = text or "",
                        TextColor3 = Config.Theme.TextDarker,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }),
                })
                
                local textLabel = labelFrame:FindFirstChild("Text")
                
                function Label:Set(newText)
                    textLabel.Text = newText
                end
                
                return Label
            end
            
            --[[ 
                ==========================================
                DIVIDER ELEMENT
                ==========================================
            ]]
            
            function Section:CreateDivider()
                local Divider = { Type = "Divider" }
                table.insert(Section.Elements, Divider)
                
                Create("Frame", {
                    Name = "Divider",
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 12),
                }, {
                    Create("Frame", {
                        BackgroundColor3 = Config.Theme.Border,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 8, 0.5, 0),
                        Size = UDim2.new(1, -16, 0, 1),
                    }),
                })
                
                return Divider
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- Window methods
    function Window:SetVisible(visible)
        Window.Visible = visible
        mainFrame.Visible = visible
    end
    
    function Window:Destroy()
        mainFrame:Destroy()
        for i, w in pairs(FSlib.Windows) do
            if w == Window then
                table.remove(FSlib.Windows, i)
                break
            end
        end
    end
    
    return Window
end

--[[ 
    ==========================================
    THEME SYSTEM
    ==========================================
]]

function FSlib:SetTheme(theme)
    for key, value in pairs(theme) do
        if Config.Theme[key] then
            Config.Theme[key] = value
        end
    end
end

function FSlib:GetTheme()
    return DeepCopy(Config.Theme)
end

--[[ 
    ==========================================
    CONFIG SYSTEM
    ==========================================
]]

function FSlib:SaveConfig(name)
    if not isfolder then return false end
    
    local folderName = "FSlib_Configs"
    if not isfolder(folderName) then
        makefolder(folderName)
    end
    
    local config = {}
    for flag, value in pairs(FSlib.Flags) do
        if typeof(value) == "Color3" then
            config[flag] = { Type = "Color3", Value = { value.R, value.G, value.B } }
        elseif typeof(value) == "EnumItem" then
            config[flag] = { Type = "EnumItem", Value = tostring(value) }
        else
            config[flag] = { Type = typeof(value), Value = value }
        end
    end
    
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(config)
    end)
    
    if success then
        writefile(folderName .. "/" .. name .. ".json", encoded)
        return true
    end
    
    return false
end

function FSlib:LoadConfig(name)
    if not isfile then return false end
    
    local folderName = "FSlib_Configs"
    local filePath = folderName .. "/" .. name .. ".json"
    
    if not isfile(filePath) then
        return false
    end
    
    local success, config = pcall(function()
        return HttpService:JSONDecode(readfile(filePath))
    end)
    
    if success then
        for flag, data in pairs(config) do
            if data.Type == "Color3" then
                FSlib.Flags[flag] = Color3.new(data.Value[1], data.Value[2], data.Value[3])
            elseif data.Type == "EnumItem" then
                -- Parse enum
                local enumPath = data.Value:split(".")
                if #enumPath == 3 then
                    local enumType = Enum[enumPath[2]]
                    if enumType then
                        FSlib.Flags[flag] = enumType[enumPath[3]]
                    end
                end
            else
                FSlib.Flags[flag] = data.Value
            end
        end
        return true
    end
    
    return false
end

function FSlib:GetConfigs()
    if not isfolder then return {} end
    
    local folderName = "FSlib_Configs"
    if not isfolder(folderName) then
        return {}
    end
    
    local files = listfiles(folderName)
    local configs = {}
    
    for _, file in pairs(files) do
        local name = file:match("([^/\\]+)%.json$")
        if name then
            table.insert(configs, name)
        end
    end
    
    return configs
end

--[[ 
    ==========================================
    CLEANUP
    ==========================================
]]

function FSlib:Destroy()
    for _, window in pairs(FSlib.Windows) do
        window:Destroy()
    end
    for _, connection in pairs(FSlib.Connections) do
        connection:Disconnect()
    end
    if ScreenGui then
        ScreenGui:Destroy()
    end
end

-- Return library
return FSlib
