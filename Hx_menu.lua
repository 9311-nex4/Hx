local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local NguoiChoi = Players.LocalPlayer
local GiaoDienNguoiChoi = NguoiChoi:WaitForChild("PlayerGui")

local LINK_THU_VIEN = "https://raw.githubusercontent.com/9311-nex4/Hx/main/Animation.lua" 
local ThuVienHieuUng = loadstring(game:HttpGet(LINK_THU_VIEN))()

local DuLieuNut = {
	{ Ten = "Transform", Link = "https://raw.githubusercontent.com/9311-nex4/Hx/main/Transform.lua" },
	{ Ten = "Example 2", Link = "" },
	{ Ten = "Example 3", Link = "" },
}

local ID_ICON = "rbxassetid://117118515787811"

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
		IconCuoiPos = UDim2.new(0, 27.5, 0, 27.5),
		IconDauPos = UDim2.new(0.5, 0, 0.5, 0),
		KhungDau = UDim2.new(0, 80, 0, 80),
		KhungCuoiMobile = UDim2.new(0.45, 0, 0.7425, 0),
		KhungCuoiPC = UDim2.new(0, 360, 0, 238),
		NutDong = UDim2.new(0, 30, 0, 30),
		NutDongLuot = UDim2.new(0, 35, 0, 35),
		NutDongNhan = UDim2.new(0, 28, 0, 28),
		NutDongPop = UDim2.new(0, 48, 0, 48)
	}
}

local function TaoGiaoDien()
	if GiaoDienNguoiChoi:FindFirstChild("GiaoDienChinh") then GiaoDienNguoiChoi.GiaoDienChinh:Destroy() end

	local DangXuLy = false

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "GiaoDienChinh"
	ScreenGui.Parent = GiaoDienNguoiChoi
	ScreenGui.ResetOnSpawn = false

	local KichThuocCuoi = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) 
		and CauHinh.KichThuoc.KhungCuoiMobile or CauHinh.KichThuoc.KhungCuoiPC

	local KhungChinh = Instance.new("Frame", ScreenGui)
	KhungChinh.Size = CauHinh.KichThuoc.KhungDau
	KhungChinh.Position = UDim2.new(0.5,0,0.5,0)
	KhungChinh.AnchorPoint = Vector2.new(0.5,0.5)
	KhungChinh.BackgroundColor3 = CauHinh.MauSac.Nen
	KhungChinh.BackgroundTransparency = 1
	KhungChinh.ClipsDescendants = false

	Instance.new("UICorner", KhungChinh).CornerRadius = UDim.new(0, 12)

	local IconDaiDien = Instance.new("ImageLabel", KhungChinh)
	IconDaiDien.Size = UDim2.new(0,0,0,0)
	IconDaiDien.Position = CauHinh.KichThuoc.IconDauPos
	IconDaiDien.AnchorPoint = Vector2.new(0.5,0.5)
	IconDaiDien.Image = ID_ICON
	IconDaiDien.BackgroundTransparency = 0.6
	IconDaiDien.BackgroundColor3 = Color3.new(0,0,0)
	IconDaiDien.ZIndex = 100
	Instance.new("UICorner", IconDaiDien).CornerRadius = UDim.new(0, 12)

	local Container = Instance.new("Frame", KhungChinh)
	Container.Size = UDim2.new(1,0,1,0)
	Container.BackgroundTransparency = 1

	local TieuDe = Instance.new("TextLabel", Container)
	TieuDe.Text = "Hx Script"
	TieuDe.Size = UDim2.new(1,-80,0,40)
	TieuDe.Position = UDim2.new(0,50,0,5)
	TieuDe.BackgroundTransparency = 1
	TieuDe.TextColor3 = CauHinh.MauSac.Chu
	TieuDe.Font = Enum.Font.GothamBold
	TieuDe.TextSize = 22
	TieuDe.TextXAlignment = Enum.TextXAlignment.Left
	TieuDe.TextTransparency = 1

	local NutDong = Instance.new("TextButton", KhungChinh)
	NutDong.Size = CauHinh.KichThuoc.NutDong
	NutDong.Position = UDim2.new(1,-25,0,25)
	NutDong.AnchorPoint = Vector2.new(0.5,0.5)
	NutDong.Text = "X"
	NutDong.Font = Enum.Font.GothamBold
	NutDong.BackgroundColor3 = CauHinh.MauSac.DongThuong
	NutDong.TextColor3 = CauHinh.MauSac.Chu
	NutDong.BackgroundTransparency = 1
	NutDong.TextTransparency = 1
	NutDong.ZIndex = 2
	Instance.new("UICorner", NutDong).CornerRadius = UDim.new(0, 8)
	local DemNutDong = Instance.new("UIPadding", NutDong)
	local VienNutDong = Instance.new("UIStroke", NutDong)
	VienNutDong.Color = CauHinh.MauSac.Vien
	VienNutDong.Transparency = 1
	VienNutDong.Thickness = 1.5

	local DanhSach = Instance.new("ScrollingFrame", Container)
	DanhSach.Size = UDim2.new(1,-20,1,-70)
	DanhSach.Position = UDim2.new(0,10,0,50)
	DanhSach.BackgroundTransparency = 1
	DanhSach.BackgroundColor3 = CauHinh.MauSac.NenNoiDung
	DanhSach.ScrollBarImageTransparency = 1
	DanhSach.BorderSizePixel = 0
	Instance.new("UICorner", DanhSach).CornerRadius = UDim.new(0, 8)
	local BoCucDanhSach = Instance.new("UIListLayout", DanhSach)
	BoCucDanhSach.Padding = UDim.new(0,8)
	BoCucDanhSach.SortOrder = Enum.SortOrder.LayoutOrder
	
	BoCucDanhSach:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		DanhSach.CanvasSize = UDim2.new(0,0,0, BoCucDanhSach.AbsoluteContentSize.Y + 20)
	end)

	local CacDoiTuongGiaoDien = {
		ScreenGui = ScreenGui, Khung = KhungChinh, Icon = IconDaiDien,
		TieuDe = TieuDe, NutDong = NutDong, VienNutDong = VienNutDong, DanhSach = DanhSach
	}
	
	local CauHinhHieuUng = {
		IconDau = CauHinh.KichThuoc.IconDau,
		IconCuoi = CauHinh.KichThuoc.IconCuoi,
		IconDauPos = CauHinh.KichThuoc.IconDauPos,
		IconCuoiPos = CauHinh.KichThuoc.IconCuoiPos,
		KhungDau = CauHinh.KichThuoc.KhungDau,
		KhungCuoi = KichThuocCuoi,
		NutDongPop = CauHinh.KichThuoc.NutDongPop
	}

	ThuVienHieuUng.MoGiaoDien(CacDoiTuongGiaoDien, CauHinhHieuUng)
	
	local function DongVaXoa()
		ThuVienHieuUng.DongGiaoDien(CacDoiTuongGiaoDien, CauHinhHieuUng, function()
			ScreenGui:Destroy()
		end)
	end

	for i, duLieu in ipairs(DuLieuNut) do
		local Nut = Instance.new("TextButton", DanhSach)
		Nut.Size = UDim2.new(1,0,0,45)
		Nut.Text = duLieu.Ten
		Nut.BackgroundColor3 = CauHinh.MauSac.NutThuong
		Nut.TextColor3 = CauHinh.MauSac.Chu
		Nut.Font = Enum.Font.GothamBold
		Nut.TextSize = 18
		Nut.BackgroundTransparency = 1
		Nut.TextTransparency = 1
		Nut.LayoutOrder = i
		Instance.new("UICorner", Nut).CornerRadius = UDim.new(0, 8)

		local CauHinhNut = {
			KichThuocThuong = UDim2.new(1,0,0,45),
			KichThuocLuot = UDim2.new(1,0,0,56),
			MauThuong = CauHinh.MauSac.NutThuong,
			MauLuot = CauHinh.MauSac.NutLuot
		}

		Nut.MouseEnter:Connect(function()
			if not DangXuLy then
				ThuVienHieuUng.HieuUngLuotNut(Nut, true, CauHinhNut)
			end
		end)
		Nut.MouseLeave:Connect(function()
			if not DangXuLy then
				ThuVienHieuUng.HieuUngLuotNut(Nut, false, CauHinhNut)
			end
		end)
		Nut.MouseButton1Click:Connect(function()
			if DangXuLy then return end
			DangXuLy = true
			
			if duLieu.Link ~= "" then
				pcall(function() loadstring(game:HttpGet(duLieu.Link))() end)
			end
			DongVaXoa()
		end)
	end

	local CacDoiTuongNutDong = { NutDong = NutDong, Dem = DemNutDong, Vien = VienNutDong }
	local CauHinhMauNutDong = { Thuong = CauHinh.MauSac.DongThuong, Luot = CauHinh.MauSac.DongLuot }
	local CauHinhKichThuocNutDong = { Thuong = CauHinh.KichThuoc.NutDong, Luot = CauHinh.KichThuoc.NutDongLuot }

	NutDong.MouseEnter:Connect(function()
		if not DangXuLy then
			ThuVienHieuUng.HieuUngLuotNutDong(CacDoiTuongNutDong, true, CauHinhMauNutDong, CauHinhKichThuocNutDong)
		end
	end)
	NutDong.MouseLeave:Connect(function()
		if not DangXuLy then
			ThuVienHieuUng.HieuUngLuotNutDong(CacDoiTuongNutDong, false, CauHinhMauNutDong, CauHinhKichThuocNutDong)
		end
	end)
	NutDong.MouseButton1Down:Connect(function()
		if not DangXuLy then
			ThuVienHieuUng.HieuUngNhanNut(NutDong, CauHinh.KichThuoc.NutDongNhan)
		end
	end)
	NutDong.MouseButton1Up:Connect(function()
		if DangXuLy then return end
		DangXuLy = true
		DongVaXoa()
	end)
end

TaoGiaoDien()
