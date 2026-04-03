local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()
 
local Window = Library:CreateWindow{
    Title = "Toasty Auto Player | Funky Friday",
    SubTitle = "by Skibidi50-lol",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 430),
    Resize = true, -- Resize this ^ Size according to a 1920x1080 screen, good for mobile users but may look weird on some devices
    MinSize = Vector2.new(470, 380),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl -- Used when theres no MinimizeKeybind
}

local Tabs = {
    Main = Window:CreateTab{
        Title = "Main",
        Icon = "phosphor-users-bold"
    },
    Settings = Window:CreateTab{
        Title = "Settings",
        Icon = "settings"
    }
}

local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local keys = {Lane1 = "A", Lane2 = "S", Lane3 = "W", Lane4 = "D"}
local connections = {}
local holding = {}
local currentSide = "Right"

local accuracyPercent = 100

local BASE_WINDOW = 25

local function getMissChance()
    return (100 - accuracyPercent) * 0.6 / 100
end

local function getOffsetPixels()
    local maxOffset = 100
    local factor = (100 - accuracyPercent) / 100
    return math.random(-maxOffset * factor, maxOffset * factor)
end

local function getCenterY(frame)
    return frame.AbsolutePosition.Y + (frame.AbsoluteSize.Y / 2)
end

local function getLanes()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return end
    local win = pg:FindFirstChild("Window")
    if not win then return end
    local gameField = win:FindFirstChild("Game")
    if not gameField then return end
    local fields = gameField:FindFirstChild("Fields")
    if not fields then return end
    local side = fields:FindFirstChild(currentSide)
    if not side then return end
    return side:FindFirstChild("Inner")
end

local function stopAutoPlay()
    for note in pairs(holding) do
        local laneNum = string.match(note.Parent.Parent.Name, "Lane(%d+)")
        if laneNum then
            VIM:SendKeyEvent(false, keys["Lane"..laneNum], false, game)
        end
    end

    table.clear(holding)

    for i = 1, 4 do
        if connections[i] then
            connections[i]:Disconnect()
            connections[i] = nil
        end
    end
end

local function startAutoPlay()
    stopAutoPlay()
    local lanes = getLanes()
    if not lanes then return end

    for i = 1, 4 do
        local lane = lanes:FindFirstChild("Lane"..i)
        if not lane then continue end

        local notes = lane:FindFirstChild("Notes")
        local splash = lane:FindFirstChild("Splash")
        if not notes or not splash then continue end

        local splashCenterY = getCenterY(splash)
        local key = keys["Lane"..i]

        connections[i] = RunService.RenderStepped:Connect(function()
            local closestNote = nil
            local closestDist = math.huge

            for _, note in ipairs(notes:GetChildren()) do
                if note:IsA("Frame") and not holding[note] then
                    local dist = math.abs(getCenterY(note) - splashCenterY)
                    if dist < closestDist then
                        closestDist = dist
                        closestNote = note
                    end
                end
            end

            if closestNote and closestDist <= BASE_WINDOW then
                if math.random() < getMissChance() then
                    holding[closestNote] = "ignored"
                    return
                end

                holding[closestNote] = "holding"

                local delayMs = 0
                if accuracyPercent < 100 then
                    delayMs = math.random(0, (100 - accuracyPercent) * 0.8)
                end

                task.delay(delayMs / 1000, function()
                    local offsetY = getOffsetPixels()
                    local adjustedCenter = getCenterY(closestNote) + offsetY

                    if math.abs(adjustedCenter - splashCenterY) <= BASE_WINDOW * 1.5 then
                        VIM:SendKeyEvent(true, key, false, game)
                    end
                end)

                task.spawn(function()
                    while closestNote.Parent and holding[closestNote] == "holding" do
                        local bottomY = closestNote.AbsolutePosition.Y + closestNote.AbsoluteSize.Y
                        if bottomY < splashCenterY then
                            break
                        end
                        RunService.RenderStepped:Wait()
                    end

                    VIM:SendKeyEvent(false, key, false, game)
                    holding[closestNote] = nil
                end)
            end
        end)
    end
end


local Options = Library.Options

local AutoPlayToggle = Tabs.Main:CreateToggle("AutoPlayToggle", {Title = "Auto Play", Default = false })

AutoPlayToggle:OnChanged(function()
    if Value then startAutoPlay() else stopAutoPlay() end
end)

Tabs.Main:CreateSlider("AccuracySlider", {
    Title = "Accuracy",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        accuracyPercent = Value
    end
})

local SideDropdown = Tabs.Main:CreateDropdown("SideDropdown", {
    Title = "Dropdown",
    Values = {"Right", "Left"},
    Multi = false,
    Default = 1,
})

SideDropdown:OnChanged(function(Value)
    currentSide = Value
end)
