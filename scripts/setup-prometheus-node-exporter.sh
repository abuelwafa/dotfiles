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
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/setup-prometheus-node-exporter.sh)"

set -euo pipefail
shopt -s globstar nullglob
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

function main() {
	local start_time
	start_time=$(date +%s)

	echo "======================================="
	echo "=> Setting up Prometheus Node Exporter"
	echo "======================================="

	echo "=> Checking script dependencies"
	for cmd in jq tar curl; do
		command -v "${cmd}" > /dev/null 2>&1 || {
			echo "=> ERROR: This script depends on ${cmd}. Exiting" >&2
			exit 1
		}
	done

	echo "=> Setting up user account/group for monitoring"
	# create group and user account if they doesn't exist
	getent group monitoring &> /dev/null || sudo groupadd monitoring
	id -u node_exporter &> /dev/null || sudo useradd \
		--no-create-home \
		--gid monitoring \
		--shell /usr/sbin/nologin \
		node_exporter

	echo "=> Downloading Prometheus Node Exporter"
	local hardware_name
	hardware_name="$(uname --machine)"

	local cpu_arch
	if [[ "${hardware_name}" == "aarch64" ]] || [[ "${hardware_name}" == "arm64" ]]; then
		cpu_arch="arm64"
	elif [[ "${hardware_name}" == "amd64" ]] || [[ "${hardware_name}" == "x86_64" ]]; then
		cpu_arch="amd64"
	else
		echo "=> ERROR: Unknown CPU architecture: ${hardware_name}" >&2
		exit 1
	fi

	local tag_name # v2.0.3
	tag_name="$(curl -fsSL https://api.github.com/repos/prometheus/node_exporter/releases/latest | jq -r '.tag_name')"
	[[ -n "${tag_name}" && "${tag_name}" != "null" ]] || {
		echo "=> ERROR: Failed to resolve latest release" >&2
		exit 1
	}
	echo "=> Found Prometheus Node Exporter version ${tag_name}"

	local file_name
	file_name="node_exporter-${tag_name#v}.linux-${cpu_arch}"

	local download_url
	download_url="https://github.com/prometheus/node_exporter/releases/download/${tag_name}/${file_name}.tar.gz"

	curl -fSLO "${download_url}" --output-dir /tmp
	echo "=> Extracting downloaded archive"
	tar --extract -C /tmp -zv -f "/tmp/${file_name}.tar.gz"
	sudo mv "/tmp/${file_name}/node_exporter" /usr/local/bin/node_exporter
	sudo chown root:root /usr/local/bin/node_exporter
	sudo chmod 755 /usr/local/bin/node_exporter

	# cleaning up
	echo "=> Cleaning up downloaded files"
	rm -rf "/tmp/${file_name}"
	rm -rf "/tmp/${file_name}.tar.gz"

	echo "=> Setting up systemd service"

	local service_file="/etc/systemd/system/prometheus-node-exporter.service"
	sudo tee "${service_file}" &> /dev/null <<- 'EOF'
		[Unit]
		Description=Prometheus Node Exporter
		After=network-online.target
		Requires=network-online.target
		Wants=network-online.target
		StartLimitIntervalSec=0

		[Service]
		Type=simple
		User=node_exporter
		Group=monitoring
		Restart=on-failure
		RestartSec=3
		ProtectHome=read-only
		NoNewPrivileges=yes
		ProtectSystem=strict
		ProtectControlGroups=true
		ProtectKernelModules=true
		ProtectKernelTunables=yes
		SyslogIdentifier=node_exporter
		LimitNOFILE=65536
		ExecStart=/usr/local/bin/node_exporter \
			--web.listen-address=127.0.0.1:9100

		[Install]
		WantedBy=multi-user.target
	EOF

	sudo chmod 644 "${service_file}"
	echo "=> Created systemd service file ${service_file}"

	sudo systemctl daemon-reload
	sudo systemctl enable prometheus-node-exporter
	sudo systemctl restart prometheus-node-exporter

	echo
	echo -e "=> \e[90;102;2m INFO \e[m Prometheus Node exporter has been setup successfully."
	echo "=> Finished in $(($(date +%s) - start_time)) seconds"
	echo
}

main "$@"
