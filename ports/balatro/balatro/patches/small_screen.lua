-- PortMaster handheld layout for Balatro.
--
-- This file is injected into the user's licensed Balatro archive by the
-- Balatro launcher, and only when the launcher's display setup was
-- answered with the small screen layout -- choosing the original one builds
-- without it, which is the whole of what that answer does. Its siblings
-- options.lua, controls.lua and perf.lua are injected either way: nothing in
-- them depends on the room the game is drawn into.
--
-- It deliberately overrides only presentation functions; game rules and saves are
-- left untouched. Every measurement below is derived from the panel the game is
-- actually running on, so one patched archive is portable across devices.

-- Within the supported 1:1 to 2.4:1 range, the room is given the panel's own
-- aspect ratio and the desktop border is dropped, so the logical playfield covers
-- every pixel instead of sitting inside letterbox margins. Stock Balatro's
-- 20x11.5 room plus its border is a 22x12.9 logical window; on a 1024x768 panel
-- its width limits rendering to about 46.5 pixels per tile. The 4:3 room below
-- maps to 60 pixels per tile, about 29% larger.
--
-- The room is then grown from a 4:3 reference until it satisfies both of that
-- reference's dimensions, so one build serves every panel: 4:3 keeps exactly the
-- proportions everything here is tuned against, wider panels gain width at the
-- same height, and squarer ones gain height at the same width.
local REFERENCE_W = 17.0667
local REFERENCE_H = 12.8

local function display_ratio()
    local w, h
    if love.graphics and love.graphics.getDimensions then
        w, h = love.graphics.getDimensions()
    end
    if not (w and h and w > 0 and h > 0) and love.window then
        local ok, dw, dh = pcall(love.window.getDesktopDimensions)
        if ok and dw and dh and dh > 0 then w, h = dw, dh end
    end
    if not (w and h and w > 0 and h > 0) then return REFERENCE_W/REFERENCE_H end
    -- Portrait panels are clamped to square: love.resize refuses to scale a room
    -- taller than it is wide, so anything past that would letterbox regardless.
    return math.min(math.max(w/h, 1.0), 2.4)
end

local RATIO = display_ratio()
local ROOM_W = math.max(REFERENCE_W, REFERENCE_H*RATIO)
local ROOM_H = ROOM_W/RATIO
-- Every edge keeps this gap, so nothing is flush against the bezel.
local SAFE_MARGIN = 0.2
-- CardArea hangs its "cards left" counter below itself, and the play/discard
-- buttons hang below the hand. The desktop room padding used to catch both; this
-- layout has no padding, so the bottom row of areas is inset by that much more.
local BOTTOM_INSET = SAFE_MARGIN + 0.42
local HUD_ROW_H = 1.72
local OWNED_CARDS_Y = 2.18
-- Below the owned cards and the "3/5" counters that hang under them.
local RUN_OVERLAY_Y = 5.02
local OWNED_JOKER_SCALE = 0.95
local HAND_W = 6.8*G.CARD_W
-- Measured height of a blind-selection column: its cards, tag, and skip button.
local BLIND_SELECT_H = 7.7

-- Status bar cells are proportional to the room so the bar reaches both margins.
-- The 0.9 covers the root, row, and inter-cell padding the layout engine adds.
local HUD_INNER_W = ROOM_W - SAFE_MARGIN*2 - 0.9
local HUD_BLIND_W = HUD_INNER_W*0.29
local HUD_SCORE_W = HUD_INNER_W*0.165
local HUD_HAND_W = HUD_INNER_W*0.315
local HUD_META_W = HUD_INNER_W*0.23

-- Sizes the bar's readouts are pinned to. Each row is then built a little taller
-- than its capped text, so a value that rescales itself never resizes its row.
local SCORE_SCALE = 0.8
local SCORE_TEXT_W = HUD_SCORE_W - 0.26
local TARGET_SCALE = 0.42
-- The hand readout draws itself into fixed boxes (see FixedText), so these are
-- the sizes of those boxes rather than caps a measured layout has to respect.
local HAND_TEXT_SCALE = 0.48
-- The level rides beside the name at a fraction of its size.
local HAND_LEVEL_MULT = 0.72
local HAND_NUM_SCALE = 0.84
local HAND_NUM_BOX_W = 2.0
local HAND_BOX_PAD = 0.06
local DOLLARS_SCALE = 0.62
local DOLLARS_W = 1.24
local BLIND_NAME_SCALE = 0.5
local BLIND_NAME_W = HUD_BLIND_W - 1.05

G.F_SMALL_SCREEN_UI = true
G.TILE_W = ROOM_W
G.TILE_H = ROOM_H

-- Game:init_window reserves a one tile horizontal and 0.7 tile vertical border
-- around the room, which on a handheld is only ever letterboxing. Rebuild the
-- window transform without it; love.resize then maps the room onto the whole
-- display because the room and the panel share an aspect ratio.
local original_init_window = Game.init_window
function Game:init_window(...)
    local windows_runner = os.getenv('BALATRO_PM_WINDOWS_WINDOWED') == '1'
    if windows_runner then
        self.SETTINGS.WINDOW.screenmode = 'Windowed'
    end
    local result = original_init_window(self, ...)
    self.ROOM_PADDING_W = 0
    self.ROOM_PADDING_H = 0
    self.WINDOWTRANS.w = self.TILE_W
    self.WINDOWTRANS.h = self.TILE_H
    self.window_prev.w = self.WINDOWTRANS.w*self.TILESIZE*self.TILESCALE
    self.window_prev.h = self.WINDOWTRANS.h*self.TILESIZE*self.TILESCALE
    self.window_prev.orig_ratio = self.WINDOWTRANS.w/self.WINDOWTRANS.h
    if windows_runner then
        love.window.updateMode(
            tonumber(os.getenv('BALATRO_PM_WINDOWS_WIDTH')) or 1024,
            tonumber(os.getenv('BALATRO_PM_WINDOWS_HEIGHT')) or 768,
            {
                fullscreen = false,
                resizable = true,
                vsync = self.SETTINGS.WINDOW.vsync or 1,
                display = self.SETTINGS.WINDOW.selected_display or 1,
            }
        )
    end
    return result
end

-- Text is the one thing smoothing alone does not rescue, and not for want of
-- resolution -- it has far more than the panel can show. Every font is
-- rasterized at ten tiles, 200 pixels a glyph, and then drawn at
-- FONTSCALE/TILESIZE, which on this layout is about one tile of height per unit
-- of text scale. A 480p panel puts 37.5 pixels in a tile, so ordinary label text
-- lands between 11 and 30 pixels: a 200 pixel glyph squeezed into fifteen or so.
-- Fonts carry no mipmaps, so each pixel is a two-by-two tap taken out of a glyph
-- being minified seven to eighteen times, and undersampling at that ratio is
-- what breaks up thin strokes and makes the letters look ragged.
--
-- So rasterize nearer the size they are actually drawn at. At five tiles the
-- minification halves everywhere and still never turns into magnification: the
-- largest text this layout draws is around 1.5 tiles, which is 90 pixels on a
-- 768p panel against a 100 pixel glyph. The glyph atlas also costs a quarter of
-- what it did.
--
-- Layout is untouched. FONTSCALE converts glyph pixels to tiles and TEXT_OFFSET
-- is measured in glyph pixels, so both are compensated by the same factor the
-- glyphs shrank by -- render_scale*FONTSCALE, which is what sets the on-screen
-- size, comes out unchanged.
--
-- Lower this for sharper small text at the cost of softening the largest; 10 is
-- what the game ships.
local FONT_RASTER_TILES = 5

local function retune_fonts()
    if not G.FONTS then return end
    local target = G.TILESIZE*FONT_RASTER_TILES
    for _, font in ipairs(G.FONTS) do
        -- Only ever downward: a font already rasterized below the target is
        -- being sampled well enough, and rebuilding it larger would undo that.
        if font.FONT and font.render_scale and font.render_scale > target and
           font.file and love.filesystem.getInfo(font.file) then
            local ok, rebuilt = pcall(love.graphics.newFont, font.file, target)
            if ok and rebuilt then
                local factor = font.render_scale/target
                font.FONT = rebuilt
                font.render_scale = target
                font.FONTSCALE = font.FONTSCALE*factor
                font.TEXT_OFFSET = {x = font.TEXT_OFFSET.x/factor,
                                    y = font.TEXT_OFFSET.y/factor}
                font.GLYPH_PX_SCALE = factor
            end
        end
    end
end

-- set_language rebuilds the whole table from the stock sizes, so the retune has
-- to follow it rather than happen once.
local original_set_language = Game.set_language
function Game:set_language(...)
    local result = original_set_language(self, ...)
    retune_fonts()
    return result
end

-- Layout is untouched only for the numbers the retune actually compensates.
-- DynaText's config mixes two kinds: scale multiplies a measured glyph width, so
-- the smaller raster and the larger FONTSCALE cancel; spacing, x_offset and
-- y_offset are constants in the font's own glyph pixels, and FONTSCALE scales
-- them with nothing to cancel against. Every one of them therefore grows by the
-- factor the glyphs shrank by.
--
-- The round evaluation panel is where that becomes visible rather than merely
-- loose. Its dotted divider is 38 dots at 13.5 spacing, which measures 11.5
-- tiles at the stock raster -- just inside the panel's width -- and 18.5 tiles
-- after the retune. The row is what the panel is then sized to, so the whole
-- cash-out screen is drawn wider than the room and runs off the display.
--
-- So divide the factor back out where those constants enter, and the retune
-- stays invisible to layout. Recorded on the config table because a definition
-- built from a table that outlives its first DynaText would otherwise be
-- divided again on every rebuild.
local original_dynatext_init = DynaText.init
function DynaText:init(config)
    config = config or {}
    local font = config.font or G.LANG.font
    local factor = font and font.GLYPH_PX_SCALE
    if factor and not config.small_screen_glyph_px then
        config.small_screen_glyph_px = true
        if config.spacing then config.spacing = config.spacing/factor end
        if config.x_offset then config.x_offset = config.x_offset/factor end
        if config.y_offset then config.y_offset = config.y_offset/factor end
    end
    return original_dynatext_init(self, config)
end

-- Once for what already exists: globals.lua builds G, and so loads every font
-- before this file is read. They are rebuilt later, in Game:set_language, and
-- are caught by the wrapper above.
retune_fonts()

-- Use the Brick's vertical pixels instead of preserving a desktop-width playfield.
-- Gameplay cards retain their normal dimensions; only the persistent owned-Joker
-- strip is reduced, without changing its capacity or any card behaviour.
local function resize_owned_joker(card)
    if not card then return end
    local target_w = G.CARD_W*OWNED_JOKER_SCALE
    local target_h = G.CARD_H*OWNED_JOKER_SCALE
    if math.abs(card.T.w-target_w) > 0.001 or
       math.abs(card.T.h-target_h) > 0.001 then
        card:hard_set_T(nil, nil, target_w, target_h)
    end
end

local function compact_owned_jokers()
    if not G.jokers then return end
    G.jokers.T.w = 4.9*G.CARD_W*OWNED_JOKER_SCALE
    G.jokers.T.h = 0.95*G.CARD_H*OWNED_JOKER_SCALE
    G.jokers.card_w = G.CARD_W*OWNED_JOKER_SCALE
    for _, card in ipairs(G.jokers.cards) do resize_owned_joker(card) end
    G.jokers:align_cards()
    G.jokers:hard_set_cards()
end

-- The hand is the one area with room to spare, and its cards are the ones
-- actually being read. align_cards centres a card on the area's own middle, so
-- growing the area's height alongside the card leaves the bottom edge within a
-- few hundredths of where it was: the whole increase is spent upward, into the
-- gap the play area sits in.
--
-- The ceiling is that gap. set_screen_positions parks the play area 3.6 above
-- the hand, and it has to stay clear of the owned-card strip at RUN_OVERLAY_Y,
-- which puts the limit around 1.36 on the 4:3 room -- the squattest this
-- layout supports, and so the one that decides it. Jokers and consumables keep
-- their own sizes; the strip they live in has no room to give.
local HAND_CARD_SCALE = 1.25

-- Except while a booster pack is open. That state lays the hand out at
-- 1.8 card heights above the area instead of inside it, to raise the cards
-- clear for selection, and at normal size that already reaches the underside of
-- the owned-card strip. Scaling the cards scales the offset with them, so this
-- one state keeps the size it was tuned for.
local function hand_card_scale()
    if G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or
       G.STATE == G.STATES.PLANET_PACK then
        return 1
    end
    return HAND_CARD_SCALE
end

local function resize_card(card, scale)
    if not card then return end
    local target_w = G.CARD_W*scale
    local target_h = G.CARD_H*scale
    if math.abs(card.T.w-target_w) > 0.001 or
       math.abs(card.T.h-target_h) > 0.001 then
        card:hard_set_T(nil, nil, target_w, target_h)
    end
end

-- A card is only enlarged while it is in the hand. Playing, discarding or
-- returning it to the deck puts it back first, so every other area keeps the
-- dimensions it was laid out for -- the play area in particular is only 5.3
-- cards wide and would start overlapping the scoring row.
local function restore_played_card(card)
    if not card or not card.small_screen_hand_sized then return end
    card.small_screen_hand_sized = nil
    resize_card(card, 1)
end

local function resize_hand_card(card, scale)
    if not card then return end
    resize_card(card, scale)
    card.small_screen_hand_sized = (scale ~= 1) or nil
end

-- Cheap enough to check every frame, and it has to be: the scale depends on the
-- state, and cards arrive in the hand throughout a round.
local hand_scale_applied
local function apply_hand_card_scale()
    if not G.hand then return end
    local scale = hand_card_scale()
    if hand_scale_applied ~= scale then
        hand_scale_applied = scale
        G.hand.T.h = 0.95*G.CARD_H*scale
        G.hand.card_w = G.CARD_W*scale
    end
    for _, card in ipairs(G.hand.cards) do resize_hand_card(card, scale) end
end

-- Newly purchased Jokers enter the existing area after start_run has completed.
local original_cardarea_emplace = CardArea.emplace
function CardArea:emplace(card, ...)
    if self == G.jokers then
        resize_owned_joker(card)
    elseif self == G.hand then
        resize_hand_card(card, hand_card_scale())
    else
        restore_played_card(card)
    end
    return original_cardarea_emplace(self, card, ...)
end

-- CardArea:move re-drives the hand to G.TILE_H minus its height on every frame,
-- which parks it flush against the bottom edge. Show that one call a shorter room
-- so the hand keeps the same border as everything else and its card counter, and
-- the play/discard/sort buttons that hang beneath it, stay on screen.
local original_cardarea_move = CardArea.move
function CardArea:move(dt)
    if self == G.hand then
        -- Before the stock move reads T.h to decide where the hand sits.
        apply_hand_card_scale()
        local room_h = G.TILE_H
        G.TILE_H = room_h - BOTTOM_INSET
        original_cardarea_move(self, dt)
        G.TILE_H = room_h
        return
    end
    return original_cardarea_move(self, dt)
end

-- Every visible CardArea lazily builds a box holding a translucent black plate
-- the size of itself, with its "5/5" counter underneath. The counter is worth
-- keeping and the plate is not, so hide just that row the first time the box
-- exists -- hiding it rather than clearing its colour also drops the fill, since
-- a fully transparent node is still drawn. The shop's voucher slot is left alone:
-- its plate is nil-coloured already and carries the restock message as a child.
local original_cardarea_draw = CardArea.draw
function CardArea:draw(...)
    local result = original_cardarea_draw(self, ...)
    local box = self.children.area_uibox
    if box and not box.small_screen_plate_hidden then
        box.small_screen_plate_hidden = true
        local plate = box.UIRoot and box.UIRoot.children and box.UIRoot.children[1]
        if plate and plate.config and plate.config.colour then
            plate.states.visible = false
        end
    end
    return result
end

-- The desktop main menu places its four large buttons beside a separate
-- language/social column. Together their reserved widths sit almost exactly on
-- the edge of a 4:3 handheld room, and localized labels can push them past it.
-- Compact only this menu: preserve the button arrangement and hit targets while
-- reducing label text, wide reservations, and generous desktop padding.
local original_main_menu_buttons = create_UIBox_main_menu_buttons
local function compact_main_menu_node(node)
    if not node then return end
    local config = node.config
    if config then
        if config.scale then config.scale = config.scale*0.78 end
        if config.minw and config.minw >= 2 then
            config.minw = config.minw*0.86
        end
        if config.maxw and config.maxw >= 2 then
            config.maxw = config.maxw*0.86
        end
        if config.padding and config.padding >= 0.1 then
            config.padding = config.padding*0.8
        end
    end
    if node.nodes then
        for _, child in pairs(node.nodes) do
            compact_main_menu_node(child)
        end
    end
end

function create_UIBox_main_menu_buttons(...)
    local result = original_main_menu_buttons(...)
    compact_main_menu_node(result)
    return result
end

function set_screen_positions()
    if G.STAGE == G.STAGES.RUN then
        compact_owned_jokers()
        -- Sets the hand's height, which every line below is measured against.
        apply_hand_card_scale()

        G.deck.T.x = ROOM_W - G.deck.T.w - SAFE_MARGIN
        G.deck.T.y = ROOM_H - G.deck.T.h - BOTTOM_INSET

        -- The reclaimed width goes to the hand, which is the only area whose
        -- cards were overlapping by more than half a card at eight cards. The
        -- area still stops clear of the deck.
        G.hand.T.w = HAND_W
        G.hand.T.x = SAFE_MARGIN +
            math.max(0, (G.deck.T.x - 0.15 - SAFE_MARGIN - G.hand.T.w)/2)
        -- CardArea:move drives the hand to exactly this line, so start it there.
        G.hand.T.y = ROOM_H - G.hand.T.h - BOTTOM_INSET

        G.play.T.x = (ROOM_W - G.play.T.w)/2
        -- 3.6 above the hand on a 4:3 room, but centred in the free band on a
        -- squarer one, where holding that gap would leave a hole in the middle.
        G.play.T.y = math.min(G.hand.T.y - 3.6,
            (RUN_OVERLAY_Y + G.hand.T.y - G.play.T.h)/2)

        G.jokers.T.x = SAFE_MARGIN
        G.jokers.T.y = OWNED_CARDS_Y

        G.consumeables.T.x = ROOM_W - G.consumeables.T.w - SAFE_MARGIN
        G.consumeables.T.y = OWNED_CARDS_Y

        G.discard.T.x = math.min(G.play.T.x + G.play.T.w + 0.15,
            ROOM_W - G.discard.T.w - SAFE_MARGIN)
        G.discard.T.y = G.play.T.y

        G.hand:hard_set_VT()
        G.play:hard_set_VT()
        G.jokers:hard_set_VT()
        G.consumeables:hard_set_VT()
        G.deck:hard_set_VT()
        G.discard:hard_set_VT()
        G.hand:align_cards()
    elseif G.STAGE == G.STAGES.MAIN_MENU and G.title_top then
        G.title_top.T.x = G.TILE_W/2 - G.title_top.T.w/2
        G.title_top.T.y = G.TILE_H/2 - G.title_top.T.h/2 -
            ((G.STATE == G.STATES.DEMO_CTA and 2) or
             (G.debug_splash_size_toggle and 2 or 1.2))
        G.title_top:hard_set_VT()
    end
end

-- Stock tutorial steps are attached to the desktop sidebar and sometimes place
-- Jimbo beyond the left or top edge. Keep the narration in a consistent safe
-- region while retaining each step's highlights, input listener, and snap target.
local original_tutorial_info = tutorial_info

local function append_unique(list, node)
    if not node then return end
    for _, existing in ipairs(list) do
        if existing == node then return end
    end
    list[#list+1] = node
end

local function append_shop_highlights(list)
    append_unique(list, G.shop)
    append_unique(list, G.SHOP_SIGN)
    append_unique(list, G.shop_jokers)
    append_unique(list, G.shop_vouchers)
    append_unique(list, G.shop_booster)
    return list
end

function tutorial_info(args)
    -- Recreate the stock tutorial shade with a real controller shortcut for Skip.
    -- Start is otherwise unused while a tutorial step owns input.
    if not G.OVERLAY_TUTORIAL then
        local overlay_colour = {0.32,0.36,0.41,0}
        ease_value(overlay_colour, 4, 0.6, nil, 'REAL', true, 0.4)
        G.OVERLAY_TUTORIAL = UIBox{
            definition={n=G.UIT.ROOT, config={align='cm', padding=32.05,
                r=0.1, colour=overlay_colour, emboss=0.05}, nodes={
                {n=G.UIT.R, config={align='tr', minh=G.ROOM.T.h,
                    minw=G.ROOM.T.w}, nodes={
                    UIBox_button{
                        id='small_screen_skip_tutorial',
                        label={localize('b_skip')..' >'},
                        button='skip_tutorial_section', minw=1.3, scale=0.45,
                        colour=G.C.JOKER_GREY,
                        focus_args={button='start', set_button_pip=true,
                            orientation='tr'}
                    }
                }}
            }},
            config={align='cm', offset={x=0,y=3.2},
                major=G.ROOM_ATTACH, bond='Weak'}
        }
    end

    args.attach = {
        major=G.ROOM_ATTACH,
        type='cm',
        offset={x=0, y=1.05},
        bond='Weak'
    }
    args.pos = {x=G.TILE_W/2, y=G.TILE_H/2 + 1.05}
    args.align = args.align or 'tm'

    -- The desktop tutorial only redraws one shop card above its dark shade.
    -- On the Brick that reads as an absent shop, so keep the complete storefront
    -- visible and interactive throughout shop tutorial steps.
    if args.text_key and string.sub(args.text_key, 1, 2) == 's_' then
        local original_highlight = args.highlight
        args.highlight = function()
            local list = type(original_highlight) == 'function' and
                original_highlight() or original_highlight or {}
            return append_shop_highlights(list)
        end
    end
    return original_tutorial_info(args)
end

local original_add_speech_bubble = Card_Character.add_speech_bubble
function Card_Character:add_speech_bubble(...)
    local result = original_add_speech_bubble(self, ...)
    if self.children.speech_bubble then
        self.children.speech_bubble:set_alignment({lr_clamp=true})
    end
    return result
end

local function dyn(ref_table, ref_value, colour, scale, id, extra)
    local config = {
        string = {{ref_table = ref_table, ref_value = ref_value}},
        colours = {colour},
        font = G.LANGUAGES['en-us'].font,
        shadow = true,
        silent = true,
        scale = scale
    }
    local node_config = {id=id}
    if extra then
        for k, v in pairs(extra) do
            if k == 'prefix' then
                config.string[1].prefix = v
            elseif k == 'func' then
                node_config.func = v
            else
                config[k] = v
            end
        end
    end
    node_config.object = DynaText(config)
    return {n=G.UIT.O, config=node_config}
end

-- Largest scale at which a string still fits a given width, mirroring the
-- measurement engine/ui.lua does when it lays a text node out. Relying on the
-- node's own maxw is not enough here: that path rewrites the child's scale in
-- place and only runs when the box is recalculated, while these readouts have
-- funcs that reset their scale on every value change.
local function fit_scale(text, max_w, font, cap)
    font = font or G.LANG.font
    local width = font.FONT:getWidth(text or '')*(font.squish or 1)*
        font.FONTSCALE/G.TILESIZE
    if width <= 0 then return cap end
    return math.min(cap, max_w/width)
end

-- Text height, by the same measurement, is FONT:getHeight()*scale*FONTSCALE*
-- TEXT_HEIGHT_SCALE/TILESIZE. Rows are given a minh above whatever their capped
-- text can reach, so a readout that rescales itself never resizes its row.
local function text_height(scale, font)
    font = font or G.LANG.font
    return font.FONT:getHeight()*scale*font.FONTSCALE*
        font.TEXT_HEIGHT_SCALE/G.TILESIZE
end

-- Hold a DynaText at a fixed size instead of the size the game picks from the
-- value's magnitude or the name's length. Shrinking below the cap to fit the
-- width is fine -- the row is pinned taller than the cap, so a smaller readout
-- simply sits centred in it.
-- A readout that owns its own box.
--
-- Everything in this bar was laid out by measuring text, and that is what kept
-- moving it. A DynaText measures itself; the game rescales it from the value's
-- magnitude; its node takes that size; every container above it follows. Capping
-- the scales, declaring node heights and budgeting the padding each narrowed
-- that path without closing it -- the layout still had a route from the string
-- to the height of the bar.
--
-- These nodes declare a fixed w and h, which calculate_xywh uses instead of
-- measuring anything at all, and the object below draws its own string inside
-- that box: centred, and scaled down only when it would otherwise run past the
-- edge. There is no longer a path from any string to any dimension.
local FixedText = Moveable:extend()

function FixedText:init(W, H, args)
    Moveable.init(self, 0, 0, W, H)
    self.states.collide.can = false
    self.states.hover.can = false
    self.states.click.can = false
    self.states.drag.can = false
    self.font = args.font or G.LANG.font
    self.colour = args.colour or G.C.UI.TEXT_LIGHT
    self.max_scale = args.scale or 0.5
    self.gap = args.gap or 0
    self.parts = {}
    if getmetatable(self) == FixedText then
        table.insert(G.I.MOVEABLE, self)
    end
end

-- Parts are drawn as one line, so a name and its level stay centred together
-- rather than each being centred in a slot of its own.
function FixedText:set_parts(parts)
    for i = 1, #parts do
        local part = self.parts[i]
        if not part then
            part = {text = false, drawable = love.graphics.newText(self.font.FONT, '')}
            self.parts[i] = part
        end
        local text = parts[i].text or ''
        if part.text ~= text then
            part.text = text
            part.drawable:set(text)
            part.width = self.font.FONT:getWidth(text)
        end
        part.colour = parts[i].colour or self.colour
        part.mult = parts[i].mult or 1
    end
    for i = #self.parts, #parts + 1, -1 do self.parts[i] = nil end
end

function FixedText:set_text(text, colour)
    self:set_parts({{text = text, colour = colour}})
end

function FixedText:draw()
    if not self.states.visible then return end
    local font = self.font
    -- Pixels to tiles at scale 1, the same conversion engine/ui.lua uses when it
    -- lays out and draws a text node.
    local unit = font.FONTSCALE/G.TILESIZE
    local natural, shown = 0, 0
    for _, part in ipairs(self.parts) do
        if part.width and part.width > 0 then
            natural = natural + part.width*part.mult
            shown = shown + 1
        end
    end
    if natural <= 0 then return end
    local gaps = math.max(0, shown - 1)*self.gap
    local width = natural*unit
    local scale = math.min(self.max_scale, (self.T.w - gaps)/width)
    local x = 0.5*(self.T.w - width*scale - gaps)

    prep_draw(self, 1)
    for _, part in ipairs(self.parts) do
        if part.width and part.width > 0 then
            -- Each part sits centred on the box's own middle, so a smaller
            -- suffix rides with the text it follows rather than its top edge.
            local part_scale = scale*part.mult
            local height = font.FONT:getHeight()*part_scale*unit*
                font.TEXT_HEIGHT_SCALE
            love.graphics.setColor(part.colour)
            love.graphics.draw(part.drawable,
                x + font.TEXT_OFFSET.x*part_scale*unit,
                0.5*(self.T.h - height) + font.TEXT_OFFSET.y*part_scale*unit,
                0, part_scale*(font.squish or 1)*unit, part_scale*unit)
            x = x + part.width*unit*part_scale + self.gap
        end
    end
    love.graphics.pop()
end

-- The game pulses, quivers and refreshes these objects while a hand is scored.
-- Keep that surface; juice_up already carries the pop, and the rest described
-- per-letter animation that no longer exists here.
function FixedText:pulse(amount)
    self:juice_up(0.4*(amount or 0.2), 0.05)
end
function FixedText:set_quiver() end
function FixedText:update_text() end
function FixedText:align_letters() end

local function pin_dyna_scale(e, text, max_w, cap)
    local obj = e.config.object
    if not obj then return end
    if e.small_screen_fit_text == text and
       e.small_screen_fit_width == max_w and
       e.small_screen_fit_cap == cap then return end
    e.small_screen_fit_text = text
    e.small_screen_fit_width = max_w
    e.small_screen_fit_cap = cap
    local target = fit_scale(text, max_w, obj.font, cap)
    if math.abs((obj.scale or 0) - target) > 0.001 then
        obj.scale = target
        obj:update_text()
    end
end

local function label(text, scale, colour, id)
    return {n=G.UIT.T, config={id=id, text=text, scale=scale,
        colour=colour or G.C.UI.TEXT_LIGHT, shadow=true}}
end

local function gap(width, height)
    return {n=G.UIT.C, config={minw=width or 0.08, minh=height or 0.08}, nodes={}}
end

-- The desktop shop is a two-row panel next to a 4.7x3.1 animated sign that alone
-- is taller than the band this layout has to spend. Keep the game's familiar
-- arrangement -- controls beside the card row, voucher and packs beneath -- drop
-- the sign, and size the panel to fill the band under the owned-card strip.
--
--   +-------------------------------------------+
--   | [ Next  ] | [ card  card  card  card    ] |
--   | [ Reroll] |                               |
--   | [ Ante N voucher ] | [ pack      pack   ] |
--   +-------------------------------------------+
--
-- Every plate holds only R children: the layout engine measures a container that
-- mixes rows and bare objects as if they sat side by side, which is what made the
-- old voucher plate too wide and too short for its contents.
function G.UIDEF.shop()
    local slots = G.GAME.shop.joker_max

    G.shop_jokers = CardArea(0, ROOM_H + 5,
        slots*1.05*G.CARD_W, 1.05*G.CARD_H,
        {card_limit=slots, type='shop', highlight_limit=1})
    G.shop_vouchers = CardArea(0, ROOM_H + 5,
        2.1*G.CARD_W, 1.05*G.CARD_H,
        {card_limit=1, type='shop', highlight_limit=1})
    -- 2.55 card widths leave the two packs just clear of each other.
    G.shop_booster = CardArea(0, ROOM_H + 5,
        2.55*G.CARD_W, 1.15*G.CARD_H,
        {card_limit=2, type='shop', highlight_limit=1,
            card_w=1.27*G.CARD_W})

    -- Keep the global expected by the tutorial, but omit the decorative sign.
    G.SHOP_SIGN = UIBox{
        definition={n=G.UIT.ROOT, config={align='cm', minw=0.01,
            minh=0.01, colour=G.C.CLEAR}, nodes={}},
        config={align='tli', offset={x=-20,y=-20}, major=G.ROOM_ATTACH}
    }
    G.SHOP_SIGN.states.visible = false

    local function plate(width, nodes)
        return {n=G.UIT.C, config={align='cm', padding=0.15, minw=width,
            r=0.15, colour=G.C.L_BLACK, emboss=0.05}, nodes=nodes}
    end

    local function area_row(area)
        return {n=G.UIT.R, config={align='cm'}, nodes={
            {n=G.UIT.O, config={object=area}}
        }}
    end

    local controls = {n=G.UIT.C, config={align='cm', padding=0.08}, nodes={
        {n=G.UIT.R, config={id='next_round_button', align='cm', minw=3.0,
            minh=1.45, padding=0.06, r=0.14, colour=G.C.RED,
            one_press=true, button='toggle_shop', hover=true, shadow=true}, nodes={
            {n=G.UIT.R, config={align='cm', padding=0.04,
                focus_args={button='y', orientation='cr'}, func='set_button_pip'}, nodes={
                {n=G.UIT.R, config={align='cm', maxw=2.5}, nodes={
                    label(localize('b_next_round_1'), 0.42)
                }},
                {n=G.UIT.R, config={align='cm', maxw=2.5}, nodes={
                    label(localize('b_next_round_2'), 0.42)
                }}
            }}
        }},
        {n=G.UIT.R, config={align='cm', minw=3.0, minh=1.5,
            padding=0.06, r=0.14, colour=G.C.GREEN,
            button='reroll_shop', func='can_reroll', hover=true, shadow=true}, nodes={
            {n=G.UIT.R, config={align='cm', padding=0.04,
                focus_args={button='x', orientation='cr'}, func='set_button_pip'}, nodes={
                {n=G.UIT.R, config={align='cm', maxw=2.5}, nodes={
                    label(localize('k_reroll'), 0.42)
                }},
                {n=G.UIT.R, config={align='cm'}, nodes={
                    label(localize('$'), 0.5),
                    {n=G.UIT.T, config={ref_table=G.GAME.current_round,
                        ref_value='reroll_cost', scale=0.6, colour=G.C.WHITE,
                        shadow=true}}
                }}
            }}
        }}
    }}

    -- A shelf that stays wider than its cards reads as a shop with room on it,
    -- and keeps the panel steady when a Voucher raises the slot count.
    local card_shelf = plate(math.max(7.9, G.shop_jokers.T.w + 1.4), {
        area_row(G.shop_jokers)
    })

    local voucher = plate(nil, {
        {n=G.UIT.R, config={align='cm', maxw=G.shop_vouchers.T.w}, nodes={
            {n=G.UIT.T, config={text=localize{type='variable',
                key='ante_x_voucher', vars={G.GAME.round_resets.ante}},
                scale=0.3, colour=G.C.UI.TEXT_LIGHT, shadow=true}}
        }},
        area_row(G.shop_vouchers)
    })

    local boosters = plate(nil, {area_row(G.shop_booster)})

    -- Only maxh: when a node carries both, an overflow in either direction is
    -- resolved against maxw, which would scale a panel narrower than the room
    -- up rather than down. maxh alone shrinks the panel to fit the band.
    return {n=G.UIT.ROOT, config={align='cm', padding=0.03,
        maxh=ROOM_H-RUN_OVERLAY_Y-SAFE_MARGIN,
        colour=G.C.CLEAR}, nodes={
        {n=G.UIT.R, config={align='cm', padding=0.08, r=0.16,
            colour=G.C.DYN_UI.BOSS_MAIN, emboss=0.05}, nodes={
            {n=G.UIT.R, config={align='cm', padding=0.06}, nodes={
                controls, card_shelf
            }},
            {n=G.UIT.R, config={align='cm', padding=0.06}, nodes={
                voucher, boosters
            }}
        }}
    }}
end

-- Set when the shop's slot count changes, cleared once the panel has been laid
-- out again from where it actually sits. Read by Game:update_shop below.
local shop_needs_relayout = false

-- Overstock and Overstock Plus are the only things that change the number of
-- shop slots, and change_shop_size does it by widening the card area in place
-- and calling G.shop:recalculate().
--
-- calculate_xywh writes absolute room coordinates into every element from the
-- box's position at that moment, and the shop is redeemed from while the panel
-- is still sliding in -- the entrance runs from below the room up to its resting
-- place. So the panel gets rebuilt around a position it is only passing through,
-- and the elements are left where it was rather than where it ends up. On this
-- layout that strands them below the room: plates, both buttons, everything but
-- the cards, which are drawn from G.I.CARD independently of the panel.
--
-- The buttons stop responding for the same reason rather than a second one.
-- Controller:process_registry only dispatches a registered button while its node
-- is inside the room, so a button sitting below it silently swallows the press
-- and the shop cannot be left.
--
-- Nothing is wrong with the layout itself, only with when it is measured. Defer
-- it: Game:update_shop pins the panel to its resting place every frame, so let
-- the slot change happen and lay the panel out on the next frame, from there.
local original_change_shop_size = change_shop_size
function change_shop_size(mod)
    original_change_shop_size(mod)
    if G.shop and G.shop_jokers then
        -- change_shop_size writes the stock game's slot width; restore this
        -- layout's own spacing before the shelf is measured against it.
        G.shop_jokers.T.w = G.GAME.shop.joker_max*1.05*G.CARD_W
        shop_needs_relayout = true
    end
end

-- Retain the stock blind cards and callbacks, but give the selector the full room
-- width and a hard vertical budget below the owned-card strip. The prompt remains
-- in the HUD's blind cell, scaled to that cell instead of spilling across the bar.
local original_blind_select_uidef = create_UIBox_blind_select
function create_UIBox_blind_select(...)
    local result = original_blind_select_uidef(...)
    result.config.minw = ROOM_W - SAFE_MARGIN*2
    result.config.maxw = ROOM_W - SAFE_MARGIN*2
    result.config.maxh = ROOM_H - RUN_OVERLAY_Y - SAFE_MARGIN
    if result.nodes and result.nodes[1] and result.nodes[1].config then
        result.nodes[1].config.padding = 0.12
    end
    if G.blind_prompt_box then
        G.blind_prompt_box.UIRoot.config.maxw = HUD_BLIND_W - 0.2
        G.blind_prompt_box.UIRoot.config.maxh = 1.5
        G.blind_prompt_box:recalculate()
    end
    return result
end

-- A single horizontal status bar replaces the desktop HUD's tall left sidebar.
-- All IDs used by scoring, easing, tutorials, and blind logic are preserved.
function create_UIBox_HUD()
    local panel = G.C.DYN_UI.BOSS_MAIN
    local inset = G.C.DYN_UI.BOSS_DARK
    -- Measured, not guessed: the numeric readouts are built with the en-us font
    -- whatever the profile language is, and the hand name uses the profile's.
    local numeric = G.LANGUAGES['en-us'].font
    local score_text_h = text_height(SCORE_SCALE, numeric)
    local score_row_h = score_text_h + 0.04
    local target_text_h = text_height(TARGET_SCALE)
    local target_row_h = target_text_h + 0.04
    local dollars_box_h = text_height(DOLLARS_SCALE, numeric) + 0.08

    -- Hand readout boxes. Each of these is a declared size: the row heights are
    -- the text heights they were built for, and nothing measured contributes.
    local name_box_w = HUD_HAND_W - 0.06
    local name_box_h = text_height(HAND_TEXT_SCALE)
    local num_text_w = HAND_NUM_BOX_W - 2*HAND_BOX_PAD
    local num_text_h = text_height(HAND_NUM_SCALE, numeric)
    local num_box_h = num_text_h + 2*HAND_BOX_PAD
    -- Every term here is declared, so this is the cell's height, not a budget
    -- it might exceed. All four cells take it, which keeps the panels level.
    local row_h = math.max(HUD_ROW_H, name_box_h + num_box_h + 0.06 + 0.09)

    -- Score and requirement get the same treatment as the hand readouts: a
    -- declared box that the number is fitted into, rather than a text node the
    -- number sizes. See the score cell below for why. The requirement keeps the
    -- profile's font, which is the one its row height has always been built for.
    local score_text = FixedText(SCORE_TEXT_W, score_text_h,
        {scale=SCORE_SCALE, font=numeric, colour=G.C.WHITE})
    local target_text = FixedText(SCORE_TEXT_W, target_text_h,
        {scale=TARGET_SCALE, colour=G.C.RED})

    local hand_line_text = FixedText(name_box_w, name_box_h,
        {scale=HAND_TEXT_SCALE, gap=0.1})
    local hand_chips_text = FixedText(num_text_w, num_text_h,
        {scale=HAND_NUM_SCALE, font=numeric})
    local hand_mult_text = FixedText(num_text_w, num_text_h,
        {scale=HAND_NUM_SCALE, font=numeric})

    local blind_slot = {n=G.UIT.C, config={
        id='row_blind', align='cm', minw=HUD_BLIND_W, minh=row_h,
        r=0.1, colour=inset
    }, nodes={}}

    -- Score and requirement belong to each other: the number you have over the
    -- number you need. Both readouts fit themselves to SCORE_TEXT_W, so a seven
    -- digit score cannot widen the cell and push the bar past the margins.
    --
    -- The score is an object rather than a text node. A text node is measured
    -- from its own string, and this one carries no_recalc so that a growing
    -- score cannot re-lay-out the whole bar every time it ticks -- which also
    -- means its box keeps whatever width the first value happened to need. Past
    -- four or five digits the number simply drew past that box, and since the
    -- text is laid out from the box's left edge, a number narrower than the box
    -- sat off to one side instead of in the middle of it. FixedText owns a
    -- declared box, centres inside it, and scales the number down when it would
    -- otherwise run past the edge, which is all three complaints at once.
    local score = {n=G.UIT.C, config={
        id='row_dollars_chips', align='cm', minw=HUD_SCORE_W, minh=row_h,
        padding=0.06, r=0.1, colour=panel, emboss=0.05
    }, nodes={
        {n=G.UIT.R, config={align='cm', minw=HUD_SCORE_W-0.12, minh=score_row_h,
            r=0.08, colour=inset}, nodes={
            {n=G.UIT.O, config={id='chip_UI_count', w=SCORE_TEXT_W,
                h=score_text_h, object=score_text, func='chip_UI_set'}}
        }},
        -- No ref_table here: UIElement:update_object treats one on an object
        -- node as the source of the object itself, and would swap the readout
        -- for the string. The func feeds it instead.
        {n=G.UIT.R, config={align='cm', minh=target_row_h}, nodes={
            {n=G.UIT.O, config={id='small_screen_blind_target', w=SCORE_TEXT_W,
                h=target_text_h, object=target_text,
                func='small_screen_blind_target'}}
        }}
    }}

    local current_hand = {n=G.UIT.C, config={
        id='hand_text_area', align='cm', minw=HUD_HAND_W, minh=row_h,
        padding=0.03, r=0.1, colour=darken(G.C.BLACK, 0.1), emboss=0.05
    }, nodes={
        -- The hand name and its level on one line, then the chips and mult in
        -- their plates. Every node here carries its own w and h, so the cell is
        -- the same size whatever a hand is called and however large its numbers
        -- get -- the strings live inside the boxes rather than defining them.
        {n=G.UIT.R, config={align='cm', minh=name_box_h}, nodes={
            {n=G.UIT.O, config={id='hand_name', w=name_box_w, h=name_box_h,
                object=hand_line_text, func='small_screen_hand_line'}},
            -- The game reaches for these two by ID: it pulses the hand total
            -- through the object of one and colours the level through the
            -- config of the other. start_run points the total at hand_name.
            {n=G.UIT.B, config={id='hand_chip_total', w=0, h=0}},
            {n=G.UIT.B, config={id='hand_level', w=0, h=0,
                colour=G.C.UI.TEXT_LIGHT}}
        }},
        {n=G.UIT.R, config={align='cm', minh=num_box_h, padding=0.03}, nodes={
            {n=G.UIT.C, config={id='hand_chip_area', align='cm',
                minw=HAND_NUM_BOX_W, minh=num_box_h, padding=HAND_BOX_PAD,
                r=0.08, colour=G.C.UI_CHIPS, emboss=0.05}, nodes={
                {n=G.UIT.O, config={id='flame_chips', func='flame_handler',
                    no_role=true, object=Moveable(0,0,0,0), w=0, h=0}},
                {n=G.UIT.O, config={id='hand_chips', w=num_text_w, h=num_text_h,
                    object=hand_chips_text, func='hand_chip_UI_set'}}
            }},
            gap(0.08),
            label('X', 0.55, G.C.UI_MULT),
            gap(0.08),
            {n=G.UIT.C, config={id='hand_mult_area', align='cm',
                minw=HAND_NUM_BOX_W, minh=num_box_h, padding=HAND_BOX_PAD,
                r=0.08, colour=G.C.UI_MULT, emboss=0.05}, nodes={
                {n=G.UIT.O, config={id='flame_mult', func='flame_handler',
                    no_role=true, object=Moveable(0,0,0,0), w=0, h=0}},
                {n=G.UIT.O, config={id='hand_mult', w=num_text_w, h=num_text_h,
                    object=hand_mult_text, func='hand_mult_UI_set'}}
            }}
        }}
    }}

    local meta = {n=G.UIT.C, config={align='cm', minw=HUD_META_W, minh=row_h,
        padding=0.07, r=0.1, colour=panel, emboss=0.05}, nodes={
        {n=G.UIT.R, config={align='cm', minh=0.72}, nodes={
            {n=G.UIT.C, config={align='cm', minw=1.3, minh=dollars_box_h,
                padding=0.03, r=0.08, colour=inset}, nodes={
                dyn(G.GAME, 'dollars', G.C.MONEY, DOLLARS_SCALE, 'dollar_text_UI',
                    {prefix=localize('$'), bump=true,
                        func='small_screen_dollars'})
            }},
            gap(0.06),
            {n=G.UIT.C, config={id='hud_hands', align='cm', minw=1.0,
                minh=0.66, padding=0.03, r=0.08, colour=inset}, nodes={
                label('H', 0.32, G.C.BLUE),
                gap(0.04),
                dyn(G.GAME.current_round, 'hands_left', G.C.BLUE, 0.54, 'hand_UI_count')
            }},
            gap(0.06),
            {n=G.UIT.C, config={align='cm', minw=1.0, minh=0.66,
                padding=0.03, r=0.08, colour=inset}, nodes={
                label('D', 0.32, G.C.RED),
                gap(0.04),
                dyn(G.GAME.current_round, 'discards_left', G.C.RED, 0.54, 'discard_UI_count')
            }}
        }},
        {n=G.UIT.R, config={align='cm', minh=0.72}, nodes={
            {n=G.UIT.C, config={id='hud_ante', align='cm', minw=1.72,
                minh=0.66, padding=0.03, r=0.08, colour=inset}, nodes={
                label('A', 0.32, G.C.IMPORTANT),
                gap(0.04),
                dyn(G.GAME.round_resets, 'ante', G.C.IMPORTANT, 0.54, 'ante_UI_count'),
                label('/', 0.28),
                {n=G.UIT.T, config={ref_table=G.GAME, ref_value='win_ante',
                    scale=0.32, colour=G.C.WHITE, shadow=true}}
            }},
            gap(0.06),
            {n=G.UIT.C, config={align='cm', minw=1.14, minh=0.66,
                padding=0.03, r=0.08, colour=inset}, nodes={
                label('R', 0.32, G.C.IMPORTANT),
                gap(0.04),
                dyn(G.GAME, 'round', G.C.IMPORTANT, 0.54, 'round_UI_count')
            }},
            gap(0.06),
            {n=G.UIT.C, config={id='run_info_button', align='cm', minw=0.48,
                minh=0.66, padding=0.03, r=0.08, colour=G.C.RED,
                hover=true, button='run_info', shadow=true,
                focus_args={button=G.F_GUIDE and 'guide' or 'back', orientation='bm'}}, nodes={
                label('i', 0.34)
            }}
        }}
    }}

    -- No backing plate: each cell carries its own panel, so a strip behind them
    -- only greys out the table. minw still spans the room to keep the row
    -- centred on the same line whatever the cells measure.
    return {n=G.UIT.ROOT, config={align='cm', padding=0.06, minw=ROOM_W-SAFE_MARGIN*2,
        colour=G.C.CLEAR}, nodes={
        {n=G.UIT.R, config={id='row_round', align='cm', padding=0.06,
            r=0.1, colour=G.C.CLEAR}, nodes={
            blind_slot, gap(0.1), score, gap(0.1),
            current_hand, gap(0.1), meta
        }}
    }}
end

-- The requirement moved to the score cell, so this panel is now identity only:
-- the blind's chip beside its name, with the debuff lines under it. That matters
-- for more than tidiness. HUD_blind_debuff forces each debuff row to 0.35 with
-- 0.36 text, so the old four-row panel measured 2.29 against a 1.72 slot: it was
-- centred on the slot, and its bottom row -- the score you needed -- was drawn
-- underneath the Joker strip. Three rows fit the slot with the debuffs shown,
-- and collapse to the name alone when a blind has none.
function create_UIBox_HUD_blind()
    local box_w = HUD_BLIND_W - 0.12
    local inner_w = box_w - 0.12
    G.GAME.blind:change_dim(0.62, 0.62)
    local hidden_reward = {text=''}
    return {n=G.UIT.ROOT, config={id='HUD_blind', func='HUD_blind_visible',
        align='cm', minw=box_w, maxw=box_w, minh=1.5,
        padding=0.05, r=0.1,
        colour=G.C.BLACK, emboss=0.05}, nodes={
        {n=G.UIT.R, config={align='cm', minh=text_height(BLIND_NAME_SCALE) + 0.08,
            maxw=inner_w, r=0.08,
            padding=0.03, colour=G.C.DYN_UI.MAIN}, nodes={
            {n=G.UIT.O, config={object=G.GAME.blind, draw_layer=1}},
            {n=G.UIT.O, config={id='HUD_blind_name',
                func='small_screen_blind_name', object=DynaText({
                string={{ref_table=G.GAME.blind, ref_value='loc_name'}},
                colours={G.C.UI.TEXT_LIGHT}, shadow=true, rotate=true,
                silent=true, float=true, scale=BLIND_NAME_SCALE, y_offset=-2})}}
        }},
        {n=G.UIT.R, config={align='cm', minh=0.27, maxw=inner_w,
            colour=G.C.DYN_UI.DARK}, nodes={
            {n=G.UIT.T, config={ref_table={val=''}, ref_value='val', scale=0.31,
                colour=G.C.UI.TEXT_LIGHT, func='HUD_blind_debuff_prefix'}},
            {n=G.UIT.T, config={id='HUD_blind_debuff_1',
                ref_table=G.GAME.blind.loc_debuff_lines, ref_value=1,
                scale=0.31, colour=G.C.UI.TEXT_LIGHT, func='HUD_blind_debuff'}}
        }},
        {n=G.UIT.R, config={align='cm', minh=0.27, maxw=inner_w,
            colour=G.C.DYN_UI.DARK}, nodes={
            {n=G.UIT.T, config={id='HUD_blind_debuff_2',
                ref_table=G.GAME.blind.loc_debuff_lines, ref_value=2,
                scale=0.31, colour=G.C.UI.TEXT_LIGHT, func='HUD_blind_debuff'}}
        }},
        -- Blind.lua drives both of these IDs during its reveal animation, and
        -- hides dollars_to_be_earned by way of its grandparent node -- so keep
        -- them, nested deep enough that the hidden grandparent is this dead row
        -- and not the panel itself. HUD_blind_count keeps no scaling func: it is
        -- the score cell that shows the requirement now.
        {n=G.UIT.R, config={align='cm', minh=0.001}, nodes={
            {n=G.UIT.C, config={align='cm'}, nodes={
                {n=G.UIT.T, config={id='HUD_blind_count', ref_table=G.GAME.blind,
                    ref_value='chip_text', scale=0.001, colour=G.C.CLEAR,
                    no_recalc=true}},
                {n=G.UIT.O, config={id='dollars_to_be_earned', object=DynaText({
                    string={{ref_table=hidden_reward, ref_value='text'}},
                    colours={G.C.CLEAR}, silent=true, scale=0.01})}}
            }}
        }}
    }}
end

-- Requirement readout for the score cell. Balatro already formats the target on
-- the blind itself, so this only decides when it is meaningful to show. A slash
-- rather than a localized "score at least": the cell is 2.6 tiles wide, and the
-- number has to stay the thing you read.
-- Runs every frame, so the comparison earns its keep: set_text builds a table
-- per call, and the requirement only changes when the blind does.
G.FUNCS.small_screen_blind_target = function(e)
    local blind = G.GAME.blind
    local active = blind and blind.blind_set and blind.name and blind.name ~= ''
    local text = active and ('/ '..(blind.chip_text or '')) or ''
    if e.small_screen_target_text == text then return end
    e.small_screen_target_text = text
    e.config.object:set_text(text)
end

-- The stock func keeps G.GAME.chips_text current and picks a scale from the
-- score's magnitude; the scale lands on a field FixedText ignores, since it
-- measures the string against its own box instead. Feeding it the string is all
-- that is left to do here.
local original_chip_UI_set = G.FUNCS.chip_UI_set
G.FUNCS.chip_UI_set = function(e)
    original_chip_UI_set(e)
    if e.small_screen_chip_text ~= G.GAME.chips_text then
        e.small_screen_chip_text = G.GAME.chips_text
        e.config.object:set_text(G.GAME.chips_text)
    end
end

-- The hand readout is fed strings; its boxes were sized when the HUD was built.
-- The stock funcs still run first for their bookkeeping and their scoring juice
-- -- the scale they write lands on a field FixedText ignores.
--
-- One object owns the line: the selected hand's name, or its final total once
-- the hand has been submitted, followed by the level in whatever colour the game
-- has assigned it. The stock pair of texts cannot overlap because there is only
-- one of them.
G.FUNCS.small_screen_hand_line = function(e)
    local hand = G.GAME.current_round.current_hand
    if hand.handname ~= hand.handname_text then
        hand.handname_text = hand.handname
    end
    local total = ''
    if type(hand.chip_total) == 'number' and hand.chip_total >= 1 then
        total = number_format(hand.chip_total)
    end
    hand.chip_total_text = total

    local primary = hand.handname_text
    if primary == nil or primary == '' then primary = total end
    local level_node = G.hand_text_area and G.hand_text_area.hand_level
    e.config.object:set_parts({
        {text=primary},
        {text=hand.hand_level, mult=HAND_LEVEL_MULT,
            colour=level_node and level_node.config.colour or nil}
    })
end

local original_hand_chip_UI_set = G.FUNCS.hand_chip_UI_set
G.FUNCS.hand_chip_UI_set = function(e)
    original_hand_chip_UI_set(e)
    e.config.object:set_text(G.GAME.current_round.current_hand.chip_text)
end

local original_hand_mult_UI_set = G.FUNCS.hand_mult_UI_set
G.FUNCS.hand_mult_UI_set = function(e)
    original_hand_mult_UI_set(e)
    e.config.object:set_text(G.GAME.current_round.current_hand.mult_text)
end

-- DynaText only applies its own maxw when it is constructed, so the money and
-- blind name readouts need the same treatment to stay inside their panels.
G.FUNCS.small_screen_dollars = function(e)
    pin_dyna_scale(e, localize('$')..tostring(G.GAME.dollars or 0),
        DOLLARS_W, DOLLARS_SCALE)
end

G.FUNCS.small_screen_blind_name = function(e)
    pin_dyna_scale(e, (G.GAME.blind and G.GAME.blind.loc_name) or '',
        BLIND_NAME_W, BLIND_NAME_SCALE)
end

-- Move the compact HUD to the top after the run objects have been created.
local original_start_run = Game.start_run
function Game:start_run(...)
    local result = original_start_run(self, ...)
    -- update_hand_text pulses the hand total through its object. There is no
    -- separate total text any more, so point that lookup at the line itself.
    if G.hand_text_area and G.hand_text_area.handname then
        G.hand_text_area.chip_total = G.hand_text_area.handname
    end
    if self.HUD then
        self.HUD:set_alignment({major=G.ROOM_ATTACH, type='tmi',
            offset={x=0, y=SAFE_MARGIN}, bond='Strong'})
        self.HUD:align_to_major()
        self.HUD:recalculate()
    end
    return result
end

-- The cash-out screen, the booster packs and the deck preview are all centred on
-- the hand by the stock game, which is the same thing as the screen centre on a
-- desktop layout. Here it is not: the hand shares its row with the deck, so it
-- sits left of centre to clear it, and everything anchored to it inherited that
-- offset. Nudge those boxes back to the middle of the room without touching the
-- vertical placement or the entrance animations the game drives through it.
local function centre_on_room(box)
    if not box or not G.hand then return end
    local shift = ROOM_W/2 - (G.hand.T.x + G.hand.T.w/2)
    if math.abs(box.alignment.offset.x - shift) > 0.001 then
        box.alignment.offset.x = shift
        box:align_to_major()
    end
end

local function pin_run_overlay(box, y, x)
    if not box then return end
    box:set_alignment({major=G.ROOM_ATTACH, type='tmi',
        offset={x=x or 0, y=y}, bond='Strong'})
    -- Source transitions rewrite the offset after constructing these boxes. Force
    -- a fresh alignment so the desktop animation cannot pull them under Jokers.
    box.alignment.prev_type = nil
    box:align_to_major()
    box:hard_set_VT()
end

-- Centre the panel in the space that is actually free: the whole content band
-- vertically, and everything left of the deck horizontally, so it is never
-- crowded against the card stack. Measured once per shop so the pin cannot
-- jitter, and it falls back to the top of the band if the panel is oversized.
local shop_pin_box, shop_pin_x, shop_pin_y, shop_pin_w, shop_pin_h
local function shop_pin()
    -- Keyed on the panel's size as well as its identity: a panel that changed
    -- shape needs centring again, and measuring it once was only ever meant to
    -- stop the pin jittering frame to frame.
    if G.shop ~= shop_pin_box or
       (G.shop and (G.shop.T.w ~= shop_pin_w or G.shop.T.h ~= shop_pin_h)) then
        shop_pin_box, shop_pin_x, shop_pin_y = G.shop, nil, nil
        shop_pin_w = G.shop and G.shop.T.w
        shop_pin_h = G.shop and G.shop.T.h
    end
    if not shop_pin_y then
        local w = (G.shop and G.shop.T.w) or 0
        local h = (G.shop and G.shop.T.h) or 0
        local deck_x = (G.deck and G.deck.T.x) or (ROOM_W - SAFE_MARGIN)
        local band_bottom = ROOM_H - SAFE_MARGIN

        shop_pin_x = math.min(0, (SAFE_MARGIN + deck_x - 0.15)/2 - ROOM_W/2)
        shop_pin_x = math.max(shop_pin_x, SAFE_MARGIN + w/2 - ROOM_W/2)

        shop_pin_y = RUN_OVERLAY_Y
        if h > 0 and h < band_bottom - RUN_OVERLAY_Y then
            shop_pin_y = RUN_OVERLAY_Y + (band_bottom - RUN_OVERLAY_Y - h)/2
        end
    end
    return shop_pin_x, shop_pin_y
end

-- The shop transition normally targets a negative offset relative to the hand.
-- Re-pin the panel on every shop frame, since a queued desktop entrance event
-- also rewrites its offset shortly after construction.
local original_update_shop = Game.update_shop
function Game:update_shop(dt)
    local result = original_update_shop(self, dt)
    if G.shop then
        local x, y = shop_pin()
        pin_run_overlay(G.shop, y, x)
        -- Only now, with the panel at the position it will keep, is it worth
        -- measuring: recalculate bakes absolute coordinates into every element,
        -- so doing it from anywhere else strands them there.
        if shop_needs_relayout then
            shop_needs_relayout = false
            G.shop:recalculate()
            -- The pin is derived from the panel's size, which recalculate may
            -- have just changed, so take it again for the new shape.
            x, y = shop_pin()
            pin_run_overlay(G.shop, y, x)
        end
    end
    if G.SHOP_SIGN then G.SHOP_SIGN.states.visible = false end
    return result
end

-- Blind selection gets the same explicit lower content zone. Owned Jokers and
-- consumables remain visible for decision-making, but can no longer cover a blind.
-- Cash out, the five booster pack types, and the deck preview. Each keeps the
-- vertical placement and the slide-in the stock game gives it; only the
-- horizontal centring is corrected.
local original_update_round_eval = Game.update_round_eval
function Game:update_round_eval(dt)
    local result = original_update_round_eval(self, dt)
    centre_on_room(G.round_eval)
    return result
end

for _, pack in ipairs({'arcana', 'spectral', 'standard', 'buffoon', 'celestial'}) do
    local name = 'update_'..pack..'_pack'
    local original = Game[name]
    Game[name] = function(self, dt)
        local result = original(self, dt)
        centre_on_room(G.booster_pack)
        return result
    end
end

local original_update_selecting_hand = Game.update_selecting_hand
function Game:update_selecting_hand(dt)
    local result = original_update_selecting_hand(self, dt)
    centre_on_room(G.deck_preview)
    return result
end

local original_update_blind_select = Game.update_blind_select
function Game:update_blind_select(dt)
    local result = original_update_blind_select(self, dt)
    -- The selector carries 0.12 of padding above its cards, so pin it that much
    -- higher than the band top: the blinds start exactly under the owned cards
    -- and the skip tags stay inside the bottom margin. Its own height cannot be
    -- measured -- each column is padded to a fixed ten tiles for the pop-up
    -- animation -- so a taller band is shared out from the known content height.
    if G.blind_select then
        local band = ROOM_H - SAFE_MARGIN - RUN_OVERLAY_Y
        pin_run_overlay(G.blind_select, RUN_OVERLAY_Y - 0.12 +
            math.max(0, (band - BLIND_SELECT_H)/2))
    end
    return result
end

-- Card descriptions are the smallest important text in the desktop UI. Increase
-- only text nodes in freshly generated ability tables, leaving menu geometry and
-- dynamic score text alone.
local function enlarge_description_text(node)
    if type(node) ~= 'table' then return end
    if node.n == G.UIT.T and node.config and node.config.scale then
        node.config.scale = math.min(0.52, node.config.scale*1.22)
    end
    if node.nodes then
        for _, child in ipairs(node.nodes) do enlarge_description_text(child) end
    elseif not node.config then
        for _, child in ipairs(node) do enlarge_description_text(child) end
        for _, key in ipairs({'main', 'info', 'name', 'type'}) do
            if node[key] then enlarge_description_text(node[key]) end
        end
    end
end

local original_ability_table = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table(...)
    local result = original_ability_table(self, ...)
    enlarge_description_text(result)
    return result
end

-- Keep transient UI inside the logical room. The stock engine only supports a
-- horizontal clamp, so tall controller-hover descriptions can still escape above
-- the HUD or below the bottom edge on a 4:3 screen.
local function clamp_popup_to_room(box)
    local max_x = math.max(SAFE_MARGIN, G.ROOM.T.w - box.T.w - SAFE_MARGIN)
    local max_y = math.max(SAFE_MARGIN, G.ROOM.T.h - box.T.h - SAFE_MARGIN)
    box.T.x = math.min(math.max(box.T.x, SAFE_MARGIN), max_x)
    box.T.y = math.min(math.max(box.T.y, SAFE_MARGIN), max_y)

    local visual_max_x = math.max(SAFE_MARGIN,
        G.ROOM.T.w - box.VT.w - SAFE_MARGIN)
    local visual_max_y = math.max(SAFE_MARGIN,
        G.ROOM.T.h - box.VT.h - SAFE_MARGIN)
    box.VT.x = math.min(math.max(box.VT.x, SAFE_MARGIN), visual_max_x)
    box.VT.y = math.min(math.max(box.VT.y, SAFE_MARGIN), visual_max_y)
end

local original_uibox_move = UIBox.move
function UIBox:move(dt)
    if self.config and self.config.instance_type == 'POPUP' then
        Moveable.move(self, dt)
        clamp_popup_to_room(self)
        Moveable.move(self.UIRoot, dt)
        return
    end
    return original_uibox_move(self, dt)
end

-- Unlock notifications use the desktop room's fixed width (20 logical tiles),
-- which is wider than this layout. Preserve the banner look with safe side margins.
local original_notify_alert = create_UIBox_notify_alert
function create_UIBox_notify_alert(...)
    local result = original_notify_alert(...)
    local function fit_banner(node)
        if type(node) ~= 'table' then return end
        if node.config and node.config.minw and node.config.minw > ROOM_W then
            node.config.minw = ROOM_W - SAFE_MARGIN*2
        end
        if node.nodes then
            for _, child in ipairs(node.nodes) do fit_banner(child) end
        end
    end
    fit_banner(result)
    return result
end

-- Mark card descriptions for the engine-wide popup clamp, especially the leftmost
-- shop slot, top-row Jokers, and rightmost consumable.
-- A card with extra properties -- an edition, a seal, an enhancement, a Joker
-- whose text cites another card -- describes each of them in its own small
-- panel. show_infotip hangs those off the left of the description box, as a
-- separate UIBox parented to it, and that is the one piece of the popup nothing
-- clamps: UIBox:move only pulls instance_type POPUP back inside the room, which
-- is the description box and not its children. A description sitting near the
-- left margin therefore pushes its panels straight off the screen.
--
-- Stack them under the description instead of beside it, and do it by moving
-- them into the description's own column rather than by re-aligning the box
-- they live in. Inside a container the layout engine stacks R nodes vertically,
-- and every info panel is one, so appending them puts each under the last. The
-- popup then measures its own full height and the room clamp covers all of it,
-- which the side panel never got.
local function stack_info_boxes(node)
    if type(node) ~= 'table' then return false end
    if node.config and node.config.func == 'show_infotip' and
       type(node.config.ref_table) == 'table' and node.nodes then
        for _, box in ipairs(node.config.ref_table) do
            node.nodes[#node.nodes + 1] = box
        end
        -- show_infotip builds the side panel only while this is set, so
        -- clearing it is what stops the panels being shown twice.
        node.config.ref_table = nil
        return true
    end
    if node.nodes then
        for _, child in pairs(node.nodes) do
            if stack_info_boxes(child) then return true end
        end
    end
    return false
end

local original_card_h_popup = G.UIDEF.card_h_popup
G.UIDEF.card_h_popup = function(...)
    -- Returns nothing for a card with no ability table yet.
    local definition = original_card_h_popup(...)
    if type(definition) == 'table' then pcall(stack_info_boxes, definition) end
    return definition
end

local original_align_h_popup = Card.align_h_popup
function Card:align_h_popup(...)
    local result = original_align_h_popup(self, ...)
    result.lr_clamp = true
    return result
end
