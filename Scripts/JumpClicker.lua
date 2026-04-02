--Made by ai fully please support me

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local UnlockedWorlds = Player:WaitForChild("UnlockedWorlds")
local TrainEvent = ReplicatedStorage:WaitForChild("IncreaseSpeed") -- Train eventi

-- UI Construction
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local FarmButton = Instance.new("TextButton")
local TrainButton = Instance.new("TextButton") -- Egg yerine Train geldi
local WorldScroll = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "RedTowerUltimate_V12_Train"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Window
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -175)
MainFrame.Size = UDim2.new(0, 350, 0, 380)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Title
Title.Text = "Jump clicker"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

-- Close Button
CloseButton.Parent = MainFrame
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 2)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 8)

-- World Scroll
WorldScroll.Parent = MainFrame
WorldScroll.Position = UDim2.new(0.05, 0, 0.35, 0)
WorldScroll.Size = UDim2.new(0.45, 0, 0.6, 0)
WorldScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
WorldScroll.ScrollBarThickness = 4
UIListLayout.Parent = WorldScroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Logic Variables
local farming = false
local training = false
local selectedWorldInternal = "World1"

local worldSettings = {
    {real = "World1", display = "Earth"}, {real = "World2", display = "Moon"},
    {real = "World3", display = "Lava"}, {real = "World4", display = "Ice"},
    {real = "World5", display = "Flower"}, {real = "World6", display = "Snow"},
    {real = "World7", display = "Dark"}, {real = "World8", display = "Void"},
    {real = "World9", display = "Desert"}, {real = "World10", display = "Forest"},
    {real = "World11", display = "Candy"}, {real = "World12", display = "Steampunk"},
    {real = "World13", display = "Beach"}, {real = "World14", display = "Heaven"}
}

local function isWorldUnlocked(realName, displayName)
    if realName == "World1" or displayName == "Earth" then return true end
    return UnlockedWorlds:FindFirstChild(realName) ~= nil or UnlockedWorlds:FindFirstChild(displayName) ~= nil
end

-- Create World Buttons
for i, settings in ipairs(worldSettings) do
    local btn = Instance.new("TextButton")
    btn.Parent = WorldScroll
    btn.Size = UDim2.new(0.95, 0, 0, 35)
    btn.LayoutOrder = i
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local function updateUI()
        local unlocked = isWorldUnlocked(settings.real, settings.display)
        if settings.real == selectedWorldInternal then
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            btn.Text = settings.display .. " [SEL]"
        elseif unlocked then
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            btn.Text = settings.display
        else
            btn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
            btn.Text = settings.display .. " [Lock]"
        end
    end

    btn.MouseButton1Click:Connect(function()
        if isWorldUnlocked(settings.real, settings.display) then
            selectedWorldInternal = settings.real
        end
    end)

    task.spawn(function()
        while ScreenGui.Parent do updateUI() task.wait(1) end
    end)
end

WorldScroll.CanvasSize = UDim2.new(0, 0, 0, (#worldSettings * 40) + 10)

-- Farm & Train Buttons
FarmButton.Parent = MainFrame
FarmButton.Position = UDim2.new(0.05, 0, 0.15, 0)
FarmButton.Size = UDim2.new(0.9, 0, 0, 50)
FarmButton.Text = "WORLD FARM: OFF"
FarmButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmButton.Font = Enum.Font.GothamBold
FarmButton.TextScaled = true
Instance.new("UICorner", FarmButton)

TrainButton.Parent = MainFrame
TrainButton.Position = UDim2.new(0.55, 0, 0.45, 0)
TrainButton.Size = UDim2.new(0.4, 0, 0, 45)
TrainButton.Text = "AUTO TRAIN: OFF"
TrainButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TrainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TrainButton.Font = Enum.Font.GothamBold
TrainButton.TextScaled = true
Instance.new("UICorner", TrainButton)

-- Teleport Logic
local function teleport()
    local target = Workspace:FindFirstChild("Wins") and Workspace.Wins:FindFirstChild(selectedWorldInternal)
    if target and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local cf = target:IsA("Model") and target:GetPivot() or target.CFrame
        Player.Character.HumanoidRootPart.CFrame = cf * CFrame.new(0, 5, 0)
    end
end

FarmButton.MouseButton1Click:Connect(function()
    farming = not farming
    FarmButton.BackgroundColor3 = farming and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 60)
    FarmButton.Text = farming and "WORLD FARM: ON" or "WORLD FARM: OFF"
end)

TrainButton.MouseButton1Click:Connect(function()
    training = not training
    TrainButton.BackgroundColor3 = training and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(60, 60, 60)
    TrainButton.Text = training and "TRAIN: ON" or "TRAIN: OFF"
end)

CloseButton.MouseButton1Click:Connect(function()
    farming = false training = false ScreenGui:Destroy()
end)

-- Main Loops
task.spawn(function()
    while ScreenGui.Parent do
        if farming then teleport() end
        task.wait(5)
    end
end)

-- Auto Train Loop
task.spawn(function()
    while ScreenGui.Parent do
        if training and TrainEvent then
            TrainEvent:FireServer()
        end
        task.wait(0.1)
    end
end)
