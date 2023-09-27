-- Create Date : 2020/5/12 10:00:00 by coolzoom https://github.com/coolzoom/vmangos-pbotaddon/tree/master
-- Remaster Date : 2025/2/23 15:31:24 by minzi90 https://github.com/minzi90/vmangos-pbotaddon
-- Constants moved to top and grouped logically
local ADDON_NAME = "VBots"


VBotsDB = VBotsDB or {
    minimapButtonPosition = 268 
}

local isLookingForTemplates = false

local templateScanTimer = 0
local TEMPLATE_SCAN_TIMEOUT = 5


CMD_PARTYBOT_CLONE = ".partybot clone"
CMD_PARTYBOT_REMOVE = ".partybot remove"
CMD_PARTYBOT_ADD = ".partybot add "
CMD_PARTYBOT_SETROLE = ".partybot setrole "
CMD_PARTYBOT_GEAR = ".character premade gear "
CMD_PARTYBOT_SPEC = ".character premade spec "


CMD_BATTLEGROUND_GO = ".go "
CMD_BATTLEBOT_ADD = ".battlebot add "


local BG_INFO = {
    warsong = {
        size = 10,
        minLevel = 10,
        maxLevel = 60
    },
    arathi = {
        size = 15,
        minLevel = 20,
        maxLevel = 60
    },
    alterac = {
        size = 40,
        minLevel = 51,
        maxLevel = 60
    }
}


local useTempBots = false

-- Command queue system
local CommandQueue = {
    commands = {},
    timer = 0,
    processing = false
}


local MinimapButton = {
    shown = true,
    position = VBotsDB.minimapButtonPosition or 268,
    radius = 78,
    cos = math.cos,
    sin = math.sin,
    deg = math.deg,
    atan2 = math.atan2
}


local playerFaction = nil  
local manualFactionOverride = nil 


function GetPlayerFaction()
    
    if manualFactionOverride then
        return manualFactionOverride
    end
    
    
    local _, race = UnitRace("player")
    if race then
        if race == "Human" or race == "Dwarf" or race == "NightElf" or race == "Gnome" then
            return "alliance"
        elseif race == "Orc" or race == "Troll" or race == "Tauren" or race == "Undead" or race == "Scourge" then
            return "horde"
        end
    end
    
   
    if not playerFaction then
        local faction = UnitFactionGroup("player")
        if faction then
            playerFaction = string.lower(faction)
        else
            
            DEFAULT_CHAT_FRAME:AddMessage("Faction detection failed. Using Alliance as default. Use /vbots faction alliance|horde to set manually.")
            playerFaction = "alliance"
        end
    end
    
    return playerFaction
end


function SetPlayerFaction(faction)
    if faction == "alliance" or faction == "horde" then
        manualFactionOverride = faction
        DEFAULT_CHAT_FRAME:AddMessage("Faction manually set to: " .. faction)
        
        InitializeFactionClassButton()
    else
        DEFAULT_CHAT_FRAME:AddMessage("Invalid faction. Use 'alliance' or 'horde'.")
    end
end

SLASH_VBOTS1 = "/vbots"
SlashCmdList["VBOTS"] = function(msg)    
    vbotsFrame:Show()
    MinimapButton.shown = true
    DEFAULT_CHAT_FRAME:AddMessage("VBots window opened")
end

function MinimapButton:UpdatePosition()
    local radian = self.position * (math.pi/180)
    vbotsButtonFrame:SetPoint(
        "TOPLEFT",
        "Minimap",
        "TOPLEFT",
        54 - (self.radius * self.cos(radian)),
        (self.radius * self.sin(radian)) - 55
    )
    self:Init()
end

function MinimapButton:CalculatePosition(xpos, ypos)
    local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
    xpos = xmin - xpos/UIParent:GetScale() + 70
    ypos = ypos/UIParent:GetScale() - ymin - 70
    
    local angle = self.deg(self.atan2(ypos, xpos))
    if angle < 0 then
        angle = angle + 360
    end
    
    self.position = angle
    VBotsDB.minimapButtonPosition = angle 
    self:UpdatePosition()
end

function MinimapButton:Init()
    
    self.position = VBotsDB.minimapButtonPosition or self.position
    
    if self.shown then
        vbotsFrame:Show()
    else
        vbotsFrame:Hide()
    end
end

function MinimapButton:Toggle()
    self.shown = not self.shown
    self:Init()
end


function SubPartyBotClone(self)
    SendChatMessage(CMD_PARTYBOT_CLONE)
end

function SubPartyBotRemove(self)
    SendChatMessage(CMD_PARTYBOT_REMOVE)
end

function SubPartyBotSetRole(self, arg)
    SendChatMessage(CMD_PARTYBOT_SETROLE .. arg)
end

function SubPartyBotAdd(self, arg)
    SendChatMessage(CMD_PARTYBOT_ADD .. arg)
    DEFAULT_CHAT_FRAME:AddMessage("bot added. please search available gear and spec set.")
end

-- BattleGround function
function SubBattleGo(self, arg)
    SendChatMessage(CMD_BATTLEGROUND_GO .. arg)
end


function SubSendGuildMessage(self, arg)
    SendChatMessage(arg, "GUILD", GetDefaultLanguage("player"));
end

function CloseFrame()
    vbotsFrame:Hide()
    MinimapButton.shown = false
end

local VBOTS_NUM_TABS = 4


function vbotsFrame_ShowTab(tabID)
    
    for i=1, VBOTS_NUM_TABS do
        local content = getglobal(vbotsFrame:GetName().."Tab"..i.."Content")
        if content then
            content:Hide()
        end
    end
    
   
    local selectedContent = getglobal(vbotsFrame:GetName().."Tab"..tabID.."Content")
    if selectedContent then
        selectedContent:Show()
    end
end


function OpenFrame()
    DEFAULT_CHAT_FRAME:AddMessage("Loading " .. ADDON_NAME)
    vbotsFrame:Show()
    MinimapButton.shown = true
end


function vbotsFrame_OnLoad()
    
    this.numTabs = VBOTS_NUM_TABS
    
   
    this.selectedTab = 1
    PanelTemplates_SetNumTabs(this, VBOTS_NUM_TABS)
    PanelTemplates_SetTab(this, 1)
    
   
    vbotsFrame_ShowTab(1)
    
    
    this:RegisterEvent("VARIABLES_LOADED")
    DEFAULT_CHAT_FRAME:RegisterEvent('CHAT_MSG_SYSTEM')
end


function vbotsButtonFrame_OnClick()
    vbotsButtonFrame_Toggle()
end

function vbotsButtonFrame_Init()
    MinimapButton:Init()
end

function vbotsButtonFrame_Toggle()
    MinimapButton:Toggle()
end

function vbotsButtonFrame_UpdatePosition()
    MinimapButton:UpdatePosition()
end

function vbotsButtonFrame_BeingDragged()
    local x, y = GetCursorPosition()
    MinimapButton:CalculatePosition(x, y)
end

function vbotsButtonFrame_OnEnter()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:SetText("vmangos bot command, \n click to open/close, \n right mouse to drag me")
    GameTooltip:Show()
end


local templates = {}


function InitializeFactionClassButton()
    local button = getglobal("PartyBotAddFactionClass")
    if button then
        local faction = GetPlayerFaction()
        if faction == "alliance" then
            button:SetText("Add Paladin")
        else
            button:SetText("Add Shaman")
        end
        DEFAULT_CHAT_FRAME:AddMessage("Faction detected as: " .. faction)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function()
    local event = event
    local message = arg1

    if event == "CHAT_MSG_SYSTEM" and message then    
        if isLookingForTemplates then
            if string.find(message, "^%d+%s*-%s*") then
                local _, _, id, name = string.find(message, "^(%d+)%s*-%s*([^%(]+)")
                if id and name then
                    templates[id] = name
                    local dropdown = getglobal("vbotsTemplateDropDown")
                    if dropdown then
                        UIDropDownMenu_Initialize(dropdown, TemplateDropDown_Initialize)
                    end
                end
            end
            
            if string.find(message, "Listing available premade templates") then
                templates = {}
            end
        end
    end

    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN" then
      
        local faction = GetPlayerFaction()
        DEFAULT_CHAT_FRAME:AddMessage("VBots: Detected faction as " .. faction)
        InitializeFactionClassButton()
    end
end)


function TemplateDropDown_Initialize()
    local info = {}
    -- Add header
    info.text = "Select Template"
    info.notClickable = 1
    info.isTitle = 1
    UIDropDownMenu_AddButton(info)

    
    for id, name in pairs(templates) do
        info = {}
        info.text = id .. " - " .. name
        info.func = TemplateDropDown_OnClick
        info.value = id
        UIDropDownMenu_AddButton(info)
    end
end


function TemplateDropDown_OnClick()
    local id = this.value
    local name = templates[id]
    if id and name then
        SendChatMessage(".character premade gear " .. id)
        local dropdownText = getglobal("vbotsTemplateDropDown".."Text")
        if dropdownText then
            dropdownText:SetText(id .. " - " .. name)
        end
    end
end


local function QueueCommand(command)
    table.insert(CommandQueue.commands, command)
    if not CommandQueue.processing then
        CommandQueue.processing = true
        CommandQueue.timer = 0
        CommandQueue.frame:Show()
    end
end


CommandQueue.frame = CreateFrame("Frame")
CommandQueue.frame:Hide()
CommandQueue.frame:SetScript("OnUpdate", function()
    if table.getn(CommandQueue.commands) == 0 then
        CommandQueue.processing = false
        CommandQueue.frame:Hide()
        return
    end

    CommandQueue.timer = CommandQueue.timer + arg1
    if CommandQueue.timer >= 0.5 then 
        local command = table.remove(CommandQueue.commands, 1)
        SendChatMessage(command)
        CommandQueue.timer = 0
        
        if table.getn(CommandQueue.commands) == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("All bots have been added!")
        end
    end
end)

-- Function to fill a battleground -- THANK YOU DIGITAL SCRIPTORIUM FOR THE IDEA - https://www.youtube.com/@Digital-Scriptorium
function SubBattleFill(self, bgType)
    local playerFaction = GetPlayerFaction() 
    local playerLevel = UnitLevel("player")
    local bgData = BG_INFO[bgType]
    
    if not bgData then
        DEFAULT_CHAT_FRAME:AddMessage("Invalid battleground type: " .. bgType)
        return
    end
    
   
    if playerLevel < bgData.minLevel then
        DEFAULT_CHAT_FRAME:AddMessage("You must be at least level " .. bgData.minLevel .. " to queue for " .. bgType)
        return
    end
    
   
    CommandQueue.commands = {}
    CommandQueue.timer = 0
    
    DEFAULT_CHAT_FRAME:AddMessage("Using faction: " .. playerFaction .. " for BG fill")
    
   
    local allianceCount = bgData.size
    if playerFaction == "alliance" then
        allianceCount = bgData.size - 1 
    end
    for i = 1, allianceCount do
        local command = CMD_BATTLEBOT_ADD .. bgType .. " alliance " .. playerLevel
        if useTempBots then
            command = command .. " temp"
        end
        QueueCommand(command)
    end
    
    -- Add Horde bots
    local hordeCount = bgData.size
    if playerFaction == "horde" then
        hordeCount = bgData.size - 1 
    end
    for i = 1, hordeCount do
        local command = CMD_BATTLEBOT_ADD .. bgType .. " horde " .. playerLevel
        if useTempBots then
            command = command .. " temp"
        end
        QueueCommand(command)
    end
    
  
    QueueCommand(CMD_BATTLEGROUND_GO .. bgType)
    
   
    local totalBots = allianceCount + hordeCount
    local botType = useTempBots and "temporary" or "permanent"
    DEFAULT_CHAT_FRAME:AddMessage("Queueing " .. totalBots .. " level " .. playerLevel .. " " .. botType .. " bots for " .. bgType .. " (leaving space for you in " .. playerFaction .. " team)")
end 

function ToggleTempBots()
    useTempBots = not useTempBots
    local status = useTempBots and "enabled" or "disabled"
    DEFAULT_CHAT_FRAME:AddMessage("Temporary bots " .. status)
    
   
    local checkbox = getglobal("TempBotsCheckbox")
    if checkbox then
        checkbox:SetChecked(useTempBots)
    end
end 


local templateScanFrame = CreateFrame("Frame")
templateScanFrame:Hide()
templateScanFrame:SetScript("OnUpdate", function()
    if not isLookingForTemplates then
        templateScanFrame:Hide()
        return
    end
    
    templateScanTimer = templateScanTimer + arg1
    if templateScanTimer >= TEMPLATE_SCAN_TIMEOUT then
        isLookingForTemplates = false
        templateScanTimer = 0
        templateScanFrame:Hide()
        DEFAULT_CHAT_FRAME:AddMessage("Template scanning completed.")
    end
end)


function StartTemplateScan()
    isLookingForTemplates = true
    templateScanTimer = 0
    templateScanFrame:Show()
    DEFAULT_CHAT_FRAME:AddMessage("Looking for templates...")
end


function GearTemplateButtonClick()
    templates = {} 
    StartTemplateScan()
    SendChatMessage(CMD_PARTYBOT_GEAR)
end

function SpecTemplateButtonClick()
    templates = {} 
    StartTemplateScan()
    SendChatMessage(CMD_PARTYBOT_SPEC)
end
