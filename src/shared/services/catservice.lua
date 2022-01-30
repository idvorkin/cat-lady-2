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
        local direction = eDirection.up
        self[cat] = {
            Direction = direction
        }
        -- Note you can store the attributes in roblox properties or attributes
        -- TBD: The performance hit, and the code completion may be worse.
        cat:SetAttribute("Direction", direction)
    end
}


-- Can't figure out how to map to in game position, so store it externally
-- Arguably, this is closer to a view model, so it's more gooder

function PrintTopLine(txt)
  print (txt)
  -- game.Workspace.Billboard.Label1.Text = txt
end



local i = 0 
local clones = {}

function AttachCloneToCharector(clone, character)
    local AlignPosition = Instance.new("AlignPosition")
    local cloneAttachmentPoint =  clone.PrimaryPart:FindFirstChildOfClass("Attachment")
    -- XXX: Can I reuse them and just change the Attachment 1? 
    -- Good idea to try later.
    local characterAttachmetPoint = character.PrimaryPart:FindFirstChild("CharacterAttachment")
    AlignPosition.Attachment0 = cloneAttachmentPoint
    AlignPosition.Attachment1 = characterAttachmetPoint
    AlignPosition.MaxForce = 15 -- TBD what these values are
    AlignPosition.MaxVelocity = 15 -- TBD what these values are
    AlignPosition.RigidityEnabled = false
    AlignPosition.Parent = clone


    local AlignOrientation = Instance.new("AlignOrientation")
    AlignOrientation.Attachment0 = cloneAttachmentPoint
    AlignOrientation.Attachment1 = characterAttachmetPoint
    AlignOrientation.MaxTorque = 300 -- TBD what these values are
    AlignOrientation.RigidityEnabled = false
    AlignOrientation.Parent = clone

end

function Clone(template)
    local clone = template:Clone()
    clone.Parent = game.Workspace.Clones
    clone.Name = "CLONE:" .. clone.Name  .. i 
    clones[clone.Name] = clone
    i = i+1

    -- Add an attachment point (I guess i can add this to the model as well?)
    local attachmentPointForClone = Instance.new("Attachment")
    attachmentPointForClone.Name = "CloneAttachment"..clone.Name
    attachmentPointForClone.Parent = clone.PrimaryPart
    return clone
end



-- Use a body mover to move.
-- https://youtu.be/4QjzemDexIs?t=1424

local CatService = Knit.CreateService({Name="CatService"})


function CrazyCatLadyJoined(character)



    PrintTopLine(character.Name .. " Is the new Cat Lady")

    -- QQ: Delete old attachment point(?)
    local characterAttachment = Instance.new("Attachment")
    characterAttachment.Parent = character.PrimaryPart
    characterAttachment.Position = Vector3.new(3,3,0) --  Set Parent Offset
    characterAttachment.Name = "CharacterAttachment" 

    -- If there's an old one erase all the cat attachments
    if PlayerLifeCycle.LastCharacterSpawned then
        _.each(_.values(clones),function(clone)
            AttachCloneToCharector(clone, character)
        end)
    end


end

function getTemplate()
    return game.Workspace.Templates.Cat
end

function CatService:KnitStart()

    print('CatService:Start v0.3')

    PlayerLifeCycle.ConnectOnNewCharacter(CrazyCatLadyJoined)

    local catTemplate = getTemplate()

    -- Create Cats
    local all_cats = _.map(_.range(count_cats), function (__) return Clone(catTemplate) end)

    _.each(all_cats, function (cat) cats:Add(cat) end)

    task.wait(5)
    _.each(_.values(clones),function(clone)
        AttachCloneToCharector(clone, PlayerLifeCycle.LastCharacterSpawned)
    end)

end

return CatService