# Lookup Tool [`doc_identifier`]
Version: 1.2.2

## Description
The lookup tool is an useful little helper which can be used to quickly learn
more about about one's closer environment. It identifies blocks, dropped items
and other objects and it shows extensive information about the item on which it
is used, provided documentation is available.

## How to use the lookup tool
Punch any block or item about you wish to learn more about. This will open up
the help entry of this particular item.
The tool comes in two modes which are changed by a right-click. In liquid mode
(blue) this tool points to liquids as well while in solid mode (red) this is not
the case. Liquid mode is required if you want to identify a liquid.

## For modders
If you want the tool to identify nodes and (dropped) items, you probably don't
have to do anything, it is probably already supported. The only thing you have
to make sure is that all pointable blocks and items have a help entry, which
is already the case for most items, but you may want to do some testing on
“tricky” items. Consult the documentation of Documentation System [`doc`]
and Item Help [`doc_items`] for getting the item documentation right.

For the lookup tool to be able to work on custom objects/entities, you have to
use the tiny API of this mod, see `API.md`.

## License
Everything in this mod is licensed under the MIT License.
