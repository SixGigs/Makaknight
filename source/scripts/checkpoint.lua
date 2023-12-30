-- Creating the script constants
local pd <const> = playdate
local gfx <const> = playdate.graphics
local gd <const> = pd.datastore.read()


-- Create the checkpoint class
class('Checkpoint').extends(AnimatedSprite)

--- Initialise the checkpoint object using the data given
function Checkpoint:init(x, y, entity)
    -- Initialise the state machine
    local checkpointImageTable = gfx.imagetable.new("images/check-table-64-48")
    Checkpoint.super.init(self, checkpointImageTable)

    -- States
    self:addState("inactive", 1, 1)
    self:addState("activating", 2, 9, {tickStep = 1.5})
    self:addState("active", 10, 14, {tickStep = 3})
    self:addState("deactivating", 15, 24, {tickStep = 1.5})
    self:playAnimation()

    -- Keep the checkpoint checked if the player leaves the room
    self.fields = entity.fields
    self.ID = self.fields.ID

    -- First lets check the cached data
    if self.fields.checked then
        self.active = true
        self:changeState("active")
    else
        self.active = false
        self:changeState("inactive")
    end

    -- Next let's check for game data
    if gd then
        if self.ID == gd.checkpoint then
            self.active = true
            self:changeState("active")
        end
    end

    -- Sprite Properties
    self:setZIndex(Z_INDEXES.Checkpoint)
    self:setCenter(0, 0)
    self:moveTo(x, y)
    self:add()

    -- Set tags and collision rect
    self:setTag(TAGS.Checkpoint)
    self:setCollideRect(28, 15, 7, 33)
end

function Checkpoint:hit()
    self.active = true
    self.fields.checked = true
    self:changeState("activating")
    pd.timer.performAfterDelay(325, function()
        self:changeState("active")
    end)
end

function Checkpoint:deactivate()
    if self.active then
        self:changeState("deactivating")
        pd.timer.performAfterDelay(325, function()
            self:changeState("inactive")
        end)

        self.active = false
        self.fields.checked = false
    end
end