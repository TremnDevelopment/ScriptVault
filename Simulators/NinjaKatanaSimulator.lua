-- // Load Kavo UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("💪 Ninja Katana Simulator", "Sentinel")

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Remotes
local remotes = {
    Setting = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Setting"),
    Rebirth = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Rebirth"),
    Pets = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pets")
}

-- // Create Main Tab and Section
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Main Section")


-- // Variables


-- // Functions
local function toggleAutoTrain(value)
    return remotes.Setting:FireServer("AutoTrain", value)
end

local function performRebirth()
    return remotes.Rebirth:FireServer()
end

local function fuseAllPets()
    return remotes.Pets:WaitForChild("FuseAllPets"):FireServer()
end

local function equipBestPets()
    return remotes.Pets:WaitForChild("EquipBest"):FireServer()
end

local function buyEgg()
    return remotes.Pets:WaitForChild("BuyEgg"):FireServer("", 1, {}, false)
end

-- // Create Toggles and Buttons
MainSection:NewToggle("Toggle AutoTrain", "Enable or disable auto training.", function(state)
    toggleAutoTrain(state)
end)

MainSection:NewButton("Perform Rebirth", "Click to perform a rebirth.", performRebirth)
MainSection:NewButton("Fuse All Pets", "Click to fuse all your pets.", fuseAllPets)
MainSection:NewButton("Equip Best Pets", "Click to equip your best pets.", equipBestPets)
MainSection:NewButton("Buy Egg", "Click to buy an egg.", buyEgg)

-- // Optional: Show a notification
Library:Notify("Script Loaded", "You can now use the functions in the UI!")
