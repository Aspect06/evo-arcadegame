_Lobbys = {}
_inLobby = {}

RegisterCallbacks = function()
    Callbacks:RegisterServerCallback('Arcade:Server:CreateLobby', function(source, data, cb)
        local char = Fetch:Source(source):GetData("Character")
        local lobbyId = #_Lobbys + 1

        _inLobby[char:GetData("SID")] = {
            Id = lobbyId,
            GameMode = data.gamemode,
            Map = _Maps[data.map].LABEL,
            MapKey = data.map,
            Name = data.name,
            LobbyOwner = true,
        }

        _Lobbys[lobbyId] = {
            Id = lobbyId,
            Name = data.name,
            Passcode = data.passcode,
            Description = data.gamemode .. ' | ' .. data.map,
            GameMode = data.gamemode,
            Map = _Maps[data.map].LABEL,
            MapKey = data.map,
            Players = {
                {
                    SID = char:GetData('SID'),
                    Source = source,
                    LobbyOwner = true,
                }
            }
        }

        Wait(500)

        if _Lobbys[lobbyId] ~= nil then
            cb(true)
        else
            cb(false)
        end
    end)

    Callbacks:RegisterServerCallback('Arcade:Server:RemoveLobby', function(source, data, cb)
        for k, v in ipairs(_Lobbys[data.id].Players) do
            if v.Source == nil then return end
            if _Lobbys[data.id].Started then
                Callbacks:ClientCallback(v.Source, "Arcade:Client:BringBackToArcade", {}, function(data)
                    Logger:Info("Arcade", v.Source .. ' brought back to the arcade.')
                end)
            end

            Routing:RoutePlayerToGlobalRoute(v.Source)

            local character = Fetch:Source(v.Source):GetData("Character")
            _inLobby[character:GetData("SID")] = nil
        end

        _Lobbys[data.id] = nil
    end)

    Callbacks:RegisterServerCallback('Arcade:Server:LeaveLobby', function(source, data, cb)
        for k, v in ipairs(_Lobbys[data.id].Players) do
            if v.Source == nil then return end

            Routing:RoutePlayerToGlobalRoute(v.Source)

            _Lobbys[data.id].Players[k] = nil

            local character = Fetch:Source(v.Source):GetData("Character")
            _inLobby[character:GetData("SID")] = nil
        end

        _Lobbys[data.id] = nil
    end)

    Callbacks:RegisterServerCallback('Arcade:Server:GetLobbys', function(source, data, cb)
        cb(_Lobbys)
    end)

    Callbacks:RegisterServerCallback('Arcade:Server:GetMaps', function(source, data, cb)
        cb(_Maps)
    end)

    Callbacks:RegisterServerCallback('Arcade:Server:GetGameModes', function(source, data, cb)
        cb(_GameModes)
    end)

    Callbacks:RegisterServerCallback('Arcade:Server:CheckInLobby', function(source, data, cb)
        local char = Fetch:Source(source):GetData("Character")
        cb(_inLobby[char:GetData("SID")])
    end)

    Callbacks:RegisterServerCallback('Arcade:Server:BeginGame', function(source, data, cb)
        local Game = _Lobbys[data.id]
        local randomValue = math.random(1, 1000)

        _Lobbys[data.id].Started = true

        for k, v in ipairs(Game.Players) do
            Logger:Info("Arcade", "Adding source id " .. v.Source .. ' to bucket ' .. Game.Id + randomValue)

            Routing:AddPlayerToRoute(v.Source, Game.Id + randomValue)

            Callbacks:ClientCallback(v.Source, "Arcade:Client:SyncPlayersInGame", Game, function(data)
                Logger:Info("Arcade", v.Source .. ' synced into lobby.')
			end)
        end

        cb(true)
    end)

    Callbacks:RegisterServerCallback('Arcade:Server:GetWeapons', function(source, data, cb)
        cb(_Loadouts[data])
    end)

    Callbacks:RegisterServerCallback('Arcade:Server:JoinGame', function(source, data, cb)
        print(json.encode(data, {indent = true}))
        local char = Fetch:Source(source):GetData("Character")
        print('Inserting to players')
        print(char:GetData('SID'))
        print(source)
        table.insert(_Lobbys[data.Id].Players, {
            SID = char:GetData('SID'),
            Source = source,
            LobbyOwner = false,
        })

        _inLobby[char:GetData("SID")] = {
            Id = data.Id,
            GameMode = data.GameMode,
            Map = _Maps[data.MapKey].LABEL,
            MapKey = data.MapKey,
            Name = data.Name,
            LobbyOwner = false,
        }

        cb(true)
    end)
end