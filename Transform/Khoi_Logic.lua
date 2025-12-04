local LogicKhoi = {}

local DichVuNguoiChoi = game:GetService("Players")
local DichVuNhapLieu = game:GetService("UserInputService")
local DichVuRender = game:GetService("RunService")
local DichVuHieuUng = game:GetService("TweenService")
local KhongGian = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local NguoiChoi = DichVuNguoiChoi.LocalPlayer
local Chuot = NguoiChoi:GetMouse()

local CAI_DAT = {
	TAG_KHOI = "KhoiXayDung_System",
	GIOI_HAN_LICH_SU = 50,
	LUOI_DI_CHUYEN = 1,
	LUOI_XOAY = 15,

	MAU_NEN_CHINH = Color3.fromRGB(25, 25, 30),
	MAU_NEN_PHU = Color3.fromRGB(40, 40, 45),
	MAU_VIEN = Color3.fromRGB(255, 255, 255),

	MAU_NUT_THUONG = Color3.fromRGB(225, 225, 225),
	MAU_ICON_THUONG = Color3.fromRGB(255, 255, 255),
	MAU_NUT_KICH_HOAT = Color3.fromRGB(0, 150, 255),
	MAU_NUT_SCALE_2 = Color3.fromRGB(255, 160, 0),
	MAU_NUT_OFF = Color3.fromRGB(100, 100, 100),
	MAU_NUT_HUY = Color3.fromRGB(200, 40, 40),

	KICH_THUOC_NUT = 44,
	KICH_THUOC_NUT_PHU = 36,

	TWEEN_UI = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	TWEEN_ICON = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	TWEEN_NHUN = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

	ICONS = {
		DI_CHUYEN = "98501712328327",
		KEO_GIAN = "131983126233194",
		XOAY = "94475561845407",
		GRID = "140476097300003",
		HINH_DANG = "77461488191679",
		UNDO = "120782076898439",
		REDO = "124647276241633",
		MUI_TEN = "rbxassetid://6031091004",
		DA_CHON = "109826670489779",
		GHE = "119465930347884",
	},

	ANIMATION_NGOI = "rbxassetid://2506281703",
	MAU_CHON_BOX = Color3.fromRGB(255, 255, 255),
}

local TrangThai = {
	CacKhoiDangChon = {},
	CongCuHienTai = 1,
	CheDoScale = 1,
	CheDoLuoi = true,
	CheDoDaChon = false,
	CheDoGheHienTai = 0,
	ChiSoHinhDang = 1,
}

local LichSu = { Undo = {}, Redo = {}, TrangThaiBatDau = {} }
local TayCam = { DiChuyen = nil, KeoGian = nil, Xoay = nil }
local GiaoDien = { HopChua = nil, KhungChinh = nil, KhungPhu = nil, DanhSachNut = nil, DaMoRong = false, ViTriLuu = UDim2.new(1, -70, 0.5, 0) }
local DuLieuGoc = { CFrame = nil, Size = nil }
local TrackAnimationNgoi = nil

local CacHinhDang = {Enum.PartType.Block, Enum.PartType.Ball, Enum.PartType.Cylinder, Enum.PartType.Wedge, Enum.PartType.CornerWedge}
local CacMauHinhDang = {Color3.fromRGB(0, 150, 255), Color3.fromRGB(255, 60, 60), Color3.fromRGB(60, 255, 60), Color3.fromRGB(255, 255, 0), Color3.fromRGB(180, 0, 255)}

LogicKhoi.SuKienThayDoi = Instance.new("BindableEvent")

local CapNhatGiaoDien, CapNhatHienThiChon, TaoTayCam, HieuUngNhan, XoaTayCam, HienThiUI, HuyChon

local function LamTron(So, Luoi)
	return TrangThai.CheDoLuoi and math.round(So / Luoi) * Luoi or So
end

local function LayTrangThaiHienTai()
	local Data = {}
	for DoiTuong, _ in pairs(TrangThai.CacKhoiDangChon) do
		if DoiTuong:IsA("BasePart") then
			Data[DoiTuong] = {CFrame = DoiTuong.CFrame, Size = DoiTuong.Size, Shape = DoiTuong.Shape}
		end
	end
	return Data
end

local function ApDungTrangThai(DataStore)
	for DoiTuong, DuLieu in pairs(DataStore) do
		if DoiTuong and DoiTuong.Parent then
			DoiTuong.CFrame = DuLieu.CFrame
			DoiTuong.Size = DuLieu.Size
			if DoiTuong:IsA("Part") then DoiTuong.Shape = DuLieu.Shape end
		end
	end
end

local function GhiLichSu(Cu, Moi)
	local CoThayDoi = false
	for k, v in pairs(Moi) do
		if not Cu[k] or Cu[k].CFrame ~= v.CFrame or Cu[k].Size ~= v.Size or Cu[k].Shape ~= v.Shape then CoThayDoi = true break end
	end
	if CoThayDoi then
		table.insert(LichSu.Undo, Cu)
		if #LichSu.Undo > CAI_DAT.GIOI_HAN_LICH_SU then table.remove(LichSu.Undo, 1) end
		LichSu.Redo = {}
	end
end

local function ThucHienUndo()
	if #LichSu.Undo == 0 then return end
	local TrangThaiCu = table.remove(LichSu.Undo)
	table.insert(LichSu.Redo, LayTrangThaiHienTai())
	ApDungTrangThai(TrangThaiCu)
	CapNhatHienThiChon()
end

local function ThucHienRedo()
	if #LichSu.Redo == 0 then return end
	local TrangThaiMoi = table.remove(LichSu.Redo)
	table.insert(LichSu.Undo, LayTrangThaiHienTai())
	ApDungTrangThai(TrangThaiMoi)
	CapNhatHienThiChon()
end

local function XuLyNgoi(Ghe)
	local NhanVat = NguoiChoi.Character
	if not NhanVat then return end
	local Humanoid = NhanVat:FindFirstChild("Humanoid")
	local RootPart = NhanVat:FindFirstChild("HumanoidRootPart")

	if not Humanoid or not RootPart then return end

	local Prompt = Ghe:FindFirstChild("GheAoPrompt")
	if Prompt then Prompt.Enabled = false end

	RootPart.CFrame = Ghe.CFrame * CFrame.new(0, (Ghe.Size.Y / 2) + Humanoid.HipHeight, 0)
	local MoiHan = Instance.new("WeldConstraint")
	MoiHan.Part0 = RootPart; MoiHan.Part1 = Ghe; MoiHan.Parent = RootPart

	if TrackAnimationNgoi then TrackAnimationNgoi:Stop() end
	local Anim = Instance.new("Animation")
	Anim.AnimationId = CAI_DAT.ANIMATION_NGOI
	TrackAnimationNgoi = Humanoid:LoadAnimation(Anim)
	TrackAnimationNgoi:Play()

	local CheDo = Ghe:GetAttribute("CheDoGhe")
	local DangHoatDong = true
	local KetNoiDiChuyen, KetNoiState, KetNoiJumpRequest

	Humanoid.Sit = false
	Humanoid.PlatformStand = true
	Humanoid.AutoRotate = false

	local function ThoatRa()
		if not DangHoatDong then return end
		DangHoatDong = false

		if KetNoiDiChuyen then KetNoiDiChuyen:Disconnect() end
		if KetNoiState then KetNoiState:Disconnect() end
		if KetNoiJumpRequest then KetNoiJumpRequest:Disconnect() end

		if TrackAnimationNgoi then TrackAnimationNgoi:Stop() end
		if Prompt then Prompt.Enabled = true end
		if MoiHan then MoiHan:Destroy() end

		task.defer(function()
			Humanoid.PlatformStand = false
			Humanoid.AutoRotate = true
			if RootPart and Ghe.Parent then
				RootPart.CFrame = Ghe.CFrame * CFrame.new(0, (Ghe.Size.Y/2) + 4, 0)
				RootPart.Velocity = Vector3.new(0, 50, 0)
			end
		end)
	end

	KetNoiJumpRequest = DichVuNhapLieu.JumpRequest:Connect(ThoatRa)

	if CheDo == 2 then
		KetNoiDiChuyen = DichVuRender.Heartbeat:Connect(function()
			if not DangHoatDong or not Ghe.Parent or not MoiHan.Parent then 
				ThoatRa() 
				return 
			end

			local MoveDir = Humanoid.MoveDirection
			if MoveDir.Magnitude > 0.1 then
				local ViTriMoi = Ghe.Position + (MoveDir * (20 * DichVuRender.Heartbeat:Wait()))
				local LookAt = CFrame.lookAt(Ghe.Position, Vector3.new(ViTriMoi.X, Ghe.Position.Y, ViTriMoi.Z))
				Ghe.CFrame = Ghe.CFrame:Lerp(LookAt + (MoveDir * 0.5), 0.1)
			end
		end)
	end

	KetNoiState = Humanoid.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Dead then
			ThoatRa()
		end
	end)
end

local function CapNhatTrangThaiGhe(Khoi, CheDo)
	if not Khoi:IsA("Part") then return end
	local Prompt = Khoi:FindFirstChild("GheAoPrompt")
	Khoi:SetAttribute("CheDoGhe", CheDo)

	if CheDo == 0 then
		if Prompt then Prompt:Destroy() end
		Khoi:SetAttribute("LaGhe", nil)
	else
		if not Prompt then
			Prompt = Instance.new("ProximityPrompt")
			Prompt.Name = "GheAoPrompt"; Prompt.HoldDuration = 0; Prompt.MaxActivationDistance = 15; Prompt.Parent = Khoi
			Prompt.Triggered:Connect(function() XuLyNgoi(Khoi) end)
		end
		Prompt.ObjectText = CheDo == 1 and "Ghế" or "Xe"
		Prompt.ActionText = CheDo == 1 and "Ngồi" or "Lái"
		Khoi:SetAttribute("LaGhe", true)
	end
end

HieuUngNhan = function(DoiTuong)
	if not DoiTuong or not DoiTuong:IsA("BasePart") then return end
	local SizeGoc = DoiTuong.Size
	local T1 = DichVuHieuUng:Create(DoiTuong, CAI_DAT.TWEEN_NHUN, {Size = SizeGoc * 1.1})
	T1:Play()
	T1.Completed:Connect(function() DichVuHieuUng:Create(DoiTuong, TweenInfo.new(0.15), {Size = SizeGoc}):Play() end)
end

CapNhatGiaoDien = function()
	if not GiaoDien.DanhSachNut then return end

	for _, Con in ipairs(GiaoDien.DanhSachNut:GetChildren()) do
		if Con:IsA("ImageButton") and Con.Name:find("CongCu_") then
			local ID = tonumber(Con.Name:match("%d+"))
			local DangChon = (ID == TrangThai.CongCuHienTai)
			local MauNen = (ID == 2 and TrangThai.CheDoScale == 2) and CAI_DAT.MAU_NUT_SCALE_2 or CAI_DAT.MAU_NUT_KICH_HOAT
			local Vien = Con:FindFirstChild("UIStroke")
			local Icon = Con:FindFirstChild("Icon")

			DichVuHieuUng:Create(Con, CAI_DAT.TWEEN_ICON, {BackgroundTransparency = DangChon and 0 or 0.3}):Play()
			if Vien then DichVuHieuUng:Create(Vien, CAI_DAT.TWEEN_ICON, {Color = DangChon and MauNen or CAI_DAT.MAU_VIEN, Transparency = DangChon and 0 or 1}):Play() end
			if Icon then DichVuHieuUng:Create(Icon, CAI_DAT.TWEEN_ICON, {ImageColor3 = Color3.new(1,1,1)}):Play() end
		end
	end

	if GiaoDien.KhungPhu then
		local function SetIcon(Ten, Active, ColorOK)
			local Nut = GiaoDien.KhungPhu:FindFirstChild(Ten)
			if Nut and Nut:FindFirstChild("Icon") then
				DichVuHieuUng:Create(Nut.Icon, CAI_DAT.TWEEN_ICON, {ImageColor3 = Active and (ColorOK or CAI_DAT.MAU_NUT_KICH_HOAT) or CAI_DAT.MAU_NUT_OFF}):Play()
			end
		end

		SetIcon("NutGrid", TrangThai.CheDoLuoi)
		SetIcon("NutDaChon", TrangThai.CheDoDaChon)

		local NutGhe = GiaoDien.KhungPhu:FindFirstChild("NutGhe")
		if NutGhe and NutGhe:FindFirstChild("Icon") and NutGhe:FindFirstChild("VienNet") then
			local Mode = TrangThai.CheDoGheHienTai
			local MauIcon, MauVien, VienTrans

			if Mode == 0 then
				MauIcon = CAI_DAT.MAU_NUT_OFF
				MauVien = CAI_DAT.MAU_VIEN
				VienTrans = 1
			elseif Mode == 1 then
				MauIcon = CAI_DAT.MAU_NUT_KICH_HOAT
				MauVien = CAI_DAT.MAU_NUT_KICH_HOAT
				VienTrans = 0
			else
				MauIcon = CAI_DAT.MAU_NUT_SCALE_2 
				MauVien = CAI_DAT.MAU_NUT_SCALE_2 
				VienTrans = 0
			end

			DichVuHieuUng:Create(NutGhe.Icon, CAI_DAT.TWEEN_ICON, {ImageColor3 = MauIcon}):Play()
			DichVuHieuUng:Create(NutGhe.VienNet, CAI_DAT.TWEEN_ICON, {Color = MauVien, Transparency = VienTrans}):Play()
		end
	end
end

HuyChon = function()
	TrangThai.CacKhoiDangChon = {}
	HienThiUI(false); XoaTayCam()
	if GiaoDien.KhungPhu then GiaoDien.KhungPhu.Visible = false end
	for _, v in ipairs(CollectionService:GetTagged(CAI_DAT.TAG_KHOI)) do
		if v:FindFirstChild("HopChon_Hx") then v.HopChon_Hx:Destroy() end
	end
end

XoaTayCam = function()
	if TayCam.DiChuyen then TayCam.DiChuyen:Destroy() TayCam.DiChuyen = nil end
	if TayCam.KeoGian then TayCam.KeoGian:Destroy() TayCam.KeoGian = nil end
	if TayCam.Xoay then TayCam.Xoay:Destroy() TayCam.Xoay = nil end
end

TaoTayCam = function(KhoiDuocChon)
	XoaTayCam()
	local ThuMucGizmo = NguoiChoi.PlayerGui:FindFirstChild("Gizmos") or Instance.new("Folder", NguoiChoi.PlayerGui)
	ThuMucGizmo.Name = "Gizmos"

	local function GanSuKien(Handle)
		Handle.MouseButton1Down:Connect(function() LichSu.TrangThaiBatDau = LayTrangThaiHienTai() end)
		Handle.MouseButton1Up:Connect(function() GhiLichSu(LichSu.TrangThaiBatDau, LayTrangThaiHienTai()) end)
	end

	if TrangThai.CongCuHienTai == 1 then
		local H = Instance.new("Handles", ThuMucGizmo)
		H.Adornee = KhoiDuocChon; H.Style = "Movement"; H.Color3 = Color3.fromRGB(255, 60, 60)
		TayCam.DiChuyen = H; GanSuKien(H)

		H.MouseButton1Down:Connect(function() 
			if KhoiDuocChon:GetAttribute("KhoaDiChuyen") == true then return end
			DuLieuGoc.CFrame = KhoiDuocChon.CFrame 
		end)

		H.MouseDrag:Connect(function(Mat, Dist)
			if KhoiDuocChon:GetAttribute("KhoaDiChuyen") == true then return end

			if not DuLieuGoc.CFrame then return end
			KhoiDuocChon.CFrame = DuLieuGoc.CFrame + (DuLieuGoc.CFrame:VectorToWorldSpace(Vector3.FromNormalId(Mat)) * LamTron(Dist, CAI_DAT.LUOI_DI_CHUYEN))
			KhoiDuocChon.Anchored = true
		end)

	elseif TrangThai.CongCuHienTai == 2 then
		local H = Instance.new("Handles", ThuMucGizmo)
		H.Adornee = KhoiDuocChon; H.Style = "Resize"
		H.Color3 = TrangThai.CheDoScale == 2 and CAI_DAT.MAU_NUT_SCALE_2 or Color3.fromRGB(60, 160, 255)
		TayCam.KeoGian = H; GanSuKien(H)
		H.MouseButton1Down:Connect(function() DuLieuGoc.Size = KhoiDuocChon.Size; DuLieuGoc.CFrame = KhoiDuocChon.CFrame end)
		H.MouseDrag:Connect(function(Mat, Dist)
			if not DuLieuGoc.Size then return end
			Dist = LamTron(Dist, CAI_DAT.LUOI_DI_CHUYEN)
			local Truc = Vector3.FromNormalId(Mat)
			local SizeMoi = DuLieuGoc.Size + (Vector3.new(math.abs(Truc.X), math.abs(Truc.Y), math.abs(Truc.Z)) * Dist)
			if SizeMoi.X < 0.5 or SizeMoi.Y < 0.5 or SizeMoi.Z < 0.5 then return end
			KhoiDuocChon.Size = SizeMoi
			if TrangThai.CheDoScale == 1 then
				KhoiDuocChon.CFrame = DuLieuGoc.CFrame + (DuLieuGoc.CFrame:VectorToWorldSpace(Truc) * (Dist / 2))
			else
				KhoiDuocChon.CFrame = DuLieuGoc.CFrame
			end
		end)

	elseif TrangThai.CongCuHienTai == 3 then
		local H = Instance.new("ArcHandles", ThuMucGizmo)
		H.Adornee = KhoiDuocChon; H.Axes = Axes.new(Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z)
		TayCam.Xoay = H; GanSuKien(H)
		H.MouseButton1Down:Connect(function() DuLieuGoc.CFrame = KhoiDuocChon.CFrame end)
		H.MouseDrag:Connect(function(Truc, Goc)
			if not DuLieuGoc.CFrame then return end
			local GocRad = math.rad(LamTron(math.deg(Goc), CAI_DAT.LUOI_XOAY))
			KhoiDuocChon.CFrame = DuLieuGoc.CFrame * CFrame.Angles(Truc == Enum.Axis.X and GocRad or 0, Truc == Enum.Axis.Y and GocRad or 0, Truc == Enum.Axis.Z and GocRad or 0)
			KhoiDuocChon.Anchored = true
		end)
	end
end

CapNhatHienThiChon = function()
	for _, v in ipairs(CollectionService:GetTagged(CAI_DAT.TAG_KHOI)) do
		if v:FindFirstChild("HopChon_Hx") then v.HopChon_Hx:Destroy() end
	end
	local SoLuong, DaiDien = 0, nil
	for Khoi, _ in pairs(TrangThai.CacKhoiDangChon) do
		SoLuong = SoLuong + 1
		local MucTieu = Khoi:IsA("Model") and Khoi.PrimaryPart or Khoi
		if MucTieu then
			local Box = Instance.new("SelectionBox")
			Box.Name = "HopChon_Hx"; Box.Adornee = MucTieu; Box.LineThickness = 0.08
			Box.Color3 = CAI_DAT.MAU_CHON_BOX; Box.Parent = MucTieu
			DaiDien = MucTieu
		end
	end

	if SoLuong > 0 then
		if not GiaoDien.HopChua.Visible then HienThiUI(true) end
		if SoLuong == 1 then TaoTayCam(DaiDien) else XoaTayCam() end
	else
		HienThiUI(false); XoaTayCam()
	end
end

HienThiUI = function(Hien)
	if not GiaoDien.HopChua then return end
	if Hien then
		GiaoDien.HopChua.Visible = true
		GiaoDien.KhungChinh:TweenSize(UDim2.new(1, 0, 0, 32 + (CAI_DAT.KICH_THUOC_NUT * 3) + 70), "Out", "Back", 0.35)
	else
		GiaoDien.KhungChinh:TweenSize(UDim2.new(1, 0, 0, 0), "In", "Quart", 0.3, true, function() GiaoDien.HopChua.Visible = false end)
		if GiaoDien.DaMoRong then
			GiaoDien.DaMoRong = false
			GiaoDien.KhungPhu.Visible = false
			DichVuHieuUng:Create(GiaoDien.IconMuiTen, CAI_DAT.TWEEN_UI, {Rotation = 90}):Play()
		end
	end
end

local function TaoGiaoDien()
	if GiaoDien.HopChua then GiaoDien.HopChua:Destroy() end
	local Screen = Instance.new("ScreenGui", NguoiChoi:WaitForChild("PlayerGui"))
	Screen.Name = "HeThongXayDung_Opt"; Screen.ResetOnSpawn = false

	local function Create(Cls, Props, Parent)
		local O = Instance.new(Cls); for k,v in pairs(Props) do O[k]=v end; if Parent then O.Parent=Parent end; return O
	end

	local HopChua = Create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = GiaoDien.ViTriLuu, Size = UDim2.fromOffset(CAI_DAT.KICH_THUOC_NUT + 20, 300), BackgroundTransparency = 1, Visible = false}, Screen)
	local DragBar = Create("TextButton", {Text="", Size=UDim2.new(1,0,0,24), BackgroundTransparency=0.5, BackgroundColor3=CAI_DAT.MAU_NEN_PHU}, nil)
	Create("UICorner", {CornerRadius=UDim.new(0,8)}, DragBar)

	local Dragging, DragStart, StartPos
	DragBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging=true; DragStart=i.Position; StartPos=HopChua.Position end end)
	DichVuNhapLieu.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local D=i.Position-DragStart; HopChua.Position=UDim2.new(StartPos.X.Scale, StartPos.X.Offset+D.X, StartPos.Y.Scale, StartPos.Y.Offset+D.Y); GiaoDien.ViTriLuu=HopChua.Position end end)
	DichVuNhapLieu.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then Dragging=false end end)

	local KhungChinh = Create("Frame", {Size=UDim2.new(1,0,0,0), BackgroundColor3=CAI_DAT.MAU_NEN_CHINH, BackgroundTransparency=0.2, ClipsDescendants=true, ZIndex=10}, HopChua)
	Create("UICorner", {CornerRadius=UDim.new(0,10)}, KhungChinh); Create("UIStroke", {Color=CAI_DAT.MAU_VIEN, Thickness=1.5}, KhungChinh)
	DragBar.Parent = KhungChinh

	local ListFrame = Create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,-60), Position=UDim2.fromOffset(0,32), ZIndex=15}, KhungChinh)
	Create("UIListLayout", {HorizontalAlignment="Center", Padding=UDim.new(0,10), SortOrder="LayoutOrder"}, ListFrame)

	local function TaoNutCongCu(Icon, ID, Ord)
		local Btn = Create("ImageButton", {Name="CongCu_"..ID, LayoutOrder=Ord, Size=UDim2.fromOffset(CAI_DAT.KICH_THUOC_NUT, CAI_DAT.KICH_THUOC_NUT), BackgroundColor3=CAI_DAT.MAU_NUT_THUONG, BackgroundTransparency=0.3, Image="", ZIndex=20}, ListFrame)
		Create("UICorner", {CornerRadius=UDim.new(0,8)}, Btn); Create("UIStroke", {Color=CAI_DAT.MAU_VIEN, Transparency=1, Thickness=1.5}, Btn)
		Create("ImageLabel", {Name="Icon", BackgroundTransparency=1, Size=UDim2.fromScale(0.65,0.65), Position=UDim2.fromScale(0.5,0.5), AnchorPoint=Vector2.new(0.5,0.5), Image="rbxassetid://"..Icon, ImageColor3=CAI_DAT.MAU_ICON_THUONG, ZIndex=25}, Btn)
		Btn.MouseButton1Click:Connect(function()
			if ID == 2 and TrangThai.CongCuHienTai == 2 then TrangThai.CheDoScale = (TrangThai.CheDoScale==1 and 2 or 1) else TrangThai.CheDoScale = 1; TrangThai.CongCuHienTai = ID end
			CapNhatGiaoDien(); local T = next(TrangThai.CacKhoiDangChon); if T then TaoTayCam(T:IsA("Model") and T.PrimaryPart or T) end
		end)
	end
	TaoNutCongCu(CAI_DAT.ICONS.DI_CHUYEN, 1, 1); TaoNutCongCu(CAI_DAT.ICONS.KEO_GIAN, 2, 2); TaoNutCongCu(CAI_DAT.ICONS.XOAY, 3, 3)

	local NutDong = Create("TextButton", {Text="ĐÓNG", Size=UDim2.new(1,-24,0,28), Position=UDim2.new(0.5,0,1,-12), AnchorPoint=Vector2.new(0.5,1), BackgroundColor3=CAI_DAT.MAU_NUT_HUY, Font="GothamBlack", TextColor3=Color3.new(1,1,1), TextSize=11, ZIndex=20}, KhungChinh)
	Create("UICorner", {CornerRadius=UDim.new(0,6)}, NutDong); NutDong.MouseButton1Click:Connect(HuyChon)

	local KhungPhu = Create("Frame", {Name="KhungPhu", AnchorPoint=Vector2.new(0.4,0.8), Position=UDim2.new(0,-10,0.5,0), Size=UDim2.fromOffset((CAI_DAT.KICH_THUOC_NUT_PHU*2)+20, (CAI_DAT.KICH_THUOC_NUT_PHU*3)+28), BackgroundColor3=CAI_DAT.MAU_NEN_PHU, BackgroundTransparency=0.2, Visible=false, ZIndex=8}, HopChua)
	Create("UICorner", {CornerRadius=UDim.new(0,10)}, KhungPhu); Create("UIStroke", {Color=CAI_DAT.MAU_VIEN}, KhungPhu)
	Create("UIGridLayout", {CellSize=UDim2.fromOffset(CAI_DAT.KICH_THUOC_NUT_PHU, CAI_DAT.KICH_THUOC_NUT_PHU), CellPadding=UDim2.fromOffset(8,8), HorizontalAlignment="Center", VerticalAlignment="Center"}, KhungPhu)

	local function TaoNutPhu(Ten, Icon, Ord, Func)
		local Btn = Create("ImageButton", {Name=Ten, LayoutOrder=Ord, BackgroundColor3=CAI_DAT.MAU_NUT_THUONG, BackgroundTransparency=0.3, ZIndex=12}, KhungPhu)
		Create("UICorner", {CornerRadius=UDim.new(0,6)}, Btn); Create("UIStroke", {Name="VienNet", Color=CAI_DAT.MAU_VIEN, Transparency=0.5, Thickness=2.5}, Btn)
		Create("ImageLabel", {Name="Icon", Size=UDim2.fromScale(0.7,0.7), Position=UDim2.fromScale(0.5,0.5), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, Image="rbxassetid://"..Icon, ImageColor3=CAI_DAT.MAU_ICON_THUONG, ZIndex=13}, Btn)
		Btn.MouseButton1Click:Connect(Func)
		return Btn
	end

	TaoNutPhu("NutGrid", CAI_DAT.ICONS.GRID, 1, function() TrangThai.CheDoLuoi = not TrangThai.CheDoLuoi; CapNhatGiaoDien() end)
	TaoNutPhu("NutDaChon", CAI_DAT.ICONS.DA_CHON, 2, function() TrangThai.CheDoDaChon = not TrangThai.CheDoDaChon; CapNhatGiaoDien() end)
	TaoNutPhu("NutUndo", CAI_DAT.ICONS.UNDO, 3, ThucHienUndo)
	TaoNutPhu("NutRedo", CAI_DAT.ICONS.REDO, 4, ThucHienRedo)

	local NutHinhDang = TaoNutPhu("NutHinhDang", CAI_DAT.ICONS.HINH_DANG, 5, function()
		local StateOld = LayTrangThaiHienTai()
		TrangThai.ChiSoHinhDang = (TrangThai.ChiSoHinhDang % #CacHinhDang) + 1
		local ShapeMoi = CacHinhDang[TrangThai.ChiSoHinhDang]
		local MauMoi = CacMauHinhDang[TrangThai.ChiSoHinhDang]
		for Khoi, _ in pairs(TrangThai.CacKhoiDangChon) do if Khoi:IsA("Part") then Khoi.Shape = ShapeMoi end end
		GhiLichSu(StateOld, LayTrangThaiHienTai())
		local Nut = GiaoDien.KhungPhu:FindFirstChild("NutHinhDang")
		if Nut and Nut:FindFirstChild("VienNet") then DichVuHieuUng:Create(Nut.VienNet, TweenInfo.new(0.2), {Color=MauMoi, Transparency=0}):Play() end
	end)
	if NutHinhDang then NutHinhDang.VienNet.Color = CacMauHinhDang[TrangThai.ChiSoHinhDang]; NutHinhDang.VienNet.Transparency = 0 end

	TaoNutPhu("NutGhe", CAI_DAT.ICONS.GHE, 6, function()
		TrangThai.CheDoGheHienTai = (TrangThai.CheDoGheHienTai + 1) % 3
		for Khoi, _ in pairs(TrangThai.CacKhoiDangChon) do CapNhatTrangThaiGhe(Khoi, TrangThai.CheDoGheHienTai) end
		CapNhatGiaoDien()
	end)

	local NutMoRong = Create("ImageButton", {Name="NutMoRong", Size=UDim2.fromOffset(22,44), Position=UDim2.new(0,-15,0.45,0), AnchorPoint=Vector2.new(1.5,1), BackgroundColor3=CAI_DAT.MAU_NEN_CHINH, BackgroundTransparency=0.2, ZIndex=9}, HopChua)
	Create("UICorner", {CornerRadius=UDim.new(0,6)}, NutMoRong); Create("UIStroke", {Color=CAI_DAT.MAU_VIEN}, NutMoRong)
	local IconMuiTen = Create("ImageLabel", {Size=UDim2.fromScale(0.8,0.8), Position=UDim2.fromScale(0.5,0.5), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, Image=CAI_DAT.ICONS.MUI_TEN, Rotation=90, ImageColor3=CAI_DAT.MAU_ICON_THUONG, ZIndex=10}, NutMoRong)

	NutMoRong.MouseButton1Click:Connect(function()
		GiaoDien.DaMoRong = not GiaoDien.DaMoRong
		local PosMoi = GiaoDien.DaMoRong and UDim2.new(0, -((CAI_DAT.KICH_THUOC_NUT_PHU * 2) + 35), 0.5, 0) or UDim2.new(0, 0, 0.5, 0)
		KhungPhu.Visible = true
		KhungPhu:TweenPosition(PosMoi, GiaoDien.DaMoRong and "Out" or "In", "Back", 0.35, true, function() if not GiaoDien.DaMoRong then KhungPhu.Visible = false end end)
		DichVuHieuUng:Create(IconMuiTen, CAI_DAT.TWEEN_UI, {Rotation = GiaoDien.DaMoRong and -90 or 90}):Play()
	end)

	GiaoDien.HopChua = HopChua; GiaoDien.KhungChinh = KhungChinh; GiaoDien.KhungPhu = KhungPhu
	GiaoDien.DanhSachNut = ListFrame; GiaoDien.IconMuiTen = IconMuiTen
	CapNhatGiaoDien()
end

LogicKhoi.TaoKhoiMau = function()
	local NhanVat = NguoiChoi.Character
	if not NhanVat then return end
	local Khoi = Instance.new("Part")
	Khoi.Name = "Khoi_" .. math.random(1000, 9999); Khoi.Size = Vector3.new(4, 1, 4)
	Khoi.CFrame = NhanVat.HumanoidRootPart.CFrame * CFrame.new(0, 0, -10)
	Khoi.Position = Vector3.new(math.round(Khoi.Position.X), math.round(Khoi.Position.Y), math.round(Khoi.Position.Z))
	Khoi.Color = Color3.fromHSV(math.random(), 0.6, 0.9); Khoi.Material = "Plastic"; Khoi.Anchored = true; Khoi.Parent = KhongGian
	CollectionService:AddTag(Khoi, CAI_DAT.TAG_KHOI)
	LogicKhoi.SuKienThayDoi:Fire("Them", Khoi)
	return Khoi.Name
end

LogicKhoi.XoaKhoiChon = function()
	for Khoi, _ in pairs(TrangThai.CacKhoiDangChon) do LogicKhoi.SuKienThayDoi:Fire("Xoa", Khoi); Khoi:Destroy() end
	HuyChon()
end

LogicKhoi.KiemTraHuyChonKhiKhoa = function(Obj)
	if TrangThai.CacKhoiDangChon[Obj] then
		TrangThai.CacKhoiDangChon[Obj] = nil
		CapNhatHienThiChon()
	end
end

LogicKhoi.HanCacKhoi = function()
	local List = {}; for k in pairs(TrangThai.CacKhoiDangChon) do table.insert(List, k) end
	if #List < 2 then return end
	local Model = Instance.new("Model"); Model.Name = "Nhom_"..math.random(999); Model.Parent = KhongGian
	local Primary = List[1]
	for _, Part in ipairs(List) do
		Part.Parent = Model
		if Part ~= Primary then
			local W = Instance.new("WeldConstraint"); W.Part0 = Primary; W.Part1 = Part; W.Parent = Primary
			Part.Anchored = false
		end
		CollectionService:AddTag(Part, CAI_DAT.TAG_KHOI)
	end
	Model.PrimaryPart = Primary; Primary.Anchored = true
	CollectionService:AddTag(Model, CAI_DAT.TAG_KHOI)
	TrangThai.CacKhoiDangChon = {[Model] = true}
	HienThiUI(true); TaoTayCam(Model.PrimaryPart)
end

LogicKhoi.ThaoCacKhoi = function()
	for Model, _ in pairs(TrangThai.CacKhoiDangChon) do
		if Model:IsA("Model") then
			for _, Child in ipairs(Model:GetChildren()) do
				if Child:IsA("BasePart") then
					Child.Parent = KhongGian; Child.Anchored = true
					for _, W in ipairs(Child:GetChildren()) do if W:IsA("WeldConstraint") then W:Destroy() end end
					CollectionService:AddTag(Child, CAI_DAT.TAG_KHOI)
				end
			end
			Model:Destroy()
		end
	end
	HuyChon()
end

local ClickTime, ClickPos = 0, Vector2.new(0,0)
DichVuNhapLieu.InputBegan:Connect(function(Input, Processed)
	if Processed then return end
	if Input.KeyCode == Enum.KeyCode.One then TrangThai.CongCuHienTai = 1; CapNhatGiaoDien()
	elseif Input.KeyCode == Enum.KeyCode.Two then TrangThai.CongCuHienTai = 2; CapNhatGiaoDien()
	elseif Input.KeyCode == Enum.KeyCode.Three then TrangThai.CongCuHienTai = 3; CapNhatGiaoDien() end

	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		ClickTime = os.clock(); ClickPos = Input.Position
	end
end)

DichVuNhapLieu.InputEnded:Connect(function(Input, Processed)
	if Processed then return end
	if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
		if (os.clock() - ClickTime) < 0.3 and (Input.Position - ClickPos).Magnitude < 20 then
			local Target = Chuot.Target
			if Target and not Target.Locked then
				local FinalTarget = nil
				if CollectionService:HasTag(Target, CAI_DAT.TAG_KHOI) then FinalTarget = Target end
				if not FinalTarget and Target.Parent and CollectionService:HasTag(Target.Parent, CAI_DAT.TAG_KHOI) then FinalTarget = Target.Parent end

				if FinalTarget then
					if TrangThai.CacKhoiDangChon[FinalTarget] then
						HuyChon()
					else
						if not (DichVuNhapLieu:IsKeyDown(Enum.KeyCode.LeftControl) or TrangThai.CheDoDaChon) then TrangThai.CacKhoiDangChon = {} end
						TrangThai.CacKhoiDangChon[FinalTarget] = true
						TrangThai.CheDoGheHienTai = FinalTarget:GetAttribute("CheDoGhe") or 0
						CapNhatGiaoDien(); HieuUngNhan(FinalTarget:IsA("Model") and FinalTarget.PrimaryPart or FinalTarget)
						CapNhatHienThiChon()
					end
				else
					if not (DichVuNhapLieu:IsKeyDown(Enum.KeyCode.LeftControl) or TrangThai.CheDoDaChon) then HuyChon() end
				end
			else
				HuyChon()
			end
		end
	end
end)

task.delay(1, TaoGiaoDien)

return LogicKhoi
