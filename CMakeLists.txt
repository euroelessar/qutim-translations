cmake_minimum_required (VERSION 2.6 FATAL_ERROR)

project( translations )

set(QT_MIN_VERSION "4.6.0")
find_package( Qt4 REQUIRED )

file( GLOB LANGUAGES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/" "${CMAKE_CURRENT_SOURCE_DIR}/*/*.ts" )
file( MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/translations" )

foreach( LANGUAGE ${LANGUAGES} )
	string( REPLACE ".ts" "" LANGUAGE_NAME ${LANGUAGE} )
	string( REGEX REPLACE "/*\\\\*[a-zA-Z0-9_-]+\\.ts" "" LANGUAGE_DIRECTORY_NAME ${LANGUAGE} )
	file( MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/translations/${LANGUAGE_DIRECTORY_NAME}" )
	execute_process( COMMAND ${QT_LRELEASE_EXECUTABLE}
		-silent
		"${CMAKE_CURRENT_SOURCE_DIR}/${LANGUAGE}"
		-qm "${CMAKE_CURRENT_BINARY_DIR}/translations/${LANGUAGE_NAME}.qm"
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} )
endforeach( LANGUAGE )

