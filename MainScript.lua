local placeId = game.PlaceId

local function getGamePlaceId()
  if placeId then
    return placeId
  end
  return nil
end

local suc, err = pcall(function()
  loadstring(game:HttpGet("https://raw.githubusercontent.com/TremnDevelopment/ScriptVault/refs/heads/main/" .. getGamePlaceId() .. ".lua"))()
end)

if not suc then error(err) end
