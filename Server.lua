--[[

DarkPixlz 2022 - 2023.

Edit gamepasses (or remove them) at 166

Password algorithms and webhook URLs have been removed.


]]
-- Init webhook
local function LocalTime() local Date = os.date("*t") local DayTxt = os.date("%A") local Month = os.date("%B") local DayDate = os.date("%d") local Hour = string.format("%0.2i", ((Date.hour % 12 == 0) and 12) or (Date.hour % 12)) local Minute = string.format("%0.2i", Date.min) local Second = string.format("%0.2i", Date.sec) local Meridiem = (Date.hour < 12 and "AM" or "PM") return tostring(DayTxt..", "..Month.." "..DayDate.." "..Hour ..":".. Minute ..":".. Second .." ".. Meridiem)end local function Time() local Date = os.date("*t") local Hour = string.format("%0.2i", ((Date.hour % 12 == 0) and 12) or (Date.hour % 12)) local Minute = string.format("%0.2i", Date.min) local Second = string.format("%0.2i", Date.sec) local Meridiem = (Date.hour < 12 and "AM" or "PM") return tostring(Hour ..":".. Minute ..":".. Second .." ".. Meridiem) end local function Date() local DayTxt = os.date("%A") local Month = os.date("%B") local DayDate = os.date("%d") local Year = os.date("%Y") return tostring(DayTxt..", "..Month.." "..DayDate.." "..Year) end local function SendWebhook(b,c,d,e,f,g)local h=game:GetService("HttpService")if b=="Purchase"then local i=""local j={["contents"]="@everyone New Purchase",["username"]="StreamX".." Logging",["avatar_url"]="https://cdn.discordapp.com/avatars/1032431346385178655/e6bde5fcfd3b994456fa578b8956ff0c.png?size=4096",["embeds"]={{["title"]="New purchase!",["description"]=c.." has bought a membership",["type"]="rich",["color"]=tonumber(0xf59842),["fields"]={{["name"]="Player name:",["value"]=c,["inline"]=true},{["name"]="Player ID:",["value"]=d,["inline"]=true},{["name"]="Product ID:",["value"]=e,["inline"]=true},{["name"]="Product Exp Time (seconds)",["value"]=f,["inline"]=true},{["name"]="Report Data",["value"]="Sent at "..LocalTime(),["inline"]=true}}}}}h:PostAsync(i,h:JSONEncode(j))elseif b=="Feedback"then local i=""local j={["contents"]="@everyone New Purchase",["username"]="StreamX".." Logging",["avatar_url"]="https://cdn.discordapp.com/avatars/1032431346385178655/e6bde5fcfd3b994456fa578b8956ff0c.png?size=4096",["embeds"]={{["title"]="Cancellation feedback sent",["description"]=c.." has left cancellation feedback!",["type"]="rich",["color"]=tonumber(0xf59842),["fields"]={{["name"]="Feedback",["value"]=g,["inline"]=true},{["name"]="Report Data",["value"]="Sent at "..LocalTime(),["inline"]=true}}}}}h:PostAsync(i,h:JSONEncode(j))else warn("Invalid Type value.")end end
task.wait(5)
local AuthKey = ""
local BaseURL = ""
-- If you would like a standard URL/Auth key, put them there.
local Player = game.Players:FindFirstChildWhichIsA("Player")
local UI = Player.PlayerGui.MainStreamX
local Shop = UI.Shop
local Items = Shop.Products
local CurrentProduct
local HTTPS = game:GetService("HttpService")
local DSS = game:GetService("DataStoreService")
local CreationMode = false
local Store = DSS:GetDataStore("SX_PSWDS_Fix2")
local Frame = Player.PlayerGui.MainStreamX.Login
local Password = ""
local Home = UI.Home
local Trials = DSS:GetDataStore("SX_TRIALS")
local function GetDays(Time)
	print("\n"..os.time().." - "..math.floor(Time).." = "..tostring(math.floor(Time)-os.time()))
	return Time
	--return math.ceil((Time - os.time())/86400)
end

local function GetTrialInfo()
	local PlayerInfo = Trials:GetAsync(Player.UserId)
	return PlayerInfo
end
local function WriteTrialInfo()
	local succ, err= pcall(function()
		local Data = {
			HasClaimed = true
		}
		Trials:SetAsync(Player.UserId, Data)
	end)
	return succ, err
end

local function LoadHome()
	UI.Spinner.Visible = true
	local HomeData
	local HomeDecoded
	local succ, err = pcall(function()
		HomeData = HTTPS:GetAsync(
			BaseURL.."/info/"..Player.UserId,
			false,
			{ ["X-StreamX-Token"] = AuthKey }
		)
		HomeDecoded = HTTPS:JSONDecode(HomeData)
	end)
	task.wait(2)
	UI.Spinner.Visible = false


	if succ then
		Home.BillingDue.Visible = true
		Home.BillingDue.Time.Text = GetDays(tonumber(math.floor(HomeDecoded.quota))).." Days"
		if GetDays(HomeDecoded.quota) <= 10 then
			-- Should renew
			Home.NothingToDo.Visible = false
			Home.Renew.Visible = true
		elseif GetDays(HomeDecoded.quota) >= 999999999 then
			--			print("hello")
			Home.NothingToDo.Visible = true
			Home.Renew.Visible = false
			Home.BillingDue.Time.Text = "You're good for life!"
		elseif GetDays(HomeDecoded.quota) <= 0 then
			-- Sub expired
			Home.BillingDue.Time.Text = "0 Days"
			Home.NothingToDo.Visible = false
			Home.Renew.Visible = false
			Home.Expired.Visible = true
		else
			Home.NothingToDo.Visible = true
			Home.Renew.Visible = false
		end
	end
	if not succ and err ~= "HTTP 404 (Not Found)" then
		warn(err)
		Home.Error.Visible = true
		Home.Warning.Visible = false
		Home.Error.error.Text = err..". Requires a 200 or 404 to continue."
	elseif err == "HTTP 404 (Not Found)" then
		Home.Warning.Visible = true
	end
end


game.ReplicatedStorage.UpdateTerm.OnServerEvent:Connect(function(p, key)
	Password = key
end)

game.ReplicatedStorage.UpdateURL.OnServerEvent:Connect(function(p, URL, _AuthKey)
	BaseURL = URL
	AuthKey = _AuthKey
end)

Frame.Go.MouseButton1Click:Connect(function()
	Frame.Spinner.Visible = true
	task.wait(3)
		--Login now that they've logged in
    --Passwords removed from here, just log the player in. 
		Frame.Visible = false
	Frame.Parent.Home.Visible = true
	LoadHome()
end)
Frame.New.MouseButton1Click:Connect(function()
end)

local PurchaseActive

if Player.Name ~= "DarkPixlz" then
	Items.Dev:Destroy()
else
	Items.Dev.Activate.MouseButton1Click:Connect(function()
		CurrentProduct = "1"
	end)
end
Items.OneMonth.Activate.MouseButton1Click:Connect(function()
	if PurchaseActive then return end
	CurrentProduct = "32"
end)

Items.TwoMonths.Activate.MouseButton1Click:Connect(function()
	if PurchaseActive then return end
	CurrentProduct = "64"
end)

Items.SixMonths.Activate.MouseButton1Click:Connect(function()
	if PurchaseActive then return end
	CurrentProduct = "182"
end)

Items.OneYear.Activate.MouseButton1Click:Connect(function()
	if PurchaseActive then return end
	CurrentProduct = "365"
end)

Items.Forever.Activate.MouseButton1Click:Connect(function()
	if PurchaseActive then return end
	CurrentProduct = "999999999999999"
end)

local function FetchPlayerData()
	local Result = BaseURL.."/info/"..Player.UserId
	local Sent = HTTPS:GetAsync(Result, true,
		{ ["X-StreamX-Token"] = AuthKey }
	)
	return Sent
end

local MPS = game:GetService("MarketplaceService")
UI.Shop.Continue.MouseButton1Click:Connect(function()
	print("--------BEGIN PROCESSING--------")
	PurchaseActive = true
	Shop.Processing.Visible = true
	Shop.Spinner.Visible = true
  --CHANGE IDS HERE
    
	if CurrentProduct == "32" then -- One month
		MPS:PromptProductPurchase(Player, 1334177890)
	elseif CurrentProduct == "64" then -- Two months
		MPS:PromptProductPurchase(Player, 1334178002)
	elseif CurrentProduct == "182" then -- Six months
		MPS:PromptProductPurchase(Player, 1334178105)
	elseif CurrentProduct == "365" then -- One year
		MPS:PromptProductPurchase(Player, 1334178188)
	elseif CurrentProduct == "999999999999999" then -- Forever
		MPS:PromptProductPurchase(Player, 1334178245)
	elseif CurrentProduct == "86400" then -- Two Years
		MPS:PromptProductPurchase(Player, 1334178300)		
	end
end)
MPS.PromptProductPurchaseFinished:Connect(function(UserID, Product, WasPurchased)
	if WasPurchased then
		--SendWebhook("Purchase","New Purchase!","@"..Player.Name.." bought a StreamX membership!","Info about this purchase:","Player Name: "..Player.Name.."\nPlayer ID: "..UserID.."\nProduct: "..Product.."\nProduct Timestamp (seconds): "..CurrentProduct)
		SendWebhook("Purchase",Player.Name,UserID,Product, CurrentProduct)
		print("---PAYMENT SUCCESSFUL--\n Processing...")
		Shop.Success:Play()
		Shop.Spinner:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .2)
		Shop.Thumb:TweenSize(UDim2.new(.073,0,.118,0),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .2)
		task.wait(2)
		Shop.Thumb:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .2)
		Shop.Spinner:TweenSize(UDim2.new(.073,0,.118,0),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .2)
		local Username
		local succ, err = pcall(function() Username = game.Players:GetNameFromUserIdAsync(UserID) end)
		if not succ then return error("Failed to fetch username!") end
		local PaymentSucc, PaymentErr = pcall(function()
			local Return = HTTPS:PostAsync(
				BaseURL.."/activate",
				HTTPS:JSONEncode({ userid = UserID, username = Username, expires = os.time() + CurrentProduct }),
				Enum.HttpContentType.ApplicationJson,
				false,
				{
					["X-StreamX-Token"] = AuthKey,
				}
			)
			local Data = HTTPS:JSONDecode(Return)
			print(Return)
			print(Data)
			Shop.Processing.Visible = false
			Shop.Visible = false
			UI.Success.Visible = true
			local Success = UI.Success
			local APIKey = FetchPlayerData()
			Success.Key.Text = tostring(Data.apikey)
		end)
		
		if not PaymentSucc then
			warn(PaymentErr)
			Shop.Processing.Visible = false
			Shop.Visible = false
			Shop.Parent.Error.Visible = true
			Shop.Parent.Error.Error.Text = PaymentErr
		end
	else

	end
end)
local Whitelisting = UI.Home.GameWhitelisting
-- Homepage Handling

local function Delete()
	local Return = HTTPS:PostAsync(
		BaseURL.."/delete",
		HTTPS:JSONEncode({ userid = Player.UserId }),
		Enum.HttpContentType.ApplicationJson,
		false,
		{
			["X-StreamX-Token"] = AuthKey,
		})
end
local function BeginDeletion()
	UI.Home.Blur.Visible = true
	local Module = require(game.ReplicatedStorage.BlurUI)
	--	Module.Init(UI)
	--	Module.AddFrame(UI.Home) 
	game.Lighting.Blur.Size = 35
	--	Module.Destroy()
	UI.Home.Cancel.Visible = true
	local Tween = game:GetService("TweenService"):Create(
		UI.Home.Cancel.Delete.Frame,
		TweenInfo.new(
			7,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out,
			0,
			false,
			1
		),
		{
			Size = UDim2.new(0,0,1,0)
	})
	Tween:Play()
	Tween.Completed:Wait()
	UI.Home.Cancel.Delete.MouseButton1Click:Connect(function()
		--		Module.AddFrame(UI.Home.Cancel) 
		UI.Spinner.Visible = true
		UI.Home.Cancel.Visible = false
		UI.Home.PromptBlur.Visible = true
		task.wait(3)
		Delete()
		task.wait(2)
		game.Lighting.Blur.Size = 0
		UI.Home.Visible = false
		task.wait(1)
		UI.Cancelled.Visible = true
		UI.Spinner.Visible = false
	end)

end

local CurrentDeleteID
local Cancel = Whitelisting.RemoveGame

local function RefreshGames()
	local Frame = UI.Home.GameWhitelisting.ScrollingFrame
	for i, v in ipairs(Frame:GetChildren()) do 
		if v:IsA("Frame") and v.Name ~= "Template" then
			v:Destroy()
		end
	end
	print(HTTPS:JSONDecode(FetchPlayerData()))
	print(HTTPS:JSONDecode(FetchPlayerData())["whitelist"])
	local Keys = HTTPS:JSONDecode(FetchPlayerData())["whitelist"]
	if #Keys ~= 0 then
		for i, v in ipairs(Keys) do
			print("Making new key "..v)
			local Info = MPS:GetProductInfo(v, Enum.InfoType.Asset)
			local NewUI = Frame.Template:Clone()
			local Content = NewUI.Content
			NewUI.Name = v
			NewUI.Parent = Frame
			NewUI.Visible = true
			Content.ID.Text = "ID: "..v
			local Name = Info["Name"]
			Content.GameName.Text = Name
			Content.Icon.Image = "rbxassetid://"..Info["IconImageAssetId"]
			Content.Creator.Text = "Created by "..Info["Creator"]["Name"]
			NewUI.Delete.MouseButton1Click:Connect(function()
				CurrentDeleteID = NewUI.Name
				Cancel.Stage1.Content.Text = "Are you sure you would like to remove "..Name.." from your plan? This game will no longer be able to use your API key!"
				Cancel.Visible = true
				
			end)
		end
	end
end

local function RemoveGame()
	local succ, err = pcall(function()
		local Result = HTTPS:PostAsync(BaseURL.."/whitelist/remove",
			HTTPS:JSONEncode(
				{
					["userid"] = Player.UserId,
					["gameid"] = tonumber(CurrentDeleteID)
				}
			),
			Enum.HttpContentType.ApplicationJson,
			false,
			{
				["X-StreamX-Token"] = AuthKey,
			})
	end)
	if not succ then
		return err
	else
		RefreshGames()
		return "Success!"
	end
end

Cancel.Stage1.Go.MouseButton1Click:Connect(function()
	Cancel.Stage1.Visible = false
	Cancel.Loading.Visible = true
	Cancel.Loading.Status.Text = "Deleting this game..."
	task.wait(3)
	local Result = RemoveGame()
	if Result ~= "Success!" then
		warn(Result)
		Cancel.Loading.Visible = false
		Cancel.Error.Visible = true
		Cancel.Error.Error.Text = "Error: "..Result..". Please try again later."
	else
		Cancel.Loading.Visible = false
		Cancel.Success.Visible = true
	end
end)

local function AddGame(ID)
	-- Check if game is owned by the player
	local IsOwnedBy = true

	local Info = MPS:GetProductInfo(ID, Enum.InfoType.Asset)
	local GameOwner, IsGroup = Info["Creator"]["CreatorTargetId"], Info["Creator"]["CreatorType"]
	if IsGroup == "Group" then
		IsGroup = true
	else
		IsGroup = false
	end
	if not IsGroup then
		if GameOwner == Player.UserId then
			local succ, err = pcall(function()
				local Result = HTTPS:PostAsync(BaseURL.."/whitelist/add",
					HTTPS:JSONEncode(
						{
							["userid"] = Player.UserId,
							["gameid"] = tonumber(ID)
						}
					),
					Enum.HttpContentType.ApplicationJson,
					false,
					{
						["X-StreamX-Token"] = AuthKey,
					})
			end)
			if not succ then
				return err
			else
				RefreshGames()
				return "Success!"
			end
		else
			return "This isn't your game."
		end
	else
		local Info = MPS:GetProductInfo(ID, Enum.InfoType.Asset)
		local Owner = game:GetService("GroupService"):GetGroupInfoAsync(Info["Creator"]["CreatorTargetId"])["Owner"]["Id"]
		if Player.UserId == Owner then
			local succ, err = pcall(function()
				local Result = HTTPS:PostAsync(BaseURL.."/whitelist/add",
					HTTPS:JSONEncode(
						{
							["userid"] = Player.UserId,
							["gameid"] = tonumber(ID)
						}
					),
					Enum.HttpContentType.ApplicationJson,
					false,
					{
						["X-StreamX-Token"] = AuthKey,
					})
			end)
			if not succ then
				return err
			else
				RefreshGames()
				return "Success!"
			end
		else
			return "This is not your group. Only the group owner may whitelist group owned games."
		end
	     --return "Something else went wrong - please try again later."
	end
end

local function RefreshKeys()
	local Keys = HTTPS:JSONDecode(FetchPlayerData())["apikeys"]
	for i, v in ipairs(Keys) do
		print(v)
		Home.API.Key1.Text = v["key"]
	end
end

local function ResetAccount()

end

local function ClosePrompt(val)
	Whitelisting.Prompt.Visible = false
	for i, v in ipairs(Whitelisting.Prompt:GetChildren()) do
		if v:IsA("Frame") then
			v.Visible = false
		end
	end
	if val == false or nil then
		Whitelisting.Prompt.Stage1.Visible = true
	end
	print("Reset prompt!")
end

UI.Home.NothingToDo.Delete.MouseButton1Click:Connect(function()
	BeginDeletion()
end)

UI.Home.Renew.Delete.MouseButton1Click:Connect(function()
	BeginDeletion()
end)

game.ReplicatedStorage.Feedback.OnServerEvent:Connect(function(p, Feedback)
	SendWebhook("Feedback", Player.Name,nil,nil,nil,Feedback)
	p:Kick("Thank you for the feeback! We're sorry to see you go. Your info has been deleted from the StreamX backend database.")
end)

UI.Success.Return.MouseButton1Click:Connect(function()
	UI.Success.Visible = false
	LoadHome()
	UI.Home.Visible = true
end)

local ID
game.ReplicatedStorage.UpdateID.OnServerEvent:Connect(function(p, Text)
	ID = Text
end)
local Info
UI.Home.GameWhitelisting.New.MouseButton1Click:Connect(function()
	Whitelisting.Prompt.Visible = true
end)

Whitelisting.Prompt.Stage1.Go.MouseButton1Click:Connect(function()
	Whitelisting.Prompt.Stage1.Visible = false
	Whitelisting.Prompt.EnterID.Visible = true
end)

local function ChangeAllIcons(Name, Creator, ID, Image)
	
end

Whitelisting.Prompt.EnterID.Go.MouseButton1Click:Connect(function()
	Whitelisting.Prompt.Loading.Status.Text = "Getting info..."
	Whitelisting.Prompt.Loading.Visible = true
--	ID = Whitelisting.Prompt.Stage1.ID.Text
	Whitelisting.Prompt.EnterID.Visible = false
	local succ, err = pcall(function()
		print(ID)
		print(tonumber(ID))
		Info = MPS:GetProductInfo(ID, Enum.InfoType.Asset)
	end)
	if not succ then
		ClosePrompt(true)
		Whitelisting.Prompt.Visible = true
		Whitelisting.Prompt.Error.Visible = true
		Whitelisting.Prompt.Error.Error.Text = "Error checking asset data: "..err..". Please make sure this is a valid ID."
	end
	task.wait(1)
	Whitelisting.Prompt.Loading.Visible = false
	Whitelisting.Prompt.Stage2.Visible = true
	local Content = Whitelisting.Prompt.Stage2.Gradient.ExampleGame.Content
	Content.GameName.Text = Info["Name"]
	Content.Icon.Image = "rbxassetid://"..Info["IconImageAssetId"]
	Content.Creator.Text = Info["Creator"]["Name"]
	Whitelisting.Prompt.Success.GameText.Text = "\""..Info["Name"].."\" has been added to your account!"
	Whitelisting.Prompt.Error.GameText.Text = "\""..Info["Name"].."\" has not been added to your account."
end)
Whitelisting.Prompt.Stage2.Go.MouseButton1Click:Connect(function()
	Whitelisting.Prompt.Stage2.Visible = false
	Whitelisting.Prompt.Loading.Visible = true
	Whitelisting.Prompt.Loading.Status.Text = "Valitating..."
	task.wait(1)
	Whitelisting.Prompt.Loading.Status.Text = "Adding, please wait, this may take a while..."
	task.wait(2)
	local Result = AddGame(ID)
	task.wait(1)
	if Result ~= "Success!" then
		Whitelisting.Prompt.Loading.Visible = false
		Whitelisting.Prompt.Error.Visible = true
		Whitelisting.Prompt.Error.Error.Text = "Error: "..Result
	else
		Whitelisting.Prompt.Loading.Visible = false
		Whitelisting.Prompt.Success.Visible = true
	end
end)

Whitelisting.Prompt.Success.Exit.MouseButton1Click:Connect(function() ClosePrompt(false) end)
Whitelisting.Prompt.Stage1.Cancel.MouseButton1Click:Connect(function() ClosePrompt(false) end)
Whitelisting.Prompt.Stage2.No.MouseButton1Click:Connect(function() ClosePrompt(false) end)
Whitelisting.Prompt.Error.Exit.MouseButton1Click:Connect(function() ClosePrompt(false) end)
Home.Renew.Renew.MouseButton1Click:Connect(function()
	Home.Visible = false
	Shop.Visible = true
end)
Home.Warning.Visible = false

Home.Nav.APIKeys.MouseButton1Click:Connect(function()
	Home.API.Visible = true
	Home.Purchases.Visible = false
	Home.GameWhitelisting.Visible = false
	RefreshKeys()
end)

Home.Nav.Home.MouseButton1Click:Connect(function()
	Home.API.Visible = false
	Home.Purchases.Visible = false
	Home.GameWhitelisting.Visible = false
end)

Home.Nav.Payments.MouseButton1Click:Connect(function()
	Home.API.Visible = false
	Home.GameWhitelisting.Visible = false
	Home.Purchases.Visible = true
end)
Home.Warning.ButtonHeavy.MouseButton1Click:Connect(function()
	Home.Visible = false

	Shop.Visible = true
end)

Home.Nav.Whitelisting.MouseButton1Click:Connect(function()
	Home.GameWhitelisting.Visible = true
	Home.API.Visible = false
	Home.Purchases.Visible = false
end)

--LoadHome()
RefreshGames()
RefreshKeys()
