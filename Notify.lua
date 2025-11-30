local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local NguoiChoi = Players.LocalPlayer
local GuiNguoiChoi = NguoiChoi:WaitForChild("PlayerGui")

local CONFIG = {
	SO_LUONG_MAX = 3,
	KHOANG_CACH = 12,
	CHIEU_CAO_TB = 70,
	MAU_CHU_DAO = Color3.fromRGB(0, 255, 170),
	MAU_LOI = Color3.fromRGB(255, 60, 60),
	MAU_NEN = Color3.fromRGB(15, 15, 20),
}

local GuiChinh = Instance.new("ScreenGui")
GuiChinh.Name = "ChaosSystem_Final"
GuiChinh.ResetOnSpawn = false
GuiChinh.IgnoreGuiInset = true
GuiChinh.DisplayOrder = 1000
GuiChinh.Parent = GuiNguoiChoi

local ThongBaoDangHien = {}
local Guithongbao = {}

local function RandomChar(len)
	local text = ""
	local chars = {"@","#","%","&","*","!","?","<",">","0","1","X","Z","E","R","O","N","U","L"}
	for i = 1, len do
		text = text .. chars[math.random(1, #chars)]
	end
	return text
end

local function CapNhatViTri()
	for i, Muc in ipairs(ThongBaoDangHien) do
		local DoLech = (i - 1) * (CONFIG.CHIEU_CAO_TB + CONFIG.KHOANG_CACH)
		local ViTriDich = UDim2.new(1, -20, 1, -50 - DoLech)
		TweenService:Create(Muc.Khung, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = ViTriDich}):Play()
	end
end

function Guithongbao.thongbao(TieuDe, NoiDung, ThoiGian)
	while #ThongBaoDangHien >= CONFIG.SO_LUONG_MAX do
		local MucCu = table.remove(ThongBaoDangHien, 1)
		if MucCu and MucCu.Khung then MucCu.Khung:Destroy() end
	end

	local KhungChua = Instance.new("Frame")
	KhungChua.Name = "Notify"
	KhungChua.Size = UDim2.new(0, 260, 0, CONFIG.CHIEU_CAO_TB)
	KhungChua.Position = UDim2.new(1, 300, 1, -50)
	KhungChua.AnchorPoint = Vector2.new(1, 1)
	KhungChua.BackgroundColor3 = CONFIG.MAU_NEN
	KhungChua.BackgroundTransparency = 0.1
	KhungChua.Parent = GuiChinh
	Instance.new("UICorner", KhungChua).CornerRadius = UDim.new(0, 8)

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = CONFIG.MAU_CHU_DAO
	Stroke.Thickness = 1.5
	Stroke.Transparency = 0.6
	Stroke.Parent = KhungChua

	local NhanTieuDe = Instance.new("TextLabel")
	NhanTieuDe.Text = string.upper(TieuDe)
	NhanTieuDe.Size = UDim2.new(1, -20, 0, 20)
	NhanTieuDe.Position = UDim2.new(0, 12, 0, 8)
	NhanTieuDe.BackgroundTransparency = 1
	NhanTieuDe.TextColor3 = CONFIG.MAU_CHU_DAO
	NhanTieuDe.Font = Enum.Font.GothamBlack
	NhanTieuDe.TextSize = 14
	NhanTieuDe.TextXAlignment = Enum.TextXAlignment.Left
	NhanTieuDe.Parent = KhungChua

	local NhanNoiDung = Instance.new("TextLabel")
	NhanNoiDung.Text = NoiDung
	NhanNoiDung.Size = UDim2.new(1, -20, 0, 30)
	NhanNoiDung.Position = UDim2.new(0, 12, 0, 28)
	NhanNoiDung.BackgroundTransparency = 1
	NhanNoiDung.TextColor3 = Color3.fromRGB(220, 220, 220)
	NhanNoiDung.Font = Enum.Font.GothamMedium
	NhanNoiDung.TextSize = 12
	NhanNoiDung.TextWrapped = true
	NhanNoiDung.TextXAlignment = Enum.TextXAlignment.Left
	NhanNoiDung.Parent = KhungChua

	local NenThoiGian = Instance.new("Frame")
	NenThoiGian.Size = UDim2.new(0.95, 0, 0, 3)
	NenThoiGian.Position = UDim2.new(0.5, 0, 1, -6)
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

	local DuLieu = { Khung = KhungChua }
	table.insert(ThongBaoDangHien, DuLieu)
	CapNhatViTri()

	task.spawn(function()
		TweenService:Create(KhungChua, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -20, 1, -50 - ((#ThongBaoDangHien - 1) * (CONFIG.CHIEU_CAO_TB + CONFIG.KHOANG_CACH)))
		}):Play()

		local TweenTime = TweenService:Create(ThanhChay, TweenInfo.new(ThoiGian, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
		TweenTime:Play()
		TweenTime.Completed:Wait()

		local TweenRa = TweenService:Create(KhungChua, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = KhungChua.Position + UDim2.new(0, 150, 0, 0),
			BackgroundTransparency = 1
		})
		TweenService:Create(NhanTieuDe, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		TweenService:Create(NhanNoiDung, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()

		TweenRa:Play()
		TweenRa.Completed:Wait()

		for i, v in ipairs(ThongBaoDangHien) do
			if v == DuLieu then table.remove(ThongBaoDangHien, i) break end
		end
		CapNhatViTri()
		KhungChua:Destroy()
	end)
end

function Guithongbao.thongbaoloi(TieuDe, NoiDung)
	local LopNen = Instance.new("Frame")
	LopNen.Size = UDim2.new(1, 0, 1, 0)
	LopNen.BackgroundColor3 = Color3.new(0,0,0)
	LopNen.BackgroundTransparency = 1
	LopNen.ZIndex = 10
	LopNen.Parent = GuiChinh
	TweenService:Create(LopNen, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()

	local KhungLoi = Instance.new("Frame")
	KhungLoi.Size = UDim2.new(0, 420, 0, 160)
	KhungLoi.Position = UDim2.new(0.5, 0, 0.5, 0)
	KhungLoi.AnchorPoint = Vector2.new(0.5, 0.5)
	KhungLoi.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	KhungLoi.BorderSizePixel = 0
	KhungLoi.ClipsDescendants = true
	KhungLoi.ZIndex = 20
	KhungLoi.Parent = LopNen

	local Scanlines = Instance.new("ImageLabel")
	Scanlines.Size = UDim2.new(1, 0, 1, 0)
	Scanlines.BackgroundTransparency = 1
	Scanlines.Image = "rbxassetid://7240608779"
	Scanlines.ImageTransparency = 0.9
	Scanlines.ImageColor3 = CONFIG.MAU_LOI
	Scanlines.ScaleType = Enum.ScaleType.Tile
	Scanlines.TileSize = UDim2.new(0, 20, 0, 20)
	Scanlines.ZIndex = 21
	Scanlines.Parent = KhungLoi

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = CONFIG.MAU_LOI
	Stroke.Thickness = 2
	Stroke.Parent = KhungLoi

	local NhanTieuDe = Instance.new("TextLabel")
	NhanTieuDe.Text = string.upper(TieuDe)
	NhanTieuDe.Size = UDim2.new(1, -40, 0, 40)
	NhanTieuDe.Position = UDim2.new(0, 20, 0, 15)
	NhanTieuDe.BackgroundTransparency = 1
	NhanTieuDe.TextColor3 = CONFIG.MAU_LOI
	NhanTieuDe.Font = Enum.Font.GothamBlack
	NhanTieuDe.TextSize = 24
	NhanTieuDe.TextXAlignment = Enum.TextXAlignment.Left
	NhanTieuDe.ZIndex = 25
	NhanTieuDe.Parent = KhungLoi

	local TieuDeBong = NhanTieuDe:Clone()
	TieuDeBong.TextColor3 = Color3.fromRGB(0, 255, 255)
	TieuDeBong.TextTransparency = 0.7
	TieuDeBong.ZIndex = 24
	TieuDeBong.Parent = KhungLoi

	local NhanNoiDung = Instance.new("TextLabel")
	NhanNoiDung.Text = NoiDung
	NhanNoiDung.Size = UDim2.new(1, -40, 0, 60)
	NhanNoiDung.Position = UDim2.new(0, 20, 0, 60)
	NhanNoiDung.BackgroundTransparency = 1
	NhanNoiDung.TextColor3 = Color3.fromRGB(240, 240, 240)
	NhanNoiDung.Font = Enum.Font.Code
	NhanNoiDung.TextSize = 15
	NhanNoiDung.TextWrapped = true
	NhanNoiDung.TextXAlignment = Enum.TextXAlignment.Left
	NhanNoiDung.ZIndex = 25
	NhanNoiDung.Parent = KhungLoi

	local NutX = Instance.new("TextButton")
	NutX.Text = "[ ĐÓNG ]"
	NutX.Size = UDim2.new(0, 100, 0, 32)
	NutX.Position = UDim2.new(1, -15, 1, -15)
	NutX.AnchorPoint = Vector2.new(1, 1)
	NutX.BackgroundColor3 = CONFIG.MAU_LOI
	NutX.TextColor3 = Color3.new(0,0,0)
	NutX.Font = Enum.Font.GothamBold
	NutX.TextSize = 14
	NutX.ZIndex = 30
	NutX.Parent = KhungLoi
	Instance.new("UICorner", NutX).CornerRadius = UDim.new(0, 4)

	local DangChay = true
	local FolderGlitch = Instance.new("Folder")
	FolderGlitch.Name = "ScreenGlitches"
	FolderGlitch.Parent = GuiChinh

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

				if Roll > 0.85 then
					TextLen = math.random(13, 15)
				elseif Roll > 0.55 then
					TextLen = math.random(10, 12)
				else
					TextLen = math.random(6, 9)
				end

				local GlitchText = Instance.new("TextLabel")
				GlitchText.Size = UDim2.new(0, math.random(100, 300), 0, 50)
				GlitchText.Position = UDim2.new(math.random(-10, 110)/100, 0, math.random(-10, 110)/100, 0)
				GlitchText.Text = RandomChar(TextLen)

				local randomColor = math.random()
				if randomColor > 0.7 then
					GlitchText.TextColor3 = CONFIG.MAU_LOI
				elseif randomColor > 0.4 then
					GlitchText.TextColor3 = Color3.new(1, 1, 1)
				else
					GlitchText.TextColor3 = Color3.fromRGB(100, 100, 100)
				end

				GlitchText.BackgroundTransparency = 1
				GlitchText.Font = math.random() > 0.5 and Enum.Font.Creepster or Enum.Font.Code
				GlitchText.TextSize = math.random(12, 48)
				GlitchText.Rotation = math.random(-45, 45)
				GlitchText.ZIndex = math.random(1, 30)
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

	local function DongThongBao()
		if not DangChay then return end
		DangChay = false
		FolderGlitch:ClearAllChildren()
		FolderGlitch:Destroy()

		TweenService:Create(KhungLoi, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 420, 0, 2), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
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
	end

	NutX.MouseButton1Click:Connect(DongThongBao)
end

return Guithongbao
