local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local _  = require(game:GetService("ReplicatedStorage").Common.utils.underscore)
local PlayerLifeCycle =  require(game:GetService("ReplicatedStorage").Common.utils.PlayerLifeCycleModule)


local Players
local count_cats = 20
local g_last_player_spawned =  nil  -- LastPlayerAdded
local player_pos = Vector3.new(100,0,100)

-- Can't figure out how to map to in game position, so store it externally
-- Arguably, this is closer to a view model, so it's more gooder

function PrintTopLine(txt)
  print (txt)
  -- game.Workspace.Billboard.Label1.Text = txt
end

function model_to_movable(model)
   return model.Cat
end 


local i = 0 
function Clone(template)
    local clone = template:Clone()
    clone.Parent = game.Workspace
    clone.Name = "CLONE:" .. clone.Name  .. i 
    i = i+1
    return clone
end

function randomNegate(x)
    local dice = math.random()
    if dice < 0.5 then 
        return -1*x
    end
    return x
end 

function MoveOneSquareRandom(model)
    old_pos = model_to_movable(model).Position
    if old_pos == nil then
        return
    end

    local new_x  = old_pos.X + randomNegate(1) 
    local new_z  = old_pos.Z + randomNegate(1)
    local new_pos = Vector3.new(new_x,old_pos.y, new_z)
    -- print (old_pos)
    -- print (new_pos)
    model:MoveTo(new_pos)
end

function MoveRandom(model)
    local radius = 100
    local x = math.random(-1*radius, 1*radius)
    local z = math.random(-1*radius, 1*radius)
    local location = Vector3.new(x,0,z)
    model:MoveTo(location)
end

function MoveHowZachWants(model)
    DanceUpAndDown(model)
    local target_pos = player_pos
    if g_last_player_spawned ~= nil then
        target_pos = g_last_player_spawned.PrimaryPart.Position
    end 
    MoveCloserToPosition(model, target_pos)
end 

function MoveCloserToPosition(model, player_pos)
    old_pos = model_to_movable(model).Position
    if old_pos == nil then
        return
    end
    local delta_x=0
    local delta_y=0
    local delta_z=0
    local velocity = 5

    if old_pos.x > player_pos.x then
        delta_x = -1* velocity
    elseif  (old_pos.x < player_pos.x) then
        delta_x = 1*velocity
    end 

    if old_pos.z > player_pos.z then
        delta_z = -1*velocity
    elseif  (old_pos.z < player_pos.z) then
        delta_z = 1*velocity
    end 

    local delta = Vector3.new (delta_x, delta_y, delta_z)
    local new_pos = old_pos + delta
    model:MoveTo(new_pos)
end 

function DanceUpAndDown(model)
    old_pos = model_to_movable(model).Position
    if old_pos == nil then
        return
    end
    local rand = math.random() -- return a number from 0 to 1
    local velocity = 2
    local delta_y = 1

    if rand > 0.5 then
        delta_y = 1 * math.random(velocity)
    else
        delta_y = -1 * math.random(velocity)
    end 

    local new_pos = old_pos + Vector3.new(0,delta_y, 0)
    model:MoveTo(new_pos)
end


local CatService = Knit.CreateService({Name="CatService"})


function NewCrazyCatLady(character)
    g_last_player_spawned = character
    PrintTopLine(character.Name .. " Is the new Cat Lady")
end


function CatService:KnitStart()

    print('CatService:Start v0.2')

    PlayerLifeCycle.ConnectOnNewCharacter(_, NewCrazyCatLady)

    local catTemplate = game.Workspace.Templates.Cat --put the name of the folder here

    -- Create Cats
    local all_cats = _.map(_.range(count_cats), function (i) return Clone(catTemplate) end)

    --  Move cats to random locations
    _.each(all_cats, MoveRandom)

    -- For Each Cat in Each Tick
    local eachTick = function (cat)
        MoveHowZachWants(cat)
    end

    -- Run The Cat Game Loop
    _.each(_.range(1000), function (i)
        _.each(all_cats, eachTick)
        wait (1)
    end )
end

return CatService