#!/usr/bin/env bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# Interactive bash script for configuring Debian/Ubuntu servers
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/server-configs/setup.sh)"

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

function setup_aws_cli() {
	read -p "Setup and configure AWS CLI? (y/n): " -r install_aws_cli
	echo
	if [[ ${install_aws_cli} =~ ^[Yy]$ ]]; then
		echo "=> installing AWS CLL"
		curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" --output-dir /tmp -o "awscliv2.zip"
		unzip -u awscliv2.zip
		if command -v aws &> /dev/null; then
			sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
		else
			sudo ./aws/install
		fi
	else
		echo "Skipping install of AWS CLI"
	fi
	echo
}

function setup_hetzner_cli() {
	read -p "Setup and configure Hetzner cloud CLI (release binary)? (y/n): " -r install_hcloud_cli
	echo
	if [[ ${install_hcloud_cli} =~ ^[Yy]$ ]]; then
		echo "=> installing Hetzner cloud CLL"
		curl -sSL https://github.com/hetznercloud/cli/releases/latest/download/hcloud-linux-amd64.tar.gz --output-dir /tmp
		sudo tar -C /usr/local/bin --no-same-owner -xzf /tmp/hcloud-linux-amd64.tar.gz hcloud
		rm /tmp/hcloud-linux-amd64.tar.gz
	else
		echo "Skipping install of Hetzner cloud CLI"
	fi
	echo
}

function setup_kubectl() {
	read -p "Setup and configure Kubernetes CLI (kubectl)? (y/n): " -r install_kubectl
	echo
	if [[ ${install_kubectl} =~ ^[Yy]$ ]]; then
		echo "=> installing Kubernetes CLL"

		sudo mkdir -p /etc/apt/keyrings
		curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key \
			| sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
		sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

		if [[ -f "/etc/apt/sources.list.d/kubernetes.list" ]]; then
			echo -e "\n\e[90;103;2m WARNING \e[m file /etc/apt/sources.list.d/kubernetes.list already exists. \n\e[90;43;2m \e[m         Overwriting with latest version.\n"
			sudo cp /etc/apt/sources.list.d/kubernetes.list \
				/etc/apt/sources.list.d/kubernetes.list.bak-"$(date +%s)"
		fi
		echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
		sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

		sudo apt-get update
		sudo apt-get install -y kubectl
	else
		echo "Skipping install of Kubernetes CLI"
	fi
	echo
}

function setup_gcloud_cli() {
	read -p "Setup and configure Google Cloud CLI? (y/n): " -r install_gcloud_cli
	echo
	if [[ ${install_gcloud_cli} =~ ^[Yy]$ ]]; then
		if command -v gcloud &> /dev/null; then
			echo "=> Google Cloud CLI is already installed. update"
		else
			echo "=> installing Google Cloud CLI"
			curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
			local repo
			repo="deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main"
			echo "${repo}" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
			sudo apt-get update && sudo apt-get install -y google-cloud-cli
			echo "=> Google cloud cli has been installed successfully."
			echo "=> run \`gcloud init\` to configure it"
		fi
	else
		echo "Skipping install of Google Cloud CLI"
	fi
	echo
}

function _in_array() {
	# example:
	# echo $(_in_array "target" "${arr[@]}")
	local target=$1
	# disabling variable quoting as we are passing an array here
	# shellcheck disable=SC2206
	local arr=($2)
	local found=0
	for item in "${arr[@]}"; do
		if [[ "${target}" == "${item}" ]]; then
			found=1
			break
		fi
	done
	echo "${found}"
}

function harden_ssh() {
	read -p "Harden SSH? (y/n): " -r harden_ssh
	echo
	if [[ ${harden_ssh} =~ ^[Yy]$ ]]; then
		echo "=> hardening SSH"

		local ssh_allowed_users
		read -p "Enter usernames allowed to SSH (space separated list): " -r ssh_allowed_users

		local ssh_listen_address_rule
		ssh_listen_address_rule=""
		local ssh_listen_address
		PS3="Select listen address (choose Ignore to keep the default behaviour which is listening on any address): "
		local hostnames
		hostnames=$(hostname -I)
		local options=(${hostnames[@]} "Ignore")

		select opt in "${options[@]}"; do
			if [[ "$(_in_array "${opt}" "${hostnames[@]}")" == "1" ]]; then
				ssh_listen_address_rule="ListenAddress ${opt}"
				ssh_listen_address=${opt}
				break
			elif [[ "${opt}" == "Ignore" ]]; then
				break
			else
				echo "Invalid option! Please select properly."
			fi
		done

		local ssh_listen_port
		read -p "SSH listen port: " -r ssh_listen_port

		cat <<- EOF | sudo tee /etc/ssh/sshd_config.d/99-override.conf &> /dev/null
			# disable root login
			PermitRootLogin no

			# disable password authentication
			PasswordAuthentication no

			# restrict users allowed to use SSH
			AllowUsers ${ssh_allowed_users}

			# change the SSH port
			Port ${ssh_listen_port}

			# change listen address of the server
			${ssh_listen_address_rule}
		EOF

		# enable the ssh port for ssh in firewall
		if [[ -z "${ssh_listen_address}" ]]; then
			command -v ufw > /dev/null 2>&1 && sudo ufw allow "${ssh_listen_port}"/tcp
		else
			command -v ufw > /dev/null 2>&1 && sudo ufw limit in proto tcp to "${ssh_listen_address}" port "${ssh_listen_port}" from 0.0.0.0/0 comment "allow ssh over vpn"
		fi

		# restart the ssh service
		echo -e "\n\e[90;103;2m WARNING \e[m Restarting SSH service. Check that your SSH connection still works in another terminal.\n"
		sudo systemctl restart ssh
	else
		echo "Skipping SSH hardening"
	fi
	echo
}

function setup_nginx() {
	read -p "Setup and configure Nginx? (y/n): " -r install_nginx
	echo
	if [[ ${install_nginx} =~ ^[Yy]$ ]]; then
		echo "=> installing Nginx"
		sudo apt-get install -y nginx nginx-extras
		command -v ufw > /dev/null 2>&1 && sudo ufw allow http && sudo ufw reload

		# generate a strong diffie-hellman group
		mkdir -p /etc/nginx/dhparam
		if [[ ! -f "/etc/nginx/dhparam/dhparam.pem" ]]; then
			openssl dhparam -out /etc/nginx/dhparam/dhparam.pem 4096
		fi

		cat <<- EOF | tee /etc/nginx/sites-available/main_site.nginx &> /dev/null
			upstream ___ {

			}

			server {
				server_name;
				client_max_body_size 2m;

				proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
				proxy_set_header X-Forwarded-Proto \$scheme;
				proxy_set_header X-Real-IP \$remote_addr;
				proxy_set_header Host \$host;

				proxy_redirect off;
				proxy_pass http://gunicorn;
			}
		EOF

		rm /etc/nginx/sites-enabled/default || true
		ln --force -s /etc/nginx/sites-available/main_site.nginx /etc/nginx/sites-enabled/
		echo "=> make sure to rename and revise the nginx config at /etc/nginx/sites-available/main_site.nginx"

		if systemctl is-active nginx --quiet; then
			systemctl reload nginx
		else
			systemctl start nginx
		fi
		if ! systemctl is-enabled nginx --quiet; then
			systemctl enable nginx
		fi
	else
		echo "Skipping install of Nginx"
	fi
	echo
}

function setup_docker() {
	read -p "Setup and configure Docker engine? (y/n): " -r install_docker
	echo
	if [[ ${install_docker} =~ ^[Yy]$ ]]; then
		echo "=> installing Docker engine"
		for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
			sudo apt-get remove "${pkg}"
		done

		sudo install -m 0755 -d /etc/apt/keyrings
		sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
		sudo chmod a+r /etc/apt/keyrings/docker.asc

		local arch
		arch=$(dpkg --print-architecture)
		local codename
		# shellcheck disable=SC2154
		codename=$(. /etc/os-release && echo "${VERSION_CODENAME}")

		local repo
		repo="deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${codename} stable"

		echo "${repo}" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

		sudo apt-get update

		sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

		getent group docker &> /dev/null || sudo groupadd docker
		sudo usermod -aG docker "${USER}"
		newgrp docker

		echo "Docker engine has been successfully installed."
	else
		echo "Skipping install of Docker"
	fi
	echo
}

function setup_wireguard_client() {
	echo "=> Setting up Wireguard VPN"
	local install_wireguard
	echo "=> installing Wireguard"
	sudo apt-get install -y wireguard wireguard-tools

	# generate wireguard private key only if it doesn't exist
	if [[ ! -f "/etc/wireguard/wg0.key" ]]; then
		wg genkey | sudo tee /etc/wireguard/wg0.key &> /dev/null
	fi

	sudo cat /etc/wireguard/wg0.key | wg pubkey | sudo tee /etc/wireguard/wg0.key.pub &> /dev/null

	echo
	echo "==> The public key for wireguard is:"
	sudo cat /etc/wireguard/wg0.key.pub
	echo
	read -p "Press Enter to continue..." -r

	echo
	read -p "VPN server host(hostname only): " -r vpn_server_host
	read -p "VPN server port: " -r vpn_server_port
	read -p "VPN server public key: " -r vpn_server_public_key
	read -p "Client assigned IP: " -r vpn_client_ip
	read -p "Client allowed IPs: " -r vpn_client_allowed_ips
	cat <<- EOF | sudo tee /etc/wireguard/wg0.conf &> /dev/null
		[Interface]
		Address = ${vpn_client_ip}/32
		PrivateKey = $(sudo cat /etc/wireguard/wg0.key)

		[Peer]
		Endpoint = ${vpn_server_host}:${vpn_server_port}
		AllowedIPs = ${vpn_client_allowed_ips}
		PersistentKeepalive = 25
		PublicKey = ${vpn_server_public_key}
	EOF
	sudo systemctl enable wg-quick@wg0
	sudo systemctl start wg-quick@wg0
	wg-quick down wg0
	wg-quick up wg0

	# override the ssh service to start after the wireguard one
	# to fix ssh service error after restarts
	sudo mkdir -p /etc/systemd/system/ssh.service.d
	sudo touch /etc/systemd/system/ssh.service.d/override.conf
	cat <<- EOF | sudo tee /etc/systemd/system/ssh.service.d/override.conf &> /dev/null
		[Unit]
		After=network.target auditd.service wg-quick@wg0.service
		Requires=wg-quick@wg0.service
	EOF
	sudo systemctl daemon-reload
	sudo systemctl restart ssh

	echo
}

function setup_wireguard_server() {
	local install_wireguard
	read -p "Setup and configure Wireguard as a server (exit node)? (y/n): " -r install_wireguard
	echo
	if [[ ${install_wireguard} =~ ^[Yy]$ ]]; then
		echo "=> installing Wireguard"
		sudo apt-get install -y wireguard wireguard-tools

		# generate wireguard private key only if it doesn't exist
		if [[ ! -f "/etc/wireguard/wg0.key" ]]; then
			wg genkey | sudo tee /etc/wireguard/wg0.key &> /dev/null
		fi

		sudo cat /etc/wireguard/wg0.key | wg pubkey | sudo tee /etc/wireguard/wg0.key.pub &> /dev/null

		echo
		echo "==> The public key for wireguard is:"
		sudo cat /etc/wireguard/wg0.key.pub
		echo
		read -p "Press Enter to continue..." -r

		echo
		read -p "VPN listen port: " -r vpn_listen_port
		read -p "Wireguard subnets(example 10.0.0.0/8) [use commas for multiple subnets]: " -r vpn_network_subnet
		cat <<- EOF | sudo tee /etc/wireguard/wg0.conf &> /dev/null
			[Interface]
			Address = ${vpn_network_subnet}
			ListenPort = ${vpn_listen_port}
			PrivateKey = $(sudo cat /etc/wireguard/wg0.key)

			# [Peer]
			# # client name/identifier here
			# AllowedIPs = 10.0.0.0/8
			# PublicKey = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		EOF
		sudo systemctl enable wg-quick@wg0
		sudo systemctl start wg-quick@wg0
		wg-quick down wg0
		wg-quick up wg0
	else
		echo "Skipping Wireguard server setup"
	fi
	echo
}

function setup_prometheus_node_exporter() {
	echo "=> Setting up Prometheus Node Exporter"
	echo "=> Setting up user account/group for monitoring"
	# create group and user account if they doesn't exist
	getent group monitoring &> /dev/null || sudo groupadd monitoring
	id -u node_exporter &> /dev/null || sudo useradd \
		--no-create-home \
		--no-user-group \
		--shell /usr/sbin/nologin \
		--groups monitoring \
		node_exporter

	echo "=> Downloading Prometheus Node Exporter"
	local hardware_name
	hardware_name="$(uname --machine)"

	local cpu_arch
	if [[ "${hardware_name}" == "arm64" ]]; then
		cpu_arch="arm64"
	else
		cpu_arch="amd64"
	fi

	local tag_name # v2.0.3
	tag_name="$(curl -fsSL https://api.github.com/repos/prometheus/node_exporter/releases/latest | jq -r '.tag_name')"
	echo "=> found Prometheus Node Exporter version ${tag_name}"

	local node_exporter_version # 2.0.3
	node_exporter_version="$(echo "${tag_name}" | cut -d 'v' -f 2)"

	local file_name
	file_name="node_exporter-${node_exporter_version}.linux-${cpu_arch}"

	local download_url
	download_url="https://github.com/prometheus/node_exporter/releases/download/${tag_name}/${file_name}.tar.gz"

	curl -fSLO "${download_url}" --output-dir /tmp
	tar --extract -C /tmp -zvv -f "/tmp/${file_name}.tar.gz"
	sudo mv "/tmp/${file_name}/node_exporter" /usr/local/bin/node_exporter
	sudo chmod ug+x /usr/local/bin/node_exporter
	sudo chown node_exporter:monitoring /usr/local/bin/node_exporter

	# cleaning up
	rm -rf "/tmp/${file_name}"
	rm -rf "/tmp/${file_name}.tar.gz"

	echo "==> Setting up systemd service"
	sudo mkdir -p /etc/prometheus-node-exporter

	# sudo touch /etc/prometheus/exporters/node-exporter/web-config.yml
	# sudo tee -a /etc/prometheus/exporters/node-exporter/web-config.yml &> /dev/null <<-EOF
	# EOF

	local node_exporter_listen_address
	local node_exporter_params=""
	echo
	echo "By default, Node Exporter will listen on 127.0.0.1:9100"
	echo "you can enter additional listen address. leave blank use the localhost only"
	read -p "Additional Node Exporter listen address and port (host:port): " -r node_exporter_listen_address
	if [[ ! -z "${node_exporter_listen_address}" ]]; then
		node_exporter_params="${node_exporter_params} --web.listen-address=${node_exporter_listen_address}"
	fi

	sudo touch /etc/systemd/system/prometheus-node-exporter.service
	sudo tee /etc/systemd/system/prometheus-node-exporter.service &> /dev/null <<- EOF
		[Unit]
		Description=Prometheus Node Exporter
		After=network-online.target
		Requires=network-online.target
		Wants=network-online.target

		[Service]
		Type=simple
		User=node_exporter
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
		SyslogIdentifier=node_exporter
		ExecStart=/usr/local/bin/node_exporter --web.listen-address=127.0.0.1:9100${node_exporter_params}
		# we can also add a web.config.yml file param --web.config.file=/etc/prometheus/web.config.yml
		# to configure basic auth users and TLS. but it's better to handle these through a reverse proxy
		# and an auth server. e.g. nginx and keycloak

		[Install]
		WantedBy=multi-user.target
	EOF
	local edit_prom_node_exporter_service_file
	read -p "Would you like to edit the systemd service before running? (y/n): " -r edit_prom_node_exporter_service_file
	if [[ ${edit_prom_node_exporter_service_file} =~ ^[Yy]$ ]]; then
		sudoedit /etc/systemd/system/prometheus-node-exporter.service
	fi

	# adjust ownership and permissions
	sudo chmod 664 /etc/systemd/system/prometheus-node-exporter.service
	sudo chown --recursive node_exporter:monitoring /etc/prometheus

	sudo systemctl daemon-reload

	if systemctl is-active prometheus-node-exporter --quiet; then
		sudo systemctl restart prometheus-node-exporter
	else
		sudo systemctl start prometheus-node-exporter
	fi
	if ! systemctl is-enabled prometheus-node-exporter --quiet; then
		sudo systemctl enable prometheus-node-exporter
	fi

	echo -e "\n\e[90;102;2m INFO \e[m Prometheus Node exporter has been setup successfully."
	echo
}

function setup_prometheus_server() {
	read -p "Setup and configure Prometheus server? (y/n): " -r install_prometheus
	echo
	if [[ ${install_prometheus} =~ ^[Yy]$ ]]; then
		echo "TODO"
	else
		echo "Skipping installation of prometheus server"
	fi
	echo
}

function setup_grafana_alloy() {
	read -p "Setup and configure Grafana Alloy? (y/n): " -r install_alloy
	echo
	if [[ ${install_alloy} =~ ^[Yy]$ ]]; then
		echo "=> setting up Grafana alloy"

		if command -v alloy &> /dev/null; then
			echo "=> Grafana alloy is already installed. update through apt."
		else
			sudo mkdir -p /etc/apt/keyrings/
			curl -fsSL https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
			local grafana_repo="deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main"
			echo "${grafana_repo}" | sudo tee /etc/apt/sources.list.d/grafana.list

			sudo apt-get update && sudo apt-get install -y alloy
		fi
	else
		echo "Skipping install of Grafana Alloy"
	fi
	echo
}

function setup_git() {
	local install_git
	read -p "Setup and configure git? (y/n): " -r install_git
	echo
	if [[ ${install_git} =~ ^[Yy]$ ]]; then
		echo "=> installing git"
		sudo apt-get install -y git
		echo "=> configuring git"

		local git_email
		local git_name
		read -p "Enter git config email: " -r git_email
		echo
		read -p "Enter git config name: " -r git_name
		echo
		git config --global user.email "${git_email}"
		git config --global user.name "${git_name}"
		git config --global user.useConfigOnly true
		git config --global color.ui true
		git config --global core.editor vim
		git config --global core.autocrlf input
		git config --global status.showUntrackedFiles all
	else
		echo "Skipping setup of Git"
	fi
	echo
}

function setup_tmux() {
	read -p "Setup and configure tmux? (y/n): " -r install_tmux
	echo
	if [[ ${install_tmux} =~ ^[Yy]$ ]]; then
		echo "=> installing tmux"
		sudo apt-get install -y tmux
		echo "=> configuring tmux"
		# backup .tmux.conf file if it already exists
		if [[ -f "${HOME}/.tmux.conf" ]]; then
			cp ~/.tmux.conf ~/.tmux.conf-bak-"$(date +%s)"
			echo '=> old ~/.tmux.conf have been backed up'
		fi
		curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/tmux/tmux-minimal.conf > ~/.tmux.conf
	else
		echo "Skipping setup of TMUX"
	fi
	echo
}

function setup_ufw() {
	read -p "Setup and configure ufw? (y/n): " -r install_ufw
	echo
	if [[ ${install_ufw} =~ ^[Yy]$ ]]; then
		echo "=> installing and configuring ufw"
		sudo apt-get install -y ufw
		sudo ufw default deny incoming
		# sudo ufw default deny outgoing
		sudo ufw allow ssh
		sudo ufw --force enable
		echo
		sudo ufw status verbose
	else
		echo "Skipping UFW firewall setup"
	fi
	echo
}

function setup_fail2ban() {
	read -p "Setup and configure fail2ban? (y/n): " -r install_fail2ban
	echo
	if [[ ${install_fail2ban} =~ ^[Yy]$ ]]; then
		echo "=> installing fail2ban"
		echo "TODO"
		sudo apt-get install -y fail2ban

		echo "=> configuring fail2ban"
		sudo systemctl enable --now fail2ban.service

		echo
		systemctl status fail2ban.service
	else
		echo "Skipping setup of fail2ban"
	fi
	echo
}

function setup_containerd() {
	read -p "Setup and configure containerd? (y/n): " -r install_containerd
	echo
	if [[ ${install_containerd} =~ ^[Yy]$ ]]; then
		echo '=> Installing Containerd'

		local hardware_name
		hardware_name="$(uname --machine)"

		local cpu_arch
		if [[ "${hardware_name}" == "arm64" ]]; then
			cpu_arch="arm64"
		else
			cpu_arch="amd64"
		fi

		local tag_name # v2.0.3
		tag_name="$(curl -fsSL https://api.github.com/repos/containerd/containerd/releases/latest | jq -r '.tag_name')"
		echo "=> found containerd version ${tag_name}"

		local containerd_version # 2.0.3
		containerd_version="$(echo "${tag_name}" | cut -d 'v' -f 2)"

		local file_name
		file_name="containerd-${containerd_version}-linux-${cpu_arch}.tar.gz"

		local download_url
		download_url="https://github.com/containerd/containerd/releases/download/${tag_name}/${file_name}"

		curl -fSLO "${download_url}" --output-dir /tmp
		sudo tar --extract -C /usr/local -zvv -f /tmp/"${file_name}"

		echo "=> setting up containerd systemd service"
		# download containerd systemd service file
		sudo mkdir -p /usr/local/lib/systemd/system
		curl -fsSL https://raw.githubusercontent.com/containerd/containerd/main/containerd.service | sudo tee /usr/local/lib/systemd/system/containerd.service &> /dev/null
		sudo systemctl daemon-reload
		sudo systemctl enable --now containerd

		echo "=> cleaning up"
		rm /tmp/"${file_name}"

		echo "=> containerd has been successfully installed"
	else
		echo "Skipping install of containerd"
	fi
	echo
}

function setup_nerdctl_minimal() {
	read -p "Setup and configure nerdctl (minimal)? (y/n): " -r install_nerdctl_minimal
	echo
	if [[ ${install_nerdctl_minimal} =~ ^[Yy]$ ]]; then
		echo '=> Installing nerdctl (minimal version)'

		local hardware_name
		hardware_name="$(uname --machine)"

		local cpu_arch
		if [[ "${hardware_name}" == "arm64" ]]; then
			cpu_arch="arm64"
		else
			cpu_arch="amd64"
		fi

		local tag_name # v2.0.3
		tag_name="$(curl -fsSL https://api.github.com/repos/containerd/nerdctl/releases/latest | jq -r '.tag_name')"
		echo "=> found nerdctl version ${tag_name}"

		local nerdctl_version # 2.0.3
		nerdctl_version="$(echo "${tag_name}" | cut -d 'v' -f 2)"

		local file_name
		file_name="nerdctl-${nerdctl_version}-linux-${cpu_arch}.tar.gz"

		local download_url
		download_url="https://github.com/containerd/nerdctl/releases/download/${tag_name}/${file_name}"

		curl -fSLO "${download_url}" --output-dir /tmp
		# sudo tar --extract -C /usr/local -zvv -f "$file_name"
		# sudo systemctl enable --now containerd

		echo "=> cleaning up"
		rm /tmp/"${file_name}"
		echo "=> nerdctl has been successfully installed"
	else
		echo "Skipping install of nerdctl"
	fi
	echo
}

function setup_nerdctl_full() {
	read -p "Setup and configure full nerdctl (nerdctl + containerd + CNI)? (y/n): " -r install_containerd
	echo
	if [[ ${install_containerd} =~ ^[Yy]$ ]]; then
		echo '=> Installing nerdctl (full version)'

		local hardware_name
		hardware_name="$(uname --machine)"

		local cpu_arch
		if [[ "${hardware_name}" == "arm64" ]]; then
			cpu_arch="arm64"
		else
			cpu_arch="amd64"
		fi

		local tag_name # v2.0.3
		tag_name="$(curl -fsSL https://api.github.com/repos/containerd/nerdctl/releases/latest | jq -r '.tag_name')"
		echo "=> found nerdctl version ${tag_name}"

		local nerdctl_version # 2.0.3
		nerdctl_version="$(echo "${tag_name}" | cut -d 'v' -f 2)"

		local file_name
		file_name="nerdctl-full-${nerdctl_version}-linux-${cpu_arch}.tar.gz"

		local download_url
		download_url="https://github.com/containerd/nerdctl/releases/download/${tag_name}/${file_name}"

		curl -fSLO "${download_url}" --output-dir /tmp
		sudo tar --extract -C /usr/local -zvv -f /tmp/"${file_name}"
		sudo systemctl enable --now containerd

		echo "=> cleaning up"
		rm /tmp/"${file_name}"
		echo "=> nerdctl has been successfully installed"
	else
		echo "Skipping install of containerd/nerdctl"
	fi
	echo
}

function install_build_essential() {
	echo -ne "Install build essential?\n[no] for a production webserver. [yes] for a development machine. (y/n)\nInstall build-essential?: "
	read -r install_build_essential
	echo
	if [[ ${install_build_essential} =~ ^[Yy]$ ]]; then
		echo "=> Installing build-essential"
		echo
		sudo apt-get install -y build-essential
	else
		echo "Skipping installation of build-essential package"
	fi
	echo
}

function check_system_reboot() {
	echo "=> Checking if system reboot is required..."
	if [[ -f /var/run/reboot-required ]]; then
		echo -e "\n\e[90;103;2m WARNING \e[m System restart required. Consider rebooting by running:\n\e[90;43;2m \e[m         sudo shutdown -r now\n"
	else
		echo "System reboot is not required."
		echo
	fi
	echo
}

function setup_hostname() {
	echo "Checking machine hostname..."
	local current_hostname
	current_hostname=$(hostname)
	echo "Current hostname is set to: ${current_hostname}"
	read -p "Update machine hostname? (y/n): " -r update_hostname
	echo
	if [[ ${update_hostname} =~ ^[Yy]$ ]]; then
		local new_hostname
		read -p "Enter new hostname: " -r new_hostname
		if [[ "${current_hostname}" != "${new_hostname}" ]]; then
			echo "=> changing hostname to ${new_hostname}"
			# on a plain debian install, we get an error failed to connect to system scope bus via
			# local transoport.
			# the fix to start the dbus socket
			# systemctl start dbus
			sudo hostnamectl set-hostname "${new_hostname}"

			echo "Updating the hosts file..."
			cp /etc/hosts /etc/hosts.bak-"$(date +%s)"
			sed -i -e "s/^127.0.1.1\(.*\)/# 127.0.1.1\1/" /etc/hosts
			echo "" | sudo tee -a /etc/hosts &> /dev/null
			echo "127.0.1.1    ${new_hostname}" | sudo tee -a /etc/hosts &> /dev/null
			echo "Done."
			echo
		fi
	else
		echo "Skipping setting hostname"
	fi
	echo
}

function setup_harbor() {
	read -p "Setup and configure Harbor registry? (y/n): " -r install_harbor
	echo
	if [[ ${install_harbor} =~ ^[Yy]$ ]]; then
		echo "=> installing Harbor"
		echo "TODO"
		# install docker dependency if not already installed
		if ! command -v docker &> /dev/null; then
			setup_docker
		fi
		# download the install script
		local tag_name # v2.0.3
		tag_name="$(curl -fsSL https://api.github.com/repos/goharbor/harbor/releases/latest | jq -r '.tag_name')"
		echo "=> found Harbor version ${tag_name}"

		local file_name
		file_name="harbor-online-installer-${tag_name}.tgz"

		local download_url
		download_url="https://github.com/goharbor/harbor/releases/download/${tag_name}/${file_name}"

		curl -fSLO "${download_url}" --output-dir /tmp

		# tar xzvf harbor-online-installer-version.tgz

		# configure

		# run the install script

	else
		echo "Skipping install of Harbor"
	fi
	echo
}

function setup_keycloak() {
	read -p "Setup and configure Keycloak? (y/n): " -r install_keycloak
	echo
	if [[ ${install_keycloak} =~ ^[Yy]$ ]]; then
		echo "=> installing Keycloak"
		echo "TODO"
	else
		echo "Skipping install of Keycloak"
	fi
	echo
}

function setup_nfs() {
	read -p "Setup and configure NFS? (y/n): " -r install_nfs
	echo
	if [[ ${install_nfs} =~ ^[Yy]$ ]]; then
		echo "=> Setting up NFS"
		echo "TODO"
	else
		echo "Skipping setup of NFS"
	fi
	echo
}

main() {
	sudo apt-get update
	sudo apt-get upgrade -y
	sudo apt-get install -y \
		apt-transport-https \
		bash \
		bash-completion \
		ca-certificates \
		curl \
		gnupg \
		htop \
		jq \
		locales \
		locales-all \
		openssh-server \
		openssl \
		python3 \
		python3-venv \
		sudo \
		tmux \
		tzdata \
		unattended-upgrades \
		unzip \
		vim

	echo

	sudo apt-get autoremove -y

	# backup .bash_aliases file if it already exists
	if [[ -f "${HOME}/.bash_aliases" ]]; then
		cp ~/.bash_aliases ~/.bash_aliases-bak-"$(date +%s)"
		echo '=> old ~/.bash_aliases have been backed up'
	fi
	curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/bash/bashrc > ~/.bash_aliases

	# backup .vimrc file if it already exists
	if [[ -f "${HOME}/.vimrc" ]]; then
		cp ~/.vimrc ~/.vimrc-bak-"$(date +%s)"
		echo '=> old ~/.vimrc have been backed up'
	fi
	curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/vim/.vimrc > ~/.vimrc
	sudo update-alternatives --set editor "$(command -v vim.basic)"

	echo

	install_build_essential
	setup_git
	setup_tmux
	setup_hostname
	setup_wireguard_server
	setup_wireguard_client
	setup_ufw
	harden_ssh
	setup_nginx
	setup_fail2ban

	setup_containerd
	setup_docker
	setup_kubectl
	setup_nerdctl_minimal
	setup_nerdctl_full
	# setup_crictl

	setup_aws_cli
	setup_gcloud_cli
	setup_hetzner_cli
	setup_prometheus_server
	setup_prometheus_node_exporter
	setup_grafana_alloy
	setup_harbor
	setup_nfs
	setup_keycloak

	# setup following CLIs:
	# - cmctl cert manager
	# - linkerd
	# - egctl envoy gateway cli

	check_system_reboot

	echo "Done. Enjoy your newly configured server."
}

main "$@"

function setup_certbot() {
	echo "=> Setting up Certbot and LetsEncrypt"

	local new_hostname
	new_hostname=$1

	apt-get install -y libaugeas-dev gcc
	apt-get remove -y certbot

	rm -rf /opt/certbot || true
	rm /usr/bin/certbot || true

	python3 -m venv /opt/certbot/
	/opt/certbot/bin/pip install certbot
	ln -s /opt/certbot/bin/certbot /usr/bin/certbot

	echo
	echo "=> IF certificates are obtained through the http challenge, make sure to allow the http port in firewall"
	echo "   ufw allow http && ufw reload"
	# command -v ufw > /dev/null 2>&1 && ufw allow http && ufw reload

	echo
	echo "==> Obtaining Certificate"
	# TODO: this will fail if port 80 not enabled in firewall settings
	certbot certonly \
		--standalone \
		--non-interactive \
		--agree-tos \
		-d "${new_hostname}"

	echo
}

function create_adminstrative_account() {
	local username
	username=$1

	echo "=> Creating adminstrative user: ${username}"
	if id "${username}" > /dev/null 2>&1; then
		echo "   User ${username} already exists. skipping."
		return 0
	fi

	local ssh_public_key
	ssh_public_key=$2

	useradd --create-home --shell "$(command -v bash)" --user-group --groups sudo,adm,systemd-journal "${username}"

	local generated_password
	generated_password="$(openssl rand -base64 24)"

	echo "${username}:${generated_password}" | chpasswd
	passwd --expire "${username}"

	echo "=> Your initial generated password is: ${generated_password}"
	echo "   You will be prompted to change it as soon as you login for the first time."

	mkdir -p "/home/${username}/.ssh"
	touch "/home/${username}/.ssh/authorized_keys"
	echo "${ssh_public_key}" >> "/home/${username}/.ssh/authorized_keys"
	chown --recursive "${username}:${username}" "/home/${username}/.ssh"
	chmod --changes 700 "/home/${username}/.ssh"
	chmod --changes 600 "/home/${username}/.ssh/authorized_keys"

	echo
}
