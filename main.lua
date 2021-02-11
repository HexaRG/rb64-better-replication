--//Written by Hexa

repeat game:GetService("RunService").RenderStepped:Wait() until game:GetService("Players").LocalPlayer ~= nil

--//Config

local Glitchy = false -- Makes you look like you're having a stroke (this will not show on your client)
local ShowLocalPlayer = false -- Creates a fake of yourself (Debug)
local BetterDotAnimation = true -- Improves the dot animation to no longer be static
local DotRangeCap = true -- Whether to check the distance from the dot and the players head and cap it
local DotRange = 2 -- The maximum distance that the dot can go
local SpecialDetectionNum = 69 -- This is used to detect if a player is using the script, it works by spoofing the health as the number that is specified if the health at the max
local RGBNames = true -- Whether or not players using this script should have Rainbow names
local ReplicationErrorsReported = true -- Whether or not to log plam errors
local Hide = { -- Whether or not to hide other players when they're in these states
	Credits = true;
	LevelEditor = false;
	Boss = true;
	OtherRooms = true;
}
local HidePlayers = true -- Whether or not to hide other players
local PlayerCollisions = true -- Whether or not other players can push you
local PlayerDamage = true -- Whether or not you can take or deal damage to other players (you can only damage players using this script)
local DamageFlashing = true -- Implements a damage flashing animation

--//Code

-- Check if we already ran the script, if so disconnect all of the old events (used for development)
if _G.BetterReplication then
	_G.BetterReplication.Render:Disconnect()
	_G.BetterReplication.NewPlayerScript:Disconnect()
	workspace.fakes:ClearAllChildren()
else
	_G.BetterReplication = {}
end

function TryGetSenv(Obj)
	local Senv
	pcall(function()
		Senv = getsenv(Obj)
	end)
	if Senv then
		return Senv
	else
		game:GetService("RunService").RenderStepped:Wait()
	end
end

function Start(ClientObj)
	local Client
	repeat Client = TryGetSenv(ClientObj) until Client ~= nil
	if not workspace:WaitForChild("share"):FindFirstChild("ActualReplicate") then
		workspace.share:WaitForChild("replicate").Name = "ActualReplicate"
		local FakeRemote = Instance.new("RemoteEvent",workspace.share)
		FakeRemote.Name = "replicate"
	end
	if not workspace:FindFirstChild("realplam") then
		local realplams = Instance.new("Folder",workspace)
		workspace:WaitForChild("plam").Name = "realplam"
		realplams.Name = "plam"
		realplams.ChildRemoved:connect(function(plam)
			if workspace.fakes:FindFirstChild(plam.Name) then
				local fakemodel = workspace.fakes[plam.Name]
				Client.particle("cloud", 8, true, fakemodel.torso.CFrame)
				fakemodel:Destroy()
			end
		end)
	end
	Client.studio = true
	local SpecialPlayers = {} -- Stores all of the known players using this script (SpecialDetectionNum must be the same on your client and their client)
	local Stomp = 0
	local Stomped = 0
	_G.BetterReplication.Render = game:GetService("RunService").RenderStepped:Connect(function(DeltaTime)
		if not Client.plam or not Client.playing or (ClientObj:FindFirstChild("title") and ClientObj.title.Playing) then
			return
		end
		local PlamBackup = {}
		local ReplicationTable = {}
		for i, v in pairs(Client.plam:GetChildren()) do
			if v.Name == "health" then
				if v.Value == 4 then
					v.Value = SpecialDetectionNum
				end
			end
			if v.Name == "faceid" and Stomp-os.clock() >= 0 then
				v.Value = 6
			end
			PlamBackup[v] = v.Value
			ReplicationTable[v.Name] = v.Value
		end
		if Glitchy then
			for i, v in pairs(Client.plam:GetChildren()) do
				if typeof(ReplicationTable[v.Name]) == "CFrame" and math.random(1,30) == 1 then
					ReplicationTable[v.Name] *= CFrame.new(math.random(-255,255)/150,math.random(-255,255)/150,math.random(-255,255)/150) * CFrame.Angles(math.random(-255,255)/100,math.random(-255,255)/100,math.random(-255,255)/100)
					v.Value = ReplicationTable[v.Name]
				end
				if typeof(ReplicationTable[v.Name]) == "boolean" and math.random(1,100) == 1 then
					ReplicationTable[v.Name] = not ReplicationTable[v.Name]
					v.Value = ReplicationTable[v.Name]
				end
				if typeof(ReplicationTable[v.Name]) == "number" and math.random(1,10) == 1 then
					ReplicationTable[v.Name] = ReplicationTable[v.Name] + math.random(-2,2)
					v.Value = ReplicationTable[v.Name]
				end
			end
		end
		if not Client.paused then
			workspace.share.ActualReplicate:FireServer(Client.plam, ReplicationTable)
		end
		for i, v in pairs(PlamBackup) do
			i.Value = v
		end
		local MPSLerpAlpha = DeltaTime * 5 or DeltaTime
		local PoseLerp = DeltaTime
		for i, plam in pairs(workspace.realplam:GetChildren()) do
			if plam.Name ~= Client.lp.Name or ShowLocalPlayer then
				local success,err = pcall(function()
					if plam.health.Value == SpecialDetectionNum then
						SpecialPlayers[plam.Name] = true
					end
					if (plam.mps.Value.p - Client.tpc.p).Magnitude < Client.rendist or true then
						plam.mps.lerp.Value = plam.mps.lerp.Value:Lerp(plam.mps.Value, MPSLerpAlpha)
						local ValidMap = string.sub(plam.map.Value,1,#Client.map.Name) == Client.map.Name
						local ValidRoom = plam.map.Value ~= Client.map.Name .. (Client.room or (Client.levelid or ""))
						if HidePlayers and ( (ValidRoom or (ValidMap and not Hide.OtherRooms) ) or (plam.map.Value == "Boss" and Hide.Boss) or (plam.map.Value == "credits" and Hide.Credits) or (plam.map.Value == "MAKE" and Hide.LevelEditor) ) then
							if workspace.fakes:FindFirstChild(plam.Name) then
								workspace.fakes[plam.Name]:Destroy()
								return
							end
						elseif workspace.fakes:FindFirstChild(plam.Name) then
							local fakemodel = workspace.fakes[plam.Name]
							if PlayerDamage and plam.faceid.Value == 6 and not (Stomped-os.clock() >= 0) then
								if (fakemodel.torso.Position - Client.char.Position).Magnitude < 5 then
									--Client.psound(Client.vis.torso,"damage")
									Stomped = os.clock()+.2
									Client.damage()
								end
							end
							if SpecialPlayers[plam.Name] then
								PoseLerp = math.clamp(DeltaTime * 5, 0, 1/10)
								if RGBNames then
									fakemodel.head.BillboardGui.TextLabel.TextColor3 = Color3.fromHSV((os.clock()/8)%1,1,1)
								else
									fakemodel.head.BillboardGui.TextLabel.TextColor3 = Color3.fromHSV(0,0,1)
								end
							else
								PoseLerp = DeltaTime
							end
							Client.anim2(fakemodel, plam, PoseLerp)
							if not BetterDotAnimation then
								fakemodel.dot.CFrame = fakemodel.head.CFrame + Vector3.new(0, 2)
							else
								local TargetPosition = fakemodel.head.Position + fakemodel.head.CFrame.upVector * Client.tscale.Y * 2
								fakemodel.dot.vel.Value = fakemodel.dot.vel.Value + (TargetPosition - fakemodel.dot.Position) * DeltaTime * 8 - fakemodel.dot.vel.Value * math.min(1, DeltaTime * 5)
								if fakemodel.dot.Position.Y < fakemodel.head.Position.Y + fakemodel.head.CFrame.upVector.Y * 1.5 then
									fakemodel.dot.CFrame = fakemodel.dot.CFrame - fakemodel.dot.Position + Client.v2(fakemodel.dot.Position, fakemodel.head.Position.Y + fakemodel.head.CFrame.upVector.Y * 1.5)
								end
								if not (DotRange * Client.tscale.Y < (fakemodel.dot.Position - TargetPosition).Magnitude) or not DotRangeCap then
									fakemodel.dot.CFrame = fakemodel.dot.CFrame + fakemodel.dot.vel.Value * DeltaTime * 10
								else
									fakemodel.dot.CFrame = fakemodel.dot.CFrame - fakemodel.dot.CFrame.p + TargetPosition + CFrame.new(TargetPosition, fakemodel.dot.Position).lookVector * 1.9 * Client.tscale.Y
									fakemodel.dot.vel.Value = Vector3.new()
								end
							end
							fakemodel.trs.board.CFrame = plam.skate.Value and fakemodel.torso.CFrame * Client.cfro(0, -1.7, 0) * CFrame.Angles(0, 1.5, 0) or fakemodel.torso.CFrame * Client.cfro(0, 0, 1) * CFrame.Angles(1.5, 1, 0)
							Client.trsCF(fakemodel, plam.health.Value, 0, plam.hasfly.Value, plam.hasboard.Value, plam.hat.Value, plam.bees.Value, plam.hasflame.Value, plam.hastoy.Value)
							if plam.skin.Value ~= plam.skin.last.Value then
								Client.toskin(plam.skin.Value, fakemodel)
								plam.skin.last.Value = plam.skin.Value
							end
							if (fakemodel.torso.Position - Client.char.Position).Magnitude < 5 then
                                if PlayerCollisions then
                                    local push = Client.v2(Client.char.Position - fakemodel.torso.Position) * (DeltaTime*60)
                                    Client.char.Velocity += push
                                end
                                if PlayerDamage and not Client.ground and not (Stomp-os.clock() >= 0) then
                                    Client.char.Velocity = Client.v2(Client.char.Velocity, 30)
									fakemodel.torso.damage:Play()
									Stomp = os.clock()+.2
                                end
							end
							if plam.faceid.Value == 2 then
								fakemodel.head.face.Texture = "rbxassetid://1451124286"
								return
							elseif plam.faceid.Value == 3 then
								fakemodel.head.face.Texture = "rbxassetid://1451124533"
                                if DamageFlashing then
                                    local t = 0
                                    if (os.clock()*6)%1 > .5 then
                                        t = 1
                                    end
                                    for i, v in pairs(fakemodel:GetChildren()) do
                                        if v.Name ~= "trs" then
                                            v.Transparency = t
                                        end
                                    end
                                end
								return
							elseif plam.faceid.Value == 4 then
								fakemodel.head.face.Texture = "rbxassetid://1451125125"
								return
							elseif plam.faceid.Value == 5 then
								fakemodel.head.face.Texture = "rbxassetid://1451125369"
								return
							else
								fakemodel.head.face.Texture = "rbxassetid://1451094768"
                                if DamageFlashing then
                                    for i, v in pairs(fakemodel:GetChildren()) do
                                        if v.Name ~= "trs" then
                                            v.Transparency = 0
                                        end
                                    end
                                end
								return
							end
						else
							local newfakemodel = Client.rf.vis:Clone()
							newfakemodel.Name = plam.Name
							newfakemodel.Parent = workspace.fakes
							plam.mps.lerp.Value = plam.mps.Value
							Client.loadvis(newfakemodel)
							Client.toskin(plam.skin.Value, newfakemodel)
							Client.anim2(newfakemodel, plam, 1/10)
							newfakemodel.trs.board.CFrame = plam.skate.Value and newfakemodel.torso.CFrame * Client.cfro(0, -1.7, 0) * CFrame.Angles(0, 1.5, 0) or newfakemodel.torso.CFrame * Client.cfro(0, 0, 1) * CFrame.Angles(1.5, 1, 0)
							Client.trsCF(newfakemodel, plam.health.Value, 0, plam.hasfly.Value, plam.hasboard.Value, plam.hat.Value, plam.bees.Value, plam.hasflame.Value, plam.hastoy.Value)
						end
					end
				end)
				if not success and ReplicationErrorsReported then warn(err) end
			end
		end
	end)
end
_G.BetterReplication.NewPlayerScript = game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts").ChildAdded:Connect(function(Client)
	if Client.Name == "CharacterScript" then
		if _G.BetterReplication.Render then
			_G.BetterReplication.Render:Disconnect()
		end
		Start(Client)
	end
end)
if game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):FindFirstChild("CharacterScript") then
	Start(game.Players.LocalPlayer.PlayerScripts.CharacterScript)
end