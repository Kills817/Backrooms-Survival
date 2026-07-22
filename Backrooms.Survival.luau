local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "ES脚本",
    Text = "正在加载中…",
    Duration = 3
})
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Wind-UI/Wind-UI/main/Source.lua"))()
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerESPEnabled = false
local NPCESPEnabled = false
local FullbrightEnabled = false
local NoclipEnabled = false
local UIMinimized = false
local function applyFullbright(enable)
    if enable then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
    end
end
Lighting.LightingChanged:Connect(function()
    if FullbrightEnabled then
        applyFullbright(true)
    end
end)
local noclipConnection = nil
local function toggleNoclip(enable)
    NoclipEnabled = enable
    local char = LocalPlayer.Character
    if not char then return end
    if enable then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if not LocalPlayer.Character then
                noclipConnection:Disconnect()
                noclipConnection = nil
                return
            end
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end
end
LocalPlayer.CharacterAdded:Connect(function(char)
    if NoclipEnabled then
        wait(0.5)
        toggleNoclip(true)
    end
end)
local NPCsFolder = Workspace:FindFirstChild("NPCs")
local function isNPCModel(model)
    if not model or not model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    if not model:FindFirstChildOfClass("Humanoid") then return false end
    local parent = model.Parent
    while parent do
        if parent == NPCsFolder then return true end
        parent = parent.Parent
    end
    return false
end
local playerTags = {}
local npcTags = {}
local tagCreationTime = {}
local function removeTag(target)
    local tag = playerTags[target]
    if tag then
        tag:Destroy()
        playerTags[target] = nil
        tagCreationTime[target] = nil
        return
    end
    tag = npcTags[target]
    if tag then
        tag:Destroy()
        npcTags[target] = nil
        tagCreationTime[target] = nil
    end
end
local function createTag(target, isPlayer)
    local tagDict = isPlayer and playerTags or npcTags
    if tagDict[target] then return end
    local tag = Instance.new("Folder")
    tag.Name = "ESPTag"
    tag.Parent = target
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    highlight.Adornee = target
    highlight.FillTransparency = 0.5
    highlight.FillColor = Color3.fromRGB(128, 0, 255)
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = tag
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Billboard"
    billboard.Size = UDim2.new(0, 300, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = target
    billboard.Parent = tag
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 15
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.3
    label.TextWrapped = false
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Text = "Loading..."
    label.Parent = billboard
    tagDict[target] = tag
    tagCreationTime[target] = tick()
end
local function updateTag(target)
    local tag = playerTags[target] or npcTags[target]
    if not tag then return end
    local billboard = tag:FindFirstChild("Billboard")
    if not billboard then return end
    local label = billboard:FindFirstChild("Label")
    if not label then return end
    if not LocalPlayer.Character then
        label.Text = "Loading..."
        return
    end
    local rootPart = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
    if not rootPart then
        removeTag(target)
        return
    end
    local primaryPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
    if not primaryPart then
        label.Text = "Loading..."
        return
    end
    local distance = (rootPart.Position - primaryPart.Position).Magnitude
    if distance ~= distance or distance == math.huge then
        removeTag(target)
        return
    end
    local name = target.Name
    local player = Players:GetPlayerFromCharacter(target)
    if player then
        name = player.Name
    end
    local humanoid = target:FindFirstChildOfClass("Humanoid")
    local hp = humanoid and math.floor(humanoid.Health) or "??"
    local hpText = (type(hp) == "number") and ("HP: " .. hp) or "HP: ??"
    label.Text = name .. " | " .. string.format("%.1f", distance) .. " m | " .. hpText
end
local function clearAllESP()
    for target, tag in pairs(playerTags) do
        tag:Destroy()
    end
    for target, tag in pairs(npcTags) do
        tag:Destroy()
    end
    playerTags = {}
    npcTags = {}
    tagCreationTime = {}
end
local function updatePlayerESP()
    if PlayerESPEnabled then
        for _, target in pairs(Workspace:GetDescendants()) do
            if target:IsA("Model") and target:FindFirstChildOfClass("Humanoid") then
                local isPlayer = Players:GetPlayerFromCharacter(target)
                if isPlayer and target ~= LocalPlayer.Character and not playerTags[target] then
                    local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
                    if root and LocalPlayer.Character then
                        local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                        if pp then
                            local dist = (root.Position - pp.Position).Magnitude
                            if dist <= 500 then
                                createTag(target, true)
                                updateTag(target)
                            end
                        end
                    end
                end
            end
        end
    else
        for target, tag in pairs(playerTags) do
            tag:Destroy()
        end
        playerTags = {}
    end
end
local function updateNPCESP()
    if NPCESPEnabled then
        for _, target in pairs(Workspace:GetDescendants()) do
            if target:IsA("Model") and target:FindFirstChildOfClass("Humanoid") then
                if isNPCModel(target) and not npcTags[target] then
                    local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
                    if root and LocalPlayer.Character then
                        local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                        if pp then
                            local dist = (root.Position - pp.Position).Magnitude
                            if dist <= 500 then
                                createTag(target, false)
                                updateTag(target)
                            end
                        end
                    end
                end
            end
        end
    else
        for target, tag in pairs(npcTags) do
            tag:Destroy()
        end
        npcTags = {}
    end
end
local frameCounter = 0
RunService.Heartbeat:Connect(function()
    frameCounter = frameCounter + 1
    if frameCounter % 5 == 0 then
        local now = tick()
        local toRemove = {}
        for target, tag in pairs(playerTags) do
            if target and target:IsA("Model") and target:FindFirstChild("ESPTag") then
                local rootPart = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
                local valid = false
                if rootPart and LocalPlayer.Character then
                    local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                    if pp then
                        local dist = (rootPart.Position - pp.Position).Magnitude
                        if dist <= 500 then
                            valid = true
                            updateTag(target)
                        end
                    end
                end
                if not valid then
                    table.insert(toRemove, target)
                else
                    local label = tag:FindFirstChild("Billboard") and tag.Billboard:FindFirstChild("Label")
                    if label then
                        local text = label.Text
                        if text == "Label" or (text == "Loading..." and tagCreationTime[target] and now - tagCreationTime[target] > 3) then
                            table.insert(toRemove, target)
                        end
                    end
                end
            else
                table.insert(toRemove, target)
            end
        end
        for target, tag in pairs(npcTags) do
            if target and target:IsA("Model") and target:FindFirstChild("ESPTag") then
                local rootPart = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
                local valid = false
                if rootPart and LocalPlayer.Character then
                    local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                    if pp then
                        local dist = (rootPart.Position - pp.Position).Magnitude
                        if dist <= 500 then
                            valid = true
                            updateTag(target)
                        end
                    end
                end
                if not valid then
                    table.insert(toRemove, target)
                else
                    local label = tag:FindFirstChild("Billboard") and tag.Billboard:FindFirstChild("Label")
                    if label then
                        local text = label.Text
                        if text == "Label" or (text == "Loading..." and tagCreationTime[target] and now - tagCreationTime[target] > 3) then
                            table.insert(toRemove, target)
                        end
                    end
                end
            else
                table.insert(toRemove, target)
            end
        end
        for _, target in ipairs(toRemove) do
            removeTag(target)
        end
    end
    if frameCounter % 20 == 0 then
        for _, target in pairs(Workspace:GetDescendants()) do
            if target:IsA("Model") and target:FindFirstChildOfClass("Humanoid") then
                local isPlayer = Players:GetPlayerFromCharacter(target)
                if isPlayer then
                    if PlayerESPEnabled and target ~= LocalPlayer.Character and not playerTags[target] then
                        local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
                        if root and LocalPlayer.Character then
                            local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                            if pp then
                                local dist = (root.Position - pp.Position).Magnitude
                                if dist <= 500 then
                                    createTag(target, true)
                                    updateTag(target)
                                end
                            end
                        end
                    end
                elseif isNPCModel(target) then
                    if NPCESPEnabled and not npcTags[target] then
                        local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
                        if root and LocalPlayer.Character then
                            local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                            if pp then
                                local dist = (root.Position - pp.Position).Magnitude
                                if dist <= 500 then
                                    createTag(target, false)
                                    updateTag(target)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
local function onCharacterAdded(player)
    player.CharacterAdded:Connect(function()
        wait(0.5)
        if PlayerESPEnabled then updatePlayerESP() end
        if NPCESPEnabled then updateNPCESP() end
        if NoclipEnabled then toggleNoclip(true) end
    end)
end
for _, player in pairs(Players:GetPlayers()) do
    onCharacterAdded(player)
end
Players.PlayerAdded:Connect(onCharacterAdded)
local MainWindow = WindUI:CreateWindow({
    Name = "Explorer Script",
    Description = "version：v0.2.0.5",
    Theme = "Dark",
    Keybind = Enum.KeyCode.RightShift,
    Folder = "ExplorerScript"
})
local UpdateTab = MainWindow:CreateTab("更新公告")
UpdateTab:CreateLabel("version：v0.2.0.5")
UpdateTab:CreateLabel("▪重置UI。")
local SettingsTab = MainWindow:CreateTab("基础功能")
SettingsTab:CreateToggle("全图高亮", FullbrightEnabled, function(value)
    FullbrightEnabled = value
    applyFullbright(value)
end)
SettingsTab:CreateToggle("无碰撞", NoclipEnabled, function(value)
    toggleNoclip(value)
end)
local ESPTab = MainWindow:CreateTab("透视")
ESPTab:CreateToggle("玩家ESP", PlayerESPEnabled, function(value)
    PlayerESPEnabled = value
    if value then
        updatePlayerESP()
    else
        for target, tag in pairs(playerTags) do
            tag:Destroy()
        end
        playerTags = {}
    end
end)
ESPTab:CreateToggle("NPCs ESP", NPCESPEnabled, function(value)
    NPCESPEnabled = value
    if value then
        updateNPCESP()
    else
        for target, tag in pairs(npcTags) do
            tag:Destroy()
        end
        npcTags = {}
    end
end)
SettingsTab:CreateButton("关闭脚本（清理所有功能）", function()
    PlayerESPEnabled = false
    NPCESPEnabled = false
    FullbrightEnabled = false
    if NoclipEnabled then toggleNoclip(false) end
    applyFullbright(false)
    clearAllESP()
    MainWindow:Destroy()
end)
StarterGui:SetCore("SendNotification", {
    Title = "ES脚本",
    Text = "加载成功。该脚本完全免费，如果你通过支付渠道获得该脚本，恭喜你被骗了😇",
    Duration = 8
})
