local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local NguoiChoi = Players.LocalPlayer
local PlayerGui = NguoiChoi:WaitForChild("PlayerGui")
local PlayerScripts = NguoiChoi:WaitForChild("PlayerScripts")

local GuiThongBao = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/ThongBao.lua"))()
local function ThongBao(TieuDe, NoiDung, ThoiGian) GuiThongBao.thongbao(TieuDe, NoiDung, ThoiGian) end
local function ThongBaoLoi(TieuDe, NoiDung) GuiThongBao.thongbaoloi(TieuDe, NoiDung) end

local HoatAnh = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/Animation.lua"))()
local ThuVienUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/ThuVienUI.lua"))()
local ChuDe = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/ChuDe.lua"))()
local MenuConfigManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/MenuConfigManager.lua"))()
local Khoi = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Main_Script/Main_Utilities/Khoi_Logic.lua"))()

MenuConfigManager.SetFileName("main_v2")

local PhimMoMenu = Enum.KeyCode.Insert

local CauHinh = {
	DangTab = false, SoCot = 2,
	ConfigMenu = true, TimKiem = false,
	KichThuoc = { Header = 45, Cach = 8, IconLon = UDim2.new(0, 90, 0, 90) },
	Asset = { Icon = "rbxassetid://117118515787811", MuiTenXuong = "rbxassetid://6031091004" },
	VanBan = { Nut = 14, Nho = 13, TieuDe = 15 },
	Mau = {}
}

for k, v in pairs(ChuDe.MacDinh) do CauHinh.Mau[k] = v end

local function BaoTrangThai(TenChucNang, TrangThai)
	local NoiDung = TrangThai and "Đã bật " .. TenChucNang or "Đã tắt " .. TenChucNang
	ThongBao("Hx Script", NoiDung, 2)
end

local DuLieuDanhSachKhoiUI = {}
local TimChucNang

local TrangThaiLuu = {
	ReduceLags = false,
	RemoveFog = false,
	FullBright = false,
	NoShadows = false,
	PhimMoMenu = "Insert",
	ChuDeUI = {Ten = "Dark"}
}

local function LuuConfig()
	MenuConfigManager.Save(TrangThaiLuu)
end

CauHinh.LuuTheme = function(duLieuTheme)
	TrangThaiLuu.ChuDeUI = duLieuTheme
	LuuConfig()
end

local function TaoCauTrucItemChoKhoi(Obj)
	local TenHienThi = Obj.Name
	local LaNhom = Obj:IsA("Model")
	local CheckPart = LaNhom and Obj.PrimaryPart or Obj
	if not CheckPart and LaNhom then
		for _, v in pairs(Obj:GetChildren()) do
			if v:IsA("BasePart") then CheckPart = v break end
		end
	end
	local IsAnchored = CheckPart and CheckPart.Anchored or true
	local IsLocked = CheckPart and CheckPart.Locked or false
	local IsMoveLocked = Obj:GetAttribute("KhoaDiChuyen") == true

	local function SetAnchored(TrangThai)
		if LaNhom then
			for _, child in pairs(Obj:GetDescendants()) do
				if child:IsA("BasePart") then child.Anchored = TrangThai end
			end
		elseif Obj:IsA("BasePart") then
			Obj.Anchored = TrangThai
		end
	end

	local function SetLocked(TrangThai)
		local Khoa = not TrangThai
		if LaNhom then
			for _, child in pairs(Obj:GetDescendants()) do
				if child:IsA("BasePart") then child.Locked = Khoa end
			end
		elseif Obj:IsA("BasePart") then
			Obj.Locked = Khoa
		end
	end

	return {
		Ten = LaNhom and "[NHÓM] " .. TenHienThi or TenHienThi,
		Loai = "Gat",
		HienTai = "Bat",
		SuKien = function(TrangThai)
			if LaNhom then
				for _, child in pairs(Obj:GetDescendants()) do
					if child:IsA("BasePart") then child.Transparency = TrangThai and 0 or 1 end
				end
			else
				if Obj then Obj.Transparency = TrangThai and 0 or 1 end
			end
		end,
		CacNutCon = {
			{
				Ten = "Cho Phép Chọn Khối",
				Loai = "Gat",
				HienTai = not IsLocked and "Bat" or "Tat",
				CacNutCon = {
					{
						Ten = "Cho Phép Di Chuyển",
						Loai = "Gat",
						HienTai = not IsMoveLocked and "Bat" or "Tat",
						SuKien = function(TrangThai)
							if Obj then Obj:SetAttribute("KhoaDiChuyen", not TrangThai) end
							if TrangThai then
								ThongBao("Hx Script", "Đã mở khóa di chuyển: " .. TenHienThi, 2)
							else
								ThongBao("Hx Script", "Đã khóa vị trí: " .. TenHienThi, 2)
							end
						end
					},
					{
						Ten = "Neo Khối",
						Loai = "Gat",
						HienTai = IsAnchored and "Bat" or "Tat",
						SuKien = function(TrangThai)
							SetAnchored(TrangThai)
							if TrangThai then
								ThongBao("Hx Script", "Đã Neo khối (Đứng yên)", 2)
							else
								ThongBao("Hx Script", "Đã Tháo Neo (Rơi tự do)", 2)
							end
						end
					}
				},
				SuKien = function(TrangThai)
					SetLocked(TrangThai)
					if not TrangThai then Khoi.CheckHuy(Obj) end
					BaoTrangThai("khả năng chọn khối " .. TenHienThi, TrangThai)
				end
			}
		}
	}
end

Khoi.SuKienThayDoi.Event:Connect(function(HanhDong, DoiTuong)
	if HanhDong == "Them" then
		table.insert(DuLieuDanhSachKhoiUI, TaoCauTrucItemChoKhoi(DoiTuong))
	elseif HanhDong == "Xoa" then
		for i, v in ipairs(DuLieuDanhSachKhoiUI) do
			if v.Ten == DoiTuong.Name or v.Ten == "[NHÓM] " .. DoiTuong.Name then
				table.remove(DuLieuDanhSachKhoiUI, i)
				break
			end
		end
	end
	local cn = TimChucNang("Danh Sách")
	if cn and cn.LamMoi then cn.LamMoi() end
end)

CauHinh.ExtraConfig = {
	{ Ten = "Reduce Lags", Loai = "Gat", HienTai = "Tat", SuKien = function(st) MenuConfigManager.ReduceLags(st) TrangThaiLuu.ReduceLags = st LuuConfig() end },
	{ Ten = "Removes Fog", Loai = "Gat", HienTai = "Tat", SuKien = function(st) MenuConfigManager.RemoveFog(st) TrangThaiLuu.RemoveFog = st LuuConfig() end },
	{ Ten = "Fully Bright", Loai = "Gat", HienTai = "Tat", SuKien = function(st) MenuConfigManager.FullBright(st) TrangThaiLuu.FullBright = st LuuConfig() end },
	{ Ten = "No Shadows", Loai = "Gat", HienTai = "Tat", SuKien = function(st) MenuConfigManager.NoShadows(st) TrangThaiLuu.NoShadows = st LuuConfig() end },
	{ Ten = "HotKeys Open Menu", Loai = "PhimNong", HienTai = "Insert", SuKien = function(key) PhimMoMenu = key TrangThaiLuu.PhimMoMenu = key.Name LuuConfig() end }
}

local DanhSachNhom = {
	{
		TieuDe = "Main Transform",
		ChucNang = {
			{
				Ten = "Chức Năng Biến Hình",
				Loai = "Gat",
				HienTai = "Bat",
				CacNutCon = {
					{ Ten = "Hiển Thị Nút Chức Năng", Loai = "Gat", HienTai = "Bat", SuKien = function(TrangThai) BaoTrangThai("hiển thị nút chức năng thành công!", TrangThai) end },
					{ Ten = "Hiển thị Outline Vùng Chọn", Loai = "Gat", HienTai = "Bat", SuKien = function(TrangThai) BaoTrangThai("hiển thị outline vùng chọn cho các part.", TrangThai) end }
				},
				SuKien = function(TrangThai) BaoTrangThai("chức năng biến hình!", TrangThai) end
			}
		}
	},
	{
		TieuDe = "Nhân Vật Transform",
		ChucNang = {
			{ Loai = "NhieuNut", Ten1 = "Tạo Nhân Vật Mẫu", SuKien1 = function() ThongBaoLoi("Hx Script", "Tính năng đang phát triển!") end, Ten2 = "Xóa Nhân Vật Chọn", SuKien2 = function() ThongBaoLoi("Hx Script", "Tính năng đang phát triển!") end },
			{ Ten = "Cho Phép Di Chuyển", Loai = "Gat", HienTai = "Bat", SuKien = function(TrangThai) ThongBaoLoi("Hx Script", "Tính năng đang phát triển!") end },
			{ Ten = "Cho Phép Chọn", Loai = "Gat", HienTai = "Bat", SuKien = function(TrangThai) ThongBaoLoi("Hx Script", "Tính năng đang phát triển!") end },
			{ Ten = "Transform", Loai = "Nut", SuKien = function() ThongBaoLoi("Hx Script", "Tính năng đang phát triển!") end }
		}
	},
	{
		TieuDe = "Thành Phần Transform",
		ChucNang = {
			{
				Ten = "Thành Phần",
				Loai = "HopXo",
				HienTai = "Toàn Thân",
				LuaChon = {
					"Toàn Thân",
					{
						Ten = "Từng Phần",
						CacNutCon = {
							{
								Ten = "Phần Đầu", Loai = "Gat", HienTai = "Bat", LoaiNutCon = "CungHang",
								CacNutCon = {
									{ Ten = "Lưu Trữ", SuKien = function() ThongBao("Hx Script", "Đã lưu trữ Phần Đầu!", 3) end },
									{ Ten = "Xóa Lưu", SuKien = function() ThongBao("Hx Script", "Đã xóa lưu Phần Đầu!", 3) end }
								}
							},
							{
								Ten = "Phần Thân", Loai = "Gat", HienTai = "Bat", LoaiNutCon = "CungHang",
								CacNutCon = {
									{ Ten = "Lưu Trữ", SuKien = function() ThongBao("Hx Script", "Đã lưu trữ Phần Thân!", 3) end },
									{ Ten = "Xóa Lưu", SuKien = function() ThongBao("Hx Script", "Đã xóa lưu Phần Thân!", 3) end }
								}
							}
						}
					},
					"Nhân Vật"
				}
			}
		}
	},
	{
		TieuDe = "Tạo Khối",
		ChucNang = {
			{
				Loai = "NhieuNut",
				Ten1 = "Tạo Khối Mẫu", SuKien1 = function() local TenKhoi = Khoi.TaoBlock() if TenKhoi then ThongBao("Hx Script", "Đã tạo: " .. TenKhoi, 1) end end,
				Ten2 = "Xóa Khối Chọn", SuKien2 = function() Khoi.XoaChon() ThongBao("Hx Script", "Đã xóa các khối được chọn!", 1) end
			},
			{ Ten = "Danh Sách", Loai = "Danhsach", Danhsach = DuLieuDanhSachKhoiUI },
			{
				Loai = "NhieuNut",
				Ten1 = "Hàn Khối", SuKien1 = function() local Msg = Khoi.HanKhoi() ThongBao("Hx Build", Msg, 2) end,
				Ten2 = "Tháo Hàn", SuKien2 = function() local Msg = Khoi.ThaoKhoi() ThongBao("Hx Build", Msg, 2) end
			}
		}
	}
}

local function DuyetChucNang(DanhSach, TenChucNang)
	for _, CN in ipairs(DanhSach) do
		if CN.Ten == TenChucNang then return CN end
		if CN.CacNutCon then local res = DuyetChucNang(CN.CacNutCon, TenChucNang) if res then return res end end
	end return nil
end

function TimChucNang(TenChucNang)
	for _, KhoiObj in ipairs(DanhSachNhom) do 
		local res = DuyetChucNang(KhoiObj.ChucNang, TenChucNang) 
		if res then return res end 
	end 
	local resConfig = DuyetChucNang(CauHinh.ExtraConfig, TenChucNang)
	if resConfig then return resConfig end
	return nil
end

local function ApDungConfig(cfg)
	if not cfg then return end
	if cfg.ReduceLags then 
		MenuConfigManager.KichHoat(true) 
		local cn = TimChucNang("Reduce Lags") 
		if cn then cn.HienTai = "Bat" end 
	end
	if cfg.PhimMoMenu then 
		pcall(function() PhimMoMenu = Enum.KeyCode[cfg.PhimMoMenu] end) 
		local cn = TimChucNang("HotKeys Open Menu") 
		if cn then cn.HienTai = cfg.PhimMoMenu end 
	end
	if cfg.ChuDeUI then CauHinh.ChuDeDaLuu = cfg.ChuDeUI end
	for k, v in pairs(cfg) do TrangThaiLuu[k] = v end
end

ApDungConfig(MenuConfigManager.Load())

local function TaoGiaoDien()
	if PlayerGui:FindFirstChild("main_v2") then PlayerGui.main_v2:Destroy() end

	local ManHinhGui = Instance.new("ScreenGui") 
	ManHinhGui.Name = "main_v2" ManHinhGui.ResetOnSpawn = false ManHinhGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling ManHinhGui.Parent = PlayerGui

	local LopPhu = Instance.new("Frame", ManHinhGui) 
	LopPhu.Name = "LopPhu" LopPhu.Size = UDim2.fromScale(1, 1) LopPhu.BackgroundTransparency = 1 LopPhu.ZIndex = 100

	local ClickNgoai = Instance.new("TextButton", ManHinhGui) 
	ClickNgoai.Size = UDim2.fromScale(1, 1) ClickNgoai.BackgroundTransparency = 1 ClickNgoai.Text = "" ClickNgoai.Visible = false ClickNgoai.ZIndex = 99

	local function DongTatCaXoXuong() for _, PhanTuXo in ipairs(LopPhu:GetChildren()) do PhanTuXo:Destroy() end ClickNgoai.Visible = false end
	ClickNgoai.MouseButton1Click:Connect(DongTatCaXoXuong)

	local NutMoUI = Instance.new("ImageButton", ManHinhGui) 
	NutMoUI.Name = "NutMoUI" NutMoUI.Size = UDim2.new(0, 45, 0, 45) NutMoUI.Position = UDim2.new(0, 30, 0.4, 0) NutMoUI.Image = CauHinh.Asset.Icon NutMoUI.BackgroundColor3 = CauHinh.Mau.Nen NutMoUI.BackgroundTransparency = 0.2 NutMoUI.Active = true NutMoUI.ZIndex = 999 
	Instance.new("UICorner", NutMoUI).CornerRadius = UDim.new(0, 10) HoatAnh.KeoTha(NutMoUI, NutMoUI)

	local KhungChinh = Instance.new("Frame", ManHinhGui) 
	KhungChinh.Name = "KhungChinh" KhungChinh.Size = CauHinh.KichThuoc.IconLon KhungChinh.Position = UDim2.new(0.5, 0, 0.5, 0) KhungChinh.AnchorPoint = Vector2.new(0.5, 0.5) KhungChinh.BackgroundColor3 = CauHinh.Mau.Nen KhungChinh.BackgroundTransparency = 0.4 KhungChinh.ClipsDescendants = true KhungChinh.Visible = false KhungChinh.Active = true 
	Instance.new("UICorner", KhungChinh).CornerRadius = UDim.new(0, 14)

	local GioiHamKichThuoc = Instance.new("UISizeConstraint", KhungChinh) GioiHamKichThuoc.MinSize = Vector2.new(450, 350)

	local BieuTuong = Instance.new("ImageLabel", KhungChinh) 
	BieuTuong.Size = UDim2.fromOffset(0, 0) BieuTuong.Position = UDim2.new(0.5, 0, 0.5, 0) BieuTuong.AnchorPoint = Vector2.new(0.5, 0.5) BieuTuong.Image = CauHinh.Asset.Icon BieuTuong.BackgroundTransparency = 0.6 BieuTuong.BackgroundColor3 = Color3.new(0, 0, 0) BieuTuong.ZIndex = 2 
	Instance.new("UICorner", BieuTuong).CornerRadius = UDim.new(0, 10)

	local KhungBaoNoiDung = Instance.new("Frame", KhungChinh) 
	KhungBaoNoiDung.Name = "KhungBaoNoiDung" KhungBaoNoiDung.Size = UDim2.fromScale(1, 1) KhungBaoNoiDung.BackgroundTransparency = 1 KhungBaoNoiDung.ZIndex = 2

	local TieuDe = Instance.new("TextLabel", KhungBaoNoiDung) 
	TieuDe.Text = "Hx - Transform Script" TieuDe.Size = UDim2.new(1, -150, 0, 50) TieuDe.Position = UDim2.new(0, 60, 0, 5) TieuDe.BackgroundTransparency = 1 TieuDe.TextColor3 = CauHinh.Mau.Chu TieuDe.Font = Enum.Font.GothamBold TieuDe.TextSize = 18 TieuDe.TextXAlignment = Enum.TextXAlignment.Left TieuDe.TextTransparency = 1 TieuDe.ZIndex = 5

	local VungCuon = Instance.new("ScrollingFrame", KhungChinh) 
	VungCuon.Size = UDim2.new(1, -24, 1, -65) VungCuon.Position = UDim2.new(0.5, 0, 1, -12) VungCuon.AnchorPoint = Vector2.new(0.5, 1) VungCuon.BackgroundColor3 = CauHinh.Mau.NenList VungCuon.BackgroundTransparency = 0.6 VungCuon.ScrollBarThickness = 6 VungCuon.BorderSizePixel = 0 VungCuon.ZIndex = 2 
	Instance.new("UICorner", VungCuon).CornerRadius = UDim.new(0, 8)

	local VienVungCuon = Instance.new("UIStroke", VungCuon) 
	VienVungCuon.Name = "VienNeon" VienVungCuon.Color = CauHinh.Mau.VienNeon VienVungCuon.Transparency = 0.5 VienVungCuon.Thickness = 0.5 VungCuon.AutomaticCanvasSize = Enum.AutomaticSize.Y VungCuon.CanvasSize = UDim2.new(0, 0, 0, 0)

	local CacPhanTu = { Khung = KhungChinh, Icon = BieuTuong, TieuDe = TieuDe, KhungNoiDung = VungCuon }
	local CauHinhHieuUng = { IconDau = CauHinh.KichThuoc.IconLon, IconCuoi = UDim2.new(0, 40, 0, 40), ViTriIconDau = UDim2.new(0.5, 0, 0.5, 0), ViTriIconCuoi = UDim2.new(0, 30, 0, 30), KhungDau = CauHinh.KichThuoc.IconLon, KhungCuoi = UDim2.fromScale(0.55, 0.6), DoTrongSuotKhung = 0.4, KichThuocNutDongNay = UDim2.new(0, 45, 0, 45) }
	HoatAnh.KeoTha(KhungChinh, KhungChinh)

	local DangHanhDong = false
	local function DongGiaoDien()
		if DangHanhDong or not KhungChinh.Visible then return end
		DangHanhDong = true
		HoatAnh.DongGiaoDien(CacPhanTu, CauHinhHieuUng, function() KhungChinh.Visible = false DangHanhDong = false end)
	end

	local function PhaHuyUI()
		GuiThongBao.thongbaoxacnhan("XÁC NHẬN", "Bạn có chắc chắn muốn đóng UI không?", function()
			if Khoi and Khoi.HuyChon then Khoi.HuyChon() end
			if PlayerGui:FindFirstChild("main_v2") then PlayerGui.main_v2:Destroy() end
			if shared.HxKeybindEvent then shared.HxKeybindEvent:Disconnect() end
		end)
	end

	local PhanTuToolbar = ThuVienUI.Tao(KhungChinh, VungCuon, DanhSachNhom, CauHinh, LopPhu, function() DongTatCaXoXuong() ClickNgoai.Visible = true end, PhaHuyUI, DongGiaoDien)
	CacPhanTu.NutDong = PhanTuToolbar.NutMin    
	CacPhanTu.VienNutDong = PhanTuToolbar.VienMin
	CacPhanTu.Toolbar = PhanTuToolbar.Toolbar

	local function MoGiaoDien()
		if DangHanhDong or KhungChinh.Visible then return end
		DangHanhDong = true
		KhungChinh.Visible = true
		if CacPhanTu.NutDong then CacPhanTu.NutDong.Size = UDim2.fromOffset(35, 35) end
		CauHinhHieuUng.DoTrongSuotKhung = CauHinh.DoTrongSuotKhung or 0.4
		HoatAnh.MoGiaoDien(CacPhanTu, CauHinhHieuUng)
		task.delay(0.2, function() DangHanhDong = false end)
		if PhanTuToolbar and PhanTuToolbar.CapNhatTab then task.delay(1.1, PhanTuToolbar.CapNhatTab) end
	end

	NutMoUI.MouseButton1Click:Connect(function() HoatAnh.NhanChuot(NutMoUI) if KhungChinh.Visible then DongGiaoDien() else MoGiaoDien() end end)

	UserInputService.InputBegan:Connect(function(DauVaoBanPhim, DaXuLy)
		if shared.HxDangChinhPhim == true or DaXuLy then return end
		if DauVaoBanPhim.KeyCode == PhimMoMenu then if KhungChinh.Visible then DongGiaoDien() else MoGiaoDien() end end
	end)

	MoGiaoDien()
end

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1) TaoGiaoDien()
