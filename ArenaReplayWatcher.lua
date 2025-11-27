-- Arena Replay Watcher
-- Author: Aladine TK

local addonName, NS = ...

-- Defaults
local defaultDB = {
    matches = {}, -- { {player="Name", id="123", watched=false}, ... }
    settings = {
        serverName = "Warmane",
        ladderURL = "https://armory.warmane.com/ladder"
    }
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

-- Settings Button (Cogwheel)
local SettingsButton = CreateFrame("Button", nil, MainFrame)
SettingsButton:SetSize(20, 20)
SettingsButton:SetPoint("TOPRIGHT", -45, -14)
SettingsButton:SetNormalTexture("Interface\\Icons\\Trade_Engineering")
SettingsButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

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

-- Settings Frame
local SettingsFrame = CreateFrame("Frame", "ArenaReplaySettingsFrame", UIParent)
SettingsFrame:SetSize(400, 220)
SettingsFrame:SetPoint("CENTER")
SettingsFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
SettingsFrame:Hide()
SettingsFrame:SetFrameStrata("DIALOG")
SettingsFrame:SetMovable(true)
SettingsFrame:EnableMouse(true)
SettingsFrame:RegisterForDrag("LeftButton")
SettingsFrame:SetScript("OnDragStart", SettingsFrame.StartMoving)
SettingsFrame:SetScript("OnDragStop", SettingsFrame.StopMovingOrSizing)

local SettingsTitle = SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
SettingsTitle:SetPoint("TOP", 0, -15)
SettingsTitle:SetText("Settings")

local SettingsCloseButton = CreateFrame("Button", nil, SettingsFrame, "UIPanelCloseButton")
SettingsCloseButton:SetPoint("TOPRIGHT", -5, -5)

-- Description Label
local DescLabel = SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
DescLabel:SetPoint("TOPLEFT", 20, -35)
DescLabel:SetWidth(360)
DescLabel:SetJustifyH("LEFT")
DescLabel:SetText("Add the name of your server and the corresponding ladder URL if provided by the server.")

-- Server Name Label
local ServerLabel = SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ServerLabel:SetPoint("TOPLEFT", 20, -70)
ServerLabel:SetText("Server:")

-- Server Name EditBox
local ServerEditBox = CreateFrame("EditBox", nil, SettingsFrame)
ServerEditBox:SetSize(340, 25)
ServerEditBox:SetPoint("TOPLEFT", ServerLabel, "BOTTOMLEFT", 0, -5)
ServerEditBox:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
ServerEditBox:SetFontObject(ChatFontNormal)
ServerEditBox:SetTextInsets(5, 0, 0, 0)
ServerEditBox:SetAutoFocus(false)
ServerEditBox:SetMaxLetters(50)

-- Ladder URL Label
local LadderLabel = SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
LadderLabel:SetPoint("TOPLEFT", ServerEditBox, "BOTTOMLEFT", 0, -10)
LadderLabel:SetText("Ladder URL:")

-- Ladder Link Button (Open External)
local LadderLinkButton = CreateFrame("Button", nil, SettingsFrame, "UIPanelButtonTemplate")
LadderLinkButton:SetSize(50, 20)
LadderLinkButton:SetPoint("LEFT", LadderLabel, "RIGHT", 10, 0)
LadderLinkButton:SetText("Open")

-- Ladder URL EditBox
local LadderEditBox = CreateFrame("EditBox", nil, SettingsFrame)
LadderEditBox:SetSize(340, 25)
LadderEditBox:SetPoint("TOPLEFT", LadderLabel, "BOTTOMLEFT", 0, -5)
LadderEditBox:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
LadderEditBox:SetFontObject(ChatFontNormal)
LadderEditBox:SetTextInsets(5, 0, 0, 0)
LadderEditBox:SetAutoFocus(false)
LadderEditBox:SetMaxLetters(200)

-- Settings Save Button
local SettingsSaveButton = CreateFrame("Button", nil, SettingsFrame, "GameMenuButtonTemplate")
SettingsSaveButton:SetSize(100, 25)
SettingsSaveButton:SetPoint("BOTTOM", 0, 15)
SettingsSaveButton:SetText("Save")

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

-- Settings Button Click Handler
SettingsButton:SetScript("OnClick", function()
    SettingsFrame:Show()
    -- Load current settings
    if ArenaReplayDB and ArenaReplayDB.settings then
        ServerEditBox:SetText(ArenaReplayDB.settings.serverName or "Warmane")
        LadderEditBox:SetText(ArenaReplayDB.settings.ladderURL or "https://armory.warmane.com/ladder")
    end
    ServerEditBox:SetCursorPosition(0)
    LadderEditBox:SetCursorPosition(0)
end)

-- Settings Save Button Handler
SettingsSaveButton:SetScript("OnClick", function()
    if not ArenaReplayDB.settings then
        ArenaReplayDB.settings = {}
    end
    ArenaReplayDB.settings.serverName = ServerEditBox:GetText()
    ArenaReplayDB.settings.ladderURL = LadderEditBox:GetText()
    print("|cff00ff00[ArenaReplay]|r Settings saved!")
    SettingsFrame:Hide()
end)

-- Adds a full frame to copy the URL
local ARENAREPLAY_COPY_URL_Frame = CreateFrame("Frame", "ArenaReplayCopyURLFrame", UIParent, "DialogBoxFrame")
ARENAREPLAY_COPY_URL_Frame:SetSize(800, 115)
ARENAREPLAY_COPY_URL_Frame:SetPoint("CENTER", 0, 150)
ARENAREPLAY_COPY_URL_Frame:Hide()
ARENAREPLAY_COPY_URL_Frame:EnableKeyboard(true) -- Allows Esc/Enter key events

-- 1. Main Text
local TextLabel = ARENAREPLAY_COPY_URL_Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
TextLabel:SetPoint("TOPLEFT", 40, -20)
TextLabel:SetWidth(720) -- Ensure text wraps nicely inside the 800px frame
TextLabel:SetText("Press Ctrl+C to copy the URL:")

-- 2. Custom Edit Box (Crucial for width/multiline)
local EditBox = CreateFrame("EditBox", nil, ARENAREPLAY_COPY_URL_Frame, "InputBoxTemplate")
EditBox:SetSize(720, 30) -- Now it can be 720 wide!
EditBox:SetPoint("TOP", TextLabel, "BOTTOM", 0, -5)
EditBox:SetAutoFocus(true)

-- 3. Show Logic (Function to call when URL is available)
function ArenaReplay_ShowCopyURL(url)
    ARENAREPLAY_COPY_URL_Frame:Show()
    EditBox:SetText(url)
    EditBox:HighlightText() -- Selects the text for easy copying
    EditBox:SetFocus()      -- Ensures keyboard focus is on the box

    -- Handle ESC key to close
    ARENAREPLAY_COPY_URL_Frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" or key == "ENTER" then
            self:Hide()
        end
    end)
end

-- Ladder Link Button Click Handler
LadderLinkButton:SetScript("OnClick", function()
    local url = LadderEditBox:GetText()
    if url and url ~= "" then
        ArenaReplay_ShowCopyURL(url)
    end
end)

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
        if not ArenaReplayDB.settings then
            ArenaReplayDB.settings = {
                serverName = "Warmane",
                ladderURL = "https://armory.warmane.com/ladder"
            }
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
