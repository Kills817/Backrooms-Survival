local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ===== 状态变量 =====
local PlayerESPEnabled = false
local NPCESPEnabled = false
local FullbrightEnabled = false
local NoclipEnabled = false
local UIMinimized = false

local ESPOutlineColor = Color3.new(1, 1, 1)
local ESPFillColor = Color3.fromRGB(128, 0, 255)
local ESPOutlineEnabled = true

local activeNotifications = {}
local notifCounter = 0

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
    if FullbrightEnabled then applyFullbright(true) end
end)

-- ===== Noclip =====
local noclipConnection
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
        wait(0.5)
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

-- ===== ESP 标签管理 =====
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
    local dict = isPlayer and playerTags or npcTags
    if dict[target] then return end

    local tag = Instance.new("Folder")
    tag.Name = "ESPTag"
    tag.Parent = target

    local hl = Instance.new("Highlight")
    hl.Name = "Highlight"
    hl.Adornee = target
    hl.FillTransparency = 0.5
    hl.FillColor = ESPFillColor
    hl.OutlineTransparency = ESPOutlineEnabled and 0 or 1
    hl.OutlineColor = ESPOutlineColor
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = tag

    local bill = Instance.new("BillboardGui")
    bill.Name = "Billboard"
    bill.Size = UDim2.new(0, 300, 0, 30)
    bill.StudsOffset = Vector3.new(0, 5, 0)
    bill.AlwaysOnTop = true
    bill.Adornee = target
    bill.Parent = tag

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
    label.Parent = bill

    dict[target] = tag
    tagCreationTime[target] = tick()
end

local function updateTag(target)
    local tag = playerTags[target] or npcTags[target]
    if not tag then return end
    local bill = tag:FindFirstChild("Billboard")
    if not bill then return end
    local label = bill:FindFirstChild("Label")
    if not label then return end

    if not LocalPlayer.Character then
        label.Text = "Loading..."
        return
    end

    local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
    if not root then
        removeTag(target)
        return
    end
    local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
    if not pp then
        label.Text = "Loading..."
        return
    end

    local dist = (root.Position - pp.Position).Magnitude
    if dist ~= dist or dist == math.huge then
        removeTag(target)
        return
    end

    local name = target.Name
    local player = Players:GetPlayerFromCharacter(target)
    if player then name = player.Name end

    local hum = target:FindFirstChildOfClass("Humanoid")
    local hp = hum and math.floor(hum.Health) or "??"
    local hpText = (type(hp) == "number") and ("HP: " .. hp) or "HP: ??"

    label.Text = name .. " | " .. string.format("%.1f", dist) .. " m | " .. hpText
end

local function clearAllESP()
    for _, tag in pairs(playerTags) do tag:Destroy() end
    for _, tag in pairs(npcTags) do tag:Destroy() end
    playerTags = {}
    npcTags = {}
    tagCreationTime = {}
end

local function updateAllESP()
    -- 玩家
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

    -- NPC
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

-- 实时更新循环
local frame = 0
RunService.Heartbeat:Connect(function()
    frame = frame + 1
    if frame % 5 ~= 0 then return end

    local now = tick()
    local toRemove = {}

    for target, tag in pairs(playerTags) do
        if target and target:IsA("Model") and target:FindFirstChild("ESPTag") then
            local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
            local valid = false
            if root and LocalPlayer.Character then
                local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                if pp then
                    local dist = (root.Position - pp.Position).Magnitude
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
            local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
            local valid = false
            if root and LocalPlayer.Character then
                local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                if pp then
                    local dist = (root.Position - pp.Position).Magnitude
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

    for _, target in ipairs(toRemove) do removeTag(target) end

    if frame % 20 == 0 then
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

-- 角色添加事件
local function onCharacterAdded(player)
    player.CharacterAdded:Connect(function()
        wait(0.5)
        updateAllESP()
        if NoclipEnabled then toggleNoclip(true) end
    end)
end

for _, player in pairs(Players:GetPlayers()) do onCharacterAdded(player) end
Players.PlayerAdded:Connect(onCharacterAdded)
-- ===== 通知系统 =====
local function createNotification(title, subtitle, duration)
    notifCounter = notifCounter + 1
    local id = notifCounter
    local ScreenGui = LocalPlayer.PlayerGui:FindFirstChild("BackroomsSurvivalUI")
    if not ScreenGui then return end
    local MainFrame = ScreenGui:FindFirstChild("MainFrame")
    if not MainFrame then return end

    local notif = Instance.new("Frame")
    notif.Name = "Notif_" .. id
    notif.Size = UDim2.new(0, 280, 0, 70)
    notif.Position = UDim2.new(1, 20, 0, 10 + #activeNotifications * 80)
    notif.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -30, 0, 4)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 16
    closeBtn.Parent = notif
    closeBtn.MouseButton1Click:Connect(function()
        local tween = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, 0, notif.Position.Y.Offset)
        })
        tween:Play()
        tween.Completed:Connect(function()
            notif:Destroy()
            table.remove(activeNotifications, table.find(activeNotifications, id))
            for i, v in ipairs(activeNotifications) do
                local n = MainFrame:FindFirstChild("Notif_" .. v)
                if n then
                    TweenService:Create(n, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.new(1, -300, 0, 10 + (i-1)*80)
                    }):Play()
                end
            end
        end)
    end)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 4)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif

    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, -40, 0, 35)
    subLabel.Position = UDim2.new(0, 10, 0, 30)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = subtitle
    subLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    subLabel.Font = Enum.Font.SourceSans
    subLabel.TextSize = 13
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.TextWrapped = true
    subLabel.Parent = notif

    table.insert(activeNotifications, id)

    local tweenIn = TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -300, 0, 10 + (#activeNotifications-1)*80)
    })
    tweenIn:Play()

    if duration then
        task.delay(duration, function()
            if not notif.Parent then return end
            closeBtn.MouseButton1Click:Fire()
        end)
    end
end

-- ===== 颜色选择器 =====
local colorPickerOpen = false

local function createColorPicker(initialColor, callback, position)
    local ScreenGui = LocalPlayer.PlayerGui:FindFirstChild("BackroomsSurvivalUI")
    if not ScreenGui then return end
    local MainFrame = ScreenGui:FindFirstChild("MainFrame")
    if not MainFrame then return end

    if colorPickerOpen then
        local old = MainFrame:FindFirstChild("ColorPicker")
        if old then old:Destroy() end
        colorPickerOpen = false
    end

    local picker = Instance.new("Frame")
    picker.Name = "ColorPicker"
    picker.Size = UDim2.new(0, 220, 0, 200)
    picker.Position = position or UDim2.new(0.5, -110, 0.5, -100)
    picker.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    picker.BorderSizePixel = 0
    picker.ClipsDescendants = true
    picker.ZIndex = 10
    picker.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = picker

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleBar.Parent = picker

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -30, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "选择颜色"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0, 3)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        picker:Destroy()
        colorPickerOpen = false
    end)

    local colorImage = Instance.new("ImageLabel")
    colorImage.Size = UDim2.new(1, -20, 1, -50)
    colorImage.Position = UDim2.new(0, 10, 0, 40)
    colorImage.BackgroundColor3 = Color3.new(1, 1, 1)
    colorImage.Image = "rbxassetid://13546250212"
    colorImage.ScaleType = Enum.ScaleType.Fit
    colorImage.Parent = picker

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 40, 0, 30)
    preview.Position = UDim2.new(1, -55, 1, -40)
    preview.BackgroundColor3 = initialColor
    preview.BorderSizePixel = 0
    preview.Parent = picker
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = preview

    local currentColor = initialColor

    colorImage.MouseButton1Click:Connect(function(x, y)
        local absPos = colorImage.AbsolutePosition
        local absSize = colorImage.AbsoluteSize
        local relX = (x - absPos.X) / absSize.X
        local relY = (y - absPos.Y) / absSize.Y
        relX = math.clamp(relX, 0, 1)
        relY = math.clamp(relY, 0, 1)
        currentColor = Color3.fromHSV(relX, 1 - relY, 1)
        preview.BackgroundColor3 = currentColor
        if callback then callback(currentColor) end
    end)

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0, 60, 0, 26)
    confirmBtn.Position = UDim2.new(0.5, -30, 1, -34)
    confirmBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    confirmBtn.Text = "确定"
    confirmBtn.TextColor3 = Color3.new(1, 1, 1)
    confirmBtn.Font = Enum.Font.SourceSansBold
    confirmBtn.TextSize = 14
    confirmBtn.Parent = picker
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = confirmBtn
    confirmBtn.MouseButton1Click:Connect(function()
        if callback then callback(currentColor) end
        picker:Destroy()
        colorPickerOpen = false
    end)

    colorPickerOpen = true
end
local function createUI()
    if LocalPlayer.PlayerGui:FindFirstChild("BackroomsSurvivalUI") then return end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BackroomsSurvivalUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 420, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.Active = true
    TitleBar.Parent = MainFrame
    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 8)
    tbCorner.Parent = TitleBar

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

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.TextSize = 18
    CloseBtn.Parent = TitleBar
    CloseBtn.MouseButton1Click:Connect(function()
        PlayerESPEnabled = false
        NPCESPEnabled = false
        FullbrightEnabled = false
        if NoclipEnabled then toggleNoclip(false) end
        applyFullbright(false)
        clearAllESP()
        ScreenGui:Destroy()
    end)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -70, 0, 10)
    MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1, 1, 1)
    MinBtn.Font = Enum.Font.SourceSansBold
    MinBtn.TextSize = 22
    MinBtn.Parent = TitleBar

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
    LeftPanel.Size = UDim2.new(0, 130, 1, 0)
    LeftPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    LeftPanel.BorderSizePixel = 0
    LeftPanel.Parent = ContentContainer

    -- Right Panel
    local RightPanel = Instance.new("Frame")
    RightPanel.Size = UDim2.new(1, -130, 1, 0)
    RightPanel.Position = UDim2.new(0, 130, 0, 0)
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
        container.Size = UDim2.new(1, -16, 0, 0)
        container.Position = UDim2.new(0, 8, 0, 5)
        container.BackgroundTransparency = 1
        container.Parent = sc
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.Padding = UDim.new(0, 6)
        layout.Parent = container
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sc.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
        end)
        return sc, container, layout
    end

    local UpdateScroller, UpdateContainer, _ = createScrollingFrame("UpdateScroller")
    local SettingsScroller, SettingsContainer, _ = createScrollingFrame("SettingsScroller")
    local ESPScroller, ESPContainer, _ = createScrollingFrame("ESPScroller")
    local PuzzleScroller, PuzzleContainer, _ = createScrollingFrame("PuzzleScroller")

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
        btn.TextSize = 17
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
    createCategoryButton("⚙️基础功能⚙️", SettingsScroller, 38)
    createCategoryButton("👁️透视👁️", ESPScroller, 76)
    createCategoryButton("🔑解谜🔑", PuzzleScroller, 114)
-- ===== 更新内容 =====
local function buildUpdate()
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
        "▪ 为透视增添个性化功能。",
        "▪ 增加\"解谜\"分类，目前可查看Level 1入口门的密码。"
    }
    for _, line in ipairs(items) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 24)
        lbl.BackgroundTransparency = 1
        lbl.Text = line
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.Font = Enum.Font.SourceSans
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        lbl.Parent = UpdateContainer
    end

    local oldVersion = Instance.new("TextLabel")
    oldVersion.Size = UDim2.new(1, 0, 0, 22)
    oldVersion.BackgroundTransparency = 1
    oldVersion.Text = "V0.1.7.0"
    oldVersion.TextColor3 = Color3.fromRGB(130, 130, 130)
    oldVersion.Font = Enum.Font.SourceSansBold
    oldVersion.TextSize = 14
    oldVersion.TextXAlignment = Enum.TextXAlignment.Left
    oldVersion.Parent = UpdateContainer

    local oldItems = {
        "▪ 重构透视代码逻辑。",
        "▪ 添加了无碰撞功能。"
    }
    for _, line in ipairs(oldItems) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 22)
        lbl.BackgroundTransparency = 1
        lbl.Text = line
        lbl.TextColor3 = Color3.fromRGB(160, 160, 160)
        lbl.Font = Enum.Font.SourceSans
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        lbl.Parent = UpdateContainer
    end
end
buildUpdate()

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
        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(0, 4)
        tCorner.Parent = toggleBtn

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 22, 0, 22)
        dot.Position = UDim2.new(0, 2, 0.5, -11)
        dot.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        dot.BorderSizePixel = 0
        dot.Parent = toggleBtn
        local dCorner = Instance.new("UICorner")
        dCorner.CornerRadius = UDim.new(1, 0)
        dCorner.Parent = dot

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
            local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(dot, ti, { Position = targetPos, BackgroundColor3 = targetColor }):Play()
            TweenService:Create(toggleBtn, ti, { BackgroundColor3 = bgColor }):Play()
        end
        updateVisual(state)

        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            callback(state)
            updateVisual(state)
        end)
    end

    createRow("全图高亮", FullbrightEnabled, function(v)
        FullbrightEnabled = v
        applyFullbright(v)
    end)
    createRow("无碰撞", NoclipEnabled, function(v)
        toggleNoclip(v)
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
        label.Size = UDim2.new(0.6, -10, 1, 0)
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
        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(0, 4)
        tCorner.Parent = toggleBtn

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 22, 0, 22)
        dot.Position = UDim2.new(0, 2, 0.5, -11)
        dot.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        dot.BorderSizePixel = 0
        dot.Parent = toggleBtn
        local dCorner = Instance.new("UICorner")
        dCorner.CornerRadius = UDim.new(1, 0)
        dCorner.Parent = dot

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
            local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(dot, ti, { Position = targetPos, BackgroundColor3 = targetColor }):Play()
            TweenService:Create(toggleBtn, ti, { BackgroundColor3 = bgColor }):Play()
        end
        updateVisual(state)

        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            callback(state)
            updateVisual(state)
        end)
    end

    createRow("玩家ESP", PlayerESPEnabled, function(v)
        PlayerESPEnabled = v
        updateAllESP()
    end)
    createRow("NPCs ESP", NPCESPEnabled, function(v)
        NPCESPEnabled = v
        updateAllESP()
    end)
    createRow("描边启用", ESPOutlineEnabled, function(v)
        ESPOutlineEnabled = v
        updateAllESP()
    end)

    -- 颜色行
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

        local colorBox = Instance.new("Frame")
        colorBox.Size = UDim2.new(0, 30, 0, 22)
        colorBox.Position = UDim2.new(1, -35, 0.5, -11)
        colorBox.BackgroundColor3 = getColor()
        colorBox.BorderSizePixel = 0
        colorBox.Parent = row
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 4)
        boxCorner.Parent = colorBox

        colorBox.MouseButton1Click:Connect(function()
            createColorPicker(getColor(), function(newColor)
                setColor(newColor)
                colorBox.BackgroundColor3 = newColor
                updateAllESP()
            end, UDim2.new(0.5, -110, 0.5, -100))
        end)
    end

    createColorRow("描边颜色", function() return ESPOutlineColor end, function(c) ESPOutlineColor = c end)
    createColorRow("高光颜色", function() return ESPFillColor end, function(c) ESPFillColor = c end)
end
buildESP()

-- ===== 解谜 =====
local function buildPuzzle()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, 10)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = "Level 1入口门密码"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = PuzzleContainer
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local passcode = "未找到"
        local success = false
        local maps = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Maps")
        if maps then
            local level0 = maps:FindFirstChild("Level0")
            if level0 then
                local customDoor = level0:FindFirstChild("CustomDoor")
                if customDoor then
                    local exitDoor = customDoor:FindFirstChild("ExitDoor")
                    if exitDoor then
                        local passcodeObj = exitDoor:FindFirstChild("Passcode")
                        if passcodeObj then
                            local surfaceGui = passcodeObj:FindFirstChild("SurfaceGui")
                            if surfaceGui then
                                local sign = surfaceGui:FindFirstChild("SIGN")
                                if sign then
                                    passcode = sign.Text or "未找到"
                                    success = true
                                end
                            end
                        end
                    end
                end
            end
        end
        if success then
            createNotification("执行成功", "密码为: " .. passcode, 6)
        else
            createNotification("执行失败", "未找到密码数据，请确认路径是否正确", 5)
        end
    end)
end
buildPuzzle()
    -- ===== 最小化/展开 =====
    MinBtn.MouseButton1Click:Connect(function()
        UIMinimized = not UIMinimized
        local targetSize = UIMinimized and UDim2.new(0, 420, 0, 50) or UDim2.new(0, 420, 0, 300)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = targetSize }):Play()
        MinBtn.Text = UIMinimized and "+" or "-"
        ContentContainer.Visible = not UIMinimized
        ContentContainer.Size = UIMinimized and UDim2.new(0, 0, 0, 0) or UDim2.new(1, 0, 1, -50)
    end)

    -- ===== 拖动 =====
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
