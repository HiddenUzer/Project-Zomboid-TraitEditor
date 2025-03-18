ModifyTraitsMod = {}

-- Function to open the Trait Modification UI
function ModifyTraitsMod.OpenTraitModificationMenu(player)
    local modal = ModifyTraitsUI:new(50, 50, 400, 300, player)
    modal:initialise()
    modal:addToUIManager()
end

-- Function to add "Modify Traits" to the right-click menu
local function AddModifyTraitsOption(player, context, worldobjects)
    local playerObj = getSpecificPlayer(player)
    if playerObj then
        context:addOption("Modify Traits", nil, ModifyTraitsMod.OpenTraitModificationMenu, playerObj)
    end
end

Events.OnFillWorldObjectContextMenu.Add(AddModifyTraitsOption)
