local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local PlayerESPEnabled = false
local NPCESPEnabled = false
local UIMinimized = false

local function createTag(target)
    if target:FindFirstChild("ESPTag") then return end
    local tag = Instance.new("Folder")
    tag.Name = "ESPTag"
    tag.Parent = target

    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    highlight.FillTransparency = 0.5
    highlight.FillColor = Color3.fromRGB(128, 0, 255)
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = tag

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Billboard"
    billboard.Size = UDim2.new(0, 150, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = tag

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.TextStrokeColor = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.5
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = billboard
end

local function updateTag(target)
    local tag = target:FindFirstChild("ESPTag")
    if not tag then return end
    local label = tag:FindFirstChild("Billboard") and tag.Billboard:FindFirstChild("Label")
    if not label then return end
    local distance = (target.PrimaryPart and target.PrimaryPart.Position - LocalPlayer.Character and LocalPlayer.Character.PrimaryPart.Position).magnitude
    if not distance then distance = 0 end
    local name = (target:IsA("Model") and target.Name) or "Unknown"
    if Players:GetPlayerFromCharacter(target) then
        name = Players:GetPlayerFromCharacter(target).Name
    end
    label.Text = name .. " | " .. string.format("%.1f", distance) .. " studs"
end

local function removeTag(target)
    local tag = target:FindFirstChild("ESPTag")
    if tag then tag:Destroy() end
end

local function isNPC(target)
    return target:IsA("Model") and target:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(target)
end

local function isPlayerChar(target)
    return target:IsA("Model") and target:FindFirstChild("Humanoid") and Players:GetPlayerFromCharacter(target)
end

local function refreshTargets()
    for _, target in pairs(Workspace:GetDescendants()) do
        if target:IsA("Model") and target:FindFirstChild("Humanoid") then
            local isPlayer = Players:GetPlayerFromCharacter(target)
            if isPlayer then
                if PlayerESPEnabled and target ~= LocalPlayer.Character then
                    createTag(target)
                    updateTag(target)
                else
                    removeTag(target)
                end
            elseif isNPC(target) then
                if NPCESPEnabled then
                    createTag(target)
                    updateTag(target)
                else
                    removeTag(target)
                end
            end
        end
    end
end

local function onCharacterAdded(player)
    player.CharacterAdded:Connect(function(char)
        wait(0.5)
        refreshTargets()
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    onCharacterAdded(player)
end

Players.PlayerAdded:Connect(onCharacterAdded)

RunService.RenderStepped:Connect(function()
    if not PlayerESPEnabled and not NPCESPEnabled then
        for _, target in pairs(Workspace:GetDescendants()) do
            if target:IsA("Model") and target:FindFirstChild("Humanoid") then
                removeTag(target)
            end
        end
        return
    end
    refreshTargets()
end)

local function createUI()
    if LocalPlayer.PlayerGui:FindFirstChild("BackroomsSurvivalUI") then
        return
    end

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
    Title.Text = "Backrooms Survival"
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
    SubTitle.Text = "Testing, made by F-197"
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
        refreshTargets()
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

    local ESPCatButton = Instance.new("TextButton")
    ESPCatButton.Size = UDim2.new(1, 0, 0, 35)
    ESPCatButton.Position = UDim2.new(0, 0, 0, 0)
    ESPCatButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ESPCatButton.Text = "👁️ESP👁️"
    ESPCatButton.TextColor3 = Color3.new(1, 1, 1)
    ESPCatButton.Font = Enum.Font.SourceSans
    ESPCatButton.TextSize = 18
    ESPCatButton.Parent = LeftPanel
    ESPCatButton.MouseButton1Click:Connect(function()
        ESPFrame.Visible = true
    end)

    local ESPFrame = Instance.new("Frame")
    ESPFrame.Size = UDim2.new(1, 0, 1, 0)
    ESPFrame.BackgroundTransparency = 1
    ESPFrame.Visible = true
    ESPFrame.Parent = RightPanel

    local ListContainer = Instance.new("Frame")
    ListContainer.Size = UDim2.new(1, -20, 1, -10)
    ListContainer.Position = UDim2.new(0, 10, 0, 5)
    ListContainer.BackgroundTransparency = 1
    ListContainer.Parent = ESPFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.FillDirection = Enum.FillDirection.Vertical
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.Parent = ListContainer

    local function createRow(labelText, initialState, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundTransparency = 1
        row.Parent = ListContainer

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

        return row
    end

    createRow("Player ESP", PlayerESPEnabled, function(value)
        PlayerESPEnabled = value
        refreshTargets()
    end)

    createRow("NPCs ESP", NPCESPEnabled, function(value)
        NPCESPEnabled = value
        refreshTargets()
    end)

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
