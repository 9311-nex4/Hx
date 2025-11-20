local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local NguoiChoi = Players.LocalPlayer
local PlayerGui = NguoiChoi:WaitForChild("PlayerGui")
local PlayerScripts = NguoiChoi:WaitForChild("PlayerScripts")

local KhungCuon = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/KhungCuon.lua"))()
local HoatAnh = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Animation.lua"))()
local ThongBao = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Notify.lua"))()

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
	}
}

local function BaoTrangThai(TenChucNang, TrangThai)
	local NoiDung = TrangThai and "Đã bật " .. TenChucNang or "Đã tắt " .. TenChucNang
	ThongBao("Hx Script", NoiDung, 2)
end

local DanhSachNhom = {
	{
		TieuDe = "Main Transform",
		ChucNang = {
			{ 
				Ten = "Chức Năng Biến Hình", 
				Loai = "Otich",
				HienTai = "Bat",
				SuKien = function(TrangThai)
					BaoTrangThai("chức năng biến hình!", TrangThai)
				end
			},
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
		}
	},
	{
		TieuDe = "Nhân Vật Transform",
		ChucNang = {
			{
				Loai = "NhieuNut",
				Ten_1 = "Tạo Nhân Vật Mẫu",
				SuKien_1 = function() 
					ThongBao("Hx Script", "Đã tạo nhân vật tại vị trí của bạn!", 3) 
				end,
				Ten_2 = "Xóa Nhân Vật Chọn",
				SuKien_2 = function() 
					ThongBao("Hx Script", "Đã xóa nhân vật bạn chọn!", 3) 
				end,
			},
			{ 
				Ten = "Cho Phép Di Chuyển", 
				Loai = "Otich",
				HienTai = "Bat",
				SuKien = function(TrangThai)
					BaoTrangThai("di chuyển cho model nhân vật mẫu.", TrangThai)
				end
			},
			{ 
				Ten = "Cho Phép Chọn", 
				Loai = "Otich",
				HienTai = "Bat",
				SuKien = function(TrangThai)
					BaoTrangThai("chọn model nhân vật mẫu.", TrangThai)
				end
			},
			{ 
				Ten = "Thành Phần", 
				Loai = "HopXo", 
				HienTai = "Toàn Thân",
				LuaChon = {
					"Toàn Thân",
					{
						Ten = "Từng Phần",
						CacNutCon = {
							{ Ten = "Phần Đầu", Loai = "Otich" },
							{ Ten = "Phần Thân", Loai = "Otich" },
							{ Ten = "Tay Trái", Loai = "Otich" },
							{ Ten = "Tay Phải", Loai = "Otich" },
							{ Ten = "Chân Trái", Loai = "Otich" },
							{ Ten = "Chân Phải", Loai = "Otich" },
							{
								Loai = "NhieuNut",
								Ten_1 = "Lưu Trữ",
								SuKien_1 = function() 
									ThongBao("Hx Script", "Đã tạo khối tại vị trí của bạn!", 3) 
								end,
								Ten_2 = "Xóa Lưu",
								SuKien_2 = function() 
									ThongBao("Hx Script", "Đã xóa khối bạn chọn!", 3) 
								end,
							}
						}
					},
					"Nhân Vật"
				}
			},
			{ 
				Ten = "Transform", 
				Loai = "Nut",
				SuKien = function()
					ThongBao("Hx Script", "Biến theo nhân vật đã thực hiện!", 3)
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
							{ Ten = "Phần Đầu", Loai = "Otich" },
							{ Ten = "Phần Thân", Loai = "Otich" },
							{ Ten = "Tay Trái", Loai = "Otich" },
							{ Ten = "Tay Phải", Loai = "Otich" },
							{ Ten = "Chân Trái", Loai = "Otich" },
							{ Ten = "Chân Phải", Loai = "Otich" },
							{
								Loai = "NhieuNut",
								Ten_1 = "Lưu Trữ",
								SuKien_1 = function() 
									ThongBao("Hx Script", "Đã tạo khối tại vị trí của bạn!", 3) 
								end,
								Ten_2 = "Xóa Lưu",
								SuKien_2 = function() 
									ThongBao("Hx Script", "Đã xóa khối bạn chọn!", 3) 
								end,
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
				Ten_1 = "Tạo Khối Mẫu",
				SuKien_1 = function() 
					ThongBao("Hx Script", "Đã tạo khối tại vị trí của bạn!", 3) 
				end,
				Ten_2 = "Xóa Khối Chọn",
				SuKien_2 = function() 
					ThongBao("Hx Script", "Đã xóa khối bạn chọn!", 3) 
				end,
			},
			{ 
				Ten = "Cho Phép Di Chuyển", 
				Loai = "Otich",
				HienTai = "Bat",
				SuKien = function(TrangThai)
					BaoTrangThai("di chuyển cho model nhân vật mẫu.", TrangThai)
				end
			},
			{ 
				Ten = "Cho Phép Chọn", 
				Loai = "Otich",
				HienTai = "Bat",
				SuKien = function(TrangThai)
					BaoTrangThai("chọn model nhân vật mẫu.", TrangThai)
				end
			},
			{
				Ten = "Các Khối Đã Tạo",
				Loai = "Danhsach",
				Danhsach = {
					{
						Ten = "Khối 1",
						Loai = "Otich",
						HienTai = "Tat",
						SuKien = function(val) end
					},
					{
						Ten = "Khối 2",
						Loai = "Otich",
						HienTai = "Tat",
						SuKien = function(val) end
					}
				}
			},
			{
				Loai = "NhieuNut",
				Ten_1 = "Hàn Các Khối Đã Chọn",
				SuKien_1 = function() 
					ThongBao("Hx Script", "Đã hàn các khối.", 3) 
				end,
				Ten_2 = "Tháo Các Khối Đã Chọn",
				SuKien_2 = function() 
					ThongBao("Hx Script", "Đã tháo hàn các khối.", 3) 
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
