local maxPing       = GetConvarInt("pingkick", 150)
local checkInterval = GetConvarInt("pingkick_interval", 5000)
local kickWarning   = GetConvar("pingkick_warning", "Your ping is too high. Fix it. (%dms, Warning: %d/3)")
local kickReason    = GetConvar("pingkick_reason", "You were kicked for having a high ping. (%dms)")

local pingHits      = {}

print("Limit set to " .. maxPing)

local function CheckPing(player)
	CreateThread(function()
		if GetPlayerPed(player) == 0 then return end -- Don't do anything if player doesn't have a ped yet

		local name = GetPlayerName(player)
		local ping = GetPlayerPing(player)

		if pingHits[player] == nil then pingHits[player] = 0 end

		if ping >= maxPing then 
			pingHits[player] = pingHits[player] + 1

			print(name .. " was warned. (Ping: " .. ping .. "ms, Warning: " .. pingHits[player] .. "/3)")
			TriggerClientEvent("chat:addMessage", player, {args = {'Ping', kickWarning:format(ping, pingHits[player])}})
		elseif pingHits[player] > 0 then
			pingHits[player] = pingHits[player] - 1
		end

		if pingHits[player] == 3 then
			pingHits[player] = 0

			print(name .. " was kicked. (Ping: " .. ping .. "ms)")

			DropPlayer(player, kickReason:format(ping))
		end
	end)
end

CreateThread(function() -- Loop trough all players and check their pings
	while true do
		for _, player in ipairs(GetPlayers()) do CheckPing(player) end

		Wait(checkInterval)
	end
end)

AddEventHandler('playerDropped', function()
	pingHits[source] = 0
end)