local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ThuVien = {}

ThuVien.Styles = {
	Mo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Dong = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
	Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Pop = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Fade = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Keo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) 
}

local function ChayTween(doiTuong, tweenInfo, properties)
	if doiTuong and properties then 
		TweenService:Create(doiTuong, tweenInfo, properties):Play() 
	end
end

function ThuVien.Hover(doiTuong, trangThai, propsVao, propsRa)
	local props = trangThai and propsVao or propsRa
	ChayTween(doiTuong, ThuVien.Styles.Smooth, props)
end

function ThuVien.Click(doiTuong)
	if not doiTuong then return end
	local sizeGoc = doiTuong.Size
	local tweenDown = TweenService:Create(doiTuong, ThuVien.Styles.Pop, {Size = UDim2.new(sizeGoc.X.Scale, sizeGoc.X.Offset - 4, sizeGoc.Y.Scale, sizeGoc.Y.Offset - 4)})
	tweenDown:Play()
	tweenDown.Completed:Connect(function()
		ChayTween(doiTuong, ThuVien.Styles.Pop, {Size = sizeGoc})
	end)
end

function ThuVien.KeoTha(khung, diemKeo)
	diemKeo = diemKeo or khung
	
	local dangKeo, dragInput, dragStart, startPos

	local function capNhat(input)
		local delta = input.Position - dragStart
		local viTriMoi = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
		TweenService:Create(khung, ThuVien.Styles.Keo, {Position = viTriMoi}):Play()
	end

	diemKeo.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dangKeo = true
			dragStart = input.Position
			startPos = khung.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dangKeo = false
				end
			end)
		end
	end)

	diemKeo.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dangKeo then
			capNhat(input)
		end
	end)
end

function ThuVien.MoGiaoDien(uiElements, configs)
	if uiElements.Khung then 
		uiElements.Khung.Size = configs.KhungDau
		uiElements.Khung.BackgroundTransparency = 1 
	end
	if uiElements.Icon then 
		uiElements.Icon.Size = configs.IconDau
		uiElements.Icon.Position = configs.IconDauPos
		uiElements.Icon.ImageTransparency = 0
	end

	ChayTween(uiElements.Khung, ThuVien.Styles.Fade, {BackgroundTransparency = 1})
	
	task.wait(0.2)
	ChayTween(uiElements.Khung, ThuVien.Styles.Mo, {Size = configs.KhungCuoi, BackgroundTransparency = configs.KhungTrans or 0.15})

	if uiElements.Icon then
		local tweenIcon = TweenService:Create(uiElements.Icon, ThuVien.Styles.Mo, {
			Size = configs.IconCuoi,
			Position = configs.IconCuoiPos,
			AnchorPoint = Vector2.new(0.5, 0.5)
		})
		tweenIcon:Play()

		tweenIcon.Completed:Connect(function()
			ChayTween(uiElements.TieuDe, ThuVien.Styles.Fade, {TextTransparency = 0})
			ChayTween(uiElements.NutDong, ThuVien.Styles.Fade, {BackgroundTransparency = 0.6, TextTransparency = 0})
			ChayTween(uiElements.VienNutDong, ThuVien.Styles.Fade, {Transparency = 0.8})
			ChayTween(uiElements.DanhSach, ThuVien.Styles.Fade, {BackgroundTransparency = 0.6, ScrollBarImageTransparency = 0})

			if uiElements.DanhSach then
				for _, con in ipairs(uiElements.DanhSach:GetChildren()) do
					if con:IsA("TextButton") then
						ChayTween(con, ThuVien.Styles.Fade, {BackgroundTransparency = 0, TextTransparency = 0})
					end
				end
			end
		end)
	end
end

function ThuVien.DongGiaoDien(uiElements, configs, callback)
	if uiElements.NutDong then
		local pop = TweenService:Create(uiElements.NutDong, ThuVien.Styles.Pop, {Size = configs.NutDongPop})
		pop:Play()
		pop.Completed:Wait()
	end

	ChayTween(uiElements.TieuDe, ThuVien.Styles.Smooth, {TextTransparency = 1})
	ChayTween(uiElements.DanhSach, ThuVien.Styles.Smooth, {BackgroundTransparency = 1, ScrollBarImageTransparency = 1})
	ChayTween(uiElements.NutDong, ThuVien.Styles.Smooth, {BackgroundTransparency = 1, TextTransparency = 1})
	ChayTween(uiElements.VienNutDong, ThuVien.Styles.Smooth, {Transparency = 1})

	if uiElements.DanhSach then
		for _, con in ipairs(uiElements.DanhSach:GetChildren()) do
			if con:IsA("GuiObject") then
				ChayTween(con, ThuVien.Styles.Smooth, {BackgroundTransparency = 1, TextTransparency = 1})
			end
		end
	end

	task.wait(0.2)

	if uiElements.Icon then
		ChayTween(uiElements.Icon, ThuVien.Styles.Dong, {Position = configs.IconDauPos, Size = configs.IconDau})
	end
	
	local dongKhung = TweenService:Create(uiElements.Khung, ThuVien.Styles.Dong, {
		Size = configs.KhungDau,
		BackgroundTransparency = 1
	})
	dongKhung:Play()

	dongKhung.Completed:Connect(function()
		if uiElements.Icon then
			local fadeCuoi = TweenService:Create(uiElements.Icon, ThuVien.Styles.Fade, {ImageTransparency = 1, Size = UDim2.new(0,0,0,0)})
			fadeCuoi:Play()
			fadeCuoi.Completed:Connect(function()
				if callback then callback() end
			end)
		else
			if callback then callback() end
		end
	end)
end

return ThuVien
