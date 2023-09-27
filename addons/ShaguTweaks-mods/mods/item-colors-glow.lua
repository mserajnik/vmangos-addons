
local _G = ShaguTweaks.GetGlobalEnv()
local L, T = ShaguTweaks.L, ShaguTweaks.T
local AddBorder = ShaguTweaks.AddBorder
local HookAddonOrVariable = ShaguTweaks.HookAddonOrVariable

local module = ShaguTweaks:register({
  title = T["Item Rarity Border Glow"],
  description = T["Show item rarity as the border color with a glow on bags, bank, character, inspect, merchant, craft, tradeskill, mail, trade and loot frames."],
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  category = T["Tooltip & Items"],
  enabled = false,
})

local defcolor = {}

local paperdoll_slots = {
  [0] = "AmmoSlot", "HeadSlot",
  "NeckSlot", "ShoulderSlot",
  "ShirtSlot", "ChestSlot",
  "WaistSlot", "LegsSlot",
  "FeetSlot", "WristSlot",
  "HandsSlot", "Finger0Slot",
  "Finger1Slot", "Trinket0Slot",
  "Trinket1Slot", "BackSlot",
  "MainHandSlot", "SecondaryHandSlot",
  "RangedSlot", "TabardSlot",
}

local inspect_slots = {
  "HeadSlot", "NeckSlot",
  "ShoulderSlot", "ShirtSlot",
  "ChestSlot", "WaistSlot",
  "LegsSlot", "FeetSlot",
  "WristSlot", "HandsSlot",
  "Finger0Slot", "Finger1Slot",
  "Trinket0Slot", "Trinket1Slot",
  "BackSlot", "MainHandSlot",
  "SecondaryHandSlot", "RangedSlot",
  "TabardSlot"
}

local function AddTexture(frame, inset, color)
  if not frame then return end
  if frame.ShaguTweaks_texture then return frame.ShaguTweaks_texture end

  local top, right, bottom, left
  if type(inset) == "table" then
    top, right, bottom, left = unpack((inset))
    left, bottom = -left, -bottom
  end

  if not frame.ShaguTweaks_texture then
    frame.ShaguTweaks_texture = frame:CreateTexture(nil, "OVERLAY")
    frame.ShaguTweaks_texture:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    frame.ShaguTweaks_texture:SetBlendMode("ADD")
    frame.ShaguTweaks_texture:SetPoint("TOPLEFT", frame, "TOPLEFT", (left or -inset), (top or inset))
    frame.ShaguTweaks_texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", (right or inset), (bottom or -inset))
    if color then
      frame.ShaguTweaks_texture:SetVertexColor(color.r, color.g, color.b, 0.7) -- Changed from 1 to 0.7
    end
  end
  return frame.ShaguTweaks_texture
end

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

local function IsQuestItem(link)
  if not link then return false end
  local _, _, itemString = string.find(link, "|H(.+)|h")
  if itemString then
    local _, _, _, _, itemType = GetItemInfo(itemString)
    return itemType == "Quest"
  end
  return false
end

local function SetGlowForQuality(button, quality, defaultColor)
  if quality and quality > 1 then
    local r, g, b = GetItemQualityColor(quality)
    button.ShaguTweaks_border:SetBackdropBorderColor(r, g, b, 1)
    button.ShaguTweaks_texture:SetVertexColor(r, g, b, 0.7)
  else
    button.ShaguTweaks_border:SetBackdropBorderColor(defaultColor[1], defaultColor[2], defaultColor[3], 0)
    button.ShaguTweaks_texture:SetVertexColor(defaultColor[1], defaultColor[2], defaultColor[3], 0)
  end
end

module.enable = function(self)
  local dis
  if IsAddOnLoaded("lilsparkysworkshop") then
    dis = true
  end

  do -- paperdoll
    local refresh_paperdoll = function()
      for i, slot in pairs(paperdoll_slots) do
        local button = _G["Character"..slot]
        if button then
          local border = button.ShaguTweaks_border
          if not border then
            border = AddBorder(button, 3, { r = .5, g = .5, b = .5 })
          end
          local texture = button.ShaguTweaks_texture
          if not texture then
            texture = AddTexture(button, 14, { r = .5, g = .5, b = .5 })
          end
          if not defcolor["paperdoll"] then
            defcolor["paperdoll"] = { border:GetBackdropBorderColor() }
          end
          local quality = GetInventoryItemQuality("player", i)
          if quality then
            SetGlowForQuality(button, quality, defcolor["paperdoll"])
          else
            border:SetBackdropBorderColor(defcolor["paperdoll"][1], defcolor["paperdoll"][2], defcolor["paperdoll"][3], 1)
            texture:SetVertexColor(defcolor["paperdoll"][1], defcolor["paperdoll"][2], defcolor["paperdoll"][3], 0)
          end
        end
      end
    end
    local paperdoll = CreateFrame("Frame", nil, CharacterFrame)
    paperdoll:RegisterEvent("UNIT_INVENTORY_CHANGED")
    paperdoll:SetScript("OnEvent", refresh_paperdoll)
    paperdoll:SetScript("OnShow", refresh_paperdoll)
  end

  do -- inspect
    local refresh_inspect = function()
      for i, v in pairs(inspect_slots) do
        local button = _G["Inspect"..v]
        local link = GetInventoryItemLink("target", i)
        local border = button.ShaguTweaks_border
        if not border then
          border = AddBorder(button, 3, { r = .5, g = .5, b = .5 })
        end
        local texture = button.ShaguTweaks_texture
        if not texture then
          texture = AddTexture(button, 14, { r = .5, g = .5, b = .5 })
        end
        if not defcolor["inspect"] then
          defcolor["inspect"] = { border:GetBackdropBorderColor() }
        end
        border:SetBackdropBorderColor(defcolor["inspect"][1], defcolor["inspect"][2], defcolor["inspect"][3], 1)
        texture:SetVertexColor(defcolor["inspect"][1], defcolor["inspect"][2], defcolor["inspect"][3], 0)
        if link then
          local _, _, istring = string.find(link, "|H(.+)|h")
          local _, _, quality = GetItemInfo(istring)
          if quality then
            SetGlowForQuality(button, quality, defcolor["inspect"])
          end
        end
      end
    end
    HookAddonOrVariable("Blizzard_InspectUI", function()
      local HookInspectPaperDollItemSlotButton_Update = InspectPaperDollItemSlotButton_Update
      InspectPaperDollItemSlotButton_Update = function(arg)
        HookInspectPaperDollItemSlotButton_Update(arg)
        refresh_inspect()
      end
    end)
  end

  do -- bags
    local color = { r = .5, g = .5, b = .46 }
    for i = 0, 3 do
      AddBorder(_G["CharacterBag"..i.."Slot"], 3, color)
      AddTexture(_G["CharacterBag"..i.."Slot"], 14, color)
    end
    for i = 1, 12 do
      for k = 1, MAX_CONTAINER_ITEMS do
        AddBorder(_G["ContainerFrame"..i.."Item"..k], 3, color)
        AddTexture(_G["ContainerFrame"..i.."Item"..k], 14, color)
      end
    end
    local refresh_bags = function()
      for i = 1, 12 do
        local frame = _G["ContainerFrame"..i]
        if frame then
          local name = frame:GetName()
          local id = frame:GetID()
          for i = 1, MAX_CONTAINER_ITEMS do
            local button = _G[name.."Item"..i]
            if button and button.ShaguTweaks_border and button.ShaguTweaks_texture then
              if not defcolor["bag"] then
                defcolor["bag"] = { button.ShaguTweaks_border:GetBackdropBorderColor() }
              end
              button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["bag"][1], defcolor["bag"][2], defcolor["bag"][3], 1)
              button.ShaguTweaks_texture:SetVertexColor(defcolor["bag"][1], defcolor["bag"][2], defcolor["bag"][3], 0)
              local link = GetContainerItemLink(id, button:GetID())
              if button:IsShown() and link then
                local _, _, istring = string.find(link, "|H(.+)|h")
                local _, _, quality, _, _, itype = GetItemInfo(istring)
                if itype == "Quest" then
                  button.ShaguTweaks_border:SetBackdropBorderColor(1, 1, 0, 1)
                  button.ShaguTweaks_texture:SetVertexColor(1, 1, 0, 0.7)
                elseif quality then
                  SetGlowForQuality(button, quality, defcolor["bag"])
                end
              end
            end
          end
        end
      end
    end
    local bags = CreateFrame("Frame", nil, ContainerFrame1)
    bags:RegisterEvent("BAG_UPDATE")
    bags:SetScript("OnEvent", refresh_bags)
    local HookContainerFrame_OnShow = ContainerFrame_OnShow
    function ContainerFrame_OnShow() refresh_bags() HookContainerFrame_OnShow() end
    local HookContainerFrame_OnHide = ContainerFrame_OnHide
    function ContainerFrame_OnHide() refresh_bags() HookContainerFrame_OnHide() end
  end

  do -- bank
    local color = { r = .5, g = .5, b = .46 }
    for i = 1, 28 do
      AddBorder(_G["BankFrameItem"..i], 3, color)
      AddTexture(_G["BankFrameItem"..i], 14, color)
    end
    local refresh_bank = function()
      for i = 1, 28 do
        local button = _G["BankFrameItem"..i]
        local link = GetContainerItemLink(-1, i)
        if button then
          if not defcolor["bank"] then
            defcolor["bank"] = { button.ShaguTweaks_border:GetBackdropBorderColor() }
          end
          button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["bank"][1], defcolor["bank"][2], defcolor["bank"][3], 1)
          button.ShaguTweaks_texture:SetVertexColor(defcolor["bank"][1], defcolor["bank"][2], defcolor["bank"][3], 0)
          if link then
            local _, _, istring = string.find(link, "|H(.+)|h")
            local _, _, quality = GetItemInfo(istring)
            if IsQuestItem(link) then
              button.ShaguTweaks_border:SetBackdropBorderColor(1, 1, 0, 1)
              button.ShaguTweaks_texture:SetVertexColor(1, 1, 0, 0.7)
            elseif quality and quality > 1 then
              SetGlowForQuality(button, quality, defcolor["bank"])
            end
          end
        end
      end
    end
    local bank = CreateFrame("Frame", nil, BankFrame)
    bank:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    bank:SetScript("OnEvent", refresh_bank)
    bank:SetScript("OnShow", refresh_bank)
  end

  do -- weapon buff
    AddBorder(TempEnchant1, 3, {.2,.2,.2})
    AddBorder(TempEnchant2, 3, {.2,.2,.2})
    local hookBuffFrame_Enchant_OnUpdate = BuffFrame_Enchant_OnUpdate
    function BuffFrame_Enchant_OnUpdate(elapsed)
      hookBuffFrame_Enchant_OnUpdate(elapsed)
      local mh, _, _, oh = GetWeaponEnchantInfo()
      if not mh and not oh then return end
      local r, g, b = GetItemQualityColor(GetInventoryItemQuality("player", TempEnchant1:GetID()) or 1)
      TempEnchant1.ShaguTweaks_border:SetBackdropBorderColor(r,g,b,1)
      TempEnchant1Border:SetAlpha(0)
      r, g, b = GetItemQualityColor(GetInventoryItemQuality("player", TempEnchant2:GetID()) or 1)
      TempEnchant2.ShaguTweaks_border:SetBackdropBorderColor(r,g,b,1)
      TempEnchant2Border:SetAlpha(0)
    end
  end

do -- merchant
    local color = { r = .5, g = .5, b = .46 } -- Define color here
    AddBorder(_G["MerchantBuyBackItemItemButton"], 3, color)
    AddTexture(_G["MerchantBuyBackItemItemButton"], 14, color)

    for i = 1, 10 do -- Vanilla WoW uses 10 items per page
      AddBorder(_G["MerchantItem"..i.."ItemButton"], 3, color)
      AddTexture(_G["MerchantItem"..i.."ItemButton"], 14, color)
    end

    local refresh_merchant = function()
      if MerchantFrame.selectedTab == 1 then
        -- merchant tab
        local page = MerchantFrame.page or 1 -- Current page, defaults to 1
        local startIndex = (page - 1) * MERCHANT_ITEMS_PER_PAGE + 1
        local endIndex = startIndex + MERCHANT_ITEMS_PER_PAGE - 1

        for i = 1, MERCHANT_ITEMS_PER_PAGE do -- 10 items per page in Vanilla
          local button = _G["MerchantItem"..i.."ItemButton"]
          if button then
            if not defcolor["merchant"] then
              defcolor["merchant"] = { button.ShaguTweaks_border:GetBackdropBorderColor() }
            end

            -- Reset to default color
            button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["merchant"][1], defcolor["merchant"][2], defcolor["merchant"][3], 0)
            button.ShaguTweaks_texture:SetVertexColor(defcolor["merchant"][1], defcolor["merchant"][2], defcolor["merchant"][3], 0)

            -- Calculate the actual merchant item index based on page
            local merchantIndex = startIndex + (i - 1)
            if merchantIndex <= GetMerchantNumItems() then
              local link = GetMerchantItemLink(merchantIndex)
              if link then
                local _, _, istring = string.find(link, "|H(.+)|h")
                local _, _, q = GetItemInfo(istring)
                if q then
                  SetGlowForQuality(button, q, defcolor["merchant"])
                end
              end
            end
          end
        end

        local button = _G["MerchantBuyBackItemItemButton"]
        if button then
          button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["merchant"][1], defcolor["merchant"][2], defcolor["merchant"][3], 0)
          button.ShaguTweaks_texture:SetVertexColor(defcolor["merchant"][1], defcolor["merchant"][2], defcolor["merchant"][3], 0)

          local buyback = GetNumBuybackItems()
          if buyback > 0 then
            local iname = GetBuybackItemInfo(buyback)
            local link = GetItemLinkByName(iname)
            if link then
              local _, _, istring = string.find(link, "|H(.+)|h")
              local _, _, q = GetItemInfo(istring)
              if q then
                SetGlowForQuality(button, q, defcolor["merchant"])
              end
            end
          end
        end
      else
        -- buyback tab
        for i = 1, MERCHANT_ITEMS_PER_PAGE do -- 10 items per page
          local button = _G["MerchantItem"..i.."ItemButton"]
          if button then
            if not defcolor["merchant"] then
              defcolor["merchant"] = { button.ShaguTweaks_border:GetBackdropBorderColor() }
            end

            button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["merchant"][1], defcolor["merchant"][2], defcolor["merchant"][3], 0)
            button.ShaguTweaks_texture:SetVertexColor(defcolor["merchant"][1], defcolor["merchant"][2], defcolor["merchant"][3], 0)

            local iname = GetBuybackItemInfo(i)
            local link = GetItemLinkByName(iname)
            if link then
              local _, _, istring = string.find(link, "|H(.+)|h")
              local _, _, q = GetItemInfo(istring)
              if q then
                SetGlowForQuality(button, q, defcolor["merchant"])
              end
            end
          end
        end
      end
    end

    -- Hook the original MerchantFrame_Update
    local HookMerchantFrame_Update = MerchantFrame_Update
    MerchantFrame_Update = function()
      HookMerchantFrame_Update()
      refresh_merchant()
    end

    -- Hook Next Page Button (1.12 compatible)
    local origNextPageOnClick = MerchantNextPageButton:GetScript("OnClick")
    MerchantNextPageButton:SetScript("OnClick", function()
      if origNextPageOnClick then
        origNextPageOnClick()
      end
      refresh_merchant()
    end)

    -- Hook Previous Page Button (1.12 compatible)
    local origPrevPageOnClick = MerchantPrevPageButton:GetScript("OnClick")
    MerchantPrevPageButton:SetScript("OnClick", function()
      if origPrevPageOnClick then
        origPrevPageOnClick()
      end
      refresh_merchant()
    end)
end

do -- quest
    local color = { r = .5, g = .5, b = .46 }

    local function SetupQuestButtons()
        for i = 1, 4 do
            local button = _G["QuestDetailItem" .. i]
            if button and button:IsVisible() then
                local icon = _G["QuestDetailItem" .. i .. "IconTexture"]
                if icon and icon:IsVisible() then
                    if not button.ShaguTweaks_border then
                        button.ShaguTweaks_border = AddBorder(button, 3, color)
                        button.ShaguTweaks_border:ClearAllPoints()
                        button.ShaguTweaks_border:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
                        button.ShaguTweaks_border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
                    end
                    if not button.ShaguTweaks_texture then
                        button.ShaguTweaks_texture = AddTexture(button, 14, color)
                        button.ShaguTweaks_texture:ClearAllPoints()
                        button.ShaguTweaks_texture:SetPoint("TOPLEFT", icon, "TOPLEFT", -14, 14)
                        button.ShaguTweaks_texture:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 14, -14)
                    end
                end
            end
        end
    end

    local function refresh_quest_items()
        local numChoices = GetNumQuestChoices()
        local numRewards = GetNumQuestRewards()
        for i = 1, 4 do
            local button = _G["QuestDetailItem" .. i]
            if button and button.ShaguTweaks_border and button.ShaguTweaks_texture then
                if not defcolor["quest"] then
                    defcolor["quest"] = { button.ShaguTweaks_border:GetBackdropBorderColor() }
                end
                button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["quest"][1], defcolor["quest"][2], defcolor["quest"][3], 0)
                button.ShaguTweaks_texture:SetVertexColor(defcolor["quest"][1], defcolor["quest"][2], defcolor["quest"][3], 0)
                
                local link
                if i <= numChoices then
                    link = GetQuestItemLink("choice", i)
                elseif i <= numChoices + numRewards then
                    link = GetQuestItemLink("reward", i - numChoices)
                end
                if link then
                    local _, _, istring = string.find(link, "|H(.+)|h")
                    local _, _, quality = GetItemInfo(istring)
                    if quality and quality > 1 then
                        local r, g, b = GetItemQualityColor(quality)
                        button.ShaguTweaks_border:SetBackdropBorderColor(r, g, b, 1)
                        button.ShaguTweaks_texture:SetVertexColor(r, g, b, 0.7)
                    end
                end
            end
        end
    end

    local questUpdater = CreateFrame("Frame", "MyQuestUpdater", QuestFrame)
    questUpdater:RegisterEvent("QUEST_DETAIL")
    questUpdater:RegisterEvent("QUEST_PROGRESS")
    questUpdater:RegisterEvent("QUEST_COMPLETE")
    
    local delay = 0.1
    local elapsed = 0
    questUpdater:SetScript("OnUpdate", function()
        elapsed = elapsed + arg1
        if elapsed >= delay then
            SetupQuestButtons()
            refresh_quest_items()
            elapsed = 0
            this:Hide()
        end
    end)
    
    questUpdater:SetScript("OnEvent", function()
        elapsed = 0
        this:Show()
    end)
    
    questUpdater:SetScript("OnShow", function()
        elapsed = 0
        this:Show()
    end)
    questUpdater:Hide()
end 

do -- reward
    local color = { r = .5, g = .5, b = .46 }

    local function SetupRewardButtons()
        for i = 1, 4 do
            local button = _G["QuestRewardItem" .. i]
            if button and button:IsVisible() then
                local icon = _G["QuestRewardItem" .. i .. "IconTexture"]
                if icon and icon:IsVisible() then
                    if not button.ShaguTweaks_border then
                        button.ShaguTweaks_border = AddBorder(button, 3, color)
                        button.ShaguTweaks_border:ClearAllPoints()
                        button.ShaguTweaks_border:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
                        button.ShaguTweaks_border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
                    end
                    if not button.ShaguTweaks_texture then
                        button.ShaguTweaks_texture = AddTexture(button, 14, color)
                        button.ShaguTweaks_texture:ClearAllPoints()
                        button.ShaguTweaks_texture:SetPoint("TOPLEFT", icon, "TOPLEFT", -14, 14)
                        button.ShaguTweaks_texture:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 14, -14)
                    end
                end
            end
        end
    end

    local function refresh_reward_items()
        local numChoices = GetNumQuestChoices()
        local numRewards = GetNumQuestRewards()
        for i = 1, 4 do
            local button = _G["QuestRewardItem" .. i]
            if button and button.ShaguTweaks_border and button.ShaguTweaks_texture then
                if not defcolor["reward"] then
                    defcolor["reward"] = { button.ShaguTweaks_border:GetBackdropBorderColor() }
                end
                button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["reward"][1], defcolor["reward"][2], defcolor["reward"][3], 0)
                button.ShaguTweaks_texture:SetVertexColor(defcolor["reward"][1], defcolor["reward"][2], defcolor["reward"][3], 0)
                
                local link
                if i <= numChoices then
                    link = GetQuestItemLink("choice", i)
                elseif i <= numChoices + numRewards then
                    link = GetQuestItemLink("reward", i - numChoices)
                end
                if link then
                    local _, _, istring = string.find(link, "|H(.+)|h")
                    local _, _, quality = GetItemInfo(istring)
                    if quality and quality > 1 then
                        local r, g, b = GetItemQualityColor(quality)
                        button.ShaguTweaks_border:SetBackdropBorderColor(r, g, b, 1)
                        button.ShaguTweaks_texture:SetVertexColor(r, g, b, 0.7)
                    end
                end
            end
        end
    end

    local rewardUpdater = CreateFrame("Frame", "MyRewardUpdater", QuestFrame)
    rewardUpdater:RegisterEvent("QUEST_COMPLETE")
    rewardUpdater:SetScript("OnUpdate", function()
        local elapsed = this.elapsed or 0
        elapsed = elapsed + arg1
        if elapsed >= 0.1 then
            SetupRewardButtons()
            refresh_reward_items()
            elapsed = 0
            this:Hide()
        end
        this.elapsed = elapsed
    end)
    
    rewardUpdater:SetScript("OnEvent", function()
        this.elapsed = 0
        this:Show()
    end)
    
    rewardUpdater:SetScript("OnShow", function()
        this.elapsed = 0
        this:Show()
    end)
    rewardUpdater:Hide()
end

do -- log
    local color = { r = .5, g = .5, b = .46 } -- Default border color

    -- Add borders and textures to quest log reward items
    local function SetupQuestLogButtons()
        for i = 1, 4 do
            local button = _G["QuestLogItem" .. i]
            if button then
                local icon = _G["QuestLogItem" .. i .. "IconTexture"]
                if icon then
                    if not button.ShaguTweaks_border then
                        button.ShaguTweaks_border = AddBorder(button, 3, color)
                        button.ShaguTweaks_border:ClearAllPoints()
                        button.ShaguTweaks_border:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
                        button.ShaguTweaks_border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
                    end
                    if not button.ShaguTweaks_texture then
                        button.ShaguTweaks_texture = AddTexture(button, 14, color)
                        button.ShaguTweaks_texture:ClearAllPoints()
                        button.ShaguTweaks_texture:SetPoint("TOPLEFT", icon, "TOPLEFT", -14, 14)
                        button.ShaguTweaks_texture:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 14, -14)
                    end
                end
            end
        end
    end

    local refresh_quest_log_items = function()
        local questIndex = GetQuestLogSelection()
        if not questIndex or questIndex == 0 then return end
        
        for i = 1, 4 do
            local button = _G["QuestLogItem" .. i]
            if button then
                if button.ShaguTweaks_border and button.ShaguTweaks_texture then
                    if not defcolor["log"] then
                        defcolor["log"] = { button.ShaguTweaks_border:GetBackdropBorderColor() }
                    end
                    button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["log"][1], defcolor["log"][2], defcolor["log"][3], 0)
                    button.ShaguTweaks_texture:SetVertexColor(defcolor["log"][1], defcolor["log"][2], defcolor["log"][3], 0)
                    
                    local link = GetQuestLogItemLink("reward", i) or GetQuestLogItemLink("choice", i)
                    if link then
                        local _, _, istring = string.find(link, "|H(.+)|h")
                        local _, _, quality = GetItemInfo(istring)
                        if quality and quality > 1 then
                            local r, g, b = GetItemQualityColor(quality)
                            button.ShaguTweaks_border:SetBackdropBorderColor(r, g, b, 1)
                            button.ShaguTweaks_texture:SetVertexColor(r, g, b, 0.7)
                        end
                    end
                end
            end
        end
    end

    -- Hook quest log opening
    local logFrame = CreateFrame("Frame", nil, QuestLogFrame)
    logFrame:SetScript("OnShow", function(self)
        SetupQuestLogButtons()
        refresh_quest_log_items()
    end)

    -- Hook QuestLogTitleX OnClick for manual updates
    for i = 1, 20 do
        local titleButton = _G["QuestLogTitle" .. i]
        if titleButton then
            local origOnClick = titleButton:GetScript("OnClick")
            titleButton:SetScript("OnClick", function()
                if origOnClick then
                    origOnClick()
                end
                SetupQuestLogButtons()
                refresh_quest_log_items()
            end)
        end
    end
end

do -- mail
    local color = { r = .5, g = .5, b = .46 } -- Default color for borders

    -- Add border and texture to OpenMailPackageButton
    AddBorder(OpenMailPackageButton, 3, color)
    AddTexture(OpenMailPackageButton, 14, color)

    -- Function to map RGB to quality (from SimpleTest)
    local function GetQualityFromRGB(r, g, b)
        if math.abs(r - g) < 0.1 and math.abs(g - b) < 0.1 and r > 0.5 and r < 0.7 then return 0 end -- Poor
        if r > 0.9 and g > 0.9 and b > 0.9 then return 1 end -- Common
        if r < 0.2 and g > 0.9 and b < 0.2 then return 2 end -- Uncommon
        if r < 0.2 and g < 0.5 and b > 0.8 then return 3 end -- Rare
        if r > 0.5 and g < 0.3 and b > 0.9 then return 4 end -- Epic
        if r > 0.9 and g > 0.5 and b < 0.2 then return 5 end -- Legendary
        return 1 -- Default to Common
    end

    local refresh_mail_attachment = function(mailIndex)
        local button = OpenMailPackageButton
        if button then
            if not defcolor["mail"] then
                defcolor["mail"] = { button.ShaguTweaks_border:GetBackdropBorderColor() }
            end

            -- Reset to default color
            button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["mail"][1], defcolor["mail"][2], defcolor["mail"][3], 0)
            button.ShaguTweaks_texture:SetVertexColor(defcolor["mail"][1], defcolor["mail"][2], defcolor["mail"][3], 0)

            -- Check if the selected mail has an attachment and get its quality color
            if mailIndex and mailIndex > 0 then
                local icon = _G["MailItem" .. mailIndex .. "ButtonIcon"]
                if icon and icon:IsVisible() then
                    -- Get mail index based on page
                    local pageNum = InboxFrame.pageNum or 1
                    local absoluteMailIndex = (pageNum - 1) * 7 + mailIndex
                    local numItems = GetInboxNumItems()
                    
                    if absoluteMailIndex <= numItems then
                        local name = GetInboxItem(absoluteMailIndex)
                        if name then
                            -- Use tooltip to infer quality color
                            GameTooltip:ClearLines()
                            GameTooltip:SetInboxItem(absoluteMailIndex, 1)
                            local numRegions = GameTooltip:NumLines()
                            local r, g, b = 1, 1, 1 -- Default to white (Common)
                            if numRegions > 0 then
                                local regions = {GameTooltip:GetRegions()}
                                for i, region in ipairs(regions) do
                                    if region and region:IsObjectType("FontString") then
                                        local text = region:GetText()
                                        if text and text == name then
                                            r, g, b = region:GetTextColor()
                                            break
                                        end
                                    end
                                end
                            end
                            -- Only apply glow if quality is Uncommon (2) or higher
                            local quality = GetQualityFromRGB(r, g, b)
                            if quality >= 2 then
                                button.ShaguTweaks_border:SetBackdropBorderColor(r, g, b, 0.7)
                                button.ShaguTweaks_texture:SetVertexColor(r, g, b, 0.7)
                            end
                        end
                    end
                end
            end
        end
    end

    -- Individual handlers for each mail item button
    local mailButton1 = _G["MailItem1Button"]
    if mailButton1 then
        local origOnClick = mailButton1:GetScript("OnClick")
        mailButton1:SetScript("OnClick", function()
            if origOnClick then origOnClick() end
            refresh_mail_attachment(1)
        end)
    end

    local mailButton2 = _G["MailItem2Button"]
    if mailButton2 then
        local origOnClick = mailButton2:GetScript("OnClick")
        mailButton2:SetScript("OnClick", function()
            if origOnClick then origOnClick() end
            refresh_mail_attachment(2)
        end)
    end

    local mailButton3 = _G["MailItem3Button"]
    if mailButton3 then
        local origOnClick = mailButton3:GetScript("OnClick")
        mailButton3:SetScript("OnClick", function()
            if origOnClick then origOnClick() end
            refresh_mail_attachment(3)
        end)
    end

    local mailButton4 = _G["MailItem4Button"]
    if mailButton4 then
        local origOnClick = mailButton4:GetScript("OnClick")
        mailButton4:SetScript("OnClick", function()
            if origOnClick then origOnClick() end
            refresh_mail_attachment(4)
        end)
    end

    local mailButton5 = _G["MailItem5Button"]
    if mailButton5 then
        local origOnClick = mailButton5:GetScript("OnClick")
        mailButton5:SetScript("OnClick", function()
            if origOnClick then origOnClick() end
            refresh_mail_attachment(5)
        end)
    end

    local mailButton6 = _G["MailItem6Button"]
    if mailButton6 then
        local origOnClick = mailButton6:GetScript("OnClick")
        mailButton6:SetScript("OnClick", function()
            if origOnClick then origOnClick() end
            refresh_mail_attachment(6)
        end)
    end

    local mailButton7 = _G["MailItem7Button"]
    if mailButton7 then
        local origOnClick = mailButton7:GetScript("OnClick")
        mailButton7:SetScript("OnClick", function()
            if origOnClick then origOnClick() end
            refresh_mail_attachment(7)
        end)
    end

    -- Optional: Refresh when mail frame opens to handle initial state
    local HookMailFrame_OnShow = MailFrame_OnShow
    MailFrame_OnShow = function()
        HookMailFrame_OnShow()
        refresh_mail_attachment(0)
    end

    -- Hook page navigation buttons
    local nextButton = _G["InboxNextPageButton"]
    if nextButton then
        local origOnClickNext = nextButton:GetScript("OnClick")
        nextButton:SetScript("OnClick", function()
            if origOnClickNext then origOnClickNext() end
            refresh_mail_attachment(0) -- Reset glow on page change
        end)
    end

    local prevButton = _G["InboxPrevPageButton"]
    if prevButton then
        local origOnClickPrev = prevButton:GetScript("OnClick")
        prevButton:SetScript("OnClick", function()
            if origOnClickPrev then origOnClickPrev() end
            refresh_mail_attachment(0) -- Reset glow on page change
        end)
    end
end


  do -- tradeskill
    if not dis then
      local refresh_tradeskill = function()
        local id = TradeSkillFrame.selectedSkill
        do
          local button = _G["TradeSkillSkillIcon"]
          local border = button.ShaguTweaks_border
          if not border then
            border = AddBorder(button, 3, { r = .5, g = .5, b = .5 })
          end
          local texture = button.ShaguTweaks_texture
          if not texture then
            texture = AddTexture(button, 14, { r = .5, g = .5, b = .5 })
          end
          if not defcolor["tradeskill"] then
            defcolor["tradeskill"] = { border:GetBackdropBorderColor() }
          end
          button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["tradeskill"][1], defcolor["tradeskill"][2], defcolor["tradeskill"][3], 0)
          button.ShaguTweaks_texture:SetVertexColor(defcolor["tradeskill"][1], defcolor["tradeskill"][2], defcolor["tradeskill"][3], 0)
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
            local texture = button.ShaguTweaks_texture
            if not texture then
              texture = AddTexture(button, 14, { r = .5, g = .5, b = .5 })
              texture:ClearAllPoints()
              texture:SetPoint("TOPLEFT", border, "TOPLEFT", -12, 12)
              texture:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", 12, -12)
            end
            if not defcolor["tradeskill"] then
              defcolor["tradeskill"] = { border:GetBackdropBorderColor() }
            end
            button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["tradeskill"][1], defcolor["tradeskill"][2], defcolor["tradeskill"][3], 0)
            button.ShaguTweaks_texture:SetVertexColor(defcolor["tradeskill"][1], defcolor["tradeskill"][2], defcolor["tradeskill"][3], 0)
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
          local button = _G["CraftIcon"]
          local border = button.ShaguTweaks_border
          if not border then
            border = AddBorder(button, 3, { r = .5, g = .5, b = .5 })
          end
          local texture = button.ShaguTweaks_texture
          if not texture then
            texture = AddTexture(button, 14, { r = .5, g = .5, b = .5 })
          end
          if not defcolor["craft"] then
            defcolor["craft"] = { border:GetBackdropBorderColor() }
          end
          button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["craft"][1], defcolor["craft"][2], defcolor["craft"][3], 0)
          button.ShaguTweaks_texture:SetVertexColor(defcolor["craft"][1], defcolor["craft"][2], defcolor["craft"][3], 0)
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
            local texture = button.ShaguTweaks_texture
            if not texture then
              texture = AddTexture(button, 14, { r = .5, g = .5, b = .5 })
              texture:ClearAllPoints()
              texture:SetPoint("TOPLEFT", border, "TOPLEFT", -12, 12)
              texture:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", 12, -12)
            end
            if not defcolor["craft"] then
              defcolor["craft"] = { border:GetBackdropBorderColor() }
            end
            button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["craft"][1], defcolor["craft"][2], defcolor["craft"][3], 0)
            button.ShaguTweaks_texture:SetVertexColor(defcolor["craft"][1], defcolor["craft"][2], defcolor["craft"][3], 0)
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
    local color = { r = .5, g = .5, b = .46 }
    for i = 1, 7 do
      AddBorder(_G["TradeRecipientItem"..i.."ItemButton"], 3, color)
      AddTexture(_G["TradeRecipientItem"..i.."ItemButton"], 14, color)
      AddBorder(_G["TradePlayerItem"..i.."ItemButton"], 3, color)
      AddTexture(_G["TradePlayerItem"..i.."ItemButton"], 14, color)
    end
    local refresh_trade_target = function()
      for i = 1, 7 do
        local button = _G["TradeRecipientItem"..i.."ItemButton"]
        if button then
          if not defcolor["trade"] then
            defcolor["trade"] = { button.ShaguTweaks_border:GetBackdropBorderColor() }
          end
          button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["trade"][1], defcolor["trade"][2], defcolor["trade"][3], 0)
          button.ShaguTweaks_texture:SetVertexColor(defcolor["trade"][1], defcolor["trade"][2], defcolor["trade"][3], 0)
          local n, _, _, q = GetTradeTargetItemInfo(i)
          if n and q then
            SetGlowForQuality(button, q, defcolor["trade"])
          end
        end
      end
    end
    local refresh_trade_player = function()
      for i = 1, 7 do
        local button = _G["TradePlayerItem"..i.."ItemButton"]
        if button then
          button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["trade"][1], defcolor["trade"][2], defcolor["trade"][3], 0)
          button.ShaguTweaks_texture:SetVertexColor(defcolor["trade"][1], defcolor["trade"][2], defcolor["trade"][3], 0)
          local link = GetTradePlayerItemLink(i)
          if link then
            local _, _, istring = string.find(link, "|H(.+)|h")
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

-- ... all previous code (paperdoll, inspect, bags, etc.) ...

do -- loot
  local color = { r = .5, g = .5, b = .46 }
  for i = 1, 4 do
    local button = _G["LootButton"..i]
    if button then
      AddBorder(button, 3, color)
      AddTexture(button, 14, color)
    end
  end

  local refresh_loot = function()
    local numLootItems = GetNumLootItems()
    if numLootItems == 0 then return end
    local page = LootFrame.page or 1
    local itemsPerPage = (numLootItems <= 4) and 4 or 3 -- 4 for 1-4, 3 for 5+
    local startSlot = (page - 1) * itemsPerPage + 1
    local endSlot = math.min(startSlot + itemsPerPage - 1, numLootItems)

    -- Reset all 4 buttons
    for i = 1, 4 do
      local button = _G["LootButton"..i]
      if button and button.ShaguTweaks_border and button.ShaguTweaks_texture then
        if not defcolor["loot"] then
          defcolor["loot"] = { button.ShaguTweaks_border:GetBackdropBorderColor() }
        end
        button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["loot"][1], defcolor["loot"][2], defcolor["loot"][3], 0)
        button.ShaguTweaks_texture:SetVertexColor(defcolor["loot"][1], defcolor["loot"][2], defcolor["loot"][3], 0)
      end
    end

    -- Apply glows to visible slots
    for slot = startSlot, endSlot do
      local buttonIndex = slot - startSlot + 1
      local button = _G["LootButton"..buttonIndex] -- Fixed typo
      if button then
        if not button.ShaguTweaks_border then AddBorder(button, 3, color) end
        if not button.ShaguTweaks_texture then AddTexture(button, 14, color) end
        local link = GetLootSlotLink(slot)
        local _, itemName, _, quality = GetLootSlotInfo(slot)
        if link and IsQuestItem(link) then
          button.ShaguTweaks_border:SetBackdropBorderColor(1, 1, 0, 1)
          button.ShaguTweaks_texture:SetVertexColor(1, 1, 0, 0.7)
        elseif itemName and quality == 0 and string.find(itemName, "Quest Item") then
          button.ShaguTweaks_border:SetBackdropBorderColor(1, 1, 0, 1)
          button.ShaguTweaks_texture:SetVertexColor(1, 1, 0, 0.7)
        elseif quality and quality > 0 then
          SetGlowForQuality(button, quality, defcolor["loot"])
        end
      end
    end
  end

  -- 1.12 delay frame (cleaned up)
  local timerFrame = CreateFrame("Frame")
  local delayTime = 0.3
  local elapsed = 0
  timerFrame:Hide()
  timerFrame:SetScript("OnUpdate", function(self, elapsedTime)
    elapsed = elapsed + (elapsedTime or 0)
    if elapsed >= delayTime then
      self:Hide()
      elapsed = 0
      refresh_loot()
    end
  end)

  local loot = CreateFrame("Frame", nil, LootFrame)
  loot:RegisterEvent("LOOT_OPENED")
  loot:RegisterEvent("LOOT_SLOT_CLEARED")
  loot:RegisterEvent("LOOT_CLOSED")
  loot:SetScript("OnEvent", function(self, event)
    if event == "LOOT_CLOSED" then
      for i = 1, 4 do
        local button = _G["LootButton"..i]
        if button and button.ShaguTweaks_border and button.ShaguTweaks_texture then
          button.ShaguTweaks_border:SetBackdropBorderColor(defcolor["loot"][1], defcolor["loot"][2], defcolor["loot"][3], 0)
          button.ShaguTweaks_texture:SetVertexColor(defcolor["loot"][1], defcolor["loot"][2], defcolor["loot"][3], 0)
        end
      end
      timerFrame:Hide() -- Ensure timer stops when loot closes
    else
      refresh_loot()
    end
  end)

  local nextButton = _G["LootFrameDownButton"]
  if nextButton then
    local origNextOnClick = nextButton:GetScript("OnClick")
    nextButton:SetScript("OnClick", function()
      if origNextOnClick then
        origNextOnClick()
      end
      timerFrame:Show()
      refresh_loot() -- Ensures page 2 updates
    end)
  end

  local prevButton = _G["LootFrameUpButton"]
  if prevButton then
    local origPrevOnClick = prevButton:GetScript("OnClick")
    prevButton:SetScript("OnClick", function()
      if origPrevOnClick then
        origPrevOnClick()
      end
      timerFrame:Show()
      refresh_loot() -- Ensures page 1 updates if going back
    end)
  end
end

end -- This closes module.enable = function(self)
