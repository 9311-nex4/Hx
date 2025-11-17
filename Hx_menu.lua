local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local NguoiChoi = Players.LocalPlayer
local GiaoDienNguoiChoi = NguoiChoi:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local ThuVienHieuUng = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Animation.lua"))()
local ThongBao = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Notify.lua"))()

_G.HxScript_DaKichHoat = _G.HxScript_DaKichHoat or {}

local DuLieuNut = {
	{ Ten = "Transform", Link = "https://raw.githubusercontent.com/9311-nex4/Hx/main/Transform.lua" },
	{ Ten = "Example 2", Link = "" },
	{ Ten = "Example 3", Link = "" },
	{ Ten = "Example 4", Link = "" },
	{ Ten = "Example 5", Link = "" },
}

local CauHinh = {
	MauSac = {
		Nen = Color3.fromRGB(15, 15, 15),
		NenNoiDung = Color3.fromRGB(40, 40, 40),
		NutThuong = Color3.fromRGB(90, 90, 90),
		NutLuot = Color3.fromRGB(125, 125, 125),
		DongThuong = Color3.fromRGB(90, 90, 90),
		DongLuot = Color3.fromRGB(180, 50, 50),
		Chu = Color3.fromRGB(255, 255, 255),
		Vien = Color3.fromRGB(255, 255, 255)
	},
	KichThuoc = {
		IconDau = UDim2.new(0, 80, 0, 80),
		IconCuoi = UDim2.new(0, 35, 0, 35),
		ViTriIconCuoi = UDim2.new(0, 27.5, 0, 27.5),
		ViTriIconDau = UDim2.new(0.5, 0, 0.5, 0),
		KhungDau = UDim2.new(0, 80, 0, 80),
		NutDong = UDim2.new(0, 30, 0, 30),
		NutDongLuot = UDim2.new(0, 35, 0, 35),
		NutDongNhan = UDim2.new(0, 28, 0, 28),
		NutDongPop = UDim2.new(0, 48, 0, 48)
	}
}

local function TaoGiaoDien()
	if GiaoDienNguoiChoi:FindFirstChild("HxInterface") then GiaoDienNguoiChoi.HxInterface:Destroy() end

	local DangDong = false
	local ManHinhGui = Instance.new("ScreenGui")
	ManHinhGui.Name = "HxInterface"
	ManHinhGui.Parent = GiaoDienNguoiChoi
	ManHinhGui.ResetOnSpawn = false

	local SoLuongNut = #DuLieuNut
	local ChieuCaoNut = 45
	local KhoangCach = 8
	local ChieuCaoDau = 60 
	local ChieuCaoDuoi = 20 
	
	local TongChieuCaoCanThiet = ChieuCaoDau + (SoLuongNut * (ChieuCaoNut + KhoangCach)) + ChieuCaoDuoi
	local ChieuCaoToiDa = Camera.ViewportSize.Y * 0.7
	
	if TongChieuCaoCanThiet > ChieuCaoToiDa then
		TongChieuCaoCanThiet = ChieuCaoToiDa
	end

	local ChieuRongKhung = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) and 320 or 360
	local KichThuocCuoi = UDim2.new(0, ChieuRongKhung, 0, TongChieuCaoCanThiet)

	local KhungChinh = Instance.new("Frame")
	KhungChinh.Size = CauHinh.KichThuoc.KhungDau
	KhungChinh.Position = UDim2.new(0.5, 0, 0.5, 0)
	KhungChinh.AnchorPoint = Vector2.new(0.5, 0.5)
	KhungChinh.BackgroundColor3 = CauHinh.MauSac.Nen
	KhungChinh.BackgroundTransparency = 1
	KhungChinh.ClipsDescendants = false
	KhungChinh.Parent = ManHinhGui
	Instance.new("UICorner", KhungChinh).CornerRadius = UDim.new(0, 12)

	local Icon = Instance.new("ImageLabel")
	Icon.Size = UDim2.new(0, 0, 0, 0)
	Icon.Position = CauHinh.KichThuoc.ViTriIconDau
	Icon.AnchorPoint = Vector2.new(0.5, 0.5)
	Icon.Image = "rbxassetid://117118515787811"
	Icon.BackgroundTransparency = 0.6
	Icon.BackgroundColor3 = Color3.new(0, 0, 0)
	Icon.ZIndex = 100
	Icon.Parent = KhungChinh
	Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 12)

	local VungChua = Instance.new("Frame")
	VungChua.Size = UDim2.new(1, 0, 1, 0)
	VungChua.BackgroundTransparency = 1
	VungChua.Parent = KhungChinh

	local TieuDe = Instance.new("TextLabel")
	TieuDe.Text = "Hx Script"
	TieuDe.Size = UDim2.new(1, -80, 0, 40)
	TieuDe.Position = UDim2.new(0, 50, 0, 5)
	TieuDe.BackgroundTransparency = 1
	TieuDe.TextColor3 = CauHinh.MauSac.Chu
	TieuDe.Font = Enum.Font.GothamBold
	TieuDe.TextSize = 22
	TieuDe.TextXAlignment = Enum.TextXAlignment.Left
	TieuDe.TextTransparency = 1
	TieuDe.Parent = VungChua

	local NutDong = Instance.new("TextButton")
	NutDong.Size = CauHinh.KichThuoc.NutDong
	NutDong.Position = UDim2.new(1, -25, 0, 25)
	NutDong.AnchorPoint = Vector2.new(0.5, 0.5)
	NutDong.Text = "X"
	NutDong.Font = Enum.Font.GothamBold
	NutDong.BackgroundColor3 = CauHinh.MauSac.DongThuong
	NutDong.TextColor3 = CauHinh.MauSac.Chu
	NutDong.BackgroundTransparency = 1
	NutDong.TextTransparency = 1
	NutDong.ZIndex = 2
	NutDong.Parent = KhungChinh
	Instance.new("UICorner", NutDong).CornerRadius = UDim.new(0, 8)
	
	local DemNutDong = Instance.new("UIPadding", NutDong)
	local VienNutDong = Instance.new("UIStroke", NutDong)
	VienNutDong.Color = CauHinh.MauSac.Vien
	VienNutDong.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	VienNutDong.Transparency = 1
	VienNutDong.Thickness = 1.5

	local KhungDanhSach = Instance.new("ScrollingFrame")
	KhungDanhSach.Size = UDim2.new(0.8, 0, 1, -70)
	KhungDanhSach.Position = UDim2.new(0, 10, 0, 50)
	KhungDanhSach.BackgroundTransparency = 1
	KhungDanhSach.BackgroundColor3 = CauHinh.MauSac.NenNoiDung
	KhungDanhSach.ScrollBarImageTransparency = 1
	KhungDanhSach.BorderSizePixel = 0
	KhungDanhSach.Parent = VungChua
	Instance.new("UICorner", KhungDanhSach).CornerRadius = UDim.new(0, 8)
	
	local BoCuc = Instance.new("UIListLayout", KhungDanhSach)
	BoCuc.Padding = UDim.new(0, KhoangCach)
	BoCuc.SortOrder = Enum.SortOrder.LayoutOrder
	
	BoCuc:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		KhungDanhSach.CanvasSize = UDim2.new(0, 0, 0, BoCuc.AbsoluteContentSize.Y + 20)
	end)

	local CacDoiTuongUI = {
		ScreenGui = ManHinhGui, Khung = KhungChinh, Icon = Icon,
		TieuDe = TieuDe, NutDong = NutDong, VienNutDong = VienNutDong, DanhSach = KhungDanhSach
	}
	
	local CauHinhHieuUng = {
		IconDau = CauHinh.KichThuoc.IconDau,
		IconCuoi = CauHinh.KichThuoc.IconCuoi,
		IconDauPos = CauHinh.KichThuoc.ViTriIconDau,
		IconCuoiPos = CauHinh.KichThuoc.ViTriIconCuoi,
		KhungDau = CauHinh.KichThuoc.KhungDau,
		KhungCuoi = KichThuocCuoi,
		NutDongPop = CauHinh.KichThuoc.NutDongPop
	}

	ThuVienHieuUng.MoGiaoDien(CacDoiTuongUI, CauHinhHieuUng)
	
	local function DongVaXoa()
		DangDong = true
		ThuVienHieuUng.DongGiaoDien(CacDoiTuongUI, CauHinhHieuUng, function()
			ManHinhGui:Destroy()
		end)
	end

	for i, duLieu in ipairs(DuLieuNut) do
		local Nut = Instance.new("TextButton")
		Nut.Size = UDim2.new(1, 0, 0, ChieuCaoNut)
		Nut.Text = duLieu.Ten
		Nut.BackgroundColor3 = CauHinh.MauSac.NutThuong
		Nut.TextColor3 = CauHinh.MauSac.Chu
		Nut.Font = Enum.Font.GothamBold
		Nut.TextSize = 18
		Nut.BackgroundTransparency = 1
		Nut.TextTransparency = 1
		Nut.LayoutOrder = i
		Nut.Parent = KhungDanhSach
		Instance.new("UICorner", Nut).CornerRadius = UDim.new(0, 8)

		local CauHinhHieuUngNut = {
			KichThuocThuong = UDim2.new(1, 0, 0, ChieuCaoNut),
			KichThuocLuot = UDim2.new(1, 0, 0, ChieuCaoNut + 11),
			MauThuong = CauHinh.MauSac.NutThuong,
			MauLuot = CauHinh.MauSac.NutLuot
		}

		Nut.MouseEnter:Connect(function() ThuVienHieuUng.HieuUngLuotNut(Nut, true, CauHinhHieuUngNut) end)
		Nut.MouseLeave:Connect(function() ThuVienHieuUng.HieuUngLuotNut(Nut, false, CauHinhHieuUngNut) end)
		
		Nut.MouseButton1Click:Connect(function()
			if _G.HxScript_DaKichHoat[duLieu.Ten] then
				ThongBao("Hx Script", "Đã được kích hoạt rồi!", 3)
				return
			end

			if duLieu.Link ~= "" then
				_G.HxScript_DaKichHoat[duLieu.Ten] = true
				ThongBao("Hx Script", "Đã kích hoạt: " .. duLieu.Ten, 3)

				task.spawn(function()
					local thanhCong, loi = pcall(function() loadstring(game:HttpGet(duLieu.Link))() end)
					if not thanhCong then 
						ThongBao("Lỗi", "Không thể tải script!", 3)
						warn(loi) 
					end
				end)
			else
				ThongBao("Hx Script", "Chức năng này chưa có Link!", 2)
			end
		end)
	end

	local DoiTuongNutDong = { NutDong = NutDong, Dem = DemNutDong, Vien = VienNutDong }
	local MauNutDong = { Thuong = CauHinh.MauSac.DongThuong, Luot = CauHinh.MauSac.DongLuot }
	local KichThuocNutDong = { Thuong = CauHinh.KichThuoc.NutDong, Luot = CauHinh.KichThuoc.NutDongLuot }

	NutDong.MouseEnter:Connect(function()
		if not DangDong then ThuVienHieuUng.HieuUngLuotNutDong(DoiTuongNutDong, true, MauNutDong, KichThuocNutDong) end
	end)
	NutDong.MouseLeave:Connect(function()
		if not DangDong then ThuVienHieuUng.HieuUngLuotNutDong(DoiTuongNutDong, false, MauNutDong, KichThuocNutDong) end
	end)
	NutDong.MouseButton1Down:Connect(function()
		if not DangDong then ThuVienHieuUng.HieuUngNhanNut(NutDong, CauHinh.KichThuoc.NutDongNhan) end
	end)
	NutDong.MouseButton1Up:Connect(function()
		if not DangDong then DongVaXoa() end
	end)
end

TaoGiaoDien()
