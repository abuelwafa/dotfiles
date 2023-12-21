#!/bin/bash

# displays online status and internet speeds
show_mode_indicator() {
    echo "$(build_status_module "$1" "" "$thm_orange" "#{tmux_mode_indicator}")"
}

