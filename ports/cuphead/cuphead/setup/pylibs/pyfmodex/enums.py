"""Fmod API enumeration types."""
from enum import Enum, IntEnum

# pylint: disable=invalid-name
# Just staying close to the original names here.


class CHANNELCONTROL_CALLBACK_TYPE(Enum):
    """Types of callbacks called by Channels and ChannelGroups."""

    #: Called when a sound ends. Supported by
    #: :py:class:`~pyfmodex.channel.Channel` only.
    END = 0

    #: Called when a :py:class:`~pyfmodex.channel.Channel` is made virtual or
    #: real. Supported by :py:class:`~pyfmodex.channel.Channel` objects only.
    VIRTUALVOICE = 1

    #: Called when a syncpoint is encountered. Can be from wav file markers or
    #: user added.Called when a syncpoint is encountered. Can be from wav file
    #: markers or user added. Supported by
    #: :py:class:`~pyfmodex.channel.Channel` objects only.
    SYNCPOINT = 2

    #: Called when geometry occlusion values are calculated. Can be used to
    #: clamp or change the value. Supported by
    #: :py:class:`~pyfmodex.channel.Channel` and
    #: :py:class:`~pyfmodex.channel_group.ChannelGroup`
    OCCLUSION = 3

    #: Maximum number of callback types supported.
    MAX = 4


class CHANNELCONTROL_DSP_INDEX(IntEnum):
    """References to built in DSP positions that reside in a Channel or
    ChannelGroup DSP chain.
    """

    #: Head of the DSP chain, equivalent of index 0.
    HEAD = -1

    #: Built in fader DSP.
    FADER = -2

    #: Tail of the DSP chain, equivalent of the number of DSPs minus 1.
    TAIL = -3


class CHANNELCONTROL_TYPE(Enum):
    """Identifier used to distinguish between Channel and ChannelGroup in the
    ChannelControl callback.
    """

    #: Type representing :py:class:`~pyfmodex.channel.Channel`
    CHANNEL = 0

    #: Type representing :py:class:`~pyfmodex.channel_group.ChannelGroup`
    CHANNELGROUP = 1

    #: Maximum number of channel control types.
    MAX = 2


class CHANNELORDER(Enum):
    """Speaker ordering for multichannel signals."""

    #: Left, Right, Center, LFE, Surround Left, Surround Right, Back Left, Back
    #: Right
    DEFAULT = 0

    #: Left, Right, Center, LFE, Back Left, Back Right, Surround Left, Surround
    #: Right (as per Microsoft .wav WAVEFORMAT structure master order)
    WAVEFORMAT = 1

    #: Left, Center, Right, Surround Left, Surround Right, LFE
    PROTOOLS = 2

    #: Mono, Mono, Mono, Mono, Mono, Mono, ... (each channel up to
    #: :py:const:`~pyfmodex.constants.MAX_CHANNEL_WIDTH` treated as mono)
    ALLMONO = 3

    #: Left, Right, Left, Right, Left, Right, ... (each pair of channels up to
    #: :py:const:`~pyfmodex.constants.MAX_CHANNEL_WIDTH` treated as stereo)
    ALLSTEREO = 4

    #: Left, Right, Surround Left, Surround Right, Center, LFE (as per Linux
    #: ALSA channel order)
    ALSA = 5

    #: Maximum number of channel orderings supported.
    MAX = 6


class DEBUG_MODE(Enum):
    """Specify the destination of log output when using the logging version of
    FMOD."""

    #: Default log location per platform.
    #:
    #: TTY destination can vary depending on platform, common examples include
    #: the Visual Studio / Xcode output window, stderr and LogCat.
    TTY = 0

    #: Write log to specified file path.
    FILE = 1

    #: Call specified callback with log information.
    CALLBACK = 2


class DSPCONNECTION_TYPE(Enum):
    """List of connection types between two DSP nodes."""

    #: Default :py:class:`~pyfmodex.dsp_connection.DSPConnection` type. Audio
    #: is mixed from the input to the output :py:class:`DSP's
    #: <pyfmodex.dsp.DSP>` audible buffer. A standard connection will execute
    #: its input :py:class:`~pyfmodex.dsp.DSP` if it has not been executed
    #: before.
    STANDARD = 0

    #: Sidechain :py:class:`~pyfmodex.dsp_connection.DSPConnection` type. Audio
    #: is mixed from the input to the output :py:class:`DSP's
    #: <pyfmodex.dsp.DSP>` sidechain buffer, meaning it will NOT be part of the
    #: audible signal. A sidechain connection will execute its input
    #: :py:class:`~pyfmodex.dsp.DSP` if it has not been executed before.
    #:
    #: The purpose of the seperate sidechain buffer in a
    #: :py:class:`~pyfmodex.dsp.DSP`, is so that the
    #: :py:class:`~pyfmodex.dsp.DSP` effect can be privately accessed for
    #: analysis purposes. An example of use in this case, could be a compressor
    #: which analyzes the signal, to control its own effect parameters (i.e. a
    #: compression level or gain).
    #:
    #: For the effect developer, to accept sidechain data, the sidechain data
    #: will appear in the
    #: :py:class:`~pyfmodex.structure_declarations.DSP_STATE` struct which is
    #: passed into the read callback of a :py:class:`~pyfmodex.dsp.DSP` unit.
    #:
    #: :py:attr:`~pyfmodex.structure_declarations.DSP_STATE.sidechaindata` and
    #: :py:attr:`~pyfmodex.structure_declarations.DSP_STATE.sidechainchannels`
    #: in will hold the mixed result of any sidechain data flowing into it.
    SIDECHAIN = 1

    #: Send connection type. Audio is mixed from the input to the output
    #: :py:class:`DSP's <pyfmodex.dsp.DSP>` audible buffer, meaning it will be
    #: part of the audible signal. A send connection will NOT execute its input
    #: :py:class:`~pyfmodex.dsp.DSP` if it has not been executed before.
    #:
    #: A send connection will only read what exists at the input's buffer at
    #: the time of executing the output :py:class:`~pyfmodex.dsp.DSP` unit
    #: (which can be considered the 'return')
    SEND = 2

    #: Send sidechain :py:class:`~pyfmodex.dsp_connection.DSPConnection` type.
    #: Audio is mixed from the input to the output :py:class:`DSP's
    #: <pyfmodex.dsp.DSP>` sidechain buffer, meaning it will NOT be part of the
    #: audible signal. A send sidechain connection will NOT execute its input DSP
    #: if it has not been executed before.
    #:
    #: A send sidechain connection will only read what exists at the input's
    #: buffer at the time of executing the output :py:class:`~pyfmodex.dsp.DSP`
    #: unit (which can be considered the 'sidechain return')
    #:
    #: For the effect developer, to accept sidechain data, the sidechain data
    #: will appear in the
    #: :py:class:`~pyfmodex.structure_declarations.DSP_STATE` struct which is
    #: passed into the read callback of a :py:class:`~pyfmodex.dsp.DSP` unit.
    #:
    #: :py:attr:`~pyfmodex.structure_declarations.DSP_STATE.sidechaindata` and
    #: :py:attr:`~pyfmodex.structure_declarations.DSP_STATE.sidechainchannels`
    #: in will hold the mixed result of any sidechain data flowing into it.
    SEND_SIDECHAIN = 3

    #: Maximum number of :py:class:`~pyfmodex.dsp.DSP` connection types
    #: supported.
    MAX = 4


class DSP_CHANNELMIX(Enum):
    """Channel Mix DSP parameter types."""

    #: Channel mix output grouping.
    #:
    #: This value will set the output speaker format for the DSP which
    #: determines the number of output channels.
    #:
    #: For input channels mapped to an output channel in excess of the number
    #: of output channels, it will instead be mapped to the modulo of that
    #: channel index. E.g. if there are 4 output channels, the input channel
    #: mapped to output channel index 5 will be mapped to index 1.
    OUTPUTGROUPING = 0

    GAIN_CH0 = 1  #: Channel #1 gain.
    GAIN_CH1 = 2  #: Channel #2 gain.
    GAIN_CH2 = 3  #: Channel #3 gain.
    GAIN_CH3 = 4  #: Channel #4 gain.
    GAIN_CH4 = 5  #: Channel #5 gain.
    GAIN_CH5 = 6  #: Channel #6 gain.
    GAIN_CH6 = 7  #: Channel #7 gain.
    GAIN_CH7 = 8  #: Channel #8 gain.
    GAIN_CH8 = 9  #: Channel #9 gain.
    GAIN_CH9 = 10  #: Channel #10 gain.
    GAIN_CH10 = 11  #: Channel #11 gain.
    GAIN_CH11 = 12  #: Channel #12 gain.
    GAIN_CH12 = 13  #: Channel #13 gain.
    GAIN_CH13 = 14  #: Channel #14 gain.
    GAIN_CH14 = 15  #: Channel #15 gain.
    GAIN_CH15 = 16  #: Channel #16 gain.
    GAIN_CH16 = 17  #: Channel #17 gain.
    GAIN_CH17 = 18  #: Channel #18 gain.
    GAIN_CH18 = 19  #: Channel #19 gain.
    GAIN_CH19 = 20  #: Channel #20 gain.
    GAIN_CH20 = 21  #: Channel #21 gain.
    GAIN_CH21 = 22  #: Channel #22 gain.
    GAIN_CH22 = 23  #: Channel #23 gain.
    GAIN_CH23 = 24  #: Channel #24 gain.
    GAIN_CH24 = 25  #: Channel #25 gain.
    GAIN_CH25 = 26  #: Channel #26 gain.
    GAIN_CH26 = 27  #: Channel #27 gain.
    GAIN_CH27 = 28  #: Channel #28 gain.
    GAIN_CH28 = 29  #: Channel #29 gain.
    GAIN_CH29 = 30  #: Channel #30 gain.
    GAIN_CH30 = 31  #: Channel #31 gain.
    OUTPUT_CH0 = 33  #: Output channel for Input channel #0.
    OUTPUT_CH1 = 34  #: Output channel for Input channel #1.
    OUTPUT_CH2 = 35  #: Output channel for Input channel #2.
    OUTPUT_CH3 = 36  #: Output channel for Input channel #3.
    OUTPUT_CH4 = 37  #: Output channel for Input channel #4.
    OUTPUT_CH5 = 38  #: Output channel for Input channel #5.
    OUTPUT_CH6 = 39  #: Output channel for Input channel #6.
    OUTPUT_CH7 = 40  #: Output channel for Input channel #7.
    OUTPUT_CH8 = 41  #: Output channel for Input channel #8.
    OUTPUT_CH9 = 42  #: Output channel for Input channel #9.
    OUTPUT_CH10 = 43  #: Output channel for Input channel #10.
    OUTPUT_CH11 = 44  #: Output channel for Input channel #11.
    OUTPUT_CH12 = 45  #: Output channel for Input channel #12.
    OUTPUT_CH13 = 46  #: Output channel for Input channel #13.
    OUTPUT_CH14 = 47  #: Output channel for Input channel #14.
    OUTPUT_CH15 = 48  #: Output channel for Input channel #15.
    OUTPUT_CH16 = 49  #: Output channel for Input channel #16.
    OUTPUT_CH17 = 50  #: Output channel for Input channel #17.
    OUTPUT_CH18 = 51  #: Output channel for Input channel #18.
    OUTPUT_CH19 = 52  #: Output channel for Input channel #19.
    OUTPUT_CH20 = 53  #: Output channel for Input channel #20.
    OUTPUT_CH21 = 54  #: Output channel for Input channel #21.
    OUTPUT_CH22 = 55  #: Output channel for Input channel #22.
    OUTPUT_CH23 = 56  #: Output channel for Input channel #23.
    OUTPUT_CH24 = 57  #: Output channel for Input channel #24.
    OUTPUT_CH25 = 58  #: Output channel for Input channel #25.
    OUTPUT_CH26 = 59  #: Output channel for Input channel #26.
    OUTPUT_CH27 = 60  #: Output channel for Input channel #27.
    OUTPUT_CH28 = 61  #: Output channel for Input channel #28.
    OUTPUT_CH29 = 62  #: Output channel for Input channel #29.
    OUTPUT_CH30 = 63  #: Output channel for Input channel #30.
    OUTPUT_CH31 = 64  #: Output channel for Input channel #31.


class DSP_CHANNELMIX_OUTPUT(Enum):
    """Channel Mix DSP outgrouping parameter types."""

    #: Output channel count = input channel count. Mapping: See
    #: :py:class:`SPEAKER` enumeration
    DEFAULT = 0

    #: Output channel count = 1. Mapping: Mono, Mono, Mono, Mono, Mono, Mono,
    #: ... (each channel all the way up to
    #: :py:const:`~pyfmodex.constants.MAX_CHANNEL_WIDTH` channels are treated
    #: as if they were mono)
    ALLMONO = 1

    #: Output channel count = 2. Mapping: Left, Right, Left, Right, Left,
    #: Right, ... (each pair of channels is treated as stereo all the way up to
    #: :py:const:`~pyfmodex.constants.MAX_CHANNEL_WIDTH` channels)
    ALLSTEREO = 2

    #: Output channel count = 4. Mapping: Repeating pattern of Front Left,
    #: Front Right, Surround Left, Surround Right.
    ALLQUAD = 3

    #: Output channel count = 6. Mapping: Repeating pattern of Front Left,
    #: Front Right, Center, LFE, Surround Left, Surround Right.
    ALL5POINT1 = 4

    #: Output channel count = 8. Mapping: Repeating pattern of Front Left,
    #: Front Right, Center, LFE, Surround Left, Surround Right, Back Left, Back
    #: Right.
    ALL7POINT1 = 5

    #: Output channel count = 6. Mapping: Repeating pattern of LFE in a 5.1
    #: output signal.
    ALLLFE = 6


class DSP_CHORUS(IntEnum):
    """Chorus DSP parameter types.

    Chorus is an effect where the sound is more 'spacious' due to 1 to 3
    versions of the sound being played along side the original signal but with
    the pitch of each copy modulating on a sine wave.
    """

    MIX = 0  #: Volume of original signal to pass to output.
    RATE = 1  #: Chorus modulation rate.
    DEPTH = 2  #: Chorus modulation depth.


class DSP_COMPRESSOR(IntEnum):
    """Compressor DSP parameter types.

    This is a multichannel software limiter that is uniform across the whole spectrum.

    The limiter is not guaranteed to catch every peak above the threshold
    level, because it cannot apply gain reduction instantaneously - the time
    delay is determined by the attack time. However setting the attack time too
    short will distort the sound, so it is a compromise. High level peaks can
    be avoided by using a short attack time - but not too short, and setting
    the threshold a few decibels below the critical level.
    """

    THRESHOLD = 0  #: Threshold level.
    RATIO = 1  #: Compression Ratio.
    ATTACK = 2  #: Attack time.
    RELEASE = 3  #: Release time.
    GAINMAKEUP = 4  #: Make-up gain applied after limiting.

    #: Whether to analyse the sidechain signal instead of the input signal.
    #: Default is False.
    USESIDECHAIN = 5

    #: - False: Independent (compressor per channel).
    #: - True: Linked.
    LINKED = 6


class DSP_CONVOLUTION_REVERB(IntEnum):
    """Convolution reverb DSP parameter types."""

    #: Array of signed 16-bit (short) PCM data to be used as reverb IR. First
    #: member of the array should be a 16 bit value (short) which specifies the
    #: number of channels. Array looks like [index 0=numchannels][index 1+ =
    #: raw 16 bit PCM data]. Data is copied internally so source can be freed.
    PARAM_IR = 0

    PARAM_WET = 1  #: Volume of echo signal to pass to output.
    PARAM_DRY = 2  #: Original sound volume.

    #: Linked - channels are mixed together before processing through the
    #: reverb.
    PARAM_LINKED = 3


class DSP_DELAY(IntEnum):
    """Delay DSP parameter types."""

    CH0 = 0  #: Channel #0 Delay.
    CH1 = 1  #: Channel #1 Delay.
    CH2 = 2  #: Channel #2 Delay.
    CH3 = 3  #: Channel #3 Delay.
    CH4 = 4  #: Channel #4 Delay.
    CH5 = 5  #: Channel #5 Delay.
    CH6 = 6  #: Channel #6 Delay.
    CH7 = 7  #: Channel #7 Delay.
    CH8 = 8  #: Channel #8 Delay.
    CH9 = 9  #: Channel #9 Delay.
    CH10 = 10  #: Channel #10 Delay.
    CH11 = 11  #: Channel #11 Delay.
    CH12 = 12  #: Channel #12 Delay.
    CH13 = 13  #: Channel #13 Delay.
    CH14 = 14  #: Channel #14 Delay.
    CH15 = 15  #: Channel #15 Delay.

    #: Maximum delay.
    #:
    #: Every time MaxDelay is changed, the plugin re-allocates the delay
    #: buffer. This means the delay will dissapear at that time while it
    #: refills its new buffer. A larger MaxDelay results in larger amounts of
    #: memory allocated.
    #:
    #: Channel delays above MaxDelay will be clipped to MaxDelay and the delay
    #: buffer will not be resized.
    MAXDELAY = 16


class DSP_DISTORTION(IntEnum):
    """Distortion DSP parameter types."""

    LEVEL = 0  #: Distortion value.


class DSP_ECHO(IntEnum):
    """Echo DSP parameter types."""

    #: Echo delay.
    #:
    #: Every time the delay is changed, the plugin re-allocates the echo
    #: buffer. This means the echo will dissapear at that time while it refills
    #: its new buffer. Larger echo delays result in larger amounts of memory
    #: allocated.
    DELAY = 0

    FEEDBACK = 1  #: Echo decay per delay. 100.0 = No decay, 0.0 = total decay.
    DRYLEVEL = 2  #: Original sound volume.
    WETLEVEL = 3  #: Volume of echo signal to pass to output.


class DSP_ENVELOPEFOLLOWER(IntEnum):
    """This is a simple envelope follower for tracking the signal level. This
    unit does not affect the incoming signal.

    Deprecated and will be removed in a future release.
    """

    ATTACK = 0  #: Attack time.
    RELEASE = 1  #: Release time.
    ENVELOPE = 2  #: Current value of the envelope.

    #: Whether to analyse the sidechain signal instead of the input signal.
    USESIDECHAIN = 3


class DSP_FADER(IntEnum):
    """Fader DSP parameter types."""

    GAIN = 0  #: Signal gain.

    #: Overall gain to allow FMOD to know the DSP is scaling the signal for
    #: visualization purposes.
    OVERALL_GAIN = 1


class DSP_FFT(IntEnum):
    """FFT DSP parameter types."""

    WINDOWSIZE = 0  #: Window size. Must be a power of 2 between 128 and 16384.
    WINDOWTYPE = 1  #: FFT Window Type.

    #: The current spectrum values between 0 and 1 for each 'fft bin'. Divide
    #: the Nyquist frequency by the window size to get the Hz value per entry.
    SPECTRUMDATA = 2

    DOMINANT_FREQ = 3  #: The dominant frequencies for each channel.


class DSP_FFT_WINDOW(IntEnum):
    """List of windowing methods for the FFT DSP.

    Used in spectrum analysis to reduce leakage / transient signals interfering
    with the analysis. This is a problem with analysis of continuous signals
    that only have a small portion of the signal sample (the fft window size).
    Windowing the signal with a curve or triangle tapers the sides of the fft
    window to help alleviate this problem.

    Cyclic signals such as a sine wave that repeat their cycle in a multiple of
    the window size do not need windowing. I.e. If the sine wave repeats every
    1024, 512, 256 etc samples and the FMOD fft window is 1024, then the signal
    would not need windowing.

    Not windowing is the same as :py:attr:`RECT`, which is the default. If the
    cycle of the signal (ie the sine wave) is not a multiple of the window
    size, it will cause frequency abnormalities, so a different windowing
    method is needed.
    """

    RECT = 0  #: w[n] = 1.0
    TRIANGLE = 1  #: w[n] = TRI(2n/N)
    HAMMING = 2  #: w[n] = 0.54 - (0.46 * COS(n/N) )
    HANNING = 3  #: w[n] = 0.5 * (1.0 - COS(n/N) )
    BLACKMAN = 4  #: w[n] = 0.42 - (0.5 * COS(n/N) ) + (0.08 * COS(2.0 * n/N) )

    #: w[n] = 0.35875 - (0.48829 * COS(1.0 * n/N)) + (0.14128 * COS(2.0 * n/N))
    #: - (0.01168 * COS(3.0 * n/N))
    BLACKMANHARRIS = 5


class DSP_FLANGE(IntEnum):
    """Flange DSP parameter types.

    Flange is an effect where the signal is played twice at the same time, and
    one copy slides back and forth creating a whooshing or flanging effect. As
    there are two  copies of the same signal, by default each signal is given
    50% mix, so that the total is not louder than the original unaffected
    signal.

    Flange depth is a percentage of a 10ms shift from the original signal.
    Anything above 10ms is not considered flange because to the ear it begins
    to 'echo' so 10ms is the highest value possible.
    """

    MIX = 0  #: Percentage of wet signal in mix.
    DEPTH = 1  #: Flange depth.
    RATE = 2  #: Flange speed.


class DSP_HIGHPASS(IntEnum):
    """Highpass DSP parameter types.

    Deprecated and will be removed in a future release, to emulate with
    :py:class:`DSP_MULTIBAND_EQ`.
    """

    CUTOFF = 0  #: Highpass cutoff frequency.
    RESONANCE = 1  #: Highpass resonance Q value.


class DSP_HIGHPASS_SIMPLE(IntEnum):
    """Simple Highpass DSP parameter types.

    This is a very simple single-order high pass filter. The emphasis is on
    speed rather than accuracy, so this should not be used for task requiring
    critical filtering.

    Deprecated and will be removed in a future release, to emulate with
    :py:class:`DSP_MULTIBAND_EQ`.
    """

    CUTOFF = 0  #: Highpass cutoff frequency.


class DSP_ITECHO(IntEnum):
    """IT Echo DSP parameter types.

    This is effectively a software based echo filter that emulates the DirectX
    DMO echo effect. Impulse tracker files can support this, and FMOD will
    produce the effect on ANY platform, not just those that support DirectX
    effects!

    Every time the delay is changed, the plugin re-allocates the echo buffer.
    This means the echo will dissapear at that time while it refills its new
    buffer. Larger echo delays result in larger amounts of memory allocated.

    As this is a stereo filter made mainly for IT playback, it is targeted for
    stereo signals. With mono signals only the :py:attr:`LEFTDELAY` is used.
    For multichannel signals (>2) there will be no echo on those channels.
    """

    #: Ratio of wet (processed) signal to dry (unprocessed) signal.
    WETDRYMIX = 0

    #: Percentage of output fed back into input.
    FEEDBACK = 1

    #: Delay for left channel.
    LEFTDELAY = 2

    #: Delay for right channel.
    RIGHTDELAY = 3

    #: Value that specifies whether to swap left and right delays with each
    #: successive echo. CURRENTLY NOT SUPPORTED.
    PANDELAY = 4


class DSP_ITLOWPASS(IntEnum):
    """Lowpass DSP parameter types.

    FMOD Studio's .IT playback uses this filter.

    This is different to the default :py:attr:`DSP_TYPE.ITLOWPASS` filter in
    that it uses a different quality algorithm and is the filter used to
    produce the correct sounding playback in .IT files.

    This filter actually has a limited cutoff frequency below the specified
    maximum, due to its limited design, so for a more open range filter use
    :py:class:`DSP_LOWPASS` or if you don't mind not having resonance,
    :py:class:`DSP_LOWPASS_SIMPLE`.

    The effective maximum cutoff is about 8060hz.
    """

    CUTOFF = 0  #: Lowpass cutoff frequency.
    RESONANCE = 1  #: Lowpass resonance Q value.


class DSP_LIMITER(IntEnum):
    """Limited DSP parameter types."""

    RELEASETIME = 0  #: Time to ramp the silence to full.
    CEILING = 1  #: Maximum level of the output signal.
    MAXIMIZERGAIN = 2  #: Maximum amplification allowed.

    #: Channel processing mode where False is Independent (limiter per channel)
    #: and True is Linked.
    MODE = 3


class DSP_LOWPASS(IntEnum):
    """Lowpass DSP parameter types.

    Deprecated and will be removed in a future release, to emulate with
    :py:class:`DSP_MULTIBAND_EQ`.
    """

    CUTOFF = 0  #: Lowpass cutoff frequency.
    RESONANCE = 1  #: Lowpass resonance Q value.


class DSP_LOWPASS_SIMPLE(IntEnum):
    """Simple Lowpass DSP Parameter types.

    This is a very simple low pass filter, based on two single-pole RC
    time-constant modules.

    The emphasis is on speed rather than accuracy, so this should not be used
    for task requiring critical filtering.

    Deprecated and will be removed in a future release, to emulate with
    :py:class:`DSP_MULTIBAND_EQ`.
    """

    CUTOFF = 0  #: Lowpass cutoff frequency.


class DSP_MULTIBAND_EQ(IntEnum):
    """Multiband EQ DSP parameter types.

    Flexible five band parametric equalizer.
    """

    #: Band A: used to interpret the behavior of the remaining parameters.
    A_FILTER = 0

    #: Band A: Significant frequency, cutoff [low/high pass, low/high shelf],
    #: center [notch, peaking, band-pass], phase transition point [all-pass].
    A_FREQUENCY = 1

    #: Band A: Quality factor, resonance [low/high pass], bandwidth [notch,
    #: peaking, band-pass], phase transition sharpness [all-pass], unused
    #: [low/high shelf].
    A_Q = 2

    #: Band A: Boost or attenuation in dB [peaking, high/low shelf only]. -30
    #: to 30. Default = 0.
    A_GAIN = 3

    #: Band B: used to interpret the behavior of the remaining parameters.
    B_FILTER = 4

    #: Band B: Significant frequency, cutoff [low/high pass, low/high shelf],
    #: center [notch, peaking, band-pass], phase transition point [all-pass].
    B_FREQUENCY = 5

    #: Band B: Quality factor, resonance [low/high pass], bandwidth [notch,
    #: peaking, band-pass], phase transition sharpness [all-pass], unused
    #: [low/high shelf].
    B_Q = 6

    #: Band B: Boost or attenuation in dB [peaking, high/low shelf only]. -30
    #: to 30. Default = 0.
    B_GAIN = 7

    #: Band C: used to interpret the behavior of the remaining parameters.
    C_FILTER = 8

    #: Band C: Significant frequency, cutoff [low/high pass, low/high shelf],
    #: center [notch, peaking, band-pass], phase transition point [all-pass].
    C_FREQUENCY = 9

    #: Band C: Quality factor, resonance [low/high pass], bandwidth [notch,
    #: peaking, band-pass], phase transition sharpness [all-pass], unused
    #: [low/high shelf].
    C_Q = 10

    #: Band C: Boost or attenuation in dB [peaking, high/low shelf only]. -30
    #: to 30. Default = 0.
    C_GAIN = 11

    #: Band D: used to interpret the behavior of the remaining parameters.
    D_FILTER = 12

    #: Band D: Significant frequency, cutoff [low/high pass, low/high shelf],
    #: center [notch, peaking, band-pass], phase transition point [all-pass].
    D_FREQUENCY = 13

    #: Band D: Quality factor, resonance [low/high pass], bandwidth [notch,
    #: peaking, band-pass], phase transition sharpness [all-pass], unused
    #: [low/high shelf].
    D_Q = 14

    #: Band D: Boost or attenuation in dB [peaking, high/low shelf only]. -30
    #: to 30. Default = 0.
    D_GAIN = 15

    #: Band E: used to interpret the behavior of the remaining parameters.
    E_FILTER = 16

    #: Band E: Significant frequency, cutoff [low/high pass, low/high shelf],
    #: center [notch, peaking, band-pass], phase transition point [all-pass].
    E_FREQUENCY = 17

    #: Band E: Quality factor, resonance [low/high pass], bandwidth [notch,
    #: peaking, band-pass], phase transition sharpness [all-pass], unused
    #: [low/high shelf].
    E_Q = 18

    #: Band E: Boost or attenuation in dB [peaking, high/low shelf only]. -30
    #: to 30. Default = 0.
    E_GAIN = 19


class DSP_MULTIBAND_EQ_FILTER_TYPE(IntEnum):
    """Multiband EQ Filter types."""

    #: Disabled filter, no processing.
    DISABLED = 0

    #: Resonant low-pass filter, attenuates frequencies (12dB per octave) above
    #: a given point (with specificed resonance) while allowing the rest to pass.
    LOWPASS_12DB = 1

    #: Resonant low-pass filter, attenuates frequencies (24dB per octave) above
    #: a given point (with specificed resonance) while allowing the rest to pass.
    LOWPASS_24DB = 2

    #: Resonant low-pass filter, attenuates frequencies (48dB per octave) above
    #: a given point (with specificed resonance) while allowing the rest to pass.
    LOWPASS_48DB = 3

    #: Resonant high-pass filter, attenuates frequencies (12dB per octave)
    #: below a given point (with specificed resonance) while allowing the rest to
    #: pass.
    HIGHPASS_12DB = 4

    #: Resonant high-pass filter, attenuates frequencies (24dB per octave)
    #: below a given point (with specificed resonance) while allowing the rest to
    #: pass.
    HIGHPASS_24DB = 5

    #: Resonant high-pass filter, attenuates frequencies (48dB per octave)
    #: below a given point (with specificed resonance) while allowing the rest to
    #: pass.
    HIGHPASS_48DB = 6

    #: Low-shelf filter, boosts or attenuates frequencies (with specified gain)
    #: below a given point while allowing the rest to pass.
    LOWSHELF = 7

    #: High-shelf filter, boosts or attenuates frequencies (with specified
    #: gain) above a given point while allowing the rest to pass.
    HIGHSHELF = 8

    #: Peaking filter, boosts or attenuates frequencies (with specified gain)
    #: at a given point (with specificed bandwidth) while allowing the rest to
    #: pass.
    PEAKING = 9

    #: Band-pass filter, allows frequencies at a given point (with specificed
    #: bandwidth) to pass while attenuating frequencies outside this range.
    BANDPASS = 10

    #: Notch or band-reject filter, attenuates frequencies at a given point
    #: (with specificed bandwidth) while allowing frequencies outside this range
    #: to pass.
    NOTCH = 11

    #: All-pass filter, allows all frequencies to pass, but changes the phase
    #: response at a given point (with specified sharpness).
    ALLPASS = 12


class DSP_NORMALIZE(IntEnum):
    """Normalize DSP parameter types.

    Normalize amplifies the sound based on the maximum peaks within the signal.
    For example if the maximum peaks in the signal were 50% of the bandwidth,
    it would scale the whole sound by two.

    The lower threshold value makes the normalizer ignores peaks below a
    certain point, to avoid over-amplification if a loud signal suddenly came
    in, and also to avoid amplifying to maximum things like background hiss.

    Because FMOD is a realtime audio processor, it doesn't have the luxury of
    knowing the peak for the whole sound (ie it can't see into the future), so
    it has to process data as it comes in.

    To avoid very sudden changes in volume level based on small samples of new
    data, fmod fades towards the desired amplification which makes for smooth
    gain control. The fadetime parameter can control this.
    """

    FADETIME = 0  #: Time to ramp the silence to full.
    THRESHOLD = 1  #: Lower volume range threshold to ignore.
    MAXAMP = 2  #: Maximum amplification allowed.


class DSP_OBJECTPAN(IntEnum):
    """Object based spatializer parameters.

    Signal processed by this :py:class:`~pyfmodex.dsp.DSP` will be sent to the
    global object mixer (effectively a send), any :py:class:`~pyfmodex.dsp.DSP`
    connected after this will receive silence.

    For best results this :py:class:`~pyfmodex.dsp.DSP` should be used with
    :py:attr:`~pyfmodex.enums.OUTPUTTYPE.WINSONIC` or
    :py:attr:`~pyfmodex.enums.OUTPUTTYPE.AUDIO3D` to get height spatialization.
    Playback with any other output will result in fallback spatialization
    provided by :py:attr:`~pyfmodex.enums.DSP_TYPE.PAN`.
    """

    THREED_POSITION = 0  #: 3D Position.
    THREED_ROLLOFF = 1  #: 3D Rolloff Type.
    THREED_MIN_DISTANCE = 2  #: 3D Min Distance.
    THREED_MAX_DISTANCE = 3  #: 3D Max Distance.
    THREED_EXTENT_MODE = 4  #: 3D Extent Mode.
    THREED_SOUND_SIZE = 5  #: 3D Sound Size.
    THREED_MIN_EXTENT = 6  #: 3D Min Extent.

    #: Overall gain to allow FMOD to know the DSP is scaling the signal for
    #: virtualization purposes.
    OVERALL_GAIN = 7

    OUTPUT_GAIN = 8  #: Output gain level.


class DSP_OSCILLATOR(IntEnum):
    """Oscillator DSP parameter types."""

    #: Waveform type.
    #:
    #: - 0: sine
    #: - 1: square
    #: - 2: sawup
    #: - 3: sawdown
    #: - 4: triangle
    #: - 5: noise
    TYPE = 0

    #: Frequency of the sinewave.
    RATE = 1


class DSP_PAN(IntEnum):
    """Pan DSP parameter types."""

    MODE = 0  #: Panner mode.
    TWOD_STEREO_POSITION = 1  #: 2D Stereo pan position.

    #: 2D Surround pan direction. Direction from center point of panning circle
    #: where 0 is front center and -180 or +180 is rear speakers center point.
    TWOD_DIRECTION = 2

    TWOD_EXTENT = 3  #: 2D Surround pan extent.
    TWOD_ROTATION = 4  #: 2D Surround pan rotation.
    TWOD_LFE_LEVEL = 5  #: 2D Surround pan LFE level.
    TWOD_STEREO_MODE = 6  #: Stereo-To-Surround Mode.

    #: Separation/width of L/R parts of stereo sound.
    TWOD_STEREO_SEPARATION = 7

    TWOD_STEREO_AXIS = 8  #: Axis/rotation of L/R parts of stereo sound.

    #: Speakers Enabled Bitmask for each speaker from 0 to 32 to be considered
    #: by panner. Use to disable speakers from being panned to. 0 to 0xFFF.
    #: Default = 0xFFF (All on).
    ENABLED_SPEAKERS = 9

    THREED_POSITION = 10  #: 3D Position.
    THREED_ROLLOFF = 11  #: 3D Rolloff.
    THREED_MIN_DISTANCE = 12  #: 3D Min Distance.
    THREED_MAX_DISTANCE = 13  #: 3D Max Distance.
    THREED_EXTENT_MODE = 14  #: 3D Extent Mode.
    THREED_SOUND_SIZE = 15  #: 3D Sound Size.
    THREED_MIN_EXTENT = 16  #: 3D Min Extent.
    THREED_PAN_BLEND = 17  #: 3D Pan Blend.

    #: LFE Upmix Enabled. Determines whether non-LFE source channels should mix
    #: to the LFE or leave it alone. 0 (off) to 1 (on). Default = 0 (off).
    LFE_UPMIX_ENABLED = 18

    #: Overall gain to allow FMOD to know the DSP is scaling the signal for
    #: visualization purposes.
    OVERALL_GAIN = 19

    SURROUND_SPEAKER_MODE = 20  #: Surround speaker mode.

    #: 2D Height blend. When the input or :py:attr:`SURROUND_SPEAKER_MODE` has
    #: height speakers, control the blend between ground and height. -1.0 (push
    #: top speakers to ground), 0.0 (preserve top / ground separation), 1.0
    #: (push ground speakers to top).
    TWOD_HEIGHT_BLEND = 21


class DSP_PAN_MODE_TYPE(IntEnum):
    """3D Pan Mode values for Pan DSP."""

    MONO = 0
    STEREO = 1
    SURROUND = 2


class DSP_PAN_SURROUND_FLAGS(IntEnum):
    """Flags for the FMOD_DSP_PAN_SUMSURROUNDMATRIX_FUNC function."""

    DEFAULT = 0
    ROTATION_NOT_BIASED = 1


class DSP_PARAMEQ(IntEnum):
    """Parametric EQ DSP parameter types.

    Parametric EQ is a single band peaking EQ filter that attenuates or
    amplifies a selected frequency and its neighbouring frequencies.

    When a frequency has its gain set to 1.0, the sound will be unaffected and
    represents the original signal exactly.

    Deprecated and will be removed in a future release, to emulate with
    :py:class:`DSP_MULTIBAND_EQ`.
    """

    CENTER = 0  #: Frequency center.
    BANDWIDTH = 1  #: Octave range around the center frequency to filter.
    GAIN = 2  #: Frequency Gain in dB.


class DSP_PARAMETER_DATA_TYPE(Enum):
    """Data parameter types."""

    #: Default data type. All user data types should be 0 or above.
    USER = 0

    #: Data type for :py:class:`~pyfmodex.structures.DSP_PARAMETER_OVERALLGAIN`
    #: parameters.  There should a maximum of one per DSP.
    OVERALLGAIN = 1

    #: Data type for
    #: :py:class:`~pyfmodex.structures.DSP_PARAMETER_3DATTRIBUTES`
    #: parameters. There should a maximum of one per DSP.
    THREED_ATTRIBUTES = 2

    #: Data type for
    #: :py:class:`~pyfmodex.structures.DSP_PARAMETER_SIDECHAIN` parameters.
    #: There should a maximum of one per DSP.
    SIDECHAIN = 3

    #: Data type for :py:class:`~pyfmodex.structures.DSP_PARAMETER_FFT`
    #: parameters. There should a maximum of one per DSP.
    FFT = 4

    #: Data type for
    #: :py:class:`~pyfmodex.structures.DSP_PARAMETER_3DATTRIBUTES_MULTI`
    #: parameters. There should a maximum of one per DSP.
    THREEDATTRIBUTES_MULTI = 5


class DSP_PARAMETER_FLOAT_MAPPING_TYPE(Enum):
    LINEAR = 0
    AUTO = 1
    PIECEWISE_LINEAR = 2


class DSP_PARAMETER_TYPE(Enum):
    """DSP parameter types."""

    #: PARAMETER_DESCRIPTION will use
    #: :py:class:`~pyfmodex.structures.DSP_PARAMETER_DESC_FLOAT`.
    FLOAT = 0

    #: PARAMETER_DESCRIPTION will use
    #: :py:class:`~pyfmodex.structures.DSP_PARAMETER_DESC_INT`.
    INT = 1

    #: PARAMETER_DESCRIPTION will use
    #: :py:class:`~pyfmodex.structures.DSP_PARAMETER_DESC_BOOL`.
    BOOL = 2

    #: PARAMETER_DESCRIPTION will use
    #: :py:class:`~pyfmodex.structures.DSP_PARAMETER_DESC_DATA`.
    DATA = 3

    MAX = 4  #: Maximum number of DSP parameter types.


class DSP_PITCHSHIFT(IntEnum):
    """Pitch shift DSP parameter types

    This pitch shifting unit can be used to change the pitch of a sound without
    speeding it up or slowing it down.

    It can also be used for time stretching or scaling, for example if the
    pitch was doubled, and the frequency of the sound was halved, the pitch of
    the sound would sound correct but it would be twice as slow.

    Warning! This filter is very computationally expensive! Similar to a
    vocoder, it requires several overlapping FFT and IFFT's to produce smooth
    output, and can require around 440mhz for 1 stereo 48khz signal using the
    default settings. Reducing the signal to mono will half the cpu usage.
    Reducing this will lower audio quality, but what settings to use are
    largely dependant on the sound being played. A noisy polyphonic signal will
    need higher fft size compared to a speaking voice for example.

    This pitch shifter is based on the pitch shifter code at
    http://www.dspdimension.com, written by Stephan M. Bernsee. The original
    code is COPYRIGHT 1999-2003 Stephan M. Bernsee - smb@dspdimension.com.

    'maxchannels' dictates the amount of memory allocated. By default, the
    maxchannels value is 0. If FMOD is set to stereo, the pitch shift unit will
    allocate enough memory for 2 channels. If it is 5.1, it will allocate
    enough memory for a 6 channel pitch shift, etc.

    If the pitch shift effect is only ever applied to the global mix (ie it was
    added with :py:meth:`~pyfmodex.channel_control.ChannelControl.add_dsp` on a
    :py:class:`~pyfmodex.channel_group.ChannelGroup`), then 0
    is the value to set as it will be enough to handle all speaker modes.

    When the pitch shift is added to a channel (i.e.
    :py:meth:`~pyfmodex.channel_control.ChannelControl.add_dsp` on a
    :py:class:`~pyfmodex.channel.Channel`) then the channel count that comes in
    could be anything from 1 to 8 possibly. It is only in this case where you
    might want to increase the channel count above the output's channel count.

    If a channel pitch shift is set to a lower number than the sound's channel
    count that is coming in, it will not pitch shift the sound.
    .
    """

    #: Pitch value.
    #:
    #: - 0.5: one octave down
    #: - 2.0: one octave up
    #: - 1.0: does not change the pitch
    PITCH = 0

    #: FFT window size - 256, 512, 1024, 2048, 4096. Increase this to reduce
    #: 'smearing'. This effect is a warbling sound similar to when an mp3 is
    #: encoded at very low bitrates.
    FFTSIZE = 1

    #: Removed. Do not use. FMOD now uses 4 overlaps and cannot be changed.
    OVERLAP = 3

    #: Maximum channels supported.
    #:
    #: - 0: same as FMOD's default output polyphony
    #: - 1: mono
    #: - 2: stereo
    #: - etc...
    #:
    #: It is suggested to leave at 0!
    MAXCHANNELS = 4


class DSP_PROCESS_OPERATION(Enum):
    """Process operation type.

    A process callback will be called twice per mix for a DSP unit. Once with
    the :py:attr:`QUERY` command, then conditionally, :py:attr:`PERFORM`.

    :py:attr:`QUERY` is to be handled only by filling out the outputarray
    information, and returning a relevant return code.

    It should not really do any logic besides checking and returning or raising
    exceptions:

     - return normal: Meaning yes, it should execute the dsp process function
       with :py:attr:`PERFORM`

     - raise :py:exc:`~pyfmodex.exceptions.FmodError` with code
       :py:attr:`~RESULT.DSP_DONTPROCESS` - Meaning no, it should skip the
       process function and not call it with :py:attr:`PERFORM`.

     - raise :py:exc:`~pyfmodex.exceptions.FmodError` with code
       :py:attr:`~RESULT.DSP_SILENCE` - Meaning no, it should skip the process
       function and not call it with :py:attr:`PERFORM`, AND, tell the signal
       chain to follow that it is now idle, so that no more processing happens
       down the chain.

    If audio is to be processed, 'outbufferarray' must be filled with the
    expected output format, channel count and mask. Mask can be 0.

    The process is to be handled by reading the data from the input, processing
    it, and writing it to the output. Always write to the output buffer and
    fill it fully to avoid unpredictable audio output.

    Always return normally, the return value is ignored from the process stage.
    """

    #: Process the incoming audio in 'inbufferarray' and output to
    #: 'outbufferarray'.
    PERFORM = 0

    #: The DSP is being queried for the expected output format and whether it
    #: needs to process audio or should be bypassed. The function should
    #: succeed, or raise :py:exc:`~pyfmodex.exceptions.FmodError` if audio
    #: can pass through unprocessed. If audio is to be processed,
    #: 'outbufferarray' must be filled with the expected output format, channel
    #: count and mask.
    QUERY = 1


class DSP_RESAMPLER(IntEnum):
    """List of interpolation types used for resampling.

    Use :py:attr:`~pyfmodex.system.System.advanced_settings` and
    :py:attr:`~pyfmodex.structures.ADVANCEDSETTINGS.resamplerMethod` to
    configure the resampling quality you require for sample rate conversion
    during sound playback.
    """

    DEFAULT = 0  #: Default interpolation method, same as :py:attr:`LINEAR`.

    #: No interpolation. High frequency aliasing hiss will be audible depending
    #: on the sample rate of the sound.
    NOINTERP = 1

    #: Linear interpolation (default method). Fast and good quality, causes
    #: very slight lowpass effect on low frequency sounds.
    LINEAR = 2

    #: Cubic interpolation. Slower than linear interpolation but better
    #: quality.
    CUBIC = 3

    #: Five point spline interpolation. Slowest resampling method but best
    #: quality.
    SPLINE = 4

    MAX = 5  #: Maximum number of resample methods supported.


class DSP_RETURN(IntEnum):
    """Return DSP parameter types."""

    ID = 0  #: ID of this Return DSP.
    INPUT_SPEAKER_MODE = 1  #: Input speaker mode of this return.


class DSP_SEND(IntEnum):
    """Send DSP parameter types."""

    #: ID of the Return DSP this send is connected to where -1 indicates no
    #: connected return DSP.
    RETURNID = 0

    LEVEL = 1  #: Send level.


class DSP_SFXREVERB(IntEnum):
    """SFX Reverb DSP parameter types.

    This is a high quality I3DL2 based reverb. On top of the I3DL2 property
    set, "Dry Level" is also included to allow the dry mix to be changed. These
    properties can be set with presets in
    :py:class:`~pyfmodex.reverb_presets.REVERB_PRESET`.
    """

    DECAYTIME = 0  #: Reverberation decay time at low-frequencies.
    EARLYDELAY = 1  #: Delay time of first reflection.

    #: Late reverberation delay time relative to first reflection in
    #:milliseconds.
    LATEDELAY = 2

    HFREFERENCE = 3  #: Reference frequency for high-frequency decay.
    HFDECAYRATIO = 4  #: High-frequency decay time relative to decay time.
    DIFFUSION = 5  #: Reverberation diffusion (echo density).
    DENSITY = 6  #: Reverberation density (modal density).
    LOWSHELFFREQUENCY = 7  #: Transition frequency of low-shelf filter.
    LOWSHELFGAIN = 8  #: Gain of low-shelf filter.
    HIGHCUT = 9  #: Cutoff frequency of low-pass filter.
    EARLYLATEMIX = 10  #: Blend ratio of late reverb to early reflections.
    WETLEVEL = 11  #: Reverb signal level.
    DRYLEVEL = 12  #: Dry signal level.


class DSP_THREE_EQ(IntEnum):
    """Three EQ DSP parameter types."""

    LOWGAIN = 0  #: Low frequency gain.
    MIDGAIN = 1  #: Mid frequency gain.
    HIGHGAIN = 2  #: High frequency gain.
    LOWCROSSOVER = 3  #: Low-to-mid crossover frequency.
    HIGHCROSSOVER = 4  #: Mid-to-high crossover frequency.

    #: Crossover Slope where 0 is 12dB/Octave, 1 is 24dB/Octave and 2 is
    #: 48dB/Octave.
    CROSSOVERSLOPE = 5


class DSP_THREE_EQ_CROSSOVERSLOPE_TYPE(IntEnum):
    """Crossover values for Three EQ DSP."""

    SLOPE_12DB = 0
    SLOPE_24DB = 1
    SLOPE_48DB = 2


class DSP_TRANSCEIVER(IntEnum):
    """Transceiver DSP parameter types.

    The transceiver only transmits and receives to a global array of 32
    channels. The transceiver can be set to receiver mode (like a return) and
    can receive the signal at a variable gain. The transceiver can also be set
    to transmit to a channel (like a send) and can transmit the signal with a
    variable gain.

    The :py:attr:`TRANSMITSPEAKERMODE` is only applicable to the transmission
    format, not the receive format. This means this parameter is ignored in
    'receive mode'. This allows receivers to receive at the speaker mode of the
    user's choice. Receiving from a mono channel, is cheaper than receiving
    from a surround channel for example. The three  speaker modes
    :py:attr:`~DSP_TRANSCEIVER_SPEAKERMODE.MONO`,
    :py:attr:`~DSP_TRANSCEIVER_SPEAKERMODE.STEREO`,
    :py:attr:`~DSP_TRANSCEIVER_SPEAKERMODE.SURROUND` are stored as separate
    buffers in memory for a transmitter channel. To save memory, use one common
    speaker mode for a transmitter.

    The transceiver is double buffered to avoid desyncing of transmitters and
    receivers. This means there will be a 1 block delay on a receiver, compared
    to the data sent from a transmitter. Multiple transmitters sending to the
    same channel will be mixed together.
    """

    #: - False: Transceiver is a 'receiver' (like a return) and accepts data
    #:   from a channel.
    #: - True: Transceiver is a 'transmitter' (like a send).
    TRANSMIT = 0

    GAIN = 1  #: Gain to receive or transmit.
    CHANNEL = 2  #: Global slot that can be transmitted to or received from.
    TRANSMITSPEAKERMODE = 3  #: Speaker mode (transmitter mode only).


class DSP_TRANSCEIVER_SPEAKERMODE(IntEnum):
    """Speaker mode values for Transceiver DSP.

    The speaker mode of a transceiver buffer (of which there are up to 32 of)
    is determined automatically depending on the signal flowing through the
    transceiver effect, or it can be forced. Use a smaller fixed speaker mode
    buffer to save memory. Only relevant for transmitter dsps, as they control
    the format of the transceiver channel's buffer.

    If multiple transceivers transmit to a single buffer in different speaker
    modes, it will allocate memory for each speaker mode. This uses more memory
    than a single speaker mode. If there are multiple receivers reading from a
    channel with multiple speaker modes, it will read them all and mix them
    together.

    If the system's speaker mode is stereo or mono, it will not create a 3rd
    buffer, it will just use the mono/stereo speaker mode buffer.
    """

    #: A transmitter will use whatever signal channel count coming in to the
    #: transmitter, to determine which speaker mode is allocated for the
    #: transceiver channel.
    AUTO = 0

    MONO = 1  #: A transmitter will always downmix to a mono channel buffer.

    #: A transmitter will always upmix or downmix to a stereo channel buffer.
    STEREO = 2

    #: A transmitter will always upmix or downmix to a surround channel buffer.
    #: Surround is the speaker mode of the system above stereo, so could be
    #: quad/surround/5.1/7.1.
    SURROUND = 3


class DSP_TREMOLO(IntEnum):
    """Tremolo DSP parameter types.

    The tremolo effect varies the amplitude of a sound. Depending on the
    settings, this unit can produce a tremolo, chopper or auto-pan effect.

    The shape of the LFO (low freq. oscillator) can morphed between sine,
    triangle and sawtooth waves using the :py:attr:`SHAPE` and :py:attr:`SKEW`
    parameters.

    :py:attr:`DUTY` and :py:attr:`SQUARE` are useful for a chopper-type effect
    where the first controls the on-time duration and second controls the
    flatness of the envelope.

    :py:attr:`SPREAD` varies the LFO phase between channels to get an auto-pan
    effect. This works best with a sine shape LFO.

    The LFO can be synchronized using the :py:attr:`PHASE` parameter which sets
    its instantaneous phase.
    """

    FREQUENCY = 0  #: LFO frequency.
    DEPTH = 1  #: Tremolo depth.
    SHAPE = 2  #: LFO shape morph between triangle and sine.
    SKEW = 3  #: Time-skewing of LFO cycle.
    DUTY = 4  #: LFO on-time.
    SQUARE = 5  #: Flatness of the LFO shape.
    PHASE = 6  #: Instantaneous LFO phase.
    SPREAD = 7  #: Rotation / auto-pan effect.


class DSP_TYPE(IntEnum):
    """DSP types."""

    #: Was created via a non-FMOD plugin and has an unknown purpose.
    UNKNOWN = 0

    MIXER = 1  #: Mixes its inputs.
    OSCILLATOR = 2  #: Generates sine/square/saw/triangle or noise tones.

    #: Filters sound using a high quality, resonant lowpass filter algorithm
    #: but consumes more CPU time.
    #:
    #: Deprecated and will be removed in a future release
    LOWPASS = 3

    #: Filters sound using a resonant lowpass filter algorithm that is used in
    #: Impulse Tracker, but with limited cutoff range (0 to 8060hz).
    ITLOWPASS = 4

    #: Filters sound using a resonant highpass filter algorithm.
    #:
    #: Deprecated and will be removed in a future release.
    HIGHPASS = 5

    #: Produces an echo on the sound and fades out at the desired rate.
    ECHO = 6

    FADER = 7  #: Pans and scales the volume of a unit.
    FLANGE = 8  #: Produces a flange effect on the sound.
    DISTORTION = 9  #: Distorts the sound.
    NORMALIZE = 10  #: Normalizes or amplifies the sound to a certain level.
    LIMITER = 11  #: Limits the sound to a certain level.

    #: Attenuates or amplifies a selected frequency range.
    #:
    #: Deprecated and will be removed in a future release.
    PARAMEQ = 12

    #: Bends the pitch of a sound without changing the speed of playback.
    PITCHSHIFT = 13

    CHORUS = 14  #: Produces a chorus effect on the sound.
    VSTPLUGIN = 15  #: Allows the use of Steinberg VST plugins.
    WINAMPPLUGIN = 16  #: Allows the use of Nullsoft Winamp plugins.

    #: Produces an echo on the sound and fades out at the desired rate as is
    #: used in Impulse Tracker.
    ITECHO = 17

    #: Dynamic compression (linked/unlinked multichannel, wideband)
    COMPRESSOR = 18

    SFXREVERB = 19  #: SFX reverb

    #: Filters sound using a simple lowpass with no resonance, but has flexible
    #: cutoff and is fast.
    #:
    #: Deprecated and will be removed in a future release.
    LOWPASS_SIMPLE = 20

    #: Produces different delays on individual channels of the sound.
    DELAY = 21

    TREMOLO = 22  #: Produces a tremolo / chopper effect on the sound.
    LADSPAPLUGIN = 23  #: Unsupported / Deprecated.

    #: Sends a copy of the signal to a return DSP anywhere in the DSP tree.
    SEND = 24

    RETURN = 25  #: Receives signals from a number of send DSPs.

    #: Filters sound using a simple highpass with no resonance, but has
    #: flexible cutoff and is fast.
    #:
    #: Deprecated and will be removed in a future release.
    HIGHPASS_SIMPLE = 26

    PAN = 27  #: Pans the signal, possibly upmixing or downmixing as well.
    THREE_EQ = 28  #: Three-band equalizer.

    #: Analyzes the signal and provides spectrum information back.
    FFT = 29

    LOUDNESS_METER = 30  #: Analyzes the loudness and true peak of the signal.

    #: Tracks the envelope of the input/sidechain signal.
    #:
    #: Deprecated and will be removed in a future release.
    ENVELOPEFOLLOWER = 31

    CONVOLUTIONREVERB = 32  #: Convolution reverb.

    #: Provides per signal channel gain, and output channel mapping to allow
    #: one multichannel signal made up of many groups of signals to map to a
    #: single output signal.
    CHANNELMIX = 33

    #: 'sends' and 'receives' from a selection of up to 32 different slots. It
    #: is like a send/return but it uses global slots rather than returns as the
    #: destination. It also has other features. Multiple transceivers can receive
    #: from a single channel, or multiple transceivers can send to a single
    #: channel, or a combination of both.
    TRANSCEIVER = 34

    #: Spatializes input signal by passing it to an external object mixer.
    OBJECTPAN = 35

    MULTIBAND_EQ = 36  #: Five band parametric equalizer.
    MAX = 37  #: Maximum number of pre-defined DSP types.


class ERRORCALLBACK_INSTANCETYPE(Enum):
    """Identifier used to represent the different types of instance in the
    error callback.
    """

    NONE = 0  #: Type representing no known instance type.
    SYSTEM = 1  #: Type representing :py:class:`~pyfmodex.system.System`.
    CHANNEL = 2  #: Type representing :py:class:`~pyfmodex.channel.Channel`.

    #: Type representing :py:class:`~pyfmodex.channel_group.ChannelGroup`.
    CHANNELGROUP = 2

    #: Type representing :py:class:`~pyfmodex.channel_control.ChannelControl`.
    CHANNELCONTROL = 3

    SOUND = 4  #: Type representing :py:class:`~pyfmodex.sound.Sound`.

    #: Type representing :py:class:`~pyfmodex.sound_group.SoundGroup`.
    SOUNDGROUP = 5

    DSP = 6  #: Type representing :py:class:`~pyfmodex.dsp.DSP`.

    #: Type representing :py:class:`~pyfmodex.dsp_connection.DSPConnection`.
    DSPCONNECTION = 7

    GEOMETRY = 8  #: Type representing :py:class:`~pyfmodex.geometry.Geometry`.
    REVERB3D = 9  #: Type representing :py:class:`~pyfmodex.reverb.Reverb3D`.

    #: Type representing :py:class:`~pyfmodex.studio.system.StudioSystem`.
    STUDIO_SYSTEM = 10

    #: Type representing
    #: :py:class:`~pyfmodex.studio.event_description.EventDescription`.
    STUDIO_EVENTDESCRIPTION = 11

    #: Type representing
    #: :py:class:`~pyfmodex.studio.event_instance.EventInstance`.
    STUDIO_EVENTINSTANCE = 12

    STUDIO_PARAMETERINSTANCE = 13  #: Deprecated.

    STUDIO_BUS = 14  #: Type representing Studio Bus.
    STUDIO_VCA = 15  #: Type representing Studio VCA.
    STUDIO_BANK = 16  #: Type representing Studio Bank.
    STUDIO_COMMANDREPLAY = 17  #: Type representing Studio CommmandReplay.


class OPENSTATE(Enum):
    """These values describe what state a sound is in after the
    :py:class:`~pyfmodex.flags.MODE` flag NONBLOCKING has been used to open it.

    With streams, if you are using the :py:class:`~pyfmodex.flags.MODE` flag
    NONBLOCKING, note that if the user calls
    :py:meth:`~pyfmodex.sound.Sound.get_subsound`, a stream will go into
    :py:attr:`SEEKING` state and sound related commands will raise
    :py:exc:`~pyfmodex.exceptions.FmodError` with code
    :py:attr:`~RESULT.NOTREADY`.

    With streams, if you are using the :py:class:`~pyfmodex.flags.MODE` flag
    NONBLOCKING, note that if the user calls
    :py:meth:`~pyfmodex.channel.Channel.get_position`, a stream will go into
    :py:attr:`SETPOSITION` state and sound related commands will raise
    :py:exc:`~pyfmodex.exceptions.FmodError` with code
    :py:attr:`~RESULT.NOTREADY`.
    """

    READY = 0  #: Opened and ready to play.
    LOADING = 1  #: Initial load in progress.

    #: Failed to open - file not found, out of memory etc. See
    #: :py:exc:`~pyfmodex.exceptions.FmodError` code from
    #: :py:attr:`~pyfmodex.sound.Sound.open_state` for what happened.
    ERROR = 2

    CONNECTING = 3  #: Connecting to remote host (Internet sounds only).
    BUFFERING = 4  #: Buffering data.
    SEEKING = 5  #: Seeking to subsound and re-flushing stream buffer.

    #: Ready and playing, but not possible to release at this time without
    #: stalling the main thread.
    PLAYING = 6

    SETPOSITION = 7  #: Seeking within a stream to a different position.
    MAX = 8  #: Maximum number of open state types.


class OUTPUTTYPE(Enum):
    """Built-in output types that can be used to run the mixer."""

    #: Picks the best output mode for the platform. This is the default.
    AUTODETECT = 0

    #: All - 3rd party plugin, unknown. This is for use with
    #: :py:attr:`~pyfmodex.system.System.output` only.
    UNKNOWN = 1

    NOSOUND = 2  #: All - Perform all mixing but discard the final output.
    WAVWRITER = 3  #: All - Writes output to a .wav file.

    #: All - Non-realtime version of :py:attr:`NOSOUND`, one mix per
    #: :py:attr:`~pyfmodex.system.System.update`.
    NOSOUND_NRT = 4

    #: All - Non-realtime version of :py:attr:`WAVWRITER`, one mix per
    #: :py:attr:`~pyfmodex.system.System.update`.
    WAVWRITER_NRT = 5

    #: Win / UWP / Xbox One - Windows Audio Session API. (Default on Windows,
    #: Xbox One and UWP)
    WASAPI = 6

    #: Win - Low latency ASIO 2.0.
    ASIO = 7

    #: Linux - PulseAudio. (Default on Linux if available)
    PULSEAUDIO = 8

    #: Linux - Advanced Linux Sound Architecture. (Default on Linux if
    #: PulseAudio isn't available)
    ALSA = 9

    #: Mac / iOS - Core Audio. (Default on Mac and iOS)
    COREAUDIO = 10

    #: Android - Java Audio Track. (Default on Android 2.2 and below)
    AUDIOTRACK = 11

    #: Android - OpenSL ES. (Default on Android 2.3 up to 7.1)
    OPENSL = 12

    #: PS4 - Audio Out. (Default on PS4)
    AUDIOOUT = 13

    #: PS4 - Audio3D.
    AUDIO3D = 14

    #: Web Browser - JavaScript webaudio output. (Default on HTML5)
    WEBAUDIO = 15

    #: Switch - nn::audio. (Default on Switch)
    NAUDIO = 16

    #: Win10 / Xbox One - Windows Sonic.
    WINSONIC = 17

    #: Android - AAudio. (Default on Android 8.1 and above)
    AAUDIO = 18

    #: Maximum number of output types supported.
    MAX = 19


class PLUGINTYPE(Enum):
    """Types of plugin used to extend functionality."""

    #: Audio output interface plugin represented with
    #: :py:class:`~pyfmodex.structures.OUTPUT_DESCRIPTION`.
    OUTPUT = 0

    #: File format codec plugin represented with
    #: :py:class:`~pyfmodex.structures.CODEC_DESCRIPTION`.
    CODEC = 1

    #: DSP unit plugin represented with
    #: :py:class:`~pyfmodex.structures.DSP_DESCRIPTION`.
    DSP = 2

    #: Maximum number of plugin types supported.
    MAX = 3


class RESULT(Enum):
    """Error codes for :py:exc:`~pyfmodex.exceptions.FmodError` raised by
    every function.
    """

    OK = 0  #: No errors.

    #: Tried to call a function on a data type that does not allow this type of
    #: functionality (f.i. calling :py:meth:`~pyfmodex.sound.Sound.lock` on a
    #: streaming sound).
    BADCOMMAND = 1

    CHANNEL_ALLOC = 2  #: Error trying to allocate a channel.

    #: The specified channel has been reused to play another sound.
    CHANNEL_STOLEN = 3

    #: DMA Failure. See debug output for more information.
    DMA = 4

    #: DSP connection error. Connection possibly caused a cyclic dependency or
    #: connected dsps with incompatible buffer counts.
    DSP_CONNECTION = 5

    #: DSP return code from a DSP process query callback. Tells mixer not to
    #: call the process callback and therefore not consume CPU. Use this to
    #: optimize the DSP graph.
    DSP_DONTPROCESS = 6

    #: DSP Format error. A DSP unit may have attempted to connect to this
    #: network with the wrong format, or a matrix may have been set with the wrong
    #: size if the target unit has a specified channel map.
    DSP_FORMAT = 7

    #: DSP is already in the mixer's DSP network. It must be removed before
    #: being reinserted or released.
    DSP_INUSE = 8

    #: DSP connection error. Couldn't find the DSP unit specified.
    DSP_NOTFOUND = 9

    #: DSP operation error. Cannot perform operation on this DSP as it is
    #: reserved by the system.
    DSP_RESERVED = 10

    #: DSP return code from a DSP process query callback. Tells mixer silence
    #: would be produced from read, so go idle and not consume CPU. Use this to
    #: optimize the DSP graph.
    DSP_SILENCE = 11

    #: DSP operation cannot be performed on a DSP of this type.
    DSP_TYPE = 12

    #: Error loading file.
    FILE_BAD = 13

    #: Couldn't perform seek operation. This is a limitation of the medium (ie
    #: netstreams) or the file format.
    FILE_COULDNOTSEEK = 14

    #: Media was ejected while reading.
    FILE_DISKEJECTED = 15

    #: End of file unexpectedly reached while trying to read essential data
    #: (truncated?).
    FILE_EOF = 16

    #: End of current chunk reached while trying to read data.
    FILE_ENDOFDATA = 17

    #: File not found.
    FILE_NOTFOUND = 18

    #: Unsupported file or audio format.
    FORMAT = 19

    #: There is a version mismatch between the FMOD header and either the FMOD
    #: Studio library or the FMOD Core library.
    HEADER_MISMATCH = 20

    #: A HTTP error occurred. This is a catch-all for HTTP errors not listed
    #: elsewhere.
    HTTP = 21

    #: The specified resource requires authentication or is forbidden.
    HTTP_ACCESS = 22

    #: Proxy authentication is required to access the specified resource.
    HTTP_PROXY_AUTH = 23

    #: A HTTP server error occurred.
    HTTP_SERVER_ERROR = 24

    #: The HTTP request timed out.
    HTTP_TIMEOUT = 25

    #: FMOD was not initialized correctly to support this function.
    INITIALIZATION = 26

    #: Cannot call this command after :py:meth:`~pyfmodex.system.System.init`.
    INITIALIZED = 27

    #: An error occurred that wasn't supposed to. Contact support.
    INTERNAL = 28

    #: Value passed in was a NaN, Inf or denormalized float.
    INVALID_FLOAT = 29

    #: An invalid object handle was used.
    INVALID_HANDLE = 30

    #: An invalid parameter was passed to this function.
    INVALID_PARAM = 31

    #: An invalid seek position was passed to this function.
    INVALID_POSITION = 32

    #: An invalid speaker was passed to this function based on the current
    #: speaker mode.
    INVALID_SPEAKER = 33

    #: The syncpoint did not come from this sound handle.
    INVALID_SYNCPOINT = 34

    #: Tried to call a function on a thread that is not supported.
    INVALID_THREAD = 35

    #: The vectors passed in are not unit length, or perpendicular.
    INVALID_VECTOR = 36

    #: Reached maximum audible playback count for this sound's soundgroup.
    MAXAUDIBLE = 37

    #: Not enough memory or resources.
    MEMORY = 38

    #: Can't use the :py:class:`~pyfmodex.flags.MODE` flag OPENMEMORY_POINT on
    #: non PCM source data, or non mp3/xma/adpcm data if
    #: :py:class:`~pyfmodex.flags.MODE` flag CREATECOMPRESSEDSAMPLE was used.
    MEMORY_CANTPOINT = 39

    #: Tried to call a command on a 2d sound when the command was meant for 3d
    #: sound.
    NEEDS3D = 40

    #: Tried to use a feature that requires hardware support.
    NEEDSHARDWARE = 41

    #: Couldn't connect to the specified host.
    NET_CONNECT = 42

    #: A socket error occurred. This is a catch-all for socket-related errors
    #: not listed elsewhere.
    NET_SOCKET_ERROR = 43

    #: The specified URL couldn't be resolved.
    NET_URL = 44

    #: Operation on a non-blocking socket could not complete immediately.
    NET_WOULD_BLOCK = 45

    #: Operation could not be performed because specified sound/DSP connection
    #: is not ready.
    NOTREADY = 46

    #: Error initializing output device, but more specifically, the output
    #: device is already in use and cannot be reused.
    OUTPUT_ALLOCATED = 47

    #: Error creating hardware sound buffer.
    OUTPUT_CREATEBUFFER = 48

    #: A call to a standard soundcard driver failed, which could possibly mean
    #: a bug in the driver or resources were missing or exhausted.
    OUTPUT_DRIVERCALL = 49

    #: Soundcard does not support the specified format.
    OUTPUT_FORMAT = 50

    #: Error initializing output device.
    OUTPUT_INIT = 51

    #: The output device has no drivers installed. If pre-init,
    #: :py:attr:`~OUTPUTTYPE.NOSOUND` is selected as the output mode. If
    #: post-init, the function just fails.
    OUTPUT_NODRIVERS = 52

    #: An unspecified error has been returned from a plugin.
    PLUGIN = 53

    #: A requested output, dsp unit type or codec was not available.
    PLUGIN_MISSING = 54

    #: A resource that the plugin requires cannot be found. (i.e. the DLS file
    #: for MIDI playback)
    PLUGIN_RESOURCE = 55

    #: A plugin was built with an unsupported SDK version.
    PLUGIN_VERSION = 56

    #: An error occurred trying to initialize the recording device.
    RECORD = 57

    #: Reverb properties cannot be set on this channel because a parent
    #: :py:class:`~pyfmodex.channel_group.ChannelGroup` owns the reverb
    #: connection.
    REVERB_CHANNELGROUP = 58

    #: Specified instance in :py:class:`~pyfmodex.structures.REVERB_PROPERTIES`
    #: couldn't be set. Most likely because it is an invalid instance number or
    #: the reverb doesn't exist.
    REVERB_INSTANCE = 59

    #: The error occurred because the sound referenced contains subsounds when
    #: it shouldn't have, or it doesn't contain subsounds when it should have.
    #: The operation may also not be able to be performed on a parent sound.
    SUBSOUNDS = 60

    #: This subsound is already being used by another sound, you cannot have
    #: more than one parent to a sound. Null out the other parent's entry
    #: first.
    SUBSOUND_ALLOCATED = 61

    #: Shared subsounds cannot be replaced or moved from their parent stream,
    #: such as when the parent stream is an FSB file.
    SUBSOUND_CANTMOVE = 62

    #: The specified tag could not be found or there are no tags.
    TAGNOTFOUND = 63

    #: The sound created exceeds the allowable input channel count. This can be
    #: increased using the 'maxinputchannels' parameter in
    #: :py:attr:`~pyfmodex.system.System.software_format`.
    TOOMANYCHANNELS = 64

    #: The retrieved string is too long to fit in the supplied buffer and has
    #: been truncated.
    TRUNCATED = 65

    #: Something in FMOD hasn't been implemented when it should be! Contact
    #: support!
    UNIMPLEMENTED = 66

    #: This command failed because :py:meth:`~pyfmodex.system.System.init` or
    #: or :py:meth:`~pyfmodex.system.System.driver` was not called or set.
    UNINITIALIZED = 67

    #: A command issued was not supported by this object. Possibly a plugin
    #: without certain callbacks specified.
    UNSUPPORTED = 68

    #: The version number of this file format is not supported.
    VERSION = 69

    #: The specified bank has already been loaded.
    EVENT_ALREADY_LOADED = 70

    #: The live update connection failed due to the game already being
    #: connected.
    EVENT_LIVEUPDATE_BUSY = 71

    #: The live update connection failed due to the game data being out of sync
    #: with the tool.
    EVENT_LIVEUPDATE_MISMATCH = 72

    #: The live update connection timed out.
    EVENT_LIVEUPDATE_TIMEOUT = 73

    #: The requested event, parameter, bus or vca could not be found.
    EVENT_NOTFOUND = 74

    #: The :py:class:`~pyfmodex.studio.system.StudioSystem` object is not yet
    #: initialized.
    STUDIO_UNINITIALIZED = 75

    #: The specified resource is not loaded, so it can't be unloaded.
    STUDIO_NOT_LOADED = 76

    #: An invalid string was passed to this function.
    INVALID_STRING = 77

    #: The specified resource is already locked.
    ALREADY_LOCKED = 78

    #: The specified resource is not locked, so it can't be unlocked.
    NOT_LOCKED = 79

    #: The specified recording driver has been disconnected.
    RECORD_DISCONNECTED = 80

    #: The length provided exceeds the allowable limit.
    TOOMANYSAMPLES = 81


class SOUNDGROUP_BEHAVIOR(Enum):
    """Values specifying behavior when a sound group's max audible value is
    exceeded.

    When using :py:attr:`MUTE`,
    :py:attr:`~pyfmodex.sound_group.SoundGroup.mute_fade_speed` can be used to
    stop a sudden transition.

    Instead, the time specified will be used to cross fade between the sounds
    that go silent and the ones that become audible.
    """

    #: Excess sounds will fail when calling
    #: :py:meth:`~pyfmodex.system.System.play_sound`.`
    FAIL = 0

    #: Excess sounds will begin mute and will become audible when sufficient
    #: sounds are stopped.
    MUTE = 1

    #: Excess sounds will steal from the quietest
    #: :py:class:`~pyfmodex.sound.Sound` playing in the group.
    STEALLOWEST = 2

    #: Maximum number of :py:class:`~pyfmodex.sound_group.SoundGroup`
    #: behaviors.
    MAX = 3


class SOUND_FORMAT(Enum):
    """These definitions describe the native format of the hardware or software
    buffer that will be used.
    """

    NONE = 0  #: Uninitalized / unknown.
    PCM8 = 1  #: 8bit integer PCM data.
    PCM16 = 2  #: 16bit integer PCM data.
    PCM24 = 3  #: 24bit integer PCM data.
    PCM32 = 4  #: 32bit integer PCM data.
    PCMFLOAT = 5  #: 32bit floating point PCM data.

    #: Sound data is in its native compressed format. See
    #: :py:class:`~pyfmodex.flags.MODE` flag CREATECOMPRESSEDSAMPLE.
    BITSTREAM = 6

    MAX = 7  #: Maximum number of sound formats supported.


class SOUND_TYPE(Enum):
    """These definitions describe the type of song being played."""

    UNKNOWN = 0  #: 3rd party / unknown plugin format.
    AIFF = 1  #: AIFF.
    ASF = 2  #: Microsoft Advanced Systems Format (i.e. WMA/ASF/WMV).
    DLS = 3  #: Sound font / downloadable sound bank.
    FLAC = 4  #: FLAC lossless codec.
    FSB = 5  #: FMOD Sample Bank.
    IT = 6  #: Impulse Tracker.
    MIDI = 7  #: MIDI.
    MOD = 8  #: Protracker / Fasttracker MOD.
    MPEG = 9  #: MP2/MP3 MPEG.
    OGGVORBIS = 10  #: Ogg vorbis.
    PLAYLIST = 11  #: Information only from ASX/PLS/M3U/WAX playlists.
    RAW = 12  #: Raw PCM data.
    S3M = 13  #: ScreamTracker 3.
    USER = 14  #: User created sound.
    WAV = 15  #: Microsoft WAV.
    XM = 16  #: FastTracker 2 XM.
    XMA = 17  #: Xbox One XMA
    AUDIOQUEUE = 18  #: iPhone hardware decoder, supports AAC, ALAC and MP3.
    AT9 = 19  #: PS4 ATRAC 9 format.
    VORBIS = 20  #: Vorbis.
    MEDIA_FOUNDATION = 21  #: Windows Store Application built in system codecs.
    MEDIACODEC = 22  #: Android MediaCodec
    FADPCM = 23  #: FMOD Adaptive Differential Pulse Code Modulation.
    OPUS = 24  #: Opus.
    MAX = 25  #: Maximum number of sound types supported.


class SPEAKER(Enum):
    """Assigns an enumeration for a speaker index."""

    NONE = -1  #: No speaker.
    FRONT_LEFT = 0  #: The front left speaker.
    FRONT_RIGHT = 1  #: The front right speaker.
    FRONT_CENTER = 2  #: The front center speaker.
    LOW_FREQUENCY = 3  #: The LFE or 'subwoofer' speaker.
    SURROUND_LEFT = 4  #: The surround left (usually to the side) speaker.
    SURROUND_RIGHT = 5  #: The surround right (usually to the side) speaker.
    BACK_LEFT = 6  #: The back left speaker.
    BACK_RIGHT = 7  #: The back right speaker.
    TOP_FRONT_LEFT = 8  #: The top front left speaker
    TOP_FRONT_RIGHT = 9  #: The top front right speaker
    TOP_BACK_LEFT = 10  #: The top back left speaker
    TOP_BACK_RIGHT = 11  #: The top back right speaker
    MAX = 12  #: Maximum number of speaker types supported.


class SPEAKERMODE(Enum):
    """Speaker mode types.

    When the phrase 'sound channels' is used below, these are the subchannels
    inside a sound, they are not related and have nothing to do with the FMOD
    class "Channel".

    For example a mono sound has one sound channel, a stereo sound has two
    sound channels, and an AC3 or six channel wav file have six "sound
    channels".
    """

    #: Default speaker mode for the chosen output mode which will resolve after
    #: :py:meth:`~pyfmodex.system.System.init`.
    DEFAULT = 0

    #: This mode is for output devices that are not specifically
    #: mono/stereo/quad/surround/5.1 or 7.1, but are multichannel.
    #:
    #: - Use :py:attr:`~pyfmodex.system.System.software_format` to specify the
    #:   number of speakers you want to address, otherwise it will default to
    #:   two (stereo).
    #: - Sound channels map to speakers sequentially, so a mono sound maps to
    #:   output speaker 0, stereo sound maps to output speaker 0 & 1.
    #: - The user assumes knowledge of the speaker order. :py:class:`SPEAKER`
    #:   enumerations may not apply, so raw channel indices should be used.
    #: - Multichannel sounds map input channels to output channels 1:1.
    #: - Speaker levels must be manually set with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_mix_matrix`.
    #: - :py:meth:`~pyfmodex.channel_control.ChannelControl.set_pan` and
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_mix_levels_output`
    #:   do not work.
    RAW = 1

    #: This mode is for a one speaker arrangement.
    #:
    #: - Panning does not work in this speaker mode.
    #: - Mono, stereo and multichannel sounds have each sound channel played on
    #:   the one speaker at unity.
    #: - Mix behavior for multichannel sounds can be set with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_mix_matrix`.
    MONO = 2

    #: This mode is for two speaker arrangements that have a left and right
    #: speaker.
    #:
    #: - Mono sounds default to an even distribution between left and right.
    #:   They can be panned with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_pan`.
    #: - Stereo sounds default to the middle, or full left in the left speaker
    #:   and full right in the right speaker. They can be cross faded with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_pan`.
    #: - Multichannel sounds have each sound channel played on each speaker at
    #:   unity.
    #: - Mix behavior for multichannel sounds can be set with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_mix_matrix`.
    STEREO = 3

    #: This mode is for four speaker arrangements that have a front left, front
    #: right, surround left and a surround right speaker.
    #:
    #: - Mono sounds default to an even distribution between front left and
    #:   front right. They can be panned with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_pan`.
    #: - Stereo sounds default to the left sound channel played on the front
    #:   left, and the right sound channel played on the front right. They can
    #:   be cross faded with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_pan`.
    #: - Multichannel sounds default to all of their sound channels being
    #:   played on each speaker in order of input.
    #: - Mix behavior for multichannel sounds can be set with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_mix_matrix`.
    QUAD = 4

    #: This mode is for five speaker arrangements that have a
    #: left/right/center/surround left/surround right.This mode is for five
    #: speaker arrangements that have a left/right/center/surround
    #: left/surround right.
    #:
    #: - Mono sounds default to the central speaker. They can be panned with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_pan`.
    #: - Stereo sounds default to the left sound channel played on the front
    #:   left, and the right sound channel played on the front right. They can
    #:   be cross faded with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_pan`.
    #: - Multichannel sounds default to all of their sound channels being
    #:   played on each speaker in order of input.
    #: - Mix behavior for multichannel sounds can be set with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_mix_matrix`.
    SURROUND = 5

    #: This mode is for 5.1 speaker arrangements that have a
    #: left/right/center/surround left/surround right and a subwoofer speaker.
    #:
    #: - Mono sounds default to the central speaker. They can be panned with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_pan`.
    #: - Stereo sounds default to the left sound channel played on the front
    #:   left, and the right sound channel played on the front right. They can
    #:   be cross faded with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_pan`.
    #: - Multichannel sounds default to all of their sound channels being
    #:   played on each speaker in order of input.
    #: - Mix behavior for multichannel sounds can be set with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_mix_matrix`.
    FIVEPOINTONE = 6

    #: This mode is for 7.1 speaker arrangements that have a
    #: left/right/center/surround left/surround right/rear left/rear right and
    #: a subwoofer speaker.
    #:
    #: - Mono sounds default to the central speaker. They can be panned with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_pan`.
    #: - Stereo sounds default to the left sound channel played on the front
    #:   left, and the right sound channel played on the front right. They can
    #:   be cross faded with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_pan`.
    #: - Multichannel sounds default to all of their sound channels being
    #:   played on each speaker in order of input.
    #: - Mix behavior for multichannel sounds can be set with
    #:   :py:meth:`~pyfmodex.channel_control.ChannelControl.set_mix_matrix`.
    SEVENPOINTONE = 7

    #: Twelve 12 speaker setup (7.1.4) front left, front right, center, low
    #: frequency, surround left, surround right, back left, back right, top
    #: front left, top front right, top back left, top back right.
    SEVENPOINTONEPOINTFOUR = 8

    #: Maximum number of speaker modes supported.
    MAX = 9


class TAGDATATYPE(Enum):
    """List of tag data / metadata types."""

    BINARY = 0  #: Raw binary data.

    #: Integer - Note this integer could be 8bit / 16bit / 32bit / 64bit.
    INT = 1

    FLOAT = 2  #: IEEE floating point number.
    STRING = 3  #: 8bit ASCII char string.
    STRING_UTF16 = 4  #: 16bit UTF string. Assume little endian byte order.
    STRING_UTF16BE = 5  #: 16bit UTF string Big endian byte order.
    STRING_UTF8 = 6  #: 8 bit UTF string.
    MAX = 8  #: Maximum number of tag datatypes supported.


class TAGTYPE(Enum):
    """List of tag data / metadata types that could be stored within a sound.
    These include id3 tags, metadata from netstreams and vorbis/asf data.
    """

    UNKNOWN = 0  #: Tag type that is not recognized by FMOD.

    #: MP3 ID3 Tag 1.0. Typically 1 tag stored 128 bytes from end of an MP3 file.
    ID3V1 = 1

    #: MP3 ID3 Tag 2.0. Variable length tags with more than one possible.
    ID3V2 = 2

    #: Metadata container used in Vorbis, FLAC, Theora, Speex and Opus file
    #: formats.
    VORBISCOMMENT = 3

    #: SHOUTcast Internet stream metadata which can be issued during playback.
    SHOUTCAST = 4

    #: Icecast Internet stream metadata which can be issued during playback.
    ICECAST = 5

    #: Advanced Systems Format metadata typically associated with Windows Media
    #: formats such as WMA.
    ASF = 6

    #: Metadata stored inside a MIDI file.
    #:
    #: A midi file contains 16 channels. Not all of them are used, or in order.
    #: Use the tag 'Channel mask' and 'Number of channels' to find the channels
    #: used, to use with
    #: :py:meth:`~pyfmodex.sound.Sound.set_music_channel_volume` /
    #: :py:meth:`~pyfmodex.sound.Sound.get_music_channel_volume`. For example
    #: if the mask is 1001b, there are two channels, and channel 0 and channel
    #: 3 are the two channels used with the above methods.
    MIDI = 7

    #: Playlist files such as PLS,M3U,ASX and WAX will populate playlist
    #: information through this tag type.
    PLAYLIST = 8

    #: Tag type used by FMOD's MIDI, MOD, S3M, XM, IT format support, and
    #: netstreams to notify of Internet stream events like a sample rate
    #: change.
    FMOD = 9

    #: For codec developers, this tag type can be used with
    #: :py:func:`~pyfmodex.callback_prototypes.CODEC_METADATA_CALLBACK` to
    #: generate custom metadata.
    USER = 10

    #: Maximum number of tag types supported.
    MAX = 11


class TIMEUNIT(Enum):
    """Time types used for position or length."""

    MS = 0x00000001  #: Milliseconds.

    #: PCM samples, related to milliseconds * samplerate / 1000.
    PCM = 0x00000002

    #: Bytes, related to PCM samples * channels * datawidth (ie 16bit = 2
    #: bytes).
    PCMBYTES = 0x00000004

    #: Raw file bytes of (compressed) sound data (does not include headers).
    #: Only used by :py:meth:`~pyfmodex.sound.Sound.get_length` and
    #: :py:meth:`~pyfmodex.channel.Channel.get_position`.
    RAWBYTES = 0x00000008

    #: Fractions of one PCM sample. Unsigned int range 0 to 0xFFFFFFFF. Used for
    #: sub-sample granularity for :py:class:`~pyfmodex.dsp.DSP` purposes.
    PCMFRACTION = 0x00000010

    #: MOD/S3M/XM/IT. Order in a sequenced module format. Use
    #: :py:attr:`~pyfmodex.sound.Sound.format` to determine the PCM format
    #: being decoded to.
    MODORDER = 0x00000100

    #: MOD/S3M/XM/IT. Current row in a sequenced module format. Cannot use with
    #: :py:meth:`~pyfmodex.channel.Channel.set_position`.
    #: :py:meth:`~pyfmodex.sound.Sound.get_length` will return the number of
    #: rows in the currently playing or seeked to pattern.
    MODROW = 0x00000200

    #: MOD/S3M/XM/IT. Current pattern in a sequenced module format. Cannot use
    #: with :py:meth:`~pyfmodex.channel.Channel.set_position`.
    #: :py:meth:`~pyfmodex.sound.Sound.get_length` will return the number of
    #: patterns in the song and
    #: :py:meth:`~pyfmodex.channel.Channel.get_position` will return the
    #: currently playing pattern.
    MODPATTERN = 0x00000400


class OUTPUT_METHOD(IntEnum):
    """Output method used to interact with the mixer.

    If the hardware presents a ring buffer without synchronization primitives
    :py:attr:`POLLING` is the recommended approach where FMOD will call
    into the plugin regularly to check the play position of the buffer.

    For hardware that presents a callback that must be filled immediately
    :py:attr:`MIX_BUFFERED` is recommended as buffering occurs in a separate
    thread, reading from the mixer is simply a memcpy.

    Using :py:attr:`MIX_DIRECT` is recommended if you want to take direct
    control of how and when the mixer runs.
    """

    #: Mixer will execute directly when calling
    #: :py:data:`~pyfmodex.function_prototypes.OUTPUT_READFROMMIXER`, buffering
    #: must be performed by plugin code.
    MIX_DIRECT = 0

    #: Mixer will execute and buffer indirectly (on a separate thread) in
    #: response to
    #: :py:data:`~pyfmodex.callback_prototypes.OUTPUT_GETPOSITION_CALLBACK` /
    #: :py:data:`~pyfmodex.callback_prototypes.OUTPUT_LOCK_CALLBACK` /
    #: :py:data:`~pyfmodex.callback_prototypes.OUTPUT_UNLOCK_CALLBACK`.
    POLLING = 1

    #: Mixer will execute and buffer automatically (on a separate thread) and
    #: can be read from with
    #: :py:data:`~pyfmodex.function_prototypes.OUTPUT_READFROMMIXER`.
    MIX_BUFFERED = 2
