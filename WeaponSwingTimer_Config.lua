local addon_name, addon_data = ...
if not addon_data then
    addon_name = "WeaponSwingTimer"
    addon_data = _G.WeaponSwingTimer_AddonData
    if not addon_data then
        addon_data = {}
        _G.WeaponSwingTimer_AddonData = addon_data
    end
else
    _G.WeaponSwingTimer_AddonData = addon_data
end

local L = addon_data.localization_table
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

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

local function BuildOptionsTable()
    return {
        type = "group",
        name = addon_name,
        childGroups = "tab",
        args = {
            global = {
                type = "group",
                name = L["Global Bar Settings"],
                order = 1,
                args = {
                    lock_all = {
                        type = "toggle",
                        name = L[" Lock All Bars"],
                        desc = L["Locks all of the swing bar frames, preventing them from being dragged."],
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
                        name = L[" Welcome Message"],
                        desc = L["Displays the welcome message upon login/reload. Uncheck to disable."],
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
                        name = L["Reset Settings"],
                        order = 99,
                        func = function()
                            addon_data.core.RestoreAllDefaults()
                            SetAllBarsLocked(character_player_settings.is_locked)
                            RefreshAllVisuals()
                        end,
                    },
                },
            },
            melee = {
                type = "group",
                name = L["Melee Settings"],
                order = 2,
                childGroups = "tab",
                args = {
                    player = {
                        type = "group",
                        name = L["Player Swing Bar Settings"],
                        order = 1,
                        args = {
                            enabled = MakeToggle(character_player_settings, "enabled", "Enable", "Enables the player's swing bars."),
                            show_offhand = MakeToggle(character_player_settings, "show_offhand", "Show Off-Hand", "Enables the player's off-hand swing bar."),
                            show_border = MakeToggle(character_player_settings, "show_border", "Show border", "Enables the player bar's border."),
                            classic_bars = MakeToggle(character_player_settings, "classic_bars", "Classic bars", "Enables the classic texture for the player's bars."),
                            show_left_text = MakeToggle(character_player_settings, "show_left_text", "Show Left Text", "Enables the player's left side text."),
                            show_right_text = MakeToggle(character_player_settings, "show_right_text", "Show Right Text", "Enables the player's right side text."),
                            fill_empty = MakeToggle(character_player_settings, "fill_empty", "Fill / Empty", "Determines if the bar is full or empty when a swing is ready."),
                            width = MakeRange(character_player_settings, "width", "Bar Width", 100, 500, 1),
                            height = MakeRange(character_player_settings, "height", "Bar Height", 6, 40, 1),
                            x_offset = MakeRange(character_player_settings, "x_offset", "X Offset", -600, 600, 1),
                            y_offset = MakeRange(character_player_settings, "y_offset", "Y Offset", -600, 600, 1),
                            in_combat_alpha = MakeRange(character_player_settings, "in_combat_alpha", "In Combat Alpha", 0, 1, 0.01),
                            ooc_alpha = MakeRange(character_player_settings, "ooc_alpha", "Out of Combat Alpha", 0, 1, 0.01),
                            backplane_alpha = MakeRange(character_player_settings, "backplane_alpha", "Backplane Alpha", 0, 1, 0.01),
                        },
                    },
                    target = {
                        type = "group",
                        name = L["Target Swing Bar Settings"],
                        order = 2,
                        args = {
                            enabled = MakeToggle(character_target_settings, "enabled", "Enable", "Enables the target's swing bars."),
                            show_offhand = MakeToggle(character_target_settings, "show_offhand", "Show Off-Hand", "Enables the target's off-hand swing bar."),
                            show_border = MakeToggle(character_target_settings, "show_border", "Show border", "Enables the target bar's border."),
                            classic_bars = MakeToggle(character_target_settings, "classic_bars", "Classic bars", "Enables the classic texture for the target's bars."),
                            show_left_text = MakeToggle(character_target_settings, "show_left_text", "Show Left Text", "Enables the target's left side text."),
                            show_right_text = MakeToggle(character_target_settings, "show_right_text", "Show Right Text", "Enables the target's right side text."),
                            fill_empty = MakeToggle(character_target_settings, "fill_empty", "Fill / Empty", "Determines if the bar is full or empty when a swing is ready."),
                            width = MakeRange(character_target_settings, "width", "Bar Width", 100, 500, 1),
                            height = MakeRange(character_target_settings, "height", "Bar Height", 6, 40, 1),
                            x_offset = MakeRange(character_target_settings, "x_offset", "X Offset", -600, 600, 1),
                            y_offset = MakeRange(character_target_settings, "y_offset", "Y Offset", -600, 600, 1),
                            in_combat_alpha = MakeRange(character_target_settings, "in_combat_alpha", "In Combat Alpha", 0, 1, 0.01),
                            ooc_alpha = MakeRange(character_target_settings, "ooc_alpha", "Out of Combat Alpha", 0, 1, 0.01),
                            backplane_alpha = MakeRange(character_target_settings, "backplane_alpha", "Backplane Alpha", 0, 1, 0.01),
                        },
                    },
                },
            },
            hunter = {
                type = "group",
                name = L["Hunter & Wand Settings"],
                order = 3,
                childGroups = "tab",
                args = {
                    shot = {
                        type = "group",
                        name = L["Hunter & Wand Shot Bar Settings"],
                        order = 1,
                        args = {
                            enabled = MakeToggle(character_hunter_settings, "enabled", "Enable", nil),
                            one_bar = MakeToggle(character_hunter_settings, "one_bar", "YaHT / One bar", "Changes the Auto Shot bar to a single bar that fills from left to right"),
                            show_multishot_clip_bar = MakeToggle(character_hunter_settings, "show_multishot_clip_bar", "Multi-Shot clip bar", "Shows a bar that represents when a Multi-Shot would clip an Auto Shot."),
                            show_autoshot_delay_timer = MakeToggle(character_hunter_settings, "show_autoshot_delay_timer", "Auto Shot delay timer", "Shows a timer that represents when Auto shot is delayed."),
                            show_text = MakeToggle(character_hunter_settings, "show_text", "Show Text", "Enables the shot bar text."),
                            show_border = MakeToggle(character_hunter_settings, "show_border", "Show border", nil),
                            classic_bars = MakeToggle(character_hunter_settings, "classic_bars", "Classic bars", nil),
                            width = MakeRange(character_hunter_settings, "width", "Bar Width", 100, 500, 1),
                            height = MakeRange(character_hunter_settings, "height", "Bar Height", 6, 40, 1),
                            x_offset = MakeRange(character_hunter_settings, "x_offset", "X Offset", -600, 600, 1),
                            y_offset = MakeRange(character_hunter_settings, "y_offset", "Y Offset", -600, 600, 1),
                            in_combat_alpha = MakeRange(character_hunter_settings, "in_combat_alpha", "In Combat Alpha", 0, 1, 0.01),
                            ooc_alpha = MakeRange(character_hunter_settings, "ooc_alpha", "Out of Combat Alpha", 0, 1, 0.01),
                            backplane_alpha = MakeRange(character_hunter_settings, "backplane_alpha", "Backplane Alpha", 0, 1, 0.01),
                        },
                    },
                    castbar = {
                        type = "group",
                        name = L["Hunter Specific Settings"],
                        order = 2,
                        args = {
                            enabled = MakeToggle(character_castbar_settings, "enabled", "Enable", nil),
                            show_aimedshot_cast_bar = MakeToggle(character_castbar_settings, "show_aimedshot_cast_bar", "Aimed Shot cast bar", "Allows the cast bar to show Aimed Shot casts."),
                            show_multishot_cast_bar = MakeToggle(character_castbar_settings, "show_multishot_cast_bar", "Multi-Shot cast bar", "Allows the cast bar to show Multi-Shot casts."),
                            show_latency_bars = MakeToggle(character_castbar_settings, "show_latency_bars", "Latency bar", "Shows a bar that represents latency on cast bar."),
                            show_cast_text = MakeToggle(character_castbar_settings, "show_cast_text", "Show Cast Text", "Enables the cast bar text."),
                            width = MakeRange(character_castbar_settings, "width", "Bar Width", 100, 500, 1),
                            height = MakeRange(character_castbar_settings, "height", "Bar Height", 6, 40, 1),
                            x_offset = MakeRange(character_castbar_settings, "x_offset", "X Offset", -600, 600, 1),
                            y_offset = MakeRange(character_castbar_settings, "y_offset", "Y Offset", -600, 600, 1),
                            in_combat_alpha = MakeRange(character_castbar_settings, "in_combat_alpha", "In Combat Alpha", 0, 1, 0.01),
                            backplane_alpha = MakeRange(character_castbar_settings, "backplane_alpha", "Backplane Alpha", 0, 1, 0.01),
                        },
                    },
                },
            },
        },
    }
end

addon_data.config.InitializeAceConfig = function()
    local options = BuildOptionsTable()
    AceConfig:RegisterOptionsTable(addon_name, options)
    addon_data.config.config_parent_panel = AceConfigDialog:AddToBlizOptions(addon_name, addon_name)
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

addon_data.config.TextFactory = function(parent, text, size)
    local text_obj = parent:CreateFontString(nil, "ARTWORK")
    text_obj:SetFont("Fonts/FRIZQT__.ttf", size)
    text_obj:SetJustifyV("CENTER")
    text_obj:SetJustifyH("CENTER")
    text_obj:SetText(text)
    return text_obj
end

addon_data.config.CheckBoxFactory = function(g_name, parent, checkbtn_text, tooltip_text, on_click_func)
    local checkbox = CreateFrame("CheckButton", addon_name .. g_name, parent, "ChatConfigCheckButtonTemplate")
    getglobal(checkbox:GetName() .. 'Text'):SetText(checkbtn_text)
    checkbox.tooltip = tooltip_text
    checkbox:SetScript("OnClick", function(self)
        on_click_func(self)
    end)
    checkbox:SetScale(1.1)
    return checkbox
end

addon_data.config.EditBoxFactory = function(g_name, parent, title, w, h, enter_func)
    local edit_box_obj = CreateFrame("EditBox", addon_name .. g_name, parent)
    edit_box_obj.title_text = addon_data.config.TextFactory(edit_box_obj, title, 12)
    edit_box_obj.title_text:SetPoint("TOP", 0, 12)
    edit_box_obj:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 26,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4}
    })
    edit_box_obj:SetBackdropColor(0,0,0,1)
    edit_box_obj:SetSize(w, h)
    edit_box_obj:SetMultiLine(false)
    edit_box_obj:SetAutoFocus(false)
    edit_box_obj:SetMaxLetters(4)
    edit_box_obj:SetJustifyH("CENTER")
	edit_box_obj:SetJustifyV("CENTER")
    edit_box_obj:SetFontObject(GameFontNormal)
    edit_box_obj:SetScript("OnEnterPressed", function(self)
        enter_func(self)
        self:ClearFocus()
    end)
    edit_box_obj:SetScript("OnTextChanged", function(self)
        if self:GetText() ~= "" then
            enter_func(self)
        end
    end)
    edit_box_obj:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    return edit_box_obj
end

addon_data.config.SliderFactory = function(g_name, parent, title, min_val, max_val, val_step, func)
    local slider = CreateFrame("Slider", addon_name .. g_name, parent, "OptionsSliderTemplate")
    local editbox = CreateFrame("EditBox", "$parentEditBox", slider, "InputBoxTemplate")
    slider:SetMinMaxValues(min_val, max_val)
    slider:SetValueStep(val_step)
    slider.text = _G[addon_name .. g_name .. "Text"]
    slider.text:SetText(title)
    slider.textLow = _G[addon_name .. g_name .. "Low"]
    slider.textHigh = _G[addon_name .. g_name .. "High"]
    slider.textLow:SetText(floor(min_val))
    slider.textHigh:SetText(floor(max_val))
    slider.textLow:SetTextColor(0.8,0.8,0.8)
    slider.textHigh:SetTextColor(0.8,0.8,0.8)
    if slider.SetObeyStepOnDrag then
        slider:SetObeyStepOnDrag(true)
    end
    editbox:SetSize(45,30)
    editbox:ClearAllPoints()
    editbox:SetPoint("LEFT", slider, "RIGHT", 15, 0)
    editbox:SetText(slider:GetValue())
    editbox:SetAutoFocus(false)
    slider:SetScript("OnValueChanged", function(self)
        editbox:SetText(tostring(addon_data.utils.SimpleRound(self:GetValue(), val_step)))
        func(self)
    end)
    editbox:SetScript("OnTextChanged", function(self)
        local val = self:GetText()
        if tonumber(val) then
            self:GetParent():SetValue(val)
        end
    end)
    editbox:SetScript("OnEnterPressed", function(self)
        local val = self:GetText()
        if tonumber(val) then
            self:GetParent():SetValue(val)
            self:ClearFocus()
        end
    end)
    slider.editbox = editbox
    return slider
end

addon_data.config.color_picker_factory = function(g_name, parent, r, g, b, a, text, on_click_func)
    local color_picker = CreateFrame('Button', addon_name .. g_name, parent)
    color_picker:SetSize(15, 15)
    color_picker.normal = color_picker:CreateTexture(nil, 'BACKGROUND')
    addon_data.utils.SetTextureColor(color_picker.normal, 1, 1, 1, 1)
    color_picker.normal:SetPoint('TOPLEFT', -1, 1)
    color_picker.normal:SetPoint('BOTTOMRIGHT', 1, -1)
    color_picker.foreground = color_picker:CreateTexture(nil, 'ARTWORK')
    addon_data.utils.SetTextureColor(color_picker.foreground, r, g, b, a)
    color_picker.foreground:SetAllPoints()
    color_picker:SetNormalTexture(color_picker.foreground)
    color_picker:SetScript('OnClick', on_click_func)
    color_picker.text = addon_data.config.TextFactory(color_picker, text, 12)
    color_picker.text:SetPoint('LEFT', 25, 0)
    return color_picker
end

addon_data.config.UpdateConfigValues = function()
    local panel = addon_data.config.config_frame
    if not panel then
        return
    end
    local settings = character_player_settings
    local settings_core = character_core_settings

    panel.is_locked_checkbox:SetChecked(settings.is_locked)
	panel.welcome_checkbox:SetChecked(settings_core.welcome_message)
end

addon_data.config.IsLockedCheckBoxOnClick = function(self)
    character_player_settings.is_locked = self:GetChecked()
    character_target_settings.is_locked = self:GetChecked()
    character_hunter_settings.is_locked = self:GetChecked()
    character_castbar_settings.is_locked = self:GetChecked()
    addon_data.player.frame:EnableMouse(not character_target_settings.is_locked)
    addon_data.target.frame:EnableMouse(not character_target_settings.is_locked)
    addon_data.hunter.frame:EnableMouse(not character_target_settings.is_locked)
    addon_data.castbar.frame:EnableMouse(not character_target_settings.is_locked)
    addon_data.core.UpdateAllVisualsOnSettingsChange()
end

addon_data.config.WelcomeCheckBoxOnClick = function(self)
	character_core_settings.welcome_message = self:GetChecked()
    addon_data.core.UpdateAllVisualsOnSettingsChange()
end

addon_data.config.CreateConfigPanel = function(parent_panel)
    addon_data.config.config_frame = CreateFrame("Frame", addon_name .. "GlobalConfigPanel", parent_panel)
    local panel = addon_data.config.config_frame
    local settings = character_player_settings
    -- Title Text
    panel.title_text = addon_data.config.TextFactory(panel, L["Global Bar Settings"], 20)
    panel.title_text:SetPoint("TOPLEFT", 0, 0)
    panel.title_text:SetTextColor(1, 0.9, 0, 1)
    
    -- Is Locked Checkbox
    panel.is_locked_checkbox = addon_data.config.CheckBoxFactory(
        "IsLockedCheckBox",
        panel,
        L[" Lock All Bars"],
        L["Locks all of the swing bar frames, preventing them from being dragged."],
        addon_data.config.IsLockedCheckBoxOnClick)
    panel.is_locked_checkbox:SetPoint("TOPLEFT", 0, -30)
	    -- Is Locked Checkbox
    panel.welcome_checkbox = addon_data.config.CheckBoxFactory(
        "WelcomeCheckBox",
        panel,
        L[" Welcome Message"],
        L["Displays the welcome message upon login/reload. Uncheck to disable."],
        addon_data.config.WelcomeCheckBoxOnClick)
    panel.welcome_checkbox:SetPoint("TOPLEFT", 0, -80)
    
    -- Return the final panel
    addon_data.config.UpdateConfigValues()
    return panel
end
