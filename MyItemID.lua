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

-- Variables to store the last item ID and settings
local lastItemID = nil
local colorToggle = true -- Variable to toggle color change
local scale = 1.0 -- Default scale
local backdropAlpha = 1.0 -- Default backdrop transparency

-- Saved variables
MyItemID_SavedVariables = MyItemID_SavedVariables or {
    colorToggle = true,
    scale = 1.0,
    backdropAlpha = 1.0,
    point = "CENTER",
    relativePoint = "CENTER",
    xOfs = 0,
    yOfs = 0
}

-- Function to load saved settings
local function LoadSavedSettings()
    colorToggle = MyItemID_SavedVariables.colorToggle
    scale = MyItemID_SavedVariables.scale
    backdropAlpha = MyItemID_SavedVariables.backdropAlpha
    IDDisplay:SetScale(scale)
    IDDisplay:SetBackdropColor(0, 0, 0, backdropAlpha)
    IDDisplay:SetBackdropBorderColor(0, 0, 0, backdropAlpha)
    IDDisplay:ClearAllPoints()
    IDDisplay:SetPoint(MyItemID_SavedVariables.point, UIParent, MyItemID_SavedVariables.relativePoint, MyItemID_SavedVariables.xOfs, MyItemID_SavedVariables.yOfs)
end

-- Apply saved settings
LoadSavedSettings()

-- Function to get item quality color
local function GetItemQualityColor(quality)
    local qualityColors = {
        [0] = "|cff9d9d9d", -- Poor (Gray)
        [1] = "|cffffffff", -- Common (White)
        [2] = "|cff1eff00", -- Uncommon (Green)
        [3] = "|cff0070dd", -- Rare (Blue)
        [4] = "|cffa335ee", -- Epic (Purple)
        [5] = "|cffff8000", -- Legendary (Orange)
        [6] = "|cffe6cc80", -- Artifact (Beige-Gold)
        [7] = "|cffe6cc80", -- Heirloom (Beige-Gold)
    }
    return qualityColors[quality] or "|cffffffff" -- Default to white if quality is not found
end

-- Function to update the displayed item ID and adjust frame size
local function UpdateItemID(itemLink)
    if itemLink and itemLink ~= "" then
        local itemName, _, itemQuality = GetItemInfo(itemLink) -- Get the item info
        lastItemID = select(2, strsplit(":", itemLink)) -- Extract the item ID from the item link
        local qualityColor = colorToggle and GetItemQualityColor(itemQuality) or "|cffffffff" -- Get the color based on item quality or default to white
        itemIDText:SetText(format("|cffFFA500Item ID:|r %s%d|r", qualityColor, lastItemID or 0)) -- Color for label and ID

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
    local itemLink = select(2, self:GetItem())
    UpdateItemID(itemLink)
end)

-- Print the item ID in chat when clicking the frame
IDDisplay:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        if lastItemID then
            print(string.format("|cff00FFFFIDDisplay|r frame shown. |cffFFFFFF%d|r", lastItemID)) -- Print the last item ID in chat
        else
            print("|cff00FFFFIDDisplay|r frame shown. |cffFFFFFFN/A|r") -- Print if last item ID is not found
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
    -- Save the frame position
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    MyItemID_SavedVariables.point = point
    MyItemID_SavedVariables.relativePoint = relativePoint
    MyItemID_SavedVariables.xOfs = xOfs
    MyItemID_SavedVariables.yOfs = yOfs
end)

-- Slash command to handle show/hide, color toggle, scale, backdrop, and reset
SLASH_ITEMID1 = "/itemid"
SlashCmdList["ITEMID"] = function(msg)
    local command, arg = msg:match("^(%S*)%s*(.-)$")
    if command == "show" then
        IDDisplay:Show()
        print("|cff00FFFFIDDisplay|r frame shown.")
    elseif command == "hide" then
        IDDisplay:Hide()
        print("|cff00FFFFIDDisplay|r frame hidden.")
    elseif command == "color" then
        if arg == "on" then
            colorToggle = true
            MyItemID_SavedVariables.colorToggle = true
            print("|cff00FFFFIDDisplay|r item ID color change enabled.")
        elseif arg == "off" then
            colorToggle = false
            MyItemID_SavedVariables.colorToggle = false
            print("|cff00FFFFIDDisplay|r item ID color change disabled.")
        else
            print("|cff00FFFFIDDisplay|r usage: /itemid color on or /itemid color off")
        end
    elseif command == "scale" then
        local scaleValue = tonumber(arg)
        if scaleValue and scaleValue >= 1.0 and scaleValue <= 10.0 then
            scale = scaleValue
            MyItemID_SavedVariables.scale = scaleValue
            IDDisplay:SetScale(scale)
            print("|cff00FFFFIDDisplay|r frame scale set to " .. scale)
        else
            print("|cff00FFFFIDDisplay|r usage: /itemid scale [1.0 - 10.0]")
        end
    elseif command == "bg" then
        local alphaValue = tonumber(arg)
        if alphaValue and alphaValue >= 1.0 and alphaValue <= 10.0 then
            backdropAlpha = alphaValue / 10
            MyItemID_SavedVariables.backdropAlpha = backdropAlpha
            IDDisplay:SetBackdropColor(0, 0, 0, backdropAlpha)
            IDDisplay:SetBackdropBorderColor(0, 0, 0, backdropAlpha)
            print("|cff00FFFFIDDisplay|r backdrop transparency set to " .. alphaValue)
        else
            print("|cff00FFFFIDDisplay|r usage: /itemid bg [1 - 10]")
        end
    elseif command == "reset" then
        MyItemID_SavedVariables = {
            colorToggle = true,
            scale = 1.0,
            backdropAlpha = 1.0,
            point = "CENTER",
            relativePoint = "CENTER",
            xOfs = 0,
            yOfs = 0
        }
        colorToggle = MyItemID_SavedVariables.colorToggle
        scale = MyItemID_SavedVariables.scale
        backdropAlpha = MyItemID_SavedVariables.backdropAlpha
        IDDisplay:SetScale(scale)
        IDDisplay:SetBackdropColor(0, 0, 0, backdropAlpha)
        IDDisplay:ClearAllPoints()
        IDDisplay:SetPoint(MyItemID_SavedVariables.point, UIParent, MyItemID_SavedVariables.relativePoint, MyItemID_SavedVariables.xOfs, MyItemID_SavedVariables.yOfs)
        print("|cff00FFFFIDDisplay|r settings reset.")
    else
        print("|cff00FFFFItemID|r |cffFFFFFFMade by|r |cff00FFFFPegga|r")
        print("|cff00FFFFUsage:|r")
        print("|cff00FFFF/itemid show|r - Show the IDDisplay frame")
        print("|cff00FFFF/itemid hide|r - Hide the IDDisplay frame")
        print("|cff00FFFF/itemid color on/off|r - Toggle item ID color change")
        print("|cff00FFFF/itemid scale [1.0 - 10.0]|r - Set the scale of the IDDisplay frame")
        print("|cff00FFFF/itemid bg [1 - 10]|r - Set the backdrop transparency of the IDDisplay frame")
        print("|cff00FFFF/itemid reset|r - Reset all settings to default")
    end
end

-- Hook into the SetHyperlink function to handle item links from scripts
hooksecurefunc(ItemRefTooltip, "SetHyperlink", function(self, link)
    local itemLink = select(2, GetItemInfo(link))
    UpdateItemID(itemLink)
end)

-- Register events to save and load settings
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "MyItemID" then
        LoadSavedSettings()
    elseif event == "PLAYER_LOGOUT" then
        -- Save the frame position
        local point, _, relativePoint, xOfs, yOfs = IDDisplay:GetPoint()
        MyItemID_SavedVariables.point = point
        MyItemID_SavedVariables.relativePoint = relativePoint
        MyItemID_SavedVariables.xOfs = xOfs
        MyItemID_SavedVariables.yOfs = yOfs
    end
end)

-- Check the game client version and adjust API usage accordingly
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC or WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)

if isClassic then
    -- Classic-specific code
    GameTooltip:HookScript("OnTooltipSetItem", function(self)
        local itemLink = select(2, self:GetItem())
        UpdateItemID(itemLink)
    end)
else
    -- Retail-specific code
    GameTooltip:HookScript("OnTooltipSetItem", function(self)
        local itemLink = select(2, self:GetItem())
        UpdateItemID(itemLink)
    end)
end
