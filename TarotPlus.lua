--- STEAMODDED HEADER
--- MOD_NAME: Tarot+
--- MOD_ID: TarotPlus
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
----------------------------------------------
------------MOD CODE END----------------------
