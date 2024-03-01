# stm32-mac-dev environment

A bare metal C project template and development environment for STM32 microcontrollers with Visual Studio Cod on MacOS. This template includes bash script files to generate a new project outside the CubeMX directory so you don't loose your work everytime you regenerate the code.

## Getting Started

### Dependencies
- Visual Studio Code
    - Cortex-Debug extension
    - C/C++ extension
- CubeMX (for generating initialization files)
- [ARM GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads): arm-none-eabi-gcc
    - best to install with brew package `brew install --cask gcc-arm-embedded`
- STM Cube Programmer (for flashing)
- [OpenOCD](http://openocd.org/getting-openocd/)

### Installation
TODO: UPDATE TO bertramdesigns GIT
To install run `git clone https://github.com/lukezsmith/stm32-dev` to clone the repository.

#### STM32CubeProgrammer

Fortunately, ST now has a CLI tool for flashing and debugging called STM32CubeProgrammer. The Programmer is mainly graphical, but you can find the CLI tool in the application package.

It is recommended to create the symlink to the CLI tool in your `/usr/local/bin` directory so you can use the `make flash` command.

``` bash
ln -s /Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/bin/STM32_Programmer_CLI /usr/local/bin/stlink
```

__Note RE: no ST-Link (.org)__
stlink-org (open source) has dropped support for MacOS due to the Apple being not so friendly lately. Unfortunately, this was the most complete ecosystem for STM32 development. 

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
- DON'T Generate peripheral initialization as a pair of .c/.h files per peripheral
    - if selected, you will need to manually include files to you main.c files
    - CubeMX doesn't generate ALL the files externally so makes ejecting your code to a seperate directory a bit more difficult
    - You shouldn't touch these anyways if you are planning on using the CubeMX code generation. Otherwise you will loose your work.

Under Project Manager > Code Generator > User Actions > After Code Generation:
- Add the `post-gen-script.sh` file in the `cubemx-gen-scripts` directory.
    - This will automatically eject the main.c and main.h files to the `src` and `include` directories respectively.
    - Make sure to check the `config.sh`for the correct paths

#### Before generating code...
- Make sure to run `chmod +x ./cubemx-gen-scripts/post-gen-script.sh` to ensure CubeMX can execute the script.
- In `./cubemx-gen-scripts/config.sh` make sure the `PROJECT_ROOT_DIR` is set to the root directory of your project.

Click __Generate Code__ and check the console for errors.


#### After generating code...
After you generate code, you will have `cubemx-scripts.log`in your root directory. Check for errors and make sure the files were ejected correctly.

First thing you should do is run `make build`. If all goes well, everything ejected properly. If not, report the error and check the log file.

Your file structure should look as follows:
.
| .vscode
| board-support
| | Core
| | | Inc
| | | | main.h (bsp_main.h after script)
| | | Src
| | | | main.c (bsp_main.c after script)
| | | Startup
| | | | startup_stm32u5a5xx.s
| | Drivers
| | | CMSIS
| | | STM32U5xx_HAL_Driver
| | board-support.ioc
| | STM32U5A5ZJTXQ_FLASH.ld
| | STM32U5A5ZJTXQ_RAM.ld
| cmake
| | cpu-params.cmake
| | gcc-arm-none-eabi.cmake
| cubemx-gen-scripts
| | tasks
| | utils
| | config.sh
| | post-gen-script.sh
| | README.md
| include
| | error_handler.h (from script)
| | main.h
| src
| | error_handler.c (from script)
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

Make sure to update the `./debug-files/STM32xxxx.svd` file so you can add breakpoints.

#### c_cpp_properties.json

Once you have setup the launch, if you want a different arm toolchain and C/C++ standard update `./.vscode/c_cpp_properties.json`

#### Project/Executable Name (Makefile/CMakeLists.txt)
If you followed the the setup above, the folders will be properly configured for you CMake includes and sources. Otherwise you will need to update these. 

To rename the project and executable either:
- edit the CMakeLists.txt file in the root directory. 
or 
- edit the Makefile in the root directory.

You will need to make sure to set:
``` makefile
PROJECT_NAME ?= firmware
BUILD_DIR ?= build
MCU_FAMILY ?= STM32U5xx
MCU_MODEL ?= STM32U5A5xx
BUILD_TYPE ?= Debug
BUILD_SYSTEM ?= Unix Makefiles
```

##### CPU_PARAMETERS
The CPU parameters will automatically generate from the cmake/cpu-params.cmake file. Make sure to check the Output of VSCode to make sure the correct parameters are being added.

If you are using an unsupported cpu, you will need to add the parameters manually. For example, the STM32U5A5ZJTXQ uses the following parameters:

```
set(CPU_PARAMETERS
    -mcpu=cortex-m33
    -mfpu=fpv5-sp-d16
    -mfloat-abi=hard)
```

__NOTE:__ -mthumb is directly added to the flags in the bottom of the file.


##### Startup & Linker Script

CubeMX generates a startup and flash linker scripts for the microcontroller you are using. The CMakeLists.txt automatically imports the files from the `board-support` directory. Make sure the files are named correctly and in the correct directory.

If you have more than 1 file labeled *_FLASH.ld or you have multiple startup files, you will need to update the CMakeLists.txt file to include the correct files manually.

#### Drivers & Sources
The drivers are imported with glob imports. You may want to hardcode the correct files later if you want to slim down the code.

### Building
The template uses CMake to build the code. 
To automate the process there is a Makefile in the root directory which can be run to automate the build.

If you are using make:
``` bash
make build
```
_note_: add `make BUILD_TYPE=Release` for a release build.


if you are using CMake directly:
``` bash
cmake -B build -G "Unix Makefiles" 
```
_note_: add `-DCMAKE_BUILD_TYPE=Release` for a release build.


### Debugging
The project is ready for debugging via gdb through the `Debug` build. 

I usually use the [cortex-debug](https://marketplace.visualstudio.com/items?itemName=marus25.cortex-debug) Visual Studio Code extension. A configuration file for debugging with cortex-debug (with openocd, stlink) can be found at `.vscode/launch.json`. It is currently setup to run a standard STLink.

### Flashing 

TODO:
Included in the Makefile is a flash command to flash the program to the STM32.

To flash the release build to the microcontroller run `make flash`.


---

## References
I used a couple of different repositories to build this template:
- [ERBO/stm32-cmake](https://github.com/ERBO-Engineering/cmake-stm32/)
    - Main inspiration. Crazy simplified and works.

- [prtzl/stm32](https://github.com/prtzl/stm32/)
    - Inspired the more "manual" implementation (see docker branch)

- [lukezsmith/stm32-dev](https://github.com/lukezsmith/stm32-dev/tree/main)
    - My starting point for the project.

OpenOCD setup:
- [Forum post](https://forum.pedalpcb.com/threads/setting-up-vscode-openocd-xpack-st-link-for-debugging-on-macos-big-sur.4861/)
    - Explains how to use OpenOCD with ST-Link and VSCode/Cortex-Debug on MacOS. It recommends using the xPack version of OpenOCD, but brew has the most recent version now.

Reading:
- [Cristian's STM32 on Apple Silicon Tutorial](https://medium.com/@cristian.dbr/vs-code-setup-for-stm32-arm-development-on-apple-silicon-mac-e244b789bde1)
    - Offers a good starting point for developing on Apple Silicon with STM32.

- [Jasonyang-ee's detailed CMake files](https://github.com/jasonyang-ee/STM32-CMAKE-TEMPLATE)
    - Offers a great guidance and comments for writing the CMakeLists.txt file.

Future references:
- [rgujju/STM32_Base_Project](https://github.com/rgujju/STM32_Base_Project)
    - Test module collation idea from this unity-based project template.

Other references:
- [fcayci/stm32f4-bare-metal](https://github.com/fcayci/stm32f4-bare-metal)






