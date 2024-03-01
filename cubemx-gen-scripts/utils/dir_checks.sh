#!/bin/bash

check_directories() {
    echo "beginning check_directories"

    # check if src directory exists and write to log file
    if [ ! -d $PROJECT_SRC_DIR ]; then
        echo -e "\n[$PROJECT_SRC_DIR] does not exist in project root: '$PROJECT_SRC_DIR'/
        Skipping main.c file creation./
        Check project source directory in config.sh/
        " >>$LOG_PATH/$LOG_FILE_NAME
        exit 1
    fi

    # check if include directory exists and write to log file
    if [ ! -d $PROJECT_INC_DIR ]; then
        echo -e "\n["'$PROJECT_INC_DIR'"] does not exist in project root: '$PROJECT_INC_DIR'/
        Skipping main.h file creation./
        Check project include directory in config.sh/
        " >>$LOG_PATH/$LOG_FILE_NAME
        exit 1
    fi

    # check if /board-support/Core directory exists
    if [ ! -d $CUBEMX_CORE_DIR ]; then
        echo -e "\n["'$CUBEMX_CORE_DIR'"] ./Core directory does not exist./
        Check if the Application Structure in CubeMX is set to Advanced./
        Check config.sh matches project structure/
        " >>$LOG_PATH/$LOG_FILE_NAME
        exit 1
    fi

    # check if /board-support/Core/Src directory exists
    if [ ! -d "$CUBEMX_CORE_DIR/Src" ]; then
        echo -e "\n["'$CUBEMX_CORE_DIR'"] ./Src does not exist in $CUBEMX_CORE_DIR\n" >>$LOG_PATH/$LOG_FILE_NAME
        exit 1
    fi

    # check if /board-support/Core/Inc directory exists
    if [ ! -d "$CUBEMX_CORE_DIR/Inc" ]; then
        echo -e "\n["'$CUBEMX_CORE_DIR'"] ./Inc does not exist in $CUBEMX_CORE_DIR\n" >>$LOG_PATH/$LOG_FILE_NAME
        exit 1
    fi
}
