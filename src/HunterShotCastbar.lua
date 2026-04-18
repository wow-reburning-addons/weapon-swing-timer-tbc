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
--- define addon structure from the above local variable
addon_data.hunter_shot_castbar = {}
--- declare array for ranks of all abilities, cast times, cooldown, based on spell ID
addon_data.hunter_shot_castbar.shot_spell_ids = {
	[5384] = {spell_name = L["spell.feign_death"], rank = nil, cast_time = nil, cooldown = nil},
	[19506] = {spell_name = L["spell.trueshot_aura"], rank = 1, cast_time = nil, cooldown = nil},
	[20905] = {spell_name = L["spell.trueshot_aura"], rank = 2, cast_time = nil, cooldown = nil},
	[20906] = {spell_name = L["spell.trueshot_aura"], rank = 3, cast_time = nil, cooldown = nil},
    [2643] = {spell_name = L["spell.multi_shot"], rank = 1, cast_time = 0.5, cooldown = 10},
    [14288] = {spell_name = L["spell.multi_shot"], rank = 2, cast_time = 0.5, cooldown = 10},
    [14289] = {spell_name = L["spell.multi_shot"], rank = 3, cast_time = 0.5, cooldown = 10},
    [14290] = {spell_name = L["spell.multi_shot"], rank = 4, cast_time = 0.5, cooldown = 10},
    [25294] = {spell_name = L["spell.multi_shot"], rank = 5, cast_time = 0.5, cooldown = 10},
	[27021] = {spell_name = L["spell.multi_shot"], rank = 6, cast_time = 0.5, cooldown = 10},
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
addon_data.hunter_shot_castbar.is_spell_multi_shot = function(spell_id)
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
addon_data.hunter_shot_castbar.is_spell_aimed_shot = function(spell_id)
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
addon_data.hunter_shot_castbar.is_spell_auto_shot = function(spell_id)
    if type(spell_id) == "string" then
        return spell_id == L["spell.auto_shot"]
    end

    return (spell_id == 75)
end
--- is spell shoot defined by spell_id
addon_data.hunter_shot_castbar.is_spell_shoot = function(spell_id)
    if type(spell_id) == "string" then
        return spell_id == L["spell.shoot"]
    end

    return (spell_id == 5019)
end
--- default settings to be loaded on initial load and reset to default
addon_data.hunter_shot_castbar.default_settings = {
	enabled = true,
	width = 300,
	height = 12,
	fontsize = 12,
    point = "CENTER",
	rel_point = "CENTER",
	x_offset = 0,
	y_offset = 0,
	in_combat_alpha = 1.0,
	--ooc_alpha = 0.5,
	backplane_alpha = 0.5,
    show_cast_text = true,
    show_aimedshot_cast_bar = true,
    show_multishot_cast_bar = true,
    show_latency_bars = false,
    show_border = false
}
--- Initializing variables for calculations and function calls

addon_data.hunter_shot_castbar.casting = false
addon_data.hunter_shot_castbar.casting_shot = false
addon_data.hunter_shot_castbar.casting_spell_id = 0
addon_data.hunter_shot_castbar.cast_timer = 0.1
addon_data.hunter_shot_castbar.cast_time = 0.1
addon_data.hunter_shot_castbar.last_failed_time = GetTime()
addon_data.hunter_shot_castbar.cast_start_time = GetTime()
addon_data.hunter_shot_castbar.hitcount = 0
addon_data.hunter_shot_castbar.initial_pushback_time = 0
addon_data.hunter_shot_castbar.initial_cast_time = 0
addon_data.hunter_shot_castbar.total_pushback = 0

addon_data.hunter_shot_castbar.CastPushback = function()
	if addon_data.hunter_shot_castbar.casting_shot then
	        -- https://wow.gamepedia.com/index.php?title=Interrupt&oldid=305918
        addon_data.hunter_shot_castbar.pushbackValue = addon_data.hunter_shot_castbar.pushbackValue or 1

		if ((GetTime() - addon_data.hunter_shot_castbar.cast_start_time) < 1) and (addon_data.hunter_shot_castbar.hitcount < 1) then
			addon_data.hunter_shot_castbar.initial_pushback_time = GetTime() - addon_data.hunter_shot_castbar.cast_start_time
		end

		if addon_data.hunter_shot_castbar.initial_pushback_time > 0 then
			addon_data.hunter_shot_castbar.cast_time = addon_data.hunter_shot_castbar.cast_time + addon_data.hunter_shot_castbar.initial_pushback_time
			addon_data.hunter_shot_castbar.initial_pushback_time = 0
			addon_data.hunter_shot_castbar.pushbackValue = 1
		else
			addon_data.hunter_shot_castbar.cast_time = addon_data.hunter_shot_castbar.cast_time + addon_data.hunter_shot_castbar.pushbackValue
		end

		addon_data.hunter_shot_castbar.hitcount = addon_data.hunter_shot_castbar.hitcount + 1

        addon_data.hunter_shot_castbar.pushbackValue = max(addon_data.hunter_shot_castbar.pushbackValue - 0.2, 0.2)
		
		return
	end
end

-- Selection of starting a timer for casting multi and handling of stopping auto timer from starting
addon_data.hunter_shot_castbar.StartCastingSpell = function(spell_id)
    local settings = character_hunter_shot_castbar_settings

    if (GetTime() - addon_data.hunter_shot_castbar.last_failed_time) > 0 then
        if not addon_data.hunter_shot_castbar.casting and UnitCanAttack('player', 'target') then
            spell_name, _, _, cast_time, _, _, _ = GetSpellInfo(spell_id)
            if cast_time == nil then
			
                return 
            end
            if not addon_data.hunter_shot_castbar.is_spell_auto_shot(spell_id) and 
               not addon_data.hunter_shot_castbar.is_spell_shoot(spell_id) and cast_time > 0 then
                    addon_data.hunter_shot_castbar.casting = true
            end

			if (not addon_data.hunter_shot_castbar.casting_shot) and (addon_data.hunter_shot_castbar.is_spell_multi_shot(spell_id) and settings.show_multishot_cast_bar) or (addon_data.hunter_shot_castbar.is_spell_aimed_shot(spell_id) and settings.show_aimedshot_cast_bar) then
				addon_data.hunter_shot_castbar.cast_start_time = GetTime()
				addon_data.hunter_shot_castbar.casting_shot = true
				addon_data.hunter_shot_castbar.casting_spell_id = spell_id
				addon_data.hunter_shot_castbar.pushbackValue = 1
				addon_data.hunter_shot_castbar.initial_pushback_time = 0
				addon_data.hunter_shot_castbar.initial_cast_time = cast_time
                    
				addon_data.hunter_shot_castbar.cast_timer = 0
				addon_data.hunter_shot_castbar.frame.spell_bar:SetVertexColor(0.7, 0.4, 0, 1)

				if settings.show_latency_bars then
					local _, _, _, latency = GetNetStats()
					addon_data.hunter_shot_castbar.cast_time = addon_data.hunter_shot_castbar.cast_time + (latency / 1000)
				end
				if settings.show_cast_text then
					addon_data.hunter_shot_castbar.frame.spell_text_center:SetText(spell_name)
				end
			end	
		end
	end
end

addon_data.hunter_shot_castbar.LoadSettings = function()
    if not character_hunter_shot_castbar_settings and addon_data.core and addon_data.core.db then
        character_hunter_shot_castbar_settings = addon_data.core.db.char.hunter_shot_castbar
    end

    addon_data.hunter_shot_castbar.scan_tip = CreateFrame("GameTooltip", "WSTScanTip", nil, "GameTooltipTemplate")
    addon_data.hunter_shot_castbar.scan_tip:SetOwner(WorldFrame, "ANCHOR_NONE")
end

addon_data.hunter_shot_castbar.RestoreDefaults = function()
    for setting, value in pairs(addon_data.hunter_shot_castbar.default_settings) do
        character_hunter_shot_castbar_settings[setting] = value
    end
    _, class, _ = UnitClass("player")
    character_hunter_shot_castbar_settings.enabled = (class == "HUNTER" or class == "MAGE" or class == "PRIEST" or class == "WARLOCK")
    addon_data.hunter_shot_castbar.UpdateVisualsOnSettingsChange()
end


--- Buffs and debuffs change casting speeds, which is multiplied by the cast time
--- -----------------------------------------------------------------------------
--- Anything that changes cast times should go here. Need to add other forms of debuffs
--- berserk haste is a simple calculation to derive the percent of berserking haste provided to the player from their health percent

addon_data.hunter_shot_castbar.UpdateCastTimer = function(elapsed)
	
	local base_cast_time = addon_data.hunter_shot_castbar.shot_spell_ids[addon_data.hunter_shot_castbar.casting_spell_id].cast_time
	
	if (addon_data.hunter_shot_castbar.cast_timer < 0.25) then
		addon_data.hunter_shot_castbar.cast_time = base_cast_time * addon_data.hunter_autoshot.range_cast_speed_modifer
	end
	
    addon_data.hunter_shot_castbar.cast_timer = GetTime() - addon_data.hunter_shot_castbar.cast_start_time
    if addon_data.hunter_shot_castbar.cast_timer > addon_data.hunter_shot_castbar.cast_time + 0.5 then
        addon_data.hunter_shot_castbar.OnUnitSpellCastFailed('player', 1)
    end
	
	addon_data.hunter_shot_castbar.total_pushback = addon_data.hunter_shot_castbar.cast_time - addon_data.hunter_shot_castbar.initial_cast_time
end

addon_data.hunter_shot_castbar.OnUpdate = function(elapsed)
	local _, class, _ = UnitClass("player")
    if character_hunter_shot_castbar_settings.enabled and (class == "HUNTER") then
		local curr_time = GetTime()
        -- Update the cast bar timers
        if addon_data.hunter_shot_castbar.casting_shot then
            addon_data.hunter_shot_castbar.UpdateCastTimer(elapsed)
        end
        -- Update the visuals
        addon_data.hunter_shot_castbar.UpdateVisualsOnUpdate()
		
    end
end

-- Using combat log to detect pushback hits as well as starting to use spell cast events to replace the old version of detection that was implied
addon_data.hunter_shot_castbar.OnCombatLogUnfiltered = function(combat_info)
    local event = combat_info.event
    local casterID = combat_info.source_guid
    local targetID = combat_info.dest_guid
	local spellID = combat_info.spell_id
	if casterID == UnitGUID("player") then
	
		if event == "SPELL_CAST_START" then
			if not spellID then
				return
			end
		  
				addon_data.hunter_autoshot.FeignStatus = false
				if addon_data.hunter_shot_castbar.is_spell_multi_shot(spellID) or addon_data.hunter_shot_castbar.is_spell_aimed_shot(spellID) then
					addon_data.hunter_shot_castbar.StartCastingSpell(spellID)
					
				end
				
		return end
	
		if event == "SPELL_CAST_SUCCESS" then

		return end
	end		
		
	
	if event == "SWING_MISSED" or event == "RANGE_MISSED" or event == "SPELL_MISSED" then	return end
	if event == "SWING_DAMAGE" or event == "ENVIRONMENTAL_DAMAGE" or event == "RANGE_DAMAGE" or event == "SPELL_DAMAGE" then	
	
		if targetID == UnitGUID("player") then
			addon_data.hunter_shot_castbar.CastPushback()
		end
	return end
end

--- upon spell cast succeeded, check if is auto shot and reset timer, adjust ranged speed based on haste. 
--- If not auto shot, set bar to green *commented out
addon_data.hunter_shot_castbar.OnUnitSpellCastSucceeded = function(unit, spell_id)

	local settings = character_hunter_shot_castbar_settings
	local is_aimed_shot = addon_data.hunter_shot_castbar.is_spell_aimed_shot(spell_id)
	local is_multi_shot = addon_data.hunter_shot_castbar.is_spell_multi_shot(spell_id)

  if unit == 'player' then
	
	      addon_data.hunter_shot_castbar.casting = false
        
        if addon_data.hunter_shot_castbar.shot_spell_ids[spell_id] or is_aimed_shot or is_multi_shot then

			if is_aimed_shot then

				addon_data.hunter_autoshot.FeignDeath()
			end
			addon_data.hunter_shot_castbar.casting_spell_id = 0
            addon_data.hunter_shot_castbar.casting_shot = false
			-- only show green bar overlay if setting is enabled
			local spell_aimed_enabled = (is_aimed_shot and settings.show_aimedshot_cast_bar)
			local spell_multi_enabled = (is_multi_shot and settings.show_multishot_cast_bar)
			if (spell_aimed_enabled or spell_multi_enabled) then
				addon_data.hunter_shot_castbar.frame.spell_bar:SetVertexColor(0, 0.5, 0, 1)
				addon_data.hunter_shot_castbar.frame.spell_bar:SetWidth(character_hunter_shot_castbar_settings.width)
				addon_data.hunter_shot_castbar.frame.spell_bar_text:SetText("0.0")
			end
            
        end

    end
end

addon_data.hunter_shot_castbar.OnUnitSpellCastFailed = function(unit, spell_id)
    local settings = character_hunter_shot_castbar_settings
    local frame = addon_data.hunter_shot_castbar.frame
	-- only care about if multi fails to cast, so ignore others
    if unit == 'player' and (addon_data.hunter_shot_castbar.is_spell_multi_shot(spell_id) or addon_data.hunter_shot_castbar.is_spell_aimed_shot(spell_id)) then

        addon_data.hunter_shot_castbar.last_failed_time = GetTime()
        addon_data.hunter_shot_castbar.casting = false
		addon_data.hunter_shot_castbar.pushbackValue = 1
		addon_data.hunter_shot_castbar.initial_pushback_time = 0
		addon_data.hunter_shot_castbar.hitcount = 0
		
        local spell_aimed_enabled = (addon_data.hunter_shot_castbar.is_spell_aimed_shot(spell_id) and settings.show_aimedshot_cast_bar)
		local spell_multi_enabled = (addon_data.hunter_shot_castbar.is_spell_multi_shot(spell_id) and settings.show_multishot_cast_bar)
        if (addon_data.hunter_shot_castbar.casting_spell_id > 0) and (spell_aimed_enabled or spell_multi_enabled) then
		
            addon_data.hunter_shot_castbar.casting_shot = false
            addon_data.hunter_shot_castbar.casting_spell_id = 0
			if spell_aimed_enabled or spell_multi_enabled then
				addon_data.hunter_shot_castbar.frame.spell_bar:SetVertexColor(0.7, 0, 0, 1)
				if character_hunter_shot_castbar_settings.show_text then
					frame.spell_text_center:SetText(L["cast.failed"])
				end
				frame.spell_bar:SetWidth(settings.width)
			end
        end
    end
end

addon_data.hunter_shot_castbar.OnUnitSpellCastInterrupted = function(unit, spell_id)
    local settings = character_hunter_shot_castbar_settings
	local frame = addon_data.hunter_shot_castbar.frame
	if unit == 'player' and (addon_data.hunter_shot_castbar.is_spell_multi_shot(spell_id) or addon_data.hunter_shot_castbar.is_spell_aimed_shot(spell_id)) then
	
        addon_data.hunter_shot_castbar.casting = false
		addon_data.hunter_shot_castbar.pushbackValue = 1
		addon_data.hunter_shot_castbar.initial_pushback_time = 0
		addon_data.hunter_shot_castbar.hitcount = 0
		
		local spell_aimed_enabled = (addon_data.hunter_shot_castbar.is_spell_aimed_shot(spell_id) and settings.show_aimedshot_cast_bar)
		local spell_multi_enabled = (addon_data.hunter_shot_castbar.is_spell_multi_shot(spell_id) and settings.show_multishot_cast_bar)
        if (addon_data.hunter_shot_castbar.casting_spell_id > 0) and (spell_aimed_enabled or spell_multi_enabled) then
            addon_data.hunter_shot_castbar.casting_shot = false
            addon_data.hunter_shot_castbar.casting_spell_id = 0
			
			if spell_aimed_enabled or spell_multi_enabled then
				frame.spell_bar:SetVertexColor(0.7, 0, 0, 1)
				if settings.show_text then
					frame.spell_text_center:SetText(L["cast.interrupted"])
				end
				frame.spell_bar:SetWidth(settings.width)
			end
        end
    end
end

--- Updating and initializing visuals
--- ---------------------------------
addon_data.hunter_shot_castbar.UpdateVisualsOnUpdate = function()
    local settings = character_hunter_shot_castbar_settings
    local frame = addon_data.hunter_shot_castbar.frame
    if not frame or not frame.spell_bar then
        return
    end

    if addon_data.core.in_combat or addon_data.hunter_shot_castbar.casting_shot then
		if addon_data.hunter_shot_castbar.casting_shot then
		
			local time_left = math.max(addon_data.utils.SimpleRound(addon_data.hunter_shot_castbar.cast_time - addon_data.hunter_shot_castbar.cast_timer, 0.1), 0)
			frame.spell_bar_text:SetText(string.format("%.1f", time_left))
			frame:SetAlpha(1)
			frame.spell_bar:SetVertexColor(0.8, 0.64, 0, 1)
			new_width = settings.width * (addon_data.hunter_shot_castbar.cast_timer / addon_data.hunter_shot_castbar.cast_time)
			new_width = math.min(new_width, settings.width)
			frame.spell_bar:SetWidth(new_width)
			frame.spell_spark:SetPoint('TOPLEFT', new_width - 8, 0)
			if new_width == settings.width or not settings.classic_bars then
				frame.spell_spark:Hide()
			else
				frame.spell_spark:Show()
			end
		else
			new_alpha = frame:GetAlpha() - 0.005

			if new_alpha <= 0 then
				new_alpha = 0
				frame:SetSize(settings.width, settings.height)
				frame.spell_text_center:SetText("")
				frame.spell_bar_text:SetText("")
			end
			frame:SetAlpha(new_alpha)
			frame.spell_spark:Hide()
		end
		if settings.show_latency_bars then
				if addon_data.hunter_shot_castbar.casting_shot then
				frame.cast_latency:Show()
				_, _, _, latency = GetNetStats()
				lag_width = settings.width * ((latency / 1000) / addon_data.hunter_shot_castbar.cast_time)
				frame.cast_latency:SetWidth(lag_width)
			else
				frame.cast_latency:Hide()
		end
	end
	else
		frame.spell_bar:SetVertexColor(0.2, 0.2, 0.2, 1)
		frame:SetSize(settings.width, settings.height)
        if not (settings.is_locked) then
			frame.spell_text_center:SetText(L["cast.spell_shot_bar_unlocked"])
			frame:SetAlpha(1)
		else
			frame:SetAlpha(0)
		end
    end
end

addon_data.hunter_shot_castbar.UpdateVisualsOnSettingsChange = function()
    local settings = character_hunter_shot_castbar_settings
    local frame = addon_data.hunter_shot_castbar.frame
	local _, class, _ = UnitClass("player")
	if (settings.show_multishot_cast_bar or settings.show_aimedshot_cast_bar) and (class == "HUNTER") then
        frame:Show()
        frame:ClearAllPoints()
        frame:SetPoint(settings.point, UIParent, settings.rel_point, settings.x_offset, settings.y_offset)
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
		frame:SetAlpha(1)
        frame.backplane:SetBackdropColor(0,0,0,settings.backplane_alpha)

        frame.spell_bar_text:SetPoint("TOPRIGHT", -5, -(settings.height / 2) + (settings.fontsize / 2))
        frame.spell_bar_text:SetTextColor(1.0, 1.0, 1.0, 1.0)
		frame.spell_bar_text:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize)
		
        frame.spell_bar:SetPoint("TOPLEFT", 0, 0)
        frame.spell_bar:SetHeight(settings.height)

		addon_data.utils.SetTextureFile(frame.spell_bar, 'Interface/AddOns/WeaponSwingTimer/Images/Background')
        frame.spell_spark:SetSize(16, settings.height)
        frame.spell_text_center:SetPoint("TOP", 2, -(settings.height / 2) + (settings.fontsize / 2))
		frame.spell_text_center:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize)
		
		frame.cast_latency:SetHeight(settings.height)
        frame.cast_latency:SetPoint("TOPLEFT", 0, 0)
        addon_data.utils.SetTextureColor(frame.cast_latency, 1, 0, 0, 0.75)
        if settings.show_latency_bars then
            frame.cast_latency:Show()
        else
            frame.cast_latency:Hide()
        end

        if settings.show_cast_text then
            frame.spell_text_center:Show()
            frame.spell_bar_text:Show()
        else
            frame.spell_text_center:Hide()
            frame.spell_bar_text:Hide()
        end
    else
        frame:Hide()
    end
end

addon_data.hunter_shot_castbar.OnFrameDragStart = function()
    if not character_hunter_shot_castbar_settings.is_locked then
        addon_data.hunter_shot_castbar.frame:StartMoving()
    end
end

addon_data.hunter_shot_castbar.OnFrameDragStop = function()
    local frame = addon_data.hunter_shot_castbar.frame
    local settings = character_hunter_shot_castbar_settings
    frame:StopMovingOrSizing()
    point, _, rel_point, x_offset, y_offset = frame:GetPoint()
    if x_offset < 20 and x_offset > -20 then
        x_offset = 0
    end
    settings.point = point
    settings.rel_point = rel_point
    settings.x_offset = addon_data.utils.SimpleRound(x_offset, 1)
    settings.y_offset = addon_data.utils.SimpleRound(y_offset, 1)
    addon_data.hunter_shot_castbar.UpdateVisualsOnSettingsChange()
end

addon_data.hunter_shot_castbar.InitializeVisuals = function()
    local settings = character_hunter_shot_castbar_settings
    -- Create the frame
    addon_data.hunter_shot_castbar.frame = CreateFrame("Frame", addon_name .. "HunterCastbarFrame", UIParent)
    local frame = addon_data.hunter_shot_castbar.frame
    frame:SetMovable(true)
    frame:EnableMouse(not settings.is_locked)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", addon_data.hunter_shot_castbar.OnFrameDragStart)
    frame:SetScript("OnDragStop", addon_data.hunter_shot_castbar.OnFrameDragStop)
    -- Create the backplane
    frame.backplane = CreateFrame("Frame", addon_name .. "CastbarBackdropFrame", frame)
    frame.backplane:SetPoint('TOPLEFT', -9, 9)
    frame.backplane:SetPoint('BOTTOMRIGHT', 9, -9)
    frame.backplane:SetFrameStrata('BACKGROUND')

    -- Create the range spell shot bar
    frame.spell_bar = frame:CreateTexture(nil,"ARTWORK")
    -- Create the spell bar text
    frame.spell_bar_text = frame:CreateFontString(nil,"OVERLAY")
    frame.spell_bar_text:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize)
    frame.spell_bar_text:SetJustifyV("CENTER")
    frame.spell_bar_text:SetJustifyH("CENTER")
    -- Create the spell spark
    frame.spell_spark = frame:CreateTexture(nil,"OVERLAY")
    addon_data.utils.SetTextureFile(frame.spell_spark, 'Interface/AddOns/WeaponSwingTimer/Images/Spark')
    -- Create the range spell shot bar center text
    frame.spell_text_center = frame:CreateFontString(nil,"OVERLAY")
    frame.spell_text_center:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize)
    frame.spell_text_center:SetTextColor(1, 1, 1, 1)
    frame.spell_text_center:SetJustifyV("CENTER")
    frame.spell_text_center:SetJustifyH("LEFT")
    -- Create the latency bar
    frame.cast_latency = frame:CreateTexture(nil,"OVERLAY")
    -- Show it off
    addon_data.hunter_shot_castbar.UpdateVisualsOnSettingsChange()
    addon_data.hunter_shot_castbar.UpdateVisualsOnUpdate()
    frame:Show()
end
