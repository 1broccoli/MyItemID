local IDDisplay = CreateFrame("Frame", "IDDisplayFrame", UIParent, "BackdropTemplate")
IDDisplay:SetSize(100, 25) -- Default frame size
IDDisplay:SetPoint("CENTER") -- Default position

-- Create a backdrop for the frame
IDDisplay:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",  -- Background texture
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",    -- Border texture
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
IDDisplay:SetBackdropColor(0, 0, 0, 0.8)  -- Background color (black with transparency)
IDDisplay:SetBackdropBorderColor(0, 0, 0)  -- Border color (black)

-- Create text for Item ID
local itemIDText = IDDisplay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
itemIDText:SetPoint("TOP", IDDisplay, "TOP", 0, -5)
itemIDText:SetText(format("|cffFFA500Item ID:|r |cffFFFFFFN/A|r")) -- Initial text with color formatting

-- Variable to store the last item ID
local lastItemID = nil

-- Function to update the displayed item ID and adjust frame size
local function UpdateItemID()
    local itemLink = GameTooltip:GetItem() -- Get the item link

    if itemLink and itemLink ~= "" then
        lastItemID = GetItemInfoInstant(itemLink) -- Get the item ID from the item link
        itemIDText:SetText(format("|cffFFA500Item ID:|r |cffFFFFFF%d|r", lastItemID or 0)) -- Orange for label, white for ID

        -- Adjust the frame size based on the text width and height
        local textWidth = itemIDText:GetStringWidth() + 20 -- Adding some padding for width
        local textHeight = itemIDText:GetStringHeight() + 10 -- Adding some padding for height
        IDDisplay:SetSize(math.max(textWidth, 100), math.max(textHeight, 25)) -- Minimum height of 25
    else
        itemIDText:SetText(format("|cffFFA500Item ID:|r |cffFFFFFFN/A|r")) -- Updated to have color formatting
        IDDisplay:SetSize(100, 25) -- Reset to default size when no item is hovered
    end
end

-- Update IDs when hovering over an item
GameTooltip:HookScript("OnTooltipSetItem", function(self)
    UpdateItemID()
end)

-- Print the item ID in chat when clicking the frame
IDDisplay:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        if lastItemID then
            print(string.format("|cffFFA500Item ID:|r |cffFFFFFF%d|r", lastItemID)) -- Print the last item ID in chat
        else
            print("|cffFFA500Item ID:|r |cffFFFFFFN/A|r") -- Print if last item ID is not found
        end
    end
end)

-- Make the frame draggable
IDDisplay:SetMovable(true)
IDDisplay:EnableMouse(true)
IDDisplay:RegisterForDrag("LeftButton")
IDDisplay:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

IDDisplay:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Show the frame at the start
IDDisplay:Show()
