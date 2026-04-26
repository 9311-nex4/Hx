local LogicKhoi = {}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ColService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local vec3, cf, udim2 = Vector3.new, CFrame.new, UDim2.new
local udim, color3 = UDim.new, Color3.fromRGB
local mRound, mRad, mAbs, mDeg = math.round, math.rad, math.abs, math.deg
local ins, rem, clr = table.insert, table.remove, table.clear
local next_fn = next

local CAIDAT = {
	TAG = "BuildSystem",
	MAX_HISTORY = 50,
	LUOI_MOVE = 1,
	LUOI_ROT = 15,
	C_NEN = color3(20, 20, 25),
	C_NEN_PHU = color3(35, 35, 40),
	C_VIEN = color3(255, 255, 255),
	C_CHU = color3(240, 240, 240),
	C_BTN = color3(225, 225, 225),
	C_ICON = color3(255, 255, 255),
	C_ACT = color3(0, 150, 255),
	C_SCALE = color3(255, 160, 0),
	C_OFF = color3(100, 100, 100),
	C_HUY = color3(220, 50, 50),
	C_BOX = color3(255, 255, 255),
	SIZE_BTN = 44,
	SIZE_SUB = 36,
	SCREEN_H = 800,
	TW_UI = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	TW_ICON = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	TW_POP = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	ICONS = {
		MOVE = "98501712328327", SCALE = "131983126233194", ROTATE = "94475561845407",
		GRID = "140476097300003", SHAPE = "77461488191679", UNDO = "120782076898439",
		REDO = "124647276241633", ARROW = "rbxassetid://6031091004", SEL = "109826670489779",
		SEAT = "119465930347884", WELD = "rbxassetid://101608134171705",
		SPEED = "rbxassetid://107628976464127", PROP = "rbxassetid://115321933884958",
		COLLISION = "rbxassetid://139998791687076",
	},
	ANIM_SIT = "rbxassetid://2506281703",
}

local State = {
	DangChon = {},
	Tool = 1,
	ModeScale = 1,
	BatLuoi = true,
	DaChon = false,
	ModeGhe = 0,
	ShapeIdx = 1,
	ShowProp = false,
}

local History = { Undo = {}, Redo = {}, Start = {} }
local Gizmos = { Move = nil, Scale = nil, Rot = nil }
local UI = { Container = nil, Main = nil, Sub = nil, List = nil, MoRong = false, Pos = udim2(1, -70, 0.5, 0), P_Speed = nil, P_Prop = nil }
local DataGoc = { CF = nil, Size = nil }
local TrackAnim = nil

local RAY_PARAMS_XE = RaycastParams.new()
RAY_PARAMS_XE.FilterType = Enum.RaycastFilterType.Exclude

local ListShape = { Enum.PartType.Block, Enum.PartType.Ball, Enum.PartType.Cylinder, Enum.PartType.Wedge, Enum.PartType.CornerWedge }
local ColorShape = { color3(0,150,255), color3(255,60,60), color3(60,255,60), color3(255,255,0), color3(180,0,255) }

LogicKhoi.SuKienThayDoi = Instance.new("BindableEvent")

local CapNhatUI, UpdateBox, TaoGizmo, HieuUngPop, XoaGizmo, ToggleUI, HuyChon, ToggleSpeed, ToggleProp, ToggleXuyenTuong

local function LuuCfg()
	if LogicKhoi.OnConfigChanged then LogicKhoi.OnConfigChanged() end
end

local function TaoScale(obj)
	if not obj then return end
	local s = obj:FindFirstChild("UIScale") or Instance.new("UIScale", obj)
	s.Name = "UIScale"
	local function Update()
		if not Camera then return end
		s.Scale = math.clamp(Camera.ViewportSize.Y / CAIDAT.SCREEN_H, 0.7, 1.5)
	end
	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(Update); Update()
	return s
end

local function PlayTw(obj, info, props)
	if obj then TweenService:Create(obj, info, props):Play() end
end

local function Snap(so, luoi)
	return State.BatLuoi and mRound(so / luoi) * luoi or so
end

local function LayState()
	local d = {}
	for obj in next_fn, State.DangChon do
		if obj:IsA("BasePart") then
			d[obj] = { CF = obj.CFrame, Size = obj.Size, Shape = obj.Shape, Parent = obj.Parent }
		end
	end
	return d
end

local function SetState(data)
	for obj, info in next_fn, data do
		if obj and obj.Parent then
			obj.CFrame = info.CF; obj.Size = info.Size
			if obj:IsA("Part") then obj.Shape = info.Shape end
		end
	end
end

local function LuuHistory(cu, moi)
	local change = false
	for k, v in next_fn, moi do
		if not cu[k] or cu[k].CF ~= v.CF or cu[k].Size ~= v.Size or cu[k].Shape ~= v.Shape then
			change = true; break
		end
	end
	if change then
		ins(History.Undo, cu)
		if #History.Undo > CAIDAT.MAX_HISTORY then rem(History.Undo, 1) end
		clr(History.Redo)
	end
end

local function DoHistory(nguon, dich)
	if #nguon == 0 then return end
	local data = rem(nguon)
	ins(dich, LayState())
	SetState(data)
	UpdateBox()
end

local function XuLyNgoi(ghe)
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChild("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	local p = ghe:FindFirstChild("Prompt")
	if p then p.Enabled = false end

	for _, track in ipairs(hum:GetPlayingAnimationTracks()) do track:Stop() end

	root.CFrame = ghe.CFrame * cf(0, (ghe.Size.Y * 0.5) + hum.HipHeight, 0)
	local w = Instance.new("WeldConstraint")
	w.Part0 = root; w.Part1 = ghe; w.Parent = root

	local seatOffset = ghe.CFrame:Inverse() * root.CFrame

	if TrackAnim then TrackAnim:Stop() end
	local a = Instance.new("Animation")
	a.AnimationId = CAIDAT.ANIM_SIT
	TrackAnim = hum:LoadAnimation(a)
	TrackAnim:Play()

	local mode = ghe:GetAttribute("ModeGhe")
	local active = true
	local cMove, cState, cJump

	hum.Sit = false; hum.PlatformStand = true; hum.AutoRotate = false

	local function Exit()
		if not active then return end
		active = false
		if cMove then cMove:Disconnect() end
		if cState then cState:Disconnect() end
		if cJump then cJump:Disconnect() end
		if TrackAnim then TrackAnim:Stop() end
		if p then p.Enabled = true end
		if w then w:Destroy() end
		task.defer(function()
			hum.PlatformStand = false; hum.AutoRotate = true
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			if root and ghe.Parent then
				root.CFrame = ghe.CFrame * cf(0, (ghe.Size.Y * 0.5) + 4, 0)
				root.Velocity = vec3(0, 50, 0)
			end
		end)
	end

	cJump = UIS.JumpRequest:Connect(Exit)

	if mode == 2 then
		local spd = ghe:GetAttribute("Speed") or 20
		local smooth = 0.15

		RAY_PARAMS_XE.FilterDescendantsInstances = { char, ghe }

		local targetHoverHeight = 2
		local startRay = Workspace:Raycast(ghe.Position, vec3(0, -100, 0), RAY_PARAMS_XE)
		if startRay then
			targetHoverHeight = math.max(startRay.Distance - (ghe.Size.Y * 0.5), 0.2)
		end

		local halfSizeY = ghe.Size.Y * 0.5

		cMove = RunService.Heartbeat:Connect(function(dt)
			if not active or not ghe.Parent or not w.Parent then Exit() return end
			spd = ghe:GetAttribute("Speed") or 20
			local isGhost = ghe:GetAttribute("XuyenTuong")
			if isGhost == nil then isGhost = true end

			local dir = hum.MoveDirection
			local pos = ghe.Position
			local rayDown = Workspace:Raycast(pos, vec3(0, -50, 0), RAY_PARAMS_XE)
			local hoverOffset = 0

			if rayDown then
				local currentDist = rayDown.Distance - halfSizeY
				if not (currentDist > targetHoverHeight and (currentDist - targetHoverHeight) > 8) then
					local targetY = rayDown.Position.Y + halfSizeY + targetHoverHeight
					hoverOffset = (targetY - pos.Y) * 0.2
				end
			end

			if dir.Magnitude > 0.1 then
				local moveVec = dir * (spd * dt)
				local choPhepDi = true
				if not isGhost then
					local ray = Workspace:Raycast(pos, moveVec.Unit * (moveVec.Magnitude + 2), RAY_PARAMS_XE)
					if ray then choPhepDi = false end
				end
				if choPhepDi then
					local look = CFrame.lookAt(pos, pos + dir)
					local nCF = ghe.CFrame:Lerp(look, smooth)
					ghe.CFrame = nCF - nCF.Position + (pos + moveVec) + vec3(0, hoverOffset, 0)
				elseif mAbs(hoverOffset) > 0.001 then
					ghe.Position = pos + vec3(0, hoverOffset, 0)
				end
			elseif mAbs(hoverOffset) > 0.001 then
				ghe.Position = pos + vec3(0, hoverOffset, 0)
			end

			root.CFrame = ghe.CFrame * seatOffset
		end)
	end

	cState = hum.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Dead then Exit() end
	end)
end

local function SetGhe(khoi, mode)
	if not khoi:IsA("BasePart") then return end
	local p = khoi:FindFirstChild("Prompt")
	khoi:SetAttribute("ModeGhe", mode)

	if mode == 2 then
		if not khoi:GetAttribute("Speed") then khoi:SetAttribute("Speed", 50) end
		if khoi:GetAttribute("XuyenTuong") == nil then khoi:SetAttribute("XuyenTuong", true) end
	end

	if mode == 0 then
		if p then p:Destroy() end
		khoi:SetAttribute("IsGhe", nil)
	else
		if not p then
			p = Instance.new("ProximityPrompt")
			p.Name = "Prompt"; p.HoldDuration = 0; p.MaxActivationDistance = 50; p.Parent = khoi
			p.Triggered:Connect(function() XuLyNgoi(khoi) end)
		end
		p.ObjectText = mode == 1 and "Ghế" or "Xe"
		p.ActionText = mode == 1 and "Ngồi" or "Lái"
		khoi:SetAttribute("IsGhe", true)
	end
end

HieuUngPop = function(obj)
	if not obj or not obj:IsA("BasePart") then return end
	local sz = obj.Size
	local t = TweenService:Create(obj, CAIDAT.TW_POP, { Size = sz * 1.1 })
	t:Play()
	t.Completed:Once(function() PlayTw(obj, TweenInfo.new(0.15), { Size = sz }) end)
end

CapNhatUI = function()
	if not UI.List then return end
	local twIcon, cAct, cVien, cScale, cOff = CAIDAT.TW_ICON, CAIDAT.C_ACT, CAIDAT.C_VIEN, CAIDAT.C_SCALE, CAIDAT.C_OFF
	for _, child in ipairs(UI.List:GetChildren()) do
		if child:IsA("ImageButton") and child.Name:find("Tool_") then
			local id = tonumber(child.Name:match("%d+"))
			local sel = (id == State.Tool)
			local col = (id == 2 and State.ModeScale == 2) and cScale or cAct
			local str, ico = child:FindFirstChild("Stroke"), child:FindFirstChild("Icon")
			PlayTw(child, twIcon, { BackgroundTransparency = sel and 0 or 0.3 })
			if str then PlayTw(str, twIcon, { Color = sel and col or cVien, Transparency = sel and 0 or 1 }) end
			if ico then PlayTw(ico, twIcon, { ImageColor3 = Color3.new(1,1,1) }) end
		end
	end

	if not UI.Sub then return end

	local function SetIcon(name, active, okCol)
		local btn = UI.Sub:FindFirstChild(name)
		if not btn then return end
		local ico, str = btn:FindFirstChild("Icon"), btn:FindFirstChild("Stroke")
		local cl = active and (okCol or cAct) or cOff
		if ico then PlayTw(ico, twIcon, { ImageColor3 = cl }) end
		if str then PlayTw(str, twIcon, { Color = cl, Transparency = active and 0 or 0.5 }) end
	end

	SetIcon("BtnGrid", State.BatLuoi)
	SetIcon("BtnMulti", State.DaChon)
	SetIcon("BtnProp", State.ShowProp)

	local isModel = false
	for k in next_fn, State.DangChon do
		if k:IsA("Model") then isModel = true; break end
	end
	SetIcon("BtnWeld", isModel)

	local bSeat = UI.Sub:FindFirstChild("BtnSeat")
	if bSeat then
		local md = State.ModeGhe
		local cIcon, cStr, tr = cOff, cVien, 1
		if md == 1 then cIcon = cAct; cStr = cAct; tr = 0
		elseif md == 2 then cIcon = cScale; cStr = cScale; tr = 0 end
		PlayTw(bSeat.Icon, twIcon, { ImageColor3 = cIcon })
		PlayTw(bSeat.Stroke, twIcon, { Color = cStr, Transparency = tr })
	end

	local bSpeed = UI.Sub:FindFirstChild("BtnSpeed")
	if bSpeed then bSpeed.Visible = (State.ModeGhe == 2) end

	local bColl = UI.Sub:FindFirstChild("BtnColl")
	if bColl then
		bColl.Visible = (State.ModeGhe == 2)
		local obj = next_fn(State.DangChon)
		local isGhost = (obj == nil) or (obj:GetAttribute("XuyenTuong") ~= false)
		local cl = isGhost and cAct or CAIDAT.C_HUY
		local ico, str = bColl:FindFirstChild("Icon"), bColl:FindFirstChild("Stroke")
		if ico then PlayTw(ico, twIcon, { ImageColor3 = cl }) end
		if str then PlayTw(str, twIcon, { Color = cl, Transparency = 0 }) end
	end
end

HuyChon = function()
	clr(State.DangChon)
	ToggleUI(false); XoaGizmo()
	if UI.Sub then UI.Sub.Visible = false end
	if UI.P_Speed then UI.P_Speed:Destroy(); UI.P_Speed = nil end
	if UI.P_Prop then UI.P_Prop:Destroy(); UI.P_Prop = nil; State.ShowProp = false end
	CapNhatUI()
	for _, v in ipairs(ColService:GetTagged(CAIDAT.TAG)) do
		local b = v:FindFirstChild("SelBox"); if b then b:Destroy() end
	end
end

XoaGizmo = function()
	for k, v in next_fn, Gizmos do if v then v:Destroy(); Gizmos[k] = nil end end
end

TaoGizmo = function(target)
	XoaGizmo()
	local gui = LocalPlayer.PlayerGui
	local f = gui:FindFirstChild("Gizmos") or Instance.new("Folder", gui)
	f.Name = "Gizmos"

	local function Bind(h)
		h.MouseButton1Down:Connect(function() History.Start = LayState() end)
		h.MouseButton1Up:Connect(function()
			LuuHistory(History.Start, LayState())
			if UI.P_Prop and UI.P_Prop.Visible then ToggleProp() end
		end)
	end

	local t = State.Tool
	if t == 1 then
		local h = Instance.new("Handles", f)
		h.Adornee = target; h.Style = "Movement"; h.Color3 = color3(255,60,60); Gizmos.Move = h; Bind(h)
		h.MouseButton1Down:Connect(function()
			if not target:GetAttribute("LockMove") then DataGoc.CF = target.CFrame end
		end)
		h.MouseDrag:Connect(function(face, dist)
			if target:GetAttribute("LockMove") or not DataGoc.CF then return end
			target.CFrame = DataGoc.CF + (DataGoc.CF:VectorToWorldSpace(Vector3.FromNormalId(face)) * Snap(dist, CAIDAT.LUOI_MOVE))
			target.Anchored = true
		end)
	elseif t == 2 then
		local h = Instance.new("Handles", f)
		h.Adornee = target; h.Style = "Resize"
		h.Color3 = State.ModeScale == 2 and CAIDAT.C_SCALE or color3(60,160,255); Gizmos.Scale = h; Bind(h)
		h.MouseButton1Down:Connect(function() DataGoc.Size = target.Size; DataGoc.CF = target.CFrame end)
		h.MouseDrag:Connect(function(face, dist)
			if not DataGoc.Size then return end
			dist = Snap(dist, CAIDAT.LUOI_MOVE)
			local ax = Vector3.FromNormalId(face)
			local nSz = DataGoc.Size + (vec3(mAbs(ax.X), mAbs(ax.Y), mAbs(ax.Z)) * dist)
			if nSz.X < 0.5 or nSz.Y < 0.5 or nSz.Z < 0.5 then return end
			target.Size = nSz
			target.CFrame = State.ModeScale == 1 and DataGoc.CF + (DataGoc.CF:VectorToWorldSpace(ax) * (dist * 0.5)) or DataGoc.CF
		end)
	elseif t == 3 then
		local h = Instance.new("ArcHandles", f)
		h.Adornee = target; h.Axes = Axes.new(Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z); Gizmos.Rot = h; Bind(h)
		h.MouseButton1Down:Connect(function() DataGoc.CF = target.CFrame end)
		h.MouseDrag:Connect(function(ax, ag)
			if not DataGoc.CF then return end
			local r = mRad(Snap(mDeg(ag), CAIDAT.LUOI_ROT))
			target.CFrame = DataGoc.CF * CFrame.Angles(
				ax == Enum.Axis.X and r or 0,
				ax == Enum.Axis.Y and r or 0,
				ax == Enum.Axis.Z and r or 0
			)
			target.Anchored = true
		end)
	end
end

UpdateBox = function()
	for _, v in ipairs(ColService:GetTagged(CAIDAT.TAG)) do
		local b = v:FindFirstChild("SelBox"); if b then b:Destroy() end
	end
	local sl, rep = 0, nil
	for k in next_fn, State.DangChon do
		sl += 1
		local t = k:IsA("Model") and k.PrimaryPart or k
		if t then
			local b = Instance.new("SelectionBox")
			b.Name = "SelBox"; b.Adornee = t; b.LineThickness = 0.08
			b.Color3 = CAIDAT.C_BOX; b.Parent = t; rep = t
		end
	end
	if sl > 0 then
		if not UI.Container or not UI.Container.Visible then ToggleUI(true) end
		if sl == 1 then TaoGizmo(rep) else XoaGizmo() end
	else
		ToggleUI(false); XoaGizmo()
	end
	CapNhatUI()
end

ToggleUI = function(show)
	if not UI.Container then return end
	if show then
		UI.Container.Visible = true
		UI.Main:TweenSize(udim2(1,0,0, 32 + (CAIDAT.SIZE_BTN*3) + 70), "Out", "Back", 0.35)
	else
		UI.Main:TweenSize(udim2(1,0,0,0), "In", "Quart", 0.3, true, function() UI.Container.Visible = false end)
		if UI.MoRong then
			UI.MoRong = false
			if UI.Sub then UI.Sub.Visible = false end
			PlayTw(UI.Arrow, CAIDAT.TW_UI, { Rotation = 90 })
		end
	end
end

local function MakeDragConn(frame)
	local drag, start, startP
	local c1 = frame.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = true; start = i.Position; startP = frame.Parent.Position
		end
	end)
	local c2 = UIS.InputChanged:Connect(function(i)
		if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - start
			frame.Parent.Position = udim2(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y)
		end
	end)
	local c3 = UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = false
		end
	end)
	return function() c1:Disconnect(); c2:Disconnect(); c3:Disconnect() end
end

local function TaoUI()
	if UI.Container then UI.Container:Destroy() end
	local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
	gui.Name = "BuildSystem_V2"; gui.ResetOnSpawn = false

	local function Make(cls, props, par)
		local o = Instance.new(cls)
		for k, v in next_fn, props do o[k] = v end
		if par then o.Parent = par end
		return o
	end

	local con = Make("Frame", { AnchorPoint=Vector2.new(0.5,0.5), Position=UI.Pos, Size=udim2(0,CAIDAT.SIZE_BTN+20,0,300), BackgroundTransparency=1, Visible=false }, gui)
	TaoScale(con)

	local drag = Make("TextButton", { BackgroundColor3=CAIDAT.C_NEN_PHU, Size=udim2(1,0,0,24), BackgroundTransparency=0.2, Text="=", TextColor3=CAIDAT.C_CHU, TextSize=32 }, nil)
	Make("UICorner", { CornerRadius=udim(0,8) }, drag)

	local isDrag, start, startPos
	drag.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			isDrag=true; start=i.Position; startPos=con.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if isDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local d = i.Position-start
			con.Position = udim2(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
			UI.Pos = con.Position
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			isDrag = false
		end
	end)

	local main = Make("Frame", { Size=udim2(1,0,0,0), BackgroundColor3=CAIDAT.C_NEN, BackgroundTransparency=0.2, ClipsDescendants=true, ZIndex=10 }, con)
	Make("UICorner", { CornerRadius=udim(0,10) }, main); Make("UIStroke", { Color=CAIDAT.C_VIEN, Thickness=1.5 }, main)
	drag.Parent = main

	local list = Make("Frame", { BackgroundTransparency=1, Size=udim2(1,0,1,-60), Position=udim2(0,0,0,32), ZIndex=15 }, main)
	Make("UIListLayout", { HorizontalAlignment="Center", Padding=udim(0,10), SortOrder="LayoutOrder" }, list)

	local function MakeTool(icon, id, ord)
		local btn = Make("ImageButton", { Name="Tool_"..id, LayoutOrder=ord, Size=udim2(0,CAIDAT.SIZE_BTN,0,CAIDAT.SIZE_BTN), BackgroundColor3=CAIDAT.C_BTN, BackgroundTransparency=0.3, Image="", ZIndex=20 }, list)
		Make("UICorner", { CornerRadius=udim(0,8) }, btn); Make("UIStroke", { Name="Stroke", Color=CAIDAT.C_VIEN, Transparency=1, Thickness=1.5 }, btn)
		Make("ImageLabel", { Name="Icon", BackgroundTransparency=1, Size=udim2(0.65,0,0.65,0), Position=udim2(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), Image="rbxassetid://"..icon, ImageColor3=CAIDAT.C_ICON, ZIndex=25 }, btn)
		btn.MouseButton1Click:Connect(function()
			if id==2 and State.Tool==2 then State.ModeScale = State.ModeScale==1 and 2 or 1 else State.ModeScale=1; State.Tool=id end
			CapNhatUI(); local t = next_fn(State.DangChon); if t then TaoGizmo(t:IsA("Model") and t.PrimaryPart or t) end
			LuuCfg()
		end)
	end
	MakeTool(CAIDAT.ICONS.MOVE,1,1); MakeTool(CAIDAT.ICONS.SCALE,2,2); MakeTool(CAIDAT.ICONS.ROTATE,3,3)

	local cl = Make("TextButton", { Text="ĐÓNG", Size=udim2(1,-24,0,28), Position=udim2(0.5,0,1,-12), AnchorPoint=Vector2.new(0.5,1), BackgroundColor3=CAIDAT.C_HUY, Font="GothamBlack", TextColor3=color3(255,255,255), TextSize=11, ZIndex=20 }, main)
	Make("UICorner", { CornerRadius=udim(0,6) }, cl); cl.MouseButton1Click:Connect(HuyChon)

	local subW = (CAIDAT.SIZE_SUB*3) + 16 + 10
	local subH = (CAIDAT.SIZE_SUB*4) + 24 + 16

	local sub = Make("ScrollingFrame", { Name="Sub", AnchorPoint=Vector2.new(0.4,0.85), Position=udim2(0,-10,0.5,0), Size=udim2(0,subW,0,subH), BackgroundColor3=CAIDAT.C_NEN_PHU, BackgroundTransparency=0.2, Visible=false, ZIndex=8, CanvasSize=udim2(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=4, BorderSizePixel=0 }, con)
	Make("UICorner", { CornerRadius=udim(0,10) }, sub); Make("UIStroke", { Color=CAIDAT.C_VIEN }, sub)
	Make("UIGridLayout", { CellSize=udim2(0,CAIDAT.SIZE_SUB,0,CAIDAT.SIZE_SUB), CellPadding=udim2(0,8,0,8), HorizontalAlignment="Center", VerticalAlignment="Top", SortOrder="LayoutOrder" }, sub)
	Make("UIPadding", { PaddingTop=udim(0,8), PaddingBottom=udim(0,8) }, sub)

	local function MakeSub(name, icon, ord, func)
		local btn = Make("ImageButton", { Name=name, LayoutOrder=ord, BackgroundColor3=CAIDAT.C_BTN, BackgroundTransparency=0.3, ZIndex=12 }, sub)
		Make("UICorner", { CornerRadius=udim(0,6) }, btn); Make("UIStroke", { Name="Stroke", Color=CAIDAT.C_VIEN, Transparency=0.5, Thickness=2.5 }, btn)
		Make("ImageLabel", { Name="Icon", Size=udim2(0.7,0,0.7,0), Position=udim2(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, Image=icon, ImageColor3=CAIDAT.C_ICON, ZIndex=13 }, btn)
		if func then btn.MouseButton1Click:Connect(func) end
	end

	MakeSub("BtnShape", "rbxassetid://"..CAIDAT.ICONS.SHAPE, 1, function()
		local old = LayState()
		State.ShapeIdx = (State.ShapeIdx % #ListShape) + 1
		local shp, col = ListShape[State.ShapeIdx], ColorShape[State.ShapeIdx]
		for k in next_fn, State.DangChon do if k:IsA("Part") then k.Shape = shp end end
		LuuHistory(old, LayState())
		local n = sub:FindFirstChild("BtnShape")
		if n and n:FindFirstChild("Stroke") then PlayTw(n.Stroke, TweenInfo.new(0.2), { Color=col, Transparency=0 }) end
		LuuCfg()
	end)
	MakeSub("BtnGrid", "rbxassetid://"..CAIDAT.ICONS.GRID, 2, function() State.BatLuoi = not State.BatLuoi; CapNhatUI(); LuuCfg() end)
	MakeSub("BtnProp", CAIDAT.ICONS.PROP, 3, ToggleProp)
	MakeSub("BtnMulti", "rbxassetid://"..CAIDAT.ICONS.SEL, 4, function() State.DaChon = not State.DaChon; CapNhatUI(); LuuCfg() end)
	MakeSub("BtnUndo", "rbxassetid://"..CAIDAT.ICONS.UNDO, 5, function() DoHistory(History.Undo, History.Redo) end)
	MakeSub("BtnRedo", "rbxassetid://"..CAIDAT.ICONS.REDO, 6, function() DoHistory(History.Redo, History.Undo) end)
	MakeSub("BtnWeld", CAIDAT.ICONS.WELD, 7, function()
		local isM = false; for k in next_fn, State.DangChon do if k:IsA("Model") then isM = true; break end end
		if isM then LogicKhoi.ThaoKhoi() else LogicKhoi.HanKhoi() end
	end)
	MakeSub("BtnSeat", "rbxassetid://"..CAIDAT.ICONS.SEAT, 8, function()
		State.ModeGhe = (State.ModeGhe + 1) % 3
		for k in next_fn, State.DangChon do SetGhe(k, State.ModeGhe) end
		CapNhatUI()
	end)
	MakeSub("BtnSpeed", CAIDAT.ICONS.SPEED, 9, ToggleSpeed)
	MakeSub("BtnColl", CAIDAT.ICONS.COLLISION, 10, ToggleXuyenTuong)

	local nS = sub:FindFirstChild("BtnShape")
	if nS then nS.Stroke.Color = ColorShape[State.ShapeIdx]; nS.Stroke.Transparency = 0 end

	local more = Make("ImageButton", { Name="BtnMore", Size=udim2(0,22,0,44), Position=udim2(0,-15,0.45,0), AnchorPoint=Vector2.new(1.5,1), BackgroundColor3=CAIDAT.C_NEN, BackgroundTransparency=0.2, ZIndex=9 }, con)
	Make("UICorner", { CornerRadius=udim(0,6) }, more); Make("UIStroke", { Color=CAIDAT.C_VIEN }, more)
	local arr = Make("ImageLabel", { Size=udim2(0.8,0,0.8,0), Position=udim2(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, Image=CAIDAT.ICONS.ARROW, Rotation=90, ImageColor3=CAIDAT.C_ICON, ZIndex=10 }, more)

	more.MouseButton1Click:Connect(function()
		UI.MoRong = not UI.MoRong
		local ps = UI.MoRong and udim2(0, -((subW)+10), 0.5, 0) or udim2(0, 0, 0.5, 0)
		sub.Visible = true
		sub:TweenPosition(ps, UI.MoRong and "Out" or "In", "Back", 0.35, true, function() if not UI.MoRong then sub.Visible = false end end)
		PlayTw(arr, CAIDAT.TW_UI, { Rotation = UI.MoRong and -90 or 90 })
	end)

	UI.Container = con; UI.Main = main; UI.Sub = sub
	UI.List = list; UI.Arrow = arr
	CapNhatUI()
end

ToggleXuyenTuong = function()
	for k in next_fn, State.DangChon do
		local cur = k:GetAttribute("XuyenTuong")
		k:SetAttribute("XuyenTuong", not (cur == nil and true or cur))
	end
	CapNhatUI()
end

ToggleSpeed = function()
	if UI.P_Speed then UI.P_Speed:Destroy(); UI.P_Speed = nil; return end
	local par = UI.Container and UI.Container.Parent
	if not par then return end

	local f = Instance.new("Frame", par)
	f.Size = udim2(0, 220, 0, 135)
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = udim2(0.5, 0, 0.5, 0)
	f.BackgroundColor3 = CAIDAT.C_NEN
	Instance.new("UICorner", f).CornerRadius = udim(0, 10)
	local strk = Instance.new("UIStroke", f)
	strk.Color = CAIDAT.C_VIEN
	strk.Transparency = 0.5
	TaoScale(f)

	local header = Instance.new("Frame", f)
	header.Size = udim2(1, 0, 0, 36)
	header.BackgroundColor3 = CAIDAT.C_NEN_PHU
	header.BorderSizePixel = 0
	Instance.new("UICorner", header).CornerRadius = udim(0, 10)
	local hFiller = Instance.new("Frame", header)
	hFiller.Size = udim2(1, 0, 0, 10)
	hFiller.Position = udim2(0, 0, 1, -10)
	hFiller.BackgroundColor3 = CAIDAT.C_NEN_PHU
	hFiller.BorderSizePixel = 0

	local t = Instance.new("TextLabel", header)
	t.Text = " Tốc Độ Xe"
	t.Size = udim2(1, -40, 1, 0)
	t.BackgroundTransparency = 1
	t.TextColor3 = CAIDAT.C_CHU
	t.Font = Enum.Font.GothamBold
	t.TextSize = 13
	t.TextXAlignment = Enum.TextXAlignment.Left

	local x = Instance.new("TextButton", header)
	x.Text = "X"
	x.Size = udim2(0, 24, 0, 24)
	x.Position = udim2(1, -30, 0.5, -12)
	x.BackgroundColor3 = CAIDAT.C_HUY
	x.TextColor3 = color3(255, 255, 255)
	x.Font = Enum.Font.GothamBlack
	x.TextSize = 11
	x.AutoButtonColor = false
	Instance.new("UICorner", x).CornerRadius = udim(0, 6)
	x.MouseEnter:Connect(function() PlayTw(x, TweenInfo.new(0.15), {BackgroundColor3 = color3(255, 80, 80)}) end)
	x.MouseLeave:Connect(function() PlayTw(x, TweenInfo.new(0.15), {BackgroundColor3 = CAIDAT.C_HUY}) end)
	x.MouseButton1Click:Connect(function() f:Destroy(); UI.P_Speed = nil end)

	local ip = Instance.new("TextBox", f)
	ip.Size = udim2(0.8, 0, 0, 32)
	ip.Position = udim2(0.1, 0, 0, 50)
	ip.BackgroundColor3 = CAIDAT.C_NEN_PHU
	ip.TextColor3 = color3(255, 255, 255)
	ip.Font = Enum.Font.Gotham
	ip.TextSize = 12
	ip.PlaceholderText = "Nhập số (VD: 20)"
	ip.ClearTextOnFocus = false
	Instance.new("UICorner", ip).CornerRadius = udim(0, 6)
	local ipStrk = Instance.new("UIStroke", ip)
	ipStrk.Color = CAIDAT.C_VIEN
	ipStrk.Transparency = 0.6

	local g = next_fn(State.DangChon)
	if g then ip.Text = tostring(g:GetAttribute("Speed") or 50) end

	local btn = Instance.new("TextButton", f)
	btn.Text = "LƯU"
	btn.Size = udim2(0.8, 0, 0, 32)
	btn.Position = udim2(0.1, 0, 0, 92)
	btn.BackgroundColor3 = CAIDAT.C_ACT
	btn.TextColor3 = color3(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = udim(0, 6)
	btn.MouseEnter:Connect(function() PlayTw(btn, TweenInfo.new(0.15), {BackgroundColor3 = color3(0, 180, 255)}) end)
	btn.MouseLeave:Connect(function() PlayTw(btn, TweenInfo.new(0.15), {BackgroundColor3 = CAIDAT.C_ACT}) end)

	btn.MouseButton1Click:Connect(function()
		local s = tonumber(ip.Text)
		if s then for k in next_fn, State.DangChon do k:SetAttribute("Speed", s) end end
		f:Destroy(); UI.P_Speed = nil
	end)

	local disconnectDrag = MakeDragConn(header)
	f.Destroying:Once(disconnectDrag)

	UI.P_Speed = f
end

ToggleProp = function()
	if UI.P_Prop then
		UI.P_Prop:Destroy(); UI.P_Prop = nil
		State.ShowProp = false; CapNhatUI(); return
	end

	State.ShowProp = true; CapNhatUI()
	local obj = next_fn(State.DangChon); if not obj then return end

	local par = UI.Container and UI.Container.Parent
	if not par then return end

	local f = Instance.new("Frame", par)
	f.Name = "PropPanel"
	f.Size = udim2(0, 260, 0, 380)
	f.AnchorPoint = Vector2.new(1, 0.5)
	f.Position = udim2(0.95, 0, 0.5, 0)
	f.BackgroundColor3 = CAIDAT.C_NEN
	f.ClipsDescendants = true
	Instance.new("UICorner", f).CornerRadius = udim(0, 10)
	local strk = Instance.new("UIStroke", f)
	strk.Color = CAIDAT.C_VIEN
	strk.Transparency = 0.5
	strk.Thickness = 1.2
	TaoScale(f)

	local header = Instance.new("Frame", f)
	header.Size = udim2(1, 0, 0, 40)
	header.BackgroundColor3 = CAIDAT.C_NEN_PHU
	header.BorderSizePixel = 0
	Instance.new("UICorner", header).CornerRadius = udim(0, 10)
	local hFiller = Instance.new("Frame", header)
	hFiller.Size = udim2(1, 0, 0, 10)
	hFiller.Position = udim2(0, 0, 1, -10)
	hFiller.BackgroundColor3 = CAIDAT.C_NEN_PHU
	hFiller.BorderSizePixel = 0

	local title = Instance.new("TextLabel", header)
	title.Text = " Thuộc Tính: " .. (obj.Name:sub(1,10))
	title.Size = udim2(1, -40, 1, 0)
	title.BackgroundTransparency = 1
	title.TextColor3 = CAIDAT.C_CHU
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left

	local btnClose = Instance.new("TextButton", header)
	btnClose.Size = udim2(0, 26, 0, 26)
	btnClose.Position = udim2(1, -33, 0.5, -13)
	btnClose.BackgroundColor3 = CAIDAT.C_HUY
	btnClose.Text = "X"
	btnClose.TextColor3 = color3(255, 255, 255)
	btnClose.Font = Enum.Font.GothamBlack
	btnClose.TextSize = 12
	btnClose.AutoButtonColor = false
	Instance.new("UICorner", btnClose).CornerRadius = udim(0, 6)
	btnClose.MouseEnter:Connect(function() PlayTw(btnClose, TweenInfo.new(0.15), {BackgroundColor3 = color3(255, 80, 80)}) end)
	btnClose.MouseLeave:Connect(function() PlayTw(btnClose, TweenInfo.new(0.15), {BackgroundColor3 = CAIDAT.C_HUY}) end)

	btnClose.MouseButton1Click:Connect(function()
		f:Destroy(); UI.P_Prop=nil; State.ShowProp=false; CapNhatUI()
	end)

	local disconnectDrag = MakeDragConn(header)
	f.Destroying:Once(disconnectDrag)

	local scr = Instance.new("ScrollingFrame", f)
	scr.Size = udim2(1, 0, 1, -40)
	scr.Position = udim2(0, 0, 0, 40)
	scr.BackgroundTransparency = 1
	scr.ScrollBarThickness = 4
	scr.ScrollBarImageColor3 = CAIDAT.C_OFF
	scr.BorderSizePixel = 0
	scr.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scr.CanvasSize = udim2(0, 0, 0, 0)

	local scrPad = Instance.new("UIPadding", scr)
	scrPad.PaddingTop = udim(0, 10)
	scrPad.PaddingBottom = udim(0, 10)
	scrPad.PaddingLeft = udim(0, 10)
	scrPad.PaddingRight = udim(0, 10)

	local lst = Instance.new("UIListLayout", scr)
	lst.Padding = udim(0, 8)
	lst.SortOrder = Enum.SortOrder.LayoutOrder

	local function Row(name, val, rtype, cb)
		local d = Instance.new("Frame", scr)
		d.Size = udim2(1, 0, 0, 34)
		d.BackgroundColor3 = CAIDAT.C_NEN_PHU
		d.BackgroundTransparency = 0.5
		Instance.new("UICorner", d).CornerRadius = udim(0, 6)
		local dStrk = Instance.new("UIStroke", d)
		dStrk.Color = CAIDAT.C_VIEN
		dStrk.Transparency = 0.7

		local l = Instance.new("TextLabel", d)
		l.Text = "  " .. name
		l.Size = udim2(0.4, 0, 1, 0)
		l.TextColor3 = CAIDAT.C_CHU
		l.BackgroundTransparency = 1
		l.Font = Enum.Font.GothamMedium
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextSize = 11

		if rtype == "Str" or rtype == "Num" then
			local b = Instance.new("TextBox", d)
			b.Size = udim2(0.55, 0, 0, 24)
			b.Position = udim2(0.42, 0, 0.5, -12)
			b.Text = tostring(val)
			b.BackgroundColor3 = CAIDAT.C_NEN
			b.TextColor3 = color3(255, 255, 255)
			b.Font = Enum.Font.Gotham
			b.TextSize = 11
			b.ClearTextOnFocus = false
			b.ClipsDescendants = true
			Instance.new("UICorner", b).CornerRadius = udim(0, 4)
			local bStrk = Instance.new("UIStroke", b)
			bStrk.Color = CAIDAT.C_VIEN
			bStrk.Transparency = 0.7
			b.FocusLost:Connect(function() cb(b.Text) end)
		elseif rtype == "Bool" then
			local b = Instance.new("TextButton", d)
			b.Size = udim2(0.55, 0, 0, 24)
			b.Position = udim2(0.42, 0, 0.5, -12)
			b.Text = val and "Bật" or "Tắt"
			b.BackgroundColor3 = val and CAIDAT.C_ACT or CAIDAT.C_NEN
			b.TextColor3 = color3(255, 255, 255)
			b.Font = Enum.Font.GothamMedium
			b.TextSize = 11
			b.AutoButtonColor = false
			Instance.new("UICorner", b).CornerRadius = udim(0, 4)
			local bStrk = Instance.new("UIStroke", b)
			bStrk.Color = CAIDAT.C_VIEN
			bStrk.Transparency = 0.7
			b.MouseButton1Click:Connect(function() 
				local n = cb()
				b.Text = n and "Bật" or "Tắt"
				PlayTw(b, TweenInfo.new(0.2), {BackgroundColor3 = n and CAIDAT.C_ACT or CAIDAT.C_NEN})
			end)
		elseif rtype == "Col" then
			local r, g2, bl = math.floor(val.R*255), math.floor(val.G*255), math.floor(val.B*255)
			local box = Instance.new("Frame", d)
			box.Size = udim2(0.55, 0, 0, 24)
			box.Position = udim2(0.42, 0, 0.5, -12)
			box.BackgroundTransparency = 1

			local blist = Instance.new("UIListLayout", box)
			blist.FillDirection = Enum.FillDirection.Horizontal
			blist.Padding = udim(0, 4)

			local function Box(v, c, ref)
				local b = Instance.new("TextBox", box)
				b.Size = udim2(0.333, -3, 1, 0)
				b.Text = v
				b.BackgroundColor3 = c
				b.TextColor3 = color3(255, 255, 255)
				b.Font = Enum.Font.GothamBold
				b.TextSize = 10
				b.Name = ref
				Instance.new("UICorner", b).CornerRadius = udim(0, 4)
				local bStrk = Instance.new("UIStroke", b)
				bStrk.Color = CAIDAT.C_VIEN
				bStrk.Transparency = 0.5
				b.FocusLost:Connect(function()
					local rr = math.clamp(tonumber(box.R.Text) or 0, 0, 255)
					local gg = math.clamp(tonumber(box.G.Text) or 0, 0, 255)
					local bb = math.clamp(tonumber(box.B.Text) or 0, 0, 255)
					cb(color3(rr, gg, bb))
				end)
			end
			Box(r, color3(160, 40, 40), "R"); Box(g2, color3(40, 160, 40), "G"); Box(bl, color3(40, 40, 160), "B")
		end
	end

	Row("Tên", obj.Name, "Str", function(v) obj.Name = v end)
	Row("Màu", obj.Color, "Col", function(v) obj.Color = v end)
	local cTex = obj:FindFirstChildOfClass("Texture") and obj:FindFirstChildOfClass("Texture").Texture or ""
	Row("Texture", cTex, "Str", function(v)
		local id = v:match("%d+")
		local fId = id and "rbxassetid://"..id or ""
		local tx = obj:FindFirstChildOfClass("Texture")
		if fId == "" then if tx then tx:Destroy() end
		else if not tx then tx = Instance.new("Texture", obj); tx.Face = Enum.NormalId.Top end; tx.Texture = fId end
	end)
	Row("Vật liệu", obj.Material.Name, "Str", function(v) pcall(function() obj.Material = Enum.Material[v] end) end)
	Row("Phản chiếu", obj.Reflectance, "Num", function(v) obj.Reflectance = tonumber(v) or 0 end)
	Row("Trong suốt", obj.Transparency, "Num", function(v) obj.Transparency = tonumber(v) or 0 end)
	Row("Va chạm", obj.CanCollide, "Bool", function() obj.CanCollide = not obj.CanCollide; return obj.CanCollide end)
	Row("Cố định", obj.Anchored, "Bool", function() obj.Anchored = not obj.Anchored; return obj.Anchored end)
	Row("Đổ bóng", obj.CastShadow, "Bool", function() obj.CastShadow = not obj.CastShadow; return obj.CastShadow end)

	UI.P_Prop = f
end

LogicKhoi.TaoBlock = function()
	local char = LocalPlayer.Character
	if not char then return end
	local k = Instance.new("Part")
	k.Name = "Block_" .. math.random(1000, 9999); k.Size = vec3(4, 1, 4)
	k.CFrame = char.HumanoidRootPart.CFrame * cf(0, 0, -10)
	k.Position = vec3(mRound(k.Position.X), mRound(k.Position.Y), mRound(k.Position.Z))
	k.Color = Color3.fromHSV(math.random(), 0.6, 0.9); k.Material = "Plastic"; k.Anchored = true; k.Parent = Workspace
	ColService:AddTag(k, CAIDAT.TAG)
	LogicKhoi.SuKienThayDoi:Fire("Them", k)
	return k.Name
end

LogicKhoi.XoaChon = function()
	for k in next_fn, State.DangChon do LogicKhoi.SuKienThayDoi:Fire("Xoa", k); k:Destroy() end
	HuyChon()
end

LogicKhoi.CheckHuy = function(obj)
	if State.DangChon[obj] then State.DangChon[obj] = nil; UpdateBox() end
end

LogicKhoi.HanKhoi = function()
	local tatCaPart, nhomCuCanXoa = {}, {}
	for obj in next_fn, State.DangChon do
		if obj:IsA("Model") then
			ins(nhomCuCanXoa, obj)
			for _, child in ipairs(obj:GetDescendants()) do
				if child:IsA("BasePart") then ins(tatCaPart, child) end
			end
		elseif obj:IsA("BasePart") then
			ins(tatCaPart, obj)
		end
	end
	if #tatCaPart < 2 then return end
	LuuHistory(LayState(), LayState())

	local g = Instance.new("Model"); g.Name = "Group_"..math.random(999); g.Parent = Workspace
	local m = tatCaPart[1]
	local mGhe, spd, ghost

	for _, p in ipairs(tatCaPart) do
		if p:GetAttribute("ModeGhe") then
			m = p; mGhe = p:GetAttribute("ModeGhe"); spd = p:GetAttribute("Speed"); ghost = p:GetAttribute("XuyenTuong"); break
		end
	end

	for _, p in ipairs(tatCaPart) do
		p.Parent = g
		for _, w in ipairs(p:GetChildren()) do if w:IsA("WeldConstraint") then w:Destroy() end end
		if p ~= m then
			local w = Instance.new("WeldConstraint"); w.Part0 = m; w.Part1 = p; w.Parent = m
			p.Anchored = false
		end
		ColService:AddTag(p, CAIDAT.TAG)
	end

	g.PrimaryPart = m; m.Anchored = true
	if mGhe then
		SetGhe(m, mGhe)
		if spd then m:SetAttribute("Speed", spd) end
		if ghost ~= nil then m:SetAttribute("XuyenTuong", ghost) end
	end
	ColService:AddTag(g, CAIDAT.TAG)

	for _, oldM in ipairs(nhomCuCanXoa) do
		if oldM and oldM.Parent then oldM:Destroy() end
	end

	State.DangChon = { [g] = true }
	ToggleUI(true); TaoGizmo(g.PrimaryPart); UpdateBox()

	if LogicKhoi.OnConfigChanged then LogicKhoi.OnConfigChanged() end
end

LogicKhoi.ThaoKhoi = function()
	local co = false
	for k in next_fn, State.DangChon do if k:IsA("Model") then co = true; break end end
	if not co then return end
	LuuHistory(LayState(), LayState())
	for m in next_fn, State.DangChon do
		if m:IsA("Model") then
			for _, c in ipairs(m:GetChildren()) do
				if c:IsA("BasePart") then
					c.Parent = Workspace; c.Anchored = true; ColService:AddTag(c, CAIDAT.TAG)
					for _, w in ipairs(c:GetChildren()) do if w:IsA("WeldConstraint") then w:Destroy() end end
				end
			end
			m:Destroy()
		end
	end
	HuyChon()
end

LogicKhoi.GetConfig = function()
	return {
		Tool = State.Tool,
		ModeScale = State.ModeScale,
		BatLuoi = State.BatLuoi,
		DaChon = State.DaChon,
		ShapeIdx = State.ShapeIdx,
	}
end

LogicKhoi.SetConfig = function(cfg)
	if not cfg then return end
	if cfg.Tool then State.Tool = cfg.Tool end
	if cfg.ModeScale then State.ModeScale = cfg.ModeScale end
	if cfg.BatLuoi ~= nil then State.BatLuoi = cfg.BatLuoi end
	if cfg.DaChon ~= nil then State.DaChon = cfg.DaChon end
	if cfg.ShapeIdx then State.ShapeIdx = cfg.ShapeIdx end
	CapNhatUI()
end

LogicKhoi.HuyChon = HuyChon

local tClick, pClick = 0, Vector2.new(0,0)
local MB1 = Enum.UserInputType.MouseButton1
local Touch = Enum.UserInputType.Touch

UIS.InputBegan:Connect(function(i, p)
	if p then return end
	local kc = i.KeyCode
	if kc == Enum.KeyCode.One then State.Tool = 1; CapNhatUI(); LuuCfg()
	elseif kc == Enum.KeyCode.Two then State.Tool = 2; CapNhatUI(); LuuCfg()
	elseif kc == Enum.KeyCode.Three then State.Tool = 3; CapNhatUI(); LuuCfg() end
	local ut = i.UserInputType
	if ut == MB1 or ut == Touch then tClick = os.clock(); pClick = i.Position end
end)

UIS.InputEnded:Connect(function(i, p)
	if p then return end
	local ut = i.UserInputType
	if ut ~= MB1 and ut ~= Touch then return end
	if (os.clock() - tClick) < 0.3 and (i.Position - pClick).Magnitude < 20 then
		local t = Mouse.Target
		if t and not t.Locked then
			local final
			if t.Parent and ColService:HasTag(t.Parent, CAIDAT.TAG) then final = t.Parent
			elseif ColService:HasTag(t, CAIDAT.TAG) then final = t end

			if final then
				if State.DangChon[final] then HuyChon()
				else
					if not (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or State.DaChon) then clr(State.DangChon) end
					State.DangChon[final] = true
					State.ModeGhe = final:GetAttribute("ModeGhe") or 0
					CapNhatUI(); HieuUngPop(final:IsA("Model") and final.PrimaryPart or final); UpdateBox()
				end
			else
				if not (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or State.DaChon) then HuyChon() end
			end
		else
			HuyChon()
		end
	end
end)

task.delay(1, TaoUI)
return LogicKhoi
