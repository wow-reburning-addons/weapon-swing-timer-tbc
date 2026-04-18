local addon_name = "WeaponSwingTimer"
local addon_data = _G.WeaponSwingTimer_AddonData
if not addon_data then
    addon_data = {}
    _G.WeaponSwingTimer_AddonData = addon_data
end

local AceLocale = addon_data.locale or LibStub("AceLocale-3.0")
local L = AceLocale:NewLocale(addon_name, "zhCN")
if not L then
    return
end

local locale_table = AceLocale:GetLocale(addon_name, true)
if locale_table then
    addon_data.localization_table = locale_table
    _G.WeaponSwingTimer_LocalizationTable = locale_table
end

L["core.welcome.version"] = "感谢您安装WeaponSwingTimer版本！"
L["core.welcome.hint"] = "作者：LeftHandedGlove，持续更新：WatchYourSixx，汉化：Cyanokaze。使用|cFFFFC300/wst|r获取更多选项。"

L["config.global.title"] = "全局设定"
L["config.melee.title"] = "近战武器监控"
L["config.hunter_wand.title"] = "远程武器监控"
L["config.global.lock_all.label"] = " 全部锁定"
L["config.global.lock_all.desc"] = "锁定所有进度条和窗口，防止它们被移动。"

L["config.player.title"] = "设置自身武器进度条"
L["config.player.enable.desc"] = "启用主手武器进度条。"
L["config.player.show_offhand.desc"] = "显示副手武器进度条。"
L["config.player.show_border.desc"] = "显示进度条边框。"
L["config.player.classic_bars.desc"] = "在进度条上启用职业纹理。"
L["config.player.show_left_text.desc"] = "允许在进度条左侧显示武器位置。"
L["config.player.show_right_text.desc"] = "允许在进度右侧显示计时器。"

L["config.target.title"] = "设置目标武器进度条"
L["config.target.enable.desc"] = "启用目标武器进度条。"
L["config.target.show_offhand.desc"] = "显示目标副手武器进度条。"
L["config.target.show_border.desc"] = "显示目标进度条边框。"
L["config.target.classic_bars.desc"] = "在目标进度条上启用职业纹理。"
L["config.target.show_left_text.desc"] = "允许在目标进度条左侧显示武器位置。"
L["config.target.show_right_text.desc"] = "允许在目标进度右侧显示计时器。"

L["config.hunter.shot.title"] = "设置远程武器进度条"
L["config.hunter.general.title"] = "基础设置"
L["config.hunter.specific.title"] = "猎人特殊设置"
L["config.hunter.one_bar.label"] = " 双向/单向"
L["config.hunter.one_bar.desc"] = "切换自动射击条为双向/单向。"
L["config.hunter.show_text.label"] = " 计时器"
L["config.hunter.show_text.desc"] = "启用射击进度条文字。"
L["config.hunter.cooldown_color.label"] = "自动射击冷却颜色"
L["config.hunter.auto_cast_color.label"] = "自动射击颜色"
L["config.hunter.multishot_clip_bar.label"] = " 多重射击覆盖区间"
L["config.hunter.multishot_clip_bar.desc"] = "允许显示多重射击覆盖区间。"
L["config.hunter.autoshot_delay_timer.label"] = " 自动射击延时器"
L["config.hunter.autoshot_delay_timer.desc"] = "为自动射击延时显示一个计时器。"
L["config.hunter.multishot_clip_color.label"] = "多重射击覆盖区间颜色"
L["config.hunter.bar_explanation.label"] = "图片说明："

L["config.castbar.aimed_shot.label"] = " 瞄准射击条"
L["config.castbar.aimed_shot.desc"] = "允许显示瞄准射击条。"
L["config.castbar.multi_shot.label"] = " 多重射击条"
L["config.castbar.multi_shot.desc"] = "允许显示多重射击条。"
L["config.castbar.latency.label"] = " 延迟条"
L["config.castbar.latency.desc"] = "允许显示延迟条。"

L["config.common.enable.label"] = " 启用"
L["config.common.show_offhand.label"] = " 副手"
L["config.common.show_border.label"] = " 边框"
L["config.common.classic_bars.label"] = " 职业纹理"
L["config.common.fill_empty.label"] = " 填充/空白"
L["config.common.fill_empty.desc"] = "决定武器可用时武器条是填充状态还是空白状态。"
L["config.common.show_left_text.label"] = " 武器位置"
L["config.common.show_right_text.label"] = " 计时器"
L["config.common.bar_width.label"] = "宽度"
L["config.common.bar_height.label"] = "高度"
L["config.common.font_size.label"] = "文字大小"
L["config.common.x_offset.label"] = "X坐标"
L["config.common.y_offset.label"] = "Y坐标"
L["config.common.main_bar_color.label"] = "主武器进度条颜色"
L["config.common.main_text_color.label"] = "主武器文本颜色"
L["config.common.off_bar_color.label"] = "副武器进度条颜色"
L["config.common.off_text_color.label"] = "副武器文本颜色"
L["config.common.in_combat_alpha.label"] = "战斗时透明度"
L["config.common.out_of_combat_alpha.label"] = "脱离战斗透明度"
L["config.common.backplane_alpha.label"] = "底板透明度"

L["bar.main_hand"] = "主手"
L["bar.off_hand"] = "副手"
L["cast.failed"] = "失败"
L["cast.interrupted"] = "打断"

L["spell.auto_shot"] = "自动射击"
L["spell.feign_death"] = "假死"
L["spell.trueshot_aura"] = "强击光环"
L["spell.multi_shot"] = "多重射击"
L["spell.aimed_shot"] = "瞄准射击"
L["spell.shoot"] = "射击"
L["spell.quick_shots"] = "快速射击"
L["spell.rapid_shot"] = "急速射击"
L["spell.berserking"] = "狂暴"
L["spell.kiss_of_the_spider"] = "蜘蛛之吻"
L["spell.curse_of_tongues"] = "语言诅咒"
