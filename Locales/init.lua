local addon_name = "WeaponSwingTimer"
local addon_data = _G.WeaponSwingTimer_AddonData
if not addon_data then
    addon_data = {}
    _G.WeaponSwingTimer_AddonData = addon_data
end

addon_data.locale = LibStub("AceLocale-3.0")

if not addon_data.localization_table then
    addon_data.localization_table = setmetatable({}, {
        __index = function(_, key)
            return key
        end,
    })
end

_G.WeaponSwingTimer_LocalizationTable = addon_data.localization_table
