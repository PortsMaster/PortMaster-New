## Notes
Thanks to the [Bos Wars Team](https://www.boswars.org/) for creating this awesome RTS.


## Controls

The following instructions are for a right-facing character. 

| Button | Action |
|--|--| 
|Select| ESC|
|A| Left Mouse |
|B| Right Mouse |
|X| Slow Mouse Down|
|Y| Stop Unit| 
|L1 / R1| Increase / Decrease Gamespeed | 
|R2| Go to last Event|
|L2| Options Menu|

## Compile ## 

```bash
git clone https://codeberg.org/boswars/boswars.git

--- boswars2/fabricate.py	2024-09-01 17:46:19.776593866 +0000
+++ boswars/fabricate.py	2024-08-30 18:01:53.943668810 +0000
@@ -711,7 +711,7 @@
         return False
 
 # default Builder instance, used by helper run() and main() helper functions
-default_builder = Builder()
+default_builder = Builder(runner='always_runner')
 default_command = 'build'
 
 def setup(builder=None, default=None, **kwargs):


--- boswars2/make.py	2024-09-01 17:46:19.826593888 +0000
+++ boswars/make.py	2024-08-31 21:34:52.641632134 +0000
@@ -298,7 +298,7 @@
     sys.exit(1)
 
 def detectAlwaysDynamic(b):
-    RequireLib(b, 'z', 'zlib.h')
+    #RequireLib(b, 'z', 'zlib.h')
     detectSdl(b)
     if Check(b, function='strcasestr'):
        b.define('HAVE_STRCASESTR')
@@ -309,13 +309,16 @@
 
 def detectEmbedable(b):
     detectLua(b)
-    RequireLib(b, 'png', 'png.h')
     if CheckLib(b, 'vorbis'):
        b.define('USE_VORBIS')
     if CheckLib(b, 'theora', function='theora_decode_packetin'):
        b.define('USE_THEORA')
     if CheckLib(b, 'ogg'):
        b.define('USE_OGG')
+    if CheckLib(b, 'png'):
+       b.define('USE_PNG')
+    if CheckLib(b, 'z'):
+        b.define('USE_ZLIB')
 
 def detect(b):
     detectAlwaysDynamic(b)

```