local TimKiem = {}
local TweenService = game:GetService("TweenService")

local TweenNhanh = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local TweenCuon  = TweenInfo.new(0.4,  Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

local MAU_HIGHLIGHT_BG   = Color3.fromRGB(70, 60, 10)
local MAU_HIGHLIGHT_VIEN = Color3.fromRGB(255, 200, 50)

local DanhSachHighlight = {}
local CacheDescendants  = nil   
local CacheScrollParent = {}    

function TimKiem.XoaCache()
	CacheDescendants = nil
	CacheScrollParent = {}
end

local function XoaHighlight()
	for i = #DanhSachHighlight, 1, -1 do
		local info = DanhSachHighlight[i]
		local obj  = info.Obj
		if obj and obj.Parent then
			obj:SetAttribute("MauGoc", info.MauGoc)
			TweenService:Create(obj, TweenNhanh, {
				BackgroundColor3       = info.MauGoc,
				BackgroundTransparency = info.DoTrongSuot,
			}):Play()
		end
		local vien = info.Vien
		if vien and vien.Parent then
			vien:Destroy()
		end
		DanhSachHighlight[i] = nil
	end
end

local function LayText(obj)
	if obj:IsA("TextButton") and obj.Text ~= "" then
		return obj.Text:match("^%s*(.-)%s*$")
	end
	local label = obj:FindFirstChildWhichIsA("TextLabel")
	if label and label.Text ~= "" then
		return label.Text:match("^%s*(.-)%s*$")
	end
	local scroll = obj:FindFirstChildWhichIsA("ScrollingFrame")
	if scroll then
		local sub = scroll:FindFirstChildWhichIsA("TextLabel")
		if sub and sub.Text ~= "" then
			return sub.Text:match("^%s*(.-)%s*$")
		end
	end
	return ""
end

local function TimScrollParent(obj)
	if CacheScrollParent[obj] ~= nil then
		return CacheScrollParent[obj] or nil
	end
	local p = obj.Parent
	while p do
		if p:IsA("ScrollingFrame") then
			CacheScrollParent[obj] = p
			return p
		end
		p = p.Parent
	end
	CacheScrollParent[obj] = false
	return nil
end

local function CuonDen(scrollFrame, targetObj)
	if not scrollFrame or not targetObj then return end
	task.defer(function()
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

	if not CacheDescendants then
		CacheDescendants = Cuon:GetDescendants()
		Cuon.DescendantAdded:Once(function() CacheDescendants = nil end)
		Cuon.DescendantRemoving:Once(function() CacheDescendants = nil end)
	end

	local ItemDauTien, ScrollDauTien

	for _, obj in ipairs(CacheDescendants) do
		if obj.Name == "Theme_NenMuc"
			and (obj:IsA("TextButton") or obj:IsA("Frame"))
		then
			local text = LayText(obj)
			if text ~= "" and string.find(string.lower(text), TuKhoa, 1, true) then
				local mauGoc       = obj:GetAttribute("MauGoc") or obj.BackgroundColor3
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

				DanhSachHighlight[#DanhSachHighlight + 1] = {
					Obj         = obj,
					MauGoc      = mauGoc,
					DoTrongSuot = trongSuotGoc,
					Vien        = vien,
				}

				if not ItemDauTien then
					ItemDauTien   = obj
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
