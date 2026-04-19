local TimKiem = {}
local TweenService = game:GetService("TweenService")

local TweenNhanh = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local TweenCuon  = TweenInfo.new(0.4,  Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

local MAU_HIGHLIGHT_BG   = Color3.fromRGB(70, 60, 10)   
local MAU_HIGHLIGHT_VIEN = Color3.fromRGB(255, 200, 50) 

local DanhSachHighlight = {}

local function XoaHighlight()
	for _, info in ipairs(DanhSachHighlight) do
		if info.Obj and info.Obj.Parent then
			pcall(function()
				info.Obj:SetAttribute("MauGoc", info.MauGoc)
				TweenService:Create(info.Obj, TweenNhanh, {
					BackgroundColor3  = info.MauGoc,
					BackgroundTransparency = info.DoTrongSuot,
				}):Play()
			end)
		end
		if info.Vien and info.Vien.Parent then
			pcall(function() info.Vien:Destroy() end)
		end
	end
	DanhSachHighlight = {}
end

local function LayText(obj)
	for _, child in ipairs(obj:GetChildren()) do
		if child:IsA("TextLabel") and child.Text ~= "" then
			return child.Text:match("^%s*(.-)%s*$")
		end
		if child:IsA("ScrollingFrame") then
			for _, sub in ipairs(child:GetChildren()) do
				if sub:IsA("TextLabel") and sub.Text ~= "" then
					return sub.Text:match("^%s*(.-)%s*$")
				end
			end
		end
	end
	if obj:IsA("TextButton") and obj.Text ~= "" then
		return obj.Text:match("^%s*(.-)%s*$")
	end
	return ""
end

local function TimScrollParent(obj)
	local p = obj.Parent
	while p do
		if p:IsA("ScrollingFrame") then return p end
		p = p.Parent
	end
	return nil
end

local function CuonDen(scrollFrame, targetObj)
	if not scrollFrame or not targetObj then return end
	task.spawn(function()
		task.wait(0.06)  
		if not targetObj.Parent or not scrollFrame.Parent then return end
		local relY = targetObj.AbsolutePosition.Y
		- scrollFrame.AbsolutePosition.Y
			+ scrollFrame.CanvasPosition.Y
		local targetY = math.max(0, relY - scrollFrame.AbsoluteSize.Y * 0.25)
		TweenService:Create(scrollFrame, TweenCuon, {
			CanvasPosition = Vector2.new(0, targetY)
		}):Play()
	end)
end

function TimKiem.LocDuLieu(Cuon, TuKhoa)
	TuKhoa = string.lower((TuKhoa or ""):match("^%s*(.-)%s*$"))
	XoaHighlight()
	if TuKhoa == "" then return end

	local ItemDauTien  = nil
	local ScrollDauTien = nil

	for _, obj in ipairs(Cuon:GetDescendants()) do
		if obj.Name == "Theme_NenMuc"
			and (obj:IsA("TextButton") or obj:IsA("Frame"))
		then
			local text = LayText(obj)
			if text ~= "" and string.find(string.lower(text), TuKhoa, 1, true) then

				local mauGoc      = obj:GetAttribute("MauGoc") or obj.BackgroundColor3
				local trongSuotGoc = obj.BackgroundTransparency

				local vien = Instance.new("UIStroke")
				vien.Name            = "TimKiem_Highlight"
				vien.Color           = MAU_HIGHLIGHT_VIEN
				vien.Thickness       = 2.5
				vien.Transparency    = 0
				vien.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				vien.Parent          = obj

				TweenService:Create(obj, TweenNhanh, {
					BackgroundColor3       = MAU_HIGHLIGHT_BG,
					BackgroundTransparency = 0.15,
				}):Play()

				table.insert(DanhSachHighlight, {
					Obj        = obj,
					MauGoc     = mauGoc,
					DoTrongSuot = trongSuotGoc,
					Vien       = vien,
				})

				if not ItemDauTien then
					ItemDauTien  = obj
					ScrollDauTien = TimScrollParent(obj)
				end
			end
		end
	end

	if ItemDauTien and ScrollDauTien then
		CuonDen(ScrollDauTien, ItemDauTien)
	end
end

return TimKiem