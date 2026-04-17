local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")
local Players = game:GetService("Players")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local HttpService = game:GetService("HttpService")

local MenuConfigManager = {}

local Config = {
	WaitPerAmount = 500,
}

local CurrentFileName = "default_config.json"

local function IsPlayerCharacter(obj)
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character and obj:IsDescendantOf(plr.Character) then
			return true
		end
	end
	return false
end

function MenuConfigManager.SetFileName(name)
	CurrentFileName = tostring(name) .. ".json"
end

function MenuConfigManager.Save(data)
	local ok, err = pcall(function()
		writefile(CurrentFileName, HttpService:JSONEncode(data))
	end)
	if not ok then
		warn("Save error: " .. tostring(err))
	end
end

function MenuConfigManager.Load()
	local ok, result = pcall(function()
		if isfile and isfile(CurrentFileName) then
			return HttpService:JSONDecode(readfile(CurrentFileName))
		end
	end)
	if ok and type(result) == "table" then
		return result
	end
	return nil
end

function MenuConfigManager.KichHoat(TrangThai)
	if not TrangThai then
		Lighting.GlobalShadows = true
		return
	end

	Lighting.GlobalShadows = false
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

	local allDescendants = game:GetDescendants()
	local count = 0

	for _, v in ipairs(allDescendants) do
		count += 1
		if count >= Config.WaitPerAmount then
			task.wait()
			count = 0
		end

		if IsPlayerCharacter(v) then continue end

		if v:IsA("BasePart") then
			v.Material = Enum.Material.Plastic
			v.Reflectance = 0
			if v:IsA("MeshPart") then
				v.RenderFidelity = Enum.RenderFidelity.Performance
			end
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
			v.Enabled = false
		elseif v:IsA("Decal") or v:IsA("Texture") then
			v.Transparency = 1
		elseif v:IsA("PostEffect") then
			v.Enabled = false
		end
	end
end

return MenuConfigManager
