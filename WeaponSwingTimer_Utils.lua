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
