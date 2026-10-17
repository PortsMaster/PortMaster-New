using System;
using Microsoft.Xna.Framework.Audio;

namespace OrangeEngineR.Audio
{
    // Music-only replacement for the OeSoundEffectInstance/OeSoundEffectInstanceDynamic
    // path. That path is shared with SFX (short one-shot clips are fine to fully
    // decode up front); music tracks can be minutes long, and OeResourceManager
    // caches every distinct OeMusic ever played for the rest of the session, so
    // holding each one's full decoded PCM in RAM indefinitely adds up fast.
    //
    // This decodes from an open libvorbisfile handle a chunk at a time during
    // playback instead. The one wrinkle is the game's rewind mechanic, which
    // plays music backward sample-by-sample - Vorbis can only decode forward,
    // so a ring buffer keeps a rolling window of recently-decoded PCM well past
    // the rewind cap (OeGameState caps remaining rewind at 300 frames), so
    // reverse playback always finds its samples already buffered and only
    // forward playback ever touches disk.
    public sealed class OeMusicStreamInstance
    {
        const int Channels = 1;
        const int SampleRate = 22050;
        const int BlockAlign = Channels * 2; // 16-bit

        // 24s of headroom versus a ~5s (300 frame) max rewind. ~1MB total,
        // versus multiple MB (or tens of MB for long tracks) fully resident.
        const int RingSeconds = 24;
        const long RingSamples = SampleRate * RingSeconds;
        const int RingBytes = SampleRate * RingSeconds * BlockAlign;

        IntPtr _vf;
        byte[] _ring;
        byte[] _readTmp;
        byte[] _mBuffer;
        DynamicSoundEffectInstance _mInstance;

        long _writeVirtual;   // monotonic count of samples ever decoded into the ring
        long _currentSample;  // current playback position, same monotonic axis
        bool _reachedEnd;     // true once decode hit true EOF and IsLooped is false
        bool _hasLoop;
        int _loopStartSample; // file-native PCM sample index to seek back to
        int _bitstream;

        bool _isSetup;
        bool _isLooped;

        public bool Setup(string name, string filePath)
        {
            CloseFile();

            if (string.IsNullOrEmpty(filePath))
                return false;

            _vf = OeVorbisBridge.OpenStream(filePath);

            int unusedLoopEnd;
            _hasLoop = OeVorbisBridge.TryGetLoopPoints(_vf, out _loopStartSample, out unusedLoopEnd);

            _writeVirtual = 0;
            _currentSample = 0;
            _reachedEnd = false;
            _bitstream = 0;

            if (_ring == null)
                _ring = new byte[RingBytes];
            if (_readTmp == null)
                _readTmp = new byte[4096 * BlockAlign];

            if (_mInstance == null)
            {
                _mInstance = new DynamicSoundEffectInstance(SampleRate, AudioChannels.Mono);
                // ~50ms per submission, matching the existing dynamic
                // instance's own buffer-sizing convention (bytesPerSec/20).
                _mBuffer = new byte[(SampleRate * BlockAlign) / 20];
            }
            else
            {
                _mInstance.Stop();
            }

            _isSetup = true;
            Console.WriteLine("[OeMusicStream] opened " + filePath + (_hasLoop ? " (loop start sample " + _loopStartSample + ")" : " (no loop points)"));
            return true;
        }

        void CloseFile()
        {
            if (_vf != IntPtr.Zero)
            {
                OeVorbisBridge.CloseStream(_vf);
                _vf = IntPtr.Zero;
            }
        }

        // Decodes forward until at least `uptoExclusive` samples have been
        // written into the ring, looping the underlying file (via ov_pcm_seek)
        // on natural EOF when IsLooped is set, matching the original engine's
        // own loop trigger (physical end of the decoded data -> loop start;
        // the WAV 'smpl' chunk's loop-end field was written but never
        // actually read by playback).
        //
        // This runs on the game's main thread, so it must ALWAYS terminate.
        // The original engine looped by assigning an array index, which cannot
        // fail; here a bad loop point (past the end of the file), an empty
        // stream, or a decode error would otherwise make ov_read return <= 0
        // forever and spin here. So every retry path is bounded:
        //   - a loop seek that fails falls back to rewinding to sample 0,
        //   - two consecutive loop seeks that produce no PCM mean "give up",
        //   - OV_HOLE (a recoverable gap) is retried a few times only,
        //   - any other negative code is treated like EOF.
        // "Give up" sets _reachedEnd, i.e. the track goes silent instead of
        // freezing the game.
        const int OvHole = -3;

        void EnsureDecoded(long uptoExclusive)
        {
            if (_reachedEnd) return;

            int seeksWithoutData = 0;
            int holes = 0;

            while (_writeVirtual < uptoExclusive)
            {
                int n = OeVorbisBridge.ReadPcm(_vf, _readTmp, _readTmp.Length, ref _bitstream);

                if (n > 0)
                {
                    seeksWithoutData = 0;
                    holes = 0;

                    int gotSamples = n / BlockAlign;
                    for (int i = 0; i < gotSamples; i++)
                    {
                        long ringIdx = _writeVirtual % RingSamples;
                        Buffer.BlockCopy(_readTmp, i * BlockAlign, _ring, (int)(ringIdx * BlockAlign), BlockAlign);
                        _writeVirtual++;
                    }
                    continue;
                }

                if (n == OvHole && holes < 8)
                {
                    holes++;
                    continue;
                }

                // n == 0 (EOF) or an unrecoverable decode error.
                if (_isLooped && seeksWithoutData < 2)
                {
                    long target = (seeksWithoutData == 0 && _hasLoop) ? _loopStartSample : 0;
                    int rc = OeVorbisBridge.SeekPcm(_vf, target);
                    if (rc != 0 && target != 0)
                    {
                        Console.WriteLine("[OeMusicStream] loop point " + target + " is not seekable (code " + rc + "), looping from the start instead");
                        rc = OeVorbisBridge.SeekPcm(_vf, 0);
                    }
                    if (rc != 0)
                    {
                        Console.WriteLine("[OeMusicStream] could not rewind stream (code " + rc + "), stopping this track's audio");
                        _reachedEnd = true;
                        return;
                    }
                    _bitstream = 0;
                    seeksWithoutData++;
                    continue;
                }

                if (_isLooped)
                    Console.WriteLine("[OeMusicStream] stream produced no audio after rewinding (read code " + n + "), stopping this track's audio");

                _reachedEnd = true;
                return;
            }
        }

        void FillBuffer(bool isReverse, int amountOfSamples)
        {
            int written = 0;
            for (int i = 0; i < amountOfSamples; i++)
            {
                if (isReverse)
                {
                    if (_currentSample <= 0) break;
                    _currentSample--;
                }
                else
                {
                    EnsureDecoded(_currentSample + 1);
                    if (_currentSample >= _writeVirtual) break;
                }

                long ringIdx = _currentSample % RingSamples;
                Buffer.BlockCopy(_ring, (int)(ringIdx * BlockAlign), _mBuffer, written * BlockAlign, BlockAlign);
                written++;

                if (!isReverse)
                    _currentSample++;
            }

            if (written > 0)
                _mInstance.SubmitBuffer(_mBuffer, 0, written * BlockAlign);
        }

        public void Update(bool isReversing)
        {
            if (!_isSetup) return;
            if (State != SoundState.Playing) return;

            if (isReversing && _currentSample <= 0)
            {
                Stop();
                return;
            }
            if (!isReversing && !_isLooped && _reachedEnd && _currentSample >= _writeVirtual)
            {
                Stop();
                return;
            }

            if (_mInstance.PendingBufferCount > 2) return;

            FillBuffer(isReversing, _mBuffer.Length / BlockAlign);
        }

        // True between a successful Setup() and the next Stop(). This is the
        // streaming equivalent of OeSoundEffectInstance._mIsSetup, whose guard
        // sat at the very top of the original Update(bool). OeMusicInstance.Update
        // now checks it BEFORE it touches any game state (see CecilPatcher2.cs,
        // "UpdateStreamInstance"), because OeMusic.Tick() is pumped every frame by
        // OeGameLoader during loading, long before OeGameStateManager.GameStates
        // has been allocated.
        public bool IsSetup
        {
            get { return _isSetup; }
        }

        public SoundState State
        {
            get
            {
                if (!_isSetup || _mInstance == null) return SoundState.Stopped;
                return _mInstance.State;
            }
        }

        public void Play()
        {
            if (_isSetup) _mInstance.Play();
        }

        public void Pause()
        {
            if (_isSetup) _mInstance.Pause();
        }

        public void Resume()
        {
            if (_isSetup && _mInstance.State == SoundState.Paused)
                _mInstance.Resume();
        }

        public void Stop()
        {
            if (_mInstance != null) _mInstance.Stop();
            CloseFile();
            _isSetup = false;
        }

        public float Volume
        {
            get { return _isSetup ? _mInstance.Volume : 0f; }
            set { if (_isSetup) _mInstance.Volume = value; }
        }

        public bool IsLooped
        {
            get { return _isLooped; }
            set { _isLooped = value; }
        }

        public OeMusicStreamInstance() { }
    }
}
