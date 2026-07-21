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

-- 透视颜色设置（默认：白边紫底）
local ESPOutlineEnabled = true
local ESPFillColor = Color3.fromRGB(128, 0, 255)  -- 紫色
local ESPOutlineColor = Color3.new(1, 1, 1)       -- 白色

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
    highlight.FillColor = ESPFillColor
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = ESPOutlineColor
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = ESPOutlineEnabled
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

-- 重新应用所有标签的颜色设置（当颜色改变时调用）
local function refreshAllESPColors()
    for target, tag in pairs(playerTags) do
        local highlight = tag:FindFirstChild("Highlight")
        if highlight then
            highlight.FillColor = ESPFillColor
            highlight.OutlineColor = ESPOutlineColor
            highlight.Enabled = ESPOutlineEnabled
        end
    end
    for target, tag in pairs(npcTags) do
        local highlight = tag:FindFirstChild("Highlight")
        if highlight then
            highlight.FillColor = ESPFillColor
            highlight.OutlineColor = ESPOutlineColor
            highlight.Enabled = ESPOutlineEnabled
        end
    end
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
    SubTitle.Text = "version : v0.2.2.5"
    SubTitle.TextColor3 = Color3.fromRGB(210, 210, 210)
    SubTitle.Font = Enum.Font.SourceSans
    SubTitle.TextSize = 12
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left
    SubTitle.TextYAlignment = Enum.TextYAlignment.Top
    SubTitle.Parent = TitleBar

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

    local MinButton = Instance.new("TextButton")
    MinButton.Size = UDim2.new(0, 30, 0, 30)
    MinButton.Position = UDim2.new(1, -70, 0, 10)
    MinButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinButton.Text = "-"
    MinButton.TextColor3 = Color3.new(1, 1, 1)
    MinButton.Font = Enum.Font.SourceSansBold
    MinButton.TextSize = 22
    MinButton.Parent = TitleBar

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 1, -50)
    ContentContainer.Position = UDim2.new(0, 0, 0, 50)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame

    local LeftPanel = Instance.new("Frame")
    LeftPanel.Size = UDim2.new(0, 120, 1, 0)
    LeftPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    LeftPanel.BorderSizePixel = 0
    LeftPanel.Parent = ContentContainer

    local RightPanel = Instance.new("Frame")
    RightPanel.Size = UDim2.new(1, -120, 1, 0)
    RightPanel.Position = UDim2.new(0, 120, 0, 0)
    RightPanel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    RightPanel.BorderSizePixel = 0
    RightPanel.Parent = ContentContainer

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

    local UpdateScroller, UpdateContainer, UpdateLayout = createScrollingFrame("UpdateScroller")
    local SettingsScroller, SettingsContainer, SettingsLayout = createScrollingFrame("SettingsScroller")
    local ESPScroller, ESPContainer, ESPLayout = createScrollingFrame("ESPScroller")
    local PuzzleScroller, PuzzleContainer, PuzzleLayout = createScrollingFrame("PuzzleScroller")  -- 新增解谜分类

    UpdateScroller.Visible = false
    SettingsScroller.Visible = false
    ESPScroller.Visible = false
    PuzzleScroller.Visible = false

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
            PuzzleScroller.Visible = (targetScroller == PuzzleScroller)
        end)
        return btn
    end

    createCategoryButton("🔍更新内容🔍", UpdateScroller, 0)
    createCategoryButton("⚙️基础功能⚙️", SettingsScroller, 40)
    createCategoryButton("👁️透视👁️", ESPScroller, 80)
    createCategoryButton("🔑解谜🔑", PuzzleScroller, 120)  -- 新增分类按钮

    -- 更新内容
    local function buildUpdateContent()
        local mainTitle = Instance.new("TextLabel")
        mainTitle.Size = UDim2.new(1, 0, 0, 30)
        mainTitle.BackgroundTransparency = 1
        mainTitle.Text = "更新公告"
        mainTitle.TextColor3 = Color3.new(1, 1, 1)
        mainTitle.Font = Enum.Font.SourceSansBold
        mainTitle.TextSize = 20
        mainTitle.TextXAlignment = Enum.TextXAlignment.Left
        mainTitle.Parent = UpdateContainer

        local versionLabel = Instance.new("TextLabel")
        versionLabel.Size = UDim2.new(1, 0, 0, 22)
        versionLabel.BackgroundTransparency = 1
        versionLabel.Text = "V0.2.2.5"
        versionLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        versionLabel.Font = Enum.Font.SourceSansBold
        versionLabel.TextSize = 16
        versionLabel.TextXAlignment = Enum.TextXAlignment.Left
        versionLabel.Parent = UpdateContainer

        local items = {
            "▪ 该版本起，可查看更新内容。",
            "▪ 重构透视代码逻辑。",
            "▪ 添加了无碰撞功能。",
            "▪ 为透视增添个性化功能。",
            "▪ 增加\"解谜\"分类，目前可查看Level 1入口门的密码。"
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
    -- 基础功能
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

    -- 透视分类
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

        -- 玩家ESP开关
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

        -- NPCs ESP开关
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

        -- 描边启用开关
        createRow("描边启用", ESPOutlineEnabled, function(value)
            ESPOutlineEnabled = value
            refreshAllESPColors()
        end)

        -- 颜色选择辅助函数：创建颜色选择行
        local function createColorRow(labelText, getColor, setColor)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundTransparency = 1
            row.Parent = ESPContainer

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6, -10, 1, 0)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = labelText
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.SourceSans
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = row

            -- 颜色预览框（点击后打开颜色选择器）
            local colorBox = Instance.new("TextButton")
            colorBox.Size = UDim2.new(0, 30, 0, 26)
            colorBox.Position = UDim2.new(1, -35, 0.5, -13)
            colorBox.BackgroundColor3 = getColor()
            colorBox.BorderSizePixel = 1
            colorBox.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
            colorBox.Text = ""
            colorBox.Parent = row

            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 4)
            boxCorner.Parent = colorBox

            colorBox.MouseButton1Click:Connect(function()
                -- 创建颜色选择器弹窗 (仿 Orion 风格)
                local pickerGui = Instance.new("ScreenGui")
                pickerGui.Name = "ColorPicker"
                pickerGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

                local pickerFrame = Instance.new("Frame")
                pickerFrame.Size = UDim2.new(0, 250, 0, 200)
                pickerFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
                pickerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                pickerFrame.BorderSizePixel = 0
                pickerFrame.Active = true
                pickerFrame.Draggable = true
                pickerFrame.Parent = pickerGui

                local pickerCorner = Instance.new("UICorner")
                pickerCorner.CornerRadius = UDim.new(0, 8)
                pickerCorner.Parent = pickerFrame

                local pickerTitle = Instance.new("TextLabel")
                pickerTitle.Size = UDim2.new(1, 0, 0, 30)
                pickerTitle.Position = UDim2.new(0, 0, 0, 0)
                pickerTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                pickerTitle.Text = "选择颜色"
                pickerTitle.TextColor3 = Color3.new(1, 1, 1)
                pickerTitle.Font = Enum.Font.SourceSansBold
                pickerTitle.TextSize = 16
                pickerTitle.Parent = pickerFrame

                local pickerTitleCorner = Instance.new("UICorner")
                pickerTitleCorner.CornerRadius = UDim.new(0, 8)
                pickerTitleCorner.Parent = pickerTitle

                -- 颜色预览（当前选中的颜色）
                local previewBox = Instance.new("Frame")
                previewBox.Size = UDim2.new(0, 40, 0, 40)
                previewBox.Position = UDim2.new(0.5, -20, 0, 40)
                previewBox.BackgroundColor3 = getColor()
                previewBox.BorderSizePixel = 1
                previewBox.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
                previewBox.Parent = pickerFrame

                local previewCorner = Instance.new("UICorner")
                previewCorner.CornerRadius = UDim.new(0, 4)
                previewCorner.Parent = previewBox

                -- HSV 滑块（简化版：使用 Hue 滑块 + Saturation/Value 通过两个滑块控制）
                local function createSlider(parent, yPos, labelText, minVal, maxVal, callback)
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(0.2, 0, 0, 20)
                    label.Position = UDim2.new(0.05, 0, 0, yPos)
                    label.BackgroundTransparency = 1
                    label.Text = labelText
                    label.TextColor3 = Color3.new(1, 1, 1)
                    label.Font = Enum.Font.SourceSans
                    label.TextSize = 12
                    label.Parent = parent

                    local slider = Instance.new("Frame")
                    slider.Size = UDim2.new(0.6, 0, 0, 20)
                    slider.Position = UDim2.new(0.3, 0, 0, yPos)
                    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    slider.BorderSizePixel = 0
                    slider.Parent = parent

                    local sliderCorner = Instance.new("UICorner")
                    sliderCorner.CornerRadius = UDim.new(0, 4)
                    sliderCorner.Parent = slider

                    local fill = Instance.new("Frame")
                    fill.Size = UDim2.new(0.5, 0, 1, 0)
                    fill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
                    fill.BorderSizePixel = 0
                    fill.Parent = slider

                    local fillCorner = Instance.new("UICorner")
                    fillCorner.CornerRadius = UDim.new(0, 4)
                    fillCorner.Parent = fill

                    local valueLabel = Instance.new("TextLabel")
                    valueLabel.Size = UDim2.new(0.1, 0, 0, 20)
                    valueLabel.Position = UDim2.new(0.92, 0, 0, yPos)
                    valueLabel.BackgroundTransparency = 1
                    valueLabel.Text = "50"
                    valueLabel.TextColor3 = Color3.new(1, 1, 1)
                    valueLabel.Font = Enum.Font.SourceSans
                    valueLabel.TextSize = 12
                    valueLabel.Parent = parent

                    local function updateSlider(pos)
                        local relative = math.clamp((pos.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                        fill.Size = UDim2.new(relative, 0, 1, 0)
                        local val = minVal + (maxVal - minVal) * relative
                        valueLabel.Text = tostring(math.floor(val))
                        callback(val)
                    end

                    slider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            updateSlider(input.Position)
                        end
                    end)

                    slider.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsTouchPressed() then
                                updateSlider(input.Position)
                            end
                        end
                    end)

                    return slider, fill, valueLabel
                end

                local currentColor = getColor()
                local h, s, v = Color3.toHSV(currentColor)

                local hueSlider, hueFill, hueLabel = createSlider(pickerFrame, 90, "H", 0, 360, function(val)
                    h = val / 360
                    currentColor = Color3.fromHSV(h, s, v)
                    previewBox.BackgroundColor3 = currentColor
                    colorBox.BackgroundColor3 = currentColor
                end)

                local satSlider, satFill, satLabel = createSlider(pickerFrame, 120, "S", 0, 100, function(val)
                    s = val / 100
                    currentColor = Color3.fromHSV(h, s, v)
                    previewBox.BackgroundColor3 = currentColor
                    colorBox.BackgroundColor3 = currentColor
                end)

                local valSlider, valFill, valLabel = createSlider(pickerFrame, 150, "V", 0, 100, function(val)
                    v = val / 100
                    currentColor = Color3.fromHSV(h, s, v)
                    previewBox.BackgroundColor3 = currentColor
                    colorBox.BackgroundColor3 = currentColor
                end)

                -- 确认 / 取消按钮
                local confirmBtn = Instance.new("TextButton")
                confirmBtn.Size = UDim2.new(0.4, -5, 0, 30)
                confirmBtn.Position = UDim2.new(0.05, 0, 1, -35)
                confirmBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                confirmBtn.Text = "确认"
                confirmBtn.TextColor3 = Color3.new(1, 1, 1)
                confirmBtn.Font = Enum.Font.SourceSansBold
                confirmBtn.TextSize = 14
                confirmBtn.Parent = pickerFrame

                local confirmCorner = Instance.new("UICorner")
                confirmCorner.CornerRadius = UDim.new(0, 4)
                confirmCorner.Parent = confirmBtn

                confirmBtn.MouseButton1Click:Connect(function()
                    setColor(currentColor)
                    refreshAllESPColors()
                    pickerGui:Destroy()
                end)

                local cancelBtn = Instance.new("TextButton")
                cancelBtn.Size = UDim2.new(0.4, -5, 0, 30)
                cancelBtn.Position = UDim2.new(0.55, 0, 1, -35)
                cancelBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                cancelBtn.Text = "取消"
                cancelBtn.TextColor3 = Color3.new(1, 1, 1)
                cancelBtn.Font = Enum.Font.SourceSansBold
                cancelBtn.TextSize = 14
                cancelBtn.Parent = pickerFrame

                local cancelCorner = Instance.new("UICorner")
                cancelCorner.CornerRadius = UDim.new(0, 4)
                cancelCorner.Parent = cancelBtn

                cancelBtn.MouseButton1Click:Connect(function()
                    pickerGui:Destroy()
                end)
            end)
        end

        -- 描边颜色
        createColorRow("描边颜色", function() return ESPOutlineColor end, function(c) ESPOutlineColor = c end)

        -- 高光颜色
        createColorRow("高光颜色", function() return ESPFillColor end, function(c) ESPFillColor = c end)
    end
    buildESP()

    -- ===== 解谜分类 =====
    local function buildPuzzle()
        -- 长条按钮：Level 1入口门密码
        local passwordBtn = Instance.new("TextButton")
        passwordBtn.Size = UDim2.new(1, -10, 0, 40)
        passwordBtn.Position = UDim2.new(0.05, 0, 0, 10)
        passwordBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        passwordBtn.Text = "Level 1入口门密码"
        passwordBtn.TextColor3 = Color3.new(1, 1, 1)
        passwordBtn.Font = Enum.Font.SourceSansBold
        passwordBtn.TextSize = 16
        passwordBtn.Parent = PuzzleContainer

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = passwordBtn

        passwordBtn.MouseButton1Click:Connect(function()
            -- 读取密码
            local password = "未找到密码"
            local success, result = pcall(function()
                local sign = Workspace:FindFirstChild("Game")
                if sign then sign = sign:FindFirstChild("Maps") end
                if sign then sign = sign:FindFirstChild("Level0") end
                if sign then sign = sign:FindFirstChild("CustomDoor") end
                if sign then sign = sign:FindFirstChild("ExitDoor") end
                if sign then sign = sign:FindFirstChild("Passcode") end
                if sign then sign = sign:FindFirstChild("SurfaceGui") end
                if sign then sign = sign:FindFirstChild("SIGN") end
                if sign and sign:IsA("TextLabel") then
                    password = sign.Text
                else
                    password = "未找到密码 (路径不存在)"
                end
            end)
            if not success then
                password = "读取失败: " .. tostring(result)
            end

            -- 创建弹窗（仿注入器风格，右下角可关闭）
            local notifyGui = Instance.new("ScreenGui")
            notifyGui.Name = "PasswordNotification"
            notifyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

            local notifyFrame = Instance.new("Frame")
            notifyFrame.Size = UDim2.new(0, 320, 0, 120)
            notifyFrame.Position = UDim2.new(1, -340, 1, -140)
            notifyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            notifyFrame.BorderSizePixel = 1
            notifyFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
            notifyFrame.Parent = notifyGui

            local notifyCorner = Instance.new("UICorner")
            notifyCorner.CornerRadius = UDim.new(0, 8)
            notifyCorner.Parent = notifyFrame

            -- 关闭按钮
            local closeBtn = Instance.new("TextButton")
            closeBtn.Size = UDim2.new(0, 24, 0, 24)
            closeBtn.Position = UDim2.new(1, -30, 0, 6)
            closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            closeBtn.Text = "X"
            closeBtn.TextColor3 = Color3.new(1, 1, 1)
            closeBtn.Font = Enum.Font.SourceSansBold
            closeBtn.TextSize = 14
            closeBtn.Parent = notifyFrame

            local closeCorner = Instance.new("UICorner")
            closeCorner.CornerRadius = UDim.new(0, 4)
            closeCorner.Parent = closeBtn

            closeBtn.MouseButton1Click:Connect(function()
                notifyGui:Destroy()
            end)

            -- 标题
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -40, 0, 30)
            titleLabel.Position = UDim2.new(0, 10, 0, 6)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = "执行成功"
            titleLabel.TextColor3 = Color3.new(46, 204, 113)
            titleLabel.Font = Enum.Font.SourceSansBold
            titleLabel.TextSize = 18
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = notifyFrame

            -- 内容
            local contentLabel = Instance.new("TextLabel")
            contentLabel.Size = UDim2.new(1, -20, 0, 50)
            contentLabel.Position = UDim2.new(0, 10, 0, 40)
            contentLabel.BackgroundTransparency = 1
            contentLabel.Text = "密码为：" .. password
            contentLabel.TextColor3 = Color3.new(1, 1, 1)
            contentLabel.Font = Enum.Font.SourceSans
            contentLabel.TextSize = 15
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.TextWrapped = true
            contentLabel.Parent = notifyFrame

            -- 自动关闭（5秒后）
            task.delay(5, function()
                if notifyGui and notifyGui.Parent then
                    notifyGui:Destroy()
                end
            end)
        end)
    end
    buildPuzzle()

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
