local AutoClickLogic = {}

local DichVuAo     = game:GetService("VirtualInputManager")
local DichVuDauVao = game:GetService("UserInputService")
local DichVuTween  = game:GetService("TweenService")
local NguoiChoiSV  = game:GetService("Players")
local CoreGui      = game:GetService("CoreGui")

AutoClickLogic.DanhSachDiem = {}
AutoClickLogic.DangChay     = false
AutoClickLogic.TocDo        = 500
AutoClickLogic.AnTatCa      = false
AutoClickLogic.OnToaDoDoi   = nil

local PlayerGui           = NguoiChoiSV.LocalPlayer:WaitForChild("PlayerGui")
local VungHienThiDiem     = nil
local DiemDangKeo         = nil
local LuongAutoClick      = nil
local DanhSachUICham      = {}
local DanhSachEventKeoTha = {}

local function XoaGuiCu(ThuMuc)
	if not ThuMuc then return end
	for _, PhanTu in ipairs(ThuMuc:GetChildren()) do
		if PhanTu.Name == "HxAutoClickPoints" then
			PhanTu:Destroy()
		end
	end
end

pcall(XoaGuiCu, CoreGui)
pcall(XoaGuiCu, PlayerGui)

local function LayHoacTaoGui()
	if VungHienThiDiem and VungHienThiDiem.Parent then
		return VungHienThiDiem
	end
	local gui = Instance.new("ScreenGui")
	gui.Name             = "HxAutoClickPoints"
	gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder     = 2147483647
	gui.ResetOnSpawn     = false
	gui.IgnoreGuiInset   = true

	local ok = pcall(function() gui.Parent = CoreGui end)
	if not ok or not gui.Parent then
		gui.Parent = PlayerGui
	end
	VungHienThiDiem = gui
	return gui
end

VungHienThiDiem = LayHoacTaoGui()

local function NgatKetNoiKeoTha()
	for _, evt in ipairs(DanhSachEventKeoTha) do
		evt:Disconnect()
	end
	table.clear(DanhSachEventKeoTha)
end

local function TaoKeoThaChoDiem(ChamUI, DiemData, Index)
	local viTriChuotBatDau, viTriGUIBatDau

	local e1 = ChamUI.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			if DiemDangKeo == nil then
				DiemDangKeo       = ChamUI
				ChamUI.ZIndex     = 50
				viTriChuotBatDau  = input.Position
				viTriGUIBatDau    = ChamUI.Position
			end
		end
	end)

	local e2 = ChamUI.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			if DiemDangKeo == ChamUI then
				DiemDangKeo   = nil
				ChamUI.ZIndex = 10

				DiemData.X = math.floor(ChamUI.Position.X.Offset)
				DiemData.Y = math.floor(ChamUI.Position.Y.Offset)

				if AutoClickLogic.OnToaDoDoi then
					pcall(AutoClickLogic.OnToaDoDoi, Index, DiemData.X, DiemData.Y)
				end
			end
		end
	end)

	local e3 = DichVuDauVao.InputChanged:Connect(function(input)
		if DiemDangKeo == ChamUI
			and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - viTriChuotBatDau
			ChamUI.Position = UDim2.new(
				viTriGUIBatDau.X.Scale, viTriGUIBatDau.X.Offset + delta.X,
				viTriGUIBatDau.Y.Scale, viTriGUIBatDau.Y.Offset + delta.Y
			)
		end
	end)

	table.insert(DanhSachEventKeoTha, e1)
	table.insert(DanhSachEventKeoTha, e2)
	table.insert(DanhSachEventKeoTha, e3)
end

function AutoClickLogic.CapNhatDiem(DanhSach)
	VungHienThiDiem = LayHoacTaoGui()
	AutoClickLogic.DanhSachDiem = DanhSach
	DiemDangKeo = nil

	NgatKetNoiKeoTha()

	for _, ui in ipairs(DanhSachUICham) do
		if ui and ui.Parent then ui:Destroy() end
	end
	table.clear(DanhSachUICham)

	for ThuTu, Diem in ipairs(DanhSach) do
		local Cham = Instance.new("Frame")
		Cham.Name                    = "ClickPoint_" .. ThuTu
		Cham.Size                    = UDim2.fromOffset(36, 36)
		Cham.Position                = UDim2.fromOffset(math.floor(Diem.X), math.floor(Diem.Y))
		Cham.AnchorPoint             = Vector2.new(0.5, 0.5)
		Cham.BackgroundTransparency  = 1
		Cham.ZIndex                  = 10
		Cham.Active                  = true
		Cham.Visible                 = not (AutoClickLogic.AnTatCa or Diem.DaAn)

		local VongNgoai = Instance.new("Frame", Cham)
		VongNgoai.Name                   = "VongNgoai"
		VongNgoai.Size                   = UDim2.fromScale(1, 1)
		VongNgoai.AnchorPoint            = Vector2.new(0.5, 0.5)
		VongNgoai.Position               = UDim2.fromScale(0.5, 0.5)
		VongNgoai.BackgroundColor3       = Color3.fromRGB(15, 60, 160)
		VongNgoai.BackgroundTransparency = 0.7
		VongNgoai.ZIndex                 = 10
		Instance.new("UICorner", VongNgoai).CornerRadius = UDim.new(1, 0)

		local VienNgoai = Instance.new("UIStroke", VongNgoai)
		VienNgoai.Color           = Color3.fromRGB(120, 200, 255)
		VienNgoai.Thickness       = 2
		VienNgoai.Transparency    = 0.25
		VienNgoai.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local VongTrong = Instance.new("Frame", VongNgoai)
		VongTrong.Name                   = "VongTrong"
		VongTrong.Size                   = UDim2.fromScale(0.3, 0.3)
		VongTrong.Position               = UDim2.fromScale(0.5, 0.5)
		VongTrong.AnchorPoint            = Vector2.new(0.5, 0.5)
		VongTrong.BackgroundColor3       = Color3.fromRGB(0, 210, 255)
		VongTrong.BackgroundTransparency = 0.25
		VongTrong.ZIndex                 = 11
		Instance.new("UICorner", VongTrong).CornerRadius = UDim.new(1, 0)

		local VienTrong = Instance.new("UIStroke", VongTrong)
		VienTrong.Color           = Color3.fromRGB(255, 255, 255)
		VienTrong.Thickness       = 1.2
		VienTrong.Transparency    = 0.10
		VienTrong.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local So = Instance.new("TextLabel", VongNgoai)
		So.Text                   = tostring(ThuTu)
		So.Size                   = UDim2.fromScale(1, 1)
		So.Position               = UDim2.new(0, 0, 0, -3)
		So.BackgroundTransparency = 1
		So.TextColor3             = Color3.fromRGB(255, 75, 0)
		So.Font                   = Enum.Font.Cartoon
		So.TextScaled             = true
		So.TextTransparency       = 0.15
		So.TextXAlignment         = Enum.TextXAlignment.Center
		So.TextYAlignment         = Enum.TextYAlignment.Center
		So.TextStrokeTransparency = 0.6
		So.TextStrokeColor3       = Color3.new(1, 1, 1)
		So.ZIndex                 = 12

		TaoKeoThaChoDiem(Cham, Diem, ThuTu)
		Cham.Parent = VungHienThiDiem
		table.insert(DanhSachUICham, Cham)
	end
end

function AutoClickLogic.CaiDatTocDo(MiliGiay)
	local so = tonumber(MiliGiay)
	if so and so > 0 then
		AutoClickLogic.TocDo = so
	end
end

function AutoClickLogic.BatTatAnToanBo(TrangThai)
	AutoClickLogic.AnTatCa = TrangThai
	AutoClickLogic.CapNhatDiem(AutoClickLogic.DanhSachDiem)
end

function AutoClickLogic.ResetTatCa()
	AutoClickLogic.BatTatAutoClick(false)
	table.clear(AutoClickLogic.DanhSachDiem)
	AutoClickLogic.CapNhatDiem(AutoClickLogic.DanhSachDiem)
end

local function HieuUngChopSang(ChamUI)
	if not ChamUI or not ChamUI.Parent then return end
	if AutoClickLogic.TocDo < 60 then return end
	local VongTrong = ChamUI:FindFirstChild("VongTrong")
	if not VongTrong then return end

	local tSang = DichVuTween:Create(VongTrong, TweenInfo.new(0.05), {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size             = UDim2.fromOffset(30, 30)
	})
	tSang:Play()
	tSang.Completed:Wait()
	if VongTrong.Parent then
		DichVuTween:Create(VongTrong, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(0, 210, 255),
			Size             = UDim2.fromOffset(26, 26)
		}):Play()
	end
end

function AutoClickLogic.BatTatAutoClick(TrangThai)
	AutoClickLogic.DangChay = TrangThai

	if LuongAutoClick then
		task.cancel(LuongAutoClick)
		LuongAutoClick = nil
	end

	if not TrangThai then return end

	LuongAutoClick = task.spawn(function()
		while AutoClickLogic.DangChay do

			if DichVuDauVao:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) 
               or DichVuDauVao:IsMouseButtonPressed(Enum.UserInputType.Touch) 
               or DiemDangKeo ~= nil then
				task.wait(0.1)
				continue
			end

			local danhSach = AutoClickLogic.DanhSachDiem

			if #danhSach == 0 then
				task.wait(0.1)
				continue
			end

			for ThuTu, Diem in ipairs(danhSach) do
				if not AutoClickLogic.DangChay then break end

				local ChamUI = DanhSachUICham[ThuTu]
                local X = math.floor(Diem.X)
                local Y = math.floor(Diem.Y)

				if ChamUI and ChamUI.Parent then
					ChamUI.Visible = false
				end

				pcall(function()
					DichVuAo:SendMouseButtonEvent(X, Y, 0, true, game, 1)
					task.wait(0.015)
					DichVuAo:SendMouseButtonEvent(X, Y, 0, false, game, 1)
				end)

                if ChamUI and ChamUI.Parent and not AutoClickLogic.AnTatCa and not Diem.DaAn then
                    ChamUI.Visible = true
                    task.spawn(HieuUngChopSang, ChamUI)
                end

                local delayNguoiDung = AutoClickLogic.TocDo / 1000
                local thoiGianCho = math.max(0.01, delayNguoiDung - 0.015)
				task.wait(thoiGianCho)
			end
		end
	end)
end

function AutoClickLogic.Destroy()
	AutoClickLogic.BatTatAutoClick(false)
	NgatKetNoiKeoTha()

	for _, ui in ipairs(DanhSachUICham) do
		if ui and ui.Parent then ui:Destroy() end
	end
	table.clear(DanhSachUICham)

	if VungHienThiDiem and VungHienThiDiem.Parent then
		VungHienThiDiem:Destroy()
		VungHienThiDiem = nil
	end

	table.clear(AutoClickLogic.DanhSachDiem)
end

return AutoClickLogic
