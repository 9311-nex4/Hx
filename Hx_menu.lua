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
		Nen = Color3.fromRGB(20, 20, 20),
		NenList = Color3.fromRGB(30, 30, 30),
		Nut = Color3.fromRGB(45, 45, 45),
		NutHover = Color3.fromRGB(65, 65, 65),
		NutTat = Color3.fromRGB(255, 80, 80), 
		NutTatHover = Color3.fromRGB(255, 0, 0),
		Chu = Color3.fromRGB(255, 255, 255),
		Vien = Color3.fromRGB(100, 100, 100)
	},
	KichThuoc = {
		NutH = 40,
		Gap = 6,   
		IconTo = UDim2.new(0, 90, 0, 90),
		IconNho = UDim2.new(0, 30, 0, 30),
		NutTat = 32 
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
	local ChieuCaoList = (SoLuong * (CauHinh.KichThuoc.NutH + CauHinh.KichThuoc.Gap))
	local TongCao = 70 + ChieuCaoList + 20
	local MaxCao = Camera.ViewportSize.Y * 0.7
	if TongCao > MaxCao then TongCao = MaxCao end
	
	local ChieuRong = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) and 300 or 360

	local KhungChinh = Instance.new("Frame")
	KhungChinh.Name = "KhungChinh"
	KhungChinh.Size = CauHinh.KichThuoc.IconTo 
	KhungChinh.Position = UDim2.new(0.5, 0, 0.5, 0)
	KhungChinh.AnchorPoint = Vector2.new(0.5, 0.5)
	KhungChinh.BackgroundColor3 = CauHinh.Mau.Nen
	KhungChinh.BackgroundTransparency = 1
	KhungChinh.ClipsDescendants = false
	KhungChinh.Parent = ScreenGui
	Instance.new("UICorner", KhungChinh).CornerRadius = UDim.new(0, 12)

	local Icon = Instance.new("ImageLabel")
	Icon.Size = UDim2.fromOffset(0, 0)
	Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
	Icon.AnchorPoint = Vector2.new(0.5, 0.5)
	Icon.Image = "rbxassetid://117118515787811"
	Icon.BackgroundTransparency = 1
	Icon.ZIndex = 100
	Icon.Parent = KhungChinh
	Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 12)

	local NoiDung = Instance.new("Frame")
	NoiDung.Size = UDim2.fromScale(1, 1)
	NoiDung.BackgroundTransparency = 1
	NoiDung.Parent = KhungChinh

	local TieuDe = Instance.new("TextLabel")
	TieuDe.Text = "Hx Script Hub"
	TieuDe.Size = UDim2.new(1, -90, 0, 40)
	TieuDe.Position = UDim2.new(0, 55, 0, 5)
	TieuDe.BackgroundTransparency = 1
	TieuDe.TextColor3 = CauHinh.Mau.Chu
	TieuDe.Font = Enum.Font.GothamBold
	TieuDe.TextSize = 22
	TieuDe.TextXAlignment = Enum.TextXAlignment.Left
	TieuDe.TextTransparency = 1
	TieuDe.Parent = NoiDung

	local NutTat = Instance.new("TextButton")
	NutTat.Size = UDim2.fromOffset(CauHinh.KichThuoc.NutTat, CauHinh.KichThuoc.NutTat)
	NutTat.Position = UDim2.new(1, -20, 0, 20)
	NutTat.AnchorPoint = Vector2.new(0.5, 0.5)
	NutTat.Text = "X"
	NutTat.TextSize = 16
	NutTat.Font = Enum.Font.GothamBlack
	NutTat.BackgroundColor3 = Color3.new(0,0,0)
	NutTat.TextColor3 = CauHinh.Mau.NutTat
	NutTat.BackgroundTransparency = 1
	NutTat.TextTransparency = 1
	NutTat.Parent = KhungChinh
	Instance.new("UICorner", NutTat).CornerRadius = UDim.new(0, 8)
	
	local VienNutTat = Instance.new("UIStroke", NutTat)
	VienNutTat.Color = CauHinh.Mau.NutTat
	VienNutTat.Transparency = 1
	VienNutTat.Thickness = 1.5
	VienNutTat.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local KhungList = Instance.new("ScrollingFrame")
	KhungList.Size = UDim2.new(0.9, 0, 1, -60)
	KhungList.Position = UDim2.new(0.5, 0, 1, -10)
	KhungList.AnchorPoint = Vector2.new(0.5, 1)
	KhungList.BackgroundTransparency = 0.8
	KhungList.BackgroundColor3 = CauHinh.Mau.NenList
	KhungList.ScrollBarThickness = 3
	KhungList.BorderSizePixel = 0
	KhungList.Parent = NoiDung
	Instance.new("UICorner", KhungList).CornerRadius = UDim.new(0, 8)
	
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
		IconCuoiPos = UDim2.new(0, 25, 0, 25),
		KhungDau = CauHinh.KichThuoc.IconTo,
		KhungCuoi = UDim2.new(0, ChieuRong, 0, TongCao),
		NutDongPop = UDim2.new(0, CauHinh.KichThuoc.NutTat + 10, 0, CauHinh.KichThuoc.NutTat + 10),
		KhungTrans = 0.1
	}

	LibHieuUng.MoGiaoDien(Elements, AnimConfigs)

	local function DongUI()
		if DangDong then return end
		DangDong = true
		LibHieuUng.DongGiaoDien(Elements, AnimConfigs, function()
			ScreenGui:Destroy()
		end)
	end

	for i, Data in ipairs(DanhSachScript) do
		local Nut = Instance.new("TextButton")
		Nut.Size = UDim2.new(0.94, 0, 0, CauHinh.KichThuoc.NutH)
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
			Size = UDim2.new(0.94, 0, 0, CauHinh.KichThuoc.NutH),
			BackgroundColor3 = CauHinh.Mau.Nut,
			TextSize = 16
		}
		local PropsHover = {
			Size = UDim2.new(0.98, 0, 0, CauHinh.KichThuoc.NutH),
			BackgroundColor3 = CauHinh.Mau.NutHover,
			TextSize = 17
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

	local TatPropsThuong = {
		Size = UDim2.fromOffset(CauHinh.KichThuoc.NutTat, CauHinh.KichThuoc.NutTat),
		BackgroundColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 1,
		TextColor3 = CauHinh.Mau.NutTat
	}
	local TatPropsHover = {
		Size = UDim2.fromOffset(CauHinh.KichThuoc.NutTat + 4, CauHinh.KichThuoc.NutTat + 4),
		BackgroundColor3 = CauHinh.Mau.NutTatHover,
		BackgroundTransparency = 0,
		TextColor3 = Color3.new(1,1,1)
	}

	NutTat.MouseEnter:Connect(function()
		if not DangDong then 
			LibHieuUng.Hover(NutTat, true, TatPropsHover, TatPropsThuong)
			game:GetService("TweenService"):Create(VienNutTat, TweenInfo.new(0.2), {Transparency = 0}):Play()
		end
	end)
	NutTat.MouseLeave:Connect(function()
		if not DangDong then 
			LibHieuUng.Hover(NutTat, false, TatPropsHover, TatPropsThuong)
			game:GetService("TweenService"):Create(VienNutTat, TweenInfo.new(0.2), {Transparency = 1}):Play()
		end
	end)
	
	NutTat.MouseButton1Click:Connect(function()
		if not DangDong then DongUI() end
	end)
end

TaoGiaoDien()
