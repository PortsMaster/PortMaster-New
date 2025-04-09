;; -*- scheme -*-

(pingus-controller
  (standard-pointer
   (sdl:mouse-pointer)
   (core:axis-pointer
    (x-axis (wiimote:axis (axis "nunchuk:x")))
    (y-axis (wiimote:axis (axis "nunchuk:y")))))

 (standard-scroller
  (core:axis-scroller
   (x-axis (wiimote:axis (axis "nunchuk:x")))
   (y-axis (wiimote:axis (axis "nunchuk:y")))))

 (primary-button
  (wiimote:button (button "a")))

 (secondary-button
  (wiimote:button (button "nunchuk:z")))

 (pause-button
  (wiimote:button (button "plus")))

 (fast-forward-button
  (wiimote:button (button "minus")))

 (armageddon-button
  (wiimote:button (button "home")))

 (escape-button
  (sdl:keyboard-button (key "escape")))

 (action-up-button
  (wiimote:button (button "up")))

 (action-down-button
  (wiimote:button (button "down")))
 )

;; EOF ;;
