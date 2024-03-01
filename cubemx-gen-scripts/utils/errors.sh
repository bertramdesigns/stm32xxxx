#!/bin/bash

# function to fire and catch unexpected errors
handle_unexpected_error() {
    # log caught error to log file at e-: mark
    awk -v error_message="$1" '
        {
            print
            if ($0 == "ERRORS:") {
                print "ERROR: Caught unexpected error"
                print error_message
            }
        }
    ' $LOG_PATH/$LOG_FILE_NAME >tmp && mv tmp $LOG_PATH/$LOG_FILE_NAME
}

# wrapper function to execute a command and handle errors
exe_and_handle_error() {
    # Capture the standard error of the command in a variable
    error_message=$("$@" 2>&1 >/dev/null)
    # If the command failed, call the error handler
    if [ $? -ne 0 ]; then
        handle_unexpected_error "$error_message"
    fi
}
