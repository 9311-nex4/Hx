local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local NguoiChoi = Players.LocalPlayer
local GuiNguoiChoi = NguoiChoi:WaitForChild("PlayerGui")

local CONFIG = {
	SO_LUONG_MAX = 3,
	KHOANG_CACH = 10,
	CHIEU_CAO_TB = 65,
	MAU_CHU_DAO = Color3.fromRGB(0, 255, 170),
	MAU_LOI = Color3.fromRGB(255, 60, 60),
	MAU_NEN = Color3.fromRGB(15, 15, 20),
	MAU_XAC_NHAN = Color3.fromRGB(255, 75, 75),
	MAU_CHU = Color3.fromRGB(220, 220, 220)
}

local existingGui = GuiNguoiChoi:FindFirstChild("ChaosSystem_Final")
if existingGui then
	existingGui:Destroy()
end

local GuiChinh = Instance.new("ScreenGui")
GuiChinh.Name = "ChaosSystem_Final"
GuiChinh.ResetOnSpawn = false
GuiChinh.IgnoreGuiInset = true
GuiChinh.DisplayOrder = 1000
GuiChinh.Parent = GuiNguoiChoi

local ThongBaoDangHien = {}
local KhungLoiHienTai = nil
local KhungXacNhanHienTai = nil
local Guithongbao = {}

function Guithongbao.CapNhatChuDe(ThemeInfo)
	if not ThemeInfo then return end
	CONFIG.MAU_CHU_DAO = ThemeInfo.VienNeon or CONFIG.MAU_CHU_DAO
	CONFIG.MAU_NEN = ThemeInfo.NenKhoi or ThemeInfo.Nen or CONFIG.MAU_NEN
	CONFIG.MAU_CHU = ThemeInfo.Chu or CONFIG.MAU_CHU

	local ti = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	for _, v in ipairs(ThongBaoDangHien) do
		if v.Khung then TweenService:Create(v.Khung, ti, {BackgroundColor3 = CONFIG.MAU_NEN}):Play() end
		if v.Stroke then TweenService:Create(v.Stroke, ti, {Color = CONFIG.MAU_CHU_DAO}):Play() end
		if v.NhanTieuDe then TweenService:Create(v.NhanTieuDe, ti, {TextColor3 = CONFIG.MAU_CHU_DAO}):Play() end
		if v.NhanNoiDung then TweenService:Create(v.NhanNoiDung, ti, {TextColor3 = CONFIG.MAU_CHU}):Play() end
		if v.ThanhChay then TweenService:Create(v.ThanhChay, ti, {BackgroundColor3 = CONFIG.MAU_CHU_DAO}):Play() end
	end

	if KhungXacNhanHienTai then
		local kxn = KhungXacNhanHienTai:FindFirstChildOfClass("Frame")
		if kxn then TweenService:Create(kxn, ti, {BackgroundColor3 = CONFIG.MAU_NEN}):Play() end
	end
end

local function KiemTraMobile()
	local cam = workspace.CurrentCamera
	if not cam then return false end
	return cam.ViewportSize.X <= 800 and cam.ViewportSize.X > 0
end

local function CapNhatViTri()
	local tongDoLech = 0
	for i = #ThongBaoDangHien, 1, -1 do
		local Muc = ThongBaoDangHien[i]
		if Muc.Khung and Muc.Khung.Parent then
			local ViTriDich = UDim2.new(1, -20, 1, -50 - tongDoLech)
			TweenService:Create(Muc.Khung, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = ViTriDich}):Play()
			tongDoLech = tongDoLech + Muc.Khung.Size.Y.Offset + CONFIG.KHOANG_CACH
		end
	end
end

local function RandomChar(len)
	local text = ""
	local chars = {"@","#","%","&","*","!","?","<",">","0","1","X","Z","E","R","O","N","U","L"}
	for i = 1, len do text = text .. chars[math.random(1, #chars)] end
	return text
end

function Guithongbao.thongbao(TieuDe, NoiDung, ThoiGian)
	ThoiGian = math.max(0.1, tonumber(ThoiGian) or 3)

	while #ThongBaoDangHien >= CONFIG.SO_LUONG_MAX do
		local MucCu = table.remove(ThongBaoDangHien, 1)
		if MucCu and MucCu.Khung then
			local TweenRa = TweenService:Create(MucCu.Khung, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(1, 300, 1, MucCu.Khung.Position.Y.Offset),
				BackgroundTransparency = 1
			})
			for _, child in ipairs(MucCu.Khung:GetDescendants()) do
				if child:IsA("TextLabel") then
					TweenService:Create(child, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
				elseif child:IsA("UIStroke") then
					TweenService:Create(child, TweenInfo.new(0.2), {Transparency = 1}):Play()
				end
			end
			TweenRa:Play()
			Debris:AddItem(MucCu.Khung, 0.2)
		end
	end

	local isMobile = KiemTraMobile()
	local width = isMobile and 160 or 220
	local height = isMobile and 55 or CONFIG.CHIEU_CAO_TB
	local titleSize = isMobile and 11 or 14
	local descSize = isMobile and 10 or 12

	local KhungChua = Instance.new("Frame")
	KhungChua.Name = "Notify"
	KhungChua.Size = UDim2.new(0, width, 0, height)
	KhungChua.Position = UDim2.new(1, 300, 1, -50)
	KhungChua.AnchorPoint = Vector2.new(1, 1)
	KhungChua.BackgroundColor3 = CONFIG.MAU_NEN
	KhungChua.BackgroundTransparency = 0.1
	KhungChua.ClipsDescendants = true
	KhungChua.Parent = GuiChinh
	Instance.new("UICorner", KhungChua).CornerRadius = UDim.new(0, 6)

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = CONFIG.MAU_CHU_DAO
	Stroke.Thickness = 1.5
	Stroke.Transparency = 0.4
	Stroke.Parent = KhungChua

	local NhanTieuDe = Instance.new("TextLabel")
	NhanTieuDe.Text = string.upper(tostring(TieuDe))
	NhanTieuDe.Size = UDim2.new(1, -20, 0, 20)
	NhanTieuDe.Position = UDim2.new(0, 12, 0, isMobile and 4 or 6)
	NhanTieuDe.BackgroundTransparency = 1
	NhanTieuDe.TextColor3 = CONFIG.MAU_CHU_DAO
	NhanTieuDe.Font = Enum.Font.GothamBlack
	NhanTieuDe.TextSize = titleSize
	NhanTieuDe.TextXAlignment = Enum.TextXAlignment.Left
	NhanTieuDe.Parent = KhungChua

	local NhanNoiDung = Instance.new("TextLabel")
	NhanNoiDung.Text = tostring(NoiDung)
	NhanNoiDung.Size = UDim2.new(1, -20, 0, isMobile and 25 or 30)
	NhanNoiDung.Position = UDim2.new(0, 12, 0, isMobile and 20 or 26)
	NhanNoiDung.BackgroundTransparency = 1
	NhanNoiDung.TextColor3 = CONFIG.MAU_CHU
	NhanNoiDung.Font = Enum.Font.GothamMedium
	NhanNoiDung.TextSize = descSize
	NhanNoiDung.TextWrapped = true
	NhanNoiDung.TextXAlignment = Enum.TextXAlignment.Left
	NhanNoiDung.Parent = KhungChua

	local NenThoiGian = Instance.new("Frame")
	NenThoiGian.Size = UDim2.new(0.95, 0, 0, 3)
	NenThoiGian.Position = UDim2.new(0.5, 0, 1, -5)
	NenThoiGian.AnchorPoint = Vector2.new(0.5, 0)
	NenThoiGian.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	NenThoiGian.BorderSizePixel = 0
	NenThoiGian.Parent = KhungChua
	Instance.new("UICorner", NenThoiGian).CornerRadius = UDim.new(1, 0)

	local ThanhChay = Instance.new("Frame")
	ThanhChay.Size = UDim2.new(1, 0, 1, 0)
	ThanhChay.BackgroundColor3 = CONFIG.MAU_CHU_DAO
	ThanhChay.BorderSizePixel = 0
	ThanhChay.Parent = NenThoiGian
	Instance.new("UICorner", ThanhChay).CornerRadius = UDim.new(1, 0)

	local DuLieu = { Khung = KhungChua, Stroke = Stroke, NhanTieuDe = NhanTieuDe, NhanNoiDung = NhanNoiDung, ThanhChay = ThanhChay }
	table.insert(ThongBaoDangHien, DuLieu)

	CapNhatViTri()
	TweenService:Create(ThanhChay, TweenInfo.new(ThoiGian, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()

	task.delay(ThoiGian, function()
		if not KhungChua.Parent then return end

		local isExist = false
		for i, v in ipairs(ThongBaoDangHien) do
			if v == DuLieu then
				table.remove(ThongBaoDangHien, i)
				isExist = true
				break
			end
		end

		if not isExist then return end

		local TweenRa = TweenService:Create(KhungChua, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 300, 1, KhungChua.Position.Y.Offset),
			BackgroundTransparency = 1
		})
		TweenService:Create(NhanTieuDe, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		TweenService:Create(NhanNoiDung, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()

		TweenRa:Play()
		Debris:AddItem(KhungChua, 0.35)

		CapNhatViTri()
	end)
end

function Guithongbao.thongbaoloi(TieuDe, NoiDung)
	if KhungLoiHienTai or KhungXacNhanHienTai then return end

	local isMobile = KiemTraMobile()
	local width = isMobile and 300 or 420
	local height = isMobile and 120 or 160
	local titleSize = isMobile and 18 or 24
	local descSize = isMobile and 12 or 15

	local LopNen = Instance.new("Frame")
	LopNen.Size = UDim2.new(1, 0, 1, 0)
	LopNen.BackgroundColor3 = Color3.new(0,0,0)
	LopNen.BackgroundTransparency = 1
	LopNen.Parent = GuiChinh
	TweenService:Create(LopNen, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
	KhungLoiHienTai = LopNen

	local KhungLoi = Instance.new("Frame")
	KhungLoi.Size = UDim2.new(0, width, 0, height)
	KhungLoi.Position = UDim2.new(0.5, 0, 0.5, 0)
	KhungLoi.AnchorPoint = Vector2.new(0.5, 0.5)
	KhungLoi.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	KhungLoi.BorderSizePixel = 0
	KhungLoi.ClipsDescendants = true
	KhungLoi.Parent = LopNen

	local Scanlines = Instance.new("ImageLabel")
	Scanlines.Size = UDim2.new(1, 0, 1, 0)
	Scanlines.BackgroundTransparency = 1
	Scanlines.Image = "rbxassetid://7240608779"
	Scanlines.ImageTransparency = 0.9
	Scanlines.ImageColor3 = CONFIG.MAU_LOI
	Scanlines.ScaleType = Enum.ScaleType.Tile
	Scanlines.TileSize = UDim2.new(0, 20, 0, 20)
	Scanlines.Parent = KhungLoi

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = CONFIG.MAU_LOI
	Stroke.Thickness = 2
	Stroke.Parent = KhungLoi

	local NhanTieuDe = Instance.new("TextLabel")
	NhanTieuDe.Text = string.upper(tostring(TieuDe))
	NhanTieuDe.Size = UDim2.new(1, -40, 0, 40)
	NhanTieuDe.Position = UDim2.new(0, 20, 0, isMobile and 5 or 15)
	NhanTieuDe.BackgroundTransparency = 1
	NhanTieuDe.TextColor3 = CONFIG.MAU_LOI
	NhanTieuDe.Font = Enum.Font.GothamBlack
	NhanTieuDe.TextSize = titleSize
	NhanTieuDe.TextXAlignment = Enum.TextXAlignment.Left
	NhanTieuDe.Parent = KhungLoi

	local TieuDeBong = NhanTieuDe:Clone()
	TieuDeBong.TextColor3 = Color3.fromRGB(0, 255, 255)
	TieuDeBong.TextTransparency = 0.7
	TieuDeBong.Parent = KhungLoi

	local NhanNoiDung = Instance.new("TextLabel")
	NhanNoiDung.Text = tostring(NoiDung)
	NhanNoiDung.Size = UDim2.new(1, -40, 0, 60)
	NhanNoiDung.Position = UDim2.new(0, 20, 0, isMobile and 40 or 60)
	NhanNoiDung.BackgroundTransparency = 1
	NhanNoiDung.TextColor3 = Color3.fromRGB(240, 240, 240)
	NhanNoiDung.Font = Enum.Font.Code
	NhanNoiDung.TextSize = descSize
	NhanNoiDung.TextWrapped = true
	NhanNoiDung.TextXAlignment = Enum.TextXAlignment.Left
	NhanNoiDung.Parent = KhungLoi

	local NutX = Instance.new("TextButton")
	NutX.Text = "[ ĐÓNG ]"
	NutX.Size = UDim2.new(0, isMobile and 80 or 100, 0, isMobile and 28 or 32)
	NutX.Position = UDim2.new(1, -15, 1, -15)
	NutX.AnchorPoint = Vector2.new(1, 1)
	NutX.BackgroundColor3 = CONFIG.MAU_LOI
	NutX.TextColor3 = Color3.new(0,0,0)
	NutX.Font = Enum.Font.GothamBold
	NutX.TextSize = isMobile and 12 or 14
	NutX.Parent = KhungLoi
	Instance.new("UICorner", NutX).CornerRadius = UDim.new(0, 4)

	local DangChay = true
	local FolderGlitch = Instance.new("Folder")
	FolderGlitch.Name = "ScreenGlitches"
	FolderGlitch.Parent = LopNen

	task.spawn(function()
		local ScaleEffect = Instance.new("UIScale")
		ScaleEffect.Parent = KhungLoi
		for i = 1, 8 do
			ScaleEffect.Scale = math.random(80, 130) / 100
			KhungLoi.Rotation = math.random(-15, 15)
			KhungLoi.Position = UDim2.new(0.5, math.random(-50,50), 0.5, math.random(-50,50))
			Stroke.Thickness = math.random(1, 6)
			task.wait(0.03)
		end
		ScaleEffect.Scale = 1
		KhungLoi.Rotation = 0
		KhungLoi.Position = UDim2.new(0.5, 0, 0.5, 0)
		Stroke.Thickness = 2

		while DangChay and KhungLoi.Parent do
			for i = 1, math.random(2, 6) do
				local Roll = math.random()
				local TextLen
				if Roll > 0.85 then TextLen = math.random(13, 15)
				elseif Roll > 0.55 then TextLen = math.random(10, 12)
				else TextLen = math.random(6, 9) end

				local GlitchText = Instance.new("TextLabel")
				GlitchText.Size = UDim2.new(0, math.random(100, 300), 0, 50)
				GlitchText.Position = UDim2.new(math.random(-10, 110)/100, 0, math.random(-10, 110)/100, 0)
				GlitchText.Text = RandomChar(TextLen)

				local randomColor = math.random()
				if randomColor > 0.7 then GlitchText.TextColor3 = CONFIG.MAU_LOI
				elseif randomColor > 0.4 then GlitchText.TextColor3 = Color3.new(1, 1, 1)
				else GlitchText.TextColor3 = Color3.fromRGB(100, 100, 100) end

				GlitchText.BackgroundTransparency = 1
				GlitchText.Font = math.random() > 0.5 and Enum.Font.Creepster or Enum.Font.Code
				GlitchText.TextSize = math.random(12, 48)
				GlitchText.Rotation = math.random(-45, 45)
				GlitchText.TextTransparency = math.random(0, 5) / 10
				GlitchText.Parent = FolderGlitch

				local LifeTime = math.random(5, 20) / 10
				TweenService:Create(GlitchText, TweenInfo.new(LifeTime), {TextTransparency = 1, Rotation = math.random(-90, 90)}):Play()
				Debris:AddItem(GlitchText, LifeTime)
			end

			if math.random() > 0.8 then
				KhungLoi.Position = UDim2.new(0.5, math.random(-5,5), 0.5, math.random(-5,5))
			else
				KhungLoi.Position = UDim2.new(0.5, 0, 0.5, 0)
			end

			if math.random() > 0.6 then
				TieuDeBong.Position = UDim2.new(0, 20 + math.random(-4, 4), 0, 15 + math.random(-2,2))
				TieuDeBong.Visible = true
			else
				TieuDeBong.Visible = false
			end
			task.wait(0.05)
		end
	end)

	NutX.MouseButton1Click:Connect(function()
		if not DangChay then return end
		DangChay = false
		KhungLoiHienTai = nil
		FolderGlitch:ClearAllChildren()
		FolderGlitch:Destroy()
		TweenService:Create(KhungLoi, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0, width, 0, 2), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		NhanTieuDe.TextTransparency = 1
		TieuDeBong.TextTransparency = 1
		NhanNoiDung.TextTransparency = 1
		NutX.TextTransparency = 1
		NutX.BackgroundTransparency = 1
		Scanlines.ImageTransparency = 1
		Stroke.Transparency = 1
		task.wait(0.1)

		local Buoc2 = TweenService:Create(KhungLoi, TweenInfo.new(0.1), {Size = UDim2.new(0, 0, 0, 0)})
		Buoc2:Play()
		Buoc2.Completed:Wait()
		TweenService:Create(LopNen, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
		task.wait(0.2)
		LopNen:Destroy()
	end)
end

function Guithongbao.thongbaoxacnhan(TieuDe, NoiDung, CallbackDongY, CallbackHuy)
	if KhungXacNhanHienTai or KhungLoiHienTai then return end

	local isMobile = KiemTraMobile()
	local width = isMobile and 280 or 380
	local height = isMobile and 130 or 160
	local titleSize = isMobile and 16 or 20
	local descSize = isMobile and 12 or 14

	local LopNen = Instance.new("Frame")
	LopNen.Size = UDim2.new(1, 0, 1, 0)
	LopNen.BackgroundColor3 = Color3.new(0, 0, 0)
	LopNen.BackgroundTransparency = 1
	LopNen.Parent = GuiChinh
	TweenService:Create(LopNen, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
	KhungXacNhanHienTai = LopNen

	local KhungXN = Instance.new("Frame")
	KhungXN.Size = UDim2.new(0, width, 0, height)
	KhungXN.Position = UDim2.new(0.5, 0, 0.45, 0)
	KhungXN.AnchorPoint = Vector2.new(0.5, 0.5)
	KhungXN.BackgroundColor3 = CONFIG.MAU_NEN
	KhungXN.Parent = LopNen
	Instance.new("UICorner", KhungXN).CornerRadius = UDim.new(0, 8)

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = CONFIG.MAU_XAC_NHAN
	Stroke.Thickness = 2
	Stroke.Parent = KhungXN

	local NhanTieuDe = Instance.new("TextLabel")
	NhanTieuDe.Text = string.upper(tostring(TieuDe))
	NhanTieuDe.Size = UDim2.new(1, -40, 0, 30)
	NhanTieuDe.Position = UDim2.new(0, 20, 0, 10)
	NhanTieuDe.BackgroundTransparency = 1
	NhanTieuDe.TextColor3 = CONFIG.MAU_XAC_NHAN
	NhanTieuDe.Font = Enum.Font.GothamBlack
	NhanTieuDe.TextSize = titleSize
	NhanTieuDe.TextXAlignment = Enum.TextXAlignment.Center
	NhanTieuDe.Parent = KhungXN

	local NhanNoiDung = Instance.new("TextLabel")
	NhanNoiDung.Text = tostring(NoiDung)
	NhanNoiDung.Size = UDim2.new(1, -40, 0, 50)
	NhanNoiDung.Position = UDim2.new(0, 20, 0, 40)
	NhanNoiDung.BackgroundTransparency = 1
	NhanNoiDung.TextColor3 = CONFIG.MAU_CHU
	NhanNoiDung.Font = Enum.Font.GothamMedium
	NhanNoiDung.TextSize = descSize
	NhanNoiDung.TextWrapped = true
	NhanNoiDung.TextXAlignment = Enum.TextXAlignment.Center
	NhanNoiDung.Parent = KhungXN

	local KhungChuaNut = Instance.new("Frame")
	KhungChuaNut.Size = UDim2.new(1, -40, 0, 35)
	KhungChuaNut.Position = UDim2.new(0, 20, 1, -45)
	KhungChuaNut.BackgroundTransparency = 1
	KhungChuaNut.Parent = KhungXN

	local NutHuy = Instance.new("TextButton")
	NutHuy.Text = "No"
	NutHuy.Size = UDim2.new(0.48, 0, 1, 0)
	NutHuy.Position = UDim2.new(0, 0, 0, 0)
	NutHuy.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	NutHuy.TextColor3 = Color3.new(1, 1, 1)
	NutHuy.Font = Enum.Font.GothamBold
	NutHuy.TextSize = isMobile and 12 or 14
	NutHuy.Parent = KhungChuaNut
	Instance.new("UICorner", NutHuy).CornerRadius = UDim.new(0, 4)

	local NutDongY = Instance.new("TextButton")
	NutDongY.Text = "Yes"
	NutDongY.Size = UDim2.new(0.48, 0, 1, 0)
	NutDongY.Position = UDim2.new(1, 0, 0, 0)
	NutDongY.AnchorPoint = Vector2.new(1, 0)
	NutDongY.BackgroundColor3 = CONFIG.MAU_XAC_NHAN
	NutDongY.TextColor3 = Color3.new(0, 0, 0)
	NutDongY.Font = Enum.Font.GothamBold
	NutDongY.TextSize = isMobile and 12 or 14
	NutDongY.Parent = KhungChuaNut
	Instance.new("UICorner", NutDongY).CornerRadius = UDim.new(0, 4)

	local ScaleEffect = Instance.new("UIScale")
	ScaleEffect.Scale = 0.8
	ScaleEffect.Parent = KhungXN

	TweenService:Create(ScaleEffect, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	TweenService:Create(KhungXN, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()

	local function DongThongBao()
		KhungXacNhanHienTai = nil
		TweenService:Create(ScaleEffect, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.8}):Play()
		TweenService:Create(KhungXN, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
		TweenService:Create(LopNen, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
		Stroke:Destroy() NhanTieuDe:Destroy() NhanNoiDung:Destroy() KhungChuaNut:Destroy()
		task.wait(0.15)
		LopNen:Destroy()
	end

	NutHuy.MouseButton1Click:Connect(function()
		DongThongBao()
		if CallbackHuy then CallbackHuy() end
	end)

	NutDongY.MouseButton1Click:Connect(function()
		DongThongBao()
		if CallbackDongY then CallbackDongY() end
	end)
end

return Guithongbao
