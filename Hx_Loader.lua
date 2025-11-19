local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local NguoiChoi = Players.LocalPlayer
local PlayerGui = NguoiChoi:WaitForChild("PlayerGui")
local PlayerScripts = NguoiChoi:WaitForChild("PlayerScripts")
local Camera = Workspace.CurrentCamera

local HoatAnh = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Animation.lua"))()
local ThongBao = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Notify.lua"))()

_G.DaKichHoat = _G.DaKichHoat or {}

local DanhSachKichBan = {
	{ Ten = "Transform", Link = "https://raw.githubusercontent.com/9311-nex4/Hx/main/Transform/main.lua" },
	{ Ten = "Example 2", Link = "" },
	{ Ten = "Example 3", Link = "" },
	{ Ten = "Example 4", Link = "" },
	{ Ten = "Example 5", Link = "" },
}

local CauHinh = {
	Mau = {
		Nen = Color3.fromRGB(18, 18, 18),
		NenList = Color3.fromRGB(35, 35, 35),
		Nut = Color3.fromRGB(60, 60, 60),
		NutLuot = Color3.fromRGB(90, 90, 90),
		NutDong = Color3.fromRGB(80, 80, 80),
		NutDongLuot = Color3.fromRGB(200, 0, 0),
		Chu = Color3.fromRGB(240, 240, 240),
		Vien = Color3.fromRGB(255, 255, 255)
	},
	KichThuoc = {
		Cao = 38,
		Cach = 6,
		IconLon = UDim2.new(0, 80, 0, 80),
		IconNho = UDim2.new(0, 35, 0, 35),
		NutDong = 30
	}
}

local function TaoGiaoDien()
	if PlayerGui:FindFirstChild("HxInterface") then PlayerGui.HxInterface:Destroy() end

	local DangDong = false
	local ManHinhGui = Instance.new("ScreenGui")
	ManHinhGui.Name = "HxInterface"
	ManHinhGui.ResetOnSpawn = false
	ManHinhGui.Parent = PlayerGui

	local KiemTraDienThoai = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
	local ChieuRong = KiemTraDienThoai and 380 or 340
	local TyLeChieuCao = 0.45

	local SoLuong = #DanhSachKichBan
	local ChieuCaoList = (SoLuong * (CauHinh.KichThuoc.Cao + CauHinh.KichThuoc.Cach))
	local TongCao = 70 + ChieuCaoList + 20
	local MaxCao = Camera.ViewportSize.Y * TyLeChieuCao

	if TongCao > MaxCao then TongCao = MaxCao end

	local KhungChinh = Instance.new("Frame")
	KhungChinh.Name = "KhungChinh"
	KhungChinh.Size = CauHinh.KichThuoc.IconLon
	KhungChinh.Position = UDim2.new(0.5, 0, 0.5, 0)
	KhungChinh.AnchorPoint = Vector2.new(0.5, 0.5)
	KhungChinh.BackgroundColor3 = CauHinh.Mau.Nen
	KhungChinh.BackgroundTransparency = 1
	KhungChinh.ClipsDescendants = false
	KhungChinh.Parent = ManHinhGui
	Instance.new("UICorner", KhungChinh).CornerRadius = UDim.new(0, 10)

	local Icon = Instance.new("ImageLabel")
	Icon.Size = UDim2.fromOffset(0, 0)
	Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
	Icon.AnchorPoint = Vector2.new(0.5, 0.5)
	Icon.Image = "rbxassetid://117118515787811"
	Icon.BackgroundTransparency = 0.6
	Icon.BackgroundColor3 = Color3.new(0, 0, 0)
	Icon.ZIndex = 100
	Icon.Parent = KhungChinh
	Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 12)

	local NoiDung = Instance.new("Frame")
	NoiDung.Size = UDim2.fromScale(1, 1)
	NoiDung.BackgroundTransparency = 1
	NoiDung.Parent = KhungChinh

	local TieuDe = Instance.new("TextLabel")
	TieuDe.Text = "Hx Script"
	TieuDe.Size = UDim2.new(1, -80, 0, 40)
	TieuDe.Position = UDim2.new(0, 50, 0, 5)
	TieuDe.BackgroundTransparency = 1
	TieuDe.TextColor3 = CauHinh.Mau.Chu
	TieuDe.Font = Enum.Font.GothamBold
	TieuDe.TextSize = 20
	TieuDe.TextXAlignment = Enum.TextXAlignment.Left
	TieuDe.TextTransparency = 1
	TieuDe.Parent = NoiDung

	local NutDong = Instance.new("TextButton")
	NutDong.Size = UDim2.fromOffset(CauHinh.KichThuoc.NutDong, CauHinh.KichThuoc.NutDong)
	NutDong.Position = UDim2.new(1, -25, 0, 25)
	NutDong.AnchorPoint = Vector2.new(0.5, 0.5)
	NutDong.Text = "X"
	NutDong.TextSize = 18
	NutDong.Font = Enum.Font.GothamBlack
	NutDong.BackgroundColor3 = CauHinh.Mau.NutDong
	NutDong.TextColor3 = CauHinh.Mau.Chu
	NutDong.BackgroundTransparency = 1
	NutDong.TextTransparency = 1
	NutDong.Parent = KhungChinh
	Instance.new("UICorner", NutDong).CornerRadius = UDim.new(0, 6)

	local VienNutDong = Instance.new("UIStroke", NutDong)
	VienNutDong.Color = CauHinh.Mau.Vien
	VienNutDong.Transparency = 1
	VienNutDong.Thickness = 1.5
	VienNutDong.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local KhungList = Instance.new("ScrollingFrame")
	KhungList.Size = UDim2.new(0.9, 0, 1, -65)
	KhungList.Position = UDim2.new(0.5, 0, 0, 55)
	KhungList.AnchorPoint = Vector2.new(0.5, 0)
	KhungList.BackgroundTransparency = 0.8
	KhungList.BackgroundColor3 = CauHinh.Mau.NenList
	KhungList.ScrollBarThickness = 2
	KhungList.BorderSizePixel = 0
	KhungList.Parent = NoiDung
	Instance.new("UICorner", KhungList).CornerRadius = UDim.new(0, 6)

	local Layout = Instance.new("UIListLayout", KhungList)
	Layout.Padding = UDim.new(0, CauHinh.KichThuoc.Cach)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.SortOrder = Enum.SortOrder.LayoutOrder

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		KhungList.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
	end)

	local DoiTuongUI = {
		ScreenGui = ManHinhGui, 
		Khung = KhungChinh, 
		Icon = Icon,
		TieuDe = TieuDe, 
		NutDong = NutDong, 
		VienNutDong = VienNutDong, 
		KhungNoiDung = KhungList
	}

	local CauHinhHieuUng = {
		IconDau = CauHinh.KichThuoc.IconLon,
		IconCuoi = CauHinh.KichThuoc.IconNho,
		ViTriIconDau = UDim2.new(0.5, 0, 0.5, 0),
		ViTriIconCuoi = UDim2.new(0, 27, 0, 27),
		KhungDau = CauHinh.KichThuoc.IconLon,
		KhungCuoi = UDim2.new(0, ChieuRong, 0, TongCao),
		KichThuocNutDongNay = UDim2.new(0, 42, 0, 42),
		DoTrongSuotKhung = 0.15
	}
	
	for i, DuLieu in ipairs(DanhSachKichBan) do
		local Nut = Instance.new("TextButton")
		Nut.Size = UDim2.new(0.9, 0, 0, CauHinh.KichThuoc.Cao)
		Nut.Text = DuLieu.Ten
		Nut.BackgroundColor3 = CauHinh.Mau.Nut
		Nut.TextColor3 = CauHinh.Mau.Chu
		Nut.Font = Enum.Font.GothamMedium
		Nut.TextSize = 16
		Nut.BackgroundTransparency = 0
		Nut.TextTransparency = 0
		Nut.LayoutOrder = i
		Nut.Parent = KhungList
		Instance.new("UICorner", Nut).CornerRadius = UDim.new(0, 6)

		local ThuocTinhThuong = {
			Size = UDim2.new(0.9, 0, 0, CauHinh.KichThuoc.Cao),
			BackgroundColor3 = CauHinh.Mau.Nut,
			TextSize = 16
		}
		local ThuocTinhLuot = {
			Size = KiemTraDienThoai and UDim2.new(0.9, 0, 0, CauHinh.KichThuoc.Cao) or UDim2.new(0.92, 0, 0, CauHinh.KichThuoc.Cao + 4),
			BackgroundColor3 = CauHinh.Mau.NutLuot,
			TextSize = 18
		}

		Nut.MouseEnter:Connect(function() HoatAnh.LuotChuot(Nut, true, ThuocTinhLuot, ThuocTinhThuong) end)
		Nut.MouseLeave:Connect(function() HoatAnh.LuotChuot(Nut, false, ThuocTinhLuot, ThuocTinhThuong) end)

		Nut.MouseButton1Click:Connect(function()
			HoatAnh.NhanChuot(Nut)

			if _G.DaKichHoat[DuLieu.Ten] then
				ThongBao("Hx Script", "Đã bật chức năng này rồi!", 2)
				return
			end

			if DuLieu.Link ~= "" then
				_G.DaKichHoat[DuLieu.Ten] = true
				ThongBao("Hx Script", "Đang tải: " .. DuLieu.Ten, 2)

				task.spawn(function()
					local ok, err = pcall(function() loadstring(game:HttpGet(DuLieu.Link))() end)
					if not ok then warn(err) ThongBao("Hx Script", "Link hiện tại chưa được cập nhật. Vui lòng chờ!", 3) end
				end)
			else
				ThongBao("Hx Script", "Chưa có script cho nút này. Vui lòng chờ!", 2)
			end
		end)
	end

	HoatAnh.MoGiaoDien(DoiTuongUI, CauHinhHieuUng)
	HoatAnh.KeoTha(KhungChinh, KhungChinh)

	local function DongGiaoDien()
		if DangDong then return end
		DangDong = true
		HoatAnh.DongGiaoDien(DoiTuongUI, CauHinhHieuUng, function()
			ManHinhGui:Destroy()
		end)
	end


	local NutDongThuong = {
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = CauHinh.Mau.NutDong,
		BackgroundTransparency = 0.6,
		TextSize = 18,
		TextColor3 = CauHinh.Mau.Chu
	}
	local NutDongLuot = {
		Size = KiemTraDienThoai and UDim2.fromOffset(30, 30) or UDim2.fromOffset(34, 34),
		BackgroundColor3 = CauHinh.Mau.NutDongLuot,
		BackgroundTransparency = 0,
		TextSize = 22,
		TextColor3 = Color3.new(1,1,1)
	}

	NutDong.MouseEnter:Connect(function()
		if not DangDong then
			HoatAnh.LuotChuot(NutDong, true, NutDongLuot, NutDongThuong)
			TweenService:Create(VienNutDong, TweenInfo.new(0.3), {Transparency = 0.4}):Play()
		end
	end)
	NutDong.MouseLeave:Connect(function()
		if not DangDong then
			HoatAnh.LuotChuot(NutDong, false, NutDongLuot, NutDongThuong)
			TweenService:Create(VienNutDong, TweenInfo.new(0.3), {Transparency = 0.8}):Play()
		end
	end)

	NutDong.MouseButton1Click:Connect(function()
		if not DangDong then DongGiaoDien() end
	end)
end
TaoGiaoDien()
