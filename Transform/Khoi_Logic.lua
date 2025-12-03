local LogicKhoi = {}

local DichVuNguoiChoi = game:GetService("Players")
local DichVuNhapLieu = game:GetService("UserInputService")
local DichVuRender = game:GetService("RunService")
local DichVuHieuUng = game:GetService("TweenService")
local KhongGian = game:GetService("Workspace")

local NguoiChoi = DichVuNguoiChoi.LocalPlayer
local Chuot = NguoiChoi:GetMouse()

local CAI_DAT = {
	THOI_GIAN_GIU = 0.3,
	KHOANG_CACH_GIU = 15,
	GIOI_HAN_LICH_SU = 30,
	LUOI_DI_CHUYEN_MAC_DINH = 1,
	LUOI_XOAY_MAC_DINH = 15,
	KICH_THUOC_TOI_THIEU = 0.5,

	MAU_NEN_CHINH = Color3.fromRGB(25, 25, 30),
	MAU_NEN_PHU = Color3.fromRGB(40, 40, 45),
	MAU_VIEN = Color3.fromRGB(255, 255, 255),

	DO_TRONG_SUOT_NEN = 0.3,
	DO_TRONG_SUOT_VIEN = 0,

	MAU_NUT_THUONG = Color3.fromRGB(225, 225, 225),
	MAU_ICON_THUONG = Color3.fromRGB(255, 255, 255), 

	MAU_NUT_KICH_HOAT = Color3.fromRGB(0, 150, 255), 
	MAU_NUT_SCALE_2 = Color3.fromRGB(255, 160, 0),
	MAU_NUT_OFF = Color3.fromRGB(100, 100, 100),

	MAU_NUT_HUY_NEN = Color3.fromRGB(200, 40, 40),
	MAU_NUT_HUY_CHU = Color3.fromRGB(255, 255, 255),

	KICH_THUOC_NUT = 44,
	KICH_THUOC_NUT_PHU = 36,
	BO_GOC_CHINH = 10,
	BO_GOC_NUT = 8,

	TWEEN_UI = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	TWEEN_ICON = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	TWEEN_NHUN = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

	ICON_DI_CHUYEN = "98501712328327",
	ICON_KEO_GIAN = "131983126233194",
	ICON_XOAY = "94475561845407",
	ICON_GRID = "140476097300003",
	ICON_HINH_DANG = "77461488191679",
	ICON_UNDO = "124647276241633",
	ICON_REDO = "120782076898439",
	ICON_MUI_TEN = "rbxassetid://6031091004",
	ICON_DA_CHON = "109826670489779",

	MAU_CHON_BOX = Color3.fromRGB(255, 255, 255),
	DO_DAY_VIEN_CHON = 0.08,
	MAU_TAY_CAM_DI_CHUYEN = Color3.fromRGB(255, 60, 60),
	MAU_TAY_CAM_SCALE = Color3.fromRGB(60, 160, 255),
}

local DanhSachKhoi = {}
local CacKhoiDangChon = {}
local CongCuHienTai = 1
local CheDoScale = 1
local CheDoLuoi = true
local CheDoDaChon = false

local TayCam = {DiChuyen = nil, KeoGian = nil, Xoay = nil}
local GiaoDien = {
	HopChua = nil, KhungChinh = nil, KhungPhu = nil,
	DanhSachNut = nil, NutMoRong = nil, IconMuiTen = nil,
	DaMoRong = false, ViTriLuu = UDim2.new(1, -70, 0.5, 0)
}
local DuLieuGoc = {CFrame = nil, Size = nil}
local LichSu = {Undo = {}, Redo = {}, TrangThaiBatDau = {}}
local CacHinhDang = {Enum.PartType.Block, Enum.PartType.Ball, Enum.PartType.Cylinder, Enum.PartType.Wedge, Enum.PartType.CornerWedge}
local ChiSoHinhDang = 1

LogicKhoi.SuKienThayDoi = Instance.new("BindableEvent")

local function LayTrangThai(DanhSach)
	local TrangThai = {}
	for DoiTuong, _ in pairs(DanhSach) do
		if DoiTuong:IsA("BasePart") then
			TrangThai[DoiTuong] = {CFrame = DoiTuong.CFrame, Size = DoiTuong.Size, Shape = DoiTuong.Shape}
		end
	end
	return TrangThai
end

local function ApDungTrangThai(TrangThai)
	for DoiTuong, DuLieu in pairs(TrangThai) do
		if DoiTuong and DoiTuong.Parent then
			DoiTuong.CFrame = DuLieu.CFrame; DoiTuong.Size = DuLieu.Size; DoiTuong.Shape = DuLieu.Shape
		end
	end
end

local function GhiLichSu(Cu, Moi)
	local CoThayDoi = false
	for k, v in pairs(Moi) do
		if not Cu[k] or Cu[k].CFrame ~= v.CFrame or Cu[k].Size ~= v.Size or Cu[k].Shape ~= v.Shape then CoThayDoi = true break end
	end
	if CoThayDoi then
		table.insert(LichSu.Undo, Cu)
		if #LichSu.Undo > CAI_DAT.GIOI_HAN_LICH_SU then table.remove(LichSu.Undo, 1) end
		LichSu.Redo = {}
	end
end

local function ThucHienUndo()
	if #LichSu.Undo == 0 then return end
	local TrangThaiCu = table.remove(LichSu.Undo)
	table.insert(LichSu.Redo, LayTrangThai(CacKhoiDangChon))
	ApDungTrangThai(TrangThaiCu)
end

local function ThucHienRedo()
	if #LichSu.Redo == 0 then return end
	local TrangThaiMoi = table.remove(LichSu.Redo)
	table.insert(LichSu.Undo, LayTrangThai(CacKhoiDangChon))
	ApDungTrangThai(TrangThaiMoi)
end

local function LamTron(So, Luoi)
	return CheDoLuoi and math.round(So / Luoi) * Luoi or So
end

local function HieuUngNhan(DoiTuong)
	if not DoiTuong or not DoiTuong:IsA("BasePart") then return end
	local SizeGoc = DoiTuong.Size
	local HieuUng = DichVuHieuUng:Create(DoiTuong, CAI_DAT.TWEEN_NHUN, {Size = SizeGoc * 1.1})
	HieuUng:Play(); HieuUng.Completed:Connect(function() DichVuHieuUng:Create(DoiTuong, TweenInfo.new(0.15), {Size = SizeGoc}):Play() end)
end

local function CapNhatGiaoDien()
	if not GiaoDien.DanhSachNut then return end

	for _, Con in ipairs(GiaoDien.DanhSachNut:GetChildren()) do
		if Con:IsA("ImageButton") and Con.Name:find("CongCu_") then
			local ID = tonumber(Con.Name:match("%d+"))
			local DangChon = (ID == CongCuHienTai)
			local MauNen = (ID == 2 and CheDoScale == 2) and CAI_DAT.MAU_NUT_SCALE_2 or CAI_DAT.MAU_NUT_KICH_HOAT

			local BieuTuong = Con:FindFirstChild("Icon"); local VienNet = Con:FindFirstChild("UIStroke")
			if BieuTuong then DichVuHieuUng:Create(BieuTuong, CAI_DAT.TWEEN_ICON, {ImageColor3 = Color3.new(1,1,1)}):Play() end
			if VienNet then DichVuHieuUng:Create(VienNet, CAI_DAT.TWEEN_ICON, {Color = DangChon and MauNen or CAI_DAT.MAU_VIEN, Transparency = DangChon and 0 or 1}):Play() end
			DichVuHieuUng:Create(Con, CAI_DAT.TWEEN_ICON, {BackgroundTransparency = DangChon and 0 or 0.3}):Play()
		end
	end

	if GiaoDien.KhungPhu then
		local NutGrid = GiaoDien.KhungPhu:FindFirstChild("NutGrid")
		if NutGrid and NutGrid:FindFirstChild("Icon") then
			DichVuHieuUng:Create(NutGrid.Icon, CAI_DAT.TWEEN_ICON, {ImageColor3 = CheDoLuoi and CAI_DAT.MAU_NUT_KICH_HOAT or CAI_DAT.MAU_NUT_OFF}):Play()
		end

		local NutDaChon = GiaoDien.KhungPhu:FindFirstChild("NutDaChon")
		if NutDaChon and NutDaChon:FindFirstChild("Icon") then
			local MauDaChon = CheDoDaChon and CAI_DAT.MAU_NUT_KICH_HOAT or CAI_DAT.MAU_NUT_OFF
			DichVuHieuUng:Create(NutDaChon.Icon, CAI_DAT.TWEEN_ICON, {ImageColor3 = MauDaChon}):Play()
		end
	end
end

local function TaoGiaoDien()
	if GiaoDien.HopChua then GiaoDien.HopChua:Destroy() end
	local KhoGiaoDien = NguoiChoi:WaitForChild("PlayerGui")
	local ManHinhGui = Instance.new("ScreenGui", KhoGiaoDien); ManHinhGui.Name = "HeThongXayDung_V9_SizeColor"
	ManHinhGui.ResetOnSpawn = false

	local HopChua = Instance.new("Frame", ManHinhGui); HopChua.Name = "HopChua"
	HopChua.AnchorPoint = Vector2.new(0.5, 0.5); HopChua.Position = GiaoDien.ViTriLuu
	HopChua.Size = UDim2.fromOffset(CAI_DAT.KICH_THUOC_NUT + 20, 300); HopChua.BackgroundTransparency = 1
	HopChua.Visible = false; HopChua.ZIndex = 1

	local KhungChinh = Instance.new("Frame", HopChua); KhungChinh.Name = "KhungChinh"
	KhungChinh.Size = UDim2.new(1, 0, 0, 0); KhungChinh.BackgroundColor3 = CAI_DAT.MAU_NEN_CHINH
	KhungChinh.BackgroundTransparency = CAI_DAT.DO_TRONG_SUOT_NEN; KhungChinh.ClipsDescendants = true
	KhungChinh.ZIndex = 10
	Instance.new("UICorner", KhungChinh).CornerRadius = UDim.new(0, CAI_DAT.BO_GOC_CHINH)
	local VienChinh = Instance.new("UIStroke", KhungChinh); VienChinh.Color = CAI_DAT.MAU_VIEN; VienChinh.Thickness = 1.5; VienChinh.Transparency = CAI_DAT.DO_TRONG_SUOT_VIEN

	local ThanhKeo = Instance.new("TextButton", KhungChinh); ThanhKeo.Name = "ThanhKeo"
	ThanhKeo.Size = UDim2.new(1, 0, 0, 24); ThanhKeo.Text = ""; ThanhKeo.BackgroundTransparency = 0.5; ThanhKeo.BackgroundColor3 = CAI_DAT.MAU_NEN_PHU; ThanhKeo.ZIndex = 11
	Instance.new("UICorner", ThanhKeo).CornerRadius = UDim.new(1, 0)
	local IconKeo = Instance.new("Frame", ThanhKeo); IconKeo.Size = UDim2.new(0, 24, 0, 3); IconKeo.Position = UDim2.fromScale(0.5, 0.5); IconKeo.AnchorPoint = Vector2.new(0.5, 0.5); IconKeo.BackgroundColor3 = Color3.fromRGB(200, 200, 200); IconKeo.ZIndex = 12

	local DangKeo, DiemBatDau, ViTriGoc = false, nil, nil
	ThanhKeo.InputBegan:Connect(function(DauVao)
		if DauVao.UserInputType == Enum.UserInputType.MouseButton1 or DauVao.UserInputType == Enum.UserInputType.Touch then
			DangKeo = true; DiemBatDau = DauVao.Position; ViTriGoc = HopChua.Position
			DauVao.Changed:Connect(function() if DauVao.UserInputState == Enum.UserInputState.End then DangKeo = false; GiaoDien.ViTriLuu = HopChua.Position end end)
		end
	end)
	DichVuNhapLieu.InputChanged:Connect(function(DauVao)
		if DangKeo and (DauVao.UserInputType == Enum.UserInputType.MouseMovement or DauVao.UserInputType == Enum.UserInputType.Touch) then
			local DoLech = DauVao.Position - DiemBatDau; HopChua.Position = UDim2.new(ViTriGoc.X.Scale, ViTriGoc.X.Offset + DoLech.X, ViTriGoc.Y.Scale, ViTriGoc.Y.Offset + DoLech.Y)
		end
	end)

	local DanhSachNut = Instance.new("Frame", KhungChinh); DanhSachNut.Name = "DanhSachNut"
	DanhSachNut.BackgroundTransparency = 1; DanhSachNut.Size = UDim2.new(1, 0, 1, -60); DanhSachNut.Position = UDim2.new(0, 0, 0, 32); DanhSachNut.ZIndex = 15
	local BoCuc = Instance.new("UIListLayout", DanhSachNut); BoCuc.HorizontalAlignment = Enum.HorizontalAlignment.Center; BoCuc.Padding = UDim.new(0, 10); BoCuc.SortOrder = Enum.SortOrder.LayoutOrder

	local function TaoNutCongCu(MaBieuTuong, MaSo, ThuTu)
		local Nut = Instance.new("ImageButton", DanhSachNut); Nut.Name = "CongCu_" .. MaSo; Nut.LayoutOrder = ThuTu
		Nut.Size = UDim2.fromOffset(CAI_DAT.KICH_THUOC_NUT, CAI_DAT.KICH_THUOC_NUT); Nut.BackgroundColor3 = CAI_DAT.MAU_NUT_THUONG; Nut.BackgroundTransparency = 0.3; Nut.Image = ""; Nut.ZIndex = 20
		Instance.new("UICorner", Nut).CornerRadius = UDim.new(0, CAI_DAT.BO_GOC_NUT)
		local VienNet = Instance.new("UIStroke", Nut); VienNet.Color = CAI_DAT.MAU_VIEN; VienNet.Thickness = 1.5; VienNet.Transparency = 1
		local BieuTuong = Instance.new("ImageLabel", Nut); BieuTuong.Name = "Icon"; BieuTuong.BackgroundTransparency = 1; BieuTuong.ImageTransparency = 0
		BieuTuong.Size = UDim2.new(0.65, 0, 0.65, 0); BieuTuong.Position = UDim2.fromScale(0.5, 0.5); BieuTuong.AnchorPoint = Vector2.new(0.5, 0.5); BieuTuong.Image = "rbxassetid://" .. MaBieuTuong; BieuTuong.ImageColor3 = CAI_DAT.MAU_ICON_THUONG; BieuTuong.ZIndex = 25
		Nut.MouseButton1Click:Connect(function() LogicKhoi.ChinhCongCu(MaSo) end)
	end
	TaoNutCongCu(CAI_DAT.ICON_DI_CHUYEN, 1, 1); TaoNutCongCu(CAI_DAT.ICON_KEO_GIAN, 2, 2); TaoNutCongCu(CAI_DAT.ICON_XOAY, 3, 3)

	local NutHuy = Instance.new("TextButton", KhungChinh); NutHuy.Name = "NutHuy"
	NutHuy.Size = UDim2.new(1, -24, 0, 28); NutHuy.Position = UDim2.new(0.5, 0, 1, -12); NutHuy.AnchorPoint = Vector2.new(0.5, 1); NutHuy.Text = "ĐÓNG"; NutHuy.Font = Enum.Font.GothamBlack; NutHuy.TextSize = 11
	NutHuy.TextColor3 = CAI_DAT.MAU_NUT_HUY_CHU; NutHuy.BackgroundColor3 = CAI_DAT.MAU_NUT_HUY_NEN; NutHuy.BackgroundTransparency = 0.1; NutHuy.ZIndex = 20
	Instance.new("UICorner", NutHuy).CornerRadius = UDim.new(0, 6)
	NutHuy.MouseButton1Click:Connect(function() LogicKhoi.HuyChon() end)

	local NutMoRong = Instance.new("ImageButton", HopChua); NutMoRong.Name = "NutMoRong"
	NutMoRong.Size = UDim2.fromOffset(22, 44); NutMoRong.Position = UDim2.new(0, -15, 0.45, 0); NutMoRong.AnchorPoint = Vector2.new(1.5, 1)
	NutMoRong.BackgroundColor3 = CAI_DAT.MAU_NEN_CHINH; NutMoRong.BackgroundTransparency = 0.2; NutMoRong.ZIndex = 9
	Instance.new("UICorner", NutMoRong).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", NutMoRong).Color = CAI_DAT.MAU_VIEN
	local IconMuiTen = Instance.new("ImageLabel", NutMoRong); IconMuiTen.Size = UDim2.fromScale(0.8, 0.8); IconMuiTen.Position = UDim2.fromScale(0.5, 0.5); IconMuiTen.AnchorPoint = Vector2.new(0.5, 0.5); IconMuiTen.BackgroundTransparency = 1; IconMuiTen.Image = CAI_DAT.ICON_MUI_TEN; IconMuiTen.Rotation = 90; IconMuiTen.ImageColor3 = CAI_DAT.MAU_ICON_THUONG; IconMuiTen.ZIndex = 10

	local KhungPhu = Instance.new("Frame", HopChua); KhungPhu.Name = "KhungPhu"
	KhungPhu.AnchorPoint = Vector2.new(0.4, 0.8); KhungPhu.Position = UDim2.new(0, -10, 0.5, 0)
	KhungPhu.Size = UDim2.fromOffset((CAI_DAT.KICH_THUOC_NUT_PHU * 2) + 20, (CAI_DAT.KICH_THUOC_NUT_PHU * 3) + 28)
	KhungPhu.BackgroundColor3 = CAI_DAT.MAU_NEN_PHU; KhungPhu.BackgroundTransparency = CAI_DAT.DO_TRONG_SUOT_NEN; KhungPhu.Visible = false; KhungPhu.ZIndex = 8
	Instance.new("UICorner", KhungPhu).CornerRadius = UDim.new(0, CAI_DAT.BO_GOC_CHINH)
	Instance.new("UIStroke", KhungPhu).Color = CAI_DAT.MAU_VIEN
	local GridPhu = Instance.new("UIGridLayout", KhungPhu); GridPhu.CellSize = UDim2.fromOffset(CAI_DAT.KICH_THUOC_NUT_PHU, CAI_DAT.KICH_THUOC_NUT_PHU); GridPhu.CellPadding = UDim2.fromOffset(8, 8); GridPhu.HorizontalAlignment = Enum.HorizontalAlignment.Center; GridPhu.VerticalAlignment = Enum.VerticalAlignment.Center; GridPhu.SortOrder = Enum.SortOrder.LayoutOrder

	local function TaoNutPhu(Ten, MaBieuTuong, ThuTu, HamGoiLai)
		local Nut = Instance.new("ImageButton", KhungPhu); Nut.Name = Ten; Nut.LayoutOrder = ThuTu
		Nut.BackgroundColor3 = CAI_DAT.MAU_NUT_THUONG; Nut.BackgroundTransparency = 0.3; Nut.Image = ""; Nut.ZIndex = 12
		Instance.new("UICorner", Nut).CornerRadius = UDim.new(0, 6)
		local BieuTuong = Instance.new("ImageLabel", Nut); BieuTuong.Name = "Icon"; BieuTuong.BackgroundTransparency = 1; BieuTuong.ImageTransparency = 0
		BieuTuong.Size = UDim2.new(0.7, 0, 0.7, 0); BieuTuong.Position = UDim2.fromScale(0.5, 0.5); BieuTuong.AnchorPoint = Vector2.new(0.5, 0.5); BieuTuong.Image = "rbxassetid://" .. MaBieuTuong; BieuTuong.ImageColor3 = CAI_DAT.MAU_ICON_THUONG; BieuTuong.ZIndex = 13
		Nut.MouseButton1Click:Connect(HamGoiLai)
		return Nut
	end

	TaoNutPhu("NutGrid", CAI_DAT.ICON_GRID, 1, function() CheDoLuoi = not CheDoLuoi; CapNhatGiaoDien() end)
	TaoNutPhu("NutHinhDang", CAI_DAT.ICON_HINH_DANG, 2, function() 
		local TrangThaiCu = LayTrangThai(CacKhoiDangChon); ChiSoHinhDang = ChiSoHinhDang + 1; if ChiSoHinhDang > #CacHinhDang then ChiSoHinhDang = 1 end
		local HinhMoi = CacHinhDang[ChiSoHinhDang]; for Khoi, _ in pairs(CacKhoiDangChon) do if Khoi:IsA("BasePart") then Khoi.Shape = HinhMoi end end
		GhiLichSu(TrangThaiCu, LayTrangThai(CacKhoiDangChon)); CapNhatGiaoDien()
	end)
	TaoNutPhu("NutUndo", CAI_DAT.ICON_UNDO, 3, ThucHienUndo)
	TaoNutPhu("NutRedo", CAI_DAT.ICON_REDO, 4, ThucHienRedo)

	TaoNutPhu("NutDaChon", CAI_DAT.ICON_DA_CHON, 5, function() 
		CheDoDaChon = not CheDoDaChon
		CapNhatGiaoDien()
	end)

	NutMoRong.MouseButton1Click:Connect(function()
		GiaoDien.DaMoRong = not GiaoDien.DaMoRong
		local VI_TRI_NUP = 0; local DO_HO_GIUA_HAI_KHUNG = 15; local TOC_DO = 0.35
		if GiaoDien.DaMoRong then
			KhungPhu.Visible = true
			local DoRongKhung = (CAI_DAT.KICH_THUOC_NUT_PHU * 2) + 20; local ViTriMo = -(DoRongKhung + DO_HO_GIUA_HAI_KHUNG)
			KhungPhu:TweenPosition(UDim2.new(0, ViTriMo, 0.5, 0), "Out", Enum.EasingStyle.Back, TOC_DO)
			DichVuHieuUng:Create(IconMuiTen, CAI_DAT.TWEEN_UI, {Rotation = -90}):Play()
		else
			KhungPhu:TweenPosition(UDim2.new(0, VI_TRI_NUP, 0.5, 0), "In", Enum.EasingStyle.Back, TOC_DO, true, function() KhungPhu.Visible = false end)
			DichVuHieuUng:Create(IconMuiTen, CAI_DAT.TWEEN_UI, {Rotation = 90}):Play()
		end
	end)

	GiaoDien.HopChua = HopChua; GiaoDien.KhungChinh = KhungChinh; GiaoDien.KhungPhu = KhungPhu; GiaoDien.DanhSachNut = DanhSachNut; GiaoDien.NutMoRong = NutMoRong; GiaoDien.IconMuiTen = IconMuiTen
	CapNhatGiaoDien()
end

local function HienThiUI(Hien)
	if not GiaoDien.HopChua then return end
	if Hien then
		GiaoDien.HopChua.Visible = true; local ChieuCao = 32 + (CAI_DAT.KICH_THUOC_NUT * 3) + 30 + 40
		GiaoDien.KhungChinh:TweenSize(UDim2.new(1, 0, 0, ChieuCao), "Out", Enum.EasingStyle.Back, 0.35)
	else
		GiaoDien.KhungChinh:TweenSize(UDim2.new(1, 0, 0, 0), "In", Enum.EasingStyle.Quart, 0.3, true, function()
			GiaoDien.HopChua.Visible = false
		end)
		if GiaoDien.DaMoRong then
			GiaoDien.DaMoRong = false; if GiaoDien.KhungPhu then GiaoDien.KhungPhu.Visible = false; GiaoDien.KhungPhu.Position = UDim2.new(0, -10, 0.5, 0) end
			if GiaoDien.IconMuiTen then DichVuHieuUng:Create(GiaoDien.IconMuiTen, CAI_DAT.TWEEN_UI, {Rotation = 90}):Play() end
		end
	end
end

local function XoaTayCam()
	if TayCam.DiChuyen then TayCam.DiChuyen:Destroy() TayCam.DiChuyen = nil end
	if TayCam.KeoGian then TayCam.KeoGian:Destroy() TayCam.KeoGian = nil end
	if TayCam.Xoay then TayCam.Xoay:Destroy() TayCam.Xoay = nil end
end

local function TaoTayCam(KhoiDuocChon)
	XoaTayCam()
	local ThuMucGizmo = NguoiChoi.PlayerGui:FindFirstChild("Gizmos") or Instance.new("Folder", NguoiChoi.PlayerGui); ThuMucGizmo.Name = "Gizmos"
	local function GanSuKien(TayCamAo)
		TayCamAo.MouseButton1Down:Connect(function() LichSu.TrangThaiBatDau = LayTrangThai(CacKhoiDangChon) end)
		TayCamAo.MouseButton1Up:Connect(function() GhiLichSu(LichSu.TrangThaiBatDau, LayTrangThai(CacKhoiDangChon)) end)
	end

	if CongCuHienTai == 1 then
		local H = Instance.new("Handles", ThuMucGizmo); H.Adornee = KhoiDuocChon; H.Style = Enum.HandlesStyle.Movement; H.Color3 = CAI_DAT.MAU_TAY_CAM_DI_CHUYEN; TayCam.DiChuyen = H; GanSuKien(H)
		H.MouseButton1Down:Connect(function() DuLieuGoc.CFrame = KhoiDuocChon.CFrame end)
		H.MouseDrag:Connect(function(Mat, KhoangCach)
			if not DuLieuGoc.CFrame then return end
			local KhoangCachLamTron = LamTron(KhoangCach, CAI_DAT.LUOI_DI_CHUYEN_MAC_DINH); local DoLech = DuLieuGoc.CFrame:VectorToWorldSpace(Vector3.FromNormalId(Mat)) * KhoangCachLamTron
			KhoiDuocChon.CFrame = DuLieuGoc.CFrame + DoLech
			local NeoCu = KhoiDuocChon.Anchored; KhoiDuocChon.Anchored = true; H.MouseButton1Up:Once(function() KhoiDuocChon.Anchored = NeoCu end)
		end)
	elseif CongCuHienTai == 2 then
		local H = Instance.new("Handles", ThuMucGizmo); H.Adornee = KhoiDuocChon; H.Style = Enum.HandlesStyle.Resize; H.Color3 = CheDoScale == 2 and CAI_DAT.MAU_NUT_SCALE_2 or CAI_DAT.MAU_TAY_CAM_SCALE; TayCam.KeoGian = H; GanSuKien(H)
		H.MouseButton1Down:Connect(function() DuLieuGoc.Size = KhoiDuocChon.Size; DuLieuGoc.CFrame = KhoiDuocChon.CFrame end)
		H.MouseDrag:Connect(function(Mat, KhoangCach)
			if not DuLieuGoc.Size then return end
			local KhoangCachLamTron = LamTron(KhoangCach, CAI_DAT.LUOI_DI_CHUYEN_MAC_DINH); local TrucDiaPhuong = Vector3.FromNormalId(Mat); local TrucTuyetDoi = Vector3.new(math.abs(TrucDiaPhuong.X), math.abs(TrucDiaPhuong.Y), math.abs(TrucDiaPhuong.Z))
			local KichThuocToiThieu = CAI_DAT.KICH_THUOC_TOI_THIEU
			if CheDoScale == 1 then
				local KichThuocMoi = DuLieuGoc.Size + (TrucTuyetDoi * KhoangCachLamTron)
				if KichThuocMoi.X < KichThuocToiThieu or KichThuocMoi.Y < KichThuocToiThieu or KichThuocMoi.Z < KichThuocToiThieu then return end
				KhoiDuocChon.Size = KichThuocMoi; local HuongTheGioi = DuLieuGoc.CFrame:VectorToWorldSpace(TrucDiaPhuong); KhoiDuocChon.CFrame = DuLieuGoc.CFrame + (HuongTheGioi * (KhoangCachLamTron / 2))
			else
				local KichThuocMoi = DuLieuGoc.Size + (TrucTuyetDoi * KhoangCachLamTron)
				KichThuocMoi = Vector3.new(math.max(KichThuocToiThieu, KichThuocMoi.X), math.max(KichThuocToiThieu, KichThuocMoi.Y), math.max(KichThuocToiThieu, KichThuocMoi.Z))
				KhoiDuocChon.Size = KichThuocMoi; KhoiDuocChon.CFrame = DuLieuGoc.CFrame
			end
		end)
	elseif CongCuHienTai == 3 then
		local H = Instance.new("ArcHandles", ThuMucGizmo); H.Adornee = KhoiDuocChon; H.Axes = Axes.new(Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z); TayCam.Xoay = H; GanSuKien(H)
		H.MouseButton1Down:Connect(function() DuLieuGoc.CFrame = KhoiDuocChon.CFrame end)
		H.MouseDrag:Connect(function(Truc, Goc)
			if not DuLieuGoc.CFrame then return end
			local GocLamTron = LamTron(math.deg(Goc), CAI_DAT.LUOI_XOAY_MAC_DINH); local GocRadian = math.rad(GocLamTron)
			local Xoay = CFrame.Angles(Truc == Enum.Axis.X and GocRadian or 0, Truc == Enum.Axis.Y and GocRadian or 0, Truc == Enum.Axis.Z and GocRadian or 0)
			KhoiDuocChon.CFrame = DuLieuGoc.CFrame * Xoay
			local NeoCu = KhoiDuocChon.Anchored; KhoiDuocChon.Anchored = true; H.MouseButton1Up:Once(function() KhoiDuocChon.Anchored = NeoCu end)
		end)
	end
end

function LogicKhoi.TaoKhoiMau()
	local NhanVat = NguoiChoi.Character; if not NhanVat then return end
	local GocNhanVat = NhanVat:FindFirstChild("HumanoidRootPart")
	local Khoi = Instance.new("Part"); Khoi.Name = "Khoi_" .. math.random(100, 999)
	Khoi.Size = Vector3.new(4, 1, 4)
	Khoi.CFrame = GocNhanVat.CFrame * CFrame.new(0, 0, -10); Khoi.Position = Vector3.new(math.round(Khoi.Position.X), math.round(Khoi.Position.Y), math.round(Khoi.Position.Z))
	Khoi.Color = Color3.new(math.random(), math.random(), math.random())
	Khoi.Material = Enum.Material.Plastic; Khoi.Anchored = true; Khoi.Parent = KhongGian
	table.insert(DanhSachKhoi, Khoi); LogicKhoi.SuKienThayDoi:Fire("Them", Khoi); return Khoi.Name
end

function LogicKhoi.HuyChon()
	CacKhoiDangChon = {}; HienThiUI(false); XoaTayCam()
	if GiaoDien.KhungPhu then GiaoDien.KhungPhu.Visible = false end
	for _, v in ipairs(DanhSachKhoi) do local MucTieu = v:IsA("Model") and v.PrimaryPart or v; if MucTieu and MucTieu:FindFirstChild("HopChon_Hx") then MucTieu.HopChon_Hx:Destroy() end end
end

function LogicKhoi.ChinhCongCu(MaSo)
	if MaSo == 2 and CongCuHienTai == 2 then CheDoScale = (CheDoScale == 1) and 2 or 1 else CheDoScale = 1; CongCuHienTai = MaSo end
	CapNhatGiaoDien()
	local DanhSach = {}; for k, _ in pairs(CacKhoiDangChon) do table.insert(DanhSach, k) end
	if #DanhSach == 1 then local MucTieu = DanhSach[1]:IsA("Model") and DanhSach[1].PrimaryPart or DanhSach[1]; TaoTayCam(MucTieu) end
end

function LogicKhoi.XoaKhoiChon()
	for Khoi, _ in pairs(CacKhoiDangChon) do
		LogicKhoi.SuKienThayDoi:Fire("Xoa", Khoi); Khoi:Destroy()
		for i, v in ipairs(DanhSachKhoi) do if v == Khoi then table.remove(DanhSachKhoi, i) break end end
	end
	LogicKhoi.HuyChon()
end

function LogicKhoi.HanCacKhoi()
	local CacKhoi = {}; for k, _ in pairs(CacKhoiDangChon) do table.insert(CacKhoi, k) end
	if #CacKhoi < 2 then return "Cần 2 khối!" end
	local MoHinh = Instance.new("Model"); MoHinh.Name = "Nhom_" .. math.random(100,999); MoHinh.Parent = KhongGian; local KhoiChinh = CacKhoi[1]
	for _, p in ipairs(CacKhoi) do
		LogicKhoi.SuKienThayDoi:Fire("Xoa", p); for i, v in ipairs(DanhSachKhoi) do if v == p then table.remove(DanhSachKhoi, i) break end end
		p.Parent = MoHinh; if p ~= KhoiChinh then local W = Instance.new("WeldConstraint"); W.Part0 = KhoiChinh; W.Part1 = p; W.Parent = KhoiChinh; p.Anchored = false end
	end
	MoHinh.PrimaryPart = KhoiChinh; KhoiChinh.Anchored = true; table.insert(DanhSachKhoi, MoHinh); LogicKhoi.SuKienThayDoi:Fire("Them", MoHinh)
	CacKhoiDangChon = {[MoHinh] = true}; CongCuHienTai = 1; HienThiUI(true); local MucTieu = MoHinh.PrimaryPart; TaoTayCam(MucTieu); return "Đã hàn nhóm!"
end

function LogicKhoi.ThaoCacKhoi()
	local Dem = 0; local CacModel = {}; for k, _ in pairs(CacKhoiDangChon) do if k:IsA("Model") then table.insert(CacModel, k) end end
	if #CacModel == 0 then return "Không có nhóm!" end
	for _, M in ipairs(CacModel) do
		LogicKhoi.SuKienThayDoi:Fire("Xoa", M); for i, v in ipairs(DanhSachKhoi) do if v == M then table.remove(DanhSachKhoi, i) break end end
		for _, c in ipairs(M:GetChildren()) do if c:IsA("BasePart") then c.Parent = KhongGian; c.Anchored = true; for _, w in ipairs(c:GetChildren()) do if w:IsA("WeldConstraint") then w:Destroy() end end; table.insert(DanhSachKhoi, c); LogicKhoi.SuKienThayDoi:Fire("Them", c); Dem = Dem + 1 end end; M:Destroy()
	end
	LogicKhoi.HuyChon(); return "Đã rã nhóm!"
end

local function LayDoiTuongGoc(Khoi)
	if not Khoi then return nil end
	for _, v in ipairs(DanhSachKhoi) do if v == Khoi or Khoi:IsDescendantOf(v) then return v end end
	return nil
end

local function CapNhatHienThiChon()
	for _, v in ipairs(DanhSachKhoi) do
		local MucTieu = v:IsA("Model") and v.PrimaryPart or v
		if MucTieu and MucTieu:FindFirstChild("HopChon_Hx") then MucTieu.HopChon_Hx:Destroy() end
	end
	local DanhSach = {}
	for k, _ in pairs(CacKhoiDangChon) do table.insert(DanhSach, k) end
	for _, Khoi in ipairs(DanhSach) do
		local MucTieu = Khoi:IsA("Model") and Khoi.PrimaryPart or Khoi
		if MucTieu then
			local HopChon = Instance.new("SelectionBox"); HopChon.Name = "HopChon_Hx"; HopChon.Adornee = MucTieu
			HopChon.LineThickness = CAI_DAT.DO_DAY_VIEN_CHON
			HopChon.Color3 = CAI_DAT.MAU_CHON_BOX; HopChon.Parent = MucTieu
		end
	end

	if #DanhSach > 0 then
		if not GiaoDien.HopChua or not GiaoDien.HopChua.Visible then HienThiUI(true) end
		if #DanhSach == 1 then
			local MucTieu = DanhSach[1]:IsA("Model") and DanhSach[1].PrimaryPart or DanhSach[1]
			TaoTayCam(MucTieu)
		else XoaTayCam() end
	else
		HienThiUI(false); XoaTayCam()
	end
end

DichVuNhapLieu.InputBegan:Connect(function(DauVao, DaXuLyGame)
	if DaXuLyGame then return end
	if DauVao.KeyCode == Enum.KeyCode.One then LogicKhoi.ChinhCongCu(1)
	elseif DauVao.KeyCode == Enum.KeyCode.Two then LogicKhoi.ChinhCongCu(2)
	elseif DauVao.KeyCode == Enum.KeyCode.Three then LogicKhoi.ChinhCongCu(3) end
end)

local TrangThaiNhap = {ThoiGianNhan = 0, DiemBatDau = Vector2.zero, DangGiu = false}

DichVuNhapLieu.InputBegan:Connect(function(DauVao, DaXuLy)
	if DaXuLy then return end
	if DauVao.UserInputType == Enum.UserInputType.MouseButton1 or DauVao.UserInputType == Enum.UserInputType.Touch then
		TrangThaiNhap.DangGiu = true; TrangThaiNhap.ThoiGianNhan = os.clock(); TrangThaiNhap.DiemBatDau = DichVuNhapLieu:GetMouseLocation()
	end
end)

DichVuNhapLieu.InputEnded:Connect(function(DauVao)
	if DauVao.UserInputType == Enum.UserInputType.MouseButton1 or DauVao.UserInputType == Enum.UserInputType.Touch then TrangThaiNhap.DangGiu = false end
end)

DichVuRender.RenderStepped:Connect(function()
	if TrangThaiNhap.DangGiu then
		local ThoiGianTroi = os.clock() - TrangThaiNhap.ThoiGianNhan
		if (DichVuNhapLieu:GetMouseLocation() - TrangThaiNhap.DiemBatDau).Magnitude > CAI_DAT.KHOANG_CACH_GIU then TrangThaiNhap.DangGiu = false; return end
		if ThoiGianTroi >= CAI_DAT.THOI_GIAN_GIU then
			TrangThaiNhap.DangGiu = false
			local MucTieu = Chuot.Target; local Khoi = LayDoiTuongGoc(MucTieu)
			if Khoi then
				if CacKhoiDangChon[Khoi] then LogicKhoi.HuyChon() else
					if not (DichVuNhapLieu:IsKeyDown(Enum.KeyCode.LeftControl) or CheDoDaChon) then CacKhoiDangChon = {} end
					CacKhoiDangChon[Khoi] = true; CongCuHienTai = 1; CheDoScale = 1
					CapNhatGiaoDien(); HieuUngNhan(Khoi:IsA("Model") and Khoi.PrimaryPart or Khoi); CapNhatHienThiChon()
				end
			else
				if not (DichVuNhapLieu:IsKeyDown(Enum.KeyCode.LeftControl) or CheDoDaChon) then LogicKhoi.HuyChon() end
			end
		end
	end
end)

task.delay(1, TaoGiaoDien)
return LogicKhoi
