#!/bin/bash

# For debugging the error handler is being pulled into project dir

create_error_handler_c() {
    echo "beginning create_error_handler_c"

    if [ ! -f $PROJECT_SRC_DIR/error_handler.c ]; then
        echo '#include "error_handler.h"
/**
* @brief  This function is executed in case of error occurrence.
* @retval None
*/
void Error_Handler(void)
{
    /* USER CODE BEGIN Error_Handler_Debug */
    /* User can add his own implementation to report the HAL error return state */
    __disable_irq();
    while (1)
    {
    }
    /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
* @brief  Reports the name of the source file and the source line number
*         where the assert_param error has occurred.
* @param  file: pointer to the source file name
* @param  line: assert_param error line source number
* @retval None
*/
void assert_failed(uint8_t *file, uint32_t line)
{
    /* USER CODE BEGIN 6 */
    /* User can add his own implementation to report the file name and line number,
        ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
    /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */' >$PROJECT_SRC_DIR/error_handler.c

        # log the creation of the file
        echo "[error_handler.c] Created error_handler.c." >>$LOG_PATH/$LOG_FILE_NAME

    else
        # log that the file already exists
        echo "[WARNING] error_handler.c already exists in ./src. Skipped file creation." >>$LOG_PATH/$LOG_FILE_NAME
    fi
}

create_error_handler_h() {
    echo "beginning create_error_handler_h"
    
    # include the correct #include "stm" hal by copying it from bsp_main.h 
    if exe_and_handle_error grep '#include "stm32' $CUBEMX_CORE_DIR/Inc/main.h; then
        stm_hal_include=$(grep '#include "stm32' $CUBEMX_CORE_DIR/Inc/main.h)
    else
        stm_hal_include='#include "stm32__xx_hal.h"'
        echo "[WARNING] Failed to find #include \"stm32\" in main.h." >>$LOG_PATH/$LOG_FILE_NAME
        echo "You will need to add your stm32 hal file in error_handler.h manually" >>$LOG_PATH/$LOG_FILE_NAME
    fi


    if [ ! -f "$PROJECT_INC_DIR/error_handler.h" ]; then
        echo "/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef ERROR_HANDLER_H
#define ERROR_HANDLER_H
#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
$stm_hal_include

/* Exported types ------------------------------------------------------------*/

/* Exported constants --------------------------------------------------------*/

/* Exported macro ------------------------------------------------------------*/

/* Exported functions ------------------------------------------------------- */
void Error_Handler(void);

#ifdef __cplusplus
}
#endif
#endif /* ERROR_HANDLER_H */" >$PROJECT_INC_DIR/error_handler.h

        # log the creation of the file
        echo "[error_handler.h] Created file." >>$LOG_PATH/$LOG_FILE_NAME

    else
        echo "[WARNING] error_handler.h already exists. Skipped file creation." >>$LOG_PATH/$LOG_FILE_NAME
    fi

   
}

migrate_bsp_main_to_proj_error_handler() {
    echo "beginning migrate_bsp_main_to_proj_error_handler"

    # include the new error handler in bsp_main.h
    if exe_and_handle_error sed -i '' '/\/\* Includes/a\ 
#include "error_handler.h"\
' $CUBEMX_BSP_MAIN_H_PATH; then
        echo "[bsp_main.h] Included error_handler.h/" >>$LOG_PATH/$LOG_FILE_NAME
    else
        echo "[WARNING] Failed to include error_handler.h in bsp_main.h" >>$LOG_PATH/$LOG_FILE_NAME
    fi
}

delete_bsp_main_error_handler() {
    echo "beginning delete_bsp_main_error_handler"

    # remove the old error handler from bsp_main.c
    if exe_and_handle_error sed -i '' '/void Error_Handler(void)/,/USER CODE END Error_Handler_Debug/{N; d;}' $CUBEMX_BSP_MAIN_C_PATH; then
        echo "[bsp_main.c] Removed 'void Error_Handler(void)'" >>$LOG_PATH/$LOG_FILE_NAME
        
        # clean up comments
        sed -i '' '/@brief  This function is executed in case of error occurrence./{N; d;}' $CUBEMX_BSP_MAIN_C_PATH
    else
        echo "[WARNING] FAILED to removed 'void Error_Handler(void)' in bsp_main.c" >>$LOG_PATH/$LOG_FILE_NAME
    fi

    # remove the old assert_failed from bsp_main.c
    if exe_and_handle_error sed -i '' '/#ifdef  USE_FULL_ASSERT/,/USE_FULL_ASSERT/d' $CUBEMX_BSP_MAIN_C_PATH; then
        echo "[bsp_main.c] Removed 'void assert_failed(){}'" >>$LOG_PATH/$LOG_FILE_NAME
    else
        echo "[WARNING] Failed to remove 'void assert_failed()' in bsp_main.c" >>$LOG_PATH/$LOG_FILE_NAME
    fi


}
delete_main_c_error_handler() {
    echo "beginning delete_main_c_error_handler"

    # remove the old error handler from main.c
    if exe_and_handle_error sed -i '' '/void Error_Handler(void)/,/USER CODE END Error_Handler_Debug/{N; d;}' $PROJECT_SRC_DIR/main.c; then
        echo "[main.c] Removed 'void Error_Handler(void)'" >>$LOG_PATH/$LOG_FILE_NAME
         # clean up comments
        sed -i '' '/@brief  This function is executed in case of error occurrence./{N; d;}' $PROJECT_SRC_DIR/main.c
    else
        echo "[WARNING] Failed to removed 'void Error_Handler(void)' in main.c" >>$LOG_PATH/$LOG_FILE_NAME
    fi

    # remove the old assert_failed from main.c
    if exe_and_handle_error sed -i '' '/#ifdef  USE_FULL_ASSERT/,/USE_FULL_ASSERT/d' $PROJECT_SRC_DIR/main.c; then
        echo "[main.c] Removed 'void assert_failed(){}'" >>$LOG_PATH/$LOG_FILE_NAME
    else
        echo "[WARNING] FAILED to remove 'void assert_failed()' in main.c" >>$LOG_PATH/$LOG_FILE_NAME
    fi
}
