local NhanVat = {}
local State = { CurrentDummy = nil }

function NhanVat.CreateDummy()
	if State.CurrentDummy then State.CurrentDummy:Destroy() end
	local Player = game.Players.LocalPlayer
	local char = Player.Character
	local refCF = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5) or CFrame.new()

	local rig = Instance.new("Model"); rig.Name = "Dummy_Mau"
	Instance.new("Humanoid").Parent = rig

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"; root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1; root.Anchored = true; root.CFrame = refCF
	root.Parent = rig

	local head = Instance.new("Part")
	head.Name = "Head"; head.Size = Vector3.new(2, 1, 1)
	head.Color = Color3.fromRGB(255, 255, 0); head.Anchored = true
	head.CFrame = refCF * CFrame.new(0, 1.5, 0); head.Parent = rig

	local torso = Instance.new("Part")
	torso.Name = "Torso"; torso.Size = Vector3.new(2, 2, 1)
	torso.Color = Color3.fromRGB(200, 200, 200); torso.Anchored = true
	torso.CFrame = refCF; torso.Parent = rig

	rig.PrimaryPart = root
	rig.Parent = workspace
	State.CurrentDummy = rig
	return rig
end

function NhanVat.RemoveDummy()
	if State.CurrentDummy then
		State.CurrentDummy:Destroy()
		State.CurrentDummy = nil
	end
end

return NhanVat
