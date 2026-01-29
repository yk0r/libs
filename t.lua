--[[
    ███████╗███████╗██╗     ██╗██████╗ 
    ██╔════╝██╔════╝██║     ██║██╔══██╗
    █████╗  ███████╗██║     ██║██████╔╝
    ██╔══╝  ╚════██║██║     ██║██╔══██╗
    ██║     ███████║███████╗██║██████╔╝
    ╚═╝     ╚══════╝╚══════╝╚═╝╚═════╝ 
    
    FriendShip.Lua (FSlib) v1.0.7
    A professional Roblox GUI Library
    
    GitHub: https://github.com/FSlib
    Discord: discord.gg/FSlib
]]

local FSlib = {
    _VERSION = "1.0.7",
    _NAME = "FriendShip.Lua",
    Flags = {},
    Windows = {},
    Theme = {
        Primary = Color3.fromRGB(139, 0, 0),
        PrimaryDark = Color3.fromRGB(100, 0, 0),
        PrimaryLight = Color3.fromRGB(180, 30, 30),
        Background = Color3.fromRGB(12, 12, 12),
        BackgroundSecondary = Color3.fromRGB(18, 18, 18),
        BackgroundTertiary = Color3.fromRGB(25, 25, 25),
        Border = Color3.fromRGB(40, 40, 40),
        BorderLight = Color3.fromRGB(60, 60, 60),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 150, 150),
        TextDisabled = Color3.fromRGB(80, 80, 80),
        Success = Color3.fromRGB(0, 180, 100),
        Warning = Color3.fromRGB(255, 180, 0),
        Error = Color3.fromRGB(255, 60, 60),
        Info = Color3.fromRGB(60, 150, 255),
    },
    _ThemeBindings = {},
}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Utility Functions
local function Create(className, properties, children)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = instance
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
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ripple })
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Tween(ripple, { Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1 }, 0.5)
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

-- 注册主题绑定
local function BindToTheme(element, property, themeKey)
    table.insert(FSlib._ThemeBindings, {
        Element = element,
        Property = property,
        ThemeKey = themeKey
    })
end

-- 实时更新主题
function FSlib:SetTheme(options)
    for key, value in pairs(options) do
        if self.Theme[key] then
            self.Theme[key] = value
        end
    end
    
    -- 更新所有绑定的元素
    for _, binding in ipairs(self._ThemeBindings) do
        if binding.Element and binding.Element.Parent then
            local themeValue = self.Theme[binding.ThemeKey]
            if themeValue then
                pcall(function()
                    binding.Element[binding.Property] = themeValue
                end)
            end
        end
    end
end

-- 获取主题颜色
function FSlib:GetThemeColor(key)
    return self.Theme[key]
end

-- Create ScreenGui
function FSlib:CreateWindow(options)
    options = options or {}
    local title = options.Title or "FSlib"
    local subtitle = options.Subtitle or "v1.0.0"
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    
    -- Main ScreenGui
    local screenGui = Create("ScreenGui", {
        Name = "FSlib_" .. title,
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    })
    
    -- Main Window Frame
    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = screenGui,
        BackgroundColor3 = FSlib.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        ClipsDescendants = true,
        ZIndex = 1,
    })
    BindToTheme(mainFrame, "BackgroundColor3", "Background")
    
    -- Main Border
    local mainBorder = Create("UIStroke", {
        Parent = mainFrame,
        Color = FSlib.Theme.Border,
        Thickness = 1,
    })
    BindToTheme(mainBorder, "Color", "Border")
    
    -- Title Bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = mainFrame,
        BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 28),
        ZIndex = 2,
    })
    BindToTheme(titleBar, "BackgroundColor3", "BackgroundSecondary")
    
    local titleBorder = Create("Frame", {
        Name = "TitleBorder",
        Parent = titleBar,
        BackgroundColor3 = FSlib.Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 2,
    })
    BindToTheme(titleBorder, "BackgroundColor3", "Border")
    
    -- Title Label
    local titleLabel = Create("TextLabel", {
        Name = "TitleLabel",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = FSlib.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })
    BindToTheme(titleLabel, "TextColor3", "Text")
    
    local subtitleLabel = Create("TextLabel", {
        Name = "SubtitleLabel",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamMedium,
        Text = " | " .. subtitle,
        TextColor3 = FSlib.Theme.TextDark,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })
    BindToTheme(subtitleLabel, "TextColor3", "TextDark")
    
    -- 更新 subtitle 位置
    task.defer(function()
        subtitleLabel.Position = UDim2.new(0, 10 + titleLabel.TextBounds.X, 0, 0)
    end)
    
    titleLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        subtitleLabel.Position = UDim2.new(0, 10 + titleLabel.TextBounds.X, 0, 0)
    end)
    
    -- Tab Container
    local tabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = mainFrame,
        BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 28),
        Size = UDim2.new(1, 0, 0, 28),
        ZIndex = 2,
    })
    BindToTheme(tabContainer, "BackgroundColor3", "BackgroundSecondary")
    
    local tabBorder = Create("Frame", {
        Name = "TabBorder",
        Parent = tabContainer,
        BackgroundColor3 = FSlib.Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 2,
    })
    BindToTheme(tabBorder, "BackgroundColor3", "Border")
    
    local tabList = Create("Frame", {
        Name = "TabList",
        Parent = tabContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -16, 1, 0),
        ZIndex = 3,
    })
    
    Create("UIListLayout", {
        Parent = tabList,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    })
    
    -- Content Container
    local contentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 56),
        Size = UDim2.new(1, 0, 1, -56),
        ClipsDescendants = true,
        ZIndex = 2,
    })
    
    -- Dragging
    local dragging = false
    local dragStart, startPos
    
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
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Toggle Key
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
    
    -- Window Object
    local Window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        Tabs = {},
        ActiveTab = nil,
    }
    
    -- Create Tab
    function Window:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon or ""
        
        local tabIndex = #self.Tabs + 1
        
        -- Tab Button
        local tabButton = Create("TextButton", {
            Name = "Tab_" .. tabName,
            Parent = tabList,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 80, 1, -4),
            Font = Enum.Font.GothamMedium,
            Text = tabIcon ~= "" and (tabIcon .. " " .. tabName) or tabName,
            TextColor3 = FSlib.Theme.TextDark,
            TextSize = 12,
            LayoutOrder = tabIndex,
            ZIndex = 4,
        })
        BindToTheme(tabButton, "TextColor3", "TextDark")
        
        local tabIndicator = Create("Frame", {
            Name = "Indicator",
            Parent = tabButton,
            BackgroundColor3 = FSlib.Theme.Primary,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(1, 0, 0, 2),
            Visible = false,
            ZIndex = 5,
        })
        BindToTheme(tabIndicator, "BackgroundColor3", "Primary")
        
        -- Tab Content
        local tabContent = Create("ScrollingFrame", {
            Name = "TabContent_" .. tabName,
            Parent = contentContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(1, -16, 1, -16),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = FSlib.Theme.Primary,
            Visible = false,
            ZIndex = 3,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        })
        BindToTheme(tabContent, "ScrollBarImageColor3", "Primary")
        
        -- 左右两列容器
        local leftColumn = Create("Frame", {
            Name = "LeftColumn",
            Parent = tabContent,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.5, -4, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 3,
        })
        
        Create("UIListLayout", {
            Parent = leftColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        })
        
        local rightColumn = Create("Frame", {
            Name = "RightColumn",
            Parent = tabContent,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 4, 0, 0),
            Size = UDim2.new(0.5, -4, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 3,
        })
        
        Create("UIListLayout", {
            Parent = rightColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        })
        
        -- Tab Object
        local Tab = {
            Name = tabName,
            Button = tabButton,
            Content = tabContent,
            LeftColumn = leftColumn,
            RightColumn = rightColumn,
            Sections = {},
            SectionCount = 0,
        }
        
        -- Create Section
        function Tab:CreateSection(sectionOptions)
            sectionOptions = sectionOptions or {}
            local sectionName = sectionOptions.Name or "Section"
            local side = sectionOptions.Side or "Left"
            
            self.SectionCount = self.SectionCount + 1
            local parentColumn = side == "Left" and self.LeftColumn or self.RightColumn
            
            -- Section Frame (容器)
            local sectionFrame = Create("Frame", {
                Name = "Section_" .. sectionName,
                Parent = parentColumn,
                BackgroundColor3 = FSlib.Theme.BackgroundTertiary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = self.SectionCount,
                ZIndex = 4,
            })
            BindToTheme(sectionFrame, "BackgroundColor3", "BackgroundTertiary")
            
            -- Section 完整边框
            local sectionStroke = Create("UIStroke", {
                Parent = sectionFrame,
                Color = FSlib.Theme.Border,
                Thickness = 1,
            })
            BindToTheme(sectionStroke, "Color", "Border")
            
            -- Section Header
            local sectionHeader = Create("Frame", {
                Name = "Header",
                Parent = sectionFrame,
                BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 24),
                ZIndex = 5,
            })
            BindToTheme(sectionHeader, "BackgroundColor3", "BackgroundSecondary")
            
            -- Header 底部边框线
            local headerBorder = Create("Frame", {
                Name = "Border",
                Parent = sectionHeader,
                BackgroundColor3 = FSlib.Theme.Border,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -1),
                Size = UDim2.new(1, 0, 0, 1),
                ZIndex = 6,
            })
            BindToTheme(headerBorder, "BackgroundColor3", "Border")
            
            local sectionTitle = Create("TextLabel", {
                Name = "Title",
                Parent = sectionHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionName:upper(),
                TextColor3 = FSlib.Theme.Primary,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 6,
            })
            BindToTheme(sectionTitle, "TextColor3", "Primary")
            
            -- Elements Holder (元素容器)
            local elementsHolder = Create("Frame", {
                Name = "Elements",
                Parent = sectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 32),
                Size = UDim2.new(1, -16, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 5,
            })
            
            Create("UIListLayout", {
                Parent = elementsHolder,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
            })
            
            -- 底部 Padding
            local bottomPadding = Create("Frame", {
                Name = "BottomPadding",
                Parent = sectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 12),
                LayoutOrder = 999999,
                ZIndex = 5,
            })
            
            -- 监听 elementsHolder 大小变化，更新 bottomPadding 位置
            elementsHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                bottomPadding.Position = UDim2.new(0, 0, 0, 32 + elementsHolder.AbsoluteSize.Y)
            end)
            
            local Section = {
                Frame = sectionFrame,
                Content = elementsHolder,
                ElementCount = 0,
            }
            
            -- ============== UI ELEMENTS ==============
            
            -- Toggle (无对勾，颜色跟随主题)
            function Section:CreateToggle(toggleOptions)
                toggleOptions = toggleOptions or {}
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
                    Name = "Toggle_" .. name,
                    Parent = self.Content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    LayoutOrder = self.ElementCount,
                    ZIndex = 10,
                })
                
                local toggleBox = Create("Frame", {
                    Name = "Box",
                    Parent = toggleFrame,
                    BackgroundColor3 = value and FSlib.Theme.Primary or FSlib.Theme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    ZIndex = 11,
                })
                
                local toggleStroke = Create("UIStroke", {
                    Parent = toggleBox,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                BindToTheme(toggleStroke, "Color", "Border")
                
                local toggleLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = toggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 20, 0, 0),
                    Size = UDim2.new(1, -20, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                })
                BindToTheme(toggleLabel, "TextColor3", "Text")
                
                local toggleButton = Create("TextButton", {
                    Name = "Button",
                    Parent = toggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 13,
                })
                
                local function updateToggle()
                    if value then
                        Tween(toggleBox, { BackgroundColor3 = FSlib.Theme.Primary }, 0.15)
                    else
                        Tween(toggleBox, { BackgroundColor3 = FSlib.Theme.BackgroundSecondary }, 0.15)
                    end
                    
                    if flag then
                        FSlib.Flags[flag] = value
                    end
                    callback(value)
                end
                
                toggleButton.MouseButton1Click:Connect(function()
                    value = not value
                    updateToggle()
                end)
                
                return {
                    Set = function(_, newValue)
                        value = newValue
                        updateToggle()
                    end,
                    Get = function()
                        return value
                    end,
                }
            end
            
            -- Slider
            function Section:CreateSlider(sliderOptions)
                sliderOptions = sliderOptions or {}
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
                    Name = "Slider_" .. name,
                    Parent = self.Content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    LayoutOrder = self.ElementCount,
                    ZIndex = 10,
                })
                
                local sliderLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = sliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0.6, 0, 0, 14),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                })
                BindToTheme(sliderLabel, "TextColor3", "Text")
                
                local sliderValueBox = Create("TextBox", {
                    Name = "ValueBox",
                    Parent = sliderFrame,
                    BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -50, 0, 0),
                    Size = UDim2.new(0, 50, 0, 14),
                    Font = Enum.Font.GothamMedium,
                    Text = tostring(value) .. suffix,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ClearTextOnFocus = true,
                    ZIndex = 11,
                })
                BindToTheme(sliderValueBox, "BackgroundColor3", "BackgroundSecondary")
                
                Create("UIStroke", {
                    Parent = sliderValueBox,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                local sliderBg = Create("Frame", {
                    Name = "Background",
                    Parent = sliderFrame,
                    BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 8),
                    ZIndex = 11,
                })
                BindToTheme(sliderBg, "BackgroundColor3", "BackgroundSecondary")
                
                Create("UIStroke", {
                    Parent = sliderBg,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                local sliderFill = Create("Frame", {
                    Name = "Fill",
                    Parent = sliderBg,
                    BackgroundColor3 = FSlib.Theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    ZIndex = 12,
                })
                BindToTheme(sliderFill, "BackgroundColor3", "Primary")
                
                local sliderButton = Create("TextButton", {
                    Name = "Button",
                    Parent = sliderBg,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 13,
                })
                
                local dragging = false
                
                local function updateSliderVisual()
                    sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    sliderValueBox.Text = tostring(value) .. suffix
                    
                    if flag then
                        FSlib.Flags[flag] = value
                    end
                    callback(value)
                end
                
                local function updateSliderFromInput(input)
                    local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    local rawValue = min + (max - min) * relativeX
                    value = math.floor(rawValue / increment + 0.5) * increment
                    value = math.clamp(value, min, max)
                    updateSliderVisual()
                end
                
                sliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSliderFromInput(input)
                    end
                end)
                
                sliderButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSliderFromInput(input)
                    end
                end)
                
                sliderValueBox.FocusLost:Connect(function(enterPressed)
                    local inputText = sliderValueBox.Text:gsub(suffix, ""):gsub("%s+", "")
                    local inputNum = tonumber(inputText)
                    
                    if inputNum then
                        inputNum = math.floor(inputNum / increment + 0.5) * increment
                        value = math.clamp(inputNum, min, max)
                    end
                    
                    updateSliderVisual()
                end)
                
                return {
                    Set = function(_, newValue)
                        value = math.clamp(newValue, min, max)
                        updateSliderVisual()
                    end,
                    Get = function()
                        return value
                    end,
                }
            end
            
            -- Dropdown
            function Section:CreateDropdown(dropdownOptions)
                dropdownOptions = dropdownOptions or {}
                local name = dropdownOptions.Name or "Dropdown"
                local items = dropdownOptions.Items or {}
                local default = dropdownOptions.Default
                local flag = dropdownOptions.Flag
                local callback = dropdownOptions.Callback or function() end
                
                self.ElementCount = self.ElementCount + 1
                local value = default or (items[1] or "")
                local isOpen = false
                
                if flag then
                    FSlib.Flags[flag] = value
                end
                
                local dropdownFrame = Create("Frame", {
                    Name = "Dropdown_" .. name,
                    Parent = self.Content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 42),
                    LayoutOrder = self.ElementCount,
                    ClipsDescendants = false,
                    ZIndex = 10,
                })
                
                local dropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = dropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                })
                BindToTheme(dropdownLabel, "TextColor3", "Text")
                
                local dropdownButton = Create("TextButton", {
                    Name = "Button",
                    Parent = dropdownFrame,
                    BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 16),
                    Size = UDim2.new(1, 0, 0, 24),
                    Font = Enum.Font.GothamMedium,
                    Text = "  " .. tostring(value),
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                })
                BindToTheme(dropdownButton, "BackgroundColor3", "BackgroundSecondary")
                BindToTheme(dropdownButton, "TextColor3", "Text")
                
                Create("UIStroke", {
                    Parent = dropdownButton,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                local dropdownArrow = Create("TextLabel", {
                    Name = "Arrow",
                    Parent = dropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = "▼",
                    TextColor3 = FSlib.Theme.TextDark,
                    TextSize = 10,
                    ZIndex = 12,
                })
                BindToTheme(dropdownArrow, "TextColor3", "TextDark")
                
                -- Overlay (点击外部关闭)
                local dropdownOverlay = Create("TextButton", {
                    Name = "Overlay_" .. name,
                    Parent = screenGui,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Visible = false,
                    ZIndex = 998,
                })
                
                -- Dropdown List
                local dropdownList = Create("Frame", {
                    Name = "List_" .. name,
                    Parent = screenGui,
                    BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 999,
                    Active = true,
                })
                BindToTheme(dropdownList, "BackgroundColor3", "BackgroundSecondary")
                
                Create("UIStroke", {
                    Parent = dropdownList,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                local listScroll = Create("ScrollingFrame", {
                    Name = "Scroll",
                    Parent = dropdownList,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = FSlib.Theme.Primary,
                    ZIndex = 1000,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                })
                
                Create("UIListLayout", {
                    Parent = listScroll,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
                
                local function updateDropdownPosition()
                    local absPos = dropdownButton.AbsolutePosition
                    local absSize = dropdownButton.AbsoluteSize
                    dropdownList.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
                    dropdownList.Size = UDim2.new(0, absSize.X, 0, math.min(#items * 24, 150))
                end
                
                local function closeDropdown()
                    isOpen = false
                    dropdownList.Visible = false
                    dropdownOverlay.Visible = false
                    dropdownArrow.Text = "▼"
                end
                
                local function createItems()
                    for _, child in ipairs(listScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for i, item in ipairs(items) do
                        local itemButton = Create("TextButton", {
                            Name = "Item_" .. tostring(item),
                            Parent = listScroll,
                            BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                            BackgroundTransparency = 0,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 24),
                            Font = Enum.Font.GothamMedium,
                            Text = "  " .. tostring(item),
                            TextColor3 = FSlib.Theme.Text,
                            TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            LayoutOrder = i,
                            ZIndex = 1001,
                        })
                        
                        itemButton.MouseEnter:Connect(function()
                            Tween(itemButton, { BackgroundColor3 = FSlib.Theme.Primary }, 0.1)
                        end)
                        itemButton.MouseLeave:Connect(function()
                            Tween(itemButton, { BackgroundColor3 = FSlib.Theme.BackgroundSecondary }, 0.1)
                        end)
                        
                        itemButton.MouseButton1Click:Connect(function()
                            value = item
                            dropdownButton.Text = "  " .. tostring(value)
                            closeDropdown()
                            
                            if flag then
                                FSlib.Flags[flag] = value
                            end
                            callback(value)
                        end)
                    end
                end
                
                createItems()
                
                dropdownOverlay.MouseButton1Click:Connect(function()
                    closeDropdown()
                end)
                
                dropdownButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    dropdownList.Visible = isOpen
                    dropdownOverlay.Visible = isOpen
                    dropdownArrow.Text = isOpen and "▲" or "▼"
                    
                    if isOpen then
                        updateDropdownPosition()
                    end
                end)
                
                return {
                    Set = function(_, newValue)
                        value = newValue
                        dropdownButton.Text = "  " .. tostring(value)
                        if flag then
                            FSlib.Flags[flag] = value
                        end
                        callback(value)
                    end,
                    Get = function()
                        return value
                    end,
                    SetOptions = function(_, newItems)
                        items = newItems
                        createItems()
                    end,
                }
            end
            
            -- Keybind
            function Section:CreateKeybind(keybindOptions)
                keybindOptions = keybindOptions or {}
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
                    Name = "Keybind_" .. name,
                    Parent = self.Content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    LayoutOrder = self.ElementCount,
                    ZIndex = 10,
                })
                
                local keybindLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = keybindFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                })
                BindToTheme(keybindLabel, "TextColor3", "Text")
                
                local keybindButton = Create("TextButton", {
                    Name = "Button",
                    Parent = keybindFrame,
                    BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -55, 0.5, -10),
                    Size = UDim2.new(0, 55, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    Text = value.Name or "None",
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 11,
                    ZIndex = 11,
                })
                BindToTheme(keybindButton, "BackgroundColor3", "BackgroundSecondary")
                BindToTheme(keybindButton, "TextColor3", "Text")
                
                Create("UIStroke", {
                    Parent = keybindButton,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                keybindButton.MouseButton1Click:Connect(function()
                    listening = true
                    keybindButton.Text = "..."
                    Tween(keybindButton, { BackgroundColor3 = FSlib.Theme.Primary }, 0.15)
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            value = input.KeyCode
                            keybindButton.Text = value.Name
                            listening = false
                            Tween(keybindButton, { BackgroundColor3 = FSlib.Theme.BackgroundSecondary }, 0.15)
                            
                            if flag then
                                FSlib.Flags[flag] = value
                            end
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                               input.UserInputType == Enum.UserInputType.MouseButton2 then
                            listening = false
                            keybindButton.Text = value.Name or "None"
                            Tween(keybindButton, { BackgroundColor3 = FSlib.Theme.BackgroundSecondary }, 0.15)
                        end
                    elseif not processed and input.KeyCode == value then
                        callback(value)
                    end
                end)
                
                return {
                    Set = function(_, newValue)
                        value = newValue
                        keybindButton.Text = value.Name or "None"
                        if flag then
                            FSlib.Flags[flag] = value
                        end
                    end,
                    Get = function()
                        return value
                    end,
                }
            end
            
            -- ColorPicker
            function Section:CreateColorPicker(colorPickerOptions)
                colorPickerOptions = colorPickerOptions or {}
                local name = colorPickerOptions.Name or "Color"
                local default = colorPickerOptions.Default or Color3.fromRGB(255, 0, 0)
                local flag = colorPickerOptions.Flag
                local callback = colorPickerOptions.Callback or function() end
                
                self.ElementCount = self.ElementCount + 1
                local value = default
                local isOpen = false
                local hue, sat, val = Color3.toHSV(default)
                
                if flag then
                    FSlib.Flags[flag] = value
                end
                
                local colorFrame = Create("Frame", {
                    Name = "ColorPicker_" .. name,
                    Parent = self.Content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    LayoutOrder = self.ElementCount,
                    ClipsDescendants = false,
                    ZIndex = 10,
                })
                
                local colorLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = colorFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                })
                BindToTheme(colorLabel, "TextColor3", "Text")
                
                local colorPreview = Create("TextButton", {
                    Name = "Preview",
                    Parent = colorFrame,
                    BackgroundColor3 = value,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -35, 0.5, -8),
                    Size = UDim2.new(0, 35, 0, 16),
                    Text = "",
                    ZIndex = 11,
                })
                
                Create("UIStroke", {
                    Parent = colorPreview,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                -- Picker Panel (在 ScreenGui 上)
                local pickerPanel = Create("Frame", {
                    Name = "ColorPanel_" .. name,
                    Parent = screenGui,
                    BackgroundColor3 = FSlib.Theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0, 200, 0, 170),
                    Visible = false,
                    ZIndex = 5000,
                    Active = true,
                })
                BindToTheme(pickerPanel, "BackgroundColor3", "Background")
                
                Create("UIStroke", {
                    Parent = pickerPanel,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                local function updatePickerPosition()
                    local absPos = colorPreview.AbsolutePosition
                    local absSize = colorPreview.AbsoluteSize
                    pickerPanel.Position = UDim2.new(0, absPos.X - 165, 0, absPos.Y + absSize.Y + 4)
                end
                
                -- SV Picker (色相饱和度)
                local svPicker = Create("Frame", {
                    Name = "SVPicker",
                    Parent = pickerPanel,
                    BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 8, 0, 8),
                    Size = UDim2.new(0, 150, 0, 100),
                    ZIndex = 5001,
                    Active = true,
                })
                
                -- 白色渐变 (左到右)
                local satGradient = Create("Frame", {
                    Name = "SatGradient",
                    Parent = svPicker,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 5002,
                })
                
                Create("UIGradient", {
                    Parent = satGradient,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }),
                })
                
                -- 黑色渐变 (上到下)
                local valOverlay = Create("Frame", {
                    Name = "ValOverlay",
                    Parent = svPicker,
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 5003,
                })
                
                Create("UIGradient", {
                    Parent = valOverlay,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }),
                    Rotation = 90,
                })
                
                -- SV Cursor
                local svCursor = Create("Frame", {
                    Name = "Cursor",
                    Parent = svPicker,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(sat, -5, 1 - val, -5),
                    Size = UDim2.new(0, 10, 0, 10),
                    ZIndex = 5004,
                })
                
                Create("UICorner", {
                    Parent = svCursor,
                    CornerRadius = UDim.new(1, 0),
                })
                
                Create("UIStroke", {
                    Parent = svCursor,
                    Color = Color3.new(0, 0, 0),
                    Thickness = 2,
                })
                
                -- SV Click Area
                local svClickArea = Create("TextButton", {
                    Name = "ClickArea",
                    Parent = svPicker,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 5005,
                })
                
                -- Hue Picker
                local huePicker = Create("Frame", {
                    Name = "HuePicker",
                    Parent = pickerPanel,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 166, 0, 8),
                    Size = UDim2.new(0, 18, 0, 100),
                    ZIndex = 5001,
                    Active = true,
                })
                
                Create("UIGradient", {
                    Parent = huePicker,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
                    }),
                    Rotation = 90,
                })
                
                Create("UIStroke", {
                    Parent = huePicker,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                -- Hue Cursor
                local hueCursor = Create("Frame", {
                    Name = "Cursor",
                    Parent = huePicker,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, -2, hue, -2),
                    Size = UDim2.new(1, 4, 0, 4),
                    ZIndex = 5002,
                })
                
                Create("UIStroke", {
                    Parent = hueCursor,
                    Color = Color3.new(1, 1, 1),
                    Thickness = 2,
                })
                
                -- Hue Click Area
                local hueClickArea = Create("TextButton", {
                    Name = "ClickArea",
                    Parent = huePicker,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 5003,
                })
                
                -- Hex Input
                local hexInput = Create("TextBox", {
                    Name = "HexInput",
                    Parent = pickerPanel,
                    BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 8, 0, 116),
                    Size = UDim2.new(0, 80, 0, 22),
                    Font = Enum.Font.Code,
                    Text = "#" .. string.format("%02X%02X%02X", math.floor(value.R * 255), math.floor(value.G * 255), math.floor(value.B * 255)),
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 11,
                    ZIndex = 5001,
                    ClearTextOnFocus = false,
                })
                BindToTheme(hexInput, "BackgroundColor3", "BackgroundSecondary")
                BindToTheme(hexInput, "TextColor3", "Text")
                
                Create("UIStroke", {
                    Parent = hexInput,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                -- Apply Button
                local applyButton = Create("TextButton", {
                    Name = "Apply",
                    Parent = pickerPanel,
                    BackgroundColor3 = FSlib.Theme.Primary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 96, 0, 116),
                    Size = UDim2.new(0, 88, 0, 22),
                    Font = Enum.Font.GothamBold,
                    Text = "APPLY",
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 11,
                    ZIndex = 5001,
                })
                BindToTheme(applyButton, "BackgroundColor3", "Primary")
                BindToTheme(applyButton, "TextColor3", "Text")
                
                -- Presets
                local presets = {
                    Color3.fromRGB(255, 0, 0),
                    Color3.fromRGB(255, 128, 0),
                    Color3.fromRGB(255, 255, 0),
                    Color3.fromRGB(0, 255, 0),
                    Color3.fromRGB(0, 255, 255),
                    Color3.fromRGB(0, 128, 255),
                    Color3.fromRGB(0, 0, 255),
                    Color3.fromRGB(128, 0, 255),
                    Color3.fromRGB(255, 0, 255),
                    Color3.fromRGB(255, 255, 255),
                    Color3.fromRGB(128, 128, 128),
                    Color3.fromRGB(0, 0, 0),
                }
                
                for i, presetColor in ipairs(presets) do
                    local presetButton = Create("TextButton", {
                        Name = "Preset" .. i,
                        Parent = pickerPanel,
                        BackgroundColor3 = presetColor,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 8 + ((i - 1) % 12) * 15, 0, 146),
                        Size = UDim2.new(0, 13, 0, 16),
                        Text = "",
                        ZIndex = 5001,
                    })
                    
                    Create("UIStroke", {
                        Parent = presetButton,
                        Color = FSlib.Theme.Border,
                        Thickness = 1,
                    })
                    
                    presetButton.MouseButton1Click:Connect(function()
                        value = presetColor
                        hue, sat, val = Color3.toHSV(presetColor)
                        colorPreview.BackgroundColor3 = value
                        svPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        svCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
                        hueCursor.Position = UDim2.new(0, -2, hue, -2)
                        hexInput.Text = "#" .. string.format("%02X%02X%02X", math.floor(value.R * 255), math.floor(value.G * 255), math.floor(value.B * 255))
                    end)
                end
                
                local function updateColor()
                    value = Color3.fromHSV(hue, sat, val)
                    colorPreview.BackgroundColor3 = value
                    svPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    hexInput.Text = "#" .. string.format("%02X%02X%02X", math.floor(value.R * 255), math.floor(value.G * 255), math.floor(value.B * 255))
                end
                
                local svDragging = false
                local hueDragging = false
                
                svClickArea.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = true
                        local relX = math.clamp((input.Position.X - svPicker.AbsolutePosition.X) / svPicker.AbsoluteSize.X, 0, 1)
                        local relY = math.clamp((input.Position.Y - svPicker.AbsolutePosition.Y) / svPicker.AbsoluteSize.Y, 0, 1)
                        sat = relX
                        val = 1 - relY
                        svCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
                        updateColor()
                    end
                end)
                
                svClickArea.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = false
                    end
                end)
                
                hueClickArea.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = true
                        local relY = math.clamp((input.Position.Y - huePicker.AbsolutePosition.Y) / huePicker.AbsoluteSize.Y, 0, 1)
                        hue = relY
                        hueCursor.Position = UDim2.new(0, -2, hue, -2)
                        updateColor()
                    end
                end)
                
                hueClickArea.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if svDragging then
                            local relX = math.clamp((input.Position.X - svPicker.AbsolutePosition.X) / svPicker.AbsoluteSize.X, 0, 1)
                            local relY = math.clamp((input.Position.Y - svPicker.AbsolutePosition.Y) / svPicker.AbsoluteSize.Y, 0, 1)
                            sat = relX
                            val = 1 - relY
                            svCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
                            updateColor()
                        elseif hueDragging then
                            local relY = math.clamp((input.Position.Y - huePicker.AbsolutePosition.Y) / huePicker.AbsoluteSize.Y, 0, 1)
                            hue = relY
                            hueCursor.Position = UDim2.new(0, -2, hue, -2)
                            updateColor()
                        end
                    end
                end)
                
                local function closeColorPicker()
                    isOpen = false
                    pickerPanel.Visible = false
                    
                    if flag then
                        FSlib.Flags[flag] = value
                    end
                    callback(value)
                end
                
                colorPreview.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    pickerPanel.Visible = isOpen
                    if isOpen then
                        updatePickerPosition()
                    end
                end)
                
                -- 只有点击 Apply 才关闭面板
                applyButton.MouseButton1Click:Connect(function()
                    closeColorPicker()
                end)
                
                hexInput.FocusLost:Connect(function()
                    local hex = hexInput.Text:gsub("#", "")
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1, 2), 16)
                        local g = tonumber(hex:sub(3, 4), 16)
                        local b = tonumber(hex:sub(5, 6), 16)
                        if r and g and b then
                            value = Color3.fromRGB(r, g, b)
                            hue, sat, val = Color3.toHSV(value)
                            colorPreview.BackgroundColor3 = value
                            svPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                            svCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
                            hueCursor.Position = UDim2.new(0, -2, hue, -2)
                        end
                    end
                end)
                
                return {
                    Set = function(_, newValue)
                        value = newValue
                        hue, sat, val = Color3.toHSV(newValue)
                        colorPreview.BackgroundColor3 = value
                        svPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        svCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
                        hueCursor.Position = UDim2.new(0, -2, hue, -2)
                        hexInput.Text = "#" .. string.format("%02X%02X%02X", math.floor(value.R * 255), math.floor(value.G * 255), math.floor(value.B * 255))
                        
                        if flag then
                            FSlib.Flags[flag] = value
                        end
                        callback(value)
                    end,
                    Get = function()
                        return value
                    end,
                }
            end
            
            -- Textbox
            function Section:CreateTextbox(textboxOptions)
                textboxOptions = textboxOptions or {}
                local name = textboxOptions.Name or "Textbox"
                local default = textboxOptions.Default or ""
                local placeholder = textboxOptions.Placeholder or "Enter text..."
                local flag = textboxOptions.Flag
                local callback = textboxOptions.Callback or function() end
                
                self.ElementCount = self.ElementCount + 1
                local value = default
                
                if flag then
                    FSlib.Flags[flag] = value
                end
                
                local textboxFrame = Create("Frame", {
                    Name = "Textbox_" .. name,
                    Parent = self.Content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 42),
                    LayoutOrder = self.ElementCount,
                    ZIndex = 10,
                })
                
                local textboxLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = textboxFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                })
                BindToTheme(textboxLabel, "TextColor3", "Text")
                
                local textbox = Create("TextBox", {
                    Name = "Input",
                    Parent = textboxFrame,
                    BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 16),
                    Size = UDim2.new(1, 0, 0, 24),
                    Font = Enum.Font.GothamMedium,
                    Text = default,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = FSlib.Theme.TextDark,
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    ZIndex = 11,
                })
                BindToTheme(textbox, "BackgroundColor3", "BackgroundSecondary")
                BindToTheme(textbox, "TextColor3", "Text")
                BindToTheme(textbox, "PlaceholderColor3", "TextDark")
                
                Create("UIPadding", {
                    Parent = textbox,
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
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
                
                return {
                    Set = function(_, newValue)
                        value = newValue
                        textbox.Text = newValue
                        if flag then
                            FSlib.Flags[flag] = value
                        end
                        callback(value)
                    end,
                    Get = function()
                        return value
                    end,
                }
            end
            
            -- Button
            function Section:CreateButton(buttonOptions)
                buttonOptions = buttonOptions or {}
                local name = buttonOptions.Name or "Button"
                local callback = buttonOptions.Callback or function() end
                
                self.ElementCount = self.ElementCount + 1
                
                local buttonFrame = Create("Frame", {
                    Name = "Button_" .. name,
                    Parent = self.Content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 26),
                    LayoutOrder = self.ElementCount,
                    ZIndex = 10,
                })
                
                local button = Create("TextButton", {
                    Name = "Button",
                    Parent = buttonFrame,
                    BackgroundColor3 = FSlib.Theme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = name,
                    TextColor3 = FSlib.Theme.Text,
                    TextSize = 12,
                    ClipsDescendants = true,
                    ZIndex = 11,
                })
                BindToTheme(button, "BackgroundColor3", "BackgroundSecondary")
                BindToTheme(button, "TextColor3", "Text")
                
                Create("UIStroke", {
                    Parent = button,
                    Color = FSlib.Theme.Border,
                    Thickness = 1,
                })
                
                button.MouseEnter:Connect(function()
                    Tween(button, { BackgroundColor3 = FSlib.Theme.Primary }, 0.15)
                end)
                
                button.MouseLeave:Connect(function()
                    Tween(button, { BackgroundColor3 = FSlib.Theme.BackgroundSecondary }, 0.15)
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
                    Parent = self.Content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    LayoutOrder = self.ElementCount,
                    ZIndex = 10,
                })
                
                local label = Create("TextLabel", {
                    Name = "Text",
                    Parent = labelFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = text or "",
                    TextColor3 = FSlib.Theme.TextDark,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                })
                BindToTheme(label, "TextColor3", "TextDark")
                
                return {
                    Set = function(_, newText)
                        label.Text = newText
                    end,
                }
            end
            
            -- Divider
            function Section:CreateDivider()
                self.ElementCount = self.ElementCount + 1
                
                local divider = Create("Frame", {
                    Name = "Divider",
                    Parent = self.Content,
                    BackgroundColor3 = FSlib.Theme.Border,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1),
                    LayoutOrder = self.ElementCount,
                    ZIndex = 10,
                })
                BindToTheme(divider, "BackgroundColor3", "Border")
                
                return divider
            end
            
            table.insert(self.Sections, Section)
            return Section
        end
        
        -- Tab button events
        tabButton.MouseButton1Click:Connect(function()
            for _, t in ipairs(Window.Tabs) do
                t.Button.TextColor3 = FSlib.Theme.TextDark
                t.Button.Indicator.Visible = false
                t.Content.Visible = false
            end
            
            tabButton.TextColor3 = FSlib.Theme.Text
            tabIndicator.Visible = true
            tabContent.Visible = true
            Window.ActiveTab = Tab
        end)
        
        tabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(tabButton, { TextColor3 = FSlib.Theme.Text }, 0.1)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(tabButton, { TextColor3 = FSlib.Theme.TextDark }, 0.1)
            end
        end)
        
        table.insert(self.Tabs, Tab)
        
        -- Auto-select first tab
        if #self.Tabs == 1 then
            tabButton.TextColor3 = FSlib.Theme.Text
            tabIndicator.Visible = true
            tabContent.Visible = true
            self.ActiveTab = Tab
        end
        
        return Tab
    end
    
    table.insert(FSlib.Windows, Window)
    return Window
end

-- Notification System
function FSlib:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 3
    local notifType = options.Type or "Info"
    
    local colors = {
        Success = FSlib.Theme.Success,
        Warning = FSlib.Theme.Warning,
        Error = FSlib.Theme.Error,
        Info = FSlib.Theme.Info,
    }
    
    local accentColor = colors[notifType] or colors.Info
    
    local screenGui = game:GetService("CoreGui"):FindFirstChild("FSlib_Notifications")
    if not screenGui then
        screenGui = Create("ScreenGui", {
            Name = "FSlib_Notifications",
            Parent = game:GetService("CoreGui"),
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false,
        })
        
        Create("Frame", {
            Name = "Container",
            Parent = screenGui,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -260, 0, 10),
            Size = UDim2.new(0, 250, 1, -20),
        })
        
        Create("UIListLayout", {
            Parent = screenGui.Container,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
        })
    end
    
    local container = screenGui.Container
    
    local notif = Create("Frame", {
        Name = "Notification",
        Parent = container,
        BackgroundColor3 = FSlib.Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
    })
    
    Create("UIStroke", {
        Parent = notif,
        Color = FSlib.Theme.Border,
        Thickness = 1,
    })
    
    local accent = Create("Frame", {
        Name = "Accent",
        Parent = notif,
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0),
    })
    
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -20, 0, 14),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = accentColor,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local contentLabel = Create("TextLabel", {
        Name = "Content",
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 24),
        Size = UDim2.new(1, -20, 0, 28),
        Font = Enum.Font.GothamMedium,
        Text = content,
        TextColor3 = FSlib.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
    })
    
    Tween(notif, { Size = UDim2.new(1, 0, 0, 60) }, 0.3)
    
    task.delay(duration, function()
        Tween(notif, { Size = UDim2.new(1, 0, 0, 0) }, 0.3)
        task.delay(0.3, function()
            notif:Destroy()
        end)
    end)
end

-- Watermark
function FSlib:CreateWatermark(options)
    options = options or {}
    local name = options.Name or "FSlib"
    
    local screenGui = Create("ScreenGui", {
        Name = "FSlib_Watermark",
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    })
    
    local watermark = Create("Frame", {
        Name = "Watermark",
        Parent = screenGui,
        BackgroundColor3 = FSlib.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 280, 0, 28),
    })
    BindToTheme(watermark, "BackgroundColor3", "Background")
    
    Create("UIStroke", {
        Parent = watermark,
        Color = FSlib.Theme.Border,
        Thickness = 1,
    })
    
    local accent = Create("Frame", {
        Name = "Accent",
        Parent = watermark,
        BackgroundColor3 = FSlib.Theme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0),
    })
    BindToTheme(accent, "BackgroundColor3", "Primary")
    
    local text = Create("TextLabel", {
        Name = "Text",
        Parent = watermark,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = name .. "  |  FPS: 60  |  Ping: 0ms  |  00:00:00",
        TextColor3 = FSlib.Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    BindToTheme(text, "TextColor3", "Text")
    
    local lastUpdate = 0
    local fps = 60
    
    RunService.RenderStepped:Connect(function(delta)
        fps = math.floor(1 / delta)
    end)
    
    RunService.Heartbeat:Connect(function()
        if tick() - lastUpdate >= 0.5 then
            lastUpdate = tick()
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            local timeStr = os.date("%H:%M:%S")
            text.Text = string.format("%s  |  FPS: %d  |  Ping: %dms  |  %s", name, fps, ping, timeStr)
            
            local textWidth = text.TextBounds.X + 30
            watermark.Size = UDim2.new(0, math.max(textWidth, 200), 0, 28)
        end
    end)
    
    -- Dragging
    local dragging = false
    local dragStart, startPos
    
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
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return {
        Frame = watermark,
        SetVisible = function(_, visible)
            watermark.Visible = visible
        end,
    }
end

return FSlib
