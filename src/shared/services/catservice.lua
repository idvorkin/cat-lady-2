local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local CatService = Knit.CreateService({Name="CatService"})
function CatService:KnitStart()
   print("Server CatService Started")
end

function CatService:AddCat()
   print("CatService Cat Added")
end

function CatService:KnitStop()
   print("Server CatService Ended")
end
return CatService