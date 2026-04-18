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
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local bliz_bridge_app_name = addon_name .. "_BlizBridge"

addon_data.config = {}

local function RefreshAllVisuals()
    addon_data.core.UpdateAllVisualsOnSettingsChange()
end

local function SetAllBarsLocked(is_locked)
    character_player_settings.is_locked = is_locked
    character_target_settings.is_locked = is_locked
    character_hunter_autoshot_settings.is_locked = is_locked
    character_hunter_shot_castbar_settings.is_locked = is_locked

    if addon_data.player and addon_data.player.frame then
        addon_data.player.frame:EnableMouse(not is_locked)
    end
    if addon_data.target and addon_data.target.frame then
        addon_data.target.frame:EnableMouse(not is_locked)
    end
    if addon_data.hunter_autoshot and addon_data.hunter_autoshot.frame then
        addon_data.hunter_autoshot.frame:EnableMouse(not is_locked)
    end
    if addon_data.hunter_shot_castbar and addon_data.hunter_shot_castbar.frame then
        addon_data.hunter_shot_castbar.frame:EnableMouse(not is_locked)
    end

    RefreshAllVisuals()
end

local function GetSettingsTable(scope_key)
    if scope_key == "core" then
        return character_core_settings
    elseif scope_key == "player" then
        return character_player_settings
    elseif scope_key == "target" then
        return character_target_settings
    elseif scope_key == "hunter_autoshot" then
        return character_hunter_autoshot_settings
    elseif scope_key == "hunter_shot_castbar" then
        return character_hunter_shot_castbar_settings
    end

    return nil
end

local function MakeToggle(scope_key, setting_key, text_key, desc_key)
    return {
        type = "toggle",
        name = L[text_key],
        desc = desc_key and L[desc_key] or nil,
        get = function()
            local settings_table = GetSettingsTable(scope_key)
            if not settings_table then
                return false
            end
            return settings_table[setting_key]
        end,
        set = function(_, value)
            local settings_table = GetSettingsTable(scope_key)
            if not settings_table then
                return
            end
            settings_table[setting_key] = value
            RefreshAllVisuals()
        end,
    }
end

local function MakeRange(scope_key, setting_key, text_key, min_val, max_val, step_val)
    return {
        type = "range",
        name = L[text_key],
        min = min_val,
        max = max_val,
        step = step_val,
        get = function()
            local settings_table = GetSettingsTable(scope_key)
            if not settings_table then
                return min_val
            end
            return settings_table[setting_key]
        end,
        set = function(_, value)
            local settings_table = GetSettingsTable(scope_key)
            if not settings_table then
                return
            end
            settings_table[setting_key] = value
            RefreshAllVisuals()
        end,
    }
end

local function MakeColor(scope_key, r_key, g_key, b_key, a_key, text_key)
    return {
        type = "color",
        name = L[text_key],
        hasAlpha = true,
        get = function()
            local settings_table = GetSettingsTable(scope_key)
            if not settings_table then
                return 1, 1, 1, 1
            end
            return settings_table[r_key], settings_table[g_key], settings_table[b_key], settings_table[a_key]
        end,
        set = function(_, r, g, b, a)
            local settings_table = GetSettingsTable(scope_key)
            if not settings_table then
                return
            end
            settings_table[r_key] = r
            settings_table[g_key] = g
            settings_table[b_key] = b
            settings_table[a_key] = a
            RefreshAllVisuals()
        end,
    }
end

local function BuildOptionsTable()
    local options = {
        type = "group",
        name = addon_name,
        args = {
            global = {
                type = "group",
                name = L["config.global.title"],
                order = 1,
                args = {
                    lock_all = {
                        type = "toggle",
                        name = L["config.global.lock_all.label"],
                        desc = L["config.global.lock_all.desc"],
                        order = 1,
                        get = function()
                            return character_player_settings.is_locked
                        end,
                        set = function(_, value)
                            SetAllBarsLocked(value)
                        end,
                    },
                    welcome_message = {
                        type = "toggle",
                        name = L["config.global.welcome_message.label"],
                        desc = L["config.global.welcome_message.desc"],
                        order = 2,
                        get = function()
                            return character_core_settings.welcome_message
                        end,
                        set = function(_, value)
                            character_core_settings.welcome_message = value
                            RefreshAllVisuals()
                        end,
                    },
                    reset_defaults = {
                        type = "execute",
                        name = L["config.global.reset_settings"],
                        order = 99,
                        func = function()
                            addon_data.core.RestoreAllDefaults()
                            SetAllBarsLocked(character_player_settings.is_locked)
                            RefreshAllVisuals()
                        end,
                    },
                },
            },
            player = {
                type = "group",
                name = L["config.player.title"],
                order = 2,
                args = {
                    enabled = MakeToggle("player", "enabled", "config.common.enable.label", "config.player.enable.desc"),
                    show_offhand = MakeToggle("player", "show_offhand", "config.common.show_offhand.label", "config.player.show_offhand.desc"),
                    show_border = MakeToggle("player", "show_border", "config.common.show_border.label", "config.player.show_border.desc"),
                    classic_bars = MakeToggle("player", "classic_bars", "config.common.classic_bars.label", "config.player.classic_bars.desc"),
                    show_left_text = MakeToggle("player", "show_left_text", "config.common.show_left_text.label", "config.player.show_left_text.desc"),
                    show_right_text = MakeToggle("player", "show_right_text", "config.common.show_right_text.label", "config.player.show_right_text.desc"),
                    fill_empty = MakeToggle("player", "fill_empty", "config.common.fill_empty.label", "config.common.fill_empty.desc"),
                    width = MakeRange("player", "width", "config.common.bar_width.label", 100, 500, 1),
                    height = MakeRange("player", "height", "config.common.bar_height.label", 6, 40, 1),
                    fontsize = MakeRange("player", "fontsize", "config.common.font_size.label", 6, 32, 1),
                    x_offset = MakeRange("player", "x_offset", "config.common.x_offset.label", -600, 600, 1),
                    y_offset = MakeRange("player", "y_offset", "config.common.y_offset.label", -600, 600, 1),
                    main_color = MakeColor("player", "main_r", "main_g", "main_b", "main_a", "config.common.main_bar_color.label"),
                    main_text_color = MakeColor("player", "main_text_r", "main_text_g", "main_text_b", "main_text_a", "config.common.main_text_color.label"),
                    off_color = MakeColor("player", "off_r", "off_g", "off_b", "off_a", "config.common.off_bar_color.label"),
                    off_text_color = MakeColor("player", "off_text_r", "off_text_g", "off_text_b", "off_text_a", "config.common.off_text_color.label"),
                    in_combat_alpha = MakeRange("player", "in_combat_alpha", "config.common.in_combat_alpha.label", 0, 1, 0.01),
                    ooc_alpha = MakeRange("player", "ooc_alpha", "config.common.out_of_combat_alpha.label", 0, 1, 0.01),
                    backplane_alpha = MakeRange("player", "backplane_alpha", "config.common.backplane_alpha.label", 0, 1, 0.01),
                },
            },
            target = {
                type = "group",
                name = L["config.target.title"],
                order = 3,
                args = {
                    enabled = MakeToggle("target", "enabled", "config.common.enable.label", "config.target.enable.desc"),
                    show_offhand = MakeToggle("target", "show_offhand", "config.common.show_offhand.label", "config.target.show_offhand.desc"),
                    show_border = MakeToggle("target", "show_border", "config.common.show_border.label", "config.target.show_border.desc"),
                    classic_bars = MakeToggle("target", "classic_bars", "config.common.classic_bars.label", "config.target.classic_bars.desc"),
                    show_left_text = MakeToggle("target", "show_left_text", "config.common.show_left_text.label", "config.target.show_left_text.desc"),
                    show_right_text = MakeToggle("target", "show_right_text", "config.common.show_right_text.label", "config.target.show_right_text.desc"),
                    fill_empty = MakeToggle("target", "fill_empty", "config.common.fill_empty.label", "config.common.fill_empty.desc"),
                    width = MakeRange("target", "width", "config.common.bar_width.label", 100, 500, 1),
                    height = MakeRange("target", "height", "config.common.bar_height.label", 6, 40, 1),
                    fontsize = MakeRange("target", "fontsize", "config.common.font_size.label", 6, 32, 1),
                    x_offset = MakeRange("target", "x_offset", "config.common.x_offset.label", -600, 600, 1),
                    y_offset = MakeRange("target", "y_offset", "config.common.y_offset.label", -600, 600, 1),
                    main_color = MakeColor("target", "main_r", "main_g", "main_b", "main_a", "config.common.main_bar_color.label"),
                    main_text_color = MakeColor("target", "main_text_r", "main_text_g", "main_text_b", "main_text_a", "config.common.main_text_color.label"),
                    off_color = MakeColor("target", "off_r", "off_g", "off_b", "off_a", "config.common.off_bar_color.label"),
                    off_text_color = MakeColor("target", "off_text_r", "off_text_g", "off_text_b", "off_text_a", "config.common.off_text_color.label"),
                    in_combat_alpha = MakeRange("target", "in_combat_alpha", "config.common.in_combat_alpha.label", 0, 1, 0.01),
                    ooc_alpha = MakeRange("target", "ooc_alpha", "config.common.out_of_combat_alpha.label", 0, 1, 0.01),
                    backplane_alpha = MakeRange("target", "backplane_alpha", "config.common.backplane_alpha.label", 0, 1, 0.01),
                },
            },
            hunter_autoshot = {
                type = "group",
                name = L["config.hunter.shot.title"],
                order = 4,
                args = {
                    enabled = MakeToggle("hunter_autoshot", "enabled", "config.common.enable.label", nil),
                    one_bar = MakeToggle("hunter_autoshot", "one_bar", "config.hunter.one_bar.label", "config.hunter.one_bar.desc"),
                    show_multishot_clip_bar = MakeToggle("hunter_autoshot", "show_multishot_clip_bar", "config.hunter.multishot_clip_bar.label", "config.hunter.multishot_clip_bar.desc"),
                    show_autoshot_delay_timer = MakeToggle("hunter_autoshot", "show_autoshot_delay_timer", "config.hunter.autoshot_delay_timer.label", "config.hunter.autoshot_delay_timer.desc"),
                    show_text = MakeToggle("hunter_autoshot", "show_text", "config.hunter.show_text.label", "config.hunter.show_text.desc"),
                    show_border = MakeToggle("hunter_autoshot", "show_border", "config.common.show_border.label", nil),
                    classic_bars = MakeToggle("hunter_autoshot", "classic_bars", "config.common.classic_bars.label", nil),
                    width = MakeRange("hunter_autoshot", "width", "config.common.bar_width.label", 100, 500, 1),
                    height = MakeRange("hunter_autoshot", "height", "config.common.bar_height.label", 6, 40, 1),
                    fontsize = MakeRange("hunter_autoshot", "fontsize", "config.common.font_size.label", 6, 32, 1),
                    x_offset = MakeRange("hunter_autoshot", "x_offset", "config.common.x_offset.label", -600, 600, 1),
                    y_offset = MakeRange("hunter_autoshot", "y_offset", "config.common.y_offset.label", -600, 600, 1),
                    cooldown_color = MakeColor("hunter_autoshot", "cooldown_r", "cooldown_g", "cooldown_b", "cooldown_a", "config.hunter.cooldown_color.label"),
                    auto_cast_color = MakeColor("hunter_autoshot", "auto_cast_r", "auto_cast_g", "auto_cast_b", "auto_cast_a", "config.hunter.auto_cast_color.label"),
                    multishot_clip_color = MakeColor("hunter_autoshot", "clip_r", "clip_g", "clip_b", "clip_a", "config.hunter.multishot_clip_color.label"),
                    in_combat_alpha = MakeRange("hunter_autoshot", "in_combat_alpha", "config.common.in_combat_alpha.label", 0, 1, 0.01),
                    ooc_alpha = MakeRange("hunter_autoshot", "ooc_alpha", "config.common.out_of_combat_alpha.label", 0, 1, 0.01),
                    backplane_alpha = MakeRange("hunter_autoshot", "backplane_alpha", "config.common.backplane_alpha.label", 0, 1, 0.01),
                },
            },
            hunter_shot_castbar = {
                type = "group",
                name = L["config.hunter.specific.title"],
                order = 5,
                args = {
                    enabled = MakeToggle("hunter_shot_castbar", "enabled", "config.common.enable.label", nil),
                    show_aimedshot_cast_bar = MakeToggle("hunter_shot_castbar", "show_aimedshot_cast_bar", "config.spell_shot_bar.aimed_shot.label", "config.spell_shot_bar.aimed_shot.desc"),
                    show_multishot_cast_bar = MakeToggle("hunter_shot_castbar", "show_multishot_cast_bar", "config.spell_shot_bar.multi_shot.label", "config.spell_shot_bar.multi_shot.desc"),
                    show_latency_bars = MakeToggle("hunter_shot_castbar", "show_latency_bars", "config.spell_shot_bar.latency.label", "config.spell_shot_bar.latency.desc"),
                    show_cast_text = MakeToggle("hunter_shot_castbar", "show_cast_text", "config.spell_shot_bar.show_cast_text.label", "config.spell_shot_bar.show_cast_text.desc"),
                    width = MakeRange("hunter_shot_castbar", "width", "config.common.bar_width.label", 100, 500, 1),
                    height = MakeRange("hunter_shot_castbar", "height", "config.common.bar_height.label", 6, 40, 1),
                    fontsize = MakeRange("hunter_shot_castbar", "fontsize", "config.common.font_size.label", 6, 32, 1),
                    x_offset = MakeRange("hunter_shot_castbar", "x_offset", "config.common.x_offset.label", -600, 600, 1),
                    y_offset = MakeRange("hunter_shot_castbar", "y_offset", "config.common.y_offset.label", -600, 600, 1),
                    in_combat_alpha = MakeRange("hunter_shot_castbar", "in_combat_alpha", "config.common.in_combat_alpha.label", 0, 1, 0.01),
                    backplane_alpha = MakeRange("hunter_shot_castbar", "backplane_alpha", "config.common.backplane_alpha.label", 0, 1, 0.01),
                },
            },
        },
    }

    if addon_data.core and addon_data.core.db then
        local profile_options = AceDBOptions:GetOptionsTable(addon_data.core.db)
        profile_options.order = 100
        options.args.profiles = profile_options
    end

    return options
end

local function BuildBlizBridgeOptionsTable()
    return {
        type = "group",
        name = addon_name,
        args = {
            open_standalone = {
                type = "execute",
                name = L["config.bliz_bridge.open.label"],
                desc = L["config.bliz_bridge.open.desc"],
                order = 1,
                func = function()
                    addon_data.config.OpenStandaloneConfig()
                end,
            },
        },
    }
end

addon_data.config.OpenStandaloneConfig = function(...)
    AceConfigDialog:Open(addon_name, ...)
end

addon_data.config.InitializeAceConfig = function()
    local options = BuildOptionsTable()
    AceConfig:RegisterOptionsTable(addon_name, options)

    local bliz_bridge_options = BuildBlizBridgeOptionsTable()
    AceConfig:RegisterOptionsTable(bliz_bridge_app_name, bliz_bridge_options)

    addon_data.config.config_parent_panel = AceConfigDialog:AddToBlizOptions(bliz_bridge_app_name, addon_name)
    addon_data.config.config_panels = nil

    addon_data.config.config_parent_panel.default = addon_data.config.OnDefault
end

addon_data.config.OnDefault = function()
    addon_data.core.RestoreAllDefaults()
    SetAllBarsLocked(character_player_settings.is_locked)
    RefreshAllVisuals()
end

addon_data.config.InitializeVisuals = function()
    addon_data.config.InitializeAceConfig()
end
