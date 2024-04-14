Walkover
--------

Some mode developers have shown an interest in having an `on_walk_over` event. This is useful for pressure-plates and the like.

See this issue - https://github.com/minetest/minetest/issues/247

I have implemented a server-side version in Lua using globalstep which people might find useful. Of course this would better implemented via a client-based "on walk over", but it is sufficient for my needs now.

Example Usage
-------------

    minetest.register_node("somemod:someblock", {
           description = "Talking Block",
           tiles = {"somemod_someblock.png"},
           on_walk_over = function(pos, node, player)
                 minetest.chat_send_player(player, "Hey! Watch it!")
           end
    })

 
Credits
-------
Mod created by lordfingle, licensed under Apache License 2.0.
