local DichVuTween = game:GetService("TweenService")
local DichVuRun = game:GetService("RunService")
local DichVuInput = game:GetService("UserInputService")
local TimKiem = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/TimKiem.lua"))()
local ChuDe = loadstring(game:HttpGet("https://raw.githubusercontent.com/9311-nex4/Hx/main/Utilities/ChuDe.lua"))()

local TweenNhanh = TweenInfo.new(0.08, Enum.EasingStyle.Sine)
local TweenMuot = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local TweenNay = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local TWEEN_BGDOWN = {BackgroundTransparency = 0.2}
local TWEEN_BGUP = {BackgroundTransparency = 0}

local ThuVienUI = {}
local ThanhPhan = {}

local ThemeData = ChuDe.DanhSach

local function ChayTween(DoiTuong, ThongTin, ThuocTinh)
	if not DoiTuong then return end
	DichVuTween:Create(DoiTuong, ThongTin, ThuocTinh):Play()
end

local function TaoDoiTuong(Loai, ThuocTinh, DoiTuongCon)
	local DoiTuong = Instance.new(Loai)
	local thuocTinhParent = ThuocTinh and ThuocTinh.Parent or nil
	if ThuocTinh then
		ThuocTinh.Parent = nil
		for Khoa, GiaTri in pairs(ThuocTinh) do DoiTuong[Khoa] = GiaTri end
	end
	if DoiTuongCon then
		for _, Con in ipairs(DoiTuongCon) do Con.Parent = DoiTuong end
	end
	if thuocTinhParent then DoiTuong.Parent = thuocTinhParent end
	return DoiTuong
end

local function TaoBoGoc(Cha, BanKinh) return TaoDoiTuong("UICorner", {CornerRadius = UDim.new(0, BanKinh), Parent = Cha}) end
local function TaoVien(Cha, Mau, DoTrongSuot, DoDay, TenVien)
	return TaoDoiTuong("UIStroke", {Name = TenVien or "Theme_Vien", Color = Mau, Transparency = DoTrongSuot or 0, Thickness = DoDay or 0.8, ApplyStrokeMode = "Border", Parent = Cha})
end
local function TaoGioiHanChu(Cha, KichThuocMax) return TaoDoiTuong("UITextSizeConstraint", {MaxTextSize = KichThuocMax or 14, Parent = Cha}) end

local function TaoNhan(ThuocTinh)
	ThuocTinh.Font = ThuocTinh.Font or Enum.Font.GothamMedium
	ThuocTinh.TextScaled = true
	ThuocTinh.BackgroundTransparency = 1
	return TaoDoiTuong("TextLabel", ThuocTinh)
end

local function TaoHieuUng(NutBam, MauThayDoi)
	local MauGocBanDau = NutBam.BackgroundColor3
	NutBam.MouseEnter:Connect(function()
		local base = NutBam:GetAttribute("MauGoc") or MauGocBanDau
		local hover = MauThayDoi or Color3.new(
			math.min(base.R + 0.12, 1),
			math.min(base.G + 0.12, 1),
			math.min(base.B + 0.12, 1)
		)
		ChayTween(NutBam, TweenMuot, {BackgroundColor3 = hover})
	end)
	NutBam.MouseLeave:Connect(function()
		ChayTween(NutBam, TweenMuot, {BackgroundColor3 = NutBam:GetAttribute("MauGoc") or MauGocBanDau})
	end)
	NutBam.MouseButton1Down:Connect(function() ChayTween(NutBam, TweenNhanh, TWEEN_BGDOWN) end)
	NutBam.MouseButton1Up:Connect(function() ChayTween(NutBam, TweenNhanh, TWEEN_BGUP) end)
end

local function TaoThemeSelector(KhungCha, CauHinhRef, ApDungThemeCB, Mau, NguCanh)
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = KhungCha})
	local HangNgang = TaoDoiTuong("Frame", {Name = "Theme_NenMuc", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Mau.NenMuc, ClipsDescendants = true, ZIndex = 2, Parent = KhungChinh})
	TaoBoGoc(HangNgang, 8)

	local NhanTieuDe = TaoNhan({Text = "UI Theme", Size = UDim2.new(0.5, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextColor3 = Mau.Chu, TextXAlignment = "Left", ZIndex = 3, Parent = HangNgang})
	TaoGioiHanChu(NhanTieuDe, 13)

	local HienThi = TaoDoiTuong("TextButton", {Name = "Theme_HopVuong", Size = UDim2.new(0.48, -10, 0, 28), Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.5, Text = "Dark", TextColor3 = Mau.Chu, Font = "GothamBold", TextScaled = true, ZIndex = 3, Parent = HangNgang})
	TaoBoGoc(HienThi, 6) TaoVien(HienThi, Mau.VienNeon, 0.8) TaoGioiHanChu(HienThi, 13) TaoHieuUng(HienThi, nil)

	local ThemeHienTai = "Dark"
	local DanhSachNutTheme = {}

	local function ChonTheme(TT)
		ThemeHienTai = TT.Ten 
		HienThi.Text = TT.Ten
		ApDungThemeCB(TT, false)
		if CauHinhRef.LuuTheme then CauHinhRef.LuuTheme({Ten = TT.Ten}) end

		for _, info in ipairs(DanhSachNutTheme) do
			local isChon = (info.Data and info.Data.Ten == ThemeHienTai)
			if info.Tich then info.Tich.Visible = isChon end
			ChayTween(info.Vien, TweenMuot, {Thickness = isChon and 2 or 1, Transparency = isChon and 0 or 0.85})
			ChayTween(info.Nut, TweenMuot, {BackgroundTransparency = isChon and 0.05 or 0.4})
		end
	end

	local HopXoDangMo, AnimDongXoXuong = false, nil

	HienThi.MouseButton1Click:Connect(function()
		if HopXoDangMo then if AnimDongXoXuong then AnimDongXoXuong() end return end
		if NguCanh and NguCanh.DongMenuAnim then NguCanh.DongMenuAnim() elseif NguCanh and NguCanh.DongMenu then NguCanh.DongMenu() end
		HopXoDangMo = true

		local KhungXo = TaoDoiTuong("Frame", {Name = "Theme_NenPhu", Size = UDim2.new(0, 304, 0, 0), Position = UDim2.fromOffset(HienThi.AbsolutePosition.X + HienThi.AbsoluteSize.X - 304, HienThi.AbsolutePosition.Y + HienThi.AbsoluteSize.Y + 6), BackgroundColor3 = Mau.NenPhu, ClipsDescendants = true, BorderSizePixel = 0, ZIndex = 105, Parent = NguCanh and NguCanh.LopPhu})
		TaoBoGoc(KhungXo, 8) local VienKhung = TaoVien(KhungXo, Mau.VienNeon, 0.6)
		if NguCanh and NguCanh.LopPhu and NguCanh.LopPhu.Parent then
			for _, v in ipairs(NguCanh.LopPhu.Parent:GetChildren()) do if v:IsA("TextButton") and v.ZIndex == 99 then v.Visible = true end end
		end
		local Cuon = TaoDoiTuong("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 4, AutomaticCanvasSize = "Y", CanvasSize = UDim2.new(), ZIndex = 106, Parent = KhungXo})
		TaoDoiTuong("UIPadding", {PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10), PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10), Parent = Cuon})

		local Grid = Instance.new("UIGridLayout")
		Grid.CellSize = UDim2.new(0, 65, 0, 60) Grid.CellPadding = UDim2.new(0, 8, 0, 8)
		Grid.SortOrder = "LayoutOrder" Grid.HorizontalAlignment = "Left" Grid.Parent = Cuon

		AnimDongXoXuong = function()
			if not HopXoDangMo then return end HopXoDangMo = false
			if NguCanh and NguCanh.DongMenuAnim == AnimDongXoXuong then NguCanh.DongMenuAnim = nil end
			if not KhungXo.Parent then return end
			ChayTween(VienKhung, TweenMuot, {Transparency = 1})
			for _, child in ipairs(Cuon:GetChildren()) do if child:IsA("TextButton") then ChayTween(child, TweenMuot, {BackgroundTransparency = 1}) end end
			local HieuUngDong = DichVuTween:Create(KhungXo, TweenMuot, {Size = UDim2.new(0, 304, 0, 0)}) HieuUngDong:Play()
			HieuUngDong.Completed:Connect(function() if KhungXo then KhungXo:Destroy() end end)
		end
		if NguCanh then NguCanh.DongMenuAnim = AnimDongXoXuong end

		KhungXo.AncestryChanged:Connect(function(_, parent)
			if not parent then
				HopXoDangMo = false
				if NguCanh and NguCanh.DongMenuAnim == AnimDongXoXuong then NguCanh.DongMenuAnim = nil end
			end
		end)

		for _, v in ipairs(Cuon:GetChildren()) do if not v:IsA("UIGridLayout") and not v:IsA("UIPadding") then v:Destroy() end end
		DanhSachNutTheme = {}
		local order = 1

		for _, TT in ipairs(ThemeData) do
			local NutTheme = TaoDoiTuong("TextButton", {LayoutOrder = order, BackgroundColor3 = Color3.fromRGB(28, 28, 28), BackgroundTransparency = 0.4, Text = "", ZIndex = 107, Parent = Cuon})
			TaoBoGoc(NutTheme, 8)

			local clr = TT.VienNeon
			local Vien = TaoVien(NutTheme, clr, 0.85, 1, "Theme_Vien_ThemeCard")
			local ChamMau = TaoDoiTuong("Frame", {Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0.5, 0, 0, 9), AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = clr, ZIndex = 108, Parent = NutTheme})
			TaoBoGoc(ChamMau, 10)
			local Strk = TaoDoiTuong("UIStroke", {Color = clr, Transparency = 0.35, Thickness = 3, Parent = ChamMau})

			TaoNhan({Text = TT.Ten, Size = UDim2.new(1,-4,0,14), Position = UDim2.new(0.5,0,1,-17), AnchorPoint = Vector2.new(0.5,0), TextColor3 = Color3.fromRGB(210,210,210), TextSize = 10, ZIndex = 108, Parent = NutTheme})
			local Tich = TaoNhan({Text = "✓", Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1,-2,0,2), AnchorPoint = Vector2.new(1,0), TextColor3 = clr, ZIndex = 109, Parent = NutTheme})

			local isChon = (ThemeHienTai == TT.Ten)
			Tich.Visible = isChon
			if isChon then Vien.Transparency = 0 Vien.Thickness = 2 NutTheme.BackgroundTransparency = 0.05 end

			table.insert(DanhSachNutTheme, {Nut = NutTheme, Vien = Vien, Tich = Tich, ChamMau = ChamMau, Data = TT})
			NutTheme.MouseButton1Click:Connect(function() ChonTheme(TT) end)
			order = order + 1
		end

		ChayTween(VienKhung, TweenMuot, {Transparency = 0.5})
		ChayTween(KhungXo, TweenMuot, {Size = UDim2.new(0, 304, 0, 216)})

		local ToaDoYBanDau = HienThi.AbsolutePosition.Y
		local CapNhatViTri = nil
		CapNhatViTri = DichVuRun.RenderStepped:Connect(function()
			if not HienThi.Parent or not HienThi.Visible or not KhungXo.Parent then
				if CapNhatViTri then CapNhatViTri:Disconnect() CapNhatViTri = nil end return
			end
			if math.abs(HienThi.AbsolutePosition.Y - ToaDoYBanDau) > 2 then AnimDongXoXuong() return end
			KhungXo.Position = UDim2.fromOffset(HienThi.AbsolutePosition.X + HienThi.AbsoluteSize.X - 304, HienThi.AbsolutePosition.Y + HienThi.AbsoluteSize.Y + 6)
		end)
	end)

	task.defer(function()
		local luu = CauHinhRef.ChuDeDaLuu or {Ten = "Dark"}
		ThemeHienTai = luu.Ten 
		HienThi.Text = luu.Ten
	end)
end

function ThanhPhan.Otich(Cha, DuLieu, CauHinh, CapNhat, DeQuy)
	local Mau = CauHinh.Mau
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})})
	local HangNgang = TaoDoiTuong("Frame", {LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, ZIndex = 2, Parent = KhungChinh})
	if DuLieu.LoaiNutCon == "CungHang" then TaoDoiTuong("UIListLayout", {FillDirection = "Horizontal", SortOrder = "LayoutOrder", Padding = UDim.new(0, 4), Parent = HangNgang}) end

	local NutTich = TaoDoiTuong("TextButton", {Name = "Theme_NenMuc", LayoutOrder = 1, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc, Text = "", AutoButtonColor = false, ZIndex = 2, Parent = HangNgang})
	NutTich:SetAttribute("MauGoc", DuLieu.MauNenRieng or Mau.NenMuc)
	TaoBoGoc(NutTich, 8)

	local NhanTich = TaoNhan({Text = "  " .. DuLieu.Ten, Size = UDim2.new(0.72, -5, 1, 0), TextColor3 = Mau.Chu, TextXAlignment = "Left", TextWrapped = true, ZIndex = 3, Parent = NutTich})
	TaoGioiHanChu(NhanTich, CauHinh.VanBan.Nho)

	local HopVuong = TaoDoiTuong("Frame", {Name = "Theme_HopVuong", Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Mau.NenHop, ZIndex = 3, Parent = NutTich})
	TaoBoGoc(HopVuong, 6) TaoVien(HopVuong, Mau.VienNeon, 0.5, 1.2)

	DuLieu.TrangThai = (DuLieu.HienTai == "Bat") or DuLieu.TrangThai or false
	local DauTich = TaoDoiTuong("Frame", {Name = "Theme_TichBat", Size = UDim2.new(1, -8, 1, -8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Mau.TichBat, Visible = DuLieu.TrangThai, ZIndex = 4, Parent = HopVuong})
	TaoBoGoc(DauTich, 4)

	local NutPhu, CapNhatNutPhu, ChiSoPhu = nil, nil, 1
	local KhungChuaPhu = TaoDoiTuong("Frame", {LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = KhungChinh})
	local Dem = TaoDoiTuong("UIPadding", {Parent = KhungChuaPhu})
	TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = "LayoutOrder", Parent = KhungChuaPhu})

	if DuLieu.LoaiNutCon == "CungHang" then
		NutPhu = TaoDoiTuong("TextButton", {Name = "Theme_NenMuc", LayoutOrder = 2, Size = UDim2.new(0.3, 0, 1, 0), BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc, Text = "...", TextColor3 = Mau.Chu, Font = "GothamMedium", TextScaled = true, Visible = false, ZIndex = 2, Parent = HangNgang})
		NutPhu:SetAttribute("MauGoc", DuLieu.MauNenRieng or Mau.NenMuc)
		TaoBoGoc(NutPhu, 8) TaoVien(NutPhu, Mau.VienNeon, 0.7) TaoGioiHanChu(NutPhu, CauHinh.VanBan.Nho) TaoHieuUng(NutPhu, nil)
		CapNhatNutPhu = function() NutPhu.Text = (DuLieu.CacNutCon and DuLieu.CacNutCon[ChiSoPhu]) and DuLieu.CacNutCon[ChiSoPhu].Ten or "Trong" end
		if DuLieu.CacNutCon then CapNhatNutPhu() end
		NutPhu.MouseButton1Click:Connect(function()
			if DuLieu.CacNutCon and DuLieu.CacNutCon[ChiSoPhu] then
				if type(DuLieu.CacNutCon[ChiSoPhu].SuKien) == "function" then task.spawn(DuLieu.CacNutCon[ChiSoPhu].SuKien) end
				if #DuLieu.CacNutCon > 1 then ChiSoPhu = (ChiSoPhu % #DuLieu.CacNutCon) + 1 CapNhatNutPhu() end
			end
		end)
	end

	local function LamMoi()
		if DuLieu.LoaiNutCon == "CungHang" then
			if DuLieu.TrangThai then
				ChayTween(NutTich, TweenMuot, {Size = UDim2.new(0.68, -4, 1, 0)}) NutPhu.Visible = true ChayTween(NutPhu, TweenMuot, {BackgroundTransparency = 0})
			else
				ChayTween(NutTich, TweenMuot, {Size = UDim2.new(1, 0, 1, 0)}) NutPhu.Visible = false
			end return
		end
		for _, PhanTu in ipairs(KhungChuaPhu:GetChildren()) do if PhanTu:IsA("GuiObject") then PhanTu:Destroy() end end
		if DuLieu.TrangThai and DuLieu.CacNutCon and #DuLieu.CacNutCon > 0 then
			Dem.PaddingTop = UDim.new(0, 6) Dem.PaddingBottom = UDim.new(0, 6)
			for ThuTuNho, DuLieuNho in ipairs(DuLieu.CacNutCon) do DuLieuNho.MauNenRieng = Mau.NenMuc DeQuy(KhungChuaPhu, DuLieuNho, CapNhat, ThuTuNho) end
		else Dem.PaddingTop = UDim.new(0, 0) Dem.PaddingBottom = UDim.new(0, 0) end
		task.delay(0.05, CapNhat)
	end

	DuLieu.SetTrangThai = function(TrangThaiMoi)
		if DuLieu.TrangThai == TrangThaiMoi then return end
		DuLieu.TrangThai = TrangThaiMoi
		DuLieu.HienTai = TrangThaiMoi and "Bat" or "Tat"
		DauTich.Visible = TrangThaiMoi
		if TrangThaiMoi then DauTich.Size = UDim2.fromScale(0, 0) ChayTween(DauTich, TweenNay, {Size = UDim2.new(1, -8, 1, -8)}) end
		LamMoi()
	end

	if DuLieu.TrangThai then LamMoi() end
	TaoHieuUng(NutTich, nil)
	NutTich.MouseButton1Click:Connect(function() DuLieu.SetTrangThai(not DuLieu.TrangThai) if type(DuLieu.SuKien) == "function" then task.spawn(DuLieu.SuKien, DuLieu.TrangThai) end end)

	if DuLieu.TrangThai and type(DuLieu.SuKien) == "function" then
		task.defer(function() DuLieu.SuKien(true) end)
	end
end

function ThanhPhan.Gat(Cha, DuLieu, CauHinh, CapNhat, DeQuy)
	local Mau = CauHinh.Mau
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})})
	local HangNgang = TaoDoiTuong("Frame", {LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, ZIndex = 2, Parent = KhungChinh})
	local NutBam = TaoDoiTuong("TextButton", {Name = "Theme_NenMuc", LayoutOrder = 1, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc, Text = "", AutoButtonColor = false, ClipsDescendants = true, ZIndex = 2, Parent = HangNgang})
	NutBam:SetAttribute("MauGoc", DuLieu.MauNenRieng or Mau.NenMuc)
	TaoBoGoc(NutBam, 8)

	local DoDaiChuoi = utf8.len(DuLieu.Ten) or string.len(DuLieu.Ten)
	if DoDaiChuoi > 10 then
		local VungCuonChu = TaoDoiTuong("ScrollingFrame", {Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X, AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(0,0,0,0), ClipsDescendants = true, ZIndex = 3, Parent = NutBam})
		local NhanTieuDe = TaoNhan({Text = DuLieu.Ten, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, TextColor3 = Mau.Chu, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = VungCuonChu})
		NhanTieuDe.TextScaled = false NhanTieuDe.TextWrapped = false NhanTieuDe.TextSize = CauHinh.VanBan.Nho
	else
		local NhanTieuDe = TaoNhan({Text = DuLieu.Ten, Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextColor3 = Mau.Chu, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 3, Parent = NutBam})
		TaoGioiHanChu(NhanTieuDe, CauHinh.VanBan.Nho)
	end

	local KhungGat = TaoDoiTuong("Frame", {Name = "Theme_KhungGat", Size = UDim2.fromOffset(36, 18), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Mau.NenHop, ZIndex = 3, Parent = NutBam})
	TaoBoGoc(KhungGat, 10)
	TaoVien(KhungGat, Mau.VienNeon, 0.55, 1, "Theme_Vien")

	DuLieu.TrangThai = (DuLieu.HienTai == "Bat") or DuLieu.TrangThai or false
	local CucGat = TaoDoiTuong("Frame", {Name = "Theme_CucGat", Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0, 2, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Mau.ChuMo, ZIndex = 4, Parent = KhungGat})
	TaoBoGoc(CucGat, 10)
	CucGat:SetAttribute("IsOn", DuLieu.TrangThai)

	local NutPhu, CapNhatNutPhu, ChiSoPhu = nil, nil, 1
	local KhungChuaPhu = TaoDoiTuong("Frame", {LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = KhungChinh})
	local Dem = TaoDoiTuong("UIPadding", {Parent = KhungChuaPhu})
	TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = "LayoutOrder", Parent = KhungChuaPhu})

	if DuLieu.LoaiNutCon == "CungHang" then
		TaoDoiTuong("UIListLayout", {FillDirection = "Horizontal", SortOrder = "LayoutOrder", Padding = UDim.new(0, 4), Parent = HangNgang})
		NutPhu = TaoDoiTuong("TextButton", {Name = "Theme_NenMuc", LayoutOrder = 2, Size = UDim2.new(0.3, 0, 1, 0), BackgroundColor3 = Mau.NenHop, Text = "...", TextColor3 = Mau.Chu, Font = "GothamMedium", TextScaled = true, Visible = false, ZIndex = 2, Parent = HangNgang})
		NutPhu:SetAttribute("MauGoc", Mau.NenHop)
		TaoBoGoc(NutPhu, 8) TaoGioiHanChu(NutPhu, CauHinh.VanBan.Nho) TaoHieuUng(NutPhu, nil)
		CapNhatNutPhu = function() NutPhu.Text = (DuLieu.CacNutCon and DuLieu.CacNutCon[ChiSoPhu]) and DuLieu.CacNutCon[ChiSoPhu].Ten or "Trong" end
		if DuLieu.CacNutCon then CapNhatNutPhu() end
		NutPhu.MouseButton1Click:Connect(function()
			if DuLieu.CacNutCon and DuLieu.CacNutCon[ChiSoPhu] then
				if type(DuLieu.CacNutCon[ChiSoPhu].SuKien) == "function" then task.spawn(DuLieu.CacNutCon[ChiSoPhu].SuKien) end
				if #DuLieu.CacNutCon > 1 then ChiSoPhu = (ChiSoPhu % #DuLieu.CacNutCon) + 1 CapNhatNutPhu() end
			end
		end)
	end

	local function LamMoi()
		if DuLieu.LoaiNutCon == "CungHang" then
			if DuLieu.TrangThai then
				ChayTween(NutBam, TweenMuot, {Size = UDim2.new(0.68, -4, 1, 0)})
				NutPhu.Visible = true ChayTween(NutPhu, TweenMuot, {BackgroundTransparency = 0})
			else
				ChayTween(NutBam, TweenMuot, {Size = UDim2.new(1, 0, 1, 0)}) NutPhu.Visible = false
			end return
		end
		for _, PhanTu in ipairs(KhungChuaPhu:GetChildren()) do if PhanTu:IsA("GuiObject") then PhanTu:Destroy() end end
		if DuLieu.TrangThai and DuLieu.CacNutCon and #DuLieu.CacNutCon > 0 then
			Dem.PaddingTop = UDim.new(0, 10) Dem.PaddingBottom = UDim.new(0, 10)
			for ThuTuNho, DuLieuNho in ipairs(DuLieu.CacNutCon) do DuLieuNho.MauNenRieng = Mau.NenMuc DeQuy(KhungChuaPhu, DuLieuNho, CapNhat, ThuTuNho) end
		else
			Dem.PaddingTop = UDim.new(0, 0) Dem.PaddingBottom = UDim.new(0, 0)
		end
		task.delay(0.05, CapNhat)
	end

	DuLieu.SetTrangThai = function(TrangThaiMoi)
		if DuLieu.TrangThai == TrangThaiMoi then return end
		DuLieu.TrangThai = TrangThaiMoi
		DuLieu.HienTai = TrangThaiMoi and "Bat" or "Tat"
		CucGat:SetAttribute("IsOn", TrangThaiMoi)
		if TrangThaiMoi then
			ChayTween(CucGat, TweenNay, {Position = UDim2.new(1, -16, 0.5, 0), BackgroundColor3 = Mau.TichBat})
			ChayTween(KhungGat, TweenNay, {BackgroundColor3 = Mau.ChonPhu})
		else
			ChayTween(CucGat, TweenNay, {Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Mau.ChuMo})
			ChayTween(KhungGat, TweenNay, {BackgroundColor3 = Mau.NenHop})
		end
		LamMoi()
	end

	if DuLieu.TrangThai then
		LamMoi()
		ChayTween(CucGat, TweenNhanh, {Position = UDim2.new(1, -16, 0.5, 0), BackgroundColor3 = Mau.TichBat})
		ChayTween(KhungGat, TweenNhanh, {BackgroundColor3 = Mau.ChonPhu})
	end
	TaoHieuUng(NutBam, nil)

	NutBam.MouseButton1Click:Connect(function()
		DuLieu.SetTrangThai(not DuLieu.TrangThai)
		if type(DuLieu.SuKien) == "function" then task.spawn(DuLieu.SuKien, DuLieu.TrangThai) end
	end)
end

function ThanhPhan.Nut(Cha, DuLieu, CauHinh, CapNhat, DeQuy)
	local Mau = CauHinh.Mau
	local NutBam = TaoDoiTuong("TextButton", {Name = "Theme_NenMuc", LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc, Text = DuLieu.Ten, TextColor3 = Mau.Chu, Font = "GothamMedium", TextScaled = true, ZIndex = 2, Parent = Cha})
	NutBam:SetAttribute("MauGoc", DuLieu.MauNenRieng or Mau.NenMuc)
	TaoBoGoc(NutBam, 8) TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = NutBam}) TaoGioiHanChu(NutBam, CauHinh.VanBan.Nut) TaoHieuUng(NutBam, nil)

	local DuLieuHienTai, ChiSoVongLap = DuLieu, 0
	NutBam.MouseButton1Click:Connect(function()
		if type(DuLieuHienTai.SuKien) == "function" then task.spawn(DuLieuHienTai.SuKien) end
		if DuLieuHienTai.SauBam == "Thay" and DuLieuHienTai.DanhSachThay then
			local DuLieuMoi
			if type(DuLieuHienTai.DanhSachThay) == "table" and DuLieuHienTai.DanhSachThay[1] then
				ChiSoVongLap = ChiSoVongLap + 1
				local DanhSach = DuLieuHienTai.DanhSachThay
				local CoVongLap = true
				for _, PhanTuThay in ipairs(DanhSach) do if PhanTuThay.Loai and PhanTuThay.Loai ~= "Nut" then CoVongLap = false break end end
				ChiSoVongLap = CoVongLap and ((ChiSoVongLap - 1) % #DanhSach) + 1 or ChiSoVongLap
				DuLieuMoi = DanhSach[ChiSoVongLap]
			else
				DuLieuMoi = DuLieuHienTai.DanhSachThay
			end
			if DuLieuMoi then
				if (DuLieuMoi.Loai or "Nut") == "Nut" then
					NutBam.Text = DuLieuMoi.Ten or NutBam.Text
					if DuLieuMoi.Mau then ChayTween(NutBam, TweenMuot, {BackgroundColor3 = DuLieuMoi.Mau}) NutBam:SetAttribute("MauGoc", DuLieuMoi.Mau) end
					local DanhSachCu = DuLieuHienTai.DanhSachThay
					DuLieuHienTai = DuLieuMoi
					if ChiSoVongLap > 0 then DuLieuHienTai.DanhSachThay = DanhSachCu DuLieuHienTai.SauBam = "Thay" end
				else
					NutBam:Destroy() DeQuy(Cha, DuLieuMoi, CapNhat, DuLieu.ThuTu) CapNhat()
				end
			end
		end
	end)
end

function ThanhPhan.NhieuNut(Cha, DuLieu, CauHinh, CapNhat)
	local Mau = CauHinh.Mau
	local KhungChua = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = Cha}, {TaoDoiTuong("UIListLayout", {FillDirection = "Horizontal", SortOrder = "LayoutOrder", Padding = UDim.new(0, 10)})})
	local function TaoNutNho(TenNut, SuKienNut, ThuTuNut, TongSoNut)
		local DoRong = 1 / (TongSoNut or 1)
		local NutBam = TaoDoiTuong("TextButton", {Name = "Theme_NenMuc", LayoutOrder = ThuTuNut, Size = UDim2.new(DoRong, -((10 * (TongSoNut - 1)) / TongSoNut), 1, 0), BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc, Text = TenNut or "Nut", TextColor3 = Mau.Chu, Font = "GothamMedium", TextScaled = true, ZIndex = 2, Parent = KhungChua})
		NutBam:SetAttribute("MauGoc", DuLieu.MauNenRieng or Mau.NenMuc)
		TaoBoGoc(NutBam, 8) TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = NutBam}) TaoGioiHanChu(NutBam, CauHinh.VanBan.Nho) TaoHieuUng(NutBam, nil)
		NutBam.MouseButton1Click:Connect(function() if type(SuKienNut) == "function" then task.spawn(SuKienNut) end end)
	end
	DuLieu.LamMoi = function()
		for _, v in ipairs(KhungChua:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		if DuLieu.DanhSachNut then
			for ViTriNut, DuLieuNho in ipairs(DuLieu.DanhSachNut) do TaoNutNho(DuLieuNho.Ten, DuLieuNho.SuKien, ViTriNut, #DuLieu.DanhSachNut) end
		else
			local DanhSachThayThe = {}
			if DuLieu.Ten1 then table.insert(DanhSachThayThe, {DuLieu.Ten1, DuLieu.SuKien1}) end
			if DuLieu.Ten2 then table.insert(DanhSachThayThe, {DuLieu.Ten2, DuLieu.SuKien2}) end
			for ViTriThayThe, DuLieuThayThe in ipairs(DanhSachThayThe) do TaoNutNho(DuLieuThayThe[1], DuLieuThayThe[2], ViTriThayThe, #DanhSachThayThe) end
		end
	end
	DuLieu.LamMoi()
end

function ThanhPhan.HopXo(Cha, DuLieu, CauHinh, CapNhat, DeQuy, NguCanh)
	local Mau = CauHinh.Mau
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})})
	local HangNgang = TaoDoiTuong("Frame", {Name = "Theme_NenMuc", LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc, ClipsDescendants = true, ZIndex = 2, Parent = KhungChinh})
	TaoBoGoc(HangNgang, 8)

	local NhanTieuDe = TaoNhan({Text = "  " .. DuLieu.Ten, Size = UDim2.new(0.5, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextColor3 = Mau.Chu, TextXAlignment = "Left", ZIndex = 3, Parent = HangNgang})
	TaoGioiHanChu(NhanTieuDe, CauHinh.VanBan.Nho)

	local HienThi = TaoDoiTuong("TextButton", {Name = "Theme_HopVuong", Size = UDim2.new(0.48, -10, 0, 28), Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.5, Text = DuLieu.HienTai or "...", TextColor3 = Mau.Chu, Font = "Gotham", TextScaled = true, ZIndex = 3, Parent = HangNgang})
	TaoBoGoc(HienThi, 6) TaoVien(HienThi, Mau.VienNeon, 0.8) TaoGioiHanChu(HienThi, CauHinh.VanBan.Nho) TaoHieuUng(HienThi, nil)

	local KhungPhu = TaoDoiTuong("Frame", {LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = KhungChinh})
	local Dem = TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0,6), Parent = KhungPhu})
	TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = "LayoutOrder", Parent = KhungPhu})

	local function LamMoiKhungPhu(CacMuc)
		for _, PhanTuCu in ipairs(KhungPhu:GetChildren()) do if PhanTuCu:IsA("GuiObject") then PhanTuCu:Destroy() end end
		if CacMuc and #CacMuc > 0 then
			Dem.PaddingTop = UDim.new(0, 10) Dem.PaddingBottom = UDim.new(0, 10)
			for ViTriMuc, GiaTriMuc in ipairs(CacMuc) do DeQuy(KhungPhu, GiaTriMuc, CapNhat, ViTriMuc) end
		else
			Dem.PaddingTop = UDim.new(0, 0) Dem.PaddingBottom = UDim.new(0, 0)
		end
		CapNhat()
	end

	for _, LuaChon in ipairs(DuLieu.LuaChon) do
		if type(LuaChon) == "table" and LuaChon.Ten == DuLieu.HienTai then LamMoiKhungPhu(LuaChon.CacNutCon) end
	end

	local HopXoDangMo, AnimDongXoXuong = false, nil
	HienThi.MouseButton1Click:Connect(function()
		if HopXoDangMo then if AnimDongXoXuong then AnimDongXoXuong() end return end
		if NguCanh and NguCanh.DongMenuAnim then NguCanh.DongMenuAnim() elseif NguCanh and NguCanh.DongMenu then NguCanh.DongMenu() end
		HopXoDangMo = true
		local KhungXo = TaoDoiTuong("Frame", {Name = "Theme_NenPhu", Size = UDim2.new(0, HienThi.AbsoluteSize.X, 0, 0), Position = UDim2.fromOffset(HienThi.AbsolutePosition.X, HienThi.AbsolutePosition.Y + HienThi.AbsoluteSize.Y + 6), BackgroundColor3 = Mau.NenPhu, ClipsDescendants = true, BorderSizePixel = 0, ZIndex = 105, Parent = NguCanh and NguCanh.LopPhu})
		TaoBoGoc(KhungXo, 8) local VienKhung = TaoVien(KhungXo, Mau.VienNeon, 0.6)
		if NguCanh and NguCanh.LopPhu and NguCanh.LopPhu.Parent then
			for _, v in ipairs(NguCanh.LopPhu.Parent:GetChildren()) do if v:IsA("TextButton") and v.ZIndex == 99 then v.Visible = true end end
		end
		local Cuon = TaoDoiTuong("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 4, BorderSizePixel = 0, ScrollBarImageColor3 = Mau.Chu, AutomaticCanvasSize = "Y", CanvasSize = UDim2.new(), ZIndex = 106, Parent = KhungXo})
		TaoDoiTuong("UIPadding", {PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4), PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4), Parent = Cuon})
		TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder", Padding = UDim.new(0, 3), Parent = Cuon})
		local CapNhatViTri = nil
		AnimDongXoXuong = function()
			if not HopXoDangMo then return end
			HopXoDangMo = false
			if NguCanh and NguCanh.DongMenuAnim == AnimDongXoXuong then NguCanh.DongMenuAnim = nil end
			if CapNhatViTri then CapNhatViTri:Disconnect() CapNhatViTri = nil end
			if not KhungXo.Parent then return end
			ChayTween(VienKhung, TweenMuot, {Transparency = 1})
			for _, child in ipairs(Cuon:GetChildren()) do if child:IsA("TextButton") then ChayTween(child, TweenMuot, {TextTransparency = 1, BackgroundTransparency = 1}) end end
			local HieuUngDong = DichVuTween:Create(KhungXo, TweenMuot, {Size = UDim2.new(0, HienThi.AbsoluteSize.X, 0, 0)})
			HieuUngDong:Play()
			HieuUngDong.Completed:Connect(function()
				if KhungXo then KhungXo:Destroy() end
				if NguCanh and not NguCanh.DongMenuAnim and NguCanh.LopPhu and NguCanh.LopPhu.Parent then
					for _, v in ipairs(NguCanh.LopPhu.Parent:GetChildren()) do if v:IsA("TextButton") and v.ZIndex == 99 then v.Visible = false end end
				end
			end)
		end
		if NguCanh then NguCanh.DongMenuAnim = AnimDongXoXuong end
		KhungXo.AncestryChanged:Connect(function(_, parent)
			if not parent then
				HopXoDangMo = false
				if CapNhatViTri then CapNhatViTri:Disconnect() CapNhatViTri = nil end
				if NguCanh and NguCanh.DongMenuAnim == AnimDongXoXuong then NguCanh.DongMenuAnim = nil end
			end
		end)
		local ToaDoYBanDau = HienThi.AbsolutePosition.Y
		CapNhatViTri = DichVuRun.RenderStepped:Connect(function()
			if not HienThi.Parent or not HienThi.Visible or not KhungXo.Parent then
				if CapNhatViTri then CapNhatViTri:Disconnect() CapNhatViTri = nil end return
			end
			if math.abs(HienThi.AbsolutePosition.Y - ToaDoYBanDau) > 2 then AnimDongXoXuong() return end
			KhungXo.Position = UDim2.fromOffset(HienThi.AbsolutePosition.X, HienThi.AbsolutePosition.Y + HienThi.AbsoluteSize.Y + 6)
		end)
		for ViTriLuaChon, DuLieuLuaChon in ipairs(DuLieu.LuaChon) do
			local TenLuaChon = (type(DuLieuLuaChon) == "table") and DuLieuLuaChon.Ten or DuLieuLuaChon
			local DuocChon = (TenLuaChon == DuLieu.HienTai)
			local bgLuaChon = DuocChon and Mau.ChonPhu or Mau.NenPhu
			local MucLuaChon = TaoDoiTuong("TextButton", {Name = DuocChon and "Theme_ChonPhu" or "Theme_NenPhu", LayoutOrder = ViTriLuaChon, Size = UDim2.new(1, -2, 0, 30), BackgroundColor3 = bgLuaChon, BackgroundTransparency = DuocChon and 0.5 or 1, Text = "  " .. TenLuaChon, TextColor3 = DuocChon and Mau.TichBat or Mau.Chu, Font = DuocChon and "GothamBold" or "Gotham", TextScaled = true, TextXAlignment = "Left", ZIndex = 107, AutoButtonColor = false, Parent = Cuon})
			TaoBoGoc(MucLuaChon, 6) TaoGioiHanChu(MucLuaChon, CauHinh.VanBan.Nho)
			local propsHover, propsLeave = {BackgroundTransparency = 0.4, BackgroundColor3 = Mau.ChonPhu}, {BackgroundTransparency = 1}
			MucLuaChon.MouseEnter:Connect(function() if not DuocChon then ChayTween(MucLuaChon, TweenNhanh, propsHover) end end)
			MucLuaChon.MouseLeave:Connect(function() if not DuocChon then ChayTween(MucLuaChon, TweenNhanh, propsLeave) end end)
			MucLuaChon.MouseButton1Click:Connect(function()
				DuLieu.HienTai = TenLuaChon HienThi.Text = TenLuaChon
				LamMoiKhungPhu((type(DuLieuLuaChon) == "table") and DuLieuLuaChon.CacNutCon or nil)
				if type(DuLieu.SuKien) == "function" then task.spawn(DuLieu.SuKien, TenLuaChon) end
			end)
		end
		ChayTween(VienKhung, TweenMuot, {Transparency = 0.5})
		ChayTween(KhungXo, TweenMuot, {Size = UDim2.new(0, HienThi.AbsoluteSize.X, 0, math.min(#DuLieu.LuaChon * 33 + 8, 110))})
	end)
end

function ThanhPhan.Danhsach(Cha, DuLieu, CauHinh, CapNhat, DeQuy, NguCanh)
	local Mau = CauHinh.Mau
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})})
	local DauMuc = TaoDoiTuong("TextButton", {Name = DuLieu.DangMo and "Theme_NenDanhSachMo" or "Theme_NenMuc", LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = DuLieu.DangMo and Mau.NenDanhSachMo or Mau.NenMuc, Text = "", ZIndex = 2, Parent = KhungChinh})
	TaoBoGoc(DauMuc, 8)

	local NhanTieuDe = TaoNhan({Text = "  " .. DuLieu.Ten, Size = UDim2.new(0.8, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextColor3 = Mau.Chu, TextXAlignment = "Left", ZIndex = 3, Parent = DauMuc})
	TaoGioiHanChu(NhanTieuDe, CauHinh.VanBan.Nho)

	local MuiTen = TaoDoiTuong("ImageLabel", {Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Image = CauHinh.Asset.MuiTenXuong or "rbxassetid://6031091004", Rotation = DuLieu.DangMo and 180 or 0, BackgroundTransparency = 1, ZIndex = 3, Parent = DauMuc})

	local KhungChua = TaoDoiTuong("Frame", {Name = "Theme_HopVuong", LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.4, ClipsDescendants = true, Parent = KhungChinh})
	TaoBoGoc(KhungChua, 6) TaoVien(KhungChua, Mau.VienNeon, 0.9)
	TaoDoiTuong("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = KhungChua})

	local BoCuc = TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = "LayoutOrder", Parent = KhungChua})
	BoCuc:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if DuLieu.DangMo then KhungChua.Size = UDim2.new(1, 0, 0, BoCuc.AbsoluteContentSize.Y + 16) CapNhat() end
	end)

	DuLieu.LamMoi = function()
		for _, v in ipairs(KhungChua:GetChildren()) do if v:IsA("GuiObject") then v:Destroy() end end
		if DuLieu.Danhsach then
			local TongSo = #DuLieu.Danhsach
			for ViTriDanhSach, DuLieuDanhSach in ipairs(DuLieu.Danhsach) do
				DuLieuDanhSach.MauNenRieng = Mau.NenMuc
				DeQuy(KhungChua, DuLieuDanhSach, function() CapNhat() end, ViTriDanhSach * 2)
				if ViTriDanhSach < TongSo then
					local KhungBocLine = TaoDoiTuong("Frame", {LayoutOrder = ViTriDanhSach * 2 + 1, Size = UDim2.new(1, 0, 0, 1), BackgroundTransparency = 1, Parent = KhungChua})
					TaoDoiTuong("Frame", {Name = "Theme_Vien", Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, -3), BackgroundColor3 = Mau.VienNeon, BackgroundTransparency = 0.6, BorderSizePixel = 0, Parent = KhungBocLine})
				end
			end
		end
		if DuLieu.DangMo then KhungChua.Size = UDim2.new(1, 0, 0, BoCuc.AbsoluteContentSize.Y + 16) end
		task.delay(0.05, CapNhat)
	end
	DuLieu.LamMoi()

	DauMuc.MouseButton1Click:Connect(function()
		if NguCanh and NguCanh.DongMenuAnim then NguCanh.DongMenuAnim() end
		DuLieu.DangMo = not DuLieu.DangMo
		DauMuc.Name = DuLieu.DangMo and "Theme_NenDanhSachMo" or "Theme_NenMuc"
		ChayTween(KhungChua, TweenMuot, {Size = UDim2.new(1, 0, 0, DuLieu.DangMo and (BoCuc.AbsoluteContentSize.Y + 16) or 0)})
		ChayTween(MuiTen, TweenMuot, {Rotation = DuLieu.DangMo and 180 or 0})
		ChayTween(DauMuc, TweenMuot, {BackgroundColor3 = DuLieu.DangMo and Mau.NenDanhSachMo or Mau.NenMuc})
		task.delay(0.26, CapNhat)
	end)
end

function ThanhPhan.Odien(Cha, DuLieu, CauHinh, CapNhat, DeQuy)
	local Mau = CauHinh.Mau
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})})
	local HangNgang = TaoDoiTuong("Frame", {Name = "Theme_NenMuc", LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc, ZIndex = 2, Parent = KhungChinh})
	TaoBoGoc(HangNgang, 8)

	local NhanTieuDe = TaoNhan({Text = "  " .. DuLieu.Ten, Size = UDim2.new(0.6, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextColor3 = Mau.Chu, TextXAlignment = "Left", ZIndex = 3, Parent = HangNgang})
	TaoGioiHanChu(NhanTieuDe, CauHinh.VanBan.Nho)

	local ONhap = TaoDoiTuong("TextBox", {Name = "Theme_HopVuong", Size = UDim2.new(0.35, -10, 0, 28), Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.5, Text = tostring(DuLieu.HienTai or ""), PlaceholderText = DuLieu.GoiY or "", TextColor3 = Mau.Chu, Font = "Gotham", TextScaled = true, ZIndex = 3, Parent = HangNgang})
	TaoBoGoc(ONhap, 6) TaoVien(ONhap, Mau.VienNeon, 0.7) TaoGioiHanChu(ONhap, CauHinh.VanBan.Nho)

	ONhap.FocusLost:Connect(function()
		DuLieu.HienTai = ONhap.Text
		if type(DuLieu.SuKien) == "function" then task.spawn(DuLieu.SuKien, ONhap.Text) end
	end)
end

function ThanhPhan.PhimNong(Cha, DuLieu, CauHinh, CapNhat, DeQuy)
	local Mau = CauHinh.Mau
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})})
	local HangNgang = TaoDoiTuong("Frame", {Name = "Theme_NenMuc", LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc, ZIndex = 2, Parent = KhungChinh})
	TaoBoGoc(HangNgang, 8)

	local NhanTieuDe = TaoNhan({Text = "  " .. DuLieu.Ten, Size = UDim2.new(0.6, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextColor3 = Mau.Chu, TextXAlignment = "Left", ZIndex = 3, Parent = HangNgang})
	TaoGioiHanChu(NhanTieuDe, CauHinh.VanBan.Nho)

	local NutPhim = TaoDoiTuong("TextButton", {Name = "Theme_HopVuong", Size = UDim2.new(0.35, -10, 0, 28), Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.5, Text = tostring(DuLieu.HienTai or "None"), TextColor3 = Mau.Chu, Font = "GothamBold", TextScaled = true, ZIndex = 3, Parent = HangNgang})
	TaoBoGoc(NutPhim, 6) TaoVien(NutPhim, Mau.VienNeon, 0.7) TaoGioiHanChu(NutPhim, CauHinh.VanBan.Nho) TaoHieuUng(NutPhim, nil)

	local DangCho = false
	NutPhim.MouseButton1Click:Connect(function()
		if not DichVuInput.KeyboardEnabled or DangCho then return end
		DangCho = true shared.HxDangChinhPhim = true NutPhim.Text = "..."
		if DuLieu.KetNoiInput then DuLieu.KetNoiInput:Disconnect() DuLieu.KetNoiInput = nil end
		DuLieu.KetNoiInput = DichVuInput.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				if DuLieu.KetNoiInput then DuLieu.KetNoiInput:Disconnect() DuLieu.KetNoiInput = nil end
				local TenPhim = Input.KeyCode.Name DuLieu.HienTai = TenPhim NutPhim.Text = TenPhim
				if type(DuLieu.SuKien) == "function" then task.spawn(DuLieu.SuKien, Input.KeyCode) end
				task.wait(0.1) shared.HxDangChinhPhim = false DangCho = false
			end
		end)
	end)
end

function ThanhPhan.Custom(Cha, DuLieu, CauHinh, CapNhat, DeQuy, NguCanh)
	local KhungWrapper = TaoDoiTuong("Frame", {
		LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = Cha
	})
	if type(DuLieu.TaoUI) == "function" then
		DuLieu.TaoUI(KhungWrapper, CauHinh, NguCanh)
	end
	task.delay(0.08, CapNhat)
end

local function TaoBoCucCacKhoi(VungCuon, DanhSachKhoiTao, SoCotTab, CauHinh, TaoMuc)
	local Mau = CauHinh.Mau
	local SoCot = SoCotTab or 1
	if SoCot > 2 then SoCot = 2 end

	local CotTrai, CotPhai
	if SoCot == 2 then
		CotTrai = TaoDoiTuong("Frame", {Size = UDim2.new(0.48, 0, 0, 0), Position = UDim2.new(0.25, 0, 0, 6), AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = VungCuon})
		TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = "LayoutOrder", Parent = CotTrai})
		CotPhai = TaoDoiTuong("Frame", {Size = UDim2.new(0.48, 0, 0, 0), Position = UDim2.new(0.75, 0, 0, 6), AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = VungCuon})
		TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = "LayoutOrder", Parent = CotPhai})
	else
		CotTrai = TaoDoiTuong("Frame", {Size = UDim2.new(0.96, 0, 0, 0), Position = UDim2.new(0.5, 0, 0, 6), AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = VungCuon})
		TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = "LayoutOrder", Parent = CotTrai})
	end

	local function TaoKhoi(DuLieuKhoi, CotBoTri)
		local Khoi = TaoDoiTuong("Frame", {Name = "Theme_NenKhoi", Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Mau.NenKhoi, ClipsDescendants = true, ZIndex = 1, Parent = CotBoTri})
		TaoBoGoc(Khoi, 10) TaoVien(Khoi, Mau.VienNeon, 0.6)

		local DauMuc = TaoDoiTuong("TextButton", {Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Text = "", ZIndex = 2, Parent = Khoi})
		local DuongKe = TaoDoiTuong("Frame", {Name = "Theme_Vien", Size = UDim2.new(1, -24, 0, 1), Position = UDim2.new(0, 12, 1, -1), BackgroundColor3 = Mau.VienNeon, BackgroundTransparency = 0.8, BorderSizePixel = 0, ZIndex = 2, Parent = DauMuc})

		local TieuDeKhoi = TaoNhan({Text = DuLieuKhoi.TieuDe, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 12, 0, 0), TextColor3 = Mau.Chu, Font = "GothamBold", TextScaled = true, TextXAlignment = "Left", ZIndex = 3, Parent = DauMuc})
		TaoGioiHanChu(TieuDeKhoi, CauHinh.VanBan.TieuDe)

		local MuiTen = TaoDoiTuong("ImageLabel", {Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Image = CauHinh.Asset.MuiTenXuong, BackgroundTransparency = 1, ZIndex = 3, Parent = DauMuc})

		local ThanKhoi = TaoDoiTuong("Frame", {Name = "ThanKhoi", Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(1, 0, 1, -45), BackgroundTransparency = 1, Parent = Khoi})
		local BoCucThan = TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = "LayoutOrder", Parent = ThanKhoi})
		TaoDoiTuong("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = ThanKhoi})

		local DangMoRong = true
		local DangChoCapNhat = false

		local function CapNhatKichThuoc()
			if DangChoCapNhat then return end
			DangChoCapNhat = true
			task.spawn(function()
				DichVuRun.RenderStepped:Wait()
				DangChoCapNhat = false
				if not Khoi.Parent then return end
				local chieuCaoMoRong = 45 + 10 + 14 + BoCucThan.AbsoluteContentSize.Y
				ChayTween(Khoi, TweenMuot, {Size = UDim2.new(1, 0, 0, DangMoRong and chieuCaoMoRong or 45)})
			end)
		end

		ThanKhoi.ChildAdded:Connect(function(child)
			if child:IsA("Frame") then
				child:GetPropertyChangedSignal("AbsoluteSize"):Connect(CapNhatKichThuoc)
				child:GetPropertyChangedSignal("Visible"):Connect(CapNhatKichThuoc)
			end
		end)

		if DuLieuKhoi.ChucNang then
			for ViTriChucNang, DuLieuChucNang in ipairs(DuLieuKhoi.ChucNang) do TaoMuc(ThanKhoi, DuLieuChucNang, CapNhatKichThuoc, ViTriChucNang) end
		end

		DauMuc.MouseButton1Click:Connect(function()
			DangMoRong = not DangMoRong
			CapNhatKichThuoc()
			ChayTween(MuiTen, TweenMuot, {Rotation = DangMoRong and 180 or 0})
			DuongKe.Visible = DangMoRong
		end)

		CapNhatKichThuoc() DuongKe.Visible = DangMoRong MuiTen.Rotation = DangMoRong and 180 or 0
	end

	for ViTriTao, DuLieuKhoiTao in ipairs(DanhSachKhoiTao) do
		if SoCot == 2 then TaoKhoi(DuLieuKhoiTao, (ViTriTao % 2 ~= 0) and CotTrai or CotPhai) else TaoKhoi(DuLieuKhoiTao, CotTrai) end
	end
end

function ThuVienUI.Tao(KhungChinh, Cuon, DuLieu, CauHinh, LopPhu, DongMenu, HamPhaHuy, HamThuNho)
	CauHinh.Mau = CauHinh.Mau or {}
	for k, v in pairs(ChuDe.MacDinh) do
		if CauHinh.Mau[k] == nil then CauHinh.Mau[k] = v end
	end

	local Mau = CauHinh.Mau
	local NguCanh = {LopPhu = LopPhu, DongMenu = DongMenu, DongMenuAnim = nil}
	if not CauHinh.DangTab then Cuon.ScrollingDirection = Enum.ScrollingDirection.Y end

	local DanhSachTab = {}
	local CurrentTabIndex = -1

	local function ApDungThemeUI(ThemeInfo, ChiPreview)
		local thoiGian = ChiPreview and 0.08 or 0.38
		local TweenTheme = TweenInfo.new(thoiGian, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

		for k, v in pairs(ThemeInfo) do
			if k ~= "Ten" then CauHinh.Mau[k] = v end
		end

		ChayTween(KhungChinh, TweenTheme, {BackgroundColor3 = ThemeInfo.Nen})
		ChayTween(Cuon, TweenTheme, {BackgroundColor3 = ThemeInfo.NenList})
		local nutMoUI = KhungChinh.Parent and KhungChinh.Parent:FindFirstChild("NutMoUI")
		if nutMoUI then ChayTween(nutMoUI, TweenTheme, {BackgroundColor3 = ThemeInfo.Nen}) end

		for _, ui in ipairs(KhungChinh:GetDescendants()) do
			if ui.Name == "Theme_Vien_ThemeCard" or ui.Name == "Theme_Vien_Preview" or ui.Name == "Theme_Vien_CustomAdd" then continue end

			if ui.Name == "Theme_Vien" then
				if ui:IsA("UIStroke") then ChayTween(ui, TweenTheme, {Color = ThemeInfo.VienNeon})
				elseif ui:IsA("Frame") then ChayTween(ui, TweenTheme, {BackgroundColor3 = ThemeInfo.VienNeon}) end
			elseif ui.Name == "Theme_NenMuc" and ui:IsA("GuiObject") then
				ChayTween(ui, TweenTheme, {BackgroundColor3 = ThemeInfo.NenMuc})
				ui:SetAttribute("MauGoc", ThemeInfo.NenMuc)
			elseif ui.Name == "Theme_NenDanhSachMo" and ui:IsA("GuiObject") then
				ChayTween(ui, TweenTheme, {BackgroundColor3 = ThemeInfo.NenDanhSachMo})
			elseif ui.Name == "Theme_TichBat" and ui:IsA("GuiObject") then
				ChayTween(ui, TweenTheme, {BackgroundColor3 = ThemeInfo.TichBat})
			elseif ui.Name == "Theme_CucGat" and ui:IsA("GuiObject") then
				if ui:GetAttribute("IsOn") then ChayTween(ui, TweenTheme, {BackgroundColor3 = ThemeInfo.TichBat}) end
			elseif ui.Name == "Theme_NenKhoi" and ui:IsA("Frame") then
				ChayTween(ui, TweenTheme, {BackgroundColor3 = ThemeInfo.NenKhoi})
			elseif ui.Name == "Theme_HopVuong" and ui:IsA("GuiObject") then
				ChayTween(ui, TweenTheme, {BackgroundColor3 = ThemeInfo.NenHop})
			elseif ui.Name == "Theme_NenPhu" and ui:IsA("GuiObject") then
				ChayTween(ui, TweenTheme, {BackgroundColor3 = ThemeInfo.NenPhu})
			elseif ui.Name == "Theme_ChonPhu" and ui:IsA("GuiObject") then
				ChayTween(ui, TweenTheme, {BackgroundColor3 = ThemeInfo.ChonPhu})
			elseif ui.Name == "Theme_KhungGat" and ui:IsA("Frame") then
				local cucGat = ui:FindFirstChild("Theme_CucGat")
				if cucGat and cucGat:GetAttribute("IsOn") then
					ChayTween(ui, TweenTheme, {BackgroundColor3 = ThemeInfo.ChonPhu})
				else
					ChayTween(ui, TweenTheme, {BackgroundColor3 = ThemeInfo.NenHop})
				end
			elseif ui.Name == "Theme_NenHop" and ui:IsA("TextButton") or ui.Name == "Theme_NenHop" and ui:IsA("TextBox") then
				ChayTween(ui, TweenTheme, {BackgroundColor3 = ThemeInfo.NenHop})
				ui:SetAttribute("MauGoc", ThemeInfo.NenHop)
			elseif ui.Name == "VienNeon" and ui:IsA("UIStroke") then
				ChayTween(ui, TweenTheme, {Color = ThemeInfo.VienNeon})
			end
		end

		for _, ThongTinTab in ipairs(DanhSachTab) do
			if ThongTinTab.Index == CurrentTabIndex then
				ChayTween(ThongTinTab.Nut, TweenTheme, {TextColor3 = ThemeInfo.TichBat, BackgroundColor3 = ThemeInfo.NenMuc})
				ChayTween(ThongTinTab.ThanhLine, TweenTheme, {BackgroundColor3 = ThemeInfo.TichBat})
			else
				ChayTween(ThongTinTab.Nut, TweenTheme, {TextColor3 = ThemeInfo.Chu, BackgroundColor3 = ThemeInfo.NenHop})
				ChayTween(ThongTinTab.ThanhLine, TweenTheme, {BackgroundColor3 = ThemeInfo.Chu})
			end
		end
	end

	if CauHinh.ConfigMenu then
		local KhoiSetting = {
			TieuDe = "UI Settings",
			ChucNang = {
				{
					Ten = "UI Transparency", Loai = "Otich", HienTai = "Bat",
					SuKien = function(st) 
						CauHinh.DoTrongSuotKhung = st and 0.4 or 0.15
						KhungChinh.BackgroundTransparency = CauHinh.DoTrongSuotKhung
					end
				},
				{
					Ten = "VIPThemeSelector", Loai = "Custom",
					TaoUI = function(Cha, CauHinhCustom, NguCanhCust) TaoThemeSelector(Cha, CauHinh, ApDungThemeUI, Mau, NguCanhCust) end
				}
			}
		}
		if type(CauHinh.ExtraConfig) == "table" then
			for _, v in ipairs(CauHinh.ExtraConfig) do table.insert(KhoiSetting.ChucNang, v) end
		end
		if CauHinh.DangTab then
			table.insert(DuLieu, {TenTab = "Config Menu", DuLieuKhoi = {KhoiSetting}})
		else
			table.insert(DuLieu, KhoiSetting)
		end
	end

	local Toolbar = TaoDoiTuong("Frame", {Size = UDim2.new(0, 120, 0, 35), Position = UDim2.new(1, -10, 0, 10), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, ZIndex = 10, Parent = KhungChinh})
	TaoDoiTuong("UIListLayout", {FillDirection = "Horizontal", HorizontalAlignment = "Right", SortOrder = "LayoutOrder", Padding = UDim.new(0, 8), Parent = Toolbar})

	local function SetHieuUngToolbar(Nut, Vien, Kieu, SizeThuong, SizeLuot)
		Nut.MouseEnter:Connect(function()
			local mg = Nut:GetAttribute("MauGoc") or CauHinh.Mau.NenHop
			local hoverCol = (Kieu == "Dong") and CauHinh.Mau.NutDongLuot or Color3.new(math.min(mg.R+0.1, 1), math.min(mg.G+0.1, 1), math.min(mg.B+0.1, 1))
			ChayTween(Nut, TweenMuot, {BackgroundColor3 = hoverCol, BackgroundTransparency = 0, TextSize = SizeLuot, TextColor3 = Color3.new(1, 1, 1)})
			ChayTween(Vien, TweenMuot, {Transparency = 0})
		end)
		Nut.MouseLeave:Connect(function()
			local mg = Nut:GetAttribute("MauGoc") or CauHinh.Mau.NenHop
			ChayTween(Nut, TweenMuot, {BackgroundColor3 = mg, BackgroundTransparency = 0.6, TextSize = SizeThuong, TextColor3 = CauHinh.Mau.Chu})
			ChayTween(Vien, TweenMuot, {Transparency = 1})
		end)
	end

	if CauHinh.TimKiem then
		local KhungTimKiem = TaoDoiTuong("Frame", {LayoutOrder = 0, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 10, Parent = Toolbar})
		local NhanTimKiemText = TaoDoiTuong("TextBox", {
			Size = UDim2.new(0, 150, 0, 28), Position = UDim2.new(1, -3, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.3,
			TextColor3 = Mau.Chu, PlaceholderText = "🔍  Search...", PlaceholderColor3 = Mau.ChuMo,
			Text = "", Font = "Gotham", TextSize = 12, ClearTextOnFocus = false,
			ZIndex = 10, Parent = KhungTimKiem
		})
		NhanTimKiemText.Name = "Theme_NenHop"
		TaoBoGoc(NhanTimKiemText, 8)
		TaoVien(NhanTimKiemText, Mau.VienNeon, 0.4, 1.5, "Theme_Vien")
		TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = NhanTimKiemText})

		local NutTimKiem = TaoDoiTuong("TextButton", {LayoutOrder = 1, Size = UDim2.fromOffset(35, 35), BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.6, Text = "🔍", TextColor3 = Mau.Chu, TextSize = 18, ZIndex = 10, Parent = Toolbar})
		NutTimKiem.Name = "Theme_NenHop" NutTimKiem:SetAttribute("MauGoc", Mau.NenHop)
		TaoBoGoc(NutTimKiem, 8) local VienTimKiem = TaoVien(NutTimKiem, Mau.VienNeon, 1, 2, "Theme_Vien")
		SetHieuUngToolbar(NutTimKiem, VienTimKiem, nil, 18, 22)

		local DangTimKiem = false
		NutTimKiem.MouseButton1Click:Connect(function()
			DangTimKiem = not DangTimKiem
			if DangTimKiem then
				ChayTween(KhungTimKiem, TweenMuot, {Size = UDim2.new(0, 156, 1, 0)})
				task.spawn(function() task.wait(0.35) NhanTimKiemText:CaptureFocus() end)
			else
				ChayTween(KhungTimKiem, TweenMuot, {Size = UDim2.new(0, 0, 1, 0)})
				NhanTimKiemText.Text = ""
				TimKiem.LocDuLieu(Cuon, "")
			end
		end)
		NhanTimKiemText:GetPropertyChangedSignal("Text"):Connect(function() TimKiem.LocDuLieu(Cuon, NhanTimKiemText.Text) end)
	end

	local NutMin = TaoDoiTuong("TextButton", {LayoutOrder = 2, Size = UDim2.fromOffset(35, 35), BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.6, Text = "_", TextColor3 = Mau.Chu, TextSize = 22, Font = "GothamBold", ZIndex = 10, Parent = Toolbar})
	NutMin.Name = "Theme_NenHop" NutMin:SetAttribute("MauGoc", Mau.NenHop)
	TaoBoGoc(NutMin, 8) local VienMin = TaoVien(NutMin, Mau.VienNeon, 1, 2, "Theme_Vien")
	SetHieuUngToolbar(NutMin, VienMin, nil, 22, 26)

	local function KichHoatHieuUngMin()
		ChayTween(NutMin, TweenNay, {TextSize = 35})
		task.wait(0.15)
		if NutMin and NutMin.Parent then ChayTween(NutMin, TweenMuot, {TextSize = 22}) end
	end

	shared.HxHieuUngThuNhoUI = function() task.spawn(KichHoatHieuUngMin) end
	NutMin.MouseButton1Click:Connect(function() task.spawn(KichHoatHieuUngMin) if HamThuNho then task.delay(0.15, HamThuNho) end end)

	local NutDongUI = TaoDoiTuong("TextButton", {LayoutOrder = 3, Size = UDim2.fromOffset(35, 35), BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.6, Text = "X", TextColor3 = Mau.Chu, TextSize = 22, Font = "GothamBlack", ZIndex = 10, Parent = Toolbar})
	NutDongUI.Name = "Theme_NenHop" NutDongUI:SetAttribute("MauGoc", Mau.NenHop)
	TaoBoGoc(NutDongUI, 8) local VienDong = TaoVien(NutDongUI, Mau.VienNeon, 1, 2, "Theme_Vien")
	SetHieuUngToolbar(NutDongUI, VienDong, "Dong", 22, 26)
	NutDongUI.MouseButton1Click:Connect(function() if HamPhaHuy then HamPhaHuy() end end)

	KhungChinh:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Toolbar.Visible = not (KhungChinh.AbsoluteSize.X < 50 or KhungChinh.AbsoluteSize.Y < 50) end)

	KhungChinh:GetPropertyChangedSignal("Visible"):Connect(function()
		Toolbar.Visible = KhungChinh.Visible
	end)

	local TaoMuc = nil
	TaoMuc = function(Cha, DuLieuMuc, CapNhatMuc, ThuTuDau)
		DuLieuMuc.ThuTu = ThuTuDau or 0
		if ThanhPhan[DuLieuMuc.Loai] then
			ThanhPhan[DuLieuMuc.Loai](Cha, DuLieuMuc, CauHinh, function() if CapNhatMuc then CapNhatMuc() end end, TaoMuc, NguCanh)
		end
	end
	
	local ChuyenTab
	
	if CauHinh.DangTab then
		Cuon.ScrollingEnabled = false Cuon.ScrollBarThickness = 0 Cuon.CanvasSize = UDim2.new(0, 0, 0, 0)
		local ThanhTab = TaoDoiTuong("ScrollingFrame", {Size = UDim2.new(0.96, 0, 0, 30), Position = UDim2.new(0.02, 0, 0, 1), BackgroundTransparency = 1, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X, AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(0, 0, 0, 0), ClipsDescendants = true, Parent = Cuon})
		local PaddingThanhTab = TaoDoiTuong("UIPadding", {Parent = ThanhTab})
		TaoDoiTuong("UIListLayout", {FillDirection = "Horizontal", SortOrder = "LayoutOrder", Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Left, Parent = ThanhTab})

		local KhungNoiDungTab = TaoDoiTuong("Frame", {Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Cuon})
		local TabMacDinhIndex = 1

		if CauHinh.TabMacDinh then
			for i, tab in ipairs(DuLieu) do if tab.TenTab == CauHinh.TabMacDinh or i == CauHinh.TabMacDinh then TabMacDinhIndex = i break end end
		end

		local function CapNhatPaddingTab()
			if #DanhSachTab > 0 and ThanhTab.AbsoluteSize.X > 0 then
				local NuaThanh = ThanhTab.AbsoluteSize.X / 2
				local SizeNutDau = DanhSachTab[1].Nut.AbsoluteSize.X / 2
				local SizeNutCuoi = DanhSachTab[#DanhSachTab].Nut.AbsoluteSize.X / 2
				PaddingThanhTab.PaddingLeft = UDim.new(0, NuaThanh - SizeNutDau)
				PaddingThanhTab.PaddingRight = UDim.new(0, NuaThanh - SizeNutCuoi)
			end
		end

		local function CanGiuaTab(NutTabMucTieu)
			task.spawn(function()
				task.wait(0.05) if not ThanhTab.Parent or not NutTabMucTieu.Parent then return end
				local ToaDoXCanvas = NutTabMucTieu.AbsolutePosition.X - ThanhTab.AbsolutePosition.X + ThanhTab.CanvasPosition.X
				local DiemGiuaNut = ToaDoXCanvas + (NutTabMucTieu.AbsoluteSize.X / 2)
				local ViTriCuonMoi = DiemGiuaNut - (ThanhTab.AbsoluteSize.X / 2)
				DichVuTween:Create(ThanhTab, TweenMuot, {CanvasPosition = Vector2.new(math.clamp(ViTriCuonMoi, 0, math.max(0, ThanhTab.AbsoluteCanvasSize.X - ThanhTab.AbsoluteSize.X)), 0)}):Play()
			end)
		end

		ChuyenTab = function(IndexCuaTab, InitialLoad)
			local Huong = (IndexCuaTab > CurrentTabIndex) and 1 or -1
			if InitialLoad or CurrentTabIndex == -1 then Huong = 0 end
			CurrentTabIndex = IndexCuaTab

			local tweenTabChon  = {BackgroundTransparency = 0.2, BackgroundColor3 = CauHinh.Mau.NenMuc, TextColor3 = CauHinh.Mau.TichBat, TextTransparency = 0}
			local tweenTabKhong = {BackgroundTransparency = 0.8, BackgroundColor3 = CauHinh.Mau.NenHop, TextColor3 = Mau.Chu, TextTransparency = 0.4}

			for _, ThongTin in ipairs(DanhSachTab) do
				if ThongTin.Index == IndexCuaTab then
					ThongTin.VungCuon.Visible = true
					if Huong ~= 0 then
						ThongTin.VungCuon.Position = UDim2.new(0, 40 * Huong, 0, 0)
						DichVuTween:Create(ThongTin.VungCuon, TweenMuot, {Position = UDim2.new(0, 0, 0, 0)}):Play()
					else ThongTin.VungCuon.Position = UDim2.new(0, 0, 0, 0) end
					ThongTin.Nut.Font = Enum.Font.GothamBold
					if InitialLoad then
						for k, v in pairs(tweenTabChon) do ThongTin.Nut[k] = v end
						ThongTin.ThanhLine.BackgroundTransparency = 0 ThongTin.ThanhLine.Size = UDim2.new(0.8, 0, 0, 2) ThongTin.ThanhLine.BackgroundColor3 = CauHinh.Mau.TichBat
					else
						ChayTween(ThongTin.Nut, TweenNhanh, tweenTabChon) ChayTween(ThongTin.ThanhLine, TweenNhanh, {BackgroundTransparency = 0, Size = UDim2.new(0.8, 0, 0, 2), BackgroundColor3 = CauHinh.Mau.TichBat})
					end
					CanGiuaTab(ThongTin.Nut)
				else
					ThongTin.VungCuon.Visible = false ThongTin.Nut.Font = Enum.Font.GothamMedium
					if InitialLoad then
						for k, v in pairs(tweenTabKhong) do ThongTin.Nut[k] = v end
						ThongTin.ThanhLine.BackgroundTransparency = 0.6 ThongTin.ThanhLine.Size = UDim2.new(0.3, 0, 0, 2) ThongTin.ThanhLine.BackgroundColor3 = Mau.Chu
					else
						ChayTween(ThongTin.Nut, TweenNhanh, tweenTabKhong) ChayTween(ThongTin.ThanhLine, TweenNhanh, {BackgroundTransparency = 0.6, Size = UDim2.new(0.3, 0, 0, 2), BackgroundColor3 = Mau.Chu})
					end
				end
			end
		end

		for ViTriTab, DuLieuTab in ipairs(DuLieu) do
			local NutTab = TaoDoiTuong("TextButton", {Name = "Theme_NenHop", LayoutOrder = ViTriTab, Size = UDim2.new(0, 0, 0, 28), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.8, Text = DuLieuTab.TenTab or "Tab " .. ViTriTab, TextColor3 = Mau.Chu, TextTransparency = 0.4, Font = Enum.Font.GothamMedium, TextSize = CauHinh.VanBan.Nho + 2, TextWrapped = false, AutoButtonColor = false, Parent = ThanhTab})
			TaoBoGoc(NutTab, 6) TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = NutTab})
			local ThanhLine = TaoDoiTuong("Frame", {Name = "Theme_Vien", Size = UDim2.new(0.3, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -1), AnchorPoint = Vector2.new(0.5, 1), BackgroundColor3 = Mau.Chu, BackgroundTransparency = 0.6, BorderSizePixel = 0, Parent = NutTab})
			TaoBoGoc(ThanhLine, 2)
			local VungCuonRieng = TaoDoiTuong("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 4, ScrollBarImageColor3 = Color3.fromRGB(200,200,200), BorderSizePixel = 0, ScrollingDirection = Enum.ScrollingDirection.Y, AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = KhungNoiDungTab})

			TaoDoiTuong("UIStroke", {Name = "VienNeon", Color = Mau.VienNeon, Transparency = 0.5, Thickness = 0.5, Parent = VungCuonRieng})
			TaoDoiTuong("UIPadding", {PaddingBottom = UDim.new(0, 20), Parent = VungCuonRieng})

			table.insert(DanhSachTab, {Index = ViTriTab, Nut = NutTab, ThanhLine = ThanhLine, Ten = DuLieuTab.TenTab, VungCuon = VungCuonRieng})

			NutTab.MouseButton1Click:Connect(function()
				if CurrentTabIndex ~= ViTriTab then
					if NguCanh and NguCanh.DongMenuAnim then NguCanh.DongMenuAnim() end
					CauHinh.TabMacDinh = DuLieuTab.TenTab ChuyenTab(ViTriTab, false)
				end
			end)
			TaoBoCucCacKhoi(VungCuonRieng, DuLieuTab.DuLieuKhoi or {}, DuLieuTab.SoCot or CauHinh.SoCot, CauHinh, TaoMuc)
		end

		ChuyenTab(TabMacDinhIndex, true)

		task.spawn(function()
			task.wait(0.1) CapNhatPaddingTab()
			ThanhTab:GetPropertyChangedSignal("AbsoluteSize"):Connect(CapNhatPaddingTab)
			if DanhSachTab[TabMacDinhIndex] then CanGiuaTab(DanhSachTab[TabMacDinhIndex].Nut) end
		end)
	else
		TaoDoiTuong("UIStroke", {Name = "VienNeon", Color = Mau.VienNeon, Transparency = 0.5, Thickness = 0.5, Parent = Cuon})
		TaoDoiTuong("UIPadding", {PaddingBottom = UDim.new(0, 20), Parent = Cuon})
		TaoBoCucCacKhoi(Cuon, DuLieu, CauHinh.SoCot, CauHinh, TaoMuc)
	end
	return {
		Toolbar = Toolbar, NutMin = NutMin, VienMin = VienMin,
		CapNhatTab = function()
			if CauHinh.DangTab and CurrentTabIndex > 0 then
				ChuyenTab(CurrentTabIndex, false)
			end
		end
	}
end

return ThuVienUI