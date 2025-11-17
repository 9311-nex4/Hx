local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local danhSachNut = {
	{ vanBan = "Transform", maLenh = "https://raw.githubusercontent.com/9311-nex4/Hx/main/Transform.lua" },
	{ vanBan = "2", maLenh = "" },
	{ vanBan = "3", maLenh = "" },
	{ vanBan = "4", maLenh = "" },
	{ vanBan = "5", maLenh = "" }
}

local ICON_DAI_DIEN = "rbxassetid://117118515787811"

local function taoGiaoDien()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GiaoDienChinh"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local khung = Instance.new("Frame")
	khung.Size = UDim2.new(0, 320, 0, 260)
	khung.Position = UDim2.new(0.5, 0, 0.5, 0)
	khung.AnchorPoint = Vector2.new(0.5, 0.5)
	khung.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	khung.BackgroundTransparency = 0.15
	khung.Active = true
	khung.Draggable = true
	khung.Parent = screenGui

	local khungCorner = Instance.new("UICorner")
	khungCorner.CornerRadius = UDim.new(0, 12)
	khungCorner.Parent = khung

	local iconUi = Instance.new("ImageLabel")
	iconUi.Size = UDim2.new(0, 35, 0, 35)
	iconUi.Position = UDim2.new(0, 10, 0, 10)
	iconUi.BackgroundTransparency = 1
	iconUi.Image = ICON_DAI_DIEN
	iconUi.Parent = khung

	local tieuDeUi = Instance.new("TextLabel")
	tieuDeUi.Text = "Hx Script"
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
	nutDong.AnchorPoint = Vector2.new(0.5, 0.5)
	nutDong.Position = UDim2.new(1, -25, 0, 25)
	nutDong.Text = "X"
	nutDong.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
	nutDong.BackgroundTransparency = 0.6
	nutDong.TextColor3 = Color3.fromRGB(255, 255, 255)
	nutDong.Font = Enum.Font.GothamBold
	nutDong.TextSize = 18
	nutDong.AutoButtonColor = false
	nutDong.Parent = khung

	local cornerNutDong = Instance.new("UICorner")
	cornerNutDong.CornerRadius = UDim.new(0, 8)
	cornerNutDong.Parent = nutDong

	local vienNutDong = Instance.new("UIStroke")
	vienNutDong.Color = Color3.fromRGB(255, 255, 255)
	vienNutDong.Thickness = 1.5
	vienNutDong.Transparency = 0.8
	vienNutDong.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	vienNutDong.Parent = nutDong
	
	local textPadding = Instance.new("UIPadding")
	textPadding.PaddingRight = UDim.new(0, 0)
	textPadding.Parent = nutDong

	local khungCuon = Instance.new("ScrollingFrame")
	khungCuon.Size = UDim2.new(1, -20, 1, -70)
	khungCuon.Position = UDim2.new(0, 10, 0, 50)
	khungCuon.CanvasSize = UDim2.new(0, 0, 0, 0)
	khungCuon.ScrollBarThickness = 4
	khungCuon.BackgroundTransparency = 0.6
	khungCuon.BorderSizePixel = 0
	khungCuon.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	khungCuon.Parent = khung

	local khungCuonCorner = Instance.new("UICorner")
	khungCuonCorner.CornerRadius = UDim.new(0, 8)
	khungCuonCorner.Parent = khungCuon

	local innerPadding = Instance.new("UIPadding")
	innerPadding.Parent = khungCuon
	innerPadding.PaddingLeft = UDim.new(0, 10)
	innerPadding.PaddingRight = UDim.new(0, 10)
	innerPadding.PaddingTop = UDim.new(0, 10)
	innerPadding.PaddingBottom = UDim.new(0, 10)

	local listLayout = Instance.new("UIListLayout")
	listLayout.Parent = khungCuon
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 8)

	local normalHeight = 45
	local hoverHeight = 56
	local normalTextSize = 18
	local hoverTextSize = 20
	local normalColor = Color3.fromRGB(90, 90, 90)
	local hoverColor = Color3.fromRGB(125, 125, 125)
	local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local activeTweens = 0
	local updating = false
	local heartbeatConn

	local function UpdateCanvas()
		local contentY = listLayout.AbsoluteContentSize.Y
		local totalPadding = innerPadding.PaddingTop.Offset + innerPadding.PaddingBottom.Offset
		khungCuon.CanvasSize = UDim2.new(0, 0, 0, contentY + totalPadding)
	end

	local function StartHeartbeat()
		if heartbeatConn or updating then return end
		updating = true
		heartbeatConn = RunService.Heartbeat:Connect(UpdateCanvas)
	end

	local function StopHeartbeat()
		updating = false
		if heartbeatConn then
			heartbeatConn:Disconnect()
			heartbeatConn = nil
		end
	end

	local function playTween(target, props, info)
		local tw = TweenService:Create(target, info or tweenInfo, props)
		activeTweens = activeTweens + 1
		StartHeartbeat()
		tw:Play()
		tw.Completed:Connect(function()
			activeTweens = math.max(0, activeTweens - 1)
			task.defer(UpdateCanvas)
			if activeTweens == 0 then
				StopHeartbeat()
			end
		end)
		return tw
	end

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

	for i, nut in ipairs(danhSachNut) do
		local nutChon = Instance.new("TextButton")
		nutChon.Size = UDim2.new(1, 0, 0, normalHeight)
		nutChon.LayoutOrder = i
		nutChon.Text = nut.vanBan
		nutChon.BackgroundColor3 = normalColor
		nutChon.TextColor3 = Color3.fromRGB(255, 255, 255)
		nutChon.Font = Enum.Font.GothamBold
		nutChon.TextSize = normalTextSize
		nutChon.AnchorPoint = Vector2.new(0, 0)
		nutChon.AutoButtonColor = false
		nutChon.Parent = khungCuon

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = nutChon

		nutChon.MouseEnter:Connect(function()
			playTween(nutChon, {Size = UDim2.new(1, 0, 0, hoverHeight)})
			playTween(nutChon, {BackgroundColor3 = hoverColor})
			playTween(nutChon, {TextSize = hoverTextSize})
		end)

		nutChon.MouseLeave:Connect(function()
			playTween(nutChon, {Size = UDim2.new(1, 0, 0, normalHeight)})
			playTween(nutChon, {BackgroundColor3 = normalColor})
			playTween(nutChon, {TextSize = normalTextSize})
		end)

		nutChon.MouseButton1Click:Connect(function()
			if nut.maLenh and nut.maLenh ~= "" then
				local ok, err = pcall(function()
					loadstring(game:HttpGet(nut.maLenh))()
				end)
				if not ok then
					warn("LỖi:", err)
				end
			end
		end)
	end

	local closeNormalSize = UDim2.new(0, 30, 0, 30)
	local closeHoverSize = UDim2.new(0, 35, 0, 35)
	local closeNormalTextSize = 18
	local closeHoverTextSize = 22
	local closeNormalColor = Color3.fromRGB(90, 90, 90)
	local closeHoverColor = Color3.fromRGB(180, 50, 50)
	local closeTweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function playCloseTween(target, props, info)
		local tw = TweenService:Create(target, info or closeTweenInfo, props)
		activeTweens = activeTweens + 1
		StartHeartbeat()
		tw:Play()
		tw.Completed:Connect(function()
			activeTweens = math.max(0, activeTweens - 1)
			task.defer(UpdateCanvas)
			if activeTweens == 0 then
				StopHeartbeat()
			end
		end)
		return tw
	end

	nutDong.MouseEnter:Connect(function()
		playCloseTween(nutDong, {Size = closeHoverSize})
		playCloseTween(nutDong, {BackgroundColor3 = closeHoverColor})
		playCloseTween(nutDong, {TextSize = closeHoverTextSize})
		playCloseTween(textPadding, {PaddingRight = UDim.new(0, 0.5)})
		vienNutDong.Transparency = 0.4
	end)

	nutDong.MouseLeave:Connect(function()
		playCloseTween(nutDong, {Size = closeNormalSize})
		playCloseTween(nutDong, {BackgroundColor3 = closeNormalColor})
		playCloseTween(nutDong, {TextSize = closeNormalTextSize})
		playCloseTween(textPadding, {PaddingRight = UDim.new(0, 0)})
		vienNutDong.Transparency = 0.8
	end)

	nutDong.MouseButton1Down:Connect(function()
		playCloseTween(nutDong, {Size = UDim2.new(0, 28, 0, 28)}, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In))
	end)

	nutDong.MouseButton1Up:Connect(function()
		local isHovering = false
		local mouse = Players.LocalPlayer:GetMouse()
		if mouse then
			local pos = Vector2.new(mouse.X, mouse.Y)
			local absPos = nutDong.AbsolutePosition
			local absSize = nutDong.AbsoluteSize
			if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
				isHovering = true
			end
		end
		if isHovering then
			playCloseTween(nutDong, {Size = closeHoverSize})
			playCloseTween(nutDong, {BackgroundColor3 = closeHoverColor})
			playCloseTween(nutDong, {TextSize = closeHoverTextSize})
		else
			playCloseTween(nutDong, {Size = closeNormalSize})
			playCloseTween(nutDong, {BackgroundColor3 = closeNormalColor})
			playCloseTween(nutDong, {TextSize = closeNormalTextSize})
		end

		local pop = playCloseTween(nutDong, {Size = UDim2.new(0, 48, 0, 48)}, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
		pop.Completed:Wait()

		local closeAnimInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		playCloseTween(khung, {BackgroundTransparency = 1}, closeAnimInfo)
		playCloseTween(khungCuon, {BackgroundTransparency = 1}, closeAnimInfo)
		playCloseTween(tieuDeUi, {TextTransparency = 1}, closeAnimInfo)
		playCloseTween(iconUi, {ImageTransparency = 1}, closeAnimInfo)
		playCloseTween(nutDong, {BackgroundTransparency = 1, TextTransparency = 1, Size = UDim2.new(0, 8, 0, 8)}, closeAnimInfo)

		wait(0.18)
		screenGui:Destroy()
	end)

	UpdateCanvas()
end

taoGiaoDien()
