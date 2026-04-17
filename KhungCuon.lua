local DichVuTween = game:GetService("TweenService")
local DichVuRun = game:GetService("RunService")
local DichVuInput = game:GetService("UserInputService")
local DichVuText = game:GetService("TextService")

local TweenNhanh = TweenInfo.new(0.08, Enum.EasingStyle.Sine)
local TweenMuot = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local TweenNay = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local TWEEN_BGDOWN = {BackgroundTransparency = 0.2}
local TWEEN_BGUP = {BackgroundTransparency = 0}

local KhungCuon = {}
local ThanhPhan = {}

local function ChayTween(DoiTuong, ThongTin, ThuocTinh)
	if not DoiTuong then return end
	DichVuTween:Create(DoiTuong, ThongTin, ThuocTinh):Play()
end

local function TaoDoiTuong(Loai, ThuocTinh, DoiTuongCon)
	local DoiTuong = Instance.new(Loai)
	local thuocTinhParent = ThuocTinh and ThuocTinh.Parent or nil

	if ThuocTinh then
		ThuocTinh.Parent = nil
		for Khoa, GiaTri in pairs(ThuocTinh) do
			DoiTuong[Khoa] = GiaTri
		end
	end

	if DoiTuongCon then
		for _, Con in ipairs(DoiTuongCon) do Con.Parent = DoiTuong end
	end

	if thuocTinhParent then 
		DoiTuong.Parent = thuocTinhParent 
	end

	return DoiTuong
end

local function TaoBoGoc(Cha, BanKinh)
	return TaoDoiTuong("UICorner", {CornerRadius = UDim.new(0, BanKinh), Parent = Cha})
end

local function TaoVien(Cha, Mau, DoTrongSuot, DoDay)
	return TaoDoiTuong("UIStroke", {Color = Mau, Transparency = DoTrongSuot or 0, Thickness = DoDay or 0.8, ApplyStrokeMode = "Border", Parent = Cha})
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

	local propsLuot = {BackgroundColor3 = MauLuot}
	local propsGoc = {BackgroundColor3 = MauGoc}

	NutBam.MouseEnter:Connect(function() ChayTween(NutBam, TweenMuot, propsLuot) end)
	NutBam.MouseLeave:Connect(function() ChayTween(NutBam, TweenMuot, propsGoc) end)
	NutBam.MouseButton1Down:Connect(function() ChayTween(NutBam, TweenNhanh, TWEEN_BGDOWN) end)
	NutBam.MouseButton1Up:Connect(function() ChayTween(NutBam, TweenNhanh, TWEEN_BGUP) end)
end

function ThanhPhan.Otich(Cha, DuLieu, CauHinh, CapNhat, DeQuy)
	local Mau = CauHinh.Mau
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {
		TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})
	})
	local HangNgang = TaoDoiTuong("Frame", {LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, ZIndex = 2, Parent = KhungChinh})
	if DuLieu.LoaiNutCon == "CungHang" then
		TaoDoiTuong("UIListLayout", {FillDirection = "Horizontal", SortOrder = "LayoutOrder", Padding = UDim.new(0, 4), Parent = HangNgang})
	end

	local NutTich = TaoDoiTuong("TextButton", {
		Name = "NutTich", LayoutOrder = 1, Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc, Text = "", AutoButtonColor = false, ZIndex = 2, Parent = HangNgang
	})
	TaoBoGoc(NutTich, 8)
	TaoVien(NutTich, Mau.VienNeon, 0.6)

	local DoDaiChuoi = utf8.len(DuLieu.Ten) or string.len(DuLieu.Ten)
	if DoDaiChuoi > 10 then
		local VungCuonChu = TaoDoiTuong("ScrollingFrame", {
			Size = UDim2.new(0.72, -5, 1, 0), Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X,
			AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(0,0,0,0), ClipsDescendants = true, ZIndex = 3, Parent = NutTich
		})
		local NhanTich = TaoNhan({
			Text = "  " .. DuLieu.Ten, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
			TextColor3 = Mau.Chu, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = VungCuonChu
		})
		NhanTich.TextScaled = false
		NhanTich.TextWrapped = false
		NhanTich.TextSize = CauHinh.VanBan.Nho + 2
	else
		local NhanTich = TaoNhan({
			Text = "  " .. DuLieu.Ten, Size = UDim2.new(0.72, -5, 1, 0),
			TextColor3 = Mau.Chu, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 3, Parent = NutTich
		})
		TaoGioiHanChu(NhanTich, CauHinh.VanBan.Nho + 2)
	end

	local HopVuong = TaoDoiTuong("Frame", {
		Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Mau.NenHop, ZIndex = 3, Parent = NutTich
	})
	TaoBoGoc(HopVuong, 6)
	TaoVien(HopVuong, Mau.VienNeon, 0.7)

	DuLieu.TrangThai = (DuLieu.HienTai == "Bat") or DuLieu.TrangThai or false
	local DauTich = TaoDoiTuong("Frame", {
		Size = UDim2.new(1, -8, 1, -8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Mau.TichBat, Visible = DuLieu.TrangThai, ZIndex = 4, Parent = HopVuong
	})
	TaoBoGoc(DauTich, 4)

	local NutPhu = nil
	local CapNhatNutPhu = nil
	local ChiSoPhu = 1
	local KhungChuaPhu = TaoDoiTuong("Frame", {LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = KhungChinh})
	local Dem = TaoDoiTuong("UIPadding", {Parent = KhungChuaPhu})
	TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = "LayoutOrder", Parent = KhungChuaPhu})

	if DuLieu.LoaiNutCon == "CungHang" then
		NutPhu = TaoDoiTuong("TextButton", {
			LayoutOrder = 2, Size = UDim2.new(0.3, 0, 1, 0), BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc,
			Text = "...", TextColor3 = Mau.Chu, Font = "GothamMedium", TextScaled = true, Visible = false, ZIndex = 2, Parent = HangNgang
		})
		TaoBoGoc(NutPhu, 8)
		TaoVien(NutPhu, Mau.VienNeon, 0.7)
		TaoGioiHanChu(NutPhu, CauHinh.VanBan.Nho + 2)
		TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4), Parent = NutPhu})
		TaoHieuUng(NutPhu, nil)
		CapNhatNutPhu = function() NutPhu.Text = (DuLieu.CacNutCon and DuLieu.CacNutCon[ChiSoPhu]) and DuLieu.CacNutCon[ChiSoPhu].Ten or "Trong" end
		if DuLieu.CacNutCon then CapNhatNutPhu() end
		NutPhu.MouseButton1Click:Connect(function()
			if DuLieu.CacNutCon and DuLieu.CacNutCon[ChiSoPhu] then
				if type(DuLieu.CacNutCon[ChiSoPhu].SuKien) == "function" then
					task.spawn(DuLieu.CacNutCon[ChiSoPhu].SuKien)
				end
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
				ChayTween(NutTich, TweenMuot, {Size = UDim2.new(0.68, -4, 1, 0)})
				NutPhu.Visible = true
				ChayTween(NutPhu, TweenMuot, {BackgroundTransparency = 0})
			else
				ChayTween(NutTich, TweenMuot, {Size = UDim2.new(1, 0, 1, 0)})
				NutPhu.Visible = false
			end
			return 
		end
		for _, PhanTu in ipairs(KhungChuaPhu:GetChildren()) do if PhanTu:IsA("GuiObject") then PhanTu:Destroy() end end
		if DuLieu.TrangThai and DuLieu.CacNutCon and #DuLieu.CacNutCon > 0 then
			Dem.PaddingTop = UDim.new(0, 6)
			Dem.PaddingBottom = UDim.new(0, 6)
			for ThuTuNho, DuLieuNho in ipairs(DuLieu.CacNutCon) do 
				DuLieuNho.MauNenRieng = Mau.NenMuc
				DeQuy(KhungChuaPhu, DuLieuNho, CapNhat, ThuTuNho) 
			end
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
			ChayTween(DauTich, TweenNay, {Size = UDim2.new(1, -8, 1, -8)})
		end
		LamMoi()
		if type(DuLieu.SuKien) == "function" then task.spawn(DuLieu.SuKien, DuLieu.TrangThai) end
	end)
end

function ThanhPhan.Nut(Cha, DuLieu, CauHinh, CapNhat, DeQuy)
	local Mau = CauHinh.Mau
	local NutBam = TaoDoiTuong("TextButton", {
		LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc,
		Text = DuLieu.Ten, TextColor3 = Mau.Chu, Font = "GothamMedium", TextScaled = true, ZIndex = 2, Parent = Cha
	})
	TaoBoGoc(NutBam, 8)
	TaoVien(NutBam, Mau.VienNeon, 0.6)
	TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = NutBam})
	TaoGioiHanChu(NutBam, CauHinh.VanBan.Nut + 2)
	TaoHieuUng(NutBam, NutBam)

	local DuLieuHienTai = DuLieu
	local ChiSoVongLap = 0

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
					if DuLieuMoi.Mau then ChayTween(NutBam, TweenMuot, {BackgroundColor3 = DuLieuMoi.Mau}) end
					local DanhSachCu = DuLieuHienTai.DanhSachThay
					DuLieuHienTai = DuLieuMoi
					if ChiSoVongLap > 0 then 
						DuLieuHienTai.DanhSachThay = DanhSachCu 
						DuLieuHienTai.SauBam = "Thay" 
					end
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
	local Mau = CauHinh.Mau
	local KhungChua = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Parent = Cha}, {
		TaoDoiTuong("UIListLayout", {FillDirection = "Horizontal", SortOrder = "LayoutOrder", Padding = UDim.new(0, 8)})
	})

	local function TaoNutNho(TenNut, SuKienNut, ThuTuNut, TongSoNut)
		local DoRong = 1 / (TongSoNut or 1)
		local NutBam = TaoDoiTuong("TextButton", {
			LayoutOrder = ThuTuNut, Size = UDim2.new(DoRong, -((8 * (TongSoNut - 1)) / TongSoNut), 1, 0),
			BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc, Text = TenNut or "Nut", TextColor3 = Mau.Chu,
			Font = "GothamMedium", TextScaled = true, ZIndex = 2, Parent = KhungChua
		})
		TaoBoGoc(NutBam, 8)
		TaoVien(NutBam, Mau.VienNeon, 0.6)
		TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = NutBam})
		TaoGioiHanChu(NutBam, CauHinh.VanBan.Nho + 2)
		TaoHieuUng(NutBam, NutBam)
		NutBam.MouseButton1Click:Connect(function() if type(SuKienNut) == "function" then task.spawn(SuKienNut) end end)
	end

	if DuLieu.DanhSachNut then
		for ViTriNut, DuLieuNho in ipairs(DuLieu.DanhSachNut) do TaoNutNho(DuLieuNho.Ten, DuLieuNho.SuKien, ViTriNut, #DuLieu.DanhSachNut) end
	else
		local DanhSachThayThe = {}
		if DuLieu.Ten1 then table.insert(DanhSachThayThe, {DuLieu.Ten1, DuLieu.SuKien1}) end
		if DuLieu.Ten2 then table.insert(DanhSachThayThe, {DuLieu.Ten2, DuLieu.SuKien2}) end
		for ViTriThayThe, DuLieuThayThe in ipairs(DanhSachThayThe) do TaoNutNho(DuLieuThayThe[1], DuLieuThayThe[2], ViTriThayThe, #DanhSachThayThe) end
	end
end

function ThanhPhan.HopXo(Cha, DuLieu, CauHinh, CapNhat, DeQuy, NguCanh)
	local Mau = CauHinh.Mau
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {
		TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})
	})
	local HangNgang = TaoDoiTuong("Frame", {LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc, ZIndex = 2, Parent = KhungChinh})
	TaoBoGoc(HangNgang, 8)
	TaoVien(HangNgang, Mau.VienNeon, 0.5)

	local NhanTieuDe = TaoNhan({Text = "  " .. DuLieu.Ten, Size = UDim2.new(0.5, 0, 1, 0), TextColor3 = Mau.Chu, TextXAlignment = "Left", ZIndex = 3, Parent = HangNgang})
	TaoGioiHanChu(NhanTieuDe, CauHinh.VanBan.Nho + 2)

	local HienThi = TaoDoiTuong("TextButton", {
		Size = UDim2.new(0.48, 0, 0, 32), Position = UDim2.new(1, -6, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.5, Text = DuLieu.HienTai or "...",
		TextColor3 = Mau.Chu, Font = "Gotham", TextScaled = true, ZIndex = 3, Parent = HangNgang
	})
	TaoBoGoc(HienThi, 6)
	TaoVien(HienThi, Mau.VienNeon, 0.8)
	TaoGioiHanChu(HienThi, CauHinh.VanBan.Nho + 2)
	TaoHieuUng(HienThi, nil)

	local KhungPhu = TaoDoiTuong("Frame", {LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = KhungChinh})
	local Dem = TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0,6), Parent = KhungPhu})
	TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = "LayoutOrder", Parent = KhungPhu})

	local function LamMoiKhungPhu(CacMuc)
		for _, PhanTuCu in ipairs(KhungPhu:GetChildren()) do if PhanTuCu:IsA("GuiObject") then PhanTuCu:Destroy() end end
		if CacMuc and #CacMuc > 0 then
			Dem.PaddingTop = UDim.new(0, 6)
			Dem.PaddingBottom = UDim.new(0, 6)
			for ViTriMuc, GiaTriMuc in ipairs(CacMuc) do DeQuy(KhungPhu, GiaTriMuc, CapNhat, ViTriMuc) end
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
			BackgroundColor3 = Mau.NenPhu, ClipsDescendants = true, BorderSizePixel = 0, ZIndex = 105, Parent = NguCanh.LopPhu
		})
		TaoBoGoc(KhungXo, 8)
		local VienKhung = TaoVien(KhungXo, Mau.VienNeon, 0.6)

		local CapNhatViTri = nil
		local function DongXoXuong()
			if CapNhatViTri then CapNhatViTri:Disconnect() CapNhatViTri = nil end
			NguCanh.DongMenu = nil
			if not KhungXo.Parent then return end
			ChayTween(VienKhung, TweenNhanh, {Transparency = 1})
			local HieuUngDong = DichVuTween:Create(KhungXo, TweenNhanh, {Size = UDim2.new(0, HienThi.AbsoluteSize.X, 0, 0)})
			HieuUngDong:Play()
			HieuUngDong.Completed:Connect(function() KhungXo:Destroy() end)
		end

		NguCanh.DongMenu = DongXoXuong

		CapNhatViTri = DichVuRun.RenderStepped:Connect(function()
			if not HienThi.Parent or not HienThi.Visible then DongXoXuong() return end
			KhungXo.Position = UDim2.fromOffset(HienThi.AbsolutePosition.X, HienThi.AbsolutePosition.Y + HienThi.AbsoluteSize.Y + 6)
		end)

		local Cuon = TaoDoiTuong("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 4, BorderSizePixel = 0,
			ScrollBarImageColor3 = Mau.Chu, AutomaticCanvasSize = "Y", CanvasSize = UDim2.new(), ZIndex = 106, Parent = KhungXo
		})
		TaoDoiTuong("UIPadding", {PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4), PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4), Parent = Cuon})
		TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder", Padding = UDim.new(0, 3), Parent = Cuon})

		for ViTriLuaChon, DuLieuLuaChon in ipairs(DuLieu.LuaChon) do
			local TenLuaChon = (type(DuLieuLuaChon) == "table") and DuLieuLuaChon.Ten or DuLieuLuaChon
			local DuocChon = (TenLuaChon == DuLieu.HienTai)
			local bgLuaChon = DuocChon and Mau.ChonPhu or Mau.NenPhu

			local MucLuaChon = TaoDoiTuong("TextButton", {
				LayoutOrder = ViTriLuaChon, Size = UDim2.new(1, -2, 0, 34), BackgroundColor3 = bgLuaChon,
				BackgroundTransparency = DuocChon and 0.5 or 1, Text = "  " .. TenLuaChon, TextColor3 = DuocChon and Mau.TichBat or Mau.Chu,
				Font = DuocChon and "GothamBold" or "Gotham", TextScaled = true, TextXAlignment = "Left", ZIndex = 107, AutoButtonColor = false, Parent = Cuon
			})
			TaoBoGoc(MucLuaChon, 6)
			TaoGioiHanChu(MucLuaChon, CauHinh.VanBan.Nho + 2)

			local propsHover = {BackgroundTransparency = 0.4, BackgroundColor3 = Mau.ChonPhu}
			local propsLeave = {BackgroundTransparency = 1}

			MucLuaChon.MouseEnter:Connect(function() if not DuocChon then ChayTween(MucLuaChon, TweenNhanh, propsHover) end end)
			MucLuaChon.MouseLeave:Connect(function() if not DuocChon then ChayTween(MucLuaChon, TweenNhanh, propsLeave) end end)

			MucLuaChon.MouseButton1Click:Connect(function()
				DuLieu.HienTai = TenLuaChon
				HienThi.Text = TenLuaChon
				LamMoiKhungPhu((type(DuLieuLuaChon) == "table") and DuLieuLuaChon.CacNutCon or nil)
				DongXoXuong()
				if type(DuLieu.SuKien) == "function" then task.spawn(DuLieu.SuKien, TenLuaChon) end
			end)
		end

		ChayTween(VienKhung, TweenMuot, {Transparency = 0.5})
		ChayTween(KhungXo, TweenMuot, {Size = UDim2.new(0, HienThi.AbsoluteSize.X, 0, math.min(#DuLieu.LuaChon * 37 + 8, 110))})
	end)
end

function ThanhPhan.Danhsach(Cha, DuLieu, CauHinh, CapNhat, DeQuy)
	local Mau = CauHinh.Mau
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {
		TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})
	})
	local DauMuc = TaoDoiTuong("TextButton", {LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = DuLieu.DangMo and Mau.NenDanhSachMo or Mau.NenMuc, Text = "", ZIndex = 2, Parent = KhungChinh})
	TaoBoGoc(DauMuc, 8)
	TaoVien(DauMuc, Mau.VienNeon, 0.6)

	local NhanTieuDe = TaoNhan({Text = "  " .. DuLieu.Ten, Size = UDim2.new(0.8, 0, 1, 0), TextColor3 = Mau.Chu, TextXAlignment = "Left", ZIndex = 3, Parent = DauMuc})
	TaoGioiHanChu(NhanTieuDe, CauHinh.VanBan.Nho + 2)

	local MuiTen = TaoDoiTuong("ImageLabel", {
		Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
		Image = CauHinh.Asset.MuiTenXuong or "rbxassetid://6031091004", Rotation = DuLieu.DangMo and 180 or 0, BackgroundTransparency = 1, ZIndex = 3, Parent = DauMuc
	})

	local KhungChua = TaoDoiTuong("Frame", {
		LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.4, ClipsDescendants = true, Parent = KhungChinh
	})
	TaoBoGoc(KhungChua, 6)
	TaoVien(KhungChua, Mau.VienNeon, 0.9)
	TaoDoiTuong("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = KhungChua})

	local BoCuc = TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = "LayoutOrder", Parent = KhungChua})
	BoCuc:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if DuLieu.DangMo then
			KhungChua.Size = UDim2.new(1, 0, 0, BoCuc.AbsoluteContentSize.Y + 16)
			CapNhat()
		end
	end)

	if DuLieu.Danhsach then
		local TongSo = #DuLieu.Danhsach
		for ViTriDanhSach, DuLieuDanhSach in ipairs(DuLieu.Danhsach) do
			DuLieuDanhSach.MauNenRieng = Mau.NenMuc
			DeQuy(KhungChua, DuLieuDanhSach, function() CapNhat() end, ViTriDanhSach * 2)
			if ViTriDanhSach < TongSo then
				local KhungBocLine = TaoDoiTuong("Frame", {LayoutOrder = ViTriDanhSach * 2 + 1, Size = UDim2.new(1, 0, 0, 1), BackgroundTransparency = 1, Parent = KhungChua})
				TaoDoiTuong("Frame", {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, -3), BackgroundColor3 = Mau.VienNeon, BackgroundTransparency = 0.6, BorderSizePixel = 0, Parent = KhungBocLine})
			end
		end
	end

	if DuLieu.DangMo then KhungChua.Size = UDim2.new(1, 0, 0, BoCuc.AbsoluteContentSize.Y + 16) end

	DauMuc.MouseButton1Click:Connect(function()
		DuLieu.DangMo = not DuLieu.DangMo
		ChayTween(KhungChua, TweenMuot, {Size = UDim2.new(1, 0, 0, DuLieu.DangMo and (BoCuc.AbsoluteContentSize.Y + 16) or 0)})
		ChayTween(MuiTen, TweenMuot, {Rotation = DuLieu.DangMo and 180 or 0})
		ChayTween(DauMuc, TweenMuot, {BackgroundColor3 = DuLieu.DangMo and Mau.NenDanhSachMo or Mau.NenMuc})
		task.delay(0.26, CapNhat)
	end)
end

function ThanhPhan.Odien(Cha, DuLieu, CauHinh, CapNhat, DeQuy)
	local Mau = CauHinh.Mau
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {
		TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})
	})
	local HangNgang = TaoDoiTuong("Frame", {LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc, ZIndex = 2, Parent = KhungChinh})
	TaoBoGoc(HangNgang, 8)
	TaoVien(HangNgang, Mau.VienNeon, 0.6)

	local NhanTieuDe = TaoNhan({Text = "  " .. DuLieu.Ten, Size = UDim2.new(0.6, 0, 1, 0), TextColor3 = Mau.Chu, TextXAlignment = "Left", ZIndex = 3, Parent = HangNgang})
	TaoGioiHanChu(NhanTieuDe, CauHinh.VanBan.Nho + 2)

	local ONhap = TaoDoiTuong("TextBox", {
		Size = UDim2.new(0.35, 0, 0, 32), Position = UDim2.new(1, -6, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.5, Text = tostring(DuLieu.HienTai or ""),
		PlaceholderText = DuLieu.GoiY or "", TextColor3 = Mau.Chu, Font = "Gotham", TextScaled = true, ZIndex = 3, Parent = HangNgang
	})
	TaoBoGoc(ONhap, 6)
	TaoVien(ONhap, Mau.VienNeon, 0.7)
	TaoGioiHanChu(ONhap, CauHinh.VanBan.Nho + 2)

	ONhap.FocusLost:Connect(function()
		DuLieu.HienTai = ONhap.Text
		if type(DuLieu.SuKien) == "function" then task.spawn(DuLieu.SuKien, ONhap.Text) end
	end)
end

function ThanhPhan.PhimNong(Cha, DuLieu, CauHinh, CapNhat, DeQuy)
	local Mau = CauHinh.Mau
	local KhungChinh = TaoDoiTuong("Frame", {LayoutOrder = DuLieu.ThuTu, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = Cha}, {
		TaoDoiTuong("UIListLayout", {SortOrder = "LayoutOrder"})
	})
	local HangNgang = TaoDoiTuong("Frame", {LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = DuLieu.MauNenRieng or Mau.NenMuc, ZIndex = 2, Parent = KhungChinh})
	TaoBoGoc(HangNgang, 8)
	TaoVien(HangNgang, Mau.VienNeon, 0.6)

	local NhanTieuDe = TaoNhan({Text = "  " .. DuLieu.Ten, Size = UDim2.new(0.6, 0, 1, 0), TextColor3 = Mau.Chu, TextXAlignment = "Left", ZIndex = 3, Parent = HangNgang})
	TaoGioiHanChu(NhanTieuDe, CauHinh.VanBan.Nho + 2)

	local NutPhim = TaoDoiTuong("TextButton", {
		Size = UDim2.new(0.35, 0, 0, 32), Position = UDim2.new(1, -6, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.5, Text = tostring(DuLieu.HienTai or "None"),
		TextColor3 = Mau.Chu, Font = "GothamBold", TextScaled = true, ZIndex = 3, Parent = HangNgang
	})
	TaoBoGoc(NutPhim, 6)
	TaoVien(NutPhim, Mau.VienNeon, 0.7)
	TaoGioiHanChu(NutPhim, CauHinh.VanBan.Nho + 2)
	TaoHieuUng(NutPhim, nil)

	local DangCho = false

	NutPhim.MouseButton1Click:Connect(function()
		if not DichVuInput.KeyboardEnabled or DangCho then return end

		DangCho = true
		shared.HxDangChinhPhim = true 
		NutPhim.Text = "..."

		if DuLieu.KetNoiInput then
			DuLieu.KetNoiInput:Disconnect()
			DuLieu.KetNoiInput = nil
		end

		DuLieu.KetNoiInput = DichVuInput.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				if DuLieu.KetNoiInput then
					DuLieu.KetNoiInput:Disconnect()
					DuLieu.KetNoiInput = nil
				end

				local TenPhim = Input.KeyCode.Name
				DuLieu.HienTai = TenPhim
				NutPhim.Text = TenPhim

				if type(DuLieu.SuKien) == "function" then task.spawn(DuLieu.SuKien, Input.KeyCode) end

				task.wait(0.1) 
				shared.HxDangChinhPhim = false
				DangCho = false
			end
		end)
	end)
end

function KhungCuon.Tao(Cuon, DuLieu, CauHinh, LopPhu, DongMenu)
	local Mau = CauHinh.Mau
	local NguCanh = {LopPhu = LopPhu, DongMenu = DongMenu}

	if not CauHinh.DangTab then
		Cuon.ScrollingDirection = Enum.ScrollingDirection.Y
	end

	local TaoMuc = nil
	TaoMuc = function(Cha, DuLieuMuc, CapNhatMuc, ThuTuDau)
		DuLieuMuc.ThuTu = ThuTuDau or 0
		if ThanhPhan[DuLieuMuc.Loai] then ThanhPhan[DuLieuMuc.Loai](Cha, DuLieuMuc, CauHinh, function() if CapNhatMuc then CapNhatMuc() end end, TaoMuc, NguCanh) end
	end

	local function TaoBoCucCacKhoi(VungCuon, DanhSachKhoiTao)
		local SoCot = CauHinh.SoCot or 2
		local CotTrai, CotPhai, BoCucTrai, BoCucPhai

		if SoCot == 2 then
			CotTrai = TaoDoiTuong("Frame", {Size = UDim2.new(0.485, 0, 0, 0), Position = UDim2.new(0.01, 0, 0, 6), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = VungCuon})
			BoCucTrai = TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = "LayoutOrder", Parent = CotTrai})
			CotPhai = TaoDoiTuong("Frame", {Size = UDim2.new(0.485, 0, 0, 0), Position = UDim2.new(0.99, 0, 0, 6), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = VungCuon})
			BoCucPhai = TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = "LayoutOrder", Parent = CotPhai})
		else
			CotTrai = TaoDoiTuong("Frame", {Size = UDim2.new(0.96, 0, 0, 0), Position = UDim2.new(0.02, 0, 0, 6), BackgroundTransparency = 1, AutomaticSize = "Y", Parent = VungCuon})
			BoCucTrai = TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = "LayoutOrder", Parent = CotTrai})
		end

		local function CapNhatCuon()
			if SoCot == 2 then
				VungCuon.CanvasSize = UDim2.new(0, 0, 0, math.max(BoCucTrai.AbsoluteContentSize.Y, BoCucPhai.AbsoluteContentSize.Y) + 25)
			else
				VungCuon.CanvasSize = UDim2.new(0, 0, 0, BoCucTrai.AbsoluteContentSize.Y + 25)
			end
		end

		BoCucTrai:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(CapNhatCuon)
		if SoCot == 2 then BoCucPhai:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(CapNhatCuon) end

		local function TaoKhoi(DuLieuKhoi, CotBoTri)
			local Khoi = TaoDoiTuong("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Mau.NenKhoi, ClipsDescendants = true, ZIndex = 1, Parent = CotBoTri})
			TaoBoGoc(Khoi, 10)
			TaoVien(Khoi, Mau.VienNeon, 0.6)

			local DauMuc = TaoDoiTuong("TextButton", {Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Text = "", ZIndex = 2, Parent = Khoi})
			local DuongKe = TaoDoiTuong("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Mau.VienNeon, BackgroundTransparency = 0.8, BorderSizePixel = 0, ZIndex = 2, Parent = DauMuc})

			local TieuDeKhoi = TaoNhan({Text = DuLieuKhoi.TieuDe, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 12, 0, 0), TextColor3 = Mau.Chu, Font = "GothamBold", TextScaled = true, TextXAlignment = "Left", ZIndex = 3, Parent = DauMuc})
			TaoGioiHanChu(TieuDeKhoi, CauHinh.VanBan.TieuDe + 2)

			local MuiTen = TaoDoiTuong("ImageLabel", {Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -30, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Image = CauHinh.Asset.MuiTenXuong, BackgroundTransparency = 1, ZIndex = 3, Parent = DauMuc})

			local ThanKhoi = TaoDoiTuong("Frame", {Position = UDim2.new(0, 0, 0, 65), Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Parent = Khoi})
			local BoCucThan = TaoDoiTuong("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = "LayoutOrder", Parent = ThanKhoi})
			TaoDoiTuong("UIPadding", {PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = ThanKhoi})

			local DangMoRong = true
			local tweenSpeed = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			local function BatTatThuGon()
				local ChieuCaoNoiDung = BoCucThan.AbsoluteContentSize.Y
				local ChieuCaoMucTieu = DangMoRong and (50 + ChieuCaoNoiDung + 18) or 50
				ChayTween(Khoi, tweenSpeed, {Size = UDim2.new(1, 0, 0, ChieuCaoMucTieu)})
				ChayTween(MuiTen, tweenSpeed, {Rotation = DangMoRong and 180 or 0})
				DuongKe.Visible = DangMoRong
				task.delay(0.26, CapNhatCuon)
			end

			BoCucThan:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if DangMoRong then
					Khoi.Size = UDim2.new(1, 0, 0, 50 + BoCucThan.AbsoluteContentSize.Y + 18)
					CapNhatCuon()
				end
			end)

			if DuLieuKhoi.ChucNang then
				for ViTriChucNang, DuLieuChucNang in ipairs(DuLieuKhoi.ChucNang) do TaoMuc(ThanKhoi, DuLieuChucNang, function() if DangMoRong then BatTatThuGon() end end, ViTriChucNang) end
			end
			DauMuc.MouseButton1Click:Connect(function() DangMoRong = not DangMoRong BatTatThuGon() end)
			task.delay(0.1, BatTatThuGon)
		end

		for ViTriTao, DuLieuKhoiTao in ipairs(DanhSachKhoiTao) do 
			if SoCot == 2 then TaoKhoi(DuLieuKhoiTao, (ViTriTao % 2 ~= 0) and CotTrai or CotPhai) else TaoKhoi(DuLieuKhoiTao, CotTrai) end
		end
	end

	if CauHinh.DangTab then
		Cuon.ScrollingEnabled = false
		Cuon.ScrollBarThickness = 0
		Cuon.CanvasSize = UDim2.new(0, 0, 0, 0)

		local ThanhTab = TaoDoiTuong("ScrollingFrame", {
			Size = UDim2.new(0.96, 0, 0, 30),
			Position = UDim2.new(0.02, 0, 0, 1),
			BackgroundTransparency = 1,
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.X,
			AutomaticCanvasSize = Enum.AutomaticSize.X,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ClipsDescendants = true,
			Parent = Cuon
		})

		local PaddingThanhTab = TaoDoiTuong("UIPadding", { Parent = ThanhTab })
		TaoDoiTuong("UIListLayout", {
			FillDirection = "Horizontal", SortOrder = "LayoutOrder", Padding = UDim.new(0, 6), 
			VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Left, Parent = ThanhTab
		})

		local KhungNoiDungTab = TaoDoiTuong("Frame", {
			Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 40),
			BackgroundTransparency = 1, ClipsDescendants = true, Parent = Cuon
		})

		local DanhSachTab = {}
		local TabMacDinhIndex = 1

		if CauHinh.TabMacDinh then
			for i, tab in ipairs(DuLieu) do
				if tab.TenTab == CauHinh.TabMacDinh or i == CauHinh.TabMacDinh then
					TabMacDinhIndex = i
					break
				end
			end
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
				task.wait(0.05)
				if not ThanhTab.Parent or not NutTabMucTieu.Parent then return end
				local ToaDoXCanvas = NutTabMucTieu.AbsolutePosition.X - ThanhTab.AbsolutePosition.X + ThanhTab.CanvasPosition.X
				local DiemGiuaNut = ToaDoXCanvas + (NutTabMucTieu.AbsoluteSize.X / 2)
				local ViTriCuonMoi = DiemGiuaNut - (ThanhTab.AbsoluteSize.X / 2)
				local MaxCuon = math.max(0, ThanhTab.AbsoluteCanvasSize.X - ThanhTab.AbsoluteSize.X)

				ViTriCuonMoi = math.clamp(ViTriCuonMoi, 0, MaxCuon)
				DichVuTween:Create(ThanhTab, TweenMuot, {CanvasPosition = Vector2.new(ViTriCuonMoi, 0)}):Play()
			end)
		end

		local CurrentTabIndex = -1

		local function ChuyenTab(IndexCuaTab, InitialLoad)
			local Huong = (IndexCuaTab > CurrentTabIndex) and 1 or -1
			if InitialLoad or CurrentTabIndex == -1 then Huong = 0 end 
			CurrentTabIndex = IndexCuaTab

			local tweenTabChon = {BackgroundTransparency = 0.2, BackgroundColor3 = Mau.NenMuc, TextColor3 = Mau.TichBat, TextTransparency = 0}
			local tweenTabKhong = {BackgroundTransparency = 0.8, BackgroundColor3 = Mau.NenHop, TextColor3 = Mau.Chu, TextTransparency = 0.4}

			for _, ThongTin in ipairs(DanhSachTab) do
				if ThongTin.Index == IndexCuaTab then
					ThongTin.VungCuon.Visible = true

					if Huong ~= 0 then
						ThongTin.VungCuon.Position = UDim2.new(0, 40 * Huong, 0, 0)
						DichVuTween:Create(ThongTin.VungCuon, TweenMuot, {Position = UDim2.new(0, 0, 0, 0)}):Play()
					else
						ThongTin.VungCuon.Position = UDim2.new(0, 0, 0, 0)
					end

					ThongTin.Nut.Font = Enum.Font.GothamBold

					if InitialLoad then
						for k, v in pairs(tweenTabChon) do ThongTin.Nut[k] = v end
						ThongTin.ThanhLine.BackgroundTransparency = 0
						ThongTin.ThanhLine.Size = UDim2.new(0.8, 0, 0, 2)
						ThongTin.ThanhLine.BackgroundColor3 = Mau.TichBat
					else
						ChayTween(ThongTin.Nut, TweenNhanh, tweenTabChon)
						ChayTween(ThongTin.ThanhLine, TweenNhanh, {BackgroundTransparency = 0, Size = UDim2.new(0.8, 0, 0, 2), BackgroundColor3 = Mau.TichBat})
					end

					CanGiuaTab(ThongTin.Nut)
				else
					ThongTin.VungCuon.Visible = false
					ThongTin.Nut.Font = Enum.Font.GothamMedium

					if InitialLoad then
						for k, v in pairs(tweenTabKhong) do ThongTin.Nut[k] = v end
						ThongTin.ThanhLine.BackgroundTransparency = 0.6
						ThongTin.ThanhLine.Size = UDim2.new(0.3, 0, 0, 2)
						ThongTin.ThanhLine.BackgroundColor3 = Mau.Chu
					else
						ChayTween(ThongTin.Nut, TweenNhanh, tweenTabKhong)
						ChayTween(ThongTin.ThanhLine, TweenNhanh, {BackgroundTransparency = 0.6, Size = UDim2.new(0.3, 0, 0, 2), BackgroundColor3 = Mau.Chu})
					end
				end
			end
		end

		for ViTriTab, DuLieuTab in ipairs(DuLieu) do
			local NutTab = TaoDoiTuong("TextButton", {
				LayoutOrder = ViTriTab, Size = UDim2.new(0, 0, 0, 28), AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = Mau.NenHop, BackgroundTransparency = 0.8, Text = DuLieuTab.TenTab or "Tab " .. ViTriTab,
				TextColor3 = Mau.Chu, TextTransparency = 0.4, Font = Enum.Font.GothamMedium, TextSize = CauHinh.VanBan.Nho + 2,
				TextWrapped = false, AutoButtonColor = false, Parent = ThanhTab
			})
			TaoBoGoc(NutTab, 6)
			TaoDoiTuong("UIPadding", {PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = NutTab})

			local ThanhLine = TaoDoiTuong("Frame", {
				Size = UDim2.new(0.3, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -1), AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = Mau.Chu, BackgroundTransparency = 0.6, BorderSizePixel = 0, Parent = NutTab
			})
			TaoBoGoc(ThanhLine, 2)

			local VungCuonRieng = TaoDoiTuong("ScrollingFrame", {
				Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 4, ScrollBarImageColor3 = Mau.Chu,
				BorderSizePixel = 0, ScrollingDirection = Enum.ScrollingDirection.Y, AutomaticCanvasSize = Enum.AutomaticSize.Y,
				Visible = false, Parent = KhungNoiDungTab
			})

			table.insert(DanhSachTab, {Index = ViTriTab, Nut = NutTab, ThanhLine = ThanhLine, Ten = DuLieuTab.TenTab, VungCuon = VungCuonRieng})

			NutTab.MouseButton1Click:Connect(function()
				if CurrentTabIndex ~= ViTriTab then
					CauHinh.TabMacDinh = DuLieuTab.TenTab
					ChuyenTab(ViTriTab, false)
				end
			end)

			TaoBoCucCacKhoi(VungCuonRieng, DuLieuTab.DuLieuKhoi or {})
		end

		ChuyenTab(TabMacDinhIndex, true)

		task.spawn(function()
			task.wait(0.1)
			CapNhatPaddingTab()
			ThanhTab:GetPropertyChangedSignal("AbsoluteSize"):Connect(CapNhatPaddingTab)
		end)
	else
		TaoBoCucCacKhoi(Cuon, DuLieu)
	end
end

return KhungCuon
