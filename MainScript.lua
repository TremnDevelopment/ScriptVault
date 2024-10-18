local placeId = game.PlaceId

local authorizedPlaces = {
  [13083893317] = "https://raw.githubusercontent.com/TremnDevelopment/ScriptVault/refs/heads/main/LifeSentence.lua"
}

if authorizedPlaces and authorizedPlaces[placeId] then
  loadstring(game:HttpGet(authorizedPlaces[placeId], true))()
end