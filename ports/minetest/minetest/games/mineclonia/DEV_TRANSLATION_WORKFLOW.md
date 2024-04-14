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

You need at least Minetest 5.8.0, Python 3 and the Minetest Translation Tools for this to work. You can find the Minetest Translation tools at <https://codeberg.org/Wuzzy/Minetest_Translation_Tools>.

## Part 1: Pushing the translations from the game to Weblate:

1. Clean up: Make sure the game repository is in a clean state (no non-committed changes)
2. Update TR files: Run `util/mod_translation_updater.py` (included since Minetest 5.8.0) in the `mods` directory and commit the changes (if any)
3. Convert TR to PO: Run `mtt_convert.py --tr2po -r` in the `mods` directory and commit the changes
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

## Checking translations

At least once directly before a release, you should check the TR files for syntax errors.

1. Run `mtt_check.py -r` in the `mods` directory of the game
2. For all string errors in languages you speak, fix the offending strings **in Weblate**
3. For all string errors in languages you do not speak, **blank out** the offending strings **in Weblate**
4. For errors that are unrelated to a string, fix the TR file directly (note: if these errors keep happening, this could be a sign of an underlying flaw somewhere. Investigate!)
5. Try to fix all warnings as well unless it’s unreasonable to do so

Checking for syntax errors regularly is important. One of the most common technical mistakes of translators is to forget a placeholder (`@1`, `@2`, etc.) in the translation which is problematic because it leads to a loss of information to the player.
