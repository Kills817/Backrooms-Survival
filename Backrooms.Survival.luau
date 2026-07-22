local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "ES脚本",
    Text = "正在加载中…",
    Duration = 3
})

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExplorerScriptUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 6)
Corner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 6)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 22)
Title.Position = UDim2.new(0, 10, 0, 4)
Title.BackgroundTransparency = 1
Title.Text = "Explorer Script"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -80, 0, 16)
SubTitle.Position = UDim2.new(0, 10, 0, 26)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "version：v0.2.0.5"
SubTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
SubTitle.Font = Enum.Font.SourceSans
SubTitle.TextSize = 12
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 7)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 20
MinBtn.Parent = TitleBar

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -45)
ContentContainer.Position = UDim2.new(0, 0, 0, 45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ClipsDescendants = true
ContentContainer.Parent = MainFrame

local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 110, 1, 0)
LeftPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = ContentContainer

local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(1, -110, 1, 0)
RightPanel.Position = UDim2.new(0, 110, 0, 0)
RightPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
RightPanel.BorderSizePixel = 0
RightPanel.Parent = ContentContainer

local tabContainers = {}
local function createTabContainer(name)
    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1, 0, 1, 0)
    sc.BackgroundTransparency = 1
    sc.ScrollBarThickness = 4
    sc.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.ClipsDescendants = true
    sc.Visible = false
    sc.Parent = RightPanel

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 0)
    container.Position = UDim2.new(0, 10, 0, 5)
    container.BackgroundTransparency = 1
    container.Parent = sc

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0, 6)
    layout.Parent = container
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sc.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    tabContainers[name] = {Scroller = sc, Container = container, Layout = layout}
    return sc, container, layout
end

local function showTab(name)
    for tabName, data in pairs(tabContainers) do
        data.Scroller.Visible = (tabName == name)
    end
end

local tabButtons = {}
local function createTabButton(text, tabName, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = LeftPanel
    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        showTab(tabName)
    end)
    table.insert(tabButtons, btn)
    return btn
end

local updateSc, updateCont, updateLayout = createTabContainer("更新公告")
local setSc, setCont, setLayout = createTabContainer("基础功能")
local espSc, espCont, espLayout = createTabContainer("透视")

createTabButton("更新公告", "更新公告", 0)
createTabButton("基础功能", "基础功能", 40)
createTabButton("透视", "透视", 80)

showTab("更新公告")
if #tabButtons > 0 then tabButtons[1].BackgroundColor3 = Color3.fromRGB(60, 60, 60) end

local function addLabel(container, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.Parent = container
    return lbl
end

local function addToggle(container, labelText, initialState, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundTransparency = 1
    row.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, -10, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 26)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -13)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    toggleBtn.Text = ""
    toggleBtn.Parent = row
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = toggleBtn

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 22, 0, 22)
    dot.Position = UDim2.new(0, 2, 0.5, -11)
    dot.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    dot.BorderSizePixel = 0
    dot.Parent = toggleBtn
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local state = initialState
    local function updateVisual(isOn)
        local targetPos, targetColor, bgColor
        if isOn then
            targetPos = UDim2.new(1, -24, 0.5, -11)
            targetColor = Color3.fromRGB(255, 255, 255)
            bgColor = Color3.fromRGB(46, 204, 113)
        else
            targetPos = UDim2.new(0, 2, 0.5, -11)
            targetColor = Color3.fromRGB(120, 120, 120)
            bgColor = Color3.fromRGB(80, 80, 80)
        end
        local tween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(dot, tween, {Position = targetPos, BackgroundColor3 = targetColor}):Play()
        TweenService:Create(toggleBtn, tween, {BackgroundColor3 = bgColor}):Play()
    end
    updateVisual(state)

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        updateVisual(state)
    end)
    return row
end

local function addButton(container, labelText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundTransparency = 1
    row.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 1, 0)
    btn.Position = UDim2.new(0, 10, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = labelText
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 15
    btn.Parent = row
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return row
end

addLabel(updateCont, "version：v0.2.0.5")
addLabel(updateCont, "▪重置UI。")

local UI = {
    Containers = {
        Settings = setCont,
        ESP = espCont
    },
    AddToggle = addToggle,
    AddButton = addButton,
    AddLabel = addLabel,
    Close = function()
        for target, tag in pairs(playerTags) do tag:Destroy() end
        for target, tag in pairs(npcTags) do tag:Destroy() end
        ScreenGui:Destroy()
    end
}

local dragging = false
local dragOffset = Vector2.new()
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = Vector2.new(input.Position.X, input.Position.Y)
        local tbPos = TitleBar.AbsolutePosition
        local tbSize = TitleBar.AbsoluteSize
        if pos.X >= tbPos.X and pos.X <= tbPos.X + tbSize.X and pos.Y >= tbPos.Y and pos.Y <= tbPos.Y + tbSize.Y then
            dragging = true
            dragOffset = pos - Vector2.new(MainFrame.AbsolutePosition.X, MainFrame.AbsolutePosition.Y)
        end
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = Vector2.new(input.Position.X, input.Position.Y)
        MainFrame.Position = UDim2.new(0, pos.X - dragOffset.X, 0, pos.Y - dragOffset.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 420, 0, 45) or UDim2.new(0, 420, 0, 320)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    MinBtn.Text = minimized and "+" or "-"
    ContentContainer.Visible = not minimized
end)

CloseBtn.MouseButton1Click:Connect(function()
    UI.Close()
end)

MainWindow = UI
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
MainWindow.AddToggle(MainWindow.Containers.Settings, "全图高亮", FullbrightEnabled, function(value)
    FullbrightEnabled = value
    applyFullbright(value)
end)
MainWindow.AddToggle(MainWindow.Containers.Settings, "无碰撞", NoclipEnabled, function(value)
    toggleNoclip(value)
end)
MainWindow.AddButton(MainWindow.Containers.Settings, "关闭脚本（清理所有功能）", function()
    PlayerESPEnabled = false
    NPCESPEnabled = false
    FullbrightEnabled = false
    if NoclipEnabled then toggleNoclip(false) end
    applyFullbright(false)
    clearAllESP()
    MainWindow.Close()
end)

MainWindow.AddToggle(MainWindow.Containers.ESP, "玩家ESP", PlayerESPEnabled, function(value)
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
MainWindow.AddToggle(MainWindow.Containers.ESP, "NPCs ESP", NPCESPEnabled, function(value)
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
StarterGui:SetCore("SendNotification", {
    Title = "ES脚本",
    Text = "加载成功。该脚本完全免费，如果你通过支付渠道获得该脚本，恭喜你被骗了😇",
    Duration = 8
})
