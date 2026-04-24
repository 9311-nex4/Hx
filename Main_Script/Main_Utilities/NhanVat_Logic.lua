local NhanVat = {}
local State = { CurrentDummy = nil, IsSelecting = false, SelectedModel = nil }

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")
local Camera = workspace.CurrentCamera

local Connections = { Select = nil }

local function CreatePart(name, size, color)
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.Color = color
	p.Anchored = false; p.CanCollide = false
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	return p
end

local function CreateJoint(name, p0, p1, c0, c1)
	local j = Instance.new("Motor6D")
	j.Name = name; j.Part0 = p0; j.Part1 = p1; j.C0 = c0; j.C1 = c1; j.Parent = p0
	return j
end

local function AddAtt(name, parent, pos)
	local a = Instance.new("Attachment")
	a.Name = name
	a.Position = pos
	a.Parent = parent
	return a
end

local function Notify(title, text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {Title = title, Text = text, Duration = 2})
	end)
end

function NhanVat.OpenCustomMenu(targetModel)
	if not targetModel then return end

	local uiName = "Hx_NhanVat_CustomMenu"
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	if PlayerGui:FindFirstChild(uiName) then PlayerGui[uiName]:Destroy() end

	local sg = Instance.new("ScreenGui")
	sg.Name = uiName
	sg.ResetOnSpawn = false
	sg.Parent = PlayerGui

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(0, 300, 0, 400)
	bg.Position = UDim2.new(0.5, 0, 0.5, 0)
	bg.AnchorPoint = Vector2.new(0.5, 0.5)
	bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	bg.BorderSizePixel = 0
	bg.Active = true
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)
	bg.Parent = sg

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 0
	uiScale.Parent = bg

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 40)
	header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	header.BorderSizePixel = 0
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)
	local bottomSquare = Instance.new("Frame")
	bottomSquare.Size = UDim2.new(1, 0, 0.5, 0)
	bottomSquare.Position = UDim2.new(0, 0, 0.5, 0)
	bottomSquare.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	bottomSquare.BorderSizePixel = 0
	bottomSquare.Parent = header
	header.Parent = bg

	local dragInput, dragStart, startPos
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = true
			dragStart = input.Position
			startPos = bg.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			bg.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = false
		end
	end)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -50, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "Custom: " .. targetModel.Name
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -35, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
	closeBtn.Parent = header
	closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

	local inputFrame = Instance.new("Frame")
	inputFrame.Size = UDim2.new(1, -20, 0, 40)
	inputFrame.Position = UDim2.new(0, 10, 0, 50)
	inputFrame.BackgroundTransparency = 1
	inputFrame.Parent = bg

	local idBox = Instance.new("TextBox")
	idBox.Size = UDim2.new(0.7, -5, 1, 0)
	idBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	idBox.PlaceholderText = "Nhập ID Phụ kiện..."
	idBox.Text = ""
	idBox.TextColor3 = Color3.new(1, 1, 1)
	idBox.Font = Enum.Font.Gotham
	idBox.TextSize = 12
	idBox.ClearTextOnFocus = false
	Instance.new("UICorner", idBox).CornerRadius = UDim.new(0, 6)
	idBox.Parent = inputFrame

	local addBtn = Instance.new("TextButton")
	addBtn.Size = UDim2.new(0.3, 0, 1, 0)
	addBtn.Position = UDim2.new(0.7, 5, 0, 0)
	addBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
	addBtn.Text = "Thêm"
	addBtn.TextColor3 = Color3.new(1, 1, 1)
	addBtn.Font = Enum.Font.GothamBold
	addBtn.TextSize = 12
	Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 6)
	addBtn.Parent = inputFrame

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -20, 1, -110)
	scroll.Position = UDim2.new(0, 10, 0, 100)
	scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	scroll.ScrollBarThickness = 4
	scroll.BorderSizePixel = 0
	Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)
	scroll.Parent = bg

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	local function RefreshList()
		for _, v in ipairs(scroll:GetChildren()) do
			if v:IsA("Frame") then v:Destroy() end
		end

		local items = {}
		for _, v in ipairs(targetModel:GetDescendants()) do
			if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") then
				table.insert(items, v)
			end
		end

		for _, item in ipairs(items) do
			local itemFrame = Instance.new("Frame")
			itemFrame.Size = UDim2.new(1, -10, 0, 30)
			itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 4)

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -40, 1, 0)
			lbl.Position = UDim2.new(0, 5, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = item.Name
			lbl.TextColor3 = Color3.new(1, 1, 1)
			lbl.Font = Enum.Font.Gotham
			lbl.TextSize = 12
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.TextTruncate = Enum.TextTruncate.AtEnd
			lbl.Parent = itemFrame

			local delBtn = Instance.new("TextButton")
			delBtn.Size = UDim2.new(0, 25, 0, 25)
			delBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
			delBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
			delBtn.Text = "X"
			delBtn.TextColor3 = Color3.new(1, 1, 1)
			delBtn.Font = Enum.Font.GothamBold
			Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
			delBtn.Parent = itemFrame

			delBtn.MouseButton1Click:Connect(function()
				item:Destroy()
				RefreshList()
			end)

			itemFrame.Parent = scroll
		end
		scroll.CanvasSize = UDim2.new(0, 0, 0, #items * 35)
	end

	addBtn.MouseButton1Click:Connect(function()
		local id = tonumber(idBox.Text:match("%d+"))
		if not id then Notify("Lỗi", "Vui lòng nhập ID hợp lệ!") return end

		addBtn.Text = "..."
		local hum = targetModel:FindFirstChildWhichIsA("Humanoid")
		local result = nil

		local success, info = pcall(function()
			return MarketplaceService:GetProductInfoAsync(id)
		end)

		if success and info then
			local assetTypeId = info.AssetTypeId
			local desc = Instance.new("HumanoidDescription")
			local isValid = true

			if assetTypeId == 8 then desc.HatAccessory = tostring(id)
			elseif assetTypeId == 41 then desc.HairAccessory = tostring(id)
			elseif assetTypeId == 42 then desc.FaceAccessory = tostring(id)
			elseif assetTypeId == 43 then desc.NeckAccessory = tostring(id)
			elseif assetTypeId == 44 then desc.ShouldersAccessory = tostring(id)
			elseif assetTypeId == 45 then desc.FrontAccessory = tostring(id)
			elseif assetTypeId == 46 then desc.BackAccessory = tostring(id)
			elseif assetTypeId == 47 then desc.WaistAccessory = tostring(id)
			elseif assetTypeId == 11 then desc.Shirt = id
			elseif assetTypeId == 12 then desc.Pants = id
			elseif assetTypeId == 2 then desc.GraphicTShirt = id
			else isValid = false end

			if isValid then
				local s, tempModel = pcall(function()
					return Players:CreateHumanoidModelFromDescriptionAsync(desc, Enum.HumanoidRigType.R6)
				end)

				if s and tempModel then
					for _, v in ipairs(tempModel:GetChildren()) do
						if v:IsA("Accessory") or v:IsA("Clothing") or v:IsA("ShirtGraphic") then
							result = v:Clone()
							break
						end
					end
					tempModel:Destroy()
				end
			end
		end

		if not result then
			pcall(function() result = game:GetObjects("rbxassetid://" .. id)[1] end)
		end
		if not result then
			pcall(function() 
				local loaded = InsertService:LoadAsset(id)
				if loaded then result = loaded:GetChildren()[1] end
			end)
		end

		if result then
			local accessory = result

			if accessory:IsA("Model") and accessory.Name == "Model" then
				local realAcc = accessory:FindFirstChildWhichIsA("Accessory") or accessory:FindFirstChildWhichIsA("Accoutrement") or accessory:FindFirstChildWhichIsA("BasePart")
				if realAcc then accessory = realAcc end
			end

			local targetLimb = targetModel:FindFirstChild("Head") or targetModel.PrimaryPart

			if accessory:IsA("Accessory") or accessory:IsA("Accoutrement") then
				for _, p in ipairs(accessory:GetDescendants()) do
					if p:IsA("BasePart") then
						p.Anchored = false
						p.CanCollide = false
					end
				end

				accessory.Parent = targetModel
				if hum then hum:AddAccessory(accessory) end

				task.wait(0.05)

				local handle = accessory:FindFirstChild("Handle")
				if handle and targetLimb then
					local isWelded = false
					for _, connectedPart in ipairs(handle:GetConnectedParts()) do
						if connectedPart:IsDescendantOf(targetModel) and connectedPart ~= handle then
							isWelded = true
							break
						end
					end

					if not isWelded then
						handle.CFrame = targetLimb.CFrame
						local w = Instance.new("WeldConstraint")
						w.Part0 = targetLimb
						w.Part1 = handle
						w.Parent = handle
					end
				end

			elseif accessory:IsA("Shirt") or accessory:IsA("Pants") or accessory:IsA("ShirtGraphic") or accessory:IsA("CharacterMesh") then
				for _, old in ipairs(targetModel:GetChildren()) do
					if old.ClassName == accessory.ClassName then old:Destroy() end
				end
				accessory.Parent = targetModel

			elseif accessory:IsA("BasePart") or accessory:IsA("Model") then
				if targetLimb then
					local parts = accessory:IsA("BasePart") and {accessory} or accessory:GetDescendants()

					if accessory:IsA("Model") then
						accessory:PivotTo(targetLimb.CFrame)
					elseif accessory:IsA("BasePart") then
						accessory.CFrame = targetLimb.CFrame
					end

					for _, p in ipairs(parts) do
						if p:IsA("BasePart") then
							p.Anchored = false
							p.CanCollide = false

							local w = Instance.new("WeldConstraint")
							w.Part0 = targetLimb
							w.Part1 = p
							w.Parent = p
						end
					end
					accessory.Parent = targetModel
				end
			end

			idBox.Text = ""
			RefreshList()
			Notify("Thành công", "Đã gắn thành công!")
		else
			Notify("Lỗi", "Không thể tải ID này (Sai ID hoặc bị khóa)!")
		end

		addBtn.Text = "Thêm"
	end)

	RefreshList()
	TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end

function NhanVat.CreateDummy()
	if State.CurrentDummy then State.CurrentDummy:Destroy() end

	local Player = Players.LocalPlayer
	local char = Player.Character
	local refCF = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5) or CFrame.new(0, 5, -5)

	local rig = Instance.new("Model")
	rig.Name = "Dummy_VIP"

	local hum = Instance.new("Humanoid")
	hum.RigType = Enum.HumanoidRigType.R6
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	hum.Parent = rig

	local skinColor = Color3.fromRGB(253, 234, 141)
	local shirtColor = Color3.fromRGB(13, 105, 172)
	local pantsColor = Color3.fromRGB(40, 127, 71)

	local root = CreatePart("HumanoidRootPart", Vector3.new(2, 2, 1), skinColor)
	root.Transparency = 1; root.Anchored = true; root.Parent = rig

	local torso = CreatePart("Torso", Vector3.new(2, 2, 1), shirtColor); torso.Parent = rig
	local head = CreatePart("Head", Vector3.new(2, 1, 1), skinColor)
	local face = Instance.new("Decal"); face.Name = "face"; face.Texture = "rbxasset://textures/face.png"; face.Parent = head
	local mesh = Instance.new("SpecialMesh"); mesh.MeshType = Enum.MeshType.Head; mesh.Scale = Vector3.new(1.25, 1.25, 1.25); mesh.Parent = head
	head.Parent = rig

	local ra = CreatePart("Right Arm", Vector3.new(1, 2, 1), skinColor); ra.Parent = rig
	local la = CreatePart("Left Arm", Vector3.new(1, 2, 1), skinColor); la.Parent = rig
	local rl = CreatePart("Right Leg", Vector3.new(1, 2, 1), pantsColor); rl.Parent = rig
	local ll = CreatePart("Left Leg", Vector3.new(1, 2, 1), pantsColor); ll.Parent = rig

	CreateJoint("RootJoint", root, torso, CFrame.new(0,0,0, -1,0,0, 0,0,1, 0,1,0), CFrame.new(0,0,0, -1,0,0, 0,0,1, 0,1,0))
	CreateJoint("Neck", torso, head, CFrame.new(0, 1, 0, -1,0,0, 0,0,1, 0,1,0), CFrame.new(0, -0.5, 0, -1,0,0, 0,0,1, 0,1,0))
	CreateJoint("Right Shoulder", torso, ra, CFrame.new(1, 0.5, 0, 0,0,1, 0,1,0, -1,0,0), CFrame.new(-0.5, 0.5, 0, 0,0,1, 0,1,0, -1,0,0))
	CreateJoint("Left Shoulder", torso, la, CFrame.new(-1, 0.5, 0, 0,0,-1, 0,1,0, 1,0,0), CFrame.new(0.5, 0.5, 0, 0,0,-1, 0,1,0, 1,0,0))
	CreateJoint("Right Hip", torso, rl, CFrame.new(1, -1, 0, 0,0,1, 0,1,0, -1,0,0), CFrame.new(0.5, 1, 0, 0,0,1, 0,1,0, -1,0,0))
	CreateJoint("Left Hip", torso, ll, CFrame.new(-1, -1, 0, 0,0,-1, 0,1,0, 1,0,0), CFrame.new(-0.5, 1, 0, 0,0,-1, 0,1,0, 1,0,0))

	AddAtt("HairAttachment", head, Vector3.new(0, 0.6, 0))
	AddAtt("HatAttachment", head, Vector3.new(0, 0.6, 0))
	AddAtt("FaceFrontAttachment", head, Vector3.new(0, 0, -0.6))
	AddAtt("FaceCenterAttachment", head, Vector3.new(0, 0, 0))

	AddAtt("NeckAttachment", torso, Vector3.new(0, 1, 0))
	AddAtt("BodyFrontAttachment", torso, Vector3.new(0, 0, -0.5))
	AddAtt("BodyBackAttachment", torso, Vector3.new(0, 0, 0.5))
	AddAtt("RightCollarAttachment", torso, Vector3.new(1, 1, 0))
	AddAtt("LeftCollarAttachment", torso, Vector3.new(-1, 1, 0))
	AddAtt("WaistFrontAttachment", torso, Vector3.new(0, -1, -0.5))
	AddAtt("WaistBackAttachment", torso, Vector3.new(0, -1, 0.5))
	AddAtt("WaistCenterAttachment", torso, Vector3.new(0, -1, 0))

	rig.PrimaryPart = root
	rig:PivotTo(refCF)
	rig.Parent = workspace
	State.CurrentDummy = rig

	local att = Instance.new("Attachment", root)
	local p = Instance.new("ParticleEmitter", att)
	p.Texture = "rbxassetid://2130129598"
	p.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 0, 255))
	p.Size = NumberSequence.new(0.1, 1); p.Transparency = NumberSequence.new(0, 1)
	p.Speed = NumberRange.new(5, 15); p.Lifetime = NumberRange.new(0.5, 1)
	p.SpreadAngle = Vector2.new(360, 360); p.Rate = 0
	p:Emit(100)
	Debris:AddItem(att, 2)

	local v = Instance.new("NumberValue"); v.Value = 0.01
	v.Changed:Connect(function() if rig and rig.PrimaryPart then rig:ScaleTo(v.Value) end end)
	local tw = TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Value = 1})
	tw:Play()
	tw.Completed:Connect(function() v:Destroy() end)

	return rig
end

function NhanVat.RemoveDummy()
	if State.CurrentDummy then
		local dummy = State.CurrentDummy
		State.CurrentDummy = nil
		if dummy.PrimaryPart then
			local att = Instance.new("Attachment", workspace.Terrain)
			att.WorldCFrame = dummy.PrimaryPart.CFrame
			local p = Instance.new("ParticleEmitter", att)
			p.Texture = "rbxassetid://2130129598"; p.Color = ColorSequence.new(Color3.fromRGB(255, 50, 50))
			p.Size = NumberSequence.new(0.1, 1.5); p.Speed = NumberRange.new(10, 20)
			p.SpreadAngle = Vector2.new(360, 360); p.Rate = 0
			p:Emit(150)
			Debris:AddItem(att, 1)
		end
		local v = Instance.new("NumberValue"); v.Value = 1
		v.Changed:Connect(function() if dummy and dummy.PrimaryPart then dummy:ScaleTo(v.Value) end end)
		local tw = TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Value = 0.01})
		tw:Play()
		tw.Completed:Connect(function() v:Destroy(); dummy:Destroy() end)
	end
end

function NhanVat.ToggleSelectMode(isON)
	State.IsSelecting = isON
	if Connections.Select then Connections.Select:Disconnect(); Connections.Select = nil end

	if State.IsSelecting then
		Connections.Select = UserInputService.InputBegan:Connect(function(input, proc)
			if proc then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local mpos = UserInputService:GetMouseLocation()
				local ray = Camera:ViewportPointToRay(mpos.X, mpos.Y)
				local p = RaycastParams.new()
				p.FilterType = Enum.RaycastFilterType.Exclude
				p.FilterDescendantsInstances = {Players.LocalPlayer.Character}
				local res = workspace:Raycast(ray.Origin, ray.Direction*1000, p)

				if res and res.Instance then
					local model = res.Instance:FindFirstAncestorWhichIsA("Model")
					if model and model:FindFirstChildWhichIsA("Humanoid") then
						State.SelectedModel = model
						Notify("Hx Script", "Đã quét thành công: " .. model.Name)
					end
				end
			end
		end)
	end
end

function NhanVat.GetDummy() return State.CurrentDummy end
function NhanVat.GetSelectedModel() return State.SelectedModel end
function NhanVat.ClearSelectedModel() State.SelectedModel = nil end

return NhanVat
