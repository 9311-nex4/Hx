local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local Debris           = game:GetService("Debris")
local RunService       = game:GetService("RunService")

local playerLocal = Players.LocalPlayer
local playerGui   = playerLocal:WaitForChild("PlayerGui")
local camera      = workspace.CurrentCamera

local THEME = {
	COLORS = {
		Particle1        = Color3.fromRGB(0, 255, 255),
		Particle2        = Color3.fromRGB(0, 85,  255),
		SelectionBox     = Color3.fromRGB(0, 255, 0),
		Background       = Color3.fromRGB(40, 40, 40),
		Header           = Color3.fromRGB(60, 60, 60),
		Text             = Color3.fromRGB(255, 255, 255),
		TextSecondary    = Color3.fromRGB(230, 230, 230),
		Border           = Color3.fromRGB(255, 255, 255),
		ButtonGreen      = Color3.fromRGB(0,   175, 0),
		ButtonRed        = Color3.fromRGB(175, 0,   0),
		ButtonGray       = Color3.fromRGB(80,  80,  80),
		ButtonBlue       = Color3.fromRGB(60,  150, 255),
		ButtonText       = Color3.fromRGB(255, 255, 255),
		OpenButton       = Color3.fromRGB(30,  30,  30),
		OutsideContainer = Color3.fromRGB(255, 255, 255),
		OutsideButton    = Color3.fromRGB(30,  30,  30),
	},
	FONTS = {
		Main    = Enum.Font.SourceSans,
		Bold    = Enum.Font.SourceSansBold,
		Special = Enum.Font.SpecialElite,
	},
	ROUNDING = {
		Main        = UDim.new(0, 8),
		Button      = UDim.new(0, 4),
		ButtonSmall = UDim.new(0, 3),
		Circle      = UDim.new(1, 0),
	},
}

local ANH_HAT     = "rbxassetid://2130129598"
local ANH_ICON_MO = "rbxassetid://117118515787811"

local PART_MAP = {
	Head     = { "Head" },
	Torso    = { "Torso", "UpperTorso", "LowerTorso" },
	RightArm = { "Right Arm", "RightUpperArm", "RightLowerArm", "RightHand" },
	LeftArm  = { "Left Arm",  "LeftUpperArm",  "LeftLowerArm",  "LeftHand" },
	RightLeg = { "Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot" },
	LeftLeg  = { "Left Leg",  "LeftUpperLeg",  "LeftLowerLeg",  "LeftFoot" },
}
local THU_TU_BO_PHAN = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }

local partDuocChon    = nil
local dangBienHinh    = false
local hopChon         = nil

local doTrongSuotGoc  = {}
local vaChamGoc       = {}
local modelMucTieuGoc = nil
local cframeMucTieuGoc= nil
local cacBoPhanDaTao  = {}
local luuTruBoPhan    = {}

local animConnection        = nil
local currentPlayerHumanoid = nil
local currentCloneHumanoid  = nil

local cauHinh = {
	chucNangBat   = true,
	hienNutNgoai  = true,
	cheDoBienHinh = "ToanThan",
	boPhan = {
		Head     = { Bat = true, LuuGiu = false, TenHienThi = "Phần đầu"  },
		Torso    = { Bat = true, LuuGiu = false, TenHienThi = "Phần thân" },
		RightArm = { Bat = true, LuuGiu = false, TenHienThi = "Tay phải"  },
		LeftArm  = { Bat = true, LuuGiu = false, TenHienThi = "Tay trái"  },
		RightLeg = { Bat = true, LuuGiu = false, TenHienThi = "Chân phải" },
		LeftLeg  = { Bat = true, LuuGiu = false, TenHienThi = "Chân trái" },
	},
}

local nutBienHinh      = nil
local nutBatTatChon    = nil
local khungNutBatTat   = nil
local nutMoUi          = nil
local uiChinh          = nil
local nutToggleUiChinh = nil
local nutToggleUiNgoai = nil
local nutDropdownCheDo = nil
local frameBoPhan      = nil

local GuiThongBao = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Notify.lua"))()

local function ThongBao(TieuDe, NoiDung, ThoiGian)
	if type(GuiThongBao) == "table" and GuiThongBao.thongbao then
		GuiThongBao.thongbao(TieuDe, NoiDung, ThoiGian)
	elseif type(GuiThongBao) == "function" then
		GuiThongBao(TieuDe, NoiDung, ThoiGian)
	end
end

local function ThongBaoLoi(TieuDe, NoiDung)
	if type(GuiThongBao) == "table" and GuiThongBao.thongbaoloi then
		GuiThongBao.thongbaoloi(TieuDe, NoiDung)
	end
end

local function taoKeoTha(frame, handle)
	local dragHandle = handle or frame
	local dragging   = false
	local dragStart  = nil
	local frameStart = nil

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging   = true
			dragStart  = input.Position
			frameStart = frame.Position

			local conn
			conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					conn:Disconnect()
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch
		then return end

		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			frameStart.X.Scale,  frameStart.X.Offset + delta.X,
			frameStart.Y.Scale,  frameStart.Y.Offset + delta.Y
		)
	end)
end

local function taoHieuUng(partGoc)
	if not partGoc then return end

	local tepDinhKem = Instance.new("Attachment")

	local hat = Instance.new("ParticleEmitter")
	hat.Texture      = ANH_HAT
	hat.Color        = ColorSequence.new(THEME.COLORS.Particle1, THEME.COLORS.Particle2)
	hat.Size         = NumberSequence.new(0.1, 0.5, 0.1)
	hat.Transparency = NumberSequence.new(0, 1)
	hat.Lifetime     = NumberRange.new(0.5, 1)
	hat.Rate         = 0
	hat.Speed        = NumberRange.new(2, 5)
	hat.SpreadAngle  = Vector2.new(360, 360)
	hat.Parent       = tepDinhKem
	hat:Emit(50)

	Debris:AddItem(tepDinhKem, 2)
	tepDinhKem.Parent = partGoc
end

local function capNhatHopChon(part)
	if hopChon then
		hopChon:Destroy()
		hopChon = nil
	end
	if part then
		hopChon               = Instance.new("SelectionBox")
		hopChon.Color3        = THEME.COLORS.SelectionBox
		hopChon.LineThickness = 0.05
		hopChon.Adornee       = part
		hopChon.Parent        = playerGui
	end
end

local function luuTrangThaiNguoiChoi(nhanVat)
	doTrongSuotGoc = {}
	vaChamGoc      = {}

	for _, descendant in ipairs(nhanVat:GetDescendants()) do
		if descendant:IsA("BasePart") then
			doTrongSuotGoc[descendant] = descendant.Transparency
			vaChamGoc[descendant]      = descendant.CanCollide
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			doTrongSuotGoc[descendant] = descendant.Transparency
		end
	end
end

local function khoiPhucTrangThaiNguoiChoi(nhanVat)
	for part, doTrongSuot in pairs(doTrongSuotGoc) do
		if part and part.Parent then
			pcall(function() part.Transparency = doTrongSuot end)
		end
	end
	for part, canCollide in pairs(vaChamGoc) do
		if part and part.Parent then
			pcall(function() part.CanCollide = canCollide end)
		end
	end
	doTrongSuotGoc = {}
	vaChamGoc      = {}
end

local function hoanTac(nhanVatNguon)
	if not dangBienHinh then return end
	dangBienHinh = false

	if animConnection then
		animConnection:Disconnect()
		animConnection = nil
	end
	currentPlayerHumanoid = nil
	currentCloneHumanoid  = nil

	local nhanVat = nhanVatNguon or playerLocal.Character
	if nhanVat then
		khoiPhucTrangThaiNguoiChoi(nhanVat)
		local goc = nhanVat:FindFirstChild("HumanoidRootPart")
		if goc then taoHieuUng(goc) end
	end

	for _, instance in pairs(cacBoPhanDaTao) do
		if instance then instance:Destroy() end
	end
	cacBoPhanDaTao = {}

	if modelMucTieuGoc and cframeMucTieuGoc then
		pcall(function()
			modelMucTieuGoc:SetPrimaryPartCFrame(cframeMucTieuGoc)
		end)
		modelMucTieuGoc  = nil
		cframeMucTieuGoc = nil
	end

	if nutBienHinh then
		nutBienHinh.Text = "Biến"
	end

	capNhatHopChon(nil)
	if partDuocChon and cauHinh.chucNangBat then
		capNhatHopChon(partDuocChon)
	end
end

local function updateCloneAnimation()
	if currentPlayerHumanoid and currentCloneHumanoid
		and currentCloneHumanoid.Parent and currentPlayerHumanoid.Parent
	then
		pcall(function()
			currentCloneHumanoid:Move(currentPlayerHumanoid.MoveDirection, false)
			if currentPlayerHumanoid:GetState() == Enum.HumanoidStateType.Jumping then
				currentCloneHumanoid.Jump = true
			end
		end)
	end
end

local function bienHinhToanThan(nhanVat, partGoc)
	if not partDuocChon or not partDuocChon.Parent then
		ThongBao("Lỗi!", "Chưa chọn part để biến hình toàn thân.", 3)
		return false
	end

	for _, part in ipairs(nhanVat:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = 1
			part.CanCollide   = false
		elseif part:IsA("Decal") or part:IsA("Texture") then
			part.Transparency = 1
		end
	end

	local clone = partDuocChon:Clone()
	clone.Name       = "MorphPart_Full"
	clone.Anchored   = false
	clone.CanCollide = false
	clone.Massless   = true

	local orientationGoc = partDuocChon.CFrame - partDuocChon.CFrame.Position
	clone.CFrame = CFrame.new(partGoc.CFrame.Position) * orientationGoc

	local weld      = Instance.new("WeldConstraint")
	weld.Part0      = partGoc
	weld.Part1      = clone
	weld.Parent     = partGoc
	clone.Parent    = nhanVat

	cacBoPhanDaTao["ToanThan"] = clone
	return true
end

local function bienHinhTungPhan(nhanVat)
	local daBienHinhMotPhan = false

	for tenBoPhanLogic, data in pairs(cauHinh.boPhan) do
		if not data.Bat then continue end

		local partDeBienHinh = luuTruBoPhan[tenBoPhanLogic] or partDuocChon
		if not partDeBienHinh then continue end

		local cacTenPartThucTe = PART_MAP[tenBoPhanLogic]
		if not cacTenPartThucTe then continue end

		local partMucTieuChinh = nil
		for _, tenPartThucTe in ipairs(cacTenPartThucTe) do
			local part = nhanVat:FindFirstChild(tenPartThucTe)
			if part and part:IsA("BasePart") then
				partMucTieuChinh = part
				break
			end
		end
		if not partMucTieuChinh then continue end

		daBienHinhMotPhan = true

		local clone = partDeBienHinh:Clone()
		clone.Name       = "MorphPart_" .. tenBoPhanLogic
		clone.Anchored   = false
		clone.CanCollide = false
		clone.Massless   = true

		local orientationGoc = partDeBienHinh.CFrame - partDeBienHinh.CFrame.Position
		clone.CFrame = CFrame.new(partMucTieuChinh.CFrame.Position) * orientationGoc

		local weld    = Instance.new("WeldConstraint")
		weld.Part0    = partMucTieuChinh
		weld.Part1    = clone
		weld.Parent   = partMucTieuChinh
		clone.Parent  = nhanVat

		cacBoPhanDaTao[tenBoPhanLogic] = clone

		for _, tenPartThucTe in ipairs(cacTenPartThucTe) do
			local partDeAn = nhanVat:FindFirstChild(tenPartThucTe)
			if partDeAn then
				for _, p in ipairs(partDeAn:GetDescendants()) do
					if p:IsA("BasePart") then
						p.Transparency = 1
						p.CanCollide   = false
					elseif p:IsA("Decal") or p:IsA("Texture") then
						p.Transparency = 1
					end
				end
				partDeAn.Transparency = 1
				partDeAn.CanCollide   = false
			end
		end
	end

	if not daBienHinhMotPhan then
		ThongBao("Thông báo", "Không có bộ phận nào được bật hoặc có part để biến hình.", 3)
		return false
	end
	return true
end

local function bienHinhNhanVat(nhanVat, partGoc)
	if not partDuocChon or not partDuocChon.Parent then
		ThongBao("Lỗi!", "Chưa chọn đối tượng để biến hình.", 3)
		return false
	end

	local modelMucTieu = partDuocChon:FindFirstAncestorWhichIsA("Model")
	if not modelMucTieu or not modelMucTieu:FindFirstChildWhichIsA("Humanoid") then
		ThongBao("Lỗi!", "Đối tượng đã chọn không phải là nhân vật hợp lệ.", 3)
		return false
	end
	if modelMucTieu == nhanVat then
		ThongBao("Lỗi!", "Bạn không thể biến hình thành chính mình.", 3)
		return false
	end

	local humanoidNguoiChoi = nhanVat:FindFirstChildWhichIsA("Humanoid")
	if not humanoidNguoiChoi then
		ThongBao("Lỗi!", "Không tìm thấy Humanoid của người chơi.", 3)
		return false
	end

	for _, part in ipairs(nhanVat:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = 1
			part.CanCollide   = false
		elseif part:IsA("Decal") or part:IsA("Texture") then
			part.Transparency = 1
		end
	end

	modelMucTieuGoc  = modelMucTieu
	cframeMucTieuGoc = modelMucTieuGoc:GetPrimaryPartCFrame()

	local banSao      = modelMucTieu:Clone()
	banSao.Name       = "Morph_Character"

	pcall(function()
		modelMucTieuGoc:SetPrimaryPartCFrame(CFrame.new(0, -20000, 0))
	end)

	local gocBanSao = banSao:FindFirstChild("HumanoidRootPart")
	if not gocBanSao then
		banSao:Destroy()
		hoanTac(nhanVat)
		ThongBao("Lỗi!", "Đối tượng bản sao không có HumanoidRootPart.", 3)
		return false
	end

	local humanoidBanSao = banSao:FindFirstChildWhichIsA("Humanoid")
	if not humanoidBanSao then
		banSao:Destroy()
		hoanTac(nhanVat)
		ThongBao("Lỗi!", "Đối tượng bản sao không có Humanoid (cần cho scaling/animation).", 3)
		return false
	end

	humanoidBanSao.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoidBanSao.HealthDisplayType   = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoidBanSao.NameDisplayDistance = 0

	pcall(function()
		local moTaNguoiChoi = humanoidNguoiChoi:GetAppliedDescription()
		local moTaBanSao    = humanoidBanSao:GetAppliedDescription()
		moTaBanSao.BodyDepthScale  = moTaNguoiChoi.BodyDepthScale
		moTaBanSao.BodyHeightScale = moTaNguoiChoi.BodyHeightScale
		moTaBanSao.BodyWidthScale  = moTaNguoiChoi.BodyWidthScale
		moTaBanSao.HeadScale       = moTaNguoiChoi.HeadScale
		humanoidBanSao:ApplyDescription(moTaBanSao)
	end)

	task.wait()

	local doLechDoc = 0
	pcall(function()
		doLechDoc = humanoidNguoiChoi.HipHeight - humanoidBanSao.HipHeight
	end)

	for _, hauDue in ipairs(banSao:GetDescendants()) do
		if (hauDue:IsA("Script") or hauDue:IsA("LocalScript")) and hauDue.Name ~= "Animate" then
			hauDue:Destroy()
		elseif hauDue:IsA("BasePart") then
			hauDue.CanCollide = false
			hauDue.Massless   = true
			if hauDue ~= gocBanSao then hauDue.Anchored = false end
			pcall(function() hauDue:SetNetworkOwner(playerLocal) end)
		end
	end

	gocBanSao.Anchored = false
	banSao.Parent      = nhanVat

	gocBanSao.CFrame = partGoc.CFrame * CFrame.new(0, doLechDoc, 0)

	local lienKet   = Instance.new("WeldConstraint")
	lienKet.Part0   = partGoc
	lienKet.Part1   = gocBanSao
	lienKet.Parent  = partGoc

	cacBoPhanDaTao["NhanVat"] = banSao
	currentPlayerHumanoid     = humanoidNguoiChoi
	currentCloneHumanoid      = humanoidBanSao

	if not animConnection then
		animConnection = RunService.RenderStepped:Connect(updateCloneAnimation)
	end
	return true
end

local function chayBienHinh()
	if not cauHinh.chucNangBat then return end

	if dangBienHinh then
		hoanTac()
		return
	end

	local nhanVat = playerLocal.Character
	if not nhanVat then return end
	local partGoc = nhanVat:FindFirstChild("HumanoidRootPart")
	if not partGoc then return end

	if not partDuocChon then
		if cauHinh.cheDoBienHinh == "TungPhan" then
			local coPartLuuTru = false
			for tenBoPhanLogic, data in pairs(cauHinh.boPhan) do
				if data.Bat and luuTruBoPhan[tenBoPhanLogic] then
					coPartLuuTru = true
					break
				end
			end
			if not coPartLuuTru then
				ThongBao("Lỗi!", "Bạn phải chọn một part (hoặc có part đã lưu trữ)!", 3)
				return
			end
		else
			ThongBao("Lỗi!", "Bạn phải chọn một đối tượng trước!", 3)
			return
		end
	end

	luuTrangThaiNguoiChoi(nhanVat)
	dangBienHinh = true
	capNhatHopChon(nil)
	if nutBienHinh then nutBienHinh.Text = "Hoàn tác" end
	taoHieuUng(partGoc)
	cacBoPhanDaTao = {}

	local thanhCong = false
	if     cauHinh.cheDoBienHinh == "ToanThan" then thanhCong = bienHinhToanThan(nhanVat, partGoc)
	elseif cauHinh.cheDoBienHinh == "TungPhan" then thanhCong = bienHinhTungPhan(nhanVat)
	elseif cauHinh.cheDoBienHinh == "NhanVat"  then thanhCong = bienHinhNhanVat(nhanVat, partGoc)
	end

	if not thanhCong then hoanTac() end
end

local function capNhatUiChucNang(trangThai)
	cauHinh.chucNangBat = trangThai

	if nutBatTatChon then
		nutBatTatChon.Text             = trangThai and "Bật" or "Tắt"
		nutBatTatChon.BackgroundColor3 = trangThai and THEME.COLORS.ButtonGreen or THEME.COLORS.ButtonRed
	end

	if nutToggleUiChinh then
		nutToggleUiChinh.Text             = trangThai and "Bật" or "Tắt"
		nutToggleUiChinh.TextColor3       = THEME.COLORS.ButtonText
		nutToggleUiChinh.BackgroundColor3 = trangThai and THEME.COLORS.ButtonGreen or THEME.COLORS.ButtonRed
	end

	if nutBienHinh      then nutBienHinh.Parent.Visible      = trangThai end
	if nutToggleUiNgoai then nutToggleUiNgoai.Parent.Visible = trangThai end
	if nutDropdownCheDo then nutDropdownCheDo.Parent.Visible = trangThai end
	if frameBoPhan      then
		frameBoPhan.Visible = trangThai and (cauHinh.cheDoBienHinh == "TungPhan")
	end

	if not trangThai then
		hoanTac()
		partDuocChon = nil
		capNhatHopChon(nil)
	end
end

local function toggleChucNang()
	capNhatUiChucNang(not cauHinh.chucNangBat)
end

local function taoDongToggle(parent, tenHienThi, trangThaiBanDau)
	local frame = Instance.new("Frame")
	frame.Name                = "ToggleRow"
	frame.Size                = UDim2.new(1, 0, 0, 30)
	frame.BackgroundTransparency = 1

	local textLabel = Instance.new("TextLabel")
	textLabel.Size                = UDim2.new(0.7, -5, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font                = THEME.FONTS.Main
	textLabel.Text                = tenHienThi
	textLabel.TextColor3          = THEME.COLORS.Text
	textLabel.TextSize            = 16
	textLabel.TextXAlignment      = Enum.TextXAlignment.Left
	textLabel.Parent              = frame

	local nutToggle = Instance.new("TextButton")
	nutToggle.Name                = "Button"
	nutToggle.Size                = UDim2.new(0.25, 0, 0.8, 0)
	nutToggle.Position            = UDim2.new(0.75, 0, 0.1, 0)
	nutToggle.Font                = THEME.FONTS.Bold
	nutToggle.TextScaled          = true
	nutToggle.BorderSizePixel     = 0
	nutToggle.Text                = trangThaiBanDau and "Bật" or "Tắt"
	nutToggle.TextColor3          = THEME.COLORS.ButtonText
	nutToggle.BackgroundColor3    = trangThaiBanDau and THEME.COLORS.ButtonGreen or THEME.COLORS.ButtonRed

	local gocNut = Instance.new("UICorner")
	gocNut.CornerRadius = THEME.ROUNDING.Button
	gocNut.Parent       = nutToggle

	nutToggle.Parent = frame
	frame.Parent     = parent
	return frame, nutToggle
end

local function taoDongNutBam(parent, tenHienThi, textBanDau)
	local frame = Instance.new("Frame")
	frame.Name                = "ButtonRow"
	frame.Size                = UDim2.new(1, 0, 0, 30)
	frame.BackgroundTransparency = 1

	local textLabel = Instance.new("TextLabel")
	textLabel.Size                = UDim2.new(0.55, -5, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font                = THEME.FONTS.Main
	textLabel.Text                = tenHienThi
	textLabel.TextColor3          = THEME.COLORS.Text
	textLabel.TextSize            = 20
	textLabel.TextXAlignment      = Enum.TextXAlignment.Left
	textLabel.Parent              = frame

	local nutBam = Instance.new("TextButton")
	nutBam.Name               = "Button"
	nutBam.Size               = UDim2.new(0.45, 0, 0.8, 0)
	nutBam.Position           = UDim2.new(0.55, 0, 0.1, 0)
	nutBam.Font               = THEME.FONTS.Bold
	nutBam.TextScaled         = true
	nutBam.TextColor3         = THEME.COLORS.TextSecondary
	nutBam.BackgroundColor3   = THEME.COLORS.ButtonGray
	nutBam.BorderSizePixel    = 0
	nutBam.Text               = textBanDau

	local gocNut = Instance.new("UICorner")
	gocNut.CornerRadius = THEME.ROUNDING.Button
	gocNut.Parent       = nutBam

	nutBam.Parent = frame
	frame.Parent  = parent
	return frame, nutBam
end

local function taoDongBoPhan(parent, tenBoPhanLogic, data)
	local tenHienThi = data.TenHienThi

	local frame = Instance.new("Frame")
	frame.Name                = tenBoPhanLogic .. "Row"
	frame.Size                = UDim2.new(1, 0, 0, 25)
	frame.BackgroundTransparency = 1

	local textLabel = Instance.new("TextLabel")
	textLabel.Size                = UDim2.new(0.4, -5, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font                = THEME.FONTS.Main
	textLabel.Text                = "[ + ]   " .. tenHienThi
	textLabel.TextColor3          = THEME.COLORS.Text
	textLabel.TextSize            = 20
	textLabel.TextXAlignment      = Enum.TextXAlignment.Left
	textLabel.Parent              = frame

	local nutCo = Instance.new("TextButton")
	nutCo.Name             = "BatTat"
	nutCo.Size             = UDim2.new(0.2, 0, 0.9, 0)
	nutCo.Position         = UDim2.new(0.4, 0, 0.05, 0)
	nutCo.TextScaled       = true
	nutCo.BorderSizePixel  = 0
	nutCo.Font             = THEME.FONTS.Bold
	Instance.new("UICorner", nutCo).CornerRadius = THEME.ROUNDING.ButtonSmall
	nutCo.Parent = frame

	local nutLuuGiu = Instance.new("TextButton")
	nutLuuGiu.Name            = "LuuGiu"
	nutLuuGiu.Size            = UDim2.new(0.35, 0, 0.9, 0)
	nutLuuGiu.Position        = UDim2.new(0.6, 5, 0.05, 0)
	nutLuuGiu.Text            = "Lưu trữ"
	nutLuuGiu.TextScaled      = true
	nutLuuGiu.TextColor3      = THEME.COLORS.ButtonText
	nutLuuGiu.BackgroundColor3= THEME.COLORS.ButtonBlue
	nutLuuGiu.BorderSizePixel = 0
	nutLuuGiu.Font            = THEME.FONTS.Main
	Instance.new("UICorner", nutLuuGiu).CornerRadius = THEME.ROUNDING.ButtonSmall
	nutLuuGiu.Parent = frame

	local nutXoaLuu = Instance.new("TextButton")
	nutXoaLuu.Name            = "XoaLuu"
	nutXoaLuu.Size            = UDim2.new(0.35, 0, 0.9, 0)
	nutXoaLuu.Position        = UDim2.new(0.6, 5, 0.05, 0)
	nutXoaLuu.Text            = "Xóa lưu"
	nutXoaLuu.TextScaled      = true
	nutXoaLuu.TextColor3      = THEME.COLORS.ButtonText
	nutXoaLuu.BackgroundColor3= THEME.COLORS.ButtonRed
	nutXoaLuu.BorderSizePixel = 0
	nutXoaLuu.Font            = THEME.FONTS.Main
	Instance.new("UICorner", nutXoaLuu).CornerRadius = THEME.ROUNDING.ButtonSmall
	nutXoaLuu.Parent = frame

	local function capNhatNut()
		local batTat = cauHinh.boPhan[tenBoPhanLogic].Bat
		nutCo.Text             = batTat and "Có" or "Không"
		nutCo.TextColor3       = THEME.COLORS.ButtonText
		nutCo.BackgroundColor3 = batTat and THEME.COLORS.ButtonGreen or THEME.COLORS.ButtonRed

		local luuGiu = cauHinh.boPhan[tenBoPhanLogic].LuuGiu
		nutLuuGiu.Visible = not luuGiu
		nutXoaLuu.Visible = luuGiu
	end

	nutCo.MouseButton1Click:Connect(function()
		cauHinh.boPhan[tenBoPhanLogic].Bat = not cauHinh.boPhan[tenBoPhanLogic].Bat
		capNhatNut()
	end)

	nutLuuGiu.MouseButton1Click:Connect(function()
		if partDuocChon then
			luuTruBoPhan[tenBoPhanLogic]           = partDuocChon:Clone()
			cauHinh.boPhan[tenBoPhanLogic].LuuGiu = true
			ThongBao("Đã lưu", "Đã lưu " .. partDuocChon.Name .. " cho " .. tenHienThi, 2)
			capNhatNut()
		else
			ThongBao("Lỗi", "Bạn phải chọn một part trước khi lưu!", 3)
		end
	end)

	nutXoaLuu.MouseButton1Click:Connect(function()
		luuTruBoPhan[tenBoPhanLogic]           = nil
		cauHinh.boPhan[tenBoPhanLogic].LuuGiu = false
		ThongBao("Đã xóa", "Đã xóa lưu cho " .. tenHienThi, 2)
		capNhatNut()
	end)

	capNhatNut()
	frame.Parent = parent
	return frame
end

local function taoGiaoDien()
	local screenGui          = Instance.new("ScreenGui")
	screenGui.Name           = "TransformScreenGui"
	screenGui.ResetOnSpawn   = false

	uiChinh                  = Instance.new("Frame")
	uiChinh.Name             = "UiTuChinh"
	uiChinh.Size             = UDim2.new(0, 300, 0, 350)
	uiChinh.Position         = UDim2.new(0.5, 0, 0.5, 0)
	uiChinh.AnchorPoint      = Vector2.new(0.5, 0.5)
	uiChinh.BackgroundColor3 = THEME.COLORS.Background
	uiChinh.BorderColor3     = THEME.COLORS.Border
	uiChinh.Visible          = false
	uiChinh.Active           = true

	Instance.new("UICorner", uiChinh).CornerRadius = THEME.ROUNDING.Main

	local khungTieuDe          = Instance.new("Frame")
	khungTieuDe.Name           = "TitleFrame"
	khungTieuDe.Size           = UDim2.new(1, 0, 0, 40)
	khungTieuDe.BackgroundColor3 = THEME.COLORS.Header

	khungTieuDe.Active         = false
	khungTieuDe.Parent         = uiChinh
	Instance.new("UICorner", khungTieuDe).CornerRadius = THEME.ROUNDING.Main

	local iconUi             = Instance.new("ImageLabel")
	iconUi.Size              = UDim2.new(0, 30, 0, 30)
	iconUi.Position          = UDim2.new(0, 5, 0.5, -15)
	iconUi.BackgroundTransparency = 1
	iconUi.Image             = ANH_ICON_MO
	iconUi.Parent            = khungTieuDe

	local tieuDeUi            = Instance.new("TextLabel")
	tieuDeUi.Text             = "Transform"
	tieuDeUi.Size             = UDim2.new(1, -80, 1, 0)
	tieuDeUi.Position         = UDim2.new(0, 40, 0, 0)
	tieuDeUi.BackgroundTransparency = 1
	tieuDeUi.TextColor3       = THEME.COLORS.Text
	tieuDeUi.Font             = THEME.FONTS.Main
	tieuDeUi.TextSize         = 20
	tieuDeUi.TextXAlignment   = Enum.TextXAlignment.Left
	tieuDeUi.Parent           = khungTieuDe

	local nutDong             = Instance.new("TextButton")
	nutDong.Name              = "CloseButton"
	nutDong.Size              = UDim2.new(0, 30, 0, 30)
	nutDong.Position          = UDim2.new(1, -35, 0.5, -15)
	nutDong.Text              = "x"
	nutDong.TextScaled        = true
	nutDong.Font              = THEME.FONTS.Bold
	nutDong.TextColor3        = THEME.COLORS.ButtonText
	nutDong.BackgroundColor3  = THEME.COLORS.ButtonRed
	nutDong.BorderSizePixel   = 0
	Instance.new("UICorner", nutDong).CornerRadius = THEME.ROUNDING.Button
	local paddingDong         = Instance.new("UIPadding")
	paddingDong.PaddingBottom = UDim.new(0, 5)
	paddingDong.Parent        = nutDong
	nutDong.MouseButton1Click:Connect(function() uiChinh.Visible = false end)
	nutDong.Parent = khungTieuDe

	local khungDieuKhien    = Instance.new("Frame")
	khungDieuKhien.Name     = "ControlsFrame"
	khungDieuKhien.Size     = UDim2.new(1, 0, 1, -40)
	khungDieuKhien.Position = UDim2.new(0, 0, 0, 40)
	khungDieuKhien.BackgroundTransparency = 1

	local paddingChinh           = Instance.new("UIPadding")
	paddingChinh.PaddingLeft     = UDim.new(0, 10)
	paddingChinh.PaddingRight    = UDim.new(0, 10)
	paddingChinh.PaddingTop      = UDim.new(0, 10)
	paddingChinh.PaddingBottom   = UDim.new(0, 10)
	paddingChinh.Parent          = khungDieuKhien

	local layoutList             = Instance.new("UIListLayout")
	layoutList.Padding           = UDim.new(0, 5)
	layoutList.SortOrder         = Enum.SortOrder.LayoutOrder
	layoutList.Parent            = khungDieuKhien

	frameBoPhan                  = Instance.new("Frame")
	frameBoPhan.Name             = "FrameDongBoPhan"
	frameBoPhan.Size             = UDim2.new(1, 0, 1, 0)
	frameBoPhan.AutomaticSize    = Enum.AutomaticSize.Y
	frameBoPhan.BackgroundTransparency = 1
	frameBoPhan.ClipsDescendants = true
	frameBoPhan.Visible          = false
	frameBoPhan.LayoutOrder      = 4

	local layoutBoPhan   = Instance.new("UIListLayout")
	layoutBoPhan.Padding = UDim.new(0, 5)
	layoutBoPhan.Parent  = frameBoPhan

	local paddingBoPhan          = Instance.new("UIPadding")
	paddingBoPhan.PaddingLeft    = UDim.new(0, 10)
	paddingBoPhan.Parent         = frameBoPhan

	for _, tenBoPhanLogic in ipairs(THU_TU_BO_PHAN) do
		local data = cauHinh.boPhan[tenBoPhanLogic]
		if data then taoDongBoPhan(frameBoPhan, tenBoPhanLogic, data) end
	end
	frameBoPhan.Parent  = khungDieuKhien
	khungDieuKhien.Parent = uiChinh

	local dongToggleChinh, nut1 = taoDongToggle(khungDieuKhien, "Chức năng biến hình", cauHinh.chucNangBat)
	dongToggleChinh.LayoutOrder = 1
	nutToggleUiChinh            = nut1
	nut1.MouseButton1Click:Connect(toggleChucNang)

	local dongToggleNutNgoai, nut2 = taoDongToggle(khungDieuKhien, "Hiện Nút bật tắt bên ngoài", cauHinh.hienNutNgoai)
	dongToggleNutNgoai.LayoutOrder = 2
	nutToggleUiNgoai               = nut2
	nut2.MouseButton1Click:Connect(function()
		cauHinh.hienNutNgoai = not cauHinh.hienNutNgoai
		if khungNutBatTat then khungNutBatTat.Visible = cauHinh.hienNutNgoai end
		nut2.Text             = cauHinh.hienNutNgoai and "Bật" or "Tắt"
		nut2.TextColor3       = THEME.COLORS.ButtonText
		nut2.BackgroundColor3 = cauHinh.hienNutNgoai and THEME.COLORS.ButtonGreen or THEME.COLORS.ButtonRed
	end)

	local dongChonCheDo, nut3 = taoDongNutBam(khungDieuKhien, "Thành phần", "Toàn thân")
	dongChonCheDo.LayoutOrder  = 3
	nutDropdownCheDo           = nut3
	nut3.MouseButton1Click:Connect(function()
		hoanTac()
		if     cauHinh.cheDoBienHinh == "ToanThan" then cauHinh.cheDoBienHinh = "TungPhan" ; nut3.Text = "Từng phần"
		elseif cauHinh.cheDoBienHinh == "TungPhan" then cauHinh.cheDoBienHinh = "NhanVat"  ; nut3.Text = "Nhân vật"
		elseif cauHinh.cheDoBienHinh == "NhanVat"  then cauHinh.cheDoBienHinh = "ToanThan" ; nut3.Text = "Toàn thân"
		end
		frameBoPhan.Visible = cauHinh.chucNangBat and (cauHinh.cheDoBienHinh == "TungPhan")
	end)

	uiChinh.Parent = screenGui

	nutMoUi                      = Instance.new("ImageButton")
	nutMoUi.Name                 = "NutMoiDiChuyen"
	nutMoUi.Size                 = UDim2.new(0, 50, 0, 50)
	nutMoUi.Position             = UDim2.new(0, 10, 0.5, 0)
	nutMoUi.BackgroundColor3     = THEME.COLORS.OpenButton
	nutMoUi.Image                = ANH_ICON_MO
	nutMoUi.BackgroundTransparency = 0.2
	nutMoUi.ScaleType            = Enum.ScaleType.Crop
	nutMoUi.Active               = true

	Instance.new("UICorner", nutMoUi).CornerRadius = THEME.ROUNDING.Main
	nutMoUi.MouseButton1Click:Connect(function()
		uiChinh.Visible = not uiChinh.Visible
	end)
	nutMoUi.Parent = screenGui

	khungNutBatTat                  = Instance.new("Frame")
	khungNutBatTat.Name             = "ToggleSelectButtonContainer"
	khungNutBatTat.Size             = UDim2.new(0, 50, 0, 50)
	khungNutBatTat.Position         = UDim2.new(1, -70, 0.6, 0)
	khungNutBatTat.AnchorPoint      = Vector2.new(1, 1)
	khungNutBatTat.BackgroundColor3 = THEME.COLORS.OutsideContainer
	khungNutBatTat.BackgroundTransparency = 0.8
	khungNutBatTat.Visible          = cauHinh.hienNutNgoai
	Instance.new("UICorner", khungNutBatTat).CornerRadius = THEME.ROUNDING.Circle

	nutBatTatChon                   = Instance.new("TextButton")
	nutBatTatChon.Name              = "ToggleSelectButton"
	nutBatTatChon.Size              = UDim2.new(0.85, 0, 0.85, 0)
	nutBatTatChon.Position          = UDim2.new(0.05, 1, 0.05, 1)
	nutBatTatChon.TextColor3        = THEME.COLORS.ButtonText
	nutBatTatChon.Font              = THEME.FONTS.Special
	nutBatTatChon.TextScaled        = true
	nutBatTatChon.BackgroundTransparency = 0.15
	nutBatTatChon.BorderSizePixel   = 0
	Instance.new("UICorner", nutBatTatChon).CornerRadius = THEME.ROUNDING.Circle
	nutBatTatChon.MouseButton1Click:Connect(toggleChucNang)
	nutBatTatChon.Parent     = khungNutBatTat
	khungNutBatTat.Parent    = screenGui

	if UserInputService.TouchEnabled then
		khungNutBatTat.Position = UDim2.new(1, -10, 0.6, -60)

		local khungNutBienHinh                  = Instance.new("Frame")
		khungNutBienHinh.Name                   = "TransformButtonContainer"
		khungNutBienHinh.Size                   = UDim2.new(0, 50, 0, 50)
		khungNutBienHinh.Position               = UDim2.new(1, -70, 0.6, 0)
		khungNutBienHinh.AnchorPoint            = Vector2.new(1, 1)
		khungNutBienHinh.BackgroundColor3       = THEME.COLORS.OutsideContainer
		khungNutBienHinh.BackgroundTransparency = 0.8
		khungNutBienHinh.Visible                = cauHinh.chucNangBat
		Instance.new("UICorner", khungNutBienHinh).CornerRadius = THEME.ROUNDING.Circle

		nutBienHinh                   = Instance.new("TextButton")
		nutBienHinh.Name              = "TransformButton"
		nutBienHinh.Size              = UDim2.new(0.85, 0, 0.85, 0)
		nutBienHinh.Position          = UDim2.new(0.05, 1, 0.05, 1)
		nutBienHinh.BackgroundColor3  = THEME.COLORS.OutsideButton
		nutBienHinh.TextColor3        = THEME.COLORS.ButtonText
		nutBienHinh.Text              = "Biến"
		nutBienHinh.Font              = THEME.FONTS.Special
		nutBienHinh.TextScaled        = true
		nutBienHinh.BackgroundTransparency = 0.15
		nutBienHinh.BorderSizePixel   = 0
		Instance.new("UICorner", nutBienHinh).CornerRadius = THEME.ROUNDING.Circle
		nutBienHinh.MouseButton1Click:Connect(chayBienHinh)
		nutBienHinh.Parent        = khungNutBienHinh
		khungNutBienHinh.Parent   = screenGui
	end

	taoKeoTha(uiChinh, khungTieuDe)
	taoKeoTha(nutMoUi)

	capNhatUiChucNang(cauHinh.chucNangBat)
	screenGui.Parent = playerGui
end

UserInputService.InputBegan:Connect(function(input, daXuLyGame)

	if input.KeyCode == Enum.KeyCode.R and not daXuLyGame then
		chayBienHinh()
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch
	then return end

	if daXuLyGame or dangBienHinh or not cauHinh.chucNangBat then return end

	local character = playerLocal.Character
	if not character then return end

	local ray = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
	local raycastParams                        = RaycastParams.new()
	raycastParams.FilterType                   = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances   = hopChon and { character, hopChon } or { character }

	local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
	if not raycastResult or not raycastResult.Instance then return end

	local partChonDuoc = raycastResult.Instance
	if not partChonDuoc:IsA("BasePart") or partChonDuoc:IsA("Terrain") then return end

	if cauHinh.cheDoBienHinh == "NhanVat" then
		local modelMucTieu = partChonDuoc:FindFirstAncestorWhichIsA("Model")
		if not modelMucTieu or not modelMucTieu:FindFirstChildWhichIsA("Humanoid") then
			ThongBao("Lỗi!", "Bạn phải chọn một người chơi (hoặc đối tượng có Humanoid).", 3)
			return
		end
	elseif cauHinh.cheDoBienHinh == "ToanThan" or cauHinh.cheDoBienHinh == "TungPhan" then
		local modelMucTieu = partChonDuoc:FindFirstAncestorWhichIsA("Model")
		if modelMucTieu and modelMucTieu:FindFirstChildWhichIsA("Humanoid") then
			ThongBao("Lỗi!", "Không thể chọn người chơi/nhân vật ở chế độ này.", 3)
			return
		end
	end

	partDuocChon = partChonDuoc
	capNhatHopChon(partDuocChon)
	ThongBao("Đã chọn Part!", "Nhấn [R] (PC) hoặc nút [Biến] (Mobile) để biến hình.", 4)
end)

local function xuLyNhanVatAdded(nhanVat)
	hoanTac(nhanVat)
	local humanoid = nhanVat:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		hoanTac(nhanVat)
	end)
end

playerLocal.CharacterAdded:Connect(xuLyNhanVatAdded)
if playerLocal.Character then
	xuLyNhanVatAdded(playerLocal.Character)
end

taoGiaoDien()