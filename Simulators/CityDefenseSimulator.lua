local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🏙️ City Defense Tycoon", "Sentinel")

local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Main Section")
local RaidTab = Window:NewTab("Raid")
local StartRaidSection = RaidTab:NewSection("Start Raids")
local SpawnMobSection = RaidTab:NewSection("Spawn Mobs")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local playerLists = {}
local mobLists = {}

_G.AutoEarn = false
_G.AutoBuy = false
_G.AutoRebirth = false
_G.SelectedRaidPlayer = nil
_G.SelectedMob = nil
_G.AutoSpawnMob = false

local unitNames = {
    "Archer", "Turret", "Ninja", "Soldier", "Sniper", "Bomber", "Wizard"
}

local function isUnitName(name)
    for _, unitName in ipairs(unitNames) do
        if string.find(name:lower(), unitName:lower()) then
            return true
        end
    end
    return false
end

MainSection:NewToggle("Auto Earn", "Automatically earns for you", function(state)
    _G.AutoEarn = state
    while _G.AutoEarn and task.wait(-9e9) do
        game:GetService("ReplicatedStorage").Knit.Services.TycoonService.RF.PayIncome:InvokeServer(player)
    end
end)

MainSection:NewToggle("Auto Rebirth", "Automatically rebirths for you", function(state)
    _G.AutoRebirth = state
    while _G.AutoRebirth and task.wait(-9e9) do
        game:GetService("ReplicatedStorage").Knit.Services.TycoonService.RF.Rebirth:InvokeServer()
    end
end)

MainSection:NewToggle("Auto Buy", "Automatically buys the buttons for you", function(state)
    _G.AutoBuy = state
    while _G.AutoBuy and task.wait(-9e9) do
        for _, tycoon in ipairs(workspace:WaitForChild("Tycoons"):GetChildren()) do
            if tycoon:IsA("Folder") and tycoon:GetAttribute("Owner") == player.Name then
                local buttonFolder = tycoon:FindFirstChild("Buttons")
                
                if buttonFolder then
                    for _, button in ipairs(buttonFolder:GetChildren()) do
                        if button:IsA("Model") and not string.find(button.Name:lower(), "gamepass") then
                            local purchaseType = isUnitName(button.Name) and 3 or 1
                            local tycoonService = game:GetService("ReplicatedStorage").Knit.Services.TycoonService
                            tycoonService.RF.BuyObject:InvokeServer(button.Name, purchaseType)
                        end
                    end
                end
            end
        end
    end
end)

MainSection:NewButton("Infinite Cash", "Gives infinite cash", function()
    local args = { [1] = math.huge }
    game:GetService("ReplicatedStorage").Knit.Services.RaidService.RF.GiveReward:InvokeServer(unpack(args))
end)

local PlayerDropdown = StartRaidSection:NewDropdown("Player", "Select a player", playerLists, function(currentOption)
    _G.SelectedRaidPlayer = currentOption
end)

StartRaidSection:NewButton("Start Raid", "Fires the remote to start a raid for the player", function()
    game:GetService("ReplicatedStorage").Knit.Services.RaidService.RF.StartRaid:InvokeServer(_G.SelectedRaidPlayer)    
end)

local MobDropdown = SpawnMobSection:NewDropdown("Mob", "Select a mob", mobLists, function(currentOption)
    _G.SelectedMob = currentOption
end)

SpawnMobSection:NewToggle("Auto Spawn", "Automatically spawns the mob for you", function(state)
    _G.AutoSpawnMob = state
    while _G.AutoSpawnMob and task.wait(-9e9) do
        game:GetService("ReplicatedStorage"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("RaidService"):WaitForChild("RF"):WaitForChild("SpawnMob"):InvokeServer(_G.SelectedMob or "Giant", 0)
    end
end)

for _, ePlayer in ipairs(game.Players:GetPlayers()) do
    if ePlayer.Name ~= player.Name then
        table.insert(playerLists, ePlayer.Name)
    end
end
PlayerDropdown:Refresh(playerLists)

for _, mob in ipairs(player.PlayerGui.RaidUI.MobsFrame:GetChildren()) do
    if mob:IsA("TextButton") then
        table.insert(mobLists, mob.Name)
    end
end
MobDropdown:Refresh(mobLists)

character.Humanoid.WalkSpeed = 60
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    character.Humanoid.WalkSpeed = 60
end)

while wait(1) do
    for _, ePlayer in ipairs(game.Players:GetPlayers()) do
        if ePlayer.Name ~= player.Name and not table.find(playerLists, ePlayer.Name) then
            table.insert(playerLists, ePlayer.Name)
        end
    end
    PlayerDropdown:Refresh(playerLists)
end