-- Arena Replay Watcher
-- Author: Aladine TK

local addonName, NS = ...

-- Defaults
local defaultDB = {
    matches = {}, -- { {player="Name", id="123", watched=false}, ... }
}

-- Main Frame
local MainFrame = CreateFrame("Frame", "ArenaReplayWatcherFrame", UIParent)
MainFrame:SetSize(400, 500)
MainFrame:SetPoint("CENTER")
MainFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
MainFrame:SetMovable(true)
MainFrame:EnableMouse(true)
MainFrame:RegisterForDrag("LeftButton")
MainFrame:SetScript("OnDragStart", MainFrame.StartMoving)
MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing)
MainFrame:Hide()

-- Decorative header texture behind title
local HeaderTexture = MainFrame:CreateTexture(nil, "ARTWORK")
HeaderTexture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
HeaderTexture:SetWidth(360)
HeaderTexture:SetHeight(67)
HeaderTexture:SetPoint("TOP", 0, 12)

-- Title
local Title = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Title:SetPoint("TOP", -12, -3)
Title:SetText("Arena Replay Watcher ")

local TitleCmd = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
TitleCmd:SetPoint("LEFT", Title, "RIGHT", 0, 0)
TitleCmd:SetText("/arw")
TitleCmd:SetTextColor(0.7, 0.7, 0.7)

-- Close Button
local CloseButton = CreateFrame("Button", nil, MainFrame, "UIPanelCloseButton")
CloseButton:SetPoint("TOPRIGHT", -5, -5)

-- Headers
local HeaderReplay = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
HeaderReplay:SetPoint("TOPLEFT", 25, -35)
HeaderReplay:SetText("Replay")

local HeaderAction = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
HeaderAction:SetPoint("TOPRIGHT", -80, -35)
HeaderAction:SetText("Action")

local HeaderWatched = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
HeaderWatched:SetPoint("RIGHT", HeaderAction, "LEFT", -15, 0)
HeaderWatched:SetText("Watched")

-- Scroll Frame for List
local ScrollFrame = CreateFrame("ScrollFrame", "ArenaReplayWatcherScrollFrame", MainFrame, "UIPanelScrollFrameTemplate")
ScrollFrame:SetPoint("TOPLEFT", 20, -55)
ScrollFrame:SetPoint("BOTTOMRIGHT", -40, 50)

local ScrollChild = CreateFrame("Frame")
ScrollChild:SetSize(340, 1000) -- Height will be adjusted dynamically
ScrollFrame:SetScrollChild(ScrollChild)

-- Import Button
local ImportButton = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate")
ImportButton:SetSize(100, 25)
ImportButton:SetPoint("BOTTOMLEFT", 20, 15)
ImportButton:SetText("Import CSV")

-- Clear Button
local ClearButton = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate")
ClearButton:SetSize(100, 25)
ClearButton:SetPoint("BOTTOMRIGHT", -20, 15)
ClearButton:SetText("Clear All")

-- Import Window
local ImportFrame = CreateFrame("Frame", "ArenaReplayImportFrame", UIParent)
ImportFrame:SetSize(400, 300)
ImportFrame:SetPoint("CENTER")
ImportFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
ImportFrame:Hide()
ImportFrame:SetFrameStrata("DIALOG")

local ImportTitle = ImportFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ImportTitle:SetPoint("TOP", 0, -15)
ImportTitle:SetText("Paste CSV (Player,ID)")

local ImportScrollFrame = CreateFrame("ScrollFrame", "ArenaReplayWatcherImportScrollFrame", ImportFrame, "UIPanelScrollFrameTemplate")
ImportScrollFrame:SetPoint("TOPLEFT", 20, -40)
ImportScrollFrame:SetPoint("BOTTOMRIGHT", -40, 50)

local ImportEditBox = CreateFrame("EditBox", nil, ImportScrollFrame)
ImportEditBox:SetMultiLine(true)
ImportEditBox:SetFontObject(ChatFontNormal)
ImportEditBox:SetWidth(340)
ImportScrollFrame:SetScrollChild(ImportEditBox)

local ImportSaveButton = CreateFrame("Button", nil, ImportFrame, "GameMenuButtonTemplate")
ImportSaveButton:SetSize(100, 25)
ImportSaveButton:SetPoint("BOTTOM", 0, 15)
ImportSaveButton:SetText("Save")

local ImportCloseButton = CreateFrame("Button", nil, ImportFrame, "UIPanelCloseButton")
ImportCloseButton:SetPoint("TOPRIGHT", -5, -5)

-- Logic

local function RefreshList()
    -- Clear existing children
    local kids = {ScrollChild:GetChildren()}
    for _, child in ipairs(kids) do
        child:Hide()
        child:SetParent(nil)
    end

    local yOffset = 0
    for i, match in ipairs(ArenaReplayDB.matches) do
        local row = CreateFrame("Frame", nil, ScrollChild)
        row:SetSize(340, 20)
        row:SetPoint("TOPLEFT", 0, -yOffset)

        local check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        check:SetSize(20, 20)
        check:SetPoint("LEFT", 0, 0)
        check:SetChecked(match.watched)
        check:SetScript("OnClick", function(self)
            match.watched = self:GetChecked()
        end)

        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", 5, 0)
        text:SetText(match.player .. " (" .. match.id .. ")")

        -- Delete Button (X)
        local deleteBtn = CreateFrame("Button", nil, row, "UIPanelCloseButton")
        deleteBtn:SetSize(20, 20)
        deleteBtn:SetPoint("RIGHT", 0, 0)
        deleteBtn:SetScript("OnClick", function()
            table.remove(ArenaReplayDB.matches, i)
            RefreshList()
        end)

        -- Watch Button
        local watchBtn = CreateFrame("Button", nil, row, "GameMenuButtonTemplate")
        watchBtn:SetSize(60, 18)
        watchBtn:SetPoint("RIGHT", deleteBtn, "LEFT", -5, 0)
        watchBtn:SetText("Watch")
        watchBtn:SetNormalFontObject("GameFontNormalSmall")
        watchBtn:SetHighlightFontObject("GameFontHighlightSmall")
        
        -- Move checkbox to left of watch button
        check:ClearAllPoints()
        check:SetPoint("RIGHT", watchBtn, "LEFT", -5, 0)
        
        watchBtn:SetScript("OnClick", function()
            -- Interaction Logic
            if not GossipFrame:IsShown() then
                print("|cff00ff00[ArenaReplay]|r Please target and talk to the 'Arena Spectator' NPC first.")
                return
            end

            local options = {GetGossipOptions()}
            local found = false
            for j=1, #options, 2 do
                if options[j] == "Replay a Match ID" then
                    SelectGossipOption(math.ceil(j/2))
                    found = true
                    break
                end
            end

            if found then
                if StaticPopup1 and StaticPopup1:IsShown() then
                    StaticPopup1EditBox:SetText(match.id)
                    StaticPopup1Button1:Click()
                    match.watched = true
                    check:SetChecked(true)
                else
                    C_Timer.After(0.5, function()
                        if StaticPopup1 and StaticPopup1:IsShown() then
                            StaticPopup1EditBox:SetText(match.id)
                            StaticPopup1Button1:Click()
                            match.watched = true
                            check:SetChecked(true)
                        end
                    end)
                end
            else
                print("|cff00ff00[ArenaReplay]|r Could not find 'Replay a Match ID' option.")
            end
        end)

        yOffset = yOffset + 20
    end
    ScrollChild:SetHeight(yOffset)
end

ImportButton:SetScript("OnClick", function()
    ImportFrame:Show()
    ImportEditBox:SetText("")
    ImportEditBox:SetFocus()
end)

ClearButton:SetScript("OnClick", function()
    ArenaReplayDB.matches = {}
    RefreshList()
end)

ImportSaveButton:SetScript("OnClick", function()
    local text = ImportEditBox:GetText()
    -- Parse CSV: Player,ID
    -- Handle newlines
    for line in text:gmatch("[^\r\n]+") do
        local player, id = line:match("([^,]+),%s*([^,]+)")
        if player and id then
            -- Trim spaces
            player = player:match("^%s*(.-)%s*$")
            id = id:match("^%s*(.-)%s*$")
            table.insert(ArenaReplayDB.matches, {player = player, id = id, watched = false})
        end
    end
    ImportFrame:Hide()
    RefreshList()
end)

-- Event Handling
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ArenaReplayWatcher" then
        if not ArenaReplayDB then
            ArenaReplayDB = defaultDB
        end
        if not ArenaReplayDB.matches then
            ArenaReplayDB.matches = {}
        end
        RefreshList()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- Slash Command
SLASH_ARENAREPLAY1 = "/arw"
SLASH_ARENAREPLAY2 = "/arenareplay"
SlashCmdList["ARENAREPLAY"] = function(msg)
    if MainFrame:IsShown() then
        MainFrame:Hide()
    else
        MainFrame:Show()
    end
end
