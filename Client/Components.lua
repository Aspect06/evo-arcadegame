AddEventHandler("ArcadeGame:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Callbacks = exports["evo-base"]:FetchComponent("Callbacks")
	ListMenu = exports["evo-base"]:FetchComponent("ListMenu")
	Input = exports["evo-base"]:FetchComponent("Input")
	Notification = exports["evo-base"]:FetchComponent("Notification")
	Logger = exports["evo-base"]:FetchComponent("Logger")
	Targeting = exports["evo-base"]:FetchComponent("Targeting")
	Damage = exports["evo-base"]:FetchComponent("Damage")
	Polyzone = exports["evo-base"]:FetchComponent("Polyzone")
	Notification = exports["evo-base"]:FetchComponent("Notification")
	Interaction = exports["evo-base"]:FetchComponent("Interaction")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["evo-base"]:RequestDependencies("ArcadeGame", {
		"Callbacks",
		"ListMenu",
		"Input",
		"Logger",
		"Targeting",
		"Damage",
		"Polyzone",
		"Notification",
		"Interaction"
	}, function(error)
		if #error > 0 then
			return
		end

		RetrieveComponents()
		RegisterCallbacks()
		RegisterMenus()

		Targeting.Zones:AddBox("arcade_lobbys", "gamepad", vector3(-1660.29, -1070.63, 12.16), 1, 1, {
			heading = 320,
			minZ = 11.16,
			maxZ = 13.16
		}, {
			{
				icon = "play",
				text = "Arcade",
				event = "Arcade:Client:OpenLobbys",
			},
		}, 2.0, true)
	end)
end)