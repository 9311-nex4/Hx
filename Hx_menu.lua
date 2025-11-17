local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// 1. LOAD THƯ VIỆN HIỆU ỨNG TỪ GITHUB //--
-- Thay link dưới bằng link raw github file Animation.lua của bạn
local LINK_LIB = "https://raw.githubusercontent.com/9311-nex4/Hx/main/Animation.lua" 
local HieuUngLib = loadstring(game:HttpGet(LINK_LIB))()

local DATA_NUT = {
	{ Ten = "Transform", Link = "https://raw.githubusercontent.com/9311-nex4/Hx/main/Transform.lua" },
	{ Ten = "Example 2", Link = "" },
}

local ID_ICON = "rbxassetid://117118515787811"

-- Cấu hình màu sắc/kích thước (Vẫn giữ ở Client để dễ chỉnh giao diện)
local CONFIG = {
	MauSac = {
		Nen = Color3.fromRGB(15, 15, 15),
		NenNoiDung = Color3.fromRGB(40, 40, 40),
		NutThuong = Color3.fromRGB(90, 90, 90),
		NutHover = Color3.fromRGB(125, 125, 125),
		DongThuong = Color3.fromRGB(90, 90, 90),
		DongHover = Color3.fromRGB(180, 50, 50),
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
		NutDongHover = UDim2.new(0, 35, 0, 35),
		NutDongNhan = UDim2.new(0, 28, 0, 28),
		NutDongPop = UDim2.new(0, 48, 0, 48)
	}
}

local function TaoGiaoDien()
	if PlayerGui:FindFirstChild("GiaoDienChinh") then PlayerGui.GiaoDienChinh:Destroy() end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "GiaoDienChinh"
	ScreenGui.Parent = PlayerGui
	ScreenGui.ResetOnSpawn = false

	-- Xác định kích thước cuối dựa trên thiết bị
	local KichThuocCuoi = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) 
		and CONFIG.KichThuoc.KhungCuoiMobile or CONFIG.KichThuoc.KhungCuoiPC

	-- == TẠO GUI OBJECTS == --
	local KhungChinh = Instance.new("Frame", ScreenGui)
	KhungChinh.Size = CONFIG.KichThuoc.KhungDau
	KhungChinh.Position = UDim2.new(0.5,0,0.5,0)
	KhungChinh.AnchorPoint = Vector2.new(0.5,0.5)
	KhungChinh.BackgroundColor3 = CONFIG.MauSac.Nen
	KhungChinh.BackgroundTransparency = 1
	KhungChinh.ClipsDescendants = false

	Instance.new("UICorner", KhungChinh).CornerRadius = UDim.new(0, 12)

	local IconDaiDien = Instance.new("ImageLabel", KhungChinh)
	IconDaiDien.Size = UDim2.new(0,0,0,0)
	IconDaiDien.Position = CONFIG.KichThuoc.IconDauPos
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
	TieuDe.TextColor3 = CONFIG.MauSac.Chu
	TieuDe.Font = Enum.Font.GothamBold
	TieuDe.TextSize = 22
	TieuDe.TextXAlignment = Enum.TextXAlignment.Left
	TieuDe.TextTransparency = 1

	local NutDong = Instance.new("TextButton", KhungChinh)
	NutDong.Size = CONFIG.KichThuoc.NutDong
	NutDong.Position = UDim2.new(1,-25,0,25)
	NutDong.AnchorPoint = Vector2.new(0.5,0.5)
	NutDong.Text = "X"
	NutDong.Font = Enum.Font.GothamBold
	NutDong.BackgroundColor3 = CONFIG.MauSac.DongThuong
	NutDong.TextColor3 = CONFIG.MauSac.Chu
	NutDong.BackgroundTransparency = 1
	NutDong.TextTransparency = 1
	NutDong.ZIndex = 2
	Instance.new("UICorner", NutDong).CornerRadius = UDim.new(0, 8)
	local PadNutDong = Instance.new("UIPadding", NutDong)
	local VienNutDong = Instance.new("UIStroke", NutDong)
	VienNutDong.Color = CONFIG.MauSac.Vien
	VienNutDong.Transparency = 1
	VienNutDong.Thickness = 1.5

	local DanhSach = Instance.new("ScrollingFrame", Container)
	DanhSach.Size = UDim2.new(1,-20,1,-70)
	DanhSach.Position = UDim2.new(0,10,0,50)
	DanhSach.BackgroundTransparency = 1
	DanhSach.BackgroundColor3 = CONFIG.MauSac.NenNoiDung
	DanhSach.ScrollBarImageTransparency = 1
	DanhSach.BorderSizePixel = 0
	Instance.new("UICorner", DanhSach).CornerRadius = UDim.new(0, 8)
	local Layout = Instance.new("UIListLayout", DanhSach)
	Layout.Padding = UDim.new(0,8)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	
	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		DanhSach.CanvasSize = UDim2.new(0,0,0, Layout.AbsoluteContentSize.Y + 20)
	end)

	-- == GÓI OBJECTS VÀ CONFIG ĐỂ GỬI QUA THƯ VIỆN == --
	local GuiObjects = {
		ScreenGui = ScreenGui, Khung = KhungChinh, Icon = IconDaiDien,
		TieuDe = TieuDe, NutDong = NutDong, VienNutDong = VienNutDong, DanhSach = DanhSach
	}
	
	local AnimConfigs = {
		IconDau = CONFIG.KichThuoc.IconDau,
		IconCuoi = CONFIG.KichThuoc.IconCuoi,
		IconDauPos = CONFIG.KichThuoc.IconDauPos,
		IconCuoiPos = CONFIG.KichThuoc.IconCuoiPos,
		KhungDau = CONFIG.KichThuoc.KhungDau,
		KhungCuoi = KichThuocCuoi,
		NutDongPop = CONFIG.KichThuoc.NutDongPop
	}

	-- == GỌI HIỆU ỨNG TỪ THƯ VIỆN == --
	HieuUngLib.MoGiaoDien(GuiObjects, AnimConfigs)

	-- Tạo list nút
	for i, data in ipairs(DATA_NUT) do
		local Nut = Instance.new("TextButton", DanhSach)
		Nut.Size = UDim2.new(1,0,0,45)
		Nut.Text = data.Ten
		Nut.BackgroundColor3 = CONFIG.MauSac.NutThuong
		Nut.TextColor3 = CONFIG.MauSac.Chu
		Nut.Font = Enum.Font.GothamBold
		Nut.TextSize = 18
		Nut.BackgroundTransparency = 1
		Nut.TextTransparency = 1
		Nut.LayoutOrder = i
		Instance.new("UICorner", Nut).CornerRadius = UDim.new(0, 8)

		-- Gọi hiệu ứng Hover từ Lib
		Nut.MouseEnter:Connect(function()
			HieuUngLib.HoverNut(Nut, true, CONFIG.MauSac.NutThuong, CONFIG.MauSac.NutHover)
		end)
		Nut.MouseLeave:Connect(function()
			HieuUngLib.HoverNut(Nut, false, CONFIG.MauSac.NutThuong, CONFIG.MauSac.NutHover)
		end)
		Nut.MouseButton1Click:Connect(function()
			if data.Link ~= "" then
				pcall(function() loadstring(game:HttpGet(data.Link))() end)
			end
		end)
	end

	-- Xử lý nút đóng
	local NutDongData = { NutDong = NutDong, Padding = PadNutDong, Vien = VienNutDong }
	local ColorData = { Normal = CONFIG.MauSac.DongThuong, Hover = CONFIG.MauSac.DongHover }
	local SizeData = { Normal = CONFIG.KichThuoc.NutDong, Hover = CONFIG.KichThuoc.NutDongHover }

	NutDong.MouseEnter:Connect(function()
		HieuUngLib.HoverNutDong(NutDongData, true, ColorData, SizeData)
	end)
	NutDong.MouseLeave:Connect(function()
		HieuUngLib.HoverNutDong(NutDongData, false, ColorData, SizeData)
	end)
	NutDong.MouseButton1Down:Connect(function()
		HieuUngLib.NhanNut(NutDong, CONFIG.KichThuoc.NutDongNhan)
	end)
	NutDong.MouseButton1Up:Connect(function()
		HieuUngLib.DongGiaoDien(GuiObjects, AnimConfigs, function()
			ScreenGui:Destroy() -- Hủy GUI sau khi hiệu ứng xong
		end)
	end)
end

TaoGiaoDien()
