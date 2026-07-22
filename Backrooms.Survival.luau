--[[
    WindUI - 简洁 UI 库
    修复：左侧标签正常显示、初始右侧空白、最小化/还原带透明度动画
]]
WindUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function CreateWindow(data)
    local window = {}
    local scr = create("ScreenGui", {
        Name = data.Folder or "WindUI",
        ResetOnSpawn = false,
        Parent = LocalPlayer:WaitForChild("PlayerGui")
    })

    -- 主框架
    local main = create("Frame", {
        Size = UDim2.new(0, 460, 0, 380),
        Position = UDim2.new(0.5, -230, 0.5, -190),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = scr
    })
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = main })

    -- 标题栏
    local titleBar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Parent = main
    })
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = titleBar })

    local titleText = create("TextLabel", {
        Size = UDim2.new(1, -90, 0, 22),
        Position = UDim2.new(0, 12, 0, 4),
        BackgroundTransparency = 1,
        Text = tostring(data.Name or "WindUI"),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })

    local descText = create("TextLabel", {
        Size = UDim2.new(1, -90, 0, 16),
        Position = UDim2.new(0, 12, 0, 26),
        BackgroundTransparency = 1,
        Text = tostring(data.Description or ""),
        TextColor3 = Color3.fromRGB(180, 180, 180),
        Font = Enum.Font.SourceSans,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })

    -- 关闭按钮
    local closeBtn = create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -38, 0, 6),
        BackgroundColor3 = Color3.fromRGB(220, 60, 60),
        Text = "✕",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
        Parent = titleBar
    })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = closeBtn })
    closeBtn.Activated:Connect(function() scr:Destroy() end)

    -- 最小化按钮
    local minBtn = create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -76, 0, 6),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Text = "—",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        Parent = titleBar
    })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = minBtn })

    -- 内容区域
    local contentContainer = create("Frame", {
        Size = UDim2.new(1, 0, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = main
    })

    -- 左侧标签列表（可滚动，确保按钮可见）
    local leftPanel = create("ScrollingFrame", {
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = contentContainer
    })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = leftPanel })

    local leftLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 4),
        Parent = leftPanel
    })
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        leftPanel.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 12)
    end)

    -- 右侧内容面板
    local rightPanel = create("Frame", {
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 120, 0, 0),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Parent = contentContainer
    })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = rightPanel })

    local tabButtons = {}
    local currentTab = nil

    local function createTab(name)
        local tab = {}
        -- 标签按钮（位于左侧）
        local btn = create("TextButton", {
            Name = name,
            Size = UDim2.new(1, -10, 0, 38),
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            Text = name,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.SourceSans,
            TextSize = 15,
            Parent = leftPanel
        })
        create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = btn })

        -- 右侧容器（初始隐藏）
        local container = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ClipsDescendants = true,
            Visible = false,               -- 初始不显示任何标签内容
            Parent = rightPanel
        })

        local layout = create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, 10),
            Parent = container
        })
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)

        tab.Button = btn
        tab.Container = container

        -- 添加标签
        tab.AddLabel = function(self, text)
            create("TextLabel", {
                Size = UDim2.new(1, -24, 0, 26),
                BackgroundTransparency = 1,
                Text = tostring(text),
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = container
            })
        end

        -- 添加开关
        tab.AddToggle = function(self, labelText, initialState, callback)
            local row = create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                Parent = container
            })
            create("TextLabel", {
                Size = UDim2.new(0.65, -12, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(labelText),
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row
            })
            local toggle = create("TextButton", {
                Size = UDim2.new(0, 54, 0, 28),
                Position = UDim2.new(1, -60, 0.5, -14),
                BackgroundColor3 = Color3.fromRGB(80, 80, 80),
                Text = "",
                Parent = row
            })
            create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = toggle })
            local dot = create("Frame", {
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(0, 2, 0.5, -12),
                BackgroundColor3 = Color3.fromRGB(130, 130, 130),
                BorderSizePixel = 0,
                Parent = toggle
            })
            create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })

            local state = initialState
            local function update(isOn)
                local targetPos, targetColor, bgColor
                if isOn then
                    targetPos = UDim2.new(1, -26, 0.5, -12)
                    targetColor = Color3.fromRGB(255, 255, 255)
                    bgColor = Color3.fromRGB(46, 204, 113)
                else
                    targetPos = UDim2.new(0, 2, 0.5, -12)
                    targetColor = Color3.fromRGB(130, 130, 130)
                    bgColor = Color3.fromRGB(80, 80, 80)
                end
                local tween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(dot, tween, {Position = targetPos, BackgroundColor3 = targetColor}):Play()
                TweenService:Create(toggle, tween, {BackgroundColor3 = bgColor}):Play()
            end
            update(state)

            toggle.Activated:Connect(function()
                state = not state
                callback(state)
                update(state)
            end)
        end

        -- 添加按钮
        tab.AddButton = function(self, labelText, callback)
            local row = create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                Parent = container
            })
            local btn2 = create("TextButton", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundColor3 = Color3.fromRGB(65, 65, 65),
                Text = tostring(labelText),
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                Parent = row
            })
            create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = btn2 })
            btn2.Activated:Connect(callback)
        end

        -- 标签切换逻辑
        btn.Activated:Connect(function()
            if currentTab then
                currentTab.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                currentTab.Container.Visible = false
            end
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            container.Visible = true
            currentTab = tab
        end)

        table.insert(tabButtons, btn)
        -- 不再自动激活第一个标签，右侧初始留空
        return tab
    end

    window.CreateTab = createTab
    window.Destroy = function() scr:Destroy() end

    -- 最小化 / 还原动画（含透明度淡入淡出）
    local minimized = false
    local savedPosition = main.Position
    local savedSize = main.Size
    local targetMinSize = UDim2.new(0, 345, 0, 285)

    -- 迷你条
    local miniBar = create("Frame", {
        Size = UDim2.new(0, 210, 0, 38),
        Position = UDim2.new(0.5, -105, 0, 8),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Visible = false,
        Parent = scr
    })
    create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = miniBar })

    local dragHandle = create("Frame", {
        Size = UDim2.new(0, 54, 1, 0),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        BorderSizePixel = 0,
        Parent = miniBar
    })
    create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dragHandle })
    create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "⠿",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = dragHandle
    })

    -- 还原按钮（完整点击触发）
    local restoreBtn = create("TextButton", {
        Size = UDim2.new(1, -54, 1, 0),
        Position = UDim2.new(0, 54, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = miniBar
    })
    create("TextLabel", {
        Size = UDim2.new(1, -6, 1, 0),
        Position = UDim2.new(0, 3, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(data.Name or "WindUI"),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = restoreBtn
    })

    -- 最小化动画（同时缩小+淡出）
    local function animateMinimize()
        savedPosition = main.Position
        savedSize = main.Size
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(main, tweenInfo, {
            Size = targetMinSize,
            Position = UDim2.new(0.5, -targetMinSize.X.Offset/2, 0.5, -targetMinSize.Y.Offset/2),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            main.Visible = false
            miniBar.Visible = true
            minBtn.Text = "+"
            contentContainer.Visible = false
        end)
    end

    -- 还原动画（同时放大+淡入）
    local function animateRestore()
        miniBar.Visible = false
        main.Visible = true
        main.Size = targetMinSize   -- 先设为最小尺寸
        main.Position = UDim2.new(0.5, -targetMinSize.X.Offset/2, 0.5, -targetMinSize.Y.Offset/2)
        main.BackgroundTransparency = 1
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(main, tweenInfo, {
            Size = savedSize,
            Position = savedPosition,
            BackgroundTransparency = 0
        })
        tween:Play()
        minBtn.Text = "—"
        contentContainer.Visible = true
    end

    minBtn.Activated:Connect(function()
        if minimized then
            minimized = false
            animateRestore()
        else
            minimized = true
            animateMinimize()
        end
    end)

    restoreBtn.Activated:Connect(function()
        if minimized then
            minimized = false
            animateRestore()
        end
    end)

    -- 拖动逻辑（排除关闭/最小化按钮）
    local dragging = false
    local dragOffset = Vector2.new()
    local dragTarget = nil

    local function isInsideButton(pos, button)
        local bp = button.AbsolutePosition
        local bs = button.AbsoluteSize
        return pos.X >= bp.X and pos.X <= bp.X + bs.X and pos.Y >= bp.Y and pos.Y <= bp.Y + bs.Y
    end

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = Vector2.new(input.Position.X, input.Position.Y)

            -- 排除关闭/最小化按钮区域
            if main.Visible then
                if isInsideButton(pos, closeBtn) or isInsideButton(pos, minBtn) then
                    return
                end
                local tbPos = titleBar.AbsolutePosition
                local tbSize = titleBar.AbsoluteSize
                if pos.X >= tbPos.X and pos.X <= tbPos.X + tbSize.X and pos.Y >= tbPos.Y and pos.Y <= tbPos.Y + tbSize.Y then
                    dragging = true
                    dragOffset = pos - Vector2.new(main.AbsolutePosition.X, main.AbsolutePosition.Y)
                    dragTarget = main
                    return
                end
            end
            if miniBar.Visible then
                local dhPos = dragHandle.AbsolutePosition
                local dhSize = dragHandle.AbsoluteSize
                if pos.X >= dhPos.X and pos.X <= dhPos.X + dhSize.X and pos.Y >= dhPos.Y and pos.Y <= dhPos.Y + dhSize.Y then
                    dragging = true
                    dragOffset = pos - Vector2.new(miniBar.AbsolutePosition.X, miniBar.AbsolutePosition.Y)
                    dragTarget = miniBar
                    return
                end
            end
        end
    end

    local function onInputChanged(input)
        if dragging and dragTarget and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            dragTarget.Position = UDim2.new(0, pos.X - dragOffset.X, 0, pos.Y - dragOffset.Y)
        end
    end

    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            dragTarget = nil
        end
    end

    UserInputService.InputBegan:Connect(onInputBegan)
    UserInputService.InputChanged:Connect(onInputChanged)
    UserInputService.InputEnded:Connect(onInputEnded)

    return window
end

-- 通知系统
local notificationContainer = nil
local function Notify(data)
    if not notificationContainer then
        notificationContainer = create("Frame", {
            Size = UDim2.new(0, 320, 0, 0),
            Position = UDim2.new(1, -330, 1, -10),
            BackgroundTransparency = 1,
            Parent = LocalPlayer:WaitForChild("PlayerGui")
        })
        local layout = create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = notificationContainer
        })
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            notificationContainer.Size = UDim2.new(0, 320, 0, layout.AbsoluteContentSize.Y + 10)
        end)
    end

    local frame = create("Frame", {
        Size = UDim2.new(0, 300, 0, 72),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(1, 10, 0, 0),
        Parent = notificationContainer
    })
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = frame })

    create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 26),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(data.Title or "通知"),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    local closeBtn = create("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -32, 0, 4),
        BackgroundColor3 = Color3.fromRGB(200, 50, 50),
        Text = "✕",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        Parent = frame
    })
    create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = closeBtn })
    closeBtn.Activated:Connect(function() frame:Destroy() end)

    create("TextLabel", {
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.new(0, 12, 0, 34),
        BackgroundTransparency = 1,
        Text = tostring(data.Text or ""),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.SourceSans,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = frame
    })

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(frame, tweenInfo, {Position = UDim2.new(0, 0, 0, 0)}):Play()

    local duration = data.Duration or 4
    if duration > 0 then
        task.spawn(function()
            task.wait(duration)
            if frame and frame.Parent then
                local fadeOut = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(frame, fadeOut, {BackgroundTransparency = 1}):Play()
                task.wait(0.3)
                frame:Destroy()
            end
        end)
    end
end

WindUI.CreateWindow = CreateWindow
WindUI.Notify = Notify
--[[
    全局服务、全图高亮、无碰撞、NPC检测、ESP标签管理
]]
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PlayerESPEnabled = false
local NPCESPEnabled = false
local FullbrightEnabled = false
local NoclipEnabled = false

-- 全图高亮
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

-- 无碰撞
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

-- NPC检测（基于 NPCs 文件夹）
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

-- ESP标签存储与清理
local playerTags = {}
local npcTags = {}
local tagCreationTime = {}

Workspace.DescendantRemoving:Connect(function(desc)
    if playerTags[desc] then
        local tag = playerTags[desc]
        if tag then tag:Destroy() end
        playerTags[desc] = nil
        tagCreationTime[desc] = nil
    end
    if npcTags[desc] then
        local tag = npcTags[desc]
        if tag then tag:Destroy() end
        npcTags[desc] = nil
        tagCreationTime[desc] = nil
    end
end)

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

    local rootPart = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
    if not rootPart then return end

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
    billboard.Adornee = rootPart
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
--[[
    玩家与NPC ESP 启用/禁用，使用 DescendantAdded 事件驱动
]]
local playerESPConnection = nil
local function enablePlayerESP()
    if playerESPConnection then return end
    for _, model in pairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
            local isPlayer = Players:GetPlayerFromCharacter(model)
            if isPlayer and model ~= LocalPlayer.Character then
                local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
                if root and LocalPlayer.Character then
                    local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                    if pp and (root.Position - pp.Position).Magnitude <= 500 then
                        createTag(model, true)
                        updateTag(model)
                    end
                end
            end
        end
    end
    playerESPConnection = Workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") then
            local isPlayer = Players:GetPlayerFromCharacter(desc)
            if isPlayer and desc ~= LocalPlayer.Character then
                task.defer(function()
                    local root = desc:FindFirstChild("HumanoidRootPart") or desc:FindFirstChild("Head")
                    if root and LocalPlayer.Character then
                        local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                        if pp and (root.Position - pp.Position).Magnitude <= 500 then
                            createTag(desc, true)
                            updateTag(desc)
                        end
                    end
                end)
            end
        end
    end)
end

local function disablePlayerESP()
    if playerESPConnection then
        playerESPConnection:Disconnect()
        playerESPConnection = nil
    end
    for target, tag in pairs(playerTags) do
        tag:Destroy()
    end
    playerTags = {}
end

local npcESPConnection = nil
local function enableNPCESP()
    if npcESPConnection then return end
    for _, model in pairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and isNPCModel(model) then
            local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
            if root and LocalPlayer.Character then
                local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                if pp and (root.Position - pp.Position).Magnitude <= 500 then
                    createTag(model, false)
                    updateTag(model)
                end
            end
        end
    end
    npcESPConnection = Workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") and isNPCModel(desc) then
            task.defer(function()
                local root = desc:FindFirstChild("HumanoidRootPart") or desc:FindFirstChild("Head")
                if root and LocalPlayer.Character then
                    local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                    if pp and (root.Position - pp.Position).Magnitude <= 500 then
                        createTag(desc, false)
                        updateTag(desc)
                    end
                end
            end)
        end
    end)
end

local function disableNPCESP()
    if npcESPConnection then
        npcESPConnection:Disconnect()
        npcESPConnection = nil
    end
    for target, tag in pairs(npcTags) do
        tag:Destroy()
    end
    npcTags = {}
end
--[[
    心跳循环：每5帧更新标签文本，移除超距/失效标签
    本地玩家重生时恢复无碰撞状态
]]
local frameCounter = 0
RunService.Heartbeat:Connect(function()
    frameCounter = frameCounter + 1
    if frameCounter % 5 ~= 0 then return end

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
                if label and label.Text == "Loading..." and tagCreationTime[target] and now - tagCreationTime[target] > 3 then
                    table.insert(toRemove, target)
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
                if label and label.Text == "Loading..." and tagCreationTime[target] and now - tagCreationTime[target] > 3 then
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
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if NoclipEnabled then
        toggleNoclip(true)
    end
end)
--[[
    创建主窗口与标签页，绑定所有功能开关
]]
local MainWindow = WindUI.CreateWindow({
    Name = "Explorer Script",
    Description = "version：v0.2.0.6",
    Theme = "Dark",
    Keybind = Enum.KeyCode.RightShift,
    Folder = "ExplorerScript"
})

local UpdateTab = MainWindow:CreateTab("🔍更新内容🔍")
UpdateTab:AddLabel("v0.2.0.6")
UpdateTab:AddLabel("▪ 左侧标签列表正常显示")
UpdateTab:AddLabel("▪ 初始右侧界面空白")
UpdateTab:AddLabel("▪ 最小化/还原带透明度动画")

local SettingsTab = MainWindow:CreateTab("⚙️常规功能⚙️")
SettingsTab:AddToggle("全图高亮", FullbrightEnabled, function(value)
    FullbrightEnabled = value
    applyFullbright(value)
end)
SettingsTab:AddToggle("无碰撞", NoclipEnabled, function(value)
    toggleNoclip(value)
end)

local ESPTab = MainWindow:CreateTab("👁️透视👁️")
ESPTab:AddToggle("玩家ESP", PlayerESPEnabled, function(value)
    PlayerESPEnabled = value
    if value then
        enablePlayerESP()
    else
        disablePlayerESP()
    end
end)
ESPTab:AddToggle("NPCs ESP", NPCESPEnabled, function(value)
    NPCESPEnabled = value
    if value then
        enableNPCESP()
    else
        disableNPCESP()
    end
end)

WindUI.Notify({
    Title = "ES脚本",
    Text = "加载成功，UI已优化。该脚本完全免费，如果你通过支付渠道获得，恭喜你被骗了😇",
    Duration = 8
})
