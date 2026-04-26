local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")

local NguoiChoi         = Players.LocalPlayer
local PlayerGui         = NguoiChoi:WaitForChild("PlayerGui")
local PlayerScripts     = NguoiChoi:WaitForChild("PlayerScripts")

local ThuMucUI
local KiemTraHui, KetQuaHui = pcall(function() return gethui() end)
local KiemTraCoreGui, KetQuaCoreGui = pcall(function() return game:GetService("CoreGui") end)

if KiemTraHui and KetQuaHui then
	ThuMucUI = KetQuaHui
elseif KiemTraCoreGui and KetQuaCoreGui then
	ThuMucUI = KetQuaCoreGui
else
	ThuMucUI = PlayerGui
end

local GuiThongBao       = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/ThongBao.lua"))()
local ChuDe             = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/ChuDe.lua"))()
local HoatAnh           = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/Animation.lua"))()
local ThuVienUI         = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/ThuVienUI.lua"))()
local MenuConfigManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/MenuConfigManager.lua"))()

local Khoi              = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Main_Script/Main_Utilities/Khoi_Logic.lua"))()
local Transform_Logic   = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Main_Script/Main_Utilities/Transform_Logic.lua"))()
local NhanVat_Logic     = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Main_Script/Main_Utilities/NhanVat_Logic.lua"))()

local function ThongBao(TieuDe, NoiDung, ThoiGian) 
	GuiThongBao.thongbao("Hx Script | " .. TieuDe, NoiDung, ThoiGian or 2) 
end

local function ThongBaoLoi(TieuDe, NoiDung) 
	if GuiThongBao.thongbaoloi then 
		GuiThongBao.thongbaoloi("Hx Script | " .. TieuDe, NoiDung) 
	else 
		GuiThongBao.thongbao("Hx Script Lỗi | " .. TieuDe, NoiDung, 3) 
	end 
end

MenuConfigManager.SetFileName("main_v2")

local PhimMoMenu = Enum.KeyCode.Insert

local CauHinh = {
	DangTab = false, SoCot = 2,
	ConfigMenu = true, TimKiem = false,
	KichThuoc = { Header = 45, Cach = 8, IconLon = UDim2.new(0, 90, 0, 90) },
	Asset = { Icon = "rbxassetid://117118515787811", MuiTenXuong = "rbxassetid://6031091004" },
	VanBan = { Nut = 14, Nho = 13, TieuDe = 15 },
	Mau = {},
	DoTrongSuotKhung = 0.4,
	QuickAnim = false,
	AutoCloseUI = false
}

for k, v in pairs(ChuDe.MacDinh) do CauHinh.Mau[k] = v end

local function BaoTrangThai(TenChucNang, TrangThai)
	ThongBao("Status", TrangThai and "Đã bật " .. TenChucNang or "Đã tắt " .. TenChucNang, 2)
end

local DuLieuDanhSachKhoiUI = {}
local TimChucNang

local GlobalConfig = {
	PhimMoMenu = "Insert",
	ChuDeUI = { Ten = "Dark" },
	DoTrongSuotKhung = 0.4,
	QuickAnim = false,
	AutoCloseUI = false,
	UISize = "1.0x (rec)"
}

local GameConfig = {
	ReduceLags = false,
	RemoveFog = false,
	FullBright = false,
	NoShadows = false,
	KhoiConfig = {},
	TransformConfig = {
		ShowHUD = true,
		ShowOutline = true,
		CanSelectChar = false,
		Mode = "ToanThan",
		EnabledParts = { Head = false, Torso = false, RightArm = false, LeftArm = false, RightLeg = false, LeftLeg = false }
	},
}

local function LuuGlobal()
	MenuConfigManager.SaveGlobal(GlobalConfig)
end

local function LuuGame()
	GameConfig.KhoiConfig = Khoi.GetConfig()
	MenuConfigManager.SaveGame(GameConfig)
end

Khoi.OnConfigChanged = LuuGame

CauHinh.LuuTheme = function(duLieuTheme)
	GlobalConfig.ChuDeUI = duLieuTheme
	LuuGlobal()
end

CauHinh.LuuTrongSuot = function(val) GlobalConfig.DoTrongSuotKhung = val LuuGlobal() end
CauHinh.LuuQuickAnim = function(val) GlobalConfig.QuickAnim = val LuuGlobal() end
CauHinh.LuuAutoClose = function(val) GlobalConfig.AutoCloseUI = val LuuGlobal() end
CauHinh.UISize = "1.0x (rec)"
CauHinh.LuuKichThuoc = function(val) GlobalConfig.UISize = val LuuGlobal() end

local function UpdateSubButtonText(rowName, text)
	local gui = ThuMucUI:FindFirstChild("main_v2")
	if not gui then return end
	for _, v in ipairs(gui:GetDescendants()) do
		if v:IsA("TextLabel") and (v.Text == "  " .. rowName or v.Text == rowName) then
			local nutBam = v.Parent
			if nutBam and nutBam:IsA("TextButton") then
				local hangNgang = nutBam.Parent
				if hangNgang then
					for _, child in ipairs(hangNgang:GetChildren()) do
						if child:IsA("TextButton") and child.Name ~= "Theme_HopVuong" and child ~= nutBam then
							child.Text = text
						end
					end
				end
			end
		end
	end
end

local chonMauState = "Xong"

local function TaoCauTrucItemChoKhoi(Obj)
	local TenHienThi = Obj.Name
	local LaNhom = Obj:IsA("Model")
	local CheckPart = LaNhom and Obj.PrimaryPart or Obj
	if not CheckPart and LaNhom then
		for _, v in pairs(Obj:GetChildren()) do
			if v:IsA("BasePart") then CheckPart = v; break end
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
							ThongBao("Hệ Thống", TrangThai and "Đã mở khóa di chuyển: " .. TenHienThi or "Đã khóa vị trí: " .. TenHienThi, 2)
							LuuGame()
						end
					},
					{
						Ten = "Neo Khối",
						Loai = "Gat",
						HienTai = IsAnchored and "Bat" or "Tat",
						SuKien = function(TrangThai)
							SetAnchored(TrangThai)
							ThongBao("Hệ Thống", TrangThai and "Đã Neo khối (Đứng yên)" or "Đã Tháo Neo (Rơi tự do)", 2)
							LuuGame()
						end
					}
				},
				SuKien = function(TrangThai)
					SetLocked(TrangThai)
					if not TrangThai then Khoi.CheckHuy(Obj) end
					BaoTrangThai("khả năng chọn khối " .. TenHienThi, TrangThai)
					LuuGame()
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
				table.remove(DuLieuDanhSachKhoiUI, i); break
			end
		end
	end
	local cn = TimChucNang("Danh Sách")
	if cn and cn.LamMoi then cn.LamMoi() end
	LuuGame()
end)

CauHinh.ExtraConfig = {
	{ Ten = "Reduce Lags", Loai = "Gat", HienTai = "Tat", SuKien = function(st) 
		MenuConfigManager.ReduceLags(st) 
		GameConfig.ReduceLags = st 
		LuuGame() 
	end },
	{ Ten = "More", Loai = "Danhsach", DangMo = false, Danhsach = {
		{ Ten = "Removes Fog", Loai = "Gat", HienTai = "Tat", SuKien = function(st) 
			MenuConfigManager.RemoveFog(st) 
			GameConfig.RemoveFog = st 
			LuuGame() 
		end },
		{ Ten = "Fully Bright", Loai = "Gat", HienTai = "Tat", SuKien = function(st) 
			MenuConfigManager.FullBright(st) 
			GameConfig.FullBright = st 
			LuuGame() 
		end },
		{ Ten = "No Shadows", Loai = "Gat", HienTai = "Tat", SuKien = function(st) 
			MenuConfigManager.NoShadows(st) 
			GameConfig.NoShadows = st 
			LuuGame() 
		end }
	}}
}

CauHinh.ExtraConfigPost = {
	{ Ten = "HotKeys Open Menu", Loai = "PhimNong", HienTai = "Insert", SuKien = function(key) 
		PhimMoMenu = key 
		GlobalConfig.PhimMoMenu = key.Name 
		LuuGlobal() 
	end }
}

local function LuuTransformConfig(key, value)
	GameConfig.TransformConfig[key] = value
	LuuGame()
end

local function TaoPhanTungPhan(tenHienThi, logicName)
	return {
		Ten = tenHienThi, Loai = "Gat", HienTai = "Tat", LoaiNutCon = "CungHang",
		SuKien = function(TrangThai)
			Transform_Logic.SetPartEnabled(logicName, TrangThai)
			GameConfig.TransformConfig.EnabledParts[logicName] = TrangThai
			LuuGame()
			BaoTrangThai(tenHienThi, TrangThai)
		end,
		CacNutCon = {
			{
				Ten = "Lưu Trữ",
				SuKien = function()
					local ok = Transform_Logic.SavePart(logicName)
					if ok then ThongBao("Hệ Thống", "Đã lưu " .. tenHienThi .. "!", 2)
					else ThongBaoLoi("Lỗi", "Chưa chọn Part nào!") end
				end
			},
			{
				Ten = "Xóa Lưu",
				SuKien = function()
					Transform_Logic.ClearPart(logicName)
					ThongBao("Hệ Thống", "Đã xóa lưu " .. tenHienThi .. "!", 2)
				end
			},
		}
	}
end

local ModeMap = {
	["Toàn Thân"] = "ToanThan",
	["Từng Phần"] = "TungPhan",
	["Nhân Vật"]  = "NhanVat",
}

local DanhSachNhom = {
	{
		TieuDe = "Main Transform",
		ChucNang = {
			{
				Ten = "Chức Năng Biến Hình",
				Loai = "Gat",
				HienTai = "Tat",
				CacNutCon = {
					{
						Ten = "Hiển Thị Nút Chức Năng",
						Loai = "Gat",
						HienTai = "Bat",
						SuKien = function(TrangThai)
							local gui = ThuMucUI:FindFirstChild("main_v2")
							if gui and gui:FindFirstChild("KhungNutNgoai") then
								gui.KhungNutNgoai.Visible = TrangThai
							end
							LuuTransformConfig("ShowHUD", TrangThai)
							BaoTrangThai("hiển thị nút chức năng", TrangThai)
						end
					},
					{
						Ten = "Hiển thị Outline Vùng Chọn",
						Loai = "Gat",
						HienTai = "Bat",
						SuKien = function(TrangThai)
							Transform_Logic.ToggleOutline(TrangThai)
							LuuTransformConfig("ShowOutline", TrangThai)
							BaoTrangThai("outline vùng chọn", TrangThai)
						end
					},
				},
				SuKien = function(TrangThai)
					Transform_Logic.SetActive(TrangThai)
					BaoTrangThai("chức năng biến hình", TrangThai)
				end
			}
		}
	},
	{
		TieuDe = "Nhân Vật Transform",
		ChucNang = {
			{
				Ten = "Tạo Mẫu",
				Loai = "Gat",
				HienTai = "Tat",
				LoaiNutCon = "CungHang",
				SuKien = function(TrangThai)
					if TrangThai then
						NhanVat_Logic.CreateDummy()
						ThongBao("Hệ Thống", "Đã tạo Mẫu!", 2)
					else
						NhanVat_Logic.RemoveDummy()
						ThongBao("Hệ Thống", "Đã xóa Mẫu!", 2)
					end
				end,
				CacNutCon = {
					{
						Ten = "Tùy Chỉnh",
						SuKien = function()
							local dummy = NhanVat_Logic.GetDummy()
							if dummy then
								NhanVat_Logic.OpenCustomMenu(dummy)
							else
								ThongBaoLoi("Lỗi", "Bạn phải bật Tạo Mẫu trước!")
							end
						end
					}
				}
			},
			{
				Ten = "Chọn Mẫu",
				Loai = "Gat",
				HienTai = "Tat",
				LoaiNutCon = "CungHang",
				SuKien = function(TrangThai)
					if TrangThai then
						chonMauState = "Xong"
						NhanVat_Logic.ToggleSelectMode(true)
						UpdateSubButtonText("Chọn Mẫu", "Xong")
						ThongBao("Hệ Thống", "Hãy click vào nhân vật bất kỳ!", 3)
					else
						chonMauState = "Xong"
						NhanVat_Logic.ToggleSelectMode(false)
						NhanVat_Logic.ClearSelectedModel()
						UpdateSubButtonText("Chọn Mẫu", "Xong")
					end
				end,
				CacNutCon = {
					{
						Ten = "Xong",
						SuKien = function()
							if chonMauState == "Xong" then
								NhanVat_Logic.ToggleSelectMode(false)
								local sel = NhanVat_Logic.GetSelectedModel()
								if sel then
									ThongBao("Hệ Thống", "Đã chốt chọn: " .. sel.Name, 2)
									chonMauState = "Tùy Chỉnh"
									UpdateSubButtonText("Chọn Mẫu", "Tùy Chỉnh")
								else
									ThongBaoLoi("Lỗi", "Chưa quét được nhân vật nào!")
								end
							else
								local sel = NhanVat_Logic.GetSelectedModel()
								if sel then
									NhanVat_Logic.OpenCustomMenu(sel)
								else
									ThongBaoLoi("Lỗi", "Không tìm thấy Mẫu đã chọn!")
								end
							end
						end
					}
				}
			},
			{
				Ten = "Cho Phép Chọn Mẫu",
				Loai = "Gat",
				HienTai = "Tat",
				SuKien = function(TrangThai)
					Transform_Logic.SetCharSelect(TrangThai)
					LuuTransformConfig("CanSelectChar", TrangThai)
					BaoTrangThai("chọn mẫu biến hình", TrangThai)
				end
			},
			{
				Ten = "Transform",
				Loai = "Nut",
				SuKien = function()
					local ok, msg = Transform_Logic.DoTransform()
					if ok then ThongBao("Thành công", msg, 3)
					else ThongBaoLoi("Lỗi", msg) end
				end
			},
		}
	},
	{
		TieuDe = "Thành Phần Transform",
		ChucNang = {
			{
				Ten = "Thành Phần",
				Loai = "HopXo",
				HienTai = "Toàn Thân",
				SuKien = function(LuaChonHienTai)
					local mode = ModeMap[LuaChonHienTai] or "ToanThan"
					Transform_Logic.SetMode(mode)
					LuuTransformConfig("Mode", mode)
					ThongBao("Trạng Thái", "Chế độ: " .. LuaChonHienTai, 2)
				end,
				LuaChon = {
					"Toàn Thân",
					{
						Ten = "Từng Phần",
						CacNutCon = {
							TaoPhanTungPhan("Phần Đầu",     "Head"),
							TaoPhanTungPhan("Phần Thân",    "Torso"),
							TaoPhanTungPhan("Tay Phải",     "RightArm"),
							TaoPhanTungPhan("Tay Trái",     "LeftArm"),
							TaoPhanTungPhan("Chân Phải",    "RightLeg"),
							TaoPhanTungPhan("Chân Trái",    "LeftLeg"),
						}
					},
					"Nhân Vật",
				}
			}
		}
	},
	{
		TieuDe = "Tạo Khối",
		ChucNang = {
			{
				Loai = "NhieuNut",
				Ten1 = "Tạo Khối Mẫu",  SuKien1 = function() local n = Khoi.TaoBlock() if n then ThongBao("Hệ Thống", "Đã tạo: " .. n, 1) end end,
				Ten2 = "Xóa Khối Chọn", SuKien2 = function() Khoi.XoaChon() ThongBao("Hệ Thống", "Đã xóa các khối được chọn!", 1) end,
			},
			{ Ten = "Danh Sách", Loai = "Danhsach", Danhsach = DuLieuDanhSachKhoiUI },
			{
				Loai = "NhieuNut",
				Ten1 = "Hàn Khối",  SuKien1 = function() local Msg = Khoi.HanKhoi()  ThongBao("Hx Build", Msg, 2) end,
				Ten2 = "Tháo Hàn",  SuKien2 = function() local Msg = Khoi.ThaoKhoi() ThongBao("Hx Build", Msg, 2) end,
			},
		}
	},
}

local function DuyetChucNang(DanhSach, TenChucNang)
	for _, CN in ipairs(DanhSach) do
		if CN.Ten == TenChucNang then return CN end
		if CN.CacNutCon then local res = DuyetChucNang(CN.CacNutCon, TenChucNang); if res then return res end end
	end
	return nil
end

function TimChucNang(TenChucNang)
	for _, KhoiObj in ipairs(DanhSachNhom) do
		local res = DuyetChucNang(KhoiObj.ChucNang, TenChucNang)
		if res then return res end
	end
	return nil
end

local function ApDungConfig(globalCfg, gameCfg)
	if globalCfg then
		if globalCfg.PhimMoMenu then pcall(function() PhimMoMenu = Enum.KeyCode[globalCfg.PhimMoMenu] end) end
		if globalCfg.ChuDeUI then CauHinh.ChuDeDaLuu = globalCfg.ChuDeUI; if globalCfg.ChuDeUI.Ten ~= "Dark" then for k, v in pairs(globalCfg.ChuDeUI) do if k ~= "Ten" then CauHinh.Mau[k] = v end end end; pcall(function() GuiThongBao.CapNhatChuDe(globalCfg.ChuDeUI) end) end
		if globalCfg.DoTrongSuotKhung ~= nil then CauHinh.DoTrongSuotKhung = globalCfg.DoTrongSuotKhung end
		if globalCfg.QuickAnim ~= nil then CauHinh.QuickAnim = globalCfg.QuickAnim end
		if globalCfg.AutoCloseUI ~= nil then CauHinh.AutoCloseUI = globalCfg.AutoCloseUI end
		if globalCfg.UISize then CauHinh.UISize = globalCfg.UISize end
		for k, v in pairs(globalCfg) do GlobalConfig[k] = v end
	end

	if gameCfg then
		if gameCfg.ReduceLags then MenuConfigManager.ReduceLags(true) end
		if gameCfg.RemoveFog then MenuConfigManager.RemoveFog(true) end
		if gameCfg.FullBright then MenuConfigManager.FullBright(true) end
		if gameCfg.NoShadows then MenuConfigManager.NoShadows(true) end
		if gameCfg.KhoiConfig then Khoi.SetConfig(gameCfg.KhoiConfig) end
		if gameCfg.TransformConfig then
			local tc = gameCfg.TransformConfig
			if tc.ShowOutline ~= nil   then Transform_Logic.ToggleOutline(tc.ShowOutline) end
			if tc.CanSelectChar ~= nil then Transform_Logic.SetCharSelect(tc.CanSelectChar) end
			if tc.Mode                 then Transform_Logic.SetMode(tc.Mode) end

			local cn = TimChucNang("Hiển thị Outline Vùng Chọn")
			if cn then cn.HienTai = (tc.ShowOutline ~= false) and "Bat" or "Tat" end

			local cnHUD = TimChucNang("Hiển Thị Nút Chức Năng")
			if cnHUD then cnHUD.HienTai = (tc.ShowHUD ~= false) and "Bat" or "Tat" end

			local cnMove = TimChucNang("Cho Phép Chọn Mẫu")
			if cnMove then cnMove.HienTai = tc.CanSelectChar and "Bat" or "Tat" end

			local cnMode = TimChucNang("Thành Phần")
			if cnMode and tc.Mode then
				local RevModeMap = { ToanThan = "Toàn Thân", TungPhan = "Từng Phần", NhanVat = "Nhân Vật" }
				cnMode.HienTai = RevModeMap[tc.Mode] or "Toàn Thân"
			end

			if type(tc.EnabledParts) == "table" then
				local LogicToName = { Head = "Phần Đầu", Torso = "Phần Thân", RightArm = "Tay Phải", LeftArm = "Tay Trái", RightLeg = "Chân Phải", LeftLeg = "Chân Trái" }
				for lName, st in pairs(tc.EnabledParts) do
					Transform_Logic.SetPartEnabled(lName, st)
					local cnPart = TimChucNang(LogicToName[lName])
					if cnPart then cnPart.HienTai = st and "Bat" or "Tat" end
				end
			end

			if ThuMucUI:FindFirstChild("main_v2") and ThuMucUI.main_v2:FindFirstChild("KhungNutNgoai") then
				ThuMucUI.main_v2.KhungNutNgoai.Visible = (tc.ShowHUD ~= false)
			end
		end
		for k, v in pairs(gameCfg) do GameConfig[k] = v end
	end
end

ApDungConfig(MenuConfigManager.LoadGlobal(), MenuConfigManager.LoadGame())

local function TaoGiaoDien()
	if ThuMucUI:FindFirstChild("main_v2") then ThuMucUI.main_v2:Destroy() end

	local ManHinhGui = Instance.new("ScreenGui")
	ManHinhGui.Name = "main_v2"; ManHinhGui.ResetOnSpawn = false
	ManHinhGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; ManHinhGui.Parent = ThuMucUI

	local LopPhu = Instance.new("Frame", ManHinhGui)
	LopPhu.Name = "LopPhu"; LopPhu.Size = UDim2.fromScale(1,1)
	LopPhu.BackgroundTransparency = 1; LopPhu.ZIndex = 100

	local ClickNgoai = Instance.new("TextButton", ManHinhGui)
	ClickNgoai.Size = UDim2.fromScale(1,1); ClickNgoai.BackgroundTransparency = 1
	ClickNgoai.Text = ""; ClickNgoai.Visible = false; ClickNgoai.ZIndex = 99

	local function DongTatCaXoXuong()
		for _, PhanTuXo in ipairs(LopPhu:GetChildren()) do PhanTuXo:Destroy() end
		ClickNgoai.Visible = false
	end
	ClickNgoai.MouseButton1Click:Connect(DongTatCaXoXuong)

	local NutMoUI = Instance.new("ImageButton", ManHinhGui)
	NutMoUI.Name = "NutMoUI"; NutMoUI.Size = UDim2.new(0,45,0,45)
	NutMoUI.Position = UDim2.new(0,30,0.4,0); NutMoUI.Image = CauHinh.Asset.Icon
	NutMoUI.BackgroundColor3 = CauHinh.Mau.Nen; NutMoUI.BackgroundTransparency = 0.2
	NutMoUI.Active = true; NutMoUI.ZIndex = 999
	Instance.new("UICorner", NutMoUI).CornerRadius = UDim.new(0,10)
	HoatAnh.KeoTha(NutMoUI, NutMoUI)

	local KhungChinh = Instance.new("Frame", ManHinhGui)
	KhungChinh.Name = "KhungChinh"; KhungChinh.Size = CauHinh.KichThuoc.IconLon
	KhungChinh.Position = UDim2.new(0.5,0,0.5,0); KhungChinh.AnchorPoint = Vector2.new(0.5,0.5)
	KhungChinh.BackgroundColor3 = CauHinh.Mau.Nen; KhungChinh.BackgroundTransparency = CauHinh.DoTrongSuotKhung or 0.4
	KhungChinh.ClipsDescendants = true; KhungChinh.Visible = false; KhungChinh.Active = true
	Instance.new("UICorner", KhungChinh).CornerRadius = UDim.new(0,14)

	local function LayScaleAnToan(val)
		return tonumber(tostring(val or "1.0x"):match("([%d%.]+)")) or 1.0
	end

	local UIScaleKhung = Instance.new("UIScale")
	UIScaleKhung.Scale = LayScaleAnToan(CauHinh.UISize)
	UIScaleKhung.Parent = KhungChinh

	local UIScaleLopPhu = Instance.new("UIScale")
	UIScaleLopPhu.Scale = LayScaleAnToan(CauHinh.UISize)
	UIScaleLopPhu.Parent = LopPhu

	CauHinh.ApDungKichThuoc = function(scale, val)
		CauHinh.UISize = val
		UIScaleKhung.Scale = scale
		if UIScaleLopPhu then UIScaleLopPhu.Scale = scale end
	end

	local BieuTuong = Instance.new("ImageLabel", KhungChinh)
	BieuTuong.Size = UDim2.fromOffset(0,0); BieuTuong.Position = UDim2.new(0.5,0,0.5,0)
	BieuTuong.AnchorPoint = Vector2.new(0.5,0.5); BieuTuong.Image = CauHinh.Asset.Icon
	BieuTuong.BackgroundTransparency = 0.6; BieuTuong.BackgroundColor3 = Color3.new(0,0,0); BieuTuong.ZIndex = 2
	Instance.new("UICorner", BieuTuong).CornerRadius = UDim.new(0,10)

	local KhungBaoNoiDung = Instance.new("Frame", KhungChinh)
	KhungBaoNoiDung.Name = "KhungBaoNoiDung"
	KhungBaoNoiDung.Size = UDim2.fromOffset(550, 400)
	KhungBaoNoiDung.Position = UDim2.new(0.5, 0, 0.5, 0)
	KhungBaoNoiDung.AnchorPoint = Vector2.new(0.5, 0.5)
	KhungBaoNoiDung.BackgroundTransparency = 1; KhungBaoNoiDung.ZIndex = 2

	local TieuDe = Instance.new("TextLabel", KhungBaoNoiDung)
	TieuDe.Text = "Hx - Transform Script"; TieuDe.Size = UDim2.new(1,-150,0,50)
	TieuDe.Position = UDim2.new(0,60,0,5); TieuDe.BackgroundTransparency = 1
	TieuDe.TextColor3 = CauHinh.Mau.Chu; TieuDe.Font = Enum.Font.GothamBold
	TieuDe.TextSize = 18; TieuDe.TextXAlignment = Enum.TextXAlignment.Left
	TieuDe.TextTransparency = 1; TieuDe.ZIndex = 5

	local VungCuon = Instance.new("ScrollingFrame", KhungBaoNoiDung)
	VungCuon.Size = UDim2.new(1,-24,1,-65); VungCuon.Position = UDim2.new(0.5,0,1,-12)
	VungCuon.AnchorPoint = Vector2.new(0.5,1); VungCuon.BackgroundColor3 = CauHinh.Mau.NenList
	VungCuon.BackgroundTransparency = 0.6; VungCuon.ScrollBarThickness = 6
	VungCuon.BorderSizePixel = 0; VungCuon.ZIndex = 2
	Instance.new("UICorner", VungCuon).CornerRadius = UDim.new(0,8)

	local VienVungCuon = Instance.new("UIStroke", VungCuon)
	VienVungCuon.Name = "VienNeon"; VienVungCuon.Color = CauHinh.Mau.VienNeon
	VienVungCuon.Transparency = 0.5; VienVungCuon.Thickness = 0.5
	VungCuon.AutomaticCanvasSize = Enum.AutomaticSize.Y; VungCuon.CanvasSize = UDim2.new(0,0,0,0)

	local CacPhanTu = { Khung = KhungChinh, Icon = BieuTuong, TieuDe = TieuDe, KhungNoiDung = VungCuon }

	local function TaoCauHinhHieuUng()
		return {
			IconDau = CauHinh.KichThuoc.IconLon, 
			IconCuoi = UDim2.new(0, 40, 0, 40), 
			ViTriIconDau = UDim2.new(0.5, 0, 0.5, 0), 
			ViTriIconCuoi = UDim2.new(0, 30, 0, 30), 
			KhungDau = CauHinh.KichThuoc.IconLon, 
			KhungCuoi = UDim2.fromOffset(550, 400),
			DoTrongSuotKhung = CauHinh.DoTrongSuotKhung or 0.4, 
			KichThuocNutDongNay = UDim2.new(0, 45, 0, 45)
		}
	end

	HoatAnh.KeoTha(KhungChinh, KhungChinh)

	local LuongEpKichThuoc = nil
	local LuongCapNhatTab = nil
	local DangHanhDong = false

	local function DongGiaoDien()
		if DangHanhDong or not KhungChinh.Visible then return end
		DangHanhDong = true
		shared.HxUI_DangThuNho = true

		if LuongEpKichThuoc then task.cancel(LuongEpKichThuoc) LuongEpKichThuoc = nil end
		if LuongCapNhatTab then task.cancel(LuongCapNhatTab) LuongCapNhatTab = nil end

		if CauHinh.QuickAnim then
			KhungChinh.Visible = false 
			DangHanhDong = false 
		else
			HoatAnh.DongGiaoDien(CacPhanTu, TaoCauHinhHieuUng(), function()
				KhungChinh.Visible = false; DangHanhDong = false
			end)
		end
	end

	local SuKienBanPhim = nil
	local function PhaHuyUI()
		GuiThongBao.thongbaoxacnhan("XÁC NHẬN", "Bạn có chắc chắn muốn đóng UI không?", function()
			if Khoi and Khoi.HuyChon then pcall(function() Khoi.HuyChon() end) end
			pcall(function() Transform_Logic.SetActive(false) end)
			if SuKienBanPhim then pcall(function() SuKienBanPhim:Disconnect() end) end
			if shared.HxKeybindEvent then pcall(function() shared.HxKeybindEvent:Disconnect() end) end
			if ManHinhGui and ManHinhGui.Parent then ManHinhGui:Destroy() end
		end)
	end

	local PhanTuToolbar = ThuVienUI.Tao(KhungChinh, VungCuon, DanhSachNhom, CauHinh, LopPhu,
		function() DongTatCaXoXuong(); ClickNgoai.Visible = true end, PhaHuyUI, DongGiaoDien)

	CacPhanTu.NutDong = PhanTuToolbar.NutMin
	CacPhanTu.VienNutDong = PhanTuToolbar.VienMin
	CacPhanTu.Toolbar = PhanTuToolbar.Toolbar

	if CacPhanTu.Toolbar then CacPhanTu.Toolbar.Parent = KhungBaoNoiDung end

	KhungChinh:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if KhungChinh.AbsoluteSize.X < 150 then
			KhungBaoNoiDung.Visible = false
		else
			KhungBaoNoiDung.Visible = true
		end
	end)

	local function MoGiaoDien()
		if DangHanhDong or KhungChinh.Visible then return end
		DangHanhDong = true
		KhungChinh.Visible = true
		shared.HxUI_DangThuNho = false

		if LuongEpKichThuoc then task.cancel(LuongEpKichThuoc) LuongEpKichThuoc = nil end
		if LuongCapNhatTab then task.cancel(LuongCapNhatTab) LuongCapNhatTab = nil end

		if CacPhanTu.NutDong then CacPhanTu.NutDong.Size = UDim2.fromOffset(35,35) end

		local hieuUng = TaoCauHinhHieuUng()

		if CauHinh.QuickAnim then
			KhungChinh.Size = hieuUng.KhungCuoi
			KhungBaoNoiDung.Visible = true
			DangHanhDong = false
			if PhanTuToolbar and PhanTuToolbar.CapNhatTab then PhanTuToolbar.CapNhatTab() end
		else
			HoatAnh.MoGiaoDien(CacPhanTu, hieuUng)

			LuongEpKichThuoc = task.delay(0.25, function() 
				DangHanhDong = false
				if KhungChinh and KhungChinh.Visible and not shared.HxUI_DangThuNho then 
					KhungChinh.Size = hieuUng.KhungCuoi 
				end 
			end)

			if PhanTuToolbar and PhanTuToolbar.CapNhatTab then 
				LuongCapNhatTab = task.delay(1.1, function()
					if KhungChinh.Visible and not shared.HxUI_DangThuNho then
						PhanTuToolbar.CapNhatTab()
					end
				end)
			end
		end
	end

	NutMoUI.MouseButton1Click:Connect(function()
		NutMoUI.Size = UDim2.new(0, 45, 0, 45)
		local TS = game:GetService("TweenService")
		local thuNho = TS:Create(NutMoUI, TweenInfo.new(0.1), {Size = UDim2.new(0, 38, 0, 38)})
		local phongTo = TS:Create(NutMoUI, TweenInfo.new(0.1), {Size = UDim2.new(0, 45, 0, 45)})
		thuNho:Play()
		task.delay(0.1, function()
			if NutMoUI then phongTo:Play() end
		end)

		if KhungChinh.Visible then DongGiaoDien() else MoGiaoDien() end 
	end)

	SuKienBanPhim = UserInputService.InputBegan:Connect(function(DauVaoBanPhim, DaXuLy)
		if shared.HxDangChinhPhim == true or DaXuLy then return end
		if DauVaoBanPhim.KeyCode == PhimMoMenu then
			if KhungChinh.Visible then DongGiaoDien() else MoGiaoDien() end
		elseif DauVaoBanPhim.KeyCode == Enum.KeyCode.R then
			local ok, msg = Transform_Logic.DoTransform()
			if msg then ThongBao(ok and "Thành công" or "Lỗi", msg, 2) end
		end
	end)

	local KhungNutNgoai = Instance.new("Frame", ManHinhGui)
	KhungNutNgoai.Name = "KhungNutNgoai"
	KhungNutNgoai.Size = UDim2.new(0, 50, 0, 50)
	KhungNutNgoai.Position = UDim2.new(1, -70, 0.6, 0)
	KhungNutNgoai.AnchorPoint = Vector2.new(1, 1)
	KhungNutNgoai.BackgroundTransparency = 1
	KhungNutNgoai.Visible = (GameConfig.TransformConfig.ShowHUD ~= false)

	local NutBienHinhNgoai = Instance.new("TextButton", KhungNutNgoai)
	NutBienHinhNgoai.Name = "NutBienHinhNgoai"
	NutBienHinhNgoai.Size = UDim2.new(1, 0, 1, 0)
	NutBienHinhNgoai.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	NutBienHinhNgoai.BackgroundTransparency = 0.3
	NutBienHinhNgoai.Text = "Biến"
	NutBienHinhNgoai.TextColor3 = Color3.new(1, 1, 1)
	NutBienHinhNgoai.Font = Enum.Font.GothamBold
	NutBienHinhNgoai.TextScaled = true
	Instance.new("UICorner", NutBienHinhNgoai).CornerRadius = UDim.new(1, 0)

	NutBienHinhNgoai.MouseButton1Click:Connect(function()
		NutBienHinhNgoai.Size = UDim2.new(1, 0, 1, 0)
		local TS = game:GetService("TweenService")
		local thuNho = TS:Create(NutBienHinhNgoai, TweenInfo.new(0.1), {Size = UDim2.new(0.9, 0, 0.9, 0)})
		local phongTo = TS:Create(NutBienHinhNgoai, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 1, 0)})
		thuNho:Play()
		task.delay(0.1, function()
			if NutBienHinhNgoai then phongTo:Play() end
		end)

		local ok, msg = Transform_Logic.DoTransform()
		if msg then ThongBao(ok and "Thành công" or "Lỗi", msg, 2) end
	end)

	if CauHinh.AutoCloseUI then
		shared.HxUI_DangThuNho = true
	else
		MoGiaoDien()
	end
end

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)
TaoGiaoDien()
