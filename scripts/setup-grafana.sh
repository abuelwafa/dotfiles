#!/usr/bin/env bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# Install Grafanaa OSS.
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/setup-grafana.sh)"

set -euo pipefail
shopt -s globstar nullglob
# Debug script by setting TRACE=1
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

function main() {
	local start_time
	start_time=$(date +%s)

	echo "======================================="
	echo "=> Installing Grafana OSS"
	echo "======================================="
	echo "=> Setting up Grafana APT repositroy"
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://apt.grafana.com/gpg-full.key | sudo tee /etc/apt/keyrings/grafana.asc &> /dev/null
	sudo chmod 644 /etc/apt/keyrings/grafana.asc

	if [[ ! -f /etc/apt/sources.list.d/grafana.list ]]; then
		echo "deb [signed-by=/etc/apt/keyrings/grafana.asc] https://apt.grafana.com stable main" \
			| sudo tee -a /etc/apt/sources.list.d/grafana.list &> /dev/null
	fi

	echo "=> Installing package"
	sudo apt-get update
	sudo apt-get install -y grafana

	echo "=> Starting systemd service"
	sudo systemctl daemon-reload
	sudo systemctl enable grafana-server
	sudo systemctl restart grafana-server

	echo
	echo -e "=> \e[90;102;2m INFO \e[m Grafana OSS has been installed successfully."
	echo "=> Done in $(($(date +%s) - start_time)) seconds"
}

main "$@"
