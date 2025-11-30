local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local NguoiChoi = Players.LocalPlayer
local PlayerGui = NguoiChoi:WaitForChild("PlayerGui")
local PlayerScripts = NguoiChoi:WaitForChild("PlayerScripts")

local GuiThongBao = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Notify.lua"))()
local function ThongBao(TieuDe, NoiDung, ThoiGian) GuiThongBao.thongbao(TieuDe, NoiDung, ThoiGian) end
local function ThongBaoLoi(TieuDe, NoiDung) GuiThongBao.thongbaoloi(TieuDe, NoiDung) end

local HoatAnh = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Animation.lua"))()
local KhungCuon = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/KhungCuon.lua"))()
local Khoi = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Transform/Khoi_Logic.lua"))()

local CauHinh = {
	Mau = {
		Nen = Color3.fromRGB(18, 18, 18),
		NenList = Color3.fromRGB(35, 35, 35),
		NenKhoi = Color3.fromRGB(45, 45, 45),
		NenMuc = Color3.fromRGB(60, 60, 60),
		NenHop = Color3.fromRGB(25, 25, 25),
		VienHop = Color3.fromRGB(80, 80, 80),
		NenPhu = Color3.fromRGB(45, 45, 45),
		ChonPhu = Color3.fromRGB(60, 60, 60),
		TichBat = Color3.fromRGB(180, 180, 180),
		NutDong = Color3.fromRGB(80, 80, 80),
		NutDongLuot = Color3.fromRGB(200, 0, 0),
		Chu = Color3.fromRGB(240, 240, 240),
		ChuMo = Color3.fromRGB(180, 180, 180),
		Vien = Color3.fromRGB(255, 255, 255)
	},
	KichThuoc = {
		Header = 38,
		Cach = 8,
		NutDong = 30,
		IconLon = UDim2.new(0, 80, 0, 80),
		IconNho = UDim2.new(0, 35, 0, 35)
	},
	Asset = {
		Icon = "rbxassetid://117118515787811",
		MuiTenXuong = "rbxassetid://6031091004"
	},
	VanBan = {
		Nut = 18,
		Nho = 12,
		TieuDe = 14
	}
}

local function BaoTrangThai(TenChucNang, TrangThai)
	local NoiDung = TrangThai and "Đã bật " .. TenChucNang or "Đã tắt " .. TenChucNang
	ThongBao("Hx Script", NoiDung, 2)
end

local DuLieuDanhSachKhoiUI = {}
local TaiLaiGiaoDien = nil 

local function TaoCauTrucItemChoKhoi(Obj)
	local TenHienThi = Obj.Name
	local LaNhom = Obj:IsA("Model")

	return {
		Ten = LaNhom and "[NHÓM] " .. TenHienThi or TenHienThi,
		Loai = "Otich", 
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
				Ten = "Cho Phép Chọn",
				Loai = "Otich",
				HienTai = "Bat",
				CacNutCon = {
					{
						Ten = "Cho Phép Di Chuyển",
						Loai = "Otich",
						HienTai = "Bat",
						SuKien = function(TrangThai)
							if TrangThai then
								ThongBao("Hx Script", "Đã bật di chuyển riêng: " .. TenHienThi, 1)
							else
								ThongBao("Hx Script", "Đã khóa di chuyển riêng: " .. TenHienThi, 1)
							end
						end
					}
				},
				SuKien = function(TrangThai)
					if TrangThai then
						ThongBao("Hx Script", "Đã bật chọn riêng: " .. TenHienThi, 1)
					else
						ThongBao("Hx Script", "Đã khóa chọn riêng: " .. TenHienThi, 1)
					end
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
	if TaiLaiGiaoDien then TaiLaiGiaoDien() end
end)

local DanhSachNhom = {
	{
		TieuDe = "Main Transform",
		ChucNang = {
			{
				Ten = "Chức Năng Biến Hình",
				Loai = "Otich",
				HienTai = "Bat",
				CacNutCon = {
					{
						Ten = "Hiển Thị Nút Chức Năng",
						Loai = "Otich",
						HienTai = "Bat",
						SuKien = function(TrangThai)
							BaoTrangThai("hiển thị nút chức năng thành công!", TrangThai)
						end
					},
					{
						Ten = "Hiển thị Outline Vùng Chọn",
						Loai = "Otich",
						HienTai = "Bat",
						SuKien = function(TrangThai)
							BaoTrangThai("hiển thị outline vùng chọn cho các part.", TrangThai)
						end
					},
				},
				SuKien = function(TrangThai)
					BaoTrangThai("chức năng biến hình!", TrangThai)
				end
			},
		}
	},
	{
		TieuDe = "Nhân Vật Transform",
		ChucNang = {
			{
				Loai = "NhieuNut",
				Ten_1 = "Tạo Nhân Vật Mẫu",
				SuKien_1 = function()
					ThongBaoLoi("Hx Script", "Tính năng đang phát triển!")
				end,
				Ten_2 = "Xóa Nhân Vật Chọn",
				SuKien_2 = function()
					ThongBaoLoi("Hx Script", "Tính năng đang phát triển!")
				end,
			},
			{
				Ten = "Cho Phép Di Chuyển",
				Loai = "Otich",
				HienTai = "Bat",
				SuKien = function(TrangThai)
					ThongBaoLoi("Hx Script", "Tính năng đang phát triển!")
				end
			},
			{
				Ten = "Cho Phép Chọn",
				Loai = "Otich",
				HienTai = "Bat",
				SuKien = function(TrangThai)
					ThongBaoLoi("Hx Script", "Tính năng đang phát triển!")
				end
			},
			{
				Ten = "Transform",
				Loai = "Nut",
				SuKien = function()
					ThongBaoLoi("Hx Script", "Tính năng đang phát triển!")
				end
			}
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
								Ten = "Phần Đầu",
								Loai = "Otich",
								HienTai = "Bat",
								LoaiNutCon = "CungHang",
								CacNutCon = {
									{
										Ten = "Lưu Trữ",
										SuKien = function() ThongBao("Hx Script", "Đã lưu trữ Phần Đầu!", 3) end
									},
									{
										Ten = "Xóa Lưu",
										SuKien = function() ThongBao("Hx Script", "Đã xóa lưu Phần Đầu!", 3) end
									}
								}
							},
							{
								Ten = "Phần Thân",
								Loai = "Otich",
								HienTai = "Bat",
								LoaiNutCon = "CungHang",
								CacNutCon = {
									{
										Ten = "Lưu Trữ",
										SuKien = function() ThongBao("Hx Script", "Đã lưu trữ Phần Thân!", 3) end
									},
									{
										Ten = "Xóa Lưu",
										SuKien = function() ThongBao("Hx Script", "Đã xóa lưu Phần Thân!", 3) end
									}
								}
							},
						}
					},
					"Nhân Vật"
				}
			},
		}
	},
	{
		TieuDe = "Tạo Khối",
		ChucNang = {
			{
				Loai = "NhieuNut",
				Ten_1 = "Tạo Khối Mẫu",
				SuKien_1 = function()
					local TenKhoi = Khoi.TaoKhoiMau()
					if TenKhoi then
						ThongBao("Hx Script", "Đã tạo: " .. TenKhoi, 1)
					end
				end,
				Ten_2 = "Xóa Khối Chọn",
				SuKien_2 = function()
					Khoi.XoaKhoiChon()
					ThongBao("Hx Script", "Đã xóa các khối được chọn!", 1)
				end,
			},
			{
				Ten = "Danh Sách (Tự động)",
				Loai = "Danhsach",
				Danhsach = DuLieuDanhSachKhoiUI
			},
			{
				Loai = "NhieuNut",
				Ten_1 = "Hàn (Tạo Nhóm)",
				SuKien_1 = function()
					local Msg = Khoi.HanCacKhoi()
					ThongBao("Hx Build", Msg, 2)
				end,
				Ten_2 = "Tháo Hàn (Rã Nhóm)",
				SuKien_2 = function()
					local Msg = Khoi.ThaoCacKhoi()
					ThongBao("Hx Build", Msg, 2)
				end,
			}
		}
	}
}

local function TaoGiaoDien()
	if PlayerGui:FindFirstChild("TransformUI") then PlayerGui.TransformUI:Destroy() end

	local DangHanhDong = false
	local KiemTraDienThoai = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
	local KichThuocMo = UDim2.new(0, 550, 0, 380)

	local ManHinhGui = Instance.new("ScreenGui")
	ManHinhGui.Name = "TransformUI"
	ManHinhGui.ResetOnSpawn = false
	ManHinhGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ManHinhGui.Parent = PlayerGui

	local LopPhu = Instance.new("Frame")
	LopPhu.Name = "LopPhu"
	LopPhu.Size = UDim2.fromScale(1, 1)
	LopPhu.BackgroundTransparency = 1
	LopPhu.ZIndex = 100
	LopPhu.Parent = ManHinhGui

	local ClickOutside = Instance.new("TextButton")
	ClickOutside.Size = UDim2.fromScale(1, 1)
	ClickOutside.BackgroundTransparency = 1
	ClickOutside.Text = ""
	ClickOutside.Visible = false
	ClickOutside.ZIndex = 99
	ClickOutside.Parent = ManHinhGui

	local function CloseAllDropdowns()
		for _, c in ipairs(LopPhu:GetChildren()) do c:Destroy() end
		ClickOutside.Visible = false
	end
	ClickOutside.MouseButton1Click:Connect(CloseAllDropdowns)

	local NutMoUI = Instance.new("ImageButton")
	NutMoUI.Name = "NutMoUI"
	NutMoUI.Size = UDim2.new(0, 50, 0, 50)
	NutMoUI.Position = UDim2.new(0, 20, 0.4, 0)
	NutMoUI.Image = CauHinh.Asset.Icon
	NutMoUI.BackgroundColor3 = CauHinh.Mau.Nen
	NutMoUI.BackgroundTransparency = 0.2
	NutMoUI.Parent = ManHinhGui
	Instance.new("UICorner", NutMoUI).CornerRadius = UDim.new(0, 12)
	HoatAnh.KeoTha(NutMoUI, NutMoUI)

	local KhungChinh = Instance.new("Frame")
	KhungChinh.Name = "KhungChinh"
	KhungChinh.Size = CauHinh.KichThuoc.IconLon
	KhungChinh.Position = UDim2.new(0.5, 0, 0.5, 0)
	KhungChinh.AnchorPoint = Vector2.new(0.5, 0.5)
	KhungChinh.BackgroundColor3 = CauHinh.Mau.Nen
	KhungChinh.BackgroundTransparency = 1
	KhungChinh.ClipsDescendants = true
	KhungChinh.Visible = false
	KhungChinh.Parent = ManHinhGui
	Instance.new("UICorner", KhungChinh).CornerRadius = UDim.new(0, 10)

	local BieuTuong = Instance.new("ImageLabel")
	BieuTuong.Size = UDim2.fromOffset(0, 0)
	BieuTuong.Position = UDim2.new(0.5, 0, 0.5, 0)
	BieuTuong.AnchorPoint = Vector2.new(0.5, 0.5)
	BieuTuong.Image = CauHinh.Asset.Icon
	BieuTuong.BackgroundTransparency = 0.6
	BieuTuong.BackgroundColor3 = Color3.new(0, 0, 0)
	BieuTuong.ZIndex = 2
	BieuTuong.Parent = KhungChinh
	Instance.new("UICorner", BieuTuong).CornerRadius = UDim.new(0, 12)

	local KhungBaoNoiDung = Instance.new("Frame")
	KhungBaoNoiDung.Name = "KhungBaoNoiDung"
	KhungBaoNoiDung.Size = UDim2.fromScale(1, 1)
	KhungBaoNoiDung.BackgroundTransparency = 1
	KhungBaoNoiDung.ZIndex = 2
	KhungBaoNoiDung.Parent = KhungChinh

	local TieuDe = Instance.new("TextLabel")
	TieuDe.Text = "Hx - Transform Script"
	TieuDe.Size = UDim2.new(1, -80, 0, 40)
	TieuDe.Position = UDim2.new(0, 50, 0, 5)
	TieuDe.BackgroundTransparency = 1
	TieuDe.TextColor3 = CauHinh.Mau.Chu
	TieuDe.Font = Enum.Font.GothamBold
	TieuDe.TextSize = 20
	TieuDe.TextXAlignment = Enum.TextXAlignment.Left
	TieuDe.TextTransparency = 1
	TieuDe.ZIndex = 5
	TieuDe.Parent = KhungBaoNoiDung

	local NutDong = Instance.new("TextButton")
	NutDong.Size = UDim2.fromOffset(CauHinh.KichThuoc.NutDong, CauHinh.KichThuoc.NutDong)
	NutDong.Position = UDim2.new(1, -25, 0, 25)
	NutDong.AnchorPoint = Vector2.new(0.5, 0.5)
	NutDong.Text = "X"
	NutDong.TextSize = 18
	NutDong.Font = Enum.Font.GothamBlack
	NutDong.BackgroundColor3 = CauHinh.Mau.NutDong
	NutDong.TextColor3 = CauHinh.Mau.Chu
	NutDong.ZIndex = 10
	NutDong.Transparency = 1
	NutDong.Parent = KhungChinh
	Instance.new("UICorner", NutDong).CornerRadius = UDim.new(0, 6)

	local VienNutDong = Instance.new("UIStroke")
	VienNutDong.Color = CauHinh.Mau.Vien
	VienNutDong.Transparency = 1
	VienNutDong.Thickness = 1.5
	VienNutDong.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	VienNutDong.Parent = NutDong

	local VungCuon = Instance.new("ScrollingFrame")
	VungCuon.Size = UDim2.new(1, -20, 1, -55)
	VungCuon.Position = UDim2.new(0.5, 0, 1, -10)
	VungCuon.AnchorPoint = Vector2.new(0.5, 1)
	VungCuon.BackgroundColor3 = CauHinh.Mau.NenList
	VungCuon.BackgroundTransparency = 0.6 
	VungCuon.ScrollBarThickness = 4
	VungCuon.BorderSizePixel = 0
	VungCuon.ZIndex = 2
	VungCuon.Parent = KhungChinh
	Instance.new("UICorner", VungCuon).CornerRadius = UDim.new(0, 6)

	TaiLaiGiaoDien = function()
		if not VungCuon or not VungCuon.Parent then return end
		VungCuon:ClearAllChildren()
		KhungCuon.Tao(VungCuon, DanhSachNhom, CauHinh, LopPhu, function()
			CloseAllDropdowns()
			ClickOutside.Visible = true
		end)
	end

	KhungCuon.Tao(VungCuon, DanhSachNhom, CauHinh, LopPhu, function()
		CloseAllDropdowns()
		ClickOutside.Visible = true
	end)

	local CacPhanTu = {
		Khung = KhungChinh, 
		Icon = BieuTuong, 
		TieuDe = TieuDe, 
		NutDong = NutDong, 
		VienNutDong = VienNutDong,
		KhungNoiDung = VungCuon   
	}

	local CauHinhHieuUng = {
		IconDau = CauHinh.KichThuoc.IconLon, 
		IconCuoi = CauHinh.KichThuoc.IconNho,
		ViTriIconDau = UDim2.new(0.5, 0, 0.5, 0), 
		ViTriIconCuoi = UDim2.new(0, 25, 0, 25),
		KhungDau = CauHinh.KichThuoc.IconLon, 
		KhungCuoi = KichThuocMo,
		KichThuocNutDongNay = UDim2.new(0, 42, 0, 42), 
		DoTrongSuotKhung = 0.15 
	}

	HoatAnh.KeoTha(KhungChinh, KhungChinh)

	local function DongGiaoDien()
		if DangHanhDong or not KhungChinh.Visible then return end
		DangHanhDong = true
		HoatAnh.DongGiaoDien(CacPhanTu, CauHinhHieuUng, function()
			KhungChinh.Visible = false
			DangHanhDong = false
		end)
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
		if not DangHanhDong then
			HoatAnh.LuotChuot(NutDong, true, NutDongLuot, NutDongThuong)
			TweenService:Create(VienNutDong, TweenInfo.new(0.3), {Transparency = 0.4}):Play()
		end
	end)
	NutDong.MouseLeave:Connect(function()
		if not DangHanhDong then
			HoatAnh.LuotChuot(NutDong, false, NutDongLuot, NutDongThuong)
			TweenService:Create(VienNutDong, TweenInfo.new(0.3), {Transparency = 0.8}):Play()
		end
	end)

	NutDong.MouseButton1Click:Connect(DongGiaoDien)
	NutMoUI.MouseButton1Click:Connect(function()
		HoatAnh.NhanChuot(NutMoUI) 
		if KhungChinh.Visible then DongGiaoDien() else MoGiaoDien() end
	end)

	MoGiaoDien()
end

if not game:IsLoaded() then game.Loaded:Wait() end
TaoGiaoDien()
