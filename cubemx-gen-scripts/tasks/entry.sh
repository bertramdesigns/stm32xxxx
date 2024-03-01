#!/bin/bash

# pull the main() loop from bsp_main.c into a backup file bsp_main_loop.c
check_main_c_entry() {
    echo "beginning check_main_c_entry"

    # Extract function calls from main_loop.bak
    function_calls=$(grep -oP '[A-Z][a-zA-Z0-9_]*\([a-zA-Z0-9_, ]*\);' $PROJECT_SRC_DIR/main_loop.bak)

    # Check each function call in main.c
    for function_call in $function_calls; do
        if ! grep -q "$function_call" $PROJECT_SRC_DIR/main.c; then
            # If the function call is not found in main.c, append a log entry
            echo "'$function_call' is not initialized in main.c entry loop" >>$LOG_PATH/$LOG_FILE_NAME
        fi
    done
}

# delete entry from bsp_main.c
delete_bsp_main_c_entry() {
    echo "beginning delete_bsp_main_c_entry"

    # if main.c was created it was done from a copy, so no check needed
    if [ $MAIN_C_CREATED = false ] && grep -q 'int main(void)' $CUBEMX_BSP_MAIN_C_PATH; then
        # delete the backup
        rm -f $PROJECT_SRC_DIR/main_loop.bak
        # Extract the main loop into a backup file for comparison
        sed -n -e '/int main(void)/,/\/\* USER CODE END 3 \*\//{N; p;}' $CUBEMX_BSP_MAIN_C_PATH > $PROJECT_SRC_DIR/main_loop.bak
    fi

    # Delete the main loop from the original file
    if exe_and_handle_error sed -i '' '/int main(void)/,/\/\* USER CODE END 3 \*\//{N; d;}' $CUBEMX_BSP_MAIN_C_PATH; then
        echo "[entry] Deleted main loop from bsp_main.c" >>$LOG_PATH/$LOG_FILE_NAME
        # Clean up extra comments
        sed -i '' '/@brief  The application entry point./{N; d;}' $CUBEMX_BSP_MAIN_C_PATH
    else
        echo "[entry] Failed to delete main loop from bsp_main.c due to uknown error" >>$LOG_PATH/$LOG_FILE_NAME
    fi
}
