local ETC_Logic = {
	DangBatClickTP = false,
	PhimClickTP = Enum.KeyCode.T,
	KetNoiClickTP = nil,
	DangBayTP = false,
	TargetLockConnection = nil,
	FlyEnabled = false,
	FlySpeed = 16,
	FlyHotkey = Enum.KeyCode.F,
	FlyCollide = false,
	NoclipEnabled = false,
	ESP_Players = false,
	ESP_Items = false,
	ESP_Tracker = false,
	ListItemsESP = {},
	DangChonItem = false,
	TemplateSelectionEnabled = false,
	CurrentSelectedTemplate = nil,
}

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

local flyVelocity, flyGyro, flyConnection
local tweenFlyVelocity, tweenFlyGyro
local noclipConnection, selectionConnection
local espCache     = {}
local ScannedItems = {}
local espThrottle  = 0

local DiaDiemGame = { [0] = {"1", "2", "3"} }
local MAX_FORCE   = Vector3.new(9e9, 9e9, 9e9)
local VEC_ZERO    = Vector3.zero
local OFFSET_CFL  = CFrame.new(0, 0, 3)

local targetLockCooldown = false
local TARGET_LOCK_CD     = 0.4

local AllConnections = {}

local function TrackConn(c)
	table.insert(AllConnections, c)
	return c
end

function ETC_Logic.GetConfig()
	local items = {}
	for _, v in ipairs(ETC_Logic.ListItemsESP) do table.insert(items, v.Ten) end
	return {
		FlySpeed    = ETC_Logic.FlySpeed,
		FlyCollide  = ETC_Logic.FlyCollide,
		ESP_Players = ETC_Logic.ESP_Players,
		ESP_Items   = ETC_Logic.ESP_Items,
		ESP_Tracker = ETC_Logic.ESP_Tracker,
		SavedItems  = items,
	}
end

function ETC_Logic.SetConfig(cfg)
	if not cfg then return end
	if cfg.FlySpeed    ~= nil then ETC_Logic.FlySpeed    = cfg.FlySpeed    end
	if cfg.FlyCollide  ~= nil then ETC_Logic.FlyCollide  = cfg.FlyCollide  end
	if cfg.ESP_Players ~= nil then ETC_Logic.ESP_Players = cfg.ESP_Players end
	if cfg.ESP_Items   ~= nil then ETC_Logic.ESP_Items   = cfg.ESP_Items   end
	if cfg.ESP_Tracker ~= nil then ETC_Logic.ESP_Tracker = cfg.ESP_Tracker end
end

function ETC_Logic.LayDiaDiemGame(PlaceId) return DiaDiemGame[PlaceId] or {"Chưa có"} end

function ETC_Logic.GetPlayers()
	local ds = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then table.insert(ds, plr.Name) end
	end
	if #ds == 0 then ds[1] = "Không có" end
	return ds
end

local function CleanTweenFly()
	if tweenFlyVelocity then tweenFlyVelocity:Destroy(); tweenFlyVelocity = nil end
	if tweenFlyGyro     then tweenFlyGyro:Destroy();     tweenFlyGyro     = nil end
end

local function TweenBypassFly(TargetCFrame)
	local char = LocalPlayer.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")

	CleanTweenFly()
	ETC_Logic.DangBayTP = true

	local speed = (humanoid and humanoid.WalkSpeed > 0) and math.max(humanoid.WalkSpeed, 50) or 50

	tweenFlyVelocity = Instance.new("BodyVelocity")
	tweenFlyVelocity.MaxForce = MAX_FORCE
	tweenFlyVelocity.Parent   = hrp

	tweenFlyGyro = Instance.new("BodyGyro")
	tweenFlyGyro.MaxTorque = MAX_FORCE
	tweenFlyGyro.P        = 90000
	tweenFlyGyro.Parent   = hrp

	if humanoid then humanoid.PlatformStand = true end

	local connection
	connection = RunService.Stepped:Connect(function()
		if not ETC_Logic.DangBayTP or not char or not hrp or not char.Parent then
			connection:Disconnect()
			CleanTweenFly()
			if humanoid then humanoid.PlatformStand = false end
			return
		end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
		local currentPos = hrp.Position
		local targetPos  = TargetCFrame.Position
		local direction  = targetPos - currentPos
		if direction.Magnitude < 5 then
			hrp.CFrame = TargetCFrame
			ETC_Logic.StopTP()
		else
			tweenFlyVelocity.Velocity = direction.Unit * speed
			tweenFlyGyro.CFrame       = CFrame.new(currentPos, targetPos)
		end
	end)
end

function ETC_Logic.TeleportTo(CFrameTarget)
	if not CFrameTarget then return end
	ETC_Logic.StopTP()
	local char = LocalPlayer.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	hrp.CFrame = CFrameTarget
	task.spawn(function()
		task.wait(0.4)
		if char and char:FindFirstChild("HumanoidRootPart")
			and (hrp.Position - CFrameTarget.Position).Magnitude > 15 then
			TweenBypassFly(CFrameTarget)
		end
	end)
end

function ETC_Logic.TeleportToPlayer(TenNguoiChoi)
	local target    = Players:FindFirstChild(TenNguoiChoi)
	local targetHRP = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if targetHRP then ETC_Logic.TeleportTo(targetHRP.CFrame * OFFSET_CFL) end
end

function ETC_Logic.TargetLock(Loai, MucTieu, TrangThai)
	if ETC_Logic.TargetLockConnection then
		ETC_Logic.TargetLockConnection:Disconnect()
		ETC_Logic.TargetLockConnection = nil
	end
	if not TrangThai then return end
	targetLockCooldown = false

	ETC_Logic.TargetLockConnection = RunService.Heartbeat:Connect(function()
		if Loai == "Player" then
			local target     = Players:FindFirstChild(MucTieu)
			local targetChar = target and target.Character
			local targetHRP  = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
			local targetHum  = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
			local charHRP    = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

			if targetHRP and charHRP and targetHum and targetHum.Health > 0 then
				local targetCFrame = targetHRP.CFrame * OFFSET_CFL
				local dist = (charHRP.Position - targetCFrame.Position).Magnitude

				if not ETC_Logic.DangBayTP and not targetLockCooldown then
					if dist > 15 then
						targetLockCooldown = true
						ETC_Logic.TeleportTo(targetCFrame)
						task.delay(TARGET_LOCK_CD, function()
							targetLockCooldown = false
						end)
					else
						charHRP.CFrame = targetCFrame
					end
				end
			end
		end
	end)
end

function ETC_Logic.StopTP()
	ETC_Logic.DangBayTP = false
	targetLockCooldown  = false
	CleanTweenFly()
	if ETC_Logic.TargetLockConnection then
		ETC_Logic.TargetLockConnection:Disconnect()
		ETC_Logic.TargetLockConnection = nil
	end
end

function ETC_Logic.TeleportToMouse()
	local mouse = LocalPlayer:GetMouse()
	if mouse.Target then
		ETC_Logic.TeleportTo(CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)))
	end
end

function ETC_Logic.SetClickTP(TrangThai)
	ETC_Logic.DangBatClickTP = TrangThai
	if TrangThai and not ETC_Logic.KetNoiClickTP then
		ETC_Logic.KetNoiClickTP = UserInputService.InputBegan:Connect(function(input, processed)
			if not processed
				and not UserInputService:GetFocusedTextBox()
				and input.UserInputType == Enum.UserInputType.MouseButton1
				and UserInputService:IsKeyDown(ETC_Logic.PhimClickTP) then
				ETC_Logic.TeleportToMouse()
			end
		end)
	elseif not TrangThai and ETC_Logic.KetNoiClickTP then
		ETC_Logic.KetNoiClickTP:Disconnect()
		ETC_Logic.KetNoiClickTP = nil
	end
end

function ETC_Logic.SetKey(Key) ETC_Logic.PhimClickTP = Key end


local function GetFlyMovement()
	local moveDir = VEC_ZERO
	local cframe  = Camera.CFrame
	if UserInputService:IsKeyDown(Enum.KeyCode.W)         then moveDir += cframe.LookVector     end
	if UserInputService:IsKeyDown(Enum.KeyCode.S)         then moveDir -= cframe.LookVector     end
	if UserInputService:IsKeyDown(Enum.KeyCode.A)         then moveDir -= cframe.RightVector    end
	if UserInputService:IsKeyDown(Enum.KeyCode.D)         then moveDir += cframe.RightVector    end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then moveDir += Vector3.new(0, 1, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
	return moveDir
end

function ETC_Logic.ToggleFly(state)
	ETC_Logic.FlyEnabled = state
	local char = LocalPlayer.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	local hum  = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp then return end

	if state then
		if ETC_Logic.DangBayTP then ETC_Logic.StopTP() end

		if hum then hum.PlatformStand = true end

		flyVelocity = Instance.new("BodyVelocity")
		flyVelocity.MaxForce = MAX_FORCE
		flyVelocity.Parent   = hrp

		flyGyro = Instance.new("BodyGyro")
		flyGyro.MaxTorque = MAX_FORCE
		flyGyro.P         = 9e4
		flyGyro.Parent    = hrp

		flyConnection = RunService.RenderStepped:Connect(function()
			if not ETC_Logic.FlyEnabled or not char or not char.Parent then return end
			local moveVector = GetFlyMovement()
			flyVelocity.Velocity = moveVector.Magnitude > 0
				and moveVector.Unit * ETC_Logic.FlySpeed * 2.5
				or VEC_ZERO
			flyGyro.CFrame = Camera.CFrame
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = ETC_Logic.FlyCollide
				end
			end
		end)
	else
		if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
		if flyVelocity   then flyVelocity:Destroy();    flyVelocity   = nil end
		if flyGyro       then flyGyro:Destroy();         flyGyro       = nil end
		if hum           then hum.PlatformStand = false end
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end
end

function ETC_Logic.ToggleNoclip(state)
	ETC_Logic.NoclipEnabled = state
	if state and not noclipConnection then
		noclipConnection = RunService.Stepped:Connect(function()
			local char = LocalPlayer.Character
			if not char then return end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	elseif not state and noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end
end

local C3_Green  = Color3.new(0, 1, 0)
local C3_Red    = Color3.new(1, 0, 0)
local C3_Yellow = Color3.new(1, 1, 0)
local C3_White  = Color3.new(1, 1, 1)

local function GetPlayerColor(plr)
	return plr.Team == LocalPlayer.Team and C3_Green or C3_Red
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function CreateESPData(obj, typeESP)
	if espCache[obj] then return espCache[obj] end
	local folder = Instance.new("Folder")
	folder.Name   = typeESP == "Player" and obj.Name .. "_ESP" or "Item_ESP"
	folder.Parent = PlayerGui

	local highlight
	if typeESP == "Player" then
		highlight = Instance.new("Highlight")
		highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency    = 0.6
		highlight.OutlineTransparency = 0
	else
		highlight = Instance.new("SelectionBox")
		highlight.LineThickness       = 0.08
		highlight.SurfaceTransparency = 1
		highlight.Color3              = C3_Yellow
	end
	highlight.Parent = folder

	local billboard = Instance.new("BillboardGui")
	billboard.Size        = UDim2.new(0, 200, 0, 50)
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Parent      = folder

	local textLabel = Instance.new("TextLabel")
	textLabel.Size                   = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font                   = Enum.Font.GothamBold
	textLabel.TextSize               = 14
	textLabel.TextStrokeTransparency = 0
	textLabel.Parent                 = billboard

	local data = { Folder = folder, Highlight = highlight, Billboard = billboard, Text = textLabel, Type = typeESP }
	espCache[obj] = data
	return data
end

local function ClearESPCache(obj)
	if espCache[obj] then
		if espCache[obj].Folder then espCache[obj].Folder:Destroy() end
		espCache[obj] = nil
	end
end

local function SetupCharacterESPCleanup(plr)
	plr.CharacterAdded:Connect(function()
		ClearESPCache(plr)
	end)
end
for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LocalPlayer then SetupCharacterESPCleanup(plr) end
end
TrackConn(Players.PlayerAdded:Connect(function(plr)
	if plr ~= LocalPlayer then SetupCharacterESPCleanup(plr) end
end))
TrackConn(Players.PlayerRemoving:Connect(ClearESPCache))

task.spawn(function()
	while task.wait(1.5) do
		if ETC_Logic.ESP_Items and #ETC_Logic.ListItemsESP > 0 then
			local namesToFind = {}
			for _, v in ipairs(ETC_Logic.ListItemsESP) do namesToFind[v.Ten] = true end
			local newScanned = {}
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") and namesToFind[obj.Name] then
					newScanned[obj] = obj.Name
					if not espCache[obj] then
						local data = CreateESPData(obj, "Item")
						data.Highlight.Adornee = obj
						data.Billboard.Adornee = obj
					end
				end
			end
			ScannedItems = newScanned
			for obj, data in pairs(espCache) do
				if data.Type == "Item" and not ScannedItems[obj] then ClearESPCache(obj) end
			end
		else
			ScannedItems = {}
			for obj, data in pairs(espCache) do
				if data.Type == "Item" then ClearESPCache(obj) end
			end
		end
	end
end)

TrackConn(RunService.Heartbeat:Connect(function(dt)
	espThrottle += dt
	if espThrottle < 0.1 then return end
	espThrottle = 0

	local lpChar = LocalPlayer.Character
	local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
	local lpPos  = lpRoot and lpRoot.Position

	if ETC_Logic.ESP_Players then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local char = plr.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local hum  = char and char:FindFirstChildOfClass("Humanoid")
				if root and hum and hum.Health > 0 then
					local data  = CreateESPData(plr, "Player")
					local color = GetPlayerColor(plr)
					data.Highlight.Adornee      = char
					data.Highlight.FillColor    = color
					data.Highlight.OutlineColor = C3_White
					data.Billboard.Adornee      = root
					if ETC_Logic.ESP_Tracker then
						local dist = lpPos and math.floor((root.Position - lpPos).Magnitude) or 0
						data.Text.Text       = string.format("%s\n[%d HP] [%dm]", plr.Name, math.floor(hum.Health), dist)
						data.Text.TextColor3 = color
					else
						data.Text.Text = ""
					end
				else
					ClearESPCache(plr)
				end
			end
		end
	else
		for _, plr in ipairs(Players:GetPlayers()) do
			if espCache[plr] then ClearESPCache(plr) end
		end
	end

	if ETC_Logic.ESP_Items and ETC_Logic.ESP_Tracker then
		for obj, name in pairs(ScannedItems) do
			local data = espCache[obj]
			if data and data.Billboard.Adornee then
				local dist = lpPos and math.floor((obj.Position - lpPos).Magnitude) or 0
				data.Text.Text       = string.format("%s\n[%dm]", name, dist)
				data.Text.TextColor3 = C3_Yellow
			end
		end
	elseif ETC_Logic.ESP_Items and not ETC_Logic.ESP_Tracker then
		for obj in pairs(ScannedItems) do
			local data = espCache[obj]
			if data then data.Text.Text = "" end
		end
	end
end))

local selectionBox = Instance.new("SelectionBox")
selectionBox.Name                = "TemplateSelectionBox"
selectionBox.Color3              = C3_Green
selectionBox.LineThickness       = 0.1
selectionBox.SurfaceColor3       = C3_Green
selectionBox.SurfaceTransparency = 0.5
selectionBox.Parent              = PlayerGui

local deleteBox = Instance.new("SelectionBox")
deleteBox.Name                = "DeleteSelectionBox"
deleteBox.Color3              = C3_Red
deleteBox.LineThickness       = 0.1
deleteBox.SurfaceColor3       = C3_Red
deleteBox.SurfaceTransparency = 0.5
deleteBox.Parent              = PlayerGui

function ETC_Logic.ToggleTemplateSelection(state, callback)
	ETC_Logic.TemplateSelectionEnabled = state
	if state then
		local mouse = LocalPlayer:GetMouse()
		if not selectionConnection then
			selectionConnection = mouse.Button1Down:Connect(function()
				if ETC_Logic.TemplateSelectionEnabled and mouse.Target then
					ETC_Logic.CurrentSelectedTemplate = mouse.Target
					selectionBox.Adornee = ETC_Logic.CurrentSelectedTemplate
					if callback then callback(ETC_Logic.CurrentSelectedTemplate.Name) end
				end
			end)
		end
	else
		if selectionConnection then selectionConnection:Disconnect(); selectionConnection = nil end
		ETC_Logic.CurrentSelectedTemplate = nil
		selectionBox.Adornee = nil
	end
end

function ETC_Logic.AddCurrentTemplate()
	if ETC_Logic.CurrentSelectedTemplate then
		local name = ETC_Logic.CurrentSelectedTemplate.Name
		ETC_Logic.CurrentSelectedTemplate = nil
		selectionBox.Adornee = nil
		return name
	end
	return nil
end

function ETC_Logic.HighlightForDeletion(itemName)
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == itemName then
			deleteBox.Adornee = obj
			task.delay(2.5, function()
				if deleteBox.Adornee == obj then deleteBox.Adornee = nil end
			end)
			return
		end
	end
end

function ETC_Logic.Destroy()
	ETC_Logic.ToggleFly(false)
	ETC_Logic.ToggleNoclip(false)
	ETC_Logic.SetClickTP(false)
	ETC_Logic.StopTP()
	ETC_Logic.ToggleTemplateSelection(false)

	if ETC_Logic.TargetLockConnection then
		ETC_Logic.TargetLockConnection:Disconnect()
		ETC_Logic.TargetLockConnection = nil
	end

	for _, c in ipairs(AllConnections) do c:Disconnect() end
	table.clear(AllConnections)

	for obj in pairs(espCache) do ClearESPCache(obj) end
	table.clear(ScannedItems)

	if selectionBox and selectionBox.Parent then selectionBox:Destroy() end
	if deleteBox    and deleteBox.Parent    then deleteBox:Destroy()    end
end

return ETC_Logic
