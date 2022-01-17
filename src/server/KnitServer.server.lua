local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local CatService = require(game:GetService("ReplicatedStorage").Common.services.CatService)

Knit.AddServices(game:GetService("ReplicatedStorage").Common.services)

Knit.Start():andThen(function()
    print ("Knit Started on Server")
    -- Knit.GetService("CatService"):AddCat()
    -- CatService.AddCat()
end
):catch(warn)
-- Knit.Start() returns a Promise, so we are catching any errors and feeding it to the built-in 'warn' function
-- You could also chain 'await()' to the end to yield until the whole sequence is completed:
--    Knit.Start():catch(warn):await()