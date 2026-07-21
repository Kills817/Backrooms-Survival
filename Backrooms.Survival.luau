--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- State
local ESPEnabled = false
local UIMinimized = false

-- ESP Logic
local function updateESP(player: Player)
    if player == LocalPlayer then return end
    if not player.Character then return end

    local char = player.Character
    local hl = char:FindFirstChild("BackroomsESP")

    if ESPEnabled then
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "BackroomsESP"
            hl.Adornee = char
            hl.Parent = char
        end
        hl.FillTransparency = 0.5
        hl.FillColor = Color3.fromRGB(128, 0, 255)
        hl.OutlineTransparency = 0
        hl.OutlineColor = Color3.new(1, 1, 1)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.DistanceMode = Enum.HighlightDistanceMode.AlwaysOnTop
        hl.Enabled = true
    else
        if hl then
            hl:Destroy()
        end
    end
end

local function rescanAll()
    for _, player in pairs(Players:GetPlayers()) do
        updateESP(player)
    end
end

local function setupPlayerEvents(player: Player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        updateESP(player)
    end)
end

Players.PlayerAdded:Connect(setupPlayerEvents)
for _, player in pairs(Players:GetPlayers()) do
    setupPlayerEvents(player)
end

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hl = player.Character:FindFirstChild("BackroomsESP")
                if hl then
                    hl.Enabled = true
                end
            end
        end
    end
end)

-- UI Creation
local function createUI()
    -- Prevent duplicate UI
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

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.Parent = MainFrame

    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 8)
    TitleBarCorner.Parent = TitleBar

    -- Main Title
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

    -- Subtitle
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
    CloseButton.Activated:Connect(function()
        ESPEnabled = false
        rescanAll()
        ScreenGui:Destroy()
    end)

    -- Minimize/Expand Button
    local ToggleUIButton = Instance.new("TextButton")
    ToggleUIButton.Size = UDim2.new(0, 30, 0, 30)
    ToggleUIButton.Position = UDim2.new(1, -70, 0, 10)
    ToggleUIButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleUIButton.Text = "-"
    ToggleUIButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleUIButton.Font = Enum.Font.SourceSansBold
    ToggleUIButton.TextSize = 22
    ToggleUIButton.Parent = TitleBar

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

    -- Category Buttons
    local ESPButton = Instance.new("TextButton")
    ESPButton.Size = UDim2.new(1, 0, 0, 35)
    ESPButton.Position = UDim2.new(0, 0, 0, 0)
    ESPButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ESPButton.Text = "ESP"
    ESPButton.TextColor3 = Color3.new(1, 1, 1)
    ESPButton.Font = Enum.Font.SourceSans
    ESPButton.TextSize = 18
    ESPButton.Parent = LeftPanel
    ESPButton.Activated:Connect(function()
        ESPFrame.Visible = true
    end)

    -- ESP Frame (content area)
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

    -- Helper: create toggle row
    local function createFeatureRow(labelText, initialState, onToggle)
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

        local currentState = initialState

        local function updateVisual(state)
            local targetPos, targetColor, bgColor
            if state then
                targetPos = UDim2.new(1, -24, 0.5, -11)
                targetColor = Color3.fromRGB(255, 255, 255)
                bgColor = Color3.fromRGB(46, 204, 113)
            else
                targetPos = UDim2.new(0, 2, 0.5, -11)
                targetColor = Color3.fromRGB(120, 120, 120)
                bgColor = Color3.fromRGB(80, 80, 80)
            end
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local dotTween = TweenService:Create(dot, tweenInfo, { Position = targetPos, BackgroundColor3 = targetColor })
            dotTween:Play()
            local bgTween = TweenService:Create(toggleBtn, tweenInfo, { BackgroundColor3 = bgColor })
            bgTween:Play()
        end

        updateVisual(initialState)

        toggleBtn.Activated:Connect(function()
            currentState = not currentState
            onToggle(currentState)
            updateVisual(currentState)
        end)

        return row, toggleBtn, dot
    end

    -- Create Player ESP row
    createFeatureRow("Player ESP", ESPEnabled, function(state)
        ESPEnabled = state
        rescanAll()
    end)

    -- Minimize/Expand
    ToggleUIButton.Activated:Connect(function()
        UIMinimized = not UIMinimized
        local goalSize = UIMinimized and UDim2.new(0, 400, 0, 50) or UDim2.new(0, 400, 0, 250)
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = goalSize })
        tween:Play()
        ToggleUIButton.Text = UIMinimized and "+" or "-"

        if UIMinimized then
            ContentContainer.Visible = false
            ContentContainer.Size = UDim2.new(0, 0, 0, 0)
        else
            ContentContainer.Visible = true
            ContentContainer.Size = UDim2.new(1, 0, 1, -50)
        end
    end)

    -- Drag (TitleBar only, both mouse & touch)
    local dragging = false
    local dragOffset = Vector2.new()

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragOffset = input.Position - MainFrame.AbsolutePosition
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local newPos = input.Position - dragOffset
            MainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
        end
    end)

    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return ScreenGui, MainFrame
end

createUI()
