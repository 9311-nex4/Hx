local TweenService = game:GetService("TweenService")
local Animation = {}

local INFOS = {
	Mo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Dong = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
	FadeNhanh = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	FadeCham = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	NutHover = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	NutDongPop = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
}

local function RunTween(obj, info, props)
	if obj then TweenService:Create(obj, info, props):Play() end
end

function Animation.HoverNut(btn, isHover, colorNomal, colorHover)
	local targetSize = isHover and UDim2.new(1, 0, 0, 56) or UDim2.new(1, 0, 0, 45)
	local targetColor = isHover and colorHover or colorNomal
	local targetTextSize = isHover and 20 or 18
	
	RunTween(btn, INFOS.NutHover, {
		Size = targetSize,
		BackgroundColor3 = targetColor,
		TextSize = targetTextSize
	})
end

function Animation.HoverNutDong(objs, isHover, configColors, configSizes)
	if isHover then
		RunTween(objs.NutDong, INFOS.NutHover, {Size = configSizes.Hover, BackgroundColor3 = configColors.Hover, TextSize = 22})
		RunTween(objs.Padding, INFOS.NutHover, {PaddingRight = UDim.new(0, 0.5)})
		objs.Vien.Transparency = 0.4
	else
		RunTween(objs.NutDong, INFOS.NutHover, {Size = configSizes.Normal, BackgroundColor3 = configColors.Normal, TextSize = 18})
		RunTween(objs.Padding, INFOS.NutHover, {PaddingRight = UDim.new(0, 0)})
		objs.Vien.Transparency = 0.8
	end
end

function Animation.NhanNut(btn, sizeNhan)
	RunTween(btn, INFOS.FadeNhanh, {Size = sizeNhan})
end

function Animation.MoGiaoDien(objs, configs)
	RunTween(objs.Khung, INFOS.FadeCham, {BackgroundTransparency = 1})
	RunTween(objs.Icon, INFOS.Mo, {Size = configs.IconDau, ImageTransparency = 0})

	task.wait(0.5)

	RunTween(objs.Khung, INFOS.Mo, {Size = configs.KhungCuoi, BackgroundTransparency = 0.15})

	local IconTween = TweenService:Create(objs.Icon, INFOS.Mo, {
		Size = configs.IconCuoi,
		Position = configs.IconCuoiPos,
		AnchorPoint = Vector2.new(0.5, 0.5)
	})
	IconTween:Play()

	IconTween.Completed:Connect(function()
		RunTween(objs.TieuDe, INFOS.FadeCham, {TextTransparency = 0})
		RunTween(objs.NutDong, INFOS.FadeCham, {BackgroundTransparency = 0.6, TextTransparency = 0})
		RunTween(objs.VienNutDong, INFOS.FadeCham, {Transparency = 0.8})
		RunTween(objs.DanhSach, INFOS.FadeCham, {BackgroundTransparency = 0.6, ScrollBarImageTransparency = 0})

		for _, child in ipairs(objs.DanhSach:GetChildren()) do
			if child:IsA("TextButton") then
				RunTween(child, INFOS.FadeCham, {BackgroundTransparency = 0, TextTransparency = 0})
			end
		end
	end)
end

function Animation.DongGiaoDien(objs, configs, callbackDone)
	local PopAnim = TweenService:Create(objs.NutDong, INFOS.NutDongPop, {Size = configs.NutDongPop})
	PopAnim:Play()

	PopAnim.Completed:Connect(function()
		RunTween(objs.TieuDe, INFOS.FadeNhanh, {TextTransparency = 1})
		RunTween(objs.DanhSach, INFOS.FadeNhanh, {BackgroundTransparency = 1, ScrollBarImageTransparency = 1})
		RunTween(objs.NutDong, INFOS.FadeNhanh, {BackgroundTransparency = 1, TextTransparency = 1})
		RunTween(objs.VienNutDong, INFOS.FadeNhanh, {Transparency = 1})

		for _, child in ipairs(objs.DanhSach:GetChildren()) do
			if child:IsA("GuiObject") then
				RunTween(child, INFOS.FadeNhanh, {BackgroundTransparency = 1})
				if child:IsA("TextButton") or child:IsA("TextLabel") then
					RunTween(child, INFOS.FadeNhanh, {TextTransparency = 1})
				end
			end
		end

		task.delay(0.2, function()
			RunTween(objs.Icon, INFOS.Dong, {Position = configs.IconDauPos, Size = configs.IconDau})
			
			local DongKhung = TweenService:Create(objs.Khung, INFOS.Dong, {
				Size = configs.KhungDau,
				BackgroundTransparency = 1
			})
			DongKhung:Play()

			DongKhung.Completed:Connect(function()
				local FadeCuoi = TweenService:Create(objs.Icon, INFOS.FadeCham, {ImageTransparency = 1, Size = UDim2.new(0,0,0,0)})
				FadeCuoi:Play()
				FadeCuoi.Completed:Connect(callbackDone)
			end)
		end)
	end)
end

return Animation
