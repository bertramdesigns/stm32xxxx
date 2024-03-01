#!/bin/bash

# absolute directory path to the project root
export PROJECT_ROOT_DIR="/Users/dylanbertram/Dev/projects_embedded/_hmi_test_rig/code_stm32u5a5/_STM32u5-local-template"

############################################################################################################
# OPTIONS
export CREATE_MAIN_H=true
export CREATE_MAIN_C=true

export FORCE_OVERWRITE_MAIN_H=false
export FORCE_OVERWRITE_MAIN_C=false

############################################################################################################

# Default log path is the project root directory
export LOG_PATH="."
export LOG_FILE_NAME="cubemx-scripts.log"

# Default Project paths
export PROJECT_SRC_DIR="$PROJECT_ROOT_DIR/src"
export PROJECT_INC_DIR="$PROJECT_ROOT_DIR/include"

# Default CubeMX paths for Application Structure: Advanced
export CUBEMX_CORE_DIR="$PROJECT_ROOT_DIR/board-support/Core"

# CubeMX directory paths before renaming
export CUBEMX_MAIN_C_PATH="$CUBEMX_CORE_DIR/Src/main.c"
export CUBEMX_MAIN_H_PATH="$CUBEMX_CORE_DIR/Inc/main.h"

# CubeMX directory paths after renaming
export CUBEMX_BSP_MAIN_C_PATH="$CUBEMX_CORE_DIR/Src/bsp_main.c"
export CUBEMX_BSP_MAIN_H_PATH="$CUBEMX_CORE_DIR/Inc/bsp_main.h"
