ModifyTraitsMod = {}

-- Function to open the Trait Modification UI
function ModifyTraitsMod.OpenTraitModificationMenu(playerIndex)
    local player = getSpecificPlayer(playerIndex)
    if player then
        local modal = ModifyTraitsUI:new(50, 50, 400, 500, playerIndex)
        modal:initialise()
        modal:addToUIManager()
    end
end

-- Function to add "Modify Traits" to the right-click menu
local function OnFillWorldObjectContextMenu(playerIndex, context, worldobjects)
    -- Add the menu option to modify traits
    context:addOption("Modify Traits", worldobjects, function() 
        ModifyTraitsMod.OpenTraitModificationMenu(playerIndex)
    end)
end

-- Register the context menu event
Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)
