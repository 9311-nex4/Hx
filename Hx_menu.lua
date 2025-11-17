local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local NguoiChoi = Players.LocalPlayer
local PlayerGui = NguoiChoi:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local LibHieuUng = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Animation.lua"))()
local ThongBao = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Notify.lua"))()

_G.DaKichHoat = _G.DaKichHoat or {}

local DanhSachScript = {
	{ Ten = "Transform", Link = "https://raw.githubusercontent.com/9311-nex4/Hx/main/Transform.lua" },
	{ Ten = "Example 2", Link = "" },
	{ Ten = "Example 3", Link = "" },
	{ Ten = "Example 4", Link = "" },
	{ Ten = "Example 5", Link = "" },
}

local CaiDat = {
	Mau = {
		Nen = Color3.fromRGB(18, 18, 18),
		NenList = Color3.fromRGB(35, 35, 35),
		Nut = Color3.fromRGB(60, 60, 60),
		NutHover = Color3.fromRGB(90, 90, 90),
		NutTat = Color3.fromRGB(80, 80, 80),
		NutTatHover = Color3.fromRGB(200, 60, 60),
		Chu = Color3.fromRGB(240, 240, 240),
		Vien = Color3.fromRGB(255, 255, 255)
	},
	KichThuoc = {
		NutCao = 38,
		KhoangCach = 6,
		Icon = UDim2.new(0, 80, 0, 80),
		IconNho = UDim2.new(0, 35, 0, 35)
	}
}

local function TaoGiaoDien()
	if PlayerGui:FindFirstChild("HxInterface") then PlayerGui.HxInterface:Destroy() end

	local DangDong = false
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "HxInterface"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = PlayerGui

	local SoLuong = #DanhSachScript
	local ChieuCaoList = (SoLuong * (CaiDat.KichThuoc.NutCao + CaiDat.KichThuoc.KhoangCach))
	local TongCao = 70 + ChieuCaoList + 20
	local MaxCao = Camera.ViewportSize.Y * 0.65
	
	if TongCao > MaxCao then TongCao = MaxCao end
	
	local ChieuRong = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) and 300 or 340

	local KhungChinh = Instance.new("Frame")
	KhungChinh.Name = "KhungChinh"
	KhungChinh.Size = CaiDat.KichThuoc.Icon
	KhungChinh.Position = UDim2.new(0.5, 0, 0.5, 0)
	KhungChinh.AnchorPoint = Vector2.new(0.5, 0.5)
	KhungChinh.BackgroundColor3 = CaiDat.Mau.Nen
	KhungChinh.BackgroundTransparency = 1
	KhungChinh.ClipsDescendants = false
	KhungChinh.Parent = ScreenGui
	Instance.new("UICorner", KhungChinh).CornerRadius = UDim.new(0, 10)

	local Icon = Instance.new("ImageLabel")
	Icon.Size = UDim2.fromOffset(0, 0)
	Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
	Icon.AnchorPoint = Vector2.new(0.5, 0.5)
	Icon.Image = "rbxassetid://117118515787811"
	Icon.BackgroundTransparency = 0.6
	Icon.BackgroundColor3 = Color3.new(0, 0, 0)
	Icon.ZIndex = 100
	Icon.Parent = KhungChinh
	Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 12)

	local NoiDung = Instance.new("Frame")
	NoiDung.Size = UDim2.fromScale(1, 1)
	NoiDung.BackgroundTransparency = 1
	NoiDung.Parent = KhungChinh

	local TieuDe = Instance.new("TextLabel")
	TieuDe.Text = "Hx Script"
	TieuDe.Size = UDim2.new(1, -80, 0, 40)
	TieuDe.Position = UDim2.new(0, 50, 0, 5)
	TieuDe.BackgroundTransparency = 1
	TieuDe.TextColor3 = CaiDat.Mau.Chu
	TieuDe.Font = Enum.Font.GothamBold
	TieuDe.TextSize = 20
	TieuDe.TextXAlignment = Enum.TextXAlignment.Left
	TieuDe.TextTransparency = 1
	TieuDe.Parent = NoiDung

	local NutTat = Instance.new("TextButton")
	NutTat.Size = UDim2.fromOffset(30, 30)
	NutTat.Position = UDim2.new(1, -25, 0, 25)
	NutTat.AnchorPoint = Vector2.new(0.5, 0.5)
	NutTat.Text = "X"
	Nut.TextSize = 18
	NutTat.Font = Enum.Font.GothamBlack
	NutTat.BackgroundColor3 = CaiDat.Mau.NutTat
	NutTat.TextColor3 = CaiDat.Mau.Chu
	NutTat.BackgroundTransparency = 1
	NutTat.TextTransparency = 1
	NutTat.Parent = KhungChinh
	Instance.new("UICorner", NutTat).CornerRadius = UDim.new(0, 6)
	
	local VienNutTat = Instance.new("UIStroke", NutTat)
	VienNutTat.Color = CaiDat.Mau.Vien
	VienNutTat.Transparency = 1
	VienNutTat.Thickness = 1.5
	VienNutTat.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local KhungList = Instance.new("ScrollingFrame")
	KhungList.Size = UDim2.new(0.9, 0, 1, -65)
	KhungList.Position = UDim2.new(0.5, 0, 0, 55)
	KhungList.AnchorPoint = Vector2.new(0.5, 0)
	KhungList.BackgroundTransparency = 0.8
	KhungList.BackgroundColor3 = CaiDat.Mau.NenList
	KhungList.ScrollBarThickness = 2
	KhungList.BorderSizePixel = 0
	KhungList.Parent = NoiDung
	Instance.new("UICorner", KhungList).CornerRadius = UDim.new(0, 6)
	
	local Layout = Instance.new("UIListLayout", KhungList)
	Layout.Padding = UDim.new(0, CaiDat.KichThuoc.KhoangCach)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	
	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		KhungList.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
	end)

	local DoiTuongUI = {
		ScreenGui = ScreenGui, Khung = KhungChinh, Icon = Icon,
		TieuDe = TieuDe, NutDong = NutTat, VienNutDong = VienNutTat, DanhSach = KhungList
	}
	
	local CauHinhAnim = {
		IconDau = CaiDat.KichThuoc.Icon,
		IconCuoi = CaiDat.KichThuoc.IconNho,
		IconDauPos = UDim2.new(0.5, 0, 0.5, 0),
		IconCuoiPos = UDim2.new(0, 27, 0, 27),
		KhungDau = CaiDat.KichThuoc.Icon,
		KhungCuoi = UDim2.new(0, ChieuRong, 0, TongCao),
		NutDongPop = UDim2.new(0, 42, 0, 42)
	}

	LibHieuUng.MoGiaoDien(DoiTuongUI, CauHinhAnim)

	local function DongUI()
		DangDong = true
		LibHieuUng.DongGiaoDien(DoiTuongUI, CauHinhAnim, function()
			ScreenGui:Destroy()
		end)
	end

	for i, Data in ipairs(DanhSachScript) do
		local Nut = Instance.new("TextButton")
		Nut.Size = UDim2.new(0.9, 0, 0, CaiDat.KichThuoc.NutCao)
		Nut.Text = Data.Ten
		Nut.BackgroundColor3 = CaiDat.Mau.Nut
		Nut.TextColor3 = CaiDat.Mau.Chu
		Nut.Font = Enum.Font.GothamMedium
		Nut.TextSize = 16
		Nut.BackgroundTransparency = 1
		Nut.TextTransparency = 1
		Nut.LayoutOrder = i
		Nut.Parent = KhungList
		Instance.new("UICorner", Nut).CornerRadius = UDim.new(0, 6)

		local AnimNut = {
			KichThuocThuong = UDim2.new(0.95, 0, 0, CaiDat.KichThuoc.NutCao),
			KichThuocLuot = UDim2.new(0.98, 0, 0, CaiDat.KichThuoc.NutCao + 4),
			MauThuong = CaiDat.Mau.Nut,
			MauLuot = CaiDat.Mau.NutHover
		}

		Nut.MouseEnter:Connect(function() LibHieuUng.HieuUngLuotNut(Nut, true, AnimNut) end)
		Nut.MouseLeave:Connect(function() LibHieuUng.HieuUngLuotNut(Nut, false, AnimNut) end)
		
		Nut.MouseButton1Click:Connect(function()
			if _G.DaKichHoat[Data.Ten] then
				ThongBao("Hx Script", "Đã bật chức năng này rồi!", 2)
				return
			end

			if Data.Link ~= "" then
				_G.DaKichHoat[Data.Ten] = true
				ThongBao("Thành công", "Đang tải: " .. Data.Ten, 2)

				task.spawn(function()
					local ok, err = pcall(function() loadstring(game:HttpGet(Data.Link))() end)
					if not ok then 
						warn(err)
						ThongBao("Lỗi", "Link script bị hỏng!", 3)
					end
				end)
			else
				ThongBao("Thông báo", "Chưa có script cho nút này", 2)
			end
		end)
	end

	local DataNutTat = { NutDong = NutTat, Dem = nil, Vien = VienNutTat }
	local MauNutTat = { Thuong = CaiDat.Mau.NutTat, Luot = CaiDat.Mau.NutTatHover }
	local SizeNutTat = { Thuong = UDim2.fromOffset(30,30), Luot = UDim2.fromOffset(34,34) }

	NutTat.MouseEnter:Connect(function()
		if not DangDong then LibHieuUng.HieuUngLuotNutDong(DataNutTat, true, MauNutTat, SizeNutTat) end
	end)
	NutTat.MouseLeave:Connect(function()
		if not DangDong then LibHieuUng.HieuUngLuotNutDong(DataNutTat, false, MauNutTat, SizeNutTat) end
	end)
	NutTat.MouseButton1Click:Connect(function()
		if not DangDong then DongUI() end
	end)
end

TaoGiaoDien()
