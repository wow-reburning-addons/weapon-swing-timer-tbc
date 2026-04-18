local addon_name = "WeaponSwingTimer"
local addon_data = _G.WeaponSwingTimer_AddonData
if not addon_data then
    addon_data = {}
    _G.WeaponSwingTimer_AddonData = addon_data
end

local AceLocale = addon_data.locale or LibStub("AceLocale-3.0")
local L = AceLocale:NewLocale(addon_name, "zhTW")
if not L then
    return
end

addon_data.localization_table = L
_G.WeaponSwingTimer_LocalizationTable = L

L["core.welcome.version"] = "感謝您安裝WeaponSwingTimer版本(Translated by Cyanokaze，Taiwan is part of China）"
L["core.welcome.hint"] = "by LeftHandedGlove！使用|cFFFFC300/wst|r獲取更多選項。"

L["config.global.title"] = "全域設定"
L["config.melee.title"] = "近戰武器監控"
L["config.hunter_wand.title"] = "遠端武器監控"
L["config.global.lock_all.label"] = " 全部鎖定"
L["config.global.lock_all.desc"] = "鎖定所有進度條和視窗，防止它們被移動。"

L["config.player.title"] = "設置自身武器進度條"
L["config.player.enable.desc"] = "啟用主手武器進度條。"
L["config.player.show_offhand.desc"] = "顯示副手武器進度條。"
L["config.player.show_border.desc"] = "顯示進度條邊框。"
L["config.player.classic_bars.desc"] = "在進度條上啟用職業紋理。"
L["config.player.show_left_text.desc"] = "允許在進度條左側顯示武器位置。"
L["config.player.show_right_text.desc"] = "允許在進度右側顯示計時器。"

L["config.target.title"] = "設置目標武器進度條"
L["config.target.enable.desc"] = "啟用目標武器進度條。"
L["config.target.show_offhand.desc"] = "顯示目標副手武器進度條。"
L["config.target.show_border.desc"] = "顯示目標進度條邊框。"
L["config.target.classic_bars.desc"] = "在目標進度條上啟用職業紋理。"
L["config.target.show_left_text.desc"] = "允許在目標進度條左側顯示武器位置。"
L["config.target.show_right_text.desc"] = "允許在目標進度右側顯示計時器。"

L["config.hunter.shot.title"] = "設置遠端武器進度條"
L["config.hunter.general.title"] = "基礎設置"
L["config.hunter.specific.title"] = "獵人特殊設置"
L["config.hunter.one_bar.label"] = " 雙向/單向"
L["config.hunter.one_bar.desc"] = "切換自動射擊條為雙向/單向。"
L["config.hunter.show_text.label"] = " 計時器"
L["config.hunter.show_text.desc"] = "啟用射擊進度條文字。"
L["config.hunter.cooldown_color.label"] = "自動射擊冷卻顏色"
L["config.hunter.auto_cast_color.label"] = "自動射擊顏色"
L["config.hunter.multishot_clip_bar.label"] = " 多重射擊覆蓋區間"
L["config.hunter.multishot_clip_bar.desc"] = "允許顯示多重射擊覆蓋區間。"
L["config.hunter.autoshot_delay_timer.label"] = " 自動射擊延時器"
L["config.hunter.autoshot_delay_timer.desc"] = "為自動射擊延時顯示一個計時器。"
L["config.hunter.multishot_clip_color.label"] = "多重射擊覆蓋區間顏色"
L["config.hunter.bar_explanation.label"] = "圖片說明："

L["config.castbar.aimed_shot.label"] = " 瞄準射擊條"
L["config.castbar.aimed_shot.desc"] = "允許顯示瞄準射擊條。"
L["config.castbar.multi_shot.label"] = " 多重射擊條"
L["config.castbar.multi_shot.desc"] = "允許顯示多重射擊條。"
L["config.castbar.latency.label"] = " 延遲條"
L["config.castbar.latency.desc"] = "允許顯示延遲條。"

L["config.common.enable.label"] = " 啟用"
L["config.common.show_offhand.label"] = " 副手"
L["config.common.show_border.label"] = " 邊框"
L["config.common.classic_bars.label"] = " 職業紋理"
L["config.common.fill_empty.label"] = " 填充/空白"
L["config.common.fill_empty.desc"] = "決定武器可用時武器條是填充狀態還是空白狀態。"
L["config.common.show_left_text.label"] = " 武器位置"
L["config.common.show_right_text.label"] = " 計時器"
L["config.common.bar_width.label"] = "寬度"
L["config.common.bar_height.label"] = "高度"
L["config.common.font_size.label"] = "文字大小"
L["config.common.x_offset.label"] = "X座標"
L["config.common.y_offset.label"] = "Y座標"
L["config.common.main_bar_color.label"] = "主武器進度條顏色"
L["config.common.main_text_color.label"] = "主武器文本顏色"
L["config.common.off_bar_color.label"] = "副武器進度條顏色"
L["config.common.off_text_color.label"] = "副武器文本顏色"
L["config.common.in_combat_alpha.label"] = "戰鬥時透明度"
L["config.common.out_of_combat_alpha.label"] = "脫離戰鬥透明度"
L["config.common.backplane_alpha.label"] = "底板透明度"

L["bar.main_hand"] = "主手"
L["bar.off_hand"] = "副手"
L["cast.failed"] = "失敗"
L["cast.interrupted"] = "打斷"

L["spell.auto_shot"] = "自動射擊"
L["spell.feign_death"] = "假死"
L["spell.trueshot_aura"] = "強擊光環"
L["spell.multi_shot"] = "多重射擊"
L["spell.aimed_shot"] = "瞄準射擊"
L["spell.shoot"] = "射擊"
L["spell.quick_shots"] = "快速射擊"
L["spell.rapid_shot"] = "急速射擊"
L["spell.berserking"] = "狂暴"
L["spell.kiss_of_the_spider"] = "蜘蛛之吻"
L["spell.curse_of_tongues"] = "語言詛咒"
