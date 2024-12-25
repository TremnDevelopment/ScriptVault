local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Services = {
    PlayerService = game:GetService("Players"),
    RunService = game:GetService("RunService")
}

getgenv().Variables = {
    KillauraVariables = {
        BlacklistedEntities = {"Transport_Left"},
        KillauraEnabled = true,
        BowauraEnabled = true,
        KillauraRange = 20,
        KillauraType = "Regular",
        TeamCheck = false
    },  
    SpeedVariables = {
        SpeedEnabled = true,
        Speed = 18
    },
    ScaffoldVariables = {
        ScaffoldEnabled = false,
        ScaffoldKeybind = "V",
        ScaffoldExtend = 2
    },
    NukerVariables = {
        NukerEnabled = true,
        NukerRange = 40
    }
}

local function IsPlayerAlive(player)
    local entity = Services.PlayerService:WaitForChild(player.Name)
    if entity then
        return entity.Character and entity.Character:FindFirstChild("Humanoid") and entity.Character.Humanoid.Health > 0
    end
end

local function GetNearestEntity(maxDistance, teamCheck)
    local nearestEntity, nearestDistance = nil, maxDistance or math.huge
    local localPlayer = Services.PlayerService.LocalPlayer

    for _, entity in pairs(workspace:GetChildren()) do
        local player = Services.PlayerService:FindFirstChild(entity.Name)
        if entity:IsA("Model") and player and (player ~= localPlayer and not table.find(getgenv().Variables.KillauraVariables.BlacklistedEntities, player.Name)) and (not teamCheck or player.Team ~= localPlayer.Team) and IsPlayerAlive(player) then
            local humanoidRootPart = entity:FindFirstChild("HumanoidRootPart")
            local playerHRP = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart and playerHRP then
                local distance = (humanoidRootPart.Position - playerHRP.Position).Magnitude
                if distance <= nearestDistance then
                    nearestDistance = distance
                    nearestEntity = entity
                end
            end
        end
    end
    return nearestEntity
end

local function GetAllNearestEntities(maxDistance, teamCheck)
    local entitiesTable = {}
    local nearestDistance = maxDistance or math.huge
    local localPlayer = Services.PlayerService.LocalPlayer

    for _, entity in pairs(workspace:GetChildren()) do
        local player = Services.PlayerService:FindFirstChild(entity.Name)
        if entity:IsA("Model") and player and (player ~= localPlayer and not table.find(getgenv().Variables.KillauraVariables.BlacklistedEntities, player.Name)) and (not teamCheck or player.Team ~= localPlayer.Team) and IsPlayerAlive(player) then
            local humanoidRootPart = entity:FindFirstChild("HumanoidRootPart")
            local playerHRP = localPlayer.Character:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart and playerHRP then
                local distance = (humanoidRootPart.Position - playerHRP.Position).Magnitude
                if distance <= nearestDistance then
                    table.insert(entitiesTable, {entity, distance})
                end
            end
        end
    end

    return entitiesTable
end

local function GetEquippedTool(player, toolName)
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:match(toolName) then
                return tool
            end
        end
    end
end

local function GetToolFromBackpack(player, toolName)
    if player.Backpack then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:match(toolName) then
                return tool
            end
        end
    end
end

local function ConvertPositionToVector(pos)
    local NewPos = Vector3.new(math.floor((pos.X / 3) + 0.5) * 3, math.floor((pos.Y / 3) + 0.5) * 3, math.floor((pos.Z / 3) + 0.5) * 3)
    return NewPos
end

local function Initialize()
    local FluentOptions = Fluent.Options

    local Window = Fluent:CreateWindow({
        Title = "Keyware | Bridge Duel Remake",
        SubTitle = "Whatever I made",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Theme = "Amethyst",
        MinimizeKey = Enum.KeyCode.LeftControl
    })
    
    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "list" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }
    
    Tabs.Main:AddSection("Combat Features")

    local KillauraTarget, KillauraLoop = nil, nil
    Tabs.Main:AddToggle("killaura", { Title = "Killaura", Default = getgenv().Variables.KillauraVariables.KillauraEnabled }):OnChanged(function()
        getgenv().Variables.KillauraVariables.KillauraEnabled = FluentOptions.killaura.Value
        if getgenv().Variables.KillauraVariables.KillauraEnabled then
            Services.PlayerService.LocalPlayer.PlayerGui.Notifications.Notifications.Visible = n
            KillauraLoop = Services.RunService.Heartbeat:Connect(function()
                if not getgenv().Variables.KillauraVariables.KillauraEnabled then return end

                local Player = Services.PlayerService.LocalPlayer
                if Player and IsPlayerAlive(Player) then
                    local ToolService = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService")
                    if ToolService then
                        local Sword = GetEquippedTool(Player, "Sword")
                        if Sword then
                            KillauraTarget = getgenv().Variables.KillauraVariables.KillauraType == "Regular"
                                and GetNearestEntity(tonumber(getgenv().Variables.KillauraVariables.KillauraRange), getgenv().Variables.KillauraVariables.TeamCheck)
                                or GetAllNearestEntities(tonumber(getgenv().Variables.KillauraVariables.KillauraRange), getgenv().Variables.KillauraVariables.TeamCheck)
                
                            if type(KillauraTarget) == "userdata" and KillauraTarget:IsA("Model") then
                                ToolService:WaitForChild("RF"):WaitForChild("AttackPlayerWithSword"):InvokeServer(KillauraTarget, true, Sword.Name)
                                ToolService:WaitForChild("RF"):WaitForChild("ToggleBlockSword"):InvokeServer(true, Sword.Name)
                
                                if getgenv().Variables.KillauraVariables.BowauraEnabled then
                                    local PlayerGui = Player:FindFirstChild("PlayerGui")
                                    if PlayerGui and PlayerGui.Hotbar.MainFrame.Background.Bar.ArrowProgress.Progress.Size == UDim2.new(0, 0, 1, 0) then
                                        local InvBow = GetToolFromBackpack(Player, "Bow")
                                        if InvBow then
                                            Player.Character.Humanoid:EquipTool(InvBow)
                                            local Bow = GetEquippedTool(Player, "Bow")
                                            if Bow then
                                                if type(KillauraTarget) == "userdata" and KillauraTarget:IsA("Model") then
                                                    local Target = Services.PlayerService:WaitForChild(KillauraTarget.Name)
                                                    if Target then
                                                        Bow:WaitForChild("__comm__"):WaitForChild("RF"):FindFirstChild("Fire"):InvokeServer(Target.Character.HumanoidRootPart.Position, 9e9)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            elseif type(KillauraTarget) == "table" and next(KillauraTarget) ~= nil then
                                local PlayerGui = Player:FindFirstChild("PlayerGui")
                                local BowauraEnabled = getgenv().Variables.KillauraVariables.BowauraEnabled
                                local targetsProcessed = {}
                                local bowEquipped = false
                                
                                for _, entData in pairs(KillauraTarget) do
                                    local entity = entData[1]
                                    if entity and not targetsProcessed[entity] then
                                        ToolService:WaitForChild("RF"):WaitForChild("AttackPlayerWithSword"):InvokeServer(entity, true, Sword.Name)
                                        ToolService:WaitForChild("RF"):WaitForChild("ToggleBlockSword"):InvokeServer(true, Sword.Name)
                                        targetsProcessed[entity] = true
                                
                                        if BowauraEnabled and PlayerGui and PlayerGui.Hotbar.MainFrame.Background.Bar.ArrowProgress.Progress.Size == UDim2.new(0, 0, 1, 0) then
                                            if not bowEquipped then
                                                local InvBow = GetToolFromBackpack(Player, "Bow")
                                                if InvBow then
                                                    Player.Character.Humanoid:EquipTool(InvBow)
                                                    bowEquipped = true
                                                end
                                            end
                                
                                            local Bow = GetEquippedTool(Player, "Bow")
                                            if Bow then
                                                if type(entity) == "userdata" and entity:IsA("Model") then
                                                    local Target = Services.PlayerService:WaitForChild(entity.Name)
                                                    if Target and IsPlayerAlive(Target) then
                                                        Bow:WaitForChild("__comm__"):WaitForChild("RF"):FindFirstChild("Fire"):InvokeServer(Target.Character.HumanoidRootPart.Position, 9e9)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    task.wait()
                                end                                
                            end
                        else
                            local InvSword = GetToolFromBackpack(Player, "Sword")
                            if InvSword then
                                Player.Character.Humanoid:EquipTool(InvSword)
                                ToolService:WaitForChild("RF"):WaitForChild("ToggleBlockSword"):InvokeServer(true, InvSword.Name)
                            end
                        end
                    end
                end
                task.wait()                
            end)
        else
            Services.PlayerService.LocalPlayer.PlayerGui.Notifications.Notifications.Visible = true
            KillauraTarget = nil
            if KillauraLoop ~= nil then
                print('yes')
                KillauraLoop:Disconnect()
                KillauraLoop = nil
            end
        end
    end)

    Tabs.Main:AddToggle("teamCheck", { Title = "Team Check", Default = getgenv().Variables.KillauraVariables.TeamCheck }):OnChanged(function()
        getgenv().Variables.KillauraVariables.TeamCheck = FluentOptions.teamCheck.Value
    end)

    Tabs.Main:AddToggle("bowaura", { Title = "Bow Aura", Default = getgenv().Variables.KillauraVariables.BowauraEnabled }):OnChanged(function()
        getgenv().Variables.KillauraVariables.BowauraEnabled = FluentOptions.bowaura.Value
    end)

    Tabs.Main:AddDropdown("killauraType", { Title = "Killaura Type", Values = {"Regular", "Switch"}, Multi = false, Default = 1 }):OnChanged(function()
        getgenv().Variables.KillauraVariables.KillauraType = FluentOptions.killauraType.Value
    end)

    Tabs.Main:AddSlider("killauraRange", {
        Title = "Killaura Range",
        Description = "Changes the kill aura range",
        Default = getgenv().Variables.KillauraVariables.KillauraRange,
        Min = 20,
        Max = 40,
        Rounding = 2,
        Callback = function(Value)
            getgenv().Variables.KillauraVariables.KillauraRange = Value
        end
    })

    local NukerLoop = nil
    Tabs.Main:AddToggle("nuker", { Title = "Block Nuker (WIP)", Default = getgenv().Variables.NukerVariables.NukerEnabled }):OnChanged(function()
        getgenv().Variables.NukerVariables.NukerEnabled = FluentOptions.nuker.Value
        if getgenv().Variables.NukerVariables.NukerEnabled then
            NukerLoop = Services.RunService.Heartbeat:Connect(function()
                if IsPlayerAlive(Services.PlayerService.LocalPlayer) then
                    for _, block in pairs(game:GetService("CollectionService"):GetTagged("Block")) do
                        if block:IsA("Part") and (block.Position - Services.PlayerService.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= tonumber(getgenv().Variables.NukerVariables.NukerRange) then
                            local PositionToVector = ConvertPositionToVector(block.Position)
                            if PositionToVector then 
                                print('attempting to destroy block at', PositionToVector)   
                                game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("BreakBlock"):InvokeServer(PositionToVector)
                                print('destroyed block at', PositionToVector)
                            end
                        end
                        wait(.1)
                    end
                end
            end)
        else
            if NukerLoop ~= nil then
                NukerLoop:Disconnect()
                NukerLoop = nil
            end
        end
    end)

    Tabs.Main:AddSlider("nukerRange", {
        Title = "Nuker Range",
        Description = "Changes the nuker range",
        Default = getgenv().Variables.NukerVariables.NukerRange,
        Min = 20,
        Max = 80,
        Rounding = 2,
        Callback = function(Value)
            getgenv().Variables.NukerVariables.NukerRange = Value
        end
    })

    Tabs.Main:AddSection("Movement Features")

    local ApplyVelocityLoop = nil
    Tabs.Main:AddToggle("applyvelocity", { Title = "Speed", Default = getgenv().Variables.SpeedVariables.SpeedEnabled }):OnChanged(function()
        if FluentOptions.applyvelocity.Value then
            ApplyVelocityLoop = Services.RunService.Heartbeat:Connect(function()
                local localPlayer = Services.PlayerService.LocalPlayer
                if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and IsPlayerAlive(localPlayer) then
                    local humanoidRootPart = localPlayer.Character.HumanoidRootPart
                    
                    local velocity = localPlayer.Character.Humanoid.MoveDirection * getgenv().Variables.SpeedVariables.Speed
                    if velocity then
                        humanoidRootPart.Velocity = Vector3.new(velocity.X, humanoidRootPart.Velocity.Y, velocity.Z)
                    end
                end
            end)
        else
            if ApplyVelocityLoop ~= nil then
                ApplyVelocityLoop:Disconnect()
                ApplyVelocityLoop = nil
            end
        end
    end)    

    Tabs.Main:AddSlider("walkspeed", {
        Title = "Speed",
        Description = "Changes the player's speed",
        Default = 30,
        Min = 16,
        Max = 32,
        Rounding = 1,
        Callback = function(Value)
            getgenv().Variables.SpeedVariables.Speed = Value
        end
    })

    local NoslowFunction = nil
    Tabs.Main:AddToggle("noslow", { Title = "No Slow Down", Default = true }):OnChanged(function()
        if FluentOptions.noslow.Value then
            NoslowFunction = Services.PlayerService.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if IsPlayerAlive(Services.PlayerService.LocalPlayer) and Services.PlayerService.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed ~= 16 then
                    Services.PlayerService.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
                end
            end)
        else
            if NoslowFunction ~= nil then
                NoslowFunction:Disconnect()
                NoslowFunction = nil
            end
        end
    end)

    local ScaffoldLoop = nil
    Tabs.Main:AddKeybind("scaffold", {
        Title = "Scaffold",
        Mode = "Toggle", -- Always, Toggle, Hold
        Default = getgenv().Variables.ScaffoldVariables.ScaffoldKeybind,

        Callback = function(Value)
            getgenv().Variables.ScaffoldVariables.ScaffoldEnabled = Value
            if getgenv().Variables.ScaffoldVariables.ScaffoldEnabled then
                ScaffoldLoop = Services.RunService.Heartbeat:Connect(function()
                    local localPlayer = Services.PlayerService.LocalPlayer
                    local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoidRootPart and humanoid then
                        for i = 1, getgenv().Variables.ScaffoldVariables.ScaffoldExtend do
                            local PlacePos = ConvertPositionToVector(humanoidRootPart.Position + humanoid.MoveDirection * (i * 3.5) - Vector3.new(0, (humanoidRootPart.Size.Y / 2) + humanoid.HipHeight + 1.5, 0))
                            if PlacePos then
                                game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("PlaceBlock"):InvokeServer(PlacePos)
                            end
                            task.wait()
                        end
                    end
                end)
            else
                if ScaffoldLoop ~= nil then
                    ScaffoldLoop:Disconnect()
                    ScaffoldLoop = nil
                end
            end
        end,
    
        ChangedCallback = function(New)
            print("Keybind changed!", New)
        end
    })

    Tabs.Main:AddSlider("scafExtend", {
        Title = "Scaffold Extend",
        Description = "The amount to extend when scaffolding",
        Default = getgenv().Variables.ScaffoldVariables.ScaffoldExtend,
        Min = 2,
        Max = 10,
        Rounding = 1,
        Callback = function(Value)
            getgenv().Variables.ScaffoldVariables.ScaffoldExtend = Value
        end
    })

    InterfaceManager:SetLibrary(Fluent)
    SaveManager:SetLibrary(Fluent)
    SaveManager:SetFolder("FluentScriptHub/bridgeduel")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    Window:SelectTab(1)
    Fluent:Notify({ Title = "Keyware", Content = "The script has been loaded.", Duration = 8 })
    SaveManager:LoadAutoloadConfig()
end

Initialize()
