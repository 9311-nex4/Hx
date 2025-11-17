local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local nguoi = Players.LocalPlayer
local guiNguoi = nguoi:WaitForChild("PlayerGui")

local MAX_NOTIFS = 3
local NOTIF_HEIGHT = 80
local PADDING = 10

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "HeThongThongBao"
mainGui.ResetOnSpawn = false
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
mainGui.Parent = guiNguoi

local activeNotifs = {} 

local function updatePositions()
	for i, item in ipairs(activeNotifs) do
		local offset = (i - 1) * (NOTIF_HEIGHT + PADDING)
		local targetPos = UDim2.new(1, -20, 1, -20 - offset)
		TweenService:Create(item.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
	end
end

local function thongbao(tieude, noidung, thoigian)
	if #activeNotifs >= MAX_NOTIFS then
		local oldNotif = activeNotifs[1]
		if oldNotif and not oldNotif.IsClosing then
			oldNotif.SpeedUp()
		end
		repeat task.wait() until #activeNotifs < MAX_NOTIFS
	end

	local currentCount = #activeNotifs
	local offset = currentCount * (NOTIF_HEIGHT + PADDING)

	local viTriAn = UDim2.new(1, 250, 1, -20 - offset)
	local viTriHien = UDim2.new(1, -20, 1, -20 - offset)

	local mau1 = Color3.fromRGB(85, 255, 127)
	local mau2 = Color3.fromRGB(255, 255, 85)
	local mau3 = Color3.fromRGB(255, 85, 85)

	local khung = Instance.new("Frame")
	khung.Name = "NoiDung"
	khung.Size = UDim2.new(0, 170, 0, NOTIF_HEIGHT - 10)
	khung.Position = viTriAn
	khung.AnchorPoint = Vector2.new(1, 1)
	khung.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	khung.BorderSizePixel = 0
	khung.Parent = mainGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = khung

	local stroke = Instance.new("UIStroke")
	stroke.Color = mau1
	stroke.Thickness = 2
	stroke.Transparency = 0.8
	stroke.Parent = khung

	local lblTieuDe = Instance.new("TextLabel")
	lblTieuDe.Text = tieude
	lblTieuDe.Size = UDim2.new(0.9, 0, 0.25, 0)
	lblTieuDe.Position = UDim2.new(0.5, 0, 0.2, 0)
	lblTieuDe.AnchorPoint = Vector2.new(0.5, 0.5)
	lblTieuDe.BackgroundTransparency = 1
	lblTieuDe.TextColor3 = Color3.fromRGB(255, 255, 255)
	lblTieuDe.Font = Enum.Font.GothamBold
	lblTieuDe.TextSize = 18
	lblTieuDe.Parent = khung

	local lblNoiDung = Instance.new("TextLabel")
	lblNoiDung.Text = noidung
	lblNoiDung.Size = UDim2.new(0.9, 0, 0.4, 0)
	lblNoiDung.Position = UDim2.new(0.5, 0, 0.55, 0)
	lblNoiDung.AnchorPoint = Vector2.new(0.5, 0.5)
	lblNoiDung.BackgroundTransparency = 1
	lblNoiDung.TextColor3 = Color3.fromRGB(220, 220, 220)
	lblNoiDung.Font = Enum.Font.Gotham
	lblNoiDung.TextScaled = true
	lblNoiDung.Parent = khung

	local nenThanh = Instance.new("Frame")
	nenThanh.Size = UDim2.new(0.9, 0, 0.05, 0)
	nenThanh.Position = UDim2.new(0.5, 0, 0.88, 0)
	nenThanh.AnchorPoint = Vector2.new(0.5, 0.5)
	nenThanh.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	nenThanh.Parent = khung
	Instance.new("UICorner", nenThanh).CornerRadius = UDim.new(0, 6)

	local thanh = Instance.new("Frame")
	thanh.Size = UDim2.new(1, 0, 1, 0)
	thanh.BackgroundColor3 = mau1
	thanh.Parent = nenThanh
	Instance.new("UICorner", thanh).CornerRadius = UDim.new(0, 6)

	local notifData = {
		Frame = khung,
		IsClosing = false,
		SpeedUp = nil
	}
	table.insert(activeNotifs, notifData)

	task.spawn(function()
		local inTw = TweenService:Create(khung, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = viTriHien})
		inTw:Play()
		inTw.Completed:Wait()

		local timeTw = TweenService:Create(thanh, TweenInfo.new(thoigian, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})

		local val = Instance.new("Color3Value")
		val.Value = mau1
		val.Changed:Connect(function(v)
			stroke.Color = v
			thanh.BackgroundColor3 = v
		end)

		local half = thoigian / 2
		local c1 = TweenService:Create(val, TweenInfo.new(half), {Value = mau2})
		local c2 = TweenService:Create(val, TweenInfo.new(half), {Value = mau3})

		c1:Play()
		c1.Completed:Connect(function() if not notifData.IsClosing then c2:Play() end end)
		timeTw:Play()

		notifData.SpeedUp = function()
			if not notifData.IsClosing then
				notifData.IsClosing = true
				timeTw:Cancel()
				c1:Cancel()
				c2:Cancel()
				TweenService:Create(thanh, TweenInfo.new(0.1), {Size = UDim2.new(0,0,1,0)}):Play()
				task.wait(0.15)
			end
		end

		if not notifData.IsClosing then
			timeTw.Completed:Wait()
		end
		notifData.IsClosing = true

		for i, v in ipairs(activeNotifs) do
			if v == notifData then
				table.remove(activeNotifs, i)
				break
			end
		end
		updatePositions()

		local outPos = UDim2.new(1, 250, khung.Position.Y.Scale, khung.Position.Y.Offset)
		local outTw = TweenService:Create(khung, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = outPos})
		outTw:Play()
		outTw.Completed:Wait()

		khung:Destroy()
		val:Destroy()
	end)
end

return thongbao
