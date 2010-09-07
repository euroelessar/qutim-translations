cmake_minimum_required (VERSION 2.6 FATAL_ERROR)

project( translations )

#include(MacroAddQutIMArtwork)
#find_package( QutIM REQUIRED )

file( GLOB LANGUAGES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/*/*.ts" )
set(LANG_DIR "${CMAKE_CURRENT_BINARY_DIR}/languages")
file( MAKE_DIRECTORY ${LANG_DIR} )

foreach( LANGUAGE ${LANGUAGES} )
	string( REPLACE ".ts" "" LANGUAGE_NAME ${LANGUAGE} )
	string( REGEX REPLACE "/*\\\\*[a-zA-Z0-9_-]+\\.ts" "" LANGUAGE_DIRECTORY_NAME ${LANGUAGE} )
	file( MAKE_DIRECTORY "${LANG_DIR}/${LANGUAGE_DIRECTORY_NAME}" )
	execute_process( COMMAND ${QT_LRELEASE_EXECUTABLE}
		-silent
		"${CMAKE_CURRENT_SOURCE_DIR}/${LANGUAGE}"
		-qm "${LANG_DIR}/${LANGUAGE_NAME}.qm"
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} )
	message(STATUS "Making ${LANGUAGE_NAME}")
endforeach( LANGUAGE )

QUTIM_ADD_ARTWORK(${LANG_DIR})
