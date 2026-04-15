local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowCheckboxFrameInKeybinds = true

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

task.spawn(function()
    local function checkAndDestroy(obj)
        if obj:IsA("ScreenGui") or obj:IsA("LocalScript") then
            local name = obj.Name:lower()
            if name == "anitcheat" or name == "anticheat" then
                obj:Destroy()
            end
        end
    end
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if playerGui then
        for _, v in ipairs(playerGui:GetDescendants()) do
            checkAndDestroy(v)
        end
        playerGui.DescendantAdded:Connect(checkAndDestroy)
    end
end)

local successHook, errHook = pcall(function()
    local gm = getrawmetatable(game)
    local oldNamecall = gm.__namecall
    setreadonly(gm, false)
    
    gm.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "Kick" or method == "kick" then
            if self == LocalPlayer then return nil end
        end
        
        if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
            local remoteName = tostring(self.Name):lower()
            if remoteName == "kick" or remoteName == "ban" then return nil end
            
            for _, v in pairs(args) do
                if type(v) == "string" then
                    local argString = v:lower()
                    if argString == "kick" or argString == "ban" then return nil end
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)

    setreadonly(gm, true)
end)

local Window = Library:CreateWindow({
	Title = "Igcognito - BBN",
	Footer = "version: 1.0",
	NotifySide = "Right",
    Size = UDim2.fromOffset(736, 450),
	ShowCustomCursor = true,
})

Window:AddDialog("EmptyDialogueIdx", {
    Title = "Igcognito",
    Description = "This script is in beta so you may occurs bugs",
    AutoDismiss = true,
    OutsideClickDismiss = true,
    FooterButtons = {
        Confirm = {
            Title = "Okay",
            Variant = "Primary",
            Callback = function() end
        }
    }
})

local Tabs = {
    Info = Window:AddTab("Information", "info"),
    AntiCheat = Window:AddTab("Anti Cheat", "triangle-alert"),
    Emotes = Window:AddTab("Free Emotes", "smile"),
    Main = Window:AddTab("Main", "user"),
    Survivor = Window:AddTab("Survivor", "person-standing"),
    Killer = Window:AddTab("Killer", "sword"),
    Visual = Window:AddTab("Visual", "eye"),
    Teleport = Window:AddTab("Teleport", "map"),
    Others = Window:AddTab("Others", "more-horizontal"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local pp = Instance.new("Part")
pp.Name = "pp"
pp.Size = Vector3.new(50, 2, 50)
pp.Position = Vector3.new(0, 1000, 0)
pp.Anchored = true
pp.CanCollide = true
pp.Material = Enum.Material.ForceField
pp.Color = Color3.fromRGB(0, 170, 255)
pp.Transparency = 0.3
pp.Parent = Workspace

if math.random(1,50) == 1 then
    Library:Notify({Title = "Bite By Night", Description = "Special moment activated!", Time = 5})
else
    Library:Notify({Title = "Bite By Night", Description = "Script loaded successfully.", Time = 3})
end

-- Info Tab
local infoBox = Tabs.Info:AddLeftGroupbox("Script Information", "info")
infoBox:AddLabel("[<font color=\"rgb(73, 230, 133)\">Update Note</font>]")
infoBox:AddDivider()
infoBox:AddLabel("Beta 1.0.0")
infoBox:AddLabel("[+] Release")

local discordBox = Tabs.Info:AddLeftGroupbox("Discord", "info")
discordBox:AddButton({
    Text = "Copy Discord Link",
    Func = function()
       setclipboard("https://discord.gg/GnN6AmEvtN")
       Library:Notify({Title = "Discord", Description = "Successfully Copied Discord Link!", Time = 5})
    end
})

local suggestBox = Tabs.Info:AddRightGroupbox("Suggestion", "message-square")
suggestBox:AddInput("SuggestText", {
    Text = "Your Suggestion",
    Placeholder = "Type your suggestion here...",
    ClearTextOnFocus = false,
})
suggestBox:AddDropdown("SuggestLang", {
    Values = { "English", "Spanish", "French", "Portuguese", "Russian", "Turkish", "Vietnamese", "German", "Other" },
    Default = "English",
    Text = "Language"
})
suggestBox:AddButton({
    Text = "Send Suggestion",
    Func = function()
        local suggestion = Options.SuggestText.Value or ""
        local language = Options.SuggestLang.Value or "English"
        if suggestion:gsub("%s", "") == "" then
            Library:Notify({Title = "Suggestion", Description = "Please write a suggestion!", Time = 4})
            return
        end
        local webhook_url = "https://discord.com/api/webhooks/1456197284416196648/ha4HuUz_5I-zS67EDENDlkP3M1lI47eyTORV0mo09C64IwN146yo0YSYG01EWaIzPeBg"
        local player = game.Players.LocalPlayer
        local username = player.Name
        local userid = player.UserId
        local executor = tostring(identifyexecutor() or "Unknown")
        local currentTime = os.date("%B %d, %Y - %I:%M %p")
        local embed = {
            ["title"] = "New Igcognito Suggestion",
            ["description"] = "**" .. suggestion .. "**",
            ["color"] = 16747520,
            ["fields"] = {
                {["name"] = "Username", ["value"] = username, ["inline"] = false},
                {["name"] = "User ID", ["value"] = tostring(userid), ["inline"] = false},
                {["name"] = "Executor", ["value"] = executor, ["inline"] = false},
                {["name"] = "Language", ["value"] = language, ["inline"] = false},
                {["name"] = "Time", ["value"] = currentTime, ["inline"] = false}
            },
            ["footer"] = {["text"] = "Bite By Night Suggestion"},
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
        local payload = {["embeds"] = {embed}}
        local success, err = pcall(function()
            request({
                Url = webhook_url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = game:GetService("HttpService"):JSONEncode(payload)
            })
        end)
        if success then
            Library:Notify({Title = "Suggestion", Description = "Sent successfully!", Time = 4})
            Options.SuggestText:SetValue("")
        else
            Library:Notify({Title = "Suggestion", Description = "Failed to send (check webhook)", Time = 5})
        end
    end
})

-- AntiCheat Tab
local acKeywords = {"anticheat", "ac", "kick", "ban", "detect"}
local hookedACFunctions = {}

local ACBox = Tabs.AntiCheat:AddLeftGroupbox("Anti Cheat Bypass", "triangle-alert")
ACBox:AddCheckbox('ACCheckbox', {
    Text = 'AC Bypass',
    Default = true,
    Callback = function(Value)
        if Value then
          for _, v in pairs(getgc()) do
              if type(v) == "function" and islclosure(v) then
                  local info = debug.getinfo(v)
                  if info and info.name then
                      local funcName = string.lower(info.name)
                      for _, keyword in ipairs(acKeywords) do
                          if string.find(funcName, keyword) then
                              hookedACFunctions[v] = hookfunction(v, function() return end)
                          end
                      end
                  end
              end
          end
      else
          for orig, hook in pairs(hookedACFunctions) do
              hookfunction(orig, hook)
          end
          table.clear(hookedACFunctions)
      end
    end
})

-- Emotes Tab
local EmotesBox = Tabs.Emotes:AddLeftGroupbox("Free Emotes", "smile")
local storedEmotes = {}
local emoteDropdownList = {"Select Emote First"}
local selectedEmoteObj = nil
local activeEmoteTrack = nil
local activeEffects = {} 

local function updateEmoteList()
    table.clear(storedEmotes)
    table.clear(emoteDropdownList)
    local repStorage = game:GetService("ReplicatedStorage")
    local modulesFolder = repStorage:FindFirstChild("Modules")
    local emotesFolder = modulesFolder and modulesFolder:FindFirstChild("Emotes")
    if emotesFolder then
        pcall(function()
            for _, obj in ipairs(emotesFolder:GetChildren()) do
                if obj:IsA("ModuleScript") and obj.Name ~= "EmoteClass" then
                    local nameLower = string.lower(obj.Name)
                    if not string.find(nameLower, "ennard") then
                        storedEmotes[obj.Name] = obj
                        table.insert(emoteDropdownList, obj.Name)
                    end
                end
            end
        end)
    end
    if #emoteDropdownList == 0 then table.insert(emoteDropdownList, "No Emotes Found") end
end
updateEmoteList()

EmotesBox:AddDropdown('EmotesDropdown', {
    Values = emoteDropdownList,
    Default = "Select An Emote First",
    Multi = false,
    Text = 'Select Emote',
    Callback = function(Option)
       local opt = type(Option) == "table" and Option[1] or Option
       if storedEmotes[opt] then
           selectedEmoteObj = storedEmotes[opt]
       end
    end
})

EmotesBox:AddCheckbox('EmotesCheckbox', {
    Text = 'Play Emote',
    Default = false,
    Callback = function(Value)
        local char = LocalPlayer.Character
       local hum = char and char:FindFirstChildOfClass("Humanoid")
       local animator = hum and hum:FindFirstChildOfClass("Animator")
       local rootPart = char and char:FindFirstChild("HumanoidRootPart")
       if Value then
           if selectedEmoteObj and animator then
               pcall(function()
                   local anim = selectedEmoteObj:FindFirstChildOfClass("Animation")
                   if anim then
                       activeEmoteTrack = animator:LoadAnimation(anim)
                       activeEmoteTrack.Looped = true
                       activeEmoteTrack:Play()
                   else
                       local emoteData = require(selectedEmoteObj)
                       if type(emoteData) == "table" and emoteData.AnimationId then
                           local tempAnim = Instance.new("Animation")
                           tempAnim.AnimationId = emoteData.AnimationId
                           activeEmoteTrack = animator:LoadAnimation(tempAnim)
                           activeEmoteTrack.Looped = true
                           activeEmoteTrack:Play()
                       end
                   end
                   for _, child in ipairs(selectedEmoteObj:GetDescendants()) do
                       if child:IsA("Sound") then
                           local sfx = child:Clone()
                           sfx.Parent = rootPart or char
                           sfx:Play()
                           table.insert(activeEffects, sfx)
                       elseif child:IsA("ParticleEmitter") or child:IsA("PointLight") then
                           local fx = child:Clone()
                           fx.Parent = rootPart
                           table.insert(activeEffects, fx)
                       elseif child:IsA("MeshPart") or child:IsA("Part") then
                           local prop = child:Clone()
                           prop.Parent = char
                           local weld = Instance.new("WeldConstraint")
                           weld.Part0 = char:FindFirstChild("RightHand") or rootPart
                           weld.Part1 = prop
                           weld.Parent = prop
                           prop.CanCollide = false
                           prop.Massless = true
                           table.insert(activeEffects, prop)
                       end
                   end
               end)
           end
       else
           if activeEmoteTrack then
               activeEmoteTrack:Stop()
               activeEmoteTrack = nil
           end
           for _, effect in ipairs(activeEffects) do
               if effect and effect.Parent then
                   effect:Destroy()
               end
           end
           table.clear(activeEffects)
       end
    end
})

-- Main Tab - Movement Group
local MovementGroup = Tabs.Main:AddLeftGroupbox("Movement", "user")

local infiniteSprint = false
local sprintConn = nil
MovementGroup:AddCheckbox("Infinite Sprint", {
    Text = "Infinite Sprint",
    Default = false,
    Callback = function(state)
        infiniteSprint = state
        if state then
            sprintConn = RunService.Heartbeat:Connect(function()
                if not infiniteSprint then return end
                local char = LocalPlayer.Character
                if not char then return end
                if isMobile then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.MoveDirection.Magnitude > 0 then
                        char:SetAttribute("WalkSpeed", 24)
                    else
                        char:SetAttribute("WalkSpeed", 12)
                    end
                else
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                        char:SetAttribute("WalkSpeed", 25)
                    else
                        char:SetAttribute("WalkSpeed", 12)
                    end
                end
            end)
            Library:Notify({Title = "Infinite Sprint", Description = "Enabled.", Time = 2})
        else
            if sprintConn then sprintConn:Disconnect() end
            local char = LocalPlayer.Character
            if char then char:SetAttribute("WalkSpeed", 12) end
            Library:Notify({Title = "Infinite Sprint", Description = "Disabled.", Time = 2})
        end
    end
})

local jumpBoost = false
local jpLoop, jpCA = nil, nil
MovementGroup:AddCheckbox("Allow Jumping", {
    Text = "Allow Jumping",
    Default = false,
    Callback = function(state)
        jumpBoost = state
        local function applyJumpPower()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if hum.UseJumpPower then
                hum.JumpPower = 1.5
            else
                hum.JumpHeight = 1.5
            end
        end
        if state then
            applyJumpPower()
            if jpLoop then jpLoop:Disconnect() end
            local currentHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if currentHum then
                jpLoop = currentHum:GetPropertyChangedSignal("JumpPower"):Connect(applyJumpPower)
            end
            if jpCA then jpCA:Disconnect() end
            jpCA = LocalPlayer.CharacterAdded:Connect(function(newChar)
                local hum = newChar:WaitForChild("Humanoid")
                applyJumpPower()
                if jpLoop then jpLoop:Disconnect() end
                jpLoop = hum:GetPropertyChangedSignal("JumpPower"):Connect(applyJumpPower)
            end)
            Library:Notify({Title = "Allow Jumping", Description = "Enabled.", Time = 2})
        else
            if jpLoop then jpLoop:Disconnect() end
            if jpCA then jpCA:Disconnect() end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    if hum.UseJumpPower then hum.JumpPower = 0 else hum.JumpHeight = 0 end
                end
            end
            Library:Notify({Title = "Allow Jumping", Description = "Disabled.", Time = 2})
        end
    end
})

local flying = false
local flyConn = nil
MovementGroup:AddCheckbox("Flight", {
    Text = "Flight",
    Default = false,
    Callback = function(state)
        flying = state
        if state then
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then return end
            hum.PlatformStand = true
            root.Anchored = true
            local function noCollide()
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
            noCollide()
            flyConn = RunService.RenderStepped:Connect(function(dt)
                if not flying or not root or not root.Parent then return end
                noCollide()
                local move = Vector3.zero
                local speed = 125
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
                if move.Magnitude > 0 then
                    local direction = move.Unit
                    root.CFrame = root.CFrame + (direction * speed * dt)
                end
                root.CFrame = CFrame.new(root.Position, root.Position + Camera.CFrame.LookVector)
            end)
            Library:Notify({Title = "Flight", Description = "Enabled.", Time = 2})
        else
            if flyConn then flyConn:Disconnect() end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then root.Anchored = false end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
            Library:Notify({Title = "Flight", Description = "Disabled.", Time = 2})
        end
    end
})

local noclipEnabled = false
local noclipConn = nil
MovementGroup:AddCheckbox("Noclip", {
    Text = "Noclip",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
        if state then
            noclipConn = RunService.Stepped:Connect(function()
                if not noclipEnabled then return end
                local char = LocalPlayer.Character
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end)
            Library:Notify({Title = "Noclip", Description = "Enabled.", Time = 2})
        else
            if noclipConn then noclipConn:Disconnect() end
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
            Library:Notify({Title = "Noclip", Description = "Disabled.", Time = 2})
        end
    end
})

local lockOnEnabled = false
local lockedTarget = nil
local inputConnection, renderConnection = nil, nil
MovementGroup:AddCheckbox("Lock On", {
    Text = "Lock On",
    Default = false,
    Callback = function(state)
        lockOnEnabled = state
        Library:Notify({Title = "Lock On", Description = lockOnEnabled and "Enabled." or "Disabled.", Time = 2})
        if state then
            inputConnection = UserInputService.InputBegan:Connect(function(input, gp)
                if gp or input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
                if lockedTarget then
                    lockedTarget = nil
                else
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    local closest, shortest = nil, math.huge
                    for _, other in ipairs(Players:GetPlayers()) do
                        if other ~= LocalPlayer and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (hrp.Position - other.Character.HumanoidRootPart.Position).Magnitude
                            if dist < shortest then
                                shortest = dist
                                closest = other
                            end
                        end
                    end
                    if closest then lockedTarget = closest.Character:FindFirstChild("HumanoidRootPart") end
                end
            end)
            renderConnection = RunService.RenderStepped:Connect(function()
                if lockedTarget then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedTarget.Position)
                end
            end)
        else
            lockedTarget = nil
            if inputConnection then inputConnection:Disconnect() end
            if renderConnection then renderConnection:Disconnect() end
        end
    end
})

local oldLighting = {}
MovementGroup:AddCheckbox("Full Bright", {
    Text = "Full Bright",
    Default = false,
    Callback = function(state)
        if state then
            oldLighting.Brightness = Lighting.Brightness
            oldLighting.ClockTime = Lighting.ClockTime
            oldLighting.FogEnd = Lighting.FogEnd
            oldLighting.GlobalShadows = Lighting.GlobalShadows
            oldLighting.Ambient = Lighting.Ambient
            Lighting.Brightness = 5
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255,255,255)
        else
            if next(oldLighting) then
                Lighting.Brightness = oldLighting.Brightness
                Lighting.ClockTime = oldLighting.ClockTime
                Lighting.FogEnd = oldLighting.FogEnd
                Lighting.GlobalShadows = oldLighting.GlobalShadows
                Lighting.Ambient = oldLighting.Ambient
            end
        end
    end
})

-- Survivor Tab
local SurvivorTasksGroup = Tabs.Survivor:AddLeftGroupbox("Tasks", "list")

local AutoGen = false
local genConn
SurvivorTasksGroup:AddCheckbox("Auto Generator", {
    Text = "Auto Generator",
    Default = false,
    Callback = function(Value)
        AutoGen = Value
        if AutoGen then
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Auto Generator", Text = "Enabled.", Duration = 5})
            genConn = RunService.RenderStepped:Connect(function()
                local plr = Players.LocalPlayer
                if plr.PlayerGui:FindFirstChild("Gen") then
                    plr.PlayerGui.Gen.GeneratorMain.Event:FireServer(true)
                end
            end)
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Auto Generator", Text = "Disabled.", Duration = 5})
            if genConn then genConn:Disconnect() genConn = nil end
        end
    end
})

local autoEscape = false
local autoEscapeConn
SurvivorTasksGroup:AddCheckbox("Auto Escape", {
    Text = "Auto Escape",
    Default = false,
    Callback = function(state)
        autoEscape = state
        if state then
            game:GetService("StarterGui"):SetCore("SendNotification",{Title = "Auto Escape", Text = "Enabled.", Duration = 5})
            local teleported = false
            autoEscapeConn = RunService.RenderStepped:Connect(function()
                if teleported or not autoEscape then return end
                local char = LocalPlayer.Character
                if not char then return end
                if not Workspace.GAME.CAN_ESCAPE.Value then return end
                if char.Parent ~= Workspace.PLAYERS.ALIVE then return end
                local map = Workspace.MAPS:FindFirstChild("GAME MAP")
                if not map then return end
                local escapes = map:FindFirstChild("Escapes")
                if not escapes then return end
                for _,part in pairs(escapes:GetChildren()) do
                    if part:IsA("BasePart") and part:GetAttribute("Enabled") and part:FindFirstChildOfClass("Highlight") and part:FindFirstChildOfClass("Highlight").Enabled then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            teleported = true
                            root.Anchored = true
                            char.PrimaryPart.CFrame = part.CFrame
                            task.delay(1.5,function() root.Anchored = false end)
                            task.delay(10,function() teleported = false end)
                        end
                    end
                end
            end)
        else
            if autoEscapeConn then autoEscapeConn:Disconnect() autoEscapeConn = nil end
            game:GetService("StarterGui"):SetCore("SendNotification",{Title = "Auto Escape", Text = "Disabled.", Duration = 5})
        end
    end
})

local dotEnabled = false
local dotConn
SurvivorTasksGroup:AddCheckbox("Auto Barricade", {
    Text = "Auto Barricade",
    Default = false,
    Callback = function(state)
        dotEnabled = state
        if state then
            dotConn = RunService.RenderStepped:Connect(function()
                local gui = LocalPlayer:WaitForChild("PlayerGui")
                local dot = gui:FindFirstChild("Dot")
                if dot and dot:IsA("ScreenGui") then
                    local container = dot:FindFirstChild("Container")
                    if container then
                        local frame = container:FindFirstChild("Frame")
                        if frame then
                            if not dot.Enabled then dot:Destroy() return end
                            frame.AnchorPoint = Vector2.new(0.5,0.5)
                            frame.Position = UDim2.new(0.5,0,0.5,0)
                        end
                    end
                end
            end)
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Auto Barricade", Text = "Enabled.", Duration = 2})
        else
            if dotConn then dotConn:Disconnect() dotConn = nil end
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Auto Barricade", Text = "Disabled.", Duration = 2})
        end
    end
})

local safeTeleport = false
local lastPosition = nil
SurvivorTasksGroup:AddCheckbox("Safety Area", {
    Text = "Safety Area (KICK)",
    Default = false,
    Callback = function(state)
        safeTeleport = state
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if state then
            lastPosition = root.CFrame
            root.CFrame = CFrame.new(0, 1003, 0)
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Safety Area", Text = "Enabled.", Duration = 2})
        else
            if lastPosition then
                root.CFrame = lastPosition
                lastPosition = nil
            end
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Safety Area", Text = "Disabled.", Duration = 2})
        end
    end
})

local viewKiller = false
local killerAddedConn, killerRemovedConn = nil, nil
SurvivorTasksGroup:AddCheckbox("View Killer", {
    Text = "View Killer",
    Default = false,
    Callback = function(state)
        viewKiller = state
        local camera = Workspace.CurrentCamera
        local killerFolder = Workspace.PLAYERS:FindFirstChild("KILLER")
        if state then
            local function setKillerCamera(killerChar)
                local hum = killerChar:FindFirstChildOfClass("Humanoid")
                if hum then camera.CameraSubject = hum end
            end
            if killerFolder then
                local killer = killerFolder:GetChildren()[1]
                if killer then setKillerCamera(killer) end
                killerAddedConn = killerFolder.ChildAdded:Connect(setKillerCamera)
                killerRemovedConn = killerFolder.ChildRemoved:Connect(function()
                    if viewKiller then
                        local char = LocalPlayer.Character
                        if char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then camera.CameraSubject = hum end
                        end
                    end
                end)
            end
            game:GetService("StarterGui"):SetCore("SendNotification",{Title = "View Killer", Text = "Enabled.", Duration = 2})
        else
            if killerAddedConn then killerAddedConn:Disconnect() end
            if killerRemovedConn then killerRemovedConn:Disconnect() end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then camera.CameraSubject = hum end
            end
            game:GetService("StarterGui"):SetCore("SendNotification",{Title = "View Killer", Text = "Disabled.", Duration = 2})
        end
    end
})

local antiDeath = {enabled = false, threshold = 30, conn = nil, lastPos = nil, teleported = false, debounce = false}
SurvivorTasksGroup:AddCheckbox("Anti Death", {
    Text = "Anti Death (KICK)",
    Default = false,
    Callback = function(state)
        antiDeath.enabled = state
        if state then
            antiDeath.conn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if not hum or not root then return end
                if hum.Health < antiDeath.threshold and hum.Health > 0 and not antiDeath.teleported and not antiDeath.debounce then
                    antiDeath.debounce = true
                    antiDeath.teleported = true
                    antiDeath.lastPos = root.CFrame
                    root.CFrame = pp.CFrame + Vector3.new(0,5,0)
                    task.delay(1, function() antiDeath.debounce = false end)
                elseif hum.Health >= antiDeath.threshold and antiDeath.teleported and antiDeath.lastPos and not antiDeath.debounce then
                    antiDeath.debounce = true
                    root.CFrame = antiDeath.lastPos
                    antiDeath.lastPos = nil
                    antiDeath.teleported = false
                    task.delay(1, function() antiDeath.debounce = false end)
                end
            end)
            game:GetService("StarterGui"):SetCore("SendNotification",{Title="Anti Death", Text="Enabled.", Duration=2})
        else
            if antiDeath.conn then antiDeath.conn:Disconnect() end
            antiDeath.lastPos = nil
            antiDeath.teleported = false
            antiDeath.debounce = false
            game:GetService("StarterGui"):SetCore("SendNotification",{Title="Anti Death", Text="Disabled.", Duration=2})
        end
    end
})

SurvivorTasksGroup:AddSlider("Health Threshold", {
    Text = "Health Threshold",
    Default = 30,
    Min = 25,
    Max = 80,
    Rounding = 0.5,
    Callback = function(v)
        antiDeath.threshold = v
    end
})

-- Visual Tab
local esp = {
    survivors = {}, 
    killers = {}, 
    generators = {},
    fuses = {},
    batteries = {}
}

local function newBox(obj, color)
    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    if not root then return end
    local g = Instance.new("BillboardGui")
    g.Name = "ESPBox"
    g.Size = UDim2.new(4,0,6,0)
    g.AlwaysOnTop = true
    g.Adornee = root
    g.Parent = root
    local t = Instance.new("Frame", g) t.Size = UDim2.new(1,0,0,2) t.BackgroundColor3 = color t.BorderSizePixel = 0
    local b = Instance.new("Frame", g) b.Size = UDim2.new(1,0,0,2) b.Position = UDim2.new(0,0,1,-2) b.BackgroundColor3 = color b.BorderSizePixel = 0
    local l = Instance.new("Frame", g) l.Size = UDim2.new(0,2,1,0) l.BackgroundColor3 = color l.BorderSizePixel = 0
    local r = Instance.new("Frame", g) r.Size = UDim2.new(0,2,1,0) r.Position = UDim2.new(1,-2,0,0) r.BackgroundColor3 = color r.BorderSizePixel = 0
    return g
end

local function addESP(tbl, obj, color)
    if tbl[obj] or not obj then return end
    tbl[obj] = newBox(obj, color)
end

local function clearESP(tbl)
    for obj, b in pairs(tbl) do 
        if b then b:Destroy() end 
        tbl[obj] = nil 
    end
end

local VisualESPGroup = Tabs.Visual:AddLeftGroupbox("Player & Object ESP", "eye")

VisualESPGroup:AddCheckbox("Survivor ESP", {
    Text = "Survivor ESP",
    Default = false,
    Callback = function(state)
        local alive = Workspace.PLAYERS.ALIVE
        if state then
            Library:Notify({Title = "Survivor ESP", Description = "Enabled.", Time = 2})
            for _, v in ipairs(alive:GetChildren()) do
                if v:IsA("Model") then addESP(esp.survivors, v, Color3.fromRGB(80,180,255)) end
            end
            esp.survivorConn = alive.ChildAdded:Connect(function(v)
                if v:IsA("Model") then addESP(esp.survivors, v, Color3.fromRGB(80,180,255)) end
            end)
        else
            Library:Notify({Title = "Survivor ESP", Description = "Disabled.", Time = 2})
            if esp.survivorConn then esp.survivorConn:Disconnect() end
            clearESP(esp.survivors)
        end
    end
})

VisualESPGroup:AddCheckbox("Killer ESP", {
    Text = "Killer ESP",
    Default = false,
    Callback = function(state)
        local killers = Workspace.PLAYERS.KILLER
        if state then
            Library:Notify({Title = "Killer ESP", Description = "Enabled.", Time = 2})
            for _, v in ipairs(killers:GetChildren()) do
                if v:IsA("Model") then addESP(esp.killers, v, Color3.fromRGB(255,80,80)) end
            end
            esp.killerConn = killers.ChildAdded:Connect(function(v)
                if v:IsA("Model") then addESP(esp.killers, v, Color3.fromRGB(255,80,80)) end
            end)
        else
            Library:Notify({Title = "Killer ESP", Description = "Disabled.", Time = 2})
            if esp.killerConn then esp.killerConn:Disconnect() end
            clearESP(esp.killers)
        end
    end
})

VisualESPGroup:AddCheckbox("Generator ESP", {
    Text = "Generator ESP",
    Default = false,
    Callback = function(state)
        if state then
            Library:Notify({Title = "Generator ESP", Description = "Enabled.", Time = 2})
            task.spawn(function()
                repeat task.wait() until Workspace:FindFirstChild("MAPS")
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and v.Name == "Generator" then
                        addESP(esp.generators, v, Color3.fromRGB(0,255,100))
                    end
                end
                esp.genConn = Workspace.DescendantAdded:Connect(function(v)
                    if v:IsA("Model") and v.Name == "Generator" then
                        addESP(esp.generators, v, Color3.fromRGB(0,255,100))
                    end
                end)
            end)
        else
            Library:Notify({Title = "Generator ESP", Description = "Disabled.", Time = 2})
            if esp.genConn then esp.genConn:Disconnect() end
            clearESP(esp.generators)
        end
    end
})

VisualESPGroup:AddCheckbox("Fuse ESP", {
    Text = "Fuse ESP",
    Default = false,
    Callback = function(state)
        if state then
            Library:Notify({Title = "Fuse ESP", Description = "Enabled.", Time = 2})
            local function checkAndAdd(v)
                local maps = Workspace:FindFirstChild("MAPS")
                local gameMap = maps and maps:FindFirstChild("GAME MAP")
                local fuseBoxes = gameMap and gameMap:FindFirstChild("FuseBoxes")
                if fuseBoxes and v:IsDescendantOf(fuseBoxes) then
                    if v:IsA("Model") or v:IsA("BasePart") then
                        addESP(esp.fuses, v, Color3.fromRGB(255, 20, 147))
                    end
                end
            end

            for _, v in ipairs(Workspace:GetDescendants()) do
                checkAndAdd(v)
            end

            local maps = Workspace:FindFirstChild("MAPS")
            local gameMap = maps and maps:FindFirstChild("GAME MAP")
            local fuseBoxes = gameMap and gameMap:FindFirstChild("FuseBoxes")
            if fuseBoxes then
                for _, v in ipairs(fuseBoxes:GetChildren()) do
                    addESP(esp.fuses, v, Color3.fromRGB(255, 20, 147))
                end
            end

            esp.fuseAdd = Workspace.DescendantAdded:Connect(function(v)
                checkAndAdd(v)
            end)
        else
            Library:Notify({Title = "Fuse ESP", Description = "Disabled.", Time = 2})
            if esp.fuseAdd then esp.fuseAdd:Disconnect() end
            clearESP(esp.fuses)
        end
    end
})

VisualESPGroup:AddCheckbox("Battery ESP", {
    Text = "Battery ESP",
    Default = false,
    Callback = function(state)
        if state then
            Library:Notify({Title = "Battery ESP", Description = "Enabled.", Time = 2})
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("MeshPart") and v.Name == "Battery" then 
                    addESP(esp.batteries, v, Color3.fromRGB(0, 255, 255)) 
                end
            end
            esp.batAdd = Workspace.DescendantAdded:Connect(function(v)
                if v:IsA("MeshPart") and v.Name == "Battery" then 
                    addESP(esp.batteries, v, Color3.fromRGB(0, 255, 255)) 
                end
            end)
            esp.batRemove = Workspace.DescendantRemoving:Connect(function(v)
                if esp.batteries[v] then 
                    clearESP({[v] = true}) 
                end
            end)
        else
            Library:Notify({Title = "Battery ESP", Description = "Disabled.", Time = 2})
            if esp.batAdd then esp.batAdd:Disconnect() end
            if esp.batRemove then esp.batRemove:Disconnect() end
            clearESP(esp.batteries)
        end
    end
})

-- Teleport Tab
local TeleportGroup = Tabs.Teleport:AddLeftGroupbox("Teleports", "map")

local generatorIndex = 1
local function getRoot() 
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char, char:WaitForChild("HumanoidRootPart")
end

local function getOrderedGenerators()
    local folder = Workspace.MAPS["GAME MAP"].Generators
    local models = {}
    for _, v in ipairs(folder:GetChildren()) do
        if v:IsA("Model") then table.insert(models, v) end
    end
    table.sort(models, function(a,b) return (a:GetAttribute("Order") or 0) < (b:GetAttribute("Order") or 0) end)
    return models
end

local function Teleport(model)
    if not model then return end
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    local _, root = getRoot()
    local front = part.CFrame.Position + part.CFrame.LookVector * 5
    root.CFrame = CFrame.new(front)
end

TeleportGroup:AddButton("Generator TP", {
    Text = "Generator TP (KICK)",
    Func = function()
        local models = getOrderedGenerators()
        if #models == 0 then return end
        local model = models[generatorIndex]
        Teleport(model)
        generatorIndex += 1
        if generatorIndex > #models then generatorIndex = 1 end
    end
})

local batteryIndex = 1
local function setupBatteries()
    local batteries = {}
    local ignore = Workspace:FindFirstChild("IGNORE")
    if not ignore then return batteries end
    for _, v in ipairs(ignore:GetDescendants()) do
        if v:IsA("MeshPart") and v.Name == "Battery" then table.insert(batteries, v) end
    end
    for i,v in ipairs(batteries) do v:SetAttribute("Order", i) end
    table.sort(batteries, function(a,b) return (a:GetAttribute("Order") or 0) < (b:GetAttribute("Order") or 0) end)
    return batteries
end

TeleportGroup:AddButton("Battery TP", {
    Text = "Battery TP (KICK)",
    Func = function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        local batteries = setupBatteries()
        if #batteries == 0 then return end
        local battery = batteries[batteryIndex]
        root.CFrame = battery.CFrame + Vector3.new(0,3,0)
        batteryIndex += 1
        if batteryIndex > #batteries then batteryIndex = 1 end
    end
})

-- Killer Tab
local KillerGroup = Tabs.Killer:AddLeftGroupbox("Kill Options", "sword")

local tpKill = false
local tpConn
local targetName = ""
local mode = "Closest"

local function getAliveNames()
    local t = {}
    for _, v in ipairs(Workspace.PLAYERS.ALIVE:GetChildren()) do table.insert(t, v.Name) end
    return t
end

KillerGroup:AddCheckbox("Teleport Kill", {
    Text = "Teleport Kill (KICK)",
    Default = false,
    Callback = function(state)
        tpKill = state
        if state then
            Library:Notify({Title = "Teleport Kill", Description = "Enabled.", Time = 2})
            tpConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                local targetChar
                if mode == "Closest" then
                    local closest, dist = nil, math.huge
                    for _, v in ipairs(Workspace.PLAYERS.ALIVE:GetChildren()) do
                        local hrp = v:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local d = (root.Position - hrp.Position).Magnitude
                            if d < dist then dist = d closest = v end
                        end
                    end
                    targetChar = closest
                elseif mode == "Specific" then
                    targetChar = Workspace.PLAYERS.ALIVE:FindFirstChild(targetName)
                end
                if targetChar then
                    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
                    if hrp then root.CFrame = hrp.CFrame * CFrame.new(0,0,3) end
                end
            end)
        else
            if tpConn then tpConn:Disconnect() end
            Library:Notify({Title = "Teleport Kill", Description = "Disabled.", Time = 2})
        end
    end
})

KillerGroup:AddInput("Target Username", {
    Text = "Enter Player Username",
    Placeholder = "Username",
    ClearTextOnFocus = false,
    Callback = function(v) targetName = v end
})

KillerGroup:AddDropdown("Target Mode", {
    Values = {"Closest", "Specific"},
    Default = 1,
    Multi = false,
    Text = "Target Mode",
    Callback = function(v) mode = v end
})

-- Others Tab
local OthersGroup = Tabs.Others:AddLeftGroupbox("Extras", "more-horizontal")
OthersGroup:AddButton("Infinite Yield", {
    Text = "Infinite Yield",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

local OwnerGroup = Tabs.Info:AddRightGroupbox("Credits", "info")
OwnerGroup:AddButton("Copy Owner Discord Username", {
    Text = "Copy Owner Discord Username",
    Func = function()
        setclipboard("thanhaski862lol")
        Library:Notify({Title = "Discord Username", Description = "Copied to clipboard!", Time = 3})
    end
})

OwnerGroup:AddButton("Copy Discord Server Invite", {
    Text = "Copy Discord Server Invite",
    Func = function()
        setclipboard("https://discord.gg/4y7es694AQ")
        Library:Notify({Title = "Discord Invite", Description = "Copied to clipboard!", Time = 3})
    end
})

-- UI Settings
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddCheckbox("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddCheckbox("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",
	Text = "Notification Side",
	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Text = "DPI Scale",
	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)
		Library:SetDPIScale(DPI)
	end,
})

MenuGroup:AddSlider("UICornerSlider", {
	Text = "Corner Radius",
	Default = Library.CornerRadius,
	Min = 0,
	Max = 20,
	Rounding = 0,
	Callback = function(value)
		Window:SetCornerRadius(value)
	end
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("specific-place")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

ThemeManager:ApplyTheme("Tokyo Night")
