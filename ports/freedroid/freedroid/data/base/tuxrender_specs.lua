------------------------------------------------------------------------------
-- This file defines the animation and rendering of Tux.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Specification of Tux animations.
--
-- Keyframe numbering starts at 0.
--
-- 'duration' is the duration of the related animation, in seconds.
--
-- For walk and run animations, 'distance' is the number of tiles covered by
-- Tux during a whole sequence of animation.
--
-- Note: there is currently no standing animation is the image-archive file,
-- so we only use a single keyframe.
------------------------------------------------------------------------------

tux_animation {
  standing_keyframe = 24,

  attack = { duration = 0.55,
             first_keyframe = 0,
             last_keyframe = 13 },

  walk = { distance = 0.8,
           first_keyframe  = 14,
           last_keyframe = 23 },

  run = { distance = 10.0/3.0,
          first_keyframe = 25,
          last_keyframe = 34 }
}

------------------------------------------------------------------------------
-- Global configuration of Tux rendering
--
-- motion_class_names: list of motion class names
--   Those names are used in the next section of this file to define the ordering
--   of Tux's parts rendering, and in item_archetypes.dat to associate a
--   motion class to a weapon.
--   The first motion_class is the one used when Tux has no weapon in hand.
------------------------------------------------------------------------------

tux_rendering_config {
  motion_class_names = { "1hmelee", "2hranged", "1hranged", "2h_heavy_melee" },
  default_parts = { head = "iso_head",
                    torso = "iso_torso",
                    weaponarm = "iso_weaponarm",
                    -- weapon = "", / No default value
                    shieldarm = "iso_shieldarm",
                    feet      = "iso_feet" },
  gun_muzzle_height      = 65
}

------------------------------------------------------------------------------
-- Specification of how to order Tux parts' during rendering
--
-- The definition is:
--
--   tux_ordering {
--     type        : one of the motion_class value - example: "1hmelee"
--     rotations   : comma-separated list of rotation values - example: { 0, 1, 2 }
--     phase_start : first phase to which this order applies (optional - default value: 0)
--     phase_end   : last phase to which this order applies (optional - default value: -1,
--                   which denotes the last phase number)
--     order       : one of the parts' order definition - example: part_order.FTHASW
--   }
--
-- It is thus possible to specify the same order for several rotations and several
-- animation phases.
--
-- When a specific order is needed for a specific phase, it has to be defined
-- *before* the less specific set. For example:
--
--   tux_ordering {
--     type = "2hranged",
--     rotations = { 1, 2 },
--     phase_start = 4,
--     phase_end = 11,
--     order = part_order.FTHSWA
--   }
--
--   tux_ordering {
--     type = "2hranged",
--     rotations = { 1, 2 },
--     order = part_order.FSTHWA
--   }
------------------------------------------------------------------------------

--------------------
-- "part_order" is the definition of a list of orders.
-- The name of an order has no real meaning.
-- Here we chose the first letter of each part (with A = weaponarm).
--
-- (Note: part_order is a Lua variable, internal to this script. It does not
--  call a table constructor).
--------------------

part_order = {
  FTSWAH = { "feet", "torso",     "shieldarm", "weapon",    "weaponarm", "head"      },
  FTHSWA = { "feet", "torso",     "head",      "shieldarm", "weapon",    "weaponarm" },
  FTHSAW = { "feet", "torso",     "head",      "shieldarm", "weaponarm", "weapon"    },
  FTSAWH = { "feet", "torso",     "shieldarm", "weaponarm", "weapon",    "head"      },
  FTSAHW = { "feet", "torso",     "shieldarm", "weaponarm", "head",      "weapon"    },
  FTASWH = { "feet", "torso",     "weaponarm", "shieldarm", "weapon",    "head"      },
  FTAWSH = { "feet", "torso",     "weaponarm", "weapon",    "shieldarm", "head"      },
  FTWASH = { "feet", "torso",     "weapon",    "weaponarm", "shieldarm", "head"      },
  FATWSH = { "feet", "weaponarm", "torso",     "weapon",    "shieldarm", "head"      },
  FATSWH = { "feet", "weaponarm", "torso",     "shieldarm", "weapon",    "head"      },
  FATHWS = { "feet", "weaponarm", "torso",     "head",      "weapon",    "shieldarm" },
  FSTHWA = { "feet", "shieldarm", "torso",     "head",      "weapon",    "weaponarm" },
  FSWTAH = { "feet", "shieldarm", "weapon",    "torso",     "weaponarm", "head"      },
  FSWATH = { "feet", "shieldarm", "weapon",    "weaponarm", "torso",     "head"      },
  FSTWAH = { "feet", "shieldarm", "torso",     "weapon",    "weaponarm", "head"      },
  FSTAWH = { "feet", "shieldarm", "torso",     "weaponarm", "weapon",    "head"      },
  FWATSH = { "feet", "weapon",    "weaponarm", "torso",     "shieldarm", "head"      },
  FWASTH = { "feet", "weapon",    "weaponarm", "shieldarm", "torso",     "head"      },
  FWTASH = { "feet", "weapon",    "torso",     "weaponarm", "shieldarm", "head"      },
  FWSTAH = { "feet", "weapon",    "shieldarm", "torso",     "weaponarm", "head"      },
  FAWTSH = { "feet", "weaponarm", "weapon",    "torso",     "shieldarm", "head"      },
  FATWSH = { "feet", "weaponarm", "torso",     "weapon",    "shieldarm", "head"      },
  WFASTH = { "weapon", "feet",    "weaponarm", "shieldarm", "torso",     "head"      }
}

--------------------
-- 1-Handed Melee animation
--------------------

tux_ordering {
  type = "1hmelee",
  rotations = { 0 },
  order = part_order.FTHSWA
}

tux_ordering {
  type = "1hmelee",
  rotations = { 1 },
  phase_start = 0,
  phase_end = 10,
  order = part_order.FTHSWA
}

tux_ordering {
  type = "1hmelee",
  rotations = { 1, 2, 3, 4, 5, 6 },
  order = part_order.FSTHWA
}

tux_ordering {
  type = "1hmelee",
  rotations = { 7 },
  order = part_order.FSTWAH
}

tux_ordering {
  type = "1hmelee",
  rotations = { 8 },
  order = part_order.FSWTAH
}

tux_ordering {
  type = "1hmelee",
  rotations = { 9, 10, 11 },
  order = part_order.FWATSH
}

tux_ordering {
  type = "1hmelee",
  rotations = { 12, 13, 14, 15 },
  order = part_order.FAWTSH
}

--------------------
-- 2-Handed Ranged Animation
--------------------

tux_ordering {
  type = "2hranged",
  rotations = { 0, 1, 2 },
  order = part_order.FTSWAH
}

tux_ordering {
  type = "2hranged",
  rotations = { 3, 4 },
  order = part_order.FSTWAH
}

tux_ordering {
  type = "2hranged",
  rotations = { 5, 6, 7 },
  order = part_order.FSWTAH
}

tux_ordering {
  type = "2hranged",
  rotations = { 8 },
  order = part_order.FSWATH
}

tux_ordering {
  type = "2hranged",
  rotations = { 9 },
  order = part_order.FWASTH
}

tux_ordering {
  type = "2hranged",
  rotations = { 10 },
  order = part_order.FWATSH
}

tux_ordering {
  type = "2hranged",
  rotations = { 11 },
  order = part_order.FAWTSH
}

tux_ordering {
  type = "2hranged",
  rotations = { 12 },
  order = part_order.FATWSH
}

tux_ordering {
  type = "2hranged",
  rotations = { 13, 14 },
  order = part_order.FATSWH
}

tux_ordering {
  type = "2hranged",
  rotations = { 15 },
  order = part_order.FTSAWH
}

--------------------
-- 1-Handed Ranged Animation
--------------------

tux_ordering {
  type = "1hranged",
  rotations = { 0 },
  phase_start = 17,
  phase_end = 22,
  order = part_order.FTWASH
}

tux_ordering {
  type = "1hranged",
  rotations = { 0 },
  phase_start = 24,
  phase_end = 24,
  order = part_order.FTSWAH
}

tux_ordering {
  type = "1hranged",
  rotations = { 0 },
  phase_start = 25,
  phase_end = 28,
  order = part_order.FWTASH
}

tux_ordering {
  type = "1hranged",
  rotations = { 0 },
  phase_start = 32,
  phase_end = 34,
  order = part_order.FWTASH
}

tux_ordering {
  type = "1hranged",
  rotations = { 0 },
  order = part_order.FTSAHW
}

tux_ordering {
  type = "1hranged",
  rotations = { 1, 2, 3, 4, 5, 6, 7 },
  order = part_order.FSTWAH
}

tux_ordering {
  type = "1hranged",
  rotations = { 8 },
  phase_start = 0,
  phase_end = 1,
  order = part_order.FSWATH
}

tux_ordering {
  type = "1hranged",
  rotations = { 8 },
  phase_start = 25,
  phase_end = 27,
  order = part_order.FSTWAH
}

tux_ordering {
  type = "1hranged",
  rotations = { 8 },
  phase_start = 32,
  phase_end = 34,
  order = part_order.FSTWAH
}

tux_ordering {
  type = "1hranged",
  rotations = { 8 },
  order = part_order.FSWTAH
}

tux_ordering {
  type = "1hranged",
  rotations = { 9 },
  order = part_order.FWATSH
}

tux_ordering {
  type = "1hranged",
  rotations = { 15 },
  phase_start = 2,
  phase_end = 11,
  order = part_order.FTASWH
}

tux_ordering {
  type = "1hranged",
  rotations = { 10, 11, 12, 13, 14, 15 },
  order = part_order.FAWTSH
}

--------------------
-- 2-Handed Long Handle Melee Animation
--------------------

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 1, 2 },
  phase_start = 7,
  phase_end = 10,
  order = part_order.FTSWAH
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 0, 1, 2 },
  order = part_order.FTSAHW
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 3, 4 },
  phase_start = 1,
  phase_end = 5,
  order = part_order.FTSAHW
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 3, 4 },
  phase_start = 6,
  phase_end = 11,
  order = part_order.FSTWAH
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 3 },
  order = part_order.FSTAWH
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 4 },
  order = part_order.FSTAWH
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 5, 6 },
  phase_start = 1,
  phase_end = 5,
  order = part_order.FTSAHW
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 5, 6, 7 },
  order = part_order.FWSTAH
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 8 },
  phase_start = 3,
  phase_end = 5,
  order = part_order.FSWTAH
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 8 },
  order = part_order.FWASTH
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 9, 10 },
  phase_start = 3,
  phase_end = 12,
  order = part_order.FWASTH
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 9, 10 },
  order = part_order.FWATSH
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 11 },
  order = part_order.FAWTSH
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 12, 13, 14 },
  order = part_order.FATWSH
}

tux_ordering {
  type = "2h_heavy_melee",
  rotations = { 15 },
  order = part_order.FTAWSH
}
