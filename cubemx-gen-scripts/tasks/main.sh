#!/bin/bash
# create a variable to indicate if main files were created
export MAIN_C_CREATED=false
export MAIN_H_CREATED=false

# duplicate main.c file from CubeMX to project source directory
# if main.c already exists and it is a forced overwrite, backup existing main.c

write_main_c(){
    main_c_txt='/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  */

/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "bsp_main.h"

/* typedef -----------------------------------------------------------*/

/* define ------------------------------------------------------------*/

/* macro -------------------------------------------------------------*/

/* variables ---------------------------------------------------------*/

/* function prototypes -----------------------------------------------*/


/**
  * @brief  The application entry point.
  * @retval int
  */'

    # write the new main.c file using the main_c_txt variable
    echo "$main_c_txt" >$PROJECT_SRC_DIR/main.c
    echo "[main.c] Created main.c file in the project source directory" >>$LOG_PATH/$LOG_FILE_NAME

if grep -q 'int main(void)' $PROJECT_SRC_DIR/main.c; then
    echo "[WARNING] main.c already contains main entry loop. Skipping copy." >>$LOG_PATH/$LOG_FILE_NAME
    return
fi

if grep -q 'int main(void)' $CUBEMX_MAIN_C_PATH; then
    # get all lines between (and including)"int main(void)" and "/* USER CODE END 3 */"
    # then insert them to the end of the new main.c file
    sed -n -e '/int main(void)/,/\/\* USER CODE END 3 \*\//{N; p;}' $CUBEMX_MAIN_C_PATH >>$PROJECT_SRC_DIR/main.c
    
    echo "[main.c] Appended main entry loop to main.c file" >>$LOG_PATH/$LOG_FILE_NAME
else
    echo "[WARNING] Failed to append main entry loop to main.c file. Could not find main() loop in CubeMX gnerated files." >>$LOG_PATH/$LOG_FILE_NAME
fi
}

create_main_c() {
    echo "beginning create_main_c"

    # if CREATE_MAIN_C is set to false, skip main.c file creation
    if [ $CREATE_MAIN_C = false ]; then
        echo "[main.c] Skipping main.c file creation. "'$CREATE_MAIN_C'" is set to false. " >>$LOG_PATH/$LOG_FILE_NAME
        return
    fi

    
    # check if main.c file already exists in the $PROJECT_SRC_DIR
    # if it does and FORCE_OVERWRITE_MAIN_C is set to true, write the warning and continue
    if [ -e "$PROJECT_SRC_DIR/main.c" ] && [ $FORCE_OVERWRITE_MAIN_C = true ]; then

        #backup existing main.c file
        exe_and_handle_error cp $PROJECT_SRC_DIR/main.c $PROJECT_SRC_DIR/main.c.bak

        echo "[main.c] Overwriting existing main.c file. "'$FORCE_OVERWRITE_MAIN_C'" is set to true." >>$LOG_PATH/$LOG_FILE_NAME
        rm -f $PROJECT_SRC_DIR/main.c
        write_main_c

        MAIN_C_CREATED=true

    # if it does  write the warning and skip main.c file creation
    elif [ -e "$PROJECT_SRC_DIR/main.c" ]; then
        # log skipped main.h file creation
        echo "[WARNING] main.c already exists in ./src. Skipped main.c file creation." >>$LOG_PATH/$LOG_FILE_NAME
        return
    # else write the log message and cp the main.c file to the $PROJECT_SRC_DIR
    else
        write_main_c
        MAIN_C_CREATED=true
    fi
}

# create function to create a main.h file
# in the $PROJECT_ROOT_DIR/board-support/Core/Inc directory
create_main_h() {
    echo "beginning create_main_h"

    # if CREATE_MAIN_H is set to false, skip main.h file creation
    if [ $CREATE_MAIN_H = false ]; then
        echo "[main.h] Skipping main.h file creation. "'$CREATE_MAIN_H'" is set to false." >>$LOG_PATH/$LOG_FILE_NAME
        return
    fi

    # check if main.h file already exists in the $PROJECT_INC_DIR
    # if it does and FORCE_OVERWRITE_MAIN_H is set to true, write the warning and continue
    if [ -f "$PROJECT_INC_DIR/main.h" ] && [ $FORCE_OVERWRITE_MAIN_H = true ]; then
        #backup existing main.h file
        exe_and_handle_error cp $PROJECT_INC_DIR/main.h $PROJECT_INC_DIR/main.h.bak

        # force overwrite main.h file and log any errors
        if exe_and_handle_error cp $CUBEMX_MAIN_H_PATH $PROJECT_INC_DIR/main.h; then
            echo "[main.h] Overwriting existing main.h file. "'$FORCE_OVERWRITE_MAIN_H'" is set to true." >>$LOG_PATH/$LOG_FILE_NAME
            MAIN_H_CREATED=true
        else
            echo "[WARNING] Failed to overwrite main.h file due to unexpected error" >>$LOG_PATH/$LOG_FILE_NAME
        fi

    # if it does  write the warning and skip main.h file creation
    elif [ -f "$PROJECT_INC_DIR/main.h" ]; then
        # log skipped main.h file creation
        echo "[WARNING] main.h already exists in ./include. Skipped main.h file creation." >>$LOG_PATH/$LOG_FILE_NAME
        return
    # else write the log message and cp the main.h file to the $PROJECT_INC_DIR
    else
        if exe_and_handle_error cp $CUBEMX_MAIN_H_PATH $PROJECT_INC_DIR/main.h; then
            echo "[main.h] Created main.h file in the project include directory" >>$LOG_PATH/$LOG_FILE_NAME
            MAIN_H_CREATED=true
        else
            echo "[WARNING] Failed to create main.h file due to unexpected error" >>$LOG_PATH/$LOG_FILE_NAME
        fi
    fi
}

clear_main_h_exports() {
    echo "beginning clear_main_h_exports"

    # HAL defines are already in the bsp_main.h file
    # no exports yet, so delete those too
    if exe_and_handle_error sed -i '' '/\/* Private includes/,/\/* USER CODE END Private defines/d' $PROJECT_INC_DIR/main.h; then
        echo "[main.h] Cleared main.h of exports and declarations." >>$LOG_PATH/$LOG_FILE_NAME
    fi

}
