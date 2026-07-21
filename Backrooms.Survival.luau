local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- 状态
local PlayerESPEnabled = false
local NPCESPEnabled = false
local FullbrightEnabled = false
local NoclipEnabled = false
local UIMinimized = false

-- ===== Fullbright =====
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

-- ===== Noclip =====
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
        task.wait(0.5)
        toggleNoclip(true)
    end
end)

-- ===== NPC 识别 =====
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

-- ===== 标签管理 =====
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
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = target
    billboard.Parent = tag

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.3
    label.TextWrapped = true
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

    label.Text = name .. " | " .. string.format("%.1f", distance) .. " m"
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

-- ===== 增量更新 =====
local function updatePlayerESP()
    if PlayerESPEnabled then
        for _, target in pairs(Workspace:GetDescendants()) do
            if target:IsA("Model") and target:FindFirstChildOfClass("Humanoid") then
                local isPlayer = Players:GetPlayerFromCharacter(target)
                if isPlayer and target ~= LocalPlayer.Character and not playerTags[target] then
                    createTag(target, true)
                    updateTag(target)
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
                    createTag(target, false)
                    updateTag(target)
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

-- ===== 实时更新循环（3帧更新距离，12帧扫描新目标） =====
local frameCounter = 0
RunService.Heartbeat:Connect(function()
    frameCounter = frameCounter + 1
    if frameCounter % 3 ~= 0 then return end  -- 每3帧更新一次

    local now = tick()
    local toRemove = {}

    for target, tag in pairs(playerTags) do
        if target and target:IsA("Model") and target:FindFirstChild("ESPTag") then
            updateTag(target)
            local label = tag:FindFirstChild("Billboard") and tag.Billboard:FindFirstChild("Label")
            if label then
                local text = label.Text
                if text == "Label" or (text == "Loading..." and tagCreationTime[target] and now - tagCreationTime[target] > 3) then
                    table.insert(toRemove, target)
                end
            end
        else
            table.insert(toRemove, target)
        end
    end

    for target, tag in pairs(npcTags) do
        if target and target:IsA("Model") and target:FindFirstChild("ESPTag") then
            updateTag(target)
            local label = tag:FindFirstChild("Billboard") and tag.Billboard:FindFirstChild("Label")
            if label then
                local text = label.Text
                if text == "Label" or (text == "Loading..." and tagCreationTime[target] and now - tagCreationTime[target] > 3) then
                    table.insert(toRemove, target)
                end
            end
        else
            table.insert(toRemove, target)
        end
    end

    for _, target in ipairs(toRemove) do
        removeTag(target)
    end

    -- 每12帧扫描一次新目标
    if frameCounter % 12 == 0 then
        for _, target in pairs(Workspace:GetDescendants()) do
            if target:IsA("Model") and target:FindFirstChildOfClass("Humanoid") then
                local isPlayer = Players:GetPlayerFromCharacter(target)
                if isPlayer then
                    if PlayerESPEnabled and target ~= LocalPlayer.Character and not playerTags[target] then
                        createTag(target, true)
                        updateTag(target)
                    end
                elseif isNPCModel(target) then
                    if NPCESPEnabled and not npcTags[target] then
                        createTag(target, false)
                        updateTag(target)
                    end
                end
            end
        end
    end
end)

-- ===== 角色添加 =====
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

-- ===== UI =====
local function createUI()
    if LocalPlayer.PlayerGui:FindFirstChild("BackroomsSurvivalUI") then return end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BackroomsSurvivalUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 250)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.Active = true
    TitleBar.Parent = MainFrame
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 8)
    TitleBarCorner.Parent = TitleBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -70, 0, 20)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "Explorer Script"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Top
    Title.Parent = TitleBar

    local SubTitle = Instance.new("TextLabel")
    SubTitle.Size = UDim2.new(1, -70, 0, 15)
    SubTitle.Position = UDim2.new(0, 10, 0, 28)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "version : v0.1.7.5"
    SubTitle.TextColor3 = Color3.fromRGB(210, 210, 210)
    SubTitle.Font = Enum.Font.SourceSans
    SubTitle.TextSize = 12
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left
    SubTitle.TextYAlignment = Enum.TextYAlignment.Top
    SubTitle.Parent = TitleBar

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 10)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function()
        PlayerESPEnabled = false
        NPCESPEnabled = false
        FullbrightEnabled = false
        if NoclipEnabled then toggleNoclip(false) end
        applyFullbright(false)
        clearAllESP()
        ScreenGui:Destroy()
    end)

    -- Minimize Button
    local MinButton = Instance.new("TextButton")
    MinButton.Size = UDim2.new(0, 30, 0, 30)
    MinButton.Position = UDim2.new(1, -70, 0, 10)
    MinButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinButton.Text = "-"
    MinButton.TextColor3 = Color3.new(1, 1, 1)
    MinButton.Font = Enum.Font.SourceSansBold
    MinButton.TextSize = 22
    MinButton.Parent = TitleBar

    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 1, -50)
    ContentContainer.Position = UDim2.new(0, 0, 0, 50)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame

    -- Left Panel
    local LeftPanel = Instance.new("Frame")
    LeftPanel.Size = UDim2.new(0, 120, 1, 0)
    LeftPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    LeftPanel.BorderSizePixel = 0
    LeftPanel.Parent = ContentContainer

    -- Right Panel
    local RightPanel = Instance.new("Frame")
    RightPanel.Size = UDim2.new(1, -120, 1, 0)
    RightPanel.Position = UDim2.new(0, 120, 0, 0)
    RightPanel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    RightPanel.BorderSizePixel = 0
    RightPanel.Parent = ContentContainer

    -- 滚动框架工厂
    local function createScrollingFrame(name)
        local sc = Instance.new("ScrollingFrame")
        sc.Name = name
        sc.Size = UDim2.new(1, 0, 1, 0)
        sc.BackgroundTransparency = 1
        sc.ScrollBarThickness = 4
        sc.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
        sc.ScrollBarImageTransparency = 0.5
        sc.CanvasSize = UDim2.new(0, 0, 0, 0)
        sc.ClipsDescendants = true
        sc.Parent = RightPanel
        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(1, -20, 0, 0)
        container.Position = UDim2.new(0, 10, 0, 5)
        container.BackgroundTransparency = 1
        container.Parent = sc
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.Padding = UDim.new(0, 5)
        layout.Parent = container
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sc.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end)
        return sc, container, layout
    end

    -- 创建各分类的滚动框
    local UpdateScroller, UpdateContainer, UpdateLayout = createScrollingFrame("UpdateScroller")
    local SettingsScroller, SettingsContainer, SettingsLayout = createScrollingFrame("SettingsScroller")
    local ESPScroller, ESPContainer, ESPLayout = createScrollingFrame("ESPScroller")

    UpdateScroller.Visible = false
    SettingsScroller.Visible = false
    ESPScroller.Visible = false

    -- 左侧分类按钮
    local selectedButton = nil
    local function createCategoryButton(text, targetScroller, yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.Position = UDim2.new(0, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 18
        btn.Parent = LeftPanel
        btn.MouseButton1Click:Connect(function()
            if selectedButton then
                selectedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            selectedButton = btn
            UpdateScroller.Visible = (targetScroller == UpdateScroller)
            SettingsScroller.Visible = (targetScroller == SettingsScroller)
            ESPScroller.Visible = (targetScroller == ESPScroller)
        end)
        return btn
    end

    createCategoryButton("🔍更新内容🔍", UpdateScroller, 0)
    createCategoryButton("⚙️基础功能⚙️", SettingsScroller, 40)
    createCategoryButton("👁️透视👁️", ESPScroller, 80)

    -- ===== 更新内容 =====
    local function buildUpdateContent()
        local versionLabel = Instance.new("TextLabel")
        versionLabel.Size = UDim2.new(1, 0, 0, 25)
        versionLabel.BackgroundTransparency = 1
        versionLabel.Text = "V0.1.7.5"
        versionLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        versionLabel.Font = Enum.Font.SourceSansBold
        versionLabel.TextSize = 16
        versionLabel.TextXAlignment = Enum.TextXAlignment.Left
        versionLabel.Parent = UpdateContainer

        local items = {
            "▪ 该版本起，可查看更新内容。",
            "▪ 重构透视代码逻辑。",
            "▪ 添加了无碰撞功能。"
        }
        for _, line in ipairs(items) do
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 25)
            lbl.BackgroundTransparency = 1
            lbl.Text = line
            lbl.TextColor3 = Color3.new(1, 1, 1)
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true
            lbl.Parent = UpdateContainer
        end
    end
    buildUpdateContent()

    -- ===== 基础功能 =====
    local function buildSettings()
        local function createRow(labelText, initialState, callback)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundTransparency = 1
            row.Parent = SettingsContainer

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.7, -10, 1, 0)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = labelText
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.SourceSans
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = row

            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0, 50, 0, 26)
            toggleBtn.Position = UDim2.new(1, -50, 0.5, -13)
            toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            toggleBtn.Text = ""
            toggleBtn.Parent = row

            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 4)
            toggleCorner.Parent = toggleBtn

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
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(dot, tweenInfo, { Position = targetPos, BackgroundColor3 = targetColor }):Play()
                TweenService:Create(toggleBtn, tweenInfo, { BackgroundColor3 = bgColor }):Play()
            end

            updateVisual(state)

            toggleBtn.MouseButton1Click:Connect(function()
                state = not state
                callback(state)
                updateVisual(state)
            end)
        end

        createRow("全图高亮", FullbrightEnabled, function(value)
            FullbrightEnabled = value
            applyFullbright(value)
        end)

        createRow("无碰撞", NoclipEnabled, function(value)
            toggleNoclip(value)
        end)
    end
    buildSettings()

    -- ===== 透视 =====
    local function buildESP()
        local function createRow(labelText, initialState, callback)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundTransparency = 1
            row.Parent = ESPContainer

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.7, -10, 1, 0)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = labelText
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.SourceSans
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = row

            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0, 50, 0, 26)
            toggleBtn.Position = UDim2.new(1, -50, 0.5, -13)
            toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            toggleBtn.Text = ""
            toggleBtn.Parent = row

            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 4)
            toggleCorner.Parent = toggleBtn

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
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(dot, tweenInfo, { Position = targetPos, BackgroundColor3 = targetColor }):Play()
                TweenService:Create(toggleBtn, tweenInfo, { BackgroundColor3 = bgColor }):Play()
            end

            updateVisual(state)

            toggleBtn.MouseButton1Click:Connect(function()
                state = not state
                callback(state)
                updateVisual(state)
            end)
        end

        createRow("玩家ESP", PlayerESPEnabled, function(value)
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

        createRow("NPCs ESP", NPCESPEnabled, function(value)
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
    end
    buildESP()

    -- 最小化/展开
    MinButton.MouseButton1Click:Connect(function()
        UIMinimized = not UIMinimized
        local targetSize = UIMinimized and UDim2.new(0, 400, 0, 50) or UDim2.new(0, 400, 0, 250)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = targetSize }):Play()
        MinButton.Text = UIMinimized and "+" or "-"

        if UIMinimized then
            ContentContainer.Visible = false
            ContentContainer.Size = UDim2.new(0, 0, 0, 0)
        else
            ContentContainer.Visible = true
            ContentContainer.Size = UDim2.new(1, 0, 1, -50)
        end
    end)

    -- 拖动
    local dragging = false
    local dragOffset = Vector2.new()

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            local tbPos = TitleBar.AbsolutePosition
            local tbSize = TitleBar.AbsoluteSize
            if pos.X >= tbPos.X and pos.X <= tbPos.X + tbSize.X and
               pos.Y >= tbPos.Y and pos.Y <= tbPos.Y + tbSize.Y then
                dragging = true
                dragOffset = pos - Vector2.new(MainFrame.AbsolutePosition.X, MainFrame.AbsolutePosition.Y)
            end
        end
    end

    local function onInputChanged(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            local newPos = pos - dragOffset
            MainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
        end
    end

    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end

    UserInputService.InputBegan:Connect(onInputBegan)
    UserInputService.InputChanged:Connect(onInputChanged)
    UserInputService.InputEnded:Connect(onInputEnded)

    return ScreenGui
end

createUI()
