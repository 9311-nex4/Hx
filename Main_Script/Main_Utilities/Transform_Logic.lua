local Transform = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

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
	OriginalTransparencies = {},
	OriginalCollisions = {},
}

local Connections = {
	AnimationSync = nil,
	InputListener = nil,
	DragListener = nil,
	DeathListener = nil
}

local ASSET_HAT = "rbxassetid://2130129598"
local SELECTION_COLOR = Color3.fromRGB(0, 255, 0)
local DRAG_SPEED = 20 

local PART_MAP = {
	Head = { "Head" },
	Torso = { "Torso", "UpperTorso", "LowerTorso" },
	RightArm = { "Right Arm", "RightUpperArm", "RightLowerArm", "RightHand" },
	LeftArm = { "Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand" },
	RightLeg = { "Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot" },
	LeftLeg = { "Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" }
}

local function TaoHieuUng(part)
	if not part then return end
	local attachment = Instance.new("Attachment")
	attachment.Parent = part

	local particle = Instance.new("ParticleEmitter")
	particle.Texture = ASSET_HAT
	particle.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 85, 255))
	particle.Size = NumberSequence.new(0.1, 0.5, 0.1)
	particle.Transparency = NumberSequence.new(0, 1)
	particle.Lifetime = NumberRange.new(0.5, 1)
	particle.Speed = NumberRange.new(2, 5)
	particle.Rate = 0
	particle.Parent = attachment

	particle:Emit(50)
	Debris:AddItem(attachment, 2)
end

local function CapNhatOutline()
	local oldBox = Player.PlayerGui:FindFirstChild("TransformSelectionBox")
	if oldBox then oldBox:Destroy() end

	if State.ShowOutline and State.SelectedPart then
		local box = Instance.new("SelectionBox")
		box.Name = "TransformSelectionBox"
		box.Color3 = SELECTION_COLOR
		box.LineThickness = 0.05
		box.Adornee = State.SelectedPart
		box.Parent = Player.PlayerGui
	end
end

local function AnNhanVatThat()
	local char = Player.Character
	if not char then return end

	Storage.OriginalTransparencies = {}
	Storage.OriginalCollisions = {}

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			Storage.OriginalTransparencies[v] = v.Transparency
			Storage.OriginalCollisions[v] = v.CanCollide
			v.Transparency = 1
			v.CanCollide = false
		elseif v:IsA("Decal") or v:IsA("Texture") then
			Storage.OriginalTransparencies[v] = v.Transparency
			v.Transparency = 1
		end
	end
end

local function HienNhanVatThat()
	for obj, trans in pairs(Storage.OriginalTransparencies) do
		if obj and obj.Parent then pcall(function() obj.Transparency = trans end) end
	end
	for obj, collide in pairs(Storage.OriginalCollisions) do
		if obj and obj.Parent then pcall(function() obj.CanCollide = collide end) end
	end
	Storage.OriginalTransparencies = {}
	Storage.OriginalCollisions = {}
end

local function BatDauKeoTha()
	if Connections.DragListener then Connections.DragListener:Disconnect() end

	Connections.DragListener = RunService.RenderStepped:Connect(function()
		if State.CanMove and State.DraggingPart and State.DraggingPart.Parent then
			local mouseRay = Mouse.UnitRay
			local targetPos = mouseRay.Origin + (mouseRay.Direction * 20)

			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = {State.DraggingPart, Player.Character}
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist

			local rayResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 100, rayParams)
			if rayResult then
				targetPos = rayResult.Position + Vector3.new(0, State.DraggingPart.Size.Y/2, 0)
			end

			local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
			TweenService:Create(State.DraggingPart, tweenInfo, {Position = targetPos}):Play()
			State.DraggingPart.Anchored = true
		end
	end)
end

local function BienHinh_ToanThan(char, root)
	if not State.SelectedPart then return false, "Chưa chọn Part!" end

	AnNhanVatThat()

	local clone = State.SelectedPart:Clone()
	clone.Name = "Morph_FullBody"
	clone.Anchored = false
	clone.CanCollide = false
	clone.Massless = true
	clone.CFrame = root.CFrame

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = clone
	weld.Parent = root

	clone.Parent = char
	table.insert(Storage.CreatedObjects, clone)
	return true, "Biến hình toàn thân thành công!"
end

local function BienHinh_TungPhan(char)
	local hasPart = false
	AnNhanVatThat() 

	for logicName, realPartsList in pairs(PART_MAP) do
		local sourcePart = Storage.SavedParts[logicName]

		if sourcePart then
			hasPart = true
			local realPartTarget = nil
			for _, name in ipairs(realPartsList) do
				if char:FindFirstChild(name) then
					realPartTarget = char[name]
					break
				end
			end

			if realPartTarget then
				local clone = sourcePart:Clone()
				clone.Name = "Morph_" .. logicName
				clone.Anchored = false
				clone.CanCollide = false
				clone.Massless = true
				clone.CFrame = realPartTarget.CFrame

				local weld = Instance.new("WeldConstraint")
				weld.Part0 = realPartTarget
				weld.Part1 = clone
				weld.Parent = realPartTarget

				clone.Parent = char
				table.insert(Storage.CreatedObjects, clone)
			end
		end
	end

	if not hasPart then
		HienNhanVatThat()
		return false, "Chưa lưu trữ bộ phận nào!"
	end
	return true, "Biến hình từng phần thành công!"
end

local function BienHinh_NhanVat(char, root)
	local targetModel = State.SelectedPart and State.SelectedPart:FindFirstAncestorWhichIsA("Model")

	if not targetModel or not targetModel:FindFirstChild("Humanoid") then
		return false, "Đối tượng chọn không phải là Nhân Vật!"
	end

	if targetModel == char then return false, "Không thể biến thành chính mình!" end

	local targetHum = targetModel:FindFirstChild("Humanoid")
	local myHum = char:FindFirstChild("Humanoid")

	AnNhanVatThat()

	targetModel.Archivable = true
	local cloneChar = targetModel:Clone()
	cloneChar.Name = "Morph_Character"

	for _, v in ipairs(cloneChar:GetDescendants()) do
		if v:IsA("Script") or v:IsA("LocalScript") and v.Name ~= "Animate" then
			v:Destroy()
		end
		if v:IsA("BasePart") then
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

	local hipHeightDiff = (myHum.HipHeight - cloneHum.HipHeight)
	cloneRoot.CFrame = root.CFrame * CFrame.new(0, hipHeightDiff, 0)

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = cloneRoot
	weld.Parent = root

	cloneChar.Parent = char
	table.insert(Storage.CreatedObjects, cloneChar)

	if Connections.AnimationSync then Connections.AnimationSync:Disconnect() end
	Connections.AnimationSync = RunService.RenderStepped:Connect(function()
		if myHum and cloneHum and cloneHum.Parent then
			cloneHum:Move(myHum.MoveDirection, false)
			if myHum:GetState() == Enum.HumanoidStateType.Jumping then
				cloneHum.Jump = true
			end
		else
			if Connections.AnimationSync then Connections.AnimationSync:Disconnect() end
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

	if Connections.InputListener then Connections.InputListener:Disconnect() end

	if bool then
		Connections.InputListener = UserInputService.InputBegan:Connect(function(input, processed)
			if processed then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local mousePos = UserInputService:GetMouseLocation()
				local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Blacklist
				params.FilterDescendantsInstances = {Player.Character}

				local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
				if result and result.Instance then
					local part = result.Instance
					if part:IsA("BasePart") and not part:IsA("Terrain") then
						if State.CanMove then
							State.DraggingPart = part
							local upCon
							upCon = UserInputService.InputEnded:Connect(function(inputEnd)
								if inputEnd.UserInputType == Enum.UserInputType.MouseButton1 or inputEnd.UserInputType == Enum.UserInputType.Touch then
									State.DraggingPart = nil
									upCon:Disconnect()
								end
							end)
						else
							local model = part:FindFirstAncestorWhichIsA("Model")
							local isChar = model and model:FindFirstChild("Humanoid")

							if State.CurrentMode == "NhanVat" and not isChar then return end
							if (State.CurrentMode == "ToanThan" or State.CurrentMode == "TungPhan") and isChar then return end

							State.SelectedPart = part
							CapNhatOutline()
						end
					end
				end
			end
		end)
	end
end

function Transform.SetCharMove(bool)
	State.CanMove = bool
	State.DraggingPart = nil
	Transform.SetCharSelect(bool or State.CanSelect)

	if bool then
		BatDauKeoTha()
	else
		if Connections.DragListener then Connections.DragListener:Disconnect() end
	end
end

function Transform.CreateDummy()
	if State.CurrentDummy then State.CurrentDummy:Destroy() end

	local rig = Instance.new("Model")
	rig.Name = "Dummy_Mau"

	local hum = Instance.new("Humanoid")
	hum.Parent = rig

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1
	root.Anchored = true
	root.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
	root.Parent = rig

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2, 1, 1)
	head.Color = Color3.fromRGB(255, 255, 0)
	head.Anchored = true
	head.CFrame = root.CFrame * CFrame.new(0, 1.5, 0)
	head.Parent = rig

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Color = Color3.fromRGB(200, 200, 200)
	torso.Anchored = true
	torso.CFrame = root.CFrame
	torso.Parent = rig

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
	if State.SelectedPart then
		Storage.SavedParts[partLogicName] = State.SelectedPart:Clone()
		return true
	end
	return false
end

function Transform.ClearPart(partLogicName)
	Storage.SavedParts[partLogicName] = nil
end

function Transform.Undo()
	for _, obj in ipairs(Storage.CreatedObjects) do
		if obj then obj:Destroy() end
	end
	Storage.CreatedObjects = {}

	if Connections.AnimationSync then
		Connections.AnimationSync:Disconnect()
		Connections.AnimationSync = nil
	end

	HienNhanVatThat()

	if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
		TaoHieuUng(Player.Character.HumanoidRootPart)
	end

	return "Đã hoàn tác!"
end

function Transform.DoTransform()
	local char = Player.Character
	if not char then return false, "Chưa load nhân vật!" end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return false, "Không tìm thấy RootPart!" end

	if #Storage.CreatedObjects > 0 then
		Transform.Undo()
		return true, "Đã hoàn tác trạng thái cũ."
	end

	TaoHieuUng(root)

	local success, msg = false, ""

	if State.CurrentMode == "ToanThan" then
		success, msg = BienHinh_ToanThan(char, root)
	elseif State.CurrentMode == "TungPhan" then
		success, msg = BienHinh_TungPhan(char)
	elseif State.CurrentMode == "NhanVat" then
		success, msg = BienHinh_NhanVat(char, root)
	else
		msg = "Chế độ không hợp lệ!"
	end

	if not success then
		Transform.Undo()
	end

	return success, msg
end

function Transform.ToggleHUD(bool) end
function Transform.SetActive(bool) State.IsActive = bool end

local function OnCharacterAdded(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if hum then
		if Connections.DeathListener then Connections.DeathListener:Disconnect() end
		Connections.DeathListener = hum.Died:Connect(function()
			Transform.Undo()
		end)
	end
end

Player.CharacterAdded:Connect(OnCharacterAdded)
if Player.Character then OnCharacterAdded(Player.Character) end

script.Destroying:Connect(function()
	Transform.Undo()
	if Connections.InputListener then Connections.InputListener:Disconnect() end
	if Connections.DragListener then Connections.DragListener:Disconnect() end
end)

return Transform