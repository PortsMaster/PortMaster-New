(pingus-controller
 (standard-pointer
  (core:axis-pointer
   (x-axis (sdl:joystick-axis (device 1) (axis 0)))
   (y-axis (sdl:joystick-axis (device 1) (axis 1)))))

 (standard-scroller
  (core:axis-scroller
   (x-axis (sdl:joystick-axis (device 1) (axis 4)))
   (y-axis (sdl:joystick-axis (device 1) (axis 3)))))

 (primary-button
  (sdl:joystick-button (device 1) (button 0)))

 (secondary-button
  (sdl:joystick-button (device 1) (button 1)))

 (pause-button
  (sdl:joystick-button (device 1) (button 6))
  (sdl:joystick-button (device 1) (button 5)))

 (fast-forward-button
  (sdl:joystick-button (device 1) (button 10))
  (sdl:joystick-button (device 1) (button 4)))

 (armageddon-button
  (sdl:joystick-button (device 1) (button 7)))

 (escape-button
  (sdl:keyboard-button (key "escape")))

 (action-axis
  (sdl:joystick-axis (device 1) (axis 7)))

 (action-up-button
  (sdl:joystick-button (device 1) (button 2)))

 (action-down-button
  (sdl:joystick-button (device 1) (button 3)))
 )

;; EOF ;;
