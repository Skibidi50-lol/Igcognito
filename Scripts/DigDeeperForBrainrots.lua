local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Igcognito | ⛏️Dig DEEPER for Brainrots!",
    SubTitle = "by Skibidi50-lol",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 430),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "shovel" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "bot" }),
    Upgrade = Window:AddTab({ Title = "Upgrade", Icon = "wrench" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "cog" })
}



local Options = Fluent.Options
do
-----
-----
local JetpackToggle = Tabs.Main:AddToggle("InfiniteJetpack", {Title = "Inf Jetpack Fuel", Default = false})
local jetpackConnection = nil
JetpackToggle:OnChanged(function()
    if Options.InfiniteJetpack.Value then
        task.spawn(function()
            local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
            local RunService = game:GetService("RunService")
            local JetpackController = Knit.GetController("JetpackController")
            if not JetpackController then
                Options.InfiniteJetpack:SetValue(false)
                return
            end
            task.wait(1)
            jetpackConnection = RunService.Heartbeat:Connect(function()
                if JetpackController and JetpackController._maxFuel then
                    JetpackController._fuel = JetpackController._maxFuel
                end
            end)
        end)
    else
        if jetpackConnection then
            jetpackConnection:Disconnect()
            jetpackConnection = nil
            local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
            local JetpackController = Knit.GetController("JetpackController")
            if JetpackController then
                JetpackController._fuel = 1
            end
        end
    end
end)
-----
-----
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function getKnitRF(service, rf)
    return RS:WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_knit@1.7.0")
        :WaitForChild("knit")
        :WaitForChild("Services")
        :WaitForChild(service)
        :WaitForChild("RF")
        :WaitForChild(rf)
end
Tabs.Upgrade:AddDropdown("UpgradeTypes", {
    Title = "Upgrade Types",
    Values = {"Speed", "Power", "Run", "Carry"},
    Multi = true,
    Default = {},
})
Tabs.Upgrade:AddDropdown("SpeedAmount", {
    Title = "Speed Upgrade Amount",
    Values = {"1", "10"},
    Multi = false,
    Default = 1,
})
Tabs.Upgrade:AddDropdown("PowerAmount", {
    Title = "Power Upgrade Amount",
    Values = {"1", "10"},
    Multi = false,
    Default = 1,
})
local AutoUpgradeToggle = Tabs.Upgrade:AddToggle("AutoUpgrade", {Title = "Auto Upgrade", Default = false})
AutoUpgradeToggle:OnChanged(function()
    if Options.AutoUpgrade.Value then
        task.spawn(function()
            local UpgradeRF = getKnitRF("UpgradeService", "Upgrade")
            while Options.AutoUpgrade.Value do
                for upgType, state in next, Options.UpgradeTypes.Value do
                    if state then
                        local amount = 1
                        if upgType == "Speed" then
                            amount = tonumber(Options.SpeedAmount.Value) or 1
                        elseif upgType == "Power" then
                            amount = tonumber(Options.PowerAmount.Value) or 1
                        end
                        UpgradeRF:InvokeServer(upgType, amount)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)
-----
-----
local pickaxeOrder = {
    "Wooden Pickaxe",
    "Rusty Pickaxe",
    "Stone Pickaxe",
    "Iron Pickaxe",
    "Golden Pickaxe",
    "Duel Iron Pickaxe",
    "Diamond Pickaxe",
    "Duel Golden Pickaxe",
    "Duel Diamond Pickaxe",
    "Powerdrill",
    "Auto Drill",
    "Hammer Drill",
    "Super Drill",
}
local AutoPickaxeToggle = Tabs.Main:AddToggle("AutoPickaxe", {Title = "Auto Buy Pickaxes", Default = false})
AutoPickaxeToggle:OnChanged(function()
    if Options.AutoPickaxe.Value then
        task.spawn(function()
            local BuyRF = getKnitRF("ExcavatorService", "Buy")
            while Options.AutoPickaxe.Value do
                local gui = LocalPlayer.PlayerGui
                local scroll = gui:FindFirstChild("Pickaxes")
                    and gui.Pickaxes:FindFirstChild("Container")
                    and gui.Pickaxes.Container:FindFirstChild("Body")
                    and gui.Pickaxes.Container.Body:FindFirstChild("Scroll")
                if scroll then
                    local allOwned = true
                    for i = #pickaxeOrder, 1, -1 do
                        local name = pickaxeOrder[i]
                        local frame = scroll:FindFirstChild(name)
                        if frame then
                            local equipBtn = frame:FindFirstChild("Buttons")
                                and frame.Buttons:FindFirstChild("Equip")
                            if equipBtn and not equipBtn.Visible then
                                allOwned = false
                                BuyRF:InvokeServer(name)
                                task.wait(0.1)
                            end
                        else
                            allOwned = false
                        end
                    end
                    if allOwned then
                        Options.AutoPickaxe:SetValue(false)
                        Fluent:Notify({
                            Title = "Auto Buy Pickaxes has Stopped",
                            Content = "All pickaxes purchased!",
                            Duration = 5
                        })
                        break
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end)
-----
-----
local AutoCollectToggle = Tabs.Main:AddToggle("AutoCollect", {Title = "Auto Collect Money", Default = false})
AutoCollectToggle:OnChanged(function()
    if Options.AutoCollect.Value then
        task.spawn(function()
            local ClaimRF = getKnitRF("ButtonService", "Claim")
            local userId = LocalPlayer.UserId
            while Options.AutoCollect.Value do
                local Bases = workspace:FindFirstChild("Bases")
                if Bases then
                    for _, base in ipairs(Bases:GetChildren()) do
                        if base:GetAttribute("Owner") == userId then
                            local buttons = base:FindFirstChild("Buttons")
                            if buttons then
                                for _, slot in ipairs(buttons:GetChildren()) do
                                    if not Options.AutoCollect.Value then break end
                                    ClaimRF:InvokeServer(slot)
                                    task.wait(0.05)
                                end
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end)
-----
-----
local AutoRebirthToggle = Tabs.Main:AddToggle("AutoRebirth", {Title = "Auto Rebirth", Default = false})
AutoRebirthToggle:OnChanged(function()
    if Options.AutoRebirth.Value then
        task.spawn(function()
            local RebirthRF = getKnitRF("RebirthService", "Rebirth")
            while Options.AutoRebirth.Value do
                RebirthRF:InvokeServer()
                task.wait(1)
            end
        end)
    end
end)
-----
-----
local AutoDigToggle = Tabs.Main:AddToggle("AutoDig", 
{Title = "Auto Dig", Description = "better but only visible to you", Default = false})
AutoDigToggle:OnChanged(function()
    if Options.AutoDig.Value then
        task.spawn(function()
            local terrain = workspace.Terrain
            while Options.AutoDig.Value do
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    terrain:FillBlock(
                        hrp.CFrame,
                        Vector3.new(20, 165, 20),
                        Enum.Material.Air
                    )
                end
                task.wait(0.1)
            end
        end)
    end
end)
-----
-----
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HitRemote = game:GetService("ReplicatedStorage")
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("ExcavatorService")
    :WaitForChild("RF")
    :WaitForChild("Hit")
local validPickaxes = {
    ["Wooden Pickaxe"] = true,
    ["Rusty Pickaxe"] = true,
    ["Stone Pickaxe"] = true,
    ["Iron Pickaxe"] = true,
    ["Golden Pickaxe"] = true,
    ["Duel Iron Pickaxe"] = true,
    ["Diamond Pickaxe"] = true,
    ["Duel Golden Pickaxe"] = true,
    ["Duel Diamond Pickaxe"] = true,
    ["Powerdrill"] = true,
    ["Auto Drill"] = true,
    ["Hammer Drill"] = true,
    ["Super Drill"] = true,
}
local function getExcavatorTool()
    local character = LocalPlayer.Character
    if not character then return nil end
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and validPickaxes[tool.Name] then
            return tool
        end
    end
end
local function getDigPosition()
    local character = LocalPlayer.Character
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = { workspace.Terrain }
    local directions = {
        root.CFrame.LookVector * 5,
        Vector3.new(0, -5, 0),
        root.CFrame.LookVector * 3 + Vector3.new(0, -2, 0),
    }
    for _, dir in ipairs(directions) do
        local result = workspace:Raycast(root.Position, dir, params)
        if result then
            return result.Position
        end
    end
    return root.Position + root.CFrame.LookVector * 4
end
local AutoActivateToggle = Tabs.Main:AddToggle("AutoActivate", {
    Title = "Auto Dig",
    Description = "legit version",
    Default = false
})
AutoActivateToggle:OnChanged(function()
    if Options.AutoActivate.Value then
        task.spawn(function()
            while Options.AutoActivate.Value do
                local tool = getExcavatorTool()
                local pos = getDigPosition()
                if tool and pos then
                    HitRemote:InvokeServer(tool, pos, workspace:GetServerTimeNow())
                end
                task.wait(0.01)
            end
        end)
    end
end)
-----
-----
Tabs.Teleports:AddButton({
    Title = "Teleport Home",
    Callback = function()
        local userId = LocalPlayer.UserId
        local Bases = workspace:FindFirstChild("Bases")
        if Bases then
            for _, base in ipairs(Bases:GetChildren()) do
                if base:GetAttribute("Owner") == userId then
                    local indicator = base:FindFirstChild("Indicator")
                        and base.Indicator:FindFirstChild("Main")
                    if indicator then
                        local character = LocalPlayer.Character
                        local hrp = character and character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = indicator.CFrame + Vector3.new(0, 5, 0)
                        end
                    end
                    break
                end
            end
        end
    end
})
-----
-----
local zoneCoords = {
    ["Common Zone"] = Vector3.new(-1011, 11596, -690),
    ["Uncommon Zone"] = Vector3.new(-1012, 11496, -692),
    ["Rare Zone"] = Vector3.new(-1012, 11368, -691),
    ["Epic Zone"] = Vector3.new(-1012, 11156, -693),
    ["Legendary Zone"] = Vector3.new(-1012, 10608, -692),
    ["Mythic Zone"]  = Vector3.new(-1012, 9656, -693),
    ["Brainrot God Zone"] = Vector3.new(-1011, 7712, -692),
    ["Secret Zone"] = Vector3.new(-1005, 4340, -691),
    ["Celestial Zone"] = Vector3.new(-1006, 372, -692),
}
Tabs.Teleports:AddDropdown("ZoneSelect", {
    Title = "Select Zone",
    Values = {
        "Common Zone", "Uncommon Zone", "Rare Zone", "Epic Zone",
        "Legendary Zone", "Mythic Zone", "Brainrot god Zone", "Secret Zone", "Celestial Zone"
    },
    Multi = false,
    Default = 1,
})
Tabs.Teleports:AddButton({
    Title = "Teleport to Zone",
    Callback = function()
        local zone = Options.ZoneSelect.Value
        local coords = zoneCoords[zone]
        if coords then
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(coords)
            end
        end
    end
})
-----
-----
Tabs.Upgrade:AddSection("Brainrots")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local UpgradeRemote = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("LevellingService")
    :WaitForChild("RF")
    :WaitForChild("Upgrade")
local Toggle = Tabs.Upgrade:AddToggle("AutoUpgradeToggle", {
    Title = "Auto Upgrade Brainrots",
    Default = false
})
local Input = Tabs.Upgrade:AddInput("MaxLevelInput", {
    Title = "Max Upgrade Level",
    Default = "35",
    Placeholder = "Enter max level...",
    Numeric = true,
    Finished = false,
    Callback = function(Value) end
})
local function getMyBase()
    local basesFolder = workspace:WaitForChild("Bases")
    for i = 1, 6 do
        local base = basesFolder:FindFirstChild("Base_" .. i)
        if base then
            if base:GetAttribute("Owner") == LocalPlayer.UserId then
                return base
            end
        end
    end
    return nil
end
local function runUpgrades()
    local maxLevel = tonumber(Options.MaxLevelInput.Value)
    if not maxLevel then return end
    local base = getMyBase()
    if not base then return end
    local slotsFolder = base:FindFirstChild("Slots")
    if not slotsFolder then return end
    for _, slot in ipairs(slotsFolder:GetChildren()) do
        local brainrot = slot:FindFirstChild("Brainrot")
        if brainrot then
            local level = brainrot:GetAttribute("Level")
            if type(level) == "number" and level < maxLevel then
                UpgradeRemote:InvokeServer(slot)
                task.wait(0.1)
            end
        end
    end
end
task.spawn(function()
    while true do
        if Options.AutoUpgradeToggle.Value then
            runUpgrades()
            task.wait(0.1)
        else
            task.wait(0.1)
        end
    end
end)
-----
-----
-- not sure if this works properly i made it quickly
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local CarryRemote = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("CarryService")
    :WaitForChild("RF")
    :WaitForChild("Carry")
local POSITIONS = {
    Vector3.new(-1006, 377,   -692),
    Vector3.new(-1005, 4340,  -691),
    Vector3.new(-1011, 7712,  -692),
    Vector3.new(-1012, 9656,  -693),
    Vector3.new(-1012, 10608, -692),
    Vector3.new(-1012, 11156, -693),
    Vector3.new(-1012, 11368, -691),
    Vector3.new(-1012, 11496, -692),
    Vector3.new(-1011, 11596, -690),
}
local Toggle = Tabs.Farm:AddToggle("AutoFarmUnindexed", {
    Title = "Auto Farm Unindexed",
    Default = false
})
local function teleportTo(position)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end
local function getMyBase()
    local basesFolder = workspace:FindFirstChild("Bases")
    if not basesFolder then return nil end
    for i = 1, 6 do
        local base = basesFolder:FindFirstChild("Base_" .. i)
        if base and base:GetAttribute("Owner") == LocalPlayer.UserId then
            return base
        end
    end
    return nil
end
local function getBaseIndicatorPos()
    local base = getMyBase()
    if not base then return nil end
    local indicator = base:FindFirstChild("Indicator")
    if not indicator then return nil end
    local main = indicator:FindFirstChild("Main")
    if not main then return nil end
    return main.Position
end
local function getIndexedNames()
    local indexed = {}
    local items = LocalPlayer.PlayerGui.Index.Container.Body.Items
    if not items then return indexed end
    for _, categoryFrame in ipairs(items:GetChildren()) do
        for _, itemFrame in ipairs(categoryFrame:GetChildren()) do
            local title = itemFrame:FindFirstChild("Title")
            if title and title:IsA("TextLabel") and title.Text ~= "???" then
                indexed[title.Text] = true
            end
        end
    end
    return indexed
end
local function allIndexed()
    local items = LocalPlayer.PlayerGui.Index.Container.Body.Items
    if not items then return true end
    for _, categoryFrame in ipairs(items:GetChildren()) do
        for _, itemFrame in ipairs(categoryFrame:GetChildren()) do
            local title = itemFrame:FindFirstChild("Title")
            if title and title:IsA("TextLabel") and title.Text == "???" then
                return false
            end
        end
    end
    return true
end
task.spawn(function()
    while true do
        if Options.AutoFarmUnindexed.Value then
            if allIndexed() then
                task.wait(1)
            else
                for posIndex = 1, #POSITIONS do
                    if not Options.AutoFarmUnindexed.Value then break end
                    if allIndexed() then break end
                    teleportTo(POSITIONS[posIndex])
                    task.wait(1.5)
                    if not Options.AutoFarmUnindexed.Value then break end
                    local indexed = getIndexedNames()
                    local zonesFolder = workspace:FindFirstChild("Zones")
                    local visuals = zonesFolder and zonesFolder:FindFirstChild("Visuals")
                    if visuals then
                        for _, zone in ipairs(visuals:GetChildren()) do
                            if not Options.AutoFarmUnindexed.Value then break end
                            local brainrotsOuter = zone:FindFirstChild("Brainrots")
                            local brainrotsFolder = brainrotsOuter and brainrotsOuter:FindFirstChild("Brainrots")
                            if brainrotsFolder then
                                for _, part in ipairs(brainrotsFolder:GetChildren()) do
                                    if not Options.AutoFarmUnindexed.Value then break end
                                    local partType = part:GetAttribute("Type")
                                    if partType and not indexed[partType] then
                                        CarryRemote:InvokeServer(part)
                                        local basePos = getBaseIndicatorPos()
                                        if basePos then
                                            teleportTo(basePos)
                                        end
                                        task.wait(1.5)
                                        teleportTo(POSITIONS[posIndex])
                                        task.wait(1.5)
                                        indexed = getIndexedNames()
                                        if allIndexed() then break end
                                    end
                                end
                            end
                            if allIndexed() then break end
                        end
                    end
                end
            end
        else
            task.wait(0.2)
        end
    end
end)
-----
-----
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local AllBrainrotTypes = {
    "Meowl",
    "La Vacca Saturno Saturnita",
    "Strawberry Elephant",
    "Job Job Job Sahur",
    "Chicleteira Bicicleteira",
    "Skibidi Toilet",
    "Smurf Cat",
    "Karkerkar Kurkur",
    "Pot Hotspot",
    "Esok Sekolah"
}
local Toggle = Tabs.Farm:AddToggle("FarmToggle", {Title = "Farm Selected Brainrots", Default = false})
Toggle:OnChanged(function() end)
local MultiDropdown = Tabs.Farm:AddDropdown("BrainrotDropdown", {
    Title = "Select Brainrots",
    Values = AllBrainrotTypes,
    Multi = true,
    Default = {},
})
MultiDropdown:OnChanged(function(Value) end)
local function GetSelectedTypes()
    local selected = {}
    for v, state in next, Options.BrainrotDropdown.Value do
        if state then selected[v] = true end
    end
    return selected
end
local function FindMyBase()
    local basesFolder = workspace:FindFirstChild("Bases")
    if not basesFolder then return nil end
    for i = 1, 6 do
        local base = basesFolder:FindFirstChild("Base_" .. i)
        if base then
            local owner = base:GetAttribute("Owner")
            if tostring(owner) == tostring(LocalPlayer.UserId) then
                local indicator = base:FindFirstChild("Indicator")
                if indicator then
                    local main = indicator:FindFirstChild("Main")
                    if main then return main end
                end
            end
        end
    end
    return nil
end
local function TeleportTo(target)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if typeof(target) == "Vector3" then
        hrp.CFrame = CFrame.new(target)
    elseif typeof(target) == "Instance" then
        hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
    end
end
local function GetBrainrotParts(selectedTypes)
    local parts = {}
    local visuals = workspace:FindFirstChild("Zones") and workspace.Zones:FindFirstChild("Visuals")
    if not visuals then return parts end
    for _, zoneModel in ipairs(visuals:GetChildren()) do
        local brainrotsFolder = zoneModel:FindFirstChild("Brainrots")
        if brainrotsFolder then
            local innerBrainrots = brainrotsFolder:FindFirstChild("Brainrots")
            if innerBrainrots then
                for _, part in ipairs(innerBrainrots:GetChildren()) do
                    local typeAttr = part:GetAttribute("Type")
                    if typeAttr and selectedTypes[typeAttr] then
                        table.insert(parts, {part = part, zone = zoneModel})
                    end
                end
            end
        end
    end
    return parts
end
task.spawn(function()
    while true do
        task.wait(0.1)
        if not Options.FarmToggle.Value then
            task.wait(1)
        else
            local selectedTypes = GetSelectedTypes()
            local anySelected = false
            for _, _ in next, selectedTypes do anySelected = true break end
            if not anySelected then task.wait(1) continue end
            TeleportTo(Vector3.new(-1006, 377, -692))
            task.wait(2)
            local brainrotParts = GetBrainrotParts(selectedTypes)
            if #brainrotParts == 0 then
                task.wait(1)
                continue
            end
            local CarryRF = ReplicatedStorage
                :WaitForChild("Packages")
                :WaitForChild("_Index")
                :WaitForChild("sleitnick_knit@1.7.0")
                :WaitForChild("knit")
                :WaitForChild("Services")
                :WaitForChild("CarryService")
                :WaitForChild("RF")
                :WaitForChild("Carry")
            for _, entry in ipairs(brainrotParts) do
                if not Options.FarmToggle.Value then break end
                local part = entry.part
                if part and part.Parent then
                    pcall(function()
                        CarryRF:InvokeServer(part)
                    end)
                    task.wait(1)
                    local myBase = FindMyBase()
                    if myBase then
                        TeleportTo(myBase)
                    end
                    task.wait(1.5)
                end
            end
        end
    end
end)
-----
-----
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SUFFIXES = { T = 1e12, B = 1e9, M = 1e6 }
local function parseRate(text)
    local clean = text:gsub("^%$", ""):gsub("/s$", ""):gsub(",", "")
    local num, suffix = clean:match("^([%d%.]+)([TBM]?)$")
    if not num then return 0 end
    local value = tonumber(num) or 0
    if suffix and SUFFIXES[suffix] then
        value = value * SUFFIXES[suffix]
    end
    return value
end
local function formatRate(value)
    local formatted
    if value >= 1e12 then
        formatted = string.format("$%.2fT/s", value / 1e12)
    elseif value >= 1e9 then
        formatted = string.format("$%.2fB/s", value / 1e9)
    elseif value >= 1e6 then
        formatted = string.format("$%.2fM/s", value / 1e6)
    elseif value >= 1000 then
        local s = tostring(math.floor(value))
        formatted = "$" .. s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") .. "/s"
    else
        formatted = string.format("$%.1f/s", value)
    end
    return formatted
end
local function getMyBase()
    local basesFolder = workspace:FindFirstChild("Bases")
    if not basesFolder then return nil end
    for i = 1, 6 do
        local base = basesFolder:FindFirstChild("Base_" .. i)
        if base and base:GetAttribute("Owner") == LocalPlayer.UserId then
            return base
        end
    end
    return nil
end
local function getTotalRate()
    local base = getMyBase()
    if not base then return nil end
    local slots = base:FindFirstChild("Slots")
    if not slots then return nil end
    local brainrotParts = {}
    for _, slot in ipairs(slots:GetChildren()) do
        local brainrot = slot:FindFirstChild("Brainrot")
        if brainrot then
            brainrotParts[brainrot] = true
        end
    end
    local total = 0
    local found = 0
    for _, billboard in ipairs(LocalPlayer.PlayerGui.Tags:GetChildren()) do
        if billboard:IsA("BillboardGui") then
            local adornee = billboard.Adornee
            if adornee and brainrotParts[adornee] then
                local container = billboard:FindFirstChild("Container")
                local rate = container and container:FindFirstChild("Rate")
                if rate and rate:IsA("TextLabel") then
                    total = total + parseRate(rate.Text)
                    found = found + 1
                end
            end
        end
    end
    if found == 0 then return nil end
    return formatRate(total)
end
Tabs.Main:AddButton({
    Title = "Check Base 💰/s",
    Callback = function()
        local result = getTotalRate()
        Fluent:Notify({
            Title = "Total Base 💰/s",
            Content = result or "Could not calculate rate",
            Duration = 5
        })
    end
})
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
