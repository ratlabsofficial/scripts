--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
--[[
    Role ESP dengan Ikon & Outline Fix + Tracers
    Support XENO Executor
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local RoleIcons = {
    Killer = 607147197,
    Sheriff = 125117925593395,
    HomigradPolice = 418541763,
    HomigradTerrorist = 71660057329682,
    Target = 997927539
}

local RoleColors = {
    Killer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 0, 255),
    HomigradPolice = Color3.fromRGB(0, 0, 255),
    HomigradTerrorist = Color3.fromRGB(255, 165, 0),
    Target = Color3.fromRGB(255, 255, 0),
    Unarmed = Color3.fromRGB(0, 255, 0)
}

local weaponMarkers = {
    Killer = {"Sawn-off", "K1911", "RR-LightCompactPistolS", "JS2-Derringy", "KOLT-AR15", "JS-22", "KamatovS", "RR-LCP", "Rosen-Obrez"},
    Sheriff = {"RR-Snubby", "GG-17", "IZVEKH-412"},
    HomigradTerrorist = {"VK's ANKM", "RY's GG-17", "AT's KAR15"},
    HomigradPolice = {"RR-40", "IZVEKH-412", "ZJ23M"}
}

local tracers = {}

local function createESP(player, role)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end

    -- Ikon
    local head = char.Head
    if not head:FindFirstChild("RoleESPIcon") then
        local gui = Instance.new("BillboardGui")
        gui.Name = "RoleESPIcon"
        gui.Adornee = head
        gui.Size = UDim2.new(0, 30, 0, 30)
        gui.StudsOffset = Vector3.new(0, 2, 0)
        gui.AlwaysOnTop = true
        gui.Parent = head

        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Size = UDim2.new(1, 0, 1, 0)
        img.Image = "rbxassetid://" .. (RoleIcons[role] or "")
        img.Parent = gui
    else
        head.RoleESPIcon.ImageLabel.Image = "rbxassetid://" .. (RoleIcons[role] or "")
    end

    -- Highlight
    if not char:FindFirstChild("RoleHighlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "RoleHighlight"
        hl.FillTransparency = 0.8
        hl.OutlineTransparency = 0
        hl.OutlineColor = RoleColors[role] or Color3.fromRGB(255, 255, 255)
        hl.FillColor = RoleColors[role] or Color3.fromRGB(255, 255, 255)
        hl.Adornee = char
        hl.Parent = char
    else
        char.RoleHighlight.OutlineColor = RoleColors[role] or Color3.fromRGB(255, 255, 255)
        char.RoleHighlight.FillColor = RoleColors[role] or Color3.fromRGB(255, 255, 255)
    end
end

local function clearESP(player)
    local char = player.Character
    if char then
        local hl = char:FindFirstChild("RoleHighlight")
        if hl then hl:Destroy() end
    end
    if char and char:FindFirstChild("Head") then
        local icon = char.Head:FindFirstChild("RoleESPIcon")
        if icon then icon:Destroy() end
    end
end

local function updateTracer(player, role)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    local tracer = tracers[player]
    if not tracer then
        tracer = Drawing.new("Line")
        tracer.Thickness = 1.5
        tracer.Transparency = 1
        tracer.ZIndex = 2
        tracers[player] = tracer
    end

    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    if onScreen then
        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        tracer.To = Vector2.new(screenPos.X, screenPos.Y)
        tracer.Visible = true
        tracer.Color = RoleColors[role] or Color3.fromRGB(255, 255, 255)
    else
        tracer.Visible = false
    end
end

local function clearTracer(player)
    local tracer = tracers[player]
    if tracer then
        tracer:Remove()
        tracers[player] = nil
    end
end

local function getPlayerRole(player)
    local npc = workspace:FindFirstChild("NPCSFolder") and workspace.NPCSFolder:FindFirstChild(player.Name)
    local tool = (player.Character and player.Character:FindFirstChildOfClass("Tool")) or (npc and npc:FindFirstChildOfClass("Tool"))
    local backpack = player:FindFirstChild("Backpack")

    local function checkWeapon(weapon)
        for role, list in pairs(weaponMarkers) do
            if table.find(list, weapon) then return role end
        end
    end

    local statusGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("RESETONDEATHStatusGui")
    if statusGui and statusGui:FindFirstChild("TARGETHINT") then
        local hintText = statusGui.TARGETHINT.Text
        if npc and npc:FindFirstChild("Configuration") then
            for _, val in ipairs(npc.Configuration:GetChildren()) do
                if val:IsA("StringValue") and val.Value == hintText then
                    return "Target"
                end
            end
        end
    end

    if tool then return checkWeapon(tool.Name) end

    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            local role = checkWeapon(item.Name)
            if role then return role end
        end
    end

    return "Unarmed"
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local role = getPlayerRole(player)
            if role then
                createESP(player, role)
                updateTracer(player, role)
            else
                clearESP(player)
                clearTracer(player)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    clearTracer(player)
end)
