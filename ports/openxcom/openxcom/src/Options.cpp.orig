/*
 * Copyright 2010-2016 OpenXcom Developers.
 *
 * This file is part of OpenXcom.
 *
 * OpenXcom is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * OpenXcom is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OpenXcom.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "Options.h"
#include "../version.h"
#include "../md5.h"
#include <SDL.h>
#include <SDL_keysym.h>
#include <SDL_mixer.h>
#include <map>
#include <sstream>
#include <iostream>
#include <algorithm>
#include <yaml-cpp/yaml.h>
#include "Exception.h"
#include "Logger.h"
#include "CrossPlatform.h"
#include "FileMap.h"
#include "Screen.h"

namespace OpenXcom
{

namespace Options
{
#define OPT
#include "Options.inc.h"
#undef OPT

std::string _dataFolder;
std::vector<std::string> _dataList;
std::string _userFolder;
std::string _configFolder;
std::vector<std::string> _userList;
std::map<std::string, std::string> _commandLine;
std::vector<OptionInfo> _info;
std::map<std::string, ModInfo> _modInfos;
std::string _masterMod;
int _passwordCheck = -1;
bool _loadLastSave = false;
bool _loadLastSaveExpended = false;

/**
 * Sets up the options by creating their OptionInfo metadata.
 */
void create()
{
#ifdef DINGOO
	_info.push_back(OptionInfo("displayWidth", &displayWidth, Screen::ORIGINAL_WIDTH));
	_info.push_back(OptionInfo("displayHeight", &displayHeight, Screen::ORIGINAL_HEIGHT));
	_info.push_back(OptionInfo("fullscreen", &fullscreen, true));
	_info.push_back(OptionInfo("asyncBlit", &asyncBlit, false));
	_info.push_back(OptionInfo("keyboardMode", (int*)&keyboardMode, KEYBOARD_OFF));
#else
	_info.push_back(OptionInfo("displayWidth", &displayWidth, Screen::ORIGINAL_WIDTH*2));
	_info.push_back(OptionInfo("displayHeight", &displayHeight, Screen::ORIGINAL_HEIGHT*2));
	_info.push_back(OptionInfo("fullscreen", &fullscreen, false));
	_info.push_back(OptionInfo("asyncBlit", &asyncBlit, true));
	_info.push_back(OptionInfo("keyboardMode", (int*)&keyboardMode, KEYBOARD_ON));
#endif

	_info.push_back(OptionInfo("maxFrameSkip", &maxFrameSkip, 0));
	_info.push_back(OptionInfo("traceAI", &traceAI, false));
	_info.push_back(OptionInfo("verboseLogging", &verboseLogging, false));
	_info.push_back(OptionInfo("StereoSound", &StereoSound, true));
	//_info.push_back(OptionInfo("baseXResolution", &baseXResolution, Screen::ORIGINAL_WIDTH));
	//_info.push_back(OptionInfo("baseYResolution", &baseYResolution, Screen::ORIGINAL_HEIGHT));
	//_info.push_back(OptionInfo("baseXGeoscape", &baseXGeoscape, Screen::ORIGINAL_WIDTH));
	//_info.push_back(OptionInfo("baseYGeoscape", &baseYGeoscape, Screen::ORIGINAL_HEIGHT));
	//_info.push_back(OptionInfo("baseXBattlescape", &baseXBattlescape, Screen::ORIGINAL_WIDTH));
	//_info.push_back(OptionInfo("baseYBattlescape", &baseYBattlescape, Screen::ORIGINAL_HEIGHT));
	_info.push_back(OptionInfo("geoscapeScale", &geoscapeScale, 0));
	_info.push_back(OptionInfo("battlescapeScale", &battlescapeScale, 0));
	_info.push_back(OptionInfo("useScaleFilter", &useScaleFilter, false));
	_info.push_back(OptionInfo("useHQXFilter", &useHQXFilter, false));
	_info.push_back(OptionInfo("useXBRZFilter", &useXBRZFilter, false));
	_info.push_back(OptionInfo("useOpenGL", &useOpenGL, false));
	_info.push_back(OptionInfo("checkOpenGLErrors", &checkOpenGLErrors, false));
	_info.push_back(OptionInfo("useOpenGLShader", &useOpenGLShader, "Shaders/Raw.OpenGL.shader"));
	_info.push_back(OptionInfo("useOpenGLSmoothing", &useOpenGLSmoothing, true));
	_info.push_back(OptionInfo("debug", &debug, false));
	_info.push_back(OptionInfo("debugUi", &debugUi, false));
	_info.push_back(OptionInfo("soundVolume", &soundVolume, 2*(MIX_MAX_VOLUME/3)));
	_info.push_back(OptionInfo("musicVolume", &musicVolume, 2*(MIX_MAX_VOLUME/3)));
	_info.push_back(OptionInfo("uiVolume", &uiVolume, MIX_MAX_VOLUME/3));
	_info.push_back(OptionInfo("language", &language, ""));
	_info.push_back(OptionInfo("battleScrollSpeed", &battleScrollSpeed, 8));
	_info.push_back(OptionInfo("battleEdgeScroll", (int*)&battleEdgeScroll, SCROLL_AUTO));
	_info.push_back(OptionInfo("battleDragScrollButton", &battleDragScrollButton, 0)); // different default in OXCE
	_info.push_back(OptionInfo("dragScrollTimeTolerance", &dragScrollTimeTolerance, 300)); // miliSecond
	_info.push_back(OptionInfo("dragScrollPixelTolerance", &dragScrollPixelTolerance, 10)); // count of pixels
	_info.push_back(OptionInfo("battleFireSpeed", &battleFireSpeed, 6));
	_info.push_back(OptionInfo("battleXcomSpeed", &battleXcomSpeed, 30));
	_info.push_back(OptionInfo("battleAlienSpeed", &battleAlienSpeed, 30));
	_info.push_back(OptionInfo("battleNewPreviewPath", (int*)&battleNewPreviewPath, PATH_NONE)); // requires double-click to confirm moves
	_info.push_back(OptionInfo("fpsCounter", &fpsCounter, false));
	_info.push_back(OptionInfo("globeDetail", &globeDetail, true));
	_info.push_back(OptionInfo("globeRadarLines", &globeRadarLines, true));
	_info.push_back(OptionInfo("globeFlightPaths", &globeFlightPaths, true));
	_info.push_back(OptionInfo("globeAllRadarsOnBaseBuild", &globeAllRadarsOnBaseBuild, true));
	_info.push_back(OptionInfo("audioSampleRate", &audioSampleRate, 22050));
	_info.push_back(OptionInfo("audioBitDepth", &audioBitDepth, 16));
	_info.push_back(OptionInfo("audioChunkSize", &audioChunkSize, 1024));
	_info.push_back(OptionInfo("pauseMode", &pauseMode, 0));
	_info.push_back(OptionInfo("battleNotifyDeath", &battleNotifyDeath, false));
	_info.push_back(OptionInfo("showFundsOnGeoscape", &showFundsOnGeoscape, false));
	_info.push_back(OptionInfo("allowResize", &allowResize, false));
	_info.push_back(OptionInfo("windowedModePositionX", &windowedModePositionX, 0));
	_info.push_back(OptionInfo("windowedModePositionY", &windowedModePositionY, 0));
	_info.push_back(OptionInfo("borderless", &borderless, false));
	_info.push_back(OptionInfo("captureMouse", (bool*)&captureMouse, false));
	_info.push_back(OptionInfo("battleTooltips", &battleTooltips, true));
	_info.push_back(OptionInfo("keepAspectRatio", &keepAspectRatio, true));
	_info.push_back(OptionInfo("nonSquarePixelRatio", &nonSquarePixelRatio, false));
	_info.push_back(OptionInfo("cursorInBlackBandsInFullscreen", &cursorInBlackBandsInFullscreen, false));
	_info.push_back(OptionInfo("cursorInBlackBandsInWindow", &cursorInBlackBandsInWindow, true));
	_info.push_back(OptionInfo("cursorInBlackBandsInBorderlessWindow", &cursorInBlackBandsInBorderlessWindow, false));
	_info.push_back(OptionInfo("saveOrder", (int*)&saveOrder, SORT_DATE_DESC));
	_info.push_back(OptionInfo("geoClockSpeed", &geoClockSpeed, 80));
	_info.push_back(OptionInfo("dogfightSpeed", &dogfightSpeed, 30));
	_info.push_back(OptionInfo("geoScrollSpeed", &geoScrollSpeed, 20));
	_info.push_back(OptionInfo("geoDragScrollButton", &geoDragScrollButton, SDL_BUTTON_MIDDLE));
	_info.push_back(OptionInfo("preferredMusic", (int*)&preferredMusic, MUSIC_AUTO));
	_info.push_back(OptionInfo("preferredSound", (int*)&preferredSound, SOUND_AUTO));
	_info.push_back(OptionInfo("preferredVideo", (int*)&preferredVideo, VIDEO_FMV));
	_info.push_back(OptionInfo("wordwrap", (int*)&wordwrap, WRAP_AUTO));
	_info.push_back(OptionInfo("musicAlwaysLoop", &musicAlwaysLoop, false));
	_info.push_back(OptionInfo("touchEnabled", &touchEnabled, false));
	_info.push_back(OptionInfo("rootWindowedMode", &rootWindowedMode, false));
	_info.push_back(OptionInfo("backgroundMute", &backgroundMute, false));

	// advanced options
#ifdef _WIN32
	_info.push_back(OptionInfo("oxceUpdateCheck", &oxceUpdateCheck, false, "STR_UPDATE_CHECK", "STR_GENERAL"));
#endif
	_info.push_back(OptionInfo("playIntro", &playIntro, true, "STR_PLAYINTRO", "STR_GENERAL"));
	_info.push_back(OptionInfo("autosave", &autosave, true, "STR_AUTOSAVE", "STR_GENERAL"));
	_info.push_back(OptionInfo("autosaveFrequency", &autosaveFrequency, 5, "STR_AUTOSAVE_FREQUENCY", "STR_GENERAL"));
	_info.push_back(OptionInfo("autosaveSlots", &autosaveSlots, 1, "STR_AUTOSAVE_SLOTS", "STR_GENERAL")); // OXCE only
	_info.push_back(OptionInfo("newSeedOnLoad", &newSeedOnLoad, false, "STR_NEWSEEDONLOAD", "STR_GENERAL"));
	_info.push_back(OptionInfo("lazyLoadResources", &lazyLoadResources, true, "STR_LAZY_LOADING", "STR_GENERAL")); // exposed in OXCE
	_info.push_back(OptionInfo("mousewheelSpeed", &mousewheelSpeed, 3, "STR_MOUSEWHEEL_SPEED", "STR_GENERAL"));
	_info.push_back(OptionInfo("changeValueByMouseWheel", &changeValueByMouseWheel, 0, "STR_CHANGEVALUEBYMOUSEWHEEL", "STR_GENERAL"));
	_info.push_back(OptionInfo("soldierDiaries", &soldierDiaries, true));

// this should probably be any small screen touch-device, i don't know the defines for all of them so i'll cover android and IOS as i imagine they're more common
#ifdef __ANDROID_API__
	_info.push_back(OptionInfo("maximizeInfoScreens", &maximizeInfoScreens, true, "STR_MAXIMIZE_INFO_SCREENS", "STR_GENERAL"));
#elif __APPLE__
	// todo: ask grussel how badly i messed this up.
	#include "TargetConditionals.h"
	#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
		_info.push_back(OptionInfo("maximizeInfoScreens", &maximizeInfoScreens, true, "STR_MAXIMIZE_INFO_SCREENS", "STR_GENERAL"));
	#else
		_info.push_back(OptionInfo("maximizeInfoScreens", &maximizeInfoScreens, false, "STR_MAXIMIZE_INFO_SCREENS", "STR_GENERAL"));
	#endif
#else
	_info.push_back(OptionInfo("maximizeInfoScreens", &maximizeInfoScreens, false, "STR_MAXIMIZE_INFO_SCREENS", "STR_GENERAL"));
#endif

	_info.push_back(OptionInfo("geoDragScrollInvert", &geoDragScrollInvert, false, "STR_DRAGSCROLLINVERT", "STR_GEOSCAPE")); // true drags away from the cursor, false drags towards (like a grab)
	_info.push_back(OptionInfo("aggressiveRetaliation", &aggressiveRetaliation, false, "STR_AGGRESSIVERETALIATION", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("customInitialBase", &customInitialBase, false, "STR_CUSTOMINITIALBASE", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("allowBuildingQueue", &allowBuildingQueue, false, "STR_ALLOWBUILDINGQUEUE", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("craftLaunchAlways", &craftLaunchAlways, false, "STR_CRAFTLAUNCHALWAYS", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("storageLimitsEnforced", &storageLimitsEnforced, false, "STR_STORAGELIMITSENFORCED", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("canSellLiveAliens", &canSellLiveAliens, false, "STR_CANSELLLIVEALIENS", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("anytimePsiTraining", &anytimePsiTraining, false, "STR_ANYTIMEPSITRAINING", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("globeSeasons", &globeSeasons, false, "STR_GLOBESEASONS", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("psiStrengthEval", &psiStrengthEval, false, "STR_PSISTRENGTHEVAL", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("canTransferCraftsWhileAirborne", &canTransferCraftsWhileAirborne, false, "STR_CANTRANSFERCRAFTSWHILEAIRBORNE", "STR_GEOSCAPE")); // When the craft can reach the destination base with its fuel
	_info.push_back(OptionInfo("retainCorpses", &retainCorpses, false, "STR_RETAINCORPSES", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("fieldPromotions", &fieldPromotions, false, "STR_FIELDPROMOTIONS", "STR_GEOSCAPE"));
	//_info.push_back(OptionInfo("meetingPoint", &meetingPoint, false, "STR_MEETINGPOINT", "STR_GEOSCAPE")); // intentionally disabled in OXCE

	_info.push_back(OptionInfo("battleDragScrollInvert", &battleDragScrollInvert, false, "STR_DRAGSCROLLINVERT", "STR_BATTLESCAPE")); // true drags away from the cursor, false drags towards (like a grab)
	_info.push_back(OptionInfo("sneakyAI", &sneakyAI, false, "STR_SNEAKYAI", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("battleUFOExtenderAccuracy", &battleUFOExtenderAccuracy, false, "STR_BATTLEUFOEXTENDERACCURACY", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("showMoreStatsInInventoryView", &showMoreStatsInInventoryView, false, "STR_SHOWMORESTATSININVENTORYVIEW", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("battleHairBleach", &battleHairBleach, true, "STR_BATTLEHAIRBLEACH", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("battleInstantGrenade", &battleInstantGrenade, false, "STR_BATTLEINSTANTGRENADE", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("includePrimeStateInSavedLayout", &includePrimeStateInSavedLayout, false, "STR_INCLUDE_PRIMESTATE_IN_SAVED_LAYOUT", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("battleExplosionHeight", &battleExplosionHeight, 0, "STR_BATTLEEXPLOSIONHEIGHT", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("battleAutoEnd", &battleAutoEnd, false, "STR_BATTLEAUTOEND", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("battleSmoothCamera", &battleSmoothCamera, false, "STR_BATTLESMOOTHCAMERA", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("disableAutoEquip", &disableAutoEquip, false, "STR_DISABLEAUTOEQUIP", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("battleConfirmFireMode", &battleConfirmFireMode, false, "STR_BATTLECONFIRMFIREMODE", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("weaponSelfDestruction", &weaponSelfDestruction, false, "STR_WEAPONSELFDESTRUCTION", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("allowPsionicCapture", &allowPsionicCapture, false, "STR_ALLOWPSIONICCAPTURE", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("allowPsiStrengthImprovement", &allowPsiStrengthImprovement, false, "STR_ALLOWPSISTRENGTHIMPROVEMENT", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("strafe", &strafe, false, "STR_STRAFE", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("forceFire", &forceFire, true, "STR_FORCE_FIRE", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("skipNextTurnScreen", &skipNextTurnScreen, false, "STR_SKIPNEXTTURNSCREEN", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("noAlienPanicMessages", &noAlienPanicMessages, false, "STR_NOALIENPANICMESSAGES", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("alienBleeding", &alienBleeding, false, "STR_ALIENBLEEDING", "STR_BATTLESCAPE"));

	// OXCE GUI
#ifdef __MOBILE__
	_info.push_back(OptionInfo("oxceLinks", &oxceLinks, true, "STR_OXCE_LINKS", "STR_OXCE"));
#else
	_info.push_back(OptionInfo("oxceLinks", &oxceLinks, false, "STR_OXCE_LINKS", "STR_OXCE"));
#endif
	_info.push_back(OptionInfo("oxceUfoLandingAlert", &oxceUfoLandingAlert, false, "STR_UFO_LANDING_ALERT", "STR_OXCE"));
	_info.push_back(OptionInfo("oxceWoundedDefendBaseIf", &oxceWoundedDefendBaseIf, 100, "STR_WOUNDED_DEFEND_BASE_IF", "STR_OXCE"));
	_info.push_back(OptionInfo("oxcePlayBriefingMusicDuringEquipment", &oxcePlayBriefingMusicDuringEquipment, false, "STR_PLAY_BRIEFING_MUSIC_DURING_EQUIPMENT", "STR_OXCE"));
	_info.push_back(OptionInfo("oxceNightVisionColor", &oxceNightVisionColor, 5, "STR_NIGHT_VISION_COLOR", "STR_OXCE"));
	_info.push_back(OptionInfo("oxceAutoNightVisionThreshold", &oxceAutoNightVisionThreshold, 15, "STR_AUTO_NIGHT_VISION_THRESHOLD", "STR_OXCE"));
	_info.push_back(OptionInfo("oxceAutoSell", &oxceAutoSell, false, "STR_AUTO_SELL", "STR_OXCE"));
	_info.push_back(OptionInfo("oxceRememberDisabledCraftWeapons", &oxceRememberDisabledCraftWeapons, false, "STR_REMEMBER_DISABLED_CRAFT_WEAPONS", "STR_OXCE"));
	_info.push_back(OptionInfo("oxceEnableOffCentreShooting", &oxceEnableOffCentreShooting, false, "STR_OFF_CENTRE_SHOOTING", "STR_OXCE"));

	// OXCE hidden
#ifdef __MOBILE__
	_info.push_back(OptionInfo("oxceFatFingerLinks", &oxceFatFingerLinks, true));
#else
	_info.push_back(OptionInfo("oxceFatFingerLinks", &oxceFatFingerLinks, false));
#endif
	_info.push_back(OptionInfo("oxceHighlightNewTopicsHidden", &oxceHighlightNewTopicsHidden, true));
	_info.push_back(OptionInfo("oxceInterceptGuiMaintenanceTimeHidden", &oxceInterceptGuiMaintenanceTimeHidden, 2));
	_info.push_back(OptionInfo("oxceEnableUnitResponseSounds", &oxceEnableUnitResponseSounds, true));
	_info.push_back(OptionInfo("oxceEnableSlackingIndicator", &oxceEnableSlackingIndicator, true));
	_info.push_back(OptionInfo("oxceEnablePaletteFlickerFix", &oxceEnablePaletteFlickerFix, false));
	_info.push_back(OptionInfo("oxcePersonalLayoutIncludingArmor", &oxcePersonalLayoutIncludingArmor, true));
	_info.push_back(OptionInfo("oxceManufactureFilterSuppliesOK", &oxceManufactureFilterSuppliesOK, false));
	_info.push_back(OptionInfo("oxceModValidationLevel", &oxceModValidationLevel, (int)LOG_WARNING));

	_info.push_back(OptionInfo("oxceEmbeddedOnly", &oxceEmbeddedOnly, true));
	_info.push_back(OptionInfo("oxceListVFSContents", &oxceListVFSContents, false));
	_info.push_back(OptionInfo("oxceRawScreenShots", &oxceRawScreenShots, false));
	_info.push_back(OptionInfo("oxceThumbButtons", &oxceThumbButtons, true));

	_info.push_back(OptionInfo("oxceRecommendedOptionsWereSet", &oxceRecommendedOptionsWereSet, false));
	_info.push_back(OptionInfo("password", &password, "secret"));

	// OXCE hidden but moddable
	_info.push_back(OptionInfo("oxceStartUpTextMode", &oxceStartUpTextMode, 0, "", "HIDDEN"));
	_info.push_back(OptionInfo("oxceManufactureScrollSpeed", &oxceManufactureScrollSpeed, 10, "", "HIDDEN"));
	_info.push_back(OptionInfo("oxceManufactureScrollSpeedWithCtrl", &oxceManufactureScrollSpeedWithCtrl, 1, "", "HIDDEN"));
	_info.push_back(OptionInfo("oxceResearchScrollSpeed", &oxceResearchScrollSpeed, 10, "", "HIDDEN"));
	_info.push_back(OptionInfo("oxceResearchScrollSpeedWithCtrl", &oxceResearchScrollSpeedWithCtrl, 1, "", "HIDDEN"));
	_info.push_back(OptionInfo("oxceGeoSlowdownFactor", &oxceGeoSlowdownFactor, 1, "", "HIDDEN"));
	_info.push_back(OptionInfo("oxceDisableTechTreeViewer", &oxceDisableTechTreeViewer, false, "", "HIDDEN"));
	_info.push_back(OptionInfo("oxceDisableStatsForNerds", &oxceDisableStatsForNerds, false, "", "HIDDEN"));
	_info.push_back(OptionInfo("oxceDisableProductionDependencyTree", &oxceDisableProductionDependencyTree, false, "", "HIDDEN"));
	_info.push_back(OptionInfo("oxceDisableHitLog", &oxceDisableHitLog, false, "", "HIDDEN"));
	_info.push_back(OptionInfo("oxceDisableAlienInventory", &oxceDisableAlienInventory, false, "", "HIDDEN"));
	_info.push_back(OptionInfo("oxceDisableInventoryTuCost", &oxceDisableInventoryTuCost, false, "", "HIDDEN"));

	// controls
	_info.push_back(OptionInfo("keyOk", &keyOk, SDLK_RETURN, "STR_OK", "STR_GENERAL"));
	_info.push_back(OptionInfo("keyCancel", &keyCancel, SDLK_ESCAPE, "STR_CANCEL", "STR_GENERAL"));
	_info.push_back(OptionInfo("keyScreenshot", &keyScreenshot, SDLK_F12, "STR_SCREENSHOT", "STR_GENERAL"));
	_info.push_back(OptionInfo("keyFps", &keyFps, SDLK_F7, "STR_FPS_COUNTER", "STR_GENERAL"));
	_info.push_back(OptionInfo("keyQuickSave", &keyQuickSave, SDLK_F5, "STR_QUICK_SAVE", "STR_GENERAL"));
	_info.push_back(OptionInfo("keyQuickLoad", &keyQuickLoad, SDLK_F9, "STR_QUICK_LOAD", "STR_GENERAL"));
	_info.push_back(OptionInfo("keyGeoLeft", &keyGeoLeft, SDLK_LEFT, "STR_ROTATE_LEFT", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoRight", &keyGeoRight, SDLK_RIGHT, "STR_ROTATE_RIGHT", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoUp", &keyGeoUp, SDLK_UP, "STR_ROTATE_UP", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoDown", &keyGeoDown, SDLK_DOWN, "STR_ROTATE_DOWN", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoZoomIn", &keyGeoZoomIn, SDLK_PLUS, "STR_ZOOM_IN", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoZoomOut", &keyGeoZoomOut, SDLK_MINUS, "STR_ZOOM_OUT", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoSpeed1", &keyGeoSpeed1, SDLK_1, "STR_5_SECONDS", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoSpeed2", &keyGeoSpeed2, SDLK_2, "STR_1_MINUTE", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoSpeed3", &keyGeoSpeed3, SDLK_3, "STR_5_MINUTES", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoSpeed4", &keyGeoSpeed4, SDLK_4, "STR_30_MINUTES", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoSpeed5", &keyGeoSpeed5, SDLK_5, "STR_1_HOUR", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoSpeed6", &keyGeoSpeed6, SDLK_6, "STR_1_DAY", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoIntercept", &keyGeoIntercept, SDLK_i, "STR_INTERCEPT", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoBases", &keyGeoBases, SDLK_b, "STR_BASES", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoGraphs", &keyGeoGraphs, SDLK_g, "STR_GRAPHS", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoUfopedia", &keyGeoUfopedia, SDLK_u, "STR_UFOPAEDIA_UC", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoOptions", &keyGeoOptions, SDLK_ESCAPE, "STR_OPTIONS_UC", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoFunding", &keyGeoFunding, SDLK_f, "STR_FUNDING_UC", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoToggleDetail", &keyGeoToggleDetail, SDLK_TAB, "STR_TOGGLE_COUNTRY_DETAIL", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyGeoToggleRadar", &keyGeoToggleRadar, SDLK_r, "STR_TOGGLE_RADAR_RANGES", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyBaseSelect1", &keyBaseSelect1, SDLK_1, "STR_SELECT_BASE_1", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyBaseSelect2", &keyBaseSelect2, SDLK_2, "STR_SELECT_BASE_2", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyBaseSelect3", &keyBaseSelect3, SDLK_3, "STR_SELECT_BASE_3", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyBaseSelect4", &keyBaseSelect4, SDLK_4, "STR_SELECT_BASE_4", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyBaseSelect5", &keyBaseSelect5, SDLK_5, "STR_SELECT_BASE_5", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyBaseSelect6", &keyBaseSelect6, SDLK_6, "STR_SELECT_BASE_6", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyBaseSelect7", &keyBaseSelect7, SDLK_7, "STR_SELECT_BASE_7", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyBaseSelect8", &keyBaseSelect8, SDLK_8, "STR_SELECT_BASE_8", "STR_GEOSCAPE"));
	_info.push_back(OptionInfo("keyBattleLeft", &keyBattleLeft, SDLK_LEFT, "STR_SCROLL_LEFT", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleRight", &keyBattleRight, SDLK_RIGHT, "STR_SCROLL_RIGHT", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleUp", &keyBattleUp, SDLK_UP, "STR_SCROLL_UP", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleDown", &keyBattleDown, SDLK_DOWN, "STR_SCROLL_DOWN", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleLevelUp", &keyBattleLevelUp, SDLK_PAGEUP, "STR_VIEW_LEVEL_ABOVE", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleLevelDown", &keyBattleLevelDown, SDLK_PAGEDOWN, "STR_VIEW_LEVEL_BELOW", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleCenterUnit", &keyBattleCenterUnit, SDLK_HOME, "STR_CENTER_SELECTED_UNIT", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattlePrevUnit", &keyBattlePrevUnit, SDLK_UNKNOWN, "STR_PREVIOUS_UNIT", "STR_BATTLESCAPE")); // different default in OXCE
	_info.push_back(OptionInfo("keyBattleNextUnit", &keyBattleNextUnit, SDLK_TAB, "STR_NEXT_UNIT", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleDeselectUnit", &keyBattleDeselectUnit, SDLK_BACKSLASH, "STR_DESELECT_UNIT", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleUseLeftHand", &keyBattleUseLeftHand, SDLK_q, "STR_USE_LEFT_HAND", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleUseRightHand", &keyBattleUseRightHand, SDLK_e, "STR_USE_RIGHT_HAND", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleInventory", &keyBattleInventory, SDLK_i, "STR_INVENTORY", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleMap", &keyBattleMap, SDLK_m, "STR_MINIMAP", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleOptions", &keyBattleOptions, SDLK_ESCAPE, "STR_OPTIONS", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleEndTurn", &keyBattleEndTurn, SDLK_BACKSPACE, "STR_END_TURN", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleAbort", &keyBattleAbort, SDLK_a, "STR_ABORT_MISSION", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleStats", &keyBattleStats, SDLK_s, "STR_UNIT_STATS", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleKneel", &keyBattleKneel, SDLK_k, "STR_KNEEL", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleReload", &keyBattleReload, SDLK_r, "STR_RELOAD", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattlePersonalLighting", &keyBattlePersonalLighting, SDLK_l, "STR_TOGGLE_PERSONAL_LIGHTING", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleReserveNone", &keyBattleReserveNone, SDLK_F1, "STR_DONT_RESERVE_TIME_UNITS", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleReserveSnap", &keyBattleReserveSnap, SDLK_F2, "STR_RESERVE_TIME_UNITS_FOR_SNAP_SHOT", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleReserveAimed", &keyBattleReserveAimed, SDLK_F3, "STR_RESERVE_TIME_UNITS_FOR_AIMED_SHOT", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleReserveAuto", &keyBattleReserveAuto, SDLK_F4, "STR_RESERVE_TIME_UNITS_FOR_AUTO_SHOT", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleReserveKneel", &keyBattleReserveKneel, SDLK_j, "STR_RESERVE_TIME_UNITS_FOR_KNEEL", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleZeroTUs", &keyBattleZeroTUs, SDLK_DELETE, "STR_EXPEND_ALL_TIME_UNITS", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleCenterEnemy1", &keyBattleCenterEnemy1, SDLK_1, "STR_CENTER_ON_ENEMY_1", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleCenterEnemy2", &keyBattleCenterEnemy2, SDLK_2, "STR_CENTER_ON_ENEMY_2", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleCenterEnemy3", &keyBattleCenterEnemy3, SDLK_3, "STR_CENTER_ON_ENEMY_3", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleCenterEnemy4", &keyBattleCenterEnemy4, SDLK_4, "STR_CENTER_ON_ENEMY_4", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleCenterEnemy5", &keyBattleCenterEnemy5, SDLK_5, "STR_CENTER_ON_ENEMY_5", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleCenterEnemy6", &keyBattleCenterEnemy6, SDLK_6, "STR_CENTER_ON_ENEMY_6", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleCenterEnemy7", &keyBattleCenterEnemy7, SDLK_7, "STR_CENTER_ON_ENEMY_7", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleCenterEnemy8", &keyBattleCenterEnemy8, SDLK_8, "STR_CENTER_ON_ENEMY_8", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleCenterEnemy9", &keyBattleCenterEnemy9, SDLK_9, "STR_CENTER_ON_ENEMY_9", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleCenterEnemy10", &keyBattleCenterEnemy10, SDLK_0, "STR_CENTER_ON_ENEMY_10", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyBattleVoxelView", &keyBattleVoxelView, SDLK_F10, "STR_SAVE_VOXEL_VIEW", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyInvCreateTemplate", &keyInvCreateTemplate, SDLK_c, "STR_CREATE_INVENTORY_TEMPLATE", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyInvApplyTemplate", &keyInvApplyTemplate, SDLK_v, "STR_APPLY_INVENTORY_TEMPLATE", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyInvClear", &keyInvClear, SDLK_x, "STR_CLEAR_INVENTORY", "STR_BATTLESCAPE"));
	_info.push_back(OptionInfo("keyInvAutoEquip", &keyInvAutoEquip, SDLK_z, "STR_AUTO_EQUIP", "STR_BATTLESCAPE"));

	// OXCE
	_info.push_back(OptionInfo("keyBasescapeBuildNewBase", &keyBasescapeBuildNewBase, SDLK_n, "STR_BUILD_NEW_BASE_UC", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBasescapeBaseInformation", &keyBasescapeBaseInfo, SDLK_i, "STR_BASE_INFORMATION", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBasescapeSoldiers", &keyBasescapeSoldiers, SDLK_s, "STR_SOLDIERS_UC", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBasescapeEquipCraft", &keyBasescapeCrafts, SDLK_e, "STR_EQUIP_CRAFT", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBasescapeBuildFacilities", &keyBasescapeFacilities, SDLK_f, "STR_BUILD_FACILITIES", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBasescapeResearch", &keyBasescapeResearch, SDLK_r, "STR_RESEARCH", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBasescapeManufacture", &keyBasescapeManufacture, SDLK_m, "STR_MANUFACTURE", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBasescapeTransfer", &keyBasescapeTransfer, SDLK_t, "STR_TRANSFER_UC", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBasescapePurchase", &keyBasescapePurchase, SDLK_p, "STR_PURCHASE_RECRUIT", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBasescapeSell", &keyBasescapeSell, SDLK_l, "STR_SELL_SACK_UC", "STR_OXCE"));

	_info.push_back(OptionInfo("keyGeoDailyPilotExperience", &keyGeoDailyPilotExperience, SDLK_e, "STR_DAILY_PILOT_EXPERIENCE", "STR_OXCE"));
	_info.push_back(OptionInfo("keyGeoUfoTracker", &keyGeoUfoTracker, SDLK_t, "STR_UFO_TRACKER", "STR_OXCE"));
	_info.push_back(OptionInfo("keyGeoTechTreeViewer", &keyGeoTechTreeViewer, SDLK_q, "STR_TECH_TREE_VIEWER", "STR_OXCE"));
	_info.push_back(OptionInfo("keyGeoGlobalProduction", &keyGeoGlobalProduction, SDLK_p, "STR_PRODUCTION_OVERVIEW", "STR_OXCE"));
	_info.push_back(OptionInfo("keyGeoGlobalResearch", &keyGeoGlobalResearch, SDLK_c, "STR_RESEARCH_OVERVIEW", "STR_OXCE"));
	_info.push_back(OptionInfo("keyGraphsZoomIn", &keyGraphsZoomIn, SDLK_KP_PLUS, "STR_GRAPHS_ZOOM_IN", "STR_OXCE"));
	_info.push_back(OptionInfo("keyGraphsZoomOut", &keyGraphsZoomOut, SDLK_KP_MINUS, "STR_GRAPHS_ZOOM_OUT", "STR_OXCE"));

	_info.push_back(OptionInfo("keyToggleQuickSearch", &keyToggleQuickSearch, SDLK_q, "STR_TOGGLE_QUICK_SEARCH", "STR_OXCE"));
	_info.push_back(OptionInfo("keyCraftLoadoutSave", &keyCraftLoadoutSave, SDLK_F5, "STR_SAVE_CRAFT_LOADOUT_TEMPLATE", "STR_OXCE"));
	_info.push_back(OptionInfo("keyCraftLoadoutLoad", &keyCraftLoadoutLoad, SDLK_F9, "STR_LOAD_CRAFT_LOADOUT_TEMPLATE", "STR_OXCE"));

	_info.push_back(OptionInfo("keyMarkAllAsSeen", &keyMarkAllAsSeen, SDLK_x, "STR_MARK_ALL_AS_SEEN", "STR_OXCE"));
	_info.push_back(OptionInfo("keySellAll", &keySellAll, SDLK_x, "STR_SELL_ALL", "STR_OXCE"));
	_info.push_back(OptionInfo("keySellAllButOne", &keySellAllButOne, SDLK_z, "STR_SELL_ALL_BUT_ONE", "STR_OXCE"));
	_info.push_back(OptionInfo("keyRemoveSoldiersFromAllCrafts", &keyRemoveSoldiersFromAllCrafts, SDLK_x, "STR_REMOVE_SOLDIERS_FROM_ALL_CRAFTS", "STR_OXCE"));
	_info.push_back(OptionInfo("keyRemoveSoldiersFromCraft", &keyRemoveSoldiersFromCraft, SDLK_z, "STR_REMOVE_SOLDIERS_FROM_CRAFT", "STR_OXCE"));
	_info.push_back(OptionInfo("keyRemoveEquipmentFromCraft", &keyRemoveEquipmentFromCraft, SDLK_x, "STR_REMOVE_EQUIPMENT_FROM_CRAFT", "STR_OXCE"));
	_info.push_back(OptionInfo("keyRemoveArmorFromAllCrafts", &keyRemoveArmorFromAllCrafts, SDLK_x, "STR_REMOVE_ARMOR_FROM_ALL_CRAFTS", "STR_OXCE"));
	_info.push_back(OptionInfo("keyRemoveArmorFromCraft", &keyRemoveArmorFromCraft, SDLK_z, "STR_REMOVE_ARMOR_FROM_CRAFT", "STR_OXCE"));
	_info.push_back(OptionInfo("keyRemoveSoldiersFromTraining", &keyRemoveSoldiersFromTraining, SDLK_x, "STR_REMOVE_SOLDIERS_FROM_TRAINING", "STR_OXCE"));

	_info.push_back(OptionInfo("keyInventoryArmor", &keyInventoryArmor, SDLK_a, "STR_INVENTORY_ARMOR", "STR_OXCE"));
	_info.push_back(OptionInfo("keyInventoryAvatar", &keyInventoryAvatar, SDLK_m, "STR_INVENTORY_AVATAR", "STR_OXCE"));
	_info.push_back(OptionInfo("keyInventorySave", &keyInventorySave, SDLK_F5, "STR_SAVE_EQUIPMENT_TEMPLATE", "STR_OXCE"));
	_info.push_back(OptionInfo("keyInventoryLoad", &keyInventoryLoad, SDLK_F9, "STR_LOAD_EQUIPMENT_TEMPLATE", "STR_OXCE"));

	_info.push_back(OptionInfo("keyInvSavePersonalEquipment", &keyInvSavePersonalEquipment, SDLK_s, "STR_SAVE_PERSONAL_EQUIPMENT", "STR_OXCE"));
	_info.push_back(OptionInfo("keyInvLoadPersonalEquipment", &keyInvLoadPersonalEquipment, SDLK_l, "STR_LOAD_PERSONAL_EQUIPMENT", "STR_OXCE"));
	_info.push_back(OptionInfo("keyInvShowPersonalEquipment", &keyInvShowPersonalEquipment, SDLK_p, "STR_PERSONAL_EQUIPMENT", "STR_OXCE"));

	_info.push_back(OptionInfo("keyBattleUseSpecial", &keyBattleUseSpecial, SDLK_w, "STR_USE_SPECIAL_ITEM", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBattleActionItem1", &keyBattleActionItem1, SDLK_1, "STR_ACTION_ITEM_1", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBattleActionItem2", &keyBattleActionItem2, SDLK_2, "STR_ACTION_ITEM_2", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBattleActionItem3", &keyBattleActionItem3, SDLK_3, "STR_ACTION_ITEM_3", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBattleActionItem4", &keyBattleActionItem4, SDLK_4, "STR_ACTION_ITEM_4", "STR_OXCE"));
	_info.push_back(OptionInfo("keyBattleActionItem5", &keyBattleActionItem5, SDLK_5, "STR_ACTION_ITEM_5", "STR_OXCE"));
	_info.push_back(OptionInfo("keyNightVisionToggle", &keyNightVisionToggle, SDLK_SCROLLOCK, "STR_TOGGLE_NIGHT_VISION", "STR_OXCE"));
	_info.push_back(OptionInfo("keyNightVisionHold", &keyNightVisionHold, SDLK_SPACE, "STR_HOLD_NIGHT_VISION", "STR_OXCE"));
	_info.push_back(OptionInfo("keySelectMusicTrack", &keySelectMusicTrack, SDLK_END, "STR_SELECT_MUSIC_TRACK", "STR_OXCE"));

#ifdef __MORPHOS__
	_info.push_back(OptionInfo("FPS", &FPS, 15, "STR_FPS_LIMIT", "STR_GENERAL"));
	_info.push_back(OptionInfo("FPSInactive", &FPSInactive, 15, "STR_FPS_INACTIVE_LIMIT", "STR_GENERAL"));
#else
	_info.push_back(OptionInfo("FPS", &FPS, 60, "STR_FPS_LIMIT", "STR_GENERAL"));
	_info.push_back(OptionInfo("FPSInactive", &FPSInactive, 30, "STR_FPS_INACTIVE_LIMIT", "STR_GENERAL"));
	_info.push_back(OptionInfo("vSyncForOpenGL", &vSyncForOpenGL, true, "STR_VSYNC_FOR_OPENGL", "STR_GENERAL")); // exposed in OXCE
#endif

}

// we can get fancier with these detection routines, but for now just look for
// *something* in the data folders.  case sensitivity can make actually verifying
// that the *correct* files are there complex.
static bool _gameIsInstalled(const std::string &gameName)
{
	// look for game data in either the data or user directories
	std::string dataGameFolder = CrossPlatform::searchDataFolder(gameName);
	std::string dataGameZipFile = CrossPlatform::searchDataFile(gameName + ".zip");
	std::string userGameFolder = _userFolder + gameName;
	std::string userGameZipFile = _userFolder + gameName + ".zip";
	return (CrossPlatform::folderExists(dataGameFolder)	&& CrossPlatform::getFolderContents(dataGameFolder).size() >= 8)
	    || (CrossPlatform::folderExists(userGameFolder)	&& CrossPlatform::getFolderContents(userGameFolder).size() >= 8)
		||  CrossPlatform::fileExists( dataGameZipFile )
		||  CrossPlatform::fileExists( userGameZipFile );
}

static bool _ufoIsInstalled()
{
	return _gameIsInstalled("UFO");
}

static bool _tftdIsInstalled()
{
	return _gameIsInstalled("TFTD");
}

static void _setDefaultMods()
{
	bool haveUfo = _ufoIsInstalled();
	if (haveUfo)
	{
		mods.push_back(std::pair<std::string, bool>("xcom1", true));
	}

	if (_tftdIsInstalled())
	{
		mods.push_back(std::pair<std::string, bool>("xcom2", !haveUfo));
	}
}

/**
 * Resets the options back to their defaults.
 * @param includeMods Reset mods to default as well.
 */
void resetDefault(bool includeMods)
{
	for (std::vector<OptionInfo>::iterator i = _info.begin(); i != _info.end(); ++i)
	{
		i->reset();
	}
	backupDisplay();

	if (includeMods)
	{
		mods.clear();
		if (!_dataList.empty())
		{
			_setDefaultMods();
		}
	}
}

/**
 * Loads options from a set of command line arguments,
 * in the format "-option value".
 * @param argc Number of arguments.
 * @param argv Array of argument strings.
 */
static void loadArgs()
{
	auto argv = CrossPlatform::getArgs();
	for (size_t i = 1; i < argv.size(); ++i)
	{
		auto arg = argv[i];
		if (arg.size() > 1 && arg[0] == '-')
		{
			std::string argname;
			if (arg[1] == '-' && arg.length() > 2)
				argname = arg.substr(2, arg.length()-1);
			else
				argname = arg.substr(1, arg.length()-1);
			std::transform(argname.begin(), argname.end(), argname.begin(), ::tolower);
			if (argname == "cont" || argname == "continue")
			{
				_loadLastSave = true;
				continue;
			}
			if (argv.size() > i + 1)
			{
				++i; // we'll be consuming the next argument too
				Log(LOG_DEBUG) << "loadArgs(): "<< argname <<" -> " << argv[i];
				if (argname == "data")
				{
					_dataFolder = argv[i];
					if (_dataFolder.size() > 1 && _dataFolder[_dataFolder.size() - 1] != '/') {
						_dataFolder.push_back('/');
					}
				}
				else if (argname == "user")
				{
					_userFolder = argv[i];
					if (_userFolder.size() > 1 && _userFolder[_userFolder.size() - 1] != '/') {
						_userFolder.push_back('/');
					}
				}
				else if (argname == "cfg" || argname == "config")
				{
					_configFolder = argv[i];
					if (_configFolder.size() > 1 && _configFolder[_configFolder.size() - 1] != '/') {
						_configFolder.push_back('/');
					}
				}
				else if (argname == "master")
				{
					_masterMod = argv[i];
				}
				else
				{
					//save this command line option for now, we will apply it later
					_commandLine[argname] = argv[i];
				}
			}
			else
			{
				Log(LOG_WARNING) << "Unknown option: " << argname;
			}
		}
	}
}

/*
 * Displays command-line help when appropriate.
 * @param argc Number of arguments.
 * @param argv Array of argument strings.
 */
static bool showHelp()
{
	std::ostringstream help;
	help << "OpenXcom v" << OPENXCOM_VERSION_SHORT << std::endl;
	help << "Usage: openxcom [OPTION]..." << std::endl << std::endl;
	help << "-data PATH" << std::endl;
	help << "        use PATH as the default Data Folder instead of auto-detecting" << std::endl << std::endl;
	help << "-user PATH" << std::endl;
	help << "        use PATH as the default User Folder instead of auto-detecting" << std::endl << std::endl;
	help << "-cfg PATH  or  -config PATH" << std::endl;
	help << "        use PATH as the default Config Folder instead of auto-detecting" << std::endl << std::endl;
	help << "-master MOD" << std::endl;
	help << "        set MOD to the current master mod (eg. -master xcom2)" << std::endl << std::endl;
	help << "-KEY VALUE" << std::endl;
	help << "        override option KEY with VALUE (eg. -displayWidth 640)" << std::endl << std::endl;
	help << "-help" << std::endl;
	help << "-?" << std::endl;
	help << "        show command-line help" << std::endl;
	for (auto arg: CrossPlatform::getArgs())
	{
		if ((arg[0] == '-' || arg[0] == '/') && arg.length() > 1)
		{
			std::string argname;
			if (arg[1] == '-' && arg.length() > 2)
				argname = arg.substr(2, arg.length()-1);
			else
				argname = arg.substr(1, arg.length()-1);
			std::transform(argname.begin(), argname.end(), argname.begin(), ::tolower);
			if (argname == "help" || argname == "?")
			{
				std::cout << help.str();
				return true;
			}
		}
	}
	return false;
}

const std::map<std::string, ModInfo> &getModInfos() { return _modInfos; }

/**
 * Splits the game's User folder by master mod,
 * creating a subfolder for each one.
 * Moving the saves from userFolder into subfolders
 * has been removed.
 */
static void userSplitMasters()
{
	for (auto i : _modInfos) {
		if (i.second.isMaster()) {
			std::string masterFolder = _userFolder + i.first;
			if (!CrossPlatform::folderExists(masterFolder)) {
				CrossPlatform::createFolder(masterFolder);
			}
		}
	}
}

/**
 * Handles the initialization of setting up default options
 * and finding and loading any existing ones.
 * @param argc Number of arguments.
 * @param argv Array of argument strings.
 * @return Do we start the game?
 */
bool init()
{
	if (showHelp())
		return false;
	create();
	resetDefault(true);
	loadArgs();
	setFolders();
	_setDefaultMods();
	updateOptions();

	// set up the logging reportingLevel
#ifdef _DEBUG
	Logger::reportingLevel() = LOG_DEBUG;
#else
	Logger::reportingLevel() = LOG_INFO;
#endif

	if (Options::verboseLogging)
		Logger::reportingLevel() = LOG_VERBOSE;

	// this enables writes to the log file and filters already emitted messages
	CrossPlatform::setLogFileName(getUserFolder() + "openxcom.log");

	Log(LOG_INFO) << "OpenXcom Version: " << OPENXCOM_VERSION_SHORT << OPENXCOM_VERSION_GIT;
#ifdef _WIN64
	Log(LOG_INFO) << "Platform: Windows 64 bit";
#elif _WIN32
	Log(LOG_INFO) << "Platform: Windows 32 bit";
#elif __APPLE__
	Log(LOG_INFO) << "Platform: OSX";
#elif  __ANDROID_API__
	Log(LOG_INFO) << "Platform: Android";
#elif __linux__
	Log(LOG_INFO) << "Platform: Linux";
#else
	Log(LOG_INFO) << "Platform: Unix-like";
#endif

	Log(LOG_INFO) << "Data folder is: " << _dataFolder;
	Log(LOG_INFO) << "Data search is: ";
	for (std::vector<std::string>::iterator i = _dataList.begin(); i != _dataList.end(); ++i)
	{
		Log(LOG_INFO) << "- " << *i;
	}
	Log(LOG_INFO) << "User folder is: " << _userFolder;
	Log(LOG_INFO) << "Config folder is: " << _configFolder;
	Log(LOG_INFO) << "Options loaded successfully.";

	FileMap::clear(false, Options::oxceEmbeddedOnly);
	return true;
}

// called from the dos screen state (StartState)
void refreshMods()
{
	if (reload)
	{
		_masterMod = "";
	}

	_modInfos.clear();
	SDL_RWops *rwops = CrossPlatform::getEmbeddedAsset("standard.zip");
	if (rwops) {
		Log(LOG_INFO) << "Scanning embedded standard mods...";
		FileMap::scanModZipRW(rwops, "exe:standard.zip");
	}
	if (Options::oxceEmbeddedOnly && rwops) {
		Log(LOG_INFO) << "Modding embedded resources is disabled, set 'oxceEmbeddedOnly: false' in options.cfg to enable.";
	} else {
		Log(LOG_INFO) << "Scanning standard mods in '" << getDataFolder() << "'...";
		FileMap::scanModDir(getDataFolder(), "standard", true);
	}
	Log(LOG_INFO) << "Scanning user mods in '" << getUserFolder() << "'...";
	FileMap::scanModDir(getUserFolder(), "mods", false);
#ifdef __MOBILE__
	if (getDataFolder() == getUserFolder())
	{
		Log(LOG_INFO) << "Skipped scanning user mods in the data folder, because it's the same folder as the user folder.";
	}
	else
	{
		Log(LOG_INFO) << "Scanning user mods in '" << getDataFolder() << "'...";
		FileMap::scanModDir(getDataFolder(), "mods", false);
	}
#endif

	// Check mods' dependencies on other mods and extResources (UFO, TFTD, etc),
	// also breaks circular dependency loops.
	FileMap::checkModsDependencies();

	// Now we can get the list of ModInfos from the FileMap -
	// those are the mods that can possibly be loaded.
	_modInfos = FileMap::getModInfos();

	// remove mods from list that no longer exist
	bool nonMasterModFound = false;
	std::map<std::string, bool> corruptedMasters;
	for (auto i = mods.begin(); i != mods.end();)
	{
		auto modIt = _modInfos.find(i->first);
		if (_modInfos.end() == modIt)
		{
			Log(LOG_VERBOSE) << "removing references to missing mod: " << i->first;
			i = mods.erase(i);
			continue;
		}
		else
		{
			if ((*modIt).second.isMaster())
			{
				if (nonMasterModFound)
				{
					Log(LOG_ERROR) << "Removing master mod '" << i->first << "' from the list, because it is on a wrong position. It will be re-added automatically.";
					corruptedMasters[i->first] = i->second;
					i = mods.erase(i);
					continue;
				}
			}
			else
			{
				nonMasterModFound = true;
			}
		}
		++i;
	}
	// re-insert corrupted masters at the beginning of the list
	for (auto j : corruptedMasters)
	{
		std::pair<std::string, bool> newMod(j.first, j.second);
		mods.insert(mods.begin(), newMod);
	}

	// add in any new mods picked up from the scan and ensure there is but a single
	// master active
	std::string activeMaster;
	std::string inactiveMaster;
	for (auto i = _modInfos.cbegin(); i != _modInfos.cend(); ++i)
	{
		bool found = false;
		for (std::vector< std::pair<std::string, bool> >::iterator j = mods.begin(); j != mods.end(); ++j)
		{
			if (i->first == j->first)
			{
				found = true;
				if (i->second.isMaster())
				{
					if (!_masterMod.empty())
					{
						j->second = (_masterMod == j->first);
					}
					if (j->second)
					{
						if (!activeMaster.empty())
						{
							Log(LOG_WARNING) << "Too many active masters detected; turning off " << j->first;
							j->second = false;
						}
						else
						{
							activeMaster = j->first;
						}
					}
					else
					{
						// prefer activating standard masters over a possibly broken
						// third party master
						if (inactiveMaster.empty() || j->first == "xcom1" || j->first == "xcom2")
						{
							inactiveMaster = j->first;
						}
					}
				}

				break;
			}
		}
		if (found)
		{
			continue;
		}

		// not active by default
		std::pair<std::string, bool> newMod(i->first, false);
		if (i->second.isMaster())
		{
			// it doesn't matter what order the masters are in since
			// only one can be active at a time anyway
			mods.insert(mods.begin(), newMod);

			if (inactiveMaster.empty())
			{
				inactiveMaster = i->first;
			}
		}
		else
		{
			mods.push_back(newMod);
		}
	}

	if (activeMaster.empty())
	{
		if (inactiveMaster.empty())
		{
			Log(LOG_ERROR) << "no mod masters available";
			throw Exception("No X-COM installations found");
		}
		else
		{
			Log(LOG_INFO) << "no master already active; activating " << inactiveMaster;
			std::find(mods.begin(), mods.end(), std::pair<std::string, bool>(inactiveMaster, false))->second = true;
			_masterMod = inactiveMaster;
		}
	}
	else
	{
		_masterMod = activeMaster;
	}
	save();
}

void updateMods()
{
	// pick up stuff in common before-hand
	FileMap::clear(false, Options::oxceEmbeddedOnly);

	refreshMods();
	FileMap::setup(getActiveMods(), Options::oxceEmbeddedOnly);
	userSplitMasters();

	// report active mods that don't meet the minimum OXCE requirements
	Log(LOG_INFO) << "Active mods:";
	auto activeMods = getActiveMods();
	for (auto modInf : activeMods)
	{
		Log(LOG_INFO) << "- " << modInf->getId() << " v" << modInf->getVersion();
		if (!modInf->isVersionOk())
		{
			Log(LOG_ERROR) << "Mod '" << modInf->getName() << "' requires at least OXCE v" << modInf->getRequiredExtendedVersion();
		}
	}
}

/**
 * Is the password correct?
 * @return Mostly false.
 */
bool isPasswordCorrect()
{
	if (_passwordCheck < 0)
	{
		std::string md5hash = md5(Options::password);
		if (md5hash == "52bd8e15118862c40fc0d6107e197f42")
			_passwordCheck = 1;
		else
			_passwordCheck = 0;
	}

	return _passwordCheck > 0;
}

/**
 * Gets the currently active master mod.
 * @return Mod id.
 */
std::string getActiveMaster()
{
	return _masterMod;
}

bool getLoadLastSave()
{
	return _loadLastSave && !_loadLastSaveExpended;
}

void expendLoadLastSave()
{
	_loadLastSaveExpended = true;
}

/**
 * Sets up the game's Data folder where the data files
 * are loaded from and the User folder and Config
 * folder where settings and saves are stored in.
 */
void setFolders()
{
	_dataList = CrossPlatform::findDataFolders();
	if (!_dataFolder.empty())
	{
		_dataList.insert(_dataList.begin(), _dataFolder);
		Log(LOG_DEBUG) << "setFolders(): inserting " << _dataFolder;
	}
	if (_userFolder.empty())
	{
		std::vector<std::string> user = CrossPlatform::findUserFolders();

		if (_configFolder.empty())
		{
			_configFolder = CrossPlatform::findConfigFolder();
		}

		// Look for an existing user folder
		for (std::vector<std::string>::reverse_iterator i = user.rbegin(); i != user.rend(); ++i)
		{
			if (CrossPlatform::folderExists(*i))
			{
				_userFolder = *i;
				break;
			}
		}

		// Set up folders
		if (_userFolder.empty())
		{
			for (std::vector<std::string>::iterator i = user.begin(); i != user.end(); ++i)
			{
				if (CrossPlatform::createFolder(*i))
				{
					_userFolder = *i;
					break;
				}
			}
		}
	}
	if (!_userFolder.empty())
	{
		// create mod folder if it doesn't already exist
		CrossPlatform::createFolder(_userFolder + "mods");
	}

	if (_configFolder.empty())
	{
		_configFolder = _userFolder;
	}
}

/**
 * Updates the game's options with those in the configuration
 * file, if it exists yet, and any supplied on the command line.
 */
void updateOptions()
{
	// Load existing options
	if (CrossPlatform::folderExists(_configFolder))
	{
		if (CrossPlatform::fileExists(_configFolder + "options.cfg"))
		{
			load();
#ifndef EMBED_ASSETS
			Options::oxceEmbeddedOnly = false;
#endif
		}
		else
		{
			save();
		}
	}
	// Create config folder and save options
	else
	{
		CrossPlatform::createFolder(_configFolder);
		save();
	}

	// now apply options set on the command line, overriding defaults and those loaded from config file
	//if (!_commandLine.empty())
	for (std::vector<OptionInfo>::iterator i = _info.begin(); i != _info.end(); ++i)
	{
		i->load(_commandLine, true);
	}
}

/**
 * Loads options from a YAML file.
 * @param filename YAML filename.
 * @return Was the loading successful?
 */
bool load(const std::string &filename)
{
	std::string s = _configFolder + filename + ".cfg";
	try
	{
		YAML::Node doc = YAML::Load(*CrossPlatform::readFile(s));
		// Ignore old options files
		if (doc["options"]["NewBattleMission"])
		{
			return false;
		}
		for (std::vector<OptionInfo>::iterator i = _info.begin(); i != _info.end(); ++i)
		{
			i->load(doc["options"]);
		}

		mods.clear();
		for (YAML::const_iterator i = doc["mods"].begin(); i != doc["mods"].end(); ++i)
		{
			std::string id = (*i)["id"].as<std::string>();
			bool active = (*i)["active"].as<bool>(false);
			mods.push_back(std::pair<std::string, bool>(id, active));
		}
		if (mods.empty())
		{
			_setDefaultMods();
		}
	}
	catch (YAML::Exception &e)
	{
		Log(LOG_WARNING) << e.what();
		return false;
	}
	return true;
}

void writeNode(const YAML::Node& node, YAML::Emitter& emitter)
{
	switch (node.Type())
	{
		case YAML::NodeType::Sequence:
		{
			emitter << YAML::BeginSeq;
			for (size_t i = 0; i < node.size(); i++)
			{
				writeNode(node[i], emitter);
			}
			emitter << YAML::EndSeq;
			break;
		}
		case YAML::NodeType::Map:
		{
			emitter << YAML::BeginMap;

			// First collect all the keys
			std::vector<std::string> keys(node.size());
			int key_it = 0;
			for (YAML::const_iterator it = node.begin(); it != node.end(); ++it)
			{
				keys[key_it++] = it->first.as<std::string>();
			}

			// Then sort them
			std::sort(keys.begin(), keys.end());

			// Then emit all the entries in sorted order.
			for(size_t i = 0; i < keys.size(); i++)
			{
				emitter << YAML::Key;
				emitter << keys[i];
				emitter << YAML::Value;
				writeNode(node[keys[i]], emitter);
			}
			emitter << YAML::EndMap;
			break;
		}
		default:
			emitter << node;
			break;
	}
}

/**
 * Saves options to a YAML file.
 * @param filename YAML filename.
 * @return Was the saving successful?
 */
bool save(const std::string &filename)
{
	YAML::Emitter out;
	try
	{
		YAML::Node doc, node;
		for (std::vector<OptionInfo>::iterator i = _info.begin(); i != _info.end(); ++i)
		{
			i->save(node);
		}
		doc["options"] = node;

		for (std::vector< std::pair<std::string, bool> >::iterator i = mods.begin(); i != mods.end(); ++i)
		{
			YAML::Node mod;
			mod["id"] = i->first;
			mod["active"] = i->second;
			doc["mods"].push_back(mod);
		}

		writeNode(doc, out);
	}
	catch (YAML::Exception &e)
	{
		Log(LOG_WARNING) << e.what();
		return false;
	}
	std::string filepath = _configFolder + filename + ".cfg";
	std::string data(out.c_str());

	if (!CrossPlatform::writeFile(filepath, data + "\n" ))
	{
		Log(LOG_WARNING) << "Failed to save " << filepath;
		return false;
	}
	return true;
}

/**
 * Returns the game's current Data folder where resources
 * and X-Com files are loaded from.
 * @return Full path to Data folder.
 */
std::string getDataFolder()
{
	return _dataFolder;
}

/**
 * Changes the game's current Data folder where resources
 * and X-Com files are loaded from.
 * @param folder Full path to Data folder.
 */
void setDataFolder(const std::string &folder)
{
	_dataFolder = folder;
	Log(LOG_DEBUG) << "setDataFolder(" << folder <<");";
}

/**
 * Returns the game's list of possible Data folders.
 * @return List of Data paths.
 */
const std::vector<std::string> &getDataList()
{
	return _dataList;
}

/**
 * Returns the game's User folder where
 * saves are stored in.
 * @return Full path to User folder.
 */
std::string getUserFolder()
{
	return _userFolder;
}

/**
 * Returns the game's Config folder where
 * settings are stored in. Normally the same
 * as the User folder.
 * @return Full path to Config folder.
 */
std::string getConfigFolder()
{
	return _configFolder;
}

/**
 * Returns the game's User folder for the
 * currently loaded master mod.
 * @return Full path to User folder.
 */
std::string getMasterUserFolder()
{
	return _userFolder + _masterMod + "/";
}

/**
 * Returns the game's list of all available option information.
 * @return List of OptionInfo's.
 */
const std::vector<OptionInfo> &getOptionInfo()
{
	return _info;
}

/**
 * Returns a list of currently active mods.
 * They must be enabled and activable.
 * @sa ModInfo::canActivate
 * @return List of info for the active mods.
 */
std::vector<const ModInfo *> getActiveMods()
{
	std::vector<const ModInfo*> activeMods;
	for (std::vector< std::pair<std::string, bool> >::iterator i = mods.begin(); i != mods.end(); ++i)
	{
		if (i->second)
		{
			const ModInfo *info = &_modInfos.at(i->first);
			if (info->canActivate(_masterMod))
			{
				activeMods.push_back(info);
			}
		}
	}
	return activeMods;
}

/**
 * Saves display settings temporarily to be able
 * to revert to old ones.
 */
void backupDisplay()
{
	Options::newDisplayWidth = Options::displayWidth;
	Options::newDisplayHeight = Options::displayHeight;
	Options::newBattlescapeScale = Options::battlescapeScale;
	Options::newGeoscapeScale = Options::geoscapeScale;
	Options::newOpenGL = Options::useOpenGL;
	Options::newScaleFilter = Options::useScaleFilter;
	Options::newHQXFilter = Options::useHQXFilter;
	Options::newOpenGLShader = Options::useOpenGLShader;
	Options::newXBRZFilter = Options::useXBRZFilter;
	Options::newRootWindowedMode = Options::rootWindowedMode;
	Options::newWindowedModePositionX = Options::windowedModePositionX;
	Options::newWindowedModePositionY = Options::windowedModePositionY;
	Options::newFullscreen = Options::fullscreen;
	Options::newAllowResize = Options::allowResize;
	Options::newBorderless = Options::borderless;
}

/**
 * Switches old/new display options for temporarily
 * testing a new display setup.
 */
void switchDisplay()
{
	std::swap(displayWidth, newDisplayWidth);
	std::swap(displayHeight, newDisplayHeight);
	std::swap(useOpenGL, newOpenGL);
	std::swap(useScaleFilter, newScaleFilter);
	std::swap(battlescapeScale, newBattlescapeScale);
	std::swap(geoscapeScale, newGeoscapeScale);
	std::swap(useHQXFilter, newHQXFilter);
	std::swap(useOpenGLShader, newOpenGLShader);
	std::swap(useXBRZFilter, newXBRZFilter);
	std::swap(rootWindowedMode, newRootWindowedMode);
	std::swap(windowedModePositionX, newWindowedModePositionX);
	std::swap(windowedModePositionY, newWindowedModePositionY);
	std::swap(fullscreen, newFullscreen);
	std::swap(allowResize, newAllowResize);
	std::swap(borderless, newBorderless);
}

}

}
