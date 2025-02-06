#!/bin/bash

set -x

# Function to run xrandr --auto for a display
run_xrandr() {
    local display="$1"
    local user="$2"
    
    # Export display and xauthority
    export DISPLAY="$display"
    
    # If user is provided, get their XAUTHORITY
    if [ -n "$user" ]; then
        export XAUTHORITY="/home/$user/.Xauthority"
    else
        # For LightDM or similar, check common locations
        for auth in /run/lightdm/root/$display /var/run/lightdm/root/$display ; do
            if [ -f "$auth" ]; then
                export XAUTHORITY="$auth"
                break
            fi
        done
    fi
    
    # Run xrandr if DISPLAY and XAUTHORITY are set
    if [ -n "$DISPLAY" ] && [ -n "$XAUTHORITY" ] && [ -f "$XAUTHORITY" ]; then
        xrandr --auto
    fi
}

# Find all active X displays
for display in /tmp/.X11-unix/X*; do
    if [ -e "$display" ]; then
        display_num=":${display##*/X}"
        
        # Get users running X sessions
        users=$(who | grep "$display_num" | awk '{print $1}' | sort -u)
        
        if [ -n "$users" ]; then
            # Run for each user session
            while IFS= read -r user; do
                run_xrandr "$display_num" "$user"
            done <<< "$users"
        else
            # No user session found, try running for display manager
            run_xrandr "$display_num" ""
        fi
    fi
done
