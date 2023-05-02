ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('cb:mdOn' , function(source, cb)
	local src = source
	local Ply = ESX.GetPlayerFromId(src)
	local xPlayers = ESX.GetPlayers()
	local doctor = 0
	local canpay = false
	if Ply.getMoney() >= Config.Price then
		canpay = true
	else
		if Ply.getAccount('bank').money >= Config.Price then
			canpay = true
		end
	end

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'ambulance' then
			doctor = doctor + 1
			print(doctor)
		end
	end

	
	cb(doctor, canpay)
end)


ESX.RegisterServerCallback('cb:isAdmin', function(source, cb)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local group = xPlayer.getGroup()
	
	if group == 'admin' then
		cb(true)
	else
		cb(false)
	end

end)


RegisterServerEvent('ardo:gibgeld')
AddEventHandler('ardo:gibgeld', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getMoney()>= Config.Price then
		xPlayer.removeMoney(Config.Price)
	else
		xPlayer.removeAccountMoney('bank', Config.Price)
	end
end)

ESX.RegisterServerCallback('cb:hatGeld' , function(source, cb)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local hatPara = false
	if xPlayer.getMoney() >= Config.Price then
		hatPara = true
	else
		if xPlayer.getAccount('bank').money >= Config.Price then
			hatPara = true
		end
	end
	cb(hatPara)
end)

ESX.RegisterServerCallback('cb:medicOn' , function(source, cb)
	local playerCount = 0
    local xPlayers = ESX.GetExtendedPlayers('job', 'ambulance')
    for _, xPlayer in pairs(xPlayers) do
		playerCount = playerCount + 1
    end
    cb(playerCount)
end)
