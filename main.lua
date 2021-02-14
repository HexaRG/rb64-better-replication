--//Written by Hexa

repeat game:GetService("RunService").RenderStepped:Wait() until game:GetService("Players").LocalPlayer ~= nil

--//Config

local Glitchy = false -- Makes it look like you're glitchy (this will not show on your client)
local ShowLocalPlayer = false -- Creates a fake of yourself (Debug)
local BetterDotAnimation = true -- Improves the dot animation to no longer be static
local DotRangeCap = true -- Whether to check the distance from the dot and the players head and cap it
local DotRange = 2 -- The maximum distance that the dot can go
local SpecialDetectionNum = 385 -- This is used to detect if a player is using the script, it works by spoofing the health as the number that is specified if the health at the max
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
local FaceIds = { -- Stores all of the face textures
	"rbxassetid://1451094768"; -- Default Face
	"rbxassetid://1451124286"; -- Happy Face
	"rbxassetid://1451124533"; -- Hurt Face
	"rbxassetid://1451125125"; -- Blink 1 
	"rbxassetid://1451125369"; -- Blink 2
}
local AlwaysReplicate = false -- Whether or not to always replicate even if the Client is paused
local ChatBubbles = true -- Whether or not to enable chat bubbles

--//Code

-- Check if we already ran the script, if so disconnect all of the old events (used for development)
if _G.BetterReplication then
	if _G.BetterReplication.Render then
		_G.BetterReplication.Render:Disconnect()
	end
	if _G.BetterReplication.PlayerAdded then
		_G.BetterReplication.PlayerAdded:Disconnect()
	end
	if _G.BetterReplication.PlayerRemoved then
		_G.BetterReplication.PlayerRemoved:Disconnect()
	end
	if _G.BetterReplication.Chat then
		for _,ChatEvent in pairs(_G.BetterReplication.Chat) do
			ChatEvent:Disconnect()
		end
	end
	if workspace:FindFirstChild("fakes") then
		workspace.fakes:ClearAllChildren()
	end
else
	_G.BetterReplication = {}
end

-- Attempts to get the script environment, if it fails wait 1 frame
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
	-- Get the client script environment
	repeat Client = TryGetSenv(ClientObj) until Client ~= nil
	game.ReplicatedFirst:RemoveDefaultLoadingScreen()
	-- Renames the replicate remote to prevent the CharacterScript from replicating
	if not workspace:WaitForChild("share"):FindFirstChild("ActualReplicate") then
		workspace.share:WaitForChild("replicate").Name = "ActualReplicate"
		local FakeRemote = Instance.new("RemoteEvent",workspace.share)
		FakeRemote.Name = "replicate"
	end
	-- Replaces workspace.plam with a fake folder to prevent the CharacterScript from rendering other players
	if not workspace:FindFirstChild("realplam") then
		local fakeplams = Instance.new("Folder",workspace)
		workspace:WaitForChild("plam").Name = "realplam"
		fakeplams.Name = "plam"
		workspace.realplam.ChildRemoved:connect(function(plam)
			if workspace.fakes:FindFirstChild(plam.Name) then
				local FakeModel = workspace.fakes[plam.Name]
				Client.particle("cloud", 8, true, FakeModel.torso.CFrame)
				FakeModel:Destroy()
			end
		end)
	end
	local SpecialPlayers = {} -- Stores all of the known players using this script (SpecialDetectionNum must be the same on your client and their client)
	local Stomp = 0
	local Stomped = 0
	if ChatBubbles then
		_G.BetterReplication.Chat = {}
		local function PlayerAdded(Player)
			if Player == Client.lp then
				return
			end
			_G.BetterReplication.Chat[Player] = Player.Chatted:Connect(function(Message)
				local FakeModel = workspace.fakes[Player.Name]
				if FakeModel then
					local Plam = workspace.realplam[Player.Name]
					local TalkRs = game:GetService("RunService").RenderStepped:Connect(function()
						if (os.clock()*6)%1 > .5 then
							Plam.faceid.Value = 2
						else
							Plam.faceid.Value = 1
						end
					end)
					if FakeModel.head:FindFirstChild("ChatBillboard") then
						FakeModel.head.ChatBillboard:Destroy()
					end
					local ChatBillboard = Instance.new("BillboardGui",FakeModel.head)
					ChatBillboard.Name = "ChatBillboard"
					ChatBillboard.MaxDistance = math.huge
					ChatBillboard.LightInfluence = 0
					ChatBillboard.Size = UDim2.new(16,0,0.7,0)
					ChatBillboard.StudsOffset = Vector3.new(0,4,0)
					local ChatText = Instance.new("TextLabel",ChatBillboard)
					ChatText.Name = "ChatText"
					ChatText.Text = Message
					ChatText.Font = Enum.Font.SourceSansBold
					ChatText.TextScaled = true
					ChatText.Size = UDim2.new(1,0,1,0)
					ChatText.BackgroundTransparency = 1
					ChatText.TextColor3 = Color3.fromHSV(0,0,1)
					ChatText.TextStrokeColor3 = Color3.fromHSV(0,0,0.6470588235294118)
					local Counter = 0
					while Counter < #Message do
						Counter += 1
						local PitchVal = Client.map.settings:FindFirstChild("minor") and Client.min or Client.maj
						FakeModel.head.BeeboTextSound.PlaybackSpeed = 2 ^ (PitchVal[math.random(#PitchVal)] / 12);
						FakeModel.head.BeeboTextSound:Play()
						wait(.15)
					end
					TalkRs:Disconnect()
					Plam.faceid.Value = 1
					wait(5)
					if ChatBillboard then
						ChatBillboard:Destroy()
					end
				end
			end)
		end
		local function PlayerRemoved(Player)
			_G.BetterReplication.Chat[Player]:Disconnect()
		end
		_G.BetterReplication.PlayerAdded = game:GetService("Players").PlayerAdded:Connect(PlayerAdded)
		_G.BetterReplication.PlayerRemoved = game:GetService("Players").PlayerRemoving:Connect(PlayerRemoved)
		for _,Player in pairs(game:GetService("Players"):GetPlayers()) do
			PlayerAdded(Player)
		end
	end
	_G.BetterReplication.Render = game:GetService("RunService").RenderStepped:Connect(function(DeltaTime)
		if not Client.plam or not Client.playing or (ClientObj:FindFirstChild("title") and ClientObj.title.Playing) then
			return
		end
		local ReplicationTable = {}
		for _, PlamObj in pairs(Client.plam:GetChildren()) do
			if PlamObj.Name == "health" then
				if PlamObj.Value == 4 then
					--Spoof the health so other clients can detect the script
					PlamObj.Value = SpecialDetectionNum
				end
			end
			if PlamObj.Name == "faceid" and Stomp-os.clock() >= 0 then
				--Spoof the faceid as 6 if the player is attempting to deal damage to a nearby player
				PlamObj.Value = 6
			end
			ReplicationTable[PlamObj.Name] = PlamObj.Value
		end
		if Glitchy then
			local PlamBackup = {}
			
			for _, PlamObj in pairs(Client.plam:GetChildren()) do
				PlamBackup[PlamObj] = PlamObj.Value
				if typeof(ReplicationTable[PlamObj.Name]) == "CFrame" and math.random(1,30) == 1 then
					ReplicationTable[PlamObj.Name] *= CFrame.new(math.random(-255,255)/150,math.random(-255,255)/150,math.random(-255,255)/150) * CFrame.Angles(math.random(-255,255)/100,math.random(-255,255)/100,math.random(-255,255)/100)
					PlamObj.Value = ReplicationTable[PlamObj.Name]
				end
				if typeof(ReplicationTable[PlamObj.Name]) == "boolean" and math.random(1,100) == 1 then
					ReplicationTable[PlamObj.Name] = not ReplicationTable[v.Name]
					PlamObj.Value = ReplicationTable[PlamObj.Name]
				end
				if typeof(ReplicationTable[PlamObj.Name]) == "number" and math.random(1,10) == 1 then
					ReplicationTable[PlamObj.Name] = ReplicationTable[v.Name] + math.random(-2,2)
					PlamObj.Value = ReplicationTable[PlamObj.Name]
				end
			end

			--Restore the plam (this doesn't work idk why)
			for PlamObj, BackupValue in pairs(PlamBackup) do
				PlamObj.Value = BackupValue
			end
		end
		if not Client.paused or AlwaysReplicate then
			workspace.share.ActualReplicate:FireServer(Client.plam, ReplicationTable)
		end
		local MPSLerpAlpha = DeltaTime * 5 or DeltaTime
		local PoseLerp = DeltaTime
		for _, PlamObj in pairs(workspace.realplam:GetChildren()) do
			if PlamObj.Name ~= Client.lp.Name or ShowLocalPlayer then
				local Success,Error = pcall(function()
					if PlamObj.health.Value == SpecialDetectionNum then
						SpecialPlayers[PlamObj.Name] = true
					end
					if (PlamObj.mps.Value.p - Client.tpc.p).Magnitude < Client.rendist or true then
						PlamObj.mps.lerp.Value = PlamObj.mps.lerp.Value:Lerp(PlamObj.mps.Value, MPSLerpAlpha)
						local ValidMap = string.sub(PlamObj.map.Value,1,#Client.map.Name) == Client.map.Name
						local ValidRoom = PlamObj.map.Value ~= Client.map.Name .. (Client.room or (Client.levelid or ""))
						if HidePlayers and ( (ValidRoom or (ValidMap and not Hide.OtherRooms) ) or (PlamObj.map.Value == "Boss" and Hide.Boss) or (PlamObj.map.Value == "credits" and Hide.Credits) or (PlamObj.map.Value == "MAKE" and Hide.LevelEditor) ) then
							if workspace.fakes:FindFirstChild(PlamObj.Name) then
								workspace.fakes[PlamObj.Name]:Destroy()
								return
							end
						elseif workspace.fakes:FindFirstChild(PlamObj.Name) then
							local FakeModel = workspace.fakes[PlamObj.Name]
							if PlayerDamage and PlamObj.faceid.Value == 6 and not (Stomped-os.clock() >= 0) then
								--Detects if the player is attempting to deal damage (faceid:6)
								if (FakeModel.torso.Position - Client.char.Position).Magnitude < 5 then
									Stomped = os.clock()+.2
									Client.damage()
								end
							end
							if SpecialPlayers[PlamObj.Name] then
								PoseLerp = math.clamp(DeltaTime * 5, 0, 1/10)
								if RGBNames then
									FakeModel.head.BillboardGui.TextLabel.TextColor3 = Color3.fromHSV((os.clock()/8)%1,1,1)
									FakeModel.head.BillboardGui.TextLabel.TextStrokeColor3 = Color3.fromHSV((os.clock()/8)%1,1,0.6470588235294118)
								else
									FakeModel.head.BillboardGui.TextLabel.TextColor3 = Color3.fromHSV(0,0,1)
									FakeModel.head.BillboardGui.TextLabel.TextStrokeColor3 = Color3.fromHSV(0,0,0.6470588235294118)
								end
							else
								PoseLerp = DeltaTime
							end
							-- Pose the player model
							Client.anim2(FakeModel, PlamObj, PoseLerp)
							if not BetterDotAnimation then
								FakeModel.dot.CFrame = FakeModel.head.CFrame + Vector3.new(0, 2)
							else
								local TargetPosition = FakeModel.head.Position + FakeModel.head.CFrame.upVector * Client.tscale.Y * 2
								FakeModel.dot.vel.Value = FakeModel.dot.vel.Value + (TargetPosition - FakeModel.dot.Position) * DeltaTime * 8 - FakeModel.dot.vel.Value * math.min(1, DeltaTime * 5)
								if FakeModel.dot.Position.Y < FakeModel.head.Position.Y + FakeModel.head.CFrame.upVector.Y * 1.5 then
									FakeModel.dot.CFrame = FakeModel.dot.CFrame - FakeModel.dot.Position + Client.v2(FakeModel.dot.Position, FakeModel.head.Position.Y + FakeModel.head.CFrame.upVector.Y * 1.5)
								end
								if not (DotRange * Client.tscale.Y < (FakeModel.dot.Position - TargetPosition).Magnitude) or not DotRangeCap then
									FakeModel.dot.CFrame = FakeModel.dot.CFrame + FakeModel.dot.vel.Value * DeltaTime * 10
								else
									FakeModel.dot.CFrame = FakeModel.dot.CFrame - FakeModel.dot.CFrame.p + TargetPosition + CFrame.new(TargetPosition, FakeModel.dot.Position).lookVector * 1.9 * Client.tscale.Y
									FakeModel.dot.vel.Value = Vector3.new()
								end
							end
							--Update the skateboard CFrame
							FakeModel.trs.board.CFrame = PlamObj.skate.Value and FakeModel.torso.CFrame * Client.cfro(0, -1.7, 0) * CFrame.Angles(0, 1.5, 0) or FakeModel.torso.CFrame * Client.cfro(0, 0, 1) * CFrame.Angles(1.5, 1, 0)
							--[[ Update the accessories:
								battery pack,
								battery 1,
								battery 2,
								battery 3,
								battery 4,
								jetpack,
							    skateboard
								flamethrower,
								hats
							]]
							Client.trsCF(FakeModel, PlamObj.health.Value, 0, PlamObj.hasfly.Value, PlamObj.hasboard.Value, PlamObj.hat.Value, PlamObj.bees.Value, PlamObj.hasflame.Value, PlamObj.hastoy.Value)
							-- Update the skin if it has changed
							if PlamObj.skin.Value ~= PlamObj.skin.last.Value then
								Client.toskin(PlamObj.skin.Value, FakeModel)
								PlamObj.skin.last.Value = PlamObj.skin.Value
							end
							-- Push beebo if PlayerCollisions is enabled
							if (FakeModel.torso.Position - Client.char.Position).Magnitude < 5 then
                                if PlayerCollisions then
                                    local push = Client.v2(Client.char.Position - FakeModel.torso.Position) * (DeltaTime*60)
                                    Client.char.Velocity += push
                                end
                                if PlayerDamage and not Client.ground and not (Stomp-os.clock() >= 0) then
                                    Client.char.Velocity = Client.v2(Client.char.Velocity, 30)
									FakeModel.torso.damage:Play()
									Stomp = os.clock()+.2
                                end
							end
							-- Update the face texture
							local DesiredFaceTexture = FaceIds[PlamObj.faceid.Value] or FaceIds[1]
							FakeModel.head.face.Texture = DesiredFaceTexture
							if PlamObj.faceid.Value == 3 then
								--Enable damage flashing if the hurt face is detected
                                if DamageFlashing then
                                    local t = 0
                                    if (os.clock()*6)%1 > .5 then
                                        t = 1
                                    end
                                    for i, v in pairs(FakeModel:GetChildren()) do
                                        if v.Name ~= "trs" then
                                            v.Transparency = t
                                        end
                                    end
                                end
							else
								--Revert the damage flashing transparency
                                if DamageFlashing then
                                    for i, v in pairs(FakeModel:GetChildren()) do
                                        if v.Name ~= "trs" then
                                            v.Transparency = 0
                                        end
                                    end
                                end
							end
						else --Fake doesn't exist
							-- Create a fake
							local NewFakeModel = Client.rf.vis:Clone()
							NewFakeModel.Name = PlamObj.Name
							NewFakeModel.Parent = workspace.fakes
							PlamObj.mps.lerp.Value = PlamObj.mps.Value
							Client.loadvis(NewFakeModel)
							-- Update the skin
							Client.toskin(PlamObj.skin.Value, NewFakeModel)
							-- Pose the player model
							Client.anim2(NewFakeModel, PlamObj, 1/10)
							--Update the skateboard CFrame
							NewFakeModel.trs.board.CFrame = PlamObj.skate.Value and NewFakeModel.torso.CFrame * Client.cfro(0, -1.7, 0) * CFrame.Angles(0, 1.5, 0) or NewFakeModel.torso.CFrame * Client.cfro(0, 0, 1) * CFrame.Angles(1.5, 1, 0)
							--[[ Update the accessories:
								battery pack,
								battery 1,
								battery 2,
								battery 3,
								battery 4,
								jetpack,
							    skateboard
								flamethrower,
								hats
							]]
							Client.trsCF(NewFakeModel, PlamObj.health.Value, 0, PlamObj.hasfly.Value, PlamObj.hasboard.Value, PlamObj.hat.Value, PlamObj.bees.Value, PlamObj.hasflame.Value, PlamObj.hastoy.Value)
							local BeeboTextSound = ClientObj.text:Clone()
							BeeboTextSound.Parent = NewFakeModel.head
							BeeboTextSound.Name = "BeeboTextSound"
						end
					end
				end)
				if not Success and ReplicationErrorsReported then
					warn(Error)
				end
			end
		end
	end)
end

_G.BetterReplication.NewPlayerScript = game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts").ChildAdded:Connect(function(Client)
	if Client.Name == "CharacterScript" then
		if _G.BetterReplication.Render then
			_G.BetterReplication.Render:Disconnect()
		end
		if _G.BetterReplication.Chat then
			_G.BetterReplication.PlayerAdded:Disconnect()
			_G.BetterReplication.PlayerRemoved:Disconnect()
			for _,ChatEvent in pairs(_G.BetterReplication.Chat) do
				ChatEvent:Disconnect()
			end
		end
		Start(Client)
	end
end)

if game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):FindFirstChild("CharacterScript") then
	Start(game.Players.LocalPlayer.PlayerScripts.CharacterScript)
end