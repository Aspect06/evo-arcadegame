GameData = {}
leftArcade = false

RegisterMenus = function()
    Interaction:RegisterMenu("change_weapon", "Choose New Weapon", "gun", function()
        Callbacks:ServerCallback('Arcade:Server:GetWeapons', GameData.GameMode, function(callback)
            if callback then
                Weapons = {}

                for k, v in ipairs(callback) do
                    table.insert(Weapons, {
                        label = v.Label,
                        event = 'Arcade:Client:ChangeWeapon',
                        data = {
                            Weapon = v.SpawnName
                        }
                    })
                end

                ListMenu:Show({
                    main = {
                        label = 'Choose Weapon',
                        items = Weapons
                    }
                })
            end
        end)

        Interaction:Hide()
    end, function()
        return LocalPlayer.state.inArcade
    end)

    Interaction:RegisterMenu("close_lobby", "Close Lobby", "hand", function()
        TriggerEvent('Arcade:Client:CloseLobby', { id = GameData.GameId })
        Interaction:Hide()
    end, function()
        return LocalPlayer.state.inArcade and GameData.Leader
    end)
end

RegisterCallbacks = function()
    Callbacks:RegisterClientCallback('Arcade:Client:SyncPlayersInGame', function(data, cb)
        GameData.Map = data.MapKey
        GameData.GameMode = data.GameMode
        DoScreenFadeOut(500)

        Callbacks:ServerCallback('Arcade:Server:GetMaps', {}, function(callback)
            LocalPlayer.state.inArcade = true

            SetEntityCoords(PlayerPedId(), callback[data.MapKey].CONFIG.LoadTextureCoords)

            local Camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", callback[data.MapKey].CONFIG.StartCameraCoords.x, callback[data.MapKey].CONFIG.StartCameraCoords.y, callback[data.MapKey].CONFIG.StartCameraCoords.z, 0, 0, callback[data.MapKey].CONFIG.StartCameraCoords.w, 180.00, false, 0)
            SetCamActiveWithInterp(Camera, Camera, 1000, true, true)
            RenderScriptCams(true, false, 1, true, true)
            SetCamFov(Camera, 80.0)

            DoScreenFadeIn(500)

            Callbacks:ServerCallback('Arcade:Server:GetWeapons', data.GameMode, function(callback)
                if callback then
                    Weapons = {}

                    for k, v in ipairs(callback) do
                        table.insert(Weapons, {
                            label = v.Label,
                            event = 'Arcade:Client:Spawn',
                            data = {
                                MAP = data.MapKey,
                                Weapon = v.SpawnName
                            }
                        })
                    end

                    ListMenu:Show({
                        main = {
                            label = 'Choose Weapon',
                            items = Weapons
                        }
                    })
                end
            end)
        end)
    end)

    Callbacks:RegisterClientCallback('Arcade:Client:BringBackToArcade', function(data, cb)
        LocalPlayer.state.inArcade = false
        GameData = {}
        SetEntityCoords(PlayerPedId(), -1658.820, -1069.151, 12.160)
        Polyzone:Remove("ARCADE_PVP_ZONE")
    end)
end

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
    if id == "ARCADE_PVP_ZONE" and LocalPlayer.state.inArcade then
        leftArcade = false
    end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
	if id == "ARCADE_PVP_ZONE" and LocalPlayer.state.inArcade then
        leftArcade = true
        Notification:Error('Return to the zone!', 1000)

        CreateThread(function()
            while leftArcade do
                Wait(1000)
                SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - 15)
            end
        end)
	end
end)

AddEventHandler('Arcade:Client:ChangeWeapon', function(DATA)
    if LocalPlayer.state.inArcade then
        RemoveAllPedWeapons(PlayerPedId())
        GiveWeaponToPed(PlayerPedId(), DATA.Weapon, 500, 1, 0)
        SetCurrentPedWeapon(PlayerPedId(), DATA.Weapon, true)

        GameData.Weapon = DATA.Weapon
    end
end)

RegisterCommand('Arcade', function()
    SetEntityCoords(PlayerPedId(), -1660.29, -1070.63, 12.16)
end)