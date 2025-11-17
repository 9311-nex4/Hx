local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

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

local CauHinh = {
	Mau = {
		Nen = Color3.fromRGB(18, 18, 18),
		NenList = Color3.fromRGB(35, 35, 35),
		Nut = Color3.fromRGB(60, 60, 60),
		NutHover = Color3.fromRGB(90, 90, 90),
		NutTat = Color3.fromRGB(80, 80, 80),
		NutTatHover = Color3.fromRGB(200, 0, 0),
		Chu = Color3.fromRGB(240, 240, 240),
		Vien = Color3.fromRGB(255, 255, 255)
	},
	KichThuoc = {
		NutH = 38,
		Gap = 6,
		IconTo = UDim2.new(0, 80, 0, 80),
		IconNho = UDim2.new(0, 35, 0, 35),
		NutTat = 30
	}
}

local function TaoGiaoDien()
	if PlayerGui:FindFirstChild("HxInterface") then PlayerGui.HxInterface:Destroy() end

	local DangDong = false
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "HxInterface"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = PlayerGui

	local MobileCheck = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
	local ChieuRong = MobileCheck and 380 or 340
	local TyLeChieuCao = 0.45
	
	
	local SoLuong = #DanhSachScript
	local ChieuCaoList = (SoLuong * (CauHinh.KichThuoc.NutH + CauHinh.KichThuoc.Gap))
	local TongCao = 70 + ChieuCaoList + 20
	local MaxCao = Camera.ViewportSize.Y * TyLeChieuCao
	
	if TongCao > MaxCao then TongCao = MaxCao end
	
	local KhungChinh = Instance.new("Frame")
	KhungChinh.Name = "KhungChinh"
	KhungChinh.Size = CauHinh.KichThuoc.IconTo
	KhungChinh.Position = UDim2.new(0.5, 0, 0.5, 0)
	KhungChinh.AnchorPoint = Vector2.new(0.5, 0.5)
	KhungChinh.BackgroundColor3 = CauHinh.Mau.Nen
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
	TieuDe.TextColor3 = CauHinh.Mau.Chu
	TieuDe.Font = Enum.Font.GothamBold
	TieuDe.TextSize = 20
	TieuDe.TextXAlignment = Enum.TextXAlignment.Left
	TieuDe.TextTransparency = 1
	TieuDe.Parent = NoiDung

	local NutTat = Instance.new("TextButton")
	NutTat.Size = UDim2.fromOffset(CauHinh.KichThuoc.NutTat, CauHinh.KichThuoc.NutTat)
	NutTat.Position = UDim2.new(1, -25, 0, 25)
	NutTat.AnchorPoint = Vector2.new(0.5, 0.5)
	NutTat.Text = "X"
	NutTat.TextSize = 18
	NutTat.Font = Enum.Font.GothamBlack
	NutTat.BackgroundColor3 = CauHinh.Mau.NutTat
	NutTat.TextColor3 = CauHinh.Mau.Chu
	NutTat.BackgroundTransparency = 1
	NutTat.TextTransparency = 1
	NutTat.Parent = KhungChinh
	Instance.new("UICorner", NutTat).CornerRadius = UDim.new(0, 6)
	
	local VienNutTat = Instance.new("UIStroke", NutTat)
	VienNutTat.Color = CauHinh.Mau.Vien
	VienNutTat.Transparency = 1
	VienNutTat.Thickness = 1.5
	VienNutTat.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local KhungList = Instance.new("ScrollingFrame")
	KhungList.Size = UDim2.new(0.9, 0, 1, -65)
	KhungList.Position = UDim2.new(0.5, 0, 0, 55)
	KhungList.AnchorPoint = Vector2.new(0.5, 0)
	KhungList.BackgroundTransparency = 0.8
	KhungList.BackgroundColor3 = CauHinh.Mau.NenList
	KhungList.ScrollBarThickness = 2
	KhungList.BorderSizePixel = 0
	KhungList.Parent = NoiDung
	Instance.new("UICorner", KhungList).CornerRadius = UDim.new(0, 6)
	
	local Layout = Instance.new("UIListLayout", KhungList)
	Layout.Padding = UDim.new(0, CauHinh.KichThuoc.Gap)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	
	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		KhungList.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
	end)

	local Elements = {
		ScreenGui = ScreenGui, Khung = KhungChinh, Icon = Icon,
		TieuDe = TieuDe, NutDong = NutTat, VienNutDong = VienNutTat, DanhSach = KhungList
	}
	
	local AnimConfigs = {
		IconDau = CauHinh.KichThuoc.IconTo,
		IconCuoi = CauHinh.KichThuoc.IconNho,
		IconDauPos = UDim2.new(0.5, 0, 0.5, 0),
		IconCuoiPos = UDim2.new(0, 27, 0, 27),
		KhungDau = CauHinh.KichThuoc.IconTo,
		KhungCuoi = UDim2.new(0, ChieuRong, 0, TongCao),
		NutDongPop = UDim2.new(0, 42, 0, 42),
		KhungTrans = 0.15
	}

	LibHieuUng.MoGiaoDien(Elements, AnimConfigs)
	LibHieuUng.KeoTha(KhungChinh, KhungChinh)

	local function DongUI()
		if DangDong then return end
		DangDong = true
		LibHieuUng.DongGiaoDien(Elements, AnimConfigs, function()
			ScreenGui:Destroy()
		end)
	end

	for i, Data in ipairs(DanhSachScript) do
		local Nut = Instance.new("TextButton")
		Nut.Size = UDim2.new(0.9, 0, 0, CauHinh.KichThuoc.NutH)
		Nut.Text = Data.Ten
		Nut.BackgroundColor3 = CauHinh.Mau.Nut
		Nut.TextColor3 = CauHinh.Mau.Chu
		Nut.Font = Enum.Font.GothamMedium
		Nut.TextSize = 16
		Nut.BackgroundTransparency = 1
		Nut.TextTransparency = 1
		Nut.LayoutOrder = i
		Nut.Parent = KhungList
		Instance.new("UICorner", Nut).CornerRadius = UDim.new(0, 6)

		local PropsThuong = {
			Size = UDim2.new(0.9, 0, 0, CauHinh.KichThuoc.NutH),
			BackgroundColor3 = CauHinh.Mau.Nut,
			TextSize = 16
		}
		local PropsHover = {
			Size = UDim2.new(0.98, 0, 0, CauHinh.KichThuoc.NutH + 4),
			BackgroundColor3 = CauHinh.Mau.NutHover,
			TextSize = 18
		}

		Nut.MouseEnter:Connect(function() LibHieuUng.Hover(Nut, true, PropsHover, PropsThuong) end)
		Nut.MouseLeave:Connect(function() LibHieuUng.Hover(Nut, false, PropsHover, PropsThuong) end)
		
		Nut.MouseButton1Click:Connect(function()
			LibHieuUng.Click(Nut)
			if _G.DaKichHoat[Data.Ten] then
				ThongBao("Hx Script", "Đã bật chức năng này rồi!", 2)
				return
			end

			if Data.Link ~= "" then
				_G.DaKichHoat[Data.Ten] = true
				ThongBao("Thành công", "Đang tải: " .. Data.Ten, 2)

				task.spawn(function()
					local ok, err = pcall(function() loadstring(game:HttpGet(Data.Link))() end)
					if not ok then warn(err) ThongBao("Lỗi", "Link hỏng!", 3) end
				end)
			else
				ThongBao("Thông báo", "Chưa có script", 2)
			end
		end)
	end

	local TatPropsThuong = {
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = CauHinh.Mau.NutTat,
		BackgroundTransparency = 0.6,
		TextSize = 18,
		TextColor3 = CauHinh.Mau.Chu
	}
	local TatPropsHover = {
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = CauHinh.Mau.NutTatHover,
		BackgroundTransparency = 0, 
		TextSize = 22,
		TextColor3 = Color3.new(1,1,1)
	}

	NutTat.MouseEnter:Connect(function()
		if not DangDong then 
			LibHieuUng.Hover(NutTat, true, TatPropsHover, TatPropsThuong)
			game:GetService("TweenService"):Create(VienNutTat, TweenInfo.new(0.3), {Transparency = 0.4}):Play()
		end
	end)
	NutTat.MouseLeave:Connect(function()
		if not DangDong then 
			LibHieuUng.Hover(NutTat, false, TatPropsHover, TatPropsThuong)
			game:GetService("TweenService"):Create(VienNutTat, TweenInfo.new(0.3), {Transparency = 0.8}):Play()
		end
	end)
	
	NutTat.MouseButton1Click:Connect(function()
		if not DangDong then DongUI() end
	end)
end

TaoGiaoDien()
