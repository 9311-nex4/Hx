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
local mRound, mRad, mAbs = math.round, math.rad, math.abs
local insert, remove = table.insert, table.remove

local CAIDAT = {
	TAG = "BuildSystem",
	MAX_HISTORY = 50,
	LUOI_MOVE = 1,
	LUOI_ROT = 15,
	C_NEN = color3(25, 25, 30),
	C_NEN_PHU = color3(40, 40, 45),
	C_VIEN = color3(255, 255, 255),
	C_CHU = color3(255, 255, 255),
	C_BTN = color3(225, 225, 225),
	C_ICON = color3(255, 255, 255),
	C_ACT = color3(0, 150, 255),
	C_SCALE = color3(255, 160, 0),
	C_OFF = color3(100, 100, 100),
	C_HUY = color3(200, 40, 40),
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
	ShowProp = false
}

local History = { Undo = {}, Redo = {}, Start = {} }
local Gizmos = { Move = nil, Scale = nil, Rot = nil }
local UI = { Container = nil, Main = nil, Sub = nil, List = nil, MoRong = false, Pos = udim2(1, -70, 0.5, 0), P_Speed = nil, P_Prop = nil }
local DataGoc = { CF = nil, Size = nil }
local TrackAnim = nil

local ListShape = {Enum.PartType.Block, Enum.PartType.Ball, Enum.PartType.Cylinder, Enum.PartType.Wedge, Enum.PartType.CornerWedge}
local ColorShape = {color3(0, 150, 255), color3(255, 60, 60), color3(60, 255, 60), color3(255, 255, 0), color3(180, 0, 255)}

LogicKhoi.Event = Instance.new("BindableEvent")

local CapNhatUI, UpdateBox, TaoGizmo, HieuUngPop, XoaGizmo, ToggleUI, HuyChon, ToggleSpeed, ToggleProp

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
	for obj, _ in pairs(State.DangChon) do
		if obj:IsA("BasePart") then
			d[obj] = {CF = obj.CFrame, Size = obj.Size, Shape = obj.Shape, Parent = obj.Parent}
		end
	end
	return d
end

local function SetState(data)
	for obj, info in pairs(data) do
		if obj and obj.Parent then
			obj.CFrame = info.CF; obj.Size = info.Size
			if obj:IsA("Part") then obj.Shape = info.Shape end
		end
	end
end

local function LuuHistory(cu, moi)
	local change = false
	for k, v in pairs(moi) do
		if not cu[k] or cu[k].CF ~= v.CF or cu[k].Size ~= v.Size or cu[k].Shape ~= v.Shape then change = true break end
	end
	if change then
		insert(History.Undo, cu)
		if #History.Undo > CAIDAT.MAX_HISTORY then remove(History.Undo, 1) end
		History.Redo = {}
	end
end

local function DoHistory(nguon, dich)
	if #nguon == 0 then return end
	local data = remove(nguon)
	insert(dich, LayState())
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

	root.CFrame = ghe.CFrame * cf(0, (ghe.Size.Y / 2) + hum.HipHeight, 0)
	local w = Instance.new("WeldConstraint")
	w.Part0 = root; w.Part1 = ghe; w.Parent = root

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
			if root and ghe.Parent then
				root.CFrame = ghe.CFrame * cf(0, (ghe.Size.Y/2) + 4, 0)
				root.Velocity = vec3(0, 50, 0)
			end
		end)
	end

	cJump = UIS.JumpRequest:Connect(Exit)

	if mode == 2 then
		local spd = ghe:GetAttribute("Speed") or 20
		local smooth = 0.15
		cMove = RunService.Heartbeat:Connect(function(dt)
			if not active or not ghe.Parent or not w.Parent then Exit() return end
			spd = ghe:GetAttribute("Speed") or 20
			local dir = hum.MoveDirection
			if dir.Magnitude > 0.1 then
				local pos = ghe.Position
				local dist = dir * (spd * dt)
				local look = CFrame.lookAt(pos, pos + dir)
				local nCF = ghe.CFrame:Lerp(look, smooth)
				ghe.CFrame = nCF - nCF.Position + (pos + dist)
			end
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

	if mode == 2 and not khoi:GetAttribute("Speed") then khoi:SetAttribute("Speed", 20) end

	if mode == 0 then
		if p then p:Destroy() end
		khoi:SetAttribute("IsGhe", nil)
	else
		if not p then
			p = Instance.new("ProximityPrompt")
			p.Name = "Prompt"; p.HoldDuration = 0; p.MaxActivationDistance = 15; p.Parent = khoi
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
	local t = TweenService:Create(obj, CAIDAT.TW_POP, {Size = sz * 1.1})
	t:Play()
	t.Completed:Connect(function() PlayTw(obj, TweenInfo.new(0.15), {Size = sz}) end)
end

CapNhatUI = function()
	if not UI.List then return end
	for _, child in ipairs(UI.List:GetChildren()) do
		if child:IsA("ImageButton") and child.Name:find("Tool_") then
			local id = tonumber(child.Name:match("%d+"))
			local sel = (id == State.Tool)
			local col = (id == 2 and State.ModeScale == 2) and CAIDAT.C_SCALE or CAIDAT.C_ACT
			local str, ico = child:FindFirstChild("Stroke"), child:FindFirstChild("Icon")

			PlayTw(child, CAIDAT.TW_ICON, {BackgroundTransparency = sel and 0 or 0.3})
			if str then PlayTw(str, CAIDAT.TW_ICON, {Color = sel and col or CAIDAT.C_VIEN, Transparency = sel and 0 or 1}) end
			if ico then PlayTw(ico, CAIDAT.TW_ICON, {ImageColor3 = Color3.new(1,1,1)}) end
		end
	end

	if UI.Sub then
		local function SetIcon(name, active, okCol)
			local btn = UI.Sub:FindFirstChild(name)
			if btn then
				local ico = btn:FindFirstChild("Icon")
				local str = btn:FindFirstChild("Stroke")
				local cl = active and (okCol or CAIDAT.C_ACT) or CAIDAT.C_OFF

				if ico then PlayTw(ico, CAIDAT.TW_ICON, {ImageColor3 = cl}) end
				if str then PlayTw(str, CAIDAT.TW_ICON, {Color = cl, Transparency = active and 0 or 0.5}) end
			end
		end
		SetIcon("BtnGrid", State.BatLuoi)
		SetIcon("BtnMulti", State.DaChon)
		SetIcon("BtnProp", State.ShowProp)

		local isModel = false
		for k in pairs(State.DangChon) do 
			if k:IsA("Model") then 
				isModel = true 
				break 
			end 
		end
		SetIcon("BtnWeld", isModel)

		local bSeat = UI.Sub:FindFirstChild("BtnSeat")
		if bSeat then
			local md = State.ModeGhe
			local cIcon, cStr, tr = CAIDAT.C_OFF, CAIDAT.C_VIEN, 1
			if md == 1 then cIcon = CAIDAT.C_ACT; cStr = CAIDAT.C_ACT; tr = 0
			elseif md == 2 then cIcon = CAIDAT.C_SCALE; cStr = CAIDAT.C_SCALE; tr = 0 end
			PlayTw(bSeat.Icon, CAIDAT.TW_ICON, {ImageColor3 = cIcon})
			PlayTw(bSeat.Stroke, CAIDAT.TW_ICON, {Color = cStr, Transparency = tr})
		end
		local bSpeed = UI.Sub:FindFirstChild("BtnSpeed")
		if bSpeed then bSpeed.Visible = (State.ModeGhe == 2) end
	end
end

HuyChon = function()
	State.DangChon = {}
	ToggleUI(false); XoaGizmo()

	if UI.Sub then UI.Sub.Visible = false end

	if UI.P_Speed then 
		UI.P_Speed:Destroy()
		UI.P_Speed = nil 
	end

	if UI.P_Prop then 
		UI.P_Prop:Destroy()
		UI.P_Prop = nil
		State.ShowProp = false
	end

	CapNhatUI()

	for _, v in ipairs(ColService:GetTagged(CAIDAT.TAG)) do
		if v:FindFirstChild("SelBox") then v.SelBox:Destroy() end
	end
end

XoaGizmo = function()
	for k, v in pairs(Gizmos) do if v then v:Destroy(); Gizmos[k] = nil end end
end

TaoGizmo = function(target)
	XoaGizmo()
	local f = LocalPlayer.PlayerGui:FindFirstChild("Gizmos") or Instance.new("Folder", LocalPlayer.PlayerGui)
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
		h.Adornee = target; h.Style = "Movement"; h.Color3 = color3(255, 60, 60); Gizmos.Move = h; Bind(h)
		h.MouseButton1Down:Connect(function() if not target:GetAttribute("LockMove") then DataGoc.CF = target.CFrame end end)
		h.MouseDrag:Connect(function(face, dist)
			if target:GetAttribute("LockMove") or not DataGoc.CF then return end
			target.CFrame = DataGoc.CF + (DataGoc.CF:VectorToWorldSpace(Vector3.FromNormalId(face)) * Snap(dist, CAIDAT.LUOI_MOVE))
			target.Anchored = true
		end)
	elseif t == 2 then
		local h = Instance.new("Handles", f)
		h.Adornee = target; h.Style = "Resize"
		h.Color3 = State.ModeScale == 2 and CAIDAT.C_SCALE or color3(60, 160, 255); Gizmos.Scale = h; Bind(h)
		h.MouseButton1Down:Connect(function() DataGoc.Size = target.Size; DataGoc.CF = target.CFrame end)
		h.MouseDrag:Connect(function(face, dist)
			if not DataGoc.Size then return end
			dist = Snap(dist, CAIDAT.LUOI_MOVE)
			local ax = Vector3.FromNormalId(face)
			local nSz = DataGoc.Size + (vec3(mAbs(ax.X), mAbs(ax.Y), mAbs(ax.Z)) * dist)
			if nSz.X < 0.5 or nSz.Y < 0.5 or nSz.Z < 0.5 then return end
			target.Size = nSz
			target.CFrame = State.ModeScale == 1 and DataGoc.CF + (DataGoc.CF:VectorToWorldSpace(ax) * (dist / 2)) or DataGoc.CF
		end)
	elseif t == 3 then
		local h = Instance.new("ArcHandles", f)
		h.Adornee = target; h.Axes = Axes.new(Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z); Gizmos.Rot = h; Bind(h)
		h.MouseButton1Down:Connect(function() DataGoc.CF = target.CFrame end)
		h.MouseDrag:Connect(function(ax, ag)
			if not DataGoc.CF then return end
			local r = mRad(Snap(math.deg(ag), CAIDAT.LUOI_ROT))
			target.CFrame = DataGoc.CF * CFrame.Angles(ax == Enum.Axis.X and r or 0, ax == Enum.Axis.Y and r or 0, ax == Enum.Axis.Z and r or 0)
			target.Anchored = true
		end)
	end
end

UpdateBox = function()
	for _, v in ipairs(ColService:GetTagged(CAIDAT.TAG)) do
		if v:FindFirstChild("SelBox") then v.SelBox:Destroy() end
	end
	local sl, rep = 0, nil
	for k, _ in pairs(State.DangChon) do
		sl = sl + 1
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
		UI.Main:TweenSize(udim2(1, 0, 0, 32 + (CAIDAT.SIZE_BTN * 3) + 70), "Out", "Back", 0.35)
	else
		UI.Main:TweenSize(udim2(1, 0, 0, 0), "In", "Quart", 0.3, true, function() UI.Container.Visible = false end)
		if UI.MoRong then
			UI.MoRong = false
			if UI.Sub then UI.Sub.Visible = false end
			PlayTw(UI.Arrow, CAIDAT.TW_UI, {Rotation = 90})
		end
	end
end

local function TaoUI()
	if UI.Container then UI.Container:Destroy() end
	local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
	gui.Name = "BuildSystem_V2"; gui.ResetOnSpawn = false

	local function Make(cls, props, par)
		local o = Instance.new(cls); for k,v in pairs(props) do o[k]=v end; if par then o.Parent=par end; return o
	end

	local con = Make("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UI.Pos, Size=udim2(0,CAIDAT.SIZE_BTN+20,0,300), BackgroundTransparency=1, Visible=false}, gui)

	TaoScale(con)

	local drag = Make("TextButton", {BackgroundColor3=CAIDAT.C_NEN_PHU, Size=udim2(1,0,0,24), BackgroundTransparency= 0.2, Text="=", TextColor3 = CAIDAT.C_CHU, TextSize = 32}, nil)
	Make("UICorner", {CornerRadius=udim(0,8)}, drag)

	local isDrag, start, startPos
	drag.InputBegan:Connect(function(i) 
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then 
			isDrag=true; start=i.Position; startPos=con.Position 
		end 
	end)
	UIS.InputChanged:Connect(function(i) 
		if isDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then 
			local d=i.Position-start
			con.Position=udim2(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
			UI.Pos=con.Position 
		end 
	end)
	UIS.InputEnded:Connect(function(i) 
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then 
			isDrag=false 
		end 
	end)

	local main = Make("Frame", {Size=udim2(1,0,0,0), BackgroundColor3=CAIDAT.C_NEN, BackgroundTransparency=0.2, ClipsDescendants=true, ZIndex=10}, con)
	Make("UICorner", {CornerRadius=udim(0,10)}, main); Make("UIStroke", {Color=CAIDAT.C_VIEN, Thickness=1.5}, main); drag.Parent = main

	local list = Make("Frame", {BackgroundTransparency=1, Size=udim2(1,0,1,-60), Position=udim2(0,0,0,32), ZIndex=15}, main)
	Make("UIListLayout", {HorizontalAlignment="Center", Padding=udim(0,10), SortOrder="LayoutOrder"}, list)

	local function MakeTool(icon, id, ord)
		local btn = Make("ImageButton", {Name="Tool_"..id, LayoutOrder=ord, Size=udim2(0,CAIDAT.SIZE_BTN,0,CAIDAT.SIZE_BTN), BackgroundColor3=CAIDAT.C_BTN, BackgroundTransparency=0.3, Image="", ZIndex=20}, list)
		Make("UICorner", {CornerRadius=udim(0,8)}, btn); Make("UIStroke", {Name="Stroke", Color=CAIDAT.C_VIEN, Transparency=1, Thickness=1.5}, btn)
		Make("ImageLabel", {Name="Icon", BackgroundTransparency=1, Size=udim2(0.65,0,0.65,0), Position=udim2(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), Image="rbxassetid://"..icon, ImageColor3=CAIDAT.C_ICON, ZIndex=25}, btn)
		btn.MouseButton1Click:Connect(function()
			if id==2 and State.Tool==2 then State.ModeScale = (State.ModeScale==1 and 2 or 1) else State.ModeScale=1; State.Tool=id end
			CapNhatUI(); local t = next(State.DangChon); if t then TaoGizmo(t:IsA("Model") and t.PrimaryPart or t) end
		end)
	end
	MakeTool(CAIDAT.ICONS.MOVE,1,1); MakeTool(CAIDAT.ICONS.SCALE,2,2); MakeTool(CAIDAT.ICONS.ROTATE,3,3)

	local cl = Make("TextButton", {Text="ĐÓNG", Size=udim2(1,-24,0,28), Position=udim2(0.5,0,1,-12), AnchorPoint=Vector2.new(0.5,1), BackgroundColor3=CAIDAT.C_HUY, Font="GothamBlack", TextColor3=color3(255,255,255), TextSize=11, ZIndex=20}, main)
	Make("UICorner", {CornerRadius=udim(0,6)}, cl); cl.MouseButton1Click:Connect(HuyChon)

	local sub = Make("Frame", {Name="Sub", AnchorPoint=Vector2.new(0.4,0.85), Position=udim2(0,-10,0.5,0), Size=udim2(0,(CAIDAT.SIZE_SUB*3)+28,0,(CAIDAT.SIZE_SUB*4)+32), BackgroundColor3=CAIDAT.C_NEN_PHU, BackgroundTransparency=0.2, Visible=false, ZIndex=8}, con)
	Make("UICorner", {CornerRadius=udim(0,10)}, sub); Make("UIStroke", {Color=CAIDAT.C_VIEN}, sub)
	Make("UIGridLayout", {CellSize=udim2(0,CAIDAT.SIZE_SUB,0,CAIDAT.SIZE_SUB), CellPadding=udim2(0,8,0,8), HorizontalAlignment="Center", VerticalAlignment="Center"}, sub)

	local function MakeSub(name, icon, ord, func)
		local btn = Make("ImageButton", {Name=name, LayoutOrder=ord, BackgroundColor3=CAIDAT.C_BTN, BackgroundTransparency=0.3, ZIndex=12}, sub)
		Make("UICorner", {CornerRadius=udim(0,6)}, btn); Make("UIStroke", {Name="Stroke", Color=CAIDAT.C_VIEN, Transparency=0.5, Thickness=2.5}, btn)
		Make("ImageLabel", {Name="Icon", Size=udim2(0.7,0,0.7,0), Position=udim2(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, Image=icon, ImageColor3=CAIDAT.C_ICON, ZIndex=13}, btn)
		if func then btn.MouseButton1Click:Connect(func) end
	end

	MakeSub("BtnGrid", "rbxassetid://"..CAIDAT.ICONS.GRID, 1, function() State.BatLuoi = not State.BatLuoi; CapNhatUI() end)
	MakeSub("BtnMulti", "rbxassetid://"..CAIDAT.ICONS.SEL, 2, function() State.DaChon = not State.DaChon; CapNhatUI() end)
	MakeSub("BtnShape", "rbxassetid://"..CAIDAT.ICONS.SHAPE, 3, function()
		local old = LayState()
		State.ShapeIdx = (State.ShapeIdx % #ListShape) + 1
		local shp, col = ListShape[State.ShapeIdx], ColorShape[State.ShapeIdx]
		for k, _ in pairs(State.DangChon) do if k:IsA("Part") then k.Shape = shp end end
		LuuHistory(old, LayState())
		local n = UI.Sub:FindFirstChild("BtnShape")
		if n and n:FindFirstChild("Stroke") then PlayTw(n.Stroke, TweenInfo.new(0.2), {Color=col, Transparency=0}) end
	end)
	MakeSub("BtnUndo", "rbxassetid://"..CAIDAT.ICONS.UNDO, 4, function() DoHistory(History.Undo, History.Redo) end)
	MakeSub("BtnRedo", "rbxassetid://"..CAIDAT.ICONS.REDO, 5, function() DoHistory(History.Redo, History.Undo) end)
	MakeSub("BtnSeat", "rbxassetid://"..CAIDAT.ICONS.SEAT, 6, function()
		State.ModeGhe = (State.ModeGhe + 1) % 3
		for k, _ in pairs(State.DangChon) do SetGhe(k, State.ModeGhe) end
		CapNhatUI()
	end)
	MakeSub("BtnWeld", CAIDAT.ICONS.WELD, 7, function()
		local isM = false; for k in pairs(State.DangChon) do if k:IsA("Model") then isM = true break end end
		if isM then LogicKhoi.ThaoKhoi() else LogicKhoi.HanKhoi() end
	end)
	MakeSub("BtnSpeed", CAIDAT.ICONS.SPEED, 8, ToggleSpeed)
	MakeSub("BtnProp", CAIDAT.ICONS.PROP, 9, ToggleProp)

	local nS = sub:FindFirstChild("BtnShape")
	if nS then nS.Stroke.Color = ColorShape[State.ShapeIdx]; nS.Stroke.Transparency = 0 end

	local more = Make("ImageButton", {Name="BtnMore", Size=udim2(0,22,0,44), Position=udim2(0,-15,0.45,0), AnchorPoint=Vector2.new(1.5,1), BackgroundColor3=CAIDAT.C_NEN, BackgroundTransparency=0.2, ZIndex=9}, con)
	Make("UICorner", {CornerRadius=udim(0,6)}, more); Make("UIStroke", {Color=CAIDAT.C_VIEN}, more)
	local arr = Make("ImageLabel", {Size=udim2(0.8,0,0.8,0), Position=udim2(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, Image=CAIDAT.ICONS.ARROW, Rotation=90, ImageColor3=CAIDAT.C_ICON, ZIndex=10}, more)

	more.MouseButton1Click:Connect(function()
		UI.MoRong = not UI.MoRong
		local ps = UI.MoRong and udim2(0, -((CAIDAT.SIZE_SUB * 3) + 38), 0.5, 0) or udim2(0, 0, 0.5, 0)
		sub.Visible = true
		sub:TweenPosition(ps, UI.MoRong and "Out" or "In", "Back", 0.35, true, function() if not UI.MoRong then sub.Visible = false end end)
		PlayTw(arr, CAIDAT.TW_UI, {Rotation = UI.MoRong and -90 or 90})
	end)

	UI.Container = con; UI.Main = main; UI.Sub = sub
	UI.List = list; UI.Arrow = arr
	CapNhatUI()
end

ToggleSpeed = function()
	if UI.P_Speed then 
		UI.P_Speed:Destroy()
		UI.P_Speed = nil
		return
	end

	local f = Instance.new("Frame", UI.Container.Parent)
	f.Size = udim2(0,200,0,100); f.AnchorPoint = Vector2.new(0.5,0.5); f.Position = udim2(0.5,0,0.5,0); f.BackgroundColor3 = CAIDAT.C_NEN
	Instance.new("UICorner", f).CornerRadius = udim(0,8); Instance.new("UIStroke", f).Color = CAIDAT.C_VIEN

	TaoScale(f)

	local t = Instance.new("TextLabel", f); t.Text = "TỐC ĐỘ XE"; t.Size = udim2(1,0,0,30); t.BackgroundTransparency=1; t.TextColor3 = CAIDAT.C_CHU; t.Font = Enum.Font.GothamBold; t.TextSize = 18
	local ip = Instance.new("TextBox", f); ip.Size = udim2(0.8,0,0,30); ip.Position = udim2(0.1,0,0.35,0); ip.BackgroundColor3 = CAIDAT.C_NEN_PHU; ip.TextColor3 = color3(255,255,255); ip.Font = Enum.Font.Gotham; ip.TextSize = 16; ip.PlaceholderText = "Nhập số (VD: 20)"
	Instance.new("UICorner", ip).CornerRadius = udim(0,6)
	local g = next(State.DangChon); if g then ip.Text = g:GetAttribute("Speed") or 50 end
	local btn = Instance.new("TextButton", f); btn.Text = "LƯU"; btn.TextSize = 16; btn.Size = udim2(0.4,0,0,25); btn.Position = udim2(0.3,0,0.7,0); btn.BackgroundColor3 = CAIDAT.C_ACT; btn.TextColor3 = color3(255,255,255); btn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", btn).CornerRadius = udim(0,6)
	btn.MouseButton1Click:Connect(function()
		local s = tonumber(ip.Text); if s then for k,_ in pairs(State.DangChon) do k:SetAttribute("Speed", s) end end
		f:Destroy(); UI.P_Speed = nil
	end)
	local x = Instance.new("TextButton", f); x.Text="x"; x.Size=udim2(0,25,0,25); x.Position=udim2(1,-25,0,0); x.BackgroundTransparency=1; x.TextColor3=CAIDAT.C_HUY
	x.MouseButton1Click:Connect(function() 
		f:Destroy(); UI.P_Speed=nil 
	end)
	UI.P_Speed = f
end

ToggleProp = function()
	if UI.P_Prop then 
		UI.P_Prop:Destroy()
		UI.P_Prop = nil
		State.ShowProp = false
		CapNhatUI()
		return
	end

	State.ShowProp = true
	CapNhatUI()

	local obj = next(State.DangChon); if not obj then return end
	local f = Instance.new("Frame", UI.Container.Parent)
	f.Name = "PropPanel"; f.Size = udim2(0,220,0,280); f.AnchorPoint = Vector2.new(1,0.5); f.Position = udim2(0.9,-10,0.75,0); f.BackgroundColor3 = CAIDAT.C_NEN; f.BackgroundTransparency = 0.1
	Instance.new("UICorner", f).CornerRadius = udim(0,8); Instance.new("UIStroke", f).Color = CAIDAT.C_VIEN

	TaoScale(f)

	local drag, start, startP
	f.InputBegan:Connect(function(i) 
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then 
			drag=true; start=i.Position; startP=f.Position 
		end 
	end)
	UIS.InputChanged:Connect(function(i) 
		if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then 
			local d=i.Position-start; f.Position=udim2(startP.X.Scale, startP.X.Offset+d.X, startP.Y.Scale, startP.Y.Offset+d.Y) 
		end 
	end)
	UIS.InputEnded:Connect(function(i) 
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then 
			drag=false 
		end 
	end)

	local t = Instance.new("TextLabel", f); t.Text = "THUỘC TÍNH"; t.Size = udim2(1,0,0,30); t.BackgroundTransparency=1; t.TextColor3 = CAIDAT.C_CHU; t.Font = Enum.Font.GothamBold; t.TextSize = 14
	local scr = Instance.new("ScrollingFrame", f); scr.Size = udim2(1,-10,1,-40); scr.Position = udim2(0,5,0,35); scr.BackgroundTransparency = 1; scr.ScrollBarThickness = 4
	local lst = Instance.new("UIListLayout", scr); lst.Padding = udim(0,5); lst.HorizontalAlignment = "Center"

	local function Row(name, val, type, cb)
		local d = Instance.new("Frame", scr); d.Size = udim2(1,0,0,30); d.BackgroundTransparency = 1
		local l = Instance.new("TextLabel", d); l.Text = name; l.Size = udim2(0.4,0,1,0); l.TextColor3 = CAIDAT.C_CHU; l.BackgroundTransparency = 1; l.Font = Enum.Font.Gotham; l.TextXAlignment = "Left"; l.TextSize = 12

		if type == "Str" or type == "Num" then
			local b = Instance.new("TextBox", d); b.Size = udim2(0.55,0,0.8,0); b.Position = udim2(0.45,0,0.1,0); b.Text = tostring(val); b.BackgroundColor3 = CAIDAT.C_NEN_PHU; b.TextColor3 = color3(255,255,255)
			Instance.new("UICorner", b).CornerRadius = udim(0,4); b.FocusLost:Connect(function() cb(b.Text) end)
		elseif type == "Bool" then
			local b = Instance.new("TextButton", d); b.Size = udim2(0.55,0,0.8,0); b.Position = udim2(0.45,0,0.1,0); b.Text = val and "Bật" or "Tắt"; b.BackgroundColor3 = val and CAIDAT.C_ACT or CAIDAT.C_OFF
			Instance.new("UICorner", b).CornerRadius = udim(0,4); b.MouseButton1Click:Connect(function() local n = not cb(); b.Text = n and "Bật" or "Tắt"; b.BackgroundColor3 = n and CAIDAT.C_ACT or CAIDAT.C_OFF end)
		elseif type == "Col" then
			local r, g, bl = math.floor(val.R*255), math.floor(val.G*255), math.floor(val.B*255)
			local box = Instance.new("Frame", d); box.Size = udim2(0.55,0,0.8,0); box.Position = udim2(0.45,0,0.1,0); box.BackgroundTransparency = 1
			local la = Instance.new("UIListLayout", box); la.FillDirection = Enum.FillDirection.Horizontal; la.Padding = udim(0,2)

			local function Box(v, c, ref)
				local b = Instance.new("TextBox", box); b.Size = udim2(0.32,0,1,0); b.Text = v; b.BackgroundColor3 = c; b.TextColor3 = color3(255,255,255); b.Name = ref
				Instance.new("UICorner", b).CornerRadius = udim(0,4)
				b.FocusLost:Connect(function()
					local rr = tonumber(box.R.Text) or 0; local gg = tonumber(box.G.Text) or 0; local bb = tonumber(box.B.Text) or 0
					cb(color3(math.clamp(rr,0,255), math.clamp(gg,0,255), math.clamp(bb,0,255)))
				end)
			end
			Box(r, color3(180, 50, 50), "R"); Box(g, color3(50, 180, 50), "G"); Box(bl, color3(50, 50, 180), "B")
		end
	end

	Row("Tên", obj.Name, "Str", function(v) obj.Name = v end)
	Row("Màu", obj.Color, "Col", function(v) obj.Color = v end)

	local cTex = obj:FindFirstChildOfClass("Texture") and obj:FindFirstChildOfClass("Texture").Texture or ""
	Row("Texture", cTex, "Str", function(v)
		local id = v:match("%d+")
		local fId = id and "rbxassetid://"..id or ""
		local t = obj:FindFirstChildOfClass("Texture")
		if fId == "" then
			if t then t:Destroy() end
		else
			if not t then t = Instance.new("Texture", obj); t.Face = Enum.NormalId.Top end
			t.Texture = fId
		end
	end)

	Row("Vật liệu", obj.Material.Name, "Str", function(v) pcall(function() obj.Material = Enum.Material[v] end) end)
	Row("Phản chiếu", obj.Reflectance, "Num", function(v) obj.Reflectance = tonumber(v) or 0 end)
	Row("Trong suốt", obj.Transparency, "Num", function(v) obj.Transparency = tonumber(v) or 0 end)
	Row("Va chạm", obj.CanCollide, "Bool", function() obj.CanCollide = not obj.CanCollide return obj.CanCollide end)
	Row("Cố định", obj.Anchored, "Bool", function() obj.Anchored = not obj.Anchored return obj.Anchored end)
	Row("Đổ bóng", obj.CastShadow, "Bool", function() obj.CastShadow = not obj.CastShadow return obj.CastShadow end)

	local x = Instance.new("TextButton", f); x.Text="X"; x.Size=udim2(0,25,0,25); x.Position=udim2(1,-25,0,0); x.BackgroundTransparency=1; x.TextColor3=CAIDAT.C_HUY
	x.MouseButton1Click:Connect(function() 
		f:Destroy(); UI.P_Prop=nil
		State.ShowProp = false
		CapNhatUI()
	end)
	lst:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scr.CanvasSize = udim2(0,0,0, lst.AbsoluteContentSize.Y) end)
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
	LogicKhoi.Event:Fire("Add", k)
	return k.Name
end

LogicKhoi.XoaChon = function()
	for k, _ in pairs(State.DangChon) do LogicKhoi.Event:Fire("Del", k); k:Destroy() end
	HuyChon()
end

LogicKhoi.CheckHuy = function(obj)
	if State.DangChon[obj] then State.DangChon[obj] = nil; UpdateBox() end
end

LogicKhoi.HanKhoi = function()
	local tatCaPart = {}
	local nhomCuCanXoa = {} 

	for obj, _ in pairs(State.DangChon) do
		if obj:IsA("Model") then
			table.insert(nhomCuCanXoa, obj) 
			for _, child in ipairs(obj:GetDescendants()) do
				if child:IsA("BasePart") then
					table.insert(tatCaPart, child)
				end
			end
		elseif obj:IsA("BasePart") then
			table.insert(tatCaPart, obj)
		end
	end

	if #tatCaPart < 2 then return end 

	LuuHistory(LayState(), LayState())

	local g = Instance.new("Model") 
	g.Name = "Group_"..math.random(999) 
	g.Parent = Workspace

	local m = tatCaPart[1]
	local mGhe, spd

	for _, p in ipairs(tatCaPart) do
		if p:GetAttribute("ModeGhe") then
			m = p 
			mGhe = p:GetAttribute("ModeGhe")
			spd = p:GetAttribute("Speed")
			break
		end
	end

	for _, p in ipairs(tatCaPart) do
		p.Parent = g

		for _, w in ipairs(p:GetChildren()) do
			if w:IsA("WeldConstraint") then w:Destroy() end
		end

		if p ~= m then
			local w = Instance.new("WeldConstraint") 
			w.Part0 = m 
			w.Part1 = p 
			w.Parent = m 
			p.Anchored = false
		end
		ColService:AddTag(p, CAIDAT.TAG)
	end

	g.PrimaryPart = m
	m.Anchored = true

	if mGhe then 
		SetGhe(m, mGhe) 
		if spd then m:SetAttribute("Speed", spd) end 
	end

	ColService:AddTag(g, CAIDAT.TAG)

	for _, oldM in ipairs(nhomCuCanXoa) do
		if oldM and oldM.Parent then oldM:Destroy() end
	end

	State.DangChon = {[g] = true}
	ToggleUI(true)
	TaoGizmo(g.PrimaryPart)
	UpdateBox()
end

LogicKhoi.ThaoKhoi = function()
	local co = false; for k in pairs(State.DangChon) do if k:IsA("Model") then co = true break end end
	if not co then return end
	LuuHistory(LayState(), LayState())
	for m, _ in pairs(State.DangChon) do
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

local tClick, pClick = 0, Vector2.new(0,0)
UIS.InputBegan:Connect(function(i, p)
	if p then return end
	if i.KeyCode == Enum.KeyCode.One then State.Tool = 1; CapNhatUI()
	elseif i.KeyCode == Enum.KeyCode.Two then State.Tool = 2; CapNhatUI()
	elseif i.KeyCode == Enum.KeyCode.Three then State.Tool = 3; CapNhatUI() end
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		tClick = os.clock(); pClick = i.Position
	end
end)

UIS.InputEnded:Connect(function(i, p)
	if p then return end
	if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
		if (os.clock() - tClick) < 0.3 and (i.Position - pClick).Magnitude < 20 then
			local t = Mouse.Target
			if t and not t.Locked then
				local final = nil
				if t.Parent and ColService:HasTag(t.Parent, CAIDAT.TAG) then
					final = t.Parent
				elseif ColService:HasTag(t, CAIDAT.TAG) then
					final = t
				end

				if final then
					if State.DangChon[final] then
						HuyChon()
					else
						if not (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or State.DaChon) then State.DangChon = {} end
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
	end
end)

task.delay(1, TaoUI)
return LogicKhoi
