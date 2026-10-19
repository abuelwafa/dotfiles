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

set -euo pipefail
shopt -s globstar nullglob
# Debug script by setting TRACE=1
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

function setup_chrome() {
	if ! command -v google-chrome; then
		curl -fSLO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb --output-dir ~/workspace/temp
		sudo dpkg -i ~/workspace/temp/google-chrome-stable_current_amd64.deb
		rm ~/workspace/temp/google-chrome-stable_current_amd64.deb
	else
		echo "  Google Chrome is already installed."
	fi
}

function main() {
	mkdir -p ~/applications

	brew install \
		lima \
		lima-additional-guestagents \
		font-jetbrains-mono-nerd-font \
		font-meslo-lg-nerd-font \
		xclip \
		libgnome-desktop-3-dev

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

	echo "=> Install Google Chrome browser"
	echo "=> Done. Enjoy your newly configured desktop."
}

main "$@"
