local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

local MenuConfigManager = {}
local CurrentFileName = "default_config_" .. tostring(game.PlaceId) .. ".json"

function MenuConfigManager.SetFileName(name)
	CurrentFileName = tostring(name) .. "_" .. tostring(game.PlaceId) .. ".json"
end

function MenuConfigManager.Save(data)
	pcall(function() writefile(CurrentFileName, HttpService:JSONEncode(data)) end)
end

function MenuConfigManager.Load()
	local ok, result = pcall(function()
		if isfile and isfile(CurrentFileName) then
			return HttpService:JSONDecode(readfile(CurrentFileName))
		end
	end)
	return (ok and type(result) == "table") and result or nil
end

function MenuConfigManager.KichHoat(TrangThai)
	Lighting.GlobalShadows = not TrangThai
	if not TrangThai then return end

	Lighting.FogEnd = 9e9
	Lighting.ShadowSoftness = 0
	if Terrain then
		Terrain.WaterWaveSize = 0
		Terrain.WaterWaveSpeed = 0
		Terrain.WaterReflectance = 0
		Terrain.WaterTransparency = 0
	end

	settings().Rendering.QualityLevel = 1
	settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01

	local CharCache = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then CharCache[plr.Character] = true end
	end

	local count = 0
	for _, v in ipairs(game:GetDescendants()) do
		count += 1
		if count >= 500 then task.wait() count = 0 end

		local isChar = false
		local parent = v.Parent
		while parent and parent ~= game do
			if CharCache[parent] then isChar = true break end
			parent = parent.Parent
		end
		if isChar then continue end

		if v:IsA("BasePart") then
			v.Material = Enum.Material.Plastic
			v.Reflectance = 0
			if v:IsA("MeshPart") then v.RenderFidelity = Enum.RenderFidelity.Performance end
		elseif v:IsA("Decal") or v:IsA("Texture") then
			v.Transparency = 1
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("PostEffect") then
			v.Enabled = false
		end
	end
end

return MenuConfigManager