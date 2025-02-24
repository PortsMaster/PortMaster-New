## Notes

Thanks to [Nikita Kryukov](https://nikita-kryukov.itch.io/pmkm) for making this and more nice visual novels

## Controls

| Button | Action |
|--|--| 
|A|Confirm |
|Up/Down/Left/Right|Movement|


## Compile

```shell
 this script will allow you to build renpy on ubuntu 20 on aarch64
 dynamically linking sdl2. It is assumed that this is a 
 throw-away environment! 
 This script should be run as root.

This script was originally run on commit 6e96dcb6762e56ec1830914e08b443cf68c19fa8
of renpy_build. You might need to move back to this commit in the future

##### install required packages 
uodpt install vim git sudo curl clang make libreadline-dev libsqlite3-dev libassimp-dev texinfo help2man libzstd-dev libsdl2-dev

##### need the correct version of cmake 
mkdir cmake
wget https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-linux-aarch64.sh
bash cmake*.sh --skip-license --prefix=/root/cmake
export PATH="/root/cmake/bin:$PATH"

##### need the correct version of autoconf
git clone git://git.sv.gnu.org/autoconf
cd autoconf
./configure && make && make install
cd ..
export PATH="/root/autoconf/bin:$PATH"

#####  need the correct version of ccache
wget https://github.com/ccache/ccache/releases/download/v4.5.1/ccache-4.5.1.tar.gz
tar xf ccache*
cd ccache-4.5.1
cmake -DREDIS_STORAGE_BACKEND=OFF . && make && make install
cd ..
export PATH="/root/ccache-4.5.1:$PATH"


#####  update assimp header files to be expected version.
#####  yes, this is very gross and bad, but we are assuming this is in a partitioned environment.
wget https://github.com/assimp/assimp/archive/refs/tags/v5.2.2.zip
unzip v5.2.2.zip
mv /usr/include/assimp/config.h assimp-5.2.2/include/assimp/
rm /usr/include/assimp/ -r
mv assimp-5.2.2/include/assimp/ /usr/include/


#####  setup correct python version
curl -fsSL https://pyenv.run | bash

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
eval "$(pyenv virtualenv-init -)"

pyenv install 3.12.4
pyenv global 3.12.4

git clone https://github.com/renpy/renpy-build.git
cd renpy-build

#####  download requesite tar files
cd tars
wget wget https://cubism.live2d.com/sdk-native/bin/CubismSdkForNative-4-r.6.2.zip
cd ..

./prepare.sh
source tmp/virtualenv.py3/bin/activate

#####  this does the following;
#####  * corrects some file names (x86_64 -> aarch64)
#####  * disables steam stuff so that we don't need that tar file
#####  * set sdl2 and sdl2_image to dynamically link
cat > patch_file <<EOF
diff --git a/tasks/__init__.py b/tasks/__init__.py
index ac12807..6cc1210 100644
--- a/tasks/__init__.py
+++ b/tasks/__init__.py
@@ -56,7 +56,7 @@ from . import zsync
 from . import sayvbs
 from . import angle

-from . import steam
+#from . import steam

 from . import pygame_sdl2
 from . import librenpy
diff --git a/tasks/python3.py b/tasks/python3.py
index 4ba9541..29eea61 100644
--- a/tasks/python3.py
+++ b/tasks/python3.py
@@ -106,7 +106,7 @@ def common_post(c: Context):

     c.copy("{{ host }}/bin/python3", "{{ install }}/bin/hostpython3")

-    for i in [ "_sysconfigdata__linux_x86_64-linux-gnu.py" ]:
+    for i in [ "_sysconfigdata__linux_aarch64-linux-gnu.py" ]:
         c.var("i", i)

         c.copy(
@@ -228,7 +228,7 @@ def build_web(c: Context):
     c.run("""{{ make }} install""")
     c.copy("{{ host }}/bin/python3", "{{ install }}/bin/hostpython3")

-    for i in [ "ssl.py", "_sysconfigdata__linux_x86_64-linux-gnu.py" ]:
+    for i in [ "ssl.py", "_sysconfigdata__linux_aarch64-linux-gnu.py" ]:
         c.var("i", i)

         c.copy(
diff --git a/tasks/pythonlib.py b/tasks/pythonlib.py
index 927cc20..0222bdb 100644
--- a/tasks/pythonlib.py
+++ b/tasks/pythonlib.py
@@ -201,8 +201,6 @@ pyobjus/

 pefile
 ordlookup/
-
-steamapi
 """


diff --git a/tasks/renpython.py b/tasks/renpython.py
index 83e1d96..12654d6 100644
--- a/tasks/renpython.py
+++ b/tasks/renpython.py
@@ -46,6 +46,8 @@ def link_linux(c: Context):

     c.run("""
     {{ CXX }} {{ LDFLAGS }}
+    -L/usr/lib/
+    -L/usr/lib/aarch64-linux-gnu/
     -shared
     -static-libstdc++
     -Wl,-Bsymbolic
EOF

git apply patch_file

./build.py --platforms linux --archs aarch64
rm tmp/install.linux-aarch64/libSDL2*
# one more time, but now it won't grab the SDL2 .a files
./build.py --platforms linux --archs aarch64



```
