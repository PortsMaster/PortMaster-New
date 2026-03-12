# mcl_paintings

## `mcl_paintings.register_painting`

To register a painting use the function `mcl_paintings.register_painting(name, def)`

`name` is a unique string identifier

Meanwhile `def` is a table with these fields:

- `width` - How wide is the painting
- `height` - how high is the painting
- `texture` - name of the texture
- `legacy_motive` - together with `width` and `height` these are used to
  convert legacy paintings to the new implementation. If you're a modder, just
  ignore this

For an example of usage you can check the `registrations.lua` file in this directory

## `mcl_paintings.register_painting_alias`

If a painting is removed or changed, an alias can be registered.

To register a painting alias use the function

```lua
mcl_paintings.register_painting_alias(alias, original_name)
```

It will result in paintings with the name `alias` be treated as paintings with
the name `original_name`, as long as `alias` is not also the name of a
registered painting.
