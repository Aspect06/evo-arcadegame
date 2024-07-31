RegisterNetEvent('Arcade:Client:RespawnPlayer', function()
    Callbacks:ServerCallback('Arcade:Server:GetMaps', {}, function(callback)
        Damage:Revive()
        LocalPlayer.state:set("isDead", false, true)

        local Spawn = math.random(#callback[GameData.Map].RESPAWN_LOCATIONS)

        SetEntityCoords(PlayerPedId(), callback[GameData.Map].RESPAWN_LOCATIONS[Spawn].x, callback[GameData.Map].RESPAWN_LOCATIONS[Spawn].y, callback[GameData.Map].RESPAWN_LOCATIONS[Spawn].z)
        SetEntityHeading(PlayerPedId(), callback[GameData.Map].RESPAWN_LOCATIONS[Spawn].w)

        Wait(1500)

        RemoveAllPedWeapons(PlayerPedId())
        GiveWeaponToPed(PlayerPedId(), GameData.Weapon, 500, 1, 0)
        SetCurrentPedWeapon(PlayerPedId(), GameData.Weapon, true)
    end)
end)