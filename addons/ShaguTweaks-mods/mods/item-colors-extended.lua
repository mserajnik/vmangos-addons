local _G = ShaguTweaks.GetGlobalEnv()
local L, T = ShaguTweaks.L, ShaguTweaks.T
local AddBorder = ShaguTweaks.AddBorder
local HookAddonOrVariable = ShaguTweaks.HookAddonOrVariable

local module = ShaguTweaks:register({
  title = T["Item Rarity Borders Extended"],
  description = T["Extends item rarity as the border color to merchant, craft, tradeskill, mail, trade and loot frames."],
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  category = T["Tooltip & Items"],
  enabled = false,
})

local defcolor = {}

local suffixes = {
  "of the Tiger", "of the Bear", "of the Gorilla", "of the Boar", "of the Monkey", "of the Falcon", "of the Wolf", "of the Eagle", "of the Whale", "of the Owl",
  "of Spirit", "of Intellect", "of Strength", "of Stamina", "of Agility",
  "of Defense", "of Healing", "of Power", "of Blocking", "of Marksmanship", "of Eluding",
  "of Frozen Wrath", "of Arcane Wrath", "of Fiery Wrath", "of Nature's Wrath", "of Shadow Wrath",
  "of Fire Resistance", "of Nature Resistance", "of Arcane Resistance", "of Frost Resistance", "of Shadow Resistance",
  "of Fire Protection", "of Nature Protection", "of Arcane Protection", "of Frost Protection", "of Shadow Protection",
}

local function remove_suffix(item)
  if not item then return end
  for _, suffix in ipairs(suffixes) do
      item = string.gsub(item, "%s" .. suffix .. "$", "")
  end
  return item
end

-- https://github.com/shagu/pfUI/blob/ebaebc6304625a47b825779231df9d4a054fd228/api/api.lua
-- [ GetItemLinkByName ]
-- Returns an itemLink for the given itemname
-- 'name'       [string]         name of the item
-- returns:     [string]         entire itemLink for the given item
local function GetItemLinkByName(name)
  name = remove_suffix(name)
  for itemID = 1, 25818 do
    local itemName, hyperLink, itemQuality = GetItemInfo(itemID)
    if (itemName and itemName == name) then
      local _, _, _, hex = GetItemQualityColor(tonumber(itemQuality))
      return hex.. "|H"..hyperLink.."|h["..itemName.."]|h|r"
    end
  end
end

-- HerrTiSo / That Guy Turtles addition: Disable low quality item glow
local function SetGlowForQuality(button, quality, defaultColor)
  if quality and quality > 1 then
    local r, g, b = GetItemQualityColor(quality)
    button.ShaguTweaks_border:SetBackdropBorderColor(r, g, b, 1)
  else
    button.ShaguTweaks_border:SetBackdropBorderColor(defaultColor[1], defaultColor[2], defaultColor[3], 0)
  end
end

module.enable = function(self)
  local dis
  if IsAddOnLoaded("lilsparkysworkshop") then
    dis = true
  end

 

  do -- tradeskill
    if not dis then
      local refresh_tradeskill = function()
        local id = TradeSkillFrame.selectedSkill

        do
          -- icon
          local button = _G["TradeSkillSkillIcon"]
          local border = button.ShaguTweaks_border

          if not border then
            border = AddBorder(button, 3, { r = .5, g = .5, b = .5 })
          end

          if not defcolor["tradeskill"] then
            defcolor["tradeskill"] = { border:GetBackdropBorderColor() }
          end

          button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["tradeskill"][1], defcolor["tradeskill"][2], defcolor["tradeskill"][3], 0)

          local link = GetTradeSkillItemLink(id)
          if link then
            local _, _, istring = string.find(link, "|H(.+)|h")
            local _, _, q = GetItemInfo(istring)
            if q then
              SetGlowForQuality(button, q, defcolor["tradeskill"])
            end
          end
        end

        do
          -- reagents
          for i = 1, GetTradeSkillNumReagents(id) do
            local button = _G["TradeSkillReagent"..i]
            local border = button.ShaguTweaks_border

            if not border then
              border = AddBorder(button, 1, { r = .5, g = .5, b = .5 })
              border:ClearAllPoints()
              local icon = _G["TradeSkillReagent"..i.."IconTexture"]
              border:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
              border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
              border:SetFrameLevel(1)
            end

            if not defcolor["tradeskill"] then
              defcolor["tradeskill"] = { border:GetBackdropBorderColor() }
            end

            button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["tradeskill"][1], defcolor["tradeskill"][2], defcolor["tradeskill"][3], 0)

            local link = GetTradeSkillReagentItemLink(id, i)
            if link then
              local _, _, istring = string.find(link, "|H(.+)|h")
              local _, _, q = GetItemInfo(istring)
                if q then
                SetGlowForQuality(button, q, defcolor["tradeskill"])
              end
            end
          end
        end
      end

      HookAddonOrVariable("Blizzard_TradeSkillUI", function()
        local HookTradeSkillFrame_Update = TradeSkillFrame_Update
        TradeSkillFrame_Update = function(arg)
          HookTradeSkillFrame_Update(arg)
          refresh_tradeskill()
        end
      end)
    end
  end

  do -- craft
    if not dis then
      local refresh_craft = function()
        local id = GetCraftSelectionIndex()

        do
          -- icon
          local button = _G["CraftIcon"]
          local border = button.ShaguTweaks_border

          if not border then
            border = AddBorder(button, 3, { r = .5, g = .5, b = .5 })
          end
          if not defcolor["craft"] then
            defcolor["craft"] = { border:GetBackdropBorderColor() }
          end

          button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["craft"][1], defcolor["craft"][2], defcolor["craft"][3], 0)
          local iname = GetCraftInfo(id)
          local link = GetItemLinkByName(iname)
          if link then
            local _, _, istring = string.find(link, "|H(.+)|h")
            local _, _, q = GetItemInfo(istring)
            if q then
              SetGlowForQuality(button, q, defcolor["craft"])
            end
          end
        end

        do
          -- reagents
          for i = 1, GetCraftNumReagents(id) do
            local button = _G["CraftReagent"..i]
            local border = button.ShaguTweaks_border

            if not border then
              border = AddBorder(button, 1, { r = .5, g = .5, b = .5 })
              border:ClearAllPoints()
              local icon = _G["CraftReagent"..i.."IconTexture"]
              border:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
              border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
              border:SetFrameLevel(1)
            end

            if not defcolor["craft"] then
              defcolor["craft"] = { border:GetBackdropBorderColor() }
            end

            button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["craft"][1], defcolor["craft"][2], defcolor["craft"][3], 0)

            local iname = GetCraftReagentInfo(id, i)
            local link = GetItemLinkByName(iname)
            if link then
              local _, _, istring = string.find(link, "|H(.+)|h")
              local _, _, q = GetItemInfo(istring)
              if q then
                SetGlowForQuality(button, q, defcolor["craft"])
              end
            end
          end
        end
      end

      HookAddonOrVariable("Blizzard_CraftUI", function()
        local HookCraftFrame_Update = CraftFrame_Update
        CraftFrame_Update = function(arg)
          HookCraftFrame_Update(arg)
          refresh_craft()
        end
      end)
    end
  end

 

  do -- trade
    for i = 1, 7  do
      AddBorder(_G["TradeRecipientItem"..i.."ItemButton"], 3, color)
      AddBorder(_G["TradePlayerItem"..i.."ItemButton"], 3, color)
    end

    local refresh_trade_target = function()
      for i = 1, 7  do
        local button = _G["TradeRecipientItem"..i.."ItemButton"]
        if button then
          if not defcolor["trade"] then
            defcolor["trade"] = { button.ShaguTweaks_border:GetBackdropBorderColor() }
          end

          button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["trade"][1], defcolor["trade"][2], defcolor["trade"][3], 0)

          local n, _, _, q = GetTradeTargetItemInfo(i)
          if n and q then
            SetGlowForQuality(button, q, defcolor["trade"])
          end
        end
      end
    end

    local refresh_trade_player = function()
      for i = 1, 7  do
        local button = _G["TradePlayerItem"..i.."ItemButton"]
        if button then

          button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["trade"][1], defcolor["trade"][2], defcolor["trade"][3], 0)

          local link = GetTradePlayerItemLink(i)
          if link then
            local _, _, istring  = string.find(link, "|H(.+)|h")
            local _, _, q = GetItemInfo(istring)
            if q then
              SetGlowForQuality(button, q, defcolor["trade"])
            end
          end
        end
      end
    end

    local trade = CreateFrame("Frame", nil, TradeFrame)
    trade:RegisterEvent("TRADE_SHOW")
    trade:RegisterEvent("TRADE_PLAYER_ITEM_CHANGED")
    trade:RegisterEvent("TRADE_TARGET_ITEM_CHANGED")
    trade:SetScript("OnEvent", function()
      if event == "TRADE_SHOW" then
        refresh_trade_target()
        refresh_trade_player()
      elseif event == "TRADE_TARGET_ITEM_CHANGED" then
        refresh_trade_target()
      elseif event == "TRADE_PLAYER_ITEM_CHANGED" then
        refresh_trade_player()
      end
    end)
  end
end