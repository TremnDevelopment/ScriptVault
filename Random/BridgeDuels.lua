local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

getgenv().Variables = {
    KillauraVariables = {
        BlacklistedEntities = {"Transport_Rice"},
        KillauraEnabled = true,
        BowauraEnabled = true,
        KillauraRange = 20,
        TeamCheck = false
    },
    SpeedVariables = {
        NoslowEnabled = true,
        SpeedEnabled = true,
        Speed = 18
    },
    ScaffoldVariables = {
        ScaffoldEnabled = false,
        ScaffoldKeybind = "V",
        ScaffoldExtend = 2
    },
    NukerVariables = {
        NukerEnabled = false,
        NukerRange = 40
    }
}

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local function IsPlayerAlive(player)
    local entityPlayer = Players:WaitForChild(player.Name)
    if entityPlayer then
        return entityPlayer.Character and entityPlayer.Character:FindFirstChildOfClass("Humanoid") and entityPlayer.Character.Humanoid.Health > 0
    end
end

local function GetNearestEntity(maxDistance, teamCheck)
    local nearestEntity, nearestDistance = nil, maxDistance or math.huge

    for _, entity in pairs(workspace:GetChildren()) do
        local playerEntity = Players:FindFirstChild(entity.Name)

        if entity:IsA("Model") and playerEntity and playerEntity ~= Player and (not teamCheck or playerEntity.Team ~= Player.Team) and IsPlayerAlive(playerEntity) then
            local entityRootPart = playerEntity.Character:WaitForChild("HumanoidRootPart")
            local playerRootPart = Player.Character:WaitForChild("HumanoidRootPart")

            if entityRootPart and playerRootPart then
                local Distance = (entityRootPart.Position - playerRootPart.Position).Magnitude

                if Distance <= nearestDistance then
                    nearestEntity = entity
                    nearestDistance = Distance
                end
            end
        end
    end
    return nearestEntity, nearestDistance
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

local function ConvertPositionToVector(Position)
    local ConvertedPosition = Vector3.new(math.floor((Position.X / 3) + 0.5) * 3, math.floor((Position.Y / 3) + 0.5) * 3, math.floor((Position.Z / 3) + 0.5) * 3)
    return ConvertedPosition
end

local function SetEquippedTool(Tool)
    Player.Character.Humanoid:EquipTool(Tool)
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
    Tabs.Main:AddToggle("Killaura", { Title = "Killaura", Default = true }):OnChanged(function()
        getgenv().Variables["KillauraVariables"].KillauraEnabled = FluentOptions.Killaura.Value
        
        if getgenv().Variables["KillauraVariables"].KillauraEnabled then
            PlayerGui.Notifications.Notifications.Visible = false
            KillauraLoop = RunService.Heartbeat:Connect(function()
                if not getgenv().Variables["KillauraVariables"].KillauraEnabled then return end

                if IsPlayerAlive(Player) then
                    KillauraTarget = GetNearestEntity(tonumber(getgenv().Variables["KillauraVariables"].KillauraRange), getgenv().Variables["KillauraVariables"].TeamCheck)

                    if KillauraTarget and not table.find(getgenv().Variables["KillauraVariables"].BlacklistedEntities, KillauraTarget.Name) then
                        local ToolService = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService")

                        if ToolService then
                            local Sword = GetEquippedTool(Player, "Sword")

                            if Sword then
                                ToolService:WaitForChild("RF"):WaitForChild("AttackPlayerWithSword"):InvokeServer(KillauraTarget, true, Sword.Name)
                                ToolService:WaitForChild("RF"):WaitForChild("ToggleBlockSword"):InvokeServer(true, Sword.Name)

                                if getgenv().Variables["KillauraVariables"].BowauraEnabled then
                                    if PlayerGui and PlayerGui.Hotbar.MainFrame.Background.Bar.ArrowProgress.Progress.Size == UDim2.new(0, 0, 1, 0) then
                                        local InvBow = GetToolFromBackpack(Player, "Bow")

                                        if InvBow then
                                            SetEquippedTool(InvBow)
                                            
                                            local Bow = GetEquippedTool(Player, "Bow")

                                            if Bow then
                                                if type(KillauraTarget) == "userdata" and KillauraTarget:IsA("Model") then
                                                    local Target = Players:WaitForChild(KillauraTarget.Name)

                                                    if Target then
                                                        Bow:WaitForChild("__comm__"):WaitForChild("RF"):FindFirstChild("Fire"):InvokeServer(Target.Character.HumanoidRootPart.Position, 9e9)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            else
                                local InvSword = GetToolFromBackpack(Player, "Sword")

                                if InvSword then
                                    SetEquippedTool(InvSword)
                                end
                            end
                        end
                    end
                end
            end)
        else
            PlayerGui.Notifications.Notifications.Visible = true
            if KillauraTarget then KillauraTarget = nil end
            if KillauraLoop then
                KillauraLoop:Disconnect()
                KillauraLoop = nil
            end
        end
    end)

    
    Tabs.Main:AddToggle("TeamCheck", { Title = "Team Check", Default = false }):OnChanged(function()
        getgenv().Variables["KillauraVariables"].TeamCheck = FluentOptions.TeamCheck.Value
    end)

    Tabs.Main:AddToggle("Bowaura", { Title = "Bow Aura", Default = true }):OnChanged(function()
        getgenv().Variables["KillauraVariables"].BowauraEnabled = FluentOptions.Bowaura.Value
    end)

    Tabs.Main:AddSlider("KillauraRange", {
        Title = "Killaura Range",
        Description = "Changes the kill aura range",
        Default = 20,
        Min = 20,
        Max = 40,
        Rounding = 2,
        Callback = function(Value)
            getgenv().Variables["KillauraVariables"].KillauraRange = Value
        end
    })

    Tabs.Main:AddSection("Movement Features")

    local ApplyVelocityLoop = nil
    Tabs.Main:AddToggle("ApplyVelocity", { Title = "Speed", Default = getgenv().Variables.SpeedVariables.SpeedEnabled }):OnChanged(function()
        getgenv().Variables["SpeedVariables"].SpeedEnabled = FluentOptions.ApplyVelocity.Value
        if getgenv().Variables["SpeedVariables"].SpeedEnabled then
            ApplyVelocityLoop = RunService.Heartbeat:Connect(function()
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and IsPlayerAlive(Player) then
                    local humanoidRootPart = Player.Character.HumanoidRootPart
                    
                    local velocity = Player.Character.Humanoid.MoveDirection * getgenv().Variables.SpeedVariables.Speed
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

    Tabs.Main:AddSlider("Speed", {
        Title = "Speed",
        Description = "Changes the player's speed",
        Default = 30,
        Min = 16,
        Max = 32,
        Rounding = 1,
        Callback = function(Value)
            getgenv().Variables["SpeedVariables"].Speed = Value
        end
    })

    local NoslowFunction = nil
    Tabs.Main:AddToggle("Noslow", { Title = "No Slow Down", Default = getgenv().Variables["SpeedVariables"].NoslowEnabled }):OnChanged(function()
        getgenv().Variables["SpeedVariables"].NoslowEnabled = FluentOptions.Noslow.Value
        if getgenv().Variables["SpeedVariables"].NoslowEnabled then
            NoslowFunction = Player.Character:FindFirstChildOfClass("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if IsPlayerAlive(Player) and Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed ~= 16 then
                    Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
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
        Default = getgenv().Variables["ScaffoldVariables"].ScaffoldKeybind,

        Callback = function(Value)
            getgenv().Variables["ScaffoldVariables"].ScaffoldEnabled = Value
            print(getgenv().Variables["ScaffoldVariables"].ScaffoldEnabled)
            if getgenv().Variables["ScaffoldVariables"].ScaffoldEnabled then
                ScaffoldLoop = RunService.Heartbeat:Connect(function()
                    local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")

                    if humanoidRootPart and humanoid then
                        for i = 1, getgenv().Variables["ScaffoldVariables"].ScaffoldExtend do
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
        Default = getgenv().Variables["ScaffoldVariables"].ScaffoldExtend,
        Min = 2,
        Max = 10,
        Rounding = 1,
        Callback = function(Value)
            getgenv().Variables["ScaffoldVariables"].ScaffoldExtend = Value
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