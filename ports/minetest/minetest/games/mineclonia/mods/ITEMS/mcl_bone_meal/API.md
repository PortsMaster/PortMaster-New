# mcl_bone_meal

## Bone meal API

### _on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
This function is called when the field is defined in a node definition
and the node is righclicked (on_place) with bone meal.

It will check for protection and creative mode and show the bone meal particles and takes a bone meal item unless the callback returns false.
