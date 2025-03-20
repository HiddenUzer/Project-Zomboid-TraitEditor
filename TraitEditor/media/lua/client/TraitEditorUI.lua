require "ISUI/ISPanel"

ModifyTraitsUI = ISPanel:derive("ModifyTraitsUI")

function ModifyTraitsUI:initialise()
    ISPanel.initialise(self)
    
    -- Title Label
    self.titleLabel = ISLabel:new(self.width/2, 20, 20, "Modify Traits", 1, 1, 1, 1, UIFont.Medium, true)
    self.titleLabel:initialise()
    self.titleLabel:instantiate()
    self:addChild(self.titleLabel)

    -- List of Traits
    self.traitsList = ISTextEntryBox:new("", 20, 50, 360, 25)
    self.traitsList:initialise()
    self.traitsList:instantiate()
    self:addChild(self.traitsList)

    -- Add Trait Button
    self.addTraitButton = ISButton:new(20, 100, 120, 30, "Add Trait", self, ModifyTraitsUI.AddTrait)
    self.addTraitButton:initialise()
    self.addTraitButton:instantiate()
    self:addChild(self.addTraitButton)

    -- Remove Trait Button
    self.removeTraitButton = ISButton:new(160, 100, 120, 30, "Remove Trait", self, ModifyTraitsUI.RemoveTrait)
    self.removeTraitButton:initialise()
    self.removeTraitButton:instantiate()
    self:addChild(self.removeTraitButton)

    -- Close Button
    self.closeButton = ISButton:new(300, 100, 80, 30, "Close", self, ModifyTraitsUI.onClose)
    self.closeButton:initialise()
    self.closeButton:instantiate()
    self:addChild(self.closeButton)
end

function ModifyTraitsUI:onClose()
    self:removeFromUIManager()
end

function ModifyTraitsUI:AddTrait()
    local player = self.player
    local trait = self.traitsList:getText()
    if trait and trait ~= "" then
        player:getTraits():add(trait)
        player:Say("Added trait: " .. trait)
    end
end

function ModifyTraitsUI:RemoveTrait()
    local player = self.player
    local trait = self.traitsList:getText()
    if trait and trait ~= "" then
        player:getTraits():remove(trait)
        player:Say("Removed trait: " .. trait)
    end
end

function ModifyTraitsUI:new(x, y, width, height, player)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    return o
end
