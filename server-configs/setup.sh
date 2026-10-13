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

	setup_hostname
	setup_ufw

	# setup_crictl

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
