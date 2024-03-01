#!/bin/bash

# if CubeMX can't run the file, run `chmod +x post-gen-script.sh` in the terminal
SCRIPT_ROOT_DIR=$(dirname "$0")

# includes
source $SCRIPT_ROOT_DIR/config.sh

source $SCRIPT_ROOT_DIR/tasks/main.sh
source $SCRIPT_ROOT_DIR/tasks/bsp-main.sh
source $SCRIPT_ROOT_DIR/tasks/error-handler.sh
source $SCRIPT_ROOT_DIR/tasks/entry.sh

source $SCRIPT_ROOT_DIR/utils/errors.sh
source $SCRIPT_ROOT_DIR/utils/dir_checks.sh

echo "begining post-gen-script.sh"

# Check if project directory is set
if [ "$PROJECT_ROOT_DIR" = "" ]; then
    echo "ERROR: Project root directory is not set."
    echo "Set PROJECT_ROOT_DIR in ./cubemx-gen-scripts/config.sh"
    exit 1
fi

# Check if product directory is valid and exit with error message if not
if [ ! -d "$PROJECT_ROOT_DIR" ]; then
    echo "ERROR: Project root directory does not exist."
    exit 1
fi

# Change to the directory containing the project
cd $PROJECT_ROOT_DIR || exit

# delete old files
rm -f $LOG_PATH/$LOG_FILE_NAME
rm -f $CUBEMX_BSP_MAIN_C_PATH
rm -f $CUBEMX_BSP_MAIN_H_PATH

# initialize new log file
echo -e "
CubeMX Post-Generation Script Log
#################################

Your project root directory is:
'$PROJECT_ROOT_DIR'

Current directory is:
'$PWD'

Note: These should match.

#################################
_________________________________
ERRORS:

_________________________________
LOG:

" >$LOG_PATH/$LOG_FILE_NAME

# Check that project directories exist & config.sh paths are correct
check_directories

# backup main.c and main.h files
cp $CUBEMX_MAIN_C_PATH $CUBEMX_MAIN_C_PATH.bak
cp $CUBEMX_MAIN_H_PATH $CUBEMX_MAIN_H_PATH.bak

############################################################################################################

### Initialize project files --------------------------- ###
create_main_h
create_main_c

# main.h file copied so needs to be re-configured
# HAL defines remain in bsp_main.h, so remove
# no exports yet, so remove all exports
if [ $MAIN_H_CREATED = true ]; then
    clear_main_h_exports
fi

# move debug error handler to project directory
create_error_handler_c
create_error_handler_h

if [ $MAIN_C_CREATED = true ]; then
    delete_main_c_error_handler
fi

### remove CubeMX main entry (main -> bsp_main) ------- ###
rename_to_bsp_main_h
rename_to_bsp_main_c

# *_hal_msp.c  & *_it.c now need to include bsp_main.h
migrate_hal_includes

# debug error handler moved to project directory. Update includes
delete_bsp_main_error_handler
migrate_bsp_main_to_proj_error_handler

# all functions should be exported to be accessed in project main
export_all_bsp_main_functions

### Move main() entry to project main --------------- ###

delete_bsp_main_c_entry


if [ $MAIN_C_CREATED = false ]; then
    # auto check all the functions from generated init match the main loop init
    # for manual ref, check main_loop.bak
    check_main_c_entry
fi

############################################################################################################
