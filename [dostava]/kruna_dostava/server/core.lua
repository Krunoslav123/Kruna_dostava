dostava = {}
dostava.Functions = {}
ESX = exports['es_extended']:getSharedObject()

dostava.Functions.SendWB = function(msg)
	if Config['EnableWebhook'] then
		PerformHttpRequest(Config['Webhook'], function(err, text, headers) end, 'POST', json.encode({
			username = Config['Username'],
			embeds = {{
				["color"] = color,
				["author"] = {
					["name"] = Config['CommunityName'],
					["icon_url"] = Config['CommunityLogo']
				},
				["description"] = "".. msg .."",
				["footer"] = {
					["text"] = "• "..os.date("%x %X %p"),
				},
			}}, 
			avatar_url = Config['Avatar']
		}),
		{
			['Content-Type'] = 'application/json'
		})
	end
end

RegisterNetEvent('kruna_dostava:wb', function(msg)
	dostava.Functions.SendWB(msg)
end)

RegisterNetEvent('kruna_dostava:pay', function(quantity)
	local xPlayer = ESX.GetPlayerFromId(source)

	if quantity > Config['dostava']['FinalPayout']['Max'] then
		dostava.Functions.SendWB("The player with Identifier " ..xPlayer.identifier.. " have tried to get more money than the maximum indicated in the config.lua")
	else
		xPlayer.addMoney(quantity)
		TriggerClientEvent('esx:showNotification', source, 'You received ~g~$' ..tonumber(quantity))
		dostava.Functions.SendWB("The player with Identifier " ..xPlayer.identifier.. " received **$" ..quantity.. "**")
	end
end)


