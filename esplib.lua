local ESP = {}
ESP.__index = ESP

local DEFAULT_CONFIG = {
    master_switch = true,
    ignore_lobby_players = true,
    lod_enabled = true,
    lod_distance = 150,
    max_distance = {
        enabled = true,
        limit = 2500
    },
    text = {
        size = 13,
        font = 2
    },
    box = {
        enabled = true,
        type = "Full",
        color = Color3.fromRGB(255, 255, 255),
        fill = {
            enabled = true,
            color = Color3.fromRGB(255, 255, 255),
            transparency = 0.25
        }
    },
    skeleton = {
        enabled = true,
        color = Color3.fromRGB(255, 255, 255),
        thickness = 1
    },
    head_dot = {
        enabled = true,
        color = Color3.fromRGB(255, 255, 255),
        radius = 3,
        filled = true
    },
    view_tracer = {
        enabled = true,
        color = Color3.fromRGB(255, 255, 255),
        thickness = 1,
        length = 6
    },
    names = {
        enabled = true,
        color = Color3.fromRGB(255, 255, 255)
    },
    health = {
        enabled = true,
        low_color = Color3.fromRGB(255, 0, 0),
        high_color = Color3.fromRGB(0, 255, 0),
        text = true,
        text_color = Color3.fromRGB(255, 255, 255)
    },
    distance = {
        enabled = true,
        color = Color3.fromRGB(255, 255, 255)
    },
    tool = {
        enabled = true,
        color = Color3.fromRGB(255, 255, 255)
    },
    chams = {
        enabled = true,
        color = Color3.fromRGB(255, 255, 255),
        transparency = 0.6
    }
}

function ESP.new()
    local self = setmetatable({}, ESP)

    self.RunService = game:GetService("RunService")
    self.Players = game:GetService("Players")
    self.Workspace = game:GetService("Workspace")
    self.Camera = self.Workspace.CurrentCamera
    self.LocalPlayer = self.Players.LocalPlayer

    self.Settings = {}
    for k, v in pairs(DEFAULT_CONFIG) do
        if type(v) == "table" then
            self.Settings[k] = {}
            for k2, v2 in pairs(v) do
                if type(v2) == "table" then
                    self.Settings[k][k2] = {}
                    for k3, v3 in pairs(v2) do
                        self.Settings[k][k2][k3] = v3
                    end
                else
                    self.Settings[k][k2] = v2
                end
            end
        else
            self.Settings[k] = v
        end
    end

    self.Cache = {}
    self.Database = {}
    self.IsInitialized = false
    
    return self
end

function ESP:NewDrawing(drawing_type, properties)
    local drawing = Drawing.new(drawing_type)
    for key, value in pairs(properties or {}) do
        drawing[key] = value
    end
    table.insert(self.Cache, drawing)
    return drawing
end

function ESP:Track(instance)
    table.insert(self.Cache, instance)
    return instance
end

function ESP:InitPlayer(player, character)
    if self.Database[player] then return end
    
    local esp_object = {
        Drawings = {},
        Chams = {},
        Character = character,
        LastPosition = nil,
        LastTick = 0,
        Velocity = Vector3.new()
    }
    
    local d = esp_object.Drawings

    d.BoxOutline = self:NewDrawing("Square", {
        Visible = false,
        Thickness = 3,
        Color = Color3.new(0, 0, 0),
        Filled = false
    })
    
    d.Box = self:NewDrawing("Square", {
        Visible = false,
        Thickness = 1,
        Filled = false
    })
    
    d.Fill = self:NewDrawing("Square", {
        Visible = false,
        Filled = true,
        Transparency = self.Settings.box.fill.transparency
    })

    for i = 1, 8 do
        d["C" .. i] = self:NewDrawing("Line", {
            Visible = false,
            Thickness = 1
        })
    end

    d.HealthBack = self:NewDrawing("Square", {
        Visible = false,
        Filled = true,
        Color = Color3.new(0, 0, 0)
    })
    
    d.HealthBar = self:NewDrawing("Square", {
        Visible = false,
        Filled = true,
        Color = self.Settings.health.high_color
    })
    
    d.HealthText = self:NewDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = true,
        Font = self.Settings.text.font,
        Size = self.Settings.text.size,
        Color = self.Settings.health.text_color
    })

    d.Name = self:NewDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = true,
        Font = self.Settings.text.font,
        Size = self.Settings.text.size,
        Color = self.Settings.names.color
    })
    
    d.Distance = self:NewDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = true,
        Font = self.Settings.text.font,
        Size = self.Settings.text.size,
        Color = self.Settings.distance.color
    })
    
    d.Tool = self:NewDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = true,
        Font = self.Settings.text.font,
        Size = self.Settings.text.size,
        Color = self.Settings.tool.color
    })

    for i = 1, 5 do
        d["Skel_" .. i] = self:NewDrawing("Line", {
            Visible = false,
            Thickness = self.Settings.skeleton.thickness
        })
    end

    d.HeadDot = self:NewDrawing("Circle", {
        Visible = false,
        Filled = self.Settings.head_dot.filled,
        Radius = self.Settings.head_dot.radius
    })

    d.ViewTracer = self:NewDrawing("Line", {
        Visible = false,
        Thickness = self.Settings.view_tracer.thickness
    })
    
    self.Database[player] = esp_object
end

function ESP:RemovePlayer(player)
    local esp_object = self.Database[player]
    if not esp_object then return end
    
    for _, drawing in pairs(esp_object.Drawings) do
        pcall(function() drawing:Remove() end)
    end
    
    for _, cham in pairs(esp_object.Chams) do
        pcall(function() cham:Destroy() end)
    end
    
    self.Database[player] = nil
end

function ESP:HideAll()
    for _, esp_object in pairs(self.Database) do
        for _, drawing in pairs(esp_object.Drawings) do
            pcall(function() drawing.Visible = false end)
        end
        for _, cham in pairs(esp_object.Chams) do
            pcall(function() cham.Visible = false end)
        end
    end
end

function ESP:DrawCornerBox(drawings, box_pos, box_size, color)
    local x, y = box_pos.X, box_pos.Y
    local w, h = box_size.X, box_size.Y
    local line_length = math.floor(w / 3)
    
    local function set_line(line, x1, y1, x2, y2)
        line.Color = color
        line.From = Vector2.new(x1, y1)
        line.To = Vector2.new(x2, y2)
    end
    
    set_line(drawings.C1, x, y, x + line_length, y)
    set_line(drawings.C2, x, y, x, y + line_length)
    set_line(drawings.C3, x + w - line_length, y, x + w, y)
    set_line(drawings.C4, x + w, y, x + w, y + line_length)
    set_line(drawings.C5, x, y + h - line_length, x, y + h)
    set_line(drawings.C6, x, y + h, x + line_length, y + h)
    set_line(drawings.C7, x + w, y + h - line_length, x + w, y + h)
    set_line(drawings.C8, x + w - line_length, y + h, x + w, y + h)
end

--// 绘制骨架 //--
function ESP:DrawSkeleton(drawings, character, color)
    local head = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local left_arm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
    local right_arm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
    local left_leg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")
    local right_leg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")
    
    local function world_to_screen(part)
        if not part then return nil, false end
        local pos, on_screen = self.Camera:WorldToViewportPoint(part.Position)
        return Vector2.new(pos.X, pos.Y), on_screen
    end
    
    local function draw_bone(line, part1, part2)
        local p1, v1 = world_to_screen(part1)
        local p2, v2 = world_to_screen(part2)
        if p1 and p2 and v1 and v2 then
            line.Visible = true
            line.Color = color
            line.From = p1
            line.To = p2
        else
            line.Visible = false
        end
    end
    
    draw_bone(drawings.Skel_1, head, torso)
    draw_bone(drawings.Skel_2, torso, left_arm)
    draw_bone(drawings.Skel_3, torso, right_arm)
    draw_bone(drawings.Skel_4, torso, left_leg)
    draw_bone(drawings.Skel_5, torso, right_leg)
end

function ESP:StartRendering()
    if self.RenderConnection then
        self.RenderConnection:Disconnect()
    end
    
    self.RenderConnection = self.RunService:BindToRenderStep("esp_render_loop", Enum.RenderPriority.Camera.Value + 1, function()
        if not self.Settings.master_switch then
            self:HideAll()
            return
        end
        
        for _, player in ipairs(self.Players:GetPlayers()) do
            if player == self.LocalPlayer then continue end
            
            if self.Settings.ignore_lobby_players and player.Team and player.Team.Name == "Lobby" then
                if self.Database[player] then
                    self:RemovePlayer(player)
                end
                continue
            end
            
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local root_part = character and character:FindFirstChild("HumanoidRootPart")
            local head = character and character:FindFirstChild("Head")
            
            if not (character and humanoid and root_part and head and humanoid.Health > 0) then
                if self.Database[player] then
                    self:RemovePlayer(player)
                end
                continue
            end
            
            if self.Database[player] and self.Database[player].Character ~= character then
                self:RemovePlayer(player)
            end
            
            self:InitPlayer(player, character)
            local esp_object = self.Database[player]
            local d = esp_object.Drawings
            
            local current_tick = tick()
            if esp_object.LastPosition then
                local delta_time = current_tick - esp_object.LastTick
                if delta_time > 0 then
                    esp_object.Velocity = (root_part.Position - esp_object.LastPosition) / delta_time
                end
            end
            esp_object.LastPosition = root_part.Position
            esp_object.LastTick = current_tick
            
            local screen_pos, on_screen = self.Camera:WorldToViewportPoint(root_part.Position)
            local distance = (self.Camera.CFrame.Position - root_part.Position).Magnitude
            
            local in_range = not self.Settings.max_distance.enabled or distance <= self.Settings.max_distance.limit
            
            if not on_screen or not in_range then
                for _, drawing in pairs(d) do
                    pcall(function() drawing.Visible = false end)
                end
                for _, cham in pairs(esp_object.Chams) do
                    pcall(function() cham.Visible = false end)
                end
                continue
            end

            local scale_factor = (1 / ((distance / 3) * math.tan(math.rad(self.Camera.FieldOfView / 2)) * 2)) * 1150
            local box_width = math.floor(scale_factor * 1.3)
            local box_height = math.floor(scale_factor * 2.1)
            local box_pos = Vector2.new(
                math.floor(screen_pos.X - box_width / 2),
                math.floor(screen_pos.Y - box_height / 2)
            )
            local box_size = Vector2.new(box_width, box_height)
            
            local is_high_detail = not self.Settings.lod_enabled or distance <= self.Settings.lod_distance
            local main_color = self.Settings.box.color
            local text_color = self.Settings.names.color

            if self.Settings.box.enabled then
                d.BoxOutline.Visible = true
                d.BoxOutline.Position = box_pos
                d.BoxOutline.Size = box_size
                
                if self.Settings.box.type == "Full" then
                    d.Box.Visible = true
                    d.Box.Position = box_pos
                    d.Box.Size = box_size
                    d.Box.Color = main_color
                    for i = 1, 8 do
                        d["C" .. i].Visible = false
                    end
                elseif self.Settings.box.type == "Corner" then
                    d.Box.Visible = false
                    for i = 1, 8 do
                        d["C" .. i].Visible = true
                    end
                    self:DrawCornerBox(d, box_pos, box_size, main_color)
                end
                
                if self.Settings.box.fill.enabled then
                    d.Fill.Visible = true
                    d.Fill.Position = box_pos
                    d.Fill.Size = box_size
                    d.Fill.Color = main_color
                    d.Fill.Transparency = self.Settings.box.fill.transparency
                else
                    d.Fill.Visible = false
                end
            else
                d.BoxOutline.Visible = false
                d.Box.Visible = false
                d.Fill.Visible = false
                for i = 1, 8 do
                    d["C" .. i].Visible = false
                end
            end

            if self.Settings.names.enabled then
                d.Name.Visible = true
                d.Name.Text = string.lower(player.DisplayName)
                d.Name.Color = text_color
                d.Name.Position = Vector2.new(
                    math.floor(box_pos.X + box_width / 2),
                    math.floor(box_pos.Y - 18)
                )
            else
                d.Name.Visible = false
            end

            if self.Settings.distance.enabled then
                d.Distance.Visible = true
                d.Distance.Text = tostring(math.floor(distance)) .. "m"
                d.Distance.Color = text_color
                d.Distance.Position = Vector2.new(
                    math.floor(box_pos.X + box_width / 2),
                    math.floor(box_pos.Y + box_height + 2)
                )
            else
                d.Distance.Visible = false
            end

            if self.Settings.health.enabled then
                local health_percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                local bar_height = math.floor(box_height * health_percent)
                local bar_width = 2
                local bar_offset = 4
                local bar_x = math.floor(box_pos.X - bar_offset - bar_width)
                local bar_y = math.floor(box_pos.Y + (box_height - bar_height))
                
                local health_color = self.Settings.health.low_color:Lerp(
                    self.Settings.health.high_color,
                    health_percent
                )
                
                d.HealthBack.Visible = true
                d.HealthBack.Size = Vector2.new(bar_width + 2, box_height + 2)
                d.HealthBack.Position = Vector2.new(bar_x - 1, math.floor(box_pos.Y) - 1)
                
                d.HealthBar.Visible = true
                d.HealthBar.Size = Vector2.new(bar_width, bar_height)
                d.HealthBar.Position = Vector2.new(bar_x, bar_y)
                d.HealthBar.Color = health_color
                
                if is_high_detail and self.Settings.health.text then
                    d.HealthText.Visible = true
                    d.HealthText.Text = tostring(math.floor(humanoid.Health)) .. "HP"
                    d.HealthText.Color = text_color
                    d.HealthText.Position = Vector2.new(
                        math.floor(bar_x - 19),
                        math.floor(bar_y - (d.HealthText.Size / 2) + 1)
                    )
                else
                    d.HealthText.Visible = false
                end
            else
                d.HealthBack.Visible = false
                d.HealthBar.Visible = false
                d.HealthText.Visible = false
            end

            if is_high_detail and self.Settings.tool.enabled then
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    d.Tool.Visible = true
                    d.Tool.Text = string.lower(tool.Name)
                    d.Tool.Color = text_color
                    d.Tool.Position = Vector2.new(
                        math.floor(box_pos.X + box_width / 2),
                        math.floor(box_pos.Y + box_height + 14)
                    )
                else
                    d.Tool.Visible = false
                end
            else
                d.Tool.Visible = false
            end

            if is_high_detail and self.Settings.skeleton.enabled then
                self:DrawSkeleton(d, character, self.Settings.skeleton.color)
            else
                for i = 1, 5 do
                    d["Skel_" .. i].Visible = false
                end
            end

            if self.Settings.head_dot.enabled then
                local head_screen, head_visible = self.Camera:WorldToViewportPoint(head.Position)
                if head_visible then
                    d.HeadDot.Visible = true
                    d.HeadDot.Position = Vector2.new(head_screen.X, head_screen.Y)
                    d.HeadDot.Color = self.Settings.head_dot.color
                    d.HeadDot.Radius = self.Settings.head_dot.radius
                    d.HeadDot.Filled = self.Settings.head_dot.filled
                else
                    d.HeadDot.Visible = false
                end
            else
                d.HeadDot.Visible = false
            end

            if self.Settings.view_tracer.enabled then
                local head_screen, head_visible = self.Camera:WorldToViewportPoint(head.Position)
                local look_direction = head.CFrame.LookVector
                local end_position = head.Position + (look_direction * self.Settings.view_tracer.length)
                local end_screen, end_visible = self.Camera:WorldToViewportPoint(end_position)
                
                if head_visible and end_visible then
                    d.ViewTracer.Visible = true
                    d.ViewTracer.Color = self.Settings.view_tracer.color
                    d.ViewTracer.From = Vector2.new(head_screen.X, head_screen.Y)
                    d.ViewTracer.To = Vector2.new(end_screen.X, end_screen.Y)
                else
                    d.ViewTracer.Visible = false
                end
            else
                d.ViewTracer.Visible = false
            end

            if self.Settings.chams.enabled then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency < 1 then
                        if not esp_object.Chams[part] then
                            local cham = Instance.new("BoxHandleAdornment")
                            cham.Name = "Cham"
                            cham.Adornee = part
                            cham.AlwaysOnTop = true
                            cham.ZIndex = 5
                            cham.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
                            cham.Transparency = self.Settings.chams.transparency
                            cham.Color3 = self.Settings.chams.color
                            cham.Parent = part
                            
                            self:Track(cham)
                            esp_object.Chams[part] = cham
                        else
                            esp_object.Chams[part].Color3 = self.Settings.chams.color
                            esp_object.Chams[part].Visible = true
                        end
                    end
                end
            else
                for part, cham in pairs(esp_object.Chams) do
                    pcall(function() cham:Destroy() end)
                    esp_object.Chams[part] = nil
                end
            end
        end
    end)
end

function ESP:StopRendering()
    if self.RenderConnection then
        self.RenderConnection:Disconnect()
        self.RenderConnection = nil
    end
end

function ESP:Init()
    if self.IsInitialized then return end

    self.PlayerRemoving = self.Players.PlayerRemoving:Connect(function(player)
        self:RemovePlayer(player)
    end)
    
    self.IsInitialized = true
end

--// 启用 ESP //--
function ESP:Enable()
    if not self.IsInitialized then
        self:Init()
    end
    self.Settings.master_switch = true
    if not self.RenderConnection then
        self:StartRendering()
    end
end

--// 禁用 ESP //--
function ESP:Disable()
    self.Settings.master_switch = false
    self:HideAll()
end

function ESP:Cleanup()
    self:StopRendering()
    
    if self.PlayerRemoving then
        self.PlayerRemoving:Disconnect()
    end
    
    for _, player in pairs(self.Players:GetPlayers()) do
        self:RemovePlayer(player)
    end
    
    for _, item in pairs(self.Cache) do
        if item then
            if item.Remove then
                pcall(function() item:Remove() end)
            elseif item.Destroy then
                pcall(function() item:Destroy() end)
            end
        end
    end
    
end

function ESP:SetColor(r, g, b)
    local color = Color3.fromRGB(r, g, b)
    self.Settings.box.color = color
    self.Settings.names.color = color
    self.Settings.skeleton.color = color
end

function ESP:SetBoxType(box_type)
    self.Settings.box.type = box_type
end

function ESP:Toggle(enabled)
    if enabled then
        self:Enable()
    else
        self:Disable()
    end
end

return ESP
