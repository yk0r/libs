--[[
    Matrix
    An expandable dropdown with 3-column grid layout and staggered animation
]]

local Theme = require(script.Parent.Parent.Theme)

local Matrix = {}
Matrix.__index = Matrix

function Matrix.new(interface, config)
    local self = setmetatable({}, Matrix)

    self.interface = interface
    self.config = config
    self.expanded = false
    self.optionButtons = {}

    -- Load saved state or use default
    local savedValue = interface:getState(config.path)
    if savedValue ~= nil and table.find(config.options, savedValue) then
        self.value = savedValue
    else
        self.value = config.default or (config.options[1] or "")
    end

    self:_build()

    return self
end

function Matrix:_build()
    -- Container
    local container = Instance.new("Frame")
    container.Name = "MatrixRow"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    self.container = container

    -- Matrix wrapper
    local matrix = Instance.new("Frame")
    matrix.Name = "Matrix"
    matrix.Size = UDim2.new(1, 0, 0, 0)
    matrix.AutomaticSize = Enum.AutomaticSize.Y
    matrix.Position = UDim2.new(0, 0, 0, 14)
    matrix.BackgroundColor3 = Theme.colors.surface
    matrix.BorderSizePixel = 0
    matrix.Parent = container

    local matrixRadius = Instance.new("UICorner")
    matrixRadius.CornerRadius = UDim.new(0, 8)
    matrixRadius.Parent = matrix

    local matrixBorder = Instance.new("UIStroke")
    matrixBorder.Color = Theme.colors.border
    matrixBorder.Thickness = 1
    matrixBorder.Transparency = 0.87
    matrixBorder.Parent = matrix

    self.matrix = matrix
    self.matrixBorder = matrixBorder

    -- Trigger button
    local trigger = Instance.new("TextButton")
    trigger.Name = "Trigger"
    trigger.Size = UDim2.new(1, 0, 0, 47)
    trigger.BackgroundTransparency = 1
    trigger.BorderSizePixel = 0
    trigger.AutoButtonColor = false
    trigger.Text = ""
    trigger.Parent = matrix

    -- Trigger content
    local triggerContent = Instance.new("Frame")
    triggerContent.Name = "Content"
    triggerContent.Size = UDim2.new(1, -24, 1, 0)
    triggerContent.Position = UDim2.new(0, 12, 0, 0)
    triggerContent.BackgroundTransparency = 1
    triggerContent.Parent = trigger

    -- Icon placeholder
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 14, 0, 14)
    icon.Position = UDim2.new(0, 0, 0.5, -7)
    icon.BackgroundTransparency = 1
    icon.Text = "▦"
    icon.TextColor3 = Theme.colors.accentDim
    icon.TextSize = 14
    icon.Font = Theme.typography.font
    icon.Parent = triggerContent

    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -160, 1, 0)
    label.Position = UDim2.new(0, 23, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = self.config.label
    label.TextColor3 = Theme.colors.text
    label.TextSize = Theme.typography.size.base
    label.Font = Theme.typography.font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = triggerContent

    -- Selected value display
    local selected = Instance.new("TextLabel")
    selected.Name = "Selected"
    selected.Size = UDim2.new(0, 113, 1, 0)
    selected.Position = UDim2.new(1, -135, 0, 0)
    selected.BackgroundTransparency = 1
    selected.Text = self.value
    selected.TextColor3 = Theme.colors.textMuted
    selected.TextSize = Theme.typography.size.sm
    selected.Font = Theme.typography.font
    selected.TextXAlignment = Enum.TextXAlignment.Right
    selected.TextTruncate = Enum.TextTruncate.AtEnd
    selected.Parent = triggerContent
    self.selectedLabel = selected

    -- Expander icon
    local expander = Instance.new("Frame")
    expander.Name = "Expander"
    expander.Size = UDim2.new(0, 22, 0, 22)
    expander.Position = UDim2.new(1, -22, 0.5, -11)
    expander.BackgroundColor3 = Theme.colors.surfaceLight
    expander.BorderSizePixel = 0
    expander.Parent = triggerContent

    local expanderRadius = Instance.new("UICorner")
    expanderRadius.CornerRadius = UDim.new(0, 5)
    expanderRadius.Parent = expander

    local expanderBorder = Instance.new("UIStroke")
    expanderBorder.Color = Theme.colors.border
    expanderBorder.Thickness = 1
    expanderBorder.Transparency = 0.88
    expanderBorder.Parent = expander

    -- Plus icon (vertical and horizontal bars)
    local plusV = Instance.new("Frame")
    plusV.Name = "PlusV"
    plusV.Size = UDim2.new(0, 1, 0, 8)
    plusV.Position = UDim2.new(0.5, -0.5, 0.5, -4)
    plusV.BackgroundColor3 = Theme.colors.text
    plusV.BorderSizePixel = 0
    plusV.Parent = expander
    self.plusV = plusV

    local plusH = Instance.new("Frame")
    plusH.Name = "PlusH"
    plusH.Size = UDim2.new(0, 8, 0, 1)
    plusH.Position = UDim2.new(0.5, -4, 0.5, -0.5)
    plusH.BackgroundColor3 = Theme.colors.text
    plusH.BorderSizePixel = 0
    plusH.Parent = expander

    self.expander = expander
    self.expanderBorder = expanderBorder

    -- Options body (collapsed initially)
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 0, 0)
    body.BackgroundTransparency = 1
    body.ClipsDescendants = true
    body.Parent = matrix
    self.body = body

    -- Options grid
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "Options"
    optionsContainer.Size = UDim2.new(1, -18, 0, 0)
    optionsContainer.Position = UDim2.new(0, 9, 0, 0)
    optionsContainer.AutomaticSize = Enum.AutomaticSize.Y
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.Parent = body

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    gridLayout.CellSize = UDim2.new(0.333, -4, 0, 40)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = optionsContainer

    self.optionsContainer = optionsContainer

    -- Build option buttons
    for i, option in ipairs(self.config.options) do
        local optionButton = self:_createOption(option, i)
        optionButton.Parent = optionsContainer
        table.insert(self.optionButtons, optionButton)
    end

    -- Bottom padding
    local bottomPadding = Instance.new("Frame")
    bottomPadding.Name = "Padding"
    bottomPadding.Size = UDim2.new(1, 0, 0, 9)
    bottomPadding.BackgroundTransparency = 1
    bottomPadding.Parent = body

    -- Click handler
    trigger.MouseButton1Click:Connect(function()
        self:toggle()
    end)

    -- Container padding
    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 17)
    padding.Parent = container
end

function Matrix:_createOption(text, index)
    local button = Instance.new("TextButton")
    button.Name = "Option_" .. index
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Theme.colors.surfaceLight
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""

    local radius = Instance.new("UICorner")
    radius.CornerRadius = UDim.new(0, 5)
    radius.Parent = button

    local border = Instance.new("UIStroke")
    border.Color = Theme.colors.border
    border.Thickness = 1
    border.Transparency = 0.88
    border.Parent = button

    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.colors.text
    label.TextSize = Theme.typography.size.md
    label.Font = Theme.typography.font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = button

    -- Check icon
    local check = Instance.new("TextLabel")
    check.Name = "Check"
    check.Size = UDim2.new(0, 12, 0, 12)
    check.Position = UDim2.new(1, -18, 0.5, -6)
    check.BackgroundTransparency = 1
    check.Text = "✓"
    check.TextColor3 = self.interface.config.accent
    check.TextSize = 12
    check.Font = Theme.typography.font
    check.TextTransparency = 1
    check.Parent = button

    -- Store references
    button:SetAttribute("OptionText", text)
    button:SetAttribute("OptionBorder", border)
    button:SetAttribute("OptionCheck", check)

    -- Update initial state
    if text == self.value then
        button.BackgroundColor3 = Theme.blend(self.interface.config.accent, Theme.colors.surface, 0.3)
        border.Color = self.interface.config.accent
        border.Transparency = 0.5
        check.TextTransparency = 0
    end

    -- Hover
    button.MouseEnter:Connect(function()
        if text ~= self.value then
            self:_tween(button, "BackgroundColor3", Theme.blend(Theme.colors.surfaceLight, Theme.colors.accent, 0.1), 0.16)
            self:_tween(border, "Transparency", 0.65, 0.16)
        end
    end)

    button.MouseLeave:Connect(function()
        if text ~= self.value then
            self:_tween(button, "BackgroundColor3", Theme.colors.surfaceLight, 0.16)
            self:_tween(border, "Transparency", 0.88, 0.16)
        end
    end)

    -- Click
    button.MouseButton1Click:Connect(function()
        -- Pulse feedback animation
        local pulseTween = game:GetService("TweenService"):Create(
            button,
            TweenInfo.new(0.085 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.975, 0, 0.975, 0)}
        )
        pulseTween:Play()

        pulseTween.Completed:Connect(function()
            local restoreTween = game:GetService("TweenService"):Create(
                button,
                TweenInfo.new(0.17 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Size = UDim2.new(1, 0, 1, 0)}
            )
            restoreTween:Play()
        end)

        self:setValue(text)
    end)

    return button
end

function Matrix:setValue(value)
    if self.value == value then return end

    -- Update all option buttons
    for _, button in ipairs(self.optionButtons) do
        local text = button:GetAttribute("OptionText")
        local border = button:FindFirstChild("UIStroke")
        local check = button:FindFirstChild("Check")

        if text == value then
            -- Selected
            self:_tween(button, "BackgroundColor3", Theme.blend(self.interface.config.accent, Theme.colors.surface, 0.3), 0.17)
            if border then
                self:_tween(border, "Color", self.interface.config.accent, 0.17)
                self:_tween(border, "Transparency", 0.5, 0.17)
            end
            if check then
                self:_tween(check, "TextTransparency", 0, 0.17)
            end
        else
            -- Unselected
            self:_tween(button, "BackgroundColor3", Theme.colors.surfaceLight, 0.16)
            if border then
                self:_tween(border, "Color", Theme.colors.border, 0.16)
                self:_tween(border, "Transparency", 0.88, 0.16)
            end
            if check then
                self:_tween(check, "TextTransparency", 1, 0.16)
            end
        end
    end

    self.value = value
    self.selectedLabel.Text = value

    -- Notify change
    if self.config.path then
        self.interface:_notifyChange(self.config.path, value)
    end
end

function Matrix:toggle()
    self.expanded = not self.expanded

    if self.expanded then
        self:_expand()
    else
        self:_collapse()
    end
end

function Matrix:_expand()
    -- Update matrix appearance
    self:_tween(self.matrix, "BackgroundColor3", Theme.blend(Theme.colors.surface, Theme.colors.accent, 0.05), 0.22)
    self:_tween(self.matrixBorder, "Transparency", 0.65, 0.22)

    -- Update expander
    self:_tween(self.expander, "BackgroundColor3", Theme.blend(Theme.colors.surfaceLight, Theme.colors.accent, 0.2), 0.22)
    self:_tween(self.expanderBorder, "Transparency", 0.67, 0.22)
    self:_tween(self.plusV, "BackgroundTransparency", 1, 0.2)

    -- Expand body
    local targetHeight = self.optionsContainer.AbsoluteSize.Y + 9

    local tweenInfo = TweenInfo.new(
        0.36 * self.interface.config.speed,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(
        self.body,
        tweenInfo,
        {Size = UDim2.new(1, 0, 0, targetHeight)}
    )
    tween:Play()

    -- Staggered option animation
    local columns = 3
    for i, button in ipairs(self.optionButtons) do
        button.BackgroundTransparency = 1
        button.Position = UDim2.new(0, 10, 0, -5)

        local row = math.floor((i - 1) / columns)
        local col = (i - 1) % columns
        local delay = (row * columns - col) * 0.022

        task.delay(delay * self.interface.config.speed, function()
            self:_tween(button, "BackgroundTransparency", 0, 0.22)

            local positionTween = game:GetService("TweenService"):Create(
                button,
                TweenInfo.new(0.22 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, 0, 0, 0)}
            )
            positionTween:Play()
        end)
    end
end

function Matrix:_collapse()
    -- Update matrix appearance
    self:_tween(self.matrix, "BackgroundColor3", Theme.colors.surface, 0.22)
    self:_tween(self.matrixBorder, "Transparency", 0.87, 0.22)

    -- Update expander
    self:_tween(self.expander, "BackgroundColor3", Theme.colors.surfaceLight, 0.22)
    self:_tween(self.expanderBorder, "Transparency", 0.88, 0.22)
    self:_tween(self.plusV, "BackgroundTransparency", 0, 0.25)

    -- Collapse body
    local tweenInfo = TweenInfo.new(
        0.27 * self.interface.config.speed,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(
        self.body,
        tweenInfo,
        {Size = UDim2.new(1, 0, 0, 0)}
    )
    tween:Play()
end

function Matrix:_tween(instance, property, value, duration)
    local tweenInfo = TweenInfo.new(
        duration * self.interface.config.speed,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, {[property] = value})
    tween:Play()
    return tween
end

function Matrix:getContainer()
    return self.container
end

return Matrix
