ECHO OFF
CLS
BREAK ON
IF "%1"=="" GOTO options
ECHO     浜様様様様様様様様様様様様様様様様様様様様融
ECHO     �    Installation        : Another World   �
ECHO     藩様様様様様様様様様様様様様様様様様様様様夕
ECHO �
ECHO This game requires 1.5 Megabyte of disk space.
ECHO �
ECHO You can cancel at anytime by pressing CTRL-C.
ECHO �
PAUSE
:disk1
IF EXIST VOL.1 GOTO copyd1
ECHO �
ECHO Please insert disk 1.
PAUSE
IF EXIST VOL.1 GOTO copyd1
GOTO disk1
:copyd1
ECHO �
ECHO Installing...
ECHO �
MD %1\AWDEMO
COPY *.* %1\AWDEMO > NUL
IF EXIST VOL.END GOTO WellDone
:disk2
CLS
ECHO  �
ECHO     浜様様様様様様様様様様様様様様様様様様様様融
ECHO     �    Installation        : Another World   �
ECHO     藩様様様様様様様様様様様様様様様様様様様様夕
ECHO �
ECHO Please insert disk 2.
PAUSE
IF EXIST VOL.2 GOTO copyd2
GOTO disk2
:copyd2
CLS
ECHO �
ECHO     浜様様様様様様様様様様様様様様様様様様様様融
ECHO     �    Installation        : Another World   �
ECHO     藩様様様様様様様様様様様様様様様様様様様様夕
ECHO �
ECHO Installing...
ECHO �
COPY *.* %1\AWDEMO > NUL
IF EXIST VOL.END GOTO WellDone
:disk3
CLS
ECHO �
ECHO     浜様様様様様様様様様様様様様様様様様様様様融
ECHO     �    Installation        : Another World   �
ECHO     藩様様様様様様様様様様様様様様様様様様様様夕
ECHO �
ECHO Please insert disk 3.
PAUSE
IF EXIST VOL.3 GOTO copyd3
GOTO disk3
:copyd3
CLS
ECHO �
ECHO     浜様様様様様様様様様様様様様様様様様様様様融
ECHO     �    Installation        : Another World   �
ECHO     藩様様様様様様様様様様様様様様様様様様様様夕
ECHO �
ECHO Installing...
ECHO �
COPY *.* %1\AWDEMO > NUL
IF EXIST VOL.END GOTO WellDone
:disk4
CLS
ECHO �
ECHO     浜様様様様様様様様様様様様様様様様様様様様融
ECHO     �    Installation        : Another World   �
ECHO     藩様様様様様様様様様様様様様様様様様様様様夕
ECHO �
ECHO Please insert disk 4.
PAUSE
IF EXIST VOL.4 GOTO copyd4
GOTO disk4
:copyd4
CLS
ECHO �
ECHO     浜様様様様様様様様様様様様様様様様様様様様融
ECHO     �    Installation        : Another World   �
ECHO     藩様様様様様様様様様様様様様様様様様様様様夕
ECHO �
ECHO Installing...
ECHO �
COPY *.* %1\AWDEMO > NUL
IF EXIST VOL.END GOTO WellDone
:disk5
CLS
ECHO �
ECHO     浜様様様様様様様様様様様様様様様様様様様様融
ECHO     �    Installation        : Another World   �
ECHO     藩様様様様様様様様様様様様様様様様様様様様夕
ECHO �
ECHO Please insert disk 5.
PAUSE
IF EXIST VOL.5 GOTO copyd5
GOTO disk5
:copyd5
CLS
ECHO �
ECHO     浜様様様様様様様様様様様様様様様様様様様様融
ECHO     �    Installation        : Another World   �
ECHO     藩様様様様様様様様様様様様様様様様様様様様夕
ECHO �
ECHO Installing...
ECHO �
COPY *.* %1\AWDEMO > NUL
:WellDone
%1
CD \AWDEMO
CONFIG
DEL %1\AWDEMO\INSTALL.BAT > NUL
CLS
ECHO �
ECHO     浜様様様様様様様様様様様様様様様様様様様様融
ECHO     �    Installation        : Another World   �
ECHO     藩様様様様様様様様様様様様様様様様様様様様夕
ECHO �
ECHO Installation is complete.
ECHO �
ECHO Please read the 'README' document before playing the game.
ECHO It contains last minute information not found in the manual.
ECHO
ECHO To start the game type:
ECHO �
ECHO AWDEMO
ECHO �
ECHO To view the 'README' document type 'TYPE README'
ECHO �
GOTO TheEnd
:options
ECHO To install the game on your hard disk type:
ECHO �
ECHO INSTALL [drive:]
ECHO �
ECHO For example, to install the game on the hard disk C, type:
ECHO �
ECHO INSTALL C:
ECHO �
GOTO TheEnd
:TheEnd
