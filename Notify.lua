local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local NguoiChoi = Players.LocalPlayer
local GuiNguoiChoi = NguoiChoi:WaitForChild("PlayerGui")

local SO_LUONG_TOI_DA = 3
local CHIEU_CAO_TB = 80
local KHOANG_CACH = 10

local GuiChinh = Instance.new("ScreenGui")
GuiChinh.Name = "HeThongThongBao"
GuiChinh.ResetOnSpawn = false
GuiChinh.ZIndexBehavior = Enum.ZIndexBehavior.Global
GuiChinh.Parent = GuiNguoiChoi

local ThongBaoDangHien = {} 

local function CapNhatViTri()
	for i, Muc in ipairs(ThongBaoDangHien) do
		local DoLech = (i - 1) * (CHIEU_CAO_TB + KHOANG_CACH)
		local ViTriDich = UDim2.new(1, -20, 1, -20 - DoLech)
		TweenService:Create(Muc.Khung, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = ViTriDich}):Play()
	end
end

local function TaoThongBao(TieuDe, NoiDung, ThoiGian)
	if #ThongBaoDangHien >= SO_LUONG_TOI_DA then
		local ThongBaoCu = ThongBaoDangHien[1]
		if ThongBaoCu and not ThongBaoCu.DangDong then
			ThongBaoCu.DongNhanh()
		end
		repeat task.wait() until #ThongBaoDangHien < SO_LUONG_TOI_DA
	end

	local SoLuongHienTai = #ThongBaoDangHien
	local DoLech = SoLuongHienTai * (CHIEU_CAO_TB + KHOANG_CACH)

	local ViTriAn = UDim2.new(1, 250, 1, -20 - DoLech)
	local ViTriHien = UDim2.new(1, -20, 1, -20 - DoLech)

	local MauXanh = Color3.fromRGB(85, 255, 127)
	local MauVang = Color3.fromRGB(255, 255, 85)
	local MauDo = Color3.fromRGB(255, 85, 85)

	local KhungChua = Instance.new("Frame")
	KhungChua.Name = "NoiDung"
	KhungChua.Size = UDim2.new(0, 170, 0, CHIEU_CAO_TB - 10)
	KhungChua.Position = ViTriAn
	KhungChua.AnchorPoint = Vector2.new(1, 1)
	KhungChua.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	KhungChua.BorderSizePixel = 0
	KhungChua.Parent = GuiChinh

	local BoGoc = Instance.new("UICorner")
	BoGoc.CornerRadius = UDim.new(0, 12)
	BoGoc.Parent = KhungChua

	local VienKhung = Instance.new("UIStroke")
	VienKhung.Color = MauXanh
	VienKhung.Thickness = 2
	VienKhung.Transparency = 0.8
	VienKhung.Parent = KhungChua

	local NhanTieuDe = Instance.new("TextLabel")
	NhanTieuDe.Text = TieuDe
	NhanTieuDe.Size = UDim2.new(0.9, 0, 0.25, 0)
	NhanTieuDe.Position = UDim2.new(0.5, 0, 0.2, 0)
	NhanTieuDe.AnchorPoint = Vector2.new(0.5, 0.5)
	NhanTieuDe.BackgroundTransparency = 1
	NhanTieuDe.TextColor3 = Color3.fromRGB(255, 255, 255)
	NhanTieuDe.Font = Enum.Font.GothamBold
	NhanTieuDe.TextScaled = true
	NhanTieuDe.Parent = KhungChua
	Instance.new("UITextSizeConstraint", NhanTieuDe).MaxTextSize = 14

	local NhanNoiDung = Instance.new("TextLabel")
	NhanNoiDung.Text = NoiDung
	NhanNoiDung.TextXAlignment = Enum.TextXAlignment.Left
	NhanNoiDung.Size = UDim2.new(0.9, 0, 0.4, 0)
	NhanNoiDung.Position = UDim2.new(0.5, 0, 0.55, 0)
	NhanNoiDung.AnchorPoint = Vector2.new(0.5, 0.5)
	NhanNoiDung.BackgroundTransparency = 1
	NhanNoiDung.TextColor3 = Color3.fromRGB(220, 220, 220)
	NhanNoiDung.Font = Enum.Font.Gotham
	NhanNoiDung.TextScaled = true
	NhanNoiDung.Parent = KhungChua
	Instance.new("UITextSizeConstraint", NhanNoiDung).MaxTextSize = 14

	local NenThanhThoiGian = Instance.new("Frame")
	NenThanhThoiGian.Size = UDim2.new(0.9, 0, 0.05, 0)
	NenThanhThoiGian.Position = UDim2.new(0.5, 0, 0.88, 0)
	NenThanhThoiGian.AnchorPoint = Vector2.new(0.5, 0.5)
	NenThanhThoiGian.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	NenThanhThoiGian.Parent = KhungChua
	Instance.new("UICorner", NenThanhThoiGian).CornerRadius = UDim.new(0, 6)

	local ThanhThoiGian = Instance.new("Frame")
	ThanhThoiGian.Size = UDim2.new(1, 0, 1, 0)
	ThanhThoiGian.BackgroundColor3 = MauXanh
	ThanhThoiGian.Parent = NenThanhThoiGian
	Instance.new("UICorner", ThanhThoiGian).CornerRadius = UDim.new(0, 6)

	local DuLieuTB = {
		Khung = KhungChua,
		DangDong = false,
		DongNhanh = nil
	}
	table.insert(ThongBaoDangHien, DuLieuTB)

	task.spawn(function()
		local HieuUngVao = TweenService:Create(KhungChua, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = ViTriHien})
		HieuUngVao:Play()
		HieuUngVao.Completed:Wait()

		local HieuUngThoiGian = TweenService:Create(ThanhThoiGian, TweenInfo.new(ThoiGian, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})

		local GiaTriMau = Instance.new("Color3Value")
		GiaTriMau.Value = MauXanh
		GiaTriMau.Changed:Connect(function(v)
			VienKhung.Color = v
			ThanhThoiGian.BackgroundColor3 = v
		end)

		local NuaThoiGian = ThoiGian / 2
		local DoiMau1 = TweenService:Create(GiaTriMau, TweenInfo.new(NuaThoiGian), {Value = MauVang})
		local DoiMau2 = TweenService:Create(GiaTriMau, TweenInfo.new(NuaThoiGian), {Value = MauDo})

		DoiMau1:Play()
		DoiMau1.Completed:Connect(function() if not DuLieuTB.DangDong then DoiMau2:Play() end end)
		HieuUngThoiGian:Play()

		DuLieuTB.DongNhanh = function()
			if not DuLieuTB.DangDong then
				DuLieuTB.DangDong = true
				HieuUngThoiGian:Cancel()
				DoiMau1:Cancel()
				DoiMau2:Cancel()
				TweenService:Create(ThanhThoiGian, TweenInfo.new(0.1), {Size = UDim2.new(0,0,1,0)}):Play()
				task.wait(0.15)
			end
		end

		if not DuLieuTB.DangDong then
			HieuUngThoiGian.Completed:Wait()
		end
		DuLieuTB.DangDong = true

		for i, v in ipairs(ThongBaoDangHien) do
			if v == DuLieuTB then
				table.remove(ThongBaoDangHien, i)
				break
			end
		end
		CapNhatViTri()

		local ViTriRa = UDim2.new(1, 250, KhungChua.Position.Y.Scale, KhungChua.Position.Y.Offset)
		local HieuUngRa = TweenService:Create(KhungChua, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = ViTriRa})
		HieuUngRa:Play()
		HieuUngRa.Completed:Wait()

		KhungChua:Destroy()
		GiaTriMau:Destroy()
	end)
end

return TaoThongBao
