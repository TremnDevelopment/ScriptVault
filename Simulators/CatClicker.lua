local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Cat Clicker 🐾", "Sentinel")

local Main = Window:NewTab("Main")
local ExploitSection = Main:NewSection("Exploit Section")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

_G.AutoFish = false
_G.AutoClick = false
_G.AutoRebirth = false
_G.AutoUpgrade = false
_G.AutoFishUpgrade = false

ExploitSection:NewToggle("Increase Fish", "Gives you tons of fishes", function(state)
    _G.AutoFish = state
    while _G.AutoFish and task.wait() do
        ReplicatedStorage:WaitForChild("Fish"):FireServer(999999999999999999)
    end
end)

ExploitSection:NewToggle("Auto Click", "Clicks the cat for you", function(state)
    _G.AutoClick = state
    while _G.AutoClick and task.wait() do
        for i = 1, 5 do
            ReplicatedStorage:WaitForChild("Click"):FindFirstChild("Click"):FireServer()
            task.wait(-9e9)
        end
    end
end)

ExploitSection:NewToggle("Auto Rebirth", "Rebirths for you", function(state)
    _G.AutoRebirth = state
    while _G.AutoRebirth and task.wait() do
        if player:WaitForChild("PriceData"):WaitForChild('Price').Value <= 5000000000000000000 * player:WaitForChild("CatData"):WaitForChild("CatLevel").Value + player:WaitForChild("leaderstats"):WaitForChild("Cat").Value then
            ReplicatedStorage:WaitForChild("Rebirth"):FireServer()
        end
    end
end)

ExploitSection:NewToggle("Auto Upgrade", "Upgrades for you", function(state)
    _G.AutoUpgrade = state
    while _G.AutoUpgrade and task.wait() do
        ReplicatedStorage:WaitForChild("MultiShop")['x100']:FireServer()
        for i = 1, 5 do
            for _, event in ipairs(ReplicatedStorage.Shop:GetChildren()) do
                event:FireServer()
                task.wait(-9e9)
            end
        end
    end
end)

ExploitSection:NewToggle("Auto Fish Upgrade", "Upgrades the fish upgrades for you", function(state)
    _G.AutoFishUpgrade = state
    while _G.AutoFishUpgrade and task.wait() do
        local MoreClicks = ReplicatedStorage:WaitForChild("FishUpgrades"):FindFirstChild("s1")
        local MoreCats = ReplicatedStorage:WaitForChild("FishUpgrades"):FindFirstChild("s2")
        for i = 1, 5 do
            MoreClicks:FireServer()
            MoreCats:FireServer()
            task.wait(-9e9)
        end
    end
end)