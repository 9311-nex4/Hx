local DichVuTween = game:GetService("TweenService")
local DichVuNhapLieu = game:GetService("UserInputService")
local HoatAnh = {}

local KhoLuuTruGiaoDien = {}

HoatAnh.Kieu = {
	Mo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Dong = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
	Muot = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Nay = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	MoDan = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Keo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
}

local function ChayTween(DoiTuong, ThongTinTween, ThuocTinh)
	if not DoiTuong or not ThuocTinh then return end
	local ThuocTinhHopLe = {}
	for k, v in pairs(ThuocTinh) do
		pcall(function() 
			if DoiTuong[k] ~= nil then ThuocTinhHopLe[k] = v end 
		end)
	end
	if next(ThuocTinhHopLe) then
		DichVuTween:Create(DoiTuong, ThongTinTween, ThuocTinhHopLe):Play()
	end
end

local function LayThongSoGoc(DoiTuong)
	if KhoLuuTruGiaoDien[DoiTuong] then return KhoLuuTruGiaoDien[DoiTuong] end

	local DuLieu = {}
	if DoiTuong:IsA("GuiObject") then
		DuLieu.BackgroundTransparency = DoiTuong.BackgroundTransparency
		if DoiTuong:IsA("TextLabel") or DoiTuong:IsA("TextButton") or DoiTuong:IsA("TextBox") then
			DuLieu.TextTransparency = DoiTuong.TextTransparency
			if DoiTuong:IsA("TextBox") then DuLieu.PlaceholderTextTransparency = DoiTuong.PlaceholderTextTransparency end
		end
		if DoiTuong:IsA("ImageLabel") or DoiTuong:IsA("ImageButton") then
			DuLieu.ImageTransparency = DoiTuong.ImageTransparency
		end
		if DoiTuong:IsA("ScrollingFrame") then
			DuLieu.ScrollBarImageTransparency = DoiTuong.ScrollBarImageTransparency
		end
		if DoiTuong:IsA("CanvasGroup") then
			DuLieu.GroupTransparency = DoiTuong.GroupTransparency
		end
	elseif DoiTuong:IsA("UIStroke") then
		DuLieu.Transparency = DoiTuong.Transparency
	end

	KhoLuuTruGiaoDien[DoiTuong] = DuLieu
	return DuLieu
end

local function XuLyHienThiNoiDung(Khung, HienThi, CoHieuUng)
	if not Khung then return end
	local CacDoiTuong = Khung:GetDescendants()
	table.insert(CacDoiTuong, Khung) 

	for _, DoiTuong in ipairs(CacDoiTuong) do
		local DichDen = {}
		if HienThi then
			DichDen = LayThongSoGoc(DoiTuong)
		else
			LayThongSoGoc(DoiTuong) 
			if DoiTuong:IsA("GuiObject") then
				DichDen.BackgroundTransparency = 1
				DichDen.TextTransparency = 1
				DichDen.ImageTransparency = 1
				DichDen.ScrollBarImageTransparency = 1
				if DoiTuong:IsA("CanvasGroup") then DichDen.GroupTransparency = 1 end
			elseif DoiTuong:IsA("UIStroke") then
				DichDen.Transparency = 1
			end
		end

		if CoHieuUng then
			ChayTween(DoiTuong, HoatAnh.Kieu.MoDan, DichDen)
		else
			for k, v in pairs(DichDen) do
				pcall(function() DoiTuong[k] = v end)
			end
		end
	end
end

function HoatAnh.LuotChuot(DoiTuong, TrangThai, ThuocTinhVao, ThuocTinhRa)
	if not DoiTuong then return end
	local ThuocTinh = TrangThai and ThuocTinhVao or ThuocTinhRa
	ChayTween(DoiTuong, HoatAnh.Kieu.Muot, ThuocTinh)
end

function HoatAnh.NhanChuot(DoiTuong)
	if not DoiTuong then return end
	local KichThuocGoc = DoiTuong.Size
	local TweenNho = DichVuTween:Create(DoiTuong, HoatAnh.Kieu.Nay, {
		Size = UDim2.new(KichThuocGoc.X.Scale, KichThuocGoc.X.Offset - 4, KichThuocGoc.Y.Scale, KichThuocGoc.Y.Offset - 4)
	})
	TweenNho:Play()
	TweenNho.Completed:Connect(function()
		ChayTween(DoiTuong, HoatAnh.Kieu.Nay, {Size = KichThuocGoc})
	end)
end

function HoatAnh.KeoTha(Khung, DiemKeo)
	DiemKeo = DiemKeo or Khung
	if not Khung or not DiemKeo then return end

	local DangKeo, DauVaoKeo, ViTriChuotBatDau, ViTriKhungBatDau

	local function CapNhat(DauVao)
		local Delta = DauVao.Position - ViTriChuotBatDau
		local ViTriMoi = UDim2.new(
			ViTriKhungBatDau.X.Scale, ViTriKhungBatDau.X.Offset + Delta.X,
			ViTriKhungBatDau.Y.Scale, ViTriKhungBatDau.Y.Offset + Delta.Y
		)
		DichVuTween:Create(Khung, HoatAnh.Kieu.Keo, {Position = ViTriMoi}):Play()
	end

	DiemKeo.InputBegan:Connect(function(DauVao)
		if DauVao.UserInputType == Enum.UserInputType.MouseButton1 or DauVao.UserInputType == Enum.UserInputType.Touch then
			DangKeo = true
			ViTriChuotBatDau = DauVao.Position
			ViTriKhungBatDau = Khung.Position
			DauVao.Changed:Connect(function()
				if DauVao.UserInputState == Enum.UserInputState.End then DangKeo = false end
			end)
		end
	end)

	DiemKeo.InputChanged:Connect(function(DauVao)
		if DauVao.UserInputType == Enum.UserInputType.MouseMovement or DauVao.UserInputType == Enum.UserInputType.Touch then
			DauVaoKeo = DauVao
		end
	end)

	DichVuNhapLieu.InputChanged:Connect(function(DauVao)
		if DauVao == DauVaoKeo and DangKeo then CapNhat(DauVao) end
	end)
end

function HoatAnh.MoGiaoDien(CacPhanTu, CauHinh)
	if CacPhanTu.Khung then 
		CacPhanTu.Khung.Size = CauHinh.KhungDau or UDim2.fromScale(0,0)
		CacPhanTu.Khung.BackgroundTransparency = 1 
	end

	if CacPhanTu.Icon then 
		CacPhanTu.Icon.Size = CauHinh.IconDau or UDim2.fromOffset(0,0)
		CacPhanTu.Icon.Position = CauHinh.ViTriIconDau or UDim2.fromScale(0.5, 0.5)
		CacPhanTu.Icon.ImageTransparency = 0
		CacPhanTu.Icon.Visible = true
	end

	if CacPhanTu.KhungNoiDung then
		CacPhanTu.KhungNoiDung.Visible = true
		XuLyHienThiNoiDung(CacPhanTu.KhungNoiDung, false, false)
	end

	ChayTween(CacPhanTu.Khung, HoatAnh.Kieu.MoDan, {BackgroundTransparency = 1})

	task.wait(0.2)
	ChayTween(CacPhanTu.Khung, HoatAnh.Kieu.Mo, {
		Size = CauHinh.KhungCuoi, 
		BackgroundTransparency = CauHinh.DoTrongSuotKhung or 0.15
	})

	if CacPhanTu.Icon then
		local HieuUngIcon = DichVuTween:Create(CacPhanTu.Icon, HoatAnh.Kieu.Mo, {
			Size = CauHinh.IconCuoi,
			Position = CauHinh.ViTriIconCuoi,
			AnchorPoint = Vector2.new(0.5, 0.5)
		})
		HieuUngIcon:Play()

		HieuUngIcon.Completed:Connect(function()
			if CacPhanTu.TieuDe then ChayTween(CacPhanTu.TieuDe, HoatAnh.Kieu.MoDan, {TextTransparency = 0}) end
			if CacPhanTu.NutDong then ChayTween(CacPhanTu.NutDong, HoatAnh.Kieu.MoDan, {BackgroundTransparency = 0.6, TextTransparency = 0}) end
			if CacPhanTu.VienNutDong then ChayTween(CacPhanTu.VienNutDong, HoatAnh.Kieu.MoDan, {Transparency = 0.8}) end
			if CacPhanTu.KhungNoiDung then XuLyHienThiNoiDung(CacPhanTu.KhungNoiDung, true, true) end
		end)
	else
		task.delay(0.3, function()
			if CacPhanTu.KhungNoiDung then XuLyHienThiNoiDung(CacPhanTu.KhungNoiDung, true, true) end
		end)
	end
end

function HoatAnh.DongGiaoDien(CacPhanTu, CauHinh, HamGoiLai)
	if CacPhanTu.NutDong then
		local HieuUngNay = DichVuTween:Create(CacPhanTu.NutDong, HoatAnh.Kieu.Nay, {Size = CauHinh.KichThuocNutDongNay})
		HieuUngNay:Play()
		HieuUngNay.Completed:Wait()
	end

	if CacPhanTu.TieuDe then ChayTween(CacPhanTu.TieuDe, HoatAnh.Kieu.Muot, {TextTransparency = 1}) end
	if CacPhanTu.NutDong then ChayTween(CacPhanTu.NutDong, HoatAnh.Kieu.Muot, {BackgroundTransparency = 1, TextTransparency = 1}) end
	if CacPhanTu.VienNutDong then ChayTween(CacPhanTu.VienNutDong, HoatAnh.Kieu.Muot, {Transparency = 1}) end

	if CacPhanTu.KhungNoiDung then XuLyHienThiNoiDung(CacPhanTu.KhungNoiDung, false, true) end

	task.wait(0.1)

	if CacPhanTu.Icon then
		ChayTween(CacPhanTu.Icon, HoatAnh.Kieu.Dong, {Position = CauHinh.ViTriIconDau, Size = CauHinh.IconDau})
	end

	if CacPhanTu.Khung then
		local HieuUngDongKhung = DichVuTween:Create(CacPhanTu.Khung, HoatAnh.Kieu.Dong, {
			Size = CauHinh.KhungDau,
			BackgroundTransparency = 1
		})
		HieuUngDongKhung:Play()

		HieuUngDongKhung.Completed:Connect(function()
			if CacPhanTu.Icon then
				local HieuUngMoCuoi = DichVuTween:Create(CacPhanTu.Icon, HoatAnh.Kieu.MoDan, {ImageTransparency = 1, Size = UDim2.new(0,0,0,0)})
				HieuUngMoCuoi:Play()
				HieuUngMoCuoi.Completed:Connect(function()
					if HamGoiLai then HamGoiLai() end
				end)
			else
				if HamGoiLai then HamGoiLai() end
			end
		end)
	else
		if HamGoiLai then HamGoiLai() end
	end
end

return HoatAnh
