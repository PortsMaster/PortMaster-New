# mcl_damage

This mod is intended to overall minetest's native damage system, to provide a better integration between features that deals with entities' health.

WARNING: Not using it inside your mods may cause strange bugs (using the native damage system may cause conflicts with this system).

## Callbacks

To modify the amount of damage made by something:

```lua
--obj: an ObjectRef
mcl_damage.register_modifier(function(obj, damage, reason)
end, 0)
```