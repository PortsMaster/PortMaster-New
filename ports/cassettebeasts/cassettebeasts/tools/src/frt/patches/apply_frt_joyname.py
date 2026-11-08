#!/usr/bin/env python3
"""FRT 2.1.0 port patch (Godot 3): joypads reach the game with a mapping that matches, and an overridable name.

1. GUID: SDL >= 2.26 puts a CRC of the device name into bytes 2-3 of the joystick GUID; Godot 3 looks up
   SDL_GAMECONTROLLERCONFIG lines by the exact GUID string, and the lines PortMaster/Knulli export carry a zero
   CRC (Cube XX: 19000000010000000100000000010000). The lookup failed, so Godot used raw evdev button numbers.
   Now, like SDL's own lookup: the exact GUID when a line has it, else the GUID with the CRC zeroed (also what
   Godot's own Linux joypad driver reports).
2. FRT_JOY_NAME=<name>: the name the game reads (Input.get_joy_name) for every joypad; with
   FRT_JOY_NAME_MATCH=<text> only for joypads whose SDL name contains <text>. Godot 3 reports the name of the
   matched mapping line, so that line is added once more under the new name (the last matching line wins).
   Cassette Beasts picks its prompts and ui_accept by name: "Nintendo"/"Switch" -> Nintendo layout.
FRT_NO_JOYSTICK (apply_frt_nojoy.py) is untouched: with it set no joypad events arrive at all.
usage: apply_frt_joyname.py <frt dir>   (idempotent)
"""
import os
import sys

MARK = "JOYNAME-PATCH"


def once(s, old, new):
    assert s.count(old) == 1, (s.count(old), old[:70])
    return s.replace(old, new)


p = os.path.join(sys.argv[1], "frt_godot3.cc")
s = open(p, encoding="utf-8").read()
if MARK in s:
    print("already patched:", p)
    sys.exit(0)
s = once(s, """	void handle_js_status_event(int id, bool connected, const char *name, const char *guid) FRT_OVERRIDE {
		input_->joy_connection_changed(id, connected, name, guid);
	}
""", """	// %s: GUID without SDL's name CRC unless a mapping line has the exact one; FRT_JOY_NAME
	// (optionally only for SDL names containing FRT_JOY_NAME_MATCH) replaces the reported name
	void handle_js_status_event(int id, bool connected, const char *name, const char *guid) FRT_OVERRIDE {
		if (!connected) {
			input_->joy_connection_changed(id, connected, name, guid);
			return;
		}
		String joy_name = name ? String::utf8(name) : String();
		String uid = guid ? String(guid) : String();
		const String db = get_environment("SDL_GAMECONTROLLERCONFIG");
		if (uid.length() == 32 && uid.substr(4, 4) != "0000" && db.find(uid + ",") < 0)
			uid = uid.substr(0, 4) + "0000" + uid.substr(8);
		const String new_name = get_environment("FRT_JOY_NAME");
		const String match = get_environment("FRT_JOY_NAME_MATCH");
		if (new_name != "" && (match == "" || joy_name.find(match) >= 0)) {
			joy_name = new_name.replace(",", " ");
			const Vector<String> lines = db.split("\\n");
			String line;
			for (int i = 0; i < lines.size(); i++)
				if (uid != "" && lines[i].strip_edges().begins_with(uid + ","))
					line = lines[i].strip_edges();
			Vector<String> fields = line.split(",");
			if (fields.size() > 2) {
				fields.set(1, joy_name);
				input_->add_joy_mapping(String(",").join(fields));
			}
		}
		input_->joy_connection_changed(id, connected, joy_name, uid);
	}
""" % MARK)
open(p, "w", encoding="utf-8", newline="\n").write(s)
print("patched:", p)
