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

local AceAddon = LibStub("AceAddon-3.0")
addon_data.core = AceAddon:NewAddon(addon_name, "AceEvent-3.0", "AceConsole-3.0")

addon_data.core.all_timers = {
    addon_data.player, addon_data.target
}

local version = "6.5.2"

local load_message = L["Thank you for installing WeaponSwingTimer Version"] .. " " .. version .. 
                     " " .. L["by WatchYourSixx! Use |cFFFFC300/wst|r for more options."]
                     
addon_data.core.default_settings = {
    one_frame = false,
	welcome_message = true
}

addon_data.core.in_combat = false

local function GetTrailingBoolean(...)
    local arg_count = select("#", ...)
    if arg_count == 0 then
        return nil
    end

    local value = select(arg_count, ...)
    if type(value) == "boolean" then
        return value
    end

    return nil
end

addon_data.core.NormalizeCombatLogEvent = function(...)
    local event = select(2, ...)
    local source_guid = select(3, ...)
    local dest_guid = select(6, ...)
    local payload_index = 9

    if (type(event) ~= "string") or (not string.find(event, "_")) then
        event = select(1, ...)
        source_guid = select(2, ...)
        dest_guid = select(5, ...)
        payload_index = 8
    end

    if type(event) ~= "string" then
        return nil
    end

    local combat_info = {
        event = event,
        source_guid = source_guid,
        dest_guid = dest_guid,
        spell_id = nil,
        spell_name = nil,
        miss_type = nil,
        is_offhand = nil,
    }

    if (event == "SPELL_DAMAGE") or (event == "SPELL_MISSED") or
       (event == "RANGE_DAMAGE") or (event == "RANGE_MISSED") or
       (event == "SPELL_CAST_START") or (event == "SPELL_CAST_SUCCESS") then
        combat_info.spell_id = select(payload_index, ...)
        combat_info.spell_name = select(payload_index + 1, ...)
    end

    if event == "SWING_MISSED" then
        combat_info.miss_type = select(payload_index, ...)
        combat_info.is_offhand = GetTrailingBoolean(select(payload_index + 1, ...))
    elseif (event == "SPELL_MISSED") or (event == "RANGE_MISSED") then
        combat_info.miss_type = select(payload_index + 3, ...)
    elseif event == "SWING_DAMAGE" then
        combat_info.is_offhand = GetTrailingBoolean(select(payload_index, ...))
    end

    return combat_info
end

local swing_reset_spells = {}
swing_reset_spells['DRUID'] = {
    -- --[[ Abolish Poison ]]           2893,
    -- --[[ Aquatic Form ]]             1066,
    -- --[[ Barkskin ]]                 22812,
    -- --[[ Bash ]]                     5211, 6798, 8983,
    -- --[[ Bear Form ]]                5487,
    -- --[[ Cat Form ]]                 768,
    -- --[[ Challenging Roar ]]         5209,
    -- --[[ Claw ]]                     1082, 3029, 5201, 9849, 9850,
    -- --[[ Cower ]]                    8998, 9000, 9892,
    -- --[[ Cure Poison ]]              8946,
    -- --[[ Dash ]]                     1850, 9821,
    -- --[[ Demoralizing Roar ]]        99, 1735, 9490, 9747, 9898,
    -- --[[ Dire Bear Form ]]           9634,
    -- --[[ Enrage ]]                   5229,
    -- --[[ Entangling Roots ]]         339, 1062, 5195, 5196, 9852, 9853,
    -- --[[ Faerie Fire ]]              770, 778, 9749, 9907, 
    -- --[[ Faerie Fire (Feral) ]]      16857, 17390, 17391, 17392, 
    -- --[[ Feral Charge ]]             16979, 
    -- --[[ Ferocious Bite ]]           22568, 22827, 22828, 22829, 31018,
    -- --[[ Frenzied Regeneration ]]    
    -- --[[ Gift of the Wild ]]
    -- --[[ Growl ]]
    -- --[[ Healing Touch ]]
    -- --[[ Hibernate ]]
    -- --[[ Hurricane ]]
    -- --[[ Innervate ]]
    -- --[[ Insect Storm ]]
    -- --[[ Mark of the Wild ]]
    --[[ Maul ]]                        6807, 6808, 6809, 8972, 9745, 9880, 9881
    -- --[[ Moonfire ]]
    -- --[[ Moonkin Form ]]
    -- --[[ Nature's Grasp ]]
    -- --[[ Nature's Swiftness ]]
    -- --[[ Omen of Clarity ]]
    -- --[[ Pounce ]]
    -- --[[ Prowl ]]
    -- --[[ Rake ]]
    -- --[[ Ravage ]]
    -- --[[ Rebirth ]]
    -- --[[ Regrowth ]]
    -- --[[ Rejuvenation ]]
    -- --[[ Remove Curse ]]
    -- --[[ Rip ]]
    -- --[[ Shred ]]
    -- --[[ Soothe Animal ]]
    -- --[[ Starfire ]]
    -- --[[ Swiftmend ]]
    -- --[[ Swipe ]]
    -- --[[ Teleport: Moonglade ]]
    -- --[[ Thorns ]]
    -- --[[ Tiger's Fury ]]
    -- --[[ Track Humanoids ]]
    -- --[[ Tranquility ]]
    -- --[[ Travel Form ]]
    -- --[[ Wrath ]]
}
swing_reset_spells['HUNTER'] = {
    -- --[[ Aimed Shot ]]
    -- --[[ Arcane Shot ]]
    -- --[[ Aspect of the Beast ]]
    -- --[[ Aspect of the Cheetah ]]
    -- --[[ Aspect of the Hawk ]]
    -- --[[ Aspect of the Monkey ]]
    -- --[[ Aspect of the Pack ]]
    -- --[[ Aspect of the Wild ]]
    -- --[[ Auto Shot ]]
    -- --[[ Beast Lore ]]
    -- --[[ Bestial Wrath ]]
    -- --[[ Call Pet ]]
    -- --[[ Concussive Shot ]]
    -- --[[ Counterattack ]]
    -- --[[ Deterrence ]]
    -- --[[ Disengage ]]
    -- --[[ Dismiss Pet ]]
    -- --[[ Distracting Shot ]]
    -- --[[ Eagle Eye ]]
    -- --[[ Explosive Trap ]]
    -- --[[ Eyes of the Beast ]]
    -- --[[ Feed Pet ]]
    -- --[[ Feign Death ]]
    -- --[[ Flare ]]
    -- --[[ Freezing Trap ]]
    -- --[[ Frost Trap ]]
    -- --[[ Hunter's Mark ]]
    -- --[[ Immolation Trap ]]
    -- --[[ Intimidation ]]
    -- --[[ Mend Pet ]]
    -- --[[ Mongoose Bite ]]
    -- --[[ Multi-Shot ]]
    -- --[[ Rapid Fire ]]
    --[[ Raptor Strike ]]               2973, 14260, 14261, 14262, 14263, 14264, 14265, 14266, 27014
    -- --[[ Readiness ]]
    -- --[[ Revive Pet ]]
    -- --[[ Scare Beast ]]
    -- --[[ Scatter Shot ]]
    -- --[[ Scorpid Sting ]]
    -- --[[ Serpent Sting ]]
    -- --[[ Tame Beast ]]
    -- --[[ Throw ]]
    -- --[[ Track Beast ]]
    -- --[[ Track Demons ]]
    -- --[[ Track Dragonkin ]]
    -- --[[ Track Elements ]]
    -- --[[ Track Giants ]]
    -- --[[ Track Hidden ]]
    -- --[[ Track Humanoids ]]
    -- --[[ Track Undead ]]
    -- --[[ Tranquilizing Shot ]]
    -- --[[ Trueshot Aura ]]
    -- --[[ Viper Sting ]]
    -- --[[ Volley ]]
    -- --[[ Wing Clip ]]
    -- --[[ Wyvern Sting ]]
}
swing_reset_spells['MAGE'] = {
    -- --[[ Amplify Magic ]]
    -- --[[ Arcane Brilliance ]]
    -- --[[ Arcane Explosion ]]
    -- --[[ Arcane Intellect ]]
    -- --[[ Arcane Missles ]]
    -- --[[ Arcane Power ]]
    -- --[[ Blast Wave ]]
    -- --[[ Blink ]]
    -- --[[ Blizzard ]]
    -- --[[ Cold Snap ]]
    -- --[[ Combustion ]]
    -- --[[ Cone of Cold ]]
    -- --[[ Counterspell ]]
    -- --[[ Dampen Magic ]]
    -- --[[ Detect Magic ]]
    -- --[[ Evocation ]]
    -- --[[ Fire Blast ]]
    -- --[[ Fire Ward ]]
    -- --[[ Fireball ]]
    -- --[[ Flamestrike ]]
    -- --[[ Frost Armor ]]
    -- --[[ Frost Nova ]]
    -- --[[ Frost Ward ]]
    -- --[[ Frostbolt ]]
    -- --[[ Ice Armor ]]
    -- --[[ Ice Barrier ]]
    -- --[[ Ice Block ]]
    -- --[[ Mage Armor ]]
    -- --[[ Mana Shield ]]
    -- --[[ Polymorph ]]
    -- --[[ Polymorph: Cow ]]
    -- --[[ Polymorph: Pig ]]
    -- --[[ Polymorph: Turtle ]]
    -- --[[ Portal: Darnassus ]]
    -- --[[ Portal: Ironforge ]]
    -- --[[ Portal: Orgimmar ]]
    -- --[[ Portal: Stormwind ]]
    -- --[[ Portal: Thunder Bluff ]]
    -- --[[ Portal: Undercity ]]
    -- --[[ Presence of Mind ]]
    -- --[[ Pyroblast ]]
    -- --[[ Remove Lesser Curse ]]
    -- --[[ Scorch ]]
    -- --[[ Shoot ]]
    -- --[[ Slow Fall ]]
    -- --[[ Teleport: Darnassus ]]
    -- --[[ Teleport: Ironforge ]]
    -- --[[ Teleport: Orgimmar ]]
    -- --[[ Teleport: Stormwind ]]
    -- --[[ Teleport: Thunder Bluff ]]
    -- --[[ Teleport: Undercity ]]
    -- --[[ Conjure Food ]]
    -- --[[ Conjure Mana Agate ]]
    -- --[[ Conjure Mana Citrine ]]
    -- --[[ Conjure Mana Jade ]]
    -- --[[ Conjure Mana Ruby ]]
    -- --[[ Conjure Water ]]
}
swing_reset_spells['PALADIN'] = {
    -- --[[ Blessing of Freedom ]]
    -- --[[ Blessing of Kings ]]
    -- --[[ Blessing of Light ]]
    -- --[[ Blessing of Might ]]
    -- --[[ Blessing of Protection ]]
    -- --[[ Blessing of Sacrifice ]]
    -- --[[ Blessing of Salvation ]]
    -- --[[ Blessing of Sanctuary ]]
    -- --[[ Blessing of Wisdom ]]
    -- --[[ Cleanse ]]
    -- --[[ Concentration Aura ]]
    -- --[[ Consecration ]]
    -- --[[ Devotion Aura ]]
    -- --[[ Divine Favor ]]
    -- --[[ Divine Intervention ]]
    -- --[[ Divine Protection ]]
    -- --[[ Divine Shield ]]
    -- --[[ Exorcism ]]
    -- --[[ Fire Resistance Aura ]]
    -- --[[ Flash of Light ]]
    -- --[[ Frost Resistance Aura ]]
    -- --[[ Greater Blessing of Kings ]]
    -- --[[ Greater Blessing of Light ]]
    -- --[[ Greater Blessing of Might ]]
    -- --[[ Greater Blessing of Salvation ]]
    -- --[[ Greater Blessing of Sanctuary ]]
    -- --[[ Greater Blessing of Wisdom ]]
    -- --[[ Hammer of Justice ]]
    -- --[[ Hammer of Wrath ]]
    -- --[[ Holy Light ]]
    -- --[[ Holy Shield ]]
    -- --[[ Holy Shock ]]
    -- --[[ Holy Wrath ]]
    -- --[[ Judgement ]]
    -- --[[ Lay on Hands ]]
    -- --[[ Purify ]]
    -- --[[ Redemption ]]
    -- --[[ Repentance ]]
    -- --[[ Retribution Aura ]]
    -- --[[ Righteous Fury ]]
    -- --[[ Sanctity Aura ]]
    -- --[[ Seal of Command ]]
    -- --[[ Seal of Justice ]]
    -- --[[ Seal of Light ]]
    -- --[[ Seal of Righteousness ]]
    -- --[[ Seal of the Crusader ]]
    -- --[[ Seal of Wisdom ]]
    -- --[[ Sense Undead ]]
    -- --[[ Shadow Resistance Aura ]]
    -- --[[ Summon Charger ]]
    -- --[[ Summon Warhorse ]]
    -- --[[ Turn Undead ]]
}
swing_reset_spells['PRIEST'] = {
    -- --[[ Abolish Disease ]]
    -- --[[ Cure Disease ]]
    -- --[[ Desperate Prayer ]]
    -- --[[ Devouring Plague ]]
    -- --[[ Dispel Magic ]]
    -- --[[ Divine Spirit ]]
    -- --[[ Fade ]]
    -- --[[ Fear Ward ]]
    -- --[[ Feedback ]]
    -- --[[ Flash Heal ]]
    -- --[[ Greater Heal ]]
    -- --[[ Heal ]]
    -- --[[ Hex of Weakness ]]
    -- --[[ Holy Fire ]]
    -- --[[ Holy Nova ]]
    -- --[[ Inner Fire ]]
    -- --[[ Inner Focus ]]
    -- --[[ Lesser Heal ]]
    -- --[[ Levitate ]]
    -- --[[ Lightwell ]]
    -- --[[ Mana Burn ]]
    -- --[[ Mind Blast ]]
    -- --[[ Mind Control ]]
    -- --[[ Mind Flay ]]
    -- --[[ Mind Soothe ]]
    -- --[[ Mind Vision ]]
    -- --[[ Power Infusion ]]
    -- --[[ Power Word: Fortitude ]]
    -- --[[ Power Word: Shield ]]
    -- --[[ Prayer of Fortitude ]]
    -- --[[ Prayer of Healing ]]
    -- --[[ Prayer of Shadow Protection ]]
    -- --[[ Prayer of Spirit ]]
    -- --[[ Psychic Scream ]]
    -- --[[ Renew ]]
    -- --[[ Resurrection ]]
    -- --[[ Shackle Undead ]]
    -- --[[ Shadow Protection ]]
    -- --[[ Shadow Word: Pain ]]
    -- --[[ Shadowform ]]
    -- --[[ Shadowguard ]]
    -- --[[ Shoot ]]
    -- --[[ Silence ]]
    -- --[[ Smite ]]
    -- --[[ Starshards ]]
    -- --[[ Touch of Weakness ]]
    -- --[[ Vampiric Embrace ]]
}
swing_reset_spells['ROGUE'] = {
    -- --[[ Adrenaline Rush ]]
    -- --[[ Ambush ]]
    -- --[[ Backstab ]]
    -- --[[ Blade Flurry ]]
    -- --[[ Blind ]]
    -- --[[ Cheap Shot ]]
    -- --[[ Cold Blood ]]
    -- --[[ Detect Traps ]]
    -- --[[ Disarm Trap ]]
    -- --[[ Distract ]]
    -- --[[ Evasion ]]
    -- --[[ Eviscerate ]]
    -- --[[ Expose Armor ]]
    -- --[[ Feint ]]
    -- --[[ Garrote ]]
    -- --[[ Ghostly Strike ]]
    -- --[[ Gouge ]]
    -- --[[ Hemorrhage ]]
    -- --[[ Kick ]]
    -- --[[ Kidney Shot ]]
    -- --[[ Pick Lock ]]
    -- --[[ Pick Pocket ]]
    -- --[[ Preparation ]]
    -- --[[ Riposte ]]
    -- --[[ Rupture ]]
    -- --[[ Sap ]]
    -- --[[ Shoot Bow ]]
    -- --[[ Shoot Crossbow ]]
    -- --[[ Shoot Gun ]]
    -- --[[ Sinister Strike ]]
    -- --[[ Slice and Dice ]]
    -- --[[ Sprint ]]
    -- --[[ Stealth ]]
    -- --[[ Throw ]]
    -- --[[ Vanish ]]
    -- --[[ Blinding Powder ]]
    -- --[[ Crippling Poison ]]
    -- --[[ Crippling Poison II ]]
    -- --[[ Deadly Poison ]]
    -- --[[ Deadly Poison II ]]
    -- --[[ Deadly Poison III ]]
    -- --[[ Deadly Poison IV ]]
    -- --[[ Deadly Poison V ]]
    -- --[[ Instant Poison ]]
    -- --[[ Instant Poison II ]]
    -- --[[ Instant Poison III ]]
    -- --[[ Instant Poison IV ]]
    -- --[[ Instant Poison V ]]
    -- --[[ Instant Poison VI ]]
    -- --[[ Mind-numbing Poison ]]
    -- --[[ Mind-numbing Poison II ]]
    -- --[[ Mind-numbing Poison III ]]
    -- --[[ Would Poison ]]
    -- --[[ Would Poison II ]]
    -- --[[ Would Poison III ]]
    -- --[[ Would Poison IV ]]
}
swing_reset_spells['SHAMAN'] = {
    -- --[[ Ancestral Spirit ]]
    -- --[[ Astral Recall ]]
    -- --[[ Chain Heal ]]
    -- --[[ Chain Lightning ]]
    -- --[[ Cure Disease ]]
    -- --[[ Cure Poison ]]
    -- --[[ Disease Cleansing Totem ]]
    -- --[[ Earth Shock ]]
    -- --[[ Earthbind Totem ]]
    -- --[[ Elemental Mastery ]]
    -- --[[ Farsight ]]
    -- --[[ Fire Nova Totem ]]
    -- --[[ Fire Resistance Totem ]]
    -- --[[ Flame Shock ]]
    -- --[[ Flametongue Totem ]]
    -- --[[ Flametongue Weapon ]]
    -- --[[ Frost Resistance Totem ]]
    -- --[[ Frost Shock ]]
    -- --[[ Frostbrand Weapon ]]
    -- --[[ Ghost Wolf ]]
    -- --[[ Grace of Air Totem ]]
    -- --[[ Grounding Totem ]]
    -- --[[ Healing Stream Totem ]]
    -- --[[ Healing Wave ]]
    -- --[[ Lesser Healing Wave ]]
    -- --[[ Lightning Bolt ]]
    -- --[[ Lightning Shield ]]
    -- --[[ Magma Totem ]]
    -- --[[ Mana Spring Totem ]]
    -- --[[ Mana Tide Totem ]]
    -- --[[ Nature Resistance Totem ]]
    -- --[[ Nature's Swiftness ]]
    -- --[[ Poison Cleansing Totem ]]
    -- --[[ Purge ]]
    -- --[[ Reincarnation ]]
    -- --[[ Rockbiter Weapon ]]
    -- --[[ Searing Totem ]]
    -- --[[ Sentry Totem ]]
    -- --[[ Stoneclaw Totem ]]
    -- --[[ Stoneskin Totem ]]
    -- --[[ Stormstrike ]]
    -- --[[ Strength of Earth Totem ]]
    -- --[[ Tranquil Air Totem ]]
    -- --[[ Tremor Totem ]]
    -- --[[ Water Breathing ]]
    -- --[[ Water Walking ]]
    -- --[[ Windfury Totem ]]
    -- --[[ Windfury Weapon ]]
    -- --[[ Windwall Totem ]]
}
swing_reset_spells['WARLOCK'] = {
    -- --[[ Amplify Curse ]]
    -- --[[ Banish ]]
    -- --[[ Conflagrate ]]
    -- --[[ Corruption ]]
    -- --[[ Create Healthstone ]]
    -- --[[ Create Healthstone (Greater) ]]
    -- --[[ Create Healthstone (Lesser) ]]
    -- --[[ Create Healthstone (Major) ]]
    -- --[[ Create Healthstone (Minor) ]]
    -- --[[ Curse of Agony ]]
    -- --[[ Curse of Doom ]]
    -- --[[ Curse of Exhaustion ]]
    -- --[[ Curse of Recklessness ]]
    -- --[[ Curse of Shadow ]]
    -- --[[ Curse of the Elements ]]
    -- --[[ Curse of Tongues ]]
    -- --[[ Curse of Weakness ]]
    -- --[[ Dark Pact ]]
    -- --[[ Death Coil ]]
    -- --[[ Demon Armor ]]
    -- --[[ Demon Skin ]]
    -- --[[ Demonic Sacrifice ]]
    -- --[[ Detect Greater Invisibility ]]
    -- --[[ Detect Invisibility ]]
    -- --[[ Detect Lesser Invisibility ]]
    -- --[[ Drain Life ]]
    -- --[[ Drain Mana ]]
    -- --[[ Drain Soul ]]
    -- --[[ Enslave Demon ]]
    -- --[[ Eye of Kilrogg ]]
    -- --[[ Fear ]]
    -- --[[ Fel Domination ]]
    -- --[[ Health Funnel ]]
    -- --[[ Hell Fire ]]
    -- --[[ Howl of Terror ]]
    -- --[[ Immolate ]]
    -- --[[ Inferno ]]
    -- --[[ Life Tap ]]
    -- --[[ Rain of Fire ]]
    -- --[[ Ritual of Doom ]]
    -- --[[ Ritual of Summoning ]]
    -- --[[ Searing Pain ]]
    -- --[[ Sense Demons ]]
    -- --[[ Shadow Bolt ]]
    -- --[[ Shadow Ward ]]
    -- --[[ Shadowburn ]]
    -- --[[ Shoot ]]
    -- --[[ Siphon Life ]]
    -- --[[ Soul Fire ]]
    -- --[[ Soul Link ]]
    -- --[[ Summon Dreadsteed ]]
    -- --[[ Summon Felhunter ]]
    -- --[[ Summon Felsteed ]]
    -- --[[ Summon Imp ]]
    -- --[[ Summon Succubus ]]
    -- --[[ Summon Voidwalker ]]
    -- --[[ Unending Breath ]]
    -- --[[ Create Firestone ]]
    -- --[[ Create Firestone (Greater) ]]
    -- --[[ Create Firestone (Lesser) ]]
    -- --[[ Create Firestone (Major) ]]
    -- --[[ Create Soulstone ]]
    -- --[[ Create Soulstone (Greater) ]]
    -- --[[ Create Soulstone (Lesser) ]]
    -- --[[ Create Soulstone (Major) ]]
    -- --[[ Create Spellstone ]]
    -- --[[ Create Spellstone (Greater) ]]
    -- --[[ Create Spellstone (Major) ]]
}
swing_reset_spells['WARRIOR'] = {
    -- --[[ Battle Shout ]]
    -- --[[ Battle Stance ]]
    -- --[[ Berserker Rage ]]
    -- --[[ Berserker Stance ]]
    -- --[[ Bloodrage ]]
    -- --[[ Bloodthirst ]]
    -- --[[ Challenging Shout ]]
    -- --[[ Charge ]]
    --[[ Cleave ]]                  845, 7369, 11608, 11609, 20569, 25231,
    -- --[[ Death Wish ]]
    -- --[[ Defensive Stance ]]
    -- --[[ Demoralizing Shout ]]
    -- --[[ Disarm ]]
    -- --[[ Execute ]]
    -- --[[ Hamstring ]]
    --[[ Heroic Strike ]]           78, 284, 285, 1608, 11564, 11565, 11566, 11567, 25286, 29707, 30324,
    -- --[[ Intercept ]]
    -- --[[ Intimidating Shout ]]
    -- --[[ Last Stand ]]
    -- --[[ Mocking Blow ]]
    -- --[[ Mortal Strike ]]
    -- --[[ Overpower ]]
    -- --[[ Piercing Howl ]]
    -- --[[ Pummel ]]
    -- --[[ Recklessness ]]
    -- --[[ Rend ]]
    -- --[[ Retaliation ]]
    -- --[[ Revenge ]]
    -- --[[ Shield Bash ]]
    -- --[[ Shield Block ]]
    -- --[[ Shield Slam ]]
    -- --[[ Shield Wall ]]
    -- --[[ Shoot Bow ]]
    -- --[[ Shoot Crossbow ]]
    -- --[[ Shoot Gun ]]
    --[[ Slam ]]                    1464, 8820, 11604, 11605, 25241, 25242
    -- --[[ Sunder Armor ]]
    -- --[[ Sweeping Strikes ]]
    -- --[[ Taunt ]]
    -- --[[ Throw ]]
    -- --[[ Thunder Clap ]]
    -- --[[ Whirlwind ]]
}

local function LoadAllSettings()
    if addon_data.core and addon_data.core.LoadSettings then addon_data.core.LoadSettings() end
    if addon_data.player and addon_data.player.LoadSettings then addon_data.player.LoadSettings() end
    if addon_data.target and addon_data.target.LoadSettings then addon_data.target.LoadSettings() end
    if addon_data.hunter and addon_data.hunter.LoadSettings then addon_data.hunter.LoadSettings() end
	if addon_data.castbar and addon_data.castbar.LoadSettings then addon_data.castbar.LoadSettings() end
end

addon_data.core.RestoreAllDefaults = function()
    addon_data.core.RestoreDefaults()
    addon_data.player.RestoreDefaults()
    addon_data.target.RestoreDefaults()
    addon_data.hunter.RestoreDefaults()
	addon_data.castbar.RestoreDefaults()
end

local function InitializeAllVisuals()
    if addon_data.player and addon_data.player.InitializeVisuals then addon_data.player.InitializeVisuals() end
    if addon_data.target and addon_data.target.InitializeVisuals then addon_data.target.InitializeVisuals() end
    if addon_data.hunter and addon_data.hunter.InitializeVisuals then addon_data.hunter.InitializeVisuals() end
	if addon_data.castbar and addon_data.castbar.InitializeVisuals then addon_data.castbar.InitializeVisuals() end
    if addon_data.config and addon_data.config.InitializeVisuals then addon_data.config.InitializeVisuals() end
end


addon_data.core.UpdateAllVisualsOnSettingsChange = function()
    addon_data.player.UpdateVisualsOnSettingsChange()
    addon_data.target.UpdateVisualsOnSettingsChange()
    addon_data.hunter.UpdateVisualsOnSettingsChange()
	addon_data.castbar.UpdateVisualsOnSettingsChange()
end

addon_data.core.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not character_core_settings then
        character_core_settings = {}
    end
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(addon_data.core.default_settings) do
        if character_core_settings[setting] == nil then
            character_core_settings[setting] = value
        end
    end
end

addon_data.core.RestoreDefaults = function()
    for setting, value in pairs(addon_data.core.default_settings) do
        character_core_settings[setting] = value
    end
end

local function CoreFrame_OnUpdate(self, elapsed)
    if addon_data.player and addon_data.player.OnUpdate then addon_data.player.OnUpdate(elapsed) end
    if addon_data.target and addon_data.target.OnUpdate then addon_data.target.OnUpdate(elapsed) end
    if addon_data.hunter and addon_data.hunter.OnUpdate then addon_data.hunter.OnUpdate(elapsed) end
	if addon_data.castbar and addon_data.castbar.OnUpdate then addon_data.castbar.OnUpdate(elapsed) end
end

addon_data.core.MissHandler = function(unit, miss_type, is_offhand)
    if miss_type == "PARRY" then
        if unit == "player" then
            min_swing_time = addon_data.target.main_weapon_speed * 0.2
            if addon_data.target.main_swing_timer > min_swing_time then
                addon_data.target.main_swing_timer = min_swing_time
            end
            if not is_offhand then
                if (addon_data.player.extra_attacks_flag == false) then
			addon_data.player.ResetMainSwingTimer()
		end
		addon_data.player.extra_attacks_flag = false
            else
                addon_data.player.ResetOffSwingTimer()
            end
        elseif unit == "target" then
            min_swing_time = addon_data.player.main_weapon_speed * 0.2
            if addon_data.player.main_swing_timer > min_swing_time then
                addon_data.player.main_swing_timer = min_swing_time
            end
            if not is_offhand then
                addon_data.target.ResetMainSwingTimer()
            else
                addon_data.target.ResetOffSwingTimer()
            end
        else
            addon_data.utils.PrintMsg(L["Unexpected Unit Type in MissHandler()."])
        end
    else
        if unit == "player" then
            if not is_offhand then
                if (addon_data.player.extra_attacks_flag == false) then
			addon_data.player.ResetMainSwingTimer()
		end
		addon_data.player.extra_attacks_flag = false
            else
                addon_data.player.ResetOffSwingTimer()
            end 
        elseif unit == "target" then
            if not is_offhand then
                addon_data.target.ResetMainSwingTimer()
            else
                addon_data.target.ResetOffSwingTimer()
            end 
        else
            addon_data.utils.PrintMsg(L["Unexpected Unit Type in MissHandler()."])
        end
    end
end

addon_data.core.SpellHandler = function(unit, spell_id)
    local _, player_class, _ = UnitClass('player')
    for class, spell_table in pairs(swing_reset_spells) do
        if player_class == class then
            for spell_index, curr_spell_id in ipairs(spell_table) do
				if spell_id == curr_spell_id then
				
                    if unit == "player" then
                        addon_data.player.ResetMainSwingTimer()
                    elseif unit == "target" then
                        addon_data.target.ResetMainSwingTimer()
                    else
                        addon_data.utils.PrintMsg(L["Unexpected Unit Type in SpellHandler()."])
                    end
                end
                
            end
        end
    end
end

function addon_data.core:OnInitialize()
    LoadAllSettings()
    self:RegisterChatCommand("wst", "OpenConfig")
    self:RegisterChatCommand("weaponswingtimer", "OpenConfig")
end

function addon_data.core:OnEnable()
    self.core_frame = self.core_frame or CreateFrame("Frame", addon_name .. "CoreFrame", UIParent)
    self.core_frame:SetScript("OnUpdate", CoreFrame_OnUpdate)

    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnPlayerRegenEnabled")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnPlayerRegenDisabled")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "OnPlayerTargetChanged")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEvent")
    self:RegisterEvent("UNIT_INVENTORY_CHANGED", "OnUnitInventoryChanged")
    self:RegisterEvent("START_AUTOREPEAT_SPELL", "OnStartAutorepeatSpell")
    self:RegisterEvent("STOP_AUTOREPEAT_SPELL", "OnStopAutorepeatSpell")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnUnitSpellCastSucceeded")
    self:RegisterEvent("UNIT_SPELLCAST_FAILED", "OnUnitSpellCastFailed")
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "OnUnitSpellCastInterrupted")
    self:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET", "OnUnitSpellCastFailedQuiet")

    InitializeAllVisuals()
    addon_data.player.ZeroizeSwingTimers()
    addon_data.target.ZeroizeSwingTimers()

    if character_core_settings.welcome_message then
        addon_data.utils.PrintMsg(load_message)
    end
end

function addon_data.core:OnPlayerRegenEnabled()
    addon_data.core.in_combat = false
end

function addon_data.core:OnPlayerRegenDisabled()
    addon_data.core.in_combat = true
end

function addon_data.core:OnPlayerTargetChanged()
    addon_data.target.OnPlayerTargetChanged()
end

function addon_data.core:OnCombatLogEvent(event, ...)
    local combat_info = addon_data.core.NormalizeCombatLogEvent(...)

    if not combat_info then
        return
    end

    addon_data.player.OnCombatLogUnfiltered(combat_info)
    addon_data.target.OnCombatLogUnfiltered(combat_info)
    addon_data.hunter.OnCombatLogUnfiltered(combat_info)
    addon_data.castbar.OnCombatLogUnfiltered(combat_info)
end

function addon_data.core:OnUnitInventoryChanged(event, ...)
    addon_data.player.OnInventoryChange()
    addon_data.target.OnInventoryChange()
    addon_data.hunter.OnInventoryChange()
end

function addon_data.core:OnStartAutorepeatSpell()
    addon_data.hunter.OnStartAutorepeatSpell()
end

function addon_data.core:OnStopAutorepeatSpell()
    addon_data.hunter.OnStopAutorepeatSpell()
end

function addon_data.core:OnUnitSpellCastSucceeded(event, ...)
    local unit = select(1, ...)
    local spell_id = select(3, ...)
    addon_data.hunter.OnUnitSpellCastSucceeded(unit, spell_id)
    addon_data.castbar.OnUnitSpellCastSucceeded(unit, spell_id)
end

function addon_data.core:OnUnitSpellCastFailed(event, ...)
    local unit = select(1, ...)
    local spell_id = select(3, ...)
    addon_data.castbar.OnUnitSpellCastFailed(unit, spell_id)
end

function addon_data.core:OnUnitSpellCastInterrupted(event, ...)
    local unit = select(1, ...)
    local spell_id = select(3, ...)
    addon_data.hunter.OnUnitSpellCastInterrupted(unit, spell_id)
    addon_data.castbar.OnUnitSpellCastInterrupted(unit, spell_id)
end

function addon_data.core:OnUnitSpellCastFailedQuiet(event, ...)
    local unit = select(1, ...)
    local spell_id = select(3, ...)
    addon_data.hunter.OnUnitSpellCastFailedQuiet(unit, spell_id)
end

function addon_data.core:OpenConfig(option)
    local panel = addon_data.config and addon_data.config.config_parent_panel
    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel or "WeaponSwingTimer")
        InterfaceOptionsFrame_OpenToCategory(panel or "WeaponSwingTimer")
    elseif InterfaceOptionsFrame_OpenToFrame and panel then
        InterfaceOptionsFrame_OpenToFrame(panel)
        InterfaceOptionsFrame_OpenToFrame(panel)
    elseif InterfaceOptionsFrame then
        ShowUIPanel(InterfaceOptionsFrame)
        if panel and InterfaceOptionsList_DisplayPanel then
            InterfaceOptionsList_DisplayPanel(panel)
        end
    end
end
