local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local NguoiChoi = Players.LocalPlayer
local PlayerGui = NguoiChoi:WaitForChild("PlayerGui")
local PlayerScripts = NguoiChoi:WaitForChild("PlayerScripts")
local Chuot = NguoiChoi:GetMouse()

local GuiThongBao = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Notify.lua"))()
local function ThongBao(TieuDe, NoiDung, ThoiGian) GuiThongBao.thongbao(TieuDe, NoiDung, ThoiGian) end
local function ThongBaoLoi(TieuDe, NoiDung) GuiThongBao.thongbaoloi(TieuDe, NoiDung) end

local HoatAnh = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Animation.lua"))()
local KhungCuon = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/KhungCuon.lua"))()
local MenuConfigManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/MenuConfigManager.lua"))()
local AutoClickLogic = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Transform/AutoClick_Logic.lua"))()
local TeleportLogic = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Transform/Teleport_Logic.lua"))

MenuConfigManager.SetFileName("main_v3")

local PhimMoMenu = Enum.KeyCode.Insert
local PhimAutoClick = Enum.KeyCode.R

local CauHinh = {
	DangTab = true,
	TabMacDinh = "Auto Click",
	SoCot = 1,
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
		TichBat = Color3.fromRGB(255, 255, 255),
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

local TrangThaiLuu = {
	TocDoClick = "500",
	PhimAutoClick = "R",
	ReduceLags = false,
	PhimMoMenu = "Insert",
	HideAll = false,
	DanhSachClick = {},
	ClickTP = false,
	PhimClickTP = "T",
	TargetPlayer = "...",
	TargetMap = "..."
}

local function LuuConfig()
	TrangThaiLuu.DanhSachClick = {}
	for _, item in ipairs(DuLieuDanhSachClick) do
		table.insert(TrangThaiLuu.DanhSachClick, {
			X = item.X,
			Y = item.Y,
			BatTat = (item.HienTai == "Bat"),
			DaAn = item.DaAn or false,
		})
	end
	MenuConfigManager.Save(TrangThaiLuu)
end

local function DocConfig()
	return MenuConfigManager.Load()
end

local function CapNhatDanhSachClick()
	for ViTri, DuLieuDanhSach in ipairs(DuLieuDanhSachClick) do
		DuLieuDanhSach.Ten = "Click " .. ViTri .. " (" .. math.floor(DuLieuDanhSach.X) .. "," .. math.floor(DuLieuDanhSach.Y) .. ")"
	end
	AutoClickLogic.CapNhatDiem(DuLieuDanhSachClick)
	LuuConfig()
	if TaiLaiGiaoDien then task.defer(TaiLaiGiaoDien) end
end

local function TaoItemClick(ToaDoX, ToaDoY, BatTatBanDau, DaAnBanDau)
	local DuLieuNut = { X = ToaDoX, Y = ToaDoY, DaAn = DaAnBanDau or false }
	DuLieuNut.Loai = "Otich"
	DuLieuNut.HienTai = (BatTatBanDau == false) and "Tat" or "Bat"
	DuLieuNut.SuKien = function(TrangThai)
		ThongBao("Hx Script", TrangThai and ("Đã bật " .. DuLieuNut.Ten) or ("Đã tắt " .. DuLieuNut.Ten), 1)
		LuuConfig()
	end
	DuLieuNut.CacNutCon = {
		{
			Ten = "Hide Click Location",
			Loai = "Otich",
			HienTai = DuLieuNut.DaAn and "Bat" or "Tat",
			SuKien = function(TrangThai)
				DuLieuNut.DaAn = TrangThai
				AutoClickLogic.CapNhatDiem(DuLieuDanhSachClick)
				LuuConfig()
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

AutoClickLogic.OnToaDoDoi = function(Index, X, Y)
	if DuLieuDanhSachClick[Index] then
		DuLieuDanhSachClick[Index].X = X
		DuLieuDanhSachClick[Index].Y = Y
		CapNhatDanhSachClick()
	end
end

local TrangThaiAnTatCa = false
local ChucNangAnTao = { Loai = "NhieuNut", Ten1 = "Create Click", Ten2 = "Hide All: OFF" }

ChucNangAnTao.SuKien1 = function()
	local KichThuocManHinh = workspace.CurrentCamera.ViewportSize
	local ToaDoX = math.floor(KichThuocManHinh.X * 0.5)
	local ToaDoY = math.floor(KichThuocManHinh.Y * 0.5)
	local NutMoi = TaoItemClick(ToaDoX, ToaDoY)
	table.insert(DuLieuDanhSachClick, NutMoi)
	CapNhatDanhSachClick()
	ThongBao("Hx Script", "Đã tạo điểm click tại: " .. ToaDoX .. ", " .. ToaDoY, 1.5)
end

ChucNangAnTao.SuKien2 = function()
	TrangThaiAnTatCa = not TrangThaiAnTatCa
	ChucNangAnTao.Ten2 = TrangThaiAnTatCa and "Hide All: ON" or "Hide All: OFF"
	AutoClickLogic.BatTatAnToanBo(TrangThaiAnTatCa)
	TrangThaiLuu.HideAll = TrangThaiAnTatCa
	LuuConfig()
	ThongBao("Hx Script", TrangThaiAnTatCa and "Đã ẩn mọi vị trí" or "Đã hiện vị trí", 1)
	if TaiLaiGiaoDien then task.defer(TaiLaiGiaoDien) end
end

local TimChucNang 

local DanhSachNhom = {
	{
		TenTab = "Auto Click",
		DuLieuKhoi = {
			{
				TieuDe = "Auto Click Config",
				ChucNang = {
					{
						Ten = "Auto Click", Loai = "Otich", HienTai = "Tat",
						SuKien = function(TrangThai)
							AutoClickLogic.BatTatAutoClick(TrangThai)
							TrangThaiLuu.AutoClick = TrangThai
							LuuConfig()
							ThongBao("Hx Script", TrangThai and "Đã BẬT Auto Click" or "Đã TẮT Auto Click", 2)
						end
					},
					{
						Ten = "Speed Click (ms)", Loai = "Odien", HienTai = "500", GoiY = "Nhập tốc độ...",
						SuKien = function(GiaTri)
							if tonumber(GiaTri) then
								AutoClickLogic.CaiDatTocDo(GiaTri)
								TrangThaiLuu.TocDoClick = GiaTri
								LuuConfig()
								ThongBao("Hx Script", "Chỉnh tốc độ: " .. GiaTri .. "ms", 1)
							else ThongBaoLoi("Hx Script", "Tốc độ phải là số!") end
						end
					},
					{
						Ten = "Auto Click Hotkey", Loai = "PhimNong", HienTai = "R",
						SuKien = function(Phim)
							PhimAutoClick = Phim
							TrangThaiLuu.PhimAutoClick = Phim.Name
							LuuConfig()
							ThongBao("Hx Script", "Đổi phím tắt Auto Click: " .. Phim.Name, 2)
						end
					},
					ChucNangAnTao,
					{ Ten = "List Of Click Locations", Loai = "Danhsach", DangMo = false, Danhsach = DuLieuDanhSachClick }
				}
			}
		}
	},
	{
		TenTab = "Teleport Menu",
		DuLieuKhoi = {
			{
				TieuDe = "Game & Player Teleport",
				ChucNang = {
					{
						Ten = "Select Location", Loai = "HopXo", HienTai = "...", LuaChon = TeleportLogic.LayDiaDiemGame(game.PlaceId),
						SuKien = function(Chon)
							TrangThaiLuu.TargetMap = Chon
							LuuConfig()
							ThongBao("Hx Script", "Mục tiêu Map hiện tại: " .. Chon, 1)
						end
					},
					{
						Ten = "Refresh Player List", Loai = "Nut",
						SuKien = function()
							local cn = TimChucNang("Teleport Menu", "Select Player")
							if cn then
								cn.LuaChon = TeleportLogic.GetPlayers()
								ThongBao("Hx Script", "Đã làm mới danh sách người chơi", 1.5)
							end
						end
					},
					{
						Ten = "Select Player", Loai = "HopXo", HienTai = "...", LuaChon = TeleportLogic.GetPlayers(),
						SuKien = function(Chon)
							TrangThaiLuu.TargetPlayer = Chon
							LuuConfig()
						end
					},
					{
						Ten = "Teleport To Player", Loai = "Nut",
						SuKien = function()
							local cn = TimChucNang("Teleport Menu", "Select Player")
							if cn and cn.HienTai and cn.HienTai ~= "..." then
								TeleportLogic.TeleportToPlayer(cn.HienTai)
								ThongBao("Hx Script", "Đang bay tới vị trí của: " .. cn.HienTai, 1.5)
							else
								ThongBaoLoi("Hx Script", "Lỗi: Bạn chưa chọn mục tiêu nào!")
							end
						end
					}
				}
			},
			{
				TieuDe = "Click Teleport Settings",
				ChucNang = {
					{
						Ten = "Enable Click TP", Loai = "Otich", HienTai = "Tat",
						SuKien = function(TrangThai)
							TeleportLogic.SetClickTP(TrangThai)
							TrangThaiLuu.ClickTP = TrangThai
							LuuConfig()
							ThongBao("Hx Script", TrangThai and "Đã BẬT Click TP (Giữ phím + Click trái)" or "Đã TẮT Click TP", 2)
						end
					},
					{
						Ten = "Click TP Hotkey", Loai = "PhimNong", HienTai = "T",
						SuKien = function(Phim)
							TeleportLogic.SetKey(Phim)
							TrangThaiLuu.PhimClickTP = Phim.Name
							LuuConfig()
							ThongBao("Hx Script", "Đổi phím Click TP thành: " .. Phim.Name, 2)
						end
					}
				}
			}
		}
	},
	{
		TenTab = "Config Menu",
		DuLieuKhoi = {
			{
				TieuDe = "Config Menu",
				ChucNang = {
					{
						Ten = "Reduce Lags",
						Loai = "Otich",
						HienTai = "Tat",
						SuKien = function(TrangThai)
							MenuConfigManager.KichHoat(TrangThai)
							TrangThaiLuu.ReduceLags = TrangThai
							LuuConfig()
							if TrangThai then
								ThongBao("Hx Script", "Đã tối ưu hóa đồ họa (Potato Mode)", 2)
							else
								ThongBao("Hx Script", "Đã khôi phục cài đặt ánh sáng", 2)
							end
						end
					},
					{
						Ten = "HotKeys Open Menu", Loai = "PhimNong", HienTai = "Insert",
						SuKien = function(Phim)
							PhimMoMenu = Phim
							TrangThaiLuu.PhimMoMenu = Phim.Name
							LuuConfig()
							ThongBao("Hx Script", "Đổi phím tắt Menu: " .. Phim.Name, 2)
						end
					},
					{
						Ten = "Destroy UI", Loai = "Nut",
						SuKien = function()
							AutoClickLogic.Destroy()
							if PlayerGui:FindFirstChild("main_v3") then
								PlayerGui.main_v3:Destroy()
							end
							if shared.HxKeybindEvent then
								shared.HxKeybindEvent:Disconnect()
							end
							ThongBao("Hx Script", "Đã xóa toàn bộ UI!", 2)
						end
					}
				}
			}
		}
	}
}

function TimChucNang(TenTab, TenChucNang)
	for _, Nhom in ipairs(DanhSachNhom) do
		if Nhom.TenTab == TenTab then
			for _, Khoi in ipairs(Nhom.DuLieuKhoi) do
				for _, CN in ipairs(Khoi.ChucNang) do
					if CN.Ten == TenChucNang then return CN end
				end
			end
		end
	end
	return nil
end

local function ApDungConfig(cfg)
	if not cfg then return end

	local cnTocDo = TimChucNang("Auto Click", "Speed Click (ms)")
	if cnTocDo and cfg.TocDoClick then
		cnTocDo.HienTai = tostring(cfg.TocDoClick)
		AutoClickLogic.CaiDatTocDo(tostring(cfg.TocDoClick))
		TrangThaiLuu.TocDoClick = tostring(cfg.TocDoClick)
	end

	if cfg.PhimAutoClick then
		local ok, key = pcall(function() return Enum.KeyCode[cfg.PhimAutoClick] end)
		if ok and key then
			PhimAutoClick = key
			TrangThaiLuu.PhimAutoClick = cfg.PhimAutoClick
			local cnPhimAC = TimChucNang("Auto Click", "Auto Click Hotkey")
			if cnPhimAC then cnPhimAC.HienTai = cfg.PhimAutoClick end
		end
	end

	local cnReduceLags = TimChucNang("Config Menu", "Reduce Lags")
	if cnReduceLags and cfg.ReduceLags then
		cnReduceLags.HienTai = "Bat"
		MenuConfigManager.KichHoat(true)
		TrangThaiLuu.ReduceLags = true
	end

	if cfg.PhimMoMenu then
		local ok, key = pcall(function() return Enum.KeyCode[cfg.PhimMoMenu] end)
		if ok and key then
			PhimMoMenu = key
			TrangThaiLuu.PhimMoMenu = cfg.PhimMoMenu
			local cnPhimMenu = TimChucNang("Config Menu", "HotKeys Open Menu")
			if cnPhimMenu then cnPhimMenu.HienTai = cfg.PhimMoMenu end
		end
	end

	if cfg.ClickTP then
		local cn = TimChucNang("Teleport Menu", "Enable Click TP")
		if cn then cn.HienTai = "Bat" end
		TeleportLogic.SetClickTP(true)
		TrangThaiLuu.ClickTP = true
	end

	if cfg.PhimClickTP then
		local ok, key = pcall(function() return Enum.KeyCode[cfg.PhimClickTP] end)
		if ok and key then
			TeleportLogic.SetKey(key)
			TrangThaiLuu.PhimClickTP = cfg.PhimClickTP
			local cn = TimChucNang("Teleport Menu", "Click TP Hotkey")
			if cn then cn.HienTai = cfg.PhimClickTP end
		end
	end

	if cfg.HideAll then
		TrangThaiAnTatCa = true
		ChucNangAnTao.Ten2 = "Hide All: ON"
		AutoClickLogic.BatTatAnToanBo(true)
		TrangThaiLuu.HideAll = true
	end

	if type(cfg.DanhSachClick) == "table" then
		for _, saved in ipairs(cfg.DanhSachClick) do
			if tonumber(saved.X) and tonumber(saved.Y) then
				local item = TaoItemClick(
					tonumber(saved.X),
					tonumber(saved.Y),
					saved.BatTat ~= false,
					saved.DaAn == true
				)
				table.insert(DuLieuDanhSachClick, item)
			end
		end
		for ViTri, d in ipairs(DuLieuDanhSachClick) do
			d.Ten = "Click " .. ViTri .. " (" .. math.floor(d.X) .. "," .. math.floor(d.Y) .. ")"
		end
		AutoClickLogic.CapNhatDiem(DuLieuDanhSachClick)
	end
end

ApDungConfig(DocConfig())

local function TaoGiaoDien()
	if PlayerGui:FindFirstChild("main_v3") then PlayerGui.main_v3:Destroy() end
	local DangHanhDong = false
	local KiemTraDienThoai = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
	local KichThuocMo = UDim2.fromScale(0.6, 0.55)

	local ManHinhGui = Instance.new("ScreenGui")
	ManHinhGui.Name = "main_v3"
	ManHinhGui.ResetOnSpawn = false
	ManHinhGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ManHinhGui.Parent = PlayerGui

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
	NutMoUI.Active = true
	NutMoUI.ZIndex = 999
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
	KhungChinh.Active = true
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
	NutDong.BackgroundTransparency = 1
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
			TweenService:Create(VienNutDong, TweenInfo.new(0.3), {Transparency = 0}):Play()
		end
	end)
	NutDong.MouseLeave:Connect(function()
		if not DangHanhDong then
			HoatAnh.LuotChuot(NutDong, false, NutDongLuot, NutDongThuong)
			TweenService:Create(VienNutDong, TweenInfo.new(0.3), {Transparency = 1}):Play()
		end
	end)
	NutDong.MouseButton1Click:Connect(DongGiaoDien)
	NutMoUI.MouseButton1Click:Connect(function() HoatAnh.NhanChuot(NutMoUI) if KhungChinh.Visible then DongGiaoDien() else MoGiaoDien() end end)

	UserInputService.InputBegan:Connect(function(DauVaoBanPhim, DaXuLy)
		if shared.HxDangChinhPhim == true then return end
		if DaXuLy then return end

		if DauVaoBanPhim.KeyCode == PhimMoMenu then
			if KhungChinh.Visible then DongGiaoDien() else MoGiaoDien() end
		end

		if DauVaoBanPhim.KeyCode == PhimAutoClick then
			if shared.HxDangChinhPhim then return end
			if AutoClickLogic and AutoClickLogic.BatTatAutoClick then
				local TrangThaiMoi = not AutoClickLogic.DangChay
				AutoClickLogic.BatTatAutoClick(TrangThaiMoi)
				TrangThaiLuu.AutoClick = TrangThaiMoi
				LuuConfig()
				ThongBao("Hx Script", TrangThaiMoi and "Đã BẬT Auto Click" or "Đã TẮT Auto Click", 1)
			end
		end
	end)

	MoGiaoDien()
end

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)
TaoGiaoDien()
