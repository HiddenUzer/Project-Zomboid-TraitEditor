require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"

ModifyTraitsUI = ISPanel:derive("ModifyTraitsUI")

function ModifyTraitsUI:initialise()
    ISPanel.initialise(self)
    
    -- Title Label
    self.titleLabel = ISLabel:new(self.width/2 - 50, 20, 20, "Modify Traits", 1, 1, 1, 1, UIFont.Medium, true)
    self.titleLabel:initialise()
    self.titleLabel:instantiate()
    self:addChild(self.titleLabel)

    -- Available Traits List
    self.availableTraitsLabel = ISLabel:new(20, 50, 20, "Available Traits", 1, 1, 1, 1, UIFont.Small, false)
    self.availableTraitsLabel:initialise()
    self.availableTraitsLabel:instantiate()
    self:addChild(self.availableTraitsLabel)
    
    self.availableTraitsList = ISScrollingListBox:new(20, 70, self.width - 40, 150)
    self.availableTraitsList:initialise()
    self.availableTraitsList:instantiate()
    self.availableTraitsList.itemheight = 22
    self.availableTraitsList.selected = 0
    self.availableTraitsList.joypadParent = self
    self.availableTraitsList.drawBorder = true
    self:addChild(self.availableTraitsList)
    
    -- Player Traits List
    self.playerTraitsLabel = ISLabel:new(20, 230, 20, "Player Traits", 1, 1, 1, 1, UIFont.Small, false)
    self.playerTraitsLabel:initialise()
    self.playerTraitsLabel:instantiate()
    self:addChild(self.playerTraitsLabel)
    
    self.playerTraitsList = ISScrollingListBox:new(20, 250, self.width - 40, 150)
    self.playerTraitsList:initialise()
    self.playerTraitsList:instantiate()
    self.playerTraitsList.itemheight = 22
    self.playerTraitsList.selected = 0
    self.playerTraitsList.joypadParent = self
    self.playerTraitsList.drawBorder = true
    self:addChild(self.playerTraitsList)

    -- Custom trait input
    self.customTraitLabel = ISLabel:new(20, 410, 20, "Custom Trait", 1, 1, 1, 1, UIFont.Small, false)
    self.customTraitLabel:initialise()
    self.customTraitLabel:instantiate()
    self:addChild(self.customTraitLabel)
    
    self.customTraitEntry = ISTextEntryBox:new("", 20, 430, self.width - 40, 25)
    self.customTraitEntry:initialise()
    self.customTraitEntry:instantiate()
    self:addChild(self.customTraitEntry)

    -- Add Trait Button
    self.addTraitButton = ISButton:new(20, 465, 120, 25, "Add Trait", self, ModifyTraitsUI.AddTrait)
    self.addTraitButton:initialise()
    self.addTraitButton:instantiate()
    self:addChild(self.addTraitButton)

    -- Remove Trait Button
    self.removeTraitButton = ISButton:new(150, 465, 120, 25, "Remove Trait", self, ModifyTraitsUI.RemoveTrait)
    self.removeTraitButton:initialise()
    self.removeTraitButton:instantiate()
    self:addChild(self.removeTraitButton)

    -- Close Button
    self.closeButton = ISButton:new(280, 465, 100, 25, "Close", self, ModifyTraitsUI.onClose)
    self.closeButton:initialise()
    self.closeButton:instantiate()
    self:addChild(self.closeButton)
    
    -- Populate trait lists
    self:populateTraitLists()
end

function ModifyTraitsUI:populateTraitLists()
    -- Clear lists
    self.availableTraitsList:clear()
    self.playerTraitsList:clear()
    
    -- Get all available traits
    local allTraits = TraitFactory.getTraits()
    local playerTraits = self.player:getTraits()
    
    -- Sort traits alphabetically
    local sortedTraits = {}
    for i=0, allTraits:size()-1 do
        local trait = allTraits:get(i)
        table.insert(sortedTraits, trait)
    end
    table.sort(sortedTraits, function(a,b) return not string.sort(a:getLabel(), b:getLabel()) end)
    
    -- Add available traits that player doesn't have
    for _, trait in ipairs(sortedTraits) do
        local traitName = trait:getType()
        if not playerTraits:contains(traitName) then
            local cost = trait:getCost()
            local costText = cost > 0 and "+" .. tostring(cost) or tostring(cost)
            self.availableTraitsList:addItem(trait:getLabel() .. " (" .. costText .. ")", traitName)
        end
    end
    
    -- Add player traits
    for i=0, playerTraits:size()-1 do
        local traitName = playerTraits:get(i)
        local trait = TraitFactory.getTrait(traitName)
        if trait then
            local cost = trait:getCost()
            local costText = cost > 0 and "+" .. tostring(cost) or tostring(cost)
            self.playerTraitsList:addItem(trait:getLabel() .. " (" .. costText .. ")", traitName)
        end
    end
end

function ModifyTraitsUI:onClose()
    self:removeFromUIManager()
end

function ModifyTraitsUI:AddTrait()
    local playerObj = self.player
    local traitName = nil
    
    if self.availableTraitsList.selected > 0 then
        -- Add selected trait from list
        local item = self.availableTraitsList.items[self.availableTraitsList.selected]
        traitName = item.item
    else
        -- Add custom trait from text box
        traitName = self.customTraitEntry:getText()
    end
    
    if traitName and traitName ~= "" then
        -- Check if trait exists
        local trait = TraitFactory.getTrait(traitName)
        if not trait and self.customTraitEntry:getText() ~= "" then
            -- Try to find trait by partial name match
            local allTraits = TraitFactory.getTraits()
            for i=0, allTraits:size()-1 do
                local t = allTraits:get(i)
                if string.find(string.lower(t:getType()), string.lower(traitName)) then
                    traitName = t:getType()
                    trait = t
                    break
                end
            end
        end
        
        if trait then
            -- Check for exclusivity conflicts
            local canAdd = true
            local conflictingTraits = ""
            
            for i=0, trait:getMutuallyExclusiveTraits():size()-1 do
                local exclusiveTrait = trait:getMutuallyExclusiveTraits():get(i)
                if playerObj:getTraits():contains(exclusiveTrait) then
                    canAdd = false
                    conflictingTraits = exclusiveTrait .. ", " .. conflictingTraits
                end
            end
            
            if canAdd then
                -- Add trait using proper API
                playerObj:getTraits():add(traitName)
                
                -- Refresh UI
                self:populateTraitLists()
                
                -- Notify player
                playerObj:Say("Added trait: " .. trait:getLabel())
            else
                -- Notify about conflict
                playerObj:Say("Trait conflict with: " .. conflictingTraits:sub(1, -3))
            end
        else
            playerObj:Say("Trait not found")
        end
    end
end

function ModifyTraitsUI:RemoveTrait()
    local playerObj = self.player
    local traitName = nil
    
    if self.playerTraitsList.selected > 0 then
        -- Remove selected trait from list
        local item = self.playerTraitsList.items[self.playerTraitsList.selected]
        traitName = item.item
    else
        -- Remove custom trait from text box
        traitName = self.customTraitEntry:getText()
    end
    
    if traitName and traitName ~= "" then
        -- Check if player has this trait
        if playerObj:getTraits():contains(traitName) then
            -- Remove trait using proper API
            playerObj:getTraits():remove(traitName)
            
            -- Refresh UI
            self:populateTraitLists()
            
            -- Notify player
            local trait = TraitFactory.getTrait(traitName)
            local traitLabel = trait and trait:getLabel() or traitName
            playerObj:Say("Removed trait: " .. traitLabel)
        else
            playerObj:Say("You don't have this trait")
        end
    end
end

function ModifyTraitsUI:prerender()
    ISPanel.prerender(self)
end

function ModifyTraitsUI:render()
    ISPanel.render(self)
end

function ModifyTraitsUI:new(x, y, width, height, player)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = getSpecificPlayer(player)
    o.variableColor = {r=0.9, g=0.55, b=0.1, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}
    o.moveWithMouse = true
    return o
end
