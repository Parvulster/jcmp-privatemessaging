-- Private Messaging V1.0
-- By: Parvulster

-- Messaging Command
msg = "/msg"

-- Reply Command
reply = "/r"

lastmsg = {}

function PlayerChat(args)
	if args.text == msg then
		SendError(args.player, "Usage: "..msg.." <player> <message>")
		return
	end
	if string.sub(args.text, 1, string.len(msg)) == msg then
		local sender = args.player
		local msgargs = string.gsub(args.text, msg, "", 1)
		if string.find(msgargs, " ") ~= 1 then
			return
		end
		msgargs = string.gsub(msgargs, " ", "", 1)
		local receiver, receiverlength = FindPlayerToMessage(msgargs)
		if receiver == false then
			SendError(sender, "You need to enter a valid player!")
			return
		end
		--if sender == receiver then
		--	SendError(sender, "You can't send a message to yourself!")
		--	return
		--end
		local msgstring = string.sub(msgargs, receiverlength + 1)
		if msgstring == "" then
			SendError(sender, "You need to enter a valid message!")
			return
		end
		if string.find(msgstring, " ") ~= 1 then
			SendError(sender, "You need to enter a valid player!")
			return
		end
		msgstring = string.gsub(msgstring, "^%s*", "")
		if msgstring == "" then
			SendError(sender, "You need to enter a valid message!")
			return
		end
		SendMessage(sender, receiver, msgstring)
	end
	if args.text == reply then
		SendError(args.player, "Usage: "..reply.." <message>")
		return
	end
	if string.sub(args.text, 1, string.len(reply)) == reply then
		local sender = args.player
		local receiver = lastmsg[sender:GetSteamId().string]
		local msgstring = string.gsub(args.text, reply, "", 1)
		if string.find(msgstring, " ") ~= 1 then
			return
		end
		msgstring = string.gsub(msgstring, " ", "", 1)
		receiver = FindPlayerBySteamId(receiver)
		if receiver == nil then
			SendError(sender, "You need to send/receive a message before you can reply! Please use /msg instead.")
			return
		end
		if receiver == false then
			lastmsg[sender:GetSteamId().string] = nil
			SendError(sender, "That player is not online any more! Please use /msg instead.")
			return
		end
		msgstring = string.gsub(msgstring, "^%s*", "")
		if msgstring == "" then
			SendError(sender, "You need to enter a valid message!")
			return
		end
		SendMessage(sender, receiver, msgstring)
	end
end

function SendMessage(sender, receiver, message)
	local sendercolor = sender:GetColor()
	local receivercolor = receiver:GetColor()
	lastmsg[sender:GetSteamId().string] = receiver:GetSteamId().string
	lastmsg[receiver:GetSteamId().string] = sender:GetSteamId().string
	Chat:Send(receiver, "[", Color.Orange, sender:GetName(), sendercolor, " -> ", Color.Orange, "me", receivercolor, "] ", Color.Orange, message, Color.White)
	Chat:Send(sender, "[", Color.Orange, "me", sendercolor, " -> ", Color.Orange, receiver:GetName(), receivercolor, "] ", Color.Orange, message, Color.White)
end

function SendError(player, message)
	Chat:Send(player, message, Color.Red)
end

function FindPlayerToMessage(message)
	for player in Server:GetPlayers() do
		local playerstring = player:GetName()
		local playerid = tostring(player:GetId())
		if string.sub(message, 1, string.len(playerstring)) == playerstring then
			return player, string.len(playerstring)
		elseif string.sub(message, 1, string.len(playerid)) == playerid then
			return player, string.len(playerid)
		end
	end
	return false
end

function FindPlayerBySteamId(steamid)
	if steamid == nil then
		return nil
	end
	for player in Server:GetPlayers() do
		if player:GetSteamId().string == steamid then
			return player
		else
			return false
		end
	end
end

function PlayerQuit(args)
	lastmsg[args.player:GetSteamId().string] = nil
end

Events:Subscribe("PlayerChat", PlayerChat)
Events:Subscribe("PlayerQuit", PlayerQuit)
