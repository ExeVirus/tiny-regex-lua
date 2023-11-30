cmake_minimum_required(VERSION 2.8.6)

project(tiny-regex)

IF (NOT CMAKE_BUILD_TYPE)
 SET(CMAKE_BUILD_TYPE "Release")
ENDIF (NOT CMAKE_BUILD_TYPE)

macro(remove_cxx_flag flag)
	string(REPLACE "${flag}" "" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
endmacro()

remove_cxx_flag("-O3")
SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -Ofast")

add_custom_command(
	DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/re.idl
	OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/re.cpp
	COMMAND lua-webidl ${CMAKE_CURRENT_SOURCE_DIR}/re.idl ${CMAKE_CURRENT_SOURCE_DIR}/bindings.cpp ${CMAKE_CURRENT_SOURCE_DIR}/re.h --libmode --cpp
)

set(EXECUTABLE_OUTPUT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/bin")

include_directories(
	"${CMAKE_CURRENT_SOURCE_DIR}/c/include/"
)
add_executable(
	re.wasm ${CMAKE_CURRENT_SOURCE_DIR}/bindings.cpp
)
target_link_libraries(
	re.wasm
)

add_custom_command(
	DEPENDS re.wasm
	OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.lua
	COMMAND wasm2lua ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.wasm ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.lua -b ${CMAKE_CURRENT_SOURCE_DIR}/re.idl --libmode --jmpstreamThreshold 4000
)

add_custom_command(
	DEPENDS re.wasm
	OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.min.lua
	COMMAND wasm2lua ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.wasm ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.min.lua -b ${CMAKE_CURRENT_SOURCE_DIR}/bindings.idl --libmode --minify 3 --discardExportSymbols --jmpstreamThreshold 4000
)

add_custom_command(
	DEPENDS re.wasm
	OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.pure.lua
	COMMAND wasm2lua ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.wasm ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.pure.lua -b ${CMAKE_CURRENT_SOURCE_DIR}/bindings.idl --libmode --pureLua --jmpstreamThreshold 4000
)

add_custom_command(
	DEPENDS re.wasm
	OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.pure.min.lua
	COMMAND wasm2lua ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.wasm ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.pure.min.lua -b ${CMAKE_CURRENT_SOURCE_DIR}/bindings.idl --libmode --pureLua --minify 3 --jmpstreamThreshold 4000
)

add_custom_target(re_lua ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.lua)
add_custom_target(re_lua_min ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.min.lua)
add_custom_target(re_purelua ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.pure.lua)
add_custom_target(re_purelua_min ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/bin/re.pure.min.lua)
