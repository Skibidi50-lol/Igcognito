local Plr = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Comm = RS:WaitForChild("Communication")
local RebirthRemote = Comm:WaitForChild("Request Rebirth")
local PingRemote = Comm:WaitForChild("ActivePing")
local InactiveRemote = Comm:WaitForChild("Inactivity")
local AFKTpRemote = Comm:WaitForChild("RequestAFKReturnTeleport")
local ChestRemote = Comm:WaitForChild("ChestCommunication")
local TickRemote = Comm:WaitForChild("Tick")
local FXRemote = Comm:WaitForChild("FX")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Hub = Rayfield:CreateWindow({
    Name = "Igcognito | Aura Ascension",
    LoadingTitle = "Loading.",
    LoadingSubtitle = "By Skibidi50-lol.",
    ConfigurationSaving = {Enabled = true, FolderName = "Igcognito", FileName = "Config"},
    Discord = {Enabled = false},
    KeySystem = false
})

local S = {
    farming = false, rebirthing = false, antiAfk = true,
    autoChest = false, speedOn = false, dismiss = false,
    curZone = "None", tickAmt = 0, sessAura = 0, sessRebirths = 0,
    sessStart = os.clock(), rebirthDelay = 1, speedVal = 50,
    manualZone = "Auto", rebLoop = false, farmLoop = false,
    chestLoop = false, afkStarted = false
}

local ZoneReqs = {
    {name="Fire Bath", req=1e8},
    {name="Dark Lava", req=1e15},
    {name="Ancient Ruins", req=1e20},
    {name="Electra Field", req=1e26},
    {name="Divine Realm", req=1e30},
    {name="Frost Heaven", req=1e35},
    {name="Fallen Star", req=1e40}
}

local Ranks = {
    {n="Noob",m=2,r=0},{n="No Aura",m=8,r=10},{n="Sigma",m=28,r=100},
    {n="Aura Farmer",m=95,r=1e3},{n="Mogger",m=320,r=1e4},
    {n="Aura Maestro",m=1050,r=1.5e5},{n="Chad",m=3400,r=2e6},
    {n="Main Character",m=16000,r=2.5e7},{n="Shadow",m=24000,r=8e7},
    {n="Ascendant",m=40000,r=1e8},{n="Conqueror",m=95000,r=1e9},
    {n="Vanguard",m=220000,r=1e10},{n="Chromatic",m=520000,r=1e11},
    {n="Sentinel",m=1250000,r=1e12},{n="Overlord",m=3e6,r=1e13},
    {n="Dominator",m=5.5e6,r=5e13},{n="Final Boss",m=1.762e7,r=1e14},
    {n="Paragon",m=3.876e7,r=1e15},{n="Imperator",m=8.528e7,r=1e16},
    {n="Supreme",m=1.876e8,r=1e17},{n="Archeox",m=3.2e8,r=8e17},
    {n="Emperor",m=7.8e8,r=5e18},{n="Celestial",m=9e8,r=2e19},
    {n="Superior",m=1.2e9,r=4e19},{n="Menace",m=1.45e9,r=6.5e19},
    {n="Grim Reaper",m=1.75e9,r=1e20},{n="The Honored One",m=2.15e9,r=1.4e20},
    {n="Antagonist",m=2.6e9,r=1.85e20},{n="Deltaversal",m=3.1e9,r=2.2e20},
    {n="Chronomancer",m=4.2e9,r=2.6e20},{n="ArchWarrior",m=4.393e9,r=3e20},
    {n="Divine",m=7e9,r=8e20},{n="Cosmic",m=1.2e10,r=3e21},
    {n="APEX",m=2.1e10,r=1e22},{n="Heptagon",m=3.8e10,r=4e22},
    {n="Transcendent",m=6.5e10,r=1.5e23},{n="God of Aura",m=1.1e11,r=6e23},
    {n="Anti-Hero",m=1.9e11,r=2e24},{n="Nemesis",m=3.2e11,r=6e24},
    {n="Malevolent",m=5.5e11,r=1.8e25},{n="The Cursed One",m=9e11,r=5e25},
    {n="Eradicator",m=1.4e12,r=1.4e26},{n="Abyss Lord",m=1.7e12,r=3.6e26},
    {n="Hyperion",m=2.1e12,r=9e26},{n="Redacted",m=2.5e12,r=2.2e27},
    {n="E N T I T Y",m=3e12,r=5.2e27},{n="Superhuman",m=3.6e12,r=1.2e28},
    {n="Sendevian",m=4.2e12,r=2.8e28},{n="Awakening",m=5e12,r=6.4e28},
    {n="Prodigy",m=5.8e12,r=1.5e29},{n="Mastermind",m=8e12,r=3.2e29},
    {n="Too Much Aura",m=1.1e13,r=7e29},{n="Omniscient",m=1.5e13,r=1.3e30},
    {n="Absolute",m=2.2e13,r=3e30},{n="Almighty",m=2.7e13,r=7e30},
    {n="Metaversal",m=3.2e13,r=1.6e31},{n="Ultrapotent",m=3.9e13,r=3.8e31},
    {n="Powerious",m=4.6e13,r=9e31},{n="Anthropeak",m=5.5e13,r=2.1e32},
    {n="I N F I N I T E",m=6.5e13,r=5e32},{n="S I N G U L A R I T Y",m=9e13,r=1.2e33},
    {n="L I M I T L E S S",m=1.3e14,r=3e33},{n="B O U N D L E S S",m=1.8e14,r=7e33},
    {n="F A L L E N   A N G E L",m=2.5e14,r=1.7e34},{n="The Ultimate",m=3.5e14,r=4e34},
    {n="Simply Better",m=5e14,r=9.5e34},{n="Deity",m=7e14,r=2.3e35},
    {n="The Ascension",m=1e15,r=8e35},{n="Nightmare",m=1.4e15,r=4e38},
    {n="True Genesis",m=2e15,r=7e39},{n="Abomination",m=2.8e15,r=5e41}
}

local function fmt(n)
    if not n or n == 0 then return "0" end
    local sf = {"","K","M","B","T","Qa","Qi","Sx","Sp","Oc","No","Dc","Ud","Dd","Txd","Exd","VgD"}
    if n < 1000 then return tostring(math.floor(n)) end
    local e = math.clamp(math.floor(math.log10(math.max(n,1))/3), 1, #sf-1)
    local v = n / (10^(e*3))
    local d = v < 10 and 2 or (v < 100 and 1 or 0)
    return string.format("%."..d.."f%s", v, sf[e+1])
end

local function getRoot()
    local c = Plr.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = Plr.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getAura()
    return Plr:GetAttribute("Aura") or 0
end

local function getRebirths()
    return Plr:GetAttribute("Rebirths") or 0
end

local function getRank(a)
    local out = Ranks[1]
    for i = 1, #Ranks do
        if a >= Ranks[i].r then out = Ranks[i] else break end
    end
    return out
end

local function getRankIdx(a)
    local idx = 1
    for i = 1, #Ranks do
        if a >= Ranks[i].r then idx = i else break end
    end
    return idx
end

local function getProgress(a)
    local i = getRankIdx(a)
    if i >= #Ranks then return 1 end
    local cur = Ranks[i].r
    local nxt = Ranks[i+1].r
    return math.clamp((a - cur) / (nxt - cur), 0, 1)
end

local cachedZones = nil

local function loadZones()
    if cachedZones then return cachedZones end
    local ta = workspace:FindFirstChild("Training Areas")
    if not ta then return {} end
    local out = {}
    for _, z in ipairs(ta:GetChildren()) do
        local hb = z:FindFirstChild("AreaHitbox")
        if hb then
            local req = 0
            for _, zr in ipairs(ZoneReqs) do
                if zr.name == z.Name then req = zr.req break end
            end
            table.insert(out, {name=z.Name, req=req, pos=hb.Position, part=hb})
        end
    end
    table.sort(out, function(a,b) return a.req < b.req end)
    cachedZones = out
    return out
end

local function getPadCF()
    local pad = workspace:FindFirstChild("RebirthPad")
    if pad then
        local tp = pad:FindFirstChild("TouchPart")
        if tp then return tp.CFrame + Vector3.new(0,3,0) end
    end
    return CFrame.new(0,50,0)
end

local function bestZone(a, zones)
    for i = #zones, 1, -1 do
        if a >= zones[i].req then return zones[i] end
    end
    return zones[1]
end

local function nextUnlock(a, zones)
    for _, z in ipairs(zones) do
        if a < z.req then return z end
    end
    return nil
end

local function tp(cf)
    local r = getRoot()
    if r then r.CFrame = cf end
end

local function tpZone(z)
    if z and z.pos then
        tp(CFrame.new(z.pos + Vector3.new(0,5,0)))
        S.curZone = z.name
    end
end

local function fireRebirth()
    local ok, res = pcall(function() return RebirthRemote:InvokeServer() end)
    return ok and res
end

local function doManualRebirth()
    local root = getRoot()
    if not root then return end
    local savedCF = root.CFrame
    tp(getPadCF())
    task.wait(0.35)
    local ok = fireRebirth()
    task.wait(0.25)
    if ok then S.sessRebirths = S.sessRebirths + 1 end
    if S.farming then
        local bz = bestZone(getAura(), loadZones())
        if bz then tpZone(bz) else tp(savedCF) end
    else
        tp(savedCF)
    end
end

local function farmLoop()
    if S.farmLoop then return end
    S.farmLoop = true
    task.spawn(function()
        local zones = loadZones()
        while S.farming do
            local a = getAura()
            local target = nil
            if S.manualZone ~= "Auto" then
                for _, z in ipairs(zones) do
                    if z.name == S.manualZone then target = z break end
                end
            end
            if not target then target = bestZone(a, zones) end
            if target then
                local root = getRoot()
                if root then
                    if (root.Position - target.pos).Magnitude > 30 then
                        tpToZone = target
                        tpZone(target)
                    else
                        S.curZone = target.name
                    end
                end
            end
            task.wait(2)
        end
        S.farmLoop = false
    end)
end

local function rebirthLoop()
    if S.rebLoop then return end
    S.rebLoop = true
    task.spawn(function()
        while S.rebirthing do
            local a = getAura()
            if a >= 1000 then
                local shouldGo = true
                if S.tickAmt > 0 and a < 5000 then
                    local secToRecover = 1000 / S.tickAmt
                    if secToRecover > 30 then shouldGo = false end
                end
                if shouldGo then
                    tp(getPadCF())
                    task.wait(0.35)
                    local ok = fireRebirth()
                    if ok then S.sessRebirths = S.sessRebirths + 1 end
                    task.wait(S.rebirthDelay)
                    if S.farming then
                        local bz = bestZone(getAura(), loadZones())
                        if bz then tpZone(bz) end
                    end
                    task.wait(0.3)
                end
            end
            task.wait(0.8)
        end
        S.rebLoop = false
    end)
end

local function antiAfk()
    if S.afkStarted then return end
    S.afkStarted = true
    task.spawn(function()
        while S.antiAfk do
            pcall(function() PingRemote:FireServer(false) end)
            local root = getRoot()
            if root and root.Anchored then root.Anchored = false end
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendMouseMoveEvent(5, 5, game)
            end)
            task.wait(12)
        end
        S.afkStarted = false
    end)
    pcall(function()
        local old = hookfunction(AFKTpRemote.FireServer, newcclosure(function(self, ...)
            if self == AFKTpRemote then return end
            return old(self, ...)
        end))
    end)
    pcall(function()
        local old2 = hookfunction(InactiveRemote.FireServer, newcclosure(function(self, ...)
            if self == InactiveRemote then return end
            return old2(self, ...)
        end))
    end)
end

local function chestLoop()
    if S.chestLoop then return end
    S.chestLoop = true
    task.spawn(function()
        while S.autoChest do
            pcall(function() ChestRemote:FireServer("Claim") end)
            task.wait(305)
        end
        S.chestLoop = false
    end)
end

local function dismissLoop()
    task.spawn(function()
        while S.dismiss do
            pcall(function()
                local pg = Plr:FindFirstChild("PlayerGui")
                if not pg then return end
                local tut = pg:FindFirstChild("Tutorial")
                if tut then tut.Enabled = false end
                for _, gui in ipairs(pg:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Name ~= "Rayfield" then
                        for _, fr in ipairs(gui:GetDescendants()) do
                            if fr:IsA("TextButton") then
                                local txt = fr.Text:lower()
                                if txt == "x" or txt == "close" or txt == "dismiss" or txt == "ok" then
                                    pcall(function() fr.Visible = false end)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(3)
        end
    end)
end

TickRemote.OnClientEvent:Connect(function(amt)
    if type(amt) == "number" then
        S.tickAmt = amt
        S.sessAura = S.sessAura + amt
    end
end)

Plr.CharacterAdded:Connect(function(c)
    task.wait(1)
    if S.antiAfk then
        local r = c:WaitForChild("HumanoidRootPart", 5)
        if r and r.Anchored then r.Anchored = false end
    end
    if S.farming then
        task.wait(0.5)
        local bz = bestZone(getAura(), loadZones())
        if bz then tpZone(bz) end
    end
    if S.speedOn then
        local h = c:WaitForChild("Humanoid", 5)
        if h then h.WalkSpeed = S.speedVal end
    end
end)

UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.R then
        task.spawn(doManualRebirth)
    end
end)

local FarmTab = Hub:CreateTab("Farming", "rotate-cw")
local RebTab = Hub:CreateTab("Rebirth", "refresh-cw")
local StatTab = Hub:CreateTab("Stats", "bar-chart-2")
local TPTab = Hub:CreateTab("Teleport", "map-pin")
local MiscTab = Hub:CreateTab("Misc", "settings")

FarmTab:CreateSection("Zone Farming")

FarmTab:CreateToggle({
    Name = "Smart Auto-Farm",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(v)
        S.farming = v
        if v then farmLoop() end
    end
})

local zNames = {"Auto"}
for _, z in ipairs(ZoneReqs) do table.insert(zNames, z.name) end

FarmTab:CreateDropdown({
    Name = "Zone Override",
    Options = zNames,
    CurrentOption = {"Auto"},
    Flag = "ZoneSelect",
    Callback = function(o) S.manualZone = o[1] or "Auto" end
})

local lbZone = FarmTab:CreateLabel("Zone: scanning...")
local lbAuraP = FarmTab:CreateLabel("Progress: ...")

FarmTab:CreateSection("Movement")

FarmTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Flag = "SpeedBoost",
    Callback = function(v)
        S.speedOn = v
        local h = getHum()
        if h then h.WalkSpeed = v and S.speedVal or 16 end
    end
})

FarmTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 50,
    Flag = "WalkSpeed",
    Callback = function(v)
        S.speedVal = v
        if S.speedOn then
            local h = getHum()
            if h then h.WalkSpeed = v end
        end
    end
})

RebTab:CreateSection("Automated Rebirth")

RebTab:CreateToggle({
    Name = "Aggressive Auto-Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(v)
        S.rebirthing = v
        if v then rebirthLoop() end
    end
})

RebTab:CreateSlider({
    Name = "Cycle Delay (s)",
    Range = {0.5, 5},
    Increment = 0.5,
    CurrentValue = 1,
    Flag = "RebDelay",
    Callback = function(v) S.rebirthDelay = v end
})

RebTab:CreateSection("Manual")

RebTab:CreateButton({
    Name = "Rebirth Now (TP > Rebirth > Return) [R Key]",
    Callback = function() task.spawn(doManualRebirth) end
})

RebTab:CreateButton({
    Name = "Fire Rebirth Remote Only (No TP)",
    Callback = function()
        task.spawn(function()
            local ok = fireRebirth()
            if ok then
                S.sessRebirths = S.sessRebirths + 1
                Rayfield:Notify({Title="Rebirth", Content="Success!", Duration=2})
            else
                Rayfield:Notify({Title="Rebirth", Content="Failed", Duration=2})
            end
        end)
    end
})

local lbReb = RebTab:CreateLabel("Rebirths: 0")
local lbMult = RebTab:CreateLabel("Multiplier: x1")
local lbRPH = RebTab:CreateLabel("Rebirths/hr: 0")
local lbETA = RebTab:CreateLabel("ETA Rebirth: N/A")

StatTab:CreateSection("Live Dashboard")
local stAura = StatTab:CreateLabel("Aura: 0")
local stRank = StatTab:CreateLabel("Rank: Noob")
local stProg = StatTab:CreateLabel("Next Rank: 0%")
local stReb = StatTab:CreateLabel("Rebirths: 0")
local stZone = StatTab:CreateLabel("Zone: None")
local stTick = StatTab:CreateLabel("Aura/Tick: 0")
local stEtaZ = StatTab:CreateLabel("Next Zone: N/A")
local stEtaR = StatTab:CreateLabel("ETA Rebirth: N/A")
local stSessA = StatTab:CreateLabel("Session Aura: 0")
local stSessR = StatTab:CreateLabel("Session Rebirths: 0")
local stUp = StatTab:CreateLabel("Uptime: 00:00:00")

task.spawn(function()
    task.wait(4)
    local zones = loadZones()
    TPTab:CreateSection("Training Areas")
    for _, z in ipairs(zones) do
        TPTab:CreateButton({
            Name = z.name .. " [" .. fmt(z.req) .. "]",
            Callback = function() tpZone(z) end
        })
    end
    TPTab:CreateSection("Landmarks")
    TPTab:CreateButton({
        Name = "Rebirth Pad",
        Callback = function() tp(getPadCF()) end
    })
    TPTab:CreateButton({
        Name = "Chest",
        Callback = function()
            pcall(function()
                local hb = workspace.Map.Chest.Hitbox
                tp(CFrame.new(hb.Position + Vector3.new(0,5,0)))
            end)
        end
    })
end)

MiscTab:CreateSection("Anti-Cheat Bypass")

MiscTab:CreateToggle({
    Name = "Anti-AFK (Bulletproof)",
    CurrentValue = true,
    Flag = "AntiAFK",
    Callback = function(v) S.antiAfk = v if v then antiAfk() end end
})

MiscTab:CreateSection("Automation")

MiscTab:CreateToggle({
    Name = "Auto Chest Claim (5min)",
    CurrentValue = false,
    Flag = "AutoChest",
    Callback = function(v) S.autoChest = v if v then chestLoop() end end
})

MiscTab:CreateToggle({
    Name = "Auto-Dismiss Popups",
    CurrentValue = false,
    Flag = "AutoDismiss",
    Callback = function(v) S.dismiss = v if v then dismissLoop() end end
})

MiscTab:CreateSection("Flex")

MiscTab:CreateButton({
    Name = "Flash My Aura (FX)",
    Callback = function()
        pcall(function() FXRemote:FireServer(Plr.UserId) end)
    end
})

MiscTab:CreateSection("Server")

MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, Plr)
        end)
    end
})

MiscTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Plr)
        end)
    end
})

antiAfk()

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local a = getAura()
            local rb = getRebirths()
            local rank = getRank(a)
            local prog = getProgress(a)
            local idx = getRankIdx(a)
            local zones = loadZones()
            local nz = nextUnlock(a, zones)
            local up = os.clock() - S.sessStart
            local ut = string.format("%02d:%02d:%02d", math.floor(up/3600), math.floor(up%3600/60), math.floor(up%60))

            stAura:Set("Aura: " .. fmt(a))
            stRank:Set("Rank: " .. rank.n .. " (x" .. fmt(rank.m) .. ")")
            if idx < #Ranks then
                stProg:Set("Next: " .. Ranks[idx+1].n .. " [" .. math.floor(prog*100) .. "%]")
            else
                stProg:Set("Rank: MAX")
            end
            stReb:Set("Rebirths: " .. fmt(rb))
            stZone:Set("Zone: " .. S.curZone)
            stTick:Set("Aura/Tick: +" .. fmt(S.tickAmt))

            if nz then
                if S.tickAmt > 0 then
                    local need = nz.req - a
                    if need > 0 then
                        local sec = need / S.tickAmt
                        if sec > 86400 then
                            stEtaZ:Set("Next Zone: " .. nz.name .. " in " .. string.format("%.1fd", sec/86400))
                        elseif sec > 3600 then
                            stEtaZ:Set("Next Zone: " .. nz.name .. " in " .. string.format("%.1fh", sec/3600))
                        else
                            stEtaZ:Set("Next Zone: " .. nz.name .. " in " .. string.format("%.0fm", sec/60))
                        end
                    else
                        stEtaZ:Set("Next Zone: " .. nz.name .. " READY!")
                    end
                else
                    stEtaZ:Set("Next Zone: " .. nz.name .. " [" .. fmt(nz.req) .. "]")
                end
            else
                stEtaZ:Set("All Zones Unlocked")
            end

            if a >= 1000 then
                stEtaR:Set("Rebirth: READY NOW")
            elseif S.tickAmt > 0 then
                stEtaR:Set("Rebirth in: " .. string.format("%.0fs", (1000 - a) / S.tickAmt))
            else
                stEtaR:Set("Rebirth: waiting for ticks...")
            end

            stSessA:Set("Session Aura: " .. fmt(S.sessAura))
            stSessR:Set("Session Rebirths: " .. S.sessRebirths)
            stUp:Set("Uptime: " .. ut)

            lbZone:Set("Zone: " .. S.curZone)
            lbAuraP:Set("Aura: " .. fmt(a) .. " | Rank: " .. rank.n)
            lbReb:Set("Rebirths: " .. fmt(rb))
            lbMult:Set("Multiplier: x" .. fmt(rank.m))

            local rph = 0
            if up > 60 then rph = math.floor(S.sessRebirths / (up/3600)) end
            lbRPH:Set("Rebirths/hr: " .. rph)

            if a >= 1000 then
                lbETA:Set("ETA: READY")
            elseif S.tickAmt > 0 then
                lbETA:Set("ETA: " .. string.format("%.0fs", (1000-a)/S.tickAmt))
            else
                lbETA:Set("ETA: waiting...")
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(1) do
        if S.speedOn then
            local h = getHum()
            if h and h.WalkSpeed ~= S.speedVal then h.WalkSpeed = S.speedVal end
        end
        if S.antiAfk then
            local r = getRoot()
            if r and r.Anchored then r.Anchored = false end
        end
    end
end)

Rayfield:Notify({Title="Aura Farm Hub", Content="Loaded! R = manual rebirth", Duration=5})
