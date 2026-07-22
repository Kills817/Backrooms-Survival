local WindUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function CreateWindow(data) local window = {} local scr = Instance.new("ScreenGui") scr.Name = data.Folder or "WindUI" scr.ResetOnSpawn = false scr.Parent = LocalPlayer:WaitForChild("PlayerGui") local main = Instance.new("Frame") main.Size = UDim2.new(0,450,0,350) main.Position = UDim2.new(0.5,-225,0.5,-175) main.BackgroundColor3 = Color3.fromRGB(30,30,30) main.BorderSizePixel = 0 main.ClipsDescendants = true main.Parent = scr local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0,6) corner.Parent = main local titleBar = Instance.new("Frame") titleBar.Size = UDim2.new(1,0,0,40) titleBar.BackgroundColor3 = Color3.fromRGB(45,45,45) titleBar.Parent = main local titleCorner = Instance.new("UICorner") titleCorner.CornerRadius = UDim.new(0,6) titleCorner.Parent = titleBar local titleText = Instance.new("TextLabel") titleText.Size = UDim2.new(1,-80,0,20) titleText.Position = UDim2.new(0,10,0,4) titleText.BackgroundTransparency = 1 titleText.Text = data.Name or "WindUI" titleText.TextColor3 = Color3.new(1,1,1) titleText.Font = Enum.Font.SourceSansBold titleText.TextSize = 18 titleText.TextXAlignment = Enum.TextXAlignment.Left titleText.Parent = titleBar local descText = Instance.new("TextLabel") descText.Size = UDim2.new(1,-80,0,16) descText.Position = UDim2.new(0,10,0,24) descText.BackgroundTransparency = 1 descText.Text = data.Description or "" descText.TextColor3 = Color3.fromRGB(180,180,180) descText.Font = Enum.Font.SourceSans descText.TextSize = 12 descText.TextXAlignment = Enum.TextXAlignment.Left descText.Parent = titleBar local closeBtn = Instance.new("TextButton") closeBtn.Size = UDim2.new(0,30,0,30) closeBtn.Position = UDim2.new(1,-35,0,5) closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50) closeBtn.Text = "X" closeBtn.TextColor3 = Color3.new(1,1,1) closeBtn.Font = Enum.Font.SourceSansBold closeBtn.TextSize = 16 closeBtn.Parent = titleBar closeBtn.MouseButton1Click:Connect(function() scr:Destroy() end) local minBtn = Instance.new("TextButton") minBtn.Size = UDim2.new(0,30,0,30) minBtn.Position = UDim2.new(1,-70,0,5) minBtn.BackgroundColor3 = Color3.fromRGB(50,50,50) minBtn.Text = "-" minBtn.TextColor3 = Color3.new(1,1,1) minBtn.Font = Enum.Font.SourceSansBold minBtn.TextSize = 20 minBtn.Parent = titleBar local content = Instance.new("Frame") content.Size = UDim2.new(1,0,1,-40) content.Position = UDim2.new(0,0,0,40) content.BackgroundTransparency = 1 content.ClipsDescendants = true content.Parent = main local tabs = {} local currentTab = nil local function createTab(name) local tab = {} local btn = Instance.new("TextButton") btn.Size = UDim2.new(1,0,0,35) btn.BackgroundColor3 = Color3.fromRGB(50,50,50) btn.Text = name btn.TextColor3 = Color3.new(1,1,1) btn.Font = Enum.Font.SourceSans btn.TextSize = 16 btn.Parent = content local container = Instance.new("ScrollingFrame") container.Size = UDim2.new(1,0,1,0) container.Position = UDim2.new(0,0,0,0) container.BackgroundTransparency = 1 container.ScrollBarThickness = 4 container.CanvasSize = UDim2.new(0,0,0,0) container.ClipsDescendants = true container.Visible = false container.Parent = content local layout = Instance.new("UIListLayout") layout.FillDirection = Enum.FillDirection.Vertical layout.HorizontalAlignment = Enum.HorizontalAlignment.Center layout.VerticalAlignment = Enum.VerticalAlignment.Top layout.Padding = UDim.new(0,6) layout.Parent = container layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() container.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10) end) tab.Button = btn tab.Container = container tab.Layout = layout tab.AddLabel = function(self,text) local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1,-20,0,24) lbl.Position = UDim2.new(0,10,0,0) lbl.BackgroundTransparency = 1 lbl.Text = text lbl.TextColor3 = Color3.new(1,1,1) lbl.Font = Enum.Font.SourceSans lbl.TextSize = 15 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.TextWrapped = true lbl.Parent = container end tab.AddToggle = function(self,labelText,initialState,callback) local row = Instance.new("Frame") row.Size = UDim2.new(1,0,0,32) row.BackgroundTransparency = 1 row.Parent = container local label = Instance.new("TextLabel") label.Size = UDim2.new(0.65,-10,1,0) label.Position = UDim2.new(0,0,0,0) label.BackgroundTransparency = 1 label.Text = labelText label.TextColor3 = Color3.new(1,1,1) label.Font = Enum.Font.SourceSans label.TextSize = 15 label.TextXAlignment = Enum.TextXAlignment.Left label.Parent = row local toggle = Instance.new("TextButton") toggle.Size = UDim2.new(0,50,0,26) toggle.Position = UDim2.new(1,-50,0.5,-13) toggle.BackgroundColor3 = Color3.fromRGB(80,80,80) toggle.Text = "" toggle.Parent = row local tCorner = Instance.new("UICorner") tCorner.CornerRadius = UDim.new(0,4) tCorner.Parent = toggle local dot = Instance.new("Frame") dot.Size = UDim2.new(0,22,0,22) dot.Position = UDim2.new(0,2,0.5,-11) dot.BackgroundColor3 = Color3.fromRGB(120,120,120) dot.BorderSizePixel = 0 dot.Parent = toggle local dCorner = Instance.new("UICorner") dCorner.CornerRadius = UDim.new(1,0) dCorner.Parent = dot local state = initialState local function update(isOn) local targetPos, targetColor, bgColor if isOn then targetPos = UDim2.new(1,-24,0.5,-11) targetColor = Color3.fromRGB(255,255,255) bgColor = Color3.fromRGB(46,204,113) else targetPos = UDim2.new(0,2,0.5,-11) targetColor = Color3.fromRGB(120,120,120) bgColor = Color3.fromRGB(80,80,80) end local tween = TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out) TweenService:Create(dot,tween,{Position=targetPos,BackgroundColor3=targetColor}):Play() TweenService:Create(toggle,tween,{BackgroundColor3=bgColor}):Play() end update(state) toggle.MouseButton1Click:Connect(function() state = not state callback(state) update(state) end) end tab.AddButton = function(self,labelText,callback) local row = Instance.new("Frame") row.Size = UDim2.new(1,0,0,32) row.BackgroundTransparency = 1 row.Parent = container local btn = Instance.new("TextButton") btn.Size = UDim2.new(1,-20,1,0) btn.Position = UDim2.new(0,10,0,0) btn.BackgroundColor3 = Color3.fromRGB(60,60,60) btn.Text = labelText btn.TextColor3 = Color3.new(1,1,1) btn.Font = Enum.Font.SourceSans btn.TextSize = 15 btn.Parent = row local bCorner = Instance.new("UICorner") bCorner.CornerRadius = UDim.new(0,4) bCorner.Parent = btn btn.MouseButton1Click:Connect(callback) end btn.MouseButton1Click:Connect(function() if currentTab then currentTab.Button.BackgroundColor3 = Color3.fromRGB(50,50,50) currentTab.Container.Visible = false end btn.BackgroundColor3 = Color3.fromRGB(70,70,70) container.Visible = true currentTab = tab end) if #tabs == 0 then btn.BackgroundColor3 = Color3.fromRGB(70,70,70) container.Visible = true currentTab = tab end table.insert(tabs,tab) return tab end window.CreateTab = createTab window.Destroy = function() scr:Destroy() end local minimized = false minBtn.MouseButton1Click:Connect(function() minimized = not minimized local targetSize = minimized and UDim2.new(0,450,0,40) or UDim2.new(0,450,0,350) TweenService:Create(main,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=targetSize}):Play() minBtn.Text = minimized and "+" or "-" content.Visible = not minimized end) local dragging = false local dragOffset = Vector2.new() local function onInputBegan(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local pos = Vector2.new(input.Position.X,input.Position.Y) local tbPos = titleBar.AbsolutePosition local tbSize = titleBar.AbsoluteSize if pos.X >= tbPos.X and pos.X <= tbPos.X + tbSize.X and pos.Y >= tbPos.Y and pos.Y <= tbPos.Y + tbSize.Y then dragging = true dragOffset = pos - Vector2.new(main.AbsolutePosition.X,main.AbsolutePosition.Y) end end end local function onInputChanged(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local pos = Vector2.new(input.Position.X,input.Position.Y) main.Position = UDim2.new(0,pos.X - dragOffset.X,0,pos.Y - dragOffset.Y) end end local function onInputEnded(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end UserInputService.InputBegan:Connect(onInputBegan) UserInputService.InputChanged:Connect(onInputChanged) UserInputService.InputEnded:Connect(onInputEnded) return window end local function Notify(data) local gui = Instance.new("ScreenGui") gui.Name = "WindUINotification" gui.ResetOnSpawn = false gui.Parent = LocalPlayer:WaitForChild("PlayerGui") local frame = Instance.new("Frame") frame.Size = UDim2.new(0,350,0,120) frame.Position = UDim2.new(0.5,-175,0.5,-60) frame.BackgroundColor3 = Color3.fromRGB(30,30,30) frame.BorderSizePixel = 0 frame.Parent = gui local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0,8) corner.Parent = frame local title = Instance.new("TextLabel") title.Size = UDim2.new(1,-20,0,30) title.Position = UDim2.new(0,10,0,10) title.BackgroundTransparency = 1 title.Text = data.Title or "通知" title.TextColor3 = Color3.new(1,1,1) title.Font = Enum.Font.SourceSansBold title.TextSize = 20 title.TextXAlignment = Enum.TextXAlignment.Left title.Parent = frame local desc = Instance.new("TextLabel") desc.Size = UDim2.new(1,-20,0,40) desc.Position = UDim2.new(0,10,0,40) desc.BackgroundTransparency = 1 desc.Text = data.Text or "" desc.TextColor3 = Color3.fromRGB(200,200,200) desc.Font = Enum.Font.SourceSans desc.TextSize = 14 desc.TextXAlignment = Enum.TextXAlignment.Left desc.TextWrapped = true desc.Parent = frame local okBtn = Instance.new("TextButton") okBtn.Size = UDim2.new(0,80,0,30) okBtn.Position = UDim2.new(1,-90,1,-40) okBtn.BackgroundColor3 = Color3.fromRGB(60,60,60) okBtn.Text = "确定" okBtn.TextColor3 = Color3.new(1,1,1) okBtn.Font = Enum.Font.SourceSansBold okBtn.TextSize = 16 okBtn.Parent = frame local btnCorner = Instance.new("UICorner") btnCorner.CornerRadius = UDim.new(0,4) btnCorner.Parent = okBtn okBtn.MouseButton1Click:Connect(function() gui:Destroy() end) local duration = data.Duration or 0 if duration > 0 then task.wait(duration) gui:Destroy() end end WindUI.CreateWindow = CreateWindow WindUI.Notify = Notify return WindUI
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local PlayerESPEnabled = false
local NPCESPEnabled = false
local FullbrightEnabled = false
local NoclipEnabled = false

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
    if FullbrightEnabled then applyFullbright(true) end
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
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if NoclipEnabled then
        task.wait(0.5)
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
    if player then name = player.Name end
    local humanoid = target:FindFirstChildOfClass("Humanoid")
    local hp = humanoid and math.floor(humanoid.Health) or "??"
    local hpText = (type(hp) == "number") and ("HP: " .. hp) or "HP: ??"
    label.Text = name .. " | " .. string.format("%.1f", distance) .. " m | " .. hpText
end

local function clearAllESP()
    for target, tag in pairs(playerTags) do tag:Destroy() end
    for target, tag in pairs(npcTags) do tag:Destroy() end
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
        for target, tag in pairs(playerTags) do tag:Destroy() end
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
        for target, tag in pairs(npcTags) do tag:Destroy() end
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
        task.wait(0.5)
        if PlayerESPEnabled then updatePlayerESP() end
        if NPCESPEnabled then updateNPCESP() end
        if NoclipEnabled then toggleNoclip(true) end
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    onCharacterAdded(player)
end
Players.PlayerAdded:Connect(onCharacterAdded)
local MainWindow = WindUI.CreateWindow({
    Name = "Explorer Script",
    Description = "version：v0.2.0.5",
    Theme = "Dark",
    Keybind = Enum.KeyCode.RightShift,
    Folder = "ExplorerScript"
})

local UpdateTab = MainWindow:CreateTab("更新公告")
UpdateTab:AddLabel("version：v0.2.0.5")
UpdateTab:AddLabel("▪重置UI。")

local SettingsTab = MainWindow:CreateTab("基础功能")
SettingsTab:AddToggle("全图高亮", FullbrightEnabled, function(value)
    FullbrightEnabled = value
    applyFullbright(value)
end)
SettingsTab:AddToggle("无碰撞", NoclipEnabled, function(value)
    toggleNoclip(value)
end)

local ESPTab = MainWindow:CreateTab("透视")
ESPTab:AddToggle("玩家ESP", PlayerESPEnabled, function(value)
    PlayerESPEnabled = value
    if value then
        updatePlayerESP()
    else
        for target, tag in pairs(playerTags) do tag:Destroy() end
        playerTags = {}
    end
end)
ESPTab:AddToggle("NPCs ESP", NPCESPEnabled, function(value)
    NPCESPEnabled = value
    if value then
        updateNPCESP()
    else
        for target, tag in pairs(npcTags) do tag:Destroy() end
        npcTags = {}
    end
end)
WindUI.Notify({
    Title = "ES脚本",
    Text = "加载成功。该脚本完全免费，如果你通过支付渠道获得该脚本，恭喜你被骗了😇",
    Duration = 8
})
