local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [services]
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Network"):WaitForChild("Remotes")
local DumbellRemote = Remotes:WaitForChild("Activate Dumbell")
local RebirthRemote = Remotes:WaitForChild("Rebirth")
local CollectRemote = Remotes:WaitForChild("Collect Earnings")
local UpgradeFriendRemote = Remotes:WaitForChild("Upgrade Friend")
local BuyDumbellRemote = Remotes:WaitForChild("Buy Dumbell")
local UpgradeCarryRemote = Remotes:WaitForChild("Upgrade Carry Limit")
-- [to find your base]
local function getPlayerBase()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for i = 1, 5 do
        local base = plots:FindFirstChild("BasePos" .. i)
        if base then
            local owner = base:FindFirstChild("owner")
            if owner and owner:IsA("StringValue") and owner.Value == LocalPlayer.Name then
                return base
            end
        end
    end
    return nil
end

local Window = Fluent:CreateWindow({
    Title = "Igcognito | Pull Lucky Blocks",
    SubTitle = "by Skibidi50-lol",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 430),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "box" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "bot" }),
    Upgrade = Window:AddTab({ Title = "Upgrade", Icon = "wrench" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "cog" })
}

local Options = Fluent.Options
local connections = {}

do
-----
-----
local Toggle = Tabs.Main:AddToggle("AutoPowerTOGGLE", {Title = "Auto Power", Default = false})
local lastFire = 0
local powerConnection

Toggle:OnChanged(function()
    if Options.AutoPowerTOGGLE.Value then
        powerConnection = RunService.Heartbeat:Connect(function()
            if tick() - lastFire >= 0.05 then
                lastFire = tick()
                DumbellRemote:FireServer()
            end
        end)
    else
        if powerConnection then
            powerConnection:Disconnect()
            powerConnection = nil
        end
    end
end)
Options.AutoPowerTOGGLE:SetValue(false)
-----
-----
local Toggle = Tabs.Main:AddToggle("VIPDoorsToggle", {Title = "Unlock VIP Doors", Default = false})
local storedDoors = {}

Toggle:OnChanged(function()
    if Options.VIPDoorsToggle.Value then
        local VIPDoors = workspace:WaitForChild("Map"):WaitForChild("VIPDoors")
        for _, part in ipairs(VIPDoors:GetChildren()) do
            table.insert(storedDoors, {
                instance = part,
                parent = part.Parent
            })
            part.Parent = nil
        end
    else
        for _, data in ipairs(storedDoors) do
            data.instance.Parent = data.parent
        end
        storedDoors = {}
    end
end)
Options.VIPDoorsToggle:SetValue(false)
-----
-----
local ToggleRebirth = Tabs.Main:AddToggle("AutoRebirth", {Title = "Auto Rebirth", Default = false})
ToggleRebirth:OnChanged(function()
    if Options.AutoRebirth.Value then
        local last = 0
        connections.rebirth = RunService.Heartbeat:Connect(function()
            if tick() - last >= 1 then
                last = tick()
                RebirthRemote:FireServer()
            end
        end)
    else
        if connections.rebirth then connections.rebirth:Disconnect() connections.rebirth = nil end
    end
end)
Options.AutoRebirth:SetValue(false)
-----
-----
local ToggleCollect = Tabs.Main:AddToggle("AutoCollect", {Title = "Auto Collect Cash", Default = false})
ToggleCollect:OnChanged(function()
    if Options.AutoCollect.Value then
        local last = 0
        local index = 1
        connections.collect = RunService.Heartbeat:Connect(function()
            if tick() - last >= 0.1 then
                last = tick()
                local base = getPlayerBase()
                if not base then return end
                local stands = base.Stands:GetChildren()
                while index <= #stands and not stands[index]:FindFirstChild("Upgrade") do
                    index = index + 1
                end
                if index > #stands then
                    index = 1
                    return
                end
                local stand = stands[index]
                LocalPlayer.Character:PivotTo(stand:GetPivot())
                CollectRemote:FireServer(stand.Name)
                index = index + 1
            end
        end)
    else
        if connections.collect then connections.collect:Disconnect() connections.collect = nil end
    end
end)
Options.AutoCollect:SetValue(false)
-----
-----
local Input = Tabs.Upgrade:AddInput("UpgradeLevel", {
    Title = "Max Upgrade Level",
    Default = "10",
    Placeholder = "Enter max level...",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        print("Target level set:", Value)
    end
})
local ToggleUpgrade = Tabs.Upgrade:AddToggle("AutoUpgrade", {Title = "Auto Upgrade Brainrots", Default = false})
ToggleUpgrade:OnChanged(function()
    if Options.AutoUpgrade.Value then
        local last = 0
        local pendingUpgrade = {}
        connections.upgrade = RunService.Heartbeat:Connect(function()
            if tick() - last >= 0.1 then
                last = tick()
                local base = getPlayerBase()
                if not base then return end
                local targetLevel = tonumber(Input.Value) or 10
                local stands = base.Stands
                for _, stand in ipairs(stands:GetChildren()) do
                    if stand:FindFirstChild("Upgrade") then
                        local levelLabel = stand.Upgrade
                            :FindFirstChild("SurfaceGui")
                            and stand.Upgrade.SurfaceGui
                            :FindFirstChild("Frame")
                            and stand.Upgrade.SurfaceGui.Frame
                            :FindFirstChild("Button")
                            and stand.Upgrade.SurfaceGui.Frame.Button
                            :FindFirstChild("Level")
                        if levelLabel then
                            local currentLevel = tonumber(levelLabel.Text:match("Lvl%s*(%d+)"))
                            if currentLevel then
                                if pendingUpgrade[stand.Name] and currentLevel ~= pendingUpgrade[stand.Name] then
                                    pendingUpgrade[stand.Name] = nil
                                end
                                if not pendingUpgrade[stand.Name] and currentLevel < targetLevel then
                                    pendingUpgrade[stand.Name] = currentLevel
                                    UpgradeFriendRemote:FireServer(stand.Name)
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if connections.upgrade then
            connections.upgrade:Disconnect()
            connections.upgrade = nil
        end
    end
end)
Options.AutoUpgrade:SetValue(false)
-----
-----
local ToggleDumbell = Tabs.Upgrade:AddToggle("AutoDumbell", {Title = "Auto Buy Dumbells", Default = false})
ToggleDumbell:OnChanged(function()
    if Options.AutoDumbell.Value then
        local last = 0
        connections.dumbell = RunService.Heartbeat:Connect(function()
            if tick() - last >= 0.1 then
                last = tick()
                for i = 1, 20 do
                    BuyDumbellRemote:FireServer("Dumbell_" .. i)
                end
            end
        end)
    else
        if connections.dumbell then connections.dumbell:Disconnect() connections.dumbell = nil end
    end
end)
Options.AutoDumbell:SetValue(false)
-----
-----
local ToggleCarry = Tabs.Upgrade:AddToggle("AutoCarry", {Title = "Auto Upgrade Pull Limit", Default = false})
ToggleCarry:OnChanged(function()
    if Options.AutoCarry.Value then
        local last = 0
        connections.carry = RunService.Heartbeat:Connect(function()
            if tick() - last >= 1 then
                last = tick()
                UpgradeCarryRemote:FireServer()
            end
        end)
    else
        if connections.carry then connections.carry:Disconnect() connections.carry = nil end
    end
end)
Options.AutoCarry:SetValue(false)
-----
-----
local rarityThresholds = {
    {name = "OG",           value = 48500000},
    {name = "Brainrot God", value = 9500000},
    {name = "Secret",       value = 2450000},
    {name = "Mythic",       value = 290000},
    {name = "Legendary",    value = 45000},
    {name = "Epic",         value = 9500},
    {name = "Rare",         value = 500},
    {name = "Common",       value = 150},
}
local rarityRank = {}
for rank, tier in ipairs(rarityThresholds) do
    rarityRank[tier.name] = rank
end
local stealRunning = false
local excludedRarities = {}
local function parseStrength(str)
    str = tostring(str):gsub(",", ""):gsub("%s", "")
    local num, suffix = str:match("^([%d%.]+)([KkMmBbTt]?)$")
    if not num then return 0 end
    num = tonumber(num) or 0
    suffix = suffix:upper()
    if suffix == "K" then num = num * 1000
    elseif suffix == "M" then num = num * 1000000
    elseif suffix == "B" then num = num * 1000000000
    end
    return num
end
local function isBeingStolen(model)
    local mass = model:FindFirstChild("Mass")
    if not mass then return false end
    local stealing = mass:FindFirstChild("STEALING")
    return stealing ~= nil and stealing:IsA("RopeConstraint")
end
local function getRarityText(model)
    local text = nil
    pcall(function()
        text = model.FriendBillboard.Frame.Rarity.Text
    end)
    return text
end
local function isRagdolled()
    local char = workspace:FindFirstChild(LocalPlayer.Name)
    if not char then return false end
    local ragdolled = char:FindFirstChild("Ragdolled")
    return ragdolled and ragdolled:IsA("BoolValue") and ragdolled.Value == true
end
local function waitForRagdollEnd()
    while stealRunning and isRagdolled() do
        task.wait(0.1)
    end
    if not stealRunning then return false end
    task.wait(0.5)
    return true
end
local function attemptSteal(model, rootPart, prompt)
    local MAX_RETRIES = 6
    for attempt = 1, MAX_RETRIES do
        if not stealRunning then return "skip" end
        if not model.Parent then return "skip" end
        if isBeingStolen(model) then return "skip" end
        if isRagdolled() then
            return "ragdoll"
        end
        pcall(function()
            LocalPlayer.Character:PivotTo(rootPart.CFrame)
        end)
        task.wait(0.67)
        if not stealRunning then return "skip" end
        if not model.Parent then return "skip" end
        if isBeingStolen(model) then return "skip" end
        if isRagdolled() then
            return "ragdoll"
        end
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(1.18)
        if not stealRunning then return "skip" end
        if not model.Parent then return "skip" end
        if isBeingStolen(model) then return "skip" end
        if isRagdolled() then
            return "ragdoll"
        end
    end
    return "skip"
end
local function returnHome()
    local HOME = CFrame.new(287, 11, 304)
    while stealRunning do
        if isRagdolled() then
            return false
        end
        pcall(function()
            LocalPlayer.Character:PivotTo(HOME)
        end)
        task.wait(0.1)
        break
    end
    return stealRunning
end
local ExcludeDropdown = Tabs.Farm:AddDropdown("ExcludeRarities", {
    Title = "Exclude Rarities to Collect",
    Values = {"Common", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Brainrot God", "OG"},
    Multi = true,
    Default = {},
})
ExcludeDropdown:OnChanged(function(Value)
    excludedRarities = {}
    for rarity, state in next, Value do
        if state then excludedRarities[rarity] = true end
    end
end)
local ToggleSteal = Tabs.Farm:AddToggle("AutoSteal", {Title = "Auto Collect Lucky Blocks", Default = false})
ToggleSteal:OnChanged(function()
    if Options.AutoSteal.Value then
        stealRunning = true
        task.spawn(function()
            while stealRunning do
                if isRagdolled() then
                    local ok = waitForRagdollEnd()
                    if not ok then break end
                    continue
                end
                local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                local strengthStat = leaderstats and leaderstats:FindFirstChild("Strength")
                if not strengthStat then task.wait(1) continue end
                local strength = parseStrength(strengthStat.Value)
                local eligibleRarities = {}
                for _, tier in ipairs(rarityThresholds) do
                    if strength >= tier.value and not excludedRarities[tier.name] then
                        eligibleRarities[tier.name] = true
                    end
                end
                if not next(eligibleRarities) then task.wait(1) continue end
                local friendsFolder = workspace:FindFirstChild("Live")
                    and workspace.Live:FindFirstChild("Friends")
                if not friendsFolder then task.wait(1) continue end
                local candidates = {}
                for _, model in ipairs(friendsFolder:GetChildren()) do
                    if not model:IsA("Model") then continue end
                    local rarity = getRarityText(model)
                    if not rarity then continue end
                    if not eligibleRarities[rarity] then continue end
                    if isBeingStolen(model) then continue end
                    local rootPart = model:FindFirstChild("RootPart")
                    if not rootPart then continue end
                    local prompt = rootPart:FindFirstChild("StealPrompt")
                    if not prompt then continue end
                    table.insert(candidates, {
                        model  = model,
                        root   = rootPart,
                        prompt = prompt,
                        rank   = rarityRank[rarity] or 999,
                    })
                end
                if #candidates == 0 then task.wait(1) continue end
                local bestRank = math.huge
                for _, c in ipairs(candidates) do
                    if c.rank < bestRank then bestRank = c.rank end
                end
                local targets = {}
                for _, c in ipairs(candidates) do
                    if c.rank == bestRank then
                        table.insert(targets, c)
                    end
                end
                local ragdolledMidLoop = false
                for _, target in ipairs(targets) do
                    if not stealRunning then break end
                    if not target.model.Parent then continue end
                    if isBeingStolen(target.model) then continue end
                    local result = attemptSteal(target.model, target.root, target.prompt)
                    if result == "ragdoll" then
                        local ok = waitForRagdollEnd()
                        ragdolledMidLoop = true
                        if not ok then stealRunning = false end
                        break
                    end
                    if stealRunning and target.model and target.model.Parent then
                        local HOME = CFrame.new(287, 11, 304)
                        local giveUp = tick() + 5 -- don't wait forever
                        while stealRunning and target.model and target.model.Parent and tick() < giveUp do
                            if isRagdolled() then
                                local ok = waitForRagdollEnd()
                                ragdolledMidLoop = true
                                if not ok then stealRunning = false end
                                break
                            end
                            pcall(function() LocalPlayer.Character:PivotTo(HOME) end)
                            task.wait(0.1)
                        end
                        if ragdolledMidLoop then break end
                    end
                    task.wait(0.5)
                end
                if stealRunning and not ragdolledMidLoop then
                    task.wait(0.5)
                end
            end
        end)
    else
        stealRunning = false
    end
end)
Options.AutoSteal:SetValue(false)
-----
-----
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
end
