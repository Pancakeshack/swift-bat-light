# Generated Cmake Pico project file

cmake_minimum_required(VERSION 3.29)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Initialise pico_sdk from installed location
# (note this can come from environment, CMake cache etc)

# == DO NOT EDIT THE FOLLOWING LINES for the Raspberry Pi Pico VS Code Extension to work ==
if(WIN32)
    set(USERHOME $ENV{USERPROFILE})
else()
    set(USERHOME $ENV{HOME})
endif()
set(sdkVersion 2.2.0)
set(toolchainVersion 14_2_Rel1)
set(picotoolVersion 2.2.0-a4)
set(picoVscode ${USERHOME}/.pico-sdk/cmake/pico-vscode.cmake)
if (EXISTS ${picoVscode})
    include(${picoVscode})
endif()
# ====================================================================================
set(PICO_BOARD pico2_w CACHE STRING "Board type")

# Pull in Raspberry Pi Pico SDK (must be before project)
include(pico_sdk_import.cmake)

set(CMAKE_Swift_COMPILATION_MODE wholemodule)
set(CMAKE_Swift_COMPILER_WORKS YES)

project(swift-blinky C CXX ASM)

# Initialise the Raspberry Pi Pico SDK
pico_sdk_init()
enable_language(Swift)

# Add executable. Default name is the project name, version 0.1
add_executable(swift-blinky
    # Source files:
    Main.swift
)

set_target_properties(swift-blinky PROPERTIES LINKER_LANGUAGE CXX)

# Pull in common dependencies
target_link_libraries(swift-blinky
    pico_stdlib hardware_uart hardware_gpio pico_lwip_arch pico_cyw43_arch_none
)

# Clear the default COMPILE_OPTIONS which include C specific compiler flags that the Swift compiler will not accept
# Instead, set those options to only apply when compiling C code.
set_target_properties(pico_standard_link PROPERTIES INTERFACE_COMPILE_OPTIONS "")
target_compile_options(pico_standard_link INTERFACE "$<$<COMPILE_LANGUAGE:C>:SHELL: -ffunction-sections -fdata-sections>")

# Gather C compile definitions from all dependencies
set_property(GLOBAL PROPERTY visited_targets "")
set_property(GLOBAL PROPERTY compilerdefs_list "")

function(gather_compile_definitions_recursive target)
    get_property(visited_targets GLOBAL PROPERTY visited_targets)
    
    if (${target} MATCHES "\\\$<" OR ${target} MATCHES "::@" OR ${target} IN_LIST visited_targets)
        return()
    endif()

    list(APPEND visited_targets ${target})
    set_property(GLOBAL PROPERTY visited_targets "${visited_targets}")

    get_target_property(target_definitions ${target} INTERFACE_COMPILE_DEFINITIONS)
    if (target_definitions)
        get_property(compilerdefs_list GLOBAL PROPERTY compilerdefs_list)
        list(APPEND compilerdefs_list ${target_definitions})
        set_property(GLOBAL PROPERTY compilerdefs_list "${compilerdefs_list}")
    endif()

    get_target_property(target_linked_libs ${target} INTERFACE_LINK_LIBRARIES)
    if (target_linked_libs)
        foreach(linked_target ${target_linked_libs})
            gather_compile_definitions_recursive(${linked_target})
        endforeach()
    endif()
endfunction()

gather_compile_definitions_recursive(swift-blinky)
get_property(COMPILE_DEFINITIONS GLOBAL PROPERTY compilerdefs_list)
get_property(INCLUDES GLOBAL PROPERTY includes_list)

# Convert compiler definitions into a format that swiftc can understand
list(REMOVE_DUPLICATES COMPILE_DEFINITIONS)
list(PREPEND COMPILE_DEFINITIONS "")
string(REPLACE "$<TARGET_PROPERTY:PICO_TARGET_BINARY_TYPE>" "$<TARGET_PROPERTY:swift-blinky,PICO_TARGET_BINARY_TYPE>" COMPILE_DEFINITIONS "${COMPILE_DEFINITIONS}")
string(REPLACE ";" " -Xcc -D" COMPILE_DEFINITIONS "${COMPILE_DEFINITIONS}")

# Compute -Xcc flags to set up the C and C++ header search paths for Swift (for bridging header).
set(IMPLICIT_INCLUDES)
foreach(dir ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES})
    string(CONCAT IMPLICIT_INCLUDES ${IMPLICIT_INCLUDES} "-Xcc ")
    string(CONCAT IMPLICIT_INCLUDES ${IMPLICIT_INCLUDES} "-I${dir} ")
endforeach()
foreach(dir ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
    string(CONCAT IMPLICIT_INCLUDES ${IMPLICIT_INCLUDES} "-Xcc ")
    string(CONCAT IMPLICIT_INCLUDES ${IMPLICIT_INCLUDES} "-I${dir} ")
endforeach()

target_compile_options(swift-blinky PUBLIC
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:
        -target armv6m-none-none-eabi
        -enable-experimental-feature Embedded
        -parse-as-library
        -module-name swift_blinky
        
        -Xcc -fshort-enums
        -Xfrontend -function-sections
        -import-bridging-header ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
        ${COMPILE_DEFINITIONS}
        ${IMPLICIT_INCLUDES}
    >")

# Create map/bin/hex file etc.
pico_add_extra_outputs(swift-blinky)
