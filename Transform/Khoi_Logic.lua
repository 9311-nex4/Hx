local Khoi_Logic = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local THOI_GIAN_GIU_CHON = 0.3 
local MAU_CHON = Color3.fromRGB(255, 170, 0)

local DanhSachKhoi = {}
local CacKhoiDangChon = {}
local ToolHienTai = 1 

local HandleMove = nil
local HandleScale = nil
local HandleRotate = nil
local UiPhai = nil 

local GocCFrame = nil
local GocSize = nil

Khoi_Logic.SuKienThayDoi = Instance.new("BindableEvent")
Khoi_Logic.SuKienChon = Instance.new("BindableEvent")

local DanhSachNutUI = {}

local function CapNhatMauNut(ToolIdDangChon)
	for id, btn in pairs(DanhSachNutUI) do
		if id == ToolIdDangChon then
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
		else
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
		end
	end
end

local function TaoUiBenPhai()
	if UiPhai then UiPhai:Destroy() end

	DanhSachNutUI = {} 

	local PlayerGui = Player:WaitForChild("PlayerGui")

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "RightSideUI_Module"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = PlayerGui

	local KhungPhai = Instance.new("Frame")
	KhungPhai.Size = UDim2.new(0, 60, 0, 170)
	KhungPhai.Position = UDim2.new(1, -80, 0.5, -120)
	KhungPhai.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	KhungPhai.BackgroundTransparency = 0.8
	KhungPhai.Visible = false
	KhungPhai.Parent = ScreenGui

	Instance.new("UICorner", KhungPhai).CornerRadius = UDim.new(0, 12)

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color3.fromRGB(80, 80, 80)
	Stroke.Thickness = 2
	Stroke.Parent = KhungPhai

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.Parent = KhungPhai
	ListLayout.FillDirection = Enum.FillDirection.Vertical
	ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ListLayout.Padding = UDim.new(0, 15)

	local function TaoNutTool(IdAnh, ToolId, PhimTat)
		local Btn = Instance.new("ImageButton")
		Btn.Name = "Tool_" .. ToolId
		Btn.Size = UDim2.new(0, 40, 0, 40)
		Btn.Image = IdAnh
		Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Btn.BackgroundTransparency = 0.5
		Btn.ImageColor3 = Color3.fromRGB(255, 255, 255)
		Btn.Parent = KhungPhai

		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

		local Padding = Instance.new("UIPadding")
		Padding.PaddingTop = UDim.new(0, 8)
		Padding.PaddingBottom = UDim.new(0, 8)
		Padding.PaddingLeft = UDim.new(0, 8)
		Padding.PaddingRight = UDim.new(0, 8)
		Padding.Parent = Btn

		DanhSachNutUI[ToolId] = Btn

		Btn.MouseButton1Click:Connect(function()
			Khoi_Logic.ChinhTool(ToolId)
		end)
	end

	TaoNutTool("rbxassetid://98501712328327", 1, "1") 
	TaoNutTool("rbxassetid://131983126233194", 2, "2") 
	TaoNutTool("rbxassetid://94475561845407", 3, "3") 

	CapNhatMauNut(ToolHienTai)

	UiPhai = KhungPhai
end

local function TimKhoiGoc(Target)
	if not Target then return nil end
	for _, v in ipairs(DanhSachKhoi) do
		if v == Target then return v end
		if Target:IsDescendantOf(v) then return v end
	end
	return nil
end

local function HieuUngChon(Part)
	if not Part or not Part:IsA("BasePart") then return end
	local OldSize = Part.Size
	local TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local T1 = TweenService:Create(Part, TweenInfo, {Size = OldSize * 1.15})
	T1:Play()
	T1.Completed:Connect(function()
		TweenService:Create(Part, TweenInfo, {Size = OldSize}):Play()
	end)
end

local function CapNhatHandles()
	if HandleMove then HandleMove:Destroy() HandleMove = nil end
	if HandleScale then HandleScale:Destroy() HandleScale = nil end
	if HandleRotate then HandleRotate:Destroy() HandleRotate = nil end

	local SoLuongChon = 0
	local DoiTuongChon = nil
	for k, _ in pairs(CacKhoiDangChon) do SoLuongChon = SoLuongChon + 1; DoiTuongChon = k end

	if SoLuongChon ~= 1 then return end

	local AdorneePart = DoiTuongChon
	if DoiTuongChon:IsA("Model") then AdorneePart = DoiTuongChon.PrimaryPart or DoiTuongChon:FindFirstChildWhichIsA("BasePart") end
	if not AdorneePart then return end

	local PlayerGui = Player:WaitForChild("PlayerGui")
	local GizmoFolder = PlayerGui:FindFirstChild("TransformGizmos_Folder")
	if not GizmoFolder then
		GizmoFolder = Instance.new("Folder")
		GizmoFolder.Name = "TransformGizmos_Folder"
		GizmoFolder.Parent = PlayerGui
	end

	if ToolHienTai == 1 then
		HandleMove = Instance.new("Handles")
		HandleMove.Adornee = AdorneePart
		HandleMove.Style = Enum.HandlesStyle.Movement
		HandleMove.Color3 = Color3.new(1, 0, 0)
		HandleMove.Parent = GizmoFolder

		HandleMove.MouseButton1Down:Connect(function() GocCFrame = AdorneePart.CFrame end)
		HandleMove.MouseDrag:Connect(function(Face, Distance)
			if not GocCFrame then return end
			local Delta = Vector3.new(0,0,0)
			if Face == Enum.NormalId.Right then Delta = GocCFrame.RightVector * Distance
			elseif Face == Enum.NormalId.Left then Delta = -GocCFrame.RightVector * Distance
			elseif Face == Enum.NormalId.Top then Delta = GocCFrame.UpVector * Distance
			elseif Face == Enum.NormalId.Bottom then Delta = -GocCFrame.UpVector * Distance
			elseif Face == Enum.NormalId.Front then Delta = GocCFrame.LookVector * Distance
			elseif Face == Enum.NormalId.Back then Delta = -GocCFrame.LookVector * Distance
			end
			AdorneePart.CFrame = GocCFrame + Delta
		end)

	elseif ToolHienTai == 2 then
		HandleScale = Instance.new("Handles")
		HandleScale.Adornee = AdorneePart
		HandleScale.Style = Enum.HandlesStyle.Resize
		HandleScale.Color3 = Color3.new(0, 0, 1)
		HandleScale.Parent = GizmoFolder

		HandleScale.MouseButton1Down:Connect(function() GocSize = AdorneePart.Size; GocCFrame = AdorneePart.CFrame end)
		HandleScale.MouseDrag:Connect(function(Face, Distance)
			if not GocSize or not AdorneePart:IsA("BasePart") then return end
			local Axis = Vector3.FromNormalId(Face)
			local AbsAxis = Vector3.new(math.abs(Axis.X), math.abs(Axis.Y), math.abs(Axis.Z))
			local NewSize = GocSize + (AbsAxis * Distance)

			if NewSize.X < 0.2 then NewSize = Vector3.new(0.2, NewSize.Y, NewSize.Z) end
			if NewSize.Y < 0.2 then NewSize = Vector3.new(NewSize.X, 0.2, NewSize.Z) end
			if NewSize.Z < 0.2 then NewSize = Vector3.new(NewSize.X, NewSize.Y, 0.2) end

			AdorneePart.Size = NewSize
		end)

	elseif ToolHienTai == 3 then
		HandleRotate = Instance.new("ArcHandles")
		HandleRotate.Adornee = AdorneePart
		HandleRotate.Axes = Axes.new(Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z)
		HandleRotate.Parent = GizmoFolder

		HandleRotate.MouseButton1Down:Connect(function() GocCFrame = AdorneePart.CFrame end)
		HandleRotate.MouseDrag:Connect(function(Axis, RelativeAngle)
			if not GocCFrame then return end
			if Axis == Enum.Axis.X then AdorneePart.CFrame = GocCFrame * CFrame.Angles(RelativeAngle, 0, 0)
			elseif Axis == Enum.Axis.Y then AdorneePart.CFrame = GocCFrame * CFrame.Angles(0, RelativeAngle, 0)
			elseif Axis == Enum.Axis.Z then AdorneePart.CFrame = GocCFrame * CFrame.Angles(0, 0, RelativeAngle)
			end
		end)
	end
end

local function CapNhatHieuUngVien()
	for _, v in ipairs(DanhSachKhoi) do
		local Item = v
		if v:IsA("Model") then Item = v.PrimaryPart end
		if Item and Item:FindFirstChild("HieuUngChon") then Item.HieuUngChon:Destroy() end
	end

	for Khoi, _ in pairs(CacKhoiDangChon) do
		local Target = Khoi
		if Khoi:IsA("Model") then Target = Khoi.PrimaryPart end

		if Target then
			local Box = Instance.new("SelectionBox")
			Box.Name = "HieuUngChon"
			Box.Adornee = Target
			Box.LineThickness = 0.05
			Box.Color3 = MAU_CHON
			Box.Parent = Target
		end
	end
end

function Khoi_Logic.TaoKhoiMau()
	local RootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then return end

	local PartMoi = Instance.new("Part")
	PartMoi.Name = "Khoi_" .. tostring(math.random(1000, 9999))
	PartMoi.Size = Vector3.new(4, 1, 4)
	PartMoi.CFrame = RootPart.CFrame * CFrame.new(0, 0, -10)
	PartMoi.Color = Color3.fromRGB(math.random(100,255), math.random(100,255), math.random(100,255))
	PartMoi.Material = Enum.Material.SmoothPlastic
	PartMoi.Anchored = true
	PartMoi.Parent = Workspace

	table.insert(DanhSachKhoi, PartMoi)
	Khoi_Logic.SuKienThayDoi:Fire("Them", PartMoi)

	return PartMoi.Name
end

function Khoi_Logic.XoaKhoiChon()
	for Khoi, _ in pairs(CacKhoiDangChon) do
		if Khoi.Parent then 
			Khoi_Logic.SuKienThayDoi:Fire("Xoa", Khoi)
			Khoi:Destroy() 
		end
	end
	CacKhoiDangChon = {}
	CapNhatHandles()
	if UiPhai then UiPhai.Visible = false end
end

function Khoi_Logic.ChinhTool(CheDo)
	ToolHienTai = CheDo
	CapNhatHandles()
	CapNhatMauNut(CheDo)
end

function Khoi_Logic.HanCacKhoi()
	local PartsToGroup = {}
	for Khoi, _ in pairs(CacKhoiDangChon) do table.insert(PartsToGroup, Khoi) end
	if #PartsToGroup < 2 then return "Cần chọn ít nhất 2 khối!" end

	local ModelMoi = Instance.new("Model")
	ModelMoi.Name = "Nhom_Han_" .. math.random(100,999)
	ModelMoi.Parent = Workspace

	local Primary = nil
	for _, Khoi in ipairs(PartsToGroup) do
		Khoi_Logic.SuKienThayDoi:Fire("Xoa", Khoi)
		for i, v in ipairs(DanhSachKhoi) do if v == Khoi then table.remove(DanhSachKhoi, i) break end end

		Khoi.Parent = ModelMoi
		if not Primary then Primary = Khoi end

		if Khoi ~= Primary then
			local Weld = Instance.new("WeldConstraint")
			Weld.Part0 = Primary
			Weld.Part1 = Khoi
			Weld.Parent = Primary
			Khoi.Anchored = true 
		end
	end
	ModelMoi.PrimaryPart = Primary

	table.insert(DanhSachKhoi, ModelMoi)
	Khoi_Logic.SuKienThayDoi:Fire("Them", ModelMoi)

	CacKhoiDangChon = {}
	CapNhatHieuUngVien()
	CapNhatHandles()
	return "Đã hàn thành nhóm: " .. ModelMoi.Name
end

function Khoi_Logic.ThaoCacKhoi()
	local Count = 0
	local CacModelCanRa = {}

	for Khoi, _ in pairs(CacKhoiDangChon) do
		if Khoi:IsA("Model") then table.insert(CacModelCanRa, Khoi) end
	end

	if #CacModelCanRa == 0 then return "Chưa chọn Nhóm (Model) nào để tháo!" end

	for _, Model in ipairs(CacModelCanRa) do
		Khoi_Logic.SuKienThayDoi:Fire("Xoa", Model)
		for i, v in ipairs(DanhSachKhoi) do if v == Model then table.remove(DanhSachKhoi, i) break end end

		local Children = Model:GetChildren()
		for _, Child in ipairs(Children) do
			if Child:IsA("BasePart") then
				Child.Parent = Workspace
				table.insert(DanhSachKhoi, Child)
				Khoi_Logic.SuKienThayDoi:Fire("Them", Child)
				for _, w in ipairs(Child:GetChildren()) do if w:IsA("WeldConstraint") then w:Destroy() end end
				Count = Count + 1
			end
		end
		Model:Destroy()
	end

	CacKhoiDangChon = {}
	CapNhatHieuUngVien()
	CapNhatHandles()
	return "Đã tháo hàn " .. Count .. " khối."
end

local MouseDownTime = 0
local StartMousePos = Vector2.new(0,0)
local IsCheckingHold = false

UserInputService.InputBegan:Connect(function(Input, GPE)
	if UiPhai and UiPhai.Visible and not GPE then
		if Input.KeyCode == Enum.KeyCode.One then Khoi_Logic.ChinhTool(1) end
		if Input.KeyCode == Enum.KeyCode.Two then Khoi_Logic.ChinhTool(2) end
		if Input.KeyCode == Enum.KeyCode.Three then Khoi_Logic.ChinhTool(3) end
	end

	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		if GPE then return end 
		IsCheckingHold = true
		MouseDownTime = tick()
		StartMousePos = UserInputService:GetMouseLocation()
	end
end)

UserInputService.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		IsCheckingHold = false
	end
end)

RunService.RenderStepped:Connect(function()
	if IsCheckingHold then
		local CurrentTime = tick()
		local CurrentPos = UserInputService:GetMouseLocation()

		if (CurrentPos - StartMousePos).Magnitude > 20 then
			IsCheckingHold = false
			return
		end

		if CurrentTime - MouseDownTime >= THOI_GIAN_GIU_CHON then
			IsCheckingHold = false
			local Target = Mouse.Target
			local KhoiTimDuoc = TimKhoiGoc(Target)

			if KhoiTimDuoc then
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
					if CacKhoiDangChon[KhoiTimDuoc] then
						CacKhoiDangChon[KhoiTimDuoc] = nil
					else
						CacKhoiDangChon[KhoiTimDuoc] = true
						HieuUngChon(KhoiTimDuoc:IsA("Model") and KhoiTimDuoc.PrimaryPart or KhoiTimDuoc)
					end
				else
					CacKhoiDangChon = {}
					CacKhoiDangChon[KhoiTimDuoc] = true
					HieuUngChon(KhoiTimDuoc:IsA("Model") and KhoiTimDuoc.PrimaryPart or KhoiTimDuoc)
				end
				CapNhatHieuUngVien()
				CapNhatHandles()
				if UiPhai then 
					UiPhai.Visible = true 
					CapNhatMauNut(ToolHienTai)
				end
			else
				if not UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
					CacKhoiDangChon = {}
					CapNhatHieuUngVien()
					CapNhatHandles()
					if UiPhai then UiPhai.Visible = false end
				end
			end
		end
	end
end)

task.delay(1, function()
	TaoUiBenPhai()
end)

return Khoi_Logic
