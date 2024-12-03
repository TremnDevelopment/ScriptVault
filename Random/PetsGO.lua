print(workspace['__THINGS'])
local player = game.Players.LocalPlayer

local character = player.Character

-- Auto Collect Orbs
local function collectOrbs()
    for _, orb in ipairs(workspace['__THINGS']:WaitForChild("Orbs"):GetChildren()) do
        if orb and orb:IsA("Part") then
            local orbPosition = orb.Position

            if character and character:WaitForChild("Humanoid") and character.Humanoid.Health > 0 then
                local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.CFrame = CFrame.new(orbPosition)
                end
            end
        end
    end
end

local function BreakNearestBreakable()
    local function getNearestBreakable(range)
        local playerPosition = character.HumanoidRootPart.Position
        local closestBreakable = nil
        local closestDistance = math.huge

        for _, breakable in ipairs(workspace["__THINGS"]:WaitForChild("Breakables"):GetChildren()) do
            if breakable:IsA("Model") then
                local breakablePart = breakable:FindFirstChildWhichIsA("Part") or breakable:FindFirstChildWhichIsA("MeshPart")
                if breakablePart then
                    local distance = (breakablePart.Position - playerPosition).Magnitude
                    if distance < closestDistance and distance <= range then
                        closestDistance = distance
                        closestBreakable = breakable
                    end
                end
            end
        end

        return closestBreakable.Name
    end
    
    local nearestBreakable = getNearestBreakable(500)
    local breakablePart = nearestBreakable:FindFirstChildWhichIsA('Part')
    character.HumanoidRootPart.CFrame = CFrame.new(breakablePart.Position)
end

BreakNearestBreakable()