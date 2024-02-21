# stm32-mac-dev environment

A bare metal C project template and development environment for STM32 microcontrollers with Visual Studio Cod on MacOS. This template includes HAL/CMSIS drivers.

__Note RE: no ST-Link__
stlink-org (open source) has dropped support for MacOS due to the Apple being not so friendly lately. Unfortunately, this was the most complete ecosystem for STM32 development. Fortunately, we can dump the ST dedicated software and use the J-Link converter from Segger to flash. The rest can be done normally.

## Getting Started

### Dependencies
- Visual Studio Code
- CubeMX (for generating initialization files)
- [ARM GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads): arm-none-eabi-gcc
    - best to install with brew package `brew install --cask gcc-arm-embedded`
- STM Cube Programmer (for flashing)
    - Alternatively [ST-Link -> J-Link](https://www.segger.com/products/debug-probes/j-link/models/other-j-links/st-link-on-board/)
- [OpenOCD](http://openocd.org/getting-openocd/)

### Installation
TODO: UPDATE TO bertramdesigns GIT
To install run `git clone https://github.com/lukezsmith/stm32-dev` to clone the repository.

#### C/C++ dependencies
You must have the compiler properly setup. It is recommended to install the VSCode C/C++ extension to manage c_cpp_properties.json
To make sure you have the whole toolchain installed make sure to use:
``` bash
brew install --cask gcc-arm-embedded
```

if you only install `brew install arm-none-eabi-xxx` there will be lots of errors about missing stdint.h and other files.

Configure by opening the extension and choosing the correct compiler path. This is usually located in `/usr/local/bin/arm-none-eabi-gcc`.


### Running
Following installation & configuration, open the directory in Visual Studio Code. 

--- 

## Building & Debugging

### Generate initialization files with CubeMX
The template is designed to work with STM32CubeMX. We are designing our own CMakeLists.txt files so we will be generating with the STM32CubeIDE toolchain to ensure we get all the required startup and linker scripts. 


When generating the code in CubeMX, make sure to select the correct microcontroller and toolchain.

Make sure under Project Manager > Project you choose:
- Application structure: Advanced
    - you must "Save As" first for this to be available
    - Advanced adds the "Core" folder instead of putting all under the root
- Toolchain/IDE: STM32CubeIDE
    - CubeMX is a bit broken on Mac so it doesn't generate linker scripts if you use "Makefile."
- Generate under root

Under Project Manager > Code Generator it is recommended to select:
- Copy only the necessary library files
- Generate peripheral initialization as a pair of .c/.h files per peripheral


Your file structure should look as follows:
.
| .vscode
| board-support
| | Core
| | | Inc
| | | Src
| | | Startup
| | | | startup_stm32u5a5xx.s
| | Drivers
| | | CMSIS
| | | STM32U5xx_HAL_Driver
| | board-support.ioc
| | STM32U5A5ZJTXQ_FLASH.ld
| | STM32U5A5ZJTXQ_RAM.ld
| src
| | main.c
| debug-files
| | README.md
| | STM32U5A5.svd (optional)
| CMakeLists.txt
| gcc-arm-none-eabi.cmake
| README.md

### Configuration
There are a number of configurable properties within the template.

#### Launch file (launch.json)


For quick reference the following are most likely to be used:

```
stm32l4x.cfg
stm32l5x.cfg
stm32u5x.cfg
stm32f7x.cfg
stm32h7x.cfg
```

Other interfaces can also be defined in `scripts/interface/` directory. For example:

```
openjtag.cfg
jink.cfg
```

#### c_cpp_properties.json

Once you have setup the launch, you will also need to adjust the c/c++ properties to match the microcontroller you are using. This file is located in the `.vscode` directory.

Make sure all the devices and include paths are correct for the project structure.

#### Project/Executable Name (CMakeLists.txt)
To rename the project and executable edit the CMakeLists.txt file in the root directory. The directories and file names need to match the CubeMX initialization.

##### CPU_PARAMETERS
Make sure the below have the correct parameters for the microcontroller you are using. For example, for the STM32U5 microcontroller the parameters are as follows:

```
set(CPU_PARAMETERS
    -mcpu=cortex-m33
    -mthumb
    -mfpu=fpv5-sp-d16
    -mfloat-abi=hard)
```

General rule for settings would be as per table below:


| STM32 Family | -mcpu           | -mfpu         | -mfloat-abi |
| ------------ | --------------- | ------------- | ----------- |
| STM32F0      | `cortex-m0`     | `Not used`    | `soft`      |
| STM32F1      | `cortex-m3`     | `Not used`    | `soft`      |
| STM32F2      | `cortex-m3`     | `Not used`    | `soft`      |
| STM32F3      | `cortex-m4`     | `fpv4-sp-d16` | `hard`      |
| STM32F4      | `cortex-m4`     | `fpv4-sp-d16` | `hard`      |
| STM32F7 SP   | `cortex-m7`     | `fpv5-sp-d16` | `hard`      |
| STM32F7 DP   | `cortex-m7`     | `fpv5-d16`    | `hard`      |
| STM32G0      | `cortex-m0plus` | `Not used`    | `soft`      |
| STM32C0      | `cortex-m0plus` | `Not used`    | `soft`      |
| STM32G4      | `cortex-m4`     | `fpv4-sp-d16` | `hard`      |
| STM32H7      | `cortex-m7`     | `fpv5-d16`    | `hard`      |
| STM32L0      | `cortex-m0plus` | `Not used`    | `soft`      |
| STM32L1      | `cortex-m3`     | `Not used`    | `soft`      |
| STM32L4      | `cortex-m4`     | `fpv4-sp-d16` | `hard`      |
| STM32L5      | `cortex-m33`    | `fpv5-sp-d16` | `hard`      |
| STM32U5      | `cortex-m33`    | `fpv5-sp-d16` | `hard`      |
| STM32WB      | `cortex-m4`     | `fpv4-sp-d16` | `hard`      |
| STM32WL CM4  | `cortex-m4`     | `Not used`    | `soft`      |
| STM32WL CM0  | `cortex-m0plus` | `Not used`    | `soft`      |


 

##### Startup & Linker Script

CubeMX generates a startup and flash linker scripts for the microcontroller you are using. The CMakeLists.txt file needs to be updated to reflect the proper script.

```
set(STARTUP_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/Startup/startup_stm32u5a5xx.s)

```


#### HAL Drivers
In `CMakeLists.txt` the HAL drivers of the project may be different. The easiest way to make sure they are correct is to configure and generate the code in CubeMX. Then go to the `STM32U5xx_HAL_Driver/Src` and highlight all the files. Right click and "copy relative path. Then find and replace all the prefixes, replacing the previous list. 

**Note**: If more are added later and you didn't use CubeMX then youll need to update `Inc/stm32u5xx_hal_conf.h`.


##### The rest
Even if not noted, make sure to check and make sure all the names of the MCU you are using are correct in the rest of the file.

### Building
The template uses CMake to build the code. 
To automate the process there is a Makefile in the root directory which can be run to automate the build.

To build for the STM32 microcontroller run `make` to build a version for debugging. To create a release build run `make BUILD_TYPE=Release`. These build will be saved in `/build/release`.


### Debugging
The project is ready for debugging via gdb through the `Debug` build. I usually use the [cortex-debug](https://marketplace.visualstudio.com/items?itemName=marus25.cortex-debug) Visual Studio Code extension. A configuration file for debugging with cortex-debug (with openocd, stlink) can be found at `.vscode/launch.json`. You will need to modify this file based on your debugging server/microcontroller setup.

### Flashing 
Included in the Makefile is a flash command to flash the program to the STM32.

To flash the release build to the microcontroller run `make flash`.

## References
I used a couple of different repositories to build this template:
- [ERBO/stm32-cmake](https://github.com/ERBO-Engineering/cmake-stm32/)
    - Main inspiration. Crazy simplified and works.

- [prtzl/stm32](https://github.com/prtzl/stm32/)
    - Inspired the more "manual" implementation (see docker branch)

- [lukezsmith/stm32-dev](https://github.com/lukezsmith/stm32-dev/tree/main)
    - My starting point for the project.

Reading:
- [Cristian's STM32 on Apple Silicon Tutorial](https://medium.com/@cristian.dbr/vs-code-setup-for-stm32-arm-development-on-apple-silicon-mac-e244b789bde1)
    - Offers a good starting point for developing on Apple Silicon with STM32.

- [Jasonyang-ee's detailed CMake files](https://github.com/jasonyang-ee/STM32-CMAKE-TEMPLATE)
    - Offers a great guidance and comments for writing the CMakeLists.txt file.

Future references:
- [rgujju/STM32_Base_Project](https://github.com/rgujju/STM32_Base_Project)
    - I borrowed the test module collation idea from this unity-based project template.

Other references:
- [fcayci/stm32f4-bare-metal](https://github.com/fcayci/stm32f4-bare-metal)
    - Original author of the base files referenced this project.






