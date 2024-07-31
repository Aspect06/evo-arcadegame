AddEventHandler("ArcadeGame:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
    Callbacks = exports["evo-base"]:FetchComponent("Callbacks")
	Fetch = exports["evo-base"]:FetchComponent("Fetch")
	Routing = exports["evo-base"]:FetchComponent("Routing")
	Logger = exports["evo-base"]:FetchComponent("Logger")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["evo-base"]:RequestDependencies("ArcadeGame", {
		"Callbacks",
		"Fetch",
		"Routing",
		"Logger"
	}, function(error)
		if #error > 0 then
			return
		end

		RetrieveComponents()
		RegisterCallbacks()
	end)
end)