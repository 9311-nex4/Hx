local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local DATA_NUT = {
	{ Ten = "Transform", Link = "https://raw.githubusercontent.com/9311-nex4/Hx/main/Transform.lua" },
	{ Ten = "2", Link = "" },
	{ Ten = "3", Link = "" },
	{ Ten = "4", Link = "" },
	{ Ten = "5", Link = "" }
}

local ID_ICON = "rbxassetid://117118515787811"

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
	},
	HieuUng = {
		Mo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		Dong = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
		FadeNhanh = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		FadeCham = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		NutHover = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		NutDongHover = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		NutDongPop = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	}
}

local function TaoGiaoDien()
	if PlayerGui:FindFirstChild("GiaoDienChinh") then
		PlayerGui.GiaoDienChinh:Destroy()
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "GiaoDienChinh"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = PlayerGui

	local KichThuocCuoi
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		KichThuocCuoi = CONFIG.KichThuoc.KhungCuoiMobile
	else
		KichThuocCuoi = CONFIG.KichThuoc.KhungCuoiPC
	end

	local KhungChinh = Instance.new("Frame")
	KhungChinh.Size = CONFIG.KichThuoc.KhungDau
	KhungChinh.Position = UDim2.new(0.5, 0, 0.5, 0)
	KhungChinh.AnchorPoint = Vector2.new(0.5, 0.5)
	KhungChinh.BackgroundColor3 = CONFIG.MauSac.Nen
	KhungChinh.BackgroundTransparency = 1
	KhungChinh.Active = true
	KhungChinh.Draggable = true
	KhungChinh.ClipsDescendants = false
	KhungChinh.Parent = ScreenGui

	local BoGocKhung = Instance.new("UICorner")
	BoGocKhung.CornerRadius = UDim.new(0, 12)
	BoGocKhung.Parent = KhungChinh

	local IconDaiDien = Instance.new("ImageLabel")
	IconDaiDien.Name = "Icon"
	IconDaiDien.Size = UDim2.new(0, 0, 0, 0)
	IconDaiDien.Position = CONFIG.KichThuoc.IconDauPos
	IconDaiDien.AnchorPoint = Vector2.new(0.5, 0.5)
	IconDaiDien.BackgroundColor3 = Color3.new(0, 0, 0)
	IconDaiDien.BackgroundTransparency = 0.6
	IconDaiDien.Image = ID_ICON
	IconDaiDien.ZIndex = 100
	IconDaiDien.Parent = KhungChinh

	local BoGocIcon = Instance.new("UICorner")
	BoGocIcon.CornerRadius = UDim.new(0, 12)
	BoGocIcon.Parent = IconDaiDien

	local ContainerNoiDung = Instance.new("Frame")
	ContainerNoiDung.Name = "NoiDung"
	ContainerNoiDung.Size = UDim2.new(1, 0, 1, 0)
	ContainerNoiDung.BackgroundTransparency = 1
	ContainerNoiDung.ZIndex = 1
	ContainerNoiDung.Parent = KhungChinh

	local TieuDe = Instance.new("TextLabel")
	TieuDe.Text = "Hx Script"
	TieuDe.Size = UDim2.new(1, -80, 0, 40)
	TieuDe.Position = UDim2.new(0, 50, 0, 5)
	TieuDe.BackgroundTransparency = 1
	TieuDe.TextColor3 = CONFIG.MauSac.Chu
	TieuDe.Font = Enum.Font.GothamBold
	TieuDe.TextSize = 22
	TieuDe.TextXAlignment = Enum.TextXAlignment.Left
	TieuDe.TextTransparency = 1
	TieuDe.Parent = ContainerNoiDung

	local NutDong = Instance.new("TextButton")
	NutDong.Size = CONFIG.KichThuoc.NutDong
	NutDong.AnchorPoint = Vector2.new(0.5, 0.5)
	NutDong.Position = UDim2.new(1, -25, 0, 25)
	NutDong.Text = "X"
	NutDong.BackgroundColor3 = CONFIG.MauSac.DongThuong
	NutDong.BackgroundTransparency = 1
	NutDong.TextColor3 = CONFIG.MauSac.Chu
	NutDong.TextTransparency = 1
	NutDong.Font = Enum.Font.GothamBold
	NutDong.TextSize = 18
	NutDong.AutoButtonColor = false
	NutDong.ZIndex = 2
	NutDong.Parent = KhungChinh

	local BoGocNutDong = Instance.new("UICorner")
	BoGocNutDong.CornerRadius = UDim.new(0, 8)
	BoGocNutDong.Parent = NutDong

	local VienNutDong = Instance.new("UIStroke")
	VienNutDong.Color = CONFIG.MauSac.Vien
	VienNutDong.Thickness = 1.5
	VienNutDong.Transparency = 1
	VienNutDong.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	VienNutDong.Parent = NutDong

	local PadNutDong = Instance.new("UIPadding")
	PadNutDong.Parent = NutDong

	local DanhSachCuon = Instance.new("ScrollingFrame")
	DanhSachCuon.Size = UDim2.new(1, -20, 1, -70)
	DanhSachCuon.Position = UDim2.new(0, 10, 0, 50)
	DanhSachCuon.CanvasSize = UDim2.new(0, 0, 0, 0)
	DanhSachCuon.ScrollBarThickness = 4
	DanhSachCuon.BackgroundTransparency = 1
	DanhSachCuon.ScrollBarImageTransparency = 1
	DanhSachCuon.BorderSizePixel = 0
	DanhSachCuon.BackgroundColor3 = CONFIG.MauSac.NenNoiDung
	DanhSachCuon.Parent = ContainerNoiDung

	local BoGocCuon = Instance.new("UICorner")
	BoGocCuon.CornerRadius = UDim.new(0, 8)
	BoGocCuon.Parent = DanhSachCuon

	local PadCuon = Instance.new("UIPadding")
	PadCuon.PaddingLeft = UDim.new(0, 10)
	PadCuon.PaddingRight = UDim.new(0, 10)
	PadCuon.PaddingTop = UDim.new(0, 10)
	PadCuon.PaddingBottom = UDim.new(0, 10)
	PadCuon.Parent = DanhSachCuon

	local LayoutDanhSach = Instance.new("UIListLayout")
	LayoutDanhSach.SortOrder = Enum.SortOrder.LayoutOrder
	LayoutDanhSach.Padding = UDim.new(0, 8)
	LayoutDanhSach.Parent = DanhSachCuon

	LayoutDanhSach:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		DanhSachCuon.CanvasSize = UDim2.new(0, 0, 0, LayoutDanhSach.AbsoluteContentSize.Y + 20)
	end)

	TweenService:Create(KhungChinh, CONFIG.HieuUng.FadeCham, {BackgroundTransparency = 1}):Play()
	TweenService:Create(IconDaiDien, CONFIG.HieuUng.Mo, {Size = CONFIG.KichThuoc.IconDau, ImageTransparency = 0}):Play()

	task.wait(0.5)

	TweenService:Create(KhungChinh, CONFIG.HieuUng.Mo, {Size = KichThuocCuoi, BackgroundTransparency = 0.15}):Play()

	local IconTween = TweenService:Create(IconDaiDien, CONFIG.HieuUng.Mo, {
		Size = CONFIG.KichThuoc.IconCuoi,
		Position = CONFIG.KichThuoc.IconCuoiPos,
		AnchorPoint = Vector2.new(0.5, 0.5)
	})
	IconTween:Play()

	IconTween.Completed:Connect(function()
		TweenService:Create(TieuDe, CONFIG.HieuUng.FadeCham, {TextTransparency = 0}):Play()
		TweenService:Create(NutDong, CONFIG.HieuUng.FadeCham, {BackgroundTransparency = 0.6, TextTransparency = 0}):Play()
		TweenService:Create(VienNutDong, CONFIG.HieuUng.FadeCham, {Transparency = 0.8}):Play()
		TweenService:Create(DanhSachCuon, CONFIG.HieuUng.FadeCham, {BackgroundTransparency = 0.6, ScrollBarImageTransparency = 0}):Play()

		for _, obj in ipairs(DanhSachCuon:GetChildren()) do
			if obj:IsA("TextButton") then
				TweenService:Create(obj, CONFIG.HieuUng.FadeCham, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
			end
		end
	end)

	for i, data in ipairs(DATA_NUT) do
		local NutItem = Instance.new("TextButton")
		NutItem.Size = UDim2.new(1, 0, 0, 45)
		NutItem.LayoutOrder = i
		NutItem.Text = data.Ten
		NutItem.BackgroundColor3 = CONFIG.MauSac.NutThuong
		NutItem.TextColor3 = CONFIG.MauSac.Chu
		NutItem.Font = Enum.Font.GothamBold
		NutItem.TextSize = 18
		NutItem.AutoButtonColor = false
		NutItem.BackgroundTransparency = 1
		NutItem.TextTransparency = 1
		NutItem.Parent = DanhSachCuon

		local BoGocNut = Instance.new("UICorner")
		BoGocNut.CornerRadius = UDim.new(0, 8)
		BoGocNut.Parent = NutItem

		NutItem.MouseEnter:Connect(function()
			TweenService:Create(NutItem, CONFIG.HieuUng.NutHover, {
				Size = UDim2.new(1, 0, 0, 56),
				BackgroundColor3 = CONFIG.MauSac.NutHover,
				TextSize = 20
			}):Play()
		end)

		NutItem.MouseLeave:Connect(function()
			TweenService:Create(NutItem, CONFIG.HieuUng.NutHover, {
				Size = UDim2.new(1, 0, 0, 45),
				BackgroundColor3 = CONFIG.MauSac.NutThuong,
				TextSize = 18
			}):Play()
		end)

		NutItem.MouseButton1Click:Connect(function()
			if data.Link ~= "" then
				local ok, err = pcall(function() loadstring(game:HttpGet(data.Link))() end)
				if not ok then warn("Loi:", err) end
			end
		end)
	end

	NutDong.MouseEnter:Connect(function()
		TweenService:Create(NutDong, CONFIG.HieuUng.NutDongHover, {
			Size = CONFIG.KichThuoc.NutDongHover, 
			BackgroundColor3 = CONFIG.MauSac.DongHover, 
			TextSize = 22
		}):Play()
		TweenService:Create(PadNutDong, CONFIG.HieuUng.NutDongHover, {PaddingRight = UDim.new(0, 0.5)}):Play()
		VienNutDong.Transparency = 0.4
	end)

	NutDong.MouseLeave:Connect(function()
		TweenService:Create(NutDong, CONFIG.HieuUng.NutDongHover, {
			Size = CONFIG.KichThuoc.NutDong, 
			BackgroundColor3 = CONFIG.MauSac.DongThuong, 
			TextSize = 18
		}):Play()
		TweenService:Create(PadNutDong, CONFIG.HieuUng.NutDongHover, {PaddingRight = UDim.new(0, 0)}):Play()
		VienNutDong.Transparency = 0.8
	end)

	NutDong.MouseButton1Down:Connect(function()
		TweenService:Create(NutDong, CONFIG.HieuUng.FadeNhanh, {Size = CONFIG.KichThuoc.NutDongNhan}):Play()
	end)

	NutDong.MouseButton1Up:Connect(function()
		local PopAnim = TweenService:Create(NutDong, CONFIG.HieuUng.NutDongPop, {Size = CONFIG.KichThuoc.NutDongPop})
		PopAnim:Play()

		PopAnim.Completed:Connect(function()
			TweenService:Create(TieuDe, CONFIG.HieuUng.FadeNhanh, {TextTransparency = 1}):Play()
			TweenService:Create(DanhSachCuon, CONFIG.HieuUng.FadeNhanh, {BackgroundTransparency = 1, ScrollBarImageTransparency = 1}):Play()
			TweenService:Create(NutDong, CONFIG.HieuUng.FadeNhanh, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			TweenService:Create(VienNutDong, CONFIG.HieuUng.FadeNhanh, {Transparency = 1}):Play()

			for _, obj in ipairs(DanhSachCuon:GetChildren()) do
				if obj:IsA("GuiObject") then
					TweenService:Create(obj, CONFIG.HieuUng.FadeNhanh, {BackgroundTransparency = 1}):Play()
					if obj:IsA("TextButton") or obj:IsA("TextLabel") then
						TweenService:Create(obj, CONFIG.HieuUng.FadeNhanh, {TextTransparency = 1}):Play()
					end
				end
			end

			task.delay(0.2, function()
				TweenService:Create(IconDaiDien, CONFIG.HieuUng.Dong, {
					Position = CONFIG.KichThuoc.IconDauPos, 
					Size = CONFIG.KichThuoc.IconDau
				}):Play()

				local DongKhung = TweenService:Create(KhungChinh, CONFIG.HieuUng.Dong, {
					Size = CONFIG.KichThuoc.KhungDau,
					BackgroundTransparency = 1
				})
				DongKhung:Play()

				DongKhung.Completed:Connect(function()
					local FadeCuoi = TweenService:Create(IconDaiDien, CONFIG.HieuUng.FadeCham, {
						ImageTransparency = 1, 
						Size = UDim2.new(0,0,0,0)
					})
					FadeCuoi:Play()
					FadeCuoi.Completed:Connect(function() ScreenGui:Destroy() end)
				end)
			end)
		end)
	end)
end
TaoGiaoDien()
