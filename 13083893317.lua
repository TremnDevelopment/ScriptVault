-- <> Game Services <> --
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- <> Player Variables <> --
local Player = Players.LocalPlayer
local character = Player.Character or Player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild('Humanoid')

-- <> Script Variables <> --
_G.AutoCollectItems = false
_G.AutoDumbBell = false
_G.DroppedItemSniper = false

local SettingVariables = {
    ItemFarmSettings = {
        AutoPickup = false,
        TeleportBack = false
    },
    AutoDumbellSettings = {
        AutoBuy = false,
        AutoEquip = false
    },
    DroppedItemSniperSettings = {
        AutoPickup = false,
        CashPickupOnly = false
    }
}

-- <> Parts Creation <> --
--[[local ExploitationFolder = Workspace:FindFirstChild("ExploitationFolder") or Instance.new("Folder")
ExploitationFolder.Name = "ExploitationFolder"
ExploitationFolder.Parent = Workspace

local SafeZonePart = Instance.new("Part")
SafeZonePart.Name = "SafeZonePart"
SafeZonePart.Anchored = true
SafeZonePart.CanCollide = false
SafeZonePart.Size = Vector3.new(5, 5, 5)
SafeZonePart.Transparency = 0.75
SafeZonePart.Color = Color3.new(0, 255, 0)
SafeZonePart.CFrame = CFrame.new(987.774292, 4.96115303, 124.865982, -0.729111016, -7.28868201e-08, 0.684395432, -1.15341052e-07, 1, -1.63788521e-08, -0.684395432, -9.08808886e-08, -0.729111016)
SafeZonePart.Parent = ExploitationFolder]]

-- <> Loadstrings <> --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- <> Windows <> --
local MainWindow = Library.CreateLib("Script Vault", "Sentinel")

-- <> Tabs <> --
local MainTab = MainWindow:NewTab("Main")
local SettingTab = MainWindow:NewTab("Settings")

-- <> Sections <> --
local MainSection = MainTab:NewSection("Main")
local ItemFarmSettings = SettingTab:NewSection("Item Farm Settings")
local AutoDumbellSettings = SettingTab:NewSection("Auto Dumbell Settings")
local DroppedItemSniperSettings = SettingTab:NewSection("Dropped Item Sniper Settings")

-- <> Functions <> --
local function equipTool(Tool)
    if Tool and Tool.Parent == Player.Backpack then
        humanoid:EquipTool(Tool)
        return true
    end
    return false
end

local function activateTool(Tool)
    if Tool then
        Tool:Activate()
    end
end

-- <> Toggles <> --
MainSection:NewToggle("Item Farm", "Collects all the items for you", function(state)
    _G.AutoCollectItems = state
    local OPosition = humanoidRootPart.Position -- Capture initial position outside the loop

    while _G.AutoCollectItems do
        print('Starting item collection...')
        for _, model in ipairs(Workspace:WaitForChild('SpawnsLoot'):GetChildren()) do
            if model:IsA('Model') and model.Name == "SpawnForLoot" then
                for _, part in ipairs(model:GetChildren()) do
                    if part:IsA("BasePart") and part.Transparency == 0 then
                        local PartPosition = part.Position + Vector3.new(0, 5, 0)
                        humanoidRootPart.CFrame = CFrame.new(PartPosition)

                        if fireproximityprompt and part.Parent.Part.Attachment:FindFirstChild("ProximityPrompt") then
                            repeat 
                                task.wait(0.1) 
                                if SettingVariables.ItemFarmSettings.AutoPickup then
                                    fireproximityprompt(part.Parent.Part.Attachment.ProximityPrompt, 1)
                                end
                            until part.Transparency == 1
                            print('Collected item')
                        end
                    end
                    task.wait(0)
                end
            end
            task.wait(0)
        end

        -- Teleport back if the setting is enabled
        if SettingVariables.ItemFarmSettings.TeleportBack then
            humanoidRootPart.CFrame = CFrame.new(OPosition) + Vector3.new(0, 5, 0)
            print('Teleported back to original position')
        end
        task.wait(30) -- Prevents you from being flagged by the anticheat (lol)
    end
end)

ItemFarmSettings:NewToggle("Auto Pickup", "Whether to pick up the item during the item farm", function(state)
    SettingVariables.ItemFarmSettings.AutoPickup = state
end)

ItemFarmSettings:NewToggle("Teleport Back", "Automatically teleport back after the item farm is done", function(state)
    SettingVariables.ItemFarmSettings.TeleportBack = state
end)

MainSection:NewToggle("Auto Dumbell", "Lifts the dumbbell automatically for you", function(state)
    _G.AutoDumbBell = state

    while _G.AutoDumbBell do
        if not Player.Character:FindFirstChild('Dumbell') and not Player.Backpack:FindFirstChild('Dumbell') and SettingVariables.AutoDumbellSettings.AutoBuy == true  then
            humanoidRootPart.CFrame = CFrame.new(1101.55347, 5.06757355, 78.8200531)
            if fireproximityprompt then
                for i = 1, 5 do
                    fireproximityprompt(Workspace.Buttons.DumbellButton.Button.ProximityPrompt, 1)
                end
            end
        else
            if Player.Backpack:FindFirstChild('Dumbell') and SettingVariables.AutoDumbellSettings.AutoEquip == true then
                equipTool(Player.Backpack:FindFirstChild('Dumbell'))
            elseif Player.Character:FindFirstChild('Dumbell') then
                activateTool(Player.Character:FindFirstChild('Dumbell'))
            end
        end

        task.wait(0)
    end
end)

AutoDumbellSettings:NewToggle("Auto Equip", "Whether to equip the dumbbell for you during the auto", function(state)
    SettingVariables.AutoDumbellSettings.AutoEquip = state
end)

AutoDumbellSettings:NewToggle("Auto Buy", "Whether to buy the dumbbell automatically for you during the auto", function(state)
    SettingVariables.AutoDumbellSettings.AutoBuy = state
end)

MainSection:NewToggle("Drop Items Sniper", "Finds dropped items and picks them up", function(state)
    _G.DroppedItemSniper = state

    while _G.DroppedItemSniper do
        local OPosition

        for _, drop in ipairs(Workspace:WaitForChild('DroppedItems'):GetChildren()) do
            local isCashPickupOnly = SettingVariables.DroppedItemSniperSettings.CashPickupOnly

            if (not isCashPickupOnly and (drop:IsA("BasePart") or (drop:IsA('Model') and drop:FindFirstChild("MainPart")))) or 
               (isCashPickupOnly and drop:IsA("BasePart") and drop.Name == "DroppedCash") then

                OPosition = humanoidRootPart.Position
                local PartPosition = drop:IsA("BasePart") and drop.Position or drop.MainPart.Position
                humanoidRootPart.CFrame = CFrame.new(PartPosition) + Vector3.new(0, 5, 0)

                local ProximityPrompt = drop:FindFirstChild("ProximityPrompt")
                if fireproximityprompt and ProximityPrompt then
                    repeat 
                        task.wait() 
                        if SettingVariables.DroppedItemSniperSettings.AutoPickup then 
                            fireproximityprompt(ProximityPrompt, 1)
                        end 
                        print('picking up')
                    until not drop.Parent
                    print('Picked up item')
                end
            end
            task.wait(0)
        end

        if OPosition then
            humanoidRootPart.CFrame = CFrame.new(OPosition) + Vector3.new(0, 5, 0) 
        end
        task.wait(0.1)
    end
end)

DroppedItemSniperSettings:NewToggle("Auto Pickup", "Whether to automatically pickup the item", function(state)
    SettingVariables.DroppedItemSniperSettings.AutoPickup = state
end)

DroppedItemSniperSettings:NewToggle("Only Cash Drop", "Whether to only snipe dropped cash", function(state)
    SettingVariables.DroppedItemSniperSettings.CashPickupOnly = state
end)
