# CubeMX post-generation scripts

For macOS and Linux.

These scripts will help you run "headless" projects in other editors such as VSCode. Allows to use a separate main.c and main.h file in your project directory to keep it simple. 

The script is non-destructive. You can always remove .bak endings from main.c and main.h to restore the original files.

__Why?__

Because CubeMX is a bit of a magical black box when generating code, it is recommended to not touch the generated code. It is dangerous to put any code in the files as, even in STM32CubeIDE, it is often overwritten leading to many tears and frustrations. 4

Instead, these scripts can be added in CubeMX to automatically prepare an external main.c and main.h file in your application directory.

__NOTE:__
In general, you shouldn't count on the general drivers from ST for an optimized product. But it is good practice as a starting point.

---

## Usage

### Setup
1. _build-script.sh_: 
    - Update the root project directory path `cd /path/to/your/project`
    - use `chmod +x build-script.sh` to ensure CubeMX can execute the script
2. _board-support.ioc_: 
    - Make sure your CubeMX project is located under the board-support directory
3. _CubeMX > Project Manager > Project_:
    - Choose `Generate under root`
    - Choose `STM32CubeIDE` toolchain
    - Choose the `Application Structure: Advanced` option to place files in `./board-support/Core`
        - `File > Save Project As` first if not available
4. _CubeMX > Project Manager > Code Generation_: 
    - Add scripts to CubeMX in `Project Manager > Code Generator > User Actions`
5. _./cubemx-gen-scripts/config.sh_
    - Update the `PROJECT_ROOT_DIR` variable to the root directory of your project

__Optional__: 
- _CubeMX > Project Manager > Code Generation_: 
    - Choose `Generate peripheral initialization as a pair of .c/.h files per peripheral`
    - If you choose this option you will need to import the files manually. [Marked as a future todo]
- _CubeMX > Project Manager > Advanced_:
    - Under `Generated Function Calls` uncheck all in `Visibility (Static)`
    - The script will automatically remove the static definitions from the main.c file anyway

### Running / Generating code
5. _CubeMX_:
    - Click `Generate Code`
    - Check the console that opens. It should state the script location and `ErrorLevel:0` if successful
7. _./gen-script-log.txt_:
    - If `ErrorLevel:` is not 0, check the error log
    - Check for any new functions that should be added to `main.c` and `main.h`
8. _./src/main.c_:

---
## Usage Details
### Step 1: Update build-script.sh root directory
At the top you will find a line to change the directory `cd /path/to/your/project`. Change this to the root directory of your project that contains the `board-support` directory.

The script directories will perfom: 
- enter `./board-support/Core`
- set the original `main.c` and `main.h` files to `.bak`
- rename `main.c` and `main.h` to `bsp_main.c` and `bsp_main.h`
- add the `main.c` and `main.h files` to `./src` and `./include` if they don't exist
    - make sure ./src and ./include exist otherwise it will skip this step
- and create a `gen-script-log.txt` file in `./`

### Step 2: board-support.ioc
This script assumes that you will generate CubeMX files under the `./board-support` directory and build your files in `./src` and `./include`. This is to keep the project clean and separate from the generated code.

### Steps 3/4/5: Generate under root

---

## Error Handling
The script will generate a `gen-script-log.txt` file in the root directory. This will contain the output of the script and any errors that may have occurred.

Unexpected errors are caught by a wrapper function [ `exe_and_handle_error` ] before commands that pulls from /dev/stdin and prints it to the log file.

The wrapper is used everytime a command is run to manipulate a generated file.

---

## Future Work

- [ ] Export interupt files to `./src` and `./include`
- [ ] Add option to skip ejecting error handling
- [ ] Add option to force overwrite error handling
- [ ] Replace all file name references with variables
- [ ] Improve error handling by echoing to console when unexpected errors happen from exe_and_handle_error
- [ ] Import all includes from bsp_main.h to main.h to allow for exporting peripheral .c/.h files as a pair