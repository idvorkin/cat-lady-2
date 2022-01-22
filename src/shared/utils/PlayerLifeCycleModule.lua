-- Player Life Cycle Module
-- Username
-- September 7, 2020
local _  = require(game:GetService("ReplicatedStorage").Common.utils.underscore)

local PlayerLifeCycleModule = {}
PlayerLifeCycleModule.LastPlayerSpawned = nil
PlayerLifeCycleModule.LastCharacterSpawned = nil

local function onPlayerAdded(onCharacterAdded,player)
    PlayerLifeCycleModule.LastPlayerSpawned = player
	if player.Character then
        onCharacterAdded(player.Character)
        PlayerLifeCycleModule.LastCharacterSpawned = player.Character
    else
	    -- Listen for the player (re)spawning 
	    player.CharacterAdded:Connect(onCharacterAdded)
	end
end

function PlayerLifeCycleModule.ConnectOnNewCharacter(onCharacterAdded)
    -- BLEH Need to figure out how to get this stuff passed in.
    -- local _ = self.Shared.underscore
    -- Should be in it's own service
    local Players = game:GetService("Players")

    local boundOnPlayerAdded = _.curry(onPlayerAdded, onCharacterAdded)

    -- Call on player added for everyone already in the game.
    _.each(Players:GetPlayers(), boundOnPlayerAdded)

    -- Register for any new players to be added
    Players.PlayerAdded:Connect(boundOnPlayerAdded)
end



return PlayerLifeCycleModule