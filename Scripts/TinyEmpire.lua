local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- State
local collectEnabled = false
local tpEnabled = false
local COLLECT_INTERVAL = 1
local isDragging = false
local dragStart, startPos

-- All known farm types
local FARM_NAMES = {
    ["Apple Farm"] = true,
    ["Bakery"] = true,
    ["Bank"] = true,
    ["Bush Farm"] = true,
    ["Carrot Farm"] = true,
    ["Copper Mine"] = true,
    ["Diamond Mine"] = true,
    ["Fishing Pond"] = true,
    ["Flower Farm"] = true,
    ["Gold Mine"] = true,
    ["Market"] = true,
    ["Sheep Farm"] = true,
    ["Silver Mine"] = true,
    ["Smithy"] = true,
    ["Super Farm"] = true,
    ["Tomato Farm"] = true,
    ["Tree Farm"] = true,
    ["Wheat Farm"] = true,
}

local function getPlotCenter(plot)
    local basePart = plot:FindFirstChildWhichIsA("BasePart", true)
    if basePart then return basePart.Position end
    return nil
end

local function findPlayerPlot()
    local character = player.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local playerPos = rootPart.Position

    local plots = workspace:WaitForChild("Plots")
    local closestPlot, closestDist = nil, math.huge

    for _, plot in ipairs(plots:GetChildren()) do
        local center = getPlotCenter(plot)
        if center then
            local dist = (playerPos - center).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPlot = plot
            end
        end
    end

    if closestDist <= 500 then
        return closestPlot, closestDist
    end
    return nil
end

local function isFarmFull(prompt)
    local objectText = prompt.ObjectText or ""
    local nums = {}
    for n in objectText:gmatch("%d+") do
        table.insert(nums, tonumber(n))
    end
    if #nums == 0 then return true end
    if #nums >= 2 then
        return nums[1] >= 1
    end
    return nums[1] >= 1
end

local function teleportToPrompt(prompt)
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local targetPart = prompt.Parent
    if not targetPart:IsA("BasePart") then
        targetPart = prompt:FindFirstAncestorWhichIsA("BasePart") or prompt.Parent
    end

    local targetPos = targetPart.Position + Vector3.new(0, 5, 0)

    -- Smooth tween
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()  -- wait until arrived

    task.wait(0.2)  -- small delay so prompt registers
end

local function collectAllFarms(plot)
    local fired = 0
    local skipped = 0
    local buildingsFolder = plot:FindFirstChild("Buildings")
    if not buildingsFolder then return 0, 0 end

    for _, building in ipairs(buildingsFolder:GetChildren()) do
        local isFarm = false
        for farmName, _ in pairs(FARM_NAMES) do
            if building.Name:find(farmName, 1, true) then
                isFarm = true
                break
            end
        end

        if isFarm then
            local prompt = building:FindFirstChild("CollectPrompt", true)
            if prompt and prompt:IsA("ProximityPrompt") then
                if isFarmFull(prompt) then
                    if tpEnabled then
                        teleportToPrompt(prompt)
                    end

                    local oldDist = prompt.MaxActivationDistance
                    prompt.MaxActivationDistance = 999999
                    fireproximityprompt(prompt)
                    fired += 1

                    task.defer(function()
                        prompt.MaxActivationDistance = oldDist
                    end)

                    task.wait(0.08)  -- slightly longer delay when TP is used
                else
                    skipped += 1
                end
            end
        end
    end
    return fired, skipped
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 240, 0, 230)  -- made a bit taller
mainFrame.Position = UDim2.new(0, 20, 0.5, -115)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(40, 40, 55)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 36)
title.Position = UDim2.new(0, 12, 0, 8)
title.BackgroundTransparency = 1
title.Text = "IGCOGNITO - TINY EMPIRE"
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 0, 16)
statusLabel.Position = UDim2.new(0, 13, 0, 34)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "● IDLE"
statusLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
statusLabel.TextSize = 10
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -24, 0, 1)
divider.Position = UDim2.new(0, 12, 0, 56)
divider.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

local function makeToggleRow(labelText, yPos, defaultState)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 34)
    row.Position = UDim2.new(0, 12, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = mainFrame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -54, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 40, 0, 20)
    track.Position = UDim2.new(1, -40, 0.5, -10)
    track.BackgroundColor3 = defaultState and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(50, 50, 65)
    track.BorderSizePixel = 0
    track.Parent = row

    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = defaultState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = track
    Instance.new("UICorner", knob)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 3
    btn.Parent = track

    return btn, track, knob
end

local collectBtn, collectTrack, collectKnob = makeToggleRow("Auto Collect", 66, false)
local tpBtn, tpTrack, tpKnob = makeToggleRow("Teleport Method", 104, false)  -- New toggle

local plotLabel = Instance.new("TextLabel")
plotLabel.Size = UDim2.new(1, -24, 0, 16)
plotLabel.Position = UDim2.new(0, 12, 0, 148)
plotLabel.BackgroundTransparency = 1
plotLabel.Text = "Plot: Searching..."
plotLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
plotLabel.TextSize = 10
plotLabel.Font = Enum.Font.Gotham
plotLabel.TextXAlignment = Enum.TextXAlignment.Left
plotLabel.Parent = mainFrame

local lastCollectLabel = Instance.new("TextLabel")
lastCollectLabel.Size = UDim2.new(1, -24, 0, 16)
lastCollectLabel.Position = UDim2.new(0, 12, 0, 166)
lastCollectLabel.BackgroundTransparency = 1
lastCollectLabel.Text = "Collected: 0   ⏭ Skipped: 0"
lastCollectLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
lastCollectLabel.TextSize = 10
lastCollectLabel.Font = Enum.Font.Gotham
lastCollectLabel.TextXAlignment = Enum.TextXAlignment.Left
lastCollectLabel.Parent = mainFrame

local totalLabel = Instance.new("TextLabel")
totalLabel.Size = UDim2.new(1, -24, 0, 16)
totalLabel.Position = UDim2.new(0, 12, 0, 184)
totalLabel.BackgroundTransparency = 1
totalLabel.Text = "Total runs: 0"
totalLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
totalLabel.TextSize = 10
totalLabel.Font = Enum.Font.Gotham
totalLabel.TextXAlignment = Enum.TextXAlignment.Left
totalLabel.Parent = mainFrame

-- Toggle functions
local function animateToggle(track, knob, state)
    local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(track, tweenInfo, {BackgroundColor3 = state and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(50, 50, 65)}):Play()
    TweenService:Create(knob, tweenInfo, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
end

local function updateStatus()
    statusLabel.Text = collectEnabled and "● RUNNING" or "● IDLE"
    statusLabel.TextColor3 = collectEnabled and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(120, 120, 140)
end

collectBtn.MouseButton1Click:Connect(function()
    collectEnabled = not collectEnabled
    animateToggle(collectTrack, collectKnob, collectEnabled)
    updateStatus()
end)

tpBtn.MouseButton1Click:Connect(function()
    tpEnabled = not tpEnabled
    animateToggle(tpTrack, tpKnob, tpEnabled)
end)

-- Dragging
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- Main loop
local totalRuns = 0
local totalFired = 0
local totalSkipped = 0

while true do
    task.wait(COLLECT_INTERVAL)

    local myPlot, dist = findPlayerPlot()
    if myPlot then
        plotLabel.Text = myPlot.Name .. " (" .. math.floor(dist) .. " studs)"
        plotLabel.TextColor3 = Color3.fromRGB(80, 180, 100)
    else
        plotLabel.Text = "Plot: Not found"
        plotLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
    end

    if collectEnabled and myPlot then
        local ok, fired, skipped = pcall(collectAllFarms, myPlot)
        if ok then
            totalRuns += 1
            totalFired += (fired or 0)
            totalSkipped += (skipped or 0)
            lastCollectLabel.Text = "Collected: " .. totalFired .. "   ⏭ Skipped: " .. totalSkipped
            totalLabel.Text = "Total runs: " .. totalRuns
        else
            warn("[AutoFarm] Error:", fired)
        end
    end
end
