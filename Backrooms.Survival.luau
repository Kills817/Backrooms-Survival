--[[
    WindUI - 简洁的 UI 库 + 通知系统
    修复：Tab 内容正确显示、最小化还原改为点击触发（非触摸即发）
    优化：滚动条厚度、颜色、布局间距，更人性化
]]
WindUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 帮助函数：快速创建 GUI 对象
local function create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

-- 创建窗口
local function CreateWindow(data)
    local window = {}
    local scr = create("ScreenGui", {
        Name = data.Folder or "WindUI",
        ResetOnSpawn = false,
        Parent = LocalPlayer:WaitForChild("PlayerGui")
    })

    -- 主框架
    local main = create("Frame", {
        Size = UDim2.new(0, 450, 0, 350),
        Position = UDim2.new(0.5, -225, 0.5, -175),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = scr
    })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = main })

    -- 标题栏
    local titleBar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Parent = main
    })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = titleBar })

    local titleText = create("TextLabel", {
        Size = UDim2.new(1, -80, 0, 20),
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
        Size = UDim2.new(1, -80, 0, 16),
        Position = UDim2.new(0, 12, 0, 24),
        BackgroundTransparency = 1,
        Text = tostring(data.Description or ""),
        TextColor3 = Color3.fromRGB(180, 180, 180),
        Font = Enum.Font.SourceSans,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })

    -- 关闭 / 最小化按钮
    local closeBtn = create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 5),
        BackgroundColor3 = Color3.fromRGB(200, 50, 50),
        Text = "✕",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
        Parent = titleBar
    })
    closeBtn.MouseButton1Click:Connect(function() scr:Destroy() end)

    local minBtn = create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0, 5),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Text = "—",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        Parent = titleBar
    })

    -- 内容区域
    local contentContainer = create("Frame", {
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = main
    })

    local leftPanel = create("Frame", {
        Size = UDim2.new(0, 110, 1, 0),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Parent = contentContainer
    })

    local rightPanel = create("Frame", {
        Size = UDim2.new(1, -110, 1, 0),
        Position = UDim2.new(0, 110, 0, 0),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Parent = contentContainer
    })

    -- 左侧标签按钮列表
    local tabButtons = {}
    local currentTab = nil

    -- 创建标签页
    local function createTab(name)
        local tab = {}
        
        -- 标签按钮
        local btn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Text = tostring(name),
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.SourceSans,
            TextSize = 15,
            Parent = leftPanel
        })

        -- 右侧滚动容器
        local container = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ClipsDescendants = true,
            Visible = false,
            Parent = rightPanel
        })

        local layout = create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, 8),
            Parent = container
        })
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
        end)

        tab.Button = btn
        tab.Container = container

        -- 添加标签
        tab.AddLabel = function(self, text)
            local lbl = create("TextLabel", {
                Size = UDim2.new(1, -20, 0, 24),
                Position = UDim2.new(0, 10, 0, 0),
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
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                Parent = container
            })
            local label = create("TextLabel", {
                Size = UDim2.new(0.65, -10, 1, 0),
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
                Size = UDim2.new(0, 50, 0, 26),
                Position = UDim2.new(1, -54, 0.5, -13),
                BackgroundColor3 = Color3.fromRGB(80, 80, 80),
                Text = "",
                Parent = row
            })
            create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = toggle })
            local dot = create("Frame", {
                Size = UDim2.new(0, 22, 0, 22),
                Position = UDim2.new(0, 2, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(120, 120, 120),
                BorderSizePixel = 0,
                Parent = toggle
            })
            create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })

            local state = initialState
            local function update(isOn)
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
                TweenService:Create(toggle, tween, {BackgroundColor3 = bgColor}):Play()
            end
            update(state)

            toggle.MouseButton1Click:Connect(function()
                state = not state
                callback(state)
                update(state)
            end)
        end

        -- 添加按钮
        tab.AddButton = function(self, labelText, callback)
            local row = create("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                Parent = container
            })
            local btn = create("TextButton", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                Text = tostring(labelText),
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                Parent = row
            })
            create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = btn })
            btn.MouseButton1Click:Connect(callback)
        end

        -- 标签切换
        btn.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                currentTab.Container.Visible = false
            end
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            container.Visible = true
            currentTab = tab
        end)

        table.insert(tabButtons, btn)
        -- 首个标签自动激活
        if #tabButtons == 1 then
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            container.Visible = true
            currentTab = tab
        end
        return tab
    end

    window.CreateTab = createTab
    window.Destroy = function() scr:Destroy() end

    -- 最小化 / 恢复动画
    local minimized = false
    local savedPosition = main.Position
    local savedSize = main.Size
    local targetMinSize = UDim2.new(0, 337.5, 0, 262.5)

    -- 迷你条
    local miniBar = create("Frame", {
        Size = UDim2.new(0, 200, 0, 34),
        Position = UDim2.new(0.5, -100, 0, 8),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Visible = false,
        Parent = scr
    })
    create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = miniBar })

    -- 拖拽手柄（左侧）
    local dragHandle = create("Frame", {
        Size = UDim2.new(0, 50, 1, 0),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
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
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = dragHandle
    })

    -- 右侧点击还原区域（透明按钮，防止一触即发）
    local restoreBtn = create("TextButton", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 50, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = miniBar
    })
    -- 标题显示在按钮上方
    create("TextLabel", {
        Size = UDim2.new(1, -4, 1, 0),
        Position = UDim2.new(0, 2, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(data.Name or "WindUI"),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = restoreBtn
    })

    local function animateMinimize()
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(main, tweenInfo, {
            Size = targetMinSize,
            Position = UDim2.new(0.5, -targetMinSize.X.Offset/2, 0.5, -targetMinSize.Y.Offset/2),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.4)
        main.Visible = false
        miniBar.Visible = true
        minBtn.Text = "+"
        contentContainer.Visible = false
    end

    local function animateRestore()
        miniBar.Visible = false
        main.Visible = true
        main.Size = targetMinSize
        main.Position = UDim2.new(0.5, -targetMinSize.X.Offset/2, 0.5, -targetMinSize.Y.Offset/2)
        main.BackgroundTransparency = 1
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(main, tweenInfo, {
            Size = savedSize,
            Position = savedPosition,
            BackgroundTransparency = 0
        }):Play()
        minBtn.Text = "—"
        contentContainer.Visible = true
    end

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            savedPosition = main.Position
            savedSize = main.Size
            animateMinimize()
        else
            animateRestore()
        end
    end)

    restoreBtn.MouseButton1Click:Connect(function()
        if minimized then
            minimized = false
            animateRestore()
        end
    end)

    -- 窗口拖动逻辑
    local dragging = false
    local dragOffset = Vector2.new()
    local dragTarget = nil

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            -- 主窗口拖动：标题栏
            if main.Visible then
                local tbPos = titleBar.AbsolutePosition
                local tbSize = titleBar.AbsoluteSize
                if pos.X >= tbPos.X and pos.X <= tbPos.X + tbSize.X and pos.Y >= tbPos.Y and pos.Y <= tbPos.Y + tbSize.Y then
                    dragging = true
                    dragOffset = pos - Vector2.new(main.AbsolutePosition.X, main.AbsolutePosition.Y)
                    dragTarget = main
                    return
                end
            end
            -- 迷你条拖动：仅拖拽手柄
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
        Size = UDim2.new(0, 300, 0, 70),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(1, 10, 0, 0),
        Parent = notificationContainer
    })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = frame })

    create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 24),
        Position = UDim2.new(0, 10, 0, 4),
        BackgroundTransparency = 1,
        Text = tostring(data.Title or "通知"),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    local closeBtn = create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0, 4),
        BackgroundColor3 = Color3.fromRGB(200, 50, 50),
        Text = "✕",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        Parent = frame
    })
    create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = closeBtn })
    closeBtn.MouseButton1Click:Connect(function() frame:Destroy() end)

    create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 30),
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
    全局变量声明、辅助函数、全图高亮、无碰撞、ESP 基础框架
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

-- NPC 检测（基于 NPCs 文件夹）
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

-- ESP 标签存储
local playerTags = {}
local npcTags = {}
local tagCreationTime = {}

-- 模型被移除时自动清理对应标签
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

-- 移除指定标签
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

-- 创建 ESP 标签（Highlight + Billboard）
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
    billboard.Adornee = rootPart   -- 附着到根部件，位置准确
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

-- 更新标签文字
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
    玩家 ESP 与 NPC ESP 的启用/禁用逻辑，使用 DescendantAdded 事件驱动
]]
-- 玩家 ESP 事件连接
local playerESPConnection = nil
local function enablePlayerESP()
    if playerESPConnection then return end
    -- 初始扫描现有玩家
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
    -- 监听新加入的玩家模型
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

-- NPC ESP 事件连接
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
    心跳循环：定期更新标签文字、移除超距或失效标签
    本地玩家重生时重新应用无碰撞和 ESP 状态
]]
local frameCounter = 0
RunService.Heartbeat:Connect(function()
    frameCounter = frameCounter + 1
    if frameCounter % 5 ~= 0 then return end  -- 每 5 帧检查一次

    local now = tick()
    local toRemove = {}

    -- 检查所有玩家标签
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
                -- 额外检查：如果标签文字长时间显示 "Loading..." 则移除
                local label = tag:FindFirstChild("Billboard") and tag.Billboard:FindFirstChild("Label")
                if label and label.Text == "Loading..." and tagCreationTime[target] and now - tagCreationTime[target] > 3 then
                    table.insert(toRemove, target)
                end
            end
        else
            table.insert(toRemove, target)
        end
    end

    -- 检查所有 NPC 标签
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

-- 本地玩家重生时恢复无碰撞状态
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if NoclipEnabled then
        toggleNoclip(true)
    end
    -- ESP 会自动通过事件处理，无需额外操作
end)

--[[
    创建主窗口和标签页，绑定全图高亮、无碰撞、ESP 开关
]]
local MainWindow = WindUI.CreateWindow({
    Name = "Explorer Script",
    Description = "version：v0.2.0.5",
    Theme = "Dark",
    Keybind = Enum.KeyCode.RightShift,
    Folder = "ExplorerScript"
})

local UpdateTab = MainWindow:CreateTab("🔍更新内容🔍")
UpdateTab:AddLabel("version：v0.2.0.5")
UpdateTab:AddLabel("▪ 重置UI，修复ESP崩溃。")
UpdateTab:AddLabel("▪ 优化最小化还原为点击触发。")
UpdateTab:AddLabel("▪ 性能提升：事件驱动ESP。")

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
    Text = "加载成功。该脚本完全免费，如果你通过支付渠道获得该脚本，恭喜你被骗了😇",
    Duration = 8
})
