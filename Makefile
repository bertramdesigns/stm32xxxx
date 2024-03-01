.PHONY: all build cmake flash-openocd clean
############################### Native Makefile ###############################
# Based on https://github.com/prtzl/stm32/blob/master/Makefile 

# .vscode files will likely need to be updated if using tasks or launch.json
PROJECT_NAME ?= firmware
BUILD_DIR ?= build
MCU_FAMILY ?= STM32U5xx
MCU_MODEL ?= STM32U5A5xx
# FIRMWARE := $(BUILD_DIR)/$(PROJECT_NAME).bin
BUILD_TYPE ?= Debug
BUILD_SYSTEM ?= Unix Makefiles

all: build

build: cmake
	$(MAKE) -C $(BUILD_DIR) --no-print-directory

cmake: $(BUILD_DIR)/Makefile

$(BUILD_DIR)/Makefile: CMakeLists.txt
	cmake \
		-G "$(BUILD_SYSTEM)" \
		-B$(BUILD_DIR) \
		-DPROJECT_NAME=$(PROJECT_NAME) \
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
		-DDUMP_ASM=OFF

# strip the last two characters from the MCU_FAMILY and convert to lowercase, adding 1 'x' to the end
OCD_DEVICE_CFG := $(shell echo $(MCU_FAMILY) | sed 's/..$$/x/' | tr '[:upper:]' '[:lower:]')

# flash-openocd: build
# 	openocd -f "interface/stlink.cfg" -f target/$(OCD_DEVICE_CFG).cfg -c "program $(BUILD_DIR)/$(PROJECT_NAME).elf verify reset exit"

# flash-stlink-debug: build
#	stlink -c port=SWD file_path=$(BUILD_DIR)/$(PROJECT_NAME).elf start_address=0x08000000

clean:
	rm -rf $(BUILD_DIR)