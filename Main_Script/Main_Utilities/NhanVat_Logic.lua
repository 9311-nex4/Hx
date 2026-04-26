local NhanVat = {}
local State = {
	CurrentDummy = nil,
	IsSelecting = false,
	SelectedModel = nil,
	Highlights = {},
	AnimTrack = nil,
	CurrentScale = 1,
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Connections = { Select = nil, Spin = nil, Follow = nil }
local GuiThongBao = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/ThongBao.lua"))()

local AnimCache = setmetatable({}, {__mode = "k"})
local R6Anims = { Idle = 180435571, Walk = 180426354, Jump = 125750702, Fall = 180436148 }
local R15Anims = { Idle = 507766388, Walk = 507777826, Jump = 507765000, Fall = 507767968 }

local bodyPartsMapping = {
	Head = {"Head"},
	Torso = {"Torso", "UpperTorso", "LowerTorso"},
	["Right Arm"] = {"Right Arm", "RightUpperArm", "RightLowerArm", "RightHand"},
	["Left Arm"] = {"Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand"},
	["Right Leg"] = {"Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"},
	["Left Leg"] = {"Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot"}
}

local C = {
	Nen = Color3.fromRGB(15, 15, 15),
	NenList = Color3.fromRGB(25, 25, 25),
	NenKhoi = Color3.fromRGB(32, 32, 32),
	NenMuc = Color3.fromRGB(50, 50, 50),
	NenHop = Color3.fromRGB(15, 15, 15),
	NenDanhSachMo = Color3.fromRGB(65, 70, 75),
	VienHop = Color3.fromRGB(80, 80, 80),
	VienNeon = Color3.fromRGB(255, 255, 255),
	NenPhu = Color3.fromRGB(45, 45, 45),
	ChonPhu = Color3.fromRGB(60, 60, 60),
	TichBat = Color3.fromRGB(255, 255, 255),
	NutDong = Color3.fromRGB(80, 80, 80),
	NutDongLuot = Color3.fromRGB(200, 0, 0),
	Chu = Color3.fromRGB(240, 240, 240),
	ChuMo = Color3.fromRGB(180, 180, 180),
	Vang = Color3.fromRGB(255, 200, 50)
}

local function ThongBao(title, text)
	GuiThongBao.thongbao("Hx Script | " .. title, text, 3)
end

local function ThongBaoLoi(title, text)
	GuiThongBao.thongbaoloi("Hx Script | " .. title, text)
end

local function Tween(obj, t, style, dir, props)
	style = style or Enum.EasingStyle.Quint
	dir = dir or Enum.EasingDirection.Out
	return TweenService:Create(obj, TweenInfo.new(t, style, dir), props)
end

local function Corner(parent, rad)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, rad or 8)
	c.Parent = parent
	return c
end

local function Stroke(parent, color, transparency, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or C.VienNeon
	s.Transparency = transparency or 0.6
	s.Thickness = thickness or 1
	s.Parent = parent
	return s
end

local function Padding(parent, left, right, top, bottom)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, left)
	p.PaddingRight = UDim.new(0, right or left)
	p.PaddingTop = UDim.new(0, top or left)
	p.PaddingBottom = UDim.new(0, bottom or left)
	p.Parent = parent
	return p
end

local function MakeBtn(parent, text, bgColor, size, pos)
	local b = Instance.new("TextButton")
	b.Size = size or UDim2.new(1,0,0,32)
	b.Position = pos or UDim2.new(0,0,0,0)
	b.BackgroundColor3 = bgColor or C.NenMuc
	b.Text = text
	b.TextColor3 = C.Chu
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 12
	b.AutoButtonColor = false
	b.Parent = parent
	Corner(b, 6)

	b.MouseEnter:Connect(function()
		local hover = bgColor and bgColor:Lerp(Color3.new(1,1,1), 0.1) or C.NenMuc:Lerp(Color3.new(1,1,1), 0.1)
		Tween(b, 0.15, nil, nil, {BackgroundColor3 = hover}):Play()
	end)
	b.MouseLeave:Connect(function()
		Tween(b, 0.15, nil, nil, {BackgroundColor3 = bgColor or C.NenMuc}):Play()
	end)
	return b
end

local function Ripple(btn)
	btn.MouseButton1Click:Connect(function()
		local circle = Instance.new("Frame")
		circle.Size = UDim2.new(0,0,0,0)
		circle.AnchorPoint = Vector2.new(0.5,0.5)
		circle.Position = UDim2.new(0.5,0,0.5,0)
		circle.BackgroundColor3 = Color3.new(1,1,1)
		circle.BackgroundTransparency = 0.7
		circle.ZIndex = btn.ZIndex + 1
		Corner(circle, 999)
		circle.Parent = btn
		Tween(circle, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			Size = UDim2.new(2,0,2,0), BackgroundTransparency = 1
		}):Play()
		task.delay(0.4, function() circle:Destroy() end)
	end)
end

local function PlayStateAnim(model, state)
	if not AnimCache[model] then AnimCache[model] = { tracks = {}, current = nil } end
	local cache = AnimCache[model]
	if cache.current == state then return end
	cache.current = state

	local hum = model:FindFirstChildWhichIsA("Humanoid")
	if not hum then return end
	local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
	local isR15 = hum.RigType == Enum.HumanoidRigType.R15
	local anims = isR15 and R15Anims or R6Anims

	for name, track in pairs(cache.tracks) do
		if name ~= state then track:Stop(0.2) end
	end

	if not cache.tracks[state] and anims[state] then
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. anims[state]
		cache.tracks[state] = animator:LoadAnimation(anim)
	end
	if cache.tracks[state] then cache.tracks[state]:Play(0.2) end
end

local function CreatePart(name, size, color)
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.Color = color
	p.Anchored = false; p.CanCollide = false
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	return p
end

local function CreateJoint(name, p0, p1, c0, c1)
	local j = Instance.new("Motor6D")
	j.Name = name; j.Part0 = p0; j.Part1 = p1
	j.C0 = c0; j.C1 = c1; j.Parent = p0
	return j
end

local function AddAtt(name, parent, pos)
	local a = Instance.new("Attachment")
	a.Name = name; a.Position = pos; a.Parent = parent
	return a
end

function NhanVat.CreateDummy()
	if State.CurrentDummy then State.CurrentDummy:Destroy() end

	local char = LocalPlayer.Character
	local refCF = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.CFrame * CFrame.new(0,0,-6) or CFrame.new(0,5,-6)

	local rigType = Enum.HumanoidRigType.R15
	if char then
		local hum = char:FindFirstChildWhichIsA("Humanoid")
		if hum then rigType = hum.RigType end
	end

	local desc = Instance.new("HumanoidDescription")
	local skin = Color3.fromRGB(253,234,141)
	local shirt = Color3.fromRGB(13,105,172)
	local pants = Color3.fromRGB(40,127,71)

	desc.HeadColor = skin
	desc.LeftArmColor = skin
	desc.RightArmColor = skin
	desc.LeftLegColor = pants
	desc.RightLegColor = pants
	desc.TorsoColor = shirt

	local ok, rig = pcall(function() return Players:CreateHumanoidModelFromDescriptionAsync(desc, rigType) end)

	if not ok or not rig then
		rig = Instance.new("Model")
		local hum = Instance.new("Humanoid")
		hum.RigType = Enum.HumanoidRigType.R6
		hum.Parent = rig

		local root = CreatePart("HumanoidRootPart", Vector3.new(2,2,1), skin)
		root.Transparency = 1; root.Parent = rig
		local torso = CreatePart("Torso", Vector3.new(2,2,1), shirt); torso.Parent = rig
		local head = CreatePart("Head", Vector3.new(2,1,1), skin)
		local face = Instance.new("Decal")
		face.Name = "face"; face.Texture = "rbxasset://textures/face.png"; face.Parent = head
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Head; mesh.Scale = Vector3.new(1.25,1.25,1.25); mesh.Parent = head
		head.Parent = rig

		local ra = CreatePart("Right Arm", Vector3.new(1,2,1), skin); ra.Parent = rig
		local la = CreatePart("Left Arm", Vector3.new(1,2,1), skin); la.Parent = rig
		local rl = CreatePart("Right Leg", Vector3.new(1,2,1), pants); rl.Parent = rig
		local ll = CreatePart("Left Leg", Vector3.new(1,2,1), pants); ll.Parent = rig

		CreateJoint("RootJoint", root, torso, CFrame.new(0,0,0,-1,0,0,0,0,1,0,1,0), CFrame.new(0,0,0,-1,0,0,0,0,1,0,1,0))
		CreateJoint("Neck", torso, head, CFrame.new(0,1,0,-1,0,0,0,0,1,0,1,0), CFrame.new(0,-0.5,0,-1,0,0,0,0,1,0,1,0))
		CreateJoint("Right Shoulder", torso, ra, CFrame.new(1,0.5,0,0,0,1,0,1,0,-1,0,0), CFrame.new(-0.5,0.5,0,0,0,1,0,1,0,-1,0,0))
		CreateJoint("Left Shoulder", torso, la, CFrame.new(-1,0.5,0,0,0,-1,0,1,0,1,0,0), CFrame.new(0.5,0.5,0,0,0,-1,0,1,0,1,0,0))
		CreateJoint("Right Hip", torso, rl, CFrame.new(1,-1,0,0,0,1,0,1,0,-1,0,0), CFrame.new(0.5,1,0,0,0,1,0,1,0,-1,0,0))
		CreateJoint("Left Hip", torso, ll, CFrame.new(-1,-1,0,0,0,-1,0,1,0,1,0,0), CFrame.new(-0.5,1,0,0,0,-1,0,1,0,1,0,0))

		AddAtt("HairAttachment", head, Vector3.new(0,0.6,0))
		AddAtt("HatAttachment", head, Vector3.new(0,0.6,0))
		AddAtt("FaceFrontAttachment", head, Vector3.new(0,0,-0.6))
		AddAtt("FaceCenterAttachment", head, Vector3.new(0,0,0))
		AddAtt("NeckAttachment", torso, Vector3.new(0,1,0))
		AddAtt("BodyFrontAttachment", torso, Vector3.new(0,0,-0.5))
		AddAtt("BodyBackAttachment", torso, Vector3.new(0,0,0.5))
		AddAtt("RightCollarAttachment",torso, Vector3.new(1,1,0))
		AddAtt("LeftCollarAttachment", torso, Vector3.new(-1,1,0))
		AddAtt("WaistFrontAttachment", torso, Vector3.new(0,-1,-0.5))
		AddAtt("WaistBackAttachment", torso, Vector3.new(0,-1,0.5))
		AddAtt("WaistCenterAttachment",torso, Vector3.new(0,-1,0))
		rig.PrimaryPart = root
	end

	rig.Name = "Mẫu"
	local hum = rig:FindFirstChildWhichIsA("Humanoid")
	if hum then
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	end

	local root = rig.PrimaryPart or rig:FindFirstChild("HumanoidRootPart")
	if root then root.Anchored = true end

	rig:PivotTo(refCF)
	rig.Parent = workspace
	State.CurrentDummy = rig

	if root then
		local att = Instance.new("Attachment", root)
		local pe = Instance.new("ParticleEmitter", att)
		pe.Texture = "rbxassetid://2130129598"
		pe.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(100,80,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0,200,255))})
		pe.Size = NumberSequence.new(0.1,1.2)
		pe.Transparency = NumberSequence.new(0,1)
		pe.Speed = NumberRange.new(8,20)
		pe.Lifetime = NumberRange.new(0.5,1.2)
		pe.SpreadAngle = Vector2.new(360,360)
		pe.Rate = 0; pe:Emit(150)
		Debris:AddItem(att,2)
	end

	local sv = Instance.new("NumberValue"); sv.Value = 0.01
	sv.Changed:Connect(function() if rig and rig.PrimaryPart then rig:ScaleTo(sv.Value) end end)
	local tw = Tween(sv, 0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Value=1})
	tw:Play(); tw.Completed:Connect(function() sv:Destroy() end)

	return rig
end

function NhanVat.RemoveDummy()
	if not State.CurrentDummy then return end
	local dummy = State.CurrentDummy
	State.CurrentDummy = nil
	AnimCache[dummy] = nil

	if dummy.PrimaryPart then
		local att = Instance.new("Attachment", workspace.Terrain)
		att.WorldCFrame = dummy.PrimaryPart.CFrame
		local pe = Instance.new("ParticleEmitter", att)
		pe.Texture = "rbxassetid://2130129598"
		pe.Color = ColorSequence.new(Color3.fromRGB(255,75,75))
		pe.Size = NumberSequence.new(0.2,1.8)
		pe.Speed = NumberRange.new(12,25)
		pe.SpreadAngle = Vector2.new(360,360)
		pe.Rate = 0; pe:Emit(200)
		Debris:AddItem(att,1.5)
	end

	local sv = Instance.new("NumberValue"); sv.Value = dummy:GetScale()
	sv.Changed:Connect(function() if dummy and dummy.PrimaryPart then dummy:ScaleTo(sv.Value) end end)
	local tw = Tween(sv, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {Value=0.01})
	tw:Play(); tw.Completed:Connect(function() sv:Destroy(); dummy:Destroy() end)
end

local function HandleAccessory(acc, targetModel)
	local handle = acc:FindFirstChild("Handle")
	if not handle then acc.Parent = targetModel return end

	for _, w in ipairs(handle:GetChildren()) do
		if w:IsA("JointInstance") or w:IsA("WeldConstraint") then w:Destroy() end
	end
	for _, p in ipairs(acc:GetDescendants()) do
		if p:IsA("BasePart") then p.Anchored = false p.CanCollide = false end
	end

	acc.Parent = targetModel

	local att = handle:FindFirstChildOfClass("Attachment")
	local targetAtt
	if att then
		for _, p in ipairs(targetModel:GetDescendants()) do
			if p:IsA("Attachment") and p.Name == att.Name then targetAtt = p break end
		end
	end

	local w = Instance.new("Weld")
	w.Name = "AccessoryWeld"
	w.Part1 = handle
	if targetAtt and att then
		w.Part0 = targetAtt.Parent
		w.C0 = targetAtt.CFrame
		w.C1 = att.CFrame
	else
		local head = targetModel:FindFirstChild("Head")
		if head then
			w.Part0 = head
			w.C0 = CFrame.new(0, 0.5, 0)
		end
	end
	w.Parent = handle
end

local function RestartAnimateScript(model)
	local animate = model:FindFirstChild("Animate")
	if animate and (animate:IsA("LocalScript") or animate:IsA("Script")) then
		animate.Disabled = true
		task.spawn(function()
			task.wait(0.05)
			animate.Disabled = false
		end)
	end
end

function NhanVat.CopyAppearance(sourceModel, targetModel)
	if not sourceModel or not targetModel then ThongBaoLoi("Lỗi", "Chưa chọn model nguồn hoặc đích!") return end

	local sHum = sourceModel:FindFirstChildWhichIsA("Humanoid")
	local tHum = targetModel:FindFirstChildWhichIsA("Humanoid")

	if sHum and tHum then
		local ok, desc = pcall(function() return sHum:GetAppliedDescription() end)
		if ok and desc then
			local applyOk = pcall(function() tHum:ApplyDescription(desc) end)
			if applyOk then
				if targetModel == State.CurrentDummy and State.CurrentScale ~= 1 then
					targetModel:ScaleTo(State.CurrentScale)
				end
				RestartAnimateScript(targetModel)
				ThongBao("Sao chép", "Đã chép 100% ngoại hình từ " .. sourceModel.Name)
				return
			end
		end
	end

	for _, v in ipairs(targetModel:GetChildren()) do
		if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("ShirtGraphic") then v:Destroy() end
	end

	local sHead = sourceModel:FindFirstChild("Head")
	local tHead = targetModel:FindFirstChild("Head")
	if sHead and tHead then
		local sFace = sHead:FindFirstChildOfClass("Decal")
		local tFace = tHead:FindFirstChildOfClass("Decal")
		if sFace then
			if tFace then tFace.Texture = sFace.Texture else sFace:Clone().Parent = tHead end
		elseif tFace then tFace:Destroy() end
	end

	for _, sp in ipairs(sourceModel:GetChildren()) do
		if sp:IsA("BasePart") then
			local tp = targetModel:FindFirstChild(sp.Name)
			if tp and tp:IsA("BasePart") then tp.Color = sp.Color end
		end
	end

	local count = 0
	for _, v in ipairs(sourceModel:GetChildren()) do
		if v:IsA("Accessory") then
			HandleAccessory(v:Clone(), targetModel)
			count += 1
		elseif v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("ShirtGraphic") then
			v:Clone().Parent = targetModel
			count += 1
		end
	end
	RestartAnimateScript(targetModel)
	ThongBao("Sao chép", "Đã chép " .. count .. " trang bị từ " .. sourceModel.Name)
end

function NhanVat.ScaleDummy(targetScale, duration)
	local dummy = State.CurrentDummy
	if not dummy or not dummy.PrimaryPart then ThongBaoLoi("Lỗi", "Chưa có Mẫu!") return end
	duration = duration or 0.4
	State.CurrentScale = targetScale
	local sv = Instance.new("NumberValue")
	sv.Value = dummy:GetScale()
	sv.Changed:Connect(function() if dummy and dummy.PrimaryPart then dummy:ScaleTo(sv.Value) end end)
	local tw = Tween(sv, duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Value=targetScale})
	tw:Play(); tw.Completed:Connect(function() sv:Destroy() end)
end

function NhanVat.ClearAllAccessories(model)
	model = model or State.CurrentDummy
	if not model then return end

	local hum = model:FindFirstChildWhichIsA("Humanoid")
	if hum then
		local ok, desc = pcall(function() return hum:GetAppliedDescription() end)
		if ok and desc then
			desc.HatAccessory = ""
			desc.HairAccessory = ""
			desc.FaceAccessory = ""
			desc.NeckAccessory = ""
			desc.ShouldersAccessory = ""
			desc.FrontAccessory = ""
			desc.BackAccessory = ""
			desc.WaistAccessory = ""
			desc.Shirt = 0
			desc.Pants = 0
			desc.GraphicTShirt = 0
			pcall(function() hum:ApplyDescription(desc) end)
		end
	end

	local removed = 0
	for _, v in ipairs(model:GetChildren()) do
		if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("ShirtGraphic") then
			v:Destroy(); removed += 1
		end
	end
	ThongBao("Xóa", "Đã xóa toàn bộ trang bị!")
end

function NhanVat.SetBodyPartColor(model, partGroup, color)
	model = model or State.CurrentDummy
	if not model then return end

	local hum = model:FindFirstChildWhichIsA("Humanoid")
	if hum then
		local ok, desc = pcall(function() return hum:GetAppliedDescription() end)
		if ok and desc then
			if partGroup == "Head" then desc.HeadColor = color
			elseif partGroup == "Torso" then desc.TorsoColor = color
			elseif partGroup == "Right Arm" then desc.RightArmColor = color
			elseif partGroup == "Left Arm" then desc.LeftArmColor = color
			elseif partGroup == "Right Leg" then desc.RightLegColor = color
			elseif partGroup == "Left Leg" then desc.LeftLegColor = color end
			pcall(function() hum:ApplyDescription(desc) end)
		end
	end

	local parts = bodyPartsMapping[partGroup]
	if parts then
		for _, pName in ipairs(parts) do
			local p = model:FindFirstChild(pName)
			if p and p:IsA("BasePart") then Tween(p, 0.3, nil, nil, {Color = color}):Play() end
		end
	end
end

function NhanVat.SetFace(model, textureId)
	model = model or State.CurrentDummy
	if not model then return end

	local hum = model:FindFirstChildWhichIsA("Humanoid")
	if hum then
		local ok, desc = pcall(function() return hum:GetAppliedDescription() end)
		if ok and desc then
			desc.Face = textureId
			pcall(function() hum:ApplyDescription(desc) end)
		end
	end

	local head = model:FindFirstChild("Head")
	if not head then return end
	local face = head:FindFirstChildOfClass("Decal")
	if not face then
		face = Instance.new("Decal")
		face.Name = "face"
		face.Parent = head
	end
	face.Texture = "rbxassetid://" .. tostring(textureId)
	ThongBao("Khuôn mặt", "Đã đổi khuôn mặt!")
end

function NhanVat.PlayAnim(model, animId)
	model = model or State.CurrentDummy
	if not model then return end
	local hum = model:FindFirstChildWhichIsA("Humanoid")
	if not hum then return end

	local idNum = tonumber(tostring(animId):match("%d+"))
	if not idNum then
		ThongBaoLoi("Lỗi Định Dạng", "Vui lòng nhập ID hợp lệ (chỉ chứa số).")
		return
	end

	if State.AnimTrack then
		pcall(function() State.AnimTrack:Stop() end)
		State.AnimTrack = nil
	end

	local ok, info = pcall(MarketplaceService.GetProductInfoAsync, MarketplaceService, idNum)
	if not ok or not info then
		ThongBaoLoi("Lỗi ID", "ID này không tồn tại, bị sai, hoặc là ID Private (Bị khóa)!")
		return
	end

	local realAnimId = "rbxassetid://" .. idNum

	if info.AssetTypeId == 61 then

		local successExtract = false
		local executorBlocked = false

		local okObj, objs = pcall(function() return game:GetObjects("rbxassetid://" .. idNum) end)
		if not okObj then
			executorBlocked = true
		elseif objs and objs[1] then
			local animObj = objs[1]:FindFirstChildWhichIsA("Animation", true) or (objs[1]:IsA("Animation") and objs[1])
			if animObj then
				realAnimId = animObj.AnimationId
				successExtract = true
				executorBlocked = false
			end
		end

		if not successExtract then
			local okInsert, loadedModel = pcall(function() return InsertService:LoadAsset(idNum) end)
			if not okInsert then
				executorBlocked = true
			elseif loadedModel then
				local animObj = loadedModel:FindFirstChildWhichIsA("Animation", true)
				if animObj then
					realAnimId = animObj.AnimationId
					successExtract = true
					executorBlocked = false
				end
				loadedModel:Destroy()
			end
		end

		if executorBlocked and not successExtract then
			ThongBaoLoi("Executor Chặn", "Tính năng bóc tách ID Shop đã bị chặn bởi Executor của bạn (Không hỗ trợ GetObjects/LoadAsset).")
			return
		elseif not successExtract then
			ThongBaoLoi("Lỗi Dữ Liệu", "ID là hàng Shop nhưng không tìm thấy dữ liệu Animation bên trong!")
			return
		end
	else
		realAnimId = "rbxassetid://" .. idNum
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = realAnimId

	local animator = hum:FindFirstChildOfClass("Animator") or hum
	local okLoad, track = pcall(function() return animator:LoadAnimation(anim) end)

	if okLoad and track then
		track:Play()
		State.AnimTrack = track
		ThongBao("Thành công", "Đang phát Animation ID: " .. tostring(idNum))
	else
		ThongBaoLoi("Lỗi Tải", "Không thể phát! Dữ liệu ID bị hỏng hoặc nhân vật không hỗ trợ hoạt ảnh này (Lệch R6/R15).")
	end
end

function NhanVat.TeleportDummyToPlayer(targetModel)
	local dummy = targetModel or State.CurrentDummy
	if not dummy then ThongBaoLoi("Lỗi", "Chưa có Mẫu!") return end
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local scale = dummy:GetScale()
	dummy:PivotTo(hrp.CFrame * CFrame.new(1.5, 3 * (scale - 1), 1.5))
	ThongBao("Di chuyển", "Đã mang Mẫu đến vị trí của bạn!")
end

function NhanVat.HighlightModel(model, color, enabled)
	if not model then return end
	local existing = model:FindFirstChildOfClass("SelectionBox")
	if existing then existing:Destroy() end

	if enabled ~= false then
		local sel = Instance.new("SelectionBox")
		sel.Adornee = model
		sel.Color3 = color or C.VienNeon
		sel.LineThickness = 0.05
		sel.SurfaceTransparency = 0.85
		sel.SurfaceColor3 = color or C.VienNeon
		sel.Parent = model
		model:SetAttribute("HxHighlight", true)
	else
		model:SetAttribute("HxHighlight", false)
	end
end

function NhanVat.LoadUserAppearance(model, userId)
	model = model or State.CurrentDummy
	if not model then ThongBaoLoi("Lỗi", "Chưa có Mẫu!") return end

	local ok, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserIdAsync(userId) end)
	if not ok or not desc then ThongBaoLoi("Lỗi", "Không thể lấy avatar của UserId " .. tostring(userId)) return end

	local hum = model:FindFirstChildWhichIsA("Humanoid")
	if hum then
		local applyOk, err = pcall(function() hum:ApplyDescription(desc) end)
		if applyOk then
			task.wait()
			model:ScaleTo(1)
			State.CurrentScale = 1
			RestartAnimateScript(model) 
			ThongBao("Ngoại hình", "Đã tải 100% avatar UserId: " .. tostring(userId))
		else
			ThongBaoLoi("Lỗi", "Không thể áp dụng ngoại hình!")
		end
	else
		ThongBaoLoi("Lỗi", "Model không có Humanoid!")
	end
end

function NhanVat.ToggleSelectMode(isON)
	State.IsSelecting = isON
	if Connections.Select then
		Connections.Select:Disconnect()
		Connections.Select = nil
	end

	if State.IsSelecting then
		Connections.Select = UserInputService.InputBegan:Connect(function(input, proc)
			if proc then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end

			local mpos = UserInputService:GetMouseLocation()
			local ray = Camera:ViewportPointToRay(mpos.X, mpos.Y)
			local rp = RaycastParams.new()
			rp.FilterType = Enum.RaycastFilterType.Exclude
			rp.FilterDescendantsInstances = {LocalPlayer.Character}
			local res = workspace:Raycast(ray.Origin, ray.Direction*1000, rp)

			if res and res.Instance then
				local model = res.Instance:FindFirstAncestorWhichIsA("Model")
				if model and model:FindFirstChildWhichIsA("Humanoid") then
					if State.SelectedModel then NhanVat.HighlightModel(State.SelectedModel, nil, false) end
					State.SelectedModel = model
					NhanVat.HighlightModel(model, C.TichBat, true)
					ThongBao("Đã chọn", "Mục tiêu: " .. model.Name)
				end
			end
		end)
	end
end

local function AttachAccessory(targetModel, id, addBtn)
	if addBtn then addBtn.Text = "Đang tải" end

	local targetHum = targetModel:FindFirstChildWhichIsA("Humanoid")
	if not targetHum then
		if addBtn then addBtn.Text = "Thêm" end
		return false
	end

	local okDesc, desc = pcall(function() return targetHum:GetAppliedDescription() end)
	if not okDesc or not desc then
		desc = Instance.new("HumanoidDescription")
	end

	local AssetService = game:GetService("AssetService")
	local isBundle = false
	local assetIdsToProcess = {id}

	local okBundle, bundleDetails = pcall(function() return AssetService:GetBundleDetailsAsync(id) end)
	if okBundle and bundleDetails and bundleDetails.Items then
		isBundle = true
		assetIdsToProcess = {}
		for _, item in ipairs(bundleDetails.Items) do
			if item.Type == "Asset" then
				table.insert(assetIdsToProcess, item.Id)
			end
		end
		ThongBao("Giải nén Gói", "Đã tìm thấy " .. #assetIdsToProcess .. " mảnh trong gói!")
	end

	local hasChanges = false

	for _, assetId in ipairs(assetIdsToProcess) do
		local ok, info = pcall(MarketplaceService.GetProductInfoAsync, MarketplaceService, assetId)
		if ok and info then
			local typeId = info.AssetTypeId
			if typeId==8 then desc.HatAccessory = desc.HatAccessory == "" and tostring(assetId) or desc.HatAccessory .. "," .. tostring(assetId); hasChanges = true
			elseif typeId==41 then desc.HairAccessory = desc.HairAccessory == "" and tostring(assetId) or desc.HairAccessory .. "," .. tostring(assetId); hasChanges = true
			elseif typeId==42 then desc.FaceAccessory = desc.FaceAccessory == "" and tostring(assetId) or desc.FaceAccessory .. "," .. tostring(assetId); hasChanges = true
			elseif typeId==43 then desc.NeckAccessory = desc.NeckAccessory == "" and tostring(assetId) or desc.NeckAccessory .. "," .. tostring(assetId); hasChanges = true
			elseif typeId==44 then desc.ShouldersAccessory = desc.ShouldersAccessory == "" and tostring(assetId) or desc.ShouldersAccessory .. "," .. tostring(assetId); hasChanges = true
			elseif typeId==45 then desc.FrontAccessory = desc.FrontAccessory == "" and tostring(assetId) or desc.FrontAccessory .. "," .. tostring(assetId); hasChanges = true
			elseif typeId==46 then desc.BackAccessory = desc.BackAccessory == "" and tostring(assetId) or desc.BackAccessory .. "," .. tostring(assetId); hasChanges = true
			elseif typeId==47 then desc.WaistAccessory = desc.WaistAccessory == "" and tostring(assetId) or desc.WaistAccessory .. "," .. tostring(assetId); hasChanges = true
			elseif typeId==11 then desc.Shirt = assetId; hasChanges = true
			elseif typeId==12 then desc.Pants = assetId; hasChanges = true
			elseif typeId==2 then desc.GraphicTShirt = assetId; hasChanges = true
			elseif typeId==17 then desc.Head = assetId; hasChanges = true
			elseif typeId==27 then desc.Torso = assetId; hasChanges = true
			elseif typeId==28 then desc.RightArm = assetId; hasChanges = true
			elseif typeId==29 then desc.LeftArm = assetId; hasChanges = true
			elseif typeId==30 then desc.LeftLeg = assetId; hasChanges = true
			elseif typeId==31 then desc.RightLeg = assetId; hasChanges = true
			elseif typeId==48 then desc.ClimbAnimation = assetId; hasChanges = true
			elseif typeId==50 then desc.FallAnimation = assetId; hasChanges = true
			elseif typeId==51 then desc.IdleAnimation = assetId; hasChanges = true
			elseif typeId==52 then desc.JumpAnimation = assetId; hasChanges = true
			elseif typeId==53 then desc.RunAnimation = assetId; hasChanges = true
			elseif typeId==55 then desc.SwimAnimation = assetId; hasChanges = true
			elseif typeId==56 then desc.WalkAnimation = assetId; hasChanges = true
			end
		end
	end

	if hasChanges then
		local s = pcall(function() targetHum:ApplyDescription(desc) end)
		if s then
			if RestartAnimateScript then pcall(function() RestartAnimateScript(targetModel) end) end
			if addBtn then addBtn.Text = "Thêm" end
			return true
		end
	end

	if not isBundle then
		local result = nil
		pcall(function() result = game:GetObjects("rbxassetid://"..id)[1] end)
		if not result then
			pcall(function()
				local loaded = InsertService:LoadAsset(id)
				if loaded then result = loaded:GetChildren()[1] end
			end)
		end

		if result then
			if targetModel:FindFirstChild(result.Name) then
				if addBtn then addBtn.Text = "Thêm" end
				ThongBao("Đã tồn tại", "Trang bị này đã được mặc!")
				return false
			end

			if result:IsA("Model") and result.Name=="Model" then
				result = result:FindFirstChildWhichIsA("Accessory") or result:FindFirstChildWhichIsA("Accoutrement") or result:FindFirstChildWhichIsA("BasePart") or result
			end

			if result:IsA("Accessory") or result:IsA("Accoutrement") then
				HandleAccessory(result, targetModel)
			elseif result:IsA("Shirt") or result:IsA("Pants") or result:IsA("ShirtGraphic") or result:IsA("CharacterMesh") then
				for _, old in ipairs(targetModel:GetChildren()) do
					if old.ClassName == result.ClassName then old:Destroy() end
				end
				result.Parent = targetModel
			end

			if addBtn then addBtn.Text = "Thêm" end
			return true
		end
	end

	if addBtn then addBtn.Text = "Thêm" end
	ThongBaoLoi("Lỗi", "Không thể tải ID này! Có thể ID bị sai hoặc là asset private.")
	return false
end

function NhanVat.OpenCustomMenu(targetModel)
	if not targetModel then ThongBaoLoi("Lỗi", "Chưa có mục tiêu để mở menu!") return end

	local uiName = "Hx_NhanVat_V2"
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	if PlayerGui:FindFirstChild(uiName) then PlayerGui[uiName]:Destroy() end

	local sg = Instance.new("ScreenGui")
	sg.Name = uiName
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.Parent = PlayerGui

	local win = Instance.new("Frame")
	win.Name = "Window"
	win.Size = UDim2.new(0, 360, 0, 0)
	win.Position = UDim2.new(0.5, 0, 0.5, 0)
	win.AnchorPoint = Vector2.new(0.5, 0.5)
	win.BackgroundColor3 = C.Nen
	win.BorderSizePixel = 0
	win.ClipsDescendants = true
	win.Active = true
	win.AutomaticSize = Enum.AutomaticSize.Y
	Corner(win, 10)
	Stroke(win, C.VienNeon, 0.4, 1.2)
	win.Parent = sg

	local winScale = Instance.new("UIScale", win)
	winScale.Scale = 0.85
	Tween(winScale, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Scale = 1}):Play()
	Tween(win, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = 0}):Play()

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 45)
	header.BackgroundColor3 = C.NenKhoi
	header.BorderSizePixel = 0
	Corner(header, 10)
	header.Parent = win

	local hFiller = Instance.new("Frame")
	hFiller.Size = UDim2.new(1, 0, 0, 10)
	hFiller.Position = UDim2.new(0, 0, 1, -10)
	hFiller.BackgroundColor3 = C.NenKhoi
	hFiller.BorderSizePixel = 0
	hFiller.Parent = header

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, 24, 0, 24)
	icon.Position = UDim2.new(0, 14, 0.5, -12)
	icon.BackgroundTransparency = 1
	icon.Image = "rbxassetid://117118515787811"
	icon.Parent = header

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(0, 200, 0, 18)
	titleLbl.Position = UDim2.new(0, 48, 0, 6)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = "Hx Custom Menu"
	titleLbl.TextColor3 = C.Chu
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 14
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = header

	local isClosing = false
	local function DongGiaoDien()
		if isClosing then return end
		isClosing = true
		Tween(winScale, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In, {Scale = 0.8}):Play()
		local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		for _, v in ipairs(win:GetDescendants()) do
			if v:IsA("UIStroke") then
				TweenService:Create(v, ti, {Transparency = 1}):Play()
			elseif v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
				TweenService:Create(v, ti, {TextTransparency = 1, BackgroundTransparency = 1}):Play()
			elseif v:IsA("ImageLabel") then
				TweenService:Create(v, ti, {ImageTransparency = 1, BackgroundTransparency = 1}):Play()
			elseif v:IsA("Frame") or v:IsA("ScrollingFrame") then
				TweenService:Create(v, ti, {BackgroundTransparency = 1}):Play()
			end
		end
		TweenService:Create(win, ti, {BackgroundTransparency = 1}):Play()
		if win:FindFirstChildOfClass("UIStroke") then
			TweenService:Create(win:FindFirstChildOfClass("UIStroke"), ti, {Transparency = 1}):Play()
		end
		task.delay(0.25, function() sg:Destroy() end)
	end

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 28, 0, 28)
	closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
	closeBtn.BackgroundColor3 = C.NutDong
	closeBtn.Text = "X"
	closeBtn.TextColor3 = C.Chu
	closeBtn.Font = Enum.Font.GothamBlack
	closeBtn.TextSize = 12
	closeBtn.AutoButtonColor = false
	Corner(closeBtn, 6)
	closeBtn.Parent = header
	closeBtn.MouseEnter:Connect(function() Tween(closeBtn, 0.15, nil, nil, {BackgroundColor3 = C.NutDongLuot}):Play() end)
	closeBtn.MouseLeave:Connect(function() Tween(closeBtn, 0.15, nil, nil, {BackgroundColor3 = C.NutDong}):Play() end)
	closeBtn.MouseButton1Click:Connect(DongGiaoDien)

	local contentWrapper = Instance.new("Frame")
	contentWrapper.Size = UDim2.new(1, 0, 0, 0)
	contentWrapper.Position = UDim2.new(0, 0, 0, 45)
	contentWrapper.BackgroundTransparency = 1
	contentWrapper.AutomaticSize = Enum.AutomaticSize.Y
	contentWrapper.Parent = win

	local contentLayout = Instance.new("UIListLayout", contentWrapper)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 28, 0, 28)
	minBtn.Position = UDim2.new(1, -72, 0.5, -14)
	minBtn.BackgroundColor3 = C.NenHop
	minBtn.Text = "_"
	minBtn.TextColor3 = C.Chu
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 13
	minBtn.AutoButtonColor = false
	Corner(minBtn, 6)
	Stroke(minBtn, C.VienNeon, 0.6)
	minBtn.Parent = header
	minBtn.MouseEnter:Connect(function() Tween(minBtn, 0.15, nil, nil, {BackgroundColor3 = C.NenMuc}):Play() end)
	minBtn.MouseLeave:Connect(function() Tween(minBtn, 0.15, nil, nil, {BackgroundColor3 = C.NenHop}):Play() end)

	local dragging, dragStart, startPos = false, nil, nil
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true dragStart = input.Position startPos = win.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)

	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, 0, 0, 35)
	tabBar.BackgroundColor3 = C.NenHop
	tabBar.BorderSizePixel = 0
	tabBar.LayoutOrder = 1
	tabBar.Parent = contentWrapper

	local tabLayout = Instance.new("UIListLayout", tabBar)
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local contentHolder = Instance.new("Frame")
	contentHolder.Size = UDim2.new(1, 0, 0, 0)
	contentHolder.BackgroundTransparency = 1
	contentHolder.AutomaticSize = Enum.AutomaticSize.Y
	contentHolder.LayoutOrder = 2
	contentHolder.Parent = contentWrapper

	local isMinimized = false
	minBtn.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		if isMinimized then
			win.AutomaticSize = Enum.AutomaticSize.None
			local currentSize = win.AbsoluteSize.Y
			win.Size = UDim2.new(0, 360, 0, currentSize)
			hFiller.Visible = false
			Tween(win, 0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, {Size = UDim2.new(0, 360, 0, 45)}):Play()
		else
			local targetSize = 45 + contentWrapper.AbsoluteSize.Y
			Tween(win, 0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, {Size = UDim2.new(0, 360, 0, targetSize)}):Play()
			task.delay(0.35, function()
				if not isMinimized then
					win.AutomaticSize = Enum.AutomaticSize.Y
					hFiller.Visible = true
				end
			end)
		end
	end)

	local TABS = {{name="Phụ kiện"}, {name="Cơ thể"}, {name="Chuyển động"}, {name="Công cụ"}}
	local tabPages = {}
	local tabBtns = {}
	local activeTab = nil

	local function SwitchTab(idx)
		if activeTab == idx then return end
		activeTab = idx
		for i, page in ipairs(tabPages) do
			local active = (i == idx)
			page.Visible = active
			local btn = tabBtns[i]
			Tween(btn, 0.15, nil, nil, {BackgroundColor3 = active and C.NenMuc or C.NenHop}):Play()
			btn.TextColor3 = active and C.TichBat or C.ChuMo
		end
	end

	for i, tab in ipairs(TABS) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.25, 0, 1, 0)
		btn.BackgroundColor3 = C.NenHop
		btn.BorderSizePixel = 0
		btn.Text = tab.name
		btn.TextColor3 = C.ChuMo
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 11
		btn.LayoutOrder = i
		btn.AutoButtonColor = false
		btn.Parent = tabBar
		tabBtns[i] = btn

		local page = Instance.new("Frame")
		page.Size = UDim2.new(1, 0, 0, 0)
		page.BackgroundTransparency = 1
		page.AutomaticSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.Parent = contentHolder
		tabPages[i] = page
		btn.MouseButton1Click:Connect(function() SwitchTab(i) end)
	end

	local page1 = tabPages[1]
	local p1Layout = Instance.new("UIListLayout", page1)
	p1Layout.SortOrder = Enum.SortOrder.LayoutOrder
	p1Layout.Padding = UDim.new(0, 10)
	Padding(page1, 12, 2, 12, 12)

	local inputRow = Instance.new("Frame", page1)
	inputRow.Size = UDim2.new(1, 0, 0, 32)
	inputRow.BackgroundTransparency = 1
	inputRow.LayoutOrder = 1

	local idBox = Instance.new("TextBox")
	idBox.Size = UDim2.new(1, -96, 1, 0)
	idBox.BackgroundColor3 = C.NenHop
	idBox.PlaceholderText = "Nhập Asset ID..."
	idBox.PlaceholderColor3 = C.ChuMo
	idBox.Text = ""
	idBox.TextColor3 = C.Chu
	idBox.Font = Enum.Font.Gotham
	idBox.TextSize = 12
	idBox.TextXAlignment = Enum.TextXAlignment.Left
	idBox.ClearTextOnFocus = false
	Corner(idBox, 6)
	Stroke(idBox, C.VienNeon, 0.6)
	Padding(idBox, 8)
	idBox.Parent = inputRow

	local addBtn = MakeBtn(inputRow, "Thêm", C.NenMuc, UDim2.new(0, 80, 1, 0), UDim2.new(1, -88, 0, 0))
	Stroke(addBtn, C.VienNeon, 0.6)
	Ripple(addBtn)

	local quickRow = Instance.new("Frame", page1)
	quickRow.Size = UDim2.new(1, 0, 0, 32)
	quickRow.BackgroundTransparency = 1
	quickRow.LayoutOrder = 2

	local clearBtn = MakeBtn(quickRow, "Xóa tất cả", C.NenMuc, UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0))
	Stroke(clearBtn, C.VienNeon, 0.6)
	Ripple(clearBtn)
	clearBtn.MouseButton1Click:Connect(function() NhanVat.ClearAllAccessories(targetModel) end)

	local copyBtn = MakeBtn(quickRow, "Copy từ quét", C.NenMuc, UDim2.new(0.48, -8, 1, 0), UDim2.new(0.52, 0, 0, 0))
	Stroke(copyBtn, C.VienNeon, 0.6)
	Ripple(copyBtn)
	copyBtn.MouseButton1Click:Connect(function()
		if State.SelectedModel then
			NhanVat.CopyAppearance(State.SelectedModel, targetModel)
			local scroll1 = page1:FindFirstChild("ScrollingFrame")
			if scroll1 and scroll1:FindFirstChild("UIListLayout") then
				for _, v in ipairs(scroll1:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
				local items = {}
				for _, v in ipairs(targetModel:GetDescendants()) do
					if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("ShirtGraphic") then table.insert(items, v) end
				end
				for idx, item in ipairs(items) do
					local row = Instance.new("Frame")
					row.Size = UDim2.new(1, 0, 0, 34)
					row.BackgroundColor3 = C.NenHop
					row.LayoutOrder = idx
					Corner(row, 4)
					Stroke(row, C.VienNeon, 0.8)

					local typeLbl = Instance.new("TextLabel")
					typeLbl.Size = UDim2.new(0, 40, 1, 0)
					typeLbl.BackgroundTransparency = 1
					typeLbl.Text = "["..string.sub(item.ClassName, 1, 4).."]"
					typeLbl.TextSize = 10
					typeLbl.Font = Enum.Font.GothamBold
					typeLbl.TextColor3 = C.TichBat
					typeLbl.Parent = row

					local nameLbl = Instance.new("TextLabel")
					nameLbl.Size = UDim2.new(1, -75, 1, 0)
					nameLbl.Position = UDim2.new(0, 42, 0, 0)
					nameLbl.BackgroundTransparency = 1
					nameLbl.Text = item.Name
					nameLbl.TextColor3 = C.Chu
					nameLbl.Font = Enum.Font.Gotham
					nameLbl.TextSize = 12
					nameLbl.TextXAlignment = Enum.TextXAlignment.Left
					nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
					nameLbl.Parent = row

					local delBtnRow = Instance.new("TextButton")
					delBtnRow.Size = UDim2.new(0, 26, 0, 26)
					delBtnRow.Position = UDim2.new(1, -30, 0.5, -13)
					delBtnRow.BackgroundColor3 = C.NenMuc
					delBtnRow.Text = "X"
					delBtnRow.TextColor3 = C.Chu
					delBtnRow.Font = Enum.Font.GothamBold
					delBtnRow.TextSize = 11
					delBtnRow.AutoButtonColor = false
					Corner(delBtnRow, 4)
					delBtnRow.Parent = row
					delBtnRow.MouseEnter:Connect(function() Tween(delBtnRow, 0.15, nil, nil, {BackgroundColor3 = C.NutDongLuot}):Play() end)
					delBtnRow.MouseLeave:Connect(function() Tween(delBtnRow, 0.15, nil, nil, {BackgroundColor3 = C.NenMuc}):Play() end)
					delBtnRow.MouseButton1Click:Connect(function()
						local tw = Tween(row, 0.15, nil, nil, {BackgroundTransparency = 1})
						tw:Play()
						tw.Completed:Connect(function() item:Destroy() row:Destroy() end)
					end)
					row.Parent = scroll1
				end
			end
		else ThongBaoLoi("Lỗi", "Chưa có mục tiêu quét. Bật chế độ quét trước.") end
	end)

	local scroll1 = Instance.new("ScrollingFrame", page1)
	scroll1.Size = UDim2.new(1, 0, 0, 0)
	scroll1.BackgroundColor3 = C.NenList
	scroll1.ScrollBarThickness = 4
	scroll1.ScrollBarImageColor3 = C.ChuMo
	scroll1.BorderSizePixel = 0
	scroll1.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll1.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll1.LayoutOrder = 3
	Corner(scroll1, 6)
	Stroke(scroll1, C.VienNeon, 0.6)

	local sLayout1 = Instance.new("UIListLayout", scroll1)
	sLayout1.Padding = UDim.new(0, 4)
	sLayout1.SortOrder = Enum.SortOrder.LayoutOrder
	Padding(scroll1, 6)

	sLayout1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll1.Size = UDim2.new(1, 0, 0, math.clamp(sLayout1.AbsoluteContentSize.Y + 12, 0, 240))
	end)

	local function RefreshList()
		for _, v in ipairs(scroll1:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
		local items = {}
		for _, v in ipairs(targetModel:GetDescendants()) do
			if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("ShirtGraphic") then
				table.insert(items, v)
			end
		end
		for idx, item in ipairs(items) do
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 34)
			row.BackgroundColor3 = C.NenHop
			row.LayoutOrder = idx
			Corner(row, 4)
			Stroke(row, C.VienNeon, 0.8)

			local typeLbl = Instance.new("TextLabel")
			typeLbl.Size = UDim2.new(0, 40, 1, 0)
			typeLbl.BackgroundTransparency = 1
			typeLbl.Text = "["..string.sub(item.ClassName, 1, 4).."]"
			typeLbl.TextSize = 10
			typeLbl.Font = Enum.Font.GothamBold
			typeLbl.TextColor3 = C.TichBat
			typeLbl.Parent = row

			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.new(1, -75, 1, 0)
			nameLbl.Position = UDim2.new(0, 42, 0, 0)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Text = item.Name
			nameLbl.TextColor3 = C.Chu
			nameLbl.Font = Enum.Font.Gotham
			nameLbl.TextSize = 12
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
			nameLbl.Parent = row

			local delBtn = Instance.new("TextButton")
			delBtn.Size = UDim2.new(0, 26, 0, 26)
			delBtn.Position = UDim2.new(1, -30, 0.5, -13)
			delBtn.BackgroundColor3 = C.NenMuc
			delBtn.Text = "X"
			delBtn.TextColor3 = C.Chu
			delBtn.Font = Enum.Font.GothamBold
			delBtn.TextSize = 11
			delBtn.AutoButtonColor = false
			Corner(delBtn, 4)
			delBtn.Parent = row
			delBtn.MouseEnter:Connect(function() Tween(delBtn, 0.15, nil, nil, {BackgroundColor3 = C.NutDongLuot}):Play() end)
			delBtn.MouseLeave:Connect(function() Tween(delBtn, 0.15, nil, nil, {BackgroundColor3 = C.NenMuc}):Play() end)
			delBtn.MouseButton1Click:Connect(function()
				local tw = Tween(row, 0.15, nil, nil, {BackgroundTransparency = 1})
				tw:Play()
				tw.Completed:Connect(function() item:Destroy() RefreshList() end)
			end)
			row.Parent = scroll1
		end
		scroll1.Size = UDim2.new(1, 0, 0, math.clamp(sLayout1.AbsoluteContentSize.Y + 12, 0, 240))
	end

	addBtn.MouseButton1Click:Connect(function()
		local id = tonumber(idBox.Text:match("%d+"))
		if not id then ThongBaoLoi("Lỗi", "Vui lòng nhập ID hợp lệ!") return end
		local success = AttachAccessory(targetModel, id, addBtn)
		if success then idBox.Text = "" RefreshList() ThongBao("Thành công", "Đã gắn trang bị!") end
	end)
	clearBtn.MouseButton1Click:Connect(RefreshList)
	RefreshList()

	local page2 = tabPages[2]
	Padding(page2, 12, 2, 12, 12)

	local bodyScroll = Instance.new("ScrollingFrame", page2)
	bodyScroll.Size = UDim2.new(1, 0, 0, 0)
	bodyScroll.BackgroundTransparency = 1
	bodyScroll.ScrollBarThickness = 4
	bodyScroll.ScrollBarImageColor3 = C.ChuMo
	bodyScroll.BorderSizePixel = 0
	bodyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	bodyScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

	local bodyLayout = Instance.new("UIListLayout", bodyScroll)
	bodyLayout.Padding = UDim.new(0, 8)
	bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	Padding(bodyScroll, 2)

	bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		bodyScroll.Size = UDim2.new(1, 0, 0, math.clamp(bodyLayout.AbsoluteContentSize.Y + 4, 0, 300))
	end)

	local function SectionLabel(parent, text, order)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, 0, 0, 22)
		f.BackgroundTransparency = 1
		f.LayoutOrder = order
		f.Parent = parent
		local l = Instance.new("TextLabel", f)
		l.Size = UDim2.new(1, 0, 1, 0)
		l.BackgroundTransparency = 1
		l.Text = text
		l.TextColor3 = C.TichBat
		l.Font = Enum.Font.GothamBold
		l.TextSize = 11
		l.TextXAlignment = Enum.TextXAlignment.Left
	end

	SectionLabel(bodyScroll, "Tải Avatar từ UserId", 1)

	local uidRow = Instance.new("Frame")
	uidRow.Size = UDim2.new(1, 0, 0, 36)
	uidRow.BackgroundTransparency = 1
	uidRow.LayoutOrder = 2
	uidRow.Parent = bodyScroll

	local uidBox = Instance.new("TextBox")
	uidBox.Size = UDim2.new(1, -98, 1, 0)
	uidBox.BackgroundColor3 = C.NenHop
	uidBox.PlaceholderText = "Nhập UserId..."
	uidBox.PlaceholderColor3 = C.ChuMo
	uidBox.Text = ""
	uidBox.TextColor3 = C.Chu
	uidBox.Font = Enum.Font.Gotham
	uidBox.TextSize = 12
	uidBox.TextXAlignment = Enum.TextXAlignment.Left
	uidBox.ClearTextOnFocus = false
	Corner(uidBox, 6)
	Stroke(uidBox, C.VienNeon, 0.6)
	Padding(uidBox, 8)
	uidBox.Parent = uidRow

	local scaleRow = Instance.new("Frame")
	scaleRow.Size = UDim2.new(1, 0, 0, 36)
	scaleRow.BackgroundTransparency = 1
	scaleRow.LayoutOrder = 4
	scaleRow.Parent = bodyScroll

	local loadAvaBtn = MakeBtn(uidRow, "Tải", C.NenMuc, UDim2.new(0, 80, 1, 0), UDim2.new(1, -88, 0, 0))
	Stroke(loadAvaBtn, C.VienNeon, 0.6)
	Ripple(loadAvaBtn)
	loadAvaBtn.MouseButton1Click:Connect(function()
		local uid = tonumber(uidBox.Text:match("%d+"))
		if not uid then ThongBaoLoi("Lỗi", "UserId không hợp lệ!") return end
		loadAvaBtn.Text = "..."

		NhanVat.ScaleDummy(1)
		for _, btn in ipairs(scaleRow:GetChildren()) do
			if btn:IsA("TextButton") then
				if btn.Text == "Thường" then
					Tween(btn, 0.15, nil, nil, {BackgroundColor3 = C.NenMuc}):Play()
					btn.TextColor3 = C.TichBat
				else
					Tween(btn, 0.15, nil, nil, {BackgroundColor3 = C.NenHop}):Play()
					btn.TextColor3 = C.Chu
				end
			end
		end

		NhanVat.LoadUserAppearance(targetModel, uid)
		loadAvaBtn.Text = "Tải"
		RefreshList()
	end)

	SectionLabel(bodyScroll, "Tỉ lệ nhân vật", 3)

	local SCALES = {{"Bé", 0.5}, {"Nhỏ", 0.75}, {"Thường", 1}, {"To", 1.5}, {"Lớn", 2.5}}
	local scListLayout = Instance.new("UIListLayout", scaleRow)
	scListLayout.FillDirection = Enum.FillDirection.Horizontal
	scListLayout.Padding = UDim.new(0, 4)

	for _, sv in ipairs(SCALES) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 56, 1, 0)
		b.BackgroundColor3 = C.NenHop
		b.Text = sv[1]
		b.TextColor3 = C.Chu
		b.Font = Enum.Font.Gotham
		b.TextSize = 11
		b.AutoButtonColor = false
		Corner(b, 6)
		Stroke(b, C.VienNeon, 0.6)
		b.Parent = scaleRow
		b.MouseButton1Click:Connect(function()
			NhanVat.ScaleDummy(sv[2])
			for _, btn in ipairs(scaleRow:GetChildren()) do
				if btn:IsA("TextButton") then
					Tween(btn, 0.15, nil, nil, {BackgroundColor3 = C.NenHop}):Play()
					btn.TextColor3 = C.Chu
				end
			end
			Tween(b, 0.15, nil, nil, {BackgroundColor3 = C.NenMuc}):Play()
			b.TextColor3 = C.TichBat
		end)
	end

	SectionLabel(bodyScroll, "Màu sắc cơ thể", 5)
	local presetColors = {
		Color3.fromRGB(253,234,141), Color3.fromRGB(255,180,100), Color3.fromRGB(200,120,60), Color3.fromRGB(120,60,20),
		Color3.fromRGB(255,255,255), Color3.fromRGB(0,0,0), Color3.fromRGB(100,200,255), Color3.fromRGB(255,100,100),
	}

	local orderIndex = 6
	for pGroup, _ in pairs(bodyPartsMapping) do
		local prow = Instance.new("Frame")
		prow.Size = UDim2.new(1, 0, 0, 30)
		prow.BackgroundTransparency = 1
		prow.LayoutOrder = orderIndex
		prow.Parent = bodyScroll
		orderIndex = orderIndex + 1
		local plbl = Instance.new("TextLabel", prow)
		plbl.Size = UDim2.new(0, 80, 1, 0)
		plbl.BackgroundTransparency = 1
		plbl.Text = pGroup
		plbl.TextColor3 = C.ChuMo
		plbl.Font = Enum.Font.Gotham
		plbl.TextSize = 10
		plbl.TextXAlignment = Enum.TextXAlignment.Left
		local colorRow = Instance.new("Frame", prow)
		colorRow.Size = UDim2.new(1, -84, 1, 0)
		colorRow.Position = UDim2.new(0, 84, 0, 0)
		colorRow.BackgroundTransparency = 1
		local cl = Instance.new("UIListLayout", colorRow)
		cl.FillDirection = Enum.FillDirection.Horizontal
		cl.Padding = UDim.new(0, 3)
		for _, col in ipairs(presetColors) do
			local cb = Instance.new("TextButton", colorRow)
			cb.Size = UDim2.new(0, 22, 0, 22)
			cb.BackgroundColor3 = col
			cb.Text = ""
			cb.AutoButtonColor = false
			Corner(cb, 4)
			Stroke(cb, C.VienNeon, 0.4)
			cb.MouseButton1Click:Connect(function() NhanVat.SetBodyPartColor(targetModel, pGroup, col) end)
		end
	end

	SectionLabel(bodyScroll, "Thay đổi khuôn mặt", orderIndex)
	local faceRow = Instance.new("Frame")
	faceRow.Size = UDim2.new(1, 0, 0, 36)
	faceRow.BackgroundTransparency = 1
	faceRow.LayoutOrder = orderIndex + 1
	faceRow.Parent = bodyScroll
	local faceBox = Instance.new("TextBox")
	faceBox.Size = UDim2.new(1, -98, 1, 0)
	faceBox.BackgroundColor3 = C.NenHop
	faceBox.PlaceholderText = "Nhập ID Face..."
	faceBox.PlaceholderColor3 = C.ChuMo
	faceBox.Text = ""
	faceBox.TextColor3 = C.Chu
	faceBox.Font = Enum.Font.Gotham
	faceBox.TextSize = 12
	faceBox.TextXAlignment = Enum.TextXAlignment.Left
	faceBox.ClearTextOnFocus = false
	Corner(faceBox, 6)
	Stroke(faceBox, C.VienNeon, 0.6)
	Padding(faceBox, 8)
	faceBox.Parent = faceRow

	local setFaceBtn = MakeBtn(faceRow, "Đặt", C.NenMuc, UDim2.new(0, 80, 1, 0), UDim2.new(1, -88, 0, 0))
	Stroke(setFaceBtn, C.VienNeon, 0.6)
	Ripple(setFaceBtn)
	setFaceBtn.MouseButton1Click:Connect(function()
		local fid = tonumber(faceBox.Text:match("%d+"))
		if fid then NhanVat.SetFace(targetModel, fid) else ThongBaoLoi("Lỗi", "Face ID không hợp lệ!") end
	end)
	bodyScroll.Size = UDim2.new(1, 0, 0, math.clamp(bodyLayout.AbsoluteContentSize.Y + 4, 0, 300))

	local page3 = tabPages[3]
	Padding(page3, 12, 2, 12, 12)

	local animScroll = Instance.new("ScrollingFrame", page3)
	animScroll.Size = UDim2.new(1, 0, 0, 0)
	animScroll.BackgroundTransparency = 1
	animScroll.ScrollBarThickness = 4
	animScroll.ScrollBarImageColor3 = C.ChuMo
	animScroll.BorderSizePixel = 0
	animScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	animScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

	local animLayout = Instance.new("UIListLayout", animScroll)
	animLayout.Padding = UDim.new(0, 8)
	animLayout.SortOrder = Enum.SortOrder.LayoutOrder
	Padding(animScroll, 2)

	animLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		animScroll.Size = UDim2.new(1, 0, 0, math.clamp(animLayout.AbsoluteContentSize.Y + 4, 0, 300))
	end)

	local animInfoLbl = Instance.new("TextLabel", animScroll)
	animInfoLbl.Size = UDim2.new(1, -8, 0, 36)
	animInfoLbl.BackgroundColor3 = C.NenHop
	animInfoLbl.Text = "Nhập Animation ID để phát. Mục tiêu cần có Animator."
	animInfoLbl.TextColor3 = C.ChuMo
	animInfoLbl.Font = Enum.Font.Gotham
	animInfoLbl.TextSize = 11
	animInfoLbl.TextWrapped = true
	animInfoLbl.LayoutOrder = 0
	Corner(animInfoLbl, 6)
	Stroke(animInfoLbl, C.VienNeon, 0.6)
	Padding(animInfoLbl, 6)

	local animRow = Instance.new("Frame")
	animRow.Size = UDim2.new(1, 0, 0, 36)
	animRow.BackgroundTransparency = 1
	animRow.LayoutOrder = 1
	animRow.Parent = animScroll

	local animBox = Instance.new("TextBox")
	animBox.Size = UDim2.new(1, -98, 1, 0)
	animBox.BackgroundColor3 = C.NenHop
	animBox.PlaceholderText = "Animation ID..."
	animBox.PlaceholderColor3 = C.ChuMo
	animBox.Text = ""
	animBox.TextColor3 = C.Chu
	animBox.Font = Enum.Font.Gotham
	animBox.TextSize = 12
	animBox.TextXAlignment = Enum.TextXAlignment.Left
	animBox.ClearTextOnFocus = false
	Corner(animBox, 6)
	Stroke(animBox, C.VienNeon, 0.6)
	Padding(animBox, 8)
	animBox.Parent = animRow

	local playAnimBtn = MakeBtn(animRow, "Phát", C.NenMuc, UDim2.new(0, 80, 1, 0), UDim2.new(1, -88, 0, 0))
	Stroke(playAnimBtn, C.VienNeon, 0.6)
	Ripple(playAnimBtn)
	playAnimBtn.MouseButton1Click:Connect(function()
		local aid = tonumber(animBox.Text:match("%d+"))
		if aid then NhanVat.PlayAnim(targetModel, aid) else ThongBaoLoi("Lỗi", "Animation ID không hợp lệ!") end
	end)

	local stopAnimBtn = MakeBtn(animScroll, "Dừng Animation", C.NenMuc, UDim2.new(1, -8, 0, 34))
	stopAnimBtn.LayoutOrder = 2
	Stroke(stopAnimBtn, C.VienNeon, 0.6)
	Ripple(stopAnimBtn)
	stopAnimBtn.MouseButton1Click:Connect(function()
		if State.AnimTrack then
			State.AnimTrack:Stop()
			State.AnimTrack = nil
			ThongBao("Animation", "Đã dừng chuyển động.")
		end
		if targetModel then
			local hum = targetModel:FindFirstChildWhichIsA("Humanoid")
			if hum then
				local animator = hum:FindFirstChildOfClass("Animator")
				if animator then
					for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
						track:Stop(0.2)
					end
				end
			end
		end
	end)

	local presetLbl = Instance.new("TextLabel", animScroll)
	presetLbl.Size = UDim2.new(1, 0, 0, 18)
	presetLbl.BackgroundTransparency = 1
	presetLbl.Text = "Gợi ý Animation"
	presetLbl.TextColor3 = C.TichBat
	presetLbl.Font = Enum.Font.GothamBold
	presetLbl.TextSize = 11
	presetLbl.TextXAlignment = Enum.TextXAlignment.Left
	presetLbl.LayoutOrder = 3

	local presetGrid = Instance.new("Frame")
	presetGrid.Size = UDim2.new(1, 0, 0, 0)
	presetGrid.BackgroundTransparency = 1
	presetGrid.AutomaticSize = Enum.AutomaticSize.Y
	presetGrid.LayoutOrder = 4
	presetGrid.Parent = animScroll

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.25, -6, 0, 32)
	gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = presetGrid

	local isR15Preset = targetModel:FindFirstChildWhichIsA("Humanoid") and targetModel:FindFirstChildWhichIsA("Humanoid").RigType == Enum.HumanoidRigType.R15
	local presetAnimsList = isR15Preset and {
		{ "Dance", 507771019 }, { "Idle",  507766388 }, { "Run",   507767714 },
		{ "Walk",  507777826 }, { "Wave",  507770239 }, { "Laugh", 507770818 },
	} or {
		{ "Dance", 182435998 }, { "Idle",  180435571 }, { "Run",   180426354 },
		{ "Walk",  180426354 }, { "Wave",  128777973 }, { "Laugh", 129423131 },
	}

	for pi, pa in ipairs(presetAnimsList) do
		local pb = MakeBtn(presetGrid, pa[1], C.NenHop)
		pb.LayoutOrder = pi
		pb.TextColor3 = C.Chu
		pb.TextSize = 12
		Stroke(pb, C.VienNeon, 0.6)
		Ripple(pb)
		pb.MouseButton1Click:Connect(function() NhanVat.PlayAnim(targetModel, pa[2]) end)
	end
	animScroll.Size = UDim2.new(1, 0, 0, math.clamp(animLayout.AbsoluteContentSize.Y + 4, 0, 300))

	local page4 = tabPages[4]
	Padding(page4, 12, 2, 12, 12)

	local toolScroll = Instance.new("ScrollingFrame", page4)
	toolScroll.Size = UDim2.new(1, 0, 0, 0)
	toolScroll.BackgroundTransparency = 1
	toolScroll.ScrollBarThickness = 4
	toolScroll.ScrollBarImageColor3 = C.ChuMo
	toolScroll.BorderSizePixel = 0
	toolScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	toolScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

	local toolLayout = Instance.new("UIListLayout", toolScroll)
	toolLayout.Padding = UDim.new(0, 8)
	toolLayout.SortOrder = Enum.SortOrder.LayoutOrder
	Padding(toolScroll, 2)

	toolLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		toolScroll.Size = UDim2.new(1, 0, 0, math.clamp(toolLayout.AbsoluteContentSize.Y + 4, 0, 300))
	end)

	local tpRow = Instance.new("Frame", toolScroll)
	tpRow.Size = UDim2.new(1, 0, 0, 32)
	tpRow.BackgroundTransparency = 1
	tpRow.LayoutOrder = 1

	local tpPlayerBtn = MakeBtn(tpRow, "Đến Player", C.NenMuc, UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0))
	Stroke(tpPlayerBtn, C.VienNeon, 0.6)
	Ripple(tpPlayerBtn)
	tpPlayerBtn.MouseButton1Click:Connect(function() NhanVat.TeleportDummyToPlayer(targetModel) end)

	local tpCamBtn = MakeBtn(tpRow, "Đến Camera", C.NenMuc, UDim2.new(0.48, -8, 1, 0), UDim2.new(0.52, 0, 0, 0))
	Stroke(tpCamBtn, C.VienNeon, 0.6)
	Ripple(tpCamBtn)
	tpCamBtn.MouseButton1Click:Connect(function()
		if targetModel and targetModel.PrimaryPart then
			local scale = targetModel:GetScale()
			targetModel:PivotTo(Camera.CFrame * CFrame.new(0, -1.5 * (scale - 1), -5 - scale))
			ThongBao("Di chuyển", "Đã mang đến trước Camera!")
		end
	end)

	local folRow = Instance.new("Frame", toolScroll)
	folRow.Size = UDim2.new(1, 0, 0, 32)
	folRow.BackgroundTransparency = 1
	folRow.LayoutOrder = 2

	local isFol = targetModel:GetAttribute("HxFollowing") or false
	local isFly = targetModel:GetAttribute("HxFlying") or false

	local followBtn = MakeBtn(folRow, "Đi Theo : " .. (isFol and "Bật" or "Tắt"), isFol and C.NenMuc or C.NenHop, UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0))
	followBtn.TextColor3 = isFol and C.TichBat or C.Chu
	Stroke(followBtn, C.VienNeon, 0.6)
	Ripple(followBtn)

	local flyBtn = MakeBtn(folRow, "Bay Theo : " .. (isFly and "Bật" or "Tắt"), isFly and C.NenMuc or C.NenHop, UDim2.new(0.48, -8, 1, 0), UDim2.new(0.52, 0, 0, 0))
	flyBtn.TextColor3 = isFly and C.TichBat or C.Chu
	Stroke(flyBtn, C.VienNeon, 0.6)
	Ripple(flyBtn)

	local lastPos = targetModel:GetPivot().Position
	local function RefreshFollowLoop()
		if Connections.Follow then Connections.Follow:Disconnect() Connections.Follow = nil end

		if targetModel:GetAttribute("HxFollowing") or targetModel:GetAttribute("HxFlying") then
			Connections.Follow = RunService.Heartbeat:Connect(function(dt)
				if targetModel and targetModel.PrimaryPart then
					local isFolAttr = targetModel:GetAttribute("HxFollowing")
					local isFlyAttr = targetModel:GetAttribute("HxFlying")

					if not isFolAttr and not isFlyAttr then
						if Connections.Follow then Connections.Follow:Disconnect() Connections.Follow = nil end
						return
					end

					local char = LocalPlayer.Character
					if char and char:FindFirstChild("HumanoidRootPart") then
						local hrp = char.HumanoidRootPart
						local scale = targetModel:GetScale()

						local currentPos = targetModel:GetPivot().Position
						local deltaY = currentPos.Y - lastPos.Y
						lastPos = currentPos
						local vY = deltaY / dt

						if isFolAttr then
							local targetCF = hrp.CFrame * CFrame.new(1.5, 3 * (scale - 1), 2)
							targetModel:PivotTo(targetModel:GetPivot():Lerp(targetCF, 0.1))

							local speed = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z).Magnitude
							if vY > 2 then PlayStateAnim(targetModel, "Jump")
							elseif vY < -2 then PlayStateAnim(targetModel, "Fall")
							elseif speed > 0.5 then PlayStateAnim(targetModel, "Walk")
							else PlayStateAnim(targetModel, "Idle") end

						elseif isFlyAttr then
							local speed = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z).Magnitude
							local isMoving = speed > 0.5

							local tiltX = isMoving and math.rad(-22) or 0
							local tilt = CFrame.Angles(tiltX, 0, 0)

							local bobAmp = isMoving and 0.15 or 0.5
							local bobSpeed = isMoving and 6 or 2.5
							local bobY = math.sin(tick() * bobSpeed) * bobAmp

							local targetCF = hrp.CFrame * CFrame.new(1.5, 3 * (scale - 1) + 3 + bobY, 1.5) * tilt
							local currentPivot = targetModel:GetPivot()
							local nextPivot = currentPivot:Lerp(targetCF, 0.1)
							targetModel:PivotTo(nextPivot)

							if vY > 1.5 then PlayStateAnim(targetModel, "Jump")
							elseif vY < -1.5 then PlayStateAnim(targetModel, "Fall")
							else PlayStateAnim(targetModel, "Idle") end
						end
					end
				else
					if Connections.Follow then Connections.Follow:Disconnect() Connections.Follow = nil end
				end
			end)
		end
	end

	followBtn.MouseButton1Click:Connect(function()
		local newState = not targetModel:GetAttribute("HxFollowing")
		targetModel:SetAttribute("HxFollowing", newState)
		if newState then targetModel:SetAttribute("HxFlying", false) end

		local fState = targetModel:GetAttribute("HxFollowing")
		local flState = targetModel:GetAttribute("HxFlying")

		followBtn.Text = "Đi Theo : " .. (fState and "Bật" or "Tắt")
		Tween(followBtn, 0.15, nil, nil, {BackgroundColor3 = fState and C.NenMuc or C.NenHop}):Play()
		followBtn.TextColor3 = fState and C.TichBat or C.Chu

		flyBtn.Text = "Bay Theo : " .. (flState and "Bật" or "Tắt")
		Tween(flyBtn, 0.15, nil, nil, {BackgroundColor3 = flState and C.NenMuc or C.NenHop}):Play()
		flyBtn.TextColor3 = flState and C.TichBat or C.Chu

		RefreshFollowLoop()
	end)

	flyBtn.MouseButton1Click:Connect(function()
		local newState = not targetModel:GetAttribute("HxFlying")
		targetModel:SetAttribute("HxFlying", newState)
		if newState then targetModel:SetAttribute("HxFollowing", false) end

		local fState = targetModel:GetAttribute("HxFollowing")
		local flState = targetModel:GetAttribute("HxFlying")

		followBtn.Text = "Đi Theo : " .. (fState and "Bật" or "Tắt")
		Tween(followBtn, 0.15, nil, nil, {BackgroundColor3 = fState and C.NenMuc or C.NenHop}):Play()
		followBtn.TextColor3 = fState and C.TichBat or C.Chu

		flyBtn.Text = "Bay Theo : " .. (flState and "Bật" or "Tắt")
		Tween(flyBtn, 0.15, nil, nil, {BackgroundColor3 = flState and C.NenMuc or C.NenHop}):Play()
		flyBtn.TextColor3 = flState and C.TichBat or C.Chu

		RefreshFollowLoop()
	end)

	local isHl = targetModel:GetAttribute("HxHighlight") or false
	local hlBtn = MakeBtn(toolScroll, "Highlight : " .. (isHl and "Bật" or "Tắt"), isHl and C.NenMuc or C.NenHop, UDim2.new(1, -8, 0, 32))
	hlBtn.LayoutOrder = 3
	hlBtn.TextColor3 = isHl and C.TichBat or C.Chu
	Stroke(hlBtn, C.VienNeon, 0.6)
	Ripple(hlBtn)
	hlBtn.MouseButton1Click:Connect(function()
		local newState = not targetModel:GetAttribute("HxHighlight")
		targetModel:SetAttribute("HxHighlight", newState)
		hlBtn.Text = "Highlight : " .. (newState and "Bật" or "Tắt")
		Tween(hlBtn, 0.15, nil, nil, {BackgroundColor3 = newState and C.NenMuc or C.NenHop}):Play()
		hlBtn.TextColor3 = newState and C.TichBat or C.Chu
		if newState then NhanVat.HighlightModel(targetModel, C.VienNeon, true) else NhanVat.HighlightModel(targetModel, nil, false) end
	end)

	local isSpin = targetModel:GetAttribute("HxSpinning") or false
	local spinBtn = MakeBtn(toolScroll, "Xoay Mục Tiêu : " .. (isSpin and "Bật" or "Tắt"), isSpin and C.NenMuc or C.NenHop, UDim2.new(1, -8, 0, 32))
	spinBtn.LayoutOrder = 4
	spinBtn.TextColor3 = isSpin and C.TichBat or C.Chu
	Stroke(spinBtn, C.VienNeon, 0.6)
	Ripple(spinBtn)
	spinBtn.MouseButton1Click:Connect(function()
		local newState = not targetModel:GetAttribute("HxSpinning")
		targetModel:SetAttribute("HxSpinning", newState)
		spinBtn.Text = "Xoay Mục Tiêu : " .. (newState and "Bật" or "Tắt")
		Tween(spinBtn, 0.15, nil, nil, {BackgroundColor3 = newState and C.NenMuc or C.NenHop}):Play()
		spinBtn.TextColor3 = newState and C.TichBat or C.Chu
		if newState then
			if Connections.Spin then Connections.Spin:Disconnect() end
			Connections.Spin = RunService.Heartbeat:Connect(function(dt)
				if targetModel and targetModel.PrimaryPart and targetModel:GetAttribute("HxSpinning") then
					targetModel:PivotTo(targetModel:GetPivot() * CFrame.Angles(0, dt * 2, 0))
				else
					if Connections.Spin then Connections.Spin:Disconnect() Connections.Spin = nil end
				end
			end)
		else
			if Connections.Spin then Connections.Spin:Disconnect() Connections.Spin = nil end
		end
	end)

	local delBtn = MakeBtn(toolScroll, "Xóa Model Này", C.NenMuc, UDim2.new(1, -8, 0, 32))
	delBtn.LayoutOrder = 5
	Stroke(delBtn, C.VienNeon, 0.6)
	Ripple(delBtn)
	delBtn.MouseButton1Click:Connect(function()
		if targetModel == State.CurrentDummy then NhanVat.RemoveDummy()
		else
			targetModel:Destroy()
			ThongBao("Đã Xóa", "Mục tiêu đã bị xóa!")
		end
		task.delay(0.3, DongGiaoDien)
	end)

	toolScroll.Size = UDim2.new(1, 0, 0, math.clamp(toolLayout.AbsoluteContentSize.Y + 4, 0, 300))

	RefreshFollowLoop()
	SwitchTab(1)
end

function NhanVat.GetDummy() return State.CurrentDummy end
function NhanVat.GetSelectedModel() return State.SelectedModel end
function NhanVat.ClearSelectedModel()
	if State.SelectedModel then
		NhanVat.HighlightModel(State.SelectedModel, nil, false)
	end
	State.SelectedModel = nil
	NhanVat.ToggleSelectMode(false)
end

return NhanVat
