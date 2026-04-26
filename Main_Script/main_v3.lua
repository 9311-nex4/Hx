local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local NguoiChoi = Players.LocalPlayer
local PlayerGui = NguoiChoi:WaitForChild("PlayerGui")
local PlayerScripts = NguoiChoi:WaitForChild("PlayerScripts")

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

local GuiThongBao = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/ThongBao.lua"))()
local function ThongBao(TieuDe, NoiDung, ThoiGian) GuiThongBao.thongbao("Hx Script | " .. TieuDe, NoiDung, ThoiGian or 2) end
local function ThongBaoLoi(TieuDe, NoiDung) GuiThongBao.thongbaoloi("Hx Script | " .. TieuDe, NoiDung) end

local ChuDe = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/ChuDe.lua"))()
local TimKiem = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/TimKiem.lua"))()
local HoatAnh = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/Animation.lua"))()
local ThuVienUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/ThuVienUI.lua"))()
local MenuConfigManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/MenuConfigManager.lua"))()

local AutoClickLogic = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Main_Script/Main_Utilities/AutoClick_Logic.lua"))()
local ETC_Logic = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Main_Script/Main_Utilities/ETC_Logic.lua"))()

MenuConfigManager.SetFileName("main_v3")

local PhimMoMenu = Enum.KeyCode.Insert
local PhimAutoClick = Enum.KeyCode.R

local CauHinh = {
	DangTab = true, TabMacDinh = "Auto Click", SoCot = 1,
	ConfigMenu = true, TimKiem = true,
	KichThuoc = { Header = 45, Cach = 8, IconLon = UDim2.new(0, 90, 0, 90) },
	Asset = { Icon = "rbxassetid://117118515787811", MuiTenXuong = "rbxassetid://6031091004" },
	VanBan = { Nut = 14, Nho = 13, TieuDe = 15 },
	Mau = {},
	DoTrongSuotKhung = 0.4,
	QuickAnim = false,
	AutoCloseUI = false
}

for k, v in pairs(ChuDe.MacDinh) do CauHinh.Mau[k] = v end

local DuLieuDanhSachClick = {}
local TimChucNang

local GlobalConfig = { 
	PhimMoMenu = "Insert", PhimAutoClick = "R", PhimClickTP = "T", FlyHotkey = "F", 
	ChuDeUI = {Ten = "Dark"}, DoTrongSuotKhung = 0.4,
	QuickAnim = false, AutoCloseUI = false, UISize = "1.0x (rec)"
}
local GameConfig = { 
	TocDoClick = "500", HideAll = false, DanhSachClick = {}, 
	ReduceLags = false, RemoveFog = false, FullBright = false, NoShadows = false, ETCConfig = {}
}

local function LuuGlobal() MenuConfigManager.SaveGlobal(GlobalConfig) end

local function LuuGame()
	GameConfig.DanhSachClick = {}
	for _, item in ipairs(DuLieuDanhSachClick) do 
		table.insert(GameConfig.DanhSachClick, { X = item.X, Y = item.Y, BatTat = (item.HienTai == "Bat"), DaAn = item.DaAn or false }) 
	end
	GameConfig.ETCConfig = ETC_Logic.GetConfig()
	MenuConfigManager.SaveGame(GameConfig)
end

CauHinh.LuuTheme = function(duLieuTheme)
	GlobalConfig.ChuDeUI = duLieuTheme
	LuuGlobal()
end

local function CapNhatDanhSachClick()
	for ViTri, DuLieuDanhSach in ipairs(DuLieuDanhSachClick) do 
		DuLieuDanhSach.Ten = "Click " .. ViTri .. " (" .. math.floor(DuLieuDanhSach.X) .. "," .. math.floor(DuLieuDanhSach.Y) .. ")" 
	end
	AutoClickLogic.CapNhatDiem(DuLieuDanhSachClick) 
	LuuGame()
	local cn = TimChucNang("Auto Click", "List Of Click Locations")
	if cn and cn.LamMoi then cn.LamMoi() end
end

local function TaoItemClick(ToaDoX, ToaDoY, BatTatBanDau, DaAnBanDau)
	local DuLieuNut = { X = ToaDoX, Y = ToaDoY, DaAn = DaAnBanDau or false, Loai = "Gat", HienTai = (BatTatBanDau == false) and "Tat" or "Bat" }
	DuLieuNut.SuKien = function(TrangThai) 
		ThongBao("Status", TrangThai and ("Bật " .. DuLieuNut.Ten) or ("Tắt " .. DuLieuNut.Ten), 1) 
		LuuGame() 
	end
	DuLieuNut.CacNutCon = {
		{
			Ten = "Hide Click Location", Loai = "Gat", HienTai = DuLieuNut.DaAn and "Bat" or "Tat",
			SuKien = function(TrangThai) 
				DuLieuNut.DaAn = TrangThai 
				AutoClickLogic.CapNhatDiem(DuLieuDanhSachClick) 
				LuuGame() 
				ThongBao("Status", TrangThai and "Ẩn UI " .. DuLieuNut.Ten or "Hiện UI " .. DuLieuNut.Ten, 1) 
			end
		},
		{
			Ten = "DieuKhienItem", Loai = "NhieuNut",
			DanhSachNut = {
				{ Ten = "Up", SuKien = function() 
					local ViTriNut = table.find(DuLieuDanhSachClick, DuLieuNut) 
					if ViTriNut and ViTriNut > 1 then 
						DuLieuDanhSachClick[ViTriNut], DuLieuDanhSachClick[ViTriNut - 1] = DuLieuDanhSachClick[ViTriNut - 1], DuLieuDanhSachClick[ViTriNut] 
						CapNhatDanhSachClick() 
					end 
				end },
				{ Ten = "Delete", SuKien = function() 
					local ViTriXoa = table.find(DuLieuDanhSachClick, DuLieuNut) 
					if ViTriXoa then 
						table.remove(DuLieuDanhSachClick, ViTriXoa) 
						CapNhatDanhSachClick() 
						ThongBao("Hệ Thống", "Xóa 1 vị trí", 1) 
					end 
				end },
				{ Ten = "Down", SuKien = function() 
					local ViTriNut = table.find(DuLieuDanhSachClick, DuLieuNut) 
					if ViTriNut and ViTriNut < #DuLieuDanhSachClick then 
						DuLieuDanhSachClick[ViTriNut], DuLieuDanhSachClick[ViTriNut + 1] = DuLieuDanhSachClick[ViTriNut + 1], DuLieuDanhSachClick[ViTriNut] 
						CapNhatDanhSachClick() 
					end 
				end }
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

local function CapNhatDanhSachESPItem()
	local mucList = TimChucNang("ETC", "List of items being added")
	if mucList then 
		mucList.Danhsach = ETC_Logic.ListItemsESP 
		if mucList.LamMoi then mucList.LamMoi() end 
	end
end

local function ThemItemVaoESP(TenItem)
	if TenItem == "..." or TenItem == "" then return end
	for _, v in ipairs(ETC_Logic.ListItemsESP) do if v.Ten == TenItem then return end end
	table.insert(ETC_Logic.ListItemsESP, {
		Ten = TenItem, Loai = "Nut", SauBam = "Thay", 
		SuKien = function() ETC_Logic.HighlightForDeletion(TenItem) end,
		DanhSachThay = {
			Ten = "Confirm Delete", Loai = "Nut", Mau = Color3.new(0.8, 0, 0),
			SuKien = function() 
				for i, v in ipairs(ETC_Logic.ListItemsESP) do 
					if v.Ten == TenItem then 
						table.remove(ETC_Logic.ListItemsESP, i) 
						break 
					end 
				end 
				CapNhatDanhSachESPItem() 
				LuuGame() 
			end
		}
	})
	CapNhatDanhSachESPItem()
	LuuGame()
end

CauHinh.LuuTrongSuot = function(val) GlobalConfig.DoTrongSuotKhung = val LuuGlobal() end
CauHinh.LuuQuickAnim = function(val) GlobalConfig.QuickAnim = val LuuGlobal() end
CauHinh.LuuAutoClose = function(val) GlobalConfig.AutoCloseUI = val LuuGlobal() end
CauHinh.UISize = "1.0x (rec)"
CauHinh.LuuKichThuoc = function(val) GlobalConfig.UISize = val LuuGlobal() end

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

local DanhSachNhom = {
	{
		TenTab = "Auto Click", DuLieuKhoi = {{ TieuDe = "Auto Click Config", ChucNang = {
			{ Ten = "Auto Click", Loai = "Gat", HienTai = "Tat", SuKien = function(st) AutoClickLogic.BatTatAutoClick(st) GameConfig.AutoClick = st LuuGame() end },
			{ Ten = "Speed Click (ms)", Loai = "Odien", HienTai = "500", GoiY = "Nhập tốc độ...", SuKien = function(val) if tonumber(val) then AutoClickLogic.CaiDatTocDo(val) GameConfig.TocDoClick = val LuuGame() end end },
			{ Ten = "Auto Click Hotkey", Loai = "PhimNong", HienTai = "R", SuKien = function(key) PhimAutoClick = key GlobalConfig.PhimAutoClick = key.Name LuuGlobal() end },
			{ Ten = "DieuKhienClick", Loai = "NhieuNut", Ten1 = "Create Click", Ten2 = "Hide All: OFF",
				SuKien1 = function() 
					table.insert(DuLieuDanhSachClick, TaoItemClick(workspace.CurrentCamera.ViewportSize.X * 0.5, workspace.CurrentCamera.ViewportSize.Y * 0.5, true, false)) 
					CapNhatDanhSachClick() 
				end,
				SuKien2 = function() 
					local self = TimChucNang("Auto Click", "DieuKhienClick") 
					GameConfig.HideAll = not GameConfig.HideAll 
					if self then 
						self.Ten2 = GameConfig.HideAll and "Hide All: ON" or "Hide All: OFF" 
						if self.LamMoi then self.LamMoi() end 
					end 
					AutoClickLogic.BatTatAnToanBo(GameConfig.HideAll) 
					LuuGame() 
				end
			},
			{ Ten = "List Of Click Locations", Loai = "Danhsach", DangMo = false, Danhsach = DuLieuDanhSachClick }
		}}}
	},
	{
		TenTab = "ETC", SoCot = 2, DuLieuKhoi = {
			{ TieuDe = "Teleport", ChucNang = {
				{ Ten = "Click TP", Loai = "Gat", HienTai = "Tat", SuKien = function(st) ETC_Logic.SetClickTP(st) end, CacNutCon = { { Ten = "Click TP Hotkey", Loai = "PhimNong", HienTai = "T", SuKien = function(key) ETC_Logic.SetKey(key) GlobalConfig.PhimClickTP = key.Name LuuGlobal() end } } },
				{ Ten = "Map Teleport", Loai = "Gat", HienTai = "Tat", SuKien = function() end, CacNutCon = { 
				{ Ten = "Select Location", Loai = "HopXo", HienTai = "...", LuaChon = ETC_Logic.LayDiaDiemGame(game.PlaceId), SuKien = function() end }, 
				{ Loai = "NhieuNut", DanhSachNut = { 
					{ Ten = "TP", SuKien = function() local cn = TimChucNang("ETC", "Select Location") if cn and cn.HienTai ~= "..." then ThongBao("Di Chuyển", "Bay tới: " .. cn.HienTai, 1) end end }, 
					{ Ten = "Stop", SuKien = function() ETC_Logic.StopTP() ThongBao("Di Chuyển", "Dừng Teleport", 1) end } 
				}} 
				}},
				{ Ten = "Player Teleport", Loai = "Gat", HienTai = "Tat", SuKien = function() end, CacNutCon = { 
				{ Ten = "Select Player", Loai = "HopXo", HienTai = "...", LuaChon = ETC_Logic.GetPlayers(), SuKien = function() end }, 
				{ Ten = "Target Lock Player", Loai = "Gat", HienTai = "Tat", SuKien = function(st) local cn = TimChucNang("ETC", "Select Player") if cn and cn.HienTai ~= "..." then ETC_Logic.TargetLock("Player", cn.HienTai, st) end end }, 
				{ Loai = "NhieuNut", DanhSachNut = { 
					{ Ten = "TP", SuKien = function() local cn = TimChucNang("ETC", "Select Player") if cn and cn.HienTai ~= "..." then ETC_Logic.TeleportToPlayer(cn.HienTai) ThongBao("Di Chuyển", "Bay tới: " .. cn.HienTai, 1.5) end end }, 
					{ Ten = "Refresh", Loai = "Nut", SuKien = function() local cn = TimChucNang("ETC", "Select Player") if cn then cn.LuaChon = ETC_Logic.GetPlayers() ThongBao("Hệ Thống", "Làm mới Player List", 1) end end }, 
					{ Ten = "Stop", SuKien = function() ETC_Logic.StopTP() ThongBao("Di Chuyển", "Dừng Teleport", 1) end } 
				}} 
				}}
			}},
			{ TieuDe = "Visuals (ESP)", ChucNang = {
				{ Ten = "Enable ESP", Loai = "Gat", HienTai = "Tat", SuKien = function() end, CacNutCon = {
				{ Ten = "ESP Player", Loai = "Gat", HienTai = "Tat", SuKien = function(st) ETC_Logic.ESP_Players = st LuuGame() end },
				{ Ten = "ESP Part", Loai = "Gat", HienTai = "Tat", SuKien = function(st) ETC_Logic.ESP_Items = st LuuGame() end },
				{ Ten = "Tracker (Player & Item)", Loai = "Gat", HienTai = "Tat", SuKien = function(st) ETC_Logic.ESP_Tracker = st LuuGame() end },
				{ Ten = "Select Template", Loai = "Gat", HienTai = "Tat", SuKien = function(st) ETC_Logic.ToggleTemplateSelection(st, function(ten) ThongBao("ESP", "Đang chọn: " .. ten, 1) end) if st then ThongBao("ESP", "Hãy click vào vật thể bất kỳ", 2) end end },
				{ Ten = "Add Selected", Loai = "Nut", SuKien = function() local ten = ETC_Logic.AddCurrentTemplate() if ten then ThemItemVaoESP(ten) ThongBao("ESP", "Thêm Template: " .. ten, 1.5) else ThongBaoLoi("ESP", "Bạn chưa click chọn vật thể nào!") end end },
				{ Ten = "List of items being added", Loai = "Danhsach", DangMo = false, Danhsach = ETC_Logic.ListItemsESP }
				}}
			}},
			{ TieuDe = "Movement", ChucNang = {
				{ Ten = "Noclip", Loai = "Gat", HienTai = "Tat", SuKien = function(st) ETC_Logic.ToggleNoclip(st) end},
				{ Ten = "Fly", Loai = "Gat", HienTai = "Tat", SuKien = function(st) ETC_Logic.ToggleFly(st) end, CacNutCon = {
				{ Ten = "Speed Fly", Loai = "Odien", HienTai = tostring((NguoiChoi.Character and NguoiChoi.Character:FindFirstChildOfClass("Humanoid")) and NguoiChoi.Character:FindFirstChildOfClass("Humanoid").WalkSpeed or 16), GoiY = "Nhập tốc độ", SuKien = function(val) ETC_Logic.FlySpeed = tonumber(val) or 16 LuuGame() end },
				{ Ten = "Hotkey Fly", Loai = "PhimNong", HienTai = "F", SuKien = function(key) ETC_Logic.FlyHotkey = key GlobalConfig.FlyHotkey = key.Name LuuGlobal() end },
				{ Ten = "Enable Collide", Loai = "Gat", HienTai = "Tat", SuKien = function(st) ETC_Logic.FlyCollide = st LuuGame() end }
				}}
			}}
		}
	}
}

local function DuyetChucNang(DanhSach, TenChucNang)
	for _, CN in ipairs(DanhSach) do
		if CN.Ten == TenChucNang then return CN end
		if CN.CacNutCon then 
			local res = DuyetChucNang(CN.CacNutCon, TenChucNang) 
			if res then return res end 
		end
	end 
	return nil
end

function TimChucNang(TenTab, TenChucNang)
	for _, Nhom in ipairs(DanhSachNhom) do 
		if Nhom.TenTab == TenTab then 
			for _, Khoi in ipairs(Nhom.DuLieuKhoi) do 
				local res = DuyetChucNang(Khoi.ChucNang, TenChucNang) 
				if res then return res end 
			end 
		end 
	end 
	return nil
end

local function ApDungConfig(globalCfg, gameCfg)
	if globalCfg then
		if globalCfg.PhimMoMenu then pcall(function() PhimMoMenu = Enum.KeyCode[globalCfg.PhimMoMenu] end) local cn = TimChucNang("Config Menu", "HotKeys Open Menu") if cn then cn.HienTai = globalCfg.PhimMoMenu end end
		if globalCfg.PhimAutoClick then pcall(function() PhimAutoClick = Enum.KeyCode[globalCfg.PhimAutoClick] end) local cn = TimChucNang("Auto Click", "Auto Click Hotkey") if cn then cn.HienTai = globalCfg.PhimAutoClick end end
		if globalCfg.PhimClickTP then pcall(function() ETC_Logic.SetKey(Enum.KeyCode[globalCfg.PhimClickTP]) end) local cn = TimChucNang("ETC", "Click TP Hotkey") if cn then cn.HienTai = globalCfg.PhimClickTP end end
		if globalCfg.FlyHotkey then pcall(function() ETC_Logic.FlyHotkey = Enum.KeyCode[globalCfg.FlyHotkey] end) local cn = TimChucNang("ETC", "Hotkey Fly") if cn then cn.HienTai = globalCfg.FlyHotkey end end
		if globalCfg.ChuDeUI then CauHinh.ChuDeDaLuu = globalCfg.ChuDeUI end
		if globalCfg.DoTrongSuotKhung ~= nil then CauHinh.DoTrongSuotKhung = globalCfg.DoTrongSuotKhung end
		if globalCfg.QuickAnim ~= nil then CauHinh.QuickAnim = globalCfg.QuickAnim end
		if globalCfg.AutoCloseUI ~= nil then CauHinh.AutoCloseUI = globalCfg.AutoCloseUI end
		if globalCfg.UISize then CauHinh.UISize = globalCfg.UISize end
		for k, v in pairs(globalCfg) do GlobalConfig[k] = v end
	end

	if gameCfg then
		if gameCfg.TocDoClick then AutoClickLogic.CaiDatTocDo(tostring(gameCfg.TocDoClick)) local cn = TimChucNang("Auto Click", "Speed Click (ms)") if cn then cn.HienTai = tostring(gameCfg.TocDoClick) end end
		if gameCfg.ReduceLags then MenuConfigManager.ReduceLags(true) local cn = TimChucNang("Config Menu", "Reduce Lags") if cn then cn.HienTai = "Bat" end end
		if gameCfg.RemoveFog then MenuConfigManager.RemoveFog(true) local cn = TimChucNang("Config Menu", "Removes Fog") if cn then cn.HienTai = "Bat" end end
		if gameCfg.FullBright then MenuConfigManager.FullBright(true) local cn = TimChucNang("Config Menu", "Fully Bright") if cn then cn.HienTai = "Bat" end end
		if gameCfg.NoShadows then MenuConfigManager.NoShadows(true) local cn = TimChucNang("Config Menu", "No Shadows") if cn then cn.HienTai = "Bat" end end
		if type(gameCfg.DanhSachClick) == "table" then for _, saved in ipairs(gameCfg.DanhSachClick) do if tonumber(saved.X) and tonumber(saved.Y) then table.insert(DuLieuDanhSachClick, TaoItemClick(tonumber(saved.X), tonumber(saved.Y), saved.BatTat ~= false, saved.DaAn == true)) end end CapNhatDanhSachClick() end
		if gameCfg.ETCConfig then
			ETC_Logic.SetConfig(gameCfg.ETCConfig)
			if type(gameCfg.ETCConfig.SavedItems) == "table" then for _, tenItem in ipairs(gameCfg.ETCConfig.SavedItems) do ThemItemVaoESP(tenItem) end end
			local cn = TimChucNang("ETC", "Speed Fly") if cn then cn.HienTai = tostring(ETC_Logic.FlySpeed) end
			cn = TimChucNang("ETC", "Enable Collide") if cn then cn.HienTai = ETC_Logic.FlyCollide and "Bat" or "Tat" end
			cn = TimChucNang("ETC", "ESP Player") if cn then cn.HienTai = ETC_Logic.ESP_Players and "Bat" or "Tat" end
			cn = TimChucNang("ETC", "ESP Part") if cn then cn.HienTai = ETC_Logic.ESP_Items and "Bat" or "Tat" end
			cn = TimChucNang("ETC", "Tracker (Player & Item)") if cn then cn.HienTai = ETC_Logic.ESP_Tracker and "Bat" or "Tat" end
		end
		for k, v in pairs(gameCfg) do GameConfig[k] = v end
	end
end

ApDungConfig(MenuConfigManager.LoadGlobal(), MenuConfigManager.LoadGame())

local function TaoGiaoDien()
	if ThuMucUI:FindFirstChild("main_v3") then ThuMucUI.main_v3:Destroy() end

	local ManHinhGui = Instance.new("ScreenGui") 
	ManHinhGui.Name = "main_v3" 
	ManHinhGui.ResetOnSpawn = false 
	ManHinhGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
	ManHinhGui.Parent = ThuMucUI

	local LopPhu = Instance.new("Frame") 
	LopPhu.Name = "LopPhu" 
	LopPhu.Size = UDim2.fromScale(1, 1) 
	LopPhu.BackgroundTransparency = 1 
	LopPhu.ZIndex = 100 
	LopPhu.Parent = ManHinhGui

	local ClickNgoai = Instance.new("TextButton") 
	ClickNgoai.Size = UDim2.fromScale(1, 1) 
	ClickNgoai.BackgroundTransparency = 1 
	ClickNgoai.Text = "" 
	ClickNgoai.Visible = false 
	ClickNgoai.ZIndex = 99 
	ClickNgoai.Parent = ManHinhGui

	local function DongTatCaXoXuong() 
		for _, PhanTuXo in ipairs(LopPhu:GetChildren()) do 
			if PhanTuXo:IsA("GuiObject") then PhanTuXo:Destroy() end 
		end 
		ClickNgoai.Visible = false 
	end
	ClickNgoai.MouseButton1Click:Connect(DongTatCaXoXuong)

	local NutMoUI = Instance.new("ImageButton") 
	NutMoUI.Name = "NutMoUI" 
	NutMoUI.Size = UDim2.fromOffset(45, 45) 
	NutMoUI.Position = UDim2.new(0, 30, 0.4, 0) 
	NutMoUI.Image = CauHinh.Asset.Icon 
	NutMoUI.BackgroundColor3 = CauHinh.Mau.Nen 
	NutMoUI.BackgroundTransparency = 0.2 
	NutMoUI.Active = true 
	NutMoUI.ZIndex = 999 

	local uiCornerNutMo = Instance.new("UICorner")
	uiCornerNutMo.CornerRadius = UDim.new(0, 10)
	uiCornerNutMo.Parent = NutMoUI
	NutMoUI.Parent = ManHinhGui
	HoatAnh.KeoTha(NutMoUI, NutMoUI)

	local KhungChinh = Instance.new("Frame") 
	KhungChinh.Name = "KhungChinh" 
	KhungChinh.Size = CauHinh.KichThuoc.IconLon 
	KhungChinh.Position = UDim2.fromScale(0.5, 0.5) 
	KhungChinh.AnchorPoint = Vector2.new(0.5, 0.5) 
	KhungChinh.BackgroundColor3 = CauHinh.Mau.Nen 
	KhungChinh.BackgroundTransparency = CauHinh.DoTrongSuotKhung or 0.4 
	KhungChinh.ClipsDescendants = true 
	KhungChinh.Visible = false 
	KhungChinh.Active = true 
	KhungChinh.Parent = ManHinhGui

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

	local uiCornerKhung = Instance.new("UICorner")
	uiCornerKhung.CornerRadius = UDim.new(0, 14)
	uiCornerKhung.Parent = KhungChinh

	local BieuTuong = Instance.new("ImageLabel") 
	BieuTuong.Size = UDim2.fromOffset(0, 0) 
	BieuTuong.Position = UDim2.fromScale(0.5, 0.5) 
	BieuTuong.AnchorPoint = Vector2.new(0.5, 0.5) 
	BieuTuong.Image = CauHinh.Asset.Icon 
	BieuTuong.BackgroundTransparency = 0.6 
	BieuTuong.BackgroundColor3 = Color3.new(0, 0, 0) 
	BieuTuong.ZIndex = 2 

	local uiCornerBieuTuong = Instance.new("UICorner")
	uiCornerBieuTuong.CornerRadius = UDim.new(0, 10)
	uiCornerBieuTuong.Parent = BieuTuong
	BieuTuong.Parent = KhungChinh

	local KhungBaoNoiDung = Instance.new("Frame") 
	KhungBaoNoiDung.Name = "KhungBaoNoiDung" 
	KhungBaoNoiDung.Size = UDim2.fromOffset(550, 400) 
	KhungBaoNoiDung.Position = UDim2.fromScale(0.5, 0.5)
	KhungBaoNoiDung.AnchorPoint = Vector2.new(0.5, 0.5)
	KhungBaoNoiDung.BackgroundTransparency = 1 
	KhungBaoNoiDung.ZIndex = 2
	KhungBaoNoiDung.Parent = KhungChinh

	local TieuDe = Instance.new("TextLabel") 
	TieuDe.Text = "Hx - Something Script" 
	TieuDe.Size = UDim2.new(1, -150, 0, 50) 
	TieuDe.Position = UDim2.fromOffset(60, 5) 
	TieuDe.BackgroundTransparency = 1 
	TieuDe.TextColor3 = CauHinh.Mau.Chu 
	TieuDe.Font = Enum.Font.GothamBold 
	TieuDe.TextSize = 18 
	TieuDe.TextXAlignment = Enum.TextXAlignment.Left 
	TieuDe.TextTransparency = 1 
	TieuDe.ZIndex = 5
	TieuDe.Parent = KhungBaoNoiDung

	local VungCuon = Instance.new("ScrollingFrame") 
	VungCuon.Size = UDim2.new(1, -24, 1, -65) 
	VungCuon.Position = UDim2.new(0.5, 0, 1, -12) 
	VungCuon.AnchorPoint = Vector2.new(0.5, 1) 
	VungCuon.BackgroundColor3 = CauHinh.Mau.NenList 
	VungCuon.BackgroundTransparency = 0.6 
	VungCuon.ScrollBarThickness = 6 
	VungCuon.BorderSizePixel = 0 
	VungCuon.ZIndex = 2 
	VungCuon.AutomaticCanvasSize = Enum.AutomaticSize.Y 
	VungCuon.CanvasSize = UDim2.new()

	local uiCornerVungCuon = Instance.new("UICorner")
	uiCornerVungCuon.CornerRadius = UDim.new(0, 8)
	uiCornerVungCuon.Parent = VungCuon

	local VienVungCuon = Instance.new("UIStroke") 
	VienVungCuon.Name = "VienNeon" 
	VienVungCuon.Color = CauHinh.Mau.VienNeon 
	VienVungCuon.Transparency = 0.5 
	VienVungCuon.Thickness = 0.5 
	VienVungCuon.Parent = VungCuon
	VungCuon.Parent = KhungBaoNoiDung

	local CacPhanTu = { Khung = KhungChinh, Icon = BieuTuong, TieuDe = TieuDe, KhungNoiDung = VungCuon }

	local function TaoCauHinhHieuUng()
		return {
			IconDau = CauHinh.KichThuoc.IconLon, 
			IconCuoi = UDim2.fromOffset(40, 40), 
			ViTriIconDau = UDim2.fromScale(0.5, 0.5), 
			ViTriIconCuoi = UDim2.fromOffset(30, 30), 
			KhungDau = CauHinh.KichThuoc.IconLon, 
			KhungCuoi = UDim2.fromOffset(550, 400),
			DoTrongSuotKhung = CauHinh.DoTrongSuotKhung or 0.4, 
			KichThuocNutDongNay = UDim2.fromOffset(45, 45)
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
				KhungChinh.Visible = false 
				DangHanhDong = false 
			end)
		end
	end

	local SuKienBanPhim = nil
	local function PhaHuyUI()
		GuiThongBao.thongbaoxacnhan("XÁC NHẬN", "Bạn có chắc chắn muốn đóng UI không?", function()
			pcall(function() AutoClickLogic.Destroy() end)
			pcall(function() ETC_Logic.ToggleFly(false) end)
			pcall(function() ETC_Logic.ToggleNoclip(false) end)
			pcall(function() ETC_Logic.StopTP() end)
			pcall(function() 
				ETC_Logic.ESP_Players = false 
				ETC_Logic.ESP_Items = false 
				ETC_Logic.ESP_Tracker = false 
			end)
			if SuKienBanPhim then pcall(function() SuKienBanPhim:Disconnect() end) end
			if ManHinhGui and ManHinhGui.Parent then ManHinhGui:Destroy() end
		end)
	end

	local PhanTuToolbar = ThuVienUI.Tao(KhungChinh, VungCuon, DanhSachNhom, CauHinh, LopPhu, function() DongTatCaXoXuong() ClickNgoai.Visible = true end, PhaHuyUI, DongGiaoDien)
	CacPhanTu.NutDong = PhanTuToolbar.NutMin    
	CacPhanTu.VienNutDong = PhanTuToolbar.VienMin
	CacPhanTu.Toolbar = PhanTuToolbar.Toolbar

	if CacPhanTu.Toolbar then CacPhanTu.Toolbar.Parent = KhungBaoNoiDung end

	KhungChinh:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		KhungBaoNoiDung.Visible = KhungChinh.AbsoluteSize.X >= 150
	end)

	local function MoGiaoDien()
		if DangHanhDong or KhungChinh.Visible then return end
		DangHanhDong = true
		KhungChinh.Visible = true
		shared.HxUI_DangThuNho = false

		if LuongEpKichThuoc then task.cancel(LuongEpKichThuoc) LuongEpKichThuoc = nil end
		if LuongCapNhatTab then task.cancel(LuongCapNhatTab) LuongCapNhatTab = nil end

		if CacPhanTu.NutDong then CacPhanTu.NutDong.Size = UDim2.fromOffset(35, 35) end

		local hieuUng = TaoCauHinhHieuUng()

		if CauHinh.QuickAnim then
			KhungChinh.Size = hieuUng.KhungCuoi
			KhungBaoNoiDung.Visible = true
			DangHanhDong = false
			if PhanTuToolbar and PhanTuToolbar.CapNhatTab then PhanTuToolbar.CapNhatTab(true) end
		else
			HoatAnh.MoGiaoDien(CacPhanTu, hieuUng, function()
				if KhungChinh.Visible and not shared.HxUI_DangThuNho then
					if PhanTuToolbar and PhanTuToolbar.CapNhatTab then PhanTuToolbar.CapNhatTab(true) end
				end
			end)

			LuongEpKichThuoc = task.delay(0.25, function()
				DangHanhDong = false
				if KhungChinh and KhungChinh.Visible and not shared.HxUI_DangThuNho then
					KhungChinh.Size = hieuUng.KhungCuoi
				end
			end)
		end
	end

	NutMoUI.MouseButton1Click:Connect(function() 
		NutMoUI.Size = UDim2.fromOffset(45, 45)
		local thuNho = TweenService:Create(NutMoUI, TweenInfo.new(0.1), {Size = UDim2.fromOffset(38, 38)})
		local phongTo = TweenService:Create(NutMoUI, TweenInfo.new(0.1), {Size = UDim2.fromOffset(45, 45)})
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
		end
		if DauVaoBanPhim.KeyCode == PhimAutoClick then
			if AutoClickLogic and AutoClickLogic.BatTatAutoClick then
				local TrangThaiMoi = not AutoClickLogic.DangChay
				AutoClickLogic.BatTatAutoClick(TrangThaiMoi) 
				GameConfig.AutoClick = TrangThaiMoi 
				LuuGame()
				local cn = TimChucNang("Auto Click", "Auto Click") 
				if cn and cn.SetTrangThai then cn.SetTrangThai(TrangThaiMoi) end
				ThongBao("Status", TrangThaiMoi and "Bật Auto Click" or "Tắt Auto Click", 1)
			end
		end
		if DauVaoBanPhim.KeyCode == ETC_Logic.FlyHotkey then
			local TrangThaiMoi = not ETC_Logic.FlyEnabled 
			ETC_Logic.ToggleFly(TrangThaiMoi)
			local cn = TimChucNang("ETC", "Fly") 
			if cn and cn.SetTrangThai then cn.SetTrangThai(TrangThaiMoi) end
			ThongBao("Status", TrangThaiMoi and "Bật Fly" or "Tắt Fly", 1)
		end
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
