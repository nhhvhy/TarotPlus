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
    edition = {negative = false},
    loc_vars = function(self, card)
        return {vars = {G.GAME.probabilities.normal, self.config.chance}}
    end,
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

----------------------------------------------
------------MOD CODE END----------------------