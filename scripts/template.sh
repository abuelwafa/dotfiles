#!/usr/bin/env bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# small description on what this script does.
# Check help and usage information through ./setup_backend --help
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/template.sh)"

set -euo pipefail
shopt -s globstar nullglob
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

function main() {
	local start_time
	start_time=$(date +%s)

	echo "======================================="
	echo "=> Running script"
	echo "======================================="
	echo "=> sleeping 3 seconds"
	sleep 3

	echo
	echo -e "=> \e[90;102;2m INFO \e[m Finished running script."
	echo "=> Done in $(($(date +%s) - start_time)) seconds"
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
