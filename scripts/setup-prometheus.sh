#!/usr/bin/env bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# Installs the lates version of prometheus wihin a systemd service
# Check help and usage information through ./setup_backend --help
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/setup-prometheus.sh)"

set -euo pipefail
shopt -s globstar nullglob
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

function main() {
	local start_time
	start_time=$(date +%s)

	echo "========================="
	echo "=> Setting up Prometheus"
	echo "========================="

	echo "=> Setting up user account/group for monitoring"
	# create group and user account if they doesn't exist
	getent group monitoring &> /dev/null || sudo groupadd monitoring
	id -u prometheus &> /dev/null || sudo useradd \
		--no-create-home \
		--no-user-group \
		--shell /usr/sbin/nologin \
		--groups monitoring \
		prometheus

	echo "=> Downloading Prometheus"
	local hardware_name
	hardware_name="$(uname --machine)"

	local cpu_arch
	if [[ "${hardware_name}" == "arm64" ]]; then
		cpu_arch="arm64"
	else
		cpu_arch="amd64"
	fi

	local tag_name # v2.0.3
	tag_name="$(curl -fsSL https://api.github.com/repos/prometheus/prometheus/releases/latest | jq -r '.tag_name')"
	echo "=> Found Prometheus version ${tag_name}"

	local prometheus_version # 2.0.3
	prometheus_version="$(echo "${tag_name}" | cut -d 'v' -f 2)"

	local file_name
	file_name="prometheus-${prometheus_version}.linux-${cpu_arch}"

	local download_url
	download_url="https://github.com/prometheus/prometheus/releases/download/${tag_name}/${file_name}.tar.gz"

	curl -fSLO "${download_url}" --output-dir /tmp
	echo "=> Extracting downloaded archive"
	tar --extract -C /tmp -zvv -f "/tmp/${file_name}.tar.gz"
	sudo mv "/tmp/${file_name}/prometheus" /usr/local/bin/prometheus
	sudo chmod ug+x /usr/local/bin/prometheus
	sudo chown prometheus:monitoring /usr/local/bin/prometheus

	# cleaning up
	echo "=> Cleaning up downloaded files"
	rm -rf "/tmp/${file_name}"
	rm -rf "/tmp/${file_name}.tar.gz"

	echo "=> Setting up systemd service"
	sudo mkdir -p /etc/prometheus

	local service_file="/etc/systemd/system/prometheus.service"
	sudo touch "${service_file}"
	sudo tee "${service_file}" &> /dev/null <<- EOF
		[Unit]
		Description=Prometheus
		After=network-online.target
		Requires=network-online.target
		Wants=network-online.target

		[Service]
		Type=simple
		User=prometheus
		Group=monitoring
		Restart=on-failure
		RestartSec=3
		StartLimitInterval=0 # disables rate limiting
		ProtecHome=read-only
		NoNewPriviliges=yes
		ProtectSystem=strict
		ProtectControlGroups=true
		ProtectKernelModules=true
		ProtectKernelTunables=yes
		SyslogIdentifier=prometheus
		ExecStart=/usr/local/bin/prometheus --web.listen-address=127.0.0.1:9100

		[Install]
		WantedBy=multi-user.target
	EOF

	echo "=> Created systemd service file ${service_file}"

	# adjust ownership and permissions
	sudo chmod 664 "${service_file}"
	sudo chown --recursive prometheus:monitoring /etc/prometheus

	sudo systemctl daemon-reload

	if systemctl is-active prometheus --quiet; then
		sudo systemctl restart prometheus
	else
		sudo systemctl start prometheus
	fi
	if ! systemctl is-enabled prometheus --quiet; then
		sudo systemctl enable prometheus
	fi

	echo
	echo -e "=> \e[90;102;2m INFO \e[m Prometheus has been setup successfully."
	echo "=> Finished in $(($(date +%s) - start_time)) seconds"
	echo
}

main "$@"
