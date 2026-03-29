
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Igcognito | Swing Obby for Brainrots!",
    SubTitle = "by Skibidi50-lol",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 430),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})
local Tabs = {
    Farm = Window:AddTab({ Title = "Farm", Icon = "bot" }),
    Upgrades = Window:AddTab({ Title = "Upgrades", Icon = "dollar-sign" }),
    Automation = Window:AddTab({ Title = "Automation", Icon = "folder-cog" }),
    Random = Window:AddTab({ Title = "Random", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "cog" })
}
local Options = Fluent.Options

---------
---------
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local running = false
local suffixes = {
    k = 1e3, m = 1e6, b = 1e9, t = 1e12,
    qa = 1e15, qi = 1e18, sx = 1e21,
    sp = 1e24, oc = 1e27, no = 1e30, dc = 1e33
}
local function parseMoney(text)
    if not text then return 0 end
    text = text:lower():gsub("%$", ""):gsub(",", "")
    local num, suf = text:match("([%d%.]+)(%a*)")
    num = tonumber(num)
    if not num then return 0 end
    return num * (suffixes[suf] or 1)
end
local RarityDropdown = Tabs.Farm:AddDropdown("RarityFilter", {
    Title = "Exclude Rarities",
    Values = {"COMMON","UNCOMMON","RARE","EPIC","LEGENDARY","MYTHIC","SECRET","ANCIENT","DIVINE"},
    Multi = true,
    Default = {}
})
local excludedRarities = {}
RarityDropdown:OnChanged(function(Value)
    excludedRarities = Value
end)
local RankDropdown = Tabs.Farm:AddDropdown("RankFilter", {
    Title = "Exclude Ranks",
    Values = {"NORMAL","GOLDEN","DIAMOND","EMERALD","RUBY","RAINBOW","VOID","ETHEREAL","CELESTIAL"},
    Multi = true,
    Default = {}
})
local excludedRanks = {}
RankDropdown:OnChanged(function(Value)
    excludedRanks = Value
end)
local levelLimit = 0
local LevelInput1 = Tabs.Farm:AddInput("LevelInput1", {
    Title = "Minimum Brainrot Level",
    Default = "",
    Placeholder = "Enter number",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        levelLimit = tonumber(Value) or 0
    end
})
LevelInput1:OnChanged(function()
    levelLimit = tonumber(LevelInput1.Value) or 0
end)
local function getBest()
    local bestPart = nil
    local bestModel = nil
    local bestValue = 0
    for _, part in pairs(workspace.ActiveBrainrots:GetChildren()) do
        if part:IsA("BasePart") then
            local model = part:FindFirstChildOfClass("Model")
            if not model then continue end
            local success, data = pcall(function()
                local frame = model.LevelBoard.Frame
                return {
                    earnings = frame.CurrencyFrame.Earnings.Text,
                    rarity = frame.Rarity.Text,
                    rank = frame.Rank.Text,
                    level = frame.Level.Text
                }
            end)
            if success and data then
                if excludedRarities[data.rarity] then continue end
                if excludedRanks[data.rank] then continue end
                local levelNumber = tonumber(string.match(data.level, "%d+")) or 0
                if levelNumber <= levelLimit then continue end
                local value = parseMoney(data.earnings)
                if value > bestValue then
                    bestValue = value
                    bestPart = part
                    bestModel = model
                end
            end
        end
    end
    return bestPart, bestModel
end
local function teleport(cf)
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    root.CFrame = cf
end
local function process()
    local part, model = getBest()
    if not part or not model then return end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    teleport(hrp.CFrame + Vector3.new(0, 3, 0))
    task.wait(0.3)
    local attachment = part:FindFirstChild("Attachment")
    if attachment then
        local prompt = attachment:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
        end
    end
    task.wait(0.3)
    teleport(CFrame.new(-18, -10, -57))
end
local fb = Tabs.Farm:AddToggle("fb", {
    Title = "Farm Brainrots",
    Default = false
})
fb:OnChanged(function(Value)
    running = Value
    if running then
        task.spawn(function()
            while running do
                pcall(process)
                task.wait(1.5)
            end
        end)
    end
end)
Options.fb:SetValue(false)
---------
---------
local runningUpgrade = false
local busy = false
local interval = 1
local UpgradeDropdown = Tabs.Upgrades:AddDropdown("UpgradeSelect", {
    Title = "Select Upgrades",
    Values = {"Power", "Reach", "Carry"},
    Multi = true,
    Default = {}
})
local selectedUpgrades = {}
UpgradeDropdown:OnChanged(function(Value)
    selectedUpgrades = Value
end)
local PowerAmountDropdown = Tabs.Upgrades:AddDropdown("PowerAmount", {
    Title = "Power Amount",
    Values = {"5", "25", "50"},
    Multi = false,
    Default = "5"
})
local powerAmount = 5
PowerAmountDropdown:OnChanged(function(Value)
    powerAmount = tonumber(Value) or 5
end)
local ReachAmountDropdown = Tabs.Upgrades:AddDropdown("ReachAmount", {
    Title = "Reach Amount",
    Values = {"5", "25", "50"},
    Multi = false,
    Default = "5"
})
local reachAmount = 5
ReachAmountDropdown:OnChanged(function(Value)
    reachAmount = tonumber(Value) or 5
end)
local upgradeslider = Tabs.Upgrades:AddSlider("UpgradeInterval", {
    Title = "Upgrade Interval",
    Default = 1,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        interval = Value
    end
})
upgradeslider:OnChanged(function(Value)
    interval = Value
end)
upgradeslider:SetValue(1)
local upgradeRemote = game:GetService("ReplicatedStorage")
    :WaitForChild("Packages")
    :WaitForChild("Knit")
    :WaitForChild("Services")
    :WaitForChild("StatUpgradeService")
    :WaitForChild("RF")
    :WaitForChild("Upgrade")
local function doUpgrade()
    if busy then return end
    busy = true
    if selectedUpgrades["Power"] then
        pcall(function()
            upgradeRemote:InvokeServer("Power", powerAmount)
        end)
    end
    if selectedUpgrades["Reach"] then
        pcall(function()
            upgradeRemote:InvokeServer("Reach_Distance", reachAmount)
        end)
    end
    if selectedUpgrades["Carry"] then
        pcall(function()
            upgradeRemote:InvokeServer("GrabAmount", 1)
        end)
    end
    busy = false
end
local UpgradeToggle = Tabs.Upgrades:AddToggle("AutoUpgradeToggle", {
    Title = "Auto Upgrade Selected",
    Default = false
})
UpgradeToggle:OnChanged(function(Value)
    runningUpgrade = Value
    if runningUpgrade then
        task.spawn(function()
            while runningUpgrade do
                doUpgrade()
                task.wait(interval)
            end
        end)
    end
end)
Options.AutoUpgradeToggle:SetValue(false)
---------
---------
Tabs.Upgrades:AddSection("Brainrots")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local running = false
local busy = false
local maxLevel = 100
local LevelInput = Tabs.Upgrades:AddInput("MaxLevelInput", {
    Title = "Max Brainrot Level",
    Default = "100",
    Placeholder = "Enter max level",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        maxLevel = tonumber(Value) or 100
    end
})
LevelInput:OnChanged(function()
    maxLevel = tonumber(LevelInput.Value) or 100
end)
local upgradeRemote = game:GetService("ReplicatedStorage")
    :WaitForChild("Packages")
    :WaitForChild("Knit")
    :WaitForChild("Services")
    :WaitForChild("PlotService")
    :WaitForChild("RF")
    :WaitForChild("Upgrade")
local function getMyPlot()
    local myName = string.upper(player.Name)
    for i = 1, 5 do
        local plot = workspace.Plots:FindFirstChild("Plot"..i)
        if plot then
            local success, ownerText = pcall(function()
                return plot.MainSign.ScreenFrame.SurfaceGui.Frame.Owner.PlayerName.Text
            end)
            if success and ownerText == myName then
                return plot
            end
        end
    end
end
local function getPodLevel(pod)
    local success, levelText = pcall(function()
        local model = pod:FindFirstChild("BrainrotModel")
        if not model then return nil end
        local visual = model:FindFirstChild("VisualAnchor")
        if not visual then return nil end
        local brainrot = visual:GetChildren()[1]
        if not brainrot then return nil end
        return brainrot.LevelBoard.Frame.Level.Text
    end)
    if success and levelText then
        return tonumber(string.match(levelText, "%d+")) or 0
    end
    return nil
end
local function process()
    if busy then return end
    busy = true
    local plot = getMyPlot()
    if not plot then
        busy = false
        return
    end
    local pods = plot:FindFirstChild("Pods")
    if not pods then
        busy = false
        return
    end
    for _, pod in pairs(pods:GetChildren()) do
        if not running then break end
        local level = getPodLevel(pod)
        if level and level < maxLevel then
            pcall(function()
                upgradeRemote:InvokeServer(pod)
            end)
            task.wait(0.1)
        end
    end
    busy = false
end
local AutoPodUpgrade = Tabs.Upgrades:AddToggle("AutoPodUpgrade", {
    Title = "Auto Upgrade Brainrots",
    Default = false
})
AutoPodUpgrade:OnChanged(function(Value)
    running = Value
    if running then
        task.spawn(function()
            while running do
                process()
                task.wait(0.1)
            end
        end)
    end
end)
Options.AutoPodUpgrade:SetValue(false)
---------
---------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local TIERS = {
    "Normal",
    "Golden",
    "Diamond",
    "Emerald",
    "Ruby",
    "Rainbow",
    "Void",
    "Ethereal",
    "Celestial"
}
local running = false
local function getButtons()
    local buttons = {}
   
    local path = player:WaitForChild("PlayerGui")
        :WaitForChild("ScreenGui")
        :WaitForChild("FrameIndex")
        :WaitForChild("Main")
        :WaitForChild("ScrollingFrame")
    for _, v in ipairs(path:GetChildren()) do
        if v:IsA("ImageButton") then
            table.insert(buttons, v)
        end
    end
    return buttons
end
local function run()
    while running do
        local buttons = getButtons()
        for _, button in ipairs(buttons) do
            if not running then break end
            local brainrotName = button.Name
            for _, tier in ipairs(TIERS) do
                if not running then break end
                local args = {
                    brainrotName,
                    tier
                }
                ReplicatedStorage
                    :WaitForChild("Remotes")
                    :WaitForChild("NewBrainrotIndex")
                    :WaitForChild("ClaimBrainrotIndex")
                    :FireServer(unpack(args))
                task.wait(0.1)
            end
        end
        task.wait(1)
    end
end
local changethisnametowhatever = Tabs.Automation:AddToggle("changethisnametowhatever", {
    Title = "Auto Claim Index Rewards",
    Default = false
})
changethisnametowhatever:OnChanged(function(value)
    running = value
    if running then
        task.spawn(run)
    end
end)
Options.changethisnametowhatever:SetValue(false)
---------
---------
local RS = game:GetService("ReplicatedStorage")
local enabled = false
local function autoRebirthLoop()
    while enabled do
        pcall(function()
            RS
                :WaitForChild("Packages")
                :WaitForChild("Knit")
                :WaitForChild("Services")
                :WaitForChild("StatUpgradeService")
                :WaitForChild("RF")
                :WaitForChild("Rebirth")
                :InvokeServer()
        end)
        task.wait(1)
    end
end
local rebirthToggle = Tabs.Automation:AddToggle("rebirthToggle", {
    Title = "Auto Rebirth",
    Default = false
})
rebirthToggle:OnChanged(function(state)
    enabled = state
    if enabled then
        task.spawn(autoRebirthLoop)
    end
end)
Options.rebirthToggle:SetValue(false)
---------
---------
Tabs.Automation:AddSection("Collecting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local active = false
local mode = "Teleport"
local Dropdown = Tabs.Automation:AddDropdown("MoveMode", {
    Title = "Collection Method",
    Values = {"Teleport", "Tween"},
    Multi = false,
    Default = 1,
})
Dropdown:SetValue("Teleport")
Dropdown:OnChanged(function(Value)
    mode = Value
end)
local function getMyPlot()
    for i = 1, 5 do
        local plot = workspace:WaitForChild("Plots"):FindFirstChild("Plot"..i)
        if plot then
            local label = plot.MainSign.ScreenFrame.SurfaceGui.Frame.Owner.PlayerName
            if label and label.Text == string.upper(player.Name) then
                return plot
            end
        end
    end
end
local function teleportTo(cf)
    root.CFrame = cf
end
local function tweenTo(cf)
    local tween = TweenService:Create(
        root,
        TweenInfo.new(0.15, Enum.EasingStyle.Linear),
        {CFrame = cf}
    )
    tween:Play()
    tween.Completed:Wait()
end
local function moveTo(cf)
    if mode == "Tween" then
        tweenTo(cf)
    else
        teleportTo(cf)
    end
end
local function run()
    while active do
        local plot = getMyPlot()
        if not plot then
            task.wait(1)
            continue
        end
        local startPart = plot.MainSign.ScreenFrame
        moveTo(startPart.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.5)
        local pods = plot:WaitForChild("Pods")
        for i = 1, 40 do
            if not active then break end
            local pod = pods:FindFirstChild(tostring(i))
            if pod and pod:FindFirstChild("TouchPart") then
                local touch = pod.TouchPart
                moveTo(touch.CFrame + Vector3.new(0, 3, 0))
                task.wait(0.2)
            end
        end
        task.wait(1)
    end
end
local autoMove = Tabs.Automation:AddToggle("AutoPods", {
    Title = "Auto Collect Money",
    Default = false
})
autoMove:OnChanged(function(v)
    active = v
    if active then
        task.spawn(run)
    end
end)
Options.AutoPods:SetValue(false)
---------
---------
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local stat = player:WaitForChild("updateStatsFolder"):WaitForChild("Reach_Distance")
local enabled = false
local originalValue = stat.Value
local MAX_VALUE = 1e9
local function enforce()
    while enabled do
        if stat.Value ~= MAX_VALUE then
            stat.Value = MAX_VALUE
        end
        task.wait(0.1)
    end
end
local reachToggle = Tabs.Random:AddToggle("ReachToggle", {
    Title = "Inf Rope Reach",
    Default = false
})
reachToggle:OnChanged(function(state)
    enabled = state
    if enabled then
        originalValue = stat.Value
        stat.Value = MAX_VALUE
        task.spawn(enforce)
    else
        stat.Value = originalValue
    end
end)
Options.ReachToggle:SetValue(false)
---------
---------
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local stat = player:WaitForChild("updateStatsFolder"):WaitForChild("Power")
local enabled = false
local originalValue = stat.Value
local sliderValue = 10
local Slider = Tabs.Random:AddSlider("PowerSlider", {
    Title = "Custom Power",
    Default = 10,
    Min = 5,
    Max = 15000,
    Rounding = 1,
    Callback = function(Value)
        sliderValue = Value
    end
})
Slider:OnChanged(function(Value)
    sliderValue = Value
end)
Slider:SetValue(10)
local function enforce()
    while enabled do
        if stat.Value ~= sliderValue then
            stat.Value = sliderValue
        end
        task.wait(0.1)
    end
end
local powerToggle = Tabs.Random:AddToggle("PowerToggle", {
    Title = "Enable Custom Power",
    Default = false
})
powerToggle:OnChanged(function(state)
    enabled = state
    if enabled then
        originalValue = stat.Value
        stat.Value = sliderValue
        task.spawn(enforce)
    else
        stat.Value = originalValue
    end
end)
Options.PowerToggle:SetValue(false)
---------
---------
local Players = game:GetService("Players")
local player = Players.LocalPlayer
Tabs.Random:AddButton({
    Title = "Tp to End",
    Callback = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        root.CFrame = CFrame.new(21, -10, -34044)
    end
})
---------
---------
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

loadstring(game:HttpGet("https://raw.githubusercontent.com/evxncodes/mainroblox/main/anti-afk", true))()
