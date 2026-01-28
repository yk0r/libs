--[[
    ███████╗███████╗██████╗     ██╗     ██╗██████╗ ██████╗  █████╗ ██████╗ ██╗   ██╗
    ██╔════╝██╔════╝██╔══██╗    ██║     ██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝
    █████╗  ███████╗██████╔╝    ██║     ██║██████╔╝██████╔╝███████║██████╔╝ ╚████╔╝ 
    ██╔══╝  ╚════██║██╔═══╝     ██║     ██║██╔══██╗██╔══██╗██╔══██║██╔══██╗  ╚██╔╝  
    ███████╗███████║██║         ███████╗██║██████╔╝██║  ██║██║  ██║██║  ██║   ██║   
    ╚══════╝╚══════╝╚═╝         ╚══════╝╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   
    
    ESP Library v1.0
    仅供学习研究使用
    
    使用方法:
    local ESP = loadstring(game:HttpGet("你的链接"))()
    
    -- 添加玩家 ESP
    ESP:AddPlayer(player)
    
    -- 移除玩家 ESP
    ESP:RemovePlayer(player)
    
    -- 修改设置
    ESP.Settings.Box.Enabled = false
    ESP.Settings.Skeleton.Enabled = true
    
    -- 销毁整个 ESP 系统
    ESP:Destroy()
]]

local ESP = {}
ESP.__index = ESP

--// 服务 //--
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// 唯一标识符 //--
local LIBRARY_ID = "ESP_LIBRARY_" .. tostring(math.random(100000, 999999))

--// 清理旧实例 //--
if getgenv().ESP_LIBRARY_INSTANCE then
    pcall(function()
        getgenv().ESP_LIBRARY_INSTANCE:Destroy()
    end)
end

--// 默认设置 //--
ESP.Settings = {
    -- 主开关
    Enabled = true,
    
    -- 团队检测
    TeamCheck = false,           -- 是否检测队友
    TeamColor = false,           -- 使用队伍颜色
    
    -- 显示范围
    MaxDistance = 2500,          -- 最大显示距离
    
    -- LOD 系统
    LOD = {
        Enabled = true,
        Distance = 150           -- 超过此距离简化显示
    },
    
    -- 文字设置
    Text = {
        Size = 13,
        Font = 2,                -- 0=UI, 1=System, 2=Plex, 3=Monospace
        Outline = true
    },
    
    -- 方框
    Box = {
        Enabled = true,
        Type = "Full",           -- "Full" 或 "Corner"
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Fill = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0.75
        }
    },
    
    -- 骨架
    Skeleton = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1
    },
    
    -- 头部圆点
    HeadDot = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Radius = 3,
        Filled = true,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0)
    },
    
    -- 视线追踪
    Tracer = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Origin = "Bottom"        -- "Bottom", "Center", "Mouse"
    },
    
    -- 视线方向
    LookDirection = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Length = 6
    },
    
    -- 名称
    Name = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        ShowDisplayName = true   -- true=DisplayName, false=Username
    },
    
    -- 血量
    Health = {
        Enabled = true,
        Position = "Left",       -- "Left" 或 "Right"
        LowColor = Color3.fromRGB(255, 0, 0),
        HighColor = Color3.fromRGB(0, 255, 0),
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Text = {
            Enabled = true,
            Color = Color3.fromRGB(255, 255, 255)
        }
    },
    
    -- 距离
    Distance = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255)
    },
    
    -- 武器/工具
    Weapon = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255)
    },
    
    -- Chams (透视高亮)
    Chams = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 255),
        Transparency = 0.5
    }
}

--// 内部变量 //--
local Objects = {}          -- 存储所有玩家的 ESP 对象
local Connections = {}      -- 存储事件连接
local Cache = {}            -- 缓存所有创建的对象
local RenderConnection      -- 渲染循环连接

--// 工具函数 //--

-- 创建 Drawing 对象
local function NewDrawing(Type, Properties)
    local Drawing_Object = Drawing.new(Type)
    for Key, Value in pairs(Properties or {}) do
        Drawing_Object[Key] = Value
    end
    table.insert(Cache, Drawing_Object)
    return Drawing_Object
end

-- 追踪实例对象
local function Track(Instance_Object)
    table.insert(Cache, Instance_Object)
    return Instance_Object
end

-- 世界坐标转屏幕坐标
local function WorldToScreen(Position)
    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Position)
    return Vector2.new(ScreenPos.X, ScreenPos.Y), OnScreen, ScreenPos.Z
end

-- 检查是否为队友
local function IsTeammate(Player)
    if not ESP.Settings.TeamCheck then
        return false
    end
    if LocalPlayer.Team and Player.Team then
        return LocalPlayer.Team == Player.Team
    end
    return false
end

-- 获取玩家颜色
local function GetPlayerColor(Player)
    if ESP.Settings.TeamColor and Player.Team then
        return Player.TeamColor.Color
    end
    return nil
end

--// ESP 对象类 //--
local ESPObject = {}
ESPObject.__index = ESPObject

function ESPObject.new(Player)
    local self = setmetatable({}, ESPObject)
    
    self.Player = Player
    self.Character = nil
    self.Humanoid = nil
    self.RootPart = nil
    self.Head = nil
    
    -- 速度追踪
    self.LastPosition = nil
    self.LastTick = 0
    self.Velocity = Vector3.new()
    
    -- 创建绘图对象
    self.Drawings = {}
    self.Chams = {}
    
    -- 方框
    self.Drawings.BoxOutline = NewDrawing("Square", {
        Visible = false,
        Thickness = 3,
        Color = ESP.Settings.Box.OutlineColor,
        Filled = false
    })
    
    self.Drawings.Box = NewDrawing("Square", {
        Visible = false,
        Thickness = ESP.Settings.Box.Thickness,
        Color = ESP.Settings.Box.Color,
        Filled = false
    })
    
    self.Drawings.BoxFill = NewDrawing("Square", {
        Visible = false,
        Filled = true,
        Transparency = ESP.Settings.Box.Fill.Transparency
    })
    
    -- 角框 (8条线)
    for i = 1, 8 do
        self.Drawings["Corner" .. i] = NewDrawing("Line", {
            Visible = false,
            Thickness = ESP.Settings.Box.Thickness,
            Color = ESP.Settings.Box.Color
        })
        self.Drawings["CornerOutline" .. i] = NewDrawing("Line", {
            Visible = false,
            Thickness = ESP.Settings.Box.Thickness + 2,
            Color = ESP.Settings.Box.OutlineColor
        })
    end
    
    -- 血量条
    self.Drawings.HealthOutline = NewDrawing("Square", {
        Visible = false,
        Filled = true,
        Color = ESP.Settings.Health.OutlineColor
    })
    
    self.Drawings.HealthBar = NewDrawing("Square", {
        Visible = false,
        Filled = true
    })
    
    self.Drawings.HealthText = NewDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = ESP.Settings.Text.Outline,
        Font = ESP.Settings.Text.Font,
        Size = ESP.Settings.Text.Size
    })
    
    -- 名称
    self.Drawings.Name = NewDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = ESP.Settings.Text.Outline,
        Font = ESP.Settings.Text.Font,
        Size = ESP.Settings.Text.Size
    })
    
    -- 距离
    self.Drawings.Distance = NewDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = ESP.Settings.Text.Outline,
        Font = ESP.Settings.Text.Font,
        Size = ESP.Settings.Text.Size
    })
    
    -- 武器
    self.Drawings.Weapon = NewDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = ESP.Settings.Text.Outline,
        Font = ESP.Settings.Text.Font,
        Size = ESP.Settings.Text.Size
    })
    
    -- 骨架 (5条线)
    for i = 1, 5 do
        self.Drawings["Skeleton" .. i] = NewDrawing("Line", {
            Visible = false,
            Thickness = ESP.Settings.Skeleton.Thickness
        })
    end
    
    -- 头部圆点
    self.Drawings.HeadDotOutline = NewDrawing("Circle", {
        Visible = false,
        Filled = true,
        Color = ESP.Settings.HeadDot.OutlineColor,
        Radius = ESP.Settings.HeadDot.Radius + 1
    })
    
    self.Drawings.HeadDot = NewDrawing("Circle", {
        Visible = false,
        Filled = ESP.Settings.HeadDot.Filled,
        Radius = ESP.Settings.HeadDot.Radius
    })
    
    -- 视线方向
    self.Drawings.LookDirection = NewDrawing("Line", {
        Visible = false,
        Thickness = ESP.Settings.LookDirection.Thickness
    })
    
    -- 追踪线
    self.Drawings.Tracer = NewDrawing("Line", {
        Visible = false,
        Thickness = ESP.Settings.Tracer.Thickness
    })
    
    return self
end

-- 隐藏所有绘图
function ESPObject:Hide()
    for _, Drawing in pairs(self.Drawings) do
        Drawing.Visible = false
    end
    for _, Cham in pairs(self.Chams) do
        Cham.Visible = false
    end
end

-- 销毁 ESP 对象
function ESPObject:Destroy()
    for _, Drawing in pairs(self.Drawings) do
        Drawing:Remove()
    end
    for _, Cham in pairs(self.Chams) do
        Cham:Destroy()
    end
    self.Drawings = {}
    self.Chams = {}
end

-- 绘制角框
function ESPObject:DrawCornerBox(BoxPos, BoxSize, Color)
    local X, Y = BoxPos.X, BoxPos.Y
    local W, H = BoxSize.X, BoxSize.Y
    local LineLength = math.floor(W / 3)
    
    local Corners = {
        -- 左上角
        {self.Drawings.Corner1, X, Y, X + LineLength, Y},
        {self.Drawings.Corner2, X, Y, X, Y + LineLength},
        -- 右上角
        {self.Drawings.Corner3, X + W - LineLength, Y, X + W, Y},
        {self.Drawings.Corner4, X + W, Y, X + W, Y + LineLength},
        -- 左下角
        {self.Drawings.Corner5, X, Y + H - LineLength, X, Y + H},
        {self.Drawings.Corner6, X, Y + H, X + LineLength, Y + H},
        -- 右下角
        {self.Drawings.Corner7, X + W, Y + H - LineLength, X + W, Y + H},
        {self.Drawings.Corner8, X + W - LineLength, Y + H, X + W, Y + H}
    }
    
    for i, Data in ipairs(Corners) do
        local Line = Data[1]
        local OutlineLine = self.Drawings["CornerOutline" .. i]
        
        Line.Visible = true
        Line.Color = Color
        Line.From = Vector2.new(Data[2], Data[3])
        Line.To = Vector2.new(Data[4], Data[5])
        
        if ESP.Settings.Box.Outline then
            OutlineLine.Visible = true
            OutlineLine.Color = ESP.Settings.Box.OutlineColor
            OutlineLine.From = Line.From
            OutlineLine.To = Line.To
        else
            OutlineLine.Visible = false
        end
    end
end

-- 绘制骨架
function ESPObject:DrawSkeleton(Character, Color)
    local Head = Character:FindFirstChild("Head")
    local Torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
    local LeftArm = Character:FindFirstChild("LeftUpperArm") or Character:FindFirstChild("Left Arm")
    local RightArm = Character:FindFirstChild("RightUpperArm") or Character:FindFirstChild("Right Arm")
    local LeftLeg = Character:FindFirstChild("LeftUpperLeg") or Character:FindFirstChild("Left Leg")
    local RightLeg = Character:FindFirstChild("RightUpperLeg") or Character:FindFirstChild("Right Leg")
    
    local function GetScreenPos(Part)
        if not Part then return nil, false end
        local Pos, OnScreen = WorldToScreen(Part.Position)
        return Pos, OnScreen
    end
    
    local function DrawBone(Line, Part1, Part2)
        local P1, V1 = GetScreenPos(Part1)
        local P2, V2 = GetScreenPos(Part2)
        
        if P1 and P2 and V1 and V2 then
            Line.Visible = true
            Line.Color = Color
            Line.From = P1
            Line.To = P2
        else
            Line.Visible = false
        end
    end
    
    DrawBone(self.Drawings.Skeleton1, Head, Torso)
    DrawBone(self.Drawings.Skeleton2, Torso, LeftArm)
    DrawBone(self.Drawings.Skeleton3, Torso, RightArm)
    DrawBone(self.Drawings.Skeleton4, Torso, LeftLeg)
    DrawBone(self.Drawings.Skeleton5, Torso, RightLeg)
end

-- 更新 Chams
function ESPObject:UpdateChams(Character, Color)
    if not ESP.Settings.Chams.Enabled then
        for Part, Cham in pairs(self.Chams) do
            Cham:Destroy()
        end
        self.Chams = {}
        return
    end
    
    for _, Part in pairs(Character:GetChildren()) do
        if Part:IsA("BasePart") and Part.Name ~= "HumanoidRootPart" and Part.Transparency < 1 then
            if not self.Chams[Part] then
                local Cham = Instance.new("BoxHandleAdornment")
                Cham.Name = "ESP_Cham"
                Cham.Adornee = Part
                Cham.AlwaysOnTop = true
                Cham.ZIndex = 5
                Cham.Size = Part.Size + Vector3.new(0.05, 0.05, 0.05)
                Cham.Transparency = ESP.Settings.Chams.Transparency
                Cham.Color3 = Color
                Cham.Parent = Part
                
                Track(Cham)
                self.Chams[Part] = Cham
            else
                self.Chams[Part].Color3 = Color
                self.Chams[Part].Transparency = ESP.Settings.Chams.Transparency
                self.Chams[Part].Visible = true
            end
        end
    end
end

-- 主更新函数
function ESPObject:Update()
    -- 验证角色
    local Character = self.Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local Head = Character and Character:FindFirstChild("Head")
    
    -- 角色无效时隐藏
    if not (Character and Humanoid and RootPart and Head and Humanoid.Health > 0) then
        self:Hide()
        return
    end
    
    -- 队友检测
    if IsTeammate(self.Player) then
        self:Hide()
        return
    end
    
    -- 更新引用
    self.Character = Character
    self.Humanoid = Humanoid
    self.RootPart = RootPart
    self.Head = Head
    
    -- 计算速度
    local CurrentTick = tick()
    if self.LastPosition then
        local DeltaTime = CurrentTick - self.LastTick
        if DeltaTime > 0 then
            self.Velocity = (RootPart.Position - self.LastPosition) / DeltaTime
        end
    end
    self.LastPosition = RootPart.Position
    self.LastTick = CurrentTick
    
    -- 屏幕位置和距离
    local ScreenPos, OnScreen, Depth = WorldToScreen(RootPart.Position)
    local Distance = (Camera.CFrame.Position - RootPart.Position).Magnitude
    
    -- 距离检测
    if Distance > ESP.Settings.MaxDistance then
        self:Hide()
        return
    end
    
    -- 不在屏幕内
    if not OnScreen then
        -- 只显示追踪线
        if ESP.Settings.Tracer.Enabled then
            local TracerColor = GetPlayerColor(self.Player) or ESP.Settings.Tracer.Color
            local EdgePos = WorldToScreen(RootPart.Position)
            
            self.Drawings.Tracer.Visible = true
            self.Drawings.Tracer.Color = TracerColor
            self.Drawings.Tracer.To = EdgePos
            
            local Origin = ESP.Settings.Tracer.Origin
            if Origin == "Bottom" then
                self.Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            elseif Origin == "Center" then
                self.Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            else -- Mouse
                self.Drawings.Tracer.From = game:GetService("UserInputService"):GetMouseLocation()
            end
        else
            self.Drawings.Tracer.Visible = false
        end
        
        -- 隐藏其他元素
        for Name, Drawing in pairs(self.Drawings) do
            if Name ~= "Tracer" then
                Drawing.Visible = false
            end
        end
        for _, Cham in pairs(self.Chams) do
            Cham.Visible = false
        end
        return
    end
    
    -- 获取颜色
    local MainColor = GetPlayerColor(self.Player) or ESP.Settings.Box.Color
    local TextColor = GetPlayerColor(self.Player) or ESP.Settings.Name.Color
    
    -- LOD 检测
    local IsHighDetail = not ESP.Settings.LOD.Enabled or Distance <= ESP.Settings.LOD.Distance
    
    -- 计算方框尺寸
    local ScaleFactor = (1 / ((Distance / 3) * math.tan(math.rad(Camera.FieldOfView / 2)) * 2)) * 1150
    local BoxWidth = math.floor(ScaleFactor * 1.3)
    local BoxHeight = math.floor(ScaleFactor * 2.1)
    local BoxPos = Vector2.new(
        math.floor(ScreenPos.X - BoxWidth / 2),
        math.floor(ScreenPos.Y - BoxHeight / 2)
    )
    local BoxSize = Vector2.new(BoxWidth, BoxHeight)
    
    --[[ ========== 绘制方框 ========== ]]--
    if ESP.Settings.Box.Enabled then
        if ESP.Settings.Box.Type == "Full" then
            -- 完整方框
            if ESP.Settings.Box.Outline then
                self.Drawings.BoxOutline.Visible = true
                self.Drawings.BoxOutline.Position = BoxPos
                self.Drawings.BoxOutline.Size = BoxSize
                self.Drawings.BoxOutline.Color = ESP.Settings.Box.OutlineColor
            else
                self.Drawings.BoxOutline.Visible = false
            end
            
            self.Drawings.Box.Visible = true
            self.Drawings.Box.Position = BoxPos
            self.Drawings.Box.Size = BoxSize
            self.Drawings.Box.Color = MainColor
            self.Drawings.Box.Thickness = ESP.Settings.Box.Thickness
            
            -- 隐藏角框
            for i = 1, 8 do
                self.Drawings["Corner" .. i].Visible = false
                self.Drawings["CornerOutline" .. i].Visible = false
            end
        else
            -- 角框
            self.Drawings.BoxOutline.Visible = false
            self.Drawings.Box.Visible = false
            self:DrawCornerBox(BoxPos, BoxSize, MainColor)
        end
        
        -- 方框填充
        if ESP.Settings.Box.Fill.Enabled then
            self.Drawings.BoxFill.Visible = true
            self.Drawings.BoxFill.Position = BoxPos
            self.Drawings.BoxFill.Size = BoxSize
            self.Drawings.BoxFill.Color = ESP.Settings.Box.Fill.Color
            self.Drawings.BoxFill.Transparency = ESP.Settings.Box.Fill.Transparency
        else
            self.Drawings.BoxFill.Visible = false
        end
    else
        self.Drawings.BoxOutline.Visible = false
        self.Drawings.Box.Visible = false
        self.Drawings.BoxFill.Visible = false
        for i = 1, 8 do
            self.Drawings["Corner" .. i].Visible = false
            self.Drawings["CornerOutline" .. i].Visible = false
        end
    end
    
    --[[ ========== 绘制名称 ========== ]]--
    if ESP.Settings.Name.Enabled then
        local DisplayText = ESP.Settings.Name.ShowDisplayName 
            and self.Player.DisplayName 
            or self.Player.Name
        
        self.Drawings.Name.Visible = true
        self.Drawings.Name.Text = DisplayText
        self.Drawings.Name.Color = TextColor
        self.Drawings.Name.Size = ESP.Settings.Text.Size
        self.Drawings.Name.Font = ESP.Settings.Text.Font
        self.Drawings.Name.Position = Vector2.new(
            math.floor(BoxPos.X + BoxWidth / 2),
            math.floor(BoxPos.Y - ESP.Settings.Text.Size - 4)
        )
    else
        self.Drawings.Name.Visible = false
    end
    
    --[[ ========== 绘制距离 ========== ]]--
    if ESP.Settings.Distance.Enabled then
        self.Drawings.Distance.Visible = true
        self.Drawings.Distance.Text = math.floor(Distance) .. "m"
        self.Drawings.Distance.Color = ESP.Settings.Distance.Color
        self.Drawings.Distance.Size = ESP.Settings.Text.Size
        self.Drawings.Distance.Font = ESP.Settings.Text.Font
        self.Drawings.Distance.Position = Vector2.new(
            math.floor(BoxPos.X + BoxWidth / 2),
            math.floor(BoxPos.Y + BoxHeight + 2)
        )
    else
        self.Drawings.Distance.Visible = false
    end
    
    --[[ ========== 绘制血量条 ========== ]]--
    if ESP.Settings.Health.Enabled then
        local HealthPercent = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
        local BarHeight = math.floor(BoxHeight * HealthPercent)
        local BarWidth = 2
        local BarOffset = 4
        
        local BarX, BarY
        if ESP.Settings.Health.Position == "Left" then
            BarX = math.floor(BoxPos.X - BarOffset - BarWidth)
        else
            BarX = math.floor(BoxPos.X + BoxWidth + BarOffset)
        end
        BarY = math.floor(BoxPos.Y + (BoxHeight - BarHeight))
        
        -- 颜色插值
        local HealthColor = ESP.Settings.Health.LowColor:Lerp(
            ESP.Settings.Health.HighColor,
            HealthPercent
        )
        
        -- 背景
        if ESP.Settings.Health.Outline then
            self.Drawings.HealthOutline.Visible = true
            self.Drawings.HealthOutline.Size = Vector2.new(BarWidth + 2, BoxHeight + 2)
            self.Drawings.HealthOutline.Position = Vector2.new(BarX - 1, math.floor(BoxPos.Y) - 1)
            self.Drawings.HealthOutline.Color = ESP.Settings.Health.OutlineColor
        else
            self.Drawings.HealthOutline.Visible = false
        end
        
        -- 血条
        self.Drawings.HealthBar.Visible = true
        self.Drawings.HealthBar.Size = Vector2.new(BarWidth, BarHeight)
        self.Drawings.HealthBar.Position = Vector2.new(BarX, BarY)
        self.Drawings.HealthBar.Color = HealthColor
        
        -- 血量文字
        if IsHighDetail and ESP.Settings.Health.Text.Enabled then
            self.Drawings.HealthText.Visible = true
            self.Drawings.HealthText.Text = math.floor(Humanoid.Health) .. "HP"
            self.Drawings.HealthText.Color = ESP.Settings.Health.Text.Color
            self.Drawings.HealthText.Size = ESP.Settings.Text.Size
            self.Drawings.HealthText.Font = ESP.Settings.Text.Font
            
            local TextX = ESP.Settings.Health.Position == "Left" 
                and BarX - 20 
                or BarX + BarWidth + 4
            
            self.Drawings.HealthText.Position = Vector2.new(
                math.floor(TextX),
                math.floor(BarY - (ESP.Settings.Text.Size / 2) + 1)
            )
        else
            self.Drawings.HealthText.Visible = false
        end
    else
        self.Drawings.HealthOutline.Visible = false
        self.Drawings.HealthBar.Visible = false
        self.Drawings.HealthText.Visible = false
    end
    
    --[[ ========== 绘制武器 ========== ]]--
    if IsHighDetail and ESP.Settings.Weapon.Enabled then
        local Tool = Character:FindFirstChildOfClass("Tool")
        if Tool then
            self.Drawings.Weapon.Visible = true
            self.Drawings.Weapon.Text = "[" .. Tool.Name .. "]"
            self.Drawings.Weapon.Color = ESP.Settings.Weapon.Color
            self.Drawings.Weapon.Size = ESP.Settings.Text.Size
            self.Drawings.Weapon.Font = ESP.Settings.Text.Font
            self.Drawings.Weapon.Position = Vector2.new(
                math.floor(BoxPos.X + BoxWidth / 2),
                math.floor(BoxPos.Y + BoxHeight + ESP.Settings.Text.Size + 4)
            )
        else
            self.Drawings.Weapon.Visible = false
        end
    else
        self.Drawings.Weapon.Visible = false
    end
    
    --[[ ========== 绘制骨架 ========== ]]--
    if IsHighDetail and ESP.Settings.Skeleton.Enabled then
        self:DrawSkeleton(Character, ESP.Settings.Skeleton.Color)
    else
        for i = 1, 5 do
            self.Drawings["Skeleton" .. i].Visible = false
        end
    end
    
    --[[ ========== 绘制头部圆点 ========== ]]--
    if ESP.Settings.HeadDot.Enabled then
        local HeadScreen, HeadVisible = WorldToScreen(Head.Position)
        if HeadVisible then
            if ESP.Settings.HeadDot.Outline then
                self.Drawings.HeadDotOutline.Visible = true
                self.Drawings.HeadDotOutline.Position = HeadScreen
                self.Drawings.HeadDotOutline.Radius = ESP.Settings.HeadDot.Radius + 1
                self.Drawings.HeadDotOutline.Color = ESP.Settings.HeadDot.OutlineColor
            else
                self.Drawings.HeadDotOutline.Visible = false
            end
            
            self.Drawings.HeadDot.Visible = true
            self.Drawings.HeadDot.Position = HeadScreen
            self.Drawings.HeadDot.Radius = ESP.Settings.HeadDot.Radius
            self.Drawings.HeadDot.Color = ESP.Settings.HeadDot.Color
            self.Drawings.HeadDot.Filled = ESP.Settings.HeadDot.Filled
        else
            self.Drawings.HeadDot.Visible = false
            self.Drawings.HeadDotOutline.Visible = false
        end
    else
        self.Drawings.HeadDot.Visible = false
        self.Drawings.HeadDotOutline.Visible = false
    end
    
    --[[ ========== 绘制视线方向 ========== ]]--
    if ESP.Settings.LookDirection.Enabled then
        local HeadScreen, HeadVisible = WorldToScreen(Head.Position)
        local LookVector = Head.CFrame.LookVector
        local EndPos = Head.Position + (LookVector * ESP.Settings.LookDirection.Length)
        local EndScreen, EndVisible = WorldToScreen(EndPos)
        
        if HeadVisible and EndVisible then
            self.Drawings.LookDirection.Visible = true
            self.Drawings.LookDirection.Color = ESP.Settings.LookDirection.Color
            self.Drawings.LookDirection.Thickness = ESP.Settings.LookDirection.Thickness
            self.Drawings.LookDirection.From = HeadScreen
            self.Drawings.LookDirection.To = EndScreen
        else
            self.Drawings.LookDirection.Visible = false
        end
    else
        self.Drawings.LookDirection.Visible = false
    end
    
    --[[ ========== 绘制追踪线 ========== ]]--
    if ESP.Settings.Tracer.Enabled then
        self.Drawings.Tracer.Visible = true
        self.Drawings.Tracer.Color = ESP.Settings.Tracer.Color
        self.Drawings.Tracer.Thickness = ESP.Settings.Tracer.Thickness
        self.Drawings.Tracer.To = Vector2.new(
            math.floor(BoxPos.X + BoxWidth / 2),
            math.floor(BoxPos.Y + BoxHeight)
        )
        
        local Origin = ESP.Settings.Tracer.Origin
        if Origin == "Bottom" then
            self.Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        elseif Origin == "Center" then
            self.Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        else -- Mouse
            self.Drawings.Tracer.From = game:GetService("UserInputService"):GetMouseLocation()
        end
    else
        self.Drawings.Tracer.Visible = false
    end
    
    --[[ ========== 更新 Chams ========== ]]--
    local ChamsColor = GetPlayerColor(self.Player) or ESP.Settings.Chams.Color
    self:UpdateChams(Character, ChamsColor)
end

--// 库主函数 //--

-- 添加玩家
function ESP:AddPlayer(Player)
    if Player == LocalPlayer then return end
    if Objects[Player] then return end
    
    Objects[Player] = ESPObject.new(Player)
    
    -- 监听角色重生
    Connections[Player] = Player.CharacterAdded:Connect(function()
        -- 角色重生时重置追踪数据
        if Objects[Player] then
            Objects[Player].LastPosition = nil
            Objects[Player].LastTick = 0
            Objects[Player].Velocity = Vector3.new()
        end
    end)
end

-- 移除玩家
function ESP:RemovePlayer(Player)
    if Objects[Player] then
        Objects[Player]:Destroy()
        Objects[Player] = nil
    end
    
    if Connections[Player] then
        Connections[Player]:Disconnect()
        Connections[Player] = nil
    end
end

-- 获取玩家 ESP 对象
function ESP:GetPlayer(Player)
    return Objects[Player]
end

-- 获取所有 ESP 对象
function ESP:GetAll()
    return Objects
end

-- 启动 ESP
function ESP:Start()
    -- 为现有玩家添加 ESP
    for _, Player in ipairs(Players:GetPlayers()) do
        self:AddPlayer(Player)
    end
    
    -- 监听新玩家加入
    Connections.PlayerAdded = Players.PlayerAdded:Connect(function(Player)
        self:AddPlayer(Player)
    end)
    
    -- 监听玩家离开
    Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(Player)
        self:RemovePlayer(Player)
    end)
    
    -- 渲染循环
    RenderConnection = RunService:BindToRenderStep(LIBRARY_ID, Enum.RenderPriority.Camera.Value + 1, function()
        if not ESP.Settings.Enabled then
            for _, ESPObj in pairs(Objects) do
                ESPObj:Hide()
            end
            return
        end
        
        for _, ESPObj in pairs(Objects) do
            ESPObj:Update()
        end
    end)
end

-- 停止 ESP (保留对象)
function ESP:Stop()
    if RenderConnection then
        RunService:UnbindFromRenderStep(LIBRARY_ID)
        RenderConnection = nil
    end
    
    for _, ESPObj in pairs(Objects) do
        ESPObj:Hide()
    end
end

-- 销毁整个 ESP 系统
function ESP:Destroy()
    -- 停止渲染
    self:Stop()
    
    -- 断开所有连接
    for _, Connection in pairs(Connections) do
        if typeof(Connection) == "RBXScriptConnection" then
            Connection:Disconnect()
        end
    end
    Connections = {}
    
    -- 销毁所有 ESP 对象
    for Player, ESPObj in pairs(Objects) do
        ESPObj:Destroy()
    end
    Objects = {}
    
    -- 清理缓存
    for _, Obj in pairs(Cache) do
        if typeof(Obj) == "Instance" then
            Obj:Destroy()
        elseif Obj.Remove then
            Obj:Remove()
        end
    end
    Cache = {}
    
    -- 清除全局引用
    getgenv().ESP_LIBRARY_INSTANCE = nil
end

--// 自动启动 //--
ESP:Start()

-- 保存全局引用
getgenv().ESP_LIBRARY_INSTANCE = ESP

--// 返回库 //--
return ESP
