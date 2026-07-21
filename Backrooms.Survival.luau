local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = false

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

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Backrooms Survival"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 2.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar

local ToggleUIButton = Instance.new("TextButton")
ToggleUIButton.Size = UDim2.new(0, 30, 0, 30)
ToggleUIButton.Position = UDim2.new(1, -70, 0, 2.5)
ToggleUIButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleUIButton.Text = "-"
ToggleUIButton.TextColor3 = Color3.new(1, 1, 1)
ToggleUIButton.Font = Enum.Font.SourceSansBold
ToggleUIButton.TextSize = 22
ToggleUIButton.Parent = TitleBar

local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 120, 1, -35)
LeftPanel.Position = UDim2.new(0, 0, 0, 35)
LeftPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame

local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(1, -120, 1, -35)
RightPanel.Position = UDim2.new(0, 120, 0, 35)
RightPanel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
RightPanel.BorderSizePixel = 0
RightPanel.Parent = MainFrame

local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(1, 0, 0, 35)
ESPButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ESPButton.Text = "ESP"
ESPButton.TextColor3 = Color3.new(1, 1, 1)
ESPButton.Font = Enum.Font.SourceSans
ESPButton.TextSize = 18
ESPButton.Parent = LeftPanel

local ESPFrame = Instance.new("Frame")
ESPFrame.Size = UDim2.new(1, 0, 1, 0)
ESPFrame.BackgroundTransparency = 1
ESPFrame.Visible = false
ESPFrame.Parent = RightPanel

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

local ToggleDot = Instance.new("Frame")
ToggleDot.Size = UDim2.new(0, 22, 0, 22)
ToggleDot.Position = UDim2.new(0, 2, 0.5, -11)
ToggleDot.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
ToggleDot.BorderSizePixel = 0
ToggleDot.Parent = PlayerESPToggle

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleDot

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 4)
UICorner2.Parent = PlayerESPToggle

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 8)
UICorner3.Parent = MainFrame

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(0, 8)
UICorner4.Parent = TitleBar

local function updateESP(player)
	if player == LocalPlayer then return end
	if not player.Character then return end
	local char = player.Character
	local existing = char:FindFirstChild("BackroomsESP")
	if ESPEnabled then
		if not existing then
			local hl = Instance.new("Highlight")
			hl.Name = "BackroomsESP"
			hl.Adornee = char
			hl.FillTransparency = 0.7
			hl.OutlineTransparency = 0
			hl.Outlin
