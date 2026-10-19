#!/usr/bin/env bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# Interactive bash script for configuring Debian/Ubuntu servers
# assuming sudo and curl are present
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/debian-server-setup.sh)"
#
# on a minimal bare debian install, the above command will not work. out of the box.
# if using a non root user, you can use the following one liner to install prerequisites
# su -c "apt update && apt install -y curl sudo && usermod -aG sudo,adm,systemd-journal $USER" -l root && newgrp sudo -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/debian-server-setup.sh)"
#
# if using the root user,
# apt update && apt install curl sudo && useradd --create-home --user-group --groups sudo --shell $(which bash) my_username && newgrp sudo -c "exit" && su -c 'bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/debian-server-setup.sh)"' -l my_username

set -euo pipefail
shopt -s globstar nullglob
# Debug script by setting TRACE=1
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

function setup_ufw() {
	echo "=> installing and configuring ufw"
	sudo ufw default deny incoming
	# sudo ufw default deny outgoing
	sudo ufw allow ssh
	sudo ufw --force enable
	echo
	sudo ufw status verbose
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
		ufw \
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

	echo "=> Setting up vim"
	# backup .vimrc file if it already exists
	if [[ -f "${HOME}/.vimrc" ]]; then
		cp ~/.vimrc ~/.vimrc-bak-"$(date +%s)"
		echo '=> old ~/.vimrc have been backed up'
	fi
	curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/vim/.vimrc > ~/.vimrc
	sudo update-alternatives --set editor "$(command -v vim.basic)"

	echo

	echo "=> Setting up tmux"
	# backup .tmux.conf file if it already exists
	if [[ -f "${HOME}/.tmux.conf" ]]; then
		cp ~/.tmux.conf ~/.tmux.conf-bak-"$(date +%s)"
		echo '=> old ~/.tmux.conf have been backed up'
	fi
	curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/tmux/tmux-minimal.conf > ~/.tmux.conf
	echo

	setup_ufw

	check_system_reboot

	echo "Done. Enjoy your newly configured server."
}

main "$@"
