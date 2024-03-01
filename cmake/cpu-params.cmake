# Configures the CPU parameters for the given MCU family
macro(set_cpu_params MCU_FAMILY)
    if(${MCU_FAMILY} STREQUAL "STM32F0xx")
        set(CPU_PARAMETERS
            -mcpu=cortex-m0
            -mfloat-abi=soft)
    elseif(${MCU_FAMILY} MATCHES "STM32F1xx|STM32F2xx")
        set(CPU_PARAMETERS
            -mcpu=cortex-m3
            -mfloat-abi=soft)
    elseif(${MCU_FAMILY} MATCHES "STM32F3xx|STM32F4xx")
        set(CPU_PARAMETERS
            -mcpu=cortex-m4
            -mfpu=fpv4-sp-d16
            -mfloat-abi=hard)
    elseif(${MCU_FAMILY} STREQUAL "STM32F7xx")
        message(FATAL_ERROR "Set full name of MCU_FAMILY (i.e. STM32F765) to properly set double or single precision -mcpu")
    elseif(${MCU_FAMILY} MATCHES "STM32F7.*")
        # all single point precision F7s
        if(${MCU_FAMILY} MATCHES "STM32F722|STM32F723|STM32F730|STM32F732|STM32F733|STM32F745|STM32F746|STM32F750|STM32F756")
            set(CPU_PARAMETERS
                -mcpu=cortex-m7
                -mfpu=fpv5-sp-d16
                -mfloat-abi=hard)
        # all double point precision F7s
        elseif(${MCU_FAMILY} STREQUAL "STM32F765|STM32F767|STM32F768|STM32F769|STM32F777|STM32F778|STM32F779")
        set(CPU_PARAMETERS
            -mcpu=cortex-m7
            -mfpu=fpv5-d16
            -mfloat-abi=hard)
        else()
            message(FATAL_ERROR "Unknown MCU family: ${MCU_FAMILY}. Check cpu-params.cmake")
        endif()
    elseif(${MCU_FAMILY} MATCHES "STM32G0xx|STM32C0xx")
        set(CPU_PARAMETERS
            -mcpu=cortex-m0plus
            -mfloat-abi=soft)
    elseif(${MCU_FAMILY} STREQUAL "STM32G4xx")
        set(CPU_PARAMETERS
            -mcpu=cortex-m4
            -mfpu=fpv4-sp-d16
            -mfloat-abi=hard)
    elseif(${MCU_FAMILY} STREQUAL "STM32H7xx")
        set(CPU_PARAMETERS
            -mcpu=cortex-m7
            -mfpu=fpv5-d16
            -mfloat-abi=hard)
    elseif(${MCU_FAMILY} STREQUAL "STM32L0xx")
        set(CPU_PARAMETERS
            -mcpu=cortex-m0plus
            -mfloat-abi=soft)
    elseif(${MCU_FAMILY} STREQUAL "STM32L1xx")
        set(CPU_PARAMETERS
            -mcpu=cortex-m3
            -mfloat-abi=soft)
    elseif(${MCU_FAMILY} STREQUAL "STM32L4xx")
        set(CPU_PARAMETERS
            -mcpu=cortex-m4
            -mfpu=fpv4-sp-d16
            -mfloat-abi=hard)
    elseif(${MCU_FAMILY} STREQUAL "STM32L5xx")
        set(CPU_PARAMETERS
            -mcpu=cortex-m33
            -mfpu=fpv5-sp-d16
            -mfloat-abi=hard)
    elseif(${MCU_FAMILY} STREQUAL "STM32U5xx")
        set(CPU_PARAMETERS
            -mcpu=cortex-m33
            -mfpu=fpv5-sp-d16
            -mfloat-abi=hard)
    elseif(${MCU_FAMILY} STREQUAL "STM32WBxx")
        set(CPU_PARAMETERS
            -mcpu=cortex-m4
            -mfpu=fpv4-sp-d16
            -mfloat-abi=hard)
    elseif(${MCU_FAMILY} STREQUAL "STM32WLxx")
        message(FATAL_ERROR "Unsupported MCU family: ${MCU_FAMILY}. Add CPU_PARAMETERS manually")
    else()
        message(FATAL_ERROR "Unknown MCU family: ${MCU_FAMILY}. Check cpu-params.cmake")
    endif()
endmacro()