# Stand-in for fmod_toolkit (FMOD audio export), which UnityPy imports at start-up. The converter
# never exports audio, and FMOD's library may not be redistributed, so it is left out.
def raw_to_wav(*args, **kwargs):
    raise RuntimeError("audio export is not available in this build")
