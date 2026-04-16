local DichVuNguoiChoi = game:GetService("Players")
local DichVuTween = game:GetService("TweenService")
local DichVuDauVao = game:GetService("UserInputService")
local NguoiChoi = DichVuNguoiChoi.LocalPlayer
local GiaoDienNguoiChoi = NguoiChoi:WaitForChild("PlayerGui")
local KichBanNguoiChoi = NguoiChoi:WaitForChild("PlayerScripts")
local Chuot = NguoiChoi:GetMouse()

local GuiThongBao = require(KichBanNguoiChoi:WaitForChild("Notify"))
local function ThongBao(TieuDe, NoiDung, ThoiGian) GuiThongBao.thongbao(TieuDe, NoiDung, ThoiGian) end
local function ThongBaoLoi(TieuDe, NoiDung) GuiThongBao.thongbaoloi(TieuDe, NoiDung) end

local HoatAnh = require(KichBanNguoiChoi:WaitForChild("Animation"))
local KhungCuon = require(KichBanNguoiChoi:WaitForChild("KhungCuon"))
local AutoClickLogic = require(KichBanNguoiChoi:WaitForChild("AutoClick_Logic"))

local PhimMoMenu = Enum.KeyCode.Insert
local CauHinh = {
	SoCot = 2,
	Mau = {
		Nen = Color3.fromRGB(15, 15, 15),
		NenList = Color3.fromRGB(25, 25, 25),
		NenKhoi = Color3.fromRGB(35, 35, 35),
		NenMuc = Color3.fromRGB(50, 50, 50),
		NenHop = Color3.fromRGB(15, 15, 15),
		NenDanhSachMo = Color3.fromRGB(65, 70, 75),
		VienHop = Color3.fromRGB(80, 80, 80),
		VienNeon = Color3.fromRGB(255, 255, 255),
		NenPhu = Color3.fromRGB(45, 45, 45),
		ChonPhu = Color3.fromRGB(60, 60, 60),
		TichBat = Color3.fromRGB(180, 180, 180),
		NutDong = Color3.fromRGB(80, 80, 80),
		NutDongLuot = Color3.fromRGB(200, 0, 0),
		Chu = Color3.fromRGB(240, 240, 240),
		ChuMo = Color3.fromRGB(180, 180, 180),
		Vien = Color3.fromRGB(255, 255, 255)
	},
	KichThuoc = { Header = 45, Cach = 8, NutDong = 35, IconLon = UDim2.new(0, 90, 0, 90), IconNho = UDim2.new(0, 40, 0, 40) },
	Asset = { Icon = "rbxassetid://117118515787811", MuiTenXuong = "rbxassetid://6031091004" },
	VanBan = { Nut = 20, Nho = 14, TieuDe = 16 }
}

local DuLieuDanhSachClick = {}
local TaiLaiGiaoDien = nil

local function CapNhatDanhSachClick()
	for ViTri, DuLieuDanhSach in ipairs(DuLieuDanhSachClick) do
		DuLieuDanhSach.Ten = "Click " .. ViTri .. " (" .. math.floor(DuLieuDanhSach.X) .. "," .. math.floor(DuLieuDanhSach.Y) .. ")"
	end
	AutoClickLogic.CapNhatDiem(DuLieuDanhSachClick)
	if TaiLaiGiaoDien then task.defer(TaiLaiGiaoDien) end
end

local function TaoItemClick(ToaDoX, ToaDoY)
	local DuLieuNut = { X = ToaDoX, Y = ToaDoY, DaAn = false }
	DuLieuNut.Loai = "Otich"
	DuLieuNut.HienTai = "Bat"
	DuLieuNut.SuKien = function(TrangThai)
		ThongBao("Auto Click", TrangThai and ("Đã bật " .. DuLieuNut.Ten) or ("Đã tắt " .. DuLieuNut.Ten), 1)
	end
	DuLieuNut.CacNutCon = {
		{
			Ten = "Hide Click Location",
			Loai = "Otich",
			HienTai = "Tat",
			SuKien = function(TrangThai)
				DuLieuNut.DaAn = TrangThai
				AutoClickLogic.CapNhatDiem(DuLieuDanhSachClick)
				ThongBao("Hx Script", TrangThai and "Đã ẩn UI " .. DuLieuNut.Ten or "Đã hiện UI " .. DuLieuNut.Ten, 1)
			end
		},
		{
			Loai = "NhieuNut",
			DanhSachNut = {
				{
					Ten = "Up",
					SuKien = function()
						local ViTriNut = nil
						for ViTriTim, DuLieuTim in ipairs(DuLieuDanhSachClick) do if DuLieuTim == DuLieuNut then ViTriNut = ViTriTim break end end
						if ViTriNut and ViTriNut > 1 then
							DuLieuDanhSachClick[ViTriNut], DuLieuDanhSachClick[ViTriNut - 1] = DuLieuDanhSachClick[ViTriNut - 1], DuLieuDanhSachClick[ViTriNut]
							CapNhatDanhSachClick()
						end
					end
				},
				{
					Ten = "Delete",
					SuKien = function()
						for ViTriXoa, DuLieuXoa in ipairs(DuLieuDanhSachClick) do
							if DuLieuXoa == DuLieuNut then table.remove(DuLieuDanhSachClick, ViTriXoa) break end
						end
						CapNhatDanhSachClick()
						ThongBao("Hx Script", "Đã xóa 1 vị trí", 1)
					end
				},
				{
					Ten = "Down",
					SuKien = function()
						local ViTriNut = nil
						for ViTriTim, DuLieuTim in ipairs(DuLieuDanhSachClick) do if DuLieuTim == DuLieuNut then ViTriNut = ViTriTim break end end
						if ViTriNut and ViTriNut < #DuLieuDanhSachClick then
							DuLieuDanhSachClick[ViTriNut], DuLieuDanhSachClick[ViTriNut + 1] = DuLieuDanhSachClick[ViTriNut + 1], DuLieuDanhSachClick[ViTriNut]
							CapNhatDanhSachClick()
						end
					end
				}
			}
		}
	}
	return DuLieuNut
end

local TrangThaiAnTatCa = false
local ChucNangAnTao = { Loai = "NhieuNut", Ten1 = "Create Click", Ten2 = "Hide All: OFF" }

ChucNangAnTao.SuKien1 = function()
	local KichThuocManHinh = workspace.CurrentCamera.ViewportSize
	local ToaDoX = KichThuocManHinh.X * 0.5
	local ToaDoY = KichThuocManHinh.Y * 0.5

	local NutMoi = TaoItemClick(ToaDoX, ToaDoY)
	table.insert(DuLieuDanhSachClick, NutMoi)
	CapNhatDanhSachClick()
	ThongBao("Hx Script", "Đã tạo điểm click tại: " .. math.floor(ToaDoX) .. ", " .. math.floor(ToaDoY), 1.5)
end

ChucNangAnTao.SuKien2 = function()
	TrangThaiAnTatCa = not TrangThaiAnTatCa
	ChucNangAnTao.Ten2 = TrangThaiAnTatCa and "Hide All: ON" or "Hide All: OFF"
	AutoClickLogic.BatTatAnToanBo(TrangThaiAnTatCa)
	ThongBao("Hx Script", TrangThaiAnTatCa and "Đã ẩn mọi vị trí" or "Đã hiện vị trí", 1)
	if TaiLaiGiaoDien then task.defer(TaiLaiGiaoDien) end
end

local DanhSachNhom = {
	{
		TieuDe = "Auto Click Config",
		ChucNang = {
			{
				Ten = "Auto Click", Loai = "Otich", HienTai = "Tat",
				SuKien = function(TrangThai)
					AutoClickLogic.BatTatAutoClick(TrangThai)
					ThongBao("Hx Script", TrangThai and "Đã BẬT Auto Click" or "Đã TẮT Auto Click", 2)
				end
			},
			{
				Ten = "Speed Click (ms)", Loai = "Odien", HienTai = "2000", GoiY = "Nhập tốc độ...",
				SuKien = function(GiaTri)
					if tonumber(GiaTri) then
						AutoClickLogic.CaiDatTocDo(GiaTri)
						ThongBao("Hx Script", "Chỉnh tốc độ: " .. GiaTri .. "ms", 1)
					else ThongBaoLoi("Hx Script", "Tốc độ phải là số!") end
				end
			},
			ChucNangAnTao,
			{ Ten = "List Of Click Locations", Loai = "Danhsach", DangMo = false, Danhsach = DuLieuDanhSachClick }
		}
	},
	{
		TieuDe = "Config Menu",
		ChucNang = {
			{ Ten = "Reduce Lags", Loai = "Otich", HienTai = "Tat", SuKien = function(TrangThai) end },
			{
				Ten = "HotKeys Open Menu", Loai = "HopXo", HienTai = "Insert", LuaChon = {"Insert", "Shift Right", "Ctrl Right"},
				SuKien = function(GiaTri)
					if GiaTri == "Insert" then PhimMoMenu = Enum.KeyCode.Insert
					elseif GiaTri == "Shift Right" then PhimMoMenu = Enum.KeyCode.RightShift
					elseif GiaTri == "Ctrl Right" then PhimMoMenu = Enum.KeyCode.RightControl end
					ThongBao("Hx Script", "Đổi phím tắt: " .. GiaTri, 2)
				end
			}
		}
	}
}

local function TaoGiaoDien()
	if GiaoDienNguoiChoi:FindFirstChild("AutoClickUI") then GiaoDienNguoiChoi.AutoClickUI:Destroy() end
	local DangHanhDong = false
	local KiemTraDienThoai = (DichVuDauVao.TouchEnabled and not DichVuDauVao.KeyboardEnabled)
	local KichThuocMo = UDim2.fromScale(0.7, 0.65)

	local ManHinhGui = Instance.new("ScreenGui")
	ManHinhGui.Name = "AutoClickUI"
	ManHinhGui.ResetOnSpawn = false
	ManHinhGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ManHinhGui.Parent = GiaoDienNguoiChoi

	local LopPhu = Instance.new("Frame", ManHinhGui)
	LopPhu.Name = "LopPhu"
	LopPhu.Size = UDim2.fromScale(1,1)
	LopPhu.BackgroundTransparency = 1
	LopPhu.ZIndex = 100

	local ClickNgoai = Instance.new("TextButton", ManHinhGui)
	ClickNgoai.Size = UDim2.fromScale(1,1)
	ClickNgoai.BackgroundTransparency = 1
	ClickNgoai.Text = ""
	ClickNgoai.Visible = false
	ClickNgoai.ZIndex = 99

	local function DongTatCaXoXuong()
		for _, PhanTuXo in ipairs(LopPhu:GetChildren()) do PhanTuXo:Destroy() end
		ClickNgoai.Visible = false
	end
	ClickNgoai.MouseButton1Click:Connect(DongTatCaXoXuong)

	local NutMoUI = Instance.new("ImageButton", ManHinhGui)
	NutMoUI.Name = "NutMoUI"
	NutMoUI.Size = UDim2.new(0,45,0,45)
	NutMoUI.Position = UDim2.new(0,30,0.4,0)
	NutMoUI.Image = CauHinh.Asset.Icon
	NutMoUI.BackgroundColor3 = CauHinh.Mau.Nen
	NutMoUI.BackgroundTransparency = 0.2
	Instance.new("UICorner", NutMoUI).CornerRadius = UDim.new(0, 10)
	HoatAnh.KeoTha(NutMoUI, NutMoUI)

	local KhungChinh = Instance.new("Frame", ManHinhGui)
	KhungChinh.Name = "KhungChinh"
	KhungChinh.Size = CauHinh.KichThuoc.IconLon
	KhungChinh.Position = UDim2.new(0.5,0,0.5,0)
	KhungChinh.AnchorPoint = Vector2.new(0.5,0.5)
	KhungChinh.BackgroundColor3 = CauHinh.Mau.Nen
	KhungChinh.BackgroundTransparency = 1
	KhungChinh.ClipsDescendants = true
	KhungChinh.Visible = false
	Instance.new("UICorner", KhungChinh).CornerRadius = UDim.new(0, 14)
	local GioiHanKichThuoc = Instance.new("UISizeConstraint", KhungChinh)
	GioiHanKichThuoc.MinSize = Vector2.new(450, 350)

	local BieuTuong = Instance.new("ImageLabel", KhungChinh)
	BieuTuong.Size = UDim2.fromOffset(0,0)
	BieuTuong.Position = UDim2.new(0.5,0,0.5,0)
	BieuTuong.AnchorPoint = Vector2.new(0.5,0.5)
	BieuTuong.Image = CauHinh.Asset.Icon
	BieuTuong.BackgroundTransparency = 0.6
	BieuTuong.BackgroundColor3 = Color3.new(0,0,0)
	BieuTuong.ZIndex = 2
	Instance.new("UICorner", BieuTuong).CornerRadius = UDim.new(0, 10)

	local KhungBaoNoiDung = Instance.new("Frame", KhungChinh)
	KhungBaoNoiDung.Name = "KhungBaoNoiDung"
	KhungBaoNoiDung.Size = UDim2.fromScale(1,1)
	KhungBaoNoiDung.BackgroundTransparency = 1
	KhungBaoNoiDung.ZIndex = 2

	local TieuDe = Instance.new("TextLabel", KhungBaoNoiDung)
	TieuDe.Text = "Hx - Something Script"
	TieuDe.Size = UDim2.new(1,-90,0,50)
	TieuDe.Position = UDim2.new(0,60,0,5)
	TieuDe.BackgroundTransparency = 1
	TieuDe.TextColor3 = CauHinh.Mau.Chu
	TieuDe.Font = Enum.Font.GothamBold
	TieuDe.TextSize = 22
	TieuDe.TextXAlignment = Enum.TextXAlignment.Left
	TieuDe.TextTransparency = 1
	TieuDe.ZIndex = 5

	local NutDong = Instance.new("TextButton", KhungChinh)
	NutDong.Size = UDim2.fromOffset(CauHinh.KichThuoc.NutDong, CauHinh.KichThuoc.NutDong)
	NutDong.Position = UDim2.new(1,-30,0,30)
	NutDong.AnchorPoint = Vector2.new(0.5,0.5)
	NutDong.Text = "X"
	NutDong.TextSize = 22
	NutDong.Font = Enum.Font.GothamBlack
	NutDong.BackgroundColor3 = CauHinh.Mau.NutDong
	NutDong.TextColor3 = CauHinh.Mau.Chu
	NutDong.ZIndex = 10
	NutDong.Transparency = 1
	Instance.new("UICorner", NutDong).CornerRadius = UDim.new(0, 8)
	local VienNutDong = Instance.new("UIStroke", NutDong)
	VienNutDong.Color = CauHinh.Mau.VienNeon
	VienNutDong.Transparency = 1
	VienNutDong.Thickness = 2
	VienNutDong.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local VungCuon = Instance.new("ScrollingFrame", KhungChinh)
	VungCuon.Size = UDim2.new(1,-24,1,-65)
	VungCuon.Position = UDim2.new(0.5,0,1,-12)
	VungCuon.AnchorPoint = Vector2.new(0.5,1)
	VungCuon.BackgroundColor3 = CauHinh.Mau.NenList
	VungCuon.BackgroundTransparency = 0.6
	VungCuon.ScrollBarThickness = 6
	VungCuon.BorderSizePixel = 0
	VungCuon.ZIndex = 2
	Instance.new("UICorner", VungCuon).CornerRadius = UDim.new(0, 8)
	local VienVungCuon = Instance.new("UIStroke", VungCuon)
	VienVungCuon.Color = CauHinh.Mau.VienNeon
	VienVungCuon.Transparency = 0.5
	VienVungCuon.Thickness = 0.5

	TaiLaiGiaoDien = function()
		if not VungCuon or not VungCuon.Parent then return end
		for _, PhanTuCu in ipairs(VungCuon:GetChildren()) do
			if PhanTuCu:IsA("GuiObject") or PhanTuCu:IsA("UIListLayout") then PhanTuCu:Destroy() end
		end
		KhungCuon.Tao(VungCuon, DanhSachNhom, CauHinh, LopPhu, function()
			DongTatCaXoXuong()
			ClickNgoai.Visible = true
		end)
	end
	TaiLaiGiaoDien()

	local CacPhanTu = { Khung = KhungChinh, Icon = BieuTuong, TieuDe = TieuDe, NutDong = NutDong, VienNutDong = VienNutDong, KhungNoiDung = VungCuon }
	local CauHinhHieuUng = { IconDau = CauHinh.KichThuoc.IconLon, IconCuoi = CauHinh.KichThuoc.IconNho, ViTriIconDau = UDim2.new(0.5,0,0.5,0), ViTriIconCuoi = UDim2.new(0,30,0,30), KhungDau = CauHinh.KichThuoc.IconLon, KhungCuoi = KichThuocMo, KichThuocNutDongNay = UDim2.new(0,50,0,50), DoTrongSuotKhung = 0.15 }

	HoatAnh.KeoTha(KhungChinh, KhungChinh)

	local function DongGiaoDien()
		if DangHanhDong or not KhungChinh.Visible then return end
		DangHanhDong = true
		HoatAnh.DongGiaoDien(CacPhanTu, CauHinhHieuUng, function() KhungChinh.Visible = false DangHanhDong = false end)
	end

	local function MoGiaoDien()
		if DangHanhDong or KhungChinh.Visible then return end
		DangHanhDong = true
		KhungChinh.Visible = true
		NutDong.Size = UDim2.fromOffset(CauHinh.KichThuoc.NutDong, CauHinh.KichThuoc.NutDong)
		NutDong.BackgroundColor3 = CauHinh.Mau.NutDong
		HoatAnh.MoGiaoDien(CacPhanTu, CauHinhHieuUng)
		task.delay(0.2, function() DangHanhDong = false end)
	end

	local NutDongThuong = { Size = UDim2.fromOffset(35, 35), BackgroundColor3 = CauHinh.Mau.NutDong, BackgroundTransparency = 0.6, TextSize = 22, TextColor3 = CauHinh.Mau.Chu }
	local NutDongLuot = { Size = KiemTraDienThoai and UDim2.fromOffset(35, 35) or UDim2.fromOffset(40, 40), BackgroundColor3 = CauHinh.Mau.NutDongLuot, BackgroundTransparency = 0, TextSize = 26, TextColor3 = Color3.new(1,1,1) }

	NutDong.MouseEnter:Connect(function()
		if not DangHanhDong then
			HoatAnh.LuotChuot(NutDong, true, NutDongLuot, NutDongThuong)
			DichVuTween:Create(VienNutDong, TweenInfo.new(0.3), {Transparency = 0}):Play()
		end
	end)
	NutDong.MouseLeave:Connect(function()
		if not DangHanhDong then
			HoatAnh.LuotChuot(NutDong, false, NutDongLuot, NutDongThuong)
			DichVuTween:Create(VienNutDong, TweenInfo.new(0.3), {Transparency = 1}):Play()
		end
	end)
	NutDong.MouseButton1Click:Connect(DongGiaoDien)
	NutMoUI.MouseButton1Click:Connect(function() HoatAnh.NhanChuot(NutMoUI) if KhungChinh.Visible then DongGiaoDien() else MoGiaoDien() end end)

	if shared.HxKeybindEvent then shared.HxKeybindEvent:Disconnect() end
	shared.HxKeybindEvent = DichVuDauVao.InputBegan:Connect(function(DauVaoBanPhim, DaXuLy)
		if DaXuLy then return end
		if DauVaoBanPhim.KeyCode == PhimMoMenu then 
			if KhungChinh.Visible then DongGiaoDien() else MoGiaoDien() end 
		end
	end)

	MoGiaoDien()
end

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)
TaoGiaoDien()
