--[[
    FSLib - Professional Roblox Script GUI Library
    Build 1.0.0
    
    Usage:
    local FSLib = loadstring(game:HttpGet("your-url"))()
    
    local Window = FSLib:CreateWindow({
        Title = "FSLib",
        Subtitle = "build 1.0.0",
        Theme = "Default",
        ToggleKey = Enum.KeyCode.RightShift
    })
    
    local Tab = Window:CreateTab({
        Name = "Aimbot",
        Icon = "◎"
    })
    
    local Section = Tab:CreateSection({
        Name = "Settings",
        Side = "Left"
    })
    
    Section:CreateToggle({...})
    Section:CreateSlider({...})
    ...
]]

local FSLib = {
    Version = "1.0.0",
    Build = "1.0.0"
}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Themes
local Themes = {
    Default = {
        Primary = Color3.fromRGB(15, 15, 20),
        Secondary = Color3.fromRGB(20, 20, 28),
        Tertiary = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(139, 92, 246),
        AccentDark = Color3.fromRGB(109, 62, 216),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(45, 45, 55)
    },
    Blood = {
        Primary = Color3.fromRGB(15, 12, 12),
        Secondary = Color3.fromRGB(22, 18, 18),
        Tertiary = Color3.fromRGB(30, 22, 22),
        Accent = Color3.fromRGB(220, 50, 50),
        AccentDark = Color3.fromRGB(180, 30, 30),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(160, 140, 140),
        Border = Color3.fromRGB(55, 40, 40)
    },
    Ocean = {
        Primary = Color3.fromRGB(12, 15, 18),
        Secondary = Color3.fromRGB(16, 22, 28),
        Tertiary = Color3.fromRGB(20, 28, 38),
        Accent = Color3.fromRGB(56, 189, 248),
        AccentDark = Color3.fromRGB(36, 159, 218),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(140, 160, 170),
        Border = Color3.fromRGB(40, 50, 60)
    },
    Mint = {
        Primary = Color3.fromRGB(12, 18, 15),
        Secondary = Color3.fromRGB(16, 26, 20),
        Tertiary = Color3.fromRGB(20, 35, 28),
        Accent = Color3.fromRGB(52, 211, 153),
        AccentDark = Color3.fromRGB(32, 181, 123),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(140, 170, 155),
        Border = Color3.fromRGB(40, 55, 48)
    }
}

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then
            instance[k] = v
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
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v = 0, 0, max
    local d = max - min
    
    s = max == 0 and 0 or d / max
    
    if max ~= min then
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h * 60
    end
    
    return h, s, v
end

local function RGBtoHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255), 
        math.floor(color.G * 255), 
        math.floor(color.B * 255)
    )
end

-- Main Create Window Function
function FSLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "FSLib"
    local subtitle = config.Subtitle or "build 1.0.0"
    local themeName = config.Theme or "Default"
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    local theme = Themes[themeName] or Themes.Default
    
    local windowVisible = true
    local tabs = {}
    local activeTab = nil
    
    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "FSLib",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (RunService:IsStudio() and Player:WaitForChild("PlayerGui")) or game:GetService("CoreGui")
    })
    
    -- Main Window Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 580, 0, 420),
        Position = UDim2.new(0.5, -290, 0.5, -210),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = MainFrame})
    Create("UIStroke", {
        Color = theme.Border,
        Thickness = 1,
        Parent = MainFrame
    })
    
    -- Accent Line (Top, inside the window)
    local AccentLine = Create("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, -16, 0, 3),
        Position = UDim2.new(0, 8, 0, 8),
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = AccentLine})
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Accent),
            ColorSequenceKeypoint.new(1, theme.AccentDark)
        }),
        Parent = AccentLine
    })
    
    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    
    -- Title
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0, 16, 0, 18),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Subtitle
    local SubtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 100, 0, 16),
        Position = UDim2.new(0, 16 + TitleLabel.TextBounds.X + 8, 0, 20),
        BackgroundTransparency = 1,
        Text = subtitle,
        TextColor3 = theme.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Update subtitle position when title changes
    TitleLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        SubtitleLabel.Position = UDim2.new(0, 16 + TitleLabel.TextBounds.X + 8, 0, 20)
    end)
    
    -- Keybind Hint
    local KeybindHint = Create("TextLabel", {
        Name = "KeybindHint",
        Size = UDim2.new(0, 100, 0, 20),
        Position = UDim2.new(1, -110, 0, 18),
        BackgroundTransparency = 1,
        Text = "[" .. toggleKey.Name .. "]",
        TextColor3 = theme.TextDark,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Header
    })
    
    -- Tab Bar Container
    local TabBar = Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, -32, 0, 32),
        Position = UDim2.new(0, 16, 0, 48),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBar})
    
    local TabListLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = TabBar
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        Parent = TabBar
    })
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -32, 1, -120),
        Position = UDim2.new(0, 16, 0, 88),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ContentContainer})
    
    -- Left Column
    local LeftColumn = Create("ScrollingFrame", {
        Name = "LeftColumn",
        Size = UDim2.new(0.5, -4, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = ContentContainer
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = LeftColumn
    })
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = LeftColumn
    })
    
    -- Right Column
    local RightColumn = Create("ScrollingFrame", {
        Name = "RightColumn",
        Size = UDim2.new(0.5, -4, 1, -8),
        Position = UDim2.new(0.5, 0, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = ContentContainer
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = RightColumn
    })
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = RightColumn
    })
    
    -- Status Bar
    local StatusBar = Create("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 1, -24),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    -- Cover top corners to make them square
    Create("Frame", {
        Name = "TopCover",
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Parent = StatusBar
    })
    
    -- Status Indicator
    local StatusDot = Create("Frame", {
        Name = "StatusDot",
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 12, 0.5, -3),
        BackgroundColor3 = Color3.fromRGB(74, 222, 128),
        BorderSizePixel = 0,
        Parent = StatusBar
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = StatusDot})
    
    local StatusText = Create("TextLabel", {
        Name = "StatusText",
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = "ready",
        TextColor3 = theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = StatusBar
    })
    
    local BuildText = Create("TextLabel", {
        Name = "BuildText",
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0.5, -60, 0, 0),
        BackgroundTransparency = 1,
        Text = "build: " .. os.date("%Y%m%d"),
        TextColor3 = theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Parent = StatusBar
    })
    
    local VersionText = Create("TextLabel", {
        Name = "VersionText",
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(1, -72, 0, 0),
        BackgroundTransparency = 1,
        Text = "v" .. FSLib.Version,
        TextColor3 = theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = StatusBar
    })
    
    -- Dragging
    local dragging, dragStart, startPos
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Toggle Key
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            windowVisible = not windowVisible
            MainFrame.Visible = windowVisible
        end
    end)
    
    -- Window Object
    local Window = {}
    
    -- Set Status Bar
    function Window:SetStatusBar(config)
        if config.Text then StatusText.Text = config.Text end
        if config.Build then BuildText.Text = config.Build end
        if config.Version then VersionText.Text = config.Version end
        if config.Status then
            local colors = {
                ready = Color3.fromRGB(74, 222, 128),
                loading = Color3.fromRGB(250, 204, 21),
                error = Color3.fromRGB(248, 113, 113),
                offline = Color3.fromRGB(120, 120, 130)
            }
            StatusDot.BackgroundColor3 = colors[config.Status] or colors.ready
        end
    end
    
    -- Notifications
    function Window:Notify(config)
        local notifTitle = config.Title or "Notification"
        local message = config.Message or ""
        local notifType = config.Type or "Info"
        local duration = config.Duration or 4
        
        local typeColors = {
            Success = Color3.fromRGB(74, 222, 128),
            Error = Color3.fromRGB(248, 113, 113),
            Warning = Color3.fromRGB(250, 204, 21),
            Info = theme.Accent
        }
        
        local typeIcons = {
            Success = "✓",
            Error = "✕",
            Warning = "⚠",
            Info = "ℹ"
        }
        
        local accentColor = typeColors[notifType] or typeColors.Info
        local icon = typeIcons[notifType] or typeIcons.Info
        
        local NotifFrame = Create("Frame", {
            Name = "Notification",
            Size = UDim2.new(0, 280, 0, 70),
            Position = UDim2.new(1, 300, 1, -90),
            BackgroundColor3 = theme.Primary,
            BorderSizePixel = 0,
            Parent = ScreenGui
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = NotifFrame})
        Create("UIStroke", {Color = theme.Border, Thickness = 1, Parent = NotifFrame})
        
        -- Accent line
        local NotifAccent = Create("Frame", {
            Name = "Accent",
            Size = UDim2.new(1, -12, 0, 2),
            Position = UDim2.new(0, 6, 0, 6),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Parent = NotifFrame
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 1), Parent = NotifAccent})
        
        -- Icon
        Create("TextLabel", {
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0, 12, 0, 18),
            BackgroundTransparency = 1,
            Text = icon,
            TextColor3 = accentColor,
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            Parent = NotifFrame
        })
        
        -- Title
        Create("TextLabel", {
            Size = UDim2.new(1, -50, 0, 16),
            Position = UDim2.new(0, 42, 0, 16),
            BackgroundTransparency = 1,
            Text = notifTitle,
            TextColor3 = theme.Text,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = NotifFrame
        })
        
        -- Message
        Create("TextLabel", {
            Size = UDim2.new(1, -50, 0, 16),
            Position = UDim2.new(0, 42, 0, 34),
            BackgroundTransparency = 1,
            Text = message,
            TextColor3 = theme.TextDark,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = NotifFrame
        })
        
        -- Progress bar
        local ProgressBg = Create("Frame", {
            Size = UDim2.new(1, -12, 0, 2),
            Position = UDim2.new(0, 6, 1, -8),
            BackgroundColor3 = theme.Tertiary,
            BorderSizePixel = 0,
            Parent = NotifFrame
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 1), Parent = ProgressBg})
        
        local ProgressFill = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Parent = ProgressBg
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 1), Parent = ProgressFill})
        
        -- Animate in
        Tween(NotifFrame, {Position = UDim2.new(1, -300, 1, -90)}, 0.3, Enum.EasingStyle.Back)
        
        -- Progress animation
        Tween(ProgressFill, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
        
        -- Animate out
        task.delay(duration, function()
            Tween(NotifFrame, {Position = UDim2.new(1, 300, 1, -90)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.wait(0.35)
            NotifFrame:Destroy()
        end)
    end
    
    -- Create Tab
    function Window:CreateTab(config)
        local tabName = config.Name or "Tab"
        local tabIcon = config.Icon or "◆"
        
        local TabButton = Create("TextButton", {
            Name = "Tab_" .. tabName,
            Size = UDim2.new(0, 90, 0, 24),
            BackgroundColor3 = theme.Tertiary,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = TabBar
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = TabButton})
        
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tabIcon .. "  " .. tabName,
            TextColor3 = theme.TextDark,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            Parent = TabButton
        })
        
        local TabContent = {Left = LeftColumn, Right = RightColumn}
        
        local tabData = {
            Button = TabButton,
            Name = tabName,
            Sections = {}
        }
        
        local function selectTab()
            for _, t in ipairs(tabs) do
                t.Button.BackgroundColor3 = theme.Tertiary
                t.Button:FindFirstChildOfClass("TextLabel").TextColor3 = theme.TextDark
                for _, s in ipairs(t.Sections) do
                    s.Frame.Visible = false
                end
            end
            
            TabButton.BackgroundColor3 = theme.Accent
            TabButton:FindFirstChildOfClass("TextLabel").TextColor3 = theme.Text
            for _, s in ipairs(tabData.Sections) do
                s.Frame.Visible = true
            end
            activeTab = tabData
        end
        
        TabButton.MouseButton1Click:Connect(selectTab)
        
        table.insert(tabs, tabData)
        
        -- Select first tab
        if #tabs == 1 then
            selectTab()
        end
        
        -- Tab Object
        local Tab = {}
        
        function Tab:CreateSection(sectionConfig)
            local sectionName = sectionConfig.Name or "Section"
            local side = sectionConfig.Side or "Left"
            local parent = (side == "Left") and LeftColumn or RightColumn
            
            local SectionFrame = Create("Frame", {
                Name = "Section_" .. sectionName,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Tertiary,
                BorderSizePixel = 0,
                Visible = (activeTab == tabData),
                Parent = parent
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SectionFrame})
            
            local SectionTitle = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -16, 0, 28),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = theme.Text,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionFrame
            })
            
            local ElementsContainer = Create("Frame", {
                Name = "Elements",
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 28),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = SectionFrame
            })
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
                Parent = ElementsContainer
            })
            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
                Parent = ElementsContainer
            })
            
            table.insert(tabData.Sections, {Frame = SectionFrame})
            
            -- Section Object
            local Section = {}
            
            -- Toggle
            function Section:CreateToggle(toggleConfig)
                local toggleName = toggleConfig.Name or "Toggle"
                local default = toggleConfig.Default or false
                local callback = toggleConfig.Callback or function() end
                local enabled = default
                
                local ToggleFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = ElementsContainer
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, -44, 1, 0),
                    BackgroundTransparency = 1,
                    Text = toggleName,
                    TextColor3 = theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })
                
                local ToggleButton = Create("Frame", {
                    Size = UDim2.new(0, 36, 0, 18),
                    Position = UDim2.new(1, -36, 0.5, -9),
                    BackgroundColor3 = enabled and theme.Accent or theme.Secondary,
                    BorderSizePixel = 0,
                    Parent = ToggleFrame
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleButton})
                
                local ToggleCircle = Create("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                    BackgroundColor3 = theme.Text,
                    BorderSizePixel = 0,
                    Parent = ToggleButton
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleCircle})
                
                local ClickButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = ToggleFrame
                })
                
                ClickButton.MouseButton1Click:Connect(function()
                    enabled = not enabled
                    Tween(ToggleButton, {BackgroundColor3 = enabled and theme.Accent or theme.Secondary}, 0.2)
                    Tween(ToggleCircle, {Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2)
                    callback(enabled)
                end)
                
                return {
                    Set = function(_, value)
                        enabled = value
                        Tween(ToggleButton, {BackgroundColor3 = enabled and theme.Accent or theme.Secondary}, 0.2)
                        Tween(ToggleCircle, {Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2)
                        callback(enabled)
                    end,
                    Get = function() return enabled end
                }
            end
            
            -- Slider
            function Section:CreateSlider(sliderConfig)
                local sliderName = sliderConfig.Name or "Slider"
                local min = sliderConfig.Min or 0
                local max = sliderConfig.Max or 100
                local default = sliderConfig.Default or min
                local callback = sliderConfig.Callback or function() end
                local value = default
                
                local SliderFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = ElementsContainer
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(0.6, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = sliderName,
                    TextColor3 = theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame
                })
                
                local ValueLabel = Create("TextLabel", {
                    Size = UDim2.new(0.4, 0, 0, 16),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    TextColor3 = theme.Accent,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderFrame
                })
                
                local SliderBg = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel = 0,
                    Parent = SliderFrame
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderBg})
                
                local SliderFill = Create("Frame", {
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Parent = SliderBg
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
                
                local SliderKnob = Create("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7),
                    BackgroundColor3 = theme.Text,
                    BorderSizePixel = 0,
                    Parent = SliderBg
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderKnob})
                
                local sliderDragging = false
                
                local function updateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max - min) * pos)
                    ValueLabel.Text = tostring(value)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
                    callback(value)
                end
                
                SliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliderDragging = true
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliderDragging = false
                    end
                end)
                
                return {
                    Set = function(_, newValue)
                        value = math.clamp(newValue, min, max)
                        local pos = (value - min) / (max - min)
                        ValueLabel.Text = tostring(value)
                        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                        SliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
                        callback(value)
                    end,
                    Get = function() return value end
                }
            end
            
            -- Button
            function Section:CreateButton(buttonConfig)
                local buttonName = buttonConfig.Name or "Button"
                local callback = buttonConfig.Callback or function() end
                
                local Button = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Text = buttonName,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.GothamMedium,
                    AutoButtonColor = false,
                    Parent = ElementsContainer
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Button})
                
                Button.MouseEnter:Connect(function()
                    Tween(Button, {BackgroundColor3 = theme.AccentDark}, 0.15)
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {BackgroundColor3 = theme.Accent}, 0.15)
                end)
                
                Button.MouseButton1Click:Connect(callback)
            end
            
            -- Dropdown
            function Section:CreateDropdown(dropdownConfig)
                local dropdownName = dropdownConfig.Name or "Dropdown"
                local options = dropdownConfig.Options or {}
                local default = dropdownConfig.Default or (options[1] or "")
                local callback = dropdownConfig.Callback or function() end
                local selected = default
                local isOpen = false
                
                local DropdownFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent = ElementsContainer
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = dropdownName,
                    TextColor3 = theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownFrame
                })
                
                local DropdownButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = DropdownFrame
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DropdownButton})
                
                local SelectedLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = selected,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownButton
                })
                
                local ArrowLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 16, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = theme.TextDark,
                    TextSize = 8,
                    Font = Enum.Font.Gotham,
                    Parent = DropdownButton
                })
                
                -- Options container on ScreenGui
                local OptionsContainer = Create("Frame", {
                    Size = UDim2.new(0, 200, 0, 0),
                    BackgroundColor3 = theme.Primary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 200,
                    ClipsDescendants = true,
                    Parent = ScreenGui
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = OptionsContainer})
                Create("UIStroke", {Color = theme.Border, Thickness = 1, Parent = OptionsContainer})
                
                local OptionsLayout = Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 0),
                    Parent = OptionsContainer
                })
                Create("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    Parent = OptionsContainer
                })
                
                local function createOption(optionText)
                    local OptionBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 24),
                        BackgroundColor3 = theme.Primary,
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        Text = "",
                        AutoButtonColor = false,
                        ZIndex = 201,
                        Parent = OptionsContainer
                    })
                    
                    Create("TextLabel", {
                        Size = UDim2.new(1, -16, 1, 0),
                        Position = UDim2.new(0, 8, 0, 0),
                        BackgroundTransparency = 1,
                        Text = optionText,
                        TextColor3 = (optionText == selected) and theme.Accent or theme.Text,
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 201,
                        Parent = OptionBtn
                    })
                    
                    OptionBtn.MouseEnter:Connect(function()
                        Tween(OptionBtn, {BackgroundColor3 = theme.Secondary}, 0.1)
                    end)
                    
                    OptionBtn.MouseLeave:Connect(function()
                        Tween(OptionBtn, {BackgroundColor3 = theme.Primary}, 0.1)
                    end)
                    
                    OptionBtn.MouseButton1Click:Connect(function()
                        selected = optionText
                        SelectedLabel.Text = selected
                        isOpen = false
                        OptionsContainer.Visible = false
                        
                        for _, child in ipairs(OptionsContainer:GetChildren()) do
                            if child:IsA("TextButton") then
                                local lbl = child:FindFirstChildOfClass("TextLabel")
                                if lbl then
                                    lbl.TextColor3 = (lbl.Text == selected) and theme.Accent or theme.Text
                                end
                            end
                        end
                        
                        callback(selected)
                    end)
                end
                
                for _, opt in ipairs(options) do
                    createOption(opt)
                end
                
                local function toggleDropdown()
                    isOpen = not isOpen
                    if isOpen then
                        local btnPos = DropdownButton.AbsolutePosition
                        local btnSize = DropdownButton.AbsoluteSize
                        local optionCount = #options
                        local height = optionCount * 24 + 8
                        
                        OptionsContainer.Position = UDim2.new(0, btnPos.X, 0, btnPos.Y + btnSize.Y + 2)
                        OptionsContainer.Size = UDim2.new(0, btnSize.X, 0, height)
                        OptionsContainer.Visible = true
                    else
                        OptionsContainer.Visible = false
                    end
                end
                
                DropdownButton.MouseButton1Click:Connect(toggleDropdown)
                
                -- Close when clicking elsewhere
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
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
                            task.defer(function()
                                isOpen = false
                                OptionsContainer.Visible = false
                            end)
                        end
                    end
                end)
                
                return {
                    Set = function(_, value)
                        selected = value
                        SelectedLabel.Text = selected
                        callback(selected)
                    end,
                    Get = function() return selected end,
                    Refresh = function(_, newOptions)
                        options = newOptions
                        for _, child in ipairs(OptionsContainer:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end
                        for _, opt in ipairs(options) do
                            createOption(opt)
                        end
                    end
                }
            end
            
            -- MultiDropdown
            function Section:CreateMultiDropdown(multiConfig)
                local multiName = multiConfig.Name or "MultiDropdown"
                local options = multiConfig.Options or {}
                local default = multiConfig.Default or {}
                local callback = multiConfig.Callback or function() end
                local selected = {}
                for _, v in ipairs(default) do selected[v] = true end
                local isOpen = false
                
                local MultiFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    Parent = ElementsContainer
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = multiName,
                    TextColor3 = theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = MultiFrame
                })
                
                local function getDisplayText()
                    local selectedList = {}
                    for _, opt in ipairs(options) do
                        if selected[opt] then
                            table.insert(selectedList, opt)
                        end
                    end
                    if #selectedList == 0 then return "None" end
                    if #selectedList <= 2 then return table.concat(selectedList, ", ") end
                    return #selectedList .. " selected"
                end
                
                local MultiButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = MultiFrame
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = MultiButton})
                
                local SelectedLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = getDisplayText(),
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = MultiButton
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(0, 16, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = theme.TextDark,
                    TextSize = 8,
                    Font = Enum.Font.Gotham,
                    Parent = MultiButton
                })
                
                local OptionsContainer = Create("Frame", {
                    Size = UDim2.new(0, 200, 0, 0),
                    BackgroundColor3 = theme.Primary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 200,
                    Parent = ScreenGui
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = OptionsContainer})
                Create("UIStroke", {Color = theme.Border, Thickness = 1, Parent = OptionsContainer})
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = OptionsContainer
                })
                Create("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    Parent = OptionsContainer
                })
                
                local checkboxes = {}
                
                for _, optionText in ipairs(options) do
                    local OptionBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 24),
                        BackgroundTransparency = 1,
                        Text = "",
                        ZIndex = 201,
                        Parent = OptionsContainer
                    })
                    
                    local Checkbox = Create("Frame", {
                        Size = UDim2.new(0, 14, 0, 14),
                        Position = UDim2.new(0, 8, 0.5, -7),
                        BackgroundColor3 = selected[optionText] and theme.Accent or theme.Secondary,
                        BorderSizePixel = 0,
                        ZIndex = 201,
                        Parent = OptionBtn
                    })
                    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Checkbox})
                    
                    local Checkmark = Create("TextLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = "✓",
                        TextColor3 = theme.Text,
                        TextSize = 10,
                        Font = Enum.Font.GothamBold,
                        Visible = selected[optionText],
                        ZIndex = 201,
                        Parent = Checkbox
                    })
                    
                    Create("TextLabel", {
                        Size = UDim2.new(1, -32, 1, 0),
                        Position = UDim2.new(0, 28, 0, 0),
                        BackgroundTransparency = 1,
                        Text = optionText,
                        TextColor3 = theme.Text,
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 201,
                        Parent = OptionBtn
                    })
                    
                    checkboxes[optionText] = {Checkbox = Checkbox, Checkmark = Checkmark}
                    
                    OptionBtn.MouseButton1Click:Connect(function()
                        selected[optionText] = not selected[optionText]
                        Checkbox.BackgroundColor3 = selected[optionText] and theme.Accent or theme.Secondary
                        Checkmark.Visible = selected[optionText]
                        SelectedLabel.Text = getDisplayText()
                        
                        local result = {}
                        for _, opt in ipairs(options) do
                            if selected[opt] then table.insert(result, opt) end
                        end
                        callback(result)
                    end)
                end
                
                local function toggleDropdown()
                    isOpen = not isOpen
                    if isOpen then
                        local btnPos = MultiButton.AbsolutePosition
                        local btnSize = MultiButton.AbsoluteSize
                        local height = #options * 24 + 8
                        
                        OptionsContainer.Position = UDim2.new(0, btnPos.X, 0, btnPos.Y + btnSize.Y + 2)
                        OptionsContainer.Size = UDim2.new(0, btnSize.X, 0, height)
                        OptionsContainer.Visible = true
                    else
                        OptionsContainer.Visible = false
                    end
                end
                
                MultiButton.MouseButton1Click:Connect(toggleDropdown)
                
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local optPos = OptionsContainer.AbsolutePosition
                        local optSize = OptionsContainer.AbsoluteSize
                        local btnPos = MultiButton.AbsolutePosition
                        local btnSize = MultiButton.AbsoluteSize
                        
                        local inOptions = mousePos.X >= optPos.X and mousePos.X <= optPos.X + optSize.X and
                                         mousePos.Y >= optPos.Y and mousePos.Y <= optPos.Y + optSize.Y
                        local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
                                        mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
                        
                        if not inOptions and not inButton then
                            task.defer(function()
                                isOpen = false
                                OptionsContainer.Visible = false
                            end)
                        end
                    end
                end)
                
                return {
                    Set = function(_, values)
                        selected = {}
                        for _, v in ipairs(values) do selected[v] = true end
                        for opt, data in pairs(checkboxes) do
                            data.Checkbox.BackgroundColor3 = selected[opt] and theme.Accent or theme.Secondary
                            data.Checkmark.Visible = selected[opt]
                        end
                        SelectedLabel.Text = getDisplayText()
                        callback(values)
                    end,
                    Get = function()
                        local result = {}
                        for _, opt in ipairs(options) do
                            if selected[opt] then table.insert(result, opt) end
                        end
                        return result
                    end
                }
            end
            
            -- Input
            function Section:CreateInput(inputConfig)
                local inputName = inputConfig.Name or "Input"
                local placeholder = inputConfig.Placeholder or "Enter text..."
                local callback = inputConfig.Callback or function() end
                
                local InputFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    Parent = ElementsContainer
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = inputName,
                    TextColor3 = theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = InputFrame
                })
                
                local InputBox = Create("TextBox", {
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel = 0,
                    Text = "",
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = theme.TextDark,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    ClearTextOnFocus = false,
                    Parent = InputFrame
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = InputBox})
                Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = InputBox})
                
                InputBox.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        callback(InputBox.Text)
                    end
                end)
                
                return {
                    Set = function(_, text) InputBox.Text = text end,
                    Get = function() return InputBox.Text end
                }
            end
            
            -- Keybind
            function Section:CreateKeybind(keybindConfig)
                local keybindName = keybindConfig.Name or "Keybind"
                local default = keybindConfig.Default or Enum.KeyCode.Unknown
                local callback = keybindConfig.Callback or function() end
                local key = default
                local listening = false
                
                local KeybindFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = ElementsContainer
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    BackgroundTransparency = 1,
                    Text = keybindName,
                    TextColor3 = theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeybindFrame
                })
                
                local KeybindButton = Create("TextButton", {
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -50, 0.5, -10),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel = 0,
                    Text = key == Enum.KeyCode.Unknown and "None" or key.Name,
                    TextColor3 = theme.Text,
                    TextSize = 10,
                    Font = Enum.Font.GothamMedium,
                    AutoButtonColor = false,
                    Parent = KeybindFrame
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = KeybindButton})
                
                KeybindButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeybindButton.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        key = input.KeyCode
                        KeybindButton.Text = key.Name
                        listening = false
                    elseif not processed and input.KeyCode == key then
                        callback(key)
                    end
                end)
                
                return {
                    Set = function(_, newKey)
                        key = newKey
                        KeybindButton.Text = key.Name
                    end,
                    Get = function() return key end
                }
            end
            
            -- ColorPicker
            function Section:CreateColorPicker(colorConfig)
                local colorName = colorConfig.Name or "Color"
                local defaultColor = colorConfig.Default or Color3.fromRGB(255, 0, 0)
                local defaultAlpha = colorConfig.Alpha or 1
                local callback = colorConfig.Callback or function() end
                
                local currentH, currentS, currentV = RGBtoHSV(defaultColor)
                local currentAlpha = defaultAlpha
                local isOpen = false
                local svDragging, hueDragging, alphaDragging = false, false, false
                
                local ColorFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = ElementsContainer
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, -44, 1, 0),
                    BackgroundTransparency = 1,
                    Text = colorName,
                    TextColor3 = theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorFrame
                })
                
                local ColorButton = Create("TextButton", {
                    Size = UDim2.new(0, 36, 0, 18),
                    Position = UDim2.new(1, -36, 0.5, -9),
                    BackgroundColor3 = defaultColor,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = ColorFrame
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ColorButton})
                Create("UIStroke", {Color = theme.Border, Thickness = 1, Parent = ColorButton})
                
                -- Picker Panel on ScreenGui
                local PickerPanel = Create("Frame", {
                    Size = UDim2.new(0, 180, 0, 200),
                    BackgroundColor3 = theme.Primary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 300,
                    Parent = ScreenGui
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = PickerPanel})
                Create("UIStroke", {Color = theme.Border, Thickness = 1, Parent = PickerPanel})
                
                -- SV Picker
                local SVPicker = Create("Frame", {
                    Size = UDim2.new(1, -16, 0, 120),
                    Position = UDim2.new(0, 8, 0, 8),
                    BackgroundColor3 = HSVtoRGB(currentH, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 301,
                    Parent = PickerPanel
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = SVPicker})
                
                -- White gradient (left to right)
                local WhiteGradient = Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 302,
                    Parent = SVPicker
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = WhiteGradient})
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
                    ZIndex = 303,
                    Parent = SVPicker
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = BlackGradient})
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
                    Position = UDim2.new(currentS, -6, 1 - currentV, -6),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 305,
                    Parent = SVPicker
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SVCursor})
                Create("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 2, Parent = SVCursor})
                
                -- Hue Slider
                local HueSlider = Create("Frame", {
                    Size = UDim2.new(1, -16, 0, 14),
                    Position = UDim2.new(0, 8, 0, 136),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 301,
                    Parent = PickerPanel
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = HueSlider})
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
                    Size = UDim2.new(0, 4, 1, 4),
                    Position = UDim2.new(currentH / 360, -2, 0, -2),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 302,
                    Parent = HueSlider
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = HueCursor})
                
                -- Alpha Slider
                local AlphaSlider = Create("Frame", {
                    Size = UDim2.new(1, -16, 0, 14),
                    Position = UDim2.new(0, 8, 0, 156),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 301,
                    Parent = PickerPanel
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = AlphaSlider})
                
                local AlphaGradient = Create("UIGradient", {
                    Color = ColorSequence.new(Color3.new(0, 0, 0), HSVtoRGB(currentH, currentS, currentV)),
                    Parent = AlphaSlider
                })
                
                local AlphaCursor = Create("Frame", {
                    Size = UDim2.new(0, 4, 1, 4),
                    Position = UDim2.new(currentAlpha, -2, 0, -2),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 302,
                    Parent = AlphaSlider
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = AlphaCursor})
                
                -- Hex Label
                local HexLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -16, 0, 16),
                    Position = UDim2.new(0, 8, 0, 176),
                    BackgroundTransparency = 1,
                    Text = RGBtoHex(defaultColor),
                    TextColor3 = theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.GothamMedium,
                    ZIndex = 301,
                    Parent = PickerPanel
                })
                
                local function updateColor()
                    local color = HSVtoRGB(currentH, currentS, currentV)
                    ColorButton.BackgroundColor3 = color
                    SVPicker.BackgroundColor3 = HSVtoRGB(currentH, 1, 1)
                    SVCursor.Position = UDim2.new(currentS, -6, 1 - currentV, -6)
                    HueCursor.Position = UDim2.new(currentH / 360, -2, 0, -2)
                    AlphaCursor.Position = UDim2.new(currentAlpha, -2, 0, -2)
                    AlphaGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), color)
                    HexLabel.Text = RGBtoHex(color) .. " | " .. math.floor(currentAlpha * 100) .. "%"
                    callback(color, currentAlpha)
                end
                
                ColorButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        local btnPos = ColorButton.AbsolutePosition
                        local btnSize = ColorButton.AbsoluteSize
                        PickerPanel.Position = UDim2.new(0, btnPos.X - 140, 0, btnPos.Y + btnSize.Y + 4)
                        PickerPanel.Visible = true
                    else
                        PickerPanel.Visible = false
                    end
                end)
                
                -- SV Picker interaction
                SVPicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = true
                    end
                end)
                
                -- Hue Slider interaction
                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = true
                    end
                end)
                
                -- Alpha Slider interaction
                AlphaSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        alphaDragging = true
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if svDragging then
                            local pos = SVPicker.AbsolutePosition
                            local size = SVPicker.AbsoluteSize
                            currentS = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                            currentV = math.clamp(1 - (input.Position.Y - pos.Y) / size.Y, 0, 1)
                            updateColor()
                        elseif hueDragging then
                            local pos = HueSlider.AbsolutePosition
                            local size = HueSlider.AbsoluteSize
                            currentH = math.clamp((input.Position.X - pos.X) / size.X, 0, 1) * 360
                            updateColor()
                        elseif alphaDragging then
                            local pos = AlphaSlider.AbsolutePosition
                            local size = AlphaSlider.AbsoluteSize
                            currentAlpha = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                            updateColor()
                        end
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = false
                        hueDragging = false
                        alphaDragging = false
                    end
                end)
                
                -- Close when clicking outside
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
                        if svDragging or hueDragging or alphaDragging then return end
                        
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
                            task.defer(function()
                                isOpen = false
                                PickerPanel.Visible = false
                            end)
                        end
                    end
                end)
                
                return {
                    Set = function(_, color, alpha)
                        currentH, currentS, currentV = RGBtoHSV(color)
                        currentAlpha = alpha or 1
                        updateColor()
                    end,
                    Get = function()
                        return HSVtoRGB(currentH, currentS, currentV), currentAlpha
                    end
                }
            end
            
            -- Label
            function Section:CreateLabel(text)
                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ElementsContainer
                })
                
                return {
                    Set = function(_, newText) Label.Text = newText end
                }
            end
            
            -- Separator
            function Section:CreateSeparator()
                Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = theme.Border,
                    BorderSizePixel = 0,
                    Parent = ElementsContainer
                })
            end
            
            return Section
        end
        
        return Tab
    end
    
    return Window
end

-- Watermark
function FSLib:CreateWatermark(config)
    config = config or {}
    local title = config.Title or "FSLib"
    local themeName = config.Theme or "Default"
    local showFPS = config.ShowFPS ~= false
    local showPing = config.ShowPing ~= false
    local showTime = config.ShowTime ~= false
    local showUser = config.ShowUser ~= false
    local theme = Themes[themeName] or Themes.Default
    
    local ScreenGui = Create("ScreenGui", {
        Name = "FSLib_Watermark",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or game:GetService("CoreGui")
    })
    
    -- Calculate initial width
    local baseWidth = 80  -- Title + padding
    if showUser then baseWidth = baseWidth + 70 end
    if showFPS then baseWidth = baseWidth + 50 end
    if showPing then baseWidth = baseWidth + 50 end
    if showTime then baseWidth = baseWidth + 60 end
    
    local WatermarkFrame = Create("Frame", {
        Size = UDim2.new(0, baseWidth, 0, 24),
        Position = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = WatermarkFrame})
    Create("UIStroke", {Color = theme.Border, Thickness = 1, Parent = WatermarkFrame})
    
    -- Accent line
    local AccentLine = Create("Frame", {
        Size = UDim2.new(1, -12, 0, 2),
        Position = UDim2.new(0, 6, 0, 4),
        BorderSizePixel = 0,
        Parent = WatermarkFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 1), Parent = AccentLine})
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Accent),
            ColorSequenceKeypoint.new(1, theme.AccentDark)
        }),
        Parent = AccentLine
    })
    
    -- Content container
    local Content = Create("Frame", {
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        Parent = WatermarkFrame
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 0),
        Parent = Content
    })
    
    local function createText(text, order, color)
        return Create("TextLabel", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = color or theme.Text,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            LayoutOrder = order,
            Parent = Content
        })
    end
    
    local function createSeparator(order)
        return Create("TextLabel", {
            Size = UDim2.new(0, 16, 1, 0),
            BackgroundTransparency = 1,
            Text = "|",
            TextColor3 = theme.TextDark,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            LayoutOrder = order,
            Parent = Content
        })
    end
    
    local TitleLabel = createText(title, 1, theme.Accent)
    local order = 2
    
    local UserLabel, FPSLabel, PingLabel, TimeLabel
    
    if showUser then
        createSeparator(order); order = order + 1
        UserLabel = createText(Player.Name, order); order = order + 1
    end
    
    if showFPS then
        createSeparator(order); order = order + 1
        FPSLabel = createText("060 fps", order); order = order + 1
    end
    
    if showPing then
        createSeparator(order); order = order + 1
        PingLabel = createText("000 ms", order); order = order + 1
    end
    
    if showTime then
        createSeparator(order); order = order + 1
        TimeLabel = createText("00:00:00", order); order = order + 1
    end
    
    -- Update loop
    local lastUpdate = 0
    RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastUpdate >= 0.5 then
            lastUpdate = now
            
            if FPSLabel then
                local fps = math.floor(1 / RunService.Heartbeat:Wait())
                FPSLabel.Text = string.format("%03d fps", math.min(fps, 999))
            end
            
            if PingLabel then
                local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                PingLabel.Text = string.format("%03d ms", math.min(ping, 999))
            end
            
            if TimeLabel then
                TimeLabel.Text = os.date("%H:%M:%S")
            end
            
            -- Update width based on content
            task.defer(function()
                local totalWidth = 16  -- Padding
                for _, child in ipairs(Content:GetChildren()) do
                    if child:IsA("TextLabel") then
                        totalWidth = totalWidth + child.AbsoluteSize.X
                    end
                end
                WatermarkFrame.Size = UDim2.new(0, totalWidth, 0, 24)
            end)
        end
    end)
    
    -- Dragging
    local dragging, dragStart, startPos
    
    WatermarkFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = WatermarkFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            WatermarkFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return {
        SetTitle = function(_, newTitle)
            TitleLabel.Text = newTitle
        end,
        Hide = function()
            WatermarkFrame.Visible = false
        end,
        Show = function()
            WatermarkFrame.Visible = true
        end,
        Destroy = function()
            ScreenGui:Destroy()
        end
    }
end

return FSLib
