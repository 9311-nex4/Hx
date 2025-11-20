local DichVuTween = game:GetService("TweenService")

local KhungCuon = {}

function KhungCuon.Tao(VungCuon, DuLieu, CauHinh, LopPhu, HamDongMenu)
	local CotTrai = Instance.new("Frame")
	CotTrai.Size = UDim2.new(0.46, 0, 0, 0)
	CotTrai.Position = UDim2.new(0.02, 0, 0, 5)
	CotTrai.BackgroundTransparency = 1
	CotTrai.AutomaticSize = Enum.AutomaticSize.Y
	CotTrai.Parent = VungCuon

	local BoCucTrai = Instance.new("UIListLayout")
	BoCucTrai.Padding = UDim.new(0, 10)
	BoCucTrai.SortOrder = Enum.SortOrder.LayoutOrder
	BoCucTrai.Parent = CotTrai

	local CotPhai = Instance.new("Frame")
	CotPhai.Size = UDim2.new(0.46, 0, 0, 0)
	CotPhai.Position = UDim2.new(0.98, 0, 0, 5)
	CotPhai.AnchorPoint = Vector2.new(1, 0)
	CotPhai.BackgroundTransparency = 1
	CotPhai.AutomaticSize = Enum.AutomaticSize.Y
	CotPhai.Parent = VungCuon

	local BoCucPhai = Instance.new("UIListLayout")
	BoCucPhai.Padding = UDim.new(0, 10)
	BoCucPhai.SortOrder = Enum.SortOrder.LayoutOrder
	BoCucPhai.Parent = CotPhai

	local function CapNhatVungCuon()
		VungCuon.CanvasSize = UDim2.new(0, 0, 0, math.max(BoCucTrai.AbsoluteContentSize.Y, BoCucPhai.AbsoluteContentSize.Y) + 20)
	end
	BoCucTrai:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(CapNhatVungCuon)
	BoCucPhai:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(CapNhatVungCuon)

	local TaoMuc
	TaoMuc = function(Cha, DuLieuMuc, HamCapNhatKichThuoc, ThuTu)
		local function YeuCauCapNhat() if HamCapNhatKichThuoc then HamCapNhatKichThuoc() end end
		local Order = ThuTu or 0

		if DuLieuMuc.Loai == "Otich" then
			local Hang = Instance.new("Frame")
			Hang.LayoutOrder = Order
			Hang.Size = UDim2.new(1, 0, 0, 36)
			Hang.BackgroundColor3 = CauHinh.Mau.NenMuc
			Hang.ZIndex = 2
			Hang.Parent = Cha
			Instance.new("UICorner", Hang).CornerRadius = UDim.new(0, 6)

			local VienHang = Instance.new("UIStroke", Hang)
			VienHang.Color = CauHinh.Mau.VienHop
			VienHang.Transparency = 0.8

			local Nhan = Instance.new("TextLabel")
			Nhan.Text = "  " .. DuLieuMuc.Ten
			Nhan.Size = UDim2.new(0.7, 0, 1, 0)
			Nhan.BackgroundTransparency = 1
			Nhan.TextColor3 = CauHinh.Mau.Chu
			Nhan.Font = Enum.Font.GothamMedium
			Nhan.TextSize = 12
			Nhan.TextXAlignment = Enum.TextXAlignment.Left
			Nhan.ZIndex = 3
			Nhan.Parent = Hang

			local Hop = Instance.new("ImageButton")
			Hop.Size = UDim2.new(0, 20, 0, 20)
			Hop.Position = UDim2.new(1, -10, 0.5, 0)
			Hop.AnchorPoint = Vector2.new(1, 0.5)
			Hop.BackgroundColor3 = CauHinh.Mau.NenHop
			Hop.ZIndex = 3
			Hop.Parent = Hang
			Instance.new("UICorner", Hop).CornerRadius = UDim.new(0, 6)
			Instance.new("UIStroke", Hop).Color = CauHinh.Mau.VienHop

			local TrangThai = false
			if DuLieuMuc.HienTai == "Bat" then TrangThai = true
			elseif DuLieuMuc.HienTai == "Tat" then TrangThai = false
			else TrangThai = DuLieuMuc.TrangThai or false end
			DuLieuMuc.TrangThai = TrangThai

			local DauTich = Instance.new("Frame")
			DauTich.Size = UDim2.new(1, -10, 1, -10)
			DauTich.Position = UDim2.new(0.5, 0, 0.5, 0)
			DauTich.AnchorPoint = Vector2.new(0.5, 0.5)
			DauTich.BackgroundColor3 = CauHinh.Mau.TichBat
			DauTich.Visible = TrangThai
			DauTich.ZIndex = 4
			DauTich.Parent = Hop
			Instance.new("UICorner", DauTich).CornerRadius = UDim.new(0, 2)

			local VienDauTich = Instance.new("UIStroke", DauTich)
			VienDauTich.Color = CauHinh.Mau.TichBat 
			VienDauTich.Thickness = 2
			VienDauTich.Transparency = 0.5
			VienDauTich.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 

			Hop.MouseButton1Click:Connect(function()
				DuLieuMuc.TrangThai = not DuLieuMuc.TrangThai
				DauTich.Visible = DuLieuMuc.TrangThai
				DuLieuMuc.HienTai = DuLieuMuc.TrangThai and "Bat" or "Tat"
				if DuLieuMuc.SuKien then DuLieuMuc.SuKien(DuLieuMuc.TrangThai) end
			end)

		elseif DuLieuMuc.Loai == "Nut" then
			local NutNhan = Instance.new("TextButton")
			NutNhan.LayoutOrder = Order
			NutNhan.Size = UDim2.new(1, 0, 0, 36)
			NutNhan.BackgroundColor3 = CauHinh.Mau.NenMuc
			NutNhan.Text = DuLieuMuc.Ten
			NutNhan.TextColor3 = CauHinh.Mau.Chu
			NutNhan.Font = Enum.Font.GothamMedium
			NutNhan.TextScaled = true
			NutNhan.ZIndex = 2
			NutNhan.Parent = Cha
			Instance.new("UICorner", NutNhan).CornerRadius = UDim.new(0, 6)
			Instance.new("UITextSizeConstraint", NutNhan).MaxTextSize = 18

			local DemNut = Instance.new("UIPadding", NutNhan)
			DemNut.PaddingLeft = UDim.new(0, 5)
			DemNut.PaddingRight = UDim.new(0, 5)

			local Vien = Instance.new("UIStroke", NutNhan)
			Vien.Color = CauHinh.Mau.VienHop
			Vien.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			NutNhan.MouseButton1Click:Connect(function()
				DichVuTween:Create(NutNhan, TweenInfo.new(0.1), {TextSize = 10}):Play()
				task.wait(0.1)
				DichVuTween:Create(NutNhan, TweenInfo.new(0.1), {TextSize = 12}):Play()
				if DuLieuMuc.SuKien then DuLieuMuc.SuKien(DuLieuMuc.TrangThai) end
			end)

		elseif DuLieuMuc.Loai == "NhieuNut" then
			local KhungNut = Instance.new("Frame")
			KhungNut.LayoutOrder = Order
			KhungNut.Size = UDim2.new(1, 0, 0, 36)
			KhungNut.BackgroundTransparency = 1
			KhungNut.Parent = Cha

			local BoCucNgang = Instance.new("UIListLayout", KhungNut)
			BoCucNgang.FillDirection = Enum.FillDirection.Horizontal
			BoCucNgang.SortOrder = Enum.SortOrder.LayoutOrder
			BoCucNgang.Padding = UDim.new(0, 10)

			local function TaoNutCon(Ten, SuKien, ThuTuCon)
				local Nut = Instance.new("TextButton")
				Nut.LayoutOrder = ThuTuCon
				Nut.Size = UDim2.new(0.5, -5, 1, 0) 
				Nut.BackgroundColor3 = CauHinh.Mau.NenMuc
				Nut.Text = Ten or "Nút"
				Nut.TextColor3 = CauHinh.Mau.Chu
				Nut.Font = Enum.Font.GothamMedium
				Nut.TextScaled = true
				Nut.ZIndex = 2
				Nut.Parent = KhungNut
				Instance.new("UICorner", Nut).CornerRadius = UDim.new(0, 6)
				Instance.new("UITextSizeConstraint", Nut).MaxTextSize = 14

				local DemNutCon = Instance.new("UIPadding", Nut)
				DemNutCon.PaddingLeft = UDim.new(0, 5)
				DemNutCon.PaddingRight = UDim.new(0, 5)

				local VienNut = Instance.new("UIStroke", Nut)
				VienNut.Color = CauHinh.Mau.VienHop
				VienNut.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

				Nut.MouseButton1Click:Connect(function()
					DichVuTween:Create(Nut, TweenInfo.new(0.1), {TextSize = 10}):Play()
					task.wait(0.1)
					DichVuTween:Create(Nut, TweenInfo.new(0.1), {TextSize = 14}):Play()
					if SuKien then SuKien() end
				end)
			end

			if DuLieuMuc.Ten_1 then TaoNutCon(DuLieuMuc.Ten_1, DuLieuMuc.SuKien_1, 1) end
			if DuLieuMuc.Ten_2 then TaoNutCon(DuLieuMuc.Ten_2, DuLieuMuc.SuKien_2, 2) end

		elseif DuLieuMuc.Loai == "HopXo" then
			local KhungBao = Instance.new("Frame")
			KhungBao.LayoutOrder = Order
			KhungBao.Size = UDim2.new(1, 0, 0, 0)
			KhungBao.BackgroundTransparency = 1
			KhungBao.AutomaticSize = Enum.AutomaticSize.Y
			KhungBao.Parent = Cha

			local BoCucBao = Instance.new("UIListLayout", KhungBao)
			BoCucBao.SortOrder = Enum.SortOrder.LayoutOrder

			local Hang = Instance.new("Frame")
			Hang.LayoutOrder = 1
			Hang.Size = UDim2.new(1, 0, 0, 36)
			Hang.BackgroundColor3 = CauHinh.Mau.NenMuc
			Hang.ZIndex = 2
			Hang.Parent = KhungBao
			Instance.new("UICorner", Hang).CornerRadius = UDim.new(0, 6)

			local VienHang = Instance.new("UIStroke", Hang)
			VienHang.Color = CauHinh.Mau.VienHop
			VienHang.Transparency = 0.8

			local Nhan = Instance.new("TextLabel")
			Nhan.Text = "  " .. DuLieuMuc.Ten
			Nhan.Size = UDim2.new(0.5, 0, 1, 0)
			Nhan.BackgroundTransparency = 1
			Nhan.TextColor3 = CauHinh.Mau.Chu
			Nhan.Font = Enum.Font.GothamMedium
			Nhan.TextSize = 12
			Nhan.TextXAlignment = Enum.TextXAlignment.Left
			Nhan.ZIndex = 3
			Nhan.Parent = Hang

			local HienThiHop = Instance.new("TextButton")
			HienThiHop.Size = UDim2.new(0.45, 0, 0, 24)
			HienThiHop.Position = UDim2.new(1, -6, 0.5, 0)
			HienThiHop.AnchorPoint = Vector2.new(1, 0.5)
			HienThiHop.BackgroundColor3 = CauHinh.Mau.NenHop
			HienThiHop.BackgroundTransparency = 0.5
			HienThiHop.Text = DuLieuMuc.HienTai or "..."
			HienThiHop.TextColor3 = CauHinh.Mau.Chu
			HienThiHop.Font = Enum.Font.Gotham
			HienThiHop.TextScaled = true
			HienThiHop.ZIndex = 3
			HienThiHop.Parent = Hang
			Instance.new("UICorner", HienThiHop).CornerRadius = UDim.new(0, 4)
			Instance.new("UITextSizeConstraint", HienThiHop).MaxTextSize = 14

			local VienHop = Instance.new("UIStroke", HienThiHop)
			VienHop.Color = CauHinh.Mau.VienHop
			VienHop.Transparency = 0.8
			VienHop.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			local CaiDatCon = Instance.new("Frame")
			CaiDatCon.LayoutOrder = 2
			CaiDatCon.Size = UDim2.new(1, 0, 0, 0)
			CaiDatCon.BackgroundTransparency = 1
			CaiDatCon.AutomaticSize = Enum.AutomaticSize.Y
			CaiDatCon.Parent = KhungBao

			local DemCon = Instance.new("UIPadding", CaiDatCon)
			DemCon.PaddingTop = UDim.new(0, 0)
			DemCon.PaddingLeft = UDim.new(0, 5)
			DemCon.PaddingBottom = UDim.new(0, 0) 

			local BoCucCon = Instance.new("UIListLayout", CaiDatCon)
			BoCucCon.Padding = UDim.new(0, 5)
			BoCucCon.SortOrder = Enum.SortOrder.LayoutOrder

			local function CapNhatCaiDatCon(CacMuc)
				for _, c in ipairs(CaiDatCon:GetChildren()) do
					if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
				end

				if CacMuc and #CacMuc > 0 then
					DemCon.PaddingTop = UDim.new(0, 5)
					DemCon.PaddingBottom = UDim.new(0, 5)
					for k, duLieuCon in ipairs(CacMuc) do
						TaoMuc(CaiDatCon, duLieuCon, YeuCauCapNhat, k)
					end
				else
					DemCon.PaddingTop = UDim.new(0, 0)
					DemCon.PaddingBottom = UDim.new(0, 0)
				end

				YeuCauCapNhat()
			end

			for _, tuyChon in ipairs(DuLieuMuc.LuaChon) do
				local tenTuyChon = (type(tuyChon) == "table") and tuyChon.Ten or tuyChon
				if tenTuyChon == DuLieuMuc.HienTai and type(tuyChon) == "table" then
					CapNhatCaiDatCon(tuyChon.CacNutCon)
				end
			end
			if not DuLieuMuc.HienTai then
				DemCon.PaddingTop = UDim.new(0, 0)
				DemCon.PaddingBottom = UDim.new(0, 0)
			end


			HienThiHop.MouseButton1Click:Connect(function()
				if HamDongMenu then HamDongMenu() end
				local KhungDanhSach = Instance.new("Frame")
				KhungDanhSach.Size = UDim2.new(0, HienThiHop.AbsoluteSize.X, 0, 0)
				KhungDanhSach.Position = UDim2.fromOffset(HienThiHop.AbsolutePosition.X, HienThiHop.AbsolutePosition.Y + HienThiHop.AbsoluteSize.Y + 5)
				KhungDanhSach.BackgroundColor3 = CauHinh.Mau.NenPhu
				KhungDanhSach.BorderSizePixel = 0
				KhungDanhSach.ClipsDescendants = true
				KhungDanhSach.ZIndex = 105
				KhungDanhSach.Parent = LopPhu
				Instance.new("UICorner", KhungDanhSach).CornerRadius = UDim.new(0, 4)
				Instance.new("UIStroke", KhungDanhSach).Color = CauHinh.Mau.VienHop

				local BoCucDanhSach = Instance.new("UIListLayout", KhungDanhSach)

				for _, tuyChon in ipairs(DuLieuMuc.LuaChon) do
					local tenTuyChon = (type(tuyChon) == "table") and tuyChon.Ten or tuyChon
					local cacMucCon = (type(tuyChon) == "table") and tuyChon.CacNutCon or nil

					local NutChon = Instance.new("TextButton")
					NutChon.Size = UDim2.new(1, 0, 0, 28)
					NutChon.BackgroundColor3 = CauHinh.Mau.NenPhu
					NutChon.Text = "  " .. tenTuyChon
					NutChon.TextColor3 = CauHinh.Mau.Chu
					NutChon.Font = Enum.Font.Gotham
					NutChon.TextSize = 12
					NutChon.TextXAlignment = Enum.TextXAlignment.Left
					NutChon.BorderSizePixel = 0
					NutChon.ZIndex = 106
					NutChon.Parent = KhungDanhSach

					NutChon.MouseEnter:Connect(function() NutChon.BackgroundColor3 = CauHinh.Mau.ChonPhu end)
					NutChon.MouseLeave:Connect(function() NutChon.BackgroundColor3 = CauHinh.Mau.NenPhu end)
					NutChon.MouseButton1Click:Connect(function()
						DuLieuMuc.HienTai = tenTuyChon
						HienThiHop.Text = tenTuyChon
						CapNhatCaiDatCon(cacMucCon)
						if HamDongMenu then HamDongMenu() end
					end)
				end

				DichVuTween:Create(KhungDanhSach, TweenInfo.new(0.2), {Size = UDim2.new(0, HienThiHop.AbsoluteSize.X, 0, #DuLieuMuc.LuaChon * 28)}):Play()
				local KetNoi
				KetNoi = VungCuon.Changed:Connect(function()
					if HamDongMenu then HamDongMenu() end
					if KetNoi then KetNoi:Disconnect() end
				end)
			end)

		elseif DuLieuMuc.Loai == "Danhsach" then
			local KhungBao = Instance.new("Frame")
			KhungBao.LayoutOrder = Order
			KhungBao.Size = UDim2.new(1, 0, 0, 0)
			KhungBao.BackgroundTransparency = 1
			KhungBao.AutomaticSize = Enum.AutomaticSize.Y
			KhungBao.Parent = Cha

			local BoCucBao = Instance.new("UIListLayout", KhungBao)
			BoCucBao.SortOrder = Enum.SortOrder.LayoutOrder

			local DauDanhSach = Instance.new("TextButton")
			DauDanhSach.LayoutOrder = 1
			DauDanhSach.Size = UDim2.new(1, 0, 0, 36)
			DauDanhSach.BackgroundColor3 = CauHinh.Mau.NenMuc
			DauDanhSach.Text = ""
			DauDanhSach.ZIndex = 2
			DauDanhSach.Parent = KhungBao
			Instance.new("UICorner", DauDanhSach).CornerRadius = UDim.new(0, 6)

			local VienDau = Instance.new("UIStroke", DauDanhSach)
			VienDau.Color = CauHinh.Mau.VienHop
			VienDau.Transparency = 0.8

			local Nhan = Instance.new("TextLabel")
			Nhan.Text = "  " .. DuLieuMuc.Ten
			Nhan.Size = UDim2.new(0.8, 0, 1, 0)
			Nhan.BackgroundTransparency = 1
			Nhan.TextColor3 = CauHinh.Mau.Chu
			Nhan.Font = Enum.Font.GothamMedium
			Nhan.TextSize = 12
			Nhan.TextXAlignment = Enum.TextXAlignment.Left
			Nhan.ZIndex = 3
			Nhan.Parent = DauDanhSach

			local MuiTen = Instance.new("ImageLabel")
			MuiTen.Size = UDim2.new(0, 16, 0, 16)
			MuiTen.Position = UDim2.new(1, -10, 0.5, 0)
			MuiTen.AnchorPoint = Vector2.new(1, 0.5)
			MuiTen.Image = CauHinh.Asset.MuiTenXuong or "rbxassetid://6031091004"
			MuiTen.BackgroundTransparency = 1
			MuiTen.ZIndex = 3
			MuiTen.Parent = DauDanhSach

			local NoiDungCon = Instance.new("Frame")
			NoiDungCon.LayoutOrder = 2
			NoiDungCon.Size = UDim2.new(1, 0, 0, 0)
			NoiDungCon.BackgroundTransparency = 1
			NoiDungCon.ClipsDescendants = true
			NoiDungCon.Parent = KhungBao

			local DemCon = Instance.new("UIPadding", NoiDungCon)
			DemCon.PaddingTop = UDim.new(0, 5)
			DemCon.PaddingLeft = UDim.new(0, 10)

			local BoCucCon = Instance.new("UIListLayout", NoiDungCon)
			BoCucCon.Padding = UDim.new(0, 5)
			BoCucCon.SortOrder = Enum.SortOrder.LayoutOrder

			if DuLieuMuc.Danhsach then
				for k, itemCon in ipairs(DuLieuMuc.Danhsach) do
					TaoMuc(NoiDungCon, itemCon, function()
						if DuLieuMuc.DangMo then
							NoiDungCon.Size = UDim2.new(1, 0, 0, BoCucCon.AbsoluteContentSize.Y + 10)
							YeuCauCapNhat()
						end
					end, k)
				end
			end

			DuLieuMuc.DangMo = false

			DauDanhSach.MouseButton1Click:Connect(function()
				DuLieuMuc.DangMo = not DuLieuMuc.DangMo
				local Dich = DuLieuMuc.DangMo and (BoCucCon.AbsoluteContentSize.Y + 10) or 0
				local GocXoay = DuLieuMuc.DangMo and 180 or 0

				DichVuTween:Create(NoiDungCon, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, Dich)}):Play()
				DichVuTween:Create(MuiTen, TweenInfo.new(0.2), {Rotation = GocXoay}):Play()
				task.delay(0.21, YeuCauCapNhat)
			end)
		end
	end

	local function TaoKhoiDuLieu(DuLieu, CotCha)
		local ChieuCaoDau = 42
		local Khoi = Instance.new("Frame")
		Khoi.Size = UDim2.new(1, 0, 0, ChieuCaoDau)
		Khoi.BackgroundColor3 = CauHinh.Mau.NenKhoi
		Khoi.ClipsDescendants = true
		Khoi.ZIndex = 1
		Khoi.Parent = CotCha
		Instance.new("UICorner", Khoi).CornerRadius = UDim.new(0, 8)
		Instance.new("UIStroke", Khoi).Color = CauHinh.Mau.VienHop

		local DauKhoi = Instance.new("TextButton")
		DauKhoi.Size = UDim2.new(1, 0, 0, ChieuCaoDau)
		DauKhoi.BackgroundColor3 = CauHinh.Mau.NenKhoi
		DauKhoi.BackgroundTransparency = 1
		DauKhoi.Text = ""
		DauKhoi.ZIndex = 2
		DauKhoi.Parent = Khoi

		local VachNgan = Instance.new("Frame")
		VachNgan.Size = UDim2.new(1, 0, 0, 1)
		VachNgan.Position = UDim2.new(0, 0, 1, -1)
		VachNgan.BackgroundColor3 = CauHinh.Mau.VienHop
		VachNgan.BorderSizePixel = 0
		VachNgan.ZIndex = 2
		VachNgan.Parent = DauKhoi

		local TieuDe = Instance.new("TextLabel")
		TieuDe.Text = DuLieu.TieuDe
		TieuDe.Size = UDim2.new(1, -35, 1, 0)
		TieuDe.Position = UDim2.new(0, 10, 0, 0)
		TieuDe.TextColor3 = CauHinh.Mau.Chu
		TieuDe.Font = Enum.Font.GothamBold
		TieuDe.TextScaled = true
		TieuDe.TextXAlignment = Enum.TextXAlignment.Left
		TieuDe.BackgroundTransparency = 1
		TieuDe.ZIndex = 3
		TieuDe.Parent = DauKhoi
		Instance.new("UITextSizeConstraint", TieuDe).MaxTextSize = 14

		local MuiTen = Instance.new("ImageLabel")
		MuiTen.Size = UDim2.new(0, 20, 0, 20)
		MuiTen.Position = UDim2.new(1, -25, 0.5, 0)
		MuiTen.AnchorPoint = Vector2.new(0, 0.5)
		MuiTen.Image = CauHinh.Asset.MuiTenXuong
		MuiTen.BackgroundTransparency = 1
		MuiTen.ZIndex = 3
		MuiTen.Parent = DauKhoi

		local NoiDung = Instance.new("Frame")
		NoiDung.Position = UDim2.new(0, 0, 0, ChieuCaoDau + 15)
		NoiDung.Size = UDim2.new(1, 0, 0, 0)
		NoiDung.BackgroundTransparency = 1
		NoiDung.Parent = Khoi

		local BoCucNoiDung = Instance.new("UIListLayout", NoiDung)
		BoCucNoiDung.Padding = UDim.new(0, 5)
		BoCucNoiDung.SortOrder = Enum.SortOrder.LayoutOrder

		local Dem = Instance.new("UIPadding", NoiDung)
		Dem.PaddingBottom = UDim.new(0, 8)
		Dem.PaddingLeft = UDim.new(0, 8)
		Dem.PaddingRight = UDim.new(0, 8)
		Dem.PaddingTop = UDim.new(0, 5)

		local DangMoRong = true
		local function CapNhatTrangThai()
			if DangMoRong then
				local ChieuCaoNoiDung = BoCucNoiDung.AbsoluteContentSize.Y + 15
				DichVuTween:Create(Khoi, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, ChieuCaoDau + ChieuCaoNoiDung)}):Play()
				DichVuTween:Create(MuiTen, TweenInfo.new(0.2), {Rotation = 180}):Play()
				VachNgan.Visible = true
			else
				DichVuTween:Create(Khoi, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, ChieuCaoDau)}):Play()
				DichVuTween:Create(MuiTen, TweenInfo.new(0.2), {Rotation = 0}):Play()
				VachNgan.Visible = false
			end
			task.delay(0.21, CapNhatVungCuon)
		end

		if DuLieu.ChucNang then
			for k, chucNang in ipairs(DuLieu.ChucNang) do
				TaoMuc(NoiDung, chucNang, function()
					if DangMoRong then CapNhatTrangThai() end
				end, k)
			end
		end

		DauKhoi.MouseButton1Click:Connect(function()
			DangMoRong = not DangMoRong
			CapNhatTrangThai()
		end)
		task.delay(0.1, CapNhatTrangThai)
	end

	for i, DuLieuItem in ipairs(DuLieu) do
		if i % 2 ~= 0 then TaoKhoiDuLieu(DuLieuItem, CotTrai) else TaoKhoiDuLieu(DuLieuItem, CotPhai) end
	end
end

return KhungCuon
