--[[
    Home
    Module list scene with staggered fade-in animation
]]

local Theme = require(script.Parent.Theme)
local Icons = require(script.Parent.Icons)

local Home = {}
Home.__index = Home

function Home.new(interface)
    local self = setmetatable({}, Home)

    self.interface = interface
    self.modules = {}

    self:_build()

    return self
end

function Home:_build()
    local root = self.interface.root

    -- Container
    local container = Instance.new("Frame")
    container.Name = "Home"
    container.Size = UDim2.new(0, 288, 0, 400)
    container.Position = UDim2.new(0.5, 0, 0.5, -90)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = root
    self.container = container

    -- Layout
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 0)
    layout.Parent = container
    self.layout = layout
end

function Home:addModule(config)
    local moduleRow = self:_createModuleRow(config, #self.modules + 1)
    table.insert(self.modules, {
        config = config,
        frame = moduleRow
    })
end

function Home:_createModuleRow(config, index)
    local row = Instance.new("TextButton")
    row.Name = "Module_" .. config.id
    row.Size = UDim2.new(1, 0, 0, 59)
    row.BackgroundColor3 = Theme.colors.background
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.AutoButtonColor = false
    row.Text = ""
    row.LayoutOrder = index
    row.Parent = self.container

    -- Hover background gradient
    local hoverBg = Instance.new("Frame")
    hoverBg.Name = "HoverBg"
    hoverBg.Size = UDim2.new(1, 0, 1, -10)
    hoverBg.Position = UDim2.new(0, 0, 0, 5)
    hoverBg.BackgroundColor3 = Theme.colors.accent
    hoverBg.BackgroundTransparency = 0.95
    hoverBg.BorderSizePixel = 0
    hoverBg.Visible = false
    hoverBg.Parent = row

    local hoverRadius = Instance.new("UICorner")
    hoverRadius.CornerRadius = UDim.new(0, 3)
    hoverRadius.Parent = hoverBg

    -- Left indicator bar
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 2, 0, 16)
    indicator.Position = UDim2.new(0, 0, 0.5, -8)
    indicator.BackgroundColor3 = self.interface.config.accent
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1
    indicator.Parent = row

    local indicatorRadius = Instance.new("UICorner")
    indicatorRadius.CornerRadius = UDim.new(0, 2)
    indicatorRadius.Parent = indicator

    -- Content frame
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -26, 1, 0)
    content.Position = UDim2.new(0, 13, 0, 0)
    content.BackgroundTransparency = 1
    content.Parent = row

    -- Icon
    local iconSymbol = Icons.getSymbol(config.icon or "grid")
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 17, 0, 17)
    icon.Position = UDim2.new(0, 0, 0.5, -8.5)
    icon.BackgroundTransparency = 1
    icon.Text = iconSymbol
    icon.TextColor3 = Theme.colors.accentDim
    icon.TextSize = Theme.typography.size.lg
    icon.Font = Theme.typography.font
    icon.Parent = content

    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 34, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.label
    label.TextColor3 = Theme.colors.text
    label.TextSize = Theme.typography.size.title
    label.Font = Theme.typography.font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content

    -- Number
    local number = Instance.new("TextLabel")
    number.Name = "Number"
    number.Size = UDim2.new(0, 40, 1, 0)
    number.Position = UDim2.new(1, -40, 0, 0)
    number.BackgroundTransparency = 1
    number.Text = string.format("%02d", index)
    number.TextColor3 = Theme.colors.textMuted
    number.TextSize = Theme.typography.size.sm
    number.Font = Theme.typography.font
    number.TextXAlignment = Enum.TextXAlignment.Right
    number.Parent = content

    -- Hover interaction
    row.MouseEnter:Connect(function()
        hoverBg.Visible = true
        self:_tweenProperty(hoverBg, "BackgroundTransparency", 0.85, 0.22)

        -- Indicator scale animation
        indicator.Visible = true
        local scaleTween = game:GetService("TweenService"):Create(
            indicator,
            TweenInfo.new(0.25 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {
                BackgroundTransparency = 0,
                Size = UDim2.new(0, 2, 0, 16)
            }
        )
        scaleTween:Play()

        -- Icon shift
        local iconShift = game:GetService("TweenService"):Create(
            icon,
            TweenInfo.new(0.3 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, 2, 0.5, -8.5)}
        )
        iconShift:Play()

        self:_tweenProperty(icon, "TextColor3", self.interface.config.accent, 0.2)
        self:_tweenProperty(label, "TextColor3", Theme.colors.white, 0.2)
        self:_tweenProperty(number, "TextColor3", Theme.blend(Theme.colors.accent, Theme.colors.white, 0.7), 0.2)
    end)

    row.MouseLeave:Connect(function()
        self:_tweenProperty(hoverBg, "BackgroundTransparency", 1, 0.22)
        task.wait(0.22 * self.interface.config.speed)
        hoverBg.Visible = false

        -- Indicator shrink
        local scaleTween = game:GetService("TweenService"):Create(
            indicator,
            TweenInfo.new(0.25 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 2, 0, 4)
            }
        )
        scaleTween:Play()
        scaleTween.Completed:Connect(function()
            indicator.Visible = false
            indicator.Size = UDim2.new(0, 2, 0, 16)
        end)

        -- Icon shift back
        local iconShift = game:GetService("TweenService"):Create(
            icon,
            TweenInfo.new(0.2 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, 0, 0.5, -8.5)}
        )
        iconShift:Play()

        self:_tweenProperty(icon, "TextColor3", Theme.colors.accentDim, 0.2)
        self:_tweenProperty(label, "TextColor3", Theme.colors.text, 0.2)
        self:_tweenProperty(number, "TextColor3", Theme.colors.textMuted, 0.2)
    end)

    -- Click handler with feedback
    row.MouseButton1Click:Connect(function()
        -- Click scale feedback
        local clickTween = game:GetService("TweenService"):Create(
            row,
            TweenInfo.new(0.08 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {Size = UDim2.new(1, 0, 0, 57)}
        )
        clickTween:Play()

        clickTween.Completed:Connect(function()
            local restoreTween = game:GetService("TweenService"):Create(
                row,
                TweenInfo.new(0.12 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Size = UDim2.new(1, 0, 0, 59)}
            )
            restoreTween:Play()
        end)

        self.interface:openModule(config.id)
    end)

    return row
end

function Home:show()
    self.container.Visible = true

    -- Staggered fade-in animation
    for i, module in ipairs(self.modules) do
        local frame = module.frame
        frame.BackgroundTransparency = 1
        frame.Position = UDim2.new(0, 0, 0, -8)

        local delay = (i - 1) * 0.048 * self.interface.config.speed

        task.delay(delay, function()
            self:_tweenProperty(frame, "BackgroundTransparency", 0, 0.32)
            local tween = game:GetService("TweenService"):Create(
                frame,
                TweenInfo.new(0.32 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, 0, 0, 0)}
            )
            tween:Play()
        end)
    end
end

function Home:hide()
    self:_tweenProperty(self.container, "BackgroundTransparency", 1, 0.18)
    task.wait(0.18 * self.interface.config.speed)
    self.container.Visible = false
end

function Home:_tweenProperty(instance, property, value, duration)
    local tweenInfo = TweenInfo.new(
        duration * self.interface.config.speed,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, {[property] = value})
    tween:Play()
    return tween
end

return Home
