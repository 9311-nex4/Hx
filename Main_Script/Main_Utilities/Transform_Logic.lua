local Transform = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local PlayerGui = Player.PlayerGui

local State = {
	IsActive = true,
	CanSelect = true,
	CanMove = false,
	ShowOutline = true,
	CurrentMode = "ToanThan",
	SelectedPart = nil,
	CurrentDummy = nil,
	DraggingPart = nil,
}

local Storage = {
	SavedParts = {},
	CreatedObjects = {},
	OrigTransparency = {},
	OrigCollision = {},
}

local Connections = {
	AnimationSync = nil,
	InputListener = nil,
	DragListener = nil,
	DeathListener = nil,
}

local ASSET_HAT = "rbxassetid://2130129598"
local SEL_COLOR = Color3.fromRGB(0, 255, 0)

local PART_MAP = {
	Head      = { "Head" },
	Torso     = { "Torso", "UpperTorso", "LowerTorso" },
	RightArm  = { "Right Arm", "RightUpperArm", "RightLowerArm", "RightHand" },
	LeftArm   = { "Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand" },
	RightLeg  = { "Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot" },
	LeftLeg   = { "Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
}

local DRAG_TWEEN = TweenInfo.new(0.07, Enum.EasingStyle.Linear)
local DRAG_RAY_PARAMS = RaycastParams.new()
DRAG_RAY_PARAMS.FilterType = Enum.RaycastFilterType.Blacklist

local SELECT_RAY_PARAMS = RaycastParams.new()
SELECT_RAY_PARAMS.FilterType = Enum.RaycastFilterType.Blacklist

local V3_ZERO = Vector3.new(0, 0, 0)

local function TaoHieuUng(part)
	if not part then return end
	local att = Instance.new("Attachment")
	att.Parent = part
	local p = Instance.new("ParticleEmitter")
	p.Texture = ASSET_HAT
	p.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 85, 255))
	p.Size = NumberSequence.new(0.1, 0.5, 0.1)
	p.Transparency = NumberSequence.new(0, 1)
	p.Lifetime = NumberRange.new(0.5, 1)
	p.Speed = NumberRange.new(2, 5)
	p.Rate = 0
	p.Parent = att
	p:Emit(50)
	Debris:AddItem(att, 2)
end

local function CapNhatOutline()
	local old = PlayerGui:FindFirstChild("TransformSelectionBox")
	if old then old:Destroy() end
	local sel = State.SelectedPart
	if State.ShowOutline and sel then
		local box = Instance.new("SelectionBox")
		box.Name = "TransformSelectionBox"
		box.Color3 = SEL_COLOR
		box.LineThickness = 0.05
		box.Adornee = sel
		box.Parent = PlayerGui
	end
end

local function AnNhanVatThat()
	local char = Player.Character
	if not char then return end
	local origT, origC = Storage.OrigTransparency, Storage.OrigCollision
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			origT[v] = v.Transparency
			origC[v] = v.CanCollide
			v.Transparency = 1
			v.CanCollide = false
		elseif v:IsA("Decal") or v:IsA("Texture") then
			origT[v] = v.Transparency
			v.Transparency = 1
		end
	end
end

local function HienNhanVatThat()
	for obj, t in next, Storage.OrigTransparency do
		if obj and obj.Parent then obj.Transparency = t end
	end
	for obj, c in next, Storage.OrigCollision do
		if obj and obj.Parent then obj.CanCollide = c end
	end
	table.clear(Storage.OrigTransparency)
	table.clear(Storage.OrigCollision)
end

local function BatDauKeoTha()
	local conn = Connections.DragListener
	if conn then conn:Disconnect() end

	local char = Player.Character
	Connections.DragListener = RunService.RenderStepped:Connect(function()
		local dp = State.DraggingPart
		if not (State.CanMove and dp and dp.Parent) then return end

		DRAG_RAY_PARAMS.FilterDescendantsInstances = { dp, char or Player.Character }
		local ray = Mouse.UnitRay
		local result = workspace:Raycast(ray.Origin, ray.Direction * 100, DRAG_RAY_PARAMS)
		local targetPos = result
			and result.Position + Vector3.new(0, dp.Size.Y * 0.5, 0)
			or ray.Origin + ray.Direction * 20

		dp.Anchored = true
		TweenService:Create(dp, DRAG_TWEEN, { Position = targetPos }):Play()
	end)
end

local function BienHinh_ToanThan(char, root)
	local sel = State.SelectedPart
	if not sel then return false, "Chưa chọn Part!" end
	AnNhanVatThat()
	local clone = sel:Clone()
	clone.Name = "Morph_FullBody"
	clone.Anchored = false
	clone.CanCollide = false
	clone.Massless = true
	clone.CFrame = root.CFrame
	local w = Instance.new("WeldConstraint")
	w.Part0 = root; w.Part1 = clone; w.Parent = root
	clone.Parent = char
	table.insert(Storage.CreatedObjects, clone)
	return true, "Biến hình toàn thân thành công!"
end

local function BienHinh_TungPhan(char)
	local hasPart = false
	AnNhanVatThat()
	local saved = Storage.SavedParts
	local created = Storage.CreatedObjects
	for logicName, realList in next, PART_MAP do
		local src = saved[logicName]
		if src then
			hasPart = true
			local target
			for i = 1, #realList do
				local c = char:FindFirstChild(realList[i])
				if c then target = c; break end
			end
			if target then
				local clone = src:Clone()
				clone.Name = "Morph_" .. logicName
				clone.Anchored = false
				clone.CanCollide = false
				clone.Massless = true
				clone.CFrame = target.CFrame
				local w = Instance.new("WeldConstraint")
				w.Part0 = target; w.Part1 = clone; w.Parent = target
				clone.Parent = char
				table.insert(created, clone)
			end
		end
	end
	if not hasPart then HienNhanVatThat(); return false, "Chưa lưu trữ bộ phận nào!" end
	return true, "Biến hình từng phần thành công!"
end

local function BienHinh_NhanVat(char, root)
	local sel = State.SelectedPart
	local targetModel = sel and sel:FindFirstAncestorWhichIsA("Model")
	if not targetModel or not targetModel:FindFirstChild("Humanoid") then
		return false, "Đối tượng chọn không phải là Nhân Vật!"
	end
	if targetModel == char then return false, "Không thể biến thành chính mình!" end

	local myHum = char:FindFirstChild("Humanoid")
	AnNhanVatThat()
	targetModel.Archivable = true
	local cloneChar = targetModel:Clone()
	cloneChar.Name = "Morph_Character"

	for _, v in ipairs(cloneChar:GetDescendants()) do
		if v:IsA("Script") or (v:IsA("LocalScript") and v.Name ~= "Animate") then
			v:Destroy()
		elseif v:IsA("BasePart") then
			v.Anchored = false
			v.CanCollide = false
			v.Massless = true
		end
	end

	local cloneRoot = cloneChar:FindFirstChild("HumanoidRootPart")
	local cloneHum = cloneChar:FindFirstChild("Humanoid")
	if not cloneRoot or not cloneHum then
		cloneChar:Destroy()
		HienNhanVatThat()
		return false, "Nhân vật mục tiêu bị lỗi!"
	end

	cloneHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	cloneHum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	cloneRoot.CFrame = root.CFrame * CFrame.new(0, myHum.HipHeight - cloneHum.HipHeight, 0)

	local w = Instance.new("WeldConstraint")
	w.Part0 = root; w.Part1 = cloneRoot; w.Parent = root
	cloneChar.Parent = char
	table.insert(Storage.CreatedObjects, cloneChar)

	local syncConn = Connections.AnimationSync
	if syncConn then syncConn:Disconnect() end

	local jumpState = Enum.HumanoidStateType.Jumping
	Connections.AnimationSync = RunService.RenderStepped:Connect(function()
		if myHum and cloneHum and cloneHum.Parent then
			cloneHum:Move(myHum.MoveDirection, false)
			if myHum:GetState() == jumpState then cloneHum.Jump = true end
		else
			Connections.AnimationSync:Disconnect()
			Connections.AnimationSync = nil
		end
	end)

	return true, "Biến hình nhân vật thành công!"
end

function Transform.ToggleOutline(bool)
	State.ShowOutline = bool
	CapNhatOutline()
end

function Transform.SetCharSelect(bool)
	State.CanSelect = bool
	if not bool then State.SelectedPart = nil end
	CapNhatOutline()

	local old = Connections.InputListener
	if old then old:Disconnect(); Connections.InputListener = nil end
	if not bool then return end

	local MB1 = Enum.UserInputType.MouseButton1
	local Touch = Enum.UserInputType.Touch
	local mode = State.CurrentMode

	Connections.InputListener = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		local itype = input.UserInputType
		if itype ~= MB1 and itype ~= Touch then return end

		local mpos = UserInputService:GetMouseLocation()
		local ray = Camera:ViewportPointToRay(mpos.X, mpos.Y)
		SELECT_RAY_PARAMS.FilterDescendantsInstances = { Player.Character }
		local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, SELECT_RAY_PARAMS)
		if not (result and result.Instance) then return end

		local part = result.Instance
		if not part:IsA("BasePart") or part:IsA("Terrain") then return end

		if State.CanMove then
			State.DraggingPart = part
			local upCon
			upCon = UserInputService.InputEnded:Connect(function(ie)
				if ie.UserInputType == MB1 or ie.UserInputType == Touch then
					State.DraggingPart = nil
					upCon:Disconnect()
				end
			end)
		else
			local mdl = part:FindFirstAncestorWhichIsA("Model")
			local isChar = mdl and mdl:FindFirstChild("Humanoid")
			mode = State.CurrentMode
			if mode == "NhanVat" and not isChar then return end
			if (mode == "ToanThan" or mode == "TungPhan") and isChar then return end
			State.SelectedPart = part
			CapNhatOutline()
		end
	end)
end

function Transform.SetCharMove(bool)
	State.CanMove = bool
	State.DraggingPart = nil
	Transform.SetCharSelect(bool or State.CanSelect)
	if bool then BatDauKeoTha()
	else
		local d = Connections.DragListener
		if d then d:Disconnect(); Connections.DragListener = nil end
	end
end

function Transform.CreateDummy()
	if State.CurrentDummy then State.CurrentDummy:Destroy() end
	local char = Player.Character
	local refCF = char and char.HumanoidRootPart and char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5) or CFrame.new()

	local rig = Instance.new("Model"); rig.Name = "Dummy_Mau"
	Instance.new("Humanoid").Parent = rig

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"; root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1; root.Anchored = true; root.CFrame = refCF
	root.Parent = rig

	local head = Instance.new("Part")
	head.Name = "Head"; head.Size = Vector3.new(2, 1, 1)
	head.Color = Color3.fromRGB(255, 255, 0); head.Anchored = true
	head.CFrame = refCF * CFrame.new(0, 1.5, 0); head.Parent = rig

	local torso = Instance.new("Part")
	torso.Name = "Torso"; torso.Size = Vector3.new(2, 2, 1)
	torso.Color = Color3.fromRGB(200, 200, 200); torso.Anchored = true
	torso.CFrame = refCF; torso.Parent = rig

	rig.PrimaryPart = root
	rig.Parent = workspace
	State.CurrentDummy = rig
	State.SelectedPart = torso
	CapNhatOutline()
	return rig
end

function Transform.RemoveCharacter()
	if State.CurrentDummy then
		State.CurrentDummy:Destroy()
		State.CurrentDummy = nil
		State.SelectedPart = nil
		CapNhatOutline()
	end
end

function Transform.SetMode(modeName)
	State.CurrentMode = modeName
	State.SelectedPart = nil
	CapNhatOutline()
end

function Transform.SavePart(partLogicName)
	local sel = State.SelectedPart
	if sel then Storage.SavedParts[partLogicName] = sel:Clone(); return true end
	return false
end

function Transform.ClearPart(partLogicName)
	Storage.SavedParts[partLogicName] = nil
end

function Transform.Undo()
	local objs = Storage.CreatedObjects
	for i = 1, #objs do
		local o = objs[i]
		if o then o:Destroy() end
	end
	table.clear(objs)

	local sync = Connections.AnimationSync
	if sync then sync:Disconnect(); Connections.AnimationSync = nil end

	HienNhanVatThat()

	local char = Player.Character
	local r = char and char:FindFirstChild("HumanoidRootPart")
	if r then TaoHieuUng(r) end
	return "Đã hoàn tác!"
end

function Transform.DoTransform()
	local char = Player.Character
	if not char then return false, "Chưa load nhân vật!" end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return false, "Không tìm thấy RootPart!" end

	if next(Storage.CreatedObjects) then
		Transform.Undo()
		return true, "Đã hoàn tác trạng thái cũ."
	end

	TaoHieuUng(root)

	local mode = State.CurrentMode
	local ok, msg
	if mode == "ToanThan" then ok, msg = BienHinh_ToanThan(char, root)
	elseif mode == "TungPhan" then ok, msg = BienHinh_TungPhan(char)
	elseif mode == "NhanVat" then ok, msg = BienHinh_NhanVat(char, root)
	else msg = "Chế độ không hợp lệ!" end

	if not ok then Transform.Undo() end
	return ok, msg
end

function Transform.ToggleHUD() end
function Transform.SetActive(bool) State.IsActive = bool end

local function OnCharacterAdded(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end
	local d = Connections.DeathListener
	if d then d:Disconnect() end
	Connections.DeathListener = hum.Died:Connect(Transform.Undo)
end

Player.CharacterAdded:Connect(OnCharacterAdded)
if Player.Character then task.spawn(OnCharacterAdded, Player.Character) end

script.Destroying:Connect(function()
	Transform.Undo()
	for k, c in next, Connections do
		if c and typeof(c) == "RBXScriptConnection" then c:Disconnect() end
	end
end)

return Transform
