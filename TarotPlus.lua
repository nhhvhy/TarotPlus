--- STEAMODDED HEADER
--- MOD_NAME: Tarot+
--- MOD_ID: tarotplus
--- PREFIX: tarotplus
--- MOD_AUTHOR: [nhhvhy]
--- MOD_DESCRIPTION: more tarot == more better
--- VERSION: 1.0
----------------------------------------------
------------MOD CODE -------------------------

local mod_path = '' .. SMODS.current_mod.path
SMODS.Atlas { key = 'Consumables', path = 'tarot.png', px = 71, py = 95 }

-- !! Doesn't include negative, use only for playing cards !!
PCARD_MODS = {
    'foil', 'holo', 'polychrome',
    'Red', 'Blue', 'Gold', 'Purple',
    'Bonus', 'Mult', 'Wild Card', 'Glass Card',
    'Steel Card', 'Stone Card', 'Gold Card', 'Lucky Card'
}

PCARD_MOD_TYPE = {
    ['foil'] = 'Edition', ['holo'] = 'Edition', ['polychrome'] = 'Edition',
    ['Red'] = 'Seal', ['Blue'] = 'Seal',
    ['Gold'] = 'Seal', ['Purple'] = 'Seal',
    ['Bonus'] = 'Enhancement', ['Mult'] = 'Enhancement',
    ['Wild Card'] = 'Enhancement', ['Glass Card'] = 'Enhancement',
    ['Steel Card'] = 'Enhancement', ['Stone Card'] = 'Enhancement',
    ['Gold Card'] = 'Enhancement', ['Lucky Card'] = 'Enhancement'
}

PCARD_EDITIONS = {
    ['foil'] = {foil = true},
    ['holo'] = {holo = true}, 
    ['polychrome'] = {polychrome = true},
}

PCARD_CENTERS = {
    ["Bonus"] = G.P_CENTERS.m_bonus,
    ["Mult"] = G.P_CENTERS.m_mult,
    ["Wild Card"] = G.P_CENTERS.m_wild,
    ["Glass Card"] = G.P_CENTERS.m_glass,
    ["Steel Card"] = G.P_CENTERS.m_steel,
    ["Stone Card"] = G.P_CENTERS.m_stone,
    ["Gold Card"] = G.P_CENTERS.m_gold,
    ["Lucky Card"] = G.P_CENTERS.m_lucky,
}

-- Returns a random !!playing card!! modification
function RandMod()
    local rand = pseudorandom(pseudoseed('RandMod'))
    rand = math.floor(rand * 15) + 1
    if rand == 16 then
        rand = 15
    end

    return PCARD_MODS[rand]
end

function AddMod(card, mod)
    mod = mod or RandMod()
    if PCARD_MOD_TYPE[mod] == 'Edition' then
        card:set_edition(PCARD_EDITIONS[mod], true)

    elseif PCARD_MOD_TYPE[mod] == 'Seal' then
        card:set_seal(mod, true)

    elseif PCARD_MOD_TYPE[mod] == 'Enhancement' then
        card:set_ability(PCARD_CENTERS[mod], nil, false)
    else
        return false
    end
    return true
end

function EnhanceToCenter(enhance_str)
    for k, v in pairs(PCARD_CENTERS) do
        if k == enhance_str.ability.name then
            return v
        end
    end
    return false
end

-- Fire Tarot
SMODS.Consumable {
    atlas = 'Consumables',
    key = 'fire',
    set = 'Tarot',
    discovered = true,
    pos = { x = 0, y = 0 },
    loc_txt = {
        ['en-us'] = {
            name = 'Fire',
            text = { "{C:mult}+1{} Discard this round" },
        },
    },
    config = { hold = 0 },
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        ease_discard(1)
        if G.shop or G.blind_select then
            G.GAME.round_resets.discards = G.GAME.round_resets.discards + 1
            local rounds = G.GAME.round
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                blocking = false,
                func = function()
                    if rounds == G.GAME.round - 1 and G.STATE == G.STATES.DRAW_TO_HAND then
                        G.GAME.round_resets.discards = G.GAME.round_resets.discards - 1
                        return true
                    end
                end
            }))
        end
    end
}

-- Ice Tarot
SMODS.Consumable {
    atlas = 'Consumables',
    key = 'ice',
    set = 'Tarot',
    discovered = true,
    pos = { x = 0, y = 0 },
    loc_txt = {
        ['en-us'] = {
            name = 'Ice',
            text = { "{C:mult}+1{} Hand this round" },
        },
    },
    config = { hold = 0 },
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        ease_hands_played(1)
        if G.shop or G.blind_select then
            G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
            local rounds = G.GAME.round
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                blocking = false,
                func = function()
                    if rounds == G.GAME.round - 1 and G.STATE == G.STATES.DRAW_TO_HAND then
                        G.GAME.round_resets.hands = G.GAME.round_resets.hands - 1
                        return true
                    end
                end
            }))
        end
    end
}

-- Fate Tarot
SMODS.Consumable {
    atlas = 'Consumables',
    key = 'fate',
    set = 'Tarot',
    discovered = true,
    pos = { x = 0, y = 0 },
    loc_txt = {
        ['en-us'] = {
            name = 'Fate',
            text = { "Duplicates a random",
                     "playing card in deck" },
        },
    },
    config = { },
    can_use = function(self, card)
        return true
    end,
    use = function(self, _card, area, copier)
        G.E_MANAGER:add_event(Event({
            func = function()
                create_playing_card({
                    front = pseudorandom_element(G.P_CARDS), 
                    center = G.P_CENTERS.c_base}, G.deck, nil, nil, {G.C.SECONDARY_SET.Enhanced})
                return true
            end}))
        return true
        end
}

-- Entropy Tarot
SMODS.Consumable {
    atlas = 'Consumables',
    key = 'entropy',
    set = 'Tarot',
    discovered = true,
    pos = { x = 0, y = 0 },
    edition = {negative = false},
    config = {chance = 5},
    loc_vars = function(self, card)
        return {vars = {G.GAME.probabilities.normal, self.config.chance}}
    end,
    loc_txt = {
        ['en-us'] = {
            name = 'Entropy',
            text = {"{C:green}#1# in #2#{} chance to",
                    "create a random",
                    "Spectral card"},
        },
    },
    can_use = function(self, card)
        if card.edition then
            if card.edition.negative then
                return G.consumeables.config.card_limit > #G.consumeables.cards
            end
        else 
            return G.consumeables.config.card_limit >= #G.consumeables.cards
        end
        end,
    use = function(self, _card, area, copier)
        local rand_val = pseudorandom(pseudoseed('entropy'))
        if rand_val <= G.GAME.probabilities.normal / self.config.chance then
            local card = create_card('Spectral', G.consumeables)
            card:add_to_deck()
            G.consumeables:emplace(card)
        else
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                attention_text({
                    text = localize('k_nope_ex'),
                    scale = 1.3, 
                    hold = 1.4,
                    major = _card,
                    backdrop_colour = G.C.SECONDARY_SET.Tarot,
                    align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and 'tm' or 'cm',
                    offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0},
                    silent = true
                    })
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                        play_sound('tarot2', 0.76, 0.4);return true end}))
                    play_sound('tarot2', 1, 0.4)
                    _card:juice_up(0.3, 0.5)
            return true end }))
        end
        return true
        end
}

-- Philosopher Tarot
SMODS.Consumable {
    atlas = 'Consumables',
    key = 'philosopher',
    set = 'Tarot',
    discovered = true,
    pos = { x = 0, y = 0 },
    loc_txt = {
        ['en-us'] = {
            name = 'The Philosopher',
            text = {"Upgrades most",
                    "played hand"}
        },
    },
    can_use = function(self, card)
        return true
        end,

    use = function(self, card, area, copier)
        local _handnames, _played, _order = {"High Card"}, -1, 100
        for k, v in pairs(G.GAME.hands) do
            if v.played > _played then
                _played = v.played
                _handnames = {k}
            elseif v.played == _played then
                table.insert(_handnames, k)
            end
        end

        local _handname = pseudorandom_element(_handnames, pseudoseed('random_poker_hand'))
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(_handname, 'poker_hands'),chips = G.GAME.hands[_handname].chips, mult = G.GAME.hands[_handname].mult, level=G.GAME.hands[_handname].level})
        level_up_hand(card, _handname, false)
        update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
        end
}

-- Nomad Tarot
SMODS.Consumable {
    atlas = 'Consumables',
    key = 'nomad',
    set = 'Tarot',
    discovered = true,
    pos = { x = 0, y = 0 },
    config = {extra = 2},
    loc_vars = function(self, card)
        local unplayed = 0
        for k, v in pairs(G.GAME.hands) do
            if v.played == 0 and v.visible == true then
                unplayed = unplayed + 1
            end
        end
        return {vars = {unplayed*self.config.extra}}
    end,
    loc_txt = {
        ['en-us'] = {
            name = 'The Nomad',
            text = {"Gives {C:money}2${} per",
                    "unplayed poker hand",
                    "{C:inactive}(Currently {C:money}$#1#{C:inactive})"}
        },
    },
    can_use = function(self, card)
        return true
        end,

    use = function(self, card, area, copier)
        local unplayed = 0
        for k, v in pairs(G.GAME.hands) do
            if v.played == 0 and v.visible == true then
                unplayed = unplayed + 1
            end
        end

        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('timpani')
            card:juice_up(0.3, 0.5)
            ease_dollars(unplayed * self.config.extra, true)
            return true end }))
        delay(0.6)
    end
}

-- Mirror Tarot
SMODS.Consumable {
    atlas = 'Consumables',
    key = 'mirror',
    set = 'Tarot',
    discovered = true,
    pos = { x = 0, y = 0 },
    config = {extra = 2},
    loc_vars = function(self, card)
    end,
    loc_txt = {
        ['en-us'] = {
            name = 'The Mirror',
            text = {"Select {C:attention}2{} cards.",
                    "{C:attention}Left{} card gains {C:attention}right{}",
                    "card {C:attention}modifications{}."
                    }
        },
    },
    can_use = function(self, card)
        return #G.hand.highlighted == 2
    end,

    use = function(self, card, area, copier)
        -- Flip Cards
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            return true end }))
        for i=1, #G.hand.highlighted do
            local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
        end
        delay(0.2)

        -- Transfer Card Modifications
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1, func = function()
            if G.hand.highlighted[2].seal then
            G.hand.highlighted[1]:set_seal(G.hand.highlighted[2].seal, true, true)
            end
            if G.hand.highlighted[2].edition then
            G.hand.highlighted[1]:set_edition(G.hand.highlighted[2].edition, true, true)
            end
            if EnhanceToCenter(G.hand.highlighted[2]) then
               G.hand.highlighted[1]:set_ability(EnhanceToCenter(G.hand.highlighted[2]), nil, false)
            end
            return true end }))

        -- Unflip Cards
        for i=1, #G.hand.highlighted do
            local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
        delay(0.5)
    end
}

-- Enigma Tarot
-- TODO: Import card flip animation
SMODS.Consumable {
    atlas = 'Consumables',
    key = 'enigma',
    set = 'Tarot',
    discovered = true,
    pos = { x = 0, y = 0 },
    loc_vars = function(self, card)
    end,
    loc_txt = {
        ['en-us'] = {
            name = 'The Enigma',
            text = {"Adds a random",
                    "modification to",
                    "{C:attention}2{} selected cards"
                    }
        },
    },
    can_use = function(self, card)
        return (0 < #G.hand.highlighted and #G.hand.highlighted <= 2)
    end,

    use = function(self, card, area, copier)
        for i=1,#G.hand.highlighted do
            AddMod(G.hand.highlighted[i])
        end
    end
}

----------------------------------------------
------------MOD CODE END----------------------