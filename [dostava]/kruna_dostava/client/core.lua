dostava = {}
dostava.Functions = {}
ESX = exports['es_extended']:getSharedObject()

local inJob = false
local haveClothes = false
local PlayerData = nil
local inAnim = false
local entity = nil
local haveBox = false
local getBox = false
local vehicle, vehicle2 = nil, nil
local gotoPoint = false
local comeBack = false
local dest_blip, blipStatus
local data = {}

CreateThread(function()
    Wait(3000)

    while PlayerData == nil do
        PlayerData = ESX.GetPlayerData()
        print("Getting PlayerData...")
        Wait(0)
    end

    Wait(2000)

    for k, v in pairs(Config['dostava']['Blips']) do
        local blip = AddBlipForCoord(v['x'], v['y'], v['z'])
        SetBlipSprite(blip, v['sprite'])
        SetBlipScale(blip, v['scale'])
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v['label'])
        EndTextCommandSetBlipName(blip)
    end

    dostava.Functions.StartThread()
end)

RegisterNetEvent('kruna_dostava:stopJob', function()
    TriggerServerEvent('kruna_dostava:wb', " **".. PlayerData.identifier .."** je zavrsio posao")
    inJob = false
    haveBox = false
    blipStatus = 'delete'
    inAnim = false
    ClearPedTasksImmediately(PlayerPedId())
    DeleteObject(entity)
    DeleteVehicle(vehicle)
end)

dostava.Functions.floatingText = function(msg, coords)
	AddTextEntry('FloatingHelpNotification', msg)
	SetFloatingHelpTextWorldPosition(1, coords)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
	BeginTextCommandDisplayHelp('FloatingHelpNotification')
	EndTextCommandDisplayHelp(2, false, false, -1)
end

dostava.Functions.ShowNotification = function(msg, thisFrame, beep, duration)
    AddTextEntry('HelpNotification', msg)
    BeginTextCommandDisplayHelp('HelpNotification')
    EndTextCommandDisplayHelp(0, false, true, 3500)
end

dostava.Functions.SetBlipRoutes = function(x, y, z, sprite, colour)
    dest_blip, blipStatus = AddBlipForCoord(x, y, z), nil
    SetBlipSprite(dest_blip, sprite)
    SetBlipDisplay(dest_blip, 4)
    SetBlipScale(dest_blip, 0.70)
    SetBlipColour(dest_blip, colour)
    SetBlipRoute(dest_blip, true)
    SetBlipAsShortRange(garbageHQBlip, false)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Destination")
    EndTextCommandSetBlipName(dest_blip)

    blipStatus = true

    CreateThread(function()
        while true do
            local distance = Vdist(x, y, z, GetEntityCoords(PlayerPedId()))
            if blipStatus == 'delete' then
                RemoveBlip(dest_blip)
                break
            end
            Wait(1000)
        end
    end)
end

dostava.Functions.GetBox = function()
    CreateThread(function()
        while not haveBox and inJob do
            dostava.Functions.floatingText("Pritisni ~y~E ~w~da uzmes ~g~paket za dostavu", vec3(Config['dostava']['Prop']['x'], Config['dostava']['Prop']['y'], Config['dostava']['Prop']['z'] + 1.0))
            if Vdist(GetEntityCoords(PlayerPedId()), GetEntityCoords(entity)) < 2 then
                if IsControlJustPressed(0, Config['dostava']['ActionKey']) then
                    ClearPedTasksImmediately(PlayerPedId())
                    TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
                    AttachEntityToEntity(entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
                    haveBox = true
                    Wait(200)
                    dostava.Functions.PutBoxInVehicle()
                end
            end
            Wait(0)
        end
    end)
end

dostava.Functions.PutBoxInVehicle = function()
    dostava.Functions.ShowNotification("Odnesi paket do gepeka vozila")
    CreateThread(function()
        while haveBox and inJob do
            local dist = Vdist(GetEntityCoords(vehicle), GetEntityCoords(PlayerPedId()))
                if dist < 4 then
                    dostava.Functions.floatingText("Pritisni ~y~E ~w~da ~g~ostavis paket ~w~u gepek od ~g~vozila", GetEntityCoords(PlayerPedId()))
                    if IsControlJustPressed(0, Config['dostava']['ActionKey']) then
                        DeleteObject(entity)
                        SetVehicleDoorsShut(vehicle, false)
                        ClearPedTasksImmediately(PlayerPedId())
                        haveBox = false
                        gotoPoint = true
                        dostava.Functions.GoToPointAnddostava()
                    end
                end
            Wait(0)
        end
    end)
end

dostava.Functions.GetClosestVehicle = function()
    CreateThread(function()
        Wait(1000)
        while gotoPoint and inJob and not getBox do
            local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
            vehicle2 = ESX.Game.GetClosestVehicle(vec3(px, py, pz))
            Wait(2000)
        end
    end)
end

dostava.Functions.GoToPointAnddostava = function()

    if not HasAnimDictLoaded("anim@heists@box_carry@") then
		RequestAnimDict("anim@heists@box_carry@") 
		while not HasAnimDictLoaded("anim@heists@box_carry@") do 
			Citizen.Wait(0)
		end
	end

    if not HasModelLoaded(Config['dostava']['Prop']['Model']) then
        RequestModel(Config['dostava']['Prop']['Model'])
        while not HasModelLoaded(Config['dostava']['Prop']['Model']) do
            Citizen.Wait(0)
        end
    end

    local dest = math.random(1, #Config['dostava']['Destinacije'])
    dostava.Functions.SetBlipRoutes(Config['dostava']['Destinacije'][dest]['x'], Config['dostava']['Destinacije'][dest]['y'], Config['dostava']['Destinacije'][dest]['z'], 1, 27)
    dostava.Functions.ShowNotification("Idite na ~g~lokaciju koja vam je oznacena na ~r~mapi")
    dostava.Functions.GetClosestVehicle()
    getBox = false
    CreateThread(function()
        Wait(5000)
        while gotoPoint and inJob do
            local msec = 1000
            local dist = Vdist(vec3(Config['dostava']['Destinacije'][dest]['x'], Config['dostava']['Destinacije'][dest]['y'], Config['dostava']['Destinacije'][dest]['z']), GetEntityCoords(PlayerPedId()))
            local isInVeh = IsPedInVehicle(PlayerPedId(), vehicle2)

            if not getBox then
                msec = 500
                local door = GetEntryPositionOfDoor(vehicle2, 3)
                local dist2 = Vdist(door, GetEntityCoords(PlayerPedId()))
                if dist2 < 1 and not getBox then
                    msec = 0
                    dostava.Functions.floatingText("Pritisni ~y~E ~w~da uzmes ~g~paket", GetEntityCoords(PlayerPedId()))
                    if IsControlJustPressed(0, Config['dostava']['ActionKey']) then
                        TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
                        SetVehicleDoorOpen(vehicle2, 3, false, true)
                        Wait(250)
                        SetVehicleDoorOpen(vehicle2, 2, false, true)
                        Wait(5000)
                        ClearPedTasks(PlayerPedId())
                        Wait(2500)
                        entity = CreateObject(Config['dostava']['Prop']['Model'], GetEntityCoords(PlayerPedId()), true, false, false)
                        Wait(150)
                        SetVehicleDoorsShut(vehicle2, false)
                        ClearPedTasksImmediately(PlayerPedId())
                        Wait(750)
                        TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
                        AttachEntityToEntity(entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
                        getBox = true
                    end
                end
            else
                if dist < 8 then
                    msec = 0
                    DrawMarker(1, vec3(Config['dostava']['Destinacije'][dest]['x'], Config['dostava']['Destinacije'][dest]['y'], Config['dostava']['Destinacije'][dest]['z'] - 1.0), 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.1, 255,0,0, 200, 0, 0, 0, 0)
                    if dist < 1.25 then
                        dostava.Functions.floatingText("Pritisni ~y~E ~w~da ostavis ~g~paket ~w~na pod", vec3(Config['dostava']['Destinacije'][dest]['x'], Config['dostava']['Destinacije'][dest]['y'], Config['dostava']['Destinacije'][dest]['z']))
                        if IsControlJustPressed(0, Config['dostava']['ActionKey']) then
                            ClearPedTasksImmediately(PlayerPedId())
                            DeleteObject(entity)
                            Wait(500)
                            blipStatus = 'delete'
                            TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
                            Wait(5000)
                            ClearPedTasks(PlayerPedId())
                            Wait(2500)
                            entity = CreateObject(Config['dostava']['Prop']['Model'], vec3(Config['dostava']['Destinacije'][dest]['x'], Config['dostava']['Destinacije'][dest]['y'], Config['dostava']['Destinacije'][dest]['z'] - 1.0), true, false, false)
                            gotoPoint = false
                            comeBack = true
                            dostava.Functions.ShowNotification("Vratite ~b~vozilo u ~g~restoran")
                            dostava.Functions.ComeBack()
                        end
                    end
                end
            end
            Wait(msec)
        end
    end)
end

dostava.Functions.ComeBack = function()
    dostava.Functions.SetBlipRoutes(Config['dostava']['Vehicles']['Deleter']['x'], Config['dostava']['Vehicles']['Deleter']['y'], Config['dostava']['Vehicles']['Deleter']['z'], 1, 27)
    CreateThread(function()
        while comeBack do
            local msec = 1000
            local dist = Vdist(GetEntityCoords(PlayerPedId()), Config['dostava']['Vehicles']['Deleter'])

            if dist > 60 and dist < 80 then
                DeleteObject(entity)
            end

            if dist < 3 then
                msec = 0
                dostava.Functions.floatingText("Pritisni ~y~E da parkiras ~b~vozilo", GetEntityCoords(GetVehiclePedIsIn(PlayerPedId())))
                if IsControlJustPressed(0, Config['dostava']['ActionKey']) then
                    local v = GetVehiclePedIsIn(PlayerPedId())
                    TaskLeaveVehicle(PlayerPedId(), v)
                    Wait(2500)
                    NetworkFadeOutEntity(v, true, false)
                    Wait(2000)
                    DeleteVehicle(v)
                    DeleteObject(entity)
                    dostava.Functions.Pay()
                    blipStatus = 'delete'
                    comeBack = false
                    inJob = false
                end
            end
            Wait(msec)
        end
    end)
end

dostava.Functions.Pay = function()
    local random = math.random(Config['dostava']['FinalPayout']['Min'], Config['dostava']['FinalPayout']['Max'])

    TriggerServerEvent('kruna_dostava:pay', tonumber(random))
end

RegisterNetEvent('kruna_dostava:clothes', function(option)
    if option == 'ped' then
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            TriggerEvent('skinchanger:loadSkin', skin)
        end)
        haveClothes = false
        print("Default Ped")
    elseif option == 'clothes' then
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            local data = nil
            if skin.sex == 1 then
                data = Config['dostava']['Uniforms']['Male']
            else 
                data = Config['dostava']['Uniforms']['Female']
            end
            TriggerEvent('skinchanger:loadClothes', skin, data)
            haveClothes = true
            print("Job Clothes")
        end)
    end
end)

RegisterNetEvent('kruna_dostava:startJob', function()
    TriggerServerEvent('kruna_dostava:wb', " **".. PlayerData.identifier .."** je zapoceo posao")
    local random = math.random(1, #Config['dostava']['Vehicles']['Cars'])
    local bone = 4089

    if not HasAnimDictLoaded("anim@heists@box_carry@") then
		RequestAnimDict("anim@heists@box_carry@") 
		while not HasAnimDictLoaded("anim@heists@box_carry@") do 
			Citizen.Wait(0)
		end
	end

    if not HasModelLoaded(Config['dostava']['Prop']['Model']) then
        RequestModel(Config['dostava']['Prop']['Model'])
        while not HasModelLoaded(Config['dostava']['Prop']['Model']) do
            Citizen.Wait(0)
        end
    end

    for k, v in pairs(Config['dostava']['Vehicles']['Spawner']['coords']) do
        local vehicles = ESX.Game.GetVehiclesInArea(v, 2)

        if #vehicles == 0 then
            ESX.Game.SpawnVehicle(Config['dostava']['Vehicles']['Cars'][random], v, Config['dostava']['Vehicles']['Spawner']['rotation'], function(veh)
                vehicle = veh
                SetVehicleNumberPlateText(veh, Config['dostava']['Vehicles']['Plate'])
                SetVehicleDoorOpen(veh, 3, false, false)
                SetVehicleDoorOpen(veh, 2, false, false)
            end)
            inJob = true
            inAnim = true
        else
            inAnim = false
            dostava.Functions.ShowNotification("Nema mesta za parkiranje vozila")
        end

        if inAnim then
            entity = CreateObject(Config['dostava']['Prop']['Model'], Config['dostava']['Prop']['x'], Config['dostava']['Prop']['y'], Config['dostava']['Prop']['z'], true, false, false)
            dostava.Functions.GetBox()
            haveBox = false
        else
            dostava.Functions.ShowNotification("Nije moguce pokrenuti dostavu")
        end
    end
end)

RegisterCommand('stopanim', function()
    inAnim = false
    DeleteObject(entity)
    ClearPedTasksImmediately(PlayerPedId())
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    	PlayerData = ESX.GetPlayerData()
	PlayerData.job = job
	dostava.Functions.CheckJob()
end)

local job = false
dostava.Functions.CheckJob = function()
    if PlayerData.job.name == Config['dostava']['JobName'] then
        job = true
    else
        job = false
    end
end

dostava.Functions.StartThread = function()
    CreateThread(function()
        Wait(2000)
        while true do
		dostava.Functions.CheckJob()
            local msec = 3000
            local playerPed = PlayerPedId()
            local pedCoords = GetEntityCoords(playerPed)
            local isInVeh = GetVehiclePedIsIn(playerPed, false)
            local inVeh = IsPedInAnyVehicle(playerPed)
            local dist = nil
                if PlayerData.job.name == Config['dostava']['JobName'] then
                    msec = 1000
                    for k, v in pairs(Config['dostava']['Base']) do
                        local dist = Vdist(pedCoords, v['coords'])
                        if dist < 20 then
                            msec = 0
                            DrawMarker(1, vector3(v['coords']['x'], v['coords']['y'], v['coords']['z'] - 1.0), 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.1, 255,0,0, 200, 0, 0, 0, 0)
                            if dist < 1 then
                                dostava.Functions.floatingText("Pritisni ~y~E ~w~da pristupis  ~g~opcijama posla", v['coords'])
                                if IsControlJustPressed(0, Config['dostava']['ActionKey']) then         
                                    data = {}
                                    if haveClothes and not inJob then
                                        table.insert(data, {text = "vrati se u dnevnu odecu", toDo = [[TriggerEvent('kruna_dostava:clothes', 'ped')]], icon = "fas fa-tshirt"})
                                    elseif not haveClothes and not inJob then
                                        table.insert(data, {text = "obuci se u radnu uniformu", toDo = [[TriggerEvent('kruna_dostava:clothes', 'clothes')]], icon = "fas fa-user-tie"})
                                    end

                                    if inJob then
                                        table.insert(data, {text = "Zaustavi posao", toDo = [[TriggerEvent('kruna_dostava:stopJob')]], icon = "fas fa-truck-loading"})
                                    elseif not inJob and haveClothes then
                                        table.insert(data, {text = "Zapocni posao", toDo = [[TriggerEvent('kruna_dostava:startJob')]], icon = "fas fa-truck-loading"})
                                    end
                                    TriggerEvent("kruna_kont:client:open", "dostava Menu", data)
                                end
                            end
                        end
                    end
                else
                    msec = 3000
                end
            Wait(msec)
        end
    end)
end
