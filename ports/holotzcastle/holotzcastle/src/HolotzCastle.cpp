/*
 * Holotz's Castle
 * Copyright (C) 2004 Juan Carlos Seijo Pérez
 * 
 * This program is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by the Free 
 * Software Foundation; either version 2 of the License, or (at your option) 
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for 
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 59 
 * Temple Place, Suite 330, Boston, MA 02111-1307 USA
 * 
 * Juan Carlos Seijo Pérez
 * jacob@mainreactor.net
 */

/** The game of Holotz's Castle.
 * @file    HolotzCastle.cpp
 * @author  Juan Carlos Seijo Pérez
 * @date    27/04/2004
 * @version 0.0.1 - 27/04/2004 - First version.
 * @version 0.0.2 - 02/01/2005 - Debian package adaptation, Miriam Ruiz.
 */

#include <HolotzCastle.h>

#ifndef HC_DATA_DIR
#define HC_DATA_DIR "res/"
#endif

/** This application.
 */
HCApp *theApp;

void HCApp::OnKeyUp(SDL_keysym key)
{
	switch (theApp->state)
	{
	case HCS_PLAYING:
		switch (key.sym)
		{
		case SDLK_ESCAPE:
			theApp->State(HCS_MENU);
			theApp->ProcessStateChange();
			break;

		case SDLK_p:
			theApp->State(HCS_PAUSED);
			theApp->ProcessStateChange();
			break;

		case SDLK_F1:
			theApp->State(HCS_PAUSED);
			theApp->ProcessStateChange();
			theApp->InitHelp();
			break;

		default:
			break;
		} // switch (key)
		break;

	case HCS_ENDLEVEL:
		break;

	case HCS_GAMEOVER:
		switch (key.sym)
		{
			// Skip game over screen
		case SDLK_RETURN:
			theApp->State(HCS_PLAYING);
			theApp->ProcessStateChange();
			break;

			// Goes to main menu
		case SDLK_ESCAPE:
			theApp->State(HCS_MENU);
			theApp->ProcessStateChange();
			break;

    default:
			break;
		}
		break;

	case HCS_SCRIPT:
		switch (key.sym)
		{
			// Skip script
		case SDLK_RETURN:
			theApp->State(HCS_ENDLEVEL);
			theApp->ProcessStateChange();
			break;

		case SDLK_SPACE:
			// Skip current dialog actions in the script
			{
				theApp->script.Skip();
			}
			break;

		case SDLK_ESCAPE:
			theApp->State(HCS_MENU);
			theApp->ProcessStateChange();
			break;

		case SDLK_p:
			theApp->State(HCS_PAUSED);
			theApp->ProcessStateChange();
			break;

    default:
			break;
		}
		break;

	case HCS_PAUSED:
		switch (key.sym)
		{
		case SDLK_ESCAPE:
		case SDLK_F1:
		case SDLK_p:
			if (theApp->imgHelp)
			{
				theApp->DestroyHelp();
			}

			theApp->State(theApp->lastState);
			theApp->ProcessStateChange();
			break;

		default:
			break;
		} // switch (key)
		break;

	case HCS_MENU:
		if (theApp->imgHelp)
		{
			switch (key.sym)
			{
			case SDLK_ESCAPE:
			case SDLK_F1:
			case SDLK_p:
				theApp->DestroyHelp();
				break;

  		default:
	  		break;
			}
		}
		else
		{
			theApp->menu->TrackKeyboard(key);
		}
		break;

	default:
	case HCS_INTRO:
	case HCS_CREDITS:
		theApp->State(HCS_MENU);
		theApp->ProcessStateChange();
		break;
	} // switch (appState)
}

HCApp::HCApp() : JApp("Holotz's Castle", 640, 480, false, 16, SDL_HWSURFACE | SDL_DOUBLEBUF)
{
	theApp = this;
	doInput = true;
	levelNumber = 1;
	SetOnKeyUp(&OnKeyUp);
	imgBack = 0;
	textBack = 0;
	imgHelp = 0;
	imgIntro = 0;
	textIntro = 0;
	menu = 0;
	imgMenu = 0;
	state = lastState = HCS_INTRO;
	memset(imgCredits, 0, sizeof(imgCredits));
	memset(textCredits, 0, sizeof(textCredits));
	fps = 25;
	playlistName = 0;
	stateChanged = false;
}

bool HCApp::Init(s32 argc, char **argv)
{
	// Loads fonts
	if (!InitFonts())
	{
		fprintf(stderr, "Couldn't load fonts.\n");
		return false;
	}

	// Tries to get the current preferences
	if (0 != preferences.Load())
	{
		// Generates a new preferences file if it doesn't exist
		if (0 != preferences.Save())
		{
			fprintf(stderr, "Couldn't write preferences file. Check the manual.\n");
		}
	}
	else
	{
		depth = preferences.BPP();
		fullScreen = preferences.Fullscreen();
		if (preferences.VideoModes())
		{
			width = preferences.VideoModes()[preferences.VideoMode()].w;
			height = preferences.VideoModes()[preferences.VideoMode()].h;
		}
	}

	// Sets the icon image name
	Icon(HC_DATA_DIR "icon/icon.bmp");

	ParseArgs(argc, argv);

	// Tries to get the current playlist
	if (!playlist.Load(playlistName))
	{
		fprintf(stderr, "Couldn't load playlist file. Check the manual.\n");
		return false;
	}

	if (!JApp::Init(0, 0))
	{
		return false;
	}

	if (!InitSound())
	{
		fprintf(stderr, "Failed to init sound. Check the manual.\n");
	}
	else
	{
		SoundEnabled(preferences.Sound());
	}
	
	// Quitamos el cursor del ratón
	MouseCursor(false);

	State(HCS_INTRO);
	ProcessStateChange();
 
	return true;
}

bool HCApp::InitSound()
{
	// Initializes the sound
	return (0 == mixer.Init());
}

bool HCApp::InitFonts()
{
	fontSmall.Destroy();
	fontMedium.Destroy();
	fontLarge.Destroy();

	// Loads the fonts according to the resolution
	if (!JFile::Exists(HC_DATA_DIR "font/font.ttf"))
	{
		fprintf(stderr, 
						"Could not find data directory.\n\n"
						"Possible solutions are:\n"
						" - Open folder JLib-1.3.1/Games/HolotzCastle and double.\n"
						"   click 'holotz-castle' application icon.\n"
						" - Maybe you did 'make' but didn't do 'make install'.\n"
						" - Else, try to reinstall the game.\n");
		return false;
	}

	if (JFont::Init() &&
			fontSmall.Open(HC_DATA_DIR "font/font.ttf", (long)JMax(11, height/35)) &&
			fontMedium.Open(HC_DATA_DIR "font/font.ttf", (long)JMax(12, height/30)) &&
			fontLarge.Open(HC_DATA_DIR "font/font.ttf", (long)JMax(13, height/25)))
	{
		level.SetTimerFont(&fontLarge);
		return true;
	}

	return false;
}

bool HCApp::InitMenu()
{
	// Reflects changes in resolution
	if (!InitFonts())
	{
		fprintf(stderr, "Couldn't load fonts.\n");
		return false;
	}

	// Load game slots
	if (!InitSlots())
	{
		fprintf(stderr, "Couldn't load game slots.\n");
		return false;
	}

	imgMenu = new JImage;

	if (!imgMenu->Load(HC_DATA_DIR "main/main.tga"))
	{
		return false;
	}

	if (imgMenu->Height() > Height())
	{
		float h = float(imgMenu->Height());
		do 
		{
			h /= 1.5f;
		}
		while (h > Height());
		
		JImage *tmp = imgMenu;
		imgMenu = imgMenu->Scale(h/float(imgMenu->Height()), h/float(imgMenu->Height()));
		
		if (imgMenu)
			delete tmp;
		else
			imgMenu = tmp;
	}

	imgMenu->Pos((width - imgMenu->Width())/2, (height - imgMenu->Height())/8);

	JDELETE(menu);
	menu = new JTextMenu;

	// Reads the menu file in the correct language
	char str[256];
	snprintf(str, sizeof(str), HC_DATA_DIR "menu/%s/menu.txt", preferences.LangCodes()[preferences.CurLang()]);

	JTextFile f;
	if (!f.Load(str, "rb"))
	{
		return false;
	}

	// Adds the options
	JTree<JTextMenuEntry *>::Iterator *it = menu->Menu();
	
	if (f.ReadLine(str)) it->Data(new JTextMenuEntry(str, &OnContinue, 0)); else return false;               // Continue game
	if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, 0, 0)); else return false;                    // Play
	{
		if (playlist.Size() > 0) it->AddBranchGo(new JTextMenuEntry(playlist[0], &OnNew, 0)); else return false;//  Story 1
		
		for (s32 sn = 1; sn < playlist.Size(); ++sn)
		{
			it->AddNodeGo(new JTextMenuEntry(playlist[sn], &OnNew, JCAST_S32_TO_VOIDPTR(sn)));                   // Story N
		}

		it->Parent();
	}
	if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, &OnHelp, 0)); else return false;              // Help
	if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, 0, 0)); else return false;                    // Options
	{
		if (f.ReadLine(str)) it->AddBranchGo(new JTextMenuEntry(str, 0, 0)); else return false;                //  Video
		{
			if (f.ReadLine(str)) it->AddBranchGo(new JTextMenuEntry(str, 0, 0)); else return false;              //   Size
			{
				// Shows all the supported modes in the current depth
				if (preferences.NumVideoModes() > 0)
				{
					snprintf(str, 128, "%dx%d", preferences.VideoModes()[0].w, preferences.VideoModes()[0].h);
					it->AddBranchGo(new JTextMenuEntry(str, &OnVideoMode, (void *)0));                               //    Modes
					
					// Adds the rest of video modes found
					for (s32 i = 1; i < preferences.NumVideoModes(); ++i)
					{
						snprintf(str, 128, "%dx%d", preferences.VideoModes()[i].w, preferences.VideoModes()[i].h);
						it->AddNodeGo(new JTextMenuEntry(str, &OnVideoMode, JCAST_S32_TO_VOIDPTR(i)));                 //    Modes
					}

					it->Parent();
				}
			}

			if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, 0, 0)); else return false;                //   BPP
			{
				it->AddBranchGo(new JTextMenuEntry("32", &OnBPP, (void *)32));                                     //    32
				it->AddNodeGo(new JTextMenuEntry("24", &OnBPP, (void *)24));                                       //    24
				it->AddNodeGo(new JTextMenuEntry("16", &OnBPP, (void *)16));                                       //    16
				it->AddNodeGo(new JTextMenuEntry("8", &OnBPP, (void *)8));                                         //    8
				it->Parent();
			}
			
			if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, 0, 0)); else return false;                //   Window
			{
				if (f.ReadLine(str))                                                                               //    Windowed
					it->AddBranchGo(new JTextMenuEntry(str, &OnWindowMode, (void *)0));
				else return false;

				if (f.ReadLine(str))                                                                               //    Fullscreen
					it->AddNodeGo(new JTextMenuEntry(str, &OnWindowMode, (void *)1));
				else return false;

				it->Parent();
			}

			if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, &OnDefaults)); else return false;         //   Defaults
			it->Parent();
		}	
		
		if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, 0, 0)); else return false;                  //  Sound
		{
			if (f.ReadLine(str)) it->AddBranchGo(new JTextMenuEntry(str, &OnSound, (void*)1)); else return false;//   On
			if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, &OnSound, (void*)0)); else return false;  //   Off
			it->Parent();
		}
			
		if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, 0, 0)); else return false;                  //  Difficulty
		{
			if (f.ReadLine(str))                                                                                 //   Easy
				it->AddBranchGo(new JTextMenuEntry(str, &OnDifficulty, (void*)HCPREFERENCES_TOY)); 
			else return false;
			if (f.ReadLine(str))                                                                                 //   Easy
				it->AddNodeGo(new JTextMenuEntry(str, &OnDifficulty, (void*)HCPREFERENCES_EASY)); 
			else return false;
			if (f.ReadLine(str))                                                                                 //   Medium
				it->AddNodeGo(new JTextMenuEntry(str, &OnDifficulty, (void*)HCPREFERENCES_NORMAL)); 
			else return false;
			if (f.ReadLine(str))                                                                                 //   Hard
				it->AddNodeGo(new JTextMenuEntry(str, &OnDifficulty, (void*)HCPREFERENCES_HARD)); 
			else return false;  
			it->Parent();
		}

		if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, 0, 0)); else return false;                  //  Language
		{
			if (preferences.NumLangs() > 0)
			{
				it->AddBranchGo(new JTextMenuEntry(preferences.Langs()[0], &OnLanguage, (void *)0));               //   Available langs
				for (s32 c = 1; c < preferences.NumLangs(); ++c)
				{                                                
					it->AddNodeGo(new JTextMenuEntry(preferences.Langs()[c], &OnLanguage, JCAST_S32_TO_VOIDPTR(c))); //   Available langs
				}

				it->Parent();
			}
		}
		it->Parent();
	}
	
	char strLev[64];
	if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, 0, 0)); else return false;                    // Load
	{
		if (strlen(saveData[0].Story()) == 0)
		{
			// Empty slot
			it->AddBranchGo(new JTextMenuEntry("< ******* >", 0, 0));                                            //   Slot 0
		}
		else
		{ 
			snprintf(strLev, sizeof(strLev), "< %s - %d >", saveData[0].Story(), saveData[0].Level());
			it->AddBranchGo(new JTextMenuEntry(strLev, &OnLoad, (void *)0));                                     //   Slot 0
		}
		
		for (s32 i = 1; i < HC_NUM_SLOTS; ++i)
		{
			if (strlen(saveData[i].Story()) == 0)
			{
				// Empty slot
				it->AddNodeGo(new JTextMenuEntry("< ******* >", 0, 0));                                            //    ...
			}
			else
			{ 
				snprintf(strLev, sizeof(strLev), "< %s - %d >", saveData[i].Story(), saveData[i].Level());
				it->AddNodeGo(new JTextMenuEntry(strLev, &OnLoad, JCAST_S32_TO_VOIDPTR(i)));                       //   Slot N
			}
		}
		it->Parent();
	}

	if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, 0, 0)); else return false;                    // Save
	{
		if (strlen(saveData[0].Story()) == 0)
		{
			// Empty slot
			it->AddBranchGo(new JTextMenuEntry("< ******* >", &OnSave, (void *)0));                              //   Slot 0
		}
		else
		{ 
			snprintf(strLev, sizeof(strLev), "< %s - %d >", saveData[0].Story(), saveData[0].Level());
			it->AddBranchGo(new JTextMenuEntry(strLev, &OnSave, (void *)0));                                     //   Slot 0
		}
		
		for (s32 i = 1; i < HC_NUM_SLOTS; ++i)
		{
			if (strlen(saveData[i].Story()) == 0)
			{
				// Empty slot
				it->AddNodeGo(new JTextMenuEntry("< ******* >", &OnSave, JCAST_S32_TO_VOIDPTR(i)));                //    ...
			}
			else
			{ 
				snprintf(strLev, sizeof(strLev), "< %s - %d >", saveData[i].Story(), saveData[i].Level());
				it->AddNodeGo(new JTextMenuEntry(strLev, &OnSave, JCAST_S32_TO_VOIDPTR(i)));                       //   Slot N
			}
		}
		it->Parent();
	}

	if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, &OnCredits, this)); else return false;        // Credits
	if (f.ReadLine(str)) it->AddNodeGo(new JTextMenuEntry(str, &OnExit, this)); else return false;           // Exit

	it->Root();

	JTextMenuConfig cfg;
	memset(&cfg, 0, sizeof(cfg));
	cfg.renderMode = JTEXTMENU_BLENDED;
	cfg.layout = JTEXTMENU_RIGHT;
	cfg.layoutV = JTEXTMENU_DOWN;
	cfg.trackKeyboard = true;
	cfg.autoEnter = true;
	cfg.lineDistance = 0;
	cfg.font = &fontLarge;
	cfg.hiColor.r = cfg.hiColor.g = cfg.hiColor.b = 255;
	cfg.color.b = 255;
	cfg.color.r = cfg.color.g = 128;
	menu->Pos(width, height);

	if (!menu->Init(cfg))
	{
		return false;
	}

	menu->Menu()->Root();

	// Loads the main title's sounds
	if (musicMainTitle.LoadWave(HC_DATA_DIR "sound/HCMainTitle.wav"))
	{
		if (SoundEnabled())
		{
			musicMainTitle.FadeIn(1000, -1, -1);
		}
	}

	imgMenu->Alpha(0);
	
	return true;
}

bool HCApp::InitIntro()
{
	SDL_Color fg = {0xff, 0xcc, 0x00, 0x00}, bg = {0x00, 0x00, 0x00, 0x00};

	imgIntro = new JImage;
	imgFatalFun = new JImage;
	
	char str[256];
	snprintf(str, sizeof(str) - 1, HC_DATA_DIR "intro/%s/intro.txt", preferences.LangCodes()[preferences.CurLang()]);
	
	JTextFile f;
	if (!f.Load(str))
	{
		strcpy(str, "Proudly presents...");
	}
	else
	{
		f.ReadWord(str);
	}

	if (imgIntro->Load(HC_DATA_DIR "intro/intro.tga", true) &&
			imgFatalFun->Load(HC_DATA_DIR "intro/ff.tga", true, 0x0000ffff) &&
			0 != (textIntro = fontMedium.RenderTextShaded(str, fg, bg)))
	{
		if (imgIntro->Width() > width)
		{
			float w = float(imgIntro->Width());
			do 
			{
				w /= 1.5f;
			}
			while (w > Width());
			
			JImage *tmp = imgIntro;
			imgIntro = imgIntro->Scale(w/float(imgIntro->Width()), w/float(imgIntro->Width()));
			
			if (imgIntro)
				delete tmp;
			else
				imgIntro = tmp;
		}

		if (imgFatalFun->Width() > width)
		{
			float w = float(imgFatalFun->Width());
			do 
			{
				w /= 1.5f;
			}
			while (w > Width());
			
			JImage *tmp = imgFatalFun;
			imgFatalFun = imgFatalFun->Scale(w/float(imgFatalFun->Width()), w/float(imgFatalFun->Width()));
			
			if (imgFatalFun)
				delete tmp;
			else
				imgFatalFun = tmp;
		}

		imgIntro->Alpha(0);
		imgFatalFun->Alpha(0);
		textIntro->Alpha(0);
		imgIntro->Pos(((width - imgIntro->Width())/2), ((height - imgIntro->Height())/2));
		imgFatalFun->Pos(((width - imgFatalFun->Width())/2), ((height - imgFatalFun->Height())/2));
		textIntro->Pos(((width - textIntro->Width())/2), ((imgIntro->Y() + imgIntro->Height()) + (height - (imgIntro->Y() + imgIntro->Height()) - textIntro->Height())/2));

		timerGeneral.Start(1000);

		return true;
	}

	fprintf(stderr, "Error loading intro. Switching to game menu.\n");
	
	return false;
}

bool HCApp::InitPaused()
{
	// Pauses the level
	level.Pause(true);

	// Copies the scene as is
	JImage img(screen);
	JDELETE(imgBack);
	imgBack = new JImage(img.Width(), img.Height());
	imgBack->Paste(&img, 0, 0, img.Width(), img.Height());

	imgBack->Alpha(255);
	JDELETE(textBack);

	// Reads the pause file in the correct language
	char str[256];
	snprintf(str, sizeof(str), HC_DATA_DIR "messages/%s/messages.txt", preferences.LangCodes()[preferences.CurLang()]);

	JTextFile f;
	if (!f.Load(str, "rb"))
	{
		snprintf(str, sizeof(str), "... ZzZzZz ...");
	}
	else
	{
		f.NextLine();
		f.ReadLine(str);
	}

	textBack = new HCText;
	textBack->Init(HCTEXTTYPE_NARRATIVE, str, &level.Theme(), &fontLarge, JFONTALIGN_CENTER, false, 0);
	textBack->Pos((Width() - textBack->Image().Width())/2, (Height() - textBack->Image().Height())/2);
	
	return true;
}
	
bool HCApp::InitPlaying()
{
	if (SoundEnabled())
	{
		musicMainTitle.FadeOut(3000);
	}

	// Loads the world map and character
	switch (LoadWorld())
	{
		// Error
		case 0:
			fprintf(stderr, "Error loading the world.\n");
			return false;
		
			// Game end
		case -1:
			State(HCS_CREDITS);
			ProcessStateChange();
			return true;
	}

	// Checks for an existing script
	JString str;
	str.Format("%s%s/script/%s/level%03d.hcs", playlist.StoryDir(), playlist.StoryName(), preferences.LangCodes()[preferences.CurLang()], levelNumber);
	
	if (JFile::Exists(str))
	{
		if (!script.Load(str))
		{
			fprintf(stderr, "Error loading the level script %s.\n", str.Str());
			return false;
		}
		else
		{
			level.Scripted(true);
			State(HCS_SCRIPT);
			ProcessStateChange();
		}
	}
	else
	{
		level.Scripted(false);
		
		// Loads the start-of-level music
		if (SoundEnabled() && musicBeginLevel.LoadWave(HC_DATA_DIR "sound/HCBeginLevel.wav"))
		{
			musicBeginLevel.Play();
		}

		// Starts the level timer
		level.Start();
	}

	return true;
}
	
bool HCApp::InitGameOver()
{
	timerGeneral.Start();

	// Loads the game over music
	if (SoundEnabled() && musicGameOver.LoadWave(HC_DATA_DIR "sound/HCGameOver.wav"))
	{
		musicGameOver.FadeIn(5000, -1, 0);
	}
	
	return true;
}

bool HCApp::InitEndLevel()
{
	// Copies the scene as is
	JImage img(screen);
	JDELETE(imgBack);
	imgBack = new JImage(img.Width(), img.Height());

	imgBack->Paste(&img, 0, 0, img.Width(), img.Height());
	
	return true;
}
	
bool HCApp::InitCredits()
{
	const char *files[HCCREDITS_IMAGE_COUNT] = {HC_DATA_DIR "credits/programming.tga",
																							HC_DATA_DIR "credits/story.tga",
																							HC_DATA_DIR "credits/drawing0.tga",
																							HC_DATA_DIR "credits/drawing1.tga",
																							HC_DATA_DIR "credits/drawing2.tga",
																							HC_DATA_DIR "credits/animation0.tga",
																							HC_DATA_DIR "credits/animation1.tga",
																							HC_DATA_DIR "credits/animation2.tga",
																							HC_DATA_DIR "credits/animation3.tga",
																							HC_DATA_DIR "credits/music.tga",
																							HC_DATA_DIR "main/main.tga",
																							HC_DATA_DIR "intro/intro.tga"};

	const char *strings[HCCREDITS_TEXT_COUNT] = {"Programming\nJuan Carlos Seijo Pérez",
																							 "Story\nJuan Carlos Seijo Pérez",
																							 "Graphics\nJuan Carlos Seijo Pérez",
																							 "Animation\nJuan Carlos Seijo Pérez",
																							 "Music\nJuan Carlos Seijo Pérez",
																							 "Thanks for playing!\nCheck for more games at\nwww.mainreactor.net\n&\nwww.FatalFun.com",
																							 "Holotz's Castle\n(C) Juan Carlos Seijo Pérez 2004-2009",
																							 ACKNOWLEDGEMENTS};

	bool ok;
	ok = true;
	for (s32 i = 0; ok && i < HCCREDITS_IMAGE_COUNT; ++i)
	{
		JDELETE(imgCredits[i]);
		imgCredits[i] = new JImage();
		ok = imgCredits[i]->Load(files[i]);
	}

	if (!ok)
	{
		return false;
	}
	
	// Adjusts main and intro images so they fit on the screen
	if (width < imgCredits[HCCREDITS_HOLOTZCASTLE]->Width())
	{ 
		JImage *tmp;
		float factor = 0.8f * width/imgCredits[HCCREDITS_HOLOTZCASTLE]->Width();
		if ((tmp = imgCredits[HCCREDITS_HOLOTZCASTLE]->Scale(factor, factor)))
		{
			JDELETE(imgCredits[HCCREDITS_HOLOTZCASTLE]);
			imgCredits[HCCREDITS_HOLOTZCASTLE] = tmp;
		}
		else
		{
			return false;
		}
	}

	if (width < imgCredits[HCCREDITS_LOGO]->Width())
	{ 
		JImage *tmp;
		float factor = 0.8f * width/imgCredits[HCCREDITS_LOGO]->Width();
		if ((tmp = imgCredits[HCCREDITS_LOGO]->Scale(factor, factor)))
		{
			JDELETE(imgCredits[HCCREDITS_LOGO]);
			imgCredits[HCCREDITS_LOGO] = tmp;
		}
		else
		{
			return false;
		}
	}

	SDL_Color fg;
	fg.b = 255;
	fg.r = fg.g = 128;

	SDL_Color bg;
	bg.r = bg.g = bg.b = 0;
	
	s8 dr = 128/(HCCREDITS_TEXT_COUNT - 1), dg = -(fg.g - 0xcc)/(HCCREDITS_TEXT_COUNT - 1), db = -255/(HCCREDITS_TEXT_COUNT - 1);

	ok = true;
	
	for (s32 i = 0; ok && i < HCCREDITS_TEXT_COUNT; ++i, fg.r += dr, fg.g += dg, fg.b += db)
	{
		JDELETE(textCredits[i]);
			
		textCredits[i] = fontLarge.PrintfShaded(JFONTALIGN_CENTER, fg, bg, strings[i]);
		ok = (textCredits[i] != 0);
	}

	if (!ok)
	{
		return false;
	}

	// Initializes positions

	// Adjusts initial Y
	textCredits[HCCREDITS_ACK_TEXT]->Y(height);

	imgCredits[HCCREDITS_PROGRAMMING]->Y(textCredits[HCCREDITS_ACK_TEXT]->Y() + textCredits[HCCREDITS_ACK_TEXT]->Height() + Height()/2);
	textCredits[HCCREDITS_PROGRAMMING_TEXT]->Y(imgCredits[HCCREDITS_PROGRAMMING]->Y() + imgCredits[HCCREDITS_PROGRAMMING]->Height());

	imgCredits[HCCREDITS_STORY]->Y(imgCredits[HCCREDITS_PROGRAMMING]->Y() + (2 * imgCredits[HCCREDITS_PROGRAMMING]->Height()));
	textCredits[HCCREDITS_STORY_TEXT]->Y(imgCredits[HCCREDITS_STORY]->Y() + imgCredits[HCCREDITS_STORY]->Height());

	imgCredits[HCCREDITS_DRAWING0]->Y(imgCredits[HCCREDITS_STORY]->Y() + (2 * imgCredits[HCCREDITS_STORY]->Height()));
	imgCredits[HCCREDITS_DRAWING1]->Y(imgCredits[HCCREDITS_STORY]->Y() + (2 * imgCredits[HCCREDITS_STORY]->Height()));
	imgCredits[HCCREDITS_DRAWING2]->Y(imgCredits[HCCREDITS_STORY]->Y() + (2 * imgCredits[HCCREDITS_STORY]->Height()));
	textCredits[HCCREDITS_DRAWING_TEXT]->Y(imgCredits[HCCREDITS_DRAWING0]->Y() + imgCredits[HCCREDITS_DRAWING0]->Height());

	imgCredits[HCCREDITS_ANIMATION0]->Y(imgCredits[HCCREDITS_DRAWING0]->Y() + (2 * imgCredits[HCCREDITS_DRAWING0]->Height()));
	imgCredits[HCCREDITS_ANIMATION1]->Y(imgCredits[HCCREDITS_DRAWING0]->Y() + (2 * imgCredits[HCCREDITS_DRAWING0]->Height()));
	imgCredits[HCCREDITS_ANIMATION2]->Y(imgCredits[HCCREDITS_DRAWING0]->Y() + (2 * imgCredits[HCCREDITS_DRAWING0]->Height()));
	imgCredits[HCCREDITS_ANIMATION3]->Y(imgCredits[HCCREDITS_DRAWING0]->Y() + (2 * imgCredits[HCCREDITS_DRAWING0]->Height()));
	textCredits[HCCREDITS_ANIMATION_TEXT]->Y(imgCredits[HCCREDITS_ANIMATION0]->Y() + imgCredits[HCCREDITS_ANIMATION0]->Height());

	imgCredits[HCCREDITS_MUSIC]->Y(imgCredits[HCCREDITS_ANIMATION0]->Y() + (2 * imgCredits[HCCREDITS_ANIMATION0]->Height()));
	textCredits[HCCREDITS_MUSIC_TEXT]->Y(imgCredits[HCCREDITS_MUSIC]->Y() + imgCredits[HCCREDITS_MUSIC]->Height());

	imgCredits[HCCREDITS_HOLOTZCASTLE]->Y(imgCredits[HCCREDITS_MUSIC]->Y() + (2 * imgCredits[HCCREDITS_MUSIC]->Height()));
	textCredits[HCCREDITS_HOLOTZCASTLE_TEXT]->Y(imgCredits[HCCREDITS_HOLOTZCASTLE]->Y() + imgCredits[HCCREDITS_HOLOTZCASTLE]->Height());

	imgCredits[HCCREDITS_LOGO]->Y(imgCredits[HCCREDITS_HOLOTZCASTLE]->Y() + (2 * imgCredits[HCCREDITS_HOLOTZCASTLE]->Height()));
	textCredits[HCCREDITS_LOGO_TEXT]->Y(imgCredits[HCCREDITS_LOGO]->Y() + imgCredits[HCCREDITS_LOGO]->Height());

	// Adjusts initial X
	textCredits[HCCREDITS_ACK_TEXT]->X((float)(width - textCredits[HCCREDITS_ACK_TEXT]->Width())/2);

 	imgCredits[HCCREDITS_PROGRAMMING]->X(float(width) * 0.3f);
	textCredits[HCCREDITS_PROGRAMMING_TEXT]->X((float)(width - textCredits[HCCREDITS_PROGRAMMING_TEXT]->Width())/2);

	imgCredits[HCCREDITS_STORY]->X(float(width) * 0.5f);
	textCredits[HCCREDITS_STORY_TEXT]->X((float)(width - textCredits[HCCREDITS_STORY_TEXT]->Width())/2);

	imgCredits[HCCREDITS_DRAWING0]->X(float(width) * 0.2f);
	imgCredits[HCCREDITS_DRAWING1]->X(float(width) * 0.2f);
	imgCredits[HCCREDITS_DRAWING2]->X(float(width) * 0.2f);
	textCredits[HCCREDITS_DRAWING_TEXT]->X((float)(width - textCredits[HCCREDITS_DRAWING_TEXT]->Width())/2);

	imgCredits[HCCREDITS_ANIMATION0]->X(float(width) * 0.6f);
	imgCredits[HCCREDITS_ANIMATION1]->X(float(width) * 0.6f);
	imgCredits[HCCREDITS_ANIMATION2]->X(float(width) * 0.6f);
	imgCredits[HCCREDITS_ANIMATION3]->X(float(width) * 0.6f);
	textCredits[HCCREDITS_ANIMATION_TEXT]->X((float)(width - textCredits[HCCREDITS_ANIMATION_TEXT]->Width())/2);

	imgCredits[HCCREDITS_MUSIC]->X(float(width) * 0.4f);
	textCredits[HCCREDITS_MUSIC_TEXT]->X((float)(width - textCredits[HCCREDITS_MUSIC_TEXT]->Width())/2);

	imgCredits[HCCREDITS_HOLOTZCASTLE]->X((float)(width - imgCredits[HCCREDITS_HOLOTZCASTLE]->Width())/2);
	textCredits[HCCREDITS_HOLOTZCASTLE_TEXT]->X((float)(width - textCredits[HCCREDITS_HOLOTZCASTLE_TEXT]->Width())/2);

	imgCredits[HCCREDITS_LOGO]->X((float)(width - imgCredits[HCCREDITS_LOGO]->Width())/2);
	textCredits[HCCREDITS_LOGO_TEXT]->X((float)(width - textCredits[HCCREDITS_LOGO_TEXT]->Width())/2);

	// Adjust alpha values and control variables for drawing and animation credits
	imgCredits[HCCREDITS_DRAWING1]->Alpha(0);
	imgCredits[HCCREDITS_DRAWING2]->Alpha(0);
	imgCredits[HCCREDITS_ANIMATION1]->Alpha(0);
	imgCredits[HCCREDITS_ANIMATION2]->Alpha(0);
	imgCredits[HCCREDITS_ANIMATION3]->Alpha(0);
	outDrawing = 0;
	inDrawing = 1;
	outAnimation = 0;
	inAnimation = 1;

	// Loads the credits' sounds
	if (musicCredits.LoadWave(HC_DATA_DIR "sound/HCCredits.wav"))
	{
		musicCredits.FadeIn(1000, -1, -1);
	}

	return true;
}

bool HCApp::InitHelp()
{
	JDELETE(imgHelp);
	
	JTextFile f;
	char str[256];

	snprintf(str, sizeof(str), HC_DATA_DIR "help/%s/help.txt", preferences.LangCodes()[preferences.CurLang()]);

	if (!f.Load(str, "rt"))
	{
		fprintf(stderr, "Couldn't load help file %s. Check manual.\n", str);
		return false;
	}
	
	s32 sz = f.BufferSize();
	char *strText = new char[sz + 1];
	memcpy(strText, f.Buffer(), sz);
	strText[sz] = '\0';
	
	SDL_Color fg = {0xff, 0xcc, 0x00, 0xff};
	SDL_Color bg = {0x00, 0x00, 0x33, 0xff};

	imgHelp = fontLarge.PrintfShaded(JFONTALIGN_CENTER, fg, bg, strText);

	if (!imgHelp)
	{
		fprintf(stderr, "Couldn't create help image, out of memory. Check manual.\n");
		JDELETE_ARRAY(strText);
		return false;
	}

	JDELETE_ARRAY(strText);
	imgHelp->Pos((Width() - imgHelp->Width())/2,
							 (Height() - imgHelp->Height())/2);
	imgHelp->Alpha(128);

	return true;
}

void HCApp::DestroyHelp()
{
	JDELETE(imgHelp);
}

bool HCApp::InitSlots()
{
	bool ok = true;
	for (s32 i = 0; i < HC_NUM_SLOTS && ok; ++i)
	{
		// Loads an existing slot
		saveData[i].Load(i);
	}

	return ok;
}

void HCApp::OnExit(void *data)
{
  ((HCApp*)data)->Exit();
}

void HCApp::OnCredits(void *data)
{
  ((HCApp*)data)->State(HCS_CREDITS);
}

void HCApp::OnDifficulty(void *data)
{
	HCPreferences::Prefs()->Difficulty((long)data);
	HCPreferences::Prefs()->Save();
	theApp->menu->Menu()->Root();
}

void HCApp::OnSound(void *data)
{
	HCApp *a = (HCApp *)App();
	a->SoundEnabled(0 != (long)data);

	if (0 != (long)data)
	{
		if (a->SoundEnabled())
		{
			a->Mixer().Volume(-1, MIX_MAX_VOLUME);
			
			// Sound successfully enabled
			a->preferences.Sound(true);
			a->preferences.Save();
			if (!a->musicMainTitle.IsPlaying())
			{
				a->musicMainTitle.FadeIn(1000, -1, -1);
			}
		}
	}
	else
	{
		a->musicMainTitle.Halt();
		a->preferences.Sound(false);
		a->preferences.Save();
	}
}

void HCApp::OnNew(void *data)
{
	if (theApp->playlist.GoTo(theApp->playlist[JCAST_VOIDPTR_TO_S32(data)]))
	{
		theApp->levelNumber = 1;
		theApp->State(HCS_PLAYING);
	}
}

void HCApp::OnContinue(void *data)
{
	// Just play, at the story it was
	theApp->State(HCS_PLAYING);
}

void HCApp::OnHelp(void *data)
{
	theApp->InitHelp();
}

void HCApp::OnVideoMode(void *data)
{
	HCApp *a = (HCApp *)App();
	a->preferences.VideoMode(JCAST_VOIDPTR_TO_S32(data));
	a->preferences.Save();
	App()->Resize(a->preferences.VideoModes()[JCAST_VOIDPTR_TO_S32(data)].w, 
								a->preferences.VideoModes()[JCAST_VOIDPTR_TO_S32(data)].h, 
								a->preferences.Fullscreen());
	a->State(HCS_MENU);
}

void HCApp::OnBPP(void *data)
{
	HCApp *a = (HCApp *)App();
	a->preferences.BPP(JCAST_VOIDPTR_TO_S32(data));
	a->preferences.Save();
	a->depth = JCAST_VOIDPTR_TO_S32(data);
	App()->Resize(a->preferences.VideoModes()[a->preferences.VideoMode()].w, 
								a->preferences.VideoModes()[a->preferences.VideoMode()].h,
								a->preferences.Fullscreen());
	a->State(HCS_MENU);
}

void HCApp::OnWindowMode(void *data)
{
	HCApp *a = (HCApp *)App();
	a->preferences.Fullscreen(JCAST_VOIDPTR_TO_S32(data));
	a->preferences.Save();
	App()->Resize(a->preferences.VideoModes()[a->preferences.VideoMode()].w, 
								a->preferences.VideoModes()[a->preferences.VideoMode()].h,
								a->preferences.Fullscreen());
	a->State(HCS_MENU);
}

void HCApp::OnLanguage(void *data)
{
	HCApp *a = (HCApp *)App();
	a->preferences.CurLang(JCAST_VOIDPTR_TO_S32(data));
	a->preferences.Save();
	a->State(HCS_MENU);
}

void HCApp::OnDefaults(void *data)
{
	HCApp *a = (HCApp *)App();
	a->preferences.Reset();
	a->preferences.Save();
	App()->Resize(a->preferences.VideoModes()[JCAST_VOIDPTR_TO_S32(data)].w, 
								a->preferences.VideoModes()[JCAST_VOIDPTR_TO_S32(data)].h, 
								a->preferences.Fullscreen());
	a->State(HCS_MENU);
}

void HCApp::OnLoad(void *data)
{
	HCApp *app = (HCApp *)App();
	if (app->playlist.GoTo(app->saveData[JCAST_VOIDPTR_TO_S32(data)].Story()))
	{
		app->levelNumber = app->saveData[JCAST_VOIDPTR_TO_S32(data)].Level();
		app->State(HCS_PLAYING);
	}
}

void HCApp::OnSave(void *data)
{
	HCApp *app = (HCApp *)App();
	if (app->saveData[JCAST_VOIDPTR_TO_S32(data)].Save(JCAST_VOIDPTR_TO_S32(data), app->playlist.StoryName(), app->levelNumber))
	{
		app->State(HCS_MENU);
	}
}

bool HCApp::DrawMenu()
{
	SDL_FillRect(screen, 0, 0);

	imgMenu->Draw();

	if (imgHelp)
	{
		imgHelp->Draw();
	}
	else
	{
		menu->Draw();
	}

	Flip();
	
  return true;
}

bool HCApp::DrawPlaying()
{
	//static s32 index = 0;
	//s32 t;
	//t = AppTime();
	
	SDL_FillRect(screen, 0, 0);

	// Draws game elements
	level.Draw();

	Flip();

	//t = AppTime() - t;
	//printf("%3.3f FPS\n", 1000.0f/float(t));

  return true;
}

bool HCApp::DrawPaused()
{
	SDL_FillRect(screen, 0, 0);

	imgBack->Draw();
	
	// If help requested, show help instead
	if (imgHelp)
	{
		imgHelp->Draw();
	}
	else
	{
		textBack->Draw();
	}

	Flip();

  return true;
}

bool HCApp::DrawIntro()
{
	if (timerGeneral.TotalLap() < 6000)
	{
		SDL_FillRect(screen, 0, SDL_MapRGB(screen->format, 255, 255, 255));
		imgFatalFun->Draw();
	}
	else
	if (timerGeneral.TotalLap() < 7000)
	{
		int a = 255 - ((timerGeneral.TotalLap()-6000)*255)/1000;
		SDL_FillRect(screen, 0, SDL_MapRGB(screen->format, a, a, a));
	}
	else
	{
		SDL_FillRect(screen, 0, 0);
		imgIntro->Draw();
		textIntro->Draw();
	}
	
	Flip();
	
  return true;
}

bool HCApp::DrawCredits()
{
	SDL_FillRect(screen, 0, 0);

	for (s32 i = 0; i < HCCREDITS_IMAGE_COUNT; ++i)
	{
		if (imgCredits[i]->Y() < height && imgCredits[i]->Y() + imgCredits[i]->Height() > 0)
			imgCredits[i]->Draw();
	}

	for (s32 i = 0; i < HCCREDITS_TEXT_COUNT; ++i)
	{
		if (textCredits[i]->Y() < height && textCredits[i]->Y() + textCredits[i]->Height() > 0)
			textCredits[i]->Draw();
	}

	Flip();
	
  return true;
}

bool HCApp::DrawScript()
{
	SDL_FillRect(screen, 0, 0);

	// Draws game elements
	level.Draw();

	Flip();

  return true;
}

bool HCApp::DrawEndLevel()
{
	SDL_FillRect(screen, 0, 0);
	imgBack->Draw();
	Flip();

  return true;
}

bool HCApp::DrawGameOver()
{
	SDL_FillRect(screen, 0, 0);
	if (imgBack)
	{
		imgBack->Draw();
		textBack->Draw();
	}
	else
	{
		level.Draw();
	}

	Flip();

  return true;
}

bool HCApp::Draw()
{
	switch (state)
	{
		default:
		case HCS_MENU:
			DrawMenu();
			break;
			
		case HCS_PLAYING:
			return DrawPlaying();
			
		case HCS_PAUSED:
			return DrawPaused();

		case HCS_INTRO:
			DrawIntro();
			break;

		case HCS_CREDITS:
			return DrawCredits();

		case HCS_SCRIPT:
			DrawScript();
			break;

		case HCS_GAMEOVER:
			return DrawGameOver();

		case HCS_ENDLEVEL:
			return DrawEndLevel();
	}
	
	/*
	static s32 i = 0;
	
	char str[32];
	sprintf(str, "video%05d.bmp", i++);
	SDL_SaveBMP(screen, str); 
	*/

	return true;
}

bool HCApp::UpdateMenu()
{
	// Make a fade-in
	if (imgMenu->Alpha() < 255)
		imgMenu->Alpha(imgMenu->Alpha() + 15);
	
  return true;
}

bool HCApp::UpdatePlaying()
{
	u32 actions = 0;

	if (level.LevelExit()->State() < HCEXITSTATE_SWALLOWING)
    {
        if (Keys()[SDLK_LEFT])
        {
            actions |= HCCA_LEFT;
        }
        else if (Keys()[SDLK_RIGHT])
        {
            actions |= HCCA_RIGHT;
        }
        if (Keys()[SDLK_UP])
        {
            actions |= HCCA_UP;
        }
        else if (Keys()[SDLK_DOWN])
        {
            actions |= HCCA_DOWN;
        }
        if (Keys()[SDLK_SPACE])
        {
            actions |= HCCA_JUMP;
        }
        level.ProcessInput(actions);
    }

	// Updates game elements
	switch (level.Update())
	{
		// Player died
		case 1:
			State(HCS_GAMEOVER);
			ProcessStateChange();
			break;
		
		// Level ended
		case 2:
			State(HCS_ENDLEVEL);
			ProcessStateChange();
			break;
		
		// Nothing happened
		case 0:
		default:
			break;
	}

  return true;
}

bool HCApp::UpdatePaused()
{
	// If help requested, don't update back text
	if (imgHelp)
	{
		return true;
	}

	if (textBack->Update() == 2)
	{
		// Disappeared, show it again!
		textBack->Reset();
	}
	
  return true;
}

bool HCApp::UpdateIntro()
{
	if (timerGeneral.TotalLap() > 10000)
	{
		if (imgIntro->Alpha() > 0)
		{
			// Fades out
			imgIntro->Alpha(imgIntro->Alpha() - 15);
			textIntro->Alpha(textIntro->Alpha() - 15);
			
			return true;
		}
		else
		{
			// Done, show menu
			State(HCS_MENU);
			ProcessStateChange();

			return true;
		}
	}
	else
	if (timerGeneral.TotalLap() > 7000)
	{
		if (imgIntro->Alpha() < 255)
		{
			// Fades in the intro image
			imgIntro->Alpha(imgIntro->Alpha() + 15);
		}
		else
		{
			if (timerGeneral.TotalLap() > 8000)
			{
				if (textIntro->Alpha() < 255)
				{
					// Fades in the intro text
					textIntro->Alpha(textIntro->Alpha() + 15);
				}
			}
		}
	}
	else
	if (timerGeneral.TotalLap() > 5000)
	{
		if (imgFatalFun->Alpha() > 0)
		{
			// Fades out
			imgFatalFun->Alpha(imgFatalFun->Alpha() - 15);
			
			return true;
		}
	}
	else
	{
		if (imgFatalFun->Alpha() < 255)
		{
			// Fades in the intro image
			imgFatalFun->Alpha(imgFatalFun->Alpha() + 15);
		}
	}

  return true;
}

bool HCApp::UpdateCredits()
{
	for (s32 i = 0; i < HCCREDITS_IMAGE_COUNT; ++i)
	{
		imgCredits[i]->Y(imgCredits[i]->Y() - 1.0f);
	}

	for (s32 i = 0; i < HCCREDITS_TEXT_COUNT; ++i)
	{
		textCredits[i]->Y(textCredits[i]->Y() - 1.0f);
	}

	// Updates fade-in's
	u8 alpha = imgCredits[HCCREDITS_DRAWING0 + outDrawing]->Alpha();
	if (alpha > 0)
	{
		imgCredits[HCCREDITS_DRAWING0 + outDrawing]->Alpha(alpha - 5);
		imgCredits[HCCREDITS_DRAWING0 + inDrawing]->Alpha(imgCredits[HCCREDITS_DRAWING0 + inDrawing]->Alpha() + 5);
	}
	else
	{
		outDrawing = inDrawing;
		inDrawing = inDrawing < 2 ? inDrawing + 1 : 0;
	}

	alpha = imgCredits[HCCREDITS_ANIMATION0 + outAnimation]->Alpha();
	if (alpha > 0)
	{
		imgCredits[HCCREDITS_ANIMATION0 + outAnimation]->Alpha(alpha - 5);
		imgCredits[HCCREDITS_ANIMATION0 + inAnimation]->Alpha(imgCredits[HCCREDITS_ANIMATION0 + inAnimation]->Alpha() + 5);
	}
	else
	{
		outAnimation = inAnimation;
		inAnimation = inAnimation < 3 ? inAnimation + 1 : 0;
	}

	if (imgCredits[HCCREDITS_LOGO]->Y() <= (height - imgCredits[HCCREDITS_LOGO]->Height())/2)
	{
		if (SoundEnabled() && !musicCredits.Fading())
		{
			musicCredits.FadeOut(3000);
		}


		// Fade out logo
		if (imgCredits[HCCREDITS_LOGO]->Alpha() > 0)
		{
			imgCredits[HCCREDITS_LOGO]->Alpha(imgCredits[HCCREDITS_LOGO]->Alpha() - 5);
			
			if (imgCredits[HCCREDITS_LOGO]->Alpha() < 85)
			{
				textCredits[HCCREDITS_LOGO_TEXT]->Alpha(textCredits[HCCREDITS_LOGO_TEXT]->Alpha() - 15);
			}
		}
		else
		{
			// Done with the credits
			State(HCS_MENU);
			ProcessStateChange();
		}
	}
	
  return true;
}

bool HCApp::UpdateScript()
{
	// Updates script elements
	script.Update();
	level.Update();

	if (script.Finished())
	{
		State(HCS_ENDLEVEL);
		ProcessStateChange();
	}

  return true;
}

bool HCApp::UpdateEndLevel()
{
	if (imgBack->Alpha() > 0)
	{
		// Fades out
		imgBack->Alpha(imgBack->Alpha() - 15);
	}
	else
	{
		// Next level
		++levelNumber;
		State(HCS_PLAYING);
		ProcessStateChange();
	}
	
	return true;
}

bool HCApp::UpdateGameOver()
{
	if (timerGeneral.TotalLap() > 4000)
	{
		if (!imgBack)
		{
			// Copies the scene as is
			JImage img(screen);
			imgBack = new JImage(img.Width(), img.Height());

			imgBack->Paste(&img, 0, 0, img.Width(), img.Height());
			imgBack->Alpha(255);
			
			// Reads the pause file in the correct language
			char str[256];
			snprintf(str, sizeof(str), HC_DATA_DIR "messages/%s/messages.txt", preferences.LangCodes()[preferences.CurLang()]);

			JTextFile f;
			if (!f.Load(str, "rb"))
			{
				snprintf(str, sizeof(str), "Game Over");
			}
			else
			{
				f.ReadLine(str);
			}

			textBack = new HCText;
			
			if (!textBack->Init(HCTEXTTYPE_NARRATIVE, str, &level.Theme(), &fontLarge, JFONTALIGN_CENTER, false, 0))
			{
				return false;
			}
			
			textBack->Pos((Width() - textBack->Image().Width())/2,
										(Height() - textBack->Image().Height())/2);
			textBack->Image().Alpha(0);
		}
		
		if (imgBack->Alpha() > 0)
		{
			// Fades out back image and fades in the text
			imgBack->Alpha(imgBack->Alpha() - 15);
			textBack->Image().Alpha(textBack->Image().Alpha() + 15);
		}
		else
		{
			if (timerGeneral.TotalLap() > 8000)
			{
				if (textBack->Image().Alpha() > 0)
				{
					// Fades out GAME OVER text
					textBack->Image().Alpha(textBack->Image().Alpha() - 15);
				}
				else
				{
					State(HCS_PLAYING);
					ProcessStateChange();
				}
			}
		}
	}
	else
	{
		level.Update();
	}

	return true;
}

bool HCApp::Update()
{
	bool ret = false;

	UpdateEvents();

	if (stateChanged)
	{
		ProcessStateChange();
	}
	
	switch (state)
	{
		case HCS_MENU:
			ret = UpdateMenu();
      break;

		case HCS_PLAYING:
			ret = UpdatePlaying();
      break;

		case HCS_PAUSED:
			ret = UpdatePaused();
      break;

		case HCS_INTRO:
			ret = UpdateIntro();
      break;

		case HCS_CREDITS:
			ret = UpdateCredits();
      break;

		case HCS_SCRIPT:
			ret = UpdateScript();
      break;

		case HCS_GAMEOVER:
			ret = UpdateGameOver();
      break;

		case HCS_ENDLEVEL:
			ret = UpdateEndLevel();
      break;

		default:
			return false;
	}

	return ret;
}

s32 HCApp::LoadWorld()
{
	JString str;
	str.Format("%s%s/level%03d.hlv", playlist.StoryDir(), playlist.StoryName(), levelNumber);

	if (!JFile::Exists(str))
	{
		// Goes to the next story
		if (playlist.NextStory())
		{
			levelNumber = 1;
			return LoadWorld();
		}
		else
		{
			// Game end, start from the beggining
			playlist.Reset();
			levelNumber = 1;
	
			return -1;
		}
	}

	JRW f;
	if (!f.Create(str, "rb") || 
			0 != level.Load(f, str))
	{
		fprintf(stderr, "Error loading the level %s.\n", str.Str());
		return 0;
	}

	// Centers the map within the screen
	level.Pos((width - level.Map().Width())/2, (height - level.Map().Height())/2);

	return 1;
}

HCState HCApp::State()
{
	return state;
}

void HCApp::State(HCState newState)
{
	lastState = state;
	state = newState;
  stateChanged = true;
}

void HCApp::ProcessStateChange()
{
	stateChanged = false;

	switch (lastState)
	{
		case HCS_PLAYING:
			if (state != HCS_ENDLEVEL &&
					state != HCS_SCRIPT &&
					state != HCS_PAUSED &&
					state != HCS_GAMEOVER)
			{
				// Frees allocated resources if not a script, paused or game over
				Destroy();
			}
			break;

		case HCS_SCRIPT:
			if (state != HCS_ENDLEVEL &&
					state != HCS_PAUSED &&
					state != HCS_GAMEOVER)
			{
				// Frees allocated resources if not paused or game over
				Destroy();
			}
			break;

		case HCS_GAMEOVER:
		case HCS_ENDLEVEL:
		case HCS_INTRO:
		case HCS_MENU:
		case HCS_CREDITS:
			// Frees allocated resources
			Destroy();
			break;

		case HCS_PAUSED:
			level.Pause(false);
			JDELETE(imgBack);
			JDELETE(textBack);
			return;


		default:
			break;
	}

	switch(state)
	{
		case HCS_INTRO:
			if (!InitIntro())
			{
				fprintf(stderr, "Failed to init intro. Check the manual.\n");
				State(HCS_MENU);
				ProcessStateChange();
			}
			break;

		case HCS_MENU:
			if (!InitMenu())
			{
				fprintf(stderr, "Failed to init application menu. Check the manual.\n");
				Destroy();
				Exit();
			}
			break;

			// Play!
		case HCS_PLAYING:
			if (!InitPlaying())
			{
				fprintf(stderr, "Failed to init game. Check the manual.\n");
				Destroy();
				Exit();
			}
			break;

		case HCS_PAUSED:
			if (!InitPaused())
			{
				fprintf(stderr, "Failed to init pause. Check the manual.\n");
				State(HCS_PLAYING);
				ProcessStateChange();
			}
			break;
			
		case HCS_GAMEOVER:
			if (!InitGameOver())
			{
				fprintf(stderr, "Failed to init game over. Check the manual.\n");
				State(HCS_PLAYING);
				ProcessStateChange();
			}
			break;

		case HCS_ENDLEVEL:
			if (!InitEndLevel())
			{
				fprintf(stderr, "Failed to init end of level. Check the manual.\n");
				State(HCS_PLAYING);
				ProcessStateChange();
			}
			break;

		case HCS_CREDITS:
			if (!InitCredits())
			{
				fprintf(stderr, "Failed to init credits. Check the manual.\n");
				State(HCS_MENU);
				ProcessStateChange();
			}
			break;

		default:
			break;
	}
}

void HCApp::Destroy()
{
	JDELETE(imgBack);
	JDELETE(textBack);
	JDELETE(imgHelp);
	JDELETE(imgIntro);
	JDELETE(textIntro);
	JDELETE(imgMenu);
	JDELETE(menu);
	script.Destroy();
	level.Destroy();

	musicMainTitle.Destroy();
	musicCredits.Destroy();
	musicGameOver.Destroy();
	
	if (SoundEnabled())
	{
		mixer.Volume(-1, MIX_MAX_VOLUME);
	}

	for (s32 i = 0; i < HCCREDITS_IMAGE_COUNT; ++i)
	{
		JDELETE(imgCredits[i]);
	}

	for (s32 i = 0; i < HCCREDITS_TEXT_COUNT; ++i)
	{
		JDELETE(textCredits[i]);
	}
	
	HCUtil::Destroy();
}

// Main function
int main(int argc, char **argv)
{
	HCApp app;
	
	if (app.Init(argc, argv))
	{
		return app.MainLoop();
	}

	fprintf(stderr, "There was an error initializing the App.\n");
	return -1;
}	

void HCApp::PrintUsage(char *program)
{
	fprintf(stderr, "Holotz's Castle v1.3.7 (C) Juan Carlos Seijo Pérez - 2004.\n\n");
	fprintf(stderr, "Usage: %s [-p playlist]", program);
	fprintf(stderr, " [-f]ullscreen [-w]indowed [--fps nnn] [-mWxHxBPP]\n");
	fprintf(stderr, "\n");
	exit(0);
}

int HCApp::ParseArg(char *args[], int argc)
{
	if (args[0][0]!='-')
		return -1;

	switch (args[0][1])
	{
		// '-p playlist'
		case 'p':
			if (argc<1)
				return -2;
			playlistName = args[1];
			return 1; // 1 argument used
	}
	return JApp::ParseArg(args, argc);
}
