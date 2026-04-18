local addon_name = "WeaponSwingTimer"
local addon_data = _G.WeaponSwingTimer_AddonData
if not addon_data then
    addon_data = {}
    _G.WeaponSwingTimer_AddonData = addon_data
end

local AceLocale = addon_data.locale or LibStub("AceLocale-3.0")
local L = AceLocale:NewLocale(addon_name, "ruRU")
if not L then
    return
end

local locale_table = AceLocale:GetLocale(addon_name, true)
if locale_table then
    addon_data.localization_table = locale_table
    _G.WeaponSwingTimer_LocalizationTable = locale_table
end

L["core.welcome.version"] = "Спасибо за установку WeaponSwingTimer версии"
L["core.welcome.hint"] = "от WatchYourSixx! Используйте |cFFFFC300/wst|r для дополнительных настроек."
L["core.error.unexpected_unit_misshandler"] = "Неожиданный тип юнита в MissHandler()."
L["core.error.unexpected_unit_spellhandler"] = "Неожиданный тип юнита в SpellHandler()."
L["core.test.running"] = "Запуск self-test для combat-log..."
L["core.test.passed"] = "Self-test combat-log пройден (%d/%d)."
L["core.test.failed"] = "Self-test combat-log не пройден (%d/%d)."
L["core.test.failed_case_nil"] = "Тест '%s' не пройден: NormalizeCombatLogEvent() вернул nil."
L["core.test.failed_case_field"] = "Тест '%s' не пройден: %s ожидалось '%s', получено '%s'."

L["config.global.title"] = "Глобальные настройки полос"
L["config.melee.title"] = "Настройки ближнего боя"
L["config.hunter_wand.title"] = "Настройки охотника и жезла"
L["config.global.lock_all.label"] = " Заблокировать все полосы"
L["config.global.lock_all.desc"] = "Блокирует все полосы таймера, чтобы их нельзя было перетаскивать."
L["config.global.welcome_message.label"] = " Приветственное сообщение"
L["config.global.welcome_message.desc"] = "Показывать приветственное сообщение при входе/перезагрузке. Снимите галочку, чтобы отключить."
L["config.global.reset_settings"] = "Сбросить настройки"
L["config.bliz_bridge.open.label"] = "Открыть настройки"
L["config.bliz_bridge.open.desc"] = "Открывает полные настройки WeaponSwingTimer в отдельном окне."

L["config.player.title"] = "Настройки полос игрока"
L["config.player.enable.desc"] = "Включает полосы таймера атак игрока."
L["config.player.show_offhand.desc"] = "Включает полосу таймера для левой руки игрока."
L["config.player.show_border.desc"] = "Показывает рамку полос игрока."
L["config.player.classic_bars.desc"] = "Включает классическую текстуру полос игрока."
L["config.player.show_left_text.desc"] = "Включает текст слева на полосах игрока."
L["config.player.show_right_text.desc"] = "Включает текст справа на полосах игрока."

L["config.target.title"] = "Настройки полос цели"
L["config.target.enable.desc"] = "Включает полосы таймера атак цели."
L["config.target.show_offhand.desc"] = "Включает полосу таймера для левой руки цели."
L["config.target.show_border.desc"] = "Показывает рамку полос цели."
L["config.target.classic_bars.desc"] = "Включает классическую текстуру полос цели."
L["config.target.show_left_text.desc"] = "Включает текст слева на полосах цели."
L["config.target.show_right_text.desc"] = "Включает текст справа на полосах цели."

L["config.hunter.shot.title"] = "Настройки полос выстрела"
L["config.hunter.general.title"] = "Основные настройки"
L["config.hunter.specific.title"] = "Особые настройки охотника"
L["config.hunter.enable.desc"] = "Включает полосы автовыстрела/выстрела."
L["config.hunter.show_border.desc"] = "Включает рамку полосы выстрела."
L["config.hunter.classic_bars.desc"] = "Включает классическую текстуру полос выстрела."
L["config.hunter.one_bar.label"] = " YaHT / Одна полоса"
L["config.hunter.one_bar.desc"] = "Переключает авто-выстрел на одну полосу, заполняемую слева направо."
L["config.hunter.show_text.label"] = " Показать текст"
L["config.hunter.show_text.desc"] = "Включает текст на полосе выстрела."
L["config.hunter.cooldown_color.label"] = "Цвет отката Автовыстрела"
L["config.hunter.auto_cast_color.label"] = "Цвет каста Автовыстрела"
L["config.hunter.multishot_clip_bar.label"] = " Полоса клипа Залпа"
L["config.hunter.multishot_clip_bar.desc"] = "Показывает момент, когда Залп обрежет Автовыстрел."
L["config.hunter.autoshot_delay_timer.label"] = " Таймер задержки Автовыстрела"
L["config.hunter.autoshot_delay_timer.desc"] = "Показывает таймер задержки Автовыстрела."
L["config.hunter.multishot_clip_color.label"] = "Цвет клипа Залпа"
L["config.hunter.bar_explanation.label"] = "Пояснение полос"

L["config.castbar.show_cast_text.label"] = " Показать текст каста"
L["config.castbar.show_cast_text.desc"] = "Включает текст на полосе каста."
L["config.castbar.aimed_shot.label"] = " Полоса Прицельного выстрела"
L["config.castbar.aimed_shot.desc"] = "Разрешает показывать на полосе каста Прицельный выстрел."
L["config.castbar.multi_shot.label"] = " Полоса Залпа"
L["config.castbar.multi_shot.desc"] = "Разрешает показывать на полосе каста Залп."
L["config.castbar.latency.label"] = " Полоса задержки"
L["config.castbar.latency.desc"] = "Показывает полосу задержки на полосе каста."

L["config.common.enable.label"] = " Включить"
L["config.common.show_offhand.label"] = " Показать левую руку"
L["config.common.show_border.label"] = " Показать рамку"
L["config.common.classic_bars.label"] = " Классические полосы"
L["config.common.fill_empty.label"] = " Заполнение / Пусто"
L["config.common.fill_empty.desc"] = "Определяет, будет ли полоса полной или пустой, когда атака готова."
L["config.common.show_left_text.label"] = " Показать левый текст"
L["config.common.show_right_text.label"] = " Показать правый текст"
L["config.common.bar_width.label"] = "Ширина полосы"
L["config.common.bar_height.label"] = "Высота полосы"
L["config.common.font_size.label"] = "Размер шрифта"
L["config.common.x_offset.label"] = "Смещение X"
L["config.common.y_offset.label"] = "Смещение Y"
L["config.common.main_bar_color.label"] = "Цвет полосы правой руки"
L["config.common.main_text_color.label"] = "Цвет текста правой руки"
L["config.common.off_bar_color.label"] = "Цвет полосы левой руки"
L["config.common.off_text_color.label"] = "Цвет текста левой руки"
L["config.common.in_combat_alpha.label"] = "Прозрачность в бою"
L["config.common.out_of_combat_alpha.label"] = "Прозрачность вне боя"
L["config.common.backplane_alpha.label"] = "Прозрачность фона"

L["bar.main_hand"] = "Правая рука"
L["bar.off_hand"] = "Левая рука"
L["cast.failed"] = "Неудачно"
L["cast.interrupted"] = "Прервано"
L["cast.spell_bar_unlocked"] = "Полоса заклинаний разблокирована"

L["spell.auto_shot"] = "Автовыстрел"
L["spell.feign_death"] = "Притвориться мертвым"
L["spell.trueshot_aura"] = "Аура меткого выстрела"
L["spell.multi_shot"] = "Залп"
L["spell.aimed_shot"] = "Прицельный выстрел"
L["spell.shoot"] = "Выстрел"
L["spell.quick_shots"] = "Быстрая стрельба"
L["spell.rapid_shot"] = "Скорострельность"
L["spell.berserking"] = "Берсерк"
L["spell.kiss_of_the_spider"] = "Поцелуй паука"
L["spell.curse_of_tongues"] = "Проклятие косноязычия"
