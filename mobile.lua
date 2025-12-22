-- 🧠 STEAL A BRAINROT - CODEX MOBILE AUTO FINDER

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ===== TES RÉGLAGES (MODIFIE ICI) =====
getgenv().MinPerSecond = 30000
getgenv().TargetName = "" -- ex: Sigma (vide = tous)
getgenv().TargetRarity = "" 
-- Commun, Rare, Epique, Légendaire, Mythique, Brainrot God, Secret, OG
-- ====================================

local PlaceId = game.PlaceId
local visited = {}

-- fonction request compatible Codex
local function httpGet(url)
    if request then
        return request({Url = url, Method = "GET"}).Body
    elseif http_request then
        return http_request({Url = url, Method = "GET"}).Body
    end
end

-- scan du serveur actuel
local function scanServer()
    local folder = workspace:FindFirstChild("Brainrots")
    if not folder then return false end

    for _, b in pairs(folder:GetChildren()) do
        if b:IsA("Model")
        and b:FindFirstChild("Value")
        and b:FindFirstChild("Rarity") then

            local value = b.Value.Value
            local rarity = b.Rarity.Value
            local name = b.Name

            if value >= getgenv().MinPerSecond
            and (getgenv().TargetName == "" or string.find(string.lower(name), string.lower(getgenv().TargetName)))
            and (getgenv().TargetRarity == "" or string.lower(rarity) == string.lower(getgenv().TargetRarity)) then

                warn("🔥 BRAINROT TROUVÉ 🔥")
                warn("Nom :", name)
                warn("Rareté :", rarity)
                warn("Valeur :", value)
                return true
            end
        end
    end
    return false
end

-- boucle principale
while task.wait(3) do
    if scanServer() then
        warn("✅ STOP : bon brainrot trouvé")
        break
    end

    local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?limit=100"
    local body = httpGet(url)
    local servers = HttpService:JSONDecode(body).data

    for _, s in pairs(servers) do
        if not visited[s.id] then
            visited[s.id] = true
            TeleportService:TeleportToPlaceInstance(PlaceId, s.id, player)
            task.wait(6)
            break
        end
    end
end
