--[[
    VertexUI - Roblox Script GUI Library
    Version: 1.0.0
    Style: CSGO Cheat GUI (Vertical Layout)
    
    Usage:
    local Vertex = loadstring(game:HttpGet("YOUR_URL_HERE"))()
    local Window = Vertex:CreateWindow("Vertex")
    local Tab = Window:CreateTab("LEGIT")
    local Section = Tab:CreateSection("Aimbot", Color3.fromRGB(61, 90, 128))
    Section:CreateToggle("Enabled", false, function(value) print(value) end)
]]
local Vertex = {}
Vertex.__index = Vertex
-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
-- Theme Colors
local Theme = {
    Background = Color3.fromRGB(13, 13, 13),
    Secondary = Color3.fromRGB(19, 19, 19),
    Tertiary = Color3.fromRGB(22, 22, 22),
    Border = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(200, 200, 200),
    TextDark = Color3.fromRGB(100, 100, 100),
    Accent = Color3.fromRGB(61, 90, 128),
    AccentHover = Color3.fromRGB(71, 100, 138),
    Toggle = Color3.fromRGB(45, 45, 45),
    ToggleActive = Color3.fromRGB(61, 90, 128),
    Slider = Color3.fromRGB(30, 30, 30),
    SliderFill = Color3.fromRGB(61, 90, 128),
}
-- Utility Functions
local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end
local function Tween(instance, properties, duration)
    local tween = TweenService:Create(instance, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad), properties)
    tween:Play()
    return tween
end
local function GetKeyName(keyCode)
    local keyNames = {
        [Enum.UserInputType.MouseButton1] = "M1",
        [Enum.UserInputType.MouseButton2] = "M2",
        [Enum.UserInputType.MouseButton3] = "M3",
    }
    if keyNames[keyCode] then
        return keyNames[keyCode]
    end
    if typeof(keyCode) == "EnumItem" and keyCode.EnumType == Enum.KeyCode then
        local name = keyCode.Name
        if name:match("^%a$") then
            return name
        elseif name:match("^%d$") then
            return name
        elseif name == "LeftShift" then return "LSHIFT"
        elseif name == "RightShift" then return "RSHIFT"
        elseif name == "LeftControl" then return "LCTRL"
        elseif name == "RightControl" then return "RCTRL"
        elseif name == "LeftAlt" then return "LALT"
        elseif name == "RightAlt" then return "RALT"
        elseif name == "Space" then return "SPACE"
        elseif name == "Tab" then return "TAB"
        elseif name == "CapsLock" then return "CAPS"
        else return name:upper()
        end
    end
    return "NONE"
end
-- Keybind Manager
local KeybindManager = {
    Keybinds = {},
    ActiveDisplay = nil
}
function KeybindManager:Register(name, key, callback)
    self.Keybinds[name] = {Key = key, Callback = callback, Active = false}
    self:UpdateDisplay()
end
function KeybindManager:Unregister(name)
    self.Keybinds[name] = nil
    self:UpdateDisplay()
end
function KeybindManager:SetKey(name, key)
    if self.Keybinds[name] then
        self.Keybinds[name].Key = key
        self:UpdateDisplay()
    end
end
function KeybindManager:UpdateDisplay()
    if not self.ActiveDisplay then return end
    
    for _, child in pairs(self.ActiveDisplay:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local yOffset = 0
    for name, data in pairs(self.Keybinds) do
        if data.Active and data.Key then
            local keyFrame = Create("Frame", {
                Parent = self.ActiveDisplay,
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, yOffset),
                Size = UDim2.new(1, 0, 0, 18),
            })
            
            Create("UICorner", {Parent = keyFrame, CornerRadius = UDim.new(0, 2)})
            Create("UIStroke", {Parent = keyFrame, Color = Theme.Border, Thickness = 1})
            
            Create("TextLabel", {
                Parent = keyFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -6, 1, 0),
                Position = UDim2.new(0, 3, 0, 0),
                Text = string.format("[%s] %s", GetKeyName(data.Key), name),
                TextColor3 = Theme.TextDark,
                TextSize = 10,
                Font = Enum.Font.Code,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            yOffset = yOffset + 20
        end
    end
    
    self.ActiveDisplay.Size = UDim2.new(0, 80, 0, math.max(yOffset, 0))
end
-- Input Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    for name, data in pairs(KeybindManager.Keybinds) do
        if data.Key then
            local match = false
            if input.UserInputType == Enum.UserInputType.Keyboard then
                match = (data.Key == input.KeyCode)
            else
                match = (data.Key == input.UserInputType)
            end
            
            if match then
                data.Active = not data.Active
                if data.Callback then
                    data.Callback(data.Active)
                end
                KeybindManager:UpdateDisplay()
            end
        end
    end
end)
-- Main Window Class
function Vertex:CreateWindow(title)
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Minimized = false
    Window.Visible = true
    
    -- Destroy existing GUI
    if CoreGui:FindFirstChild("VertexUI") then
        CoreGui:FindFirstChild("VertexUI"):Destroy()
    end
    
    -- Main ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "VertexUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    })
    
    -- Main Frame
    local MainFrame = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -140, 0.5, -250),
        Size = UDim2.new(0, 280, 0, 500),
        ClipsDescendants = true,
    })
    
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = MainFrame, Color = Theme.Border, Thickness = 1})
    
    Window.MainFrame = MainFrame
    Window.ScreenGui = ScreenGui
    
    -- Title Bar
    local TitleBar = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 28),
    })
    
    Create("UICorner", {Parent = TitleBar, CornerRadius = UDim.new(0, 4)})
    
    -- Fix corner overlap
    local TitleBarFix = Create("Frame", {
        Parent = TitleBar,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
    })
    
    -- Title Text
    local TitleText = Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Text = title or "Vertex",
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    -- Version
    local VersionText = Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 55, 0, 0),
        Size = UDim2.new(0, 50, 1, 0),
        Text = "v1.0",
        TextColor3 = Theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    -- Close Button
    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0, 4),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "×",
        TextColor3 = Theme.TextDark,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
    })
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {TextColor3 = Color3.fromRGB(255, 100, 100)}, 0.1)
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {TextColor3 = Theme.TextDark}, 0.1)
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Minimize Button
    local MinBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -44, 0, 4),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "−",
        TextColor3 = Theme.TextDark,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
    })
    
    MinBtn.MouseEnter:Connect(function()
        Tween(MinBtn, {TextColor3 = Theme.Text}, 0.1)
    end)
    
    MinBtn.MouseLeave:Connect(function()
        Tween(MinBtn, {TextColor3 = Theme.TextDark}, 0.1)
    end)
    
    MinBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            Tween(MainFrame, {Size = UDim2.new(0, 280, 0, 28)}, 0.2)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 280, 0, 500)}, 0.2)
        end
    end)
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Tab Container
    local TabContainer = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 4, 0, 32),
        Size = UDim2.new(1, -8, 0, 24),
    })
    
    Create("UICorner", {Parent = TabContainer, CornerRadius = UDim.new(0, 2)})
    
    local TabLayout = Create("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    
    Window.TabContainer = TabContainer
    
    -- Content Container
    local ContentContainer = Create("ScrollingFrame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 4, 0, 60),
        Size = UDim2.new(1, -8, 1, -82),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    
    local ContentLayout = Create("UIListLayout", {
        Parent = ContentContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    })
    
    local ContentPadding = Create("UIPadding", {
        Parent = ContentContainer,
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 2),
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 2),
    })
    
    Window.ContentContainer = ContentContainer
    
    -- Status Bar
    local StatusBar = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 4, 1, -22),
        Size = UDim2.new(1, -8, 0, 18),
    })
    
    Create("UICorner", {Parent = StatusBar, CornerRadius = UDim.new(0, 2)})
    
    local StatusText = Create("TextLabel", {
        Parent = StatusBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(1, -12, 1, 0),
        Text = "FPS: 60 | PING: 0ms | STATUS: Connected",
        TextColor3 = Theme.TextDark,
        TextSize = 9,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    Window.StatusText = StatusText
    
    -- Update Status
    spawn(function()
        while Window.ScreenGui and Window.ScreenGui.Parent do
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            local ping = math.floor(Player:GetNetworkPing() * 1000)
            StatusText.Text = string.format("FPS: %d | PING: %dms | STATUS: Connected", fps, ping)
        end
    end)
    
    -- Keybind Display
    local KeybindDisplay = Create("Frame", {
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -90, 0, 10),
        Size = UDim2.new(0, 80, 0, 0),
    })
    
    local KeybindLayout = Create("UIListLayout", {
        Parent = KeybindDisplay,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })
    
    KeybindManager.ActiveDisplay = KeybindDisplay
    
    -- Toggle Visibility
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            Window.Visible = not Window.Visible
            MainFrame.Visible = Window.Visible
        end
    end)
    
    -- Create Tab Function
    function Window:CreateTab(name)
        local Tab = {}
        Tab.Name = name
        Tab.Sections = {}
        
        local tabWidth = 1 / math.max(#self.Tabs + 1, 1)
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Theme.Tertiary,
            BorderSizePixel = 0,
            Size = UDim2.new(tabWidth, 0, 1, 0),
            Text = name,
            TextColor3 = Theme.TextDark,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
        })
        
        Tab.Button = TabButton
        
        -- Tab Content Frame
        local TabContent = Create("Frame", {
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
        })
        
        local TabContentLayout = Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        })
        
        Tab.Content = TabContent
        
        -- Update tab widths
        table.insert(self.Tabs, Tab)
        for i, t in ipairs(self.Tabs) do
            t.Button.Size = UDim2.new(1 / #self.Tabs, 0, 1, 0)
        end
        
        -- Tab Selection
        local function SelectTab()
            for _, t in ipairs(self.Tabs) do
                t.Button.BackgroundColor3 = Theme.Tertiary
                t.Button.TextColor3 = Theme.TextDark
                t.Content.Visible = false
            end
            
            TabButton.BackgroundColor3 = Theme.Accent
            TabButton.TextColor3 = Theme.Text
            TabContent.Visible = true
            self.ActiveTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        TabButton.MouseEnter:Connect(function()
            if self.ActiveTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.AccentHover}, 0.1)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if self.ActiveTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.Tertiary}, 0.1)
            end
        end)
        
        -- Auto select first tab
        if #self.Tabs == 1 then
            SelectTab()
        end
        
        -- Create Section Function
        function Tab:CreateSection(name, color)
            local Section = {}
            Section.Name = name
            Section.Color = color or Theme.Accent
            Section.Expanded = true
            Section.Elements = {}
            
            -- Section Frame
            local SectionFrame = Create("Frame", {
                Parent = TabContent,
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            
            Create("UICorner", {Parent = SectionFrame, CornerRadius = UDim.new(0, 3)})
            
            -- Color Indicator
            local ColorIndicator = Create("Frame", {
                Parent = SectionFrame,
                BackgroundColor3 = Section.Color,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 3, 1, 0),
            })
            
            Create("UICorner", {Parent = ColorIndicator, CornerRadius = UDim.new(0, 3)})
            
            -- Section Header
            local SectionHeader = Create("TextButton", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                Text = "",
                AutoButtonColor = false,
            })
            
            local SectionTitle = Create("TextLabel", {
                Parent = SectionHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = name,
                TextColor3 = Theme.Text,
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local ExpandIcon = Create("TextLabel", {
                Parent = SectionHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -20, 0, 0),
                Size = UDim2.new(0, 16, 1, 0),
                Text = "−",
                TextColor3 = Theme.TextDark,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
            })
            
            -- Section Content
            local SectionContent = Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 22),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ClipsDescendants = true,
            })
            
            local SectionContentLayout = Create("UIListLayout", {
                Parent = SectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 1),
            })
            
            local SectionContentPadding = Create("UIPadding", {
                Parent = SectionContent,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 6),
            })
            
            Section.Frame = SectionFrame
            Section.Content = SectionContent
            
            -- Toggle Expand
            SectionHeader.MouseButton1Click:Connect(function()
                Section.Expanded = not Section.Expanded
                if Section.Expanded then
                    ExpandIcon.Text = "−"
                    SectionContent.Visible = true
                else
                    ExpandIcon.Text = "+"
                    SectionContent.Visible = false
                end
            end)
            
            table.insert(Tab.Sections, Section)
            
            -- Create Toggle
            function Section:CreateToggle(name, default, callback)
                local Toggle = {}
                Toggle.Value = default or false
                
                local ToggleFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    Text = name,
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local ToggleButton = Create("TextButton", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = Toggle.Value and Theme.ToggleActive or Theme.Toggle,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -16, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    Text = Toggle.Value and "✓" or "",
                    TextColor3 = Theme.Text,
                    TextSize = 8,
                    Font = Enum.Font.GothamBold,
                    AutoButtonColor = false,
                })
                
                Create("UICorner", {Parent = ToggleButton, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = ToggleButton, Color = Theme.Border, Thickness = 1})
                
                local function UpdateToggle()
                    ToggleButton.BackgroundColor3 = Toggle.Value and Theme.ToggleActive or Theme.Toggle
                    ToggleButton.Text = Toggle.Value and "✓" or ""
                    ToggleLabel.TextColor3 = Toggle.Value and Theme.Text or Theme.TextDark
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    UpdateToggle()
                    if callback then
                        callback(Toggle.Value)
                    end
                end)
                
                function Toggle:Set(value)
                    Toggle.Value = value
                    UpdateToggle()
                    if callback then
                        callback(Toggle.Value)
                    end
                end
                
                function Toggle:Get()
                    return Toggle.Value
                end
                
                table.insert(Section.Elements, Toggle)
                return Toggle
            end
            
            -- Create Slider
            function Section:CreateSlider(name, min, max, default, callback)
                local Slider = {}
                Slider.Value = default or min
                Slider.Min = min
                Slider.Max = max
                
                local SliderFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                })
                
                local SliderLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -40, 0, 16),
                    Text = name,
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local SliderValue = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -40, 0, 0),
                    Size = UDim2.new(0, 40, 0, 16),
                    Text = tostring(Slider.Value),
                    TextColor3 = Theme.Accent,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })
                
                local SliderBG = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.Slider,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 8),
                })
                
                Create("UICorner", {Parent = SliderBG, CornerRadius = UDim.new(0, 2)})
                
                local SliderFill = Create("Frame", {
                    Parent = SliderBG,
                    BackgroundColor3 = Theme.SliderFill,
                    BorderSizePixel = 0,
                    Size = UDim2.new((Slider.Value - min) / (max - min), 0, 1, 0),
                })
                
                Create("UICorner", {Parent = SliderFill, CornerRadius = UDim.new(0, 2)})
                
                local SliderKnob = Create("Frame", {
                    Parent = SliderFill,
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -4, 0.5, -4),
                    Size = UDim2.new(0, 8, 0, 8),
                })
                
                Create("UICorner", {Parent = SliderKnob, CornerRadius = UDim.new(0, 2)})
                
                local sliding = false
                
                local function UpdateSlider(input)
                    local pos = UDim2.new(math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1), 0, 1, 0)
                    SliderFill.Size = pos
                    Slider.Value = math.floor(min + (max - min) * pos.X.Scale)
                    SliderValue.Text = tostring(Slider.Value)
                    if callback then
                        callback(Slider.Value)
                    end
                end
                
                SliderBG.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        UpdateSlider(input)
                    end
                end)
                
                SliderBG.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                function Slider:Set(value)
                    Slider.Value = math.clamp(value, min, max)
                    SliderFill.Size = UDim2.new((Slider.Value - min) / (max - min), 0, 1, 0)
                    SliderValue.Text = tostring(Slider.Value)
                    if callback then
                        callback(Slider.Value)
                    end
                end
                
                function Slider:Get()
                    return Slider.Value
                end
                
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            -- Create Dropdown
            function Section:CreateDropdown(name, options, default, callback)
                local Dropdown = {}
                Dropdown.Value = default or options[1]
                Dropdown.Options = options
                Dropdown.Open = false
                
                local DropdownFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 38),
                    ClipsDescendants = false,
                    ZIndex = 10,
                })
                
                local DropdownLabel = Create("TextLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 16),
                    Text = name,
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                })
                
                local DropdownButton = Create("TextButton", {
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.Tertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 18),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 10,
                })
                
                Create("UICorner", {Parent = DropdownButton, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = DropdownButton, Color = Theme.Border, Thickness = 1})
                
                local DropdownText = Create("TextLabel", {
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 6, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    Text = Dropdown.Value,
                    TextColor3 = Theme.Text,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                })
                
                local DropdownArrow = Create("TextLabel", {
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -18, 0, 0),
                    Size = UDim2.new(0, 14, 1, 0),
                    Text = "▼",
                    TextColor3 = Theme.TextDark,
                    TextSize = 8,
                    Font = Enum.Font.Gotham,
                    ZIndex = 10,
                })
                
                local DropdownList = Create("Frame", {
                    Parent = DropdownButton,
                    BackgroundColor3 = Theme.Tertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, 2),
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = false,
                    ZIndex = 100,
                    ClipsDescendants = true,
                })
                
                Create("UICorner", {Parent = DropdownList, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = DropdownList, Color = Theme.Border, Thickness = 1})
                
                local DropdownListLayout = Create("UIListLayout", {
                    Parent = DropdownList,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
                
                local function CreateOption(optionName)
                    local OptionButton = Create("TextButton", {
                        Parent = DropdownList,
                        BackgroundColor3 = Theme.Tertiary,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 18),
                        Text = optionName,
                        TextColor3 = Theme.TextDark,
                        TextSize = 10,
                        Font = Enum.Font.Gotham,
                        AutoButtonColor = false,
                        ZIndex = 100,
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        OptionButton.BackgroundTransparency = 0
                        OptionButton.BackgroundColor3 = Theme.Accent
                        OptionButton.TextColor3 = Theme.Text
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        OptionButton.BackgroundTransparency = 1
                        OptionButton.TextColor3 = Theme.TextDark
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Dropdown.Value = optionName
                        DropdownText.Text = optionName
                        Dropdown.Open = false
                        DropdownList.Visible = false
                        DropdownArrow.Text = "▼"
                        if callback then
                            callback(optionName)
                        end
                    end)
                end
                
                for _, option in ipairs(options) do
                    CreateOption(option)
                end
                
                DropdownList.Size = UDim2.new(1, 0, 0, #options * 18)
                
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    DropdownList.Visible = Dropdown.Open
                    DropdownArrow.Text = Dropdown.Open and "▲" or "▼"
                end)
                
                function Dropdown:Set(value)
                    if table.find(Dropdown.Options, value) then
                        Dropdown.Value = value
                        DropdownText.Text = value
                        if callback then
                            callback(value)
                        end
                    end
                end
                
                function Dropdown:Get()
                    return Dropdown.Value
                end
                
                function Dropdown:Refresh(newOptions)
                    for _, child in pairs(DropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    Dropdown.Options = newOptions
                    for _, option in ipairs(newOptions) do
                        CreateOption(option)
                    end
                    DropdownList.Size = UDim2.new(1, 0, 0, #newOptions * 18)
                end
                
                table.insert(Section.Elements, Dropdown)
                return Dropdown
            end
            
            -- Create Keybind
            function Section:CreateKeybind(name, default, callback)
                local Keybind = {}
                Keybind.Value = default
                Keybind.Listening = false
                
                local KeybindFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                })
                
                local KeybindLabel = Create("TextLabel", {
                    Parent = KeybindFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -45, 1, 0),
                    Text = name,
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local KeybindButton = Create("TextButton", {
                    Parent = KeybindFrame,
                    BackgroundColor3 = Theme.Tertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -40, 0.5, -8),
                    Size = UDim2.new(0, 36, 0, 16),
                    Text = Keybind.Value and string.format("[%s]", GetKeyName(Keybind.Value)) or "[NONE]",
                    TextColor3 = Theme.TextDark,
                    TextSize = 9,
                    Font = Enum.Font.Code,
                    AutoButtonColor = false,
                })
                
                Create("UICorner", {Parent = KeybindButton, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = KeybindButton, Color = Theme.Border, Thickness = 1})
                
                KeybindButton.MouseButton1Click:Connect(function()
                    Keybind.Listening = true
                    KeybindButton.Text = "[...]"
                    KeybindButton.TextColor3 = Theme.Accent
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not Keybind.Listening then return end
                    
                    local key = nil
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Escape then
                            Keybind.Value = nil
                            KeybindButton.Text = "[NONE]"
                        else
                            key = input.KeyCode
                            Keybind.Value = key
                            KeybindButton.Text = string.format("[%s]", GetKeyName(key))
                        end
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                           input.UserInputType == Enum.UserInputType.MouseButton2 or
                           input.UserInputType == Enum.UserInputType.MouseButton3 then
                        key = input.UserInputType
                        Keybind.Value = key
                        KeybindButton.Text = string.format("[%s]", GetKeyName(key))
                    end
                    
                    Keybind.Listening = false
                    KeybindButton.TextColor3 = Theme.TextDark
                    
                    if callback and key then
                        KeybindManager:Register(name, key, callback)
                    end
                end)
                
                function Keybind:Set(key)
                    Keybind.Value = key
                    KeybindButton.Text = key and string.format("[%s]", GetKeyName(key)) or "[NONE]"
                    if callback and key then
                        KeybindManager:SetKey(name, key)
                    end
                end
                
                function Keybind:Get()
                    return Keybind.Value
                end
                
                if default and callback then
                    KeybindManager:Register(name, default, callback)
                end
                
                table.insert(Section.Elements, Keybind)
                return Keybind
            end
            
            -- Create Color Picker
            function Section:CreateColorPicker(name, default, callback)
                local ColorPicker = {}
                ColorPicker.Value = default or Color3.fromRGB(255, 255, 255)
                ColorPicker.Open = false
                
                local ColorPickerFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    ClipsDescendants = false,
                    ZIndex = 5,
                })
                
                local ColorPickerLabel = Create("TextLabel", {
                    Parent = ColorPickerFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    Text = name,
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                })
                
                local ColorPreview = Create("TextButton", {
                    Parent = ColorPickerFrame,
                    BackgroundColor3 = ColorPicker.Value,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -16, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 5,
                })
                
                Create("UICorner", {Parent = ColorPreview, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = ColorPreview, Color = Theme.Border, Thickness = 1})
                
                -- Color Picker Panel
                local PickerPanel = Create("Frame", {
                    Parent = ColorPreview,
                    BackgroundColor3 = Theme.Tertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -150, 1, 5),
                    Size = UDim2.new(0, 150, 0, 120),
                    Visible = false,
                    ZIndex = 50,
                })
                
                Create("UICorner", {Parent = PickerPanel, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = PickerPanel, Color = Theme.Border, Thickness = 1})
                
                -- Hue/Saturation Square
                local HSSquare = Create("ImageLabel", {
                    Parent = PickerPanel,
                    BackgroundColor3 = Color3.fromHSV(0, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 8, 0, 8),
                    Size = UDim2.new(0, 100, 0, 100),
                    Image = "rbxassetid://4155801252",
                    ZIndex = 50,
                })
                
                Create("UICorner", {Parent = HSSquare, CornerRadius = UDim.new(0, 2)})
                
                local HSCursor = Create("Frame", {
                    Parent = HSSquare,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 6, 0, 6),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(1, 0, 0, 0),
                    ZIndex = 51,
                })
                
                Create("UICorner", {Parent = HSCursor, CornerRadius = UDim.new(1, 0)})
                Create("UIStroke", {Parent = HSCursor, Color = Color3.new(0, 0, 0), Thickness = 1})
                
                -- Hue Bar
                local HueBar = Create("Frame", {
                    Parent = PickerPanel,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 116, 0, 8),
                    Size = UDim2.new(0, 26, 0, 100),
                    ZIndex = 50,
                })
                
                Create("UICorner", {Parent = HueBar, CornerRadius = UDim.new(0, 2)})
                
                local HueGradient = Create("UIGradient", {
                    Parent = HueBar,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
                    }),
                    Rotation = 90,
                })
                
                local HueCursor = Create("Frame", {
                    Parent = HueBar,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 4),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 0, 0, 0),
                    ZIndex = 51,
                })
                
                Create("UICorner", {Parent = HueCursor, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = HueCursor, Color = Color3.new(0, 0, 0), Thickness = 1})
                
                local h, s, v = ColorPicker.Value:ToHSV()
                
                local function UpdateColor()
                    ColorPicker.Value = Color3.fromHSV(h, s, v)
                    ColorPreview.BackgroundColor3 = ColorPicker.Value
                    HSSquare.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    HSCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                    HueCursor.Position = UDim2.new(0, 0, h, 0)
                    if callback then
                        callback(ColorPicker.Value)
                    end
                end
                
                local draggingHS = false
                local draggingHue = false
                
                HSSquare.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHS = true
                    end
                end)
                
                HSSquare.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHS = false
                    end
                end)
                
                HueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = true
                    end
                end)
                
                HueBar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if draggingHS then
                            s = math.clamp((input.Position.X - HSSquare.AbsolutePosition.X) / HSSquare.AbsoluteSize.X, 0, 1)
                            v = 1 - math.clamp((input.Position.Y - HSSquare.AbsolutePosition.Y) / HSSquare.AbsoluteSize.Y, 0, 1)
                            UpdateColor()
                        elseif draggingHue then
                            h = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                            UpdateColor()
                        end
                    end
                end)
                
                ColorPreview.MouseButton1Click:Connect(function()
                    ColorPicker.Open = not ColorPicker.Open
                    PickerPanel.Visible = ColorPicker.Open
                end)
                
                UpdateColor()
                
                function ColorPicker:Set(color)
                    ColorPicker.Value = color
                    h, s, v = color:ToHSV()
                    UpdateColor()
                end
                
                function ColorPicker:Get()
                    return ColorPicker.Value
                end
                
                table.insert(Section.Elements, ColorPicker)
                return ColorPicker
            end
            
            -- Create Button
            function Section:CreateButton(name, callback)
                local Button = {}
                
                local ButtonFrame = Create("TextButton", {
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.Tertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 22),
                    Text = name,
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                    AutoButtonColor = false,
                })
                
                Create("UICorner", {Parent = ButtonFrame, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = ButtonFrame, Color = Theme.Border, Thickness = 1})
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, 0.1)
                    Tween(ButtonFrame, {TextColor3 = Theme.Text}, 0.1)
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.Tertiary}, 0.1)
                    Tween(ButtonFrame, {TextColor3 = Theme.TextDark}, 0.1)
                end)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    if callback then
                        callback()
                    end
                end)
                
                table.insert(Section.Elements, Button)
                return Button
            end
            
            -- Create TextBox
            function Section:CreateTextBox(name, default, placeholder, callback)
                local TextBox = {}
                TextBox.Value = default or ""
                
                local TextBoxFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 38),
                })
                
                local TextBoxLabel = Create("TextLabel", {
                    Parent = TextBoxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 16),
                    Text = name,
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local TextBoxInput = Create("TextBox", {
                    Parent = TextBoxFrame,
                    BackgroundColor3 = Theme.Tertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 18),
                    Text = TextBox.Value,
                    PlaceholderText = placeholder or "",
                    TextColor3 = Theme.Text,
                    PlaceholderColor3 = Theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    ClearTextOnFocus = false,
                })
                
                Create("UICorner", {Parent = TextBoxInput, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = TextBoxInput, Color = Theme.Border, Thickness = 1})
                Create("UIPadding", {Parent = TextBoxInput, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)})
                
                TextBoxInput.FocusLost:Connect(function(enterPressed)
                    TextBox.Value = TextBoxInput.Text
                    if callback then
                        callback(TextBox.Value, enterPressed)
                    end
                end)
                
                function TextBox:Set(value)
                    TextBox.Value = value
                    TextBoxInput.Text = value
                end
                
                function TextBox:Get()
                    return TextBox.Value
                end
                
                table.insert(Section.Elements, TextBox)
                return TextBox
            end
            
            -- Create Label
            function Section:CreateLabel(text)
                local Label = {}
                
                local LabelFrame = Create("TextLabel", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                function Label:Set(newText)
                    LabelFrame.Text = newText
                end
                
                table.insert(Section.Elements, Label)
                return Label
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- Notification System
    function Window:Notify(title, message, duration, notifType)
        duration = duration or 3
        notifType = notifType or "info"
        
        local colors = {
            info = Theme.Accent,
            success = Color3.fromRGB(80, 150, 80),
            warning = Color3.fromRGB(200, 150, 50),
            error = Color3.fromRGB(180, 60, 60),
        }
        
        local NotifContainer = ScreenGui:FindFirstChild("NotifContainer")
        if not NotifContainer then
            NotifContainer = Create("Frame", {
                Name = "NotifContainer",
                Parent = ScreenGui,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -220, 1, -10),
                Size = UDim2.new(0, 210, 0, 0),
                AnchorPoint = Vector2.new(0, 1),
            })
            
            Create("UIListLayout", {
                Parent = NotifContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 5),
            })
        end
        
        local Notif = Create("Frame", {
            Parent = NotifContainer,
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 50),
            ClipsDescendants = true,
        })
        
        Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 4)})
        Create("UIStroke", {Parent = Notif, Color = Theme.Border, Thickness = 1})
        
        local NotifColor = Create("Frame", {
            Parent = Notif,
            BackgroundColor3 = colors[notifType] or colors.info,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 1, 0),
        })
        
        local NotifTitle = Create("TextLabel", {
            Parent = Notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(1, -15, 0, 16),
            Text = title,
            TextColor3 = Theme.Text,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        local NotifMessage = Create("TextLabel", {
            Parent = Notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 22),
            Size = UDim2.new(1, -15, 0, 24),
            Text = message,
            TextColor3 = Theme.TextDark,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        })
        
        -- Progress bar
        local NotifProgress = Create("Frame", {
            Parent = Notif,
            BackgroundColor3 = colors[notifType] or colors.info,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(1, 0, 0, 2),
        })
        
        Tween(NotifProgress, {Size = UDim2.new(0, 0, 0, 2)}, duration)
        
        task.delay(duration, function()
            Tween(Notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            task.wait(0.2)
            Notif:Destroy()
        end)
    end
    
    -- Destroy Function
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    -- Toggle Visibility
    function Window:Toggle(visible)
        if visible == nil then
            Window.Visible = not Window.Visible
        else
            Window.Visible = visible
        end
        MainFrame.Visible = Window.Visible
    end
    
    return Window
end
return Vertex
