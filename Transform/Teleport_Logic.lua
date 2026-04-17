local TeleportLogic = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

TeleportLogic.DangBatClickTP = false
TeleportLogic.PhimClickTP = Enum.KeyCode.T
TeleportLogic.KetNoiClickTP = nil

local DiaDiemGame = {
	[0] = {"1", "2", "3"},
}

function TeleportLogic.LayDiaDiemGame(PlaceId)
	if DiaDiemGame[PlaceId] then
		return DiaDiemGame[PlaceId]
	else
		return {"Không có dữ liệu cho Game này"}
	end
end

function TeleportLogic.GetPlayers()
	local ds = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			table.insert(ds, plr.Name)
		end
	end
	if #ds == 0 then table.insert(ds, "Không có ai khác") end
	return ds
end

function TeleportLogic.TeleportToPlayer(TenNguoiChoi)
	local target = Players:FindFirstChild(TenNguoiChoi)
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
		end
	end
end

function TeleportLogic.TeleportToMouse()
	local mouse = LocalPlayer:GetMouse()
	if mouse.Target then
		local pos = mouse.Hit.p + Vector3.new(0, 3, 0)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(pos)
		end
	end
end

function TeleportLogic.SetClickTP(TrangThai)
	TeleportLogic.DangBatClickTP = TrangThai
	if TrangThai then
		if not TeleportLogic.KetNoiClickTP then
			TeleportLogic.KetNoiClickTP = UserInputService.InputBegan:Connect(function(input, processed)
				if processed or UserInputService:GetFocusedTextBox() then return end

				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if UserInputService:IsKeyDown(TeleportLogic.PhimClickTP) then
						TeleportLogic.TeleportToMouse()
					end
				end
			end)
		end
	else
		if TeleportLogic.KetNoiClickTP then
			TeleportLogic.KetNoiClickTP:Disconnect()
			TeleportLogic.KetNoiClickTP = nil
		end
	end
end

function TeleportLogic.SetKey(Key)
	TeleportLogic.PhimClickTP = Key
end

return TeleportLogic
