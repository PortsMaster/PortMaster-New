# The Mineclonia Translation Maintenance Workflow

_Adapted from the [Repixture](https://codeberg.org/Wuzzy/Repixture) translation maintenance workflow._

This document is directed to *developers* describing how to make sure the Mineclonia translation files stay up to date and functional.

**If you just want to translate, go to:** <https://translate.codeberg.org/projects/mineclonia/> (you can ignore the rest of the document)

## Introduction

Mineclonia translations utilize Weblate to allow translators to translate the game online. But for this to work, the workflow to maintain translations is a little bit more involved.

Rather than translating strings directly in the TR files, translators are encouraged to go to <https://translate.codeberg.org/projects/mineclonia/> to translate the string. The Mineclonia maintainer(s) do the rest.

* **TR files** (`*.tr`) contain the translation that Mineclonia actually uses in the game. They can be found in the `locale` subdirectories of the mods
* **PO files** (`*.po`) are automatically generated and are required for Weblate to work. Mineclonia ignores them. They can be found in the `poconvert` subdirectory of those `locale` directories

**IMPORTANT**: Translators should NOT translate the TR or PO files in this game repository, as it disrupts the workflow. They are adviced to go to the aforementioned website instead.

## Preconditions

You need Python 3, the Luanti Translation Tools, Luanti 5.8.0 or greater, and an environment which can interact with git repositories and execute shell scripts for this to work (e.g. any linux box or Git Bash). For the Luanti Translation tools you need parts of the repositories at <https://github.com/minetest/modtools> and <https://codeberg.org/Wuzzy/Minetest_Translation_Tools>.

## Creating translatable strings

Mineclonia uses the standard notation to mark translatable strings in the mod lua code, i.e. `S("This string can be translated")`. See the documentation included with the minetest modtools repository for details.

Additionally some mineclonia mods will compute translatable strings by piecing information fragments together, e.g. mcl_trees will create the translatable string `Cherry Log` for the name of the cherry tree trunk node when called from the `mcl_cherry_blossom` mod. The mod passes the `readable_name` property with the value `"Cherry"` (untranslated) into the `register_tree` function that concatenates this readable name with the default names used for the created items and nodes. This computed translatable string conceptually belongs to the `mcl_cherry_blossom` mod and will be automatically added to the translation template file `locale\template.txt` of `mcl_cherry_blossom` by the workflow in this document. Mods can usually override these translatable strings created by other mods on their behalf, e.g. `mcl_bamboo` overrides the name of the tree log node by passing the translated string `S("Block of Bamboo")` to the `register_tree` function. Consult the respective API documents for details.

## Notes for mod developers

To allow your carefully designed content to be easily translatable into idiomatic versions for all languages some thought is needed to find the correct English base strings to translate. This is because in many languages words need to change their form depending on the grammatic gender and number of other words. Sometimes completely different grammatic constructions are needed, just because some small detail changes. The following rules might help you get started:

 - never construct new strings of already translated parts, it is almost always wrong to use a parameterized translation string for short node and item descriptions, while it's fine to use parameters to add e.g. stats to a longer description string

 - many languages use different phrases for 1, 2, 3, and many items, so it might be necessary to take special care if you want to talk about an unknown number of items using prose (instead of a more table like syntax)

## Part 1: Pushing the translations from the game to Weblate:

1. Clean up: Make sure the game repository is in a clean state (no non-committed changes)
2. Generate computed translation strings and update TR files: Run `tools/generate_translation_strings/generate.sh` passing the path to the `mod_translation_updater.py` (from the minetest modtools repository) as the parameter and commit the resulting changes (if any). For example, if both mineclonia and the modtools are checked out to the same directory, execute `mineclonia/tools/generate_translation_strings/generate modtools/mod_translation_updater.py` in that directory.
3. Convert TR to PO: Run `mtt_convert.py --tr2po -r` (from Wuzzy's Minetest_Translation_Tools repository) in the `mods` directory and commit the changes
4. Push: Push the changes to the online repository of the game
5. Update Weblate repository (optional): Weblate should soon automatically update its repository. But if you want to want the new strings to be available immediately, go to the project page, then “Manage > Repository Maintenance” and click “Update”

Now the new translations should be visible in Weblate and are available to translators. It is best practice to do this either in regular intervals or whenever a major batch of strings was added or changed, and not just right before a release. That way, translators have time to react.

You should also quickly look over some of the Weblate components to make sure the change actually worked.

## Part 2: Translating

Use the Weblate interface to translate the strings. Inform other translations when a major batch of strings has arrived. Weblate also allows to add announcements on the top of the page via the “Management” button.

## Part 3: Downloading the translations back to the game:

This part is usually done when you’re preparing a release. You want to extract the strings that have been translated in Weblate back to the game.

1. Clean up: Make sure the game repository is in a clean state (no non-committed changes)
2. Commit to Weblate repository: Go to “Manage > Repository Maintenance” and click “Commit” (if the number of pending commits is 0, you can skip this step)
3. Pull from Weblate repository: `git pull weblate <name of main branch>`
4. Convert PO to TR: Run `mtt_convert.py --po2tr -r` in the `mods` directory and commit the changes

Now all the translations from Weblate should be in the game. You may want to do a quick in-game test to make sure.

## tools/update-tr.sh

This script combines the steps 3 and 1 of the workflow described above into a single step, simplifying the process for the maintainers.

## Checking translations

At least once directly before a release, you should check the TR files for syntax errors.

1. Run `mtt_check.py -r` in the `mods` directory of the game
2. For all string errors in languages you speak, fix the offending strings **in Weblate**
3. For all string errors in languages you do not speak, **blank out** the offending strings **in Weblate**
4. For errors that are unrelated to a string, fix the TR file directly (note: if these errors keep happening, this could be a sign of an underlying flaw somewhere. Investigate!)
5. Try to fix all warnings as well unless it’s unreasonable to do so

Checking for syntax errors regularly is important. One of the most common technical mistakes of translators is to forget a placeholder (`@1`, `@2`, etc.) in the translation which is problematic because it leads to a loss of information to the player.
