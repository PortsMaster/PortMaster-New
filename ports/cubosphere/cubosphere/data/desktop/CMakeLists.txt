set(INSTALL_DESKTOP UNIX CACHE BOOL "Install linux icons and .desktop")

if(INSTALL_DESKTOP)
	install(DIRECTORY applications icons DESTINATION "${CMAKE_INSTALL_FULL_DATADIR}" COMPONENT BIN)
endif()
