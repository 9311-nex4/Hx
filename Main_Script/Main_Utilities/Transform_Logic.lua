local Transform = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = Player:WaitForChild("PlayerGui")

local State = {
	IsActive = false,
	CanSelect_Main = false,
	CanSelect_Char = false,
	CanMove = false,
	ShowOutline = true,
	CurrentMode = "ToanThan",
	SelectedPart = nil,
	DraggingPart = nil,
	EnabledParts = {
		Head = false, Torso = false, RightArm = false, LeftArm = false, RightLeg = false, LeftLeg = false
	}
}

local Storage = {
	SavedParts = {},
	CreatedObjects = {},
	OrigTransparency = {},
	OrigCollision = {}
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

local SELECT_RAY_PARAMS = RaycastParams.new()
SELECT_RAY_PARAMS.FilterType = Enum.RaycastFilterType.Exclude

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
	p.SpreadAngle = Vector2.new(360, 360)
	p.Rate = 0
	p.Parent = att
	p:Emit(50)
	Debris:AddItem(att, 2)
end

local function CapNhatOutline()
	local old = PlayerGui:FindFirstChild("TransformSelectionBox")
	if old then old:Destroy() end
	local sel = State.SelectedPart
	if sel and not sel:IsDescendantOf(workspace) then
		State.SelectedPart = nil
		sel = nil
	end
	local modeValid = (State.CurrentMode == "NhanVat" and State.CanSelect_Char) or (State.CurrentMode ~= "NhanVat" and State.CanSelect_Main)
	if State.ShowOutline and sel and modeValid then
		local box = Instance.new("SelectionBox")
		box.Name = "TransformSelectionBox"
		box.Color3 = SEL_COLOR
		box.LineThickness = 0.05
		if State.CurrentMode == "NhanVat" then
			box.Adornee = sel:FindFirstAncestorWhichIsA("Model") or sel
		else
			box.Adornee = sel
		end
		box.Parent = PlayerGui
	end
end

local function LuuTrangThai(char)
	table.clear(Storage.OrigTransparency)
	table.clear(Storage.OrigCollision)
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			Storage.OrigTransparency[v] = v.Transparency
			Storage.OrigCollision[v] = v.CanCollide
		elseif v:IsA("Decal") or v:IsA("Texture") then
			Storage.OrigTransparency[v] = v.Transparency
		end
	end
end

local function AnToanThan(char)
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = 1
			v.CanCollide = false
		elseif v:IsA("Decal") or v:IsA("Texture") then
			v.Transparency = 1
		end
	end
end

local function AnBoPhan(char, logicName)
	local realList = PART_MAP[logicName]
	if not realList then return end
	for _, realName in ipairs(realList) do
		local c = char:FindFirstChild(realName)
		if c then
			c.Transparency = 1
			c.CanCollide = false
			for _, d in ipairs(c:GetDescendants()) do
				if d:IsA("BasePart") then
					d.Transparency = 1
					d.CanCollide = false
				elseif d:IsA("Decal") or d:IsA("Texture") then
					d.Transparency = 1
				end
			end
		end
	end
end

local function HienNhanVatThat()
	for obj, t in next, Storage.OrigTransparency do
		if obj and obj.Parent then pcall(function() obj.Transparency = t end) end
	end
	for obj, c in next, Storage.OrigCollision do
		if obj and obj.Parent then pcall(function() obj.CanCollide = c end) end
	end
	table.clear(Storage.OrigTransparency)
	table.clear(Storage.OrigCollision)
end

function Transform.Undo()
	if Connections.AnimationSync then 
		Connections.AnimationSync:Disconnect() 
		Connections.AnimationSync = nil 
	end
	HienNhanVatThat()
	for _, obj in pairs(Storage.CreatedObjects) do
		if obj then obj:Destroy() end
	end
	table.clear(Storage.CreatedObjects)
	local char = Player.Character
	if char then
		local r = char:FindFirstChild("HumanoidRootPart")
		if r then TaoHieuUng(r) end
	end
	return "Đã hoàn tác!"
end

local function BienHinh_ToanThan(char, root)
	local sel = State.SelectedPart
	if not sel or not sel:IsDescendantOf(workspace) then return false, "Chưa chọn Part hoặc Part đã biến mất!" end
	LuuTrangThai(char)
	AnToanThan(char)
	local clone = sel:Clone()
	clone.Name = "Morph_FullBody"
	clone.Anchored = false
	clone.CanCollide = false
	clone.Massless = true
	local orientationGoc = sel.CFrame - sel.CFrame.Position
	clone.CFrame = CFrame.new(root.CFrame.Position) * orientationGoc
	local w = Instance.new("WeldConstraint")
	w.Part0 = root; w.Part1 = clone; w.Parent = clone
	clone.Parent = char
	table.insert(Storage.CreatedObjects, clone)
	return true, "Biến hình toàn thân thành công!"
end

local function BienHinh_TungPhan(char)
	local hasPart = false
	local sel = State.SelectedPart
	local coBoPhanNaoDuocBat = false
	for _, isOn in pairs(State.EnabledParts) do
		if isOn then coBoPhanNaoDuocBat = true; break end
	end
	if not coBoPhanNaoDuocBat then
		return false, "Bạn phải bật ít nhất 1 bộ phận để biến hình Từng Phần!"
	end
	LuuTrangThai(char)
	for logicName, realList in next, PART_MAP do
		if State.EnabledParts[logicName] then
			local partDeBienHinh = Storage.SavedParts[logicName] or sel
			if partDeBienHinh and partDeBienHinh:IsDescendantOf(workspace) then
				local target
				for _, realName in ipairs(realList) do
					local c = char:FindFirstChild(realName)
					if c and c:IsA("BasePart") then target = c; break end
				end
				if target then
					hasPart = true
					local clone = partDeBienHinh:Clone()
					clone.Name = "Morph_" .. logicName
					clone.Anchored = false
					clone.CanCollide = false
					clone.Massless = true
					local orientationGoc = partDeBienHinh.CFrame - partDeBienHinh.CFrame.Position
					clone.CFrame = CFrame.new(target.CFrame.Position) * orientationGoc
					local w = Instance.new("WeldConstraint")
					w.Part0 = target; w.Part1 = clone; w.Parent = clone
					clone.Parent = char
					table.insert(Storage.CreatedObjects, clone)
					AnBoPhan(char, logicName)
				end
			end
		end
	end
	if not hasPart then 
		HienNhanVatThat()
		return false, "Chưa có Part hợp lệ nào được chọn!" 
	end
	return true, "Biến hình từng phần thành công!"
end

local function BienHinh_NhanVat(char, root)
	local sel = State.SelectedPart
	if not sel or not sel:IsDescendantOf(workspace) then return false, "Mục tiêu không hợp lệ hoặc đã chết!" end
	local targetModel = sel:FindFirstAncestorWhichIsA("Model")
	if not targetModel or not targetModel:FindFirstChildWhichIsA("Humanoid") then
		return false, "Đối tượng chọn không phải là Nhân Vật!"
	end
	if targetModel == char then return false, "Không thể biến thành chính mình!" end
	local myHum = char:FindFirstChildWhichIsA("Humanoid")
	if not myHum then return false, "Lỗi: Không tìm thấy Humanoid của bạn!" end

	LuuTrangThai(char)
	AnToanThan(char)

	targetModel.Archivable = true
	local cloneChar = targetModel:Clone()
	cloneChar.Name = "Morph_Character"

	local cloneRoot = cloneChar:FindFirstChild("HumanoidRootPart")
	local cloneHum = cloneChar:FindFirstChildWhichIsA("Humanoid")

	if not cloneRoot or not cloneHum then
		cloneChar:Destroy()
		HienNhanVatThat()
		return false, "Nhân vật mục tiêu bị lỗi (Thiếu Root/Humanoid)!"
	end

	cloneHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	cloneHum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	cloneHum.NameDisplayDistance = 0

	pcall(function()
		local myDesc = myHum:GetAppliedDescription()
		local cloneDesc = cloneHum:GetAppliedDescription()
		cloneDesc.BodyDepthScale = myDesc.BodyDepthScale
		cloneDesc.BodyHeightScale = myDesc.BodyHeightScale
		cloneDesc.BodyWidthScale = myDesc.BodyWidthScale
		cloneDesc.HeadScale = myDesc.HeadScale
		cloneHum:ApplyDescription(cloneDesc)
	end)

	task.wait()
	local yOffset = 0
	pcall(function() 
		yOffset = (cloneHum.HipHeight - myHum.HipHeight) + (cloneRoot.Size.Y - root.Size.Y) / 2 
	end)

	for _, v in ipairs(cloneChar:GetDescendants()) do
		if v:IsA("Script") or v:IsA("LocalScript") then
			v:Destroy()
		elseif v:IsA("BasePart") then
			v.CanCollide = false
			v.Massless = true
			v.Anchored = false
		end
	end

	cloneRoot.CFrame = root.CFrame * CFrame.new(0, yOffset, 0)

	local w = Instance.new("WeldConstraint")
	w.Part0 = root; w.Part1 = cloneRoot; w.Parent = cloneRoot
	cloneChar.Parent = char
	table.insert(Storage.CreatedObjects, cloneChar)

	cloneHum.PlatformStand = true

	local cloneAnimator = cloneHum:FindFirstChildOfClass("Animator") or Instance.new("Animator", cloneHum)
	local targetAnims = {}
	local loadedTracks = {}
	
	local animateScript = targetModel:FindFirstChild("Animate")
	if animateScript then
		for _, child in ipairs(animateScript:GetChildren()) do
			local anim = child:FindFirstChildWhichIsA("Animation")
			if anim then
				targetAnims[string.lower(child.Name)] = anim
			end
		end
	end

	local currentAnimState = nil
	local currentTrack = nil

	if Connections.AnimationSync then Connections.AnimationSync:Disconnect() end
	Connections.AnimationSync = RunService.RenderStepped:Connect(function()
		if myHum and cloneHum and cloneHum.Parent and root and cloneAnimator then
			local speed = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z).Magnitude
			local state = myHum:GetState()

			local desiredState = "idle"
			if state == Enum.HumanoidStateType.Jumping then desiredState = "jump"
			elseif state == Enum.HumanoidStateType.Freefall then desiredState = "fall"
			elseif speed > 0.5 then desiredState = "walk"
			end

			if desiredState ~= currentAnimState then
				if currentTrack then currentTrack:Stop(0.2) end
				currentAnimState = desiredState

				local animToPlay = targetAnims[desiredState]
				if desiredState == "walk" and not animToPlay then
					animToPlay = targetAnims["run"] 
				end

				if animToPlay then
					if not loadedTracks[animToPlay] then
						loadedTracks[animToPlay] = cloneAnimator:LoadAnimation(animToPlay)
					end
					currentTrack = loadedTracks[animToPlay]
					currentTrack:Play(0.2)
				end
			end

			if desiredState == "walk" and currentTrack then
				currentTrack:AdjustSpeed(math.clamp(speed / 16, 0.1, 2))
			end
		else
			if Connections.AnimationSync then Connections.AnimationSync:Disconnect() end
			if currentTrack then currentTrack:Stop() end
			for _, track in pairs(loadedTracks) do track:Stop() end
			table.clear(loadedTracks)
		end
	end)

	return true, "Biến hình nhân vật thành công!"
end

function Transform.ToggleOutline(bool)
	State.ShowOutline = bool
	CapNhatOutline()
end

function Transform.SetPartEnabled(logicName, bool)
	State.EnabledParts[logicName] = bool
end

function Transform.SetCharSelect(bool)
	State.CanSelect_Char = bool
	if not bool and State.CurrentMode == "NhanVat" then State.SelectedPart = nil end
	CapNhatOutline()
end

local function SetupInputListener()
	if Connections.InputListener then return end
	Connections.InputListener = UserInputService.InputBegan:Connect(function(input, processed)
		if processed or not State.IsActive then return end
		local itype = input.UserInputType
		if itype ~= Enum.UserInputType.MouseButton1 and itype ~= Enum.UserInputType.Touch then return end
		local mode = State.CurrentMode
		if mode == "NhanVat" and not State.CanSelect_Char then return end
		if (mode == "ToanThan" or mode == "TungPhan") and not State.CanSelect_Main then return end
		local mpos = UserInputService:GetMouseLocation()
		local ray = Camera:ViewportPointToRay(mpos.X, mpos.Y)
		local filterList = {Player.Character}
		local oldBox = PlayerGui:FindFirstChild("TransformSelectionBox")
		if oldBox then table.insert(filterList, oldBox) end
		SELECT_RAY_PARAMS.FilterDescendantsInstances = filterList
		local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, SELECT_RAY_PARAMS)
		if result and result.Instance then
			local part = result.Instance
			if not part:IsA("BasePart") or part:IsA("Terrain") then return end
			local isChar = part:FindFirstAncestorWhichIsA("Model") and part:FindFirstAncestorWhichIsA("Model"):FindFirstChildWhichIsA("Humanoid")
			if mode == "NhanVat" and not isChar then return end
			if (mode == "ToanThan" or mode == "TungPhan") and isChar then return end
			State.SelectedPart = isChar and part:FindFirstAncestorWhichIsA("Model").PrimaryPart or part
			CapNhatOutline()
		end
	end)
end

function Transform.SetMode(modeName)
	State.CurrentMode = modeName
	State.SelectedPart = nil
	CapNhatOutline()
end

function Transform.SavePart(partLogicName)
	local sel = State.SelectedPart
	if sel and sel:IsDescendantOf(workspace) then 
		Storage.SavedParts[partLogicName] = sel:Clone()
		return true 
	end
	return false
end

function Transform.ClearPart(partLogicName)
	Storage.SavedParts[partLogicName] = nil
end

function Transform.DoTransform()
	if not State.IsActive then return false, "Chức năng Transform đang TẮT!" end
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

function Transform.SetActive(bool) 
	State.IsActive = bool 
	State.CanSelect_Main = bool 
	if bool then SetupInputListener() end
	if not bool then 
		Transform.Undo()
		State.SelectedPart = nil
		CapNhatOutline()
	end
end

local function OnCharacterAdded(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end
	if Connections.DeathListener then Connections.DeathListener:Disconnect() end
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
