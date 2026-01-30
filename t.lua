--[[
    ███████╗███████╗██╗     ██╗██████╗ 
    ██╔════╝██╔════╝██║     ██║██╔══██╗
    █████╗  ███████╗██║     ██║██████╔╝
    ██╔══╝  ╚════██║██║     ██║██╔══██╗
    ██║     ███████║███████╗██║██████╔╝
    ╚═╝     ╚══════╝╚══════╝╚═╝╚═════╝ 
    
    FriendShip.Lua (FSlib) v2.0.1
    Minimal Tactical Style
    
    A professional Roblox GUI Library
    Compatible with most executors
--]]

local FSlib = {
    _VERSION = "2.0.1",
    _AUTHOR = "FSlib Team",
    Flags = {},
    Windows = {},
    Theme = {
        Primary = Color3.fromRGB(229, 57, 53),
        PrimaryDark = Color3.fromRGB(183, 28, 28),
        PrimaryLight = Color3.fromRGB(255, 82, 82),
        
        Background = Color3.fromRGB(12, 12, 12),
        BackgroundSecondary = Color3.fromRGB(18, 18, 18),
        BackgroundTertiary = Color3.fromRGB(25, 25, 25),
        
        Border = Color3.fromRGB(35, 35, 35),
        BorderLight = Color3.fromRGB(50, 50, 50),
        
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(200, 200, 200),
        TextDisabled = Color3.fromRGB(120, 120, 120),
        
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Info = Color3.fromRGB(33, 150, 243),
    },
    ThemeBindings = {},
}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Utilities
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    if properties and properties.Parent then
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

local function Ripple(button, x, y)
    local ripple = Create("Frame", {
        Name = "Ripple",
        Parent = button,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = button.ZIndex + 1,
    })
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Tween(ripple, { Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1 }, 0.5)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

local function BindTheme(instance, property, themeKey)
    if not FSlib.ThemeBindings[themeKey] then
        FSlib.ThemeBindings[themeKey] = {}
    end
    table.insert(FSlib.ThemeBindings[themeKey], { Instance = instance, Property = property })
    instance[property] = FSlib.Theme[themeKey]
end

function FSlib:SetTheme(newTheme)
    for key, value in pairs(newTheme) do
        if self.Theme[key] then
            self.Theme[key] = value
            if self.ThemeBindings[key] then
                for _, binding in ipairs(self.ThemeBindings[key]) do
                    if binding.Instance and binding.Instance.Parent then
                        binding.Instance[binding.Property] = value
                    end
                end
            end
        end
    end
end

-- Notification System
function FSlib:Notify(options)
    local title = options.Title or "Notification"
    local message = options.Message or ""
    local duration = options.Duration or 3
    local notifType = options.Type or "Info"
    
    local typeColors = {
        Success = FSlib.Theme.Success,
        Warning = FSlib.Theme.Warning,
        Error = FSlib.Theme.Error,
        Info = FSlib.Theme.Info,
    }
    
    local typeColor = typeColors[notifType] or FSlib.Theme.Info
    
    local screenGui = CoreGui:FindFirstChild("FSlib_Notifications") or Create("ScreenGui", {
        Name = "FSlib_Notifications",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    })
    
    local container = screenGui:FindFirstChild("Container") or Create("Frame", {
        Name = "Container",
        Parent = screenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 300, 1, -40),
        AnchorPoint = Vector2.new(1, 1),
    })
    
    if not container:FindFirstChild("UIListLayout") then
        Create("UIListLayout", {
            Parent = container,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 10),
        })
    end
    
    local notification = Create("Frame", {
        Name = "Notification",
        Parent = container,
        BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 70),
        ClipsDescendants = true,
    })
    
    Create("UIStroke", {
        Parent = notification,
        Color = FSlib.Theme.Border,
        Thickness = 1,
    })
    
    -- Left accent bar
    Create("Frame", {
        Name = "Accent",
        Parent = notification,
        BackgroundColor3 = typeColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
    })
    
    Create("TextLabel", {
        Name = "Title",
        Parent = notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(1, -60, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = FSlib.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    Create("TextLabel", {
        Name = "Message",
        Parent = notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 32),
        Size = UDim2.new(1, -24, 0, 30),
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = FSlib.Theme.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
    
    local closeBtn = Create("TextButton", {
        Name = "Close",
        Parent = notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 10),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = FSlib.Theme.TextDisabled,
        TextSize = 18,
    })
    
    -- Animate in
    notification.Position = UDim2.new(1, 0, 0, 0)
    Tween(notification, { Position = UDim2.new(0, 0, 0, 0) }, 0.3)
    
    local function close()
        Tween(notification, { Position = UDim2.new(1, 0, 0, 0) }, 0.3)
        task.delay(0.3, function()
            notification:Destroy()
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(close)
    task.delay(duration, close)
    
    return notification
end

-- Watermark System
function FSlib:CreateWatermark(options)
    local text = options.Text or "FSlib"
    
    local screenGui = Create("ScreenGui", {
        Name = "FSlib_Watermark",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    })
    
    local watermark = Create("Frame", {
        Name = "Watermark",
        Parent = screenGui,
        BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 20, 0, 20),
        Size = UDim2.new(0, 0, 0, 32),
        AutomaticSize = Enum.AutomaticSize.X,
    })
    
    Create("UIStroke", {
        Parent = watermark,
        Color = FSlib.Theme.Border,
        Thickness = 1,
    })
    
    -- Left accent
    local accent = Create("Frame", {
        Name = "Accent",
        Parent = watermark,
        BackgroundColor3 = FSlib.Theme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
    })
    BindTheme(accent, "BackgroundColor3", "Primary")
    
    Create("UIPadding", {
        Parent = watermark,
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
    })
    
    local textLabel = Create("TextLabel", {
        Name = "Text",
        Parent = watermark,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = FSlib.Theme.Text,
        TextSize = 12,
    })
    
    -- Drag functionality
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
    
    -- Update loop
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
        
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        local time = os.date("%H:%M:%S")
        
        textLabel.Text = string.format("%s   |   FPS: %d   |   Ping: %dms   |   %s", text, fps, ping, time)
    end)
    
    local WatermarkAPI = {}
    
    function WatermarkAPI:SetText(newText)
        text = newText
    end
    
    function WatermarkAPI:Show()
        watermark.Visible = true
    end
    
    function WatermarkAPI:Hide()
        watermark.Visible = false
    end
    
    function WatermarkAPI:Destroy()
        screenGui:Destroy()
    end
    
    return WatermarkAPI
end

-- Main Window
function FSlib:CreateWindow(options)
    local title = options.Title or "FSlib"
    local subtitle = options.Subtitle or "v" .. self._VERSION
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    local size = options.Size or UDim2.new(0, 580, 0, 420)
    
    local screenGui = Create("ScreenGui", {
        Name = "FSlib_" .. title,
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    })
    
    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = screenGui,
        BackgroundColor3 = FSlib.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = size,
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
    })
    BindTheme(mainFrame, "BackgroundColor3", "Background")
    
    Create("UIStroke", {
        Parent = mainFrame,
        Color = FSlib.Theme.Border,
        Thickness = 1,
    })
    
    -- Brand accent (left bar)
    local brandAccent = Create("Frame", {
        Name = "BrandAccent",
        Parent = mainFrame,
        BackgroundColor3 = FSlib.Theme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
    })
    BindTheme(brandAccent, "BackgroundColor3", "Primary")
    
    -- Title bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = mainFrame,
        BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 4, 0, 0),
        Size = UDim2.new(1, -4, 0, 36),
    })
    BindTheme(titleBar, "BackgroundColor3", "BackgroundSecondary")
    
    -- Title bar bottom border
    Create("Frame", {
        Name = "Border",
        Parent = titleBar,
        BackgroundColor3 = FSlib.Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
    })
    
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = FSlib.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    BindTheme(titleLabel, "TextColor3", "Text")
    
    local subtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14 + titleLabel.TextBounds.X + 10, 0, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = FSlib.Theme.TextDisabled,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    BindTheme(subtitleLabel, "TextColor3", "TextDisabled")
    
    titleLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        subtitleLabel.Position = UDim2.new(0, 14 + titleLabel.TextBounds.X + 10, 0, 0)
    end)
    
    -- Tab bar
    local tabBar = Create("Frame", {
        Name = "TabBar",
        Parent = mainFrame,
        BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 4, 0, 36),
        Size = UDim2.new(1, -4, 0, 36),
    })
    BindTheme(tabBar, "BackgroundColor3", "BackgroundSecondary")
    
    -- Tab bar bottom border
    Create("Frame", {
        Name = "Border",
        Parent = tabBar,
        BackgroundColor3 = FSlib.Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
    })
    
    local tabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = tabBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, -1),
    })
    
    Create("UIListLayout", {
        Parent = tabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    })
    
    -- Tab indicator
    local tabIndicator = Create("Frame", {
        Name = "Indicator",
        Parent = tabBar,
        BackgroundColor3 = FSlib.Theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 1, -3),
        Size = UDim2.new(0, 60, 0, 3),
    })
    BindTheme(tabIndicator, "BackgroundColor3", "Primary")
    
    -- Content area
    local contentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, 72),
        Size = UDim2.new(1, -4, 1, -72),
        ClipsDescendants = true,
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
    
    -- Toggle visibility
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
    
    -- Window API
    local Window = {
        Tabs = {},
        ActiveTab = nil,
    }
    
    function Window:CreateTab(tabOptions)
        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon or nil
        
        local tabIndex = #self.Tabs + 1
        
        -- Tab button
        local tabButton = Create("TextButton", {
            Name = tabName,
            Parent = tabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = FSlib.Theme.TextDisabled,
            TextSize = 12,
            LayoutOrder = tabIndex,
        })
        
        Create("UIPadding", {
            Parent = tabButton,
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
        })
        
        -- Tab content
        local tabContent = Create("ScrollingFrame", {
            Name = tabName .. "_Content",
            Parent = contentArea,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = FSlib.Theme.Primary,
            AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
            Visible = false,
        })
        
        Create("UIPadding", {
            Parent = tabContent,
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
            PaddingTop = UDim.new(0, 14),
            PaddingBottom = UDim.new(0, 14),
        })
        
        -- Two column layout
        local leftColumn = Create("Frame", {
            Name = "LeftColumn",
            Parent = tabContent,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.5, -8, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        
        Create("UIListLayout", {
            Parent = leftColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12),
        })
        
        local rightColumn = Create("Frame", {
            Name = "RightColumn",
            Parent = tabContent,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 8, 0, 0),
            Size = UDim2.new(0.5, -8, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        
        Create("UIListLayout", {
            Parent = rightColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12),
        })
        
        local Tab = {
            Button = tabButton,
            Content = tabContent,
            LeftColumn = leftColumn,
            RightColumn = rightColumn,
            Sections = {},
        }
        
        local function selectTab()
            for _, t in ipairs(Window.Tabs) do
                t.Content.Visible = false
                t.Button.TextColor3 = FSlib.Theme.TextDisabled
            end
            
            tabContent.Visible = true
            tabButton.TextColor3 = FSlib.Theme.Text
            Window.ActiveTab = Tab
            
            -- Animate indicator
            local buttonPos = tabButton.AbsolutePosition.X - tabContainer.AbsolutePosition.X
            local buttonWidth = tabButton.AbsoluteSize.X
            
            Tween(tabIndicator, {
                Position = UDim2.new(0, buttonPos + 10, 1, -3),
                Size = UDim2.new(0, buttonWidth, 0, 3)
            }, 0.2)
        end
        
        tabButton.MouseButton1Click:Connect(selectTab)
        
        -- Create Section
        function Tab:CreateSection(sectionOptions)
            local sectionName = sectionOptions.Name or "Section"
            local side = sectionOptions.Side or "Left"
            
            local column = side == "Left" and leftColumn or rightColumn
            local sectionIndex = #self.Sections + 1
            
            local sectionFrame = Create("Frame", {
                Name = sectionName,
                Parent = column,
                BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = sectionIndex,
            })
            BindTheme(sectionFrame, "BackgroundColor3", "BackgroundSecondary")
            
            Create("UIStroke", {
                Parent = sectionFrame,
                Color = FSlib.Theme.Border,
                Thickness = 1,
            })
            
            -- Left accent line
            local sectionAccent = Create("Frame", {
                Name = "Accent",
                Parent = sectionFrame,
                BackgroundColor3 = FSlib.Theme.Primary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 10),
                Size = UDim2.new(0, 4, 0, 18),
            })
            BindTheme(sectionAccent, "BackgroundColor3", "Primary")
            
            local sectionHeader = Create("Frame", {
                Name = "Header",
                Parent = sectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 38),
            })
            
            Create("TextLabel", {
                Name = "Title",
                Parent = sectionHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 0),
                Size = UDim2.new(1, -16, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = FSlib.Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            -- Header bottom border
            Create("Frame", {
                Name = "Border",
                Parent = sectionHeader,
                BackgroundColor3 = FSlib.Theme.Border,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -1),
                Size = UDim2.new(1, 0, 0, 1),
            })
            
            local elementsHolder = Create("Frame", {
                Name = "Elements",
                Parent = sectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 38),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            
            Create("UIListLayout", {
                Parent = elementsHolder,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2),
            })
            
            Create("UIPadding", {
                Parent = elementsHolder,
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 10),
            })
            
            local Section = {
                Frame = sectionFrame,
                Content = elementsHolder,
                ElementCount = 0,
            }
            
            -- Toggle
            function Section:CreateToggle(toggleOptions)
                local name = toggleOptions.Name or "Toggle"
                local default = toggleOptions.Default or false
                local flag = toggleOptions.Flag
                local callback = toggleOptions.Callback or function() end
                
                self.ElementCount = self.ElementCount + 1
                local value = default
                
                if flag then
                    FSlib.Flags[flag] = value
                end
                
                local toggleFrame = Create("Frame", {
                    Name = name,
                    Parent = elementsHolder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = self.ElementCount,
                })
                
                local toggleLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = toggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 16, 0, 0),
                    Size = UDim2.new(1, -70, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = FSlib.Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                BindTheme(toggleLabel, "TextColor3", "TextDark")
                
                local toggleContainer = Create("Frame", {
                    Name = "Container",
                    Parent = toggleFrame,
                    BackgroundColor3 = FSlib.Theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -52, 0.5, -9),
                    Size = UDim2.new(0, 36, 0, 18),
                })
                
                Create("UIStroke", {
                    Parent = toggleContainer,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                local toggleSlider = Create("Frame", {
                    Name = "Slider",
                    Parent = toggleContainer,
                    BackgroundColor3 = value and FSlib.Theme.Primary or FSlib.Theme.TextDisabled,
                    BorderSizePixel = 0,
                    Position = value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14),
                })
                
                local toggleButton = Create("TextButton", {
                    Name = "Button",
                    Parent = toggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                })
                
                local function updateToggle()
                    value = not value
                    if flag then
                        FSlib.Flags[flag] = value
                    end
                    
                    Tween(toggleSlider, {
                        Position = value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                        BackgroundColor3 = value and FSlib.Theme.Primary or FSlib.Theme.TextDisabled,
                    }, 0.15)
                    
                    callback(value)
                end
                
                toggleButton.MouseButton1Click:Connect(updateToggle)
                
                local ToggleAPI = {}
                
                function ToggleAPI:Set(newValue)
                    if newValue ~= value then
                        updateToggle()
                    end
                end
                
                function ToggleAPI:Get()
                    return value
                end
                
                return ToggleAPI
            end
            
            -- Slider
            function Section:CreateSlider(sliderOptions)
                local name = sliderOptions.Name or "Slider"
                local min = sliderOptions.Min or 0
                local max = sliderOptions.Max or 100
                local default = sliderOptions.Default or min
                local increment = sliderOptions.Increment or 1
                local suffix = sliderOptions.Suffix or ""
                local flag = sliderOptions.Flag
                local callback = sliderOptions.Callback or function() end
                
                self.ElementCount = self.ElementCount + 1
                local value = default
                
                if flag then
                    FSlib.Flags[flag] = value
                end
                
                local sliderFrame = Create("Frame", {
                    Name = name,
                    Parent = elementsHolder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 46),
                    LayoutOrder = self.ElementCount,
                })
                
                local sliderLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = sliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 16, 0, 6),
                    Size = UDim2.new(0.5, -16, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = FSlib.Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                BindTheme(sliderLabel, "TextColor3", "TextDark")
                
                local valueBox = Create("TextBox", {
                    Name = "ValueBox",
                    Parent = sliderFrame,
                    BackgroundColor3 = FSlib.Theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -66, 0, 6),
                    Size = UDim2.new(0, 50, 0, 18),
                    Font = Enum.Font.GothamMedium,
                    Text = tostring(value) .. suffix,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11,
                    ClearTextOnFocus = false,
                })
                
                Create("UIStroke", {
                    Parent = valueBox,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                local sliderContainer = Create("Frame", {
                    Name = "Container",
                    Parent = sliderFrame,
                    BackgroundColor3 = FSlib.Theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 16, 0, 28),
                    Size = UDim2.new(1, -32, 0, 10),
                })
                
                Create("UIStroke", {
                    Parent = sliderContainer,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                local sliderFill = Create("Frame", {
                    Name = "Fill",
                    Parent = sliderContainer,
                    BackgroundColor3 = FSlib.Theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                })
                BindTheme(sliderFill, "BackgroundColor3", "Primary")
                
                local sliderHead = Create("Frame", {
                    Name = "Head",
                    Parent = sliderFill,
                    BackgroundColor3 = FSlib.Theme.Text,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -2, 0.5, -6),
                    Size = UDim2.new(0, 4, 0, 12),
                    AnchorPoint = Vector2.new(0, 0),
                })
                
                local sliderButton = Create("TextButton", {
                    Name = "Button",
                    Parent = sliderContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                })
                
                local function updateSlider(newValue)
                    newValue = math.clamp(newValue, min, max)
                    newValue = math.floor(newValue / increment + 0.5) * increment
                    
                    value = newValue
                    if flag then
                        FSlib.Flags[flag] = value
                    end
                    
                    local percent = (value - min) / (max - min)
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    valueBox.Text = tostring(value) .. suffix
                    
                    callback(value)
                end
                
                local sliding = false
                
                sliderButton.MouseButton1Down:Connect(function()
                    sliding = true
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = math.clamp(
                            (input.Position.X - sliderContainer.AbsolutePosition.X) / sliderContainer.AbsoluteSize.X,
                            0, 1
                        )
                        local newValue = min + (max - min) * percent
                        updateSlider(newValue)
                    end
                end)
                
                valueBox.FocusLost:Connect(function(enterPressed)
                    local input = valueBox.Text:gsub(suffix, "")
                    local newValue = tonumber(input)
                    if newValue then
                        updateSlider(newValue)
                    else
                        valueBox.Text = tostring(value) .. suffix
                    end
                end)
                
                local SliderAPI = {}
                
                function SliderAPI:Set(newValue)
                    updateSlider(newValue)
                end
                
                function SliderAPI:Get()
                    return value
                end
                
                return SliderAPI
            end
            
            -- Dropdown
            function Section:CreateDropdown(dropdownOptions)
                local name = dropdownOptions.Name or "Dropdown"
                local options = dropdownOptions.Options or {}
                local default = dropdownOptions.Default or options[1]
                local flag = dropdownOptions.Flag
                local callback = dropdownOptions.Callback or function() end
                
                self.ElementCount = self.ElementCount + 1
                local value = default
                local isOpen = false
                
                if flag then
                    FSlib.Flags[flag] = value
                end
                
                local dropdownFrame = Create("Frame", {
                    Name = name,
                    Parent = elementsHolder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 46),
                    LayoutOrder = self.ElementCount,
                    ZIndex = 10,
                })
                
                local dropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = dropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 16, 0, 4),
                    Size = UDim2.new(1, -32, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = FSlib.Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                })
                BindTheme(dropdownLabel, "TextColor3", "TextDark")
                
                local dropdownButton = Create("TextButton", {
                    Name = "Button",
                    Parent = dropdownFrame,
                    BackgroundColor3 = FSlib.Theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 16, 0, 22),
                    Size = UDim2.new(1, -32, 0, 24),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    ZIndex = 10,
                })
                
                Create("UIStroke", {
                    Parent = dropdownButton,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                local selectedLabel = Create("TextLabel", {
                    Name = "Selected",
                    Parent = dropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -30, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = value or "Select...",
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                })
                
                local arrow = Create("TextLabel", {
                    Name = "Arrow",
                    Parent = dropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -22, 0, 0),
                    Size = UDim2.new(0, 14, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = FSlib.Theme.TextDisabled,
                    TextSize = 10,
                    ZIndex = 10,
                })
                
                -- Dropdown list (in ScreenGui for proper layering)
                local dropdownOverlay = Create("TextButton", {
                    Name = name .. "_Overlay",
                    Parent = screenGui,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 99,
                    Visible = false,
                    Active = true,
                })
                
                local dropdownList = Create("Frame", {
                    Name = name .. "_List",
                    Parent = screenGui,
                    BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 200, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Visible = false,
                    ZIndex = 100,
                    ClipsDescendants = true,
                })
                
                Create("UIStroke", {
                    Parent = dropdownList,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                local listContent = Create("Frame", {
                    Name = "Content",
                    Parent = dropdownList,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                })
                
                Create("UIListLayout", {
                    Parent = listContent,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
                
                local function createOptions()
                    for _, child in ipairs(listContent:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for i, option in ipairs(options) do
                        local optionButton = Create("TextButton", {
                            Name = option,
                            Parent = listContent,
                            BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                            BackgroundTransparency = 0,
                            Size = UDim2.new(1, 0, 0, 28),
                            Font = Enum.Font.Gotham,
                            Text = "",
                            LayoutOrder = i,
                            ZIndex = 101,
                            AutoButtonColor = false,
                        })
                        
                        -- Selected indicator
                        local indicator = Create("Frame", {
                            Name = "Indicator",
                            Parent = optionButton,
                            BackgroundColor3 = FSlib.Theme.Primary,
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, 0, 0, 0),
                            Size = UDim2.new(0, 4, 1, 0),
                            Visible = option == value,
                            ZIndex = 102,
                        })
                        BindTheme(indicator, "BackgroundColor3", "Primary")
                        
                        local optionLabel = Create("TextLabel", {
                            Name = "Label",
                            Parent = optionButton,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 14, 0, 0),
                            Size = UDim2.new(1, -14, 1, 0),
                            Font = Enum.Font.Gotham,
                            Text = option,
                            TextColor3 = option == value and FSlib.Theme.Text or FSlib.Theme.TextDark,
                            TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 102,
                        })
                        
                        optionButton.MouseEnter:Connect(function()
                            optionButton.BackgroundColor3 = FSlib.Theme.BackgroundTertiary
                        end)
                        
                        optionButton.MouseLeave:Connect(function()
                            optionButton.BackgroundColor3 = FSlib.Theme.BackgroundSecondary
                        end)
                        
                        optionButton.MouseButton1Click:Connect(function()
                            value = option
                            if flag then
                                FSlib.Flags[flag] = value
                            end
                            
                            selectedLabel.Text = value
                            isOpen = false
                            dropdownList.Visible = false
                            dropdownOverlay.Visible = false
                            
                            createOptions()
                            callback(value)
                        end)
                    end
                end
                
                createOptions()
                
                local function toggleDropdown()
                    isOpen = not isOpen
                    dropdownList.Visible = isOpen
                    dropdownOverlay.Visible = isOpen
                    
                    if isOpen then
                        local buttonPos = dropdownButton.AbsolutePosition
                        local buttonSize = dropdownButton.AbsoluteSize
                        dropdownList.Position = UDim2.new(0, buttonPos.X, 0, buttonPos.Y + buttonSize.Y + 4)
                        dropdownList.Size = UDim2.new(0, buttonSize.X, 0, 0)
                    end
                end
                
                dropdownButton.MouseButton1Click:Connect(toggleDropdown)
                
                dropdownOverlay.MouseButton1Click:Connect(function()
                    isOpen = false
                    dropdownList.Visible = false
                    dropdownOverlay.Visible = false
                end)
                
                local DropdownAPI = {}
                
                function DropdownAPI:Set(newValue)
                    if table.find(options, newValue) then
                        value = newValue
                        if flag then
                            FSlib.Flags[flag] = value
                        end
                        selectedLabel.Text = value
                        createOptions()
                        callback(value)
                    end
                end
                
                function DropdownAPI:SetOptions(newOptions)
                    options = newOptions
                    createOptions()
                end
                
                function DropdownAPI:Get()
                    return value
                end
                
                return DropdownAPI
            end
            
            -- Keybind
            function Section:CreateKeybind(keybindOptions)
                local name = keybindOptions.Name or "Keybind"
                local default = keybindOptions.Default or Enum.KeyCode.Unknown
                local flag = keybindOptions.Flag
                local callback = keybindOptions.Callback or function() end
                
                self.ElementCount = self.ElementCount + 1
                local value = default
                local listening = false
                
                if flag then
                    FSlib.Flags[flag] = value
                end
                
                local keybindFrame = Create("Frame", {
                    Name = name,
                    Parent = elementsHolder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = self.ElementCount,
                })
                
                local keybindLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = keybindFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 16, 0, 0),
                    Size = UDim2.new(1, -90, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = FSlib.Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                BindTheme(keybindLabel, "TextColor3", "TextDark")
                
                local keybindButton = Create("TextButton", {
                    Name = "Button",
                    Parent = keybindFrame,
                    BackgroundColor3 = FSlib.Theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -74, 0.5, -11),
                    Size = UDim2.new(0, 58, 0, 22),
                    Font = Enum.Font.GothamMedium,
                    Text = value.Name or "None",
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 11,
                    AutoButtonColor = false,
                })
                
                Create("UIStroke", {
                    Parent = keybindButton,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                keybindButton.MouseButton1Click:Connect(function()
                    listening = true
                    keybindButton.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            value = input.KeyCode
                            if flag then
                                FSlib.Flags[flag] = value
                            end
                            keybindButton.Text = value.Name
                            listening = false
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                            -- Check if clicked outside
                            task.wait()
                            if not keybindButton:IsDescendantOf(game:GetService("GuiService"):GetGuiInset()) then
                                listening = false
                                keybindButton.Text = value.Name or "None"
                            end
                        end
                    else
                        if not processed and input.KeyCode == value then
                            callback(value)
                        end
                    end
                end)
                
                local KeybindAPI = {}
                
                function KeybindAPI:Set(newValue)
                    value = newValue
                    if flag then
                        FSlib.Flags[flag] = value
                    end
                    keybindButton.Text = value.Name or "None"
                end
                
                function KeybindAPI:Get()
                    return value
                end
                
                return KeybindAPI
            end
            
            -- ColorPicker
            function Section:CreateColorPicker(colorOptions)
                local name = colorOptions.Name or "Color"
                local default = colorOptions.Default or Color3.fromRGB(255, 255, 255)
                local flag = colorOptions.Flag
                local callback = colorOptions.Callback or function() end
                
                self.ElementCount = self.ElementCount + 1
                local value = default
                local h, s, v = Color3.toHSV(value)
                local isOpen = false
                
                if flag then
                    FSlib.Flags[flag] = value
                end
                
                local colorFrame = Create("Frame", {
                    Name = name,
                    Parent = elementsHolder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = self.ElementCount,
                })
                
                local colorLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = colorFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 16, 0, 0),
                    Size = UDim2.new(1, -70, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = FSlib.Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                BindTheme(colorLabel, "TextColor3", "TextDark")
                
                local colorPreview = Create("TextButton", {
                    Name = "Preview",
                    Parent = colorFrame,
                    BackgroundColor3 = value,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -52, 0.5, -9),
                    Size = UDim2.new(0, 36, 0, 18),
                    Text = "",
                    AutoButtonColor = false,
                })
                
                Create("UIStroke", {
                    Parent = colorPreview,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                -- Color picker panel
                local pickerPanel = Create("Frame", {
                    Name = name .. "_Panel",
                    Parent = screenGui,
                    BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 240, 0, 220),
                    Visible = false,
                    ZIndex = 500,
                    Active = true,
                })
                
                Create("UIStroke", {
                    Parent = pickerPanel,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                -- Panel header
                local panelHeader = Create("Frame", {
                    Name = "Header",
                    Parent = pickerPanel,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    ZIndex = 501,
                })
                
                Create("TextLabel", {
                    Name = "Title",
                    Parent = panelHeader,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -12, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = name,
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 501,
                })
                
                Create("Frame", {
                    Name = "Border",
                    Parent = panelHeader,
                    BackgroundColor3 = FSlib.Theme.Border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -1),
                    Size = UDim2.new(1, 0, 0, 1),
                    ZIndex = 501,
                })
                
                -- SV Picker (Saturation/Value)
                local svPicker = Create("Frame", {
                    Name = "SVPicker",
                    Parent = pickerPanel,
                    BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 12, 0, 44),
                    Size = UDim2.new(0, 170, 0, 110),
                    ZIndex = 501,
                })
                
                Create("UIStroke", {
                    Parent = svPicker,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                -- White gradient (left to right)
                local satGradient = Create("Frame", {
                    Name = "SatGradient",
                    Parent = svPicker,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 502,
                })
                
                Create("UIGradient", {
                    Parent = satGradient,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1),
                    }),
                })
                
                -- Black gradient (top to bottom)
                local valGradient = Create("Frame", {
                    Name = "ValGradient",
                    Parent = svPicker,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 503,
                })
                
                Create("UIGradient", {
                    Parent = valGradient,
                    Rotation = 90,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0),
                    }),
                })
                
                local svCursor = Create("Frame", {
                    Name = "Cursor",
                    Parent = svPicker,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(s, -6, 1 - v, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    ZIndex = 505,
                })
                
                Create("UICorner", {
                    Parent = svCursor,
                    CornerRadius = UDim.new(1, 0),
                })
                
                Create("UIStroke", {
                    Parent = svCursor,
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 2,
                })
                
                local svButton = Create("TextButton", {
                    Name = "Button",
                    Parent = svPicker,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 506,
                    Active = true,
                })
                
                -- Hue slider
                local huePicker = Create("Frame", {
                    Name = "HuePicker",
                    Parent = pickerPanel,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 194, 0, 44),
                    Size = UDim2.new(0, 24, 0, 110),
                    ZIndex = 501,
                })
                
                Create("UIStroke", {
                    Parent = huePicker,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                Create("UIGradient", {
                    Parent = huePicker,
                    Rotation = 90,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                    }),
                })
                
                local hueCursor = Create("Frame", {
                    Name = "Cursor",
                    Parent = huePicker,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, -3, h, -3),
                    Size = UDim2.new(1, 6, 0, 6),
                    ZIndex = 502,
                })
                
                Create("UIStroke", {
                    Parent = hueCursor,
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 1,
                })
                
                local hueButton = Create("TextButton", {
                    Name = "Button",
                    Parent = huePicker,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 503,
                    Active = true,
                })
                
                -- Hex input
                local hexLabel = Create("TextLabel", {
                    Name = "HexLabel",
                    Parent = pickerPanel,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 166),
                    Size = UDim2.new(0, 36, 0, 22),
                    Font = Enum.Font.GothamMedium,
                    Text = "HEX",
                    TextColor3 = FSlib.Theme.TextDark,
                    TextSize = 11,
                    ZIndex = 501,
                })
                
                local hexBox = Create("TextBox", {
                    Name = "HexBox",
                    Parent = pickerPanel,
                    BackgroundColor3 = FSlib.Theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 50, 0, 166),
                    Size = UDim2.new(0, 80, 0, 22),
                    Font = Enum.Font.GothamMedium,
                    Text = string.format("#%02X%02X%02X", math.floor(value.R * 255), math.floor(value.G * 255), math.floor(value.B * 255)),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11,
                    ZIndex = 501,
                    ClearTextOnFocus = false,
                })
                
                Create("UIStroke", {
                    Parent = hexBox,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                -- Apply button
                local applyBtn = Create("TextButton", {
                    Name = "Apply",
                    Parent = pickerPanel,
                    BackgroundColor3 = FSlib.Theme.Primary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 144, 0, 166),
                    Size = UDim2.new(0, 76, 0, 22),
                    Font = Enum.Font.GothamBold,
                    Text = "APPLY",
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 11,
                    ZIndex = 501,
                    AutoButtonColor = false,
                })
                BindTheme(applyBtn, "BackgroundColor3", "Primary")
                
                -- Preview box
                local previewBox = Create("Frame", {
                    Name = "PreviewBox",
                    Parent = pickerPanel,
                    BackgroundColor3 = value,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 12, 0, 196),
                    Size = UDim2.new(1, -24, 0, 12),
                    ZIndex = 501,
                })
                
                Create("UIStroke", {
                    Parent = previewBox,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                local function updateColor()
                    value = Color3.fromHSV(h, s, v)
                    colorPreview.BackgroundColor3 = value
                    previewBox.BackgroundColor3 = value
                    svPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    svCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                    hueCursor.Position = UDim2.new(0, -3, h, -3)
                    hexBox.Text = string.format("#%02X%02X%02X", math.floor(value.R * 255), math.floor(value.G * 255), math.floor(value.B * 255))
                    
                    if flag then
                        FSlib.Flags[flag] = value
                    end
                end
                
                -- SV picking
                local svDragging = false
                
                svButton.MouseButton1Down:Connect(function()
                    svDragging = true
                end)
                
                svButton.MouseButton1Up:Connect(function()
                    svDragging = false
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = false
                    end
                end)
                
                RunService.RenderStepped:Connect(function()
                    if svDragging then
                        local mousePos = UserInputService:GetMouseLocation()
                        local relX = math.clamp((mousePos.X - svPicker.AbsolutePosition.X) / svPicker.AbsoluteSize.X, 0, 1)
                        local relY = math.clamp((mousePos.Y - svPicker.AbsolutePosition.Y - 36) / svPicker.AbsoluteSize.Y, 0, 1)
                        s = relX
                        v = 1 - relY
                        updateColor()
                    end
                end)
                
                -- Hue picking
                local hueDragging = false
                
                hueButton.MouseButton1Down:Connect(function()
                    hueDragging = true
                end)
                
                hueButton.MouseButton1Up:Connect(function()
                    hueDragging = false
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = false
                    end
                end)
                
                RunService.RenderStepped:Connect(function()
                    if hueDragging then
                        local mousePos = UserInputService:GetMouseLocation()
                        local relY = math.clamp((mousePos.Y - huePicker.AbsolutePosition.Y - 36) / huePicker.AbsoluteSize.Y, 0, 1)
                        h = relY
                        updateColor()
                    end
                end)
                
                -- Hex input
                hexBox.FocusLost:Connect(function()
                    local hex = hexBox.Text:gsub("#", "")
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1, 2), 16)
                        local g = tonumber(hex:sub(3, 4), 16)
                        local b = tonumber(hex:sub(5, 6), 16)
                        if r and g and b then
                            value = Color3.fromRGB(r, g, b)
                            h, s, v = Color3.toHSV(value)
                            updateColor()
                        end
                    end
                end)
                
                -- Toggle panel
                colorPreview.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    pickerPanel.Visible = isOpen
                    
                    if isOpen then
                        local previewPos = colorPreview.AbsolutePosition
                        pickerPanel.Position = UDim2.new(0, previewPos.X - 195, 0, previewPos.Y + 24)
                    end
                end)
                
                -- Apply button (only way to close)
                applyBtn.MouseButton1Click:Connect(function()
                    isOpen = false
                    pickerPanel.Visible = false
                    callback(value)
                end)
                
                local ColorAPI = {}
                
                function ColorAPI:Set(newColor)
                    value = newColor
                    h, s, v = Color3.toHSV(value)
                    updateColor()
                    callback(value)
                end
                
                function ColorAPI:Get()
                    return value
                end
                
                return ColorAPI
            end
            
            -- Textbox
            function Section:CreateTextbox(textboxOptions)
                local name = textboxOptions.Name or "Textbox"
                local placeholder = textboxOptions.Placeholder or "Enter text..."
                local default = textboxOptions.Default or ""
                local flag = textboxOptions.Flag
                local callback = textboxOptions.Callback or function() end
                
                self.ElementCount = self.ElementCount + 1
                local value = default
                
                if flag then
                    FSlib.Flags[flag] = value
                end
                
                local textboxFrame = Create("Frame", {
                    Name = name,
                    Parent = elementsHolder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 46),
                    LayoutOrder = self.ElementCount,
                })
                
                local textboxLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = textboxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 16, 0, 4),
                    Size = UDim2.new(1, -32, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = FSlib.Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                BindTheme(textboxLabel, "TextColor3", "TextDark")
                
                local textbox = Create("TextBox", {
                    Name = "Input",
                    Parent = textboxFrame,
                    BackgroundColor3 = FSlib.Theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 16, 0, 22),
                    Size = UDim2.new(1, -32, 0, 24),
                    Font = Enum.Font.Gotham,
                    Text = default,
                    PlaceholderText = placeholder,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    PlaceholderColor3 = FSlib.Theme.TextDisabled,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                })
                
                Create("UIPadding", {
                    Parent = textbox,
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                })
                
                Create("UIStroke", {
                    Parent = textbox,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                textbox.FocusLost:Connect(function()
                    value = textbox.Text
                    if flag then
                        FSlib.Flags[flag] = value
                    end
                    callback(value)
                end)
                
                local TextboxAPI = {}
                
                function TextboxAPI:Set(newValue)
                    value = newValue
                    textbox.Text = value
                    if flag then
                        FSlib.Flags[flag] = value
                    end
                end
                
                function TextboxAPI:Get()
                    return value
                end
                
                return TextboxAPI
            end
            
            -- Button
            function Section:CreateButton(buttonOptions)
                local name = buttonOptions.Name or "Button"
                local callback = buttonOptions.Callback or function() end
                
                self.ElementCount = self.ElementCount + 1
                
                local buttonFrame = Create("Frame", {
                    Name = name,
                    Parent = elementsHolder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                    LayoutOrder = self.ElementCount,
                })
                
                local button = Create("TextButton", {
                    Name = "Button",
                    Parent = buttonFrame,
                    BackgroundColor3 = FSlib.Theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 16, 0, 4),
                    Size = UDim2.new(1, -32, 0, 30),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 12,
                    AutoButtonColor = false,
                    ClipsDescendants = true,
                })
                
                Create("UIStroke", {
                    Parent = button,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                button.MouseEnter:Connect(function()
                    Tween(button, { BackgroundColor3 = FSlib.Theme.Primary }, 0.15)
                end)
                
                button.MouseLeave:Connect(function()
                    Tween(button, { BackgroundColor3 = FSlib.Theme.BackgroundTertiary }, 0.15)
                end)
                
                button.MouseButton1Click:Connect(function()
                    Ripple(button, Mouse.X, Mouse.Y)
                    callback()
                end)
                
                return button
            end
            
            -- Label
            function Section:CreateLabel(text)
                self.ElementCount = self.ElementCount + 1
                
                local labelFrame = Create("Frame", {
                    Name = "Label",
                    Parent = elementsHolder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    LayoutOrder = self.ElementCount,
                })
                
                local label = Create("TextLabel", {
                    Name = "Text",
                    Parent = labelFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 16, 0, 0),
                    Size = UDim2.new(1, -32, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = FSlib.Theme.TextDisabled,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                BindTheme(label, "TextColor3", "TextDisabled")
                
                local LabelAPI = {}
                
                function LabelAPI:Set(newText)
                    label.Text = newText
                end
                
                return LabelAPI
            end
            
            -- Divider
            function Section:CreateDivider()
                self.ElementCount = self.ElementCount + 1
                
                local dividerFrame = Create("Frame", {
                    Name = "Divider",
                    Parent = elementsHolder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    LayoutOrder = self.ElementCount,
                })
                
                Create("Frame", {
                    Name = "Line",
                    Parent = dividerFrame,
                    BackgroundColor3 = FSlib.Theme.Border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 16, 0.5, 0),
                    Size = UDim2.new(1, -32, 0, 1),
                })
                
                return dividerFrame
            end
            
            table.insert(self.Sections, Section)
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Select first tab
        if #Window.Tabs == 1 then
            selectTab()
        end
        
        return Tab
    end
    
    table.insert(FSlib.Windows, Window)
    return Window
end

-- Config System
FSlib.ConfigFolder = "FSlib_Configs"

function FSlib:SaveConfig(name)
    if not isfolder then return false end
    
    if not isfolder(self.ConfigFolder) then
        makefolder(self.ConfigFolder)
    end
    
    local configData = {}
    for flag, value in pairs(self.Flags) do
        if typeof(value) == "Color3" then
            configData[flag] = {
                Type = "Color3",
                R = value.R,
                G = value.G,
                B = value.B,
            }
        elseif typeof(value) == "EnumItem" then
            configData[flag] = {
                Type = "EnumItem",
                EnumType = tostring(value.EnumType),
                Name = value.Name,
            }
        else
            configData[flag] = {
                Type = typeof(value),
                Value = value,
            }
        end
    end
    
    local success, result = pcall(function()
        writefile(self.ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(configData))
    end)
    
    return success
end

function FSlib:LoadConfig(name)
    if not isfile then return false end
    
    local path = self.ConfigFolder .. "/" .. name .. ".json"
    if not isfile(path) then return false end
    
    local success, result = pcall(function()
        local data = HttpService:JSONDecode(readfile(path))
        for flag, info in pairs(data) do
            if info.Type == "Color3" then
                self.Flags[flag] = Color3.new(info.R, info.G, info.B)
            elseif info.Type == "EnumItem" then
                self.Flags[flag] = Enum[info.EnumType][info.Name]
            else
                self.Flags[flag] = info.Value
            end
        end
    end)
    
    return success
end

function FSlib:GetConfigs()
    if not isfolder or not isfolder(self.ConfigFolder) then
        return {}
    end
    
    local configs = {}
    for _, file in ipairs(listfiles(self.ConfigFolder)) do
        if file:match("%.json$") then
            table.insert(configs, file:match("([^/\\]+)%.json$"))
        end
    end
    
    return configs
end

function FSlib:DeleteConfig(name)
    if not isfile then return false end
    
    local path = self.ConfigFolder .. "/" .. name .. ".json"
    if isfile(path) then
        delfile(path)
        return true
    end
    
    return false
end

return FSlib
