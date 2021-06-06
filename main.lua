--//Written by Hexa

repeat game:GetService("RunService").RenderStepped:Wait() until game:GetService("Players").LocalPlayer ~= nil

--//Config

local DefaultConfig = {
	Glitchy = {
		Type = "bool";
		Val = false;
		Desc = "Makes it look like you're glitchy (This will not show on your client)";
		Hidden = true;
	};
	ShowLocalPlayer = {
		Type = "bool";
		Val = false;
		Desc = "Renders yourself (Debug)";
		Hidden = true;
	};
	BetterDotAnimation = {
		Type = "bool";
		Val = true;
		Desc = "When enabled other players will have animated dots on their heads";
		Hidden = false;
	};
	DotRangeCap = {
		Type = "bool";
		Val = true;
		Desc = "When enabled the script checks the distance from the dot and the players head and limits it to \"Config.DotRange\"";
		Hidden = true;
	};
	DotRange = {
		Type = "num";
		Val = 2;
		Desc = "The maximum distance the dot can reach";
		Hidden = true;
	};
	SpecialDetectionNum = {
		Type = "num";
		Val = 385;
		Desc = "Used to detect if a player is using the script, it works by spoofing the health as the specified number if the health is at the max (4)";
		Hidden = true;
	};
	RGBNames = {
		Type = "bool";
		Val = true;
		Desc = "When enabled players using this script will have Rainbow names";
		Hidden = false;
	};
	ReplicationErrorsReported = {
		Type = "bool";
		Val = true;
		Desc = "Logs plam errors to the console (F9)";
		Hidden = false;
	};
	Hide = {
		Type = "tbl";
		Val = {
			Credits = {
				Type = "bool";
				Val = true;
				Desc = "";
				Hidden = false;
			};
			LevelEditor = {
				Type = "bool";
				Val = true;
				Desc = "";
				Hidden = false;
			};
			Boss = {
				Type = "bool";
				Val = true;
				Desc = "";
				Hidden = false;
			};
			OtherRooms = {
				Type = "bool";
				Val = true;
				Desc = "";
				Hidden = false;
			};
		};
		Desc = "Which conditions should cause players to be hidden";
		Hidden = true;
	};
	HidePlayers = {
		Type = "bool";
		Val = true;
		Desc = "When this is enabled players will be hidden if they're not in the same map/room";
		Hidden = true;
	};
	PlayerCollisions = {
		Type = "bool";
		Val = true;
		Desc = "When this is enable other players can push you";
		Hidden = false;
	};
	PlayerDamage = {
		Type = "bool";
		Val = true;
		Desc = "When this is enabled you can take or deal damage to other players (you can only damage players using this script)";
		Hidden = false;
	};
	DamageFlashing = {
		Type = "bool";
		Val = true;
		Desc = "Implements a damage flashing animation when other playes take damage";
		Hidden = false;
	};
	FaceIds = {
		Type = "tbl";
		Val = {
			{
				Type = "txt";
				Val = "rbxassetid://1451094768";
				Desc = "Default";
				Hidden = false;
			};
			{
				Type = "txt";
				Val = "rbxassetid://1451124286";
				Desc = "Happy";
				Hidden = false;
			};
			{
				Type = "txt";
				Val = "rbxassetid://1451124533";
				Desc = "Hurt";
				Hidden = false;
			};
			{
				Type = "txt";
				Val = "rbxassetid://1451125125";
				Desc = "Blink 1";
				Hidden = false;
			};
			{
				Type = "txt";
				Val = "rbxassetid://1451125369";
				Desc = "Blink 2";
				Hidden = false;
			};
		};
		Desc = "All of the face textures";
		Hidden = false;
	};
	AlwaysReplicate = {
		Type = "bool";
		Val = false;
		Desc = "Always replicate even if the Client is paused";
		Hidden = true;
	};
	ChatBubbles = {
		Type = "bool";
		Val = true;
		Desc = "Enable chat bubbles";
		Hidden = false;
	};
	ShowAllSettings = {
		Type = "bool";
		Val = false;
		Desc = "When this is disabled some config items will be hidden";
	}
}

local Config = DefaultConfig

if isfile("rb64br/config.json") then
	local LoadedConfig = game:GetService("HttpService"):JSONDecode(readfile("rb64br/config.json"))
	for Key,Val in pairs(LoadedConfig) do
		Config[Key] = Val
	end
else
	writefile("rb64br/config.json",game:GetService("HttpService"):JSONEncode(DefaultConfig))
end

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
	if _G.BetterReplication.Events then
		for _,Event in pairs(_G.BetterReplication.Events) do
			Event:Disconnect()
		end
	end
	if _G.BetterReplication.ConfigEvents then
		for _,Event in pairs(_G.BetterReplication.ConfigEvents) do
			Event:Disconnect()
		end
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
local function TryGetSenv(Obj)
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

local function UpdateSettingName(Key,ConfigItem,Setting)
	Setting.Text = Key .. ": " .. tostring(ConfigItem.Val)
	Setting.outline.Text = Setting.Text
end

local function ApplySettingItemColors(Key,ConfigItem,Setting)
	if ConfigItem.Type == "bool" then
		if ConfigItem.Val then
			Setting.TextColor3 = Color3.fromRGB(66, 245, 81)
		else
			Setting.TextColor3 = Color3.fromRGB(245, 69, 66)
		end
	elseif ConfigItem.Type == "tbl" then
		Setting.TextColor3 = Color3.fromRGB(66, 108, 245)
	elseif ConfigItem.Type == "txt" then
		Setting.TextColor3 = Color3.fromRGB(179, 66, 245)
	elseif ConfigItem.Type == "num" then
		Setting.TextColor3 = Color3.fromRGB(237, 148, 64)
	end
end

local CustomBackAction = nil

local function RenderConfigItems(Client,ConfigsFrame,ConfigTable)
	if _G.BetterReplication.ConfigEvents then
		for _,Event in pairs(_G.BetterReplication.ConfigEvents) do
			Event:Disconnect()
		end
	end
	ConfigsFrame:ClearAllChildren()
	local ListLayout = Instance.new("UIListLayout",ConfigsFrame)
	ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ListLayout.Padding = UDim.new(0.02,0)
	local Counter = 0
	for Key,ConfigItem in pairs(ConfigTable) do
		if not ConfigItem.Hidden or Config.ShowAllSettings.Val then
			local Setting = Client.UI.title["continue"]:Clone()
			UpdateSettingName(Key,ConfigItem,Setting)
			Setting.Parent = ConfigsFrame
			Setting.spin.Visible = false
			Setting.spin.Position = UDim2.new(-0.4, 0,0, 0)
			Setting.LayoutOrder = Counter + 1
			Setting.Size = UDim2.new(0.5,0,0.03,0)
			ApplySettingItemColors(Key,ConfigItem,Setting)
			Counter += 1
			table.insert(_G.BetterReplication.ConfigEvents,Setting.MouseButton1Click:connect(function()
				if ConfigItem.Type == "bool" then
					ConfigItem.Val = not ConfigItem.Val
				end
				if ConfigItem.Type == "tbl" then
					RenderConfigItems(Client,ConfigsFrame,ConfigItem.Val)
					CustomBackAction = function()
						RenderConfigItems(Client,ConfigsFrame,ConfigTable)
					end
				else
					UpdateSettingName(Key,ConfigItem,Setting)
					ApplySettingItemColors(Key,ConfigItem,Setting)
				end
			end))
			table.insert(_G.BetterReplication.ConfigEvents,Setting.MouseLeave:connect(function()
				ConfigsFrame.Parent.tooltip.BackgroundTransparency = 1
				ConfigsFrame.Parent.tooltip.Text = ""
			end))
			table.insert(_G.BetterReplication.ConfigEvents,Setting.MouseEnter:connect(function()
				Client.selt = Setting.LayoutOrder
				ConfigsFrame.Parent:WaitForChild("tooltip").Size = UDim2.new(1,0,0.02,0)
				ConfigsFrame.Parent.tooltip.Text = ConfigItem.Desc
				ConfigsFrame.Parent.tooltip.Size = UDim2.new(0,ConfigsFrame.Parent.tooltip.TextBounds.X,0,ConfigsFrame.Parent.tooltip.TextBounds.Y)
				ConfigsFrame.Parent.tooltip.BackgroundTransparency = 0.5
				ConfigsFrame.Parent.tooltip.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
				ConfigsFrame.Parent.tooltip.AnchorPoint = Vector2.new(0.5,0.5)
				ConfigsFrame.Parent.tooltip.ZIndex = 100
			end))
		end
	end
end

local function Fade(Mode,ClientObj,Client)
	local loop = Client.UI.loop
	if Mode then
		ClientObj.load1:Play()
		loop.Visible = true
	else
		ClientObj.load2:Play()
		loop.BackgroundTransparency = 1
	end
	local start = tick()
	while true do
		if tick() - start < 0.4 then

		else
			break
		end
		if Client.UI.AbsoluteSize.Y < Client.UI.AbsoluteSize.X then
			loop.SizeConstraint = Enum.SizeConstraint.RelativeXX
			loop.Position = UDim2.new(0, 0, 0, -36 + (Client.UI.AbsoluteSize.Y - Client.UI.AbsoluteSize.X) / 2)
		else
			loop.SizeConstraint = Enum.SizeConstraint.RelativeYY
			loop.Position = UDim2.new(0, (Client.UI.AbsoluteSize.X - Client.UI.AbsoluteSize.Y) / 2, 0, -36)
		end
		local fadePosition = (Mode and 1 - (tick() - start) / 0.4 or (tick() - start) / 0.4) * 2
		loop.center.Size = UDim2.new(fadePosition, 0, fadePosition, 0)
		loop.center.Position = UDim2.new(0.5 - fadePosition / 2, 0, 0.5 - fadePosition / 2, 0)
		loop.l.Size = UDim2.new(0.5 - fadePosition / 2, 1, 1, 1)
		loop.r.Size = UDim2.new(-0.5 + fadePosition / 2, -1, 1, -1)
		loop.u.Size = UDim2.new(1, 1, 0.5 - fadePosition / 2, 1)
		loop.d.Size = UDim2.new(1, -1, -0.5 + fadePosition / 2, -1)
		game:GetService("RunService").RenderStepped:Wait()
	end
	if Mode then
		loop.BackgroundTransparency = 0
	else
		loop.Visible = false
	end
end

local function Start(ClientObj)
	local Client
	-- Get the client script environment
	repeat Client = TryGetSenv(ClientObj) until Client ~= nil
	--Wait for the client to load
	repeat game:GetService("RunService").RenderStepped:Wait() until not _G.loading
	repeat game:GetService("RunService").RenderStepped:Wait() until Client.UI
	_G.BetterReplication.Events = {}
	_G.BetterReplication.ConfigEvents = {}
	local function ModifyTitle()
		-- Dont modify the title if it's already modified
		if Client.moddedtitle then
			return
		end
		--Check if the title screen is active
		if Client.UI:WaitForChild("title").Visible then
			Client.moddedtitle = true
			local ConfigOption = Client.UI.title["continue"]:Clone()
			ConfigOption.Name = "config"
			ConfigOption.Position = Client.UI.title.testing.Position
			ConfigOption.Size = Client.UI.title.testing.Size
			ConfigOption.Text = "rb64-br Config"
			ConfigOption.outline.Text = "rb64-br Config"
			ConfigOption.Parent = Client.UI.title
			ConfigOption.spin.Visible = false
			ConfigOption.spin.Position = UDim2.new(-0.4, 0,0, 0)
			local ConfigMenu = Client.UI.title:Clone()
			ConfigMenu.Parent = Client.UI
			ConfigMenu.Name = "rb64br_config"
			ConfigMenu:WaitForChild("continue"):Destroy()
			ConfigMenu:WaitForChild("testing"):Destroy()
			ConfigMenu:WaitForChild("speedrun"):Destroy()
			ConfigMenu:WaitForChild("new"):Destroy()
			ConfigMenu:WaitForChild("version").Name = "tooltip"
			ConfigMenu.tooltip.Text = ""
			ConfigMenu.tooltip.Size = UDim2.new(1,0,0.2,0)
			ConfigMenu.Visible = false
			local ConfigsFrame = Instance.new("Frame",ConfigMenu)
			ConfigsFrame.Size = UDim2.new(0.5,0,1,0)
			ConfigsFrame.AnchorPoint = Vector2.new(0.5,0.5)
			ConfigsFrame.Position = UDim2.new(0.5,0,0.5,0)
			ConfigsFrame.BorderSizePixel = 0
			ConfigsFrame.BackgroundTransparency = 1
			local Back = ConfigMenu:WaitForChild("config")
			Back.Name = "back"
			Back.Text = "Back"
			Back.outline.Text = "Back"
			table.insert(_G.BetterReplication.Events,Back.MouseButton1Click:connect(function()
				if CustomBackAction then
					CustomBackAction()
					CustomBackAction = nil
					return
				end
				Fade(true,ClientObj,Client)
				print("Write rb64br/config.json")
				writefile("rb64br/config.json",game:GetService("HttpService"):JSONEncode(Config))
				print("Wrote rb64br/config.json")
				if _G.BetterReplication.ConfigEvents then
					for _,Event in pairs(_G.BetterReplication.ConfigEvents) do
						Event:Disconnect()
					end
				end
				workspace.title:Destroy()
				Client._G.reset()
			end))
			table.insert(_G.BetterReplication.Events,ConfigOption.MouseEnter:connect(function()
				Client.selt = 4
			end))
			table.insert(_G.BetterReplication.Events,Back.MouseEnter:connect(function()
				Client.selt = 0
			end))
			table.insert(_G.BetterReplication.Events,ConfigOption.MouseButton1Click:connect(function()
				Fade(true,ClientObj,Client)
				ClientObj.title:Stop()
				if isfile("rb64br/config.json") then
					local LoadedConfig = game:GetService("HttpService"):JSONDecode(readfile("rb64br/config.json"))
					for Key,Val in pairs(LoadedConfig) do
						Config[Key] = Val
					end
				else
					writefile("rb64br/config.json",game:GetService("HttpService"):JSONEncode(DefaultConfig))
				end
				Client.UI:WaitForChild("title").Visible = false
				workspace.title.logo.Transparency = 1
				ConfigMenu.Visible = true
				RenderConfigItems(Client,ConfigsFrame,Config)
				ClientObj.store.Volume = 1
				ClientObj.store:Play()
				Fade(false,ClientObj,Client)
			end))
			table.insert(_G.BetterReplication.Events,game:GetService("RunService").RenderStepped:Connect(function()
				ConfigOption.spin.Visible = Client.selt == 4
				ConfigOption.spin.Rotation = (tick() - Client.btntick) * 80
				Back.spin.Visible = Client.selt == 0
				Back.spin.Rotation = ConfigOption.spin.Rotation
				if ConfigMenu.Visible then
					for _,Obj in pairs(ConfigsFrame:GetChildren()) do
						if Obj:IsA("TextButton") then
							Obj.spin.Rotation = ConfigOption.spin.Rotation
							Obj.spin.Visible = Client.selt == Obj.LayoutOrder
						end
					end
					ConfigMenu.tooltip.Position = Client.UI.cursor.Position
				end
				if Client.UI.title.Visible or ConfigMenu.Visible then
					Client.UI.UI.Visible = false
				end
			end))
		end
	end
	coroutine.resume(coroutine.create(ModifyTitle))
	table.insert(_G.BetterReplication.Events,Client.UI.title.Changed:Connect(ModifyTitle))
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
	end
	table.insert(_G.BetterReplication.Events,workspace.realplam.ChildRemoved:connect(function(plam)
		if workspace.fakes:FindFirstChild(plam.Name) then
			local FakeModel = workspace.fakes[plam.Name]
			Client.particle("cloud", 8, true, FakeModel.torso.CFrame)
			FakeModel:Destroy()
		end
	end))
	local SpecialPlayers = {} -- Stores all of the known players using this script (SpecialDetectionNum must be the same on your client and their client)
	local Stomp = 0
	local Stomped = 0
	if Config.ChatBubbles.Val then
		_G.BetterReplication.Chat = {}
		local function PlayerAdded(Player)
			if Player == Client.lp then
				return
			end
			_G.BetterReplication.Chat[Player] = Player.Chatted:Connect(function(Message)
				local FakeModel = workspace.fakes:FindFirstChild(Player.Name)
				if FakeModel then
					local Plam = workspace.realplam[Player.Name]
					local LastFace = Plam.faceid.Value
					local TalkRs = game:GetService("RunService").RenderStepped:Connect(function()
						if (os.clock()*6)%1 > .5 then
							Plam.faceid.Value = 2
						else
							Plam.faceid.Value = LastFace
						end
					end)
					table.insert(_G.BetterReplication.Events,TalkRs)
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
					ChatText.Text = ""
					ChatText.Font = Enum.Font.SourceSansBold
					ChatText.TextScaled = true
					ChatText.Size = UDim2.new(1,0,1,0)
					ChatText.BackgroundTransparency = 1
					ChatText.TextColor3 = Color3.fromHSV(0,0,1)
					ChatText.TextStrokeColor3 = Color3.fromHSV(0,0,0.6470588235294118)
					local Counter = 0
					if not FakeModel:FindFirstChild("BeeboTextSound") then
						local BeeboTextSound = ClientObj.text:Clone()
						BeeboTextSound.Parent = FakeModel.head
						BeeboTextSound.Name = "BeeboTextSound"
					end
					while Counter < #Message do
						local Char = string.sub(Message,Counter,Counter)
						ChatText.Text = ChatText.Text .. Char
						Counter += 1
						if Char ~= " " then
							local PitchVal = Client.map.settings:FindFirstChild("minor") and Client.min or Client.maj
							FakeModel.head.BeeboTextSound.PlaybackSpeed = 2 ^ (PitchVal[math.random(#PitchVal)] / 12)
							FakeModel.head.BeeboTextSound:Play()
							wait(.05)
						end
					end
					ChatText.Text = Message
					TalkRs:Disconnect()
					Plam.faceid.Value = LastFace
					wait(5)
					if ChatBillboard then
						ChatBillboard:Destroy()
					end
				end
			end)
		end
		local function PlayerRemoved(Player)
			if _G.BetterReplication.Chat[Player] then
				_G.BetterReplication.Chat[Player]:Disconnect()
			end
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
					PlamObj.Value = Config.SpecialDetectionNum.Val
				end
			end
			if PlamObj.Name == "faceid" and Stomp-os.clock() >= 0 then
				--Spoof the faceid as 6 if the player is attempting to deal damage to a nearby player
				PlamObj.Value = 6
			end
			ReplicationTable[PlamObj.Name] = PlamObj.Value
		end
		if Config.Glitchy.Val then
			local PlamBackup = {}
			
			for _, PlamObj in pairs(Client.plam:GetChildren()) do
				PlamBackup[PlamObj] = PlamObj.Value
				if typeof(ReplicationTable[PlamObj.Name]) == "CFrame" and math.random(1,30) == 1 then
					ReplicationTable[PlamObj.Name] *= CFrame.new(math.random(-255,255)/150,math.random(-255,255)/150,math.random(-255,255)/150) * CFrame.Angles(math.random(-255,255)/100,math.random(-255,255)/100,math.random(-255,255)/100)
					PlamObj.Value = ReplicationTable[PlamObj.Name]
				end
				if typeof(ReplicationTable[PlamObj.Name]) == "boolean" and math.random(1,100) == 1 then
					ReplicationTable[PlamObj.Name] = not ReplicationTable[PlamObj.Name]
					PlamObj.Value = ReplicationTable[PlamObj.Name]
				end
				if typeof(ReplicationTable[PlamObj.Name]) == "number" and math.random(1,10) == 1 then
					ReplicationTable[PlamObj.Name] = ReplicationTable[PlamObj.Name] + math.random(-2,2)
					PlamObj.Value = ReplicationTable[PlamObj.Name]
				end
			end

			--Restore the plam (this doesn't work idk why)
			for PlamObj, BackupValue in pairs(PlamBackup) do
				PlamObj.Value = BackupValue
			end
		end
		if not Client.paused or Config.AlwaysReplicate.Val then
			workspace.share.ActualReplicate:FireServer(Client.plam, ReplicationTable)
		end
		local MPSLerpAlpha = DeltaTime * 5 or DeltaTime
		local PoseLerp = DeltaTime
		for _, PlamObj in pairs(workspace.realplam:GetChildren()) do
			if not Client.tpc then
				return
			end
			if PlamObj.Name ~= Client.lp.Name or Config.ShowLocalPlayer.Val then
				local Success,Error = pcall(function()
					if PlamObj.health.Value == Config.SpecialDetectionNum.Val then
						SpecialPlayers[PlamObj.Name] = true
					end
					if (PlamObj.mps.Value.p - Client.tpc.p).Magnitude < Client.rendist or true then
						PlamObj.mps.lerp.Value = PlamObj.mps.lerp.Value:Lerp(PlamObj.mps.Value, MPSLerpAlpha)
						local ValidMap = string.sub(PlamObj.map.Value,1,#Client.map.Name) == Client.map.Name
						local ValidRoom = PlamObj.map.Value ~= Client.map.Name .. (Client.room or (Client.levelid or ""))
						if Config.HidePlayers.Val and ( (ValidRoom or (ValidMap and not Config.Hide.Val.OtherRooms.Val) ) or (PlamObj.map.Value == "Boss" and Config.Hide.Val.Boss.Val) or (PlamObj.map.Value == "credits" and Config.Hide.Val.Credits.Val) or (PlamObj.map.Value == "MAKE" and Config.Hide.Val.LevelEditor.Val) ) then
							if workspace.fakes:FindFirstChild(PlamObj.Name) then
								workspace.fakes[PlamObj.Name]:Destroy()
								return
							end
						elseif workspace.fakes:FindFirstChild(PlamObj.Name) then
							local FakeModel = workspace.fakes[PlamObj.Name]
							if Config.PlayerDamage.Val and PlamObj.faceid.Value == 6 and not (Stomped-os.clock() >= 0) then
								--Detects if the player is attempting to deal damage (faceid:6)
								if (FakeModel.torso.Position - Client.char.Position).Magnitude < 5 then
									Stomped = os.clock()+.2
									Client.damage()
								end
							end
							if SpecialPlayers[PlamObj.Name] then
								PoseLerp = math.clamp(DeltaTime * 5, 0, 1/10)
								if Config.RGBNames.Val then
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
							if not Config.BetterDotAnimation.Val then
								FakeModel.dot.CFrame = FakeModel.head.CFrame + Vector3.new(0, 2)
							else
								local TargetPosition = FakeModel.head.Position + FakeModel.head.CFrame.upVector * Client.tscale.Y * 2
								FakeModel.dot.vel.Value = FakeModel.dot.vel.Value + (TargetPosition - FakeModel.dot.Position) * DeltaTime * 8 - FakeModel.dot.vel.Value * math.min(1, DeltaTime * 5)
								if FakeModel.dot.Position.Y < FakeModel.head.Position.Y + FakeModel.head.CFrame.upVector.Y * 1.5 then
									FakeModel.dot.CFrame = FakeModel.dot.CFrame - FakeModel.dot.Position + Client.v2(FakeModel.dot.Position, FakeModel.head.Position.Y + FakeModel.head.CFrame.upVector.Y * 1.5)
								end
								if not (Config.DotRange.Val * Client.tscale.Y < (FakeModel.dot.Position - TargetPosition).Magnitude) or not Config.DotRangeCap.Val then
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
                                if Config.PlayerCollisions.Val then
                                    local push = Client.v2(Client.char.Position - FakeModel.torso.Position) * (DeltaTime*60)
                                    Client.char.Velocity += push
                                end
                                if Config.PlayerDamage.Val and not Client.ground and not (Stomp-os.clock() >= 0) then
                                    Client.char.Velocity = Client.v2(Client.char.Velocity, 30)
									FakeModel.torso.damage:Play()
									Stomp = os.clock()+.2
                                end
							end
							-- Update the face texture
							local DesiredFaceTexture = (Config.FaceIds.Val[PlamObj.faceid.Value] or Config.FaceIds.Val[1]).Val
							FakeModel.head.face.Texture = DesiredFaceTexture
							if PlamObj.faceid.Value == 3 then
								--Enable damage flashing if the hurt face is detected
                                if Config.DamageFlashing.Val then
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
                                if Config.DamageFlashing.Val then
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
				if not Success and Config.ReplicationErrorsReported.Val then
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
		if _G.BetterReplication.Events then
			for _,Event in pairs(_G.BetterReplication.Events) do
				Event:Disconnect()
			end
		end
		if _G.BetterReplication.ConfigEvents then
			for _,Event in pairs(_G.BetterReplication.ConfigEvents) do
				Event:Disconnect()
			end
		end
		Start(Client)
	end
end)

if game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):FindFirstChild("CharacterScript") then
	Start(game.Players.LocalPlayer.PlayerScripts.CharacterScript)
end