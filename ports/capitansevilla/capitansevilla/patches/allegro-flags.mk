SEV = /root/compile/sevilla
A5 = $(SEV)/allegro5
AL = $(SEV)/allegro-legacy
AL_INC = -I$(AL)/build-pm/include -I$(AL)/include \
         -I$(A5)/build-pm/include -I$(A5)/include \
         -I$(A5)/addons/audio -I$(A5)/addons/image -I$(A5)/addons/font -I$(A5)/addons/primitives -I$(A5)/addons/acodec
AL_LIBS = -L$(AL)/build-pm/lib -L$(A5)/build-pm/lib -lalleg -lallegro_audio -lallegro
