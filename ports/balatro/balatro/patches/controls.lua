-- What a handheld needs from the game whatever it looks like.
--
-- This is neither a layout nor a performance choice: it is that a handheld has
-- no escape key, which is as true of the original Balatro layout as of the
-- small screen one -- that answer is about the desktop's arrangement of the
-- screen, not about the desktop's hardware. So it is loaded in both.
--
-- Which physical button is which used to be answered here too, from a list of
-- devices known to print their letters in the other order. The button setup the
-- launcher runs asks the device in front of the player instead, and corrects the
-- pad below the game where every prompt is drawn from, so the list is gone.

-- Start opens the pause menu, and closes it again. The stock controller binds
-- that to the escape key alone -- as a gamepad button Start does nothing outside
-- the splash screen -- so on a handheld there is no way to reach it. Two claims
-- come first, in the order the stock handler would resolve them: a tutorial step
-- owns the button while its Skip prompt is up, and any on-screen button that has
-- registered Start keeps it. Menus that refuse the escape key are left closed.
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
