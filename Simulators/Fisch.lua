-- Load external libraries
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- << Initialization >> --

local function initializeServices()
    return {
        Players = game:GetService("Players"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        GuiService = game:GetService("GuiService"),
        VirtualInputManager = game:GetService("VirtualInputManager"),
        RunService = game:GetService("RunService")
    }
end

local function initializePlayerData(services)
    local Player = services.Players.LocalPlayer
    return {
        Player = Player,
        PlayerGui = Player.PlayerGui,
        LocalName = Player.Name,
        LocalDisplayName = Player.DisplayName,
        Backpack = Player.Backpack,
        LocalCharacter = Player.Character or Player.CharacterAdded:Wait()
    }
end

local Services = initializeServices()
local PlayerData = initializePlayerData(Services)

local DescendantAddedConnection
local DescendantRemovingConnection

--- << Loading Screen Check >> ---

repeat task.wait(0.2) until PlayerData.Player:WaitForChild("DoneLoading").Value == true

--- << Auto Farm Variables >> ---

local isAutoCastEnabled = false
local isAutoReelEnabled = false
local isAutoShakeEnabled = false

--- << Miscellaneous Variables >> ---

local WalkspeedValue = 16 -- Default
local JumppowerValue = 50 -- Default

local isNoClipEnabled = true
local isWalkonWaterEnabled = true

--- << Teleport Variables >> --- 

local WorldZones = {}
local NPCZones = {}

-- << Auto Functions >> --

local function autoShake()
    xpcall(function()
        local shakeUI = PlayerData.PlayerGui:FindFirstChild("shakeui")
        if not shakeUI then return end

        local button = shakeUI:FindFirstChild("safezone"):FindFirstChild("button")
        if button and Services.GuiService.SelectedObject ~= button then
            if button == nil then return end
            Services.GuiService.SelectedObject = button
            if Services.GuiService.SelectedObject == button then
                Services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                Services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
            task.wait(0.1)
            Services.GuiService.SelectedObject = nil
        end
    end, function(err)
        warn("Error in autoShake: ", err)
    end)
end

local function startAutoShake()
    if isAutoShakeEnabled and not Fluent.Unloaded then
        AutoShakeConnection = Services.RunService.RenderStepped:Connect(function()
            autoShake()
        end)
    end
end

local function stopAutoShake()
    if AutoShakeConnection then
        AutoShakeConnection:Disconnect()
        AutoShakeConnection = nil
    end
end

local function autoReel()
    local reel = PlayerData.PlayerGui:FindFirstChild("reel")
    if reel then
        local playerBar = reel:FindFirstChild("bar"):FindFirstChild("playerbar")
        if playerBar then
            playerBar:GetPropertyChangedSignal('Position'):Wait()
            Services.ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, true)
        end
    end
end

local function startAutoReel()
    if isAutoReelEnabled and not Fluent.Unloaded then
        autoReel()
    end
end

local function stopAutoReel()
    if AutoReelConnection then
        AutoReelConnection:Disconnect()
        AutoReelConnection = nil
    end
end

local function autoCast()
    local EquippedRod = Services.ReplicatedStorage.playerstats[PlayerData.LocalName].Stats.rod.Value

    if EquippedRod and string.find(EquippedRod, "Rod") then
        if PlayerData.Backpack:FindFirstChild(EquippedRod) then
            PlayerData.LocalCharacter.Humanoid:EquipTool(PlayerData.Backpack:FindFirstChild(EquippedRod))
            wait(0.1)
        end

        if PlayerData.LocalCharacter then
            local Tool = PlayerData.LocalCharacter:FindFirstChildOfClass("Tool")
            if Tool then
                local HasBobber = Tool:FindFirstChild("bobber")
                if not HasBobber then
                    local rod = PlayerData.LocalCharacter:FindFirstChildOfClass("Tool")
                    if rod and string.find(rod.Name, "Rod") and rod:FindFirstChild("events") then
                        local castEvent = rod.events:FindFirstChild("cast")
                        if castEvent then
                            while not HasBobber do
                                HasBobber = Tool:FindFirstChild("bobber")
                                if HasBobber then return end
                                castEvent:FireServer(math.random(99, 100))
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- << Event Handlers >> --

DescendantAddedConnection = PlayerData.PlayerGui.DescendantAdded:Connect(function(descendant)
    if descendant.Name == "button" and descendant.Parent.Name == "safezone" then
        if isAutoShakeEnabled and not Fluent.Unloaded then
            startAutoShake()
        end
    elseif descendant.Name == "playerbar" and descendant.Parent.Name == "bar" then
        stopAutoShake()
        if isAutoReelEnabled and not Fluent.Unloaded then
            wait(0.5)
            startAutoReel()
        end
    end
end)

DescendantRemovingConnection = PlayerData.PlayerGui.DescendantRemoving:Connect(function(descendant)
    if descendant.Name == "playerbar" and descendant.Parent.Name == "bar" then
        stopAutoReel()
        if isAutoCastEnabled and not Fluent.Unloaded then
            wait(0.4)
            autoCast()
        end
    end
end)

local function NoClip()
    while isNoClipEnabled and not Fluent.Unloaded do
        for i, v in pairs(PlayerData.LocalCharacter:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide == true then
                v.CanCollide = false
            end
        end
        task.wait(0.1)
    end
end

if isNoClipEnabled then
    task.spawn(NoClip)
end

-- << GUI Setup with Fluent >> --

local function setupFluent()
    local Options = Fluent.Options

    local Window = Fluent:CreateWindow({
        Title = "Fisch | By Adrien",
        SubTitle = "Ancient Isles Update",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Theme = "Amethyst",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    local Tabs = {
        Home = Window:AddTab({ Title = "Home", Icon = "home" }),
        Main = Window:AddTab({ Title = "Main", Icon = "list" }),
        Miscellaneous = Window:AddTab({ Title = "Miscellaneous", Icon = "layers" }),
        Teleport = Window:AddTab({ Title = "Teleport", Icon = "navigation" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    Fluent:Notify({
        Title = "Notification",
        Content = "Loading Script | Fisch Script",
        SubContent = "Fisch",
        Duration = 2.5
    })

    --- << Home Tab >> ---
    
    Tabs.Home:AddSection("Reminder Section")
    Tabs.Home:AddParagraph({
        Title = "Unstable",
        Content = "Welcome " .. PlayerData.LocalDisplayName .. "(@" .. PlayerData.LocalName .. ")! Enjoy this script."
    })

    Tabs.Home:AddSection("Status Section")
    Tabs.Home:AddParagraph({
        Title = "Status",
        Content = "Username: " .. PlayerData.LocalDisplayName .. "(@" .. PlayerData.LocalName .. ")\nCash on Execute: ".. PlayerData.Player.leaderstats["C$"].Value or "N/A"
    })

    --- << Main Tab >> ---
    
    --- << Auto Farm Section >> ---
    Tabs.Main:AddSection("Auto Farm Section")
    Tabs.Main:AddToggle("autoCast", { Title = "Auto Cast", Default = isAutoCastEnabled }):OnChanged(function()
        isAutoCastEnabled = Options.autoCast.Value
        if isAutoCastEnabled then
            autoCast()
        end
    end)

    Tabs.Main:AddToggle("autoShake", { Title = "Auto Shake", Default = isAutoShakeEnabled }):OnChanged(function()
        isAutoShakeEnabled = Options.autoShake.Value
        if isAutoShakeEnabled then
            startAutoShake()
        else
            stopAutoShake()
        end
    end)

    Tabs.Main:AddToggle("autoReel", { Title = "Auto Minigame", Default = isAutoReelEnabled }):OnChanged(function()
        isAutoReelEnabled = Options.autoReel.Value
        if isAutoReelEnabled then
            startAutoReel()
        else
            stopAutoReel()
        end
    end)

    --- << Miscellaneous Tab >> ---
    
    Tabs.Miscellaneous:AddSection("Player Section")
    Tabs.Miscellaneous:AddToggle("noclip", { Title = "NoClip", Default = isNoClipEnabled }):OnChanged(function()
        isNoClipEnabled = Options.noclip.Value
        if isNoClipEnabled then
            task.spawn(NoClip)
        end
    end)

    Tabs.Miscellaneous:AddToggle("waterwalk", { Title = "Walk on Water", Default = isWalkonWaterEnabled }):OnChanged(function()
        isWalkonWaterEnabled = Options.waterwalk.Value
        for i,v in pairs(workspace.zones.fishing:GetChildren()) do
            v.CanCollide = isWalkonWaterEnabled
            if v.Name == "Ocean" then
                for i,v in pairs(workspace.zones.fishing:GetChildren()) do
                    if v.Name == "Deep Ocean" then
                        v.CanCollide = isWalkonWaterEnabled
                    end
                end
            end
		end
    end)

    Tabs.Miscellaneous:AddSlider("walkspeed", {
        Title = "Walkspeed",
        Description = "Changes the LocalPlayer's walkspeed",
        Default = 16,
        Min = 16,
        Max = 250,
        Rounding = 1,
        Callback = function(Value)
            WalkspeedValue = Value
            PlayerData.LocalCharacter.Humanoid.WalkSpeed = WalkspeedValue
        end
    })

    Tabs.Miscellaneous:AddSlider("jumppower", {
        Title = "Jump Height",
        Description = "Changes the LocalPlayer's jump power",
        Default = 50,
        Min = 50,
        Max = 500,
        Rounding = 1,
        Callback = function(Value)
            JumppowerValue = Value
            PlayerData.LocalCharacter.Humanoid.JumpPower = JumppowerValue
        end
    })

    Tabs.Miscellaneous:AddSection("Game Section")
    Tabs.Miscellaneous:AddToggle("bypassradar", { Title = "Bypass Fish Radar", Default = false }):OnChanged(function()
        for _, v in pairs(game:GetService("CollectionService"):GetTagged("radarTag")) do
			if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
				v.Enabled = Options.bypassradar.Value
			end
		end
    end)

    Tabs.Miscellaneous:AddToggle("disableoxygen", { Title = "Disable Oxygen", Default = false }):OnChanged(function()
        PlayerData.LocalCharacter.client.oxygen.Disabled = Options.disableoxygen.Value
    end)

    --- << Library Manager >> ---
    
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:SetLibrary(Fluent)
    SaveManager:SetFolder("FluentScriptHub/fisch")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    --- << Initialization >> ---
    
    Window:SelectTab(1)
    Fluent:Notify({ Title = "Fluent", Content = "The script has been loaded.", Duration = 8 })
    SaveManager:LoadAutoloadConfig()

    while task.wait(1) do
        game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("afk"):FireServer(false)
        if Fluent.Unloaded then
            if AutoReelConnection ~= nil then AutoReelConnection:Disconnect() AutoReelConnection = nil end
            if AutoShakeConnection ~= nil then AutoShakeConnection:Disconnect() AutoShakeConnection = nil end
            if DescendantAddedConnection ~= nil then DescendantAddedConnection:Disconnect() DescendantAddedConnection = nil end
            if DescendantRemovingConnection ~= nil then DescendantRemovingConnection:Disconnect() DescendantRemovingConnection = nil end
            print('disabled all connections.')
            break
        end
    end
end

setupFluent()