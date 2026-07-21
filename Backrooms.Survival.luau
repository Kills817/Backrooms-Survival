--!strict
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- State
local ESPEnabled = false
local UIMinimized = false
local TweenDotAnimation = nil

-- UI Creation
local function createUI()
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
    SubTitle.Position = UDim2.new(0, 10, 0, 27)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "Testing, make by F-197"
    SubTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
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
    ToggleUIButton.MouseButton1Click:Connect(function()
        UIMinimized = not UIMinimized
        local goalSize = UIMinimized and UDim2.new(0, 400, 0, 50) or UDim2.new(0, 400, 0, 250)
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = goalSize })
        tween:Play()
        ToggleUIButton.Text = UIMinimized and "+" or "-"
        LeftPanel.Visible = not UIMinimized
        RightPanel.Visible = not UIMinimized
    end)

    -- Left Panel
    local LeftPanel = Instance.new("Frame")
    LeftPanel.Size = UDim2.new(0, 120, 1, -50)
    LeftPanel.Position = UDim2.new(0, 0, 0, 50)
    LeftPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    LeftPanel.BorderSizePixel = 0
    LeftPanel.Parent = MainFrame

    -- Right Panel
    local RightPanel = Instance.new("Frame")
    RightPanel.Size = UDim2.new(1, -120, 1, -50)
    RightPanel.Position = UDim2.new(0, 120, 0, 50)
    RightPanel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    RightPanel.BorderSizePixel = 0
    RightPanel.Parent = MainFrame

    -- ESP Button
    local ESPButton = Instance.new("TextButton")
    ESPButton.Size = UDim2.new(1, 0, 0, 35)
    ESPButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ESPButton.Text = "ESP"
    ESPButton.TextColor3 = Color3.new(1, 1, 1)
    ESPButton.Font = Enum.Font.SourceSans
    ESPButton.TextSize = 18
    ESPButton.Parent = LeftPanel
    ESPButton.MouseButton1Click:Connect(function()
        ESPFrame.Visible = true
    end)

    -- ESP Frame
    local ESPFrame = Instance.new("Frame")
    ESPFrame.Size = UDim2.new(1, 0, 1, 0)
    ESPFrame.BackgroundTransparency = 1
    ESPFrame.Visible = false
    ESPFrame.Parent = RightPanel

    -- Player ESP Toggle
    local PlayerESPContainer = Instance.new("Frame")
    PlayerESPContainer.Size = UDim2.new(1, -20, 0, 40)
    PlayerESPContainer.Position = UDim2.new(0, 10, 0, 10)
    PlayerESPContainer.BackgroundTransparency = 1
    PlayerESPContainer.Parent = ESPFrame

    local PlayerESPLabel = Instance.new("TextLabel")
    PlayerESPLabel.Size = UDim2.new(1, -60, 1, 0)
    PlayerESPLabel.BackgroundTransparency = 1
    PlayerESPLabel.Text = "Player ESP"
    PlayerESPLabel.TextColor3 = Color3.new(1, 1, 1)
    PlayerESPLabel.Font = Enum.Font.SourceSans
    PlayerESPLabel.TextSize = 18
    PlayerESPLabel.TextXAlignment = Enum.TextXAlignment.Left
    PlayerESPLabel.Parent = PlayerESPContainer

    local PlayerESPToggle = Instance.new("TextButton")
    PlayerESPToggle.Size = UDim2.new(0, 50, 0, 26)
    PlayerESPToggle.Position = UDim2.new(1, -50, 0.5, -13)
    PlayerESPToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    PlayerESPToggle.Text = ""
    PlayerESPToggle.Parent = PlayerESPContainer

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = PlayerESPToggle

    local ToggleDot = Instance.new("Frame")
    ToggleDot.Size = UDim2.new(0, 22, 0, 22)
    ToggleDot.Position = UDim2.new(0, 2, 0.5, -11)
    ToggleDot.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    ToggleDot.BorderSizePixel = 0
    ToggleDot.Parent = PlayerESPToggle

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = ToggleDot

    local function updateToggleVisual()
        if TweenDotAnimation then
            TweenDotAnimation:Cancel()
            TweenDotAnimation = nil
        end

        local targetPos, targetColor, bgColor
        if ESPEnabled then
            targetPos = UDim2.new(1, -24, 0.5, -11)
            targetColor = Color3.fromRGB(255, 255, 255)
            bgColor = Color3.fromRGB(46, 204, 113)
        else
            targetPos = UDim2.new(0, 2, 0.5, -11)
            targetColor = Color3.fromRGB(120, 120, 120)
            bgColor = Color3.fromRGB(80, 80, 80)
        end

        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenDotAnimation = TweenService:Create(ToggleDot, tweenInfo, { Position = targetPos, BackgroundColor3 = targetColor })
        TweenDotAnimation:Play()

        local bgTween = TweenService:Create(PlayerESPToggle, tweenInfo, { BackgroundColor3 = bgColor })
        bgTween:Play()
    end

    PlayerESPToggle.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        updateToggleVisual()
        rescanAll()
    end)

    ESPFrame.Visible = true
    updateToggleVisual()

    return ScreenGui, MainFrame, LeftPanel, RightPanel, ESPFrame
end

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

createUI()
