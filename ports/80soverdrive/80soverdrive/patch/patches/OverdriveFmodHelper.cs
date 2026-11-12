// OverdriveFmodHelper.cs - small helper assembly called from the patched ChaiFoxes.FMODAudio.Desktop.dll.
// When FMOD's System.init fails (ChaiFoxes ignores the result and the game later dies with a NullReferenceException),
// AfterInit() logs the available FMOD drivers by name and then tries, in order:
//   1) every driver index of the currently selected output type  (System.setDriver + System.init)
//   2) FMOD_OUTPUTTYPE_NOSOUND (silent, but the game keeps running)
// Environment:  OVERDRIVE_FMOD_FALLBACK=0  disables the retries (logging stays).
// All output goes to stderr with the prefix "[FMODDIAG]" so it lands in the launcher's log.txt.
using System;
using System.Runtime.InteropServices;
using System.Text;

namespace OverdriveFmod
{
    public static class AudioInit
    {
        const string Lib = "libfmod.so";   // same library ChaiFoxes loads; resolved via LD_LIBRARY_PATH

        [DllImport(Lib, EntryPoint = "FMOD5_System_Init")] static extern int SysInit(IntPtr sys, int maxChannels, uint flags, IntPtr extra);
        [DllImport(Lib, EntryPoint = "FMOD5_System_SetOutput")] static extern int SysSetOutput(IntPtr sys, int output);
        [DllImport(Lib, EntryPoint = "FMOD5_System_SetDriver")] static extern int SysSetDriver(IntPtr sys, int driver);
        [DllImport(Lib, EntryPoint = "FMOD5_System_GetNumDrivers")] static extern int SysGetNumDrivers(IntPtr sys, out int n);
        [DllImport(Lib, EntryPoint = "FMOD5_System_GetDriverInfo")]
        static extern int SysGetDriverInfo(IntPtr sys, int id, byte[] name, int nameLen, IntPtr guid, IntPtr rate, IntPtr mode, IntPtr channels);

        const int OUTPUT_NOSOUND = 2;

        static void Log(string s) { Console.Error.WriteLine("[FMODDIAG] " + s); }

        static string DriverName(IntPtr sys, int i)
        {
            try
            {
                var buf = new byte[256];
                int r = SysGetDriverInfo(sys, i, buf, buf.Length, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero);
                if (r != 0) return "<getDriverInfo error " + r + ">";
                int len = Array.IndexOf(buf, (byte)0); if (len < 0) len = buf.Length;
                return Encoding.UTF8.GetString(buf, 0, len);
            }
            catch (Exception e) { return "<" + e.GetType().Name + ">"; }
        }

        // result: RESULT of System.init (0 == OK)
        public static void AfterInit(int result, IntPtr sys, int maxChannels, uint flags)
        {
            if (result == 0) return;
            try
            {
                Log("System.init failed with result " + result + "");
                int n; int rn = SysGetNumDrivers(sys, out n);
                Log("drivers for current output: " + (rn == 0 ? n.ToString() : "error " + rn));
                if (rn == 0) for (int i = 0; i < n; i++) Log("  driver " + i + ": " + DriverName(sys, i));

                if (Environment.GetEnvironmentVariable("OVERDRIVE_FMOD_FALLBACK") == "0") { Log("fallback disabled"); return; }

                if (rn == 0)
                    for (int i = 0; i < n; i++)
                    {
                        SysSetDriver(sys, i);
                        int r = SysInit(sys, maxChannels, flags, IntPtr.Zero);
                        Log("retry init with driver " + i + " -> " + r);
                        if (r == 0) { Log("audio OK using driver " + i); return; }
                    }

                SysSetOutput(sys, OUTPUT_NOSOUND); SysSetDriver(sys, 0);
                int rr = SysInit(sys, maxChannels, flags, IntPtr.Zero);
                Log("fallback to NOSOUND output (no audio) -> " + rr);
            }
            catch (Exception e) { Log("fallback error: " + e); }
        }
    }
}
