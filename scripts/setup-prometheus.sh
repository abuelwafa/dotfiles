#!/usr/bin/env bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# Installs the lates version of prometheus and run as a systemd service
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/setup-prometheus.sh)"

set -euo pipefail
shopt -s globstar nullglob
# Debug script by setting TRACE=1
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

function main() {
	local start_time
	start_time=$(date +%s)

	echo "========================="
	echo "=> Setting up Prometheus"
	echo "========================="

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
	id -u prometheus &> /dev/null || sudo useradd \
		--no-create-home \
		--gid monitoring \
		--shell /usr/sbin/nologin \
		prometheus

	echo "=> Downloading Prometheus"
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
	tag_name="$(curl -fsSL https://api.github.com/repos/prometheus/prometheus/releases/latest | jq -r '.tag_name')"
	[[ -n "${tag_name}" && "${tag_name}" != "null" ]] || {
		echo "=> ERROR: Failed to resolve latest release" >&2
		exit 1
	}
	echo "=> Found Prometheus version ${tag_name}"

	local file_name
	file_name="prometheus-${tag_name#v}.linux-${cpu_arch}"

	local download_url
	download_url="https://github.com/prometheus/prometheus/releases/download/${tag_name}/${file_name}.tar.gz"

	curl -fSLO "${download_url}" --output-dir /tmp
	echo "=> Extracting downloaded archive"
	tar --extract -C /tmp -zv -f "/tmp/${file_name}.tar.gz"
	sudo mv "/tmp/${file_name}/prometheus" /usr/local/bin/prometheus
	sudo chown root:root /usr/local/bin/prometheus
	sudo chmod 755 /usr/local/bin/prometheus

	sudo mv "/tmp/${file_name}/promtool" /usr/local/bin/promtool
	sudo chown root:root /usr/local/bin/promtool
	sudo chmod 755 /usr/local/bin/promtool

	# cleaning up
	echo "=> Cleaning up downloaded files"
	rm -rf "/tmp/${file_name}"
	rm -rf "/tmp/${file_name}.tar.gz"

	echo "=> Configuring prometheus"
	sudo mkdir -p /etc/prometheus
	sudo mkdir -p /var/lib/prometheus

	sudo tee "/etc/prometheus/prometheus.yaml" &> /dev/null <<- 'EOF'
		---
		global:
		  scrape_interval: 15s
		  evaluation_interval: 15s
		  scrape_timeout: 10s

		alerting:
		  alertmanagers:
		    - static_configs:
		      - targets:

		rule_files:

		scrape_configs:
		  - job_name: prometheus
		    metrics_path: /metrics
		    scheme: http
		    scrape_native_histograms: true
		    static_configs:
		      - targets:
		        - 127.0.0.1:9090
		        labels:
		          app: prometheus
	EOF

	sudo chown -R root:monitoring /etc/prometheus
	sudo chmod -R u=rwX,g=rX,o= /etc/prometheus
	sudo chown -R prometheus:monitoring /var/lib/prometheus

	echo "=> Checking configuration validity"
	sudo -u prometheus /usr/local/bin/promtool check config /etc/prometheus/prometheus.yaml

	echo "=> Setting up systemd service"
	local service_file="/etc/systemd/system/prometheus.service"
	sudo tee "${service_file}" &> /dev/null <<- 'EOF'
		[Unit]
		Description=Prometheus
		After=network-online.target
		Requires=network-online.target
		Wants=network-online.target
		StartLimitIntervalSec=0

		[Service]
		Type=simple
		User=prometheus
		Group=monitoring
		Restart=on-failure
		RestartSec=3
		ProtectHome=read-only
		NoNewPrivileges=yes
		ProtectSystem=strict
		ReadWritePaths=/var/lib/prometheus
		StateDirectory=prometheus
		ProtectControlGroups=true
		ProtectKernelModules=true
		ProtectKernelTunables=yes
		SyslogIdentifier=prometheus
		LimitNOFILE=65536
		ExecStart=/usr/local/bin/prometheus \
			--config.file=/etc/prometheus/prometheus.yaml \
			--storage.tsdb.path=/var/lib/prometheus \
			--web.listen-address=127.0.0.1:9090

		[Install]
		WantedBy=multi-user.target
	EOF

	sudo chmod 644 "${service_file}"
	echo "=> Created systemd service file ${service_file}"

	sudo systemctl daemon-reload
	sudo systemctl enable prometheus
	sudo systemctl restart prometheus

	echo
	echo -e "=> \e[90;102;2m INFO \e[m Prometheus has been setup successfully."
	echo "=> Finished in $(($(date +%s) - start_time)) seconds"
	echo
}

main "$@"
