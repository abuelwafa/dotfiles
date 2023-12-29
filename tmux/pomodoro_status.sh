#!/bin/bash

# displays online status and internet speeds
show_pomodoro_status() {
    echo "$(build_status_module "$1" "🍅" "$thm_yellow" "#{pomodoro_status}")"
}
