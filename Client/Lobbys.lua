AddEventHandler('Arcade:Client:OpenLobbys', function()
    Callbacks:ServerCallback('Arcade:Server:CheckInLobby', {}, function(data)
        print(json.encode(data, {indent = true}))
        if data then
            if data.LobbyOwner then
                local LobbyMenu = {
                    main = {
                        label = 'Arcade #' .. data.Id .. ' | Game Mode: ' .. data.GameMode,
                        hideClose = true,
                        items = {
                            {
                                label = 'Information',
                                description = 'Map ' .. data.Map,
                            },
                            {
                                label = 'Start Game',
                                description = 'Begin the game with all people in the lobby!',
                                event = 'Arcade:Client:StartGame',
                                data = {
                                    id = data.Id
                                }
                            },
                            {
                                label = 'Close lobby',
                                description = 'Close the lobby and return to lobby menu.',
                                event = 'Arcade:Client:CloseLobby',
                                data = {
                                    id = data.Id
                                }
                            }
                        },
                    },
                }
                ListMenu:Show(LobbyMenu)
            else
                local LobbyMenu = {
                    main = {
                        label = 'Arcade #' .. data.Id .. ' | Game Mode: ' .. data.GameMode,
                        hideClose = true,
                        items = {
                            {
                                label = 'Information',
                                description = 'Map ' .. data.Map,
                            },
                            {
                                label = 'Leave lobby',
                                description = 'Leave the current lobby you are in.',
                                event = 'Arcade:Client:LeaveLobby',
                                data = {
                                    id = data.Id
                                }
                            }
                        },
                    },
                }
                ListMenu:Show(LobbyMenu)
            end
        else
            Lobbys = {}
            table.insert(Lobbys, {
                label = 'Create New Lobby',
                description = 'Create your own lobby!',
                event = 'Arcade:Client:CreateLobby',
            })
        
            Callbacks:ServerCallback('Arcade:Server:GetLobbys', {}, function(data)
                for key, value in pairs(data) do
                    table.insert(Lobbys, {
                        label = value.Name,
                        description = value.Description,
                        event = 'Arcade:Client:LobbyPasscode',
                        data = value
                    })
                end
            end)
        
            Wait(500)
        
            ListMenu:Show({
                main = {
                    label = 'Arcade',
                    items = Lobbys,
                },
            })
        end
    end)
end)

AddEventHandler("Arcade:Client:CreateLobby", function(data)
    MapOptions = {}
    GameModes = {}

    Callbacks:ServerCallback('Arcade:Server:GetMaps', {}, function(data)
        for key, value in pairs(data) do
            table.insert(MapOptions, {
                label = value.LABEL,
                value = key,
            })
        end
    end)

    Callbacks:ServerCallback('Arcade:Server:GetGameModes', {}, function(data)
        for key, value in pairs(data) do
            if value.disabled then return end
            table.insert(GameModes, {
                label = value.Label,
                value = value.Label
            })
        end
    end)

    Wait(500)

    Input:Show("Lobby Settings", "Match Configuration", {
        {
            label = 'Lobby Name',
            id = "name",
            type = "text",
            options = {
                inputProps = {
                    maxLength = 24,
                },
            },
        },
        {
            id = "passcode",
            label = 'Passcode',
            type = "text",
            options = {
                inputProps = {
                    maxLength = 5,
                },
            },
        },
        {
            id = "gamemode",
            label = 'Game Mode',
            type = "select",
            select = GameModes,
            options = {},
        },
        {
            id = "map",
            type = "select",
            label = 'Map',
            select = MapOptions,
            options = {},
        },
    }, "Arcade:Client:SubmitGame", data)
end)

AddEventHandler('Arcade:Client:SubmitGame', function(data)
    Callbacks:ServerCallback('Arcade:Server:CreateLobby', data, function(callback)
        if callback then
            Notification:Info("Lobby created.", 2000)
        else
            Notification:Error("Failed to create lobby.")
        end
    end)
end)

AddEventHandler('Arcade:Client:LobbyPasscode', function(data)
    GameData = data
    Input:Show("Lobby Passcode", "Passcode", {
        {
            id = "passcode",
            type = "password",
            options = {
                inputProps = {
                    maxLength = 5,
                },
            },
        },
    }, "Arcade:Client:SubmitPasscode", data)
end)

AddEventHandler('Arcade:Client:CloseLobby', function(data)
    Callbacks:ServerCallback('Arcade:Server:RemoveLobby', { id = data.id }, function(callback) end)
end)

AddEventHandler('Arcade:Client:LeaveLobby', function(data)
    Callbacks:ServerCallback('Arcade:Server:LeaveLobby', { id = data.id }, function(callback) end)
end)

AddEventHandler('Arcade:Client:StartGame', function(data)
    GameData.GameId = data.id
    GameData.Leader = true

    Callbacks:ServerCallback('Arcade:Server:BeginGame', { id = data.id }, function(callback) end)
end)

AddEventHandler('Arcade:Client:Spawn', function(DATA)
    if LocalPlayer.state.inArcade then
        DestroyAllCams(true)
        RenderScriptCams(false, true, 1, true, true)

        Callbacks:ServerCallback('Arcade:Server:GetMaps', {}, function(callback)
            local Spawn = math.random(#callback[DATA.MAP].RESPAWN_LOCATIONS)

            SetEntityCoords(PlayerPedId(), callback[DATA.MAP].RESPAWN_LOCATIONS[Spawn].x, callback[DATA.MAP].RESPAWN_LOCATIONS[Spawn].y, callback[DATA.MAP].RESPAWN_LOCATIONS[Spawn].z)
            SetEntityHeading(PlayerPedId(), callback[DATA.MAP].RESPAWN_LOCATIONS[Spawn].w)

            RemoveAllPedWeapons(PlayerPedId())
            GiveWeaponToPed(PlayerPedId(), DATA.Weapon, 500, 1, 0)
            SetCurrentPedWeapon(PlayerPedId(), DATA.Weapon, true)

            GameData.Weapon = DATA.Weapon
            Logger:Info("Arcade", "Setting player coords to " .. callback[DATA.MAP].RESPAWN_LOCATIONS[Spawn] .. ' in map ' .. DATA.MAP .. ' with gun ' ..DATA.Weapon)

            Polyzone.Create:Box("ARCADE_PVP_ZONE", callback[DATA.MAP].POLYZONE.vector3, callback[DATA.MAP].POLYZONE.data.length, callback[DATA.MAP].POLYZONE.data.width, {
                heading = callback[DATA.MAP].POLYZONE.data.heading,
                minZ = callback[DATA.MAP].POLYZONE.data.minZ,
                maxZ = callback[DATA.MAP].POLYZONE.data.maxZ,
            })
        end)

        CreateThread(function()
            while LocalPlayer.state.inArcade do
                SetVehicleDensityMultiplierThisFrame(0.0)
                SetRandomVehicleDensityMultiplierThisFrame(0.0)
                SetParkedVehicleDensityMultiplierThisFrame(0.0)
                SetPedDensityMultiplierThisFrame(0.0)
                SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)

                Citizen.Wait(0)
            end
        end)
    end
end)

AddEventHandler('Arcade:Client:SubmitPasscode', function(data)
    if data.passcode == GameData.Passcode then
        Callbacks:ServerCallback('Arcade:Server:JoinGame', GameData, function(callback)
            if callback then
                Notification:Info('You joined the lobby.')
            else
                Notification:Error("Something went wrong.")
            end
        end)
    else
        Notification:Error("Wrong password.")
    end
end)