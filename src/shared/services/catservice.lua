local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local _  = require(game:GetService("ReplicatedStorage").Common.utils.underscore)
local PlayerLifeCycle =  require(game:GetService("ReplicatedStorage").Common.utils.PlayerLifeCycleModule)


local count_cats = 20
local default_start_location = Vector3.new(100,0,100)
local eDirection = { up="up", down="down", left="left", right="right"}
local fps = 10
local horizontal_velocity = 2/fps
local vertical_velocity = 4/fps

local cats = {
    s_minimum_cat_height = 1,
    Add = function (self, cat)
        self[cat] = {
            Direction = eDirection.up
        }
    end
}


-- Can't figure out how to map to in game position, so store it externally
-- Arguably, this is closer to a view model, so it's more gooder

function PrintTopLine(txt)
  print (txt)
  -- game.Workspace.Billboard.Label1.Text = txt
end



local i = 0 
function Clone(template)
    local clone = template:Clone()
    clone.Parent = game.Workspace.Clones
    clone.Name = "CLONE:" .. clone.Name  .. i 
    i = i+1
    return clone
end

function NegateRandomly(x)
    local dice = math.random()
    if dice < 0.5 then 
        return -1*x
    end
    return x
end 

function MoveOneSquareRandom(model:Model)
    old_pos = model.PrimaryPart.Position
    if old_pos == nil then
        return
    end
    
    local new_pos = old_pos + Vector3.new(NegateRandomly(1),0,NegateRandomly(1))
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

function MoveHowZachWants(model:Model)
    local target_position = default_start_location
    if PlayerLifeCycle.LastCharacterSpawned ~= nil then
        target_position = PlayerLifeCycle.LastCharacterSpawned.PrimaryPart.Position
    end 
    local old_position = model.PrimaryPart.Position
    local danceDelta, direction = Dance(old_position, cats[model].Direction)
    local closerDelta = MoveCloserToTarget(old_position, target_position)
    local new_position = old_position + danceDelta + closerDelta
    local new_cframe = CFrame.new(new_position, target_position)
    model.PrimaryPart.CFrame = new_cframe
    cats[model].Direction = direction
end 

function MoveCloserToTarget(old_position:Vector3, target_position:Vector3):Vector3
    local delta_x=0
    local delta_z=0

    if old_position.X > target_position.X then
        delta_x = -1* horizontal_velocity
    elseif  old_position.X < target_position.X then
        delta_x = 1*horizontal_velocity
    end 

    if old_position.Z > target_position.Z then
        delta_z = -1*horizontal_velocity
    elseif  old_position.Z < target_position.Z then
        delta_z = 1*horizontal_velocity
    end 

    local delta = Vector3.new (delta_x, 0, delta_z)
    return delta
end 

function Dance(position:Vector3, direction):(Vector3, boolean)
    local max_height = math.random(8,15)
    local min_height = 2
    local delta_y = 0 
    local new_direction = direction

    if direction == eDirection.up then
        delta_y = vertical_velocity
        if position.Y > max_height then
            new_direction = eDirection.down
            delta_y = 0
        end
    elseif direction == eDirection.down then
        delta_y = -1 * vertical_velocity
        if position.Y < min_height then
            new_direction = eDirection.up
            delta_y = 0
        end
    end 

    return Vector3.new(0, delta_y, 0), new_direction
end


local CatService = Knit.CreateService({Name="CatService"})


function NewCrazyCatLady(character)
    PrintTopLine(character.Name .. " Is the new Cat Lady")
end

function getTemplate()
    return game.Workspace.Templates.Cat
end

function CatService:KnitStart()

    print('CatService:Start v0.3')

    PlayerLifeCycle.ConnectOnNewCharacter(NewCrazyCatLady)

    local catTemplate = getTemplate()

    -- Create Cats
    local all_cats = _.map(_.range(count_cats), function (__) return Clone(catTemplate) end)

    _.each(all_cats, function (cat) cats:Add(cat) end)

    --  Move cats to random locations
    _.each(all_cats, MoveRandom)

    -- For Each Cat in Each Tick
    local eachTick = function (cat)
        MoveHowZachWants(cat)
    end

    -- Run the game loop forever
    while true
    do
        -- hack to make linting work by seeing 
        -- the function actually used.
        MoveHowZachWants(_.head(all_cats))
        _.each(all_cats, eachTick)
        task.wait(1/fps)
    end 
end

return CatService