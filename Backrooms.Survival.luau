WindUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function CreateWindow(data)
    local window = {}
    local scr = Instance.new("ScreenGui")
    scr.Name = data.Folder or "WindUI"
    scr.ResetOnSpawn = false
    scr.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- 主框架 (中心锚点)
    local main = Instance.new("Frame")
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Size = UDim2.new(0, 460, 0, 380)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = scr

    -- 整体透明度控制容器
    local canvasGroup = Instance.new("CanvasGroup")
    canvasGroup.Size = UDim2.new(1, 0, 1, 0)
    canvasGroup.BackgroundTransparency = 1
    canvasGroup.GroupTransparency = 0
    canvasGroup.Parent = main

    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 44)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    titleBar.Parent = canvasGroup

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -90, 0, 22)
    titleText.Position = UDim2.new(0, 12, 0, 4)
    titleText.BackgroundTransparency = 1
    titleText.Text = data.Name or "WindUI"
    titleText.TextColor3 = Color3.new(1, 1, 1)
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local descText = Instance.new("TextLabel")
    descText.Size = UDim2.new(1, -90, 0, 16)
    descText.Position = UDim2.new(0, 12, 0, 26)
    descText.BackgroundTransparency = 1
    descText.Text = data.Description or ""
    descText.TextColor3 = Color3.fromRGB(180, 180, 180)
    descText.Font = Enum.Font.SourceSans
    descText.TextSize = 12
    descText.TextXAlignment = Enum.TextXAlignment.Left
    descText.Parent = titleBar

    -- 关闭按钮
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -38, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar
    closeBtn.Activated:Connect(function() scr:Destroy() end)

    -- 最小化按钮
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 32, 0, 32)
    minBtn.Position = UDim2.new(1, -76, 0, 6)
    minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.Font = Enum.Font.SourceSansBold
    minBtn.TextSize = 20
    minBtn.Parent = titleBar

    -- 内容区域
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -44)
    content.Position = UDim2.new(0, 0, 0, 44)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = canvasGroup

    -- 左侧面板 (手动定位按钮)
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 120, 1, 0)
    leftPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = content

    -- 右侧面板
    local rightPanel = Instance.new("Frame")
    rightPanel.Size = UDim2.new(1, -120, 1, 0)
    rightPanel.Position = UDim2.new(0, 120, 0, 0)
    rightPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = content

    local tabs = {}
    local currentTab = nil
    local buttonCount = 0
    local btnHeight = 38
    local btnPadding = 4

    function window.CreateTab(name)
        local tab = {}
        -- 计算按钮 Y 位置
        local yPos = buttonCount * (btnHeight + btnPadding) + 4
        buttonCount = buttonCount + 1

        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(1, -10, 0, btnHeight)
        btn.Position = UDim2.new(0, 5, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.Text = name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 15
        btn.Parent = leftPanel

        local container = Instance.new("ScrollingFrame")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.ScrollBarThickness = 5
        container.CanvasSize = UDim2.new(0, 0, 0, 0)
        container.Visible = false
        container.Parent = rightPanel

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.Padding = UDim.new(0, 10)
        layout.Parent = container
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)

        tab.Button = btn
        tab.Container = container

        function tab:AddLabel(text)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -24, 0, 26)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Color3.new(1, 1, 1)
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = container
        end

        function tab:AddToggle(labelText, initialState, callback)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 36)
            row.BackgroundTransparency = 1
            row.Parent = container

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.65, -12, 1, 0)
            label.Position = UDim2.new(0, 8, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = labelText
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.SourceSans
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = row

            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(0, 54, 0, 28)
            toggle.Position = UDim2.new(1, -60, 0.5, -14)
            toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            toggle.Text = ""
            toggle.Parent = row

            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 24, 0, 24)
            dot.Position = UDim2.new(0, 2, 0.5, -12)
            dot.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
            dot.BorderSizePixel = 0
            dot.Parent = toggle

            local state = initialState
            local function update(on)
                local pos, col, bg
                if on then
                    pos = UDim2.new(1, -26, 0.5, -12)
                    col = Color3.fromRGB(255, 255, 255)
                    bg = Color3.fromRGB(46, 204, 113)
                else
                    pos = UDim2.new(0, 2, 0.5, -12)
                    col = Color3.fromRGB(130, 130, 130)
                    bg = Color3.fromRGB(80, 80, 80)
                end
                TweenService:Create(dot, TweenInfo.new(0.2), {Position = pos, BackgroundColor3 = col}):Play()
                TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = bg}):Play()
            end
            update(state)
            toggle.Activated:Connect(function()
                state = not state
                callback(state)
                update(state)
            end)
        end

        function tab:AddButton(labelText, callback)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 36)
            row.BackgroundTransparency = 1
            row.Parent = container

            local btn2 = Instance.new("TextButton")
            btn2.Size = UDim2.new(1, -20, 1, 0)
            btn2.Position = UDim2.new(0, 10, 0, 0)
            btn2.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            btn2.Text = labelText
            btn2.TextColor3 = Color3.new(1, 1, 1)
            btn2.Font = Enum.Font.SourceSans
            btn2.TextSize = 14
            btn2.Parent = row
            btn2.Activated:Connect(callback)
        end

        btn.Activated:Connect(function()
            if currentTab then
                currentTab.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                currentTab.Container.Visible = false
            end
            btn.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
            container.Visible = true
            currentTab = tab
        end)

        table.insert(tabs, btn)
        return tab
    end

    function window.Destroy()
        scr:Destroy()
    end

    -- 动画与迷你条
    local minimized = false
    local savedSize = main.Size
    local minSize = UDim2.new(0, 345, 0, 285)

    local miniBar = Instance.new("Frame")
    miniBar.Size = UDim2.new(0, 210, 0, 38)
    miniBar.Position = UDim2.new(0.5, -105, 0, 8)
    miniBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    miniBar.BorderSizePixel = 0
    miniBar.Visible = false
    miniBar.Parent = scr

    local dragHandle = Instance.new("Frame")
    dragHandle.Size = UDim2.new(0, 54, 1, 0)
    dragHandle.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    dragHandle.Parent = miniBar
    local dhIcon = Instance.new("TextLabel")
    dhIcon.Size = UDim2.new(1, 0, 1, 0)
    dhIcon.BackgroundTransparency = 1
    dhIcon.Text = "⠿"
    dhIcon.TextColor3 = Color3.fromRGB(200,200,200)
    dhIcon.Font = Enum.Font.SourceSansBold
    dhIcon.TextSize = 20
    dhIcon.TextXAlignment = Enum.TextXAlignment.Center
    dhIcon.TextYAlignment = Enum.TextYAlignment.Center
    dhIcon.Parent = dragHandle

    local restoreBtn = Instance.new("TextButton")
    restoreBtn.Size = UDim2.new(1, -54, 1, 0)
    restoreBtn.Position = UDim2.new(0, 54, 0, 0)
    restoreBtn.BackgroundTransparency = 1
    restoreBtn.Text = ""
    restoreBtn.Parent = miniBar
    local miniTitle = Instance.new("TextLabel")
    miniTitle.Size = UDim2.new(1, -6, 1, 0)
    miniTitle.Position = UDim2.new(0, 3, 0, 0)
    miniTitle.BackgroundTransparency = 1
    miniTitle.Text = data.Name or "WindUI"
    miniTitle.TextColor3 = Color3.new(1, 1, 1)
    miniTitle.Font = Enum.Font.SourceSansBold
    miniTitle.TextSize = 14
    miniTitle.TextXAlignment = Enum.TextXAlignment.Left
    miniTitle.Parent = restoreBtn

    local function animateMinimize()
        minimized = true
        savedSize = main.Size
        local ti = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(main, ti, {Size = minSize}):Play()
        TweenService:Create(canvasGroup, ti, {GroupTransparency = 1}):Play()
        task.delay(0.4, function()
            main.Visible = false
            miniBar.Visible = true
            minBtn.Text = "+"
        end)
    end

    local function animateRestore()
        minimized = false
        miniBar.Visible = false
        main.Visible = true
        main.Size = minSize
        canvasGroup.GroupTransparency = 1
        local ti = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(main, ti, {Size = savedSize}):Play()
        TweenService:Create(canvasGroup, ti, {GroupTransparency = 0}):Play()
        minBtn.Text = "—"
    end

    minBtn.Activated:Connect(function()
        if minimized then animateRestore() else animateMinimize() end
    end)
    restoreBtn.Activated:Connect(function()
        if minimized then animateRestore() end
    end)

    -- 全窗口拖动（排除按钮）
    local dragging, dragStart, dragObj = false, nil, nil
    local function isButton(obj)
        while obj do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then return true end
            obj = obj.Parent
        end
        return false
    end

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            local objs = UserInputService:GetGuiObjectsAtPosition(pos.X, pos.Y)
            local foundBtn = false
            for _, obj in ipairs(objs) do
                if isButton(obj) then foundBtn = true break end
            end
            if foundBtn then return end

            if main.Visible then
                local mPos = main.AbsolutePosition
                local mSize = main.AbsoluteSize
                if pos.X >= mPos.X and pos.X <= mPos.X + mSize.X and pos.Y >= mPos.Y and pos.Y <= mPos.Y + mSize.Y then
                    dragging = true
                    dragStart = pos - mPos
                    dragObj = main
                end
            elseif miniBar.Visible then
                local mbPos = miniBar.AbsolutePosition
                local mbSize = miniBar.AbsoluteSize
                if pos.X >= mbPos.X and pos.X <= mbPos.X + mbSize.X and pos.Y >= mbPos.Y and pos.Y <= mbPos.Y + mbSize.Y then
                    dragging = true
                    dragStart = pos - mbPos
                    dragObj = miniBar
                end
            end
        end
    end

    local function onInputChanged(input)
        if dragging and dragObj and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            dragObj.Position = UDim2.new(0, pos.X - dragStart.X, 0, pos.Y - dragStart.Y)
        end
    end

    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            dragObj = nil
        end
    end

    UserInputService.InputBegan:Connect(onInputBegan)
    UserInputService.InputChanged:Connect(onInputChanged)
    UserInputService.InputEnded:Connect(onInputEnded)

    return window
end

-- 通知系统
local notifFrame
local function Notify(data)
    if not notifFrame then
        notifFrame = Instance.new("Frame")
        notifFrame.Size = UDim2.new(0, 320, 0, 0)
        notifFrame.Position = UDim2.new(1, -330, 1, -10)
        notifFrame.BackgroundTransparency = 1
        notifFrame.Parent = LocalPlayer:WaitForChild("PlayerGui")
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.Padding = UDim.new(0, 6)
        layout.Parent = notifFrame
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            notifFrame.Size = UDim2.new(0, 320, 0, layout.AbsoluteContentSize.Y + 10)
        end)
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 72)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(1, 10, 0, 0)
    frame.Parent = notifFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 26)
    title.Position = UDim2.new(0, 12, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = data.Title or "通知"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local cls = Instance.new("TextButton")
    cls.Size = UDim2.new(0, 26, 0, 26)
    cls.Position = UDim2.new(1, -32, 0, 4)
    cls.BackgroundColor3 = Color3.fromRGB(200,50,50)
    cls.Text = "✕"
    cls.TextColor3 = Color3.new(1,1,1)
    cls.Font = Enum.Font.SourceSansBold
    cls.TextSize = 14
    cls.Parent = frame
    cls.Activated:Connect(function() frame:Destroy() end)

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -24, 0, 30)
    desc.Position = UDim2.new(0, 12, 0, 34)
    desc.BackgroundTransparency = 1
    desc.Text = data.Text or ""
    desc.TextColor3 = Color3.fromRGB(200,200,200)
    desc.Font = Enum.Font.SourceSans
    desc.TextSize = 13
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    local dur = data.Duration or 4
    if dur > 0 then
        task.spawn(function()
            task.wait(dur)
            if frame.Parent then
                TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                task.wait(0.3)
                frame:Destroy()
            end
        end)
    end
end

WindUI.CreateWindow = CreateWindow
WindUI.Notify = Notify

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PlayerESPEnabled = false
local NPCESPEnabled = false
local FullbrightEnabled = false
local NoclipEnabled = false

function applyFullbright(on)
    if on then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.new(0,0,0)
        Lighting.OutdoorAmbient = Color3.new(0,0,0)
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
    end
end
Lighting.LightingChanged:Connect(function()
    if FullbrightEnabled then applyFullbright(true) end
end)

local noclipConn
function toggleNoclip(on)
    NoclipEnabled = on
    local char = LocalPlayer.Character
    if not char then return end
    if on then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if not LocalPlayer.Character then noclipConn:Disconnect(); noclipConn = nil; return end
            for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end

local NPCsFolder = Workspace:FindFirstChild("NPCs")
function isNPC(model)
    if not model or not model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    if not model:FindFirstChildOfClass("Humanoid") then return false end
    local p = model.Parent
    while p do
        if p == NPCsFolder then return true end
        p = p.Parent
    end
    return false
end

local playerTags, npcTags, tagTime = {}, {}, {}
Workspace.DescendantRemoving:Connect(function(d)
    if playerTags[d] then playerTags[d]:Destroy(); playerTags[d]=nil; tagTime[d]=nil end
    if npcTags[d] then npcTags[d]:Destroy(); npcTags[d]=nil; tagTime[d]=nil end
end)

function removeTag(t)
    local tag = playerTags[t] or npcTags[t]
    if tag then tag:Destroy(); playerTags[t]=nil; npcTags[t]=nil; tagTime[t]=nil end
end

function createTag(target, isPlayer)
    local dict = isPlayer and playerTags or npcTags
    if dict[target] then return end
    local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
    if not root then return end
    local tag = Instance.new("Folder"); tag.Name="ESPTag"; tag.Parent = target
    local hl = Instance.new("Highlight"); hl.Adornee=target; hl.FillTransparency=0.5
    hl.FillColor=Color3.fromRGB(128,0,255); hl.OutlineColor=Color3.new(1,1,1); hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=tag
    local bb = Instance.new("BillboardGui"); bb.Size=UDim2.new(0,300,0,30); bb.StudsOffset=Vector3.new(0,5,0)
    bb.AlwaysOnTop=true; bb.Adornee=root; bb.Parent=tag
    local lb = Instance.new("TextLabel"); lb.Size=UDim2.new(1,0,1,0); lb.BackgroundTransparency=1
    lb.TextColor3=Color3.new(1,1,1); lb.Font=Enum.Font.SourceSansBold; lb.TextSize=15
    lb.TextStrokeColor3=Color3.new(0,0,0); lb.TextStrokeTransparency=0.3; lb.Text="Loading..."; lb.Parent=bb
    dict[target]=tag; tagTime[target]=tick()
end

function updateTag(target)
    local tag = playerTags[target] or npcTags[target]
    if not tag then return end
    local bb = tag:FindFirstChild("Billboard")
    if not bb then return end
    local lb = bb:FindFirstChild("TextLabel")
    if not lb then return end
    if not LocalPlayer.Character then lb.Text="Loading..."; return end
    local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
    if not root then removeTag(target); return end
    local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
    if not pp then lb.Text="Loading..."; return end
    local dist = (root.Position - pp.Position).Magnitude
    if dist~=dist or dist==math.huge then removeTag(target); return end
    local nm = target.Name
    local plr = Players:GetPlayerFromCharacter(target)
    if plr then nm=plr.Name end
    local hum = target:FindFirstChildOfClass("Humanoid")
    local hp = hum and math.floor(hum.Health) or "??"
    lb.Text = nm .. " | " .. string.format("%.1f", dist) .. " m | HP: " .. hp
end

local playerESPConn, npcESPConn
function enablePlayerESP()
    if playerESPConn then return end
    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then
            local plr = Players:GetPlayerFromCharacter(m)
            if plr and m ~= LocalPlayer.Character then
                local root = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Head")
                if root and LocalPlayer.Character then
                    local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                    if pp and (root.Position-pp.Position).Magnitude <= 500 then
                        createTag(m, true); updateTag(m)
                    end
                end
            end
        end
    end
    playerESPConn = Workspace.DescendantAdded:Connect(function(d)
        if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") then
            local plr = Players:GetPlayerFromCharacter(d)
            if plr and d ~= LocalPlayer.Character then
                task.defer(function()
                    local root = d:FindFirstChild("HumanoidRootPart") or d:FindFirstChild("Head")
                    if root and LocalPlayer.Character then
                        local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                        if pp and (root.Position-pp.Position).Magnitude <= 500 then
                            createTag(d, true); updateTag(d)
                        end
                    end
                end)
            end
        end
    end)
end

function disablePlayerESP()
    if playerESPConn then playerESPConn:Disconnect(); playerESPConn=nil end
    for k,v in pairs(playerTags) do v:Destroy() end
    playerTags = {}
end

function enableNPCESP()
    if npcESPConn then return end
    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and isNPC(m) then
            local root = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Head")
            if root and LocalPlayer.Character then
                local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                if pp and (root.Position-pp.Position).Magnitude <= 500 then
                    createTag(m, false); updateTag(m)
                end
            end
        end
    end
    npcESPConn = Workspace.DescendantAdded:Connect(function(d)
        if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") and isNPC(d) then
            task.defer(function()
                local root = d:FindFirstChild("HumanoidRootPart") or d:FindFirstChild("Head")
                if root and LocalPlayer.Character then
                    local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                    if pp and (root.Position-pp.Position).Magnitude <= 500 then
                        createTag(d, false); updateTag(d)
                    end
                end
            end)
        end
    end)
end

function disableNPCESP()
    if npcESPConn then npcESPConn:Disconnect(); npcESPConn=nil end
    for k,v in pairs(npcTags) do v:Destroy() end
    npcTags = {}
end

local frameCnt = 0
RunService.Heartbeat:Connect(function()
    frameCnt += 1
    if frameCnt % 5 ~= 0 then return end
    local now = tick()
    local toRemove = {}
    for t, _ in pairs(playerTags) do
        if t and t:IsA("Model") and t:FindFirstChild("ESPTag") then
            local rp = t:FindFirstChild("HumanoidRootPart") or t:FindFirstChild("Head")
            local ok = false
            if rp and LocalPlayer.Character then
                local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                if pp and (rp.Position-pp.Position).Magnitude <= 500 then
                    ok = true; updateTag(t)
                end
            end
            if not ok then table.insert(toRemove, t) end
        else table.insert(toRemove, t) end
    end
    for t, _ in pairs(npcTags) do
        if t and t:IsA("Model") and t:FindFirstChild("ESPTag") then
            local rp = t:FindFirstChild("HumanoidRootPart") or t:FindFirstChild("Head")
            local ok = false
            if rp and LocalPlayer.Character then
                local pp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
                if pp and (rp.Position-pp.Position).Magnitude <= 500 then
                    ok = true; updateTag(t)
                end
            end
            if not ok then table.insert(toRemove, t) end
        else table.insert(toRemove, t) end
    end
    for _, t in ipairs(toRemove) do removeTag(t) end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if NoclipEnabled then toggleNoclip(true) end
end)

local win = WindUI.CreateWindow({
    Name = "Explorer Script",
    Description = "version：v0.2.0.5",
    Theme = "Dark",
    Keybind = Enum.KeyCode.RightShift,
    Folder = "ExplorerScript"
})

local updateTab = win:CreateTab("🔍更新内容🔍")
updateTab:AddLabel("version：v0.2.0.5")
updateTab:AddLabel("▪重置UI。")

local setTab = win:CreateTab("⚙️常规功能⚙️")
setTab:AddToggle("全图高亮", false, function(v)
    FullbrightEnabled = v; applyFullbright(v)
end)
setTab:AddToggle("无碰撞", false, function(v)
    toggleNoclip(v)
end)

local espTab = win:CreateTab("👁️透视👁️")
espTab:AddToggle("玩家ESP", false, function(v)
    PlayerESPEnabled = v
    if v then enablePlayerESP() else disablePlayerESP() end
end)
espTab:AddToggle("NPCs ESP", false, function(v)
    NPCESPEnabled = v
    if v then enableNPCESP() else disableNPCESP() end
end)

WindUI.Notify({
    Title = "ES脚本",
    Text = "加载成功。该脚本完全免费，如果你通过支付渠道获得该脚本，恭喜你被骗了😇",
    Duration = 8
})
