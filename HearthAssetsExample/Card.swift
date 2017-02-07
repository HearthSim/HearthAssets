//
// Created by Benjamin Michotte on 7/02/17.
// Copyright (c) 2017 Benjamin Michotte. All rights reserved.
//

import Foundation

class Card {
    var id = ""
    var collectible = false
    var cost = 0
    var faction: Faction = .invalid
    var flavor = ""
    var health = 0
    var attack = 0
    var overload = 0
    var durability = 0
    var name = "unknown"
    var enName = ""
    var playerClass: CardClass = .neutral
    var rarity: Rarity = .free
    var set: CardSet?
    var text = ""
    var race: Race = .invalid
    var type: CardType = .invalid
    var isStandard = false
    var artist = ""
}

enum CardType: Int {
    case invalid = 0,
         game = 1,
         player = 2,
         hero = 3,
         minion = 4,
         spell = 5,
         enchantment = 6,
         weapon = 7,
         item = 8,
         token = 9,
         hero_power = 10

    init?(rawString: String) {
        for _enum in CardType.allValues() {
            if "\(_enum)" == rawString.lowercased() {
                self = _enum
                return
            }
        }
        if let value = Int(rawString), let _enum = CardType(rawValue: value) {
            self = _enum
            return
        }
        self = .invalid
    }

    static func allValues() -> [CardType] {
        return [.invalid, .game, .player, .hero, .minion, .spell,
                .enchantment, .weapon, .item, .token, .hero_power]
    }
}

enum CardSet: String {
    case all // fake one
    case core, expert1, naxx, gvg, brm,
         tgt, loe, promo, reward, hero_skins,
         og, kara, gangs

    static func allValues() -> [CardSet] {
        return [.core, .expert1, .naxx, .gvg, .brm,
                .tgt, .loe, .promo, .reward, .hero_skins,
                .og, .kara, .gangs]
    }

    static func deckManagerValidCardSets() -> [CardSet] {
        return [.all, .expert1, .naxx, .gvg, .brm, .tgt, .loe, .og, .kara, .gangs]
    }

    static func wildSets() -> [CardSet] {
        return [.naxx, .gvg]
    }
}

enum Faction: String {
    case invalid, horde, alliance, neutral
}

enum CardClass: String {
    case neutral,
         druid,
         hunter,
         mage,
         paladin,
         priest,
         rogue,
         shaman,
         warlock,
         warrior
}

enum Rarity: String {
    case free,
         common,
         rare,
         epic,
         legendary,
         golden

    static func allValues() -> [Rarity] {
        return [.free, .common, .rare, .epic, .legendary]
    }
}

enum Race: String {
    case invalid,
         bloodelf,
         draenei,
         dwarf,
         gnome,
         goblin,
         human,
         nightelf,
         orc,
         tauren,
         troll,
         undead,
         worgen,
         goblin2,
         murloc,
         demon,
         scourge,
         mechanical,
         elemental,
         ogre,
         beast,
         totem,
         nerubian,
         pirate,
         dragon
}
