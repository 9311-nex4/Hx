local TweenService = game:GetService("TweenService")
local ThuVien = {}

local CauHinhTween = {
	Mo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Dong = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
	FadeNhanh = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	FadeCham = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	NutLuot = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	NutDongPop = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
}

local function ChayTween(doiTuong, thongTin, thuocTinh)
	if doiTuong then TweenService:Create(doiTuong, thongTin, thuocTinh):Play() end
end

function ThuVien.HieuUngLuotNut(nut, dangLuot, cauHinh)
	local kichThuocDich = dangLuot and cauHinh.KichThuocLuot or cauHinh.KichThuocThuong
	local mauDich = dangLuot and cauHinh.MauLuot or cauHinh.MauThuong
	local coChuDich = dangLuot and 20 or 18
	
	ChayTween(nut, CauHinhTween.NutLuot, {
		Size = kichThuocDich,
		BackgroundColor3 = mauDich,
		TextSize = coChuDich
	})
end

function ThuVien.HieuUngLuotNutDong(cacDoiTuong, dangLuot, cauHinhMau, cauHinhKichThuoc)
	if dangLuot then
		ChayTween(cacDoiTuong.NutDong, CauHinhTween.NutLuot, {Size = cauHinhKichThuoc.Luot, BackgroundColor3 = cauHinhMau.Luot, TextSize = 22})
		ChayTween(cacDoiTuong.Dem, CauHinhTween.NutLuot, {PaddingRight = UDim.new(0, 0.5)})
		cacDoiTuong.Vien.Transparency = 0.4
	else
		ChayTween(cacDoiTuong.NutDong, CauHinhTween.NutLuot, {Size = cauHinhKichThuoc.Thuong, BackgroundColor3 = cauHinhMau.Thuong, TextSize = 18})
		ChayTween(cacDoiTuong.Dem, CauHinhTween.NutLuot, {PaddingRight = UDim.new(0, 0)})
		cacDoiTuong.Vien.Transparency = 0.8
	end
end

function ThuVien.HieuUngNhanNut(nut, kichThuocNhan)
	ChayTween(nut, CauHinhTween.FadeNhanh, {Size = kichThuocNhan})
end

function ThuVien.MoGiaoDien(cacDoiTuong, cauHinh)
	ChayTween(cacDoiTuong.Khung, CauHinhTween.FadeCham, {BackgroundTransparency = 1})
	ChayTween(cacDoiTuong.Icon, CauHinhTween.Mo, {Size = cauHinh.IconDau, ImageTransparency = 0})

	task.wait(0.5)

	ChayTween(cacDoiTuong.Khung, CauHinhTween.Mo, {Size = cauHinh.KhungCuoi, BackgroundTransparency = 0.15})

	local tweenIcon = TweenService:Create(cacDoiTuong.Icon, CauHinhTween.Mo, {
		Size = cauHinh.IconCuoi,
		Position = cauHinh.IconCuoiPos,
		AnchorPoint = Vector2.new(0.5, 0.5)
	})
	tweenIcon:Play()

	tweenIcon.Completed:Connect(function()
		ChayTween(cacDoiTuong.TieuDe, CauHinhTween.FadeCham, {TextTransparency = 0})
		ChayTween(cacDoiTuong.NutDong, CauHinhTween.FadeCham, {BackgroundTransparency = 0.6, TextTransparency = 0})
		ChayTween(cacDoiTuong.VienNutDong, CauHinhTween.FadeCham, {Transparency = 0.8})
		ChayTween(cacDoiTuong.DanhSach, CauHinhTween.FadeCham, {BackgroundTransparency = 0.6, ScrollBarImageTransparency = 0})

		for _, con in ipairs(cacDoiTuong.DanhSach:GetChildren()) do
			if con:IsA("TextButton") then
				ChayTween(con, CauHinhTween.FadeCham, {BackgroundTransparency = 0, TextTransparency = 0})
			end
		end
	end)
end

function ThuVien.DongGiaoDien(cacDoiTuong, cauHinh, hamXong)
	local hieuUngPop = TweenService:Create(cacDoiTuong.NutDong, CauHinhTween.NutDongPop, {Size = cauHinh.NutDongPop})
	hieuUngPop:Play()

	hieuUngPop.Completed:Connect(function()
		ChayTween(cacDoiTuong.TieuDe, CauHinhTween.FadeNhanh, {TextTransparency = 1})
		ChayTween(cacDoiTuong.DanhSach, CauHinhTween.FadeNhanh, {BackgroundTransparency = 1, ScrollBarImageTransparency = 1})
		ChayTween(cacDoiTuong.NutDong, CauHinhTween.FadeNhanh, {BackgroundTransparency = 1, TextTransparency = 1})
		ChayTween(cacDoiTuong.VienNutDong, CauHinhTween.FadeNhanh, {Transparency = 1})

		for _, con in ipairs(cacDoiTuong.DanhSach:GetChildren()) do
			if con:IsA("GuiObject") then
				ChayTween(con, CauHinhTween.FadeNhanh, {BackgroundTransparency = 1})
				if con:IsA("TextButton") or con:IsA("TextLabel") then
					ChayTween(con, CauHinhTween.FadeNhanh, {TextTransparency = 1})
				end
			end
		end

		task.delay(0.2, function()
			ChayTween(cacDoiTuong.Icon, CauHinhTween.Dong, {Position = cauHinh.IconDauPos, Size = cauHinh.IconDau})
			
			local dongKhung = TweenService:Create(cacDoiTuong.Khung, CauHinhTween.Dong, {
				Size = cauHinh.KhungDau,
				BackgroundTransparency = 1
			})
			dongKhung:Play()

			dongKhung.Completed:Connect(function()
				local fadeCuoi = TweenService:Create(cacDoiTuong.Icon, CauHinhTween.FadeCham, {ImageTransparency = 1, Size = UDim2.new(0,0,0,0)})
				fadeCuoi:Play()
				
				fadeCuoi.Completed:Connect(function()
					if hamXong then hamXong() end
				end)
			end)
		end)
	end)
end

return ThuVien
