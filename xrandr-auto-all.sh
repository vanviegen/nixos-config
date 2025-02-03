#!/usr/bin/env bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Iterate over all running X servers
ps aux | grep '[b]in/X' | while read -r line; do
    # Extract the DISPLAY and XAUTHORITY from the command line arguments
    DISPLAY=$(echo "$line" | grep -oP '(?<=-displayfd )\d+' | xargs -I{} echo :{})
    XAUTHORITY=$(echo "$line" | grep -oP '(?<=-auth )[^ ]+')

    if [[ -n $DISPLAY && -n $XAUTHORITY ]]; then
        echo "Configuring display $DISPLAY with xrandr"
        # Export the environment variables
        export DISPLAY=$DISPLAY
        export XAUTHORITY=$XAUTHORITY

        # Run xrandr --auto
        xrandr --auto
    else
        echo "Could not find DISPLAY or XAUTHORITY for line: $line"
    fi
done
