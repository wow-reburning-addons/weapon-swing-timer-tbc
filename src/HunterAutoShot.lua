local addon_name = "WeaponSwingTimer"
local addon_data = _G.WeaponSwingTimer_AddonData
if not addon_data then
    addon_data = {}
    _G.WeaponSwingTimer_AddonData = addon_data
end

_G.WeaponSwingTimer_LocalizationTable = _G.WeaponSwingTimer_LocalizationTable or addon_data.localization_table or {}
addon_data.localization_table = _G.WeaponSwingTimer_LocalizationTable
if not getmetatable(addon_data.localization_table) then
    setmetatable(addon_data.localization_table, {
        __index = function(_, key)
            return key
        end,
    })
end
local L = addon_data.localization_table

local function GetPlayerMovementSpeed()
    if GetUnitSpeed then
        return GetUnitSpeed("player") or 0
    end

    if GetPlayerSpeed then
        return GetPlayerSpeed() or 0
    end

    return 0
end

--- define addon structure from the above local variable
addon_data.hunter_autoshot = {}
--- declare array for ranks of all abilities, cast times, cooldown, based on spell ID
addon_data.hunter_autoshot.shot_spell_ids = {
    [75] = {spell_name = L["spell.auto_shot"], rank = nil, cast_time = 0.5, cooldown = nil},
	[5384] = {spell_name = L["spell.feign_death"], rank = nil, cast_time = nil, cooldown = nil},
	[19506] = {spell_name = L["spell.trueshot_aura"], rank = 1, cast_time = nil, cooldown = nil},
	[20905] = {spell_name = L["spell.trueshot_aura"], rank = 2, cast_time = nil, cooldown = nil},
	[20906] = {spell_name = L["spell.trueshot_aura"], rank = 3, cast_time = nil, cooldown = nil},
    [2643] = {spell_name = L["spell.multi_shot"], rank = 1, cast_time = 0.45, cooldown = 10},
    [14288] = {spell_name = L["spell.multi_shot"], rank = 2, cast_time = 0.45, cooldown = 10},
    [14289] = {spell_name = L["spell.multi_shot"], rank = 3, cast_time = 0.45, cooldown = 10},
    [14290] = {spell_name = L["spell.multi_shot"], rank = 4, cast_time = 0.45, cooldown = 10},
    [25294] = {spell_name = L["spell.multi_shot"], rank = 5, cast_time = 0.45, cooldown = 10},
	[27021] = {spell_name = L["spell.multi_shot"], rank = 6, cast_time = 0.45, cooldown = 10},
    [19434] = {spell_name = L["spell.aimed_shot"], rank = 1, cast_time = 3, cooldown = 6},
    [20900] = {spell_name = L["spell.aimed_shot"], rank = 2, cast_time = 3, cooldown = 6},
    [20901] = {spell_name = L["spell.aimed_shot"], rank = 3, cast_time = 3, cooldown = 6},
    [20902] = {spell_name = L["spell.aimed_shot"], rank = 4, cast_time = 3, cooldown = 6},
    [20903] = {spell_name = L["spell.aimed_shot"], rank = 5, cast_time = 3, cooldown = 6},
    [20904] = {spell_name = L["spell.aimed_shot"], rank = 6, cast_time = 3, cooldown = 6},
	[27065] = {spell_name = L["spell.aimed_shot"], rank = 7, cast_time = 3, cooldown = 6},
    [5019] = {spell_name = L["spell.shoot"], rank = nil, cast_time = nil, cooldown = nil}
}
--- is spell multi-shot defined by spell_id
addon_data.hunter_autoshot.is_spell_multi_shot = function(spell_id)
    if type(spell_id) == "string" then
        return spell_id == L["spell.multi_shot"]
    end

    if (spell_id == 2643) or (spell_id == 14288) or (spell_id == 14289) or 
       (spell_id == 14290) or (spell_id == 25294) or (spell_id == 27021) then
             return true
    else
            return false
    end
end
--- is spell aimed shot defined by spell_id
addon_data.hunter_autoshot.is_spell_aimed_shot = function(spell_id)
    if type(spell_id) == "string" then
        return spell_id == L["spell.aimed_shot"]
    end

    if (spell_id == 19434) or (spell_id == 20900) or (spell_id == 20901) or 
       (spell_id == 20902) or (spell_id == 20903) or (spell_id == 20904) or (spell_id == 27065) then
             return true
    else
            return false
    end
end
--- is spell auto shot defined by spell_id
addon_data.hunter_autoshot.is_spell_auto_shot = function(spell_id)
    if type(spell_id) == "string" then
        return spell_id == L["spell.auto_shot"]
    end

    return (spell_id == 75)
end
--- is spell shoot defined by spell_id
addon_data.hunter_autoshot.is_spell_shoot = function(spell_id)
    if type(spell_id) == "string" then
        return spell_id == L["spell.shoot"]
    end

    return (spell_id == 5019)
end
--- default settings to be loaded on initial load and reset to default
addon_data.hunter_autoshot.default_settings = {
	enabled = true,
    display_condition = "out_of_melee",
    placement_mode = "independent",
	width = 300,
	height = 12,
	fontsize = 12,
    point = "CENTER",
	rel_point = "CENTER",
	x_offset = 0,
	y_offset = -260,
	in_combat_alpha = 1.0,
	ooc_alpha = 0.0,
	backplane_alpha = 0.5,
	is_locked = false,
    show_text = true,
    show_multishot_clip_bar = true,
	show_autoshot_delay_timer = true,
    show_border = false,
    classic_bars = true,
    one_bar = false,
    cooldown_r = 0.95, cooldown_g = 0.95, cooldown_b = 0.95, cooldown_a = 1.0,
    auto_cast_r = 0.8, auto_cast_g = 0.0, auto_cast_b = 0.0, auto_cast_a = 1.0,
    clip_r = 1.0, clip_g = 0.0, clip_b = 0.0, clip_a = 0.7
}
--- Initializing variables for calculations and function calls
addon_data.hunter_autoshot.shooting = false
-- added check below for range speed to default 3 on initialize 
addon_data.hunter_autoshot.range_speed = 3
addon_data.hunter_autoshot.auto_cast_time = 0.52
addon_data.hunter_autoshot.shot_timer = 0.52
addon_data.hunter_autoshot.last_shot_time = GetTime()
addon_data.hunter_autoshot.auto_shot_ready = true
addon_data.hunter_autoshot.FeignStatus = false
addon_data.hunter_autoshot.FeignFullReset = false
addon_data.hunter_autoshot.range_auto_speed_modified = 1
addon_data.hunter_autoshot.base_speed = 1
addon_data.hunter_autoshot.spell_GCD = 0
addon_data.hunter_autoshot.spell_GCD_Time = 0

addon_data.hunter_autoshot.casting = false
addon_data.hunter_autoshot.casting_auto = false
addon_data.hunter_autoshot.range_cast_speed_modifer = 1

addon_data.hunter_autoshot.range_weapon_id = 0
addon_data.hunter_autoshot.range_weapon_link = GetInventoryItemLink("player", 18)
addon_data.hunter_autoshot.has_moved = false

-- handling of stopping auto timer from starting
addon_data.hunter_autoshot.StartCastingSpell = function(spell_id)
    local settings = character_hunter_autoshot_settings

    if not addon_data.hunter_autoshot.casting and UnitCanAttack('player', 'target') then
        spell_name, _, _, cast_time, _, _, _ = GetSpellInfo(spell_id)
        if cast_time == nil then
			
            return 
        end
        if not addon_data.hunter_autoshot.is_spell_auto_shot(spell_id) and 
			not addon_data.hunter_autoshot.is_spell_shoot(spell_id) and cast_time > 0 then
               addon_data.hunter_autoshot.casting = true
        end
	end
end

addon_data.hunter_autoshot.LoadSettings = function()
    if not character_hunter_autoshot_settings and addon_data.core and addon_data.core.db then
        character_hunter_autoshot_settings = addon_data.core.db.profile.hunter_autoshot
    end

    if character_hunter_autoshot_settings then
        if character_hunter_autoshot_settings.display_condition == nil then
            character_hunter_autoshot_settings.display_condition = addon_data.hunter_autoshot.default_settings.display_condition
        end

        if character_hunter_autoshot_settings.placement_mode == nil then
            character_hunter_autoshot_settings.placement_mode = addon_data.hunter_autoshot.default_settings.placement_mode
        end
    end

    addon_data.hunter_autoshot.scan_tip = CreateFrame("GameTooltip", "WSTScanTip", nil, "GameTooltipTemplate")
    addon_data.hunter_autoshot.scan_tip:SetOwner(WorldFrame, "ANCHOR_NONE")
end

addon_data.hunter_autoshot.RestoreDefaults = function()
    for setting, value in pairs(addon_data.hunter_autoshot.default_settings) do
        character_hunter_autoshot_settings[setting] = value
    end
    _, class, _ = UnitClass("player")
    character_hunter_autoshot_settings.enabled = (class == "HUNTER" or class == "MAGE" or class == "PRIEST" or class == "WARLOCK")
    addon_data.hunter_autoshot.UpdateVisualsOnSettingsChange()
end

-- Replaced update info with this instead, checking weapon id every time inventory is changed for simplicity
addon_data.hunter_autoshot.OnInventoryChange = function(force_reset)
	local _, class, _ = UnitClass("player")
	if (class == "HUNTER" or class == "MAGE" or class == "PRIEST" or class == "WARLOCK") then
		local weapon_id = addon_data.utils.GetInventoryItemIDCompat("player", 18)
		local weapon_link = GetInventoryItemLink("player", 18)
		local weapon_changed = force_reset or (weapon_id ~= addon_data.hunter_autoshot.range_weapon_id) or (weapon_link ~= addon_data.hunter_autoshot.range_weapon_link)

		addon_data.hunter_autoshot.range_weapon_id = weapon_id
		addon_data.hunter_autoshot.range_weapon_link = weapon_link

		if weapon_id == nil then
			addon_data.hunter_autoshot.base_speed = 1
		elseif addon_data.ranged_DB.item_ids[weapon_id] and addon_data.ranged_DB.item_ids[weapon_id].base_speed then
			addon_data.hunter_autoshot.base_speed = addon_data.ranged_DB.item_ids[weapon_id].base_speed
		else
			addon_data.hunter_autoshot.base_speed = 1
		end

		if weapon_changed then
			addon_data.hunter_autoshot.FeignFullReset = false
			addon_data.hunter_autoshot.UpdateRangeCastSpeedModifier()
			addon_data.hunter_autoshot.ResetShotTimer()
		end
	end
end	

--- Reset Swing Timer unhasted separately due to feign and other spells
addon_data.hunter_autoshot.FeignDeath = function()
    addon_data.hunter_autoshot.last_shot_time = GetTime()
	if not addon_data.hunter_autoshot.FeignFullReset then
		local weapon_id = addon_data.utils.GetInventoryItemIDCompat("player", 18)
		if weapon_id and addon_data.ranged_DB.item_ids[weapon_id] and addon_data.ranged_DB.item_ids[weapon_id].base_speed then
			addon_data.hunter_autoshot.range_speed = addon_data.ranged_DB.item_ids[weapon_id].base_speed + 0.15
		else
			addon_data.hunter_autoshot.range_speed = 1.15
		end
		addon_data.hunter_autoshot.FeignFullReset = true
	end
    addon_data.hunter_autoshot.ResetShotTimer()
end

-- Modified to use base speed and current ranged speed, to get the haste modifiers. This is used in multi-shot cast bar to provide an accurate bar, as well as multi clip
addon_data.hunter_autoshot.UpdateRangeCastSpeedModifier = function()
	local _, class, _ = UnitClass("player")
	
	if addon_data.hunter_autoshot.base_speed == 1 and (class == "HUNTER" or class == "MAGE" or class == "PRIEST" or class == "WARLOCK") then 
		addon_data.hunter_autoshot.range_weapon_id = addon_data.utils.GetInventoryItemIDCompat("player", 18)
		local weapon_id = addon_data.hunter_autoshot.range_weapon_id
		-- added case for if no ranged equipped
		if weapon_id == nil then
			addon_data.hunter_autoshot.base_speed = 1
		elseif addon_data.ranged_DB.item_ids[weapon_id] and addon_data.ranged_DB.item_ids[weapon_id].base_speed then
			addon_data.hunter_autoshot.base_speed = addon_data.ranged_DB.item_ids[weapon_id].base_speed
		else
			addon_data.hunter_autoshot.base_speed = 1
		end
	else
		range_speed, _, _, _, _, _ = UnitRangedDamage("player")
		-- added case for if range speed returns nil or 0
		if range_speed == nil or range_speed == 0 then
			range_speed = 1
		else
			addon_data.hunter_autoshot.range_cast_speed_modifer = range_speed / addon_data.hunter_autoshot.base_speed
		end
	end
end


--- Update timer for auto shot based on various conditions
addon_data.hunter_autoshot.ResetShotTimer = function()
    -- The timer is reset to either the auto cast time or the difference between the time since the last shot and the current time depending on which is larger
    local curr_time = GetTime()
    local range_speed = addon_data.hunter_autoshot.range_speed
	
    if (curr_time + 0.05 - addon_data.hunter_autoshot.last_shot_time) > (range_speed - addon_data.hunter_autoshot.auto_cast_time) then
		addon_data.hunter_autoshot.shot_timer = addon_data.hunter_autoshot.auto_cast_time
		addon_data.hunter_autoshot.auto_shot_ready = true
		
    elseif curr_time ~= addon_data.hunter_autoshot.last_shot_time and not addon_data.hunter_autoshot.casting then
        addon_data.hunter_autoshot.shot_timer = curr_time - addon_data.hunter_autoshot.last_shot_time
        addon_data.hunter_autoshot.auto_shot_ready = false
		
	elseif addon_data.hunter_autoshot.casting then
		if (curr_time - addon_data.hunter_autoshot.last_shot_time) > (3 * addon_data.hunter_autoshot.range_cast_speed_modifer) then
			addon_data.hunter_autoshot.shot_timer = addon_data.hunter_autoshot.auto_cast_time
		end
    else
        addon_data.hunter_autoshot.shot_timer = range_speed
        addon_data.hunter_autoshot.auto_shot_ready = false
    end
end

addon_data.hunter_autoshot.UpdateAutoShotTimer = function(elapsed)
    local curr_time = GetTime()
	local shot_timer = addon_data.hunter_autoshot.shot_timer
	local _, class, _ = UnitClass("player")
    if addon_data.hunter_autoshot.shot_timer < 0 then
		addon_data.hunter_autoshot.shot_timer = 0
	else
		addon_data.hunter_autoshot.shot_timer = shot_timer - elapsed
	end
	if class == "WARLOCK" or class == "MAGE" or class == "PRIEST" then
		addon_data.hunter_autoshot.auto_cast_time = 0.52
	else
		addon_data.hunter_autoshot.UpdateRangeCastSpeedModifier()
		addon_data.hunter_autoshot.auto_cast_time = 0.52 * addon_data.hunter_autoshot.range_cast_speed_modifer
	end
	
    -- If the player moved then the timer resets
    if addon_data.hunter_autoshot.has_moved or addon_data.hunter_autoshot.casting then
        if addon_data.hunter_autoshot.shot_timer <= addon_data.hunter_autoshot.auto_cast_time then
            addon_data.hunter_autoshot.ResetShotTimer()			
        end
    end
    -- If the shot timer is less than the auto cast time then the auto shot is ready
    if addon_data.hunter_autoshot.shot_timer <= addon_data.hunter_autoshot.auto_cast_time then
        addon_data.hunter_autoshot.auto_shot_ready = true
        -- If we are not shooting then the timer should be reset
        if not addon_data.hunter_autoshot.shooting then
            addon_data.hunter_autoshot.ResetShotTimer()
        end
    else
         addon_data.hunter_autoshot.auto_shot_ready = false
    end
	if addon_data.hunter_autoshot.spell_GCD_Time + 1.5 > curr_time then
		addon_data.hunter_autoshot.spell_GCD = 1.5 - (curr_time - addon_data.hunter_autoshot.spell_GCD_Time)
	end
end

addon_data.hunter_autoshot.OnUpdate = function(elapsed)
    if character_hunter_autoshot_settings and character_hunter_autoshot_settings.enabled then
        -- Check to see if we have moved
        addon_data.hunter_autoshot.has_moved = (GetPlayerMovementSpeed() > 0)
		
		-- Check for feign death movement that causes swing reset
		if addon_data.hunter_autoshot.FeignStatus and addon_data.hunter_autoshot.has_moved then
			addon_data.hunter_autoshot.FeignDeath()
			addon_data.hunter_autoshot.FeignStatus = false
		end
		
        -- Update the Auto Shot timer based on the updated settings
        addon_data.hunter_autoshot.UpdateAutoShotTimer(elapsed)
        -- Update the visuals
        addon_data.hunter_autoshot.UpdateVisualsOnUpdate()
    end
end
-- detecting jumps out of a feign death to trigger a reset 
hooksecurefunc("JumpOrAscendStart", function()
	if  addon_data.hunter_autoshot.FeignStatus then  
			addon_data.hunter_autoshot.FeignDeath()
			addon_data.hunter_autoshot.FeignStatus = false
	end	  
end)


--- spell functions to determine the state of the spell being casted.
--- -----------------------------------------------------------------
--- Determines the state of shooting on or off
addon_data.hunter_autoshot.OnStartAutorepeatSpell = function()
    addon_data.hunter_autoshot.shooting = true
	
    if addon_data.hunter_autoshot.shot_timer <= addon_data.hunter_autoshot.auto_cast_time then
        --addon_data.hunter_autoshot.ResetShotTimer()
    end
end

addon_data.hunter_autoshot.OnStopAutorepeatSpell = function()
    addon_data.hunter_autoshot.shooting = false
end
-- Using combat log to detect pushback hits as well as starting to use spell cast events to replace the old version of detection that was implied
addon_data.hunter_autoshot.OnCombatLogUnfiltered = function(combat_info)
    local event = combat_info.event
    local casterID = combat_info.source_guid
    local spellID = combat_info.spell_id

	if casterID == UnitGUID("player") then

		if (event == "RANGE_DAMAGE" or event == "RANGE_MISSED") and (addon_data.hunter_autoshot.is_spell_auto_shot(spellID) or addon_data.hunter_autoshot.is_spell_shoot(spellID)) then
			addon_data.hunter_autoshot.FeignFullReset = false
			addon_data.hunter_autoshot.last_shot_time = GetTime()
			addon_data.hunter_autoshot.ResetShotTimer()
			addon_data.hunter_autoshot.casting_auto = false
		return end
	
		if event == "SPELL_CAST_START" then
			if not spellID then
				return
			end
		
				addon_data.hunter_autoshot.FeignStatus = false
				addon_data.hunter_autoshot.StartCastingSpell(spellID)
				
				if addon_data.hunter_autoshot.is_spell_auto_shot(spellID) then
					addon_data.hunter_autoshot.casting_auto = true
				end
				if spellID == 34120 or addon_data.hunter_autoshot.is_spell_multi_shot(spellID) then
					addon_data.hunter_autoshot.spell_GCD = 1.5
					addon_data.hunter_autoshot.spell_GCD_Time = GetTime()
				end
				
		return end
	
		if event == "SPELL_CAST_SUCCESS" then

		return end
	end		
end

--- upon spell cast succeeded, check if is auto shot and reset timer, adjust ranged speed based on haste. 
--- If not auto shot, set bar to green *commented out
addon_data.hunter_autoshot.OnUnitSpellCastSucceeded = function(unit, spell_id)

	local settings = character_hunter_autoshot_settings
	if unit == 'player' then
		local is_auto_shot = addon_data.hunter_autoshot.is_spell_auto_shot(spell_id)
		local is_shoot = addon_data.hunter_autoshot.is_spell_shoot(spell_id)
		local is_aimed_shot = addon_data.hunter_autoshot.is_spell_aimed_shot(spell_id)
		local spell_name = nil
		if type(spell_id) == "number" and addon_data.hunter_autoshot.shot_spell_ids[spell_id] then
			spell_name = addon_data.hunter_autoshot.shot_spell_ids[spell_id].spell_name
		elseif type(spell_id) == "string" then
			spell_name = spell_id
		end
	
	    addon_data.hunter_autoshot.casting = false
        -- If the spell is Auto Shot then reset the shot timer
		if spell_name then
			if spell_name == L["spell.feign_death"] or spell_name == L["spell.trueshot_aura"] then
				if spell_name == L["spell.feign_death"] then
					addon_data.hunter_autoshot.FeignStatus = true
				end
				addon_data.hunter_autoshot.FeignDeath()
				return
			end
			if is_aimed_shot then
				addon_data.hunter_autoshot.FeignFullReset = false
                addon_data.hunter_autoshot.last_shot_time = GetTime()
                addon_data.hunter_autoshot.ResetShotTimer()
				addon_data.hunter_autoshot.casting_auto = false
				
			end
			if is_auto_shot or is_shoot then
				addon_data.hunter_autoshot.FeignFullReset = false
                addon_data.hunter_autoshot.last_shot_time = GetTime()
                addon_data.hunter_autoshot.ResetShotTimer()
				addon_data.hunter_autoshot.casting_auto = false
			--else 
                --addon_data.hunter_autoshot.casting_auto = false
            end
			if is_shoot then
				new_range_speed, _, _, _, _, _ = UnitRangedDamage("player")
				addon_data.hunter_autoshot.range_speed = new_range_speed
			end
        end

		if is_auto_shot then	-- Update the ranged attack speed
			new_range_speed, _, _, _, _, _ = UnitRangedDamage("player")

			-- Handling for getting haste buffs in combat, don't need to update auto shot cast time until the next shot is ready
			if new_range_speed ~= addon_data.hunter_autoshot.range_speed then
				if not addon_data.hunter_autoshot.auto_shot_ready then
					addon_data.hunter_autoshot.shot_timer = addon_data.hunter_autoshot.shot_timer * 
											(new_range_speed / addon_data.hunter_autoshot.range_speed)
				end
				addon_data.hunter_autoshot.range_speed = new_range_speed
				addon_data.hunter_autoshot.range_auto_speed_modified = addon_data.hunter_autoshot.range_cast_speed_modifer
			end
		end
    end
end

addon_data.hunter_autoshot.OnUnitSpellCastInterrupted = function(unit, spell_id)
    local settings = character_hunter_autoshot_settings
	
	addon_data.hunter_autoshot.casting = false
	if unit == 'player' and addon_data.hunter_autoshot.is_spell_auto_shot(spell_id) then
		addon_data.hunter_autoshot.casting_auto = false
		--addon_data.hunter_autoshot.shot_timer = addon_data.hunter_autoshot.auto_cast_time
		--addon_data.hunter_autoshot.ResetShotTimer()
	end
	
end

--- triggered when auto shot is toggled on and attempts to begin casting, but can't
--- This causes 0.5 seconds of delay before it can try casting again
addon_data.hunter_autoshot.OnUnitSpellCastFailedQuiet = function(unit, spell_id)
    local settings = character_hunter_autoshot_settings
	local curr_time = GetTime()
    if settings.show_autoshot_delay_timer and unit == "player" and addon_data.hunter_autoshot.is_spell_auto_shot(spell_id) then
        
		if not addon_data.hunter_autoshot.casting and addon_data.hunter_autoshot.shooting 
		   and (curr_time - addon_data.hunter_autoshot.last_shot_time) > (addon_data.hunter_autoshot.range_speed - addon_data.hunter_autoshot.auto_cast_time) then
			
			addon_data.hunter_autoshot.shot_timer = addon_data.hunter_autoshot.auto_cast_time + 0.5
		end
    end
end

addon_data.hunter_autoshot.UsesPlayerMainhandAnchor = function()
    local settings = character_hunter_autoshot_settings
    if not settings then
        return false
    end

    local placement_mode = addon_data.hunter_autoshot.NormalizePlacementMode(settings.placement_mode)
    return (placement_mode == "overlay_mainhand") or (placement_mode == "replace_mainhand")
end

addon_data.hunter_autoshot.NormalizePlacementMode = function(placement_mode)
    if placement_mode == "independent" or placement_mode == 1 then
        return "independent"
    end

    if placement_mode == "overlay_mainhand" or placement_mode == 2 then
        return "overlay_mainhand"
    end

    if placement_mode == "replace_mainhand" or placement_mode == 3 then
        return "replace_mainhand"
    end

    return "independent"
end

addon_data.hunter_autoshot.GetVisualDimensions = function()
    local settings = character_hunter_autoshot_settings or addon_data.hunter_autoshot.default_settings
    if addon_data.hunter_autoshot.UsesPlayerMainhandAnchor() and character_player_settings then
        local player_fontsize = character_player_settings.fontsize or settings.fontsize
        return character_player_settings.width, character_player_settings.height, player_fontsize
    end

    return settings.width, settings.height, settings.fontsize
end

addon_data.hunter_autoshot.ShouldShowBar = function()
    local settings = character_hunter_autoshot_settings
    if not settings or not settings.enabled then
        return false
    end

    local attack_mode = "none"
    if addon_data.core and addon_data.core.GetActiveAttackMode then
        attack_mode = addon_data.core.GetActiveAttackMode()
    end

    if attack_mode == "melee" then
        return false
    end

    if not addon_data.utils.ShouldShowByDistanceCondition(settings.display_condition, attack_mode, false) then
        return false
    end

    return true
end

addon_data.hunter_autoshot.ShouldReplacePlayerMainhandBar = function()
    local settings = character_hunter_autoshot_settings
    if not settings then
        return false
    end

    local placement_mode = addon_data.hunter_autoshot.NormalizePlacementMode(settings.placement_mode)
    if placement_mode ~= "replace_mainhand" then
        return false
    end

    return addon_data.hunter_autoshot.ShouldShowBar()
end

--- Updating and initializing visuals
--- ---------------------------------
addon_data.hunter_autoshot.UpdateVisualsOnUpdate = function()
    local settings = character_hunter_autoshot_settings
    local frame = addon_data.hunter_autoshot.frame
    if not frame or not frame.shot_bar then
        return
    end
    local should_show = addon_data.hunter_autoshot.ShouldShowBar()
    if not should_show then
        frame:Hide()
        return
    end

    if not frame:IsShown() then
        frame:Show()
    end

    local bar_width, bar_height = addon_data.hunter_autoshot.GetVisualDimensions()
    local range_speed = addon_data.hunter_autoshot.range_speed
    local shot_timer = addon_data.hunter_autoshot.shot_timer
    local auto_cast_time = addon_data.hunter_autoshot.auto_cast_time
	local mult_cast_time = 0.5 * addon_data.hunter_autoshot.range_cast_speed_modifer
	
	if settings.enabled then
        frame.shot_bar_text:SetText(tostring(addon_data.utils.SimpleRound(shot_timer, 0.1)))
        if addon_data.core.in_combat or addon_data.hunter_autoshot.shooting or addon_data.hunter_autoshot.casting_shot then
            frame:SetAlpha(settings.in_combat_alpha)
        else
            frame:SetAlpha(settings.ooc_alpha)
        end
        if not settings.one_bar then
            if addon_data.hunter_autoshot.auto_shot_ready then
                frame.shot_bar:SetVertexColor(settings.auto_cast_r, settings.auto_cast_g, settings.auto_cast_b, settings.auto_cast_a)
                new_width = bar_width * (auto_cast_time - shot_timer) / auto_cast_time
                frame.multishot_clip_bar:Hide()
            else
                if addon_data.hunter_autoshot.spell_GCD > 0.5 then
					frame.shot_bar:SetVertexColor(0.8, 0.64, 0, 1)
				else
					frame.shot_bar:SetVertexColor(settings.cooldown_r, settings.cooldown_g, settings.cooldown_b, settings.cooldown_a)
				end
                new_width = bar_width * ((shot_timer - auto_cast_time) / (range_speed - auto_cast_time))
                if settings.show_multishot_clip_bar then
                    frame.multishot_clip_bar:Show()
                    multishot_clip_width = math.min((bar_width * 2) * (mult_cast_time / (addon_data.hunter_autoshot.range_speed)), bar_width)
                    frame.multishot_clip_bar:SetWidth(multishot_clip_width)
                end
            end
            if new_width < 2 then
                new_width = 2
            end
            frame.shot_bar:SetWidth(math.min(new_width, bar_width))
        else
		    if addon_data.hunter_autoshot.spell_GCD > 0.2 then
				frame.shot_bar:SetVertexColor(0.8, 0.64, 0, 1)
			else
				frame.shot_bar:SetVertexColor(settings.cooldown_r, settings.cooldown_g, settings.cooldown_b, settings.cooldown_a)
			end
            timer_width = bar_width * ((addon_data.hunter_autoshot.range_speed - addon_data.hunter_autoshot.shot_timer) / addon_data.hunter_autoshot.range_speed)
            if addon_data.hunter_autoshot.auto_shot_ready then
                auto_shot_cast_width = bar_width * (addon_data.hunter_autoshot.shot_timer / addon_data.hunter_autoshot.range_speed)
            else
                auto_shot_cast_width = bar_width * (addon_data.hunter_autoshot.auto_cast_time / addon_data.hunter_autoshot.range_speed)
            end
            if settings.show_multishot_clip_bar then
                frame.multishot_clip_bar:Show()
                multishot_clip_width = math.min(bar_width * (mult_cast_time / range_speed ), bar_width)
                frame.multishot_clip_bar:SetWidth(5)
                multi_offset = (bar_width * (addon_data.hunter_autoshot.auto_cast_time / addon_data.hunter_autoshot.range_speed)) + multishot_clip_width
                frame.multishot_clip_bar:SetPoint('BOTTOMRIGHT', -multi_offset, 0)
            end
            frame.shot_bar:SetWidth(math.min(timer_width, bar_width))
            frame.auto_shot_cast_bar:SetWidth(math.max(auto_shot_cast_width, 0.001))
        end
		frame:SetSize(bar_width, bar_height)
    end
end

addon_data.hunter_autoshot.UpdateVisualsOnSettingsChange = function()
    local settings = character_hunter_autoshot_settings
    local frame = addon_data.hunter_autoshot.frame
	local anchor_settings = settings
	local bar_width, bar_height, bar_fontsize = addon_data.hunter_autoshot.GetVisualDimensions()
	if addon_data.hunter_autoshot.UsesPlayerMainhandAnchor() and character_player_settings then
		anchor_settings = character_player_settings
	end
	if settings.enabled then
        frame:ClearAllPoints()
        frame:SetPoint(anchor_settings.point, UIParent, anchor_settings.rel_point, anchor_settings.x_offset, anchor_settings.y_offset)
        if settings.show_border then
            addon_data.utils.SetBackdropCompat(frame.backplane,
                "Interface/AddOns/WeaponSwingTimer/Images/Background",
                "Interface/AddOns/WeaponSwingTimer/Images/Border",
                16,
                12,
                { left = 8, right = 8, top = 8, bottom = 8 })
        else
            addon_data.utils.SetBackdropCompat(frame.backplane,
                "Interface/AddOns/WeaponSwingTimer/Images/Background",
                nil,
                16,
                16,
                { left = 8, right = 8, top = 8, bottom = 8 })
        end
        frame.backplane:SetBackdropColor(0,0,0,settings.backplane_alpha)
        frame.shot_bar:ClearAllPoints()
        if not settings.one_bar then
            frame.shot_bar:SetPoint("BOTTOM", 0, 0)
            frame.auto_shot_cast_bar:Hide()
        else
            frame.shot_bar:SetPoint("BOTTOMLEFT", 0, 0)
            frame.shot_bar:SetVertexColor(settings.cooldown_r, settings.cooldown_g, settings.cooldown_b, settings.cooldown_a)
            frame.auto_shot_cast_bar:Show()
            frame.auto_shot_cast_bar:SetPoint('BOTTOMRIGHT', 0, 0)
            frame.auto_shot_cast_bar:SetHeight(bar_height)
            frame.auto_shot_cast_bar:SetVertexColor(settings.auto_cast_r, settings.auto_cast_g, settings.auto_cast_b, settings.auto_cast_a)
        end
        frame.shot_bar_text:SetPoint("BOTTOMRIGHT", -5, (bar_height / 2) - (bar_fontsize / 2))
        frame.shot_bar_text:SetTextColor(1.0, 1.0, 1.0, 1.0)
		frame.shot_bar_text:SetFont("Fonts/FRIZQT__.ttf", bar_fontsize)
		
        frame.shot_bar:SetHeight(bar_height)
        if settings.classic_bars then
            addon_data.utils.SetTextureFile(frame.shot_bar, 'Interface/AddOns/WeaponSwingTimer/Images/Bar')
            addon_data.utils.SetTextureFile(frame.auto_shot_cast_bar, 'Interface/AddOns/WeaponSwingTimer/Images/Bar')
        else
            addon_data.utils.SetTextureFile(frame.shot_bar, 'Interface/AddOns/WeaponSwingTimer/Images/Background')
            addon_data.utils.SetTextureFile(frame.auto_shot_cast_bar, 'Interface/AddOns/WeaponSwingTimer/Images/Background')
        end
        frame.multishot_clip_bar:ClearAllPoints()
        if not settings.one_bar then
            frame.multishot_clip_bar:SetPoint("BOTTOM", 0, 0)
        else
            frame.multishot_clip_bar:SetPoint("BOTTOMRIGHT", 0, 0)
        end
        frame.multishot_clip_bar:SetHeight(bar_height)
		addon_data.utils.SetTextureColor(frame.multishot_clip_bar, settings.clip_r, settings.clip_g, settings.clip_b, settings.clip_a)
		
        if settings.show_multishot_clip_bar then
            frame.multishot_clip_bar:Show()
        else
            frame.multishot_clip_bar:Hide()
        end
        if settings.show_text then
            frame.shot_bar_text:Show()
        else
            frame.shot_bar_text:Hide()
        end

        if addon_data.hunter_autoshot.ShouldShowBar() then
            frame:Show()
        else
            frame:Hide()
        end
    else
        frame:Hide()
    end
end

addon_data.hunter_autoshot.OnFrameDragStart = function()
    if not character_hunter_autoshot_settings.is_locked then
        addon_data.hunter_autoshot.frame:StartMoving()
    end
end

addon_data.hunter_autoshot.OnFrameDragStop = function()
    local frame = addon_data.hunter_autoshot.frame
    local settings = character_hunter_autoshot_settings
    frame:StopMovingOrSizing()
    point, _, rel_point, x_offset, y_offset = frame:GetPoint()
    if x_offset < 20 and x_offset > -20 then
        x_offset = 0
    end
    settings.point = point
    settings.rel_point = rel_point
    settings.x_offset = addon_data.utils.SimpleRound(x_offset, 1)
    settings.y_offset = addon_data.utils.SimpleRound(y_offset, 1)
    addon_data.hunter_autoshot.UpdateVisualsOnSettingsChange()
end

addon_data.hunter_autoshot.InitializeVisuals = function()
    local settings = character_hunter_autoshot_settings or addon_data.hunter_autoshot.default_settings
    if not settings.fontsize then
        settings.fontsize = addon_data.hunter_autoshot.default_settings.fontsize
    end
    -- Create the frame
    addon_data.hunter_autoshot.frame = CreateFrame("Frame", addon_name .. "HunterAutoshotFrame", UIParent)
    local frame = addon_data.hunter_autoshot.frame
	
    frame:SetMovable(true)
    frame:EnableMouse(not settings.is_locked)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", addon_data.hunter_autoshot.OnFrameDragStart)
    frame:SetScript("OnDragStop", addon_data.hunter_autoshot.OnFrameDragStop)
    -- Create the backplane
    frame.backplane = CreateFrame("Frame", addon_name .. "HunterBackdropFrame", frame)
    frame.backplane:SetPoint('TOPLEFT', -9, 9)
    frame.backplane:SetPoint('BOTTOMRIGHT', 9, -9)
    frame.backplane:SetFrameStrata('BACKGROUND')
    -- Create the shot bar
    frame.shot_bar = frame:CreateTexture(nil,"ARTWORK")
    -- Create the shot bar text
    frame.shot_bar_text = frame:CreateFontString(nil,"OVERLAY")
    frame.shot_bar_text:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize)
    frame.shot_bar_text:SetJustifyV("CENTER")
    frame.shot_bar_text:SetJustifyH("CENTER")
    -- Create the multishot clip bar
    frame.multishot_clip_bar = frame:CreateTexture(nil,"OVERLAY")
    -- Create the auto shot cast bar indicator
    frame.auto_shot_cast_bar = frame:CreateTexture(nil,"OVERLAY")
    -- Show it off
    addon_data.hunter_autoshot.UpdateVisualsOnSettingsChange()
    addon_data.hunter_autoshot.UpdateVisualsOnUpdate()
    if addon_data.hunter_autoshot.ShouldShowBar() then
        frame:Show()
    else
        frame:Hide()
    end
end
