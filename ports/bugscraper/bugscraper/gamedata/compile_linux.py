#!/usr/bin/env python3
import os
import sys
import datetime as dt

def ask_for_input(msg, values):
	inp = ''
	while not inp in values:
		inp = input(f'{msg} {tuple(values)}: ')
	return inp

def mkdir(dir):
	if not os.path.isdir(f'{dir}'):
		os.system(f'mkdir {dir}')

def export_win64():
	path_love_win64 = 'love_win_64'
	path_exportdir = f'export/{gamename}'
	path_export_win64 = f'export/{gamename}/win64'
	path_temp_export = f'{gamename}_win_64'

	# Zip into a .love
	print("Generating .love...")
	os.system(f'zip -9 -r {gamename}.love . -x ".git/*" -x ".vscode/*" -x "love_win_64/*" -x "export/*"')

	# Export dirs
	mkdir('export')
	mkdir(f'export/{gamename}')
	mkdir(f'export/{gamename}/win64')

	mkdir(path_temp_export)

	if os.path.isdir(path_love_win64):
		# cat to a .exe
		print("Generating .exe...")
		os.system(f'cat {path_love_win64}/love.exe {gamename}.love > {gamename}.exe')
		os.system(f'mv {gamename}.exe {path_temp_export}/')
		os.system(f'rm {gamename}.love')

		# Copy dependencies
		print("Copying dependencies...")
		deps = ["SDL2.dll","OpenAL32.dll","license.txt","love.dll","lua51.dll","mpg123.dll","msvcp120.dll","msvcr120.dll"]
		for dep in deps:
			os.system(f'cp {path_love_win64}/{dep} {path_temp_export}/')
		
		# Zip
		print("Zipping game directory...")
		os.system(f'zip -r {gamename}_win_64.zip {path_temp_export}')

		# Moving files
		print("Moving files to export directory...")
		os.system(f'mv {gamename}_win_64.zip {gamename_time}_win_64.zip')
		os.system(f'mv {gamename_time}_win_64.zip {path_exportdir}')
		os.system(f'mv {path_temp_export}/* {path_export_win64}/')
		os.system(f'rm -r {path_temp_export}')
	else:
		print("ERROR: please define a love_win_64 folder and unzip the official LÖVE executable: https://www.love2d.org/")


today = str(dt.date.today()) 
y, m, d = today.split("-")
gamename = f'DemineurRoyale'
gamename_time = f'{gamename}_v0_{y[2:]}-{m}-{d}'

platforms = ("win32","win64","macos","linux")
platform = ''
args = sys.argv[1:]
for a in args:
	if a in platforms:
		platform = a

if platform == '':
	platform = ask_for_input('Platform (PROTIP: you can do `python3 compile_linux.py [platform]`)', platforms)

if platform == 'win64':
	export_win64()
		
print("Done")