
local S = core.get_translator(core.get_current_modname())

--
-- Advanced usage
--

doc.add_category("advanced", {
	name = S("Advanced usage"),
	description = S("Advanced information which may be nice to know, but is not crucial to gameplay"),
	sorting = "custom",
	sorting_data = {"creative", "console", "commands", "privs", "movement_modes", "coordinates", "settings", "online"},
	build_formspec = doc.entry_builders.text_and_gallery,
})


doc.add_entry("advanced", "creative", {
	name = S("Creative Mode"),
	data = { text =
S("Enabling Creative Mode in MineClonia applies the following changes:").."\n\n"..

S("• You keep the things you've placed").."\n"..
S("• Creative inventory is available to obtain most items easily").."\n"..
S("• Hand breaks all default blocks instantly").."\n"..
S("• Greatly increased hand pointing range").."\n"..
S("• Mined blocks don't drop items").."\n"..
S("• Items don't get used up").."\n"..
S("• Tools don't wear off").."\n"..
S("• You can eat food whenever you want").."\n"..
S("• You can always use the minimap (including radar mode)").."\n\n"..

S("Damage is not affected by Creative Mode, it needs to be disabled separately.")
}})

doc.add_entry("advanced", "console", {
	name = S("Console"),
	data = { text =
S("With [F10] you can open and close the console. The main use of the console is to show the chat log and enter chat messages or server commands.").."\n"..
S("Using the chat or server command key also opens the console, but it is smaller and will be closed after you sent a message.").."\n\n"..

S("Use the chat to communicate with other players. This requires you to have the “shout” privilege.").."\n"..
S("Just type in the message and hit [Enter]. Public chat messages can not begin with “/”.").."\n\n"..

S("You can send private messages: Say “/msg <player> <message>” in chat to send “<message>” which can only be seen by <player>.").."\n\n"..

S("There are some special controls for the console:").."\n\n"..

S("• [F10] Open/close console").."\n"..
S("• [Enter]: Send message or command").."\n"..
S("• [Tab]: Try to auto-complete a partially-entered player name").."\n"..
S("• [Ctrl]+[Left]: Move cursor to the beginning of the previous word").."\n"..
S("• [Ctrl]+[Right]: Move cursor to the beginning of the next word").."\n"..
S("• [Ctrl]+[Backspace]: Delete previous word").."\n"..
S("• [Ctrl]+[Delete]: Delete next word").."\n"..
S("• [Ctrl]+[U]: Delete all text before the cursor").."\n"..
S("• [Ctrl]+[K]: Delete all text after the cursor").."\n"..
S("• [Page up]: Scroll up").."\n"..
S("• [Page down]: Scroll down").."\n"..

S("There is also an input history. Luanti saves your previous console inputs which you can quickly access later:").."\n\n"..

S("• [Up]: Go to previous entry in history").."\n"..
S("• [Down]: Go to next entry in history")
}})

doc.add_entry("advanced", "commands", {
	name = S("Server commands"),
	data = { text =
S("Server commands (also called “chat commands”) are little helpers for advanced users. You don't need to use these commands when playing. But they might come in handy to perform some more technical tasks. Server commands work both in multi-player and single-player mode.").."\n\n"..

S("Server commands can be entered by players using the chat to perform a special server action. There are a few commands which can be issued by everyone, but some commands only work if you have certain privileges granted on the server. There is a small set of basic commands which are always available, other commands can be added by mods.").."\n\n"..

S("To issue a command, simply type it like a chat message or press Luanti's command key (default: [/]). All commands have to begin with “/”, for example “/mods”. The Luanti command key does the same as the chat key, except that the slash is already entered.").."\n"..
S("Commands may or may not give a response in the chat log, but errors will generally be shown in the chat. Try it for yourselves: Close this window and type in the “/mods” command. This will give you the list of available mods on this server.").."\n\n"..

S("“/help all” is a very important command: You get a list of all available commands on the server, a short explanation and the allowed parameters. This command is also important because the available commands often differ per server.").."\n\n"..

S("Commands are followed by zero or more parameters.").."\n\n"..

S("In the command reference, you see some placeholders which you need to replace with an actual value. Here's an explanation:").."\n\n"..

S("• Text in greater-than and lower-than signs (e.g. “<param>”): Placeholder for a parameter").."\n"..
S("• Anything in square brackets (e.g. “[text]”) is optional and can be omitted").."\n"..
S("• Pipe or slash (e.g. “text1 | text2 | text3”): Alternation. One of multiple texts must be used (e.g. “text2”)").."\n"..
S("• Parenthesis: (e.g. “(word1 word2) | word3”): Groups multiple words together, used for alternations").."\n"..
S("• Everything else is to be read as literal text").."\n\n"..

S("Here are some examples to illustrate the command syntax:").."\n\n"..

S("• /mods: No parameters. Just enter “/mods”").."\n"..
S("• /me <action>: 1 parameter. You have to enter “/me ” followed by any text, e.g. “/me orders pizza”").."\n"..
S("• /give <name> <ItemString>: Two parameters. Example: “/give Player default:apple”").."\n"..
S("• /help [all|privs|<cmd>]: Valid inputs are “/help”, “/help all”, “/help privs”, or “/help ” followed by a command name, like “/help time”").."\n"..
S("• /spawnentity <EntityName> [<X>,<Y>,<Z>]: Valid inputs include “/spawnentity boats:boat” and “/spawnentity boats:boat 0,0,0”").."\n\n\n"..


S("Some final remarks:").."\n\n"..

S("• For /give and /giveme, you need an itemstring. This is an internally used unique item identifier which you may find in the item help if you have the “give” or “debug” privilege").."\n"..
S("• For /spawnentity you need an entity name, which is another identifier")
}})

doc.add_entry("advanced", "privs", {
	name = S("Privileges"),
	data = { text =
S("Each player has a set of privileges, which differs from server to server. Your privileges determine what you can and can't do. Privileges can be granted and revoked from other players by any player who has the privilege called “privs”.").."\n\n"..

S("On a multiplayer server with the default configuration, new players start with the privileges called “interact” and “shout”. The “interact” privilege is required for the most basic gameplay actions such as building, mining, using, etc. The “shout” privilege allows to chat.").."\n\n"..

S("There is a small set of core privileges which you'll find on every server, other privileges might be added by mods.").."\n\n"..

S("To view your own privileges, issue the server command “/privs”.").."\n\n"..

S("Here are a few basic privilege-related commands:").."\n\n"..

S("• /privs: Lists your privileges").."\n"..
S("• /privs <player>: Lists the privileges of <player>").."\n"..
S("• /help privs: Shows a list and description about all privileges").."\n\n"..

S("Players with the “privs” privilege can modify privileges at will:").."\n\n"..

S("• /grant <player> <privilege>: Grant <privilege> to <player>").."\n"..
S("• /revoke <player> <privilege>: Revoke <privilege> from <player>").."\n\n"..

S("In single-player mode, you can use “/grantme all” to unlock all abilities.")
}})

doc.add_entry("advanced", "movement_modes", {
	name = S("Movement modes"),
	data = { text =
S("You can enable some special movement modes that change how you move.").."\n\n"..

S("Pitch movement mode:").."\n"..
S("• Description: If this mode is activated, the movement keys will move you relative to your current view pitch (vertical look angle) when you're in a liquid or in fly mode.").."\n"..
S("• Default key: [L]").."\n"..
S("• No privilege required").."\n\n"..

S("Fast mode:").."\n"..
S("• Description: Allows you to move much faster. Hold down the the “Use” key [E] to move faster. In the client configuration, you can further customize fast mode.").."\n"..
S("• Default key: [J]").."\n"..
S("• Required privilege: fast").."\n\n"..

S("Fly mode:").."\n"..
S("• Description: Gravity doesn't affect you and you can move freely in all directions. Use the jump key to rise and the sneak key to sink.").."\n"..
S("• Default key: [K]").."\n"..
S("• Required privilege: fly").."\n\n"..

S("Noclip mode:").."\n"..
S("• Description: Allows you to move through walls. Only works when fly mode is enabled, too.").."\n"..
S("• Default key: [H]").."\n"..
S("• Required privilege: noclip")
}})

doc.add_entry("advanced", "coordinates", {
	name = S("Coordinates"),
	data = { text =
S("The world is a large cube. And because of this, a position in the world can be easily expressed with Cartesian coordinates. That is, for each position in the world, there are 3 values X, Y and Z.").."\n\n"..

S("Like this: (5, 45, -12)").."\n\n"..

S("This refers to the position where X=5, Y=45 and Z=-12. The 3 letters are called “axes”: Y is for the height. X and Z are for the horizontal position.").."\n\n"..

S("The values for X, Y and Z work like this:").."\n\n"..

S("• If you go up, Y increases").."\n"..
S("• If you go down, Y decreases").."\n"..
S("• If you follow the sun, X increases").."\n"..
S("• If you go to the reverse direction, X decreases").."\n"..
S("• Follow the sun, then go right: Z increases").."\n"..
S("• Follow the sun, then go left: Z decreases").."\n"..
S("• The side length of a full cube is 1").."\n\n"..

S("You can view your current position in the debug screen (open with [F5]).")
}})

doc.add_entry("advanced", "settings", {
	name = S("Settings"),
	data = {
		text =
S("There is a large variety of settings to configure Luanti. Pretty much every aspect can be changed that way.").."\n\n"..

S("These are a few of the most important gameplay settings:").."\n\n"..

S("• Damage enabled (enable_damage): Enables the health and breath attributes for all players. If disabled, players are immortal").."\n"..
S("• Creative Mode (creative_mode): Enables sandbox-style gameplay focusing on creativity rather than a challenging gameplay. The meaning depends on the game; usual changes are: Reduced dig times, easy access to almost all items, tools never wear off, etc.").."\n"..
S("• PvP (enable_pvp): Short for “Player vs Player”. If enabled, players can deal damage to each other").."\n\n"..

S("For a full list of all available settings, use the “All Settings” dialog in the main menu.")
}})

doc.add_entry("advanced", "online", {
	name = S("Online help"),
	data = { text=
S("You may want to check out these online resources related to Luanti:").."\n\n"..

S("Official homepage of Luanti: <https://luanti.org/>").."\n"..
S("The main place to find the most recent version of Luanti.").."\n\n"..

S("Luanti Documentation: <https://docs.luanti.org/>").."\n"..
S("A official documentation website for Luanti.").."\n\n"..

S("Web forums: <https://forum.luanti.org/>").."\n"..
S("A web-based discussion platform where you can discuss everything related to Luanti. This is also a place where player-made mods and games are published and discussed. The discussions are mainly in English, but there is also space for discussion in other languages.").."\n\n"..

S("Chat: <irc://irc.libera.chat/#luanti>").."\n"..
S("A generic Internet Relay Chat channel for everything related to Luanti where people can meet to discuss in real-time. If you do not understand IRC, see the Luanti Documentation for help.")
}})
