local addon_name = "WeaponSwingTimer"
local addon_data = _G.WeaponSwingTimer_AddonData
if not addon_data then
    addon_data = {}
    _G.WeaponSwingTimer_AddonData = addon_data
end


addon_data.utils = {}

-- Sends the given message to the chat frame with the addon name in front.
addon_data.utils.PrintMsg = function(msg)
	chat_msg = "|cFF00FFB0" .. addon_name .. ": |r" .. msg
	DEFAULT_CHAT_FRAME:AddMessage(chat_msg)
end

-- Rounds the given number to the given step.
-- If num was 1.17 and step was 0.1 then this would return 1.1
addon_data.utils.SimpleRound = function(num, step)
    return floor(num / step) * step
end

addon_data.utils.GetInventoryItemIDCompat = function(unit, slot_id)
    if GetInventoryItemID then
        return GetInventoryItemID(unit, slot_id)
    end

    local item_link = GetInventoryItemLink(unit, slot_id)
    if not item_link then
        return nil
    end

    local item_id = string.match(item_link, "item:(%d+):")
    if item_id then
        return tonumber(item_id)
    end

    return nil
end

addon_data.utils.GetClassToken = function(unit)
    local _, class_token = UnitClass(unit)
    return class_token
end

addon_data.utils.SetTextureColor = function(texture_obj, r, g, b, a)
    if texture_obj.SetColorTexture then
        texture_obj:SetColorTexture(r, g, b, a)
    else
        texture_obj:SetTexture(r, g, b, a)
    end
end

addon_data.utils.NormalizeTexturePath = function(path)
    if type(path) ~= "string" then
        return path
    end

    return string.gsub(path, "/", "\\")
end

addon_data.utils.SetTextureFile = function(texture_obj, path)
    if not texture_obj then
        return
    end

    texture_obj:SetTexture(path)
    if texture_obj:GetTexture() then
        return
    end

    local normalized_path = addon_data.utils.NormalizeTexturePath(path)
    texture_obj:SetTexture(normalized_path)
    if texture_obj:GetTexture() then
        return
    end

    texture_obj:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
end

addon_data.utils.SetBackdropCompat = function(frame, bg_file, edge_file, tile_size, edge_size, insets)
    if not frame or not frame.SetBackdrop then
        return
    end

    frame:SetBackdrop({
        bgFile = addon_data.utils.NormalizeTexturePath(bg_file),
        edgeFile = addon_data.utils.NormalizeTexturePath(edge_file),
        tile = true,
        tileSize = tile_size,
        edgeSize = edge_size,
        insets = insets,
    })
end

addon_data.utils.IsValidHostileTarget = function()
    if not UnitExists("target") then
        return false
    end

    if UnitIsDead("target") then
        return false
    end

    if not UnitCanAttack("player", "target") then
        return false
    end

    return true
end

addon_data.utils.IsTargetInMeleeRange = function()
    if not addon_data.utils.IsValidHostileTarget() then
        return nil
    end

    if CheckInteractDistance then
        local in_range_duel = CheckInteractDistance("target", 3)
        if (in_range_duel == 1) or (in_range_duel == true) then
            return true
        end

        if (in_range_duel == 0) or (in_range_duel == false) then
            return false
        end

        local in_range_trade = CheckInteractDistance("target", 2)
        if (in_range_trade == 1) or (in_range_trade == true) then
            return true
        end

        if (in_range_trade == 0) or (in_range_trade == false) then
            return false
        end
    end

    if IsSpellInRange and ATTACK then
        local attack_range = IsSpellInRange(ATTACK, "target")
        if attack_range == 1 then
            return true
        end

        if attack_range == 0 then
            return false
        end
    end

    return nil
end

addon_data.utils.NormalizeDisplayCondition = function(display_condition)
    if display_condition == "always" or display_condition == 1 then
        return "always"
    end

    if display_condition == "in_melee" or display_condition == 2 then
        return "in_melee"
    end

    if display_condition == "out_of_melee" or display_condition == 3 then
        return "out_of_melee"
    end

    return "always"
end

addon_data.utils.ShouldShowByDistanceCondition = function(display_condition, attack_mode, show_when_unknown)
    local normalized_condition = addon_data.utils.NormalizeDisplayCondition(display_condition)

    if normalized_condition == "always" then
        return true
    end

    local in_melee_range = addon_data.utils.IsTargetInMeleeRange()
    if in_melee_range == nil then
        if attack_mode == "melee" then
            in_melee_range = true
        elseif attack_mode == "ranged" then
            in_melee_range = false
        else
            if show_when_unknown == nil then
                show_when_unknown = false
            end
            return show_when_unknown
        end
    end

    if normalized_condition == "in_melee" then
        return in_melee_range
    end

    if normalized_condition == "out_of_melee" then
        return not in_melee_range
    end

    return true
end
