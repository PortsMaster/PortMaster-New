--[[

  Copyright (c) 2013 Samuel Degrande

  This file is part of Freedroid

  Freedroid is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  Freedroid is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Freedroid; see the file COPYING. If not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
  MA  02111-1307  USA

]]--

--!
--! \file FDutils.lua
--! \brief This file contains some utility functions.
--!

-- Avoid doxygen to complain about missing namespace definition
--! \namespace Lua

--! \class Lua::FDutils
--! \brief Some utilities, grouped by fonctionnality

FDutils = {}

------------
--! \class Lua::FDutils::system
--! \brief Some OS related utilities
--! \memberof Lua::FDutils
------------

FDutils.system = {}

--! \fn table scandir(string subdir, string filter, string exclude)
--!
--! \brief Return a list of files contained in a directory
--!
--! \param  subdir  Path of the directory to scan, or array of path of directories
--! \param  filter  Regexp used to filter the content of the directory (a file name has to match the filter)
--! \param  exclude A list of filename to exclude from the returned list
--! \return         An alphabetically sorted list of filenames
--!
--! \memberof Lua::FDutils::system

function FDutils.system.scandir(subdir, filter, exclude)
	local filtered = {}
	local exclude_dict = {}
	local files = {}
	local subdirs = (type(subdir) == "table") and subdir or { subdir } -- Enfore subdirs to be a table
	for i,onedir in ipairs(subdirs) do
		local files_found = dir(onedir)
		for j,file in ipairs(files_found) do
			table.insert(files, file)
		end
	end
	filter = filter or ".*"
	exclude = exclude or {}

	if (files) then
		-- transform the exclude list into a 'dictionary'
		for i,v in ipairs(exclude) do
			exclude_dict[v] = true
		end

		-- for each file in the directory, check if it matches the regexp
		-- filter and if it is not in the exclude list
		for i,file in ipairs(files) do
			if ((file:match(filter) == file) and not exclude_dict[file]) then
				filtered[#filtered + 1] = file
			end
		end

		-- alphabetic sort
		table.sort(filtered)
	end

	return filtered
end

------------
--! \class Lua::FDutils::dump
--! \brief Utilities to dump the content of a Lua table
--! \memberof Lua::FDutils
------------

FDutils.dump = {}

--! \fn string value(void d, int indent)
--!
--! \brief Return a textual dump of a lua data. If the value is a table, generate a recursive dump.
--!
--! \param  d       Data to dump
--! \param  indent  Number of space indentation to use as a prefix to each dump line
--! \return         String containing the dump of the value
--!
--! \memberof Lua::FDutils::dump

function FDutils.dump.value(d, indent)
	local dump_str = ""
	--
	if (type(d) == "nil" or type(d) == "boolean" or type(d) == "number" or
	    type(d) == "userdata" or type(d) == "thread") then
		dump_str = tostring(d)
	--
	elseif (type(d) == "string") then
		dump_str = '"' .. d .. '"'
	--
	elseif (type(d) == "function") then
		-- Get the src file, and dump the lines defining the function
		local finfo = debug.getinfo(d)
		local f = io.open(finfo["source"]:sub(2, -1))
		local ln = 0
		local skip = 1
		for l in f:lines("*l") do
			ln = ln + 1
			if (ln == finfo["linedefined"]) then
				-- Count trailing spaces and tabs to skip them in the output
				skip = l:find("%S")
				-- Do not output the beginning of the line (the data's key was already written)
				local sub_start = l:find("function()")
				local sub_end = -1
				if (ln == finfo["lastlinedefined"]) then
					if (l:reverse():byte() == string.byte(",")) then
						sub_end = -2
					end
				end
				dump_str = dump_str .. l:sub(sub_start, sub_end)
			elseif (ln > finfo["linedefined"]) then
				local sub_end = -1
				if (ln == finfo["lastlinedefined"]) then
					if (l:reverse():byte() == string.byte(",")) then
						sub_end = -2
					end
				end
				dump_str = dump_str .. "\n" .. indent .. l:sub(skip, sub_end)
			end
			if (ln >= finfo["lastlinedefined"]) then break end
		end
	--
	elseif (type(d) == "table") then
		dump_str = dump_str .. "{\n"
		-- recursive call, with a larger indentation
		dump_str = dump_str .. FDutils.dump.table(d, "", indent.."  ")
		dump_str = dump_str .. indent.."}"
	end
	return dump_str
end

--! \fn string table(void t, string title, int indent)
--!
--! \brief Return a textual dump of a table.
--!
--! \param  t       Table to dump
--! \param  title   If not nil or empty, insert the title before the dump
--! \param  indent  Number of space indentation to use as a prefix to each dump line
--! \return         String containing the dump of the table
--!
--! \memberof Lua::FDutils::dump

function FDutils.dump.table(t, title, indent)
	local indent = indent or "  "
	local dump_str = ""
	if (title and title ~= "") then
		dump_str = dump_str .. indent .. title .. ":\n"
	end
	dump_str = dump_str .. indent .. "{\n"
	for k,v in pairs(t) do
		if (type(k) == "number") then
			dump_str = dump_str .. indent .. "  " .. '[' .. k .. '] = '
		else
			dump_str = dump_str .. indent .. "  " .. '["' .. k .. '"] = '
		end
		dump_str = dump_str .. FDutils.dump.value(v, indent.."  ")
		dump_str = dump_str .. (",\n")
	end
	dump_str = dump_str .. indent .. "}\n"
	return dump_str
end

------------
--! \class Lua::FDutils::text
--! \brief Utilities to manipulate texts
--! \memberof Lua::FDutils
------------

FDutils.text = {}

--! \fn string highlight(string text, string mode)
--!
--! \brief Add ANSI codes around a text, if the current terminal accepts them
--!
--! \param  text  Text to highlight
--! \param  mode  Highlight mode to use ("red" for instance)
--! \return       String containing the highlighted version of the input text
--!
--! \memberof Lua::FDutils::text

function FDutils.text.highlight(text, mode)
	-- Check color capability of the current terminal, if not yet done
	FDutils.text.color_cap = FDutils.text.color_cap or term_has_color_cap()
	-- ANSI prefix codes
	local highlight_mode = {
		black  = "\27[30m",
		red    = "\27[31m",
		green  = "\27[32m",
		yellow = "\27[33m",
		blue   = "\27[34m",
		purple = "\27[35m",
		cyan   = "\27[36m",
		white  = "\27[37m"
	}
	-- Return highlighted text if the terminal has color capabilities
	return FDutils.text.color_cap and highlight_mode[mode] .. text .. "\27[0m" or text
end

--! \fn string red(string text)
--!
--! \brief Shortcut function, to add ANSI red codes around a text, if the current terminal accepts them
--!
--! \param  text  Text to highlight
--! \return       String containing the red version of the input text
--!
--! \memberof Lua::FDutils::text

function FDutils.text.red(t)
	return FDutils.text.highlight(t, "red")
end

return FDutils
