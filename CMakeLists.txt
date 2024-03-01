# STM32 Minimal CMake project for C/C++ projects
cmake_minimum_required(VERSION 3.12)

include(./cmake/gcc-arm-none-eabi.cmake)
include(./cmake/cpu-params.cmake)

###############################################################################
# PROJECT & BOARD SETUP - update these to match your project
# if you don't intend to use a Makefile then delete all the if statements

# set project name. Allows input from Makefile
if ("${PROJECT_NAME}" STREQUAL "")
    set(PROJECT_NAME firmware)
endif()
project(${PROJECT_NAME})

# Set MCU family (i.e. STM32U5xx) and model (i.e. STM32U5A5xx)
if ("${MCU_FAMILY}" STREQUAL "")
    set(MCU_FAMILY STM32U5xx)
endif()
if ("${MCU_MODEL}" STREQUAL "")
    set(MCU_MODEL STM32U5A5xx)
endif()

# Automatically set MCU parameters. Use set(CPU_PARAMETERS ...) for manual setup
# Found in STM32CubeIDE > Properties for [project] > C/C++ Build > Settings > MCU GCC Linker
set_cpu_params(${MCU_FAMILY})

# Automatically imports the linker scripts and startup files
# Set specifically if you have more than one for some reason
file(GLOB STARTUP_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/board-support/Core/Startup/*.s)
file(GLOB MCU_LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/board-support/*_FLASH.ld)

# Set debug mode as default. Allows input from Makefile
if ("${CMAKE_BUILD_TYPE}" STREQUAL "")
    set(CMAKE_BUILD_TYPE Debug)
endif()
message("Build type: ${CMAKE_BUILD_TYPE}")

# If everything is in C, only enable C
# enable_language(C CXX ASM)
enable_language(C ASM)

###############################################################################
# COMPILER SETTINGS - no need to touch
set(EXECUTABLE_NAME ${CMAKE_PROJECT_NAME})

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
set(CMAKE_CXX_EXTENSIONS ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

###############################################################################
# ADD SOURCES - currently does globbing for speedy prototyping
# If making for more critical applications, consider adding sources manually

# include directories
set(STM32CUBEMX_INCLUDE_DIRECTORIES
    ${CMAKE_CURRENT_SOURCE_DIR}/board-support/Core/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/board-support/Drivers/${MCU_FAMILY}_HAL_Driver/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/board-support/Drivers/${MCU_FAMILY}_HAL_Driver/Inc/Legacy
    ${CMAKE_CURRENT_SOURCE_DIR}/board-support/Drivers/CMSIS/Device/ST/${MCU_FAMILY}/Include
    ${CMAKE_CURRENT_SOURCE_DIR}/board-support/Drivers/CMSIS/Include)

set(PROJECT_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR}/include)

# sources
file(GLOB_RECURSE STM32CUBEMX_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/board-support/Core/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/board-support/Drivers/CMSIS/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/board-support/Drivers/${MCU_FAMILY}_HAL_DRIVER/Src/*.c)

file(GLOB_RECURSE PROJECT_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c)

add_executable(${EXECUTABLE_NAME}
    ${STM32CUBEMX_SOURCES} 
    ${PROJECT_SOURCES}
    ${STARTUP_SCRIPT})

target_compile_definitions(${EXECUTABLE_NAME} PRIVATE
    #$<$<CONFIG:Debug>:DEBUG>
    ${MCU_MODEL}
    USE_HAL_DRIVER)

target_include_directories(${EXECUTABLE_NAME} SYSTEM PRIVATE
    ${STM32CUBEMX_INCLUDE_DIRECTORIES})

target_include_directories(${EXECUTABLE_NAME} PRIVATE
    ${PROJECT_INCLUDE_DIRECTORIES})

###############################################################################
# COMPILER & LINKER SETTINGS - no need to touch
# Most of these are pulled from the STM32CubeIDE project settings

# Check if the wildcard imports resolved to valid file paths
if(NOT STARTUP_SCRIPT)
    message(FATAL_ERROR "No startup script found")
endif()
if(NOT MCU_LINKER_SCRIPT)
    message(FATAL_ERROR "No linker script found")
endif()

# Print the resolved file paths for verification
message("Startup script: ${STARTUP_SCRIPT}")
message("MCU linker script: ${MCU_LINKER_SCRIPT}")

# Found in Properties for <project> -> C/C++ Build -> Settings -> MCU GCC Compiler
target_compile_options(${EXECUTABLE_NAME} PRIVATE
    -mthumb
    ${CPU_PARAMETERS}
    -Wall
    -Wextra
    -Wpedantic
    -Wshadow
    -Wdouble-promotion
    -Wformat=2 -Wformat-truncation
    -Wundef
    -fno-common
    -Wno-unused-parameter
    $<$<COMPILE_LANGUAGE:CXX>:
        -Wconversion
        -Wno-volatile
        -Wold-style-cast
        -Wuseless-cast
        -Wsuggest-override>
    $<$<CONFIG:Debug>:-Og -g3 -ggdb>
    $<$<CONFIG:Release>:-Og -g0>)

# Found in Properties for <project> -> C/C++ Build -> Settings -> MCU GCC Linker
target_link_options(${EXECUTABLE_NAME} PRIVATE
    -T${MCU_LINKER_SCRIPT}
    ${CPU_PARAMETERS}
    --specs=nosys.specs
    -mthumb
    -Wl,-Map=${CMAKE_PROJECT_NAME}.map
    $<$<VERSION_GREATER:$<C_COMPILER_VERSION>,10.3.1>:-Wl,--no-warn-rwx-segments>
    -Wl,--start-group
    -lc
    -lm
    -lstdc++
    -Wl,--end-group
    -Wl,--print-memory-usage)


###############################################################################

# The last command can take a couple of seconds on larger project, useful for debugging
add_custom_command(TARGET ${EXECUTABLE_NAME} POST_BUILD
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${EXECUTABLE_NAME}>
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${EXECUTABLE_NAME}> ${EXECUTABLE_NAME}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${EXECUTABLE_NAME}> ${EXECUTABLE_NAME}.bin)

option(DUMP_ASM "Create full assembly of final executable" OFF)
if (${DUMP_ASM})
    add_custom_command(TARGET ${EXECUTABLE_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJDUMP} -D -C $<TARGET_FILE:${EXECUTABLE_NAME}> > ${EXECUTABLE_NAME}.s)
endif()