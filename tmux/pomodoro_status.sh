#!/bin/bash

# displays online status and internet speeds
show_pomodoro_status() {
    echo "$(build_status_module "$1" "🍅" "$thm_yellow" "#[fg=$thm_fg]#{pomodoro_status} #{cpu_bg_color}#[fg=$thm_black] 󰍛 #{cpu_percentage} #{ram_bg_color}#[fg=$thm_black]  #{ram_percentage} ")"
}
