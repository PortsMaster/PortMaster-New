# mcl_compass

# Compass API

##mcl_compass.stereotype = "mcl_compass:" .. stereotype_frame
Default compass craftitem.  This is also the image that is shown in the inventory.

##mcl_compass/init.lua:function mcl_compass.get_compass_itemname(pos, dir, itemstack)
Returns the itemname of a compass with needle direction matching the
current compass position.

  pos: position of the compass;
  dir: rotational orientation of the compass;
  itemstack: the compass including its optional lodestone metadata.

##mcl_compass/init.lua:function mcl_compass.get_compass_image(pos, dir)
-- Returns partial itemname of a compass with needle direction matching compass position.
-- Legacy compatibility function for mods using older api.

##mcl_compass.register_compass(name, definition)

### Compass definition:
{
    name = "mycompass",
    name_fmt = "",
    overrides = { --item definition overrides e.g. description etc.
        _mcl_compass_img_fmt = "", --format string to build the item image from a compass frame number
        _mcl_compass_update = function(stack, player) end, --function to update the compass item, will be run regularily in player inventories, should return the updated itemstack
    }
}
