# Runtime patch, not an edit to the game's own Game.rgssad.
#
# Window_Name#set_name unconditionally rebuilds its bitmap and issues 5
# draw_text calls every time it's called, even when the name text hasn't
# changed. reset_window calls it every frame while a message is anchored
# to an event, so any multi-line line from the same speaker redoes this
# needless work 60x/sec - verified this is the actual cost, not just the
# per-frame reset_window call itself (RPG::Cache-backed bitmap lookups in
# the same method are already memoized and cheap).
#
# Applied via a TracePoint instead of editing Scripts.rxdata directly:
# Window_Name is defined by the game's own scripts, which haven't run yet
# when preloadScript files execute, so the class can't be reopened early
# without risking a superclass mismatch once the real definition runs.
tp = TracePoint.new(:end) do |t|
  if t.self.is_a?(Module) && t.self.name == "Window_Name"
    t.self.class_eval do
      def set_name(name)
        return if @name == name
        @name = name
        refresh
      end
    end
    t.disable
  end
end
tp.enable
