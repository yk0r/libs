local ESP = {}
ESP.__index = ESP

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local LIBRARY_ID = "ESP_LIBRARY_" .. tostring(math.random(100000, 999999))

if getgenv().ESP_LIBRARY_INSTANCE then
    pcall(function()
        getgenv().ESP_LIBRARY_INSTANCE:Destroy()
    end)
end

ESP.Settings = {
    Enabled = true,
    TeamCheck = false,
    TeamColor = false,
    MaxDistance = 2500,
    LOD = {
        Enabled = true,
        Distance = 150
    },
    Text = {
        Size = 13,
        Font = 2,
        Outline = true
    },
    Box = {
        Enabled = true,
        Type = "Full",
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
    Skeleton = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1
    },
    HeadDot = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Radius = 3,
        Filled = true,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0)
    },
    Tracer = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Origin = "Bottom"
    },
    LookDirection = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Length = 6
    },
    Name = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        ShowDisplayName = true
    },
    Health = {
        Enabled = true,
        Position = "Left",
        LowColor = Color3.fromRGB(255, 0, 0),
        HighColor = Color3.fromRGB(0, 255, 0),
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Text = {
            Enabled = true,
            Color = Color3.fromRGB(255, 255, 255)
        }
    },
    Distance = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255)
    },
    Weapon = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255)
    },
    Chams = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 255),
        Transparency = 0.5
    }
}

local Objects = {}
local Connections = {}
local Cache = {}
local RenderConnection

local function NewDrawing(Type, Properties)
    local Drawing_Object = Drawing.new(Type)
    for k, v in next, Properties or {} do
        Drawing_Object[k] = v
    end
    table.insert(Cache, Drawing_Object)
    return Drawing_Object
end

local function Track(Instance_Object)
    table.insert(Cache, Instance_Object)
    return Instance_Object
end

local function WorldToScreen(Position)
    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Position)
    return Vector2.new(ScreenPos.X, ScreenPos.Y), OnScreen, ScreenPos.Z
end

local function GetOffScreenPosition(WorldPosition)
    local ViewportSize = Camera.ViewportSize
    local ScreenCenter = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)
    local CameraSpace = Camera.CFrame:PointToObjectSpace(WorldPosition)
    
    if CameraSpace.Z > 0 then
        CameraSpace = Vector3.new(-CameraSpace.X, -CameraSpace.Y, CameraSpace.Z)
    end
    
    local Direction = Vector2.new(CameraSpace.X, -CameraSpace.Y).Unit
    local Padding = 50
    local MaxX = (ViewportSize.X / 2) - Padding
    local MaxY = (ViewportSize.Y / 2) - Padding
    local ScaleX = math.abs(Direction.X) > 0.001 and (MaxX / math.abs(Direction.X)) or math.huge
    local ScaleY = math.abs(Direction.Y) > 0.001 and (MaxY / math.abs(Direction.Y)) or math.huge
    local Scale = math.min(ScaleX, ScaleY)
    
    return ScreenCenter + (Direction * Scale)
end

local function IsTeammate(Player)
    if not ESP.Settings.TeamCheck then
        return false
    end
    if LocalPlayer.Team and Player.Team then
        return LocalPlayer.Team == Player.Team
    end
    return false
end

local function GetPlayerColor(Player)
    if ESP.Settings.TeamColor and Player.Team then
        return Player.TeamColor.Color
    end
    return nil
end

local ESPObject = {}
ESPObject.__index = ESPObject

function ESPObject.new(Player)
    local self = setmetatable({}, ESPObject)
    
    self.Player = Player
    self.Character = nil
    self.Humanoid = nil
    self.RootPart = nil
    self.Head = nil
    self.LastPosition = nil
    self.LastTick = 0
    self.Velocity = Vector3.new()
    self.Drawings = {}
    self.Chams = {}
    
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
    
    self.Drawings.Name = NewDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = ESP.Settings.Text.Outline,
        Font = ESP.Settings.Text.Font,
        Size = ESP.Settings.Text.Size
    })
    
    self.Drawings.Distance = NewDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = ESP.Settings.Text.Outline,
        Font = ESP.Settings.Text.Font,
        Size = ESP.Settings.Text.Size
    })
    
    self.Drawings.Weapon = NewDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = ESP.Settings.Text.Outline,
        Font = ESP.Settings.Text.Font,
        Size = ESP.Settings.Text.Size
    })
    
    for i = 1, 5 do
        self.Drawings["Skeleton" .. i] = NewDrawing("Line", {
            Visible = false,
            Thickness = ESP.Settings.Skeleton.Thickness
        })
    end
    
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
    
    self.Drawings.LookDirection = NewDrawing("Line", {
        Visible = false,
        Thickness = ESP.Settings.LookDirection.Thickness
    })
    
    self.Drawings.Tracer = NewDrawing("Line", {
        Visible = false,
        Thickness = ESP.Settings.Tracer.Thickness
    })
    
    return self
end

function ESPObject:Hide()
    for k, v in next, self.Drawings do
        v.Visible = false
    end
    for k, v in next, self.Chams do
        v.Visible = false
    end
end

function ESPObject:Destroy()
    for k, v in next, self.Drawings do
        v:Remove()
    end
    for k, v in next, self.Chams do
        v:Destroy()
    end
    self.Drawings = {}
    self.Chams = {}
end

function ESPObject:DrawCornerBox(BoxPos, BoxSize, Color)
    local X, Y = BoxPos.X, BoxPos.Y
    local W, H = BoxSize.X, BoxSize.Y
    local LineLength = math.floor(W / 3)
    
    local Corners = {
        {self.Drawings.Corner1, X, Y, X + LineLength, Y},
        {self.Drawings.Corner2, X, Y, X, Y + LineLength},
        {self.Drawings.Corner3, X + W - LineLength, Y, X + W, Y},
        {self.Drawings.Corner4, X + W, Y, X + W, Y + LineLength},
        {self.Drawings.Corner5, X, Y + H - LineLength, X, Y + H},
        {self.Drawings.Corner6, X, Y + H, X + LineLength, Y + H},
        {self.Drawings.Corner7, X + W, Y + H - LineLength, X + W, Y + H},
        {self.Drawings.Corner8, X + W - LineLength, Y + H, X + W, Y + H}
    }
    
    for i = 1, 8 do
        local Data = Corners[i]
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

function ESPObject:UpdateChams(Character, Color)
    if not ESP.Settings.Chams.Enabled then
        for k, v in next, self.Chams do
            v:Destroy()
        end
        self.Chams = {}
        return
    end
    
    for k, v in next, Character:GetChildren() do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v.Transparency < 1 then
            if not self.Chams[v] then
                local Cham = Instance.new("BoxHandleAdornment")
                Cham.Name = "ESP_Cham"
                Cham.Adornee = v
                Cham.AlwaysOnTop = true
                Cham.ZIndex = 5
                Cham.Size = v.Size + Vector3.new(0.05, 0.05, 0.05)
                Cham.Transparency = ESP.Settings.Chams.Transparency
                Cham.Color3 = Color
                Cham.Parent = v
                
                Track(Cham)
                self.Chams[v] = Cham
            else
                self.Chams[v].Color3 = Color
                self.Chams[v].Transparency = ESP.Settings.Chams.Transparency
                self.Chams[v].Visible = true
            end
        end
    end
end

function ESPObject:Update()
    local Character = self.Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local Head = Character and Character:FindFirstChild("Head")
    
    if not (Character and Humanoid and RootPart and Head and Humanoid.Health > 0) then
        self:Hide()
        return
    end
    
    if IsTeammate(self.Player) then
        self:Hide()
        return
    end
    
    self.Character = Character
    self.Humanoid = Humanoid
    self.RootPart = RootPart
    self.Head = Head
    
    local CurrentTick = tick()
    if self.LastPosition then
        local DeltaTime = CurrentTick - self.LastTick
        if DeltaTime > 0 then
            self.Velocity = (RootPart.Position - self.LastPosition) / DeltaTime
        end
    end
    self.LastPosition = RootPart.Position
    self.LastTick = CurrentTick
    
    local ScreenPos, OnScreen, Depth = WorldToScreen(RootPart.Position)
    local Distance = (Camera.CFrame.Position - RootPart.Position).Magnitude
    
    if Distance > ESP.Settings.MaxDistance then
        self:Hide()
        return
    end
    
    if not OnScreen then
        if ESP.Settings.Tracer.Enabled then
            local TracerColor = GetPlayerColor(self.Player) or ESP.Settings.Tracer.Color
            local EdgePos = GetOffScreenPosition(RootPart.Position)
            
            self.Drawings.Tracer.Visible = true
            self.Drawings.Tracer.Color = TracerColor
            self.Drawings.Tracer.Thickness = ESP.Settings.Tracer.Thickness
            self.Drawings.Tracer.To = EdgePos
            
            local Origin = ESP.Settings.Tracer.Origin
            if type(Origin) == "table" then
                Origin = Origin[1]
            end
            
            if Origin == "Bottom" then
                self.Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            elseif Origin == "Center" then
                self.Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            else
                self.Drawings.Tracer.From = UserInputService:GetMouseLocation()
            end
        else
            self.Drawings.Tracer.Visible = false
        end
        
        for k, v in next, self.Drawings do
            if k ~= "Tracer" then
                v.Visible = false
            end
        end
        for k, v in next, self.Chams do
            v.Visible = false
        end
        return
    end
    
    local MainColor = GetPlayerColor(self.Player) or ESP.Settings.Box.Color
    local TextColor = GetPlayerColor(self.Player) or ESP.Settings.Name.Color
    local IsHighDetail = not ESP.Settings.LOD.Enabled or Distance <= ESP.Settings.LOD.Distance
    
    local ScaleFactor = (1 / ((Distance / 3) * math.tan(math.rad(Camera.FieldOfView / 2)) * 2)) * 1150
    local BoxWidth = math.floor(ScaleFactor * 1.3)
    local BoxHeight = math.floor(ScaleFactor * 2.1)
    local BoxPos = Vector2.new(
        math.floor(ScreenPos.X - BoxWidth / 2),
        math.floor(ScreenPos.Y - BoxHeight / 2)
    )
    local BoxSize = Vector2.new(BoxWidth, BoxHeight)
    
    if ESP.Settings.Box.Enabled then
        local BoxType = ESP.Settings.Box.Type
        if type(BoxType) == "table" then
            BoxType = BoxType[1]
        end
        
        if BoxType == "Full" then
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
            
            for i = 1, 8 do
                self.Drawings["Corner" .. i].Visible = false
                self.Drawings["CornerOutline" .. i].Visible = false
            end
        else
            self.Drawings.BoxOutline.Visible = false
            self.Drawings.Box.Visible = false
            self:DrawCornerBox(BoxPos, BoxSize, MainColor)
        end
        
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
    
    if ESP.Settings.Name.Enabled then
        local DisplayText = ESP.Settings.Name.ShowDisplayName and self.Player.DisplayName or self.Player.Name
        
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
    
    if ESP.Settings.Health.Enabled then
        local HealthPercent = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
        local BarHeight = math.floor(BoxHeight * HealthPercent)
        local BarWidth = 2
        local BarOffset = 4
        
        local HealthPosition = ESP.Settings.Health.Position
        if type(HealthPosition) == "table" then
            HealthPosition = HealthPosition[1]
        end
        
        local BarX, BarY
        if HealthPosition == "Left" then
            BarX = math.floor(BoxPos.X - BarOffset - BarWidth)
        else
            BarX = math.floor(BoxPos.X + BoxWidth + BarOffset)
        end
        BarY = math.floor(BoxPos.Y + (BoxHeight - BarHeight))
        
        local HealthColor = ESP.Settings.Health.LowColor:Lerp(ESP.Settings.Health.HighColor, HealthPercent)
        
        if ESP.Settings.Health.Outline then
            self.Drawings.HealthOutline.Visible = true
            self.Drawings.HealthOutline.Size = Vector2.new(BarWidth + 2, BoxHeight + 2)
            self.Drawings.HealthOutline.Position = Vector2.new(BarX - 1, math.floor(BoxPos.Y) - 1)
            self.Drawings.HealthOutline.Color = ESP.Settings.Health.OutlineColor
        else
            self.Drawings.HealthOutline.Visible = false
        end
        
        self.Drawings.HealthBar.Visible = true
        self.Drawings.HealthBar.Size = Vector2.new(BarWidth, BarHeight)
        self.Drawings.HealthBar.Position = Vector2.new(BarX, BarY)
        self.Drawings.HealthBar.Color = HealthColor
        
        if IsHighDetail and ESP.Settings.Health.Text.Enabled then
            self.Drawings.HealthText.Visible = true
            self.Drawings.HealthText.Text = math.floor(Humanoid.Health) .. "HP"
            self.Drawings.HealthText.Color = ESP.Settings.Health.Text.Color
            self.Drawings.HealthText.Size = ESP.Settings.Text.Size
            self.Drawings.HealthText.Font = ESP.Settings.Text.Font
            
            local TextX = HealthPosition == "Left" and BarX - 20 or BarX + BarWidth + 4
            
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
    
    if IsHighDetail and ESP.Settings.Skeleton.Enabled then
        self:DrawSkeleton(Character, ESP.Settings.Skeleton.Color)
    else
        for i = 1, 5 do
            self.Drawings["Skeleton" .. i].Visible = false
        end
    end
    
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
    
    if ESP.Settings.Tracer.Enabled then
        self.Drawings.Tracer.Visible = true
        self.Drawings.Tracer.Color = ESP.Settings.Tracer.Color
        self.Drawings.Tracer.Thickness = ESP.Settings.Tracer.Thickness
        self.Drawings.Tracer.To = Vector2.new(
            math.floor(BoxPos.X + BoxWidth / 2),
            math.floor(BoxPos.Y + BoxHeight)
        )
        
        local Origin = ESP.Settings.Tracer.Origin
        if type(Origin) == "table" then
            Origin = Origin[1]
        end
        
        if Origin == "Bottom" then
            self.Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        elseif Origin == "Center" then
            self.Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        else
            self.Drawings.Tracer.From = UserInputService:GetMouseLocation()
        end
    else
        self.Drawings.Tracer.Visible = false
    end
    
    local ChamsColor = GetPlayerColor(self.Player) or ESP.Settings.Chams.Color
    self:UpdateChams(Character, ChamsColor)
end

function ESP:AddPlayer(Player)
    if Player == LocalPlayer then return end
    if Objects[Player] then return end
    
    Objects[Player] = ESPObject.new(Player)
    
    Connections[Player] = Player.CharacterAdded:Connect(function()
        if Objects[Player] then
            Objects[Player].LastPosition = nil
            Objects[Player].LastTick = 0
            Objects[Player].Velocity = Vector3.new()
        end
    end)
end

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

function ESP:GetPlayer(Player)
    return Objects[Player]
end

function ESP:GetAll()
    return Objects
end

function ESP:Start()
    for k, v in next, Players:GetPlayers() do
        self:AddPlayer(v)
    end
    
    Connections.PlayerAdded = Players.PlayerAdded:Connect(function(Player)
        self:AddPlayer(Player)
    end)
    
    Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(Player)
        self:RemovePlayer(Player)
    end)
    
    RenderConnection = RunService:BindToRenderStep(LIBRARY_ID, Enum.RenderPriority.Camera.Value + 1, function()
        if not ESP.Settings.Enabled then
            for k, v in next, Objects do
                v:Hide()
            end
            return
        end
        
        for k, v in next, Objects do
            v:Update()
        end
    end)
end

function ESP:Stop()
    if RenderConnection then
        RunService:UnbindFromRenderStep(LIBRARY_ID)
        RenderConnection = nil
    end
    
    for k, v in next, Objects do
        v:Hide()
    end
end

function ESP:Destroy()
    self:Stop()
    
    for k, v in next, Connections do
        if typeof(v) == "RBXScriptConnection" then
            v:Disconnect()
        end
    end
    Connections = {}
    
    for k, v in next, Objects do
        v:Destroy()
    end
    Objects = {}
    
    for k, v in next, Cache do
        if typeof(v) == "Instance" then
            v:Destroy()
        elseif v.Remove then
            v:Remove()
        end
    end
    Cache = {}
    
    getgenv().ESP_LIBRARY_INSTANCE = nil
end

ESP:Start()

getgenv().ESP_LIBRARY_INSTANCE = ESP

return ESP
