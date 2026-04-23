local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

local MenuConfigManager = {}
local CurrentFileName = "default_config_" .. tostring(game.PlaceId) .. ".json"
local _KetNoiDonDep = {}
local _DaKichHoat = false

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

local function TatHieuUngLighting()
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect")
			or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
			v.Enabled = false
		end
	end
	Lighting.GlobalShadows             = false
	Lighting.FogEnd                    = 9e9
	Lighting.FogStart                  = 9e9
	Lighting.Brightness                = 1
	Lighting.ShadowSoftness            = 0
	Lighting.EnvironmentDiffuseScale   = 0
	Lighting.EnvironmentSpecularScale  = 0
	Lighting.OutdoorAmbient            = Color3.fromRGB(70, 70, 70)
	Lighting.Ambient                   = Color3.fromRGB(70, 70, 70)
end

local function TatHieuUngTerrain()
	if not Terrain then return end
	Terrain.WaterWaveSize     = 0
	Terrain.WaterWaveSpeed    = 0
	Terrain.WaterReflectance  = 0
	Terrain.WaterTransparency = 0
	Terrain.Decoration        = false
	Terrain.WaterColor        = Color3.fromRGB(0, 0, 0)
end

local function ToiUuCaiDat()
	pcall(function()
		settings().Rendering.QualityLevel       = 1
		settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
		settings().Rendering.EagerBulkExecution  = true
	end)
end

local function XayDungCacheChar()
	local cache = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then cache[plr.Character] = true end
	end
	return cache
end

local function LaObjTrongChar(obj, charCache)
	local p = obj.Parent
	while p and p ~= game do
		if charCache[p] then return true end
		p = p.Parent
	end
	return false
end

local function TatHieuUngObject(v)
	if v:IsA("BasePart") then
		v.Material    = Enum.Material.Plastic
		v.Reflectance = 0
		v.CastShadow  = false
		if v:IsA("MeshPart") then
			v.RenderFidelity = Enum.RenderFidelity.Performance
		end
	elseif v:IsA("Decal") or v:IsA("Texture") then
		v.Transparency = 1
	elseif v:IsA("ParticleEmitter") then
		v.Enabled  = false
		v.Rate     = 0
		v.Lifetime = NumberRange.new(0)
		v.Speed    = NumberRange.new(0)
	elseif v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire")
		or v:IsA("Sparkles") or v:IsA("Explosion") then
		v.Enabled = false
	elseif v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") then
		v.Enabled = false
	elseif v:IsA("Sound") then
		v.Volume = 0
	elseif v:IsA("SelectionBox") or v:IsA("SelectionSphere") or v:IsA("Highlight") then
		v.Visible = false
	elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
		v.Enabled = false
	end
end

local function QuetToanBo(charCache)
	local danhSach = game:GetDescendants()
	local tong     = #danhSach
	local batch    = 800
	for i = 1, tong do
		local v = danhSach[i]
		if not LaObjTrongChar(v, charCache) then
			TatHieuUngObject(v)
		end
		if i % batch == 0 then
			RunService.RenderStepped:Wait()
		end
	end
end

local function LangNgheObjMoi(charCache)
	local conn = game.DescendantAdded:Connect(function(v)
		if not LaObjTrongChar(v, charCache) then
			task.defer(function() TatHieuUngObject(v) end)
		end
	end)
	table.insert(_KetNoiDonDep, conn)
end

local function LangNgheCharMoi(charCache)
	local connAdded = Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function(char)
			charCache[char] = true
			task.delay(1, function()
				for _, v in ipairs(char:GetDescendants()) do
					if v:IsA("BasePart") then v.CastShadow = false end
				end
			end)
		end)
	end)
	table.insert(_KetNoiDonDep, connAdded)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then charCache[plr.Character] = true end
		plr.CharacterAdded:Connect(function(char)
			charCache[char] = true
			task.delay(1, function()
				for _, v in ipairs(char:GetDescendants()) do
					if v:IsA("BasePart") then v.CastShadow = false end
				end
			end)
		end)
	end
end

function MenuConfigManager.KichHoat(TrangThai)
	if not TrangThai then
		_DaKichHoat = false
		for _, c in ipairs(_KetNoiDonDep) do
			pcall(function() c:Disconnect() end)
		end
		_KetNoiDonDep = {}
		Lighting.GlobalShadows = true
		return
	end

	if _DaKichHoat then return end
	_DaKichHoat = true

	TatHieuUngLighting()
	TatHieuUngTerrain()
	ToiUuCaiDat()

	local charCache = XayDungCacheChar()
	LangNgheCharMoi(charCache)

	task.spawn(function()
		QuetToanBo(charCache)
		LangNgheObjMoi(charCache)
	end)
end

return MenuConfigManager
