local Active = false
local test = nil
local doctorrrr = nil
local spam = true
local isDead = false
local shouldLoop = false 

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)	

RegisterCommand('cbtest', function()
	ESX.TriggerServerCallback('cb:medicOn', function(MedicsOn)
		print("Mediziner online: "..MedicsOn)
	end)
end, true)

RegisterCommand('notruf', function()
	if isDead and spam then
		local player = PlayerPedId()
		ESX.TriggerServerCallback('cb:hatGeld', function(hatGeld)
			if hatGeld then -- erstmal geld checken
				ESX.TriggerServerCallback('cb:medicOn', function(MedicsOn)
				print("Mediziner online: "..MedicsOn.." Stück!")
					if MedicsOn > Config.MedicsOn then -- Wenn mehr als 2 Mediziner online sind, wird kein NPC gespawnt
						Notify("Es sind genügend Mediziner im Dienst, hab bitte ein wenig Geduld!", "error")
					else
						SpawnVehicle(GetEntityCoords(player))
						Notify("Ein staatlicher Notfallsanitäter wurde alarmiert und ist nun unterwegs! Sollte er innert 30 Sekunden nicht ankommen, werden Notmassnahmen eingeleitet.")
						shouldLoop = true
						Timer(120)
					end
				end)
			else
				Notify("Du hast nicht genug Geld, um einen Notarzt aufzubieten", "error")
			end
		end)
	else
		Notify("Du bist kerngesund, wozu brauchst Du einen Notarzt?", "error")
	end
end)

function SpawnVehicle(x, y, z) 
	print("Trying to spawn vehicle")
	spam = false
	local vehhash = GetHashKey("ambulance")                                                     
	local loc = GetEntityCoords(PlayerPedId())
	RequestModel(vehhash)
	while not HasModelLoaded(vehhash) do
		Wait(1)
	end
	
	RequestModel('s_m_m_paramedic_01')
	while not HasModelLoaded('s_m_m_paramedic_01') do
		Wait(1)
	end
	
	local spawnRadius = 60                                                    
    local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(loc.x + math.random(-spawnRadius, spawnRadius), loc.y + math.random(-spawnRadius, spawnRadius), loc.z, 0, 3, 0)

	if not DoesEntityExist(vehhash) then
        docVeh = CreateVehicle(vehhash, spawnPos, spawnHeading, true, false)                        
        ClearAreaOfVehicles(GetEntityCoords(docVeh), 5000, false, false, false, false, false);  
        SetVehicleOnGroundProperly(docVeh)
		SetVehicleSiren(docVeh, true)
		SetVehicleNumberPlateText(docVeh, "DR ARDO")
		SetEntityAsMissionEntity(docVeh, true, true)
		SetVehicleEngineOn(docVeh, true, true, false)    
        docPed = CreatePedInsideVehicle(docVeh, 26, GetHashKey('s_m_m_paramedic_01'), -1, true, false)              	     
        mechBlip = AddBlipForEntity(docVeh)                                                        	
        SetBlipFlashes(mechBlip, true)  
        SetBlipColour(mechBlip, 5)
		PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", 1)
		Wait(2000)
		TaskVehicleDriveToCoord(docPed, docVeh, loc.x, loc.y, loc.z, 20.0, 0, GetEntityModel(docVeh), 524863, 2.0)
		test = docVeh
		doctorrrr = docPed
		Active = true
    else
		print("entity existiert nicht")
	end
end

Citizen.CreateThread(function()
    while true do
	local sleep = 500
      Citizen.Wait(sleep)
       if Active then
             loc1 = GetEntityCoords(PlayerPedId())
			 lc = GetEntityCoords(test)
			 ld = GetEntityCoords(doctorrrr)
             dist = #(loc1 - lc)
			 dist1 = #(loc1 - ld)
            if dist <= 18 then
				if Active then
				sleep = 200
					TaskGoToCoordAnyMeans(doctorrrr, loc1.x, loc1.y, loc1.z, 2.0, 0, 0, 786603, 0xbf800000)
				end
				if dist1 <= 1.5 then 
					Active = false
					shouldLoop = false
					ClearPedTasksImmediately(doctorrrr)
					DoctorNPC()
				end
            end
        end
    end
end)

function DoctorNPC()
	RequestAnimDict("mini@cpr@char_a@cpr_str")
	while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do
		Citizen.Wait(1000)
	end
	TaskPlayAnim(doctorrrr, "mini@cpr@char_a@cpr_str","cpr_pumpchest",1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
	TriggerEvent("robberies_creator:startProgressBar", 5000, "Der Notarzt leistet Dir erste Hilfe", "#0fffef")
    ClearPedTasks(doctorrrr)
	Citizen.Wait(5000)
	TriggerEvent('esx_ambulancejob:revive')
	StopScreenEffect('DeathFailOut')	
	Notify("Die Behandlung ist abgeschlossen. Behandlungskosten: "..Config.Price.." $")
	TriggerServerEvent('ardo:gibgeld')
	TaskEnterVehicle(doctorrrr, test, -1, 2, 1.0, 1, 0)
	Citizen.Wait(5000)
	DeletePed(doctorrrr)
	DeleteEntity(test)
	isDead = false
	spam = true
end

function Timer(value)
		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)
		local forwardVector = GetEntityForwardVector(playerPed)
		local rightVector = vector3(forwardVector.y, -forwardVector.x, 0)
		local spawnCoords = playerCoords + (rightVector * 5)
		local npcHeading = GetEntityHeading(playerPed) - 270.0 -- 90 Grad nach links drehen, um rechts vom Spieler zu sein
		local npcTarget = playerCoords + (GetEntityForwardVector(playerPed)*4)
	local time = value -- sekunden
	while shouldLoop do--time ~= 0 do 
		Citizen.Wait(1000) 
		time = time - 1
			print("[TIMER] time left: "..time.." seconds")
		if time == 90 then	
			teleportDoc()
			print("^2AI-Doc teleported")
			Notify("Der Notarzt wurde zu dir teleportiert, da er deine Position nicht anfahren konnte. Beachte, dass auch er nicht jeden Ort erreicht!")
		end
		if time == 0 then
			RemovePedElegantly(doctorrrr)
			DeleteEntity(test)
			DeletePed(doctorrrr)
			spam = true
			isDead = false
			print("^1AI-Docrevive failed")
			Notify("Der Notarzt konnte deine Position nicht anfahren und ist zurück zum Medical Department gefahren", "error")
		end
		
	end
end

function teleportDoc()
	local playerPed			= PlayerPedId()
	local playerCoords	= GetEntityCoords(playerPed)
	SetEntityCoords(docVeh, playerCoords.x+15.0, playerCoords.y+15.0, playerCoords.z, false, false, false, false)
	TaskWarpPedIntoVehicle(doctorrrr, docVeh, -1)
end

function Notify(msg, type)
	if type == "error" then
	TriggerEvent('b-notify:notify', 'error', '', msg)
	else
	TriggerEvent('b-notify:notify', 'medic', '', msg)
	end
end

RegisterKeyMapping('notruf', 'Notruf', 'keyboard', '') 
