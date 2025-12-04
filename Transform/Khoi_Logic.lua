local LogicKhoi = {}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local vec3, cf, udim2 = Vector3.new, CFrame.new, UDim2.new
local udim, color3 = UDim.new, Color3.fromRGB
local mRound, mRad, mAbs = math.round, math.rad, math.abs
local insert, remove = table.insert, table.remove

local CAI_DAT = {
	TAG_KHOI = "KhoiXayDung_System",
	GIOI_HAN_LICH_SU = 50,
	LUOI_DI_CHUYEN = 1,
	LUOI_XOAY = 15,
	MAU_NEN_CHINH = color3(25, 25, 30),
	MAU_NEN_PHU = color3(40, 40, 45),
	MAU_VIEN = color3(255, 255, 255),
	MAU_CHU = color3(240, 240, 240),
	MAU_NUT_THUONG = color3(225, 225, 225),
	MAU_ICON_THUONG = color3(255, 255, 255),
	MAU_NUT_KICH_HOAT = color3(0, 150, 255),
	MAU_NUT_SCALE_2 = color3(255, 160, 0),
	MAU_NUT_OFF = color3(100, 100, 100),
	MAU_NUT_HUY = color3(200, 40, 40),
	MAU_CHON_BOX = color3(255, 255, 255),
	KICH_THUOC_NUT = 44,
	KICH_THUOC_NUT_PHU = 36,
	TWEEN_UI = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	TWEEN_ICON = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	TWEEN_NHUN = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	ICONS = {
		DI_CHUYEN = "98501712328327", KEO_GIAN = "131983126233194", XOAY = "94475561845407",
		LUOI = "140476097300003", HINH_DANG = "77461488191679", HOAN_TAC = "120782076898439",
		LAM_LAI = "124647276241633", MUI_TEN = "rbxassetid://6031091004", DA_CHON = "109826670489779",
		GHE = "119465930347884", HAN = "rbxassetid://101608134171705", RA = "rbxassetid://11326667566",
		TOC_DO = "rbxassetid://107628976464127", THUOC_TINH = "rbxassetid://115321933884958",
	},
	ANIMATION_NGOI = "rbxassetid://2506281703",
	BASE_SCREEN_HEIGHT = 800,
}

local TrangThai = {
	CacKhoiDangChon = {}, CongCuHienTai = 1, CheDoScale = 1,
	CheDoLuoi = true, CheDoDaChon = false, CheDoGheHienTai = 0, ChiSoHinhDang = 1,
}

local LichSu = { HoanTac = {}, LamLai = {}, TrangThaiBatDau = {} }
local TayCam = { DiChuyen = nil, KeoGian = nil, Xoay = nil }
local GiaoDien = { HopChua = nil, KhungChinh = nil, KhungPhu = nil, DanhSachNut = nil, DaMoRong = false, ViTriLuu = udim2(1, -70, 0.5, 0), BangTocDo = nil, BangThuocTinh = nil }
local DuLieuGoc = { CFrame = nil, Size = nil }
local TrackAnimationNgoi = nil

local CacHinhDang = {Enum.PartType.Block, Enum.PartType.Ball, Enum.PartType.Cylinder, Enum.PartType.Wedge, Enum.PartType.CornerWedge}
local CacMauHinhDang = {color3(0, 150, 255), color3(255, 60, 60), color3(60, 255, 60), color3(255, 255, 0), color3(180, 0, 255)}

LogicKhoi.SuKienThayDoi = Instance.new("BindableEvent")

local CapNhatGiaoDien, CapNhatHienThiChon, TaoTayCam, HieuUngNhan, XoaTayCam, HienThiUI, HuyChon, HienThiBangTocDo, HienThiBangThuocTinh

local function TaoHieuUngResponsive(obj)
	if not obj then return end
	local uiScale = obj:FindFirstChild("TyLeManHinh") or Instance.new("UIScale", obj)
	uiScale.Name = "TyLeManHinh"

	local function CapNhatScale()
		if not Camera then return end
		local height = Camera.ViewportSize.Y
		local scale = math.clamp(height / CAI_DAT.BASE_SCREEN_HEIGHT, 0.7, 1.5)
		uiScale.Scale = scale
	end

	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(CapNhatScale)
	CapNhatScale()
	return uiScale
end

local function PlayTween(obj, info, props)
	if obj then TweenService:Create(obj, info, props):Play() end
end

local function LamTron(so, luoi)
	return TrangThai.CheDoLuoi and mRound(so / luoi) * luoi or so
end

local function LayTrangThaiHienTai()
	local dl = {}
	for obj, _ in pairs(TrangThai.CacKhoiDangChon) do
		if obj:IsA("BasePart") then
			dl[obj] = {CFrame = obj.CFrame, Size = obj.Size, Shape = obj.Shape, Parent = obj.Parent}
		end
	end
	return dl
end

local function ApDungTrangThai(kho)
	for obj, info in pairs(kho) do
		if obj and obj.Parent then
			obj.CFrame = info.CFrame; obj.Size = info.Size
			if obj:IsA("Part") then obj.Shape = info.Shape end
		end
	end
end

local function GhiLichSu(cu, moi)
	local thayDoi = false
	for k, v in pairs(moi) do
		if not cu[k] or cu[k].CFrame ~= v.CFrame or cu[k].Size ~= v.Size or cu[k].Shape ~= v.Shape then thayDoi = true break end
	end
	if thayDoi then
		insert(LichSu.HoanTac, cu)
		if #LichSu.HoanTac > CAI_DAT.GIOI_HAN_LICH_SU then remove(LichSu.HoanTac, 1) end
		LichSu.LamLai = {}
	end
end

local function ThucHienLichSu(nguon, dich)
	if #nguon == 0 then return end
	local trangThai = remove(nguon)
	insert(dich, LayTrangThaiHienTai())
	ApDungTrangThai(trangThai)
	CapNhatHienThiChon()
end

local function XuLyNgoi(ghe)
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChild("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	local prompt = ghe:FindFirstChild("GheAoPrompt")
	if prompt then prompt.Enabled = false end

	root.CFrame = ghe.CFrame * cf(0, (ghe.Size.Y / 2) + hum.HipHeight, 0)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root; weld.Part1 = ghe; weld.Parent = root

	if TrackAnimationNgoi then TrackAnimationNgoi:Stop() end
	local anim = Instance.new("Animation")
	anim.AnimationId = CAI_DAT.ANIMATION_NGOI
	TrackAnimationNgoi = hum:LoadAnimation(anim)
	TrackAnimationNgoi:Play()

	local cheDo = ghe:GetAttribute("CheDoGhe")
	local active = true
	local connMove, connState, connJump

	hum.Sit = false; hum.PlatformStand = true; hum.AutoRotate = false

	local function ThoatRa()
		if not active then return end
		active = false
		if connMove then connMove:Disconnect() end
		if connState then connState:Disconnect() end
		if connJump then connJump:Disconnect() end
		if TrackAnimationNgoi then TrackAnimationNgoi:Stop() end
		if prompt then prompt.Enabled = true end
		if weld then weld:Destroy() end

		task.defer(function()
			hum.PlatformStand = false; hum.AutoRotate = true
			if root and ghe.Parent then
				root.CFrame = ghe.CFrame * cf(0, (ghe.Size.Y/2) + 4, 0)
				root.Velocity = vec3(0, 50, 0)
			end
		end)
	end

	connJump = UIS.JumpRequest:Connect(ThoatRa)

	if cheDo == 2 then
		local tocDo = ghe:GetAttribute("TocDoXe") or 20
		local doMuot = 0.15
		connMove = RunService.Heartbeat:Connect(function(dt)
			if not active or not ghe.Parent or not weld.Parent then ThoatRa() return end
			tocDo = ghe:GetAttribute("TocDoXe") or 20
			local dir = hum.MoveDirection
			if dir.Magnitude > 0.1 then
				local pos = ghe.Position
				local dist = dir * (tocDo * dt)
				local look = CFrame.lookAt(pos, pos + dir)
				local newCF = ghe.CFrame:Lerp(look, doMuot)
				ghe.CFrame = newCF - newCF.Position + (pos + dist)
			end
		end)
	end
	connState = hum.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Dead then ThoatRa() end
	end)
end

local function CapNhatTrangThaiGhe(khoi, cheDo)
	if not khoi:IsA("BasePart") then return end
	local prompt = khoi:FindFirstChild("GheAoPrompt")
	khoi:SetAttribute("CheDoGhe", cheDo)

	if cheDo == 2 and not khoi:GetAttribute("TocDoXe") then khoi:SetAttribute("TocDoXe", 20) end

	if cheDo == 0 then
		if prompt then prompt:Destroy() end
		khoi:SetAttribute("LaGhe", nil)
	else
		if not prompt then
			prompt = Instance.new("ProximityPrompt")
			prompt.Name = "GheAoPrompt"; prompt.HoldDuration = 0; prompt.MaxActivationDistance = 15; prompt.Parent = khoi
			prompt.Triggered:Connect(function() XuLyNgoi(khoi) end)
		end
		prompt.ObjectText = cheDo == 1 and "Ghế" or "Xe"
		prompt.ActionText = cheDo == 1 and "Ngồi" or "Lái"
		khoi:SetAttribute("LaGhe", true)
	end
end

HieuUngNhan = function(obj)
	if not obj or not obj:IsA("BasePart") then return end
	local size = obj.Size
	local t1 = TweenService:Create(obj, CAI_DAT.TWEEN_NHUN, {Size = size * 1.1})
	t1:Play()
	t1.Completed:Connect(function() PlayTween(obj, TweenInfo.new(0.15), {Size = size}) end)
end

CapNhatGiaoDien = function()
	if not GiaoDien.DanhSachNut then return end
	for _, con in ipairs(GiaoDien.DanhSachNut:GetChildren()) do
		if con:IsA("ImageButton") and con.Name:find("CongCu_") then
			local id = tonumber(con.Name:match("%d+"))
			local chon = (id == TrangThai.CongCuHienTai)
			local mau = (id == 2 and TrangThai.CheDoScale == 2) and CAI_DAT.MAU_NUT_SCALE_2 or CAI_DAT.MAU_NUT_KICH_HOAT
			local vien, icon = con:FindFirstChild("UIStroke"), con:FindFirstChild("Icon")

			PlayTween(con, CAI_DAT.TWEEN_ICON, {BackgroundTransparency = chon and 0 or 0.3})
			if vien then PlayTween(vien, CAI_DAT.TWEEN_ICON, {Color = chon and mau or CAI_DAT.MAU_VIEN, Transparency = chon and 0 or 1}) end
			if icon then PlayTween(icon, CAI_DAT.TWEEN_ICON, {ImageColor3 = Color3.new(1,1,1)}) end
		end
	end

	if GiaoDien.KhungPhu then
		local function DatIcon(ten, kichHoat, mauOk)
			local nut = GiaoDien.KhungPhu:FindFirstChild(ten)
			if nut and nut:FindFirstChild("Icon") then
				PlayTween(nut.Icon, CAI_DAT.TWEEN_ICON, {ImageColor3 = kichHoat and (mauOk or CAI_DAT.MAU_NUT_KICH_HOAT) or CAI_DAT.MAU_NUT_OFF})
			end
		end
		DatIcon("NutLuoi", TrangThai.CheDoLuoi)
		DatIcon("NutDaChon", TrangThai.CheDoDaChon)

		local nutGhe = GiaoDien.KhungPhu:FindFirstChild("NutGhe")
		if nutGhe and nutGhe:FindFirstChild("Icon") and nutGhe:FindFirstChild("VienNet") then
			local cd = TrangThai.CheDoGheHienTai
			local mIcon, mVien, trans = CAI_DAT.MAU_NUT_OFF, CAI_DAT.MAU_VIEN, 1
			if cd == 1 then mIcon = CAI_DAT.MAU_NUT_KICH_HOAT; mVien = CAI_DAT.MAU_NUT_KICH_HOAT; trans = 0
			elseif cd == 2 then mIcon = CAI_DAT.MAU_NUT_SCALE_2; mVien = CAI_DAT.MAU_NUT_SCALE_2; trans = 0 end
			PlayTween(nutGhe.Icon, CAI_DAT.TWEEN_ICON, {ImageColor3 = mIcon})
			PlayTween(nutGhe.VienNet, CAI_DAT.TWEEN_ICON, {Color = mVien, Transparency = trans})
		end
		local nutTocDo = GiaoDien.KhungPhu:FindFirstChild("NutTocDo")
		if nutTocDo then nutTocDo.Visible = (TrangThai.CheDoGheHienTai == 2) end
	end
end

HuyChon = function()
	TrangThai.CacKhoiDangChon = {}
	HienThiUI(false); XoaTayCam()
	if GiaoDien.KhungPhu then GiaoDien.KhungPhu.Visible = false end
	if GiaoDien.BangTocDo then GiaoDien.BangTocDo.Visible = false end
	if GiaoDien.BangThuocTinh then GiaoDien.BangThuocTinh.Visible = false end
	for _, v in ipairs(CollectionService:GetTagged(CAI_DAT.TAG_KHOI)) do
		if v:FindFirstChild("HopChon_Hx") then v.HopChon_Hx:Destroy() end
	end
end

XoaTayCam = function()
	for k, v in pairs(TayCam) do if v then v:Destroy(); TayCam[k] = nil end end
end

TaoTayCam = function(khoi)
	XoaTayCam()
	local folder = LocalPlayer.PlayerGui:FindFirstChild("Gizmos") or Instance.new("Folder", LocalPlayer.PlayerGui)
	folder.Name = "Gizmos"

	local function GanEvent(tay)
		tay.MouseButton1Down:Connect(function() LichSu.TrangThaiBatDau = LayTrangThaiHienTai() end)
		tay.MouseButton1Up:Connect(function()
			GhiLichSu(LichSu.TrangThaiBatDau, LayTrangThaiHienTai())
			if GiaoDien.BangThuocTinh and GiaoDien.BangThuocTinh.Visible then HienThiBangThuocTinh() end
		end)
	end

	local t = TrangThai.CongCuHienTai
	if t == 1 then
		local h = Instance.new("Handles", folder)
		h.Adornee = khoi; h.Style = "Movement"; h.Color3 = color3(255, 60, 60); TayCam.DiChuyen = h; GanEvent(h)
		h.MouseButton1Down:Connect(function() if not khoi:GetAttribute("KhoaDiChuyen") then DuLieuGoc.CFrame = khoi.CFrame end end)
		h.MouseDrag:Connect(function(face, dist)
			if khoi:GetAttribute("KhoaDiChuyen") or not DuLieuGoc.CFrame then return end
			khoi.CFrame = DuLieuGoc.CFrame + (DuLieuGoc.CFrame:VectorToWorldSpace(Vector3.FromNormalId(face)) * LamTron(dist, CAI_DAT.LUOI_DI_CHUYEN))
			khoi.Anchored = true
		end)
	elseif t == 2 then
		local h = Instance.new("Handles", folder)
		h.Adornee = khoi; h.Style = "Resize"
		h.Color3 = TrangThai.CheDoScale == 2 and CAI_DAT.MAU_NUT_SCALE_2 or color3(60, 160, 255); TayCam.KeoGian = h; GanEvent(h)
		h.MouseButton1Down:Connect(function() DuLieuGoc.Size = khoi.Size; DuLieuGoc.CFrame = khoi.CFrame end)
		h.MouseDrag:Connect(function(face, dist)
			if not DuLieuGoc.Size then return end
			dist = LamTron(dist, CAI_DAT.LUOI_DI_CHUYEN)
			local axis = Vector3.FromNormalId(face)
			local newSize = DuLieuGoc.Size + (vec3(mAbs(axis.X), mAbs(axis.Y), mAbs(axis.Z)) * dist)
			if newSize.X < 0.5 or newSize.Y < 0.5 or newSize.Z < 0.5 then return end
			khoi.Size = newSize
			khoi.CFrame = TrangThai.CheDoScale == 1 and DuLieuGoc.CFrame + (DuLieuGoc.CFrame:VectorToWorldSpace(axis) * (dist / 2)) or DuLieuGoc.CFrame
		end)
	elseif t == 3 then
		local h = Instance.new("ArcHandles", folder)
		h.Adornee = khoi; h.Axes = Axes.new(Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z); TayCam.Xoay = h; GanEvent(h)
		h.MouseButton1Down:Connect(function() DuLieuGoc.CFrame = khoi.CFrame end)
		h.MouseDrag:Connect(function(axis, angle)
			if not DuLieuGoc.CFrame then return end
			local rad = mRad(LamTron(math.deg(angle), CAI_DAT.LUOI_XOAY))
			khoi.CFrame = DuLieuGoc.CFrame * CFrame.Angles(axis == Enum.Axis.X and rad or 0, axis == Enum.Axis.Y and rad or 0, axis == Enum.Axis.Z and rad or 0)
			khoi.Anchored = true
		end)
	end
end

CapNhatHienThiChon = function()
	for _, v in ipairs(CollectionService:GetTagged(CAI_DAT.TAG_KHOI)) do
		if v:FindFirstChild("HopChon_Hx") then v.HopChon_Hx:Destroy() end
	end
	local sl, daiDien = 0, nil
	for k, _ in pairs(TrangThai.CacKhoiDangChon) do
		sl = sl + 1
		local target = k:IsA("Model") and k.PrimaryPart or k
		if target then
			local box = Instance.new("SelectionBox")
			box.Name = "HopChon_Hx"; box.Adornee = target; box.LineThickness = 0.08
			box.Color3 = CAI_DAT.MAU_CHON_BOX; box.Parent = target; daiDien = target
		end
	end
	if sl > 0 then
		if not GiaoDien.HopChua or not GiaoDien.HopChua.Visible then HienThiUI(true) end
		if sl == 1 then TaoTayCam(daiDien) else XoaTayCam() end
	else
		HienThiUI(false); XoaTayCam()
	end
end

HienThiUI = function(hien)
	if not GiaoDien.HopChua then return end
	if hien then
		GiaoDien.HopChua.Visible = true
		GiaoDien.KhungChinh:TweenSize(udim2(1, 0, 0, 32 + (CAI_DAT.KICH_THUOC_NUT * 3) + 70), "Out", "Back", 0.35)
	else
		GiaoDien.KhungChinh:TweenSize(udim2(1, 0, 0, 0), "In", "Quart", 0.3, true, function() GiaoDien.HopChua.Visible = false end)
		if GiaoDien.DaMoRong then
			GiaoDien.DaMoRong = false
			if GiaoDien.KhungPhu then GiaoDien.KhungPhu.Visible = false end
			PlayTween(GiaoDien.IconMuiTen, CAI_DAT.TWEEN_UI, {Rotation = 90})
		end
		if GiaoDien.BangTocDo then GiaoDien.BangTocDo.Visible = false end
		if GiaoDien.BangThuocTinh then GiaoDien.BangThuocTinh.Visible = false end
	end
end

local function TaoGiaoDien()
	if GiaoDien.HopChua then GiaoDien.HopChua:Destroy() end
	local screen = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
	screen.Name = "HeThongXayDung_Opt"; screen.ResetOnSpawn = false

	local function TaoObj(l, p, c)
		local o = Instance.new(l); for k,v in pairs(p) do o[k]=v end; if c then o.Parent=c end; return o
	end

	local hop = TaoObj("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=GiaoDien.ViTriLuu, Size=udim2(0,CAI_DAT.KICH_THUOC_NUT+20,0,300), BackgroundTransparency=1, Visible=false}, screen)

	TaoHieuUngResponsive(hop)

	local keo = TaoObj("TextButton", {Text="", Size=udim2(1,0,0,24), BackgroundTransparency=0.5, BackgroundColor3=CAI_DAT.MAU_NEN_PHU}, nil)
	TaoObj("UICorner", {CornerRadius=udim(0,8)}, keo)

	local dragging, dragStart, startPos
	keo.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=i.Position; startPos=hop.Position end end)
	UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-dragStart; hop.Position=udim2(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y); GiaoDien.ViTriLuu=hop.Position end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

	local khung = TaoObj("Frame", {Size=udim2(1,0,0,0), BackgroundColor3=CAI_DAT.MAU_NEN_CHINH, BackgroundTransparency=0.2, ClipsDescendants=true, ZIndex=10}, hop)
	TaoObj("UICorner", {CornerRadius=udim(0,10)}, khung); TaoObj("UIStroke", {Color=CAI_DAT.MAU_VIEN, Thickness=1.5}, khung); keo.Parent = khung

	local ds = TaoObj("Frame", {BackgroundTransparency=1, Size=udim2(1,0,1,-60), Position=udim2(0,0,0,32), ZIndex=15}, khung)
	TaoObj("UIListLayout", {HorizontalAlignment="Center", Padding=udim(0,10), SortOrder="LayoutOrder"}, ds)

	local function TaoNut(icon, id, order)
		local btn = TaoObj("ImageButton", {Name="CongCu_"..id, LayoutOrder=order, Size=udim2(0,CAI_DAT.KICH_THUOC_NUT,0,CAI_DAT.KICH_THUOC_NUT), BackgroundColor3=CAI_DAT.MAU_NUT_THUONG, BackgroundTransparency=0.3, Image="", ZIndex=20}, ds)
		TaoObj("UICorner", {CornerRadius=udim(0,8)}, btn); TaoObj("UIStroke", {Color=CAI_DAT.MAU_VIEN, Transparency=1, Thickness=1.5}, btn)
		TaoObj("ImageLabel", {Name="Icon", BackgroundTransparency=1, Size=udim2(0.65,0,0.65,0), Position=udim2(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), Image="rbxassetid://"..icon, ImageColor3=CAI_DAT.MAU_ICON_THUONG, ZIndex=25}, btn)
		btn.MouseButton1Click:Connect(function()
			if id==2 and TrangThai.CongCuHienTai==2 then TrangThai.CheDoScale = (TrangThai.CheDoScale==1 and 2 or 1) else TrangThai.CheDoScale=1; TrangThai.CongCuHienTai=id end
			CapNhatGiaoDien(); local t = next(TrangThai.CacKhoiDangChon); if t then TaoTayCam(t:IsA("Model") and t.PrimaryPart or t) end
		end)
	end
	TaoNut(CAI_DAT.ICONS.DI_CHUYEN,1,1); TaoNut(CAI_DAT.ICONS.KEO_GIAN,2,2); TaoNut(CAI_DAT.ICONS.XOAY,3,3)

	local close = TaoObj("TextButton", {Text="ĐÓNG", Size=udim2(1,-24,0,28), Position=udim2(0.5,0,1,-12), AnchorPoint=Vector2.new(0.5,1), BackgroundColor3=CAI_DAT.MAU_NUT_HUY, Font="GothamBlack", TextColor3=color3(255,255,255), TextSize=11, ZIndex=20}, khung)
	TaoObj("UICorner", {CornerRadius=udim(0,6)}, close); close.MouseButton1Click:Connect(HuyChon)

	local phu = TaoObj("Frame", {Name="KhungPhu", AnchorPoint=Vector2.new(0.4,0.85), Position=udim2(0,-10,0.5,0), Size=udim2(0,(CAI_DAT.KICH_THUOC_NUT_PHU*3)+28,0,(CAI_DAT.KICH_THUOC_NUT_PHU*4)+32), BackgroundColor3=CAI_DAT.MAU_NEN_PHU, BackgroundTransparency=0.2, Visible=false, ZIndex=8}, hop)
	TaoObj("UICorner", {CornerRadius=udim(0,10)}, phu); TaoObj("UIStroke", {Color=CAI_DAT.MAU_VIEN}, phu)
	TaoObj("UIGridLayout", {CellSize=udim2(0,CAI_DAT.KICH_THUOC_NUT_PHU,0,CAI_DAT.KICH_THUOC_NUT_PHU), CellPadding=udim2(0,8,0,8), HorizontalAlignment="Center", VerticalAlignment="Center"}, phu)

	local function TaoSub(ten, icon, order, func)
		local btn = TaoObj("ImageButton", {Name=ten, LayoutOrder=order, BackgroundColor3=CAI_DAT.MAU_NUT_THUONG, BackgroundTransparency=0.3, ZIndex=12}, phu)
		TaoObj("UICorner", {CornerRadius=udim(0,6)}, btn); TaoObj("UIStroke", {Name="VienNet", Color=CAI_DAT.MAU_VIEN, Transparency=0.5, Thickness=2.5}, btn)
		TaoObj("ImageLabel", {Name="Icon", Size=udim2(0.7,0,0.7,0), Position=udim2(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, Image=icon, ImageColor3=CAI_DAT.MAU_ICON_THUONG, ZIndex=13}, btn)
		if func then btn.MouseButton1Click:Connect(func) end
	end

	TaoSub("NutLuoi", "rbxassetid://"..CAI_DAT.ICONS.LUOI, 1, function() TrangThai.CheDoLuoi = not TrangThai.CheDoLuoi; CapNhatGiaoDien() end)
	TaoSub("NutDaChon", "rbxassetid://"..CAI_DAT.ICONS.DA_CHON, 2, function() TrangThai.CheDoDaChon = not TrangThai.CheDoDaChon; CapNhatGiaoDien() end)
	TaoSub("NutHinhDang", "rbxassetid://"..CAI_DAT.ICONS.HINH_DANG, 3, function()
		local tCu = LayTrangThaiHienTai()
		TrangThai.ChiSoHinhDang = (TrangThai.ChiSoHinhDang % #CacHinhDang) + 1
		local hinh, mau = CacHinhDang[TrangThai.ChiSoHinhDang], CacMauHinhDang[TrangThai.ChiSoHinhDang]
		for k, _ in pairs(TrangThai.CacKhoiDangChon) do if k:IsA("Part") then k.Shape = hinh end end
		GhiLichSu(tCu, LayTrangThaiHienTai())
		local n = GiaoDien.KhungPhu:FindFirstChild("NutHinhDang")
		if n and n:FindFirstChild("VienNet") then PlayTween(n.VienNet, TweenInfo.new(0.2), {Color=mau, Transparency=0}) end
	end)
	TaoSub("NutHoanTac", "rbxassetid://"..CAI_DAT.ICONS.HOAN_TAC, 4, function() ThucHienLichSu(LichSu.HoanTac, LichSu.LamLai) end)
	TaoSub("NutLamLai", "rbxassetid://"..CAI_DAT.ICONS.LAM_LAI, 5, function() ThucHienLichSu(LichSu.LamLai, LichSu.HoanTac) end)
	TaoSub("NutGhe", "rbxassetid://"..CAI_DAT.ICONS.GHE, 6, function()
		TrangThai.CheDoGheHienTai = (TrangThai.CheDoGheHienTai + 1) % 3
		for k, _ in pairs(TrangThai.CacKhoiDangChon) do CapNhatTrangThaiGhe(k, TrangThai.CheDoGheHienTai) end
		CapNhatGiaoDien()
	end)
	TaoSub("NutGop", CAI_DAT.ICONS.HAN, 7, function()
		local isModel = false; for k in pairs(TrangThai.CacKhoiDangChon) do if k:IsA("Model") then isModel = true break end end
		if isModel then LogicKhoi.ThaoCacKhoi() else LogicKhoi.HanCacKhoi() end
	end)
	TaoSub("NutTocDo", CAI_DAT.ICONS.TOC_DO, 8, HienThiBangTocDo)
	TaoSub("NutThuocTinh", CAI_DAT.ICONS.THUOC_TINH, 9, HienThiBangThuocTinh)

	local nHD = phu:FindFirstChild("NutHinhDang")
	if nHD then nHD.VienNet.Color = CacMauHinhDang[TrangThai.ChiSoHinhDang]; nHD.VienNet.Transparency = 0 end

	local more = TaoObj("ImageButton", {Name="NutMoRong", Size=udim2(0,22,0,44), Position=udim2(0,-15,0.45,0), AnchorPoint=Vector2.new(1.5,1), BackgroundColor3=CAI_DAT.MAU_NEN_CHINH, BackgroundTransparency=0.2, ZIndex=9}, hop)
	TaoObj("UICorner", {CornerRadius=udim(0,6)}, more); TaoObj("UIStroke", {Color=CAI_DAT.MAU_VIEN}, more)
	local arrow = TaoObj("ImageLabel", {Size=udim2(0.8,0,0.8,0), Position=udim2(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, Image=CAI_DAT.ICONS.MUI_TEN, Rotation=90, ImageColor3=CAI_DAT.MAU_ICON_THUONG, ZIndex=10}, more)

	more.MouseButton1Click:Connect(function()
		GiaoDien.DaMoRong = not GiaoDien.DaMoRong
		local pos = GiaoDien.DaMoRong and udim2(0, -((CAI_DAT.KICH_THUOC_NUT_PHU * 3) + 38), 0.5, 0) or udim2(0, 0, 0.5, 0)
		phu.Visible = true
		phu:TweenPosition(pos, GiaoDien.DaMoRong and "Out" or "In", "Back", 0.35, true, function() if not GiaoDien.DaMoRong then phu.Visible = false end end)
		PlayTween(arrow, CAI_DAT.TWEEN_UI, {Rotation = GiaoDien.DaMoRong and -90 or 90})
	end)

	GiaoDien.HopChua = hop; GiaoDien.KhungChinh = khung; GiaoDien.KhungPhu = phu
	GiaoDien.DanhSachNut = ds; GiaoDien.IconMuiTen = arrow
	CapNhatGiaoDien()
end

HienThiBangTocDo = function()
	if GiaoDien.BangTocDo then GiaoDien.BangTocDo:Destroy() end
	local f = Instance.new("Frame", GiaoDien.HopChua.Parent)
	f.Size = udim2(0,200,0,100); f.AnchorPoint = Vector2.new(0.5,0.5); f.Position = udim2(0.5,0,0.5,0); f.BackgroundColor3 = CAI_DAT.MAU_NEN_CHINH
	Instance.new("UICorner", f).CornerRadius = udim(0,8); Instance.new("UIStroke", f).Color = CAI_DAT.MAU_VIEN

	TaoHieuUngResponsive(f)

	local t = Instance.new("TextLabel", f); t.Text = "TỐC ĐỘ XE"; t.Size = udim2(1,0,0,30); t.BackgroundTransparency=1; t.TextColor3 = CAI_DAT.MAU_CHU; t.Font = Enum.Font.GothamBold; t.TextSize = 18
	local inp = Instance.new("TextBox", f); inp.Size = udim2(0.8,0,0,30); inp.Position = udim2(0.1,0,0.35,0); inp.BackgroundColor3 = CAI_DAT.MAU_NEN_PHU; inp.TextColor3 = color3(255,255,255); inp.Font = Enum.Font.Gotham; inp.TextSize = 16; inp.PlaceholderText = "Nhập số (VD: 20)"
	Instance.new("UICorner", inp).CornerRadius = udim(0,6)
	local ghe = next(TrangThai.CacKhoiDangChon); if ghe then inp.Text = ghe:GetAttribute("TocDoXe") or 20 end
	local btn = Instance.new("TextButton", f); btn.Text = "LƯU"; btn.TextSize = 16; btn.Size = udim2(0.4,0,0,25); btn.Position = udim2(0.3,0,0.7,0); btn.BackgroundColor3 = CAI_DAT.MAU_NUT_KICH_HOAT; btn.TextColor3 = color3(255,255,255); btn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", btn).CornerRadius = udim(0,6)
	btn.MouseButton1Click:Connect(function()
		local s = tonumber(inp.Text); if s then for k,_ in pairs(TrangThai.CacKhoiDangChon) do k:SetAttribute("TocDoXe", s) end end
		f:Destroy(); GiaoDien.BangTocDo = nil
	end)
	local x = Instance.new("TextButton", f); x.Text="x"; x.Size=udim2(0,25,0,25); x.Position=udim2(1,-25,0,0); x.BackgroundTransparency=1; x.TextColor3=CAI_DAT.MAU_NUT_HUY; x.MouseButton1Click:Connect(function() f:Destroy(); GiaoDien.BangTocDo=nil end)
	GiaoDien.BangTocDo = f
end

HienThiBangThuocTinh = function()
	if GiaoDien.BangThuocTinh then GiaoDien.BangThuocTinh:Destroy() end
	local obj = next(TrangThai.CacKhoiDangChon); if not obj then return end
	local f = Instance.new("Frame", GiaoDien.HopChua.Parent)
	f.Name = "BangThuocTinh"; f.Size = udim2(0,220,0,320); f.AnchorPoint = Vector2.new(1,0.5); f.Position = udim2(0.9,-10,0.75,0); f.BackgroundColor3 = CAI_DAT.MAU_NEN_CHINH; f.BackgroundTransparency = 0.1
	Instance.new("UICorner", f).CornerRadius = udim(0,8); Instance.new("UIStroke", f).Color = CAI_DAT.MAU_VIEN

	TaoHieuUngResponsive(f)

	local dragging, dragStart, startPos
	f.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=i.Position; startPos=f.Position end end)
	UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-dragStart; f.Position=udim2(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

	local t = Instance.new("TextLabel", f); t.Text = "THUỘC TÍNH"; t.Size = udim2(1,0,0,30); t.BackgroundTransparency=1; t.TextColor3 = CAI_DAT.MAU_CHU; t.Font = Enum.Font.GothamBold; t.TextSize = 14
	local scr = Instance.new("ScrollingFrame", f); scr.Size = udim2(1,-10,1,-40); scr.Position = udim2(0,5,0,35); scr.BackgroundTransparency = 1; scr.ScrollBarThickness = 4
	local list = Instance.new("UIListLayout", scr); list.Padding = udim(0,5); list.HorizontalAlignment = "Center"

	local function Row(ten, val, kieu, cb)
		local d = Instance.new("Frame", scr); d.Size = udim2(1,0,0,30); d.BackgroundTransparency = 1
		local l = Instance.new("TextLabel", d); l.Text = ten; l.Size = udim2(0.4,0,1,0); l.TextColor3 = CAI_DAT.MAU_CHU; l.BackgroundTransparency = 1; l.Font = Enum.Font.Gotham; l.TextXAlignment = "Left"; l.TextSize = 12

		if kieu == "Chuoi" or kieu == "So" then
			local b = Instance.new("TextBox", d); b.Size = udim2(0.55,0,0.8,0); b.Position = udim2(0.45,0,0.1,0); b.Text = tostring(val); b.BackgroundColor3 = CAI_DAT.MAU_NEN_PHU; b.TextColor3 = color3(255,255,255)
			Instance.new("UICorner", b).CornerRadius = udim(0,4); b.FocusLost:Connect(function() cb(b.Text) end)
		elseif kieu == "Bool" then
			local b = Instance.new("TextButton", d); b.Size = udim2(0.55,0,0.8,0); b.Position = udim2(0.45,0,0.1,0); b.Text = val and "Bật" or "Tắt"; b.BackgroundColor3 = val and CAI_DAT.MAU_NUT_KICH_HOAT or CAI_DAT.MAU_NUT_OFF
			Instance.new("UICorner", b).CornerRadius = udim(0,4); b.MouseButton1Click:Connect(function() local n = not cb(); b.Text = n and "Bật" or "Tắt"; b.BackgroundColor3 = n and CAI_DAT.MAU_NUT_KICH_HOAT or CAI_DAT.MAU_NUT_OFF end)
		elseif kieu == "MauRGB" then
			local r, g, bl = math.floor(val.R*255), math.floor(val.G*255), math.floor(val.B*255)
			local boxCont = Instance.new("Frame", d); boxCont.Size = udim2(0.55,0,0.8,0); boxCont.Position = udim2(0.45,0,0.1,0); boxCont.BackgroundTransparency = 1
			local layout = Instance.new("UIListLayout", boxCont); layout.FillDirection = Enum.FillDirection.Horizontal; layout.Padding = udim(0,2)

			local function MakeBox(v, col, ref)
				local b = Instance.new("TextBox", boxCont); b.Size = udim2(0.32,0,1,0); b.Text = v; b.BackgroundColor3 = col; b.TextColor3 = color3(255,255,255); b.Name = ref
				Instance.new("UICorner", b).CornerRadius = udim(0,4)
				b.FocusLost:Connect(function()
					local rr = tonumber(boxCont.R.Text) or 0; local gg = tonumber(boxCont.G.Text) or 0; local bb = tonumber(boxCont.B.Text) or 0
					cb(color3(math.clamp(rr,0,255), math.clamp(gg,0,255), math.clamp(bb,0,255)))
				end)
			end
			MakeBox(r, color3(180, 50, 50), "R"); MakeBox(g, color3(50, 180, 50), "G"); MakeBox(bl, color3(50, 50, 180), "B")
		end
	end

	Row("Tên", obj.Name, "Chuoi", function(v) obj.Name = v end)
	Row("Màu (RGB)", obj.Color, "MauRGB", function(v) obj.Color = v end)

	local currentTex = obj:FindFirstChildOfClass("Texture") and obj:FindFirstChildOfClass("Texture").Texture or ""
	Row("Texture ID", currentTex, "Chuoi", function(v)
		local id = v:match("%d+")
		local finalId = id and "rbxassetid://"..id or ""
		local t = obj:FindFirstChildOfClass("Texture")
		if finalId == "" then
			if t then t:Destroy() end
		else
			if not t then t = Instance.new("Texture", obj); t.Face = Enum.NormalId.Top end
			t.Texture = finalId
		end
	end)

	Row("Vật liệu", obj.Material.Name, "Chuoi", function(v) pcall(function() obj.Material = Enum.Material[v] end) end)
	Row("Phản chiếu", obj.Reflectance, "So", function(v) obj.Reflectance = tonumber(v) or 0 end)
	Row("Trong suốt", obj.Transparency, "So", function(v) obj.Transparency = tonumber(v) or 0 end)
	Row("Va chạm", obj.CanCollide, "Bool", function() obj.CanCollide = not obj.CanCollide return obj.CanCollide end)
	Row("Cố định", obj.Anchored, "Bool", function() obj.Anchored = not obj.Anchored return obj.Anchored end)
	Row("Đổ bóng", obj.CastShadow, "Bool", function() obj.CastShadow = not obj.CastShadow return obj.CastShadow end)

	local x = Instance.new("TextButton", f); x.Text="X"; x.Size=udim2(0,25,0,25); x.Position=udim2(1,-25,0,0); x.BackgroundTransparency=1; x.TextColor3=CAI_DAT.MAU_NUT_HUY
	x.MouseButton1Click:Connect(function() f:Destroy(); GiaoDien.BangThuocTinh=nil end)
	list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scr.CanvasSize = udim2(0,0,0, list.AbsoluteContentSize.Y) end)
	GiaoDien.BangThuocTinh = f
end

LogicKhoi.TaoKhoiMau = function()
	local char = LocalPlayer.Character
	if not char then return end
	local k = Instance.new("Part")
	k.Name = "Khoi_" .. math.random(1000, 9999); k.Size = vec3(4, 1, 4)
	k.CFrame = char.HumanoidRootPart.CFrame * cf(0, 0, -10)
	k.Position = vec3(mRound(k.Position.X), mRound(k.Position.Y), mRound(k.Position.Z))
	k.Color = Color3.fromHSV(math.random(), 0.6, 0.9); k.Material = "Plastic"; k.Anchored = true; k.Parent = Workspace
	CollectionService:AddTag(k, CAI_DAT.TAG_KHOI)
	LogicKhoi.SuKienThayDoi:Fire("Them", k)
	return k.Name
end

LogicKhoi.XoaKhoiChon = function()
	for k, _ in pairs(TrangThai.CacKhoiDangChon) do LogicKhoi.SuKienThayDoi:Fire("Xoa", k); k:Destroy() end
	HuyChon()
end

LogicKhoi.KiemTraHuyChonKhiKhoa = function(obj)
	if TrangThai.CacKhoiDangChon[obj] then TrangThai.CacKhoiDangChon[obj] = nil; CapNhatHienThiChon() end
end

LogicKhoi.HanCacKhoi = function()
	local ds = {}; for k in pairs(TrangThai.CacKhoiDangChon) do insert(ds, k) end
	if #ds < 2 then return end
	GhiLichSu(LayTrangThaiHienTai(), LayTrangThaiHienTai())
	local nhom = Instance.new("Model"); nhom.Name = "Nhom_"..math.random(999); nhom.Parent = Workspace
	local chinh = ds[1]; local cdGhe, tdXe = chinh:GetAttribute("CheDoGhe"), chinh:GetAttribute("TocDoXe")

	for _, p in ipairs(ds) do
		p.Parent = nhom
		if p ~= chinh then
			local w = Instance.new("WeldConstraint"); w.Part0 = chinh; w.Part1 = p; w.Parent = chinh; p.Anchored = false
		end
		CollectionService:AddTag(p, CAI_DAT.TAG_KHOI)
	end
	nhom.PrimaryPart = chinh; chinh.Anchored = true
	if cdGhe then CapNhatTrangThaiGhe(chinh, cdGhe); if tdXe then chinh:SetAttribute("TocDoXe", tdXe) end end

	CollectionService:AddTag(nhom, CAI_DAT.TAG_KHOI)
	TrangThai.CacKhoiDangChon = {[nhom] = true}
	HienThiUI(true); TaoTayCam(nhom.PrimaryPart); CapNhatHienThiChon()
end

LogicKhoi.ThaoCacKhoi = function()
	local co = false; for k in pairs(TrangThai.CacKhoiDangChon) do if k:IsA("Model") then co = true break end end
	if not co then return end
	GhiLichSu(LayTrangThaiHienTai(), LayTrangThaiHienTai())
	for m, _ in pairs(TrangThai.CacKhoiDangChon) do
		if m:IsA("Model") then
			for _, c in ipairs(m:GetChildren()) do
				if c:IsA("BasePart") then
					c.Parent = Workspace; c.Anchored = true; CollectionService:AddTag(c, CAI_DAT.TAG_KHOI)
					for _, w in ipairs(c:GetChildren()) do if w:IsA("WeldConstraint") then w:Destroy() end end
				end
			end
			m:Destroy()
		end
	end
	HuyChon()
end

local timeClick, posClick = 0, Vector2.new(0,0)
UIS.InputBegan:Connect(function(i, p)
	if p then return end
	if i.KeyCode == Enum.KeyCode.One then TrangThai.CongCuHienTai = 1; CapNhatGiaoDien()
	elseif i.KeyCode == Enum.KeyCode.Two then TrangThai.CongCuHienTai = 2; CapNhatGiaoDien()
	elseif i.KeyCode == Enum.KeyCode.Three then TrangThai.CongCuHienTai = 3; CapNhatGiaoDien() end
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		timeClick = os.clock(); posClick = i.Position
	end
end)

UIS.InputEnded:Connect(function(i, p)
	if p then return end
	if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
		if (os.clock() - timeClick) < 0.3 and (i.Position - posClick).Magnitude < 20 then
			local target = Mouse.Target
			if target and not target.Locked then
				local final = CollectionService:HasTag(target, CAI_DAT.TAG_KHOI) and target or (target.Parent and CollectionService:HasTag(target.Parent, CAI_DAT.TAG_KHOI) and target.Parent)
				if final then
					if TrangThai.CacKhoiDangChon[final] then
						HuyChon()
					else
						if not (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or TrangThai.CheDoDaChon) then TrangThai.CacKhoiDangChon = {} end
						TrangThai.CacKhoiDangChon[final] = true
						TrangThai.CheDoGheHienTai = final:GetAttribute("CheDoGhe") or 0
						CapNhatGiaoDien(); HieuUngNhan(final:IsA("Model") and final.PrimaryPart or final); CapNhatHienThiChon()
					end
				else
					if not (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or TrangThai.CheDoDaChon) then HuyChon() end
				end
			else
				HuyChon()
			end
		end
	end
end)

task.delay(1, TaoGiaoDien)
return LogicKhoi
