local DichVuTween, DichVuRun, DichVuInput, DichVuText = game:GetService("TweenService"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TextService")
local Tween_Nhanh = TweenInfo.new(0.08, Enum.EasingStyle.Sine)
local Tween_Muot = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local Tween_Nay = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local KhungCuon, ThanhPhan = {}, {}

local function ChayTween(DoiTuong, ThongTin, ThuocTinh)
	if not DoiTuong then return end
	DichVuTween:Create(DoiTuong, ThongTin, ThuocTinh):Play()
end

local function TaoDoiTuong(Loai, ThuocTinh, DoiTuongCon)
	local DoiTuong = Instance.new(Loai)
	for k, v in pairs(ThuocTinh or {}) do
		if k ~= "Parent" then DoiTuong[k] = v end
	end
	if DoiTuongCon then
		for _, Con in ipairs(DoiTuongCon) do Con.Parent = DoiTuong end
	end
	if ThuocTinh.Parent then DoiTuong.Parent = ThuocTinh.Parent end
	return DoiTuong
end

local function TaoBoGoc(Cha, BanKinh)
	return TaoDoiTuong("UICorner", {CornerRadius = UDim.new(0, BanKinh), Parent = Cha})
end

local function TaoVien(Cha, Mau, DoTrongSuot, DoDay)
	return TaoDoiTuong("UIStroke", {Color = Mau, Transparency = DoTrongSuot or 0, Thickness = DoDay or 1, ApplyStrokeMode = "Border", Parent = Cha})
end

local function TaoGioiHanChu(Cha, KichThuocMax)
	return TaoDoiTuong("UITextSizeConstraint", {MaxTextSize = KichThuocMax or 18, Parent = Cha})
end

local function TaoNhan(ThuocTinh)
	ThuocTinh.Font = ThuocTinh.Font or Enum.Font.GothamMedium
	ThuocTinh.TextScaled = true
	ThuocTinh.BackgroundTransparency = 1
	return TaoDoiTuong("TextLabel", ThuocTinh)
end

local function TaoHieuUng(NutBam, NoiDung)
	local MauGoc = NutBam.BackgroundColor3
	local MauLuot = Color3.new(math.min(MauGoc.R + 0.1, 1), math.min(MauGoc.G + 0.1, 1), math.min(MauGoc.B + 0.1, 1))

	NutBam.MouseEnter:Connect(function() ChayTween(NutBam, Tween_Muot, {BackgroundColor3 = MauLuot}) end)
	NutBam.MouseLeave:Connect(function() ChayTween(NutBam, Tween_Muot, {BackgroundColor3 = MauGoc}) end)

	NutBam.MouseButton1Down:Connect(function()
		ChayTween(NutBam, Tween_Nhanh, {BackgroundTransparency = 0.2})
	end)

	NutBam.MouseButton1Up:Connect(function()
		ChayTween(NutBam, Tween_Nhanh, {BackgroundTransparency = 0})
	end)
end

function ThanhPhan.Otich(Cha, DuLieu, CauHinh, CapNhat, DeQuy)
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {
		TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})
	})

	local HangNgang = TaoDoiTuong("Frame", {LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, ZIndex = 2, Parent = KhungChinh})

	if DuLieu.LoaiNutCon == "CungHang" then
		TaoDoiTuong("UIListLayout", {FillDirection = "Horizontal", SortOrder = "LayoutOrder", Padding = UDim.new(0, 4), Parent = HangNgang})
	end

	local NutTich = TaoDoiTuong("TextButton", {
		Name = "NutTich", LayoutOrder = 1, Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = CauHinh.Mau.NenMuc, Text = "", AutoButtonColor = false, ZIndex = 2, Parent = HangNgang
	})
	TaoBoGoc(NutTich, 8)
	TaoVien(NutTich, CauHinh.Mau.VienHop, 0.8)

	local DoDaiChuoi = utf8.len(DuLieu.Ten) or string.len(DuLieu.Ten)

	if DoDaiChuoi > 10 then
		local VungCuonChu = TaoDoiTuong("ScrollingFrame", {
			Size = UDim2.new(0.72, -5, 1, 0), 
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1, 
			ScrollBarThickness = 0, 
			ScrollingDirection = Enum.ScrollingDirection.X,
			AutomaticCanvasSize = Enum.AutomaticSize.X, 
			CanvasSize = UDim2.new(0,0,0,0), 
			ClipsDescendants = true,
			ZIndex = 3, 
			Parent = NutTich
		})

		local NhanTich = TaoNhan({
			Text = "  " .. DuLieu.Ten, 
			Size = UDim2.new(0, 0, 1, 0), 
			AutomaticSize = Enum.AutomaticSize.X,
			TextColor3 = CauHinh.Mau.Chu, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			ZIndex = 3, 
			Parent = VungCuonChu
		})
		NhanTich.TextScaled = false
		NhanTich.TextWrapped = false
		NhanTich.TextSize = CauHinh.VanBan.Nho + 2
	else
		local NhanTich = TaoNhan({
			Text = "  " .. DuLieu.Ten, 
			Size = UDim2.new(0.72, -5, 1, 0),
			TextColor3 = CauHinh.Mau.Chu, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			TextWrapped = true,
			ZIndex = 3, 
			Parent = NutTich
		})
		TaoGioiHanChu(NhanTich, CauHinh.VanBan.Nho + 2)
	end

	local HopVuong = TaoDoiTuong("Frame", {
		Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, -8, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = CauHinh.Mau.NenHop, ZIndex = 3, Parent = NutTich
	})
	TaoBoGoc(HopVuong, 6)
	TaoVien(HopVuong, CauHinh.Mau.VienHop)

	DuLieu.TrangThai = (DuLieu.HienTai == "Bat") or DuLieu.TrangThai or false
	local DauTich = TaoDoiTuong("Frame", {
		Size = UDim2.new(1, -8, 1, -8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CauHinh.Mau.TichBat, Visible = DuLieu.TrangThai, ZIndex = 4, Parent = HopVuong
	})
	TaoBoGoc(DauTich, 4)
	TaoVien(DauTich, CauHinh.Mau.TichBat, 0.5, 2)

	local NutPhu, CapNhatNutPhu, ChiSoPhu = nil, nil, 1
	local KhungChuaPhu = TaoDoiTuong("Frame", {LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = KhungChinh})
	local Dem = TaoDoiTuong("UIPadding", {Parent = KhungChuaPhu})
	TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = "LayoutOrder", Parent = KhungChuaPhu})

	if DuLieu.LoaiNutCon == "CungHang" then
		NutPhu = TaoDoiTuong("TextButton", {
			LayoutOrder = 2, Size = UDim2.new(0.3, 0, 1, 0), BackgroundColor3 = CauHinh.Mau.NenMuc,
			Text = "...", TextColor3 = CauHinh.Mau.Chu, Font = "GothamMedium", TextScaled = true,
			Visible = false, ZIndex = 2, Parent = HangNgang
		})
		TaoBoGoc(NutPhu, 8)
		TaoVien(NutPhu, CauHinh.Mau.VienHop, 0.8)
		TaoGioiHanChu(NutPhu, CauHinh.VanBan.Nho + 2)
		TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4), Parent = NutPhu})
		TaoHieuUng(NutPhu, nil)

		CapNhatNutPhu = function()
			NutPhu.Text = (DuLieu.CacNutCon and DuLieu.CacNutCon[ChiSoPhu]) and DuLieu.CacNutCon[ChiSoPhu].Ten or "Trong"
		end
		if DuLieu.CacNutCon then CapNhatNutPhu() end

		NutPhu.MouseButton1Click:Connect(function()
			if DuLieu.CacNutCon and DuLieu.CacNutCon[ChiSoPhu] then
				task.spawn(function() if DuLieu.CacNutCon[ChiSoPhu].SuKien then DuLieu.CacNutCon[ChiSoPhu].SuKien() end end)
				if #DuLieu.CacNutCon > 1 then
					ChiSoPhu = (ChiSoPhu % #DuLieu.CacNutCon) + 1
					CapNhatNutPhu()
				end
			end
		end)
	end

	local function LamMoi()
		if DuLieu.LoaiNutCon == "CungHang" then 
			if DuLieu.TrangThai then
				ChayTween(NutTich, Tween_Muot, {Size = UDim2.new(0.68, -4, 1, 0)})
				NutPhu.Visible = true
				ChayTween(NutPhu, Tween_Muot, {BackgroundTransparency = 0})
			else
				ChayTween(NutTich, Tween_Muot, {Size = UDim2.new(1, 0, 1, 0)})
				NutPhu.Visible = false
			end
			return 
		end

		for _, c in ipairs(KhungChuaPhu:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
		if DuLieu.TrangThai and DuLieu.CacNutCon and #DuLieu.CacNutCon > 0 then
			Dem.PaddingTop = UDim.new(0, 6)
			Dem.PaddingBottom = UDim.new(0, 6)
			for k, v in ipairs(DuLieu.CacNutCon) do DeQuy(KhungChuaPhu, v, CapNhat, k) end
		else
			Dem.PaddingTop = UDim.new(0, 0)
			Dem.PaddingBottom = UDim.new(0, 0)
		end
		CapNhat()
	end

	if DuLieu.TrangThai then LamMoi() end

	TaoHieuUng(NutTich, nil)
	NutTich.MouseButton1Click:Connect(function()
		DuLieu.TrangThai = not DuLieu.TrangThai
		DuLieu.HienTai = DuLieu.TrangThai and "Bat" or "Tat"

		DauTich.Visible = DuLieu.TrangThai
		if DuLieu.TrangThai then
			DauTich.Size = UDim2.fromScale(0, 0)
			ChayTween(DauTich, Tween_Nay, {Size = UDim2.new(1, -8, 1, -8)})
		end

		LamMoi()
		if DuLieu.SuKien then task.spawn(DuLieu.SuKien, DuLieu.TrangThai) end
	end)
end

function ThanhPhan.Nut(Cha, DuLieu, CauHinh, CapNhat, DeQuy)
	local NutBam = TaoDoiTuong("TextButton", {
		LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = CauHinh.Mau.NenMuc,
		Text = DuLieu.Ten, TextColor3 = CauHinh.Mau.Chu, Font = "GothamMedium", TextScaled = true, ZIndex = 2, Parent = Cha
	})
	TaoBoGoc(NutBam, 8)
	TaoVien(NutBam, CauHinh.Mau.VienHop)
	TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = NutBam})

	TaoGioiHanChu(NutBam, CauHinh.VanBan.Nut + 2)

	TaoHieuUng(NutBam, NutBam)

	local DuLieuHienTai, ChiSoVongLap = DuLieu, 0
	NutBam.MouseButton1Click:Connect(function()
		if DuLieuHienTai.SuKien then task.spawn(DuLieuHienTai.SuKien) end
		if DuLieuHienTai.SauBam == "Thay" and DuLieuHienTai.DanhSachThay then
			local DuLieuMoi
			if type(DuLieuHienTai.DanhSachThay) == "table" and DuLieuHienTai.DanhSachThay[1] then
				ChiSoVongLap = ChiSoVongLap + 1
				local DanhSach = DuLieuHienTai.DanhSachThay
				local CoVongLap = true
				for _, v in ipairs(DanhSach) do if v.Loai and v.Loai ~= "Nut" then CoVongLap = false break end end
				ChiSoVongLap = CoVongLap and ((ChiSoVongLap - 1) % #DanhSach) + 1 or ChiSoVongLap
				DuLieuMoi = DanhSach[ChiSoVongLap]
			else
				DuLieuMoi = DuLieuHienTai.DanhSachThay
			end

			if DuLieuMoi then
				if (DuLieuMoi.Loai or "Nut") == "Nut" then
					NutBam.Text = DuLieuMoi.Ten or NutBam.Text
					if DuLieuMoi.Mau then ChayTween(NutBam, Tween_Muot, {BackgroundColor3 = DuLieuMoi.Mau}) end
					local DanhSachCu = DuLieuHienTai.DanhSachThay
					DuLieuHienTai = DuLieuMoi
					if ChiSoVongLap > 0 then DuLieuHienTai.DanhSachThay, DuLieuHienTai.SauBam = DanhSachCu, "Thay" end
				else
					NutBam:Destroy()
					DeQuy(Cha, DuLieuMoi, CapNhat, DuLieu.ThuTu)
					CapNhat()
				end
			end
		end
	end)
end

function ThanhPhan.NhieuNut(Cha, DuLieu, CauHinh, CapNhat)
	local KhungChua = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Parent = Cha}, {
		TaoDoiTuong("UIListLayout", {FillDirection = "Horizontal", SortOrder = "LayoutOrder", Padding = UDim.new(0, 8)})
	})

	local function TaoNutNho(Ten, SuKien, ThuTu, TongSo)
		local DoRong = 1 / (TongSo or 1)
		local NutBam = TaoDoiTuong("TextButton", {
			LayoutOrder = ThuTu, Size = UDim2.new(DoRong, -((8 * (TongSo - 1)) / TongSo), 1, 0),
			BackgroundColor3 = CauHinh.Mau.NenMuc, Text = Ten or "Nut", TextColor3 = CauHinh.Mau.Chu,
			Font = "GothamMedium", TextScaled = true, ZIndex = 2, Parent = KhungChua
		})
		TaoBoGoc(NutBam, 8)
		TaoVien(NutBam, CauHinh.Mau.VienHop)
		TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = NutBam})

		TaoGioiHanChu(NutBam, CauHinh.VanBan.Nho + 2)

		TaoHieuUng(NutBam, NutBam)
		NutBam.MouseButton1Click:Connect(function() if SuKien then task.spawn(SuKien) end end)
	end

	if DuLieu.DanhSachNut then
		for i, v in ipairs(DuLieu.DanhSachNut) do TaoNutNho(v.Ten, v.SuKien, i, #DuLieu.DanhSachNut) end
	else
		local DanhSach = {}
		if DuLieu.Ten_1 then table.insert(DanhSach, {DuLieu.Ten_1, DuLieu.SuKien_1}) end
		if DuLieu.Ten_2 then table.insert(DanhSach, {DuLieu.Ten_2, DuLieu.SuKien_2}) end
		for i, v in ipairs(DanhSach) do TaoNutNho(v[1], v[2], i, #DanhSach) end
	end
end

function ThanhPhan.HopXo(Cha, DuLieu, CauHinh, CapNhat, DeQuy, NguCanh)
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {
		TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})
	})
	local HangNgang = TaoDoiTuong("Frame", {LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = CauHinh.Mau.NenMuc, ZIndex = 2, Parent = KhungChinh})
	TaoBoGoc(HangNgang, 8)
	TaoVien(HangNgang, CauHinh.Mau.VienHop, 0.8, 1)

	local NhanTieuDe = TaoNhan({Text = "  " .. DuLieu.Ten, Size = UDim2.new(0.5, 0, 1, 0), TextColor3 = CauHinh.Mau.Chu, TextXAlignment = "Left", ZIndex = 3, Parent = HangNgang})
	TaoGioiHanChu(NhanTieuDe, CauHinh.VanBan.Nho + 2)

	local HienThi = TaoDoiTuong("TextButton", {
		Size = UDim2.new(0.48, 0, 0, 32), Position = UDim2.new(1, -6, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = CauHinh.Mau.NenHop, BackgroundTransparency = 0.5, Text = DuLieu.HienTai or "...",
		TextColor3 = CauHinh.Mau.Chu, Font = "Gotham", TextScaled = true, ZIndex = 3, Parent = HangNgang
	})
	TaoBoGoc(HienThi, 6)
	TaoVien(HienThi, CauHinh.Mau.VienHop, 0.6)
	TaoGioiHanChu(HienThi, CauHinh.VanBan.Nho + 2)

	TaoHieuUng(HienThi, nil)

	local KhungPhu = TaoDoiTuong("Frame", {LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = KhungChinh})
	local Dem = TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0,6), Parent = KhungPhu})
	TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = "LayoutOrder", Parent = KhungPhu})

	local function LamMoiKhungPhu(CacMuc)
		for _, c in ipairs(KhungPhu:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
		if CacMuc and #CacMuc > 0 then
			Dem.PaddingTop = UDim.new(0, 6)
			Dem.PaddingBottom = UDim.new(0, 6)
			for k, v in ipairs(CacMuc) do DeQuy(KhungPhu, v, CapNhat, k) end
		else
			Dem.PaddingTop = UDim.new(0, 0)
			Dem.PaddingBottom = UDim.new(0, 0)
		end
		CapNhat()
	end

	for _, LuaChon in ipairs(DuLieu.LuaChon) do
		if type(LuaChon) == "table" and LuaChon.Ten == DuLieu.HienTai then LamMoiKhungPhu(LuaChon.CacNutCon) end
	end

	HienThi.MouseButton1Click:Connect(function()
		if NguCanh.DongMenu then NguCanh.DongMenu() end

		local KhungXo = TaoDoiTuong("Frame", {
			Size = UDim2.new(0, HienThi.AbsoluteSize.X, 0, 0), 
			Position = UDim2.fromOffset(HienThi.AbsolutePosition.X, HienThi.AbsolutePosition.Y + HienThi.AbsoluteSize.Y + 6),
			BackgroundColor3 = CauHinh.Mau.NenPhu, 
			ClipsDescendants = true, 
			BorderSizePixel = 0,
			ZIndex = 105, 
			Parent = NguCanh.LopPhu
		})
		TaoBoGoc(KhungXo, 8)
		local VienKhung = TaoVien(KhungXo, CauHinh.Mau.VienHop, 1)

		local CapNhatViTri
		local function Dong()
			if CapNhatViTri then CapNhatViTri:Disconnect() CapNhatViTri = nil end
			NguCanh.DongMenu = nil
			if not KhungXo.Parent then return end
			ChayTween(VienKhung, Tween_Nhanh, {Transparency = 1})
			local T = DichVuTween:Create(KhungXo, Tween_Nhanh, {Size = UDim2.new(0, HienThi.AbsoluteSize.X, 0, 0)})
			T:Play()
			T.Completed:Connect(function() KhungXo:Destroy() end)
		end
		NguCanh.DongMenu = Dong

		CapNhatViTri = DichVuRun.RenderStepped:Connect(function()
			if not HienThi.Parent or not HienThi.Visible then Dong() return end
			KhungXo.Position = UDim2.fromOffset(HienThi.AbsolutePosition.X, HienThi.AbsolutePosition.Y + HienThi.AbsoluteSize.Y + 6)
		end)

		local Cuon = TaoDoiTuong("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1), 
			BackgroundTransparency = 1, 
			ScrollBarThickness = 4,
			BorderSizePixel = 0,
			ScrollBarImageColor3 = CauHinh.Mau.Chu, 
			AutomaticCanvasSize = "Y", 
			CanvasSize = UDim2.new(), 
			ZIndex = 106, 
			Parent = KhungXo
		})
		TaoDoiTuong("UIPadding", {PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4), PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4), Parent = Cuon})
		TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder", Padding = UDim.new(0, 3), Parent = Cuon})

		for i, v in ipairs(DuLieu.LuaChon) do
			local Ten = (type(v) == "table") and v.Ten or v
			local DuocChon = (Ten == DuLieu.HienTai)
			local Muc = TaoDoiTuong("TextButton", {
				LayoutOrder = i, Size = UDim2.new(1, -2, 0, 34), BackgroundColor3 = DuocChon and CauHinh.Mau.ChonPhu or CauHinh.Mau.NenPhu,
				BackgroundTransparency = DuocChon and 0.5 or 1, Text = "  " .. Ten, TextColor3 = DuocChon and CauHinh.Mau.TichBat or CauHinh.Mau.Chu,
				Font = DuocChon and "GothamBold" or "Gotham", TextScaled = true, TextXAlignment = "Left", ZIndex = 107, AutoButtonColor = false, Parent = Cuon
			})
			TaoBoGoc(Muc, 6)
			TaoGioiHanChu(Muc, CauHinh.VanBan.Nho + 2)

			Muc.MouseEnter:Connect(function() if not DuocChon then ChayTween(Muc, Tween_Nhanh, {BackgroundTransparency = 0.4, BackgroundColor3 = CauHinh.Mau.ChonPhu}) end end)
			Muc.MouseLeave:Connect(function() if not DuocChon then ChayTween(Muc, Tween_Nhanh, {BackgroundTransparency = 1}) end end)
			Muc.MouseButton1Click:Connect(function()
				DuLieu.HienTai = Ten
				HienThi.Text = Ten
				LamMoiKhungPhu((type(v) == "table") and v.CacNutCon or nil)
				Dong()
				if DuLieu.SuKien then task.spawn(DuLieu.SuKien, Ten) end
			end)
		end

		ChayTween(VienKhung, Tween_Muot, {Transparency = 0.5})
		ChayTween(KhungXo, Tween_Muot, {Size = UDim2.new(0, HienThi.AbsoluteSize.X, 0, math.min(#DuLieu.LuaChon * 37 + 8, 110))})
	end)
end

function ThanhPhan.Danhsach(Cha, DuLieu, CauHinh, CapNhat, DeQuy)
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {
		TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})
	})
	local DauMuc = TaoDoiTuong("TextButton", {LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = CauHinh.Mau.NenMuc, Text = "", ZIndex = 2, Parent = KhungChinh})
	TaoBoGoc(DauMuc, 8)
	TaoVien(DauMuc, CauHinh.Mau.VienHop, 0.8)

	local NhanTieuDe = TaoNhan({Text = "  " .. DuLieu.Ten, Size = UDim2.new(0.8, 0, 1, 0), TextColor3 = CauHinh.Mau.Chu, TextXAlignment = "Left", ZIndex = 3, Parent = DauMuc})
	TaoGioiHanChu(NhanTieuDe, CauHinh.VanBan.Nho + 2)

	local MuiTen = TaoDoiTuong("ImageLabel", {
		Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
		Image = CauHinh.Asset.MuiTenXuong or "rbxassetid://6031091004", BackgroundTransparency = 1, ZIndex = 3, Parent = DauMuc
	})
	TaoHieuUng(DauMuc, nil)

	local KhungChua = TaoDoiTuong("Frame", {LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Parent = KhungChinh})
	TaoDoiTuong("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), Parent = KhungChua})
	local BoCuc = TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = "LayoutOrder", Parent = KhungChua})

	local function CapNhatKichThuoc()
		if DuLieu.DangMo then
			KhungChua.Size = UDim2.new(1, 0, 0, BoCuc.AbsoluteContentSize.Y + 12)
			CapNhat()
		end
	end

	if DuLieu.Danhsach then for k, v in ipairs(DuLieu.Danhsach) do DeQuy(KhungChua, v, CapNhatKichThuoc, k) end end

	DuLieu.DangMo = false
	DauMuc.MouseButton1Click:Connect(function()
		DuLieu.DangMo = not DuLieu.DangMo
		ChayTween(KhungChua, Tween_Muot, {Size = UDim2.new(1, 0, 0, DuLieu.DangMo and (BoCuc.AbsoluteContentSize.Y + 12) or 0)})
		ChayTween(MuiTen, Tween_Muot, {Rotation = DuLieu.DangMo and 180 or 0})
		task.delay(0.26, CapNhat)
	end)
end

function KhungCuon.Tao(Cuon, DuLieu, CauHinh, LopPhu, DongMenu)
	local CotTrai = TaoDoiTuong("Frame", {Size = UDim2.new(0.485, 0, 0, 0), Position = UDim2.new(0.01, 0, 0, 6), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cuon})
	local BoCucTrai = TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = "LayoutOrder", Parent = CotTrai})

	local CotPhai = TaoDoiTuong("Frame", {Size = UDim2.new(0.485, 0, 0, 0), Position = UDim2.new(0.99, 0, 0, 6), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cuon})
	local BoCucPhai = TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = "LayoutOrder", Parent = CotPhai})

	local NguCanh = {LopPhu = LopPhu, DongMenu = DongMenu}

	local function CapNhatCuon()
		Cuon.CanvasSize = UDim2.new(0, 0, 0, math.max(BoCucTrai.AbsoluteContentSize.Y, BoCucPhai.AbsoluteContentSize.Y) + 25)
	end
	BoCucTrai:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(CapNhatCuon)
	BoCucPhai:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(CapNhatCuon)

	local TaoMuc
	TaoMuc = function(Cha, DuLieuMuc, CapNhatMuc, ThuTu)
		DuLieuMuc.ThuTu = ThuTu or 0
		if ThanhPhan[DuLieuMuc.Loai] then ThanhPhan[DuLieuMuc.Loai](Cha, DuLieuMuc, CauHinh, function() if CapNhatMuc then CapNhatMuc() end end, TaoMuc, NguCanh) end
	end

	local function TaoKhoi(DuLieuKhoi, Cot)
		local Khoi = TaoDoiTuong("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = CauHinh.Mau.NenKhoi, ClipsDescendants = true, ZIndex = 1, Parent = Cot})
		TaoBoGoc(Khoi, 10)
		TaoVien(Khoi, CauHinh.Mau.VienHop)

		local DauMuc = TaoDoiTuong("TextButton", {Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Text = "", ZIndex = 2, Parent = Khoi})
		local DuongKe = TaoDoiTuong("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = CauHinh.Mau.VienHop, BorderSizePixel = 0, ZIndex = 2, Parent = DauMuc})

		local TieuDeKhoi = TaoNhan({Text = DuLieuKhoi.TieuDe, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 12, 0, 0), TextColor3 = CauHinh.Mau.Chu, Font = "GothamBold", TextScaled = true, TextXAlignment = "Left", ZIndex = 3, Parent = DauMuc})

		TaoGioiHanChu(TieuDeKhoi, CauHinh.VanBan.TieuDe + 2)

		local MuiTen = TaoDoiTuong("ImageLabel", {Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -30, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Image = CauHinh.Asset.MuiTenXuong, BackgroundTransparency = 1, ZIndex = 3, Parent = DauMuc})

		local ThanKhoi = TaoDoiTuong("Frame", {Position = UDim2.new(0, 0, 0, 65), Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Parent = Khoi})
		local BoCucThan = TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = "LayoutOrder", Parent = ThanKhoi})
		TaoDoiTuong("UIPadding", {PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = ThanKhoi})

		local DangMoRong = true
		local function BatTat()
			local ChieuCaoNoiDung = BoCucThan.AbsoluteContentSize.Y
			local ChieuCaoMucTieu = DangMoRong and (50 + ChieuCaoNoiDung + 18) or 50
			ChayTween(Khoi, Tween_Muot, {Size = UDim2.new(1, 0, 0, ChieuCaoMucTieu)})
			ChayTween(MuiTen, Tween_Muot, {Rotation = DangMoRong and 180 or 0})
			DuongKe.Visible = DangMoRong
			CapNhatCuon()
			task.delay(0.26, CapNhatCuon)
		end

		if DuLieuKhoi.ChucNang then
			for k, f in ipairs(DuLieuKhoi.ChucNang) do TaoMuc(ThanKhoi, f, function() if DangMoRong then BatTat() end end, k) end
		end

		DauMuc.MouseButton1Click:Connect(function() DangMoRong = not DangMoRong BatTat() end)
		task.delay(0.1, BatTat)
	end

	for i, v in ipairs(DuLieu) do TaoKhoi(v, (i % 2 ~= 0) and CotTrai or CotPhai) end
end

return KhungCuon
