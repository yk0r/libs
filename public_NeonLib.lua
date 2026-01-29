-- NEON UI LIBRARY (Standalone)
-- A modern, retained-mode UI library for Roblox
-- Styled with a dark aesthetic and indigo accents

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Neon = {}
Neon.__index = Neon

-- Utility Functions
local function MakeDraggable(topbarobject, object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		object.Position = pos
	end

	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end)
end

local function Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

-- Library Methods

function Neon:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Neon UI"
    
    local ScreenGui = Create("ScreenGui", {
        Name = "NeonUI",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Color3.fromRGB(24, 24, 27), -- Zinc 900
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(100, 100),
        Size = UDim2.fromOffset(700, 500),
        ClipsDescendants = true
    })
    
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MainFrame })
    Create("UIStroke", { 
        Parent = MainFrame, 
        Color = Color3.fromRGB(39, 39, 42), 
        Thickness = 1 
    })
    
    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(9, 9, 11), -- Zinc 950
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40)
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Header })
    
    -- Fix bottom corners of header to be square
    local HeaderCover = Create("Frame", {
        Parent = Header,
        BackgroundColor3 = Color3.fromRGB(9, 9, 11),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10)
    })

    local TitleLabel = Create("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = string.upper(title),
        TextColor3 = Color3.fromRGB(228, 228, 231),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Accent Dot
    local AccentDot = Create("Frame", {
        Parent = Header,
        BackgroundColor3 = Color3.fromRGB(99, 102, 241), -- Indigo 500
        Position = UDim2.new(0, 8, 0.5, -2),
        Size = UDim2.fromOffset(4, 4),
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = AccentDot })

    MakeDraggable(Header, MainFrame)
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40)
    })
    
    -- Sidebar
    local Sidebar = Create("ScrollingFrame", {
        Parent = ContentContainer,
        BackgroundColor3 = Color3.fromRGB(15, 15, 17),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 180, 1, 0),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Create("UIPadding", { 
        Parent = Sidebar, 
        PaddingTop = UDim.new(0, 10), 
        PaddingLeft = UDim.new(0, 10), 
        PaddingRight = UDim.new(0, 10) 
    })
    local SidebarLayout = Create("UIListLayout", {
        Parent = Sidebar,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Pages Area
    local Pages = Create("Frame", {
        Parent = ContentContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 180, 0, 0),
        Size = UDim2.new(1, -180, 1, 0),
        ClipsDescendants = true
    })
    
    local WindowObj = {}
    local Tabs = {}
    local FirstTab = true
    
    function WindowObj:CreateTab(options)
        options = options or {}
        local tabName = options.Name or "Tab"
        local tabIcon = options.Icon or "rbxassetid://0" -- Placeholder
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Parent = Sidebar,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.GothamMedium,
            Text = "       " .. tabName,
            TextColor3 = Color3.fromRGB(113, 113, 122), -- Zinc 500
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabButton })
        
        -- Active Indicator (Background Gradient)
        local Gradient = Create("UIGradient", {
            Parent = TabButton,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(79, 70, 229)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(67, 56, 202))
            }),
            Rotation = 0,
            Enabled = false
        })
        
        -- Page Frame
        local Page = Create("ScrollingFrame", {
            Name = tabName .. "_Page",
            Parent = Pages,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Color3.fromRGB(63, 63, 70),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        Create("UIPadding", { 
            Parent = Page, 
            PaddingTop = UDim.new(0, 15), 
            PaddingLeft = UDim.new(0, 15), 
            PaddingRight = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15)
        })
        Create("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        local function Activate()
            -- Deactivate all others
            for _, t in pairs(Tabs) do
                t.Button.BackgroundTransparency = 1
                t.Button.TextColor3 = Color3.fromRGB(113, 113, 122)
                t.Gradient.Enabled = false
                t.Page.Visible = false
            end
            
            -- Activate this one
            TabButton.BackgroundTransparency = 0
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            Gradient.Enabled = true
            Page.Visible = true
        end
        
        TabButton.MouseButton1Click:Connect(Activate)
        
        if FirstTab then
            FirstTab = false
            Activate()
        end
        
        table.insert(Tabs, { Button = TabButton, Page = Page, Gradient = Gradient })
        
        local TabObj = {}
        
        function TabObj:CreateSection(options)
            options = options or {}
            local sectionTitle = options.Name or "Section"
            
            local SectionFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Color3.fromRGB(24, 24, 27),
                BorderColor3 = Color3.fromRGB(39, 39, 42),
                Size = UDim2.new(1, 0, 0, 0), -- Auto scaled
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SectionFrame })
            Create("UIStroke", { Parent = SectionFrame, Color = Color3.fromRGB(39, 39, 42), Thickness = 1 })
            
            local SectionHeader = Create("TextButton", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.GothamBold,
                Text = "  " .. string.upper(sectionTitle),
                TextColor3 = Color3.fromRGB(161, 161, 170),
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Container = Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ClipsDescendants = true
            })
            Create("UIPadding", { 
                Parent = Container, 
                PaddingLeft = UDim.new(0, 10), 
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            })
            local ContainerLayout = Create("UIListLayout", {
                Parent = Container,
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            -- Collapsing Logic
            local Open = true
            SectionHeader.MouseButton1Click:Connect(function()
                Open = not Open
                Container.Visible = Open
            end)
            
            local SectionObj = {}
            
            function SectionObj:CreateToggle(options)
                options = options or {}
                local name = options.Name or "Toggle"
                local default = options.Default or false
                local callback = options.Callback or function() end
                
                local ToggleFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24)
                })
                
                local Label = Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -30, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = Color3.fromRGB(212, 212, 216),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Button = Create("TextButton", {
                    Parent = ToggleFrame,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(20, 20),
                    BackgroundColor3 = default and Color3.fromRGB(79, 70, 229) or Color3.fromRGB(39, 39, 42),
                    Text = "",
                    AutoButtonColor = false
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Button })
                
                local Check = Create("ImageLabel", {
                    Parent = Button,
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.fromOffset(14, 14),
                    Image = "rbxassetid://6031048436", -- Checkmark icon
                    ImageTransparency = default and 0 or 1
                })
                
                local toggled = default
                
                Button.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundColor3 = toggled and Color3.fromRGB(79, 70, 229) or Color3.fromRGB(39, 39, 42)
                    }):Play()
                    TweenService:Create(Check, TweenInfo.new(0.2), {
                        ImageTransparency = toggled and 0 or 1
                    }):Play()
                    callback(toggled)
                end)
            end
            
            function SectionObj:CreateSlider(options)
                options = options or {}
                local name = options.Name or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local callback = options.Callback or function() end
                
                local SliderFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32)
                })
                
                local Label = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = Color3.fromRGB(212, 212, 216),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Enum.Font.Gotham,
                    Text = tostring(default),
                    TextColor3 = Color3.fromRGB(99, 102, 241),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local SliderBar = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Color3.fromRGB(39, 39, 42),
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 6)
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderBar })
                
                local Fill = Create("Frame", {
                    Parent = SliderBar,
                    BackgroundColor3 = Color3.fromRGB(79, 70, 229),
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })
                
                local Trigger = Create("TextButton", {
                    Parent = SliderBar,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                local dragging = false
                
                local function Update(input)
                    local sizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + ((max - min) * sizeX))
                    
                    TweenService:Create(Fill, TweenInfo.new(0.1), { Size = UDim2.new(sizeX, 0, 1, 0) }):Play()
                    ValueLabel.Text = tostring(value)
                    callback(value)
                end
                
                Trigger.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        Update(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        Update(input)
                    end
                end)
            end
            
            function SectionObj:CreateButton(options)
                options = options or {}
                local name = options.Name or "Button"
                local callback = options.Callback or function() end
                
                local ButtonFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28)
                })
                
                local Btn = Create("TextButton", {
                    Parent = ButtonFrame,
                    BackgroundColor3 = Color3.fromRGB(79, 70, 229),
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Btn })
                
                Btn.MouseButton1Click:Connect(function()
                    local originalColor = Btn.BackgroundColor3
                    TweenService:Create(Btn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(67, 56, 202) }):Play()
                    task.wait(0.1)
                    TweenService:Create(Btn, TweenInfo.new(0.1), { BackgroundColor3 = originalColor }):Play()
                    callback()
                end)
            end
            
             function SectionObj:CreateDropdown(options)
                options = options or {}
                local name = options.Name or "Dropdown"
                local items = options.Options or {}
                local default = options.Default or items[1]
                local callback = options.Callback or function() end
                
                local DropdownFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32), -- closed size
                    ClipsDescendants = true
                })
                
                local ToggleBtn = Create("TextButton", {
                    Parent = DropdownFrame,
                    BackgroundColor3 = Color3.fromRGB(39, 39, 42),
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = "  " .. name .. ": " .. tostring(default),
                    TextColor3 = Color3.fromRGB(212, 212, 216),
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ToggleBtn })
                
                local ItemContainer = Create("Frame", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 34),
                    Size = UDim2.new(1, 0, 0, 0)
                })
                local Layout = Create("UIListLayout", { Parent = ItemContainer, SortOrder = Enum.SortOrder.LayoutOrder })
                
                local open = false
                local optionButtons = {}
                
                local function RefreshOptions()
                    for _, v in pairs(ItemContainer:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end
                    
                    for _, item in pairs(items) do
                        local OptBtn = Create("TextButton", {
                            Parent = ItemContainer,
                            BackgroundColor3 = Color3.fromRGB(45, 45, 48),
                            Size = UDim2.new(1, 0, 0, 24),
                            Font = Enum.Font.Gotham,
                            Text = item,
                            TextColor3 = Color3.fromRGB(161, 161, 170),
                            TextSize = 12
                        })
                        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = OptBtn })
                        
                        OptBtn.MouseButton1Click:Connect(function()
                            ToggleBtn.Text = "  " .. name .. ": " .. item
                            callback(item)
                            open = false
                            TweenService:Create(DropdownFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 32) }):Play()
                        end)
                    end
                end
                
                RefreshOptions()
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    open = not open
                    local contentSize = Layout.AbsoluteContentSize.Y
                    local targetSize = open and (contentSize + 40) or 32
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, targetSize) }):Play()
                end)
            end
            
            return SectionObj
        end
        
        return TabObj
    end
    
    return WindowObj
end

return Neon
