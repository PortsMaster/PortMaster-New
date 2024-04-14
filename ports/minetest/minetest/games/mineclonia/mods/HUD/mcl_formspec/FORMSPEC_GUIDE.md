# MineClone2 Formspec Guide

**_This guide will teach you the rules for creating formspecs for the MineClone2 game._**

Formspecs are an important part of game and mod development.

First of all, MineClone2 aims to support ONLY last formspec version. Many utility functions will not work with formspec v1 or v2.

The typical width of an 9 slots width inventory formspec is `0.375 + 9 + ((9-1) * 0.25) + 0.375 = 11.75`

Margins are 0.375.

The labels color is `mcl_formspec.label_color`

Space between 1st inventory line and the rest of inventory is 0.45

Labels should have 0.375 space above if there is no other stuff above and 0.45 between content

- 0.375 under

According to minetest modding book, table.concat is faster than string concatenation, so this method should be prefered (the code is also more clear)
