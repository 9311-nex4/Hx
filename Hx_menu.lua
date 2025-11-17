local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Plr = Players.LocalPlayer
local PlayerGui = Plr:WaitForChild("PlayerGui")

local LibAnim = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Animation.lua"))()
local Notify = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Notify.lua"))()

_G.HxScript_DaKichHoat = _G.HxScript_DaKichHoat or {}

local DataButtons = {
	{ Ten = "Transform", Link = "https://raw.githubusercontent.com/9311-nex4/Hx/main/Transform.lua" },
	{ Ten = "Example 2", Link = "" },
	{ Ten = "Example 3", Link = "" },
}

local Config = {
	Colors = {
		Bg = Color3.fromRGB(15, 15, 15),
		BgContent = Color3.fromRGB(40, 40, 40),
		BtnNormal = Color3.fromRGB(90, 90, 90),
		BtnHover = Color3.fromRGB(125, 125, 125),
		CloseNormal = Color3.fromRGB(90, 90, 90),
		CloseHover = Color3.fromRGB(180, 50, 50),
		Text = Color3.fromRGB(255, 255, 255),
		Border = Color3.fromRGB(255, 255, 255)
	},
	Sizes = {
		IconStart = UDim2.new(0, 80, 0, 80),
		IconEnd = UDim2.new(0, 35, 0, 35),
		IconEndPos = UDim2.new(0, 27.5, 0, 27.5),
		IconStartPos = UDim2.new(0.5, 0, 0.5, 0),
		FrameStart = UDim2.new(0, 80, 0, 80),
		FrameEndMob = UDim2.new(0.45, 0, 0.7425, 0),
		FrameEndPC = UDim2.new(0, 360, 0, 238),
		CloseBtn = UDim2.new(0, 30, 0, 30),
		CloseBtnHover = UDim2.new(0, 35, 0, 35),
		CloseBtnPress = UDim2.new(0, 28, 0, 28),
		CloseBtnPop = UDim2.new(0, 48, 0, 48)
	}
}

local function CreateUI()
	if PlayerGui:FindFirstChild("HxInterface") then PlayerGui.HxInterface:Destroy() end

	local IsClosing = false
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "HxInterface"
	ScreenGui.Parent = PlayerGui
	ScreenGui.ResetOnSpawn = false

	local FinalSize = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) 
		and Config.Sizes.FrameEndMob or Config.Sizes.FrameEndPC

	local MainFrame = Instance.new("Frame")
	MainFrame.Size = Config.Sizes.FrameStart
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.BackgroundColor3 = Config.Colors.Bg
	MainFrame.BackgroundTransparency = 1
	MainFrame.ClipsDescendants = false
	MainFrame.Parent = ScreenGui
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

	local Icon = Instance.new("ImageLabel")
	Icon.Size = UDim2.new(0, 0, 0, 0)
	Icon.Position = Config.Sizes.IconStartPos
	Icon.AnchorPoint = Vector2.new(0.5, 0.5)
	Icon.Image = "rbxassetid://117118515787811"
	Icon.BackgroundTransparency = 0.6
	Icon.BackgroundColor3 = Color3.new(0, 0, 0)
	Icon.ZIndex = 100
	Icon.Parent = MainFrame
	Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 12)

	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 1, 0)
	Container.BackgroundTransparency = 1
	Container.Parent = MainFrame

	local Title = Instance.new("TextLabel")
	Title.Text = "Hx Script"
	Title.Size = UDim2.new(1, -80, 0, 40)
	Title.Position = UDim2.new(0, 50, 0, 5)
	Title.BackgroundTransparency = 1
	Title.TextColor3 = Config.Colors.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 22
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextTransparency = 1
	Title.Parent = Container

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = Config.Sizes.CloseBtn
	CloseBtn.Position = UDim2.new(1, -25, 0, 25)
	CloseBtn.AnchorPoint = Vector2.new(0.5, 0.5)
	CloseBtn.Text = "X"
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.BackgroundColor3 = Config.Colors.CloseNormal
	CloseBtn.TextColor3 = Config.Colors.Text
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.TextTransparency = 1
	CloseBtn.ZIndex = 2
	CloseBtn.Parent = MainFrame
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
	
	local ClosePad = Instance.new("UIPadding", CloseBtn)
	local CloseStroke = Instance.new("UIStroke", CloseBtn)
	CloseStroke.Color = Config.Colors.Border
	CloseStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	CloseStroke.Transparency = 1
	CloseStroke.Thickness = 1.5

	local ListFrame = Instance.new("ScrollingFrame")
	ListFrame.Size = UDim2.new(1, -20, 1, -70)
	ListFrame.Position = UDim2.new(0, 10, 0, 50)
	ListFrame.BackgroundTransparency = 1
	ListFrame.BackgroundColor3 = Config.Colors.BgContent
	ListFrame.ScrollBarImageTransparency = 1
	ListFrame.BorderSizePixel = 0
	ListFrame.Parent = Container
	Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 8)
	
	local Layout = Instance.new("UIListLayout", ListFrame)
	Layout.Padding = UDim.new(0, 8)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	
	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ListFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
	end)

	local UIObjects = {
		ScreenGui = ScreenGui, Khung = MainFrame, Icon = Icon,
		TieuDe = Title, NutDong = CloseBtn, VienNutDong = CloseStroke, DanhSach = ListFrame
	}
	
	local AnimConfig = {
		IconDau = Config.Sizes.IconStart,
		IconCuoi = Config.Sizes.IconEnd,
		IconDauPos = Config.Sizes.IconStartPos,
		IconCuoiPos = Config.Sizes.IconEndPos,
		KhungDau = Config.Sizes.FrameStart,
		KhungCuoi = FinalSize,
		NutDongPop = Config.Sizes.CloseBtnPop
	}

	LibAnim.MoGiaoDien(UIObjects, AnimConfig)
	
	local function CloseAndDestroy()
		IsClosing = true
		LibAnim.DongGiaoDien(UIObjects, AnimConfig, function()
			ScreenGui:Destroy()
		end)
	end

	for i, data in ipairs(DataButtons) do
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, 0, 0, 45)
		Btn.Text = data.Ten
		Btn.BackgroundColor3 = Config.Colors.BtnNormal
		Btn.TextColor3 = Config.Colors.Text
		Btn.Font = Enum.Font.GothamBold
		Btn.TextSize = 18
		Btn.BackgroundTransparency = 1
		Btn.TextTransparency = 1
		Btn.LayoutOrder = i
		Btn.Parent = ListFrame
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

		local BtnAnimCfg = {
			KichThuocThuong = UDim2.new(1, 0, 0, 45),
			KichThuocLuot = UDim2.new(1, 0, 0, 56),
			MauThuong = Config.Colors.BtnNormal,
			MauLuot = Config.Colors.BtnHover
		}

		Btn.MouseEnter:Connect(function() LibAnim.HieuUngLuotNut(Btn, true, BtnAnimCfg) end)
		Btn.MouseLeave:Connect(function() LibAnim.HieuUngLuotNut(Btn, false, BtnAnimCfg) end)
		
		Btn.MouseButton1Click:Connect(function()
			if _G.HxScript_DaKichHoat[data.Ten] then
				Notify("Hệ Thống", "Đã được kích hoạt rồi!", 3)
				return
			end

			if data.Link ~= "" then
				_G.HxScript_DaKichHoat[data.Ten] = true
				Notify("Hệ Thống", "Đã kích hoạt: " .. data.Ten, 3)

				task.spawn(function()
					local s, e = pcall(function() loadstring(game:HttpGet(data.Link))() end)
					if not s then 
						Notify("Lỗi", "Không thể tải script!", 3)
						warn(e) 
					end
				end)
			else
				Notify("Thông Báo", "Chức năng này chưa có Link!", 2)
			end
		end)
	end

	local CloseBtnObjs = { NutDong = CloseBtn, Dem = ClosePad, Vien = CloseStroke }
	local CloseBtnColors = { Thuong = Config.Colors.CloseNormal, Luot = Config.Colors.CloseHover }
	local CloseBtnSizes = { Thuong = Config.Sizes.CloseBtn, Luot = Config.Sizes.CloseBtnHover }

	CloseBtn.MouseEnter:Connect(function()
		if not IsClosing then LibAnim.HieuUngLuotNutDong(CloseBtnObjs, true, CloseBtnColors, CloseBtnSizes) end
	end)
	CloseBtn.MouseLeave:Connect(function()
		if not IsClosing then LibAnim.HieuUngLuotNutDong(CloseBtnObjs, false, CloseBtnColors, CloseBtnSizes) end
	end)
	CloseBtn.MouseButton1Down:Connect(function()
		if not IsClosing then LibAnim.HieuUngNhanNut(CloseBtn, Config.Sizes.CloseBtnPress) end
	end)
	CloseBtn.MouseButton1Up:Connect(function()
		if not IsClosing then CloseAndDestroy() end
	end)
end

CreateUI()
