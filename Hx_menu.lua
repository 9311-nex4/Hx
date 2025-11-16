local nguoiChoi = game:GetService("Players")
local nguoiChoiCucBo = nguoiChoi.LocalPlayer
local giaoDienNguoiChoi = nguoiChoiCucBo:WaitForChild("PlayerGui")

local danhSachNut = {
	{ vanBan = "Transform", maLenh = [['https://raw.githubusercontent.com/9311-nex4/Hx/main/Transform']] },
	{ vanBan = "2", maLenh = [[]] },
	{ vanBan = "3", maLenh = [[]] },
	{ vanBan = "4", maLenh = [[]] },
	{ vanBan = "5", maLenh = [[]] }
}

local soNut = #danhSachNut

local ICON_DAI_DIEN = "rbxassetid://117118515787811"

local function taoGiaoDien()
	local giaoDienChinh = Instance.new("ScreenGui")
	giaoDienChinh.Name = "GiaoDienChinh"
	giaoDienChinh.ResetOnSpawn = false
	giaoDienChinh.Parent = giaoDienNguoiChoi

	local khung = Instance.new("Frame")
	khung.Size = UDim2.new(0, 320, 0, 220)
	khung.Position = UDim2.new(0.5, 0, 0.5, 0)
	khung.AnchorPoint = Vector2.new(0.5, 0.5)
	khung.BackgroundColor3 = Color3.fromRGB(15, 15, 15) 
	khung.Active = true
	khung.Draggable = true
	khung.Parent = giaoDienChinh

	local iconUi = Instance.new("ImageLabel")
	iconUi.Size = UDim2.new(0, 35, 0, 35)
	iconUi.Position = UDim2.new(0, 10, 0, 10)
	iconUi.BackgroundTransparency = 1
	iconUi.Image = ICON_DAI_DIEN
	iconUi.Parent = khung

	local tieuDeUi = Instance.new("TextLabel")
	tieuDeUi.Text = "Hx Script "
	tieuDeUi.Size = UDim2.new(1, -80, 0, 40)
	tieuDeUi.Position = UDim2.new(0, 50, 0, 5)
	tieuDeUi.BackgroundTransparency = 1
	tieuDeUi.TextColor3 = Color3.fromRGB(255, 255, 255)
	tieuDeUi.Font = Enum.Font.GothamBold
	tieuDeUi.TextSize = 22
	tieuDeUi.TextXAlignment = Enum.TextXAlignment.Left
	tieuDeUi.Parent = khung

	local nutDong = Instance.new("TextButton")
	nutDong.Size = UDim2.new(0, 30, 0, 30)
	nutDong.Position = UDim2.new(1, -40, 0, 10)
	nutDong.Text = "X"
	nutDong.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	nutDong.TextColor3 = Color3.fromRGB(255, 255, 255)
	nutDong.Font = Enum.Font.GothamBold
	nutDong.TextSize = 18
	nutDong.Parent = khung
	nutDong.MouseButton1Click:Connect(function()
		giaoDienChinh:Destroy()
	end)

	local cornernutDong = Instance.new("UICorner")
	cornernutDong.CornerRadius = UDim.new(0, 8)
	cornernutDong.Parent = nutDong

	local khungCuon = Instance.new("ScrollingFrame")
	khungCuon.Size = UDim2.new(1, -20, 1, -60)
	khungCuon.Position = UDim2.new(0, 10, 0, 50)
	khungCuon.CanvasSize = UDim2.new(0, 0, 0, soNut * 50)
	khungCuon.ScrollBarThickness = 3
	khungCuon.BackgroundTransparency = 0.2
	khungCuon.BorderSizePixel = 0
	khungCuon.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
	khungCuon.Parent = khung
	
	local cornerkhungCuon = Instance.new("UICorner")
	cornerkhungCuon.CornerRadius = UDim.new(0, 8)
	cornerkhungCuon.Parent = khungCuon

	for i, nut in ipairs(danhSachNut) do
		local nutChon = Instance.new("TextButton")
		nutChon.Size = UDim2.new(1, -20, 0, 45)
		nutChon.Position = UDim2.new(0, 10, 0, (i-1)*50 + 5)
		nutChon.Text = nut.vanBan
		nutChon.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		nutChon.TextColor3 = Color3.fromRGB(255, 255, 255)
		nutChon.Font = Enum.Font.GothamBold
		nutChon.TextSize = 18
		nutChon.Parent = khungCuon

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = nutChon

		nutChon.MouseEnter:Connect(function()
			nutChon.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
		end)
		nutChon.MouseLeave:Connect(function()
			nutChon.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		end)

		nutChon.MouseButton1Click:Connect(function()
			loadstring(game:HttpGet(nut.maLenh))()
			giaoDienChinh:Destroy()
		end)
	end

	local cornerKhung = Instance.new("UICorner")
	cornerKhung.CornerRadius = UDim.new(0, 12)
	cornerKhung.Parent = khung
end

taoGiaoDien()
