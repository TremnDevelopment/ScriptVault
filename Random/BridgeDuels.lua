local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local cloneref = cloneref or function(o) return o end

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))

local OldC0

getgenv().Variables = {
    KillauraVariables = {
        BlacklistedEntities = {"Transport_Month"},
        KillauraEnabled = true,
        BowauraEnabled = false,
        KillauraRange = 20,
        TeamCheck = true,

        SwingAnimation = {}
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

local function ConvertPositionToVector(Position)
    local ConvertedPosition = Vector3.new(math.floor((Position.X / 3) + 0.5) * 3, math.floor((Position.Y / 3) + 0.5) * 3, math.floor((Position.Z / 3) + 0.5) * 3)
    return ConvertedPosition
end

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

local function GetItemC0()
    local ToolC0 = nil
    local Viewmodel = game.Workspace.CurrentCamera:GetChildren()[1]
    
    if not OldC0 then
        OldC0 = Viewmodel:FindFirstChildWhichIsA("Model"):WaitForChild("Handle"):FindFirstChild("MainPart").C0
    end

    if Viewmodel then
        for _, model in pairs(Viewmodel:GetChildren()) do
            if model:IsA("Model") then
                for _, part in pairs(model:GetChildren()) do
                    if part:IsA("Part") and part.Name == "Handle" then
                        for _, motor in pairs(part:GetChildren()) do
                            if motor:IsA("Motor6D") and motor.Name == "MainPart" then
                                ToolC0 = motor
                            end
                        end
                    end
                end
            end
        end
    end
    return ToolC0
end

local function AnimateC0(animation)
    local Tool = GetItemC0()
    if Tool then
        for _, anim in ipairs(animation) do
            local newC0 = OldC0 * anim.CFrame
            local Tween = TweenService:Create(Tool, TweenInfo.new(anim.Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C0 = newC0})

            if Tween then
                Tween:Play()
                Tween.Completed:Wait()
            end
        end
    end
end

local function PredictPosition(target, time)
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    local targetVelocity = targetHRP.Velocity
    local predictedPosition = targetHRP.Position + (targetVelocity * time)
    return predictedPosition
end

local function CheckWall(v)
    local Raycast, Result = nil, nil

    local Direction = (v:FindFirstChild("HumanoidRootPart").Position - Player.Character:FindFirstChild("HumanoidRootPart").Position).Unit
    local Distance = (v:FindFirstChild("HumanoidRootPart").Position - Player.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude
    if Direction and Distance then
        Raycast = RaycastParams.new()
        Raycast.FilterDescendantsInstances = {Player.Character}
        Raycast.FilterType = Enum.RaycastFilterType.Exclude
        Result = game.Workspace:Raycast(Player.Character:FindFirstChild("HumanoidRootPart").Position, Direction * Distance, Raycast)
        if Result then
            if not v:IsAncestorOf(Result.Instance) then
                return false
            end
        end
    end
    return true
end

local function SetEquippedTool(Tool)
    Player.Character.Humanoid:EquipTool(Tool)
end

local function Initialize()
    local FluentOptions = Fluent.Options

    local Window = Fluent:CreateWindow({
        Title = "Keyware | Bridge Duel",
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
    local BowStartTick, BowEndTick, SwordStartTick, SwordEndTick = nil, 0, nil, 0
    Tabs.Main:AddToggle("Killaura", { Title = "Killaura", Default = true }):OnChanged(function()
        getgenv().Variables["KillauraVariables"].KillauraEnabled = FluentOptions.Killaura.Value
    
        if getgenv().Variables["KillauraVariables"].KillauraEnabled then
            task.spawn(function()
                while getgenv().Variables["KillauraVariables"].KillauraEnabled do
                    if IsPlayerAlive(Player) and (KillauraTarget and (KillauraTarget.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 20) and IsPlayerAlive(Players:WaitForChild(KillauraTarget.Name)) and GetItemC0() then
                        if typeof(getgenv().Variables["KillauraVariables"].SwingAnimation) == "table" then
                            AnimateC0(getgenv().Variables["KillauraVariables"].SwingAnimation)
                        end
                    end
                    task.wait(.35)
                end
            end)
            KillauraLoop = RunService.Heartbeat:Connect(function(deltaTime)
                if not getgenv().Variables["KillauraVariables"].KillauraEnabled then return end

                BowEndTick = BowEndTick + deltaTime
                SwordEndTick = SwordEndTick + deltaTime
    
                if IsPlayerAlive(Player) then
                    if not SwordStartTick or SwordEndTick > 0 then
                        SwordStartTick = tick(); SwordEndTick = 0
                        KillauraTarget = GetNearestEntity(tonumber(getgenv().Variables["KillauraVariables"].KillauraRange), getgenv().Variables["KillauraVariables"].TeamCheck)
    
                        if KillauraTarget and not table.find(getgenv().Variables["KillauraVariables"].BlacklistedEntities, KillauraTarget.Name) then
                            local ToolService = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService")
    
                            if ToolService then
                                local Sword = GetEquippedTool(Player, "Sword")
    
                                if Sword then
                                    if (KillauraTarget.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 20 then
										for i = 1, 2 do
                                        	ToolService:WaitForChild("RF"):WaitForChild("AttackPlayerWithSword"):InvokeServer(KillauraTarget, true, Sword.Name, "\226\128\139")
											task.wait(0.1)
										end
                                    end

                                    ToolService:WaitForChild("RF"):WaitForChild("ToggleBlockSword"):InvokeServer(true, Sword.Name)
    
                                    if getgenv().Variables["KillauraVariables"].BowauraEnabled and BowEndTick > 5 then
                                        BowStartTick = tick(); BowEndTick = 0
                                        if PlayerGui and PlayerGui.Hotbar.MainFrame.Background.Bar.ArrowProgress.Progress.Size == UDim2.new(0, 0, 1, 0) then
                                            local InvBow = GetToolFromBackpack(Player, "Bow")
                                            if InvBow then
                                                SetEquippedTool(InvBow)
    
                                                local Bow = GetEquippedTool(Player, "Bow")
                                                if Bow then
                                                    if KillauraTarget and KillauraTarget:IsA("Model") then
                                                        local Target = Players:WaitForChild(KillauraTarget.Name)
                                                        if Target and CheckWall(KillauraTarget) then
                                                            local predictedPosition = PredictPosition(Target, deltaTime)
                                                            Bow:WaitForChild("__comm__"):WaitForChild("RF"):FindFirstChild("Fire"):InvokeServer(predictedPosition, 9e9)
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
                end
            end)
        else
            if KillauraTarget then KillauraTarget = nil end

            if KillauraLoop then
                KillauraLoop:Disconnect()
                KillauraLoop = nil
            end
        end
    end)
    
    Tabs.Main:AddToggle("TeamCheck", { Title = "Team Check", Default = true }):OnChanged(function()
        getgenv().Variables["KillauraVariables"].TeamCheck = FluentOptions.TeamCheck.Value
    end)

    Tabs.Main:AddToggle("Bowaura", { Title = "Bow Aura", Default = false }):OnChanged(function()
        getgenv().Variables["KillauraVariables"].BowauraEnabled = FluentOptions.Bowaura.Value
    end)

    Tabs.Main:AddSlider("KillauraRange", {
        Title = "Range",
        Description = "Changes the range for the Killaura and Bowaura",
        Default = 20,
        Min = 20,
        Max = 160,
        Rounding = 2,
        Callback = function(Value)
            getgenv().Variables["KillauraVariables"].KillauraRange = Value
        end
    })

    Tabs.Main:AddToggle("CustomSwing", { Title = 'Custom Swing Animation', Default = false })

    Tabs.Main:AddDropdown("Animation", {
        Title = "Swing Animation",
        Values = {"Strike", "Slash", "Test"},
        Multi = false, -- set to true to make multiple
        Default = 1,
    }):OnChanged(function()
        if FluentOptions.Animation.Value == "Strike" then
            getgenv().Variables["KillauraVariables"].SwingAnimation = {
                {CFrame = CFrame.new(-2.5, 0, 3.5) * CFrame.Angles(math.rad(0), math.rad(25), math.rad(60)), Time = 0.1},
                {CFrame = CFrame.new(-0.5, 0, 1.3) * CFrame.Angles(math.rad(0), math.rad(25), math.rad(60)), Time = 0.1},
                {CFrame = CFrame.new(0.5, 0, 1.5) * CFrame.Angles(math.rad(0), math.rad(30), math.rad(60)), Time = 0.1},
                {CFrame = CFrame.new(1.5, 0, 2.0) * CFrame.Angles(math.rad(0), math.rad(35), math.rad(60)), Time = 0.1},
                {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.1},
            }
        elseif FluentOptions.Animation.Value == "Slash" then
            getgenv().Variables["KillauraVariables"].SwingAnimation = {
                {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(30), math.rad(0), math.rad(0)), Time = 0.2},
                {CFrame = CFrame.new(0, 0, -2) * CFrame.Angles(math.rad(30), math.rad(45), math.rad(0)), Time = 0.15},
                {CFrame = CFrame.new(0, 0, -1.5) * CFrame.Angles(math.rad(15), math.rad(90), math.rad(0)), Time = 0.1},
                {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
            }
        elseif FluentOptions.Animation.Value == "Test" then
            getgenv().Variables["KillauraVariables"].SwingAnimation = {
                {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.2},
                {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-45), math.rad(0)), Time = 0.3},
                {CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(0), math.rad(-20), math.rad(0)), Time = 0.2},
                {CFrame = CFrame.new(0, 0, -1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.2},
                {CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(0), math.rad(30), math.rad(0)), Time = 0.15},
                {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.2},
            }
        end
    end)

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
        Mode = "Toggle",
        Default = getgenv().Variables["ScaffoldVariables"].ScaffoldKeybind,

        Callback = function(Value)
            getgenv().Variables["ScaffoldVariables"].ScaffoldEnabled = Value
            if getgenv().Variables["ScaffoldVariables"].ScaffoldEnabled then
                ScaffoldLoop = RunService.Heartbeat:Connect(function()
                    local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                
                    if humanoidRootPart and humanoid and IsPlayerAlive(Player) then
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) and (not UserInputService:GetFocusedTextBox()) then
                            Player.Character.HumanoidRootPart.Velocity = Vector3.new(Player.Character.HumanoidRootPart.Velocity.X, 25, Player.Character.HumanoidRootPart.Velocity.Z)
                        end

                        for i = 1, getgenv().Variables["ScaffoldVariables"].ScaffoldExtend do
                            local PlacePos = ConvertPositionToVector(humanoidRootPart.Position + humanoid.MoveDirection * (i * 3.5) - Vector3.new(0, (humanoidRootPart.Size.Y / 2) + humanoid.HipHeight + 1.5, 0))
                            
                            if PlacePos then
                                local region = Region3.new(PlacePos - Vector3.new(0.5, 0.5, 0.5), PlacePos + Vector3.new(0.5, 0.5, 0.5))
                                local parts = workspace:FindPartsInRegion3(region, nil, math.huge)
                
                                if #parts == 0 then
                                    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("PlaceBlock"):InvokeServer(PlacePos)
                                end
                            end
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
        Max = 6,
        Rounding = 1,
        Callback = function(Value)
            getgenv().Variables["ScaffoldVariables"].ScaffoldExtend = Value
        end
    })	
	
    Tabs.Main:AddSection("BETA Features")   

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
