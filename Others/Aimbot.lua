local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

-- Lock state variable
local isLockedOn = false
local targetPlayer = nil

-- Player functions
local function getNearestPlayer()
    local nearestPlayer = nil
    local nearestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local distance = (localPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < nearestDistance then 
                    nearestPlayer = player
                    nearestDistance = distance
                end
            end
        end
    end

    return nearestPlayer
end

-- Highlight functions
local function isHighlighted(player)
    return player.Character and player.Character:FindFirstChild("px23jdnx") ~= nil
end

local function createHighlight(player)
    if player and player.Character then
        local character = player.Character or player.CharacterAdded:Wait()
        if character and not isHighlighted(player) then
            local highlight = Instance.new("Highlight", character)
            highlight.FillColor = Color3.new(128, 0, 128)
            highlight.FillTransparency = 0.8
            highlight.OutlineColor = Color3.new(255, 255, 255)
            highlight.Name = "px23jdnx"
        end
    end
end

local function destroyHighlight(player)
    if player and player.Character then
        local character = player.Character or player.CharacterAdded:Wait()
        if character and isHighlighted(player) then
            local highlight = character:FindFirstChild("px23jdnx")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

-- Helper functions
local function predictNextPosition(player, deltaTime)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
        local hrp = player.Character.HumanoidRootPart
        local velocity = hrp.Velocity
        local predictedPosition = hrp.Position + (velocity * deltaTime)
        return predictedPosition
    end
    return nil
end

-- Lock functions
local function lockOntoPlayer(player)
    if player and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
        local camera = workspace.CurrentCamera

        RunService:BindToRenderStep("SmoothCameraLock", Enum.RenderPriority.Camera.Value, function()
            if isLockedOn and player and player.Character and player.Character:FindFirstChild("Head") and player.Character.Humanoid.Health > 0 then
                local deltaTime = RunService.Heartbeat:Wait()
                local head = player.Character.Head
                local predictedPosition = predictNextPosition(player, deltaTime) or head.Position
                local targetCFrame = CFrame.new(camera.CFrame.Position, predictedPosition)

                camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.1)
                createHighlight(targetPlayer)
            else
                RunService:UnbindFromRenderStep("SmoothCameraLock")
                destroyHighlight(targetPlayer)
            end
        end)
    end
end

-- User input handling
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right-click
        isLockedOn = not isLockedOn
        if isLockedOn then
            targetPlayer = getNearestPlayer()
            if targetPlayer then
                lockOntoPlayer(targetPlayer)
            else
                isLockedOn = false
            end
        else
            RunService:UnbindFromRenderStep("SmoothCameraLock")
        end
    end
end)