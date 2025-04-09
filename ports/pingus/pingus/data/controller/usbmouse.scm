(pingus-controller
 (standard-pointer
  (usbmouse:pointer (device "/dev/input/mx500")))

 (standard-scroller
  (usbmouse:scroller (device "/dev/input/marblemouse")))

 (primary-button
  (usbmouse:button (device "/dev/input/mx500") (button 0)))

 (secondary-button
  (usbmouse:button (device "/dev/input/mx500") (button 1)))

 (pause-button
  (usbmouse:button (device "/dev/input/mx500") (button 4)))

 (fast-forward-button
  (usbmouse:button (device "/dev/input/mx500") (button 3)))

;; (armageddon-button
;;  (usbmouse:button (device "/dev/input/mx500") (button 4)))

 (escape-button
  (sdl:keyboard-button (key "escape")))

 (action-up-button
  (usbmouse:button (device "/dev/input/mx500") (button 6))) 

 (action-down-button
  (usbmouse:button (device "/dev/input/mx500") (button 5)))
 )

;; EOF ;;
