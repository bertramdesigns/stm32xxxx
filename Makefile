.PHONY: all build cmake format-linux flash-stlink flash-openocd clean
############################### Native Makefile ###############################
# Based on https://github.com/prtzl/stm32/blob/master/Makefile 

PROJECT_NAME ?= firmware
BUILD_DIR ?= build
FIRMWARE := $(BUILD_DIR)/$(PROJECT_NAME).bin
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

# Device specific!
#DEVICE ?= STM32U5A5ZJ

flash-stlink: build
	st-flash --reset write $(FIRMWARE) 0x08000000


# Identify the correct cfg file for openocd
ST_SERIES ?= u5

ifneq (,$(findstring $(ST_SERIES),l1 l2 l3 l4 l5 u5 f7 h7))
 OCD_DEVICE_CFG := $(subst --,$(ST_SERIES),stm32--x.cfg)
else
    $(error ST_SERIES must be one of l1 l2 l3 l4 l5 u5 f7 h7)
endif

flash-openocd: build
	openocd -f interface/stlink.cfg -f target/$(OCD_DEVICE_CFG) -c "program $(BUILD_DIR)/main.elf verify reset exit"

clean:
	rm -rf $(BUILD_DIR)