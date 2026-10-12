# Loaded before the game's own scripts.
#
# The Russian translation (see README, Translations) ships a Steamworks
# achievements script that calls Win32API.new('steam_api', ...) at load time.
# There is no steam_api native library here, so mkxp-z's own Win32API raises
# and the game dies before the title screen. Replacing the class with an inert
# stub makes those calls no-ops.
#
# The game itself never uses Win32API, so this changes nothing when the
# translation is not installed.
class Win32API
  def initialize(*args); end
  def call(*args); 0; end
end
