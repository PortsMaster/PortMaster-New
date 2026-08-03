local original_button_press_update = Controller.button_press_update
function Controller:button_press_update(button, dt)
    if button == 'start' and not self.locks.frame then
        if G.OVERLAY_TUTORIAL then
            self.frame_buttonpress = true
            G.FUNCS.skip_tutorial_section()
            return
        end
        local claimed = self.button_registry[button]
        claimed = claimed and claimed[1] and not claimed[1].node.under_overlay
        if not claimed then
            self.frame_buttonpress = true
            if G.STATE == G.STATES.SPLASH then
                G:delete_run()
                G:main_menu()
            elseif not G.OVERLAY_MENU then
                G.FUNCS:options()
            elseif not G.OVERLAY_MENU.config.no_esc then
                G.FUNCS:exit_overlay_menu()
            end
            return
        end
    end
    return original_button_press_update(self, button, dt)
end
