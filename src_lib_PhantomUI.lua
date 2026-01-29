--[[
    PhantomUI - Premium Roblox Script GUI Library
    Version: 1.0.0
    Style: Modern Minimal Industrial
    
    Inspired by classic cheat GUIs but with a unique aesthetic
    No gradient bars, no corner issues, clean design
]]

local PhantomUI = {}
PhantomUI.__index = PhantomUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

-- Theme System
local Themes = {
    Phantom = {
        Background = Color3.fromRGB(12, 12, 14),
        Surface = Color3.fromRGB(18, 18, 22),
        SurfaceAlt = Color3.fromRGB(24, 24, 28),
        Border = Color3.fromRGB(35, 35, 42),
        BorderLight = Color3.fromRGB(45, 45, 55),
        Text = Color3.fromRGB(235, 235, 240),
        TextDim = Color3.fromRGB(140, 140, 155),
        TextDark = Color3.fromRGB(85, 85, 100),
        Accent = Color3.fromRGB(130, 100, 255),
        AccentDark = Color3.fromRGB(100, 75, 200),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(240, 180, 50),
        Error = Color3.fromRGB(240, 70, 80),
        Glow = Color3.fromRGB(130, 100, 255)
    },
    Crimson = {
        Background = Color3.fromRGB(14, 10, 12),
        Surface = Color3.fromRGB(22, 16, 18),
        SurfaceAlt = Color3.fromRGB(30, 22, 25),
        Border = Color3.fromRGB(50, 30, 35),
        BorderLight = Color3.fromRGB(65, 40, 48),
        Text = Color3.fromRGB(240, 235, 235),
        TextDim = Color3.fromRGB(155, 140, 145),
        TextDark = Color3.fromRGB(100, 80, 85),
        Accent = Color3.fromRGB(220, 50, 70),
        AccentDark = Color3.fromRGB(180, 35, 55),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(240, 180, 50),
        Error = Color3.fromRGB(240, 70, 80),
        Glow = Color3.fromRGB(220, 50, 70)
    },
    Ocean = {
        Background = Color3.fromRGB(8, 12, 16),
        Surface = Color3.fromRGB(12, 18, 24),
        SurfaceAlt = Color3.fromRGB(18, 26, 34),
        Border = Color3.fromRGB(25, 40, 55),
        BorderLight = Color3.fromRGB(35, 55, 75),
        Text = Color3.fromRGB(230, 240, 245),
        TextDim = Color3.fromRGB(130, 155, 170),
        TextDark = Color3.fromRGB(75, 95, 110),
        Accent = Color3.fromRGB(45, 165, 235),
        AccentDark = Color3.fromRGB(30, 130, 190),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(240, 180, 50),
        Error = Color3.fromRGB(240, 70, 80),
        Glow = Color3.fromRGB(45, 165, 235)
    },
    Mint = {
        Background = Color3.fromRGB(10, 14, 12),
        Surface = Color3.fromRGB(14, 22, 18),
        SurfaceAlt = Color3.fromRGB(20, 30, 25),
        Border = Color3.fromRGB(30, 50, 40),
        BorderLight = Color3.fromRGB(40, 65, 52),
        Text = Color3.fromRGB(235, 245, 240),
        TextDim = Color3.fromRGB(140, 165, 150),
        TextDark = Color3.fromRGB(80, 105, 90),
        Accent = Color3.fromRGB(55, 210, 150),
        AccentDark = Color3.fromRGB(40, 170, 120),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(240, 180, 50),
        Error = Color3.fromRGB(240, 70, 80),
        Glow = Color3.fromRGB(55, 210, 150)
    }
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
        CornerRadius = UDim.new(0, radius or 4),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
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

-- Main Library
function PhantomUI:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Phantom"
    local subtitle = options.Subtitle or "v1.0.0"
    local themeName = options.Theme or "Phantom"
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    local size = options.Size or UDim2.new(0, 580, 0, 420)
    
    local theme = Themes[themeName] or Themes.Phantom
    local isVisible = true
    local windowObj = {}
    
    -- Status Bar Config
    local statusConfig = options.StatusBar or {}
    local statusText = statusConfig.Text or "ready"
    local statusState = statusConfig.Status or "ready"
    local statusBuild = statusConfig.Build or os.date("build: %Y%m%d")
    local statusVersion = statusConfig.Version or "v1.0.0"
    
    -- Destroy existing
    local existing = CoreGui:FindFirstChild("PhantomUI")
    if existing then existing:Destroy() end
    
    -- Screen GUI
    local ScreenGui = Create("ScreenGui", {
        Name = "PhantomUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    -- Main Window
    local Window = Create("Frame", {
        Name = "Window",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    AddCorner(Window, 8)
    AddStroke(Window, theme.Border, 1)
    
    -- Outer Glow Effect
    local OuterGlow = Create("ImageLabel", {
        Name = "Glow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = theme.Glow,
        ImageTransparency = 0.85,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        Parent = Window
    })
    
    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Parent = Window
    })
    AddCorner(Header, 8)
    
    -- Header Bottom Cover (makes bottom corners square)
    local HeaderCover = Create("Frame", {
        Name = "Cover",
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Parent = Header
    })
    
    -- Header Border
    local HeaderBorder = Create("Frame", {
        Name = "Border",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Parent = Header
    })
    
    -- Accent Line (inside header, at very top)
    local AccentLine = Create("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, -16, 0, 2),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Parent = Header
    })
    AddCorner(AccentLine, 1)
    
    -- Title Container (to properly layout title and subtitle)
    local TitleContainer = Create("Frame", {
        Name = "TitleContainer",
        Size = UDim2.new(0, 0, 0, 20),
        Position = UDim2.new(0, 14, 0.5, -10),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Parent = Header
    })
    
    local TitleLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = TitleContainer
    })
    
    -- Title
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        LayoutOrder = 1,
        Parent = TitleContainer
    })
    
    -- Subtitle
    local SubtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = subtitle,
        TextColor3 = theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        LayoutOrder = 2,
        Parent = TitleContainer
    })
    
    -- Keybind Hint
    local KeybindHint = Create("TextLabel", {
        Name = "KeybindHint",
        Size = UDim2.new(0, 100, 0, 20),
        Position = UDim2.new(1, -110, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "[" .. toggleKey.Name .. "]",
        TextColor3 = theme.TextDark,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Header
    })
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, 0, 1, -42 - 28),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = Window
    })
    
    -- Tab List (Left Side)
    local TabList = Create("Frame", {
        Name = "TabList",
        Size = UDim2.new(0, 100, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Parent = ContentContainer
    })
    AddCorner(TabList, 6)
    
    local TabListLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = TabList
    })
    AddPadding(TabList, 4)
    
    -- Tab Content (Right Side)
    local TabContent = Create("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, -112, 1, -8),
        Position = UDim2.new(0, 108, 0, 4),
        BackgroundTransparency = 1,
        Parent = ContentContainer
    })
    
    -- Status Bar
    local StatusBar = Create("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 1, -28),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Parent = Window
    })
    AddCorner(StatusBar, 8)
    
    -- Status Bar Top Cover (makes top corners square)
    local StatusCover = Create("Frame", {
        Name = "Cover",
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Parent = StatusBar
    })
    
    -- Status Bar Top Border
    local StatusBorder = Create("Frame", {
        Name = "Border",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Parent = StatusBar
    })
    
    -- Status Indicator
    local StatusColors = {
        ready = theme.Success,
        loading = theme.Warning,
        error = theme.Error,
        offline = theme.TextDark
    }
    
    local StatusDot = Create("Frame", {
        Name = "StatusDot",
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 12, 0.5, -3),
        BackgroundColor3 = StatusColors[statusState] or theme.Success,
        BorderSizePixel = 0,
        Parent = StatusBar
    })
    AddCorner(StatusDot, 3)
    
    local StatusLabel = Create("TextLabel", {
        Name = "StatusText",
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = statusText,
        TextColor3 = theme.TextDim,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = StatusBar
    })
    
    local BuildLabel = Create("TextLabel", {
        Name = "Build",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = statusBuild,
        TextColor3 = theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Parent = StatusBar
    })
    
    local VersionLabel = Create("TextLabel", {
        Name = "Version",
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -112, 0, 0),
        BackgroundTransparency = 1,
        Text = statusVersion,
        TextColor3 = theme.TextDim,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = StatusBar
    })
    
    -- Dragging
    local dragging = false
    local dragStart, startPos
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(
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
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey then
            isVisible = not isVisible
            Window.Visible = isVisible
        end
    end)
    
    -- Tab System
    local tabs = {}
    local activeTab = nil
    
    function windowObj:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon or ""
        local tabObj = {}
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = theme.SurfaceAlt,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = #tabs + 1,
            Parent = TabList
        })
        AddCorner(TabButton, 4)
        
        -- Tab Active Indicator
        local TabIndicator = Create("Frame", {
            Name = "Indicator",
            Size = UDim2.new(0, 3, 0, 16),
            Position = UDim2.new(0, 0, 0.5, -8),
            BackgroundColor3 = theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = TabButton
        })
        AddCorner(TabIndicator, 1)
        
        -- Tab Label
        local TabLabel = Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -12, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })
        
        -- Tab Page
        local TabPage = Create("ScrollingFrame", {
            Name = tabName .. "Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Accent,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = TabContent
        })
        
        -- Two Column Layout
        local LeftColumn = Create("Frame", {
            Name = "LeftColumn",
            Size = UDim2.new(0.5, -4, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = TabPage
        })
        
        local LeftLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
            Parent = LeftColumn
        })
        
        local RightColumn = Create("Frame", {
            Name = "RightColumn",
            Size = UDim2.new(0.5, -4, 0, 0),
            Position = UDim2.new(0.5, 4, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = TabPage
        })
        
        local RightLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
            Parent = RightColumn
        })
        
        -- Tab Selection
        local function selectTab()
            if activeTab then
                activeTab.Button.BackgroundTransparency = 1
                activeTab.Indicator.BackgroundTransparency = 1
                activeTab.Label.TextColor3 = theme.TextDim
                activeTab.Page.Visible = false
            end
            
            Tween(TabButton, {BackgroundTransparency = 0}, 0.15)
            Tween(TabIndicator, {BackgroundTransparency = 0}, 0.15)
            TabLabel.TextColor3 = theme.Text
            TabPage.Visible = true
            
            activeTab = {
                Button = TabButton,
                Indicator = TabIndicator,
                Label = TabLabel,
                Page = TabPage
            }
        end
        
        TabButton.MouseEnter:Connect(function()
            if activeTab and activeTab.Button ~= TabButton then
                Tween(TabButton, {BackgroundTransparency = 0.5}, 0.1)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if activeTab and activeTab.Button ~= TabButton then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.1)
            end
        end)
        
        TabButton.MouseButton1Click:Connect(selectTab)
        
        -- Auto select first tab
        if #tabs == 0 then
            task.defer(selectTab)
        end
        
        -- Section Creator
        function tabObj:CreateSection(sectionOptions, column)
            sectionOptions = sectionOptions or {}
            local sectionName = sectionOptions.Name or "Section"
            column = column or "Left"
            local sectionObj = {}
            
            local parent = column == "Left" and LeftColumn or RightColumn
            
            -- Section Container
            local Section = Create("Frame", {
                Name = sectionName,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Surface,
                BorderSizePixel = 0,
                LayoutOrder = #parent:GetChildren(),
                Parent = parent
            })
            AddCorner(Section, 6)
            AddStroke(Section, theme.Border, 1)
            
            -- Section Header
            local SectionHeader = Create("Frame", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Parent = Section
            })
            
            local SectionTitle = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = theme.Text,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            -- Section Content
            local SectionContent = Create("Frame", {
                Name = "Content",
                Size = UDim2.new(1, -12, 0, 0),
                Position = UDim2.new(0, 6, 0, 28),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = Section
            })
            
            local ContentLayout = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
                Parent = SectionContent
            })
            
            local ContentPadding = Create("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
                Parent = SectionContent
            })
            
            local elementCount = 0
            
            -- Toggle
            function sectionObj:CreateToggle(opts)
                opts = opts or {}
                local name = opts.Name or "Toggle"
                local default = opts.Default or false
                local callback = opts.Callback or function() end
                local enabled = default
                elementCount = elementCount + 1
                
                local Toggle = Create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementCount,
                    Parent = SectionContent
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = theme.TextDim,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Toggle
                })
                
                local ToggleBox = Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -20, 0.5, -8),
                    BackgroundColor3 = enabled and theme.Accent or theme.SurfaceAlt,
                    BorderSizePixel = 0,
                    Parent = Toggle
                })
                AddCorner(ToggleBox, 4)
                AddStroke(ToggleBox, theme.BorderLight, 1)
                
                local Checkmark = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "✓",
                    TextColor3 = theme.Background,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextTransparency = enabled and 0 or 1,
                    Parent = ToggleBox
                })
                
                local ToggleButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = Toggle
                })
                
                local function updateToggle()
                    Tween(ToggleBox, {BackgroundColor3 = enabled and theme.Accent or theme.SurfaceAlt}, 0.15)
                    Tween(Checkmark, {TextTransparency = enabled and 0 or 1}, 0.15)
                    callback(enabled)
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    enabled = not enabled
                    updateToggle()
                end)
                
                local toggleObj = {}
                function toggleObj:Set(value)
                    enabled = value
                    updateToggle()
                end
                function toggleObj:Get()
                    return enabled
                end
                
                return toggleObj
            end
            
            -- Slider
            function sectionObj:CreateSlider(opts)
                opts = opts or {}
                local name = opts.Name or "Slider"
                local min = opts.Min or 0
                local max = opts.Max or 100
                local default = opts.Default or min
                local suffix = opts.Suffix or ""
                local callback = opts.Callback or function() end
                local value = default
                elementCount = elementCount + 1
                
                local Slider = Create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementCount,
                    Parent = SectionContent
                })
                
                local SliderLabel = Create("TextLabel", {
                    Size = UDim2.new(0.6, 0, 0, 18),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = theme.TextDim,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Slider
                })
                
                local SliderValue = Create("TextLabel", {
                    Size = UDim2.new(0.4, -4, 0, 18),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value) .. suffix,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Slider
                })
                
                local SliderTrack = Create("Frame", {
                    Size = UDim2.new(1, -8, 0, 6),
                    Position = UDim2.new(0, 4, 0, 24),
                    BackgroundColor3 = theme.SurfaceAlt,
                    BorderSizePixel = 0,
                    Parent = Slider
                })
                AddCorner(SliderTrack, 3)
                
                local SliderFill = Create("Frame", {
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Parent = SliderTrack
                })
                AddCorner(SliderFill, 3)
                
                local SliderKnob = Create("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6),
                    BackgroundColor3 = theme.Text,
                    BorderSizePixel = 0,
                    Parent = SliderTrack
                })
                AddCorner(SliderKnob, 6)
                
                local sliding = false
                
                local function updateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max - min) * pos)
                    
                    Tween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
                    Tween(SliderKnob, {Position = UDim2.new(pos, -6, 0.5, -6)}, 0.05)
                    SliderValue.Text = tostring(value) .. suffix
                    callback(value)
                end
                
                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)
                
                local sliderObj = {}
                function sliderObj:Set(val)
                    value = math.clamp(val, min, max)
                    local pos = (value - min) / (max - min)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
                    SliderValue.Text = tostring(value) .. suffix
                    callback(value)
                end
                function sliderObj:Get()
                    return value
                end
                
                return sliderObj
            end
            
            -- Button
            function sectionObj:CreateButton(opts)
                opts = opts or {}
                local name = opts.Name or "Button"
                local callback = opts.Callback or function() end
                elementCount = elementCount + 1
                
                local Button = Create("TextButton", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = theme.SurfaceAlt,
                    BorderSizePixel = 0,
                    Text = name,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.GothamMedium,
                    AutoButtonColor = false,
                    LayoutOrder = elementCount,
                    Parent = SectionContent
                })
                AddCorner(Button, 4)
                AddStroke(Button, theme.BorderLight, 1)
                
                Button.MouseEnter:Connect(function()
                    Tween(Button, {BackgroundColor3 = theme.Accent}, 0.1)
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {BackgroundColor3 = theme.SurfaceAlt}, 0.1)
                end)
                
                Button.MouseButton1Click:Connect(function()
                    Tween(Button, {BackgroundColor3 = theme.AccentDark}, 0.05)
                    task.delay(0.1, function()
                        Tween(Button, {BackgroundColor3 = theme.Accent}, 0.1)
                    end)
                    callback()
                end)
                
                return Button
            end
            
            -- Dropdown
            function sectionObj:CreateDropdown(opts)
                opts = opts or {}
                local name = opts.Name or "Dropdown"
                local options = opts.Options or {}
                local default = opts.Default or (options[1] or "")
                local callback = opts.Callback or function() end
                local selected = default
                local isOpen = false
                elementCount = elementCount + 1
                
                local Dropdown = Create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex = 5,
                    LayoutOrder = elementCount,
                    Parent = SectionContent
                })
                
                local DropdownLabel = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = theme.TextDim,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = Dropdown
                })
                
                local DropdownButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = theme.SurfaceAlt,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 5,
                    Parent = Dropdown
                })
                AddCorner(DropdownButton, 4)
                AddStroke(DropdownButton, theme.BorderLight, 1)
                
                local SelectedLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -28, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = selected,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 5,
                    Parent = DropdownButton
                })
                
                local Arrow = Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -24, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = theme.TextDim,
                    TextSize = 8,
                    Font = Enum.Font.GothamBold,
                    ZIndex = 5,
                    Parent = DropdownButton
                })
                
                -- Options Container - 放在 ScreenGui 上而不是 Dropdown 内
                local OptionsContainer = Create("Frame", {
                    Name = name .. "_Options",
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 100,
                    Parent = ScreenGui
                })
                AddCorner(OptionsContainer, 4)
                AddStroke(OptionsContainer, theme.BorderLight, 1)
                
                local OptionsLayout = Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 0),
                    Parent = OptionsContainer
                })
                
                local OptionsPadding = Create("UIPadding", {
                    PaddingTop = UDim.new(0, 2),
                    PaddingBottom = UDim.new(0, 2),
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    Parent = OptionsContainer
                })
                
                local function createOptions()
                    for _, child in ipairs(OptionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for i, option in ipairs(options) do
                        local OptionBtn = Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 24),
                            BackgroundColor3 = theme.SurfaceAlt,
                            BackgroundTransparency = option == selected and 0 or 1,
                            BorderSizePixel = 0,
                            Text = option,
                            TextColor3 = option == selected and theme.Accent or theme.Text,
                            TextSize = 11,
                            Font = Enum.Font.Gotham,
                            AutoButtonColor = false,
                            LayoutOrder = i,
                            ZIndex = 101,
                            Parent = OptionsContainer
                        })
                        AddCorner(OptionBtn, 3)
                        
                        OptionBtn.MouseEnter:Connect(function()
                            if option ~= selected then
                                Tween(OptionBtn, {BackgroundTransparency = 0.5}, 0.1)
                            end
                        end)
                        
                        OptionBtn.MouseLeave:Connect(function()
                            if option ~= selected then
                                Tween(OptionBtn, {BackgroundTransparency = 1}, 0.1)
                            end
                        end)
                        
                        OptionBtn.MouseButton1Click:Connect(function()
                            selected = option
                            SelectedLabel.Text = selected
                            callback(selected)
                            
                            -- Update visual
                            for _, child in ipairs(OptionsContainer:GetChildren()) do
                                if child:IsA("TextButton") then
                                    local isSelected = child.Text == selected
                                    Tween(child, {
                                        BackgroundTransparency = isSelected and 0 or 1,
                                        TextColor3 = isSelected and theme.Accent or theme.Text
                                    }, 0.1)
                                end
                            end
                            
                            -- Close
                            isOpen = false
                            OptionsContainer.Visible = false
                            Tween(Arrow, {Rotation = 0}, 0.15)
                        end)
                    end
                end
                
                createOptions()
                
                local function updateOptionsPosition()
                    local btnPos = DropdownButton.AbsolutePosition
                    local btnSize = DropdownButton.AbsoluteSize
                    OptionsContainer.Position = UDim2.new(0, btnPos.X, 0, btnPos.Y + btnSize.Y + 2)
                    OptionsContainer.Size = UDim2.new(0, btnSize.X, 0, math.min(#options * 24 + 4, 150))
                end
                
                local function toggleDropdown()
                    isOpen = not isOpen
                    if isOpen then
                        updateOptionsPosition()
                        OptionsContainer.Visible = true
                    else
                        OptionsContainer.Visible = false
                    end
                    Tween(Arrow, {Rotation = isOpen and 180 or 0}, 0.15)
                end
                
                DropdownButton.MouseButton1Click:Connect(toggleDropdown)
                
                -- 点击其他地方关闭下拉
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if isOpen then
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
                                isOpen = false
                                OptionsContainer.Visible = false
                                Tween(Arrow, {Rotation = 0}, 0.15)
                            end
                        end
                    end
                end)
                
                local dropdownObj = {}
                function dropdownObj:Set(value)
                    if table.find(options, value) then
                        selected = value
                        SelectedLabel.Text = selected
                        callback(selected)
                        createOptions()
                    end
                end
                function dropdownObj:Get()
                    return selected
                end
                function dropdownObj:Refresh(newOptions)
                    options = newOptions
                    createOptions()
                end
                
                return dropdownObj
            end
            
            -- Multi Dropdown
            function sectionObj:CreateMultiDropdown(opts)
                opts = opts or {}
                local name = opts.Name or "MultiDropdown"
                local options = opts.Options or {}
                local default = opts.Default or {}
                local callback = opts.Callback or function() end
                local selected = {}
                for _, v in ipairs(default) do
                    selected[v] = true
                end
                local isOpen = false
                elementCount = elementCount + 1
                
                local function getSelectedText()
                    local count = 0
                    local items = {}
                    for item, _ in pairs(selected) do
                        count = count + 1
                        table.insert(items, item)
                    end
                    if count == 0 then
                        return "None"
                    elseif count <= 2 then
                        return table.concat(items, ", ")
                    else
                        return count .. " selected"
                    end
                end
                
                local function getSelectedArray()
                    local arr = {}
                    for item, _ in pairs(selected) do
                        table.insert(arr, item)
                    end
                    return arr
                end
                
                local MultiDropdown = Create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex = 5,
                    LayoutOrder = elementCount,
                    Parent = SectionContent
                })
                
                local MultiLabel = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = theme.TextDim,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = MultiDropdown
                })
                
                local MultiButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = theme.SurfaceAlt,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 5,
                    Parent = MultiDropdown
                })
                AddCorner(MultiButton, 4)
                AddStroke(MultiButton, theme.BorderLight, 1)
                
                local SelectedText = Create("TextLabel", {
                    Size = UDim2.new(1, -28, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = getSelectedText(),
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 5,
                    Parent = MultiButton
                })
                
                local MultiArrow = Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -24, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = theme.TextDim,
                    TextSize = 8,
                    Font = Enum.Font.GothamBold,
                    ZIndex = 5,
                    Parent = MultiButton
                })
                
                -- Options Container - 放在 ScreenGui 上
                local MultiOptions = Create("Frame", {
                    Name = name .. "_MultiOptions",
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 100,
                    Parent = ScreenGui
                })
                AddCorner(MultiOptions, 4)
                AddStroke(MultiOptions, theme.BorderLight, 1)
                
                local MultiLayout = Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 0),
                    Parent = MultiOptions
                })
                
                local MultiPadding = Create("UIPadding", {
                    PaddingTop = UDim.new(0, 2),
                    PaddingBottom = UDim.new(0, 2),
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    Parent = MultiOptions
                })
                
                local function createMultiOptions()
                    for _, child in ipairs(MultiOptions:GetChildren()) do
                        if child:IsA("Frame") then
                            child:Destroy()
                        end
                    end
                    
                    for i, option in ipairs(options) do
                        local OptionFrame = Create("Frame", {
                            Size = UDim2.new(1, 0, 0, 24),
                            BackgroundTransparency = 1,
                            LayoutOrder = i,
                            ZIndex = 101,
                            Parent = MultiOptions
                        })
                        
                        local Checkbox = Create("Frame", {
                            Size = UDim2.new(0, 14, 0, 14),
                            Position = UDim2.new(0, 4, 0.5, -7),
                            BackgroundColor3 = selected[option] and theme.Accent or theme.SurfaceAlt,
                            BorderSizePixel = 0,
                            ZIndex = 102,
                            Parent = OptionFrame
                        })
                        AddCorner(Checkbox, 3)
                        AddStroke(Checkbox, theme.BorderLight, 1)
                        
                        local Check = Create("TextLabel", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = "✓",
                            TextColor3 = theme.Background,
                            TextSize = 10,
                            Font = Enum.Font.GothamBold,
                            TextTransparency = selected[option] and 0 or 1,
                            ZIndex = 103,
                            Parent = Checkbox
                        })
                        
                        local OptionLabel = Create("TextLabel", {
                            Size = UDim2.new(1, -28, 1, 0),
                            Position = UDim2.new(0, 24, 0, 0),
                            BackgroundTransparency = 1,
                            Text = option,
                            TextColor3 = selected[option] and theme.Accent or theme.Text,
                            TextSize = 11,
                            Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 102,
                            Parent = OptionFrame
                        })
                        
                        local OptionBtn = Create("TextButton", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = "",
                            ZIndex = 104,
                            Parent = OptionFrame
                        })
                        
                        OptionBtn.MouseButton1Click:Connect(function()
                            selected[option] = not selected[option]
                            Tween(Checkbox, {BackgroundColor3 = selected[option] and theme.Accent or theme.SurfaceAlt}, 0.1)
                            Tween(Check, {TextTransparency = selected[option] and 0 or 1}, 0.1)
                            OptionLabel.TextColor3 = selected[option] and theme.Accent or theme.Text
                            SelectedText.Text = getSelectedText()
                            callback(getSelectedArray())
                        end)
                    end
                end
                
                createMultiOptions()
                
                local function updateMultiPosition()
                    local btnPos = MultiButton.AbsolutePosition
                    local btnSize = MultiButton.AbsoluteSize
                    MultiOptions.Position = UDim2.new(0, btnPos.X, 0, btnPos.Y + btnSize.Y + 2)
                    MultiOptions.Size = UDim2.new(0, btnSize.X, 0, math.min(#options * 24 + 4, 150))
                end
                
                local function toggleMulti()
                    isOpen = not isOpen
                    if isOpen then
                        updateMultiPosition()
                        MultiOptions.Visible = true
                    else
                        MultiOptions.Visible = false
                    end
                    Tween(MultiArrow, {Rotation = isOpen and 180 or 0}, 0.15)
                end
                
                MultiButton.MouseButton1Click:Connect(toggleMulti)
                
                -- 点击其他地方关闭
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if isOpen then
                            local mousePos = UserInputService:GetMouseLocation()
                            local optPos = MultiOptions.AbsolutePosition
                            local optSize = MultiOptions.AbsoluteSize
                            local btnPos = MultiButton.AbsolutePosition
                            local btnSize = MultiButton.AbsoluteSize
                            
                            local inOptions = mousePos.X >= optPos.X and mousePos.X <= optPos.X + optSize.X and
                                             mousePos.Y >= optPos.Y and mousePos.Y <= optPos.Y + optSize.Y
                            local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
                                            mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
                            
                            if not inOptions and not inButton then
                                isOpen = false
                                MultiOptions.Visible = false
                                Tween(MultiArrow, {Rotation = 0}, 0.15)
                            end
                        end
                    end
                end)
                
                local multiObj = {}
                function multiObj:Set(values)
                    selected = {}
                    for _, v in ipairs(values) do
                        selected[v] = true
                    end
                    SelectedText.Text = getSelectedText()
                    createMultiOptions()
                    callback(getSelectedArray())
                end
                function multiObj:Get()
                    return getSelectedArray()
                end
                
                return multiObj
            end
            
            -- Input
            function sectionObj:CreateInput(opts)
                opts = opts or {}
                local name = opts.Name or "Input"
                local placeholder = opts.Placeholder or "Enter text..."
                local default = opts.Default or ""
                local callback = opts.Callback or function() end
                elementCount = elementCount + 1
                
                local Input = Create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementCount,
                    Parent = SectionContent
                })
                
                local InputLabel = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = theme.TextDim,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Input
                })
                
                local InputBox = Create("TextBox", {
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = theme.SurfaceAlt,
                    BorderSizePixel = 0,
                    Text = default,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = theme.TextDark,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    ClearTextOnFocus = false,
                    Parent = Input
                })
                AddCorner(InputBox, 4)
                AddStroke(InputBox, theme.BorderLight, 1)
                
                local inputStroke = InputBox:FindFirstChildOfClass("UIStroke")
                
                InputBox.Focused:Connect(function()
                    Tween(inputStroke, {Color = theme.Accent}, 0.15)
                end)
                
                InputBox.FocusLost:Connect(function(enter)
                    Tween(inputStroke, {Color = theme.BorderLight}, 0.15)
                    if enter then
                        callback(InputBox.Text)
                    end
                end)
                
                local inputObj = {}
                function inputObj:Set(value)
                    InputBox.Text = value
                end
                function inputObj:Get()
                    return InputBox.Text
                end
                
                return inputObj
            end
            
            -- Keybind
            function sectionObj:CreateKeybind(opts)
                opts = opts or {}
                local name = opts.Name or "Keybind"
                local default = opts.Default or Enum.KeyCode.Unknown
                local callback = opts.Callback or function() end
                local key = default
                local listening = false
                elementCount = elementCount + 1
                
                local Keybind = Create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementCount,
                    Parent = SectionContent
                })
                
                local KeybindLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -70, 1, 0),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = theme.TextDim,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Keybind
                })
                
                local KeybindButton = Create("TextButton", {
                    Size = UDim2.new(0, 60, 0, 22),
                    Position = UDim2.new(1, -64, 0.5, -11),
                    BackgroundColor3 = theme.SurfaceAlt,
                    BorderSizePixel = 0,
                    Text = key.Name ~= "Unknown" and "[" .. key.Name .. "]" or "[None]",
                    TextColor3 = theme.Text,
                    TextSize = 10,
                    Font = Enum.Font.GothamMedium,
                    AutoButtonColor = false,
                    Parent = Keybind
                })
                AddCorner(KeybindButton, 4)
                AddStroke(KeybindButton, theme.BorderLight, 1)
                
                KeybindButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeybindButton.Text = "[...]"
                    Tween(KeybindButton, {BackgroundColor3 = theme.Accent}, 0.1)
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            key = input.KeyCode
                            KeybindButton.Text = "[" .. key.Name .. "]"
                            listening = false
                            Tween(KeybindButton, {BackgroundColor3 = theme.SurfaceAlt}, 0.1)
                        end
                    else
                        if input.KeyCode == key then
                            callback(key)
                        end
                    end
                end)
                
                local keybindObj = {}
                function keybindObj:Set(newKey)
                    key = newKey
                    KeybindButton.Text = "[" .. key.Name .. "]"
                end
                function keybindObj:Get()
                    return key
                end
                
                return keybindObj
            end
            
            -- ColorPicker (Full HSV + Alpha)
            function sectionObj:CreateColorPicker(opts)
                opts = opts or {}
                local name = opts.Name or "Color"
                local default = opts.Default or Color3.fromRGB(130, 100, 255)
                local defaultAlpha = opts.Alpha or 1
                local callback = opts.Callback or function() end
                
                local h, s, v = default:ToHSV()
                local alpha = defaultAlpha
                local isOpen = false
                elementCount = elementCount + 1
                
                local ColorPicker = Create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex = 5,
                    LayoutOrder = elementCount,
                    Parent = SectionContent
                })
                
                local ColorLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -50, 1, 0),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = theme.TextDim,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = ColorPicker
                })
                
                local ColorPreview = Create("TextButton", {
                    Size = UDim2.new(0, 40, 0, 18),
                    Position = UDim2.new(1, -44, 0.5, -9),
                    BackgroundColor3 = default,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 5,
                    Parent = ColorPicker
                })
                AddCorner(ColorPreview, 4)
                AddStroke(ColorPreview, theme.BorderLight, 1)
                
                -- Picker Panel - 放在 ScreenGui 上
                local PickerPanel = Create("Frame", {
                    Name = name .. "_Picker",
                    Size = UDim2.new(0, 200, 0, 200),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = theme.Surface,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 100,
                    Parent = ScreenGui
                })
                AddCorner(PickerPanel, 6)
                AddStroke(PickerPanel, theme.BorderLight, 1)
                
                -- SV Picker (Saturation-Value)
                local SVPicker = Create("Frame", {
                    Size = UDim2.new(1, -16, 0, 120),
                    Position = UDim2.new(0, 8, 0, 8),
                    BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 21,
                    Parent = PickerPanel
                })
                AddCorner(SVPicker, 4)
                
                local SatGradient = Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }),
                    Parent = SVPicker
                })
                
                local ValOverlay = Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    ZIndex = 22,
                    Parent = SVPicker
                })
                AddCorner(ValOverlay, 4)
                
                local ValGradient = Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }),
                    Rotation = 90,
                    Parent = ValOverlay
                })
                
                local SVCursor = Create("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(s, -6, 1 - v, -6),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 24,
                    Parent = SVPicker
                })
                
                local SVCursorInner = Create("Frame", {
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(0.5, -5, 0.5, -5),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 25,
                    Parent = SVCursor
                })
                AddCorner(SVCursorInner, 5)
                AddStroke(SVCursorInner, Color3.new(0, 0, 0), 2)
                
                -- Hue Slider
                local HueSlider = Create("Frame", {
                    Size = UDim2.new(1, -16, 0, 14),
                    Position = UDim2.new(0, 8, 0, 134),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 21,
                    Parent = PickerPanel
                })
                AddCorner(HueSlider, 4)
                
                local HueGradient = Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
                    }),
                    Parent = HueSlider
                })
                
                local HueCursor = Create("Frame", {
                    Size = UDim2.new(0, 4, 1, 4),
                    Position = UDim2.new(h, -2, 0, -2),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 22,
                    Parent = HueSlider
                })
                AddCorner(HueCursor, 2)
                AddStroke(HueCursor, Color3.new(0, 0, 0), 1)
                
                -- Alpha Slider
                local AlphaSlider = Create("Frame", {
                    Size = UDim2.new(1, -16, 0, 14),
                    Position = UDim2.new(0, 8, 0, 154),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 21,
                    Parent = PickerPanel
                })
                AddCorner(AlphaSlider, 4)
                
                local AlphaGradient = Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(h, s, v))
                    }),
                    Parent = AlphaSlider
                })
                
                local AlphaCursor = Create("Frame", {
                    Size = UDim2.new(0, 4, 1, 4),
                    Position = UDim2.new(alpha, -2, 0, -2),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 22,
                    Parent = AlphaSlider
                })
                AddCorner(AlphaCursor, 2)
                AddStroke(AlphaCursor, Color3.new(0, 0, 0), 1)
                
                -- Hex Display
                local HexDisplay = Create("TextLabel", {
                    Size = UDim2.new(1, -16, 0, 20),
                    Position = UDim2.new(0, 8, 0, 174),
                    BackgroundTransparency = 1,
                    Text = "#" .. default:ToHex():upper(),
                    TextColor3 = theme.TextDim,
                    TextSize = 10,
                    Font = Enum.Font.GothamMedium,
                    ZIndex = 21,
                    Parent = PickerPanel
                })
                
                local function updateColor()
                    local color = Color3.fromHSV(h, s, v)
                    ColorPreview.BackgroundColor3 = color
                    SVPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    AlphaGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, color)
                    })
                    HexDisplay.Text = "#" .. color:ToHex():upper() .. " | " .. math.floor(alpha * 100) .. "%"
                    callback(color, alpha)
                end
                
                -- SV Picker Interaction
                local svDragging = false
                
                SVPicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = true
                    end
                end)
                
                ValOverlay.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = true
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pos = SVPicker.AbsolutePosition
                        local size = SVPicker.AbsoluteSize
                        s = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                        v = math.clamp(1 - (input.Position.Y - pos.Y) / size.Y, 0, 1)
                        SVCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                        updateColor()
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
                        h = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                        HueCursor.Position = UDim2.new(h, -2, 0, -2)
                        updateColor()
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
                        alpha = math.clamp((input.Position.X - AlphaSlider.AbsolutePosition.X) / AlphaSlider.AbsoluteSize.X, 0, 1)
                        AlphaCursor.Position = UDim2.new(alpha, -2, 0, -2)
                        updateColor()
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = false
                        hueDragging = false
                        alphaDragging = false
                    end
                end)
                
                -- Toggle Picker
                local function updatePickerPosition()
                    local previewPos = ColorPreview.AbsolutePosition
                    local previewSize = ColorPreview.AbsoluteSize
                    -- 尝试在右侧显示，如果空间不够则在左侧
                    local screenWidth = ScreenGui.AbsoluteSize.X
                    local pickerX = previewPos.X + previewSize.X + 5
                    if pickerX + 200 > screenWidth then
                        pickerX = previewPos.X - 205
                    end
                    PickerPanel.Position = UDim2.new(0, pickerX, 0, previewPos.Y)
                end
                
                ColorPreview.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        updatePickerPosition()
                        PickerPanel.Visible = true
                    else
                        PickerPanel.Visible = false
                    end
                end)
                
                -- 点击其他地方关闭
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if isOpen and not svDragging and not hueDragging and not alphaDragging then
                            task.defer(function()
                                local mousePos = UserInputService:GetMouseLocation()
                                local panelPos = PickerPanel.AbsolutePosition
                                local panelSize = PickerPanel.AbsoluteSize
                                local previewPos = ColorPreview.AbsolutePosition
                                local previewSize = ColorPreview.AbsoluteSize
                                
                                local inPanel = mousePos.X >= panelPos.X and mousePos.X <= panelPos.X + panelSize.X and
                                               mousePos.Y >= panelPos.Y and mousePos.Y <= panelPos.Y + panelSize.Y
                                local inPreview = mousePos.X >= previewPos.X and mousePos.X <= previewPos.X + previewSize.X and
                                                 mousePos.Y >= previewPos.Y and mousePos.Y <= previewPos.Y + previewSize.Y
                                
                                if not inPanel and not inPreview then
                                    isOpen = false
                                    PickerPanel.Visible = false
                                end
                            end)
                        end
                    end
                end)
                
                local colorObj = {}
                function colorObj:Set(color, newAlpha)
                    h, s, v = color:ToHSV()
                    alpha = newAlpha or 1
                    SVCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                    HueCursor.Position = UDim2.new(h, -2, 0, -2)
                    AlphaCursor.Position = UDim2.new(alpha, -2, 0, -2)
                    updateColor()
                end
                function colorObj:Get()
                    return Color3.fromHSV(h, s, v), alpha
                end
                
                return colorObj
            end
            
            -- Label
            function sectionObj:CreateLabel(text)
                elementCount = elementCount + 1
                
                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = theme.TextDim,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = elementCount,
                    Parent = SectionContent
                })
                
                local labelObj = {}
                function labelObj:Set(newText)
                    Label.Text = newText
                end
                
                return labelObj
            end
            
            -- Separator
            function sectionObj:CreateSeparator()
                elementCount = elementCount + 1
                
                Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = theme.Border,
                    BorderSizePixel = 0,
                    LayoutOrder = elementCount,
                    Parent = SectionContent
                })
            end
            
            return sectionObj
        end
        
        table.insert(tabs, tabObj)
        return tabObj
    end
    
    -- Notification System
    function windowObj:Notify(opts)
        opts = opts or {}
        local title = opts.Title or "Notification"
        local message = opts.Message or ""
        local notifType = opts.Type or "Info"
        local duration = opts.Duration or 4
        
        local typeColors = {
            Success = theme.Success,
            Warning = theme.Warning,
            Error = theme.Error,
            Info = theme.Accent
        }
        
        local Notification = Create("Frame", {
            Size = UDim2.new(0, 280, 0, 0),
            Position = UDim2.new(1, -290, 1, -10),
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = ScreenGui
        })
        AddCorner(Notification, 6)
        AddStroke(Notification, theme.Border, 1)
        
        -- Accent Line
        local NotifAccent = Create("Frame", {
            Size = UDim2.new(0, 3, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundColor3 = typeColors[notifType] or theme.Accent,
            BorderSizePixel = 0,
            Parent = Notification
        })
        AddCorner(NotifAccent, 1)
        
        local NotifTitle = Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 14, 0, 8),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = theme.Text,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notification
        })
        
        local NotifMessage = Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 14, 0, 28),
            BackgroundTransparency = 1,
            Text = message,
            TextColor3 = theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = Notification
        })
        
        -- Animate in
        Tween(Notification, {Size = UDim2.new(0, 280, 0, 65)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        -- Auto dismiss
        task.delay(duration, function()
            Tween(Notification, {Size = UDim2.new(0, 280, 0, 0)}, 0.2)
            task.delay(0.25, function()
                Notification:Destroy()
            end)
        end)
    end
    
    -- Set Status Bar
    function windowObj:SetStatusBar(opts)
        opts = opts or {}
        if opts.Text then StatusLabel.Text = opts.Text end
        if opts.Build then BuildLabel.Text = opts.Build end
        if opts.Version then VersionLabel.Text = opts.Version end
        if opts.Status then
            local colors = {
                ready = theme.Success,
                loading = theme.Warning,
                error = theme.Error,
                offline = theme.TextDark
            }
            Tween(StatusDot, {BackgroundColor3 = colors[opts.Status] or theme.Success}, 0.15)
        end
        if opts.Visible ~= nil then
            StatusBar.Visible = opts.Visible
        end
    end
    
    -- Destroy
    function windowObj:Destroy()
        ScreenGui:Destroy()
    end
    
    return windowObj
end

-- Watermark
function PhantomUI:CreateWatermark(options)
    options = options or {}
    local title = options.Title or "phantom"
    local themeName = options.Theme or "Phantom"
    local position = options.Position or UDim2.new(0, 12, 0, 12)
    local showFPS = options.ShowFPS ~= false
    local showPing = options.ShowPing ~= false
    local showTime = options.ShowTime ~= false
    local showUser = options.ShowUser ~= false
    
    local theme = Themes[themeName] or Themes.Phantom
    local watermarkObj = {}
    
    local WatermarkGui = CoreGui:FindFirstChild("PhantomWatermark")
    if WatermarkGui then WatermarkGui:Destroy() end
    
    WatermarkGui = Create("ScreenGui", {
        Name = "PhantomWatermark",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    -- 计算需要显示的内容来确定宽度
    local contentParts = {title}
    if showUser then table.insert(contentParts, Player.Name) end
    if showFPS then table.insert(contentParts, "000 fps") end
    if showPing then table.insert(contentParts, "000 ms") end
    if showTime then table.insert(contentParts, "00:00:00") end
    
    -- 估算宽度: 每个字符约7px + 分隔符16px
    local estimatedWidth = 16 -- padding
    for i, part in ipairs(contentParts) do
        estimatedWidth = estimatedWidth + #part * 7
        if i < #contentParts then
            estimatedWidth = estimatedWidth + 16 -- separator
        end
    end
    estimatedWidth = math.max(estimatedWidth, 100)
    
    local Watermark = Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, estimatedWidth, 0, 26),
        Position = position,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = WatermarkGui
    })
    AddCorner(Watermark, 4)
    AddStroke(Watermark, theme.Border, 1)
    
    -- Accent Line (inside, at top)
    local AccentLine = Create("Frame", {
        Size = UDim2.new(1, -8, 0, 2),
        Position = UDim2.new(0, 4, 0, 3),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Parent = Watermark
    })
    AddCorner(AccentLine, 1)
    
    -- Content container
    local ContentContainer = Create("Frame", {
        Size = UDim2.new(1, -16, 1, -8),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundTransparency = 1,
        Parent = Watermark
    })
    
    local ContentLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 0),
        Parent = ContentContainer
    })
    
    local function createText(text, order, isAccent)
        local textWidth = #text * 7
        return Create("TextLabel", {
            Size = UDim2.new(0, textWidth, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = isAccent and theme.Accent or theme.Text,
            TextSize = 11,
            Font = isAccent and Enum.Font.GothamBold or Enum.Font.GothamMedium,
            LayoutOrder = order,
            Parent = ContentContainer
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
            Parent = ContentContainer
        })
    end
    
    local order = 0
    local TitleLabel = createText(title, order, true)
    
    local labels = {}
    
    if showUser then
        order = order + 1
        createSeparator(order)
        order = order + 1
        labels.user = createText(Player.Name, order)
    end
    
    if showFPS then
        order = order + 1
        createSeparator(order)
        order = order + 1
        labels.fps = createText("0 fps", order)
        labels.fps.Size = UDim2.new(0, 50, 1, 0)
    end
    
    if showPing then
        order = order + 1
        createSeparator(order)
        order = order + 1
        labels.ping = createText("0 ms", order)
        labels.ping.Size = UDim2.new(0, 45, 1, 0)
    end
    
    if showTime then
        order = order + 1
        createSeparator(order)
        order = order + 1
        labels.time = createText("00:00:00", order)
        labels.time.Size = UDim2.new(0, 60, 1, 0)
    end
    
    -- 根据实际内容调整宽度
    task.defer(function()
        local totalWidth = 16 -- padding
        for _, child in ipairs(ContentContainer:GetChildren()) do
            if child:IsA("TextLabel") then
                totalWidth = totalWidth + child.Size.X.Offset
            end
        end
        Watermark.Size = UDim2.new(0, totalWidth, 0, 26)
    end)
    
    -- Update loop
    local lastUpdate = 0
    local frameCount = 0
    
    RunService.RenderStepped:Connect(function(dt)
        frameCount = frameCount + 1
        lastUpdate = lastUpdate + dt
        
        if lastUpdate >= 0.5 then
            if labels.fps then
                labels.fps.Text = math.floor(frameCount / lastUpdate) .. " fps"
            end
            if labels.ping then
                local ping = Player:GetNetworkPing() * 1000
                labels.ping.Text = math.floor(ping) .. " ms"
            end
            if labels.time then
                labels.time.Text = os.date("%H:%M:%S")
            end
            frameCount = 0
            lastUpdate = 0
        end
    end)
    
    function watermarkObj:SetTitle(newTitle)
        TitleLabel.Text = newTitle
        TitleLabel.Size = UDim2.new(0, #newTitle * 7, 1, 0)
        -- 重新计算宽度
        task.defer(function()
            local totalWidth = 16
            for _, child in ipairs(ContentContainer:GetChildren()) do
                if child:IsA("TextLabel") then
                    totalWidth = totalWidth + child.Size.X.Offset
                end
            end
            Watermark.Size = UDim2.new(0, totalWidth, 0, 26)
        end)
    end
    
    function watermarkObj:Hide()
        Watermark.Visible = false
    end
    
    function watermarkObj:Show()
        Watermark.Visible = true
    end
    
    function watermarkObj:Destroy()
        WatermarkGui:Destroy()
    end
    
    return watermarkObj
end

return PhantomUI
