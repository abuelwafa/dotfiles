#!/bin/bash

# displays online status and internet speeds
show_net_speed() {
    echo "$(build_status_module "$1" "󰖟" "$thm_orange" "#{online_status} #{network_speed}")"
}

