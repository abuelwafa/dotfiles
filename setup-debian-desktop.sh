#!/usr/bin/env bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# Interactive bash script for configuring Debian Gnome desktop for development
# Usage:
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/server-configs/setup-debian-desktop.sh)"
#
# This script assumes curl and sudo already installed and the current user is already in the sudo group.

set -o errexit
set -o nounset
set -o pipefail
shopt -s globstar nullglob
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

shopt -s globstar nullglob

function setup_chrome() {
	echo "=> Installing Google Chrome browser"
	if ! command -v google-chrome; then
		curl -fSLO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb --output-dir ~/workspace/temp
		sudo dpkg -i ~/workspace/temp/google-chrome-stable_current_amd64.deb
		rm ~/workspace/temp/google-chrome-stable_current_amd64.deb
	else
		echo "  Google Chrome is already installed."
	fi
}

function setup_thunderbird() {
	# https://support.mozilla.org/en-US/kb/installing-thunderbird-linux
	echo "Installing Thunderbird"
}

function setup_alacritty() {
	git clone https://github.com/alacritty/alacritty.git ~/applications/alacritty

	mkdir -p ~/.config/alacritty
	ln -s ~/workspace/dotfiles/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
}

function main() {
	mkdir -p ~/applications

	echo "=> running base server config"
	/bin/bash -c "$(
		curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/server-configs/dev-vm-setup.sh
	)"

	brew install \
		lima \
		lima-additional-guestagents \
		font-jetbrains-mono-nerd-font \
		font-meslo-lg-nerd-font \
		xclip \
		libgnome-desktop-3-dev

	git clone https://github.com/tinted-theming/tinted-shell.git ~/applications/tinted-shell

	echo

	echo "=> install nvidia cuda drivers from:"
	echo "https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Debian&target_version=12&target_type=deb_local"
	echo

	# gnome extensions manager
	echo "=> Install the following Gnome extensions:"
	echo "https://extensions.gnome.org/extension/779/clipboard-indicator/"
	echo "https://extensions.gnome.org/extension/307/dash-to-dock/"
	echo "https://extensions.gnome.org/extension/2087/desktop-icons-ng-ding/"
	echo
	read -p "Press Enter to continue..." -r
	echo

	echo "=> make caps lock as ctrl in gnome tweaks"
	echo
	read -p "Press Enter to continue..." -r
	echo

	echo "=> Done. Enjoy your newly configured desktop."
}

main "$@"
