pcall(function()
    local requestFunc = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request
    local DiscordInvite = "4y7es694AQ"
    HttpService = game:GetService("HttpService")
    if requestFunc then
            requestFunc({
                Url = 'http://127.0.0.1:6463/rpc?v=1',
                Method = 'POST',
                Headers = {
                    ['Content-Type'] = 'application/json',
                    Origin = 'https://discord.com'
                },
                Body = HttpService:JSONEncode({
                    cmd = 'INVITE_BROWSER',
                    nonce = HttpService:GenerateGUID(false),
                    args = {code = DiscordInvite}
                })
            })
    end
    end)

debugX = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Igcoognito | Blade Spin",
   Icon = 0,
   LoadingTitle = "Loading....",
   LoadingSubtitle = "by Skibidi50-lol",
   Theme = "Default",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = true,
      Invite = "https://discord.gg/4y7es694AQ",
      RememberJoins = true
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "We actually have no keysys",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local Tab = Window:CreateTab("Main", 4483362458)

local Section = Tab:CreateSection("Epic Buttons")

local Button = Tab:CreateButton({
   Name = "Auto XP/Coins",
   Callback = function()
       local args = {
           9999, -- once you get higher levels you can increase this number
       }
       while wait() do
        game:GetService("ReplicatedStorage"):WaitForChild("ReplicatedStorageHolders"):WaitForChild("Events"):WaitForChild("AddCoins"):FireServer(unpack(args))
        game:GetService("ReplicatedStorage"):WaitForChild("ReplicatedStorageHolders"):WaitForChild("Events"):WaitForChild("AddXP"):FireServer(unpack(args))
       end
   end,
})

Rayfield:LoadConfiguration()
