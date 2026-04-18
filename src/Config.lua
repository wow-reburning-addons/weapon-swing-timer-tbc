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
local bliz_bridge_app_name = addon_name .. "_BlizBridge"

addon_data.config = {}

local function RefreshAllVisuals()
    addon_data.core.UpdateAllVisualsOnSettingsChange()
end

local function SetAllBarsLocked(is_locked)
    character_player_settings.is_locked = is_locked
    character_target_settings.is_locked = is_locked
    character_hunter_settings.is_locked = is_locked
    character_castbar_settings.is_locked = is_locked

    if addon_data.player and addon_data.player.frame then
        addon_data.player.frame:EnableMouse(not is_locked)
    end
    if addon_data.target and addon_data.target.frame then
        addon_data.target.frame:EnableMouse(not is_locked)
    end
    if addon_data.hunter and addon_data.hunter.frame then
        addon_data.hunter.frame:EnableMouse(not is_locked)
    end
    if addon_data.castbar and addon_data.castbar.frame then
        addon_data.castbar.frame:EnableMouse(not is_locked)
    end

    RefreshAllVisuals()
end

local function MakeToggle(settings_table, setting_key, text_key, desc_key)
    return {
        type = "toggle",
        name = L[text_key],
        desc = desc_key and L[desc_key] or nil,
        get = function()
            return settings_table[setting_key]
        end,
        set = function(_, value)
            settings_table[setting_key] = value
            RefreshAllVisuals()
        end,
    }
end

local function MakeRange(settings_table, setting_key, text_key, min_val, max_val, step_val)
    return {
        type = "range",
        name = L[text_key],
        min = min_val,
        max = max_val,
        step = step_val,
        get = function()
            return settings_table[setting_key]
        end,
        set = function(_, value)
            settings_table[setting_key] = value
            RefreshAllVisuals()
        end,
    }
end

local function MakeColor(settings_table, r_key, g_key, b_key, a_key, text_key)
    return {
        type = "color",
        name = L[text_key],
        hasAlpha = true,
        get = function()
            return settings_table[r_key], settings_table[g_key], settings_table[b_key], settings_table[a_key]
        end,
        set = function(_, r, g, b, a)
            settings_table[r_key] = r
            settings_table[g_key] = g
            settings_table[b_key] = b
            settings_table[a_key] = a
            RefreshAllVisuals()
        end,
    }
end

local function BuildOptionsTable()
    return {
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
                    enabled = MakeToggle(character_player_settings, "enabled", "config.common.enable.label", "config.player.enable.desc"),
                    show_offhand = MakeToggle(character_player_settings, "show_offhand", "config.common.show_offhand.label", "config.player.show_offhand.desc"),
                    show_border = MakeToggle(character_player_settings, "show_border", "config.common.show_border.label", "config.player.show_border.desc"),
                    classic_bars = MakeToggle(character_player_settings, "classic_bars", "config.common.classic_bars.label", "config.player.classic_bars.desc"),
                    show_left_text = MakeToggle(character_player_settings, "show_left_text", "config.common.show_left_text.label", "config.player.show_left_text.desc"),
                    show_right_text = MakeToggle(character_player_settings, "show_right_text", "config.common.show_right_text.label", "config.player.show_right_text.desc"),
                    fill_empty = MakeToggle(character_player_settings, "fill_empty", "config.common.fill_empty.label", "config.common.fill_empty.desc"),
                    width = MakeRange(character_player_settings, "width", "config.common.bar_width.label", 100, 500, 1),
                    height = MakeRange(character_player_settings, "height", "config.common.bar_height.label", 6, 40, 1),
                    fontsize = MakeRange(character_player_settings, "fontsize", "config.common.font_size.label", 6, 32, 1),
                    x_offset = MakeRange(character_player_settings, "x_offset", "config.common.x_offset.label", -600, 600, 1),
                    y_offset = MakeRange(character_player_settings, "y_offset", "config.common.y_offset.label", -600, 600, 1),
                    main_color = MakeColor(character_player_settings, "main_r", "main_g", "main_b", "main_a", "config.common.main_bar_color.label"),
                    main_text_color = MakeColor(character_player_settings, "main_text_r", "main_text_g", "main_text_b", "main_text_a", "config.common.main_text_color.label"),
                    off_color = MakeColor(character_player_settings, "off_r", "off_g", "off_b", "off_a", "config.common.off_bar_color.label"),
                    off_text_color = MakeColor(character_player_settings, "off_text_r", "off_text_g", "off_text_b", "off_text_a", "config.common.off_text_color.label"),
                    in_combat_alpha = MakeRange(character_player_settings, "in_combat_alpha", "config.common.in_combat_alpha.label", 0, 1, 0.01),
                    ooc_alpha = MakeRange(character_player_settings, "ooc_alpha", "config.common.out_of_combat_alpha.label", 0, 1, 0.01),
                    backplane_alpha = MakeRange(character_player_settings, "backplane_alpha", "config.common.backplane_alpha.label", 0, 1, 0.01),
                },
            },
            target = {
                type = "group",
                name = L["config.target.title"],
                order = 3,
                args = {
                    enabled = MakeToggle(character_target_settings, "enabled", "config.common.enable.label", "config.target.enable.desc"),
                    show_offhand = MakeToggle(character_target_settings, "show_offhand", "config.common.show_offhand.label", "config.target.show_offhand.desc"),
                    show_border = MakeToggle(character_target_settings, "show_border", "config.common.show_border.label", "config.target.show_border.desc"),
                    classic_bars = MakeToggle(character_target_settings, "classic_bars", "config.common.classic_bars.label", "config.target.classic_bars.desc"),
                    show_left_text = MakeToggle(character_target_settings, "show_left_text", "config.common.show_left_text.label", "config.target.show_left_text.desc"),
                    show_right_text = MakeToggle(character_target_settings, "show_right_text", "config.common.show_right_text.label", "config.target.show_right_text.desc"),
                    fill_empty = MakeToggle(character_target_settings, "fill_empty", "config.common.fill_empty.label", "config.common.fill_empty.desc"),
                    width = MakeRange(character_target_settings, "width", "config.common.bar_width.label", 100, 500, 1),
                    height = MakeRange(character_target_settings, "height", "config.common.bar_height.label", 6, 40, 1),
                    fontsize = MakeRange(character_target_settings, "fontsize", "config.common.font_size.label", 6, 32, 1),
                    x_offset = MakeRange(character_target_settings, "x_offset", "config.common.x_offset.label", -600, 600, 1),
                    y_offset = MakeRange(character_target_settings, "y_offset", "config.common.y_offset.label", -600, 600, 1),
                    main_color = MakeColor(character_target_settings, "main_r", "main_g", "main_b", "main_a", "config.common.main_bar_color.label"),
                    main_text_color = MakeColor(character_target_settings, "main_text_r", "main_text_g", "main_text_b", "main_text_a", "config.common.main_text_color.label"),
                    off_color = MakeColor(character_target_settings, "off_r", "off_g", "off_b", "off_a", "config.common.off_bar_color.label"),
                    off_text_color = MakeColor(character_target_settings, "off_text_r", "off_text_g", "off_text_b", "off_text_a", "config.common.off_text_color.label"),
                    in_combat_alpha = MakeRange(character_target_settings, "in_combat_alpha", "config.common.in_combat_alpha.label", 0, 1, 0.01),
                    ooc_alpha = MakeRange(character_target_settings, "ooc_alpha", "config.common.out_of_combat_alpha.label", 0, 1, 0.01),
                    backplane_alpha = MakeRange(character_target_settings, "backplane_alpha", "config.common.backplane_alpha.label", 0, 1, 0.01),
                },
            },
            hunter_shot = {
                type = "group",
                name = L["config.hunter.shot.title"],
                order = 4,
                args = {
                    enabled = MakeToggle(character_hunter_settings, "enabled", "config.common.enable.label", nil),
                    one_bar = MakeToggle(character_hunter_settings, "one_bar", "config.hunter.one_bar.label", "config.hunter.one_bar.desc"),
                    show_multishot_clip_bar = MakeToggle(character_hunter_settings, "show_multishot_clip_bar", "config.hunter.multishot_clip_bar.label", "config.hunter.multishot_clip_bar.desc"),
                    show_autoshot_delay_timer = MakeToggle(character_hunter_settings, "show_autoshot_delay_timer", "config.hunter.autoshot_delay_timer.label", "config.hunter.autoshot_delay_timer.desc"),
                    show_text = MakeToggle(character_hunter_settings, "show_text", "config.hunter.show_text.label", "config.hunter.show_text.desc"),
                    show_border = MakeToggle(character_hunter_settings, "show_border", "config.common.show_border.label", nil),
                    classic_bars = MakeToggle(character_hunter_settings, "classic_bars", "config.common.classic_bars.label", nil),
                    width = MakeRange(character_hunter_settings, "width", "config.common.bar_width.label", 100, 500, 1),
                    height = MakeRange(character_hunter_settings, "height", "config.common.bar_height.label", 6, 40, 1),
                    fontsize = MakeRange(character_hunter_settings, "fontsize", "config.common.font_size.label", 6, 32, 1),
                    x_offset = MakeRange(character_hunter_settings, "x_offset", "config.common.x_offset.label", -600, 600, 1),
                    y_offset = MakeRange(character_hunter_settings, "y_offset", "config.common.y_offset.label", -600, 600, 1),
                    cooldown_color = MakeColor(character_hunter_settings, "cooldown_r", "cooldown_g", "cooldown_b", "cooldown_a", "config.hunter.cooldown_color.label"),
                    auto_cast_color = MakeColor(character_hunter_settings, "auto_cast_r", "auto_cast_g", "auto_cast_b", "auto_cast_a", "config.hunter.auto_cast_color.label"),
                    multishot_clip_color = MakeColor(character_hunter_settings, "clip_r", "clip_g", "clip_b", "clip_a", "config.hunter.multishot_clip_color.label"),
                    in_combat_alpha = MakeRange(character_hunter_settings, "in_combat_alpha", "config.common.in_combat_alpha.label", 0, 1, 0.01),
                    ooc_alpha = MakeRange(character_hunter_settings, "ooc_alpha", "config.common.out_of_combat_alpha.label", 0, 1, 0.01),
                    backplane_alpha = MakeRange(character_hunter_settings, "backplane_alpha", "config.common.backplane_alpha.label", 0, 1, 0.01),
                },
            },
            hunter_castbar = {
                type = "group",
                name = L["config.hunter.specific.title"],
                order = 5,
                args = {
                    enabled = MakeToggle(character_castbar_settings, "enabled", "config.common.enable.label", nil),
                    show_aimedshot_cast_bar = MakeToggle(character_castbar_settings, "show_aimedshot_cast_bar", "config.castbar.aimed_shot.label", "config.castbar.aimed_shot.desc"),
                    show_multishot_cast_bar = MakeToggle(character_castbar_settings, "show_multishot_cast_bar", "config.castbar.multi_shot.label", "config.castbar.multi_shot.desc"),
                    show_latency_bars = MakeToggle(character_castbar_settings, "show_latency_bars", "config.castbar.latency.label", "config.castbar.latency.desc"),
                    show_cast_text = MakeToggle(character_castbar_settings, "show_cast_text", "config.castbar.show_cast_text.label", "config.castbar.show_cast_text.desc"),
                    width = MakeRange(character_castbar_settings, "width", "config.common.bar_width.label", 100, 500, 1),
                    height = MakeRange(character_castbar_settings, "height", "config.common.bar_height.label", 6, 40, 1),
                    fontsize = MakeRange(character_castbar_settings, "fontsize", "config.common.font_size.label", 6, 32, 1),
                    x_offset = MakeRange(character_castbar_settings, "x_offset", "config.common.x_offset.label", -600, 600, 1),
                    y_offset = MakeRange(character_castbar_settings, "y_offset", "config.common.y_offset.label", -600, 600, 1),
                    in_combat_alpha = MakeRange(character_castbar_settings, "in_combat_alpha", "config.common.in_combat_alpha.label", 0, 1, 0.01),
                    backplane_alpha = MakeRange(character_castbar_settings, "backplane_alpha", "config.common.backplane_alpha.label", 0, 1, 0.01),
                },
            },
        },
    }
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
