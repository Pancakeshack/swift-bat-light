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
# Generated Cmake Pico project file

cmake_minimum_required(VERSION 3.29)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Standard SDK Setup
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

set(PICO_BOARD pico2_w CACHE STRING "Board type")
include(pico_sdk_import.cmake)

set(CMAKE_Swift_COMPILATION_MODE wholemodule)
set(CMAKE_Swift_COMPILER_WORKS YES)

project(swift-bat-light C CXX ASM)

pico_sdk_init()
enable_language(Swift)

# --- 1. Include Protomatter Directories ---
include_directories(${CMAKE_CURRENT_LIST_DIR}/lib/protomatter)

add_executable(swift-bat-light
    Main.swift
    Matrix.swift
    Glue.c                  
    lib/protomatter/core.c 
)

pico_enable_stdio_uart(swift-bat-light 1)
pico_enable_stdio_usb(swift-bat-light 1)

set_target_properties(swift-bat-light PROPERTIES LINKER_LANGUAGE CXX)

# --- 3. Link Required Hardware Libraries ---
# Protomatter needs: hardware_pwm, hardware_timer, hardware_irq, hardware_clocks
# Swift needs: atomic (for thread safety checks)
target_link_libraries(swift-bat-light
    pico_stdlib
    pico_multicore 
    hardware_uart 
    hardware_gpio 
    pico_lwip_arch 
    pico_cyw43_arch_none
    hardware_pwm
    hardware_timer
    hardware_irq
    hardware_clocks
)

# Standard Swift Configuration (No changes needed below here usually)
set_target_properties(pico_standard_link PROPERTIES INTERFACE_COMPILE_OPTIONS "")
target_compile_options(pico_standard_link INTERFACE "$<$<COMPILE_LANGUAGE:C>:SHELL: -ffunction-sections -fdata-sections>")

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

gather_compile_definitions_recursive(swift-bat-light)
get_property(COMPILE_DEFINITIONS GLOBAL PROPERTY compilerdefs_list)

list(REMOVE_DUPLICATES COMPILE_DEFINITIONS)
list(PREPEND COMPILE_DEFINITIONS "")
string(REPLACE "$<TARGET_PROPERTY:PICO_TARGET_BINARY_TYPE>" "$<TARGET_PROPERTY:swift-bat-light,PICO_TARGET_BINARY_TYPE>" COMPILE_DEFINITIONS "${COMPILE_DEFINITIONS}")
string(REPLACE ";" " -Xcc -D" COMPILE_DEFINITIONS "${COMPILE_DEFINITIONS}")

set(IMPLICIT_INCLUDES)
foreach(dir ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES})
    string(CONCAT IMPLICIT_INCLUDES ${IMPLICIT_INCLUDES} "-Xcc -I${dir} ")
endforeach()
foreach(dir ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
    string(CONCAT IMPLICIT_INCLUDES ${IMPLICIT_INCLUDES} "-Xcc -I${dir} ")
endforeach()

# --- 4. Ensure Swift Finds the C Header ---
target_compile_options(swift-bat-light PUBLIC
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:
        -target armv6m-none-none-eabi
        -enable-experimental-feature Embedded
        -parse-as-library
        -module-name swift_blinky
        -Xcc -fshort-enums
        -Xfrontend -function-sections
        -import-bridging-header ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
        -Xcc -I${CMAKE_CURRENT_LIST_DIR}/lib/protomatter
        ${COMPILE_DEFINITIONS}
        ${IMPLICIT_INCLUDES}
    >")

pico_add_extra_outputs(swift-bat-light)