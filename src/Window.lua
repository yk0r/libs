--[[
    Window
    Modal window scene with header, tabs, panel, and footer
]]

local Theme = require(script.Parent.Theme)

local Window = {}
Window.__index = Window

function Window.new(interface)
    local self = setmetatable({}, Window)

    self.interface = interface
    self.currentPage = 0

    self:_build()

    return self
end

function Window:_build()
    local root = self.interface.root

    -- Container
    local container = Instance.new("Frame")
    container.Name = "Window"
    container.Size = UDim2.new(0, 580, 0, 450)
    container.Position = UDim2.new(0.5, 0, 0.5, -88)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = root
    self.container = container

    -- Shell (background with gradient and border)
    local shell = Instance.new("Frame")
    shell.Name = "Shell"
    shell.Size = UDim2.new(1, 0, 1, 0)
    shell.BackgroundColor3 = Theme.colors.surface
    shell.BorderSizePixel = 0
    shell.Parent = container

    local shellRadius = Instance.new("UICorner")
    shellRadius.CornerRadius = UDim.new(0, self.interface.config.radius)
    shellRadius.Parent = shell

    local shellBorder = Instance.new("UIStroke")
    shellBorder.Color = Theme.colors.border
    shellBorder.Thickness = 1
    shellBorder.Transparency = 0.85
    shellBorder.Parent = shell

    self.shell = shell

    -- Content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Parent = container
    self.content = content

    -- Header
    self:_buildHeader()

    -- Tabs
    self:_buildTabs()

    -- Panel
    self:_buildPanel()

    -- Footer
    self:_buildFooter()
end

function Window:_buildHeader()
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, -44, 0, 48)
    header.Position = UDim2.new(0, 22, 0, 19)
    header.BackgroundTransparency = 1
    header.Parent = self.content

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -50, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = ""
    title.TextColor3 = Theme.colors.text
    title.TextSize = Theme.typography.size.heading
    title.Font = Theme.typography.font
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    self.title = title

    -- Minimize button
    local minimize = Instance.new("TextButton")
    minimize.Name = "Minimize"
    minimize.Size = UDim2.new(0, 29, 0, 29)
    minimize.Position = UDim2.new(1, -29, 0, 0)
    minimize.BackgroundColor3 = Theme.colors.surfaceLight
    minimize.BackgroundTransparency = 0.7
    minimize.BorderSizePixel = 0
    minimize.AutoButtonColor = false
    minimize.Text = "−"
    minimize.TextColor3 = Theme.colors.text
    minimize.TextSize = 16
    minimize.Font = Theme.typography.font
    minimize.Parent = header

    local minimizeRadius = Instance.new("UICorner")
    minimizeRadius.CornerRadius = UDim.new(0, 5)
    minimizeRadius.Parent = minimize

    local minimizeBorder = Instance.new("UIStroke")
    minimizeBorder.Color = Theme.colors.border
    minimizeBorder.Thickness = 1
    minimizeBorder.Transparency = 0.9
    minimizeBorder.Parent = minimize

    -- Minimize hover
    minimize.MouseEnter:Connect(function()
        self:_tweenProperty(minimize, "BackgroundTransparency", 0.5, 0.18)
        self:_tweenProperty(minimizeBorder, "Transparency", 0.7, 0.18)
    end)

    minimize.MouseLeave:Connect(function()
        self:_tweenProperty(minimize, "BackgroundTransparency", 0.7, 0.18)
        self:_tweenProperty(minimizeBorder, "Transparency", 0.9, 0.18)
    end)

    minimize.MouseButton1Click:Connect(function()
        -- Click scale feedback
        local clickTween = game:GetService("TweenService"):Create(
            minimize,
            TweenInfo.new(0.09 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 26, 0, 26)}
        )
        clickTween:Play()

        clickTween.Completed:Connect(function()
            local restoreTween = game:GetService("TweenService"):Create(
                minimize,
                TweenInfo.new(0.15 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Size = UDim2.new(0, 29, 0, 29)}
            )
            restoreTween:Play()
        end)

        self.interface:closeModule()
    end)
end

function Window:_buildTabs()
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "Tabs"
    tabsContainer.Size = UDim2.new(1, -44, 0, 36)
    tabsContainer.Position = UDim2.new(0, 22, 0, 67)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.Parent = self.content

    -- Bottom border
    local border = Instance.new("Frame")
    border.Name = "Border"
    border.Size = UDim2.new(1, 0, 0, 1)
    border.Position = UDim2.new(0, 0, 1, 0)
    border.BackgroundColor3 = Theme.colors.border
    border.BackgroundTransparency = 0.95
    border.BorderSizePixel = 0
    border.Parent = tabsContainer

    -- Tab buttons container
    local tabs = Instance.new("Frame")
    tabs.Name = "TabButtons"
    tabs.Size = UDim2.new(1, 0, 1, -1)
    tabs.BackgroundTransparency = 1
    tabs.Parent = tabsContainer

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabs

    self.tabs = tabs
    self.tabsContainer = tabsContainer

    -- Indicator
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 10, 0, 2)
    indicator.Position = UDim2.new(0, 0, 1, -1)
    indicator.BackgroundColor3 = self.interface.config.accent
    indicator.BorderSizePixel = 0
    indicator.Parent = tabsContainer

    local indicatorRadius = Instance.new("UICorner")
    indicatorRadius.CornerRadius = UDim.new(0, 2)
    indicatorRadius.Parent = indicator

    self.indicator = indicator
end

function Window:_buildPanel()
    local panel = Instance.new("ScrollingFrame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(1, -44, 1, -150)
    panel.Position = UDim2.new(0, 22, 0, 103)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel = 0
    panel.ScrollBarThickness = 4
    panel.ScrollBarImageColor3 = Theme.colors.accent
    panel.ScrollBarImageTransparency = 0.7
    panel.CanvasSize = UDim2.new(0, 0, 0, 0)
    panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    panel.Parent = self.content

    local panelLayout = Instance.new("UIListLayout")
    panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
    panelLayout.Padding = UDim.new(0, 19)
    panelLayout.Parent = panel

    self.panel = panel
end

function Window:_buildFooter()
    local footer = Instance.new("Frame")
    footer.Name = "Footer"
    footer.Size = UDim2.new(1, -44, 0, 35)
    footer.Position = UDim2.new(0, 22, 1, -48)
    footer.BackgroundTransparency = 1
    footer.Parent = self.content

    -- Top border
    local border = Instance.new("Frame")
    border.Name = "Border"
    border.Size = UDim2.new(1, 0, 0, 1)
    border.BackgroundColor3 = Theme.colors.border
    border.BackgroundTransparency = 0.95
    border.BorderSizePixel = 0
    border.Parent = footer

    -- Left text
    local leftText = Instance.new("TextLabel")
    leftText.Name = "LeftText"
    leftText.Size = UDim2.new(0.5, 0, 1, 0)
    leftText.BackgroundTransparency = 1
    leftText.Text = "INTERFACE.LUA"
    leftText.TextColor3 = Theme.colors.textMuted
    leftText.TextSize = Theme.typography.size.xs
    leftText.Font = Theme.typography.font
    leftText.TextXAlignment = Enum.TextXAlignment.Left
    leftText.Parent = footer

    -- Right text (version)
    local rightText = Instance.new("TextLabel")
    rightText.Name = "RightText"
    rightText.Size = UDim2.new(0.5, 0, 1, 0)
    rightText.BackgroundTransparency = 1
    rightText.Text = "0.1"
    rightText.TextColor3 = Theme.colors.textMuted
    rightText.TextSize = Theme.typography.size.xs
    rightText.Font = Theme.typography.font
    rightText.TextXAlignment = Enum.TextXAlignment.Right
    rightText.Parent = footer
end

function Window:open(moduleId)
    -- Find module config
    local moduleConfig = nil
    local sourceModule = nil
    for _, mod in ipairs(self.interface.modules) do
        if mod.id == moduleId then
            moduleConfig = mod
            -- Get source frame from home
            for _, homeModule in ipairs(self.interface.home.modules) do
                if homeModule.config.id == moduleId then
                    sourceModule = homeModule.frame
                    break
                end
            end
            break
        end
    end

    if not moduleConfig or not sourceModule then return end

    -- Prepare content
    self.title.Text = moduleConfig.label
    self:_buildTabsForModule(moduleConfig)
    self.currentPage = 0
    self:_showPage(moduleConfig, 0)

    -- Make visible but hide content initially
    self.container.Visible = true
    self.content.Visible = false
    self.shell.BackgroundTransparency = 1

    -- Get positions for FLIP animation
    local sourcePos = sourceModule.AbsolutePosition
    local sourceSize = sourceModule.AbsoluteSize
    local targetPos = self.container.AbsolutePosition
    local targetSize = self.container.AbsoluteSize

    -- Calculate scale
    local scaleX = sourceSize.X / targetSize.X
    local scaleY = sourceSize.Y / targetSize.Y
    local offsetX = sourcePos.X - targetPos.X
    local offsetY = sourcePos.Y - targetPos.Y

    -- Get label for flying animation
    local sourceLabel = sourceModule:FindFirstChild("Content") and sourceModule.Content:FindFirstChild("Label")
    local ghostLabel = nil

    if sourceLabel then
        -- Create ghost label
        ghostLabel = Instance.new("TextLabel")
        ghostLabel.Name = "GhostLabel"
        ghostLabel.Size = UDim2.new(0, sourceLabel.AbsoluteSize.X, 0, sourceLabel.AbsoluteSize.Y)
        ghostLabel.Position = UDim2.new(0, sourceLabel.AbsolutePosition.X - self.interface.root.AbsolutePosition.X, 0, sourceLabel.AbsolutePosition.Y - self.interface.root.AbsolutePosition.Y)
        ghostLabel.BackgroundTransparency = 1
        ghostLabel.Text = moduleConfig.label
        ghostLabel.TextColor3 = Theme.colors.text
        ghostLabel.TextSize = Theme.typography.size.title
        ghostLabel.Font = Theme.typography.font
        ghostLabel.TextXAlignment = Enum.TextXAlignment.Left
        ghostLabel.ZIndex = 10
        ghostLabel.Parent = self.interface.root

        -- Hide source label
        sourceLabel.TextTransparency = 1
        self.title.TextTransparency = 1
    end

    -- Hide home
    self.interface.home:hide()

    -- Shell morph animation
    self.shell.Size = UDim2.new(scaleX, 0, scaleY, 0)
    self.shell.Position = UDim2.new(0, offsetX, 0, offsetY)

    local shellTween = self:_tween(self.shell, "BackgroundTransparency", 0, 0.5, 0.035)

    local morphTween = game:GetService("TweenService"):Create(
        self.shell,
        TweenInfo.new(0.5 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0)
        }
    )
    morphTween:Play()

    -- Label flying animation
    if ghostLabel then
        local targetLabelPos = self.title.AbsolutePosition
        local targetX = targetLabelPos.X - self.interface.root.AbsolutePosition.X
        local targetY = targetLabelPos.Y - self.interface.root.AbsolutePosition.Y
        local targetScale = Theme.typography.size.heading / Theme.typography.size.title

        -- Bounce up slightly first
        local bounceTween = game:GetService("TweenService"):Create(
            ghostLabel,
            TweenInfo.new(0.12 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {
                Position = UDim2.new(0, ghostLabel.Position.X.Offset - 3, 0, ghostLabel.Position.Y.Offset - 4),
                TextSize = Theme.typography.size.title * 1.22
            }
        )
        bounceTween:Play()

        task.delay(0.12 * self.interface.config.speed, function()
            local flyTween = game:GetService("TweenService"):Create(
                ghostLabel,
                TweenInfo.new(0.42 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {
                    Position = UDim2.new(0, targetX, 0, targetY),
                    TextSize = Theme.typography.size.heading
                }
            )
            flyTween:Play()
        end)
    end

    -- Show content after morph
    task.delay(0.275 * self.interface.config.speed, function()
        self.content.Visible = true
        self.content.BackgroundTransparency = 1
        self.content.Position = UDim2.new(0, 0, 0, -5)

        local contentTween = game:GetService("TweenService"):Create(
            self.content,
            TweenInfo.new(0.24 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {
                BackgroundTransparency = 0,
                Position = UDim2.new(0, 0, 0, 0)
            }
        )
        contentTween:Play()
    end)

    -- Cleanup ghost label and restore source
    task.delay(0.54 * self.interface.config.speed, function()
        if ghostLabel then
            ghostLabel:Destroy()
        end
        if sourceLabel then
            sourceLabel.TextTransparency = 0
            self.title.TextTransparency = 0
        end
    end)
end

function Window:_buildTabsForModule(moduleConfig)
    -- Clear existing tabs
    for _, child in ipairs(self.tabs:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- Create new tabs
    for i, page in ipairs(moduleConfig.pages) do
        local tab = self:_createTab(page.name, i - 1)
        tab.Parent = self.tabs
    end

    -- Position indicator on first tab
    task.wait()
    self:_updateIndicator(0, false)
end

function Window:_createTab(text, index)
    local tab = Instance.new("TextButton")
    tab.Name = "Tab_" .. index
    tab.Size = UDim2.new(0, 0, 1, 0)
    tab.AutomaticSize = Enum.AutomaticSize.X
    tab.BackgroundTransparency = 1
    tab.BorderSizePixel = 0
    tab.AutoButtonColor = false
    tab.Text = ""
    tab.LayoutOrder = index

    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = tab

    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.colors.textMuted
    label.TextSize = Theme.typography.size.md
    label.Font = Theme.typography.font
    label.Parent = tab

    -- Click handler
    tab.MouseButton1Click:Connect(function()
        self:_selectPage(index)
    end)

    -- Hover
    tab.MouseEnter:Connect(function()
        if index ~= self.currentPage then
            self:_tweenProperty(label, "TextColor3", Theme.colors.text, 0.18)
        end
    end)

    tab.MouseLeave:Connect(function()
        if index ~= self.currentPage then
            self:_tweenProperty(label, "TextColor3", Theme.colors.textMuted, 0.18)
        end
    end)

    return tab
end

function Window:_selectPage(index)
    if index == self.currentPage then return end

    -- Get old panel height before clearing
    local oldHeight = self.panel.AbsoluteSize.Y

    -- Update tab colors
    for i, tab in ipairs(self.tabs:GetChildren()) do
        if tab:IsA("TextButton") then
            local label = tab:FindFirstChild("Label")
            if label then
                local targetColor = (i - 1 == index) and Theme.colors.text or Theme.colors.textMuted
                self:_tweenProperty(label, "TextColor3", targetColor, 0.18)
            end
        end
    end

    -- Update indicator
    self:_updateIndicator(index, true)

    local oldPage = self.currentPage
    self.currentPage = index

    -- Find module and build new page content
    local moduleConfig = nil
    for _, mod in ipairs(self.interface.modules) do
        if mod.id == self.interface.current then
            moduleConfig = mod
            break
        end
    end

    if not moduleConfig then return end

    -- Clear and rebuild panel content
    for _, child in ipairs(self.panel:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    for _, section in ipairs(moduleConfig.pages[index + 1].sections or {}) do
        self:_buildSection(section)
    end

    -- Wait for layout to update
    task.wait()
    local newHeight = self.panel.AbsoluteSize.Y

    -- Get selected tab position for reveal animation
    local selectedTab = self.tabs:FindFirstChild("Tab_" .. index)
    if not selectedTab then return end

    local tabPos = selectedTab.AbsolutePosition
    local panelPos = self.panel.AbsolutePosition
    local panelSize = self.panel.AbsoluteSize

    -- Calculate clip-path style percentages
    local leftPercent = math.clamp((tabPos.X - panelPos.X) / panelSize.X * 100, 0, 100)
    local rightPercent = math.clamp((panelPos.X + panelSize.X - tabPos.X - selectedTab.AbsoluteSize.X) / panelSize.X * 100, 0, 100)

    -- Disable interactions during animation
    self.panel.Active = false

    -- Lock height and create reveal animation
    self.panel.Size = UDim2.new(1, -44, 0, oldHeight)
    self.panel.ClipsDescendants = true

    -- Initial state: hidden under tab
    self.panel.BackgroundTransparency = 0.35

    -- Keyframe animation: reveal from tab edge, then unfold downward
    local revealFrames = {}

    -- Frame 1: Start hidden at 0% from tab position
    table.insert(revealFrames, {
        time = 0,
        size = UDim2.new(1, -44, 0, oldHeight),
        transparency = 0.35
    })

    -- Frame 2: Peek out from tab (30% progress)
    local peekHeight = oldHeight + (newHeight - oldHeight) * 0.35
    table.insert(revealFrames, {
        time = 0.3,
        size = UDim2.new(1, -44, 0, peekHeight),
        transparency = 1
    })

    -- Frame 3: Fully revealed (100%)
    table.insert(revealFrames, {
        time = 1,
        size = UDim2.new(1, -44, 0, newHeight),
        transparency = 1
    })

    -- Animate through frames
    local duration = 0.43 * self.interface.config.speed
    local startTime = tick()

    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / duration, 1)

        -- Find current frame
        local frameIndex = 1
        for i = 1, #revealFrames do
            if progress >= revealFrames[i].time then
                frameIndex = i
            end
        end

        local nextIndex = math.min(frameIndex + 1, #revealFrames)
        local currentFrame = revealFrames[frameIndex]
        local nextFrame = revealFrames[nextIndex]

        if frameIndex == nextIndex then
            -- Final frame
            self.panel.Size = currentFrame.size
            self.panel.BackgroundTransparency = currentFrame.transparency
        else
            -- Interpolate between frames
            local frameProgress = (progress - currentFrame.time) / (nextFrame.time - currentFrame.time)
            local easedProgress = 1 - math.pow(1 - frameProgress, 3) -- Cubic ease out

            local interpHeight = currentFrame.size.Y.Offset + (nextFrame.size.Y.Offset - currentFrame.size.Y.Offset) * easedProgress
            local interpTransparency = currentFrame.transparency + (nextFrame.transparency - currentFrame.transparency) * easedProgress

            self.panel.Size = UDim2.new(1, -44, 0, interpHeight)
            self.panel.BackgroundTransparency = interpTransparency
        end

        if progress >= 1 then
            connection:Disconnect()
            -- Reset to auto size
            self.panel.Size = UDim2.new(1, -44, 1, -150)
            self.panel.BackgroundTransparency = 1
            self.panel.Active = true
        end
    end)
end

function Window:_updateIndicator(index, animate)
    local tab = self.tabs:FindFirstChild("Tab_" .. index)
    if not tab then return end

    local tabPos = tab.AbsolutePosition
    local tabSize = tab.AbsoluteSize
    local containerPos = self.tabsContainer.AbsolutePosition

    local targetX = tabPos.X - containerPos.X + 10
    local targetWidth = math.max(12, tabSize.X - 20)

    if animate then
        local tweenInfo = TweenInfo.new(0.25 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        local tween = game:GetService("TweenService"):Create(
            self.indicator,
            tweenInfo,
            {
                Position = UDim2.new(0, targetX, 1, -1),
                Size = UDim2.new(0, targetWidth, 0, 2)
            }
        )
        tween:Play()
    else
        self.indicator.Position = UDim2.new(0, targetX, 1, -1)
        self.indicator.Size = UDim2.new(0, targetWidth, 0, 2)
    end
end

function Window:_showPage(moduleConfig, pageIndex)
    -- Clear panel
    for _, child in ipairs(self.panel:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    -- Build page content (placeholder for now)
    local page = moduleConfig.pages[pageIndex + 1]
    if not page then return end

    for _, section in ipairs(page.sections or {}) do
        self:_buildSection(section)
    end
end

function Window:_buildSection(section)
    local Toggle = require(script.Parent.Controls.Toggle)
    local Slider = require(script.Parent.Controls.Slider)
    local Matrix = require(script.Parent.Controls.Matrix)

    -- Section title
    local titleFrame = Instance.new("Frame")
    titleFrame.Name = "SectionTitle"
    titleFrame.Size = UDim2.new(1, 0, 0, 20)
    titleFrame.BackgroundTransparency = 1
    titleFrame.Parent = self.panel

    -- Dot prefix
    local dot = Instance.new("Frame")
    dot.Name = "Dot"
    dot.Size = UDim2.new(0, 3, 0, 3)
    dot.Position = UDim2.new(0, 0, 0.5, -1.5)
    dot.BackgroundColor3 = Theme.blend(Theme.colors.accent, Theme.colors.textMuted, 0.5)
    dot.BackgroundTransparency = 0.4
    dot.BorderSizePixel = 0
    dot.Parent = titleFrame

    local dotRadius = Instance.new("UICorner")
    dotRadius.CornerRadius = UDim.new(1, 0)
    dotRadius.Parent = dot

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -11, 1, 0)
    titleLabel.Position = UDim2.new(0, 11, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = section.title
    titleLabel.TextColor3 = Theme.colors.textMuted
    titleLabel.TextSize = Theme.typography.size.xs
    titleLabel.Font = Theme.typography.font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleFrame

    -- Build controls
    for controlIndex, control in ipairs(section.controls or {}) do
        -- Generate path for state management
        local moduleId = self.interface.current
        local pageName = self.interface.modules[1].pages[self.currentPage + 1].name
        local controlPath = string.format("%s.%s.%s", moduleId, pageName, control.label)
        control.path = controlPath

        local controlWidget = nil

        if control.type == "toggle" then
            controlWidget = Toggle.new(self.interface, control)
        elseif control.type == "slider" then
            controlWidget = Slider.new(self.interface, control)
        elseif control.type == "matrix" then
            controlWidget = Matrix.new(self.interface, control)
        end

        if controlWidget then
            controlWidget:getContainer().Parent = self.panel
        end
    end
end

function Window:close()
    -- Find source module frame
    local sourceModule = nil
    for _, homeModule in ipairs(self.interface.home.modules) do
        if homeModule.config.id == self.interface.current then
            sourceModule = homeModule.frame
            break
        end
    end

    if not sourceModule then
        self.container.Visible = false
        return
    end

    -- Get positions for reverse FLIP
    local sourcePos = self.container.AbsolutePosition
    local sourceSize = self.container.AbsoluteSize
    local targetPos = sourceModule.AbsolutePosition
    local targetSize = sourceModule.AbsoluteSize

    local scaleX = targetSize.X / sourceSize.X
    local scaleY = targetSize.Y / sourceSize.Y
    local offsetX = targetPos.X - sourcePos.X
    local offsetY = targetPos.Y - sourcePos.Y

    -- Create ghost label
    local sourceLabel = sourceModule:FindFirstChild("Content") and sourceModule.Content:FindFirstChild("Label")
    local ghostLabel = nil

    if sourceLabel then
        ghostLabel = Instance.new("TextLabel")
        ghostLabel.Name = "GhostLabel"
        ghostLabel.Size = UDim2.new(0, self.title.AbsoluteSize.X, 0, self.title.AbsoluteSize.Y)
        ghostLabel.Position = UDim2.new(0, self.title.AbsolutePosition.X - self.interface.root.AbsolutePosition.X, 0, self.title.AbsolutePosition.Y - self.interface.root.AbsolutePosition.Y)
        ghostLabel.BackgroundTransparency = 1
        ghostLabel.Text = self.title.Text
        ghostLabel.TextColor3 = Theme.colors.text
        ghostLabel.TextSize = Theme.typography.size.heading
        ghostLabel.Font = Theme.typography.font
        ghostLabel.TextXAlignment = Enum.TextXAlignment.Left
        ghostLabel.ZIndex = 10
        ghostLabel.Parent = self.interface.root

        self.title.TextTransparency = 1
        sourceLabel.TextTransparency = 1
    end

    -- Hide content first
    local contentTween = game:GetService("TweenService"):Create(
        self.content,
        TweenInfo.new(0.14 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
        {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, -4)
        }
    )
    contentTween:Play()

    task.delay(0.14 * self.interface.config.speed, function()
        self.content.Visible = false
    end)

    -- Shell shrink animation
    task.delay(0, function()
        local shrinkTween = game:GetService("TweenService"):Create(
            self.shell,
            TweenInfo.new(0.405 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(scaleX, 0, scaleY, 0),
                Position = UDim2.new(0, offsetX, 0, offsetY)
            }
        )
        shrinkTween:Play()

        self:_tween(self.shell, "BackgroundTransparency", 1, 0.405)
    end)

    -- Label fly back
    if ghostLabel then
        local targetLabelPos = sourceLabel.AbsolutePosition
        local targetX = targetLabelPos.X - self.interface.root.AbsolutePosition.X
        local targetY = targetLabelPos.Y - self.interface.root.AbsolutePosition.Y

        local flyBackTween = game:GetService("TweenService"):Create(
            ghostLabel,
            TweenInfo.new(0.42 * self.interface.config.speed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {
                Position = UDim2.new(0, targetX, 0, targetY),
                TextSize = Theme.typography.size.title
            }
        )
        flyBackTween:Play()
    end

    -- Show home
    task.delay(0.175 * self.interface.config.speed, function()
        self.interface.home:show()
    end)

    -- Cleanup
    task.delay(0.42 * self.interface.config.speed, function()
        if ghostLabel then
            ghostLabel:Destroy()
        end
        if sourceLabel then
            sourceLabel.TextTransparency = 0
            self.title.TextTransparency = 0
        end

        self.container.Visible = false
        self.shell.Size = UDim2.new(1, 0, 1, 0)
        self.shell.Position = UDim2.new(0, 0, 0, 0)
        self.shell.BackgroundTransparency = 0
        self.content.Visible = true
        self.content.BackgroundTransparency = 0
        self.content.Position = UDim2.new(0, 0, 0, 0)
    end)
end

function Window:_tweenProperty(instance, property, value, duration)
    local tweenInfo = TweenInfo.new(
        duration * self.interface.config.speed,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, {[property] = value})
    tween:Play()
    return tween
end

return Window
