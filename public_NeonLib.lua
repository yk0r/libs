-- NEON UI LIBRARY (Standalone)
-- Commercial Grade • Native Roblox GUI
-- <https://github.com/YourRepo/NeonLib>

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Neon = {}
Neon.__index = Neon

-- [ CONFIGURATION ] -----------------------------------------------------------

Neon.Theme = {
    Accent = Color3.fromRGB(99, 102, 241),      -- Indigo 500
    AccentDark = Color3.fromRGB(79, 70, 229),   -- Indigo 600
    Background = Color3.fromRGB(24, 24, 27),    -- Zinc 900
    BackgroundDark = Color3.fromRGB(9, 9, 11),  -- Zinc 950
    Item = Color3.fromRGB(39, 39, 42),          -- Zinc 800
    ItemActive = Color3.fromRGB(63, 63, 70),    -- Zinc 700
    Text = Color3.fromRGB(244, 244, 245),       -- Zinc 100
    TextDim = Color3.fromRGB(161, 161, 170),    -- Zinc 400
    Border = Color3.fromRGB(63, 63, 70),        -- Zinc 700
}

Neon.Icons = {
    Home = "rbxassetid://6026568198",
    Settings = "rbxassetid://6031280882",
    User = "rbxassetid://6026568248",
    List = "rbxassetid://6031280896",
    Search = "rbxassetid://6031154871",
    Check = "rbxassetid://6031048436",
    Down = "rbxassetid://6034818372",
    Info = "rbxassetid://6031086096",
    Warning = "rbxassetid://6031086166",
    Error = "rbxassetid://6031086100",
}

-- [ UTILITIES ] ---------------------------------------------------------------

local function Create(class, props)
    local instance = Instance.new(class)
    for k, v in pairs(props) do
        instance[k] = v
    end
    return instance
end

local function Tween(instance, tweenInfo, goal)
    local tween = TweenService:Create(instance, tweenInfo, goal)
    tween:Play()
    return tween
end

local function MakeDraggable(trigger, object)
    local dragging, dragInput, dragStart, startPos
    
    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    trigger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            Tween(object, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)
end

-- [ LIBRARY ] -----------------------------------------------------------------

function Neon:CreateWindow(options)
    options = options or {}
    local Title = options.Title or "Neon Interface"
    local Size = options.Size or UDim2.fromOffset(700, 500)
    
    -- Cleanup Old
    if game.CoreGui:FindFirstChild("NeonUI") then
        game.CoreGui.NeonUI:Destroy()
    end

    local ScreenGui = Create("ScreenGui", {
        Name = "NeonUI",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local NotificationHolder = Create("Frame", {
        Name = "Notifications",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        AnchorPoint = Vector2.new(1, 1),
        Size = UDim2.new(0, 300, 1, 0),
        ZIndex = 100
    })
    
    local NotificationLayout = Create("UIListLayout", {
        Parent = NotificationHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10)
    })

    -- Main Container
    -- We use a CanvasGroup or just careful layering. 
    -- To fix "sharp corners", we ensure all inner frames touching edges have UICorner.
    local Main = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = Neon.Theme.Background,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = Size,
        ClipsDescendants = false -- Important for shadow/glow if we add it outside
    })
    
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Main })
    Create("UIStroke", { Parent = Main, Color = Neon.Theme.Border, Thickness = 1 })

    -- Glassmorphism glow (Behind content)
    local Glow = Create("ImageLabel", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -50, 0, -50),
        Size = UDim2.new(1, 100, 1, 100),
        Image = "rbxassetid://5028857084",
        ImageColor3 = Neon.Theme.Accent,
        ImageTransparency = 0.9,
        ZIndex = -1
    })
    
    -- [ TOP BAR ]
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = Main,
        BackgroundColor3 = Neon.Theme.BackgroundDark,
        Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0
    })
    -- Round top corners to match Main
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = TopBar })
    
    -- Patch bottom of TopBar to be flat
    local TopBarPatch = Create("Frame", {
        Parent = TopBar,
        BackgroundColor3 = Neon.Theme.BackgroundDark,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10)
    })
    
    -- Title & Light Point
    local LightPoint = Create("Frame", {
        Parent = TopBar,
        BackgroundColor3 = Neon.Theme.Accent,
        Position = UDim2.new(0, 16, 0.5, -3),
        Size = UDim2.fromOffset(6, 6),
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = LightPoint })
    
    -- Glow for light point
    local PointGlow = Create("UIStroke", {
        Parent = LightPoint,
        Color = Neon.Theme.Accent,
        Thickness = 2,
        Transparency = 0.6
    })

    local TitleText = Create("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0), -- Adjusted pos
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = string.upper(Title),
        TextColor3 = Neon.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local CloseBtn = Create("TextButton", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0, 0),
        Size = UDim2.new(0, 40, 1, 0),
        Text = "×",
        Font = Enum.Font.Gotham,
        TextSize = 24,
        TextColor3 = Neon.Theme.TextDim
    })
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    MakeDraggable(TopBar, Main)

    -- Container for Tabs and Pages
    local Content = Create("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40),
        ClipsDescendants = true -- Clip content
    })
    
    -- Corner fix for content area (bottom corners)
    -- Actually Content doesn't have background, but Sidebar does.
    
    local Sidebar = Create("ScrollingFrame", {
        Parent = Content,
        BackgroundColor3 = Neon.Theme.BackgroundDark,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 170, 1, 0),
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0,0,0,0)
    })
    
    -- Round bottom-left corner of Sidebar to match Main
    -- We can just round all, and patch the top
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Sidebar })
    
    local SidebarPatch = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Neon.Theme.BackgroundDark,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 10)
    })
    -- Also patch bottom-right of Sidebar because it should be flat (connecting to pages)
    local SidebarPatch2 = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Neon.Theme.BackgroundDark,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.new(0, 10, 0, 10)
    })
    
    local SidebarLayout = Create("UIListLayout", {
        Parent = Sidebar,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Create("UIPadding", { 
        Parent = Sidebar, 
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12)
    })

    local Pages = Create("Frame", {
        Parent = Content,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 170, 0, 0),
        Size = UDim2.new(1, -170, 1, 0),
        ClipsDescendants = true
    })

    -- Library State
    local Library = {
        Tabs = {},
        CurrentTab = nil,
        Hidden = false
    }

    function Library:Notify(options)
        options = options or {}
        local title = options.Title or "Notification"
        local text = options.Content or ""
        local duration = options.Duration or 3
        
        local Notif = Create("Frame", {
            Parent = NotificationHolder,
            BackgroundColor3 = Neon.Theme.Item,
            Size = UDim2.new(1, 0, 0, 0), -- Animate height
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1
        })
        
        local Container = Create("Frame", {
            Parent = Notif,
            BackgroundColor3 = Neon.Theme.Background,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.fromScale(1, 0) -- Animate X
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Container })
        Create("UIStroke", { Parent = Container, Color = Neon.Theme.Border, Thickness = 1 })
        
        local NTitle = Create("TextLabel", {
            Parent = Container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -20, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Neon.Theme.Accent,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local NText = Create("TextLabel", {
            Parent = Container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 26),
            Size = UDim2.new(1, -20, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Neon.Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })
        Create("UIPadding", { Parent = Container, PaddingBottom = UDim.new(0, 10) })

        -- Intro Animation
        Tween(Notif, TweenInfo.new(0.3), { BackgroundTransparency = 0 }) 
        Tween(Container, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0, 0) })
        
        task.delay(duration, function()
            Tween(Container, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Position = UDim2.fromScale(1.2, 0) })
            task.wait(0.5)
            Notif:Destroy()
        end)
    end
    
    function Library:CreateTab(options)
        options = options or {}
        local Name = options.Name or "Tab"
        local Icon = options.Icon or ""
        
        local TabBtn = Create("TextButton", {
            Parent = Sidebar,
            BackgroundColor3 = Color3.new(0,0,0),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34),
            Text = "",
            AutoButtonColor = false
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabBtn })
        
        local TabLabel = Create("TextLabel", {
            Parent = TabBtn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 36, 0, 0),
            Size = UDim2.new(1, -36, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = Name,
            TextColor3 = Neon.Theme.TextDim,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        if Icon ~= "" and not Icon:match("rbxassetid") and Neon.Icons[Icon] then
             Icon = Neon.Icons[Icon]
        end
        
        if Icon ~= "" then
             local Ico = Create("ImageLabel", {
                 Parent = TabBtn,
                 BackgroundTransparency = 1,
                 Position = UDim2.new(0, 8, 0.5, -8),
                 Size = UDim2.fromOffset(16, 16),
                 Image = Icon,
                 ImageColor3 = Neon.Theme.TextDim
             })
        else
             -- Default dot if no icon
             local Dot = Create("Frame", {
                 Parent = TabBtn,
                 BackgroundColor3 = Neon.Theme.TextDim,
                 Position = UDim2.new(0, 14, 0.5, -2),
                 Size = UDim2.fromOffset(4, 4),
                 BackgroundTransparency = 0.5
             })
             Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Dot })
        end

        local Page = Create("ScrollingFrame", {
            Name = Name .. "Page",
            Parent = Pages,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Neon.Theme.ItemActive
        })
        Create("UIPadding", { 
            Parent = Page, 
            PaddingTop = UDim.new(0, 15), 
            PaddingLeft = UDim.new(0, 20), 
            PaddingRight = UDim.new(0, 20),
            PaddingBottom = UDim.new(0, 15)
        })
        Create("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        local function UpdateState()
            local active = (Library.CurrentTab == TabBtn)
            local targetColor = active and Neon.Theme.Accent or Color3.new(0,0,0)
            local targetTrans = active and 0.1 or 1
            local textColor = active and Neon.Theme.Text or Neon.Theme.TextDim
            
            Tween(TabBtn, TweenInfo.new(0.3), { BackgroundColor3 = targetColor, BackgroundTransparency = targetTrans })
            Tween(TabLabel, TweenInfo.new(0.3), { TextColor3 = textColor })
            
            -- Icon coloring
            for _, c in pairs(TabBtn:GetChildren()) do
                if c:IsA("ImageLabel") then
                    Tween(c, TweenInfo.new(0.3), { ImageColor3 = textColor })
                elseif c:IsA("Frame") and c.Name ~= "UICorner" then -- The dot
                    Tween(c, TweenInfo.new(0.3), { BackgroundColor3 = textColor })
                end
            end
            
            Page.Visible = active
        end

        TabBtn.MouseButton1Click:Connect(function()
            Library.CurrentTab = TabBtn
            for _, t in pairs(Library.Tabs) do
                t.Update()
            end
        end)
        
        local TabObj = { Update = UpdateState }
        table.insert(Library.Tabs, TabObj)
        
        -- Select first tab automatically
        if #Library.Tabs == 1 then
            Library.CurrentTab = TabBtn
            UpdateState()
        end
        
        -- SECTION SYSTEM
        function TabObj:CreateSection(options)
            options = options or {}
            local SecName = options.Name or "Section"
            
            local SectionFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Neon.Theme.Background,
                Size = UDim2.new(1, 0, 0, 0), -- Auto
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SectionFrame })
            Create("UIStroke", { Parent = SectionFrame, Color = Neon.Theme.Item, Thickness = 1 })
            
            local SecHeader = Create("TextButton", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                Text = "",
                AutoButtonColor = false
            })
            
            local SecTitle = Create("TextLabel", {
                Parent = SecHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = string.upper(SecName),
                TextColor3 = Neon.Theme.TextDim,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Chevron = Create("ImageLabel", {
                Parent = SecHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -26, 0.5, -7),
                Size = UDim2.fromOffset(14, 14),
                Image = Neon.Icons.Down,
                ImageColor3 = Neon.Theme.TextDim
            })
            
            local Container = Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 32),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ClipsDescendants = true
            })
            Create("UIPadding", { 
                Parent = Container, 
                PaddingLeft = UDim.new(0, 12), 
                PaddingRight = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12)
            })
            local ContainerLayout = Create("UIListLayout", {
                Parent = Container,
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            local Open = true
            SecHeader.MouseButton1Click:Connect(function()
                Open = not Open
                Container.Visible = Open
                Tween(Chevron, TweenInfo.new(0.3), { Rotation = Open and 0 or -90 })
            end)
            
            local SectionObj = {}
            
            -- [ TOGGLE ] --
            function SectionObj:CreateToggle(options)
                local Name = options.Name or "Toggle"
                local Default = options.Default or false
                local Callback = options.Callback or function() end
                
                local ToggleBtn = Create("TextButton", {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    Text = "",
                    AutoButtonColor = false
                })
                
                local Label = Create("TextLabel", {
                    Parent = ToggleBtn,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Neon.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local SwitchBase = Create("Frame", {
                    Parent = ToggleBtn,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(40, 20),
                    BackgroundColor3 = Neon.Theme.Item
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchBase })
                Create("UIStroke", { Parent = SwitchBase, Color = Neon.Theme.Border, Thickness = 1 })
                
                local SwitchCircle = Create("Frame", {
                    Parent = SwitchBase,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 2, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16),
                    BackgroundColor3 = Neon.Theme.Text
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchCircle })
                
                local Toggled = Default
                
                local function Update()
                    local targetColor = Toggled and Neon.Theme.Accent or Neon.Theme.Item
                    local targetPos = Toggled and UDim2.new(0, 22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                    
                    Tween(SwitchBase, TweenInfo.new(0.2), { BackgroundColor3 = targetColor })
                    Tween(SwitchCircle, TweenInfo.new(0.2), { Position = targetPos })
                end
                
                Update()
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Update()
                    Callback(Toggled)
                end)
                
                return {
                    Set = function(self, val)
                        Toggled = val
                        Update()
                        Callback(val)
                    end
                }
            end
            
            -- [ SLIDER ] --
            function SectionObj:CreateSlider(options)
                local Name = options.Name or "Slider"
                local Min = options.Min or 0
                local Max = options.Max or 100
                local Default = options.Default or Min
                local Callback = options.Callback or function() end
                
                local SliderFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 44)
                })
                
                local Label = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Neon.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(Default),
                    TextColor3 = Neon.Theme.Accent,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local SliderBar = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Neon.Theme.Item,
                    Position = UDim2.new(0, 0, 0, 28),
                    Size = UDim2.new(1, 0, 0, 6)
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderBar })
                
                local Fill = Create("Frame", {
                    Parent = SliderBar,
                    BackgroundColor3 = Neon.Theme.Accent,
                    Size = UDim2.new(0, 0, 1, 0)
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })
                
                local Knob = Create("Frame", {
                    Parent = SliderBar,
                    BackgroundColor3 = Color3.new(1,1,1),
                    Size = UDim2.fromOffset(12, 12),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0, 0, 0.5, 0)
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })
                
                local Trigger = Create("TextButton", {
                    Parent = SliderBar,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                local Value = Default
                
                local function Set(val)
                    Value = math.clamp(val, Min, Max)
                    local percent = (Value - Min) / (Max - Min)
                    
                    Tween(Fill, TweenInfo.new(0.1), { Size = UDim2.new(percent, 0, 1, 0) })
                    Tween(Knob, TweenInfo.new(0.1), { Position = UDim2.new(percent, 0, 0.5, 0) })
                    ValueLabel.Text = tostring(math.floor(Value * 100)/100) -- Clean format
                    Callback(Value)
                end
                
                Set(Default)
                
                local dragging = false
                
                Trigger.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        
                        local sizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                        Set(Min + ((Max - Min) * sizeX))
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local sizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                        Set(Min + ((Max - Min) * sizeX))
                    end
                end)
                
                return {
                    Set = function(self, val) Set(val) end
                }
            end
            
            -- [ BUTTON ] --
            function SectionObj:CreateButton(options)
                local Name = options.Name or "Button"
                local Callback = options.Callback or function() end
                
                local BtnFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32)
                })
                
                local Btn = Create("TextButton", {
                    Parent = BtnFrame,
                    BackgroundColor3 = Neon.Theme.Item,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Neon.Theme.Text,
                    TextSize = 13,
                    AutoButtonColor = false
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Btn })
                Create("UIStroke", { Parent = Btn, Color = Neon.Theme.Border, Thickness = 1 })
                
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, TweenInfo.new(0.1), { BackgroundColor3 = Neon.Theme.AccentDark })
                    task.wait(0.1)
                    Tween(Btn, TweenInfo.new(0.1), { BackgroundColor3 = Neon.Theme.Item })
                    Callback()
                end)
            end
            
            -- [ DROPDOWN ] --
            function SectionObj:CreateDropdown(options)
                local Name = options.Name or "Dropdown"
                local Options = options.Options or {}
                local Default = options.Default or Options[1]
                local Callback = options.Callback or function() end
                
                local Frame = Create("Frame", {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 46), -- Header only height
                    ClipsDescendants = true
                })
                
                local Label = Create("TextLabel", {
                    Parent = Frame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Neon.Theme.TextDim,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Trigger = Create("TextButton", {
                    Parent = Frame,
                    BackgroundColor3 = Neon.Theme.Item,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.Gotham,
                    Text = "   " .. tostring(Default),
                    TextColor3 = Neon.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Trigger })
                Create("UIStroke", { Parent = Trigger, Color = Neon.Theme.Border, Thickness = 1 })
                
                local Arrow = Create("ImageLabel", {
                    Parent = Trigger,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -24, 0.5, -6),
                    Size = UDim2.fromOffset(12, 12),
                    Image = Neon.Icons.Down,
                    ImageColor3 = Neon.Theme.TextDim
                })
                
                local OptionList = Create("Frame", {
                    Parent = Frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 50),
                    Size = UDim2.new(1, 0, 0, 0)
                })
                local ListLayout = Create("UIListLayout", { Parent = OptionList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })
                
                local isOpen = false
                
                local function RenderOptions()
                    for _, child in pairs(OptionList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    
                    for _, opt in pairs(Options) do
                        local OptBtn = Create("TextButton", {
                            Parent = OptionList,
                            BackgroundColor3 = Neon.Theme.BackgroundDark,
                            Size = UDim2.new(1, 0, 0, 24),
                            Font = Enum.Font.Gotham,
                            Text = "   " .. tostring(opt),
                            TextColor3 = Neon.Theme.TextDim,
                            TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false
                        })
                        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = OptBtn })
                        
                        OptBtn.MouseButton1Click:Connect(function()
                            Trigger.Text = "   " .. tostring(opt)
                            Callback(opt)
                            isOpen = false
                            Tween(Frame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 46) })
                            Tween(Arrow, TweenInfo.new(0.2), { Rotation = 0 })
                        end)
                    end
                end
                
                RenderOptions()
                
                Trigger.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    local targetH = isOpen and (46 + 4 + (#Options * 28)) or 46
                    Tween(Frame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, targetH) })
                    Tween(Arrow, TweenInfo.new(0.2), { Rotation = isOpen and 180 or 0 })
                end)
            end

            -- [ COLOR PICKER ] --
            function SectionObj:CreateColorPicker(options)
                local Name = options.Name or "Color Picker"
                local Default = options.Default or Color3.fromRGB(255, 255, 255)
                local Callback = options.Callback or function() end

                local Frame = Create("Frame", {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28)
                })

                local Label = Create("TextLabel", {
                    Parent = Frame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Neon.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Preview = Create("TextButton", {
                    Parent = Frame,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(40, 20),
                    BackgroundColor3 = Default,
                    Text = ""
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Preview })
                Create("UIStroke", { Parent = Preview, Color = Neon.Theme.Border, Thickness = 1 })

                Preview.MouseButton1Click:Connect(function()
                    local r = math.random()
                    local g = math.random()
                    local b = math.random()
                    local newColor = Color3.new(r, g, b)
                    Tween(Preview, TweenInfo.new(0.2), { BackgroundColor3 = newColor })
                    Callback(newColor)
                end)
            end

            -- [ TEXT INPUT ] --
             function SectionObj:CreateInput(options)
                local Name = options.Name or "Input"
                local Placeholder = options.Placeholder or "Type here..."
                local Callback = options.Callback or function() end
                
                local Frame = Create("Frame", {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50)
                })
                
                local Label = Create("TextLabel", {
                    Parent = Frame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Neon.Theme.TextDim,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local InputBox = Create("TextBox", {
                    Parent = Frame,
                    BackgroundColor3 = Neon.Theme.Item,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    PlaceholderText = Placeholder,
                    PlaceholderColor3 = Neon.Theme.TextDim,
                    TextColor3 = Neon.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = InputBox })
                Create("UIStroke", { Parent = InputBox, Color = Neon.Theme.Border, Thickness = 1 })
                Create("UIPadding", { Parent = InputBox, PaddingLeft = UDim.new(0, 10) })
                
                InputBox.FocusLost:Connect(function(enter)
                    Callback(InputBox.Text)
                end)
            end

            return SectionObj
        end
        
        return TabObj
    end
    
    return Library
end

return Neon
