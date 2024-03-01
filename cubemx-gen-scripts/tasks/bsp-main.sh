#!/bin/bash

rename_to_bsp_main_c() {
    # rename main.c to bsp_main.c
    if exe_and_handle_error mv $CUBEMX_MAIN_C_PATH $CUBEMX_BSP_MAIN_C_PATH; then
        echo "[bsp_main.c] Renamed main.c to bsp_main.c" >>$LOG_PATH/$LOG_FILE_NAME
    fi

    # replace `main.c` with `bsp_main.c` on the same line as `@file`
    if exe_and_handle_error sed -i '' 's/main.c/bsp_main.c/' $CUBEMX_BSP_MAIN_C_PATH; then
        echo "[bsp_main.c] Replaced 'main.c' with 'bsp_main.c' for '@file' in header" >>$LOG_PATH/$LOG_FILE_NAME
    fi

    # replace `Main program body` with `Initialization program body` after `@brief`
    if exe_and_handle_error sed -i '' 's/Main program body/Initialization program body/' $CUBEMX_BSP_MAIN_C_PATH; then
        echo "[bsp_main.c] Replaced 'Main program body' with 'Initialization program body' after '@brief' in bsp_main.c" >>$LOG_PATH/$LOG_FILE_NAME
    fi

    # replace `#include main.h` with `bsp_main.h`
    if exe_and_handle_error sed -i '' 's/main.h/bsp_main.h/' $CUBEMX_BSP_MAIN_C_PATH; then
        echo "[bsp_main.c] Updated #include to bsp_main.h" >>$LOG_PATH/$LOG_FILE_NAME
    fi
}

rename_to_bsp_main_h() {
    # rename main.h to bsp_main.h
    if exe_and_handle_error mv $CUBEMX_MAIN_H_PATH $CUBEMX_BSP_MAIN_H_PATH; then
        echo "[bsp_main.h] Renamed main.h to bsp_main.h" >>$LOG_PATH/$LOG_FILE_NAME
    fi

    # replace __MAIN_H with BSP_MAIN_H in bsp_main.h
    if exe_and_handle_error sed -i '' 's/__MAIN_H/BSP_MAIN_H/g' $CUBEMX_BSP_MAIN_H_PATH; then
        echo "[bsp_main.h] Replaced '__MAIN_H' with 'BSP_MAIN_H' in bsp_main.h" >>$LOG_PATH/$LOG_FILE_NAME
    fi

    # replace `main.h` with `bsp_main.h` on the same line as `@file`
    if exe_and_handle_error sed -i '' 's/main.h/bsp_main.h/' $CUBEMX_BSP_MAIN_H_PATH; then
        echo "[bsp_main.h] Replaced 'main.h' with 'bsp_main.h' for '@file' in bsp_main.h header" >>$LOG_PATH/$LOG_FILE_NAME
    fi

    # replace main.c with bsp_main.c
    if exe_and_handle_error sed -i '' 'sed -i 's/main.c/bsp_main.c/' filename' $CUBEMX_BSP_MAIN_H_PATH; then
        echo "[bsp_main.h] Replaced 'main.c' with 'bsp_main.c' for '@brief' in bsp_main.h header" >>$LOG_PATH/$LOG_FILE_NAME
    fi
}

export_all_bsp_main_functions() {

    # start clean. Remove all current exports.
    if exe_and_handle_error sed -i '' '/\/\* Exported functions prototypes/,/\/\* Private defines/{//!d;}' $CUBEMX_BSP_MAIN_H_PATH; then
        echo "[bsp_main.h] Cleared exported function prototypes in bsp_main.h" >>$LOG_PATH/$LOG_FILE_NAME
    fi

    # make sure no functions are marked static in bsp_main.c
    if exe_and_handle_error sed -i '' 's/static //g' $CUBEMX_BSP_MAIN_C_PATH; then
        echo "[bsp_main.c] Removed 'static' from all functions in bsp_main.c" >>$LOG_PATH/$LOG_FILE_NAME
    fi

    # add new exports for all functions in bsp_main.c
    find_functions=$(grep -oE '(void )[A-Z][a-zA-Z0-9_]*\(*[a-zA-Z0-9_]*\)[^;]' $CUBEMX_BSP_MAIN_C_PATH | tr -dc '[:print:]' | sed 's/)/);@/g')

    awk_script='
    /\/\* Exported functions prototypes ---/ {
            print
            split(find_functions, array, "@")
            for (i=1; i<=length(array); i++) {
                print array[i]
            }
            next
        }
        {print}
        '

    # insert function declarations into bsp_main.h
    if awk -v find_functions="$find_functions" "$awk_script" $CUBEMX_BSP_MAIN_H_PATH >temp.txt 2>>$LOG_PATH/$LOG_FILE_NAME && mv temp.txt $CUBEMX_BSP_MAIN_H_PATH; then
        echo "[bsp_main.h] Exported the following from bsp_main.c in bsp_main.h:" >>$LOG_PATH/$LOG_FILE_NAME
        # list all functions exported in log
        echo "$find_functions" | awk -F'@' '{for(i=1; i<=NF; i++) print $i}' >>$LOG_PATH/$LOG_FILE_NAME
    fi
}

migrate_hal_includes(){
    # replace 'main.h' with 'bsp_main.h' in the files ending with '_hal_msp.c' and '_it.c'
    for file in $(find $CUBEMX_CORE_DIR/Src -name "*_hal_msp.c" -o -name "*_it.c"); do
        if exe_and_handle_error sed -i '' 's/main.h/bsp_main.h/' $file; then
            echo "Replaced 'main.h' with 'bsp_main.h' in $file" >>$LOG_PATH/$LOG_FILE_NAME
        fi
    done
}
