(enable_chatting)

(defun chat_input (str)
  (if (and (> (length str) 0) (equal (elt str 0) #\/))
      (if (and (search "/nick " str) (> (length str) 6))
	  (chat_print (concatenate 'string "# " (player_name) " is known as "
				   (progn (set_player_name (substr 6 (- (length str) 1) str))
					  (player_name))))
	(if (search "/help" str)
	    (if (local_player)
		(chat_print "Commands : /nick name, /help"))
	(if (local_player)
	    (chat_print (concatenate 'string "unknown command " str)))))

    (chat_print (concatenate 'string "<" (player_name) "> " str))))
