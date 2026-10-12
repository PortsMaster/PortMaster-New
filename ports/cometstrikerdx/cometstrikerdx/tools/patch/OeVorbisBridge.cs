using System;
using System.IO;
using System.Runtime.InteropServices;

namespace OrangeEngineR.Audio
{
    public static class OeVorbisBridge
    {
        [DllImport("vorbisfile")]
        static extern int ov_fopen(string path, IntPtr vf);

        [DllImport("vorbisfile")]
        static extern int ov_read(IntPtr vf, byte[] buffer, int length, int bigendianp, int word, int sgned, ref int bitstream);

        [DllImport("vorbisfile")]
        static extern int ov_clear(IntPtr vf);

        [DllImport("vorbisfile")]
        static extern IntPtr ov_comment(IntPtr vf, int link);

        // Max-RAM music target used by the patchscript:
        // 22.05 kHz, mono, signed 16-bit PCM.
        // Do not change these without changing the music encoding settings.
        const int Channels = 1;
        const int SampleRate = 22050;
        const int Bits = 16;

        // sfxpack.py embeds these as plain Vorbis comments (LOOPSTART=/LOOPEND=)
        // at pack time, already rescaled to this file's target sample rate.
        // We read them back here and re-materialize a standard WAV 'smpl'
        // chunk so OeWaveFileData.FromStream's existing loop-point parsing
        // (samplerLoopStart/samplerLoopEnd) keeps working unchanged.
        static bool TryGetLoopPoints(IntPtr vf, out int loopStart, out int loopEnd)
        {
            loopStart = 0;
            loopEnd = 0;

            IntPtr commentPtr = ov_comment(vf, -1);
            if (commentPtr == IntPtr.Zero)
                return false;

            // libvorbis's vorbis_comment layout is:
            //   char **user_comments; int *comment_lengths; int comments; char *vendor;
            // Read the fields by raw offset instead of declaring a matching
            // struct type - the exe-injection patcher can only retarget
            // types it already knows (mscorlib types), not new value types
            // introduced by this bridge, so this keeps everything to plain
            // IntPtr/int/string operations it can already clone.
            int ptrSize = IntPtr.Size;
            IntPtr userComments = Marshal.ReadIntPtr(commentPtr, 0);
            int comments = Marshal.ReadInt32(commentPtr, ptrSize * 2);

            bool foundStart = false, foundEnd = false;

            for (int i = 0; i < comments; i++)
            {
                IntPtr strPtr = Marshal.ReadIntPtr(userComments, i * ptrSize);
                if (strPtr == IntPtr.Zero) continue;

                string s = Marshal.PtrToStringAnsi(strPtr);
                if (string.IsNullOrEmpty(s)) continue;

                int eq = s.IndexOf('=');
                if (eq < 0) continue;

                string key = s.Substring(0, eq);
                string val = s.Substring(eq + 1);

                if (string.Equals(key, "LOOPSTART", StringComparison.OrdinalIgnoreCase))
                    foundStart = int.TryParse(val, out loopStart);
                else if (string.Equals(key, "LOOPEND", StringComparison.OrdinalIgnoreCase))
                    foundEnd = int.TryParse(val, out loopEnd);
            }

            return foundStart && foundEnd;
        }

        public static Stream TryConvertOggToWav(Stream input)
        {
            long startPos = input.Position;
            byte[] magic = new byte[4];
            int total = 0;

            while (total < 4)
            {
                int n = input.Read(magic, total, 4 - total);
                if (n <= 0) break;
                total += n;
            }

            bool isOgg = total == 4 &&
                         magic[0] == 0x4F && magic[1] == 0x67 &&
                         magic[2] == 0x67 && magic[3] == 0x53;

            if (!isOgg)
            {
                input.Position = startPos;
                return input;
            }

            string tmp = Path.GetTempFileName();
            try
            {
                // Write the compressed OGG to disk directly. The old bridge
                // built a complete byte[] copy of the OGG first, which was an
                // unnecessary managed-memory spike.
                using (FileStream fs = new FileStream(tmp, FileMode.Create, FileAccess.Write, FileShare.None, 65536))
                {
                    fs.Write(magic, 0, 4);

                    byte[] copyBuf = new byte[65536];
                    int r;
                    while ((r = input.Read(copyBuf, 0, copyBuf.Length)) > 0)
                        fs.Write(copyBuf, 0, r);
                }

                return DecodeOggToWav(tmp);
            }
            catch
            {
                try { File.Delete(tmp); } catch { }
                throw;
            }
        }

        static Stream DecodeOggToWav(string tmp)
        {
            IntPtr vf = Marshal.AllocHGlobal(4096);
            bool opened = false;

            try
            {
                int rc = ov_fopen(tmp, vf);
                if (rc != 0)
                    throw new Exception("OeVorbisBridge: ov_fopen failed with code " + rc);

                opened = true;

                bool hasLoop = TryGetLoopPoints(vf, out int loopStart, out int loopEnd);

                int blockAlign = Channels * (Bits / 8);
                int byteRate = SampleRate * blockAlign;

                // One MemoryStream only. Reserve the WAV header and write
                // decoded PCM directly after it. This removes the old pcm
                // MemoryStream -> ToArray() -> second MemoryStream copy.
                MemoryStream ms = new MemoryStream();
                BinaryWriter w = new BinaryWriter(ms);

                w.Write((byte)'R'); w.Write((byte)'I'); w.Write((byte)'F'); w.Write((byte)'F');
                w.Write((uint)0); // patched after decode
                w.Write((byte)'W'); w.Write((byte)'A'); w.Write((byte)'V'); w.Write((byte)'E');
                w.Write((byte)'f'); w.Write((byte)'m'); w.Write((byte)'t'); w.Write((byte)' ');
                w.Write((uint)16);
                w.Write((ushort)1);
                w.Write((ushort)Channels);
                w.Write((uint)SampleRate);
                w.Write((uint)byteRate);
                w.Write((ushort)blockAlign);
                w.Write((ushort)Bits);

                w.Write((byte)'d'); w.Write((byte)'a'); w.Write((byte)'t'); w.Write((byte)'a');
                long dataSizePos = ms.Position;
                w.Write((uint)0); // patched after decode

                byte[] buf = new byte[16384];
                int bitstream = 0;
                int n;
                long pcmLength = 0;

                // word=2 => signed 16-bit PCM, matching the WAV header above.
                while ((n = ov_read(vf, buf, buf.Length, 0, 2, 1, ref bitstream)) > 0)
                {
                    ms.Write(buf, 0, n);
                    pcmLength += n;
                }

                if (n < 0)
                    throw new Exception("OeVorbisBridge: ov_read failed with code " + n);

                // Re-materialize the loop points sfxpack.py embedded as Vorbis
                // comments, as a standard WAV 'smpl' chunk. OeWaveFileData.
                // FromStream only recognizes 'smpl' in the chunk scan that
                // runs AFTER it has already consumed 'data' - it does not
                // look for 'smpl' between 'fmt ' and 'data' - so this chunk
                // must be appended here, trailing the PCM payload, not
                // inserted before it.
                if (hasLoop)
                {
                    w.Write((byte)'s'); w.Write((byte)'m'); w.Write((byte)'p'); w.Write((byte)'l');
                    w.Write((uint)60); // chunk size: 7*4 header + 4 + 4 + 1*24 loop entry
                    w.Write((uint)0);  // manufacturer
                    w.Write((uint)0);  // product
                    w.Write((uint)(1000000000UL / (uint)SampleRate)); // samplePeriod (ns)
                    w.Write((uint)60); // MIDI unity note (arbitrary, unused by this engine)
                    w.Write((uint)0);  // MIDI pitch fraction
                    w.Write((uint)0);  // SMPTE format
                    w.Write((uint)0);  // SMPTE offset
                    w.Write((uint)1);  // number of sample loops
                    w.Write((uint)0);  // sampler data size
                    w.Write((uint)0);  // loop: cue point ID
                    w.Write((uint)0);  // loop: type (0 = forward)
                    w.Write((int)loopStart);
                    w.Write((int)loopEnd);
                    w.Write((uint)0);  // loop: fraction
                    w.Write((uint)0);  // loop: play count (0 = infinite)
                }

                // Patch RIFF and data sizes in-place.
                w.Flush();
                long riffSize = (dataSizePos + 4 - 8) + pcmLength + (hasLoop ? 68 : 0); // everything after the RIFF size field itself
                ms.Position = 4;
                w.Write((uint)riffSize);
                ms.Position = dataSizePos;
                w.Write((uint)pcmLength);
                w.Flush();
                ms.Position = 0;

                return ms;
            }
            finally
            {
                if (opened)
                {
                    try { ov_clear(vf); } catch { }
                }

                Marshal.FreeHGlobal(vf);
                try { File.Delete(tmp); } catch { }
            }
        }
    }
}
