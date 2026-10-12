# Loaded before the game's own scripts (see mkxp.json, preloadScript).
#
# Two things the Windows runtime does for free and mkxp-z does not.
#
# 1. Win32API
#
# The Russian translation (see README, Translations) ships a Steamworks
# achievements script that calls Win32API.new('steam_api', ...) at load time.
# There is no steam_api native library here, so mkxp-z's own Win32API raises
# and the game dies before the title screen. Replacing the class with an inert
# stub makes those calls no-ops.
#
# The game itself never uses Win32API, so this changes nothing when no
# translation is installed.
class Win32API
  def initialize(*args); end
  def call(*args); 0; end
end

# 2. Graphics.resize_screen
#
# RGSS3 caps the screen at 640x480 and silently clamps anything larger, so a
# script asking for more still gets 640x480 on Windows. mkxp-z honours the
# request instead. The Russian translation asks for 1920x1040, which on the
# Windows build is simply clamped away but here would render the whole game
# into a 1920x1040 buffer and squeeze it onto a 640x480 panel.
#
# Restoring the RGSS3 cap keeps the game at its native 640x480 whatever a
# script asks for. The game's own scripts ask for exactly 640x480, so this
# changes nothing when no translation is installed.
module Graphics
  class << self
    alias_method :rgss3_uncapped_resize_screen, :resize_screen
    def resize_screen(width, height)
      rgss3_uncapped_resize_screen([width, 640].min, [height, 480].min)
    end
  end
end
