#region License
/* Runtime patches for the FEZ PortMaster port.
 *
 * Copyright (c) 2026 martywho
 * Released under the MIT License; see licenses/LICENSE.fezpatches.txt.
 */
#endregion

using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Reflection;

using HarmonyLib;

using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.Graphics;

namespace FezPatches
{
	/* Five things FEZ 1.12 does that a handheld cannot live with, patched at
	 * runtime through Harmony: its view scale is floored at 1.0, its display
	 * mode list excludes every handheld panel, its intro splashes are drawn at
	 * a fixed pixel size, it holds every pak in memory for the session, and a
	 * transition outliving the intro dereferences a field the intro nulls.
	 * Each patch carries its reasoning at the method that implements it.
	 */
	[ModEntryPoint]
	public static class Entry
	{
		private const float FezAspect = 16.0f / 9.0f;

		private static FieldInfo viewScale;
		private static FieldInfo introPanDown;
		private static FieldInfo panDownDisposed;
		private static FieldInfo resolutions;
		private static FieldInfo settingsField;

		/* Where an asset lives, for the paks that are no longer read whole. */
		private struct Slot
		{
			public string Pak;
			public long Offset;
			public int Length;
		}

		private const int MusicCacheLimit = 4;

		private static Dictionary<string, Slot> contentIndex;
		private static Dictionary<string, Slot> musicIndex;
		private static FieldInfo cachedAssetsField;
		private static FieldInfo musicCacheField;

		private static readonly Dictionary<string, FileStream> openPaks =
			new Dictionary<string, FileStream>();
		private static readonly List<string> musicOrder = new List<string>();
		private static bool tracePaks;

		public static void Main()
		{
			Type settingsManager = AccessTools.TypeByName(
				"FezEngine.Tools.SettingsManager"
			);
			if (settingsManager == null)
			{
				throw new Exception("no FezEngine.Tools.SettingsManager");
			}

			viewScale = AccessTools.Field(settingsManager, "viewScale");
			MethodInfo setupViewport = AccessTools.Method(
				settingsManager,
				"SetupViewport"
			);
			if (viewScale == null || setupViewport == null)
			{
				throw new Exception("SettingsManager is not the expected shape");
			}

			Harmony harmony = new Harmony("portmaster.fez");
			harmony.Patch(
				setupViewport,
				null,
				new HarmonyMethod(
					typeof(Entry).GetMethod("UnclampViewScale")
				)
			);

			/* Intro splash textures are drawn at a fixed pixel size. */
			Type introStorey = AccessTools.TypeByName(
				"FezGame.Components.Intro+<LoadContent>c__AnonStorey0"
			);
			MethodInfo introLoad = introStorey == null
				? null
				: AccessTools.Method(introStorey, "<>m__0");
			if (introLoad != null)
			{
				harmony.Patch(
					introLoad,
					null,
					new HarmonyMethod(
						typeof(Entry).GetMethod("ScaleIntroSplashes")
					)
				);
			}

			/* Applying video settings during the intro leaves a
			 * TileTransition alive, holding the WaitFor predicate
			 * `() => IntroPanDown.SinceStarted > 0f`. The intro then nulls
			 * IntroPanDown as it tears itself down, and the transition's next
			 * Draw dereferences it — the game dies a frame after logging
			 * "Intro is done and game is go!".
			 *
			 * The same wait hangs instead of throwing when the component is
			 * still referenced but can no longer advance: SinceStarted only
			 * accumulates while the game is unpaused, and the video menu
			 * pauses it, so a pan-down that has disposed itself in the
			 * meantime leaves the transition waiting on a value that will
			 * never move again.
			 *
			 * TileTransition.Draw treats a null predicate as "proceed", so
			 * answer the same way whenever the pan-down can no longer make
			 * progress, rather than throwing or waiting forever.
			 */
			Type introType = AccessTools.TypeByName("FezGame.Components.Intro");
			MethodInfo panDownWait = introType == null
				? null
				: AccessTools.Method(introType, "<DoPanDown>m__3");
			introPanDown = introType == null
				? null
				: AccessTools.Field(introType, "IntroPanDown");
			panDownDisposed = introPanDown == null
				? null
				: AccessTools.Field(introPanDown.FieldType, "IsDisposed");
			if (panDownWait != null && introPanDown != null)
			{
				harmony.Patch(
					panDownWait,
					new HarmonyMethod(
						typeof(Entry).GetMethod("GuardPanDownWait")
					)
				);
			}

			/* FEZ reads Music.pak, Updates.pak and Other.pak into memory
			 * whole and holds ~370 MB of them for the session, which is more
			 * than a 1 GB device has to spare; two testers had the game
			 * SIGKILLed in the first few minutes. These patches index the paks
			 * instead and read each asset when it is asked for. All of it is
			 * cache policy, and a miss falls through to FEZ's own code, which
			 * is why FEZ_LAZY_PAKS=0 restores the original behaviour.
			 * LAZY-PAKS.md beside this file has the measurements, the pak
			 * format and the constraints each patch works under.
			 */
			string lazyPaks = Environment.GetEnvironmentVariable("FEZ_LAZY_PAKS");
			tracePaks = (lazyPaks == "debug");
			if (lazyPaks != "0")
			{
				PatchPakLoading(harmony);
			}

			/* FEZ only keeps display modes of at least 1280x720, so on a
			 * handheld nothing survives its filter and the video menu, which
			 * indexes that list with no emptiness check, throws on first input.
			 * Applying anything there also writes the chosen mode into the
			 * settings as the render size, which would undo the port's own
			 * defaults. Since the menu cannot offer the panel itself, offer it
			 * here: the panel's width at 16:9, so the list is never empty and
			 * applying is harmless.
			 */
			resolutions = AccessTools.Field(settingsManager, "Resolutions");
			settingsField = AccessTools.Field(settingsManager, "Settings");
			MethodInfo initResolutions = AccessTools.Method(
				settingsManager,
				"InitializeResolutions"
			);
			if (resolutions != null && initResolutions != null)
			{
				harmony.Patch(
					initResolutions,
					null,
					new HarmonyMethod(
						typeof(Entry).GetMethod("UsePanelResolution")
					)
				);
			}
		}

		/* FEZ's intro splashes are blitted at one texel per pixel, with only a
		 * two-way asset switch for 1440p, so below 720p they cover far more of
		 * the screen than intended and run off the edges. The draw calls carry
		 * no scale argument to correct, so shrink the textures themselves once,
		 * at load, and the existing centring maths follows.
		 */
		public static void ScaleIntroSplashes(object __instance)
		{
			float scale = (float) viewScale.GetValue(null);
			if (scale <= 0.0f || scale >= 0.999f)
			{
				return;
			}

			object intro = AccessTools
				.Field(__instance.GetType(), "$this")
				.GetValue(__instance);
			Type introType = intro.GetType();

			GraphicsDevice device = (GraphicsDevice) AccessTools
				.PropertyGetter(introType, "GraphicsDevice")
				.Invoke(intro, null);

			string[] fields = { "TrixelEngineText", "TrapdoorLogo" };
			foreach (string name in fields)
			{
				FieldInfo field = AccessTools.Field(introType, name);
				if (field == null)
				{
					continue;
				}
				Texture2D source = (Texture2D) field.GetValue(intro);
				if (source == null)
				{
					continue;
				}
				field.SetValue(intro, Downscale(device, source, scale));
			}
		}

		public static bool GuardPanDownWait(object __instance, ref bool __result)
		{
			object panDown = introPanDown.GetValue(__instance);
			bool gone = (panDown == null) ||
				(panDownDisposed != null &&
					(bool) panDownDisposed.GetValue(panDown));
			if (!gone)
			{
				return true;
			}

			/* Nothing left to wait for: let the transition finish. */
			__result = true;
			return false;
		}

		private static Texture2D Downscale(
			GraphicsDevice device,
			Texture2D source,
			float scale
		) {
			int width = Math.Max(1, (int) Math.Round(source.Width * scale));
			int height = Math.Max(1, (int) Math.Round(source.Height * scale));

			RenderTargetBinding[] previous = device.GetRenderTargets();
			RenderTarget2D target = new RenderTarget2D(device, width, height);

			device.SetRenderTarget(target);
			device.Clear(Color.Transparent);

			SpriteBatch batch = new SpriteBatch(device);
			batch.Begin(
				SpriteSortMode.Immediate,
				BlendState.AlphaBlend,
				SamplerState.LinearClamp,
				DepthStencilState.None,
				RasterizerState.CullNone
			);
			batch.Draw(source, new Rectangle(0, 0, width, height), Color.White);
			batch.End();
			batch.Dispose();

			if (previous == null || previous.Length == 0)
			{
				device.SetRenderTarget(null);
			}
			else
			{
				device.SetRenderTargets(previous);
			}

			return target;
		}

		public static void UsePanelResolution()
		{
			DisplayMode panel = GraphicsAdapter.DefaultAdapter.CurrentDisplayMode;
			if (panel == null || panel.Width <= 0)
			{
				return;
			}

			int height = (int) Math.Floor(panel.Width / FezAspect);
			if (height < 1)
			{
				height = 1;
			}

			/* DisplayMode's constructor is internal to FNA. */
			DisplayMode mode = (DisplayMode) Activator.CreateInstance(
				typeof(DisplayMode),
				BindingFlags.Instance | BindingFlags.NonPublic,
				null,
				new object[] { panel.Width, height, SurfaceFormat.Color },
				null
			);

			IList list = (IList) resolutions.GetValue(null);
			list.Clear();
			list.Add(mode);

			/* Render at that size too. The port cannot seed a resolution that
			 * suits every panel, and anything smaller than the screen would be
			 * upscaled for no reason, so take it from the display each run.
			 */
			object settings = settingsField.GetValue(null);
			if (settings != null)
			{
				AccessTools.PropertySetter(settings.GetType(), "Width")
					.Invoke(settings, new object[] { mode.Width });
				AccessTools.PropertySetter(settings.GetType(), "Height")
					.Invoke(settings, new object[] { mode.Height });
			}
		}

		/* FEZ composes its world for 1280x720 and has no cheap way to show that
		 * framing on a smaller screen. SettingsManager.SetupViewport derives a
		 * view scale from the viewport, but floors it at 1.0, so on a 640x480
		 * panel the game crops to the middle of its own composition instead of
		 * scaling it down. The only mode that escapes the floor, Supersampled,
		 * does it by lifting the backbuffer to 1280 wide, which is four times the
		 * pixels a 640x480 panel needs and is measurably choppy on rk3326.
		 *
		 * Recomputing the scale after SetupViewport, without the floor, gives the
		 * whole composition letterboxed into a native-sized backbuffer. The
		 * formula is FEZ's own; only the clamp is dropped. Where FEZ did not clamp
		 * the result is identical, so Supersampled and larger screens are
		 * unaffected.
		 */
		public static void UnclampViewScale(GraphicsDevice device)
		{
			/* SetupViewport leaves the scale alone while a render target is
			 * bound, so neither do we.
			 */
			RenderTargetBinding[] targets = device.GetRenderTargets();
			if (targets != null && targets.Length > 0)
			{
				return;
			}

			Viewport viewport = device.Viewport;
			if (viewport.Width <= 0 || viewport.Height <= 0)
			{
				return;
			}

			float pillarboxed = viewport.Height * FezAspect;
			float scale = (viewport.Width >= pillarboxed)
				? pillarboxed / 1280.0f
				: (viewport.Width / FezAspect) / 720.0f;

			viewScale.SetValue(null, scale);
		}

		private static void PatchPakLoading(Harmony harmony)
		{
			Type contentManager = AccessTools.TypeByName(
				"FezEngine.Tools.MemoryContentManager"
			);
			Type soundManager = AccessTools.TypeByName(
				"FezEngine.Services.SoundManager"
			);
			if (contentManager == null || soundManager == null)
			{
				return;
			}

			cachedAssetsField = AccessTools.Field(contentManager, "cachedAssets");
			musicCacheField = AccessTools.Field(soundManager, "MusicCache");

			MethodInfo preload = AccessTools.Method(contentManager, "Preload");
			MethodInfo openStream = AccessTools.Method(
				contentManager,
				"OpenStream",
				new Type[] { typeof(string) }
			);
			MethodInfo assetExists = AccessTools.Method(
				contentManager,
				"AssetExists",
				new Type[] { typeof(string) }
			);
			MethodInfo assetNames = AccessTools.PropertyGetter(
				contentManager,
				"AssetNames"
			);
			MethodInfo initLibrary = AccessTools.Method(
				soundManager,
				"InitializeLibrary"
			);
			MethodInfo getCue = AccessTools.Method(
				soundManager,
				"GetCue",
				new Type[] { typeof(string), typeof(bool) }
			);

			/* All of it or none: a half-applied set would leave FEZ looking
			 * for assets in a dictionary nothing fills.
			 */
			if (cachedAssetsField == null || musicCacheField == null ||
				preload == null || openStream == null ||
				assetExists == null || assetNames == null ||
				initLibrary == null || getCue == null)
			{
				return;
			}

			Patch(harmony, preload, "IndexContentPaks");
			Patch(harmony, openStream, "OpenStreamFromPak");
			Patch(harmony, assetExists, "AssetExistsInIndex");
			Patch(harmony, assetNames, "AssetNamesWithIndex");
			Patch(harmony, initLibrary, "IndexMusicPak");
			Patch(harmony, getCue, "FillCue");
		}

		private static void Patch(Harmony harmony, MethodInfo target, string prefix)
		{
			harmony.Patch(
				target,
				new HarmonyMethod(typeof(Entry).GetMethod(prefix))
			);
		}

		/* Preload reads Updates.pak and Other.pak into cachedAssets, 160 MB of
		 * it. Walk them for names and offsets instead. Returning true anywhere
		 * here hands the work back to FEZ, so a pak this cannot read is not a
		 * failure, only a fallback.
		 */
		public static bool IndexContentPaks(object __instance)
		{
			if (contentIndex != null)
			{
				return false;
			}

			ContentManager content = __instance as ContentManager;
			string root = (content == null) ? "Content" : content.RootDirectory;
			try
			{
				Dictionary<string, Slot> index = new Dictionary<string, Slot>(4096);
				IndexPak(index, Path.Combine(root, "Updates.pak"));
				IndexPak(index, Path.Combine(root, "Other.pak"));
				contentIndex = index;
				Trace("indexed " + index.Count + " content assets");
			}
			catch (Exception)
			{
				contentIndex = null;
				return true;
			}
			return false;
		}

		/* Essentials still lives in cachedAssets, so look there first and let
		 * FEZ serve those itself. FutureTexture2DReader casts this stream to
		 * MemoryStream and calls GetBuffer on it, and OggStream does the same,
		 * so it has to be a MemoryStream built publicly visible - a file
		 * stream over the pak would read as null there.
		 */
		public static bool OpenStreamFromPak(string assetName, ref Stream __result)
		{
			if (contentIndex == null)
			{
				return true;
			}

			string key = assetName
				.ToLower(CultureInfo.InvariantCulture)
				.Replace('/', '\\');

			IDictionary cached = (IDictionary) cachedAssetsField.GetValue(null);
			if (cached != null && cached.Contains(key))
			{
				return true;
			}

			Slot slot;
			if (!contentIndex.TryGetValue(key, out slot))
			{
				/* Let FEZ raise its own ContentLoadException. */
				return true;
			}

			byte[] buffer = Read(slot);
			if (buffer == null)
			{
				return true;
			}

			__result = new MemoryStream(buffer, 0, buffer.Length, false, true);
			return false;
		}

		public static bool AssetExistsInIndex(string name, ref bool __result)
		{
			if (contentIndex == null)
			{
				return true;
			}

			string key = name
				.Replace('/', '\\')
				.ToLower(CultureInfo.InvariantCulture);
			if (contentIndex.ContainsKey(key))
			{
				__result = true;
				return false;
			}
			return true;
		}

		/* ContentManagerProvider.GetAllIn filters this by prefix to find what
		 * a level needs, so indexed names have to appear here too.
		 */
		public static bool AssetNamesWithIndex(ref IEnumerable<string> __result)
		{
			if (contentIndex == null)
			{
				return true;
			}

			List<string> names = new List<string>(contentIndex.Keys);
			IDictionary cached = (IDictionary) cachedAssetsField.GetValue(null);
			if (cached != null)
			{
				foreach (object key in cached.Keys)
				{
					string name = (string) key;
					if (!contentIndex.ContainsKey(name))
					{
						names.Add(name);
					}
				}
			}

			__result = names;
			return false;
		}

		/* InitializeLibrary reads all 130 tracks, 193 MB, before the title
		 * screen. Index it and leave MusicCache empty for GetCue to fill.
		 */
		public static bool IndexMusicPak(object __instance)
		{
			if (musicIndex == null)
			{
				try
				{
					Dictionary<string, Slot> index =
						new Dictionary<string, Slot>(256);
					IndexPak(index, Path.Combine("Content", "Music.pak"));
					musicIndex = index;
					Trace("indexed " + index.Count + " music tracks");
				}
				catch (Exception)
				{
					musicIndex = null;
					return true;
				}
			}

			/* InitializeLibrary is public and guards itself against a second
			 * call, so only seed the cache when there is not one already.
			 */
			if (musicCacheField.GetValue(__instance) == null)
			{
				musicCacheField.SetValue(
					__instance,
					new Dictionary<string, byte[]>()
				);
			}

			/* InitializeLibrary's own re-entry guard, which it sets before
			 * doing any work.
			 */
			FieldInfo initialized = AccessTools.Field(
				__instance.GetType(),
				"initialized"
			);
			if (initialized != null)
			{
				initialized.SetValue(__instance, true);
			}
			return false;
		}

		/* GetCue indexes MusicCache directly, so put the track it is about to
		 * ask for in front of it. Dropping the older entries is safe: the
		 * MemoryStream FEZ wraps around a track keeps the array alive for as
		 * long as it is playing, whatever the dictionary holds.
		 */
		public static void FillCue(object __instance, string name)
		{
			if (musicIndex == null)
			{
				return;
			}

			try
			{
				string key = name
					.Replace(" ^ ", "\\")
					.ToLower(CultureInfo.InvariantCulture);

				IDictionary cache =
					(IDictionary) musicCacheField.GetValue(__instance);
				if (cache == null)
				{
					return;
				}

				lock (musicOrder)
				{
					if (!cache.Contains(key))
					{
						Slot slot;
						if (!musicIndex.TryGetValue(key, out slot))
						{
							/* Not a track; GetCue logs its own failure. */
							return;
						}
						byte[] buffer = Read(slot);
						if (buffer == null)
						{
							return;
						}
						cache[key] = buffer;
						Trace("read track " + key + ", " + buffer.Length + " bytes");
					}

					musicOrder.Remove(key);
					musicOrder.Add(key);
					while (musicOrder.Count > MusicCacheLimit)
					{
						cache.Remove(musicOrder[0]);
						musicOrder.RemoveAt(0);
					}
				}
			}
			catch (Exception)
			{
				/* A miss here only means FEZ reports the cue itself. */
			}
		}

		/* FEZ_LAZY_PAKS=debug reports what is indexed and which tracks are
		 * read, which is the part with no other visible trace. FEZ.sh tees
		 * stderr into log.txt, so a tester can turn it on and send that.
		 */
		private static void Trace(string message)
		{
			if (tracePaks)
			{
				Console.Error.WriteLine("[lazy paks] " + message);
			}
		}

		/* Pak layout: an entry count, then per entry a length-prefixed name,
		 * a length, and the payload. Names are stored as FEZ looks them up,
		 * and the first pak to carry a name wins, which is the order
		 * LoadEssentials and Preload read them in.
		 */
		private static void IndexPak(Dictionary<string, Slot> into, string path)
		{
			using (FileStream file = File.OpenRead(path))
			using (BinaryReader reader = new BinaryReader(file))
			{
				int count = reader.ReadInt32();
				for (int i = 0; i < count; i++)
				{
					string name = reader.ReadString();
					int length = reader.ReadInt32();
					if (!into.ContainsKey(name))
					{
						Slot slot;
						slot.Pak = path;
						slot.Offset = file.Position;
						slot.Length = length;
						into.Add(name, slot);
					}
					file.Seek(length, SeekOrigin.Current);
				}
			}
		}

		/* Level loading runs on worker threads, so the seek and the read have
		 * to stay together.
		 */
		private static byte[] Read(Slot slot)
		{
			lock (openPaks)
			{
				try
				{
					FileStream file;
					if (!openPaks.TryGetValue(slot.Pak, out file))
					{
						file = File.OpenRead(slot.Pak);
						openPaks.Add(slot.Pak, file);
					}

					file.Seek(slot.Offset, SeekOrigin.Begin);
					byte[] buffer = new byte[slot.Length];
					int done = 0;
					while (done < slot.Length)
					{
						int got = file.Read(buffer, done, slot.Length - done);
						if (got <= 0)
						{
							return null;
						}
						done += got;
					}
					return buffer;
				}
				catch (Exception)
				{
					return null;
				}
			}
		}
	}
}
