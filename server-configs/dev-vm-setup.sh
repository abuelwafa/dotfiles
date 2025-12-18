#!/usr/bin/env bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# Interactive bash script for configuring Debian machine for development
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/server-configs/dev-vm-setup.sh)"

set -o errexit
set -o nounset
set -o pipefail
shopt -s globstar nullglob
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

shopt -s globstar nullglob

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

function setup_sdkman() {
	read -p "Setup and configure SDKMAN with java, kotlin and gradle? (y/n): " -r install_sdkman
	echo
	if [[ ${install_sdkman} =~ ^[Yy]$ ]]; then
		echo "=> Installing SDKMAN"
		curl -s "https://get.sdkman.io" | bash
		sdk install java
		sdk install gradle
		sdk install kotlin
		sdk install groovy
		sdk install maven
	else
		echo "Skipping install of SDKMAN"
	fi
	echo
}

function setup_neovim() {
	mkdir -p ~/.config/nvim
	ln --force -s ~/workspace/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
	mkdir -p ~/.nvim/_temp
	mkdir -p ~/.nvim/_backup
    cargo install --locked tree-sitter-cli
	echo "=> Openning neovim to install plugins and language servers. Exit when finished."
	sleep 2
	echo -n "=> Openning in 5 seconds."
	sleep 1
	echo -ne "\r=> Openning in 4 seconds."
	sleep 1
	echo -ne "\r=> Openning in 3 seconds."
	sleep 1
	echo -ne "\r=> Openning in 2 seconds."
	sleep 1
	echo -ne "\r=> Openning in 1 seconds."
	sleep 1
	nvim
	echo
}

function setup_homebrew() {
	echo "=> Setting up Homebrew"
	if ! command -v brew &>/dev/null 2>&1; then
		NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	else
		echo "   brew is already installed. Updating..."
		brew update
		brew upgrade
	fi
}

main() {
	rm ~/.vimrc || true
	rm ~/.bash_aliases || true
	rm ~/.tmux.conf || true
	rm ~/.gitconfig.conf || true

	sudo apt install \
		sudo \
		openssl \
		openssh-server \
		openssh-client \
		unattended-upgrades \
		vim \
		curl \
		git \
		tmux \
		jq \
		htop \
		locales \
		locales-all \
		tzdata \
		bash-completion \
		apt-transport-https \
		ca-certificates \
		gnupg \
		build-essential \
		ufw \
		zip \
		unzip \
		python3 \
		python3-venv \
		python3-pip \
		python3-dev

	mkdir -p ~/workspace
	mkdir -p ~/temp
	touch ~/.machine-config

	echo "=> Setting up DB connections file"
	if [[ ! -f ~/workspace/db-connections/connections.json ]]; then
		mkdir -p ~/workspace/db-connections
		echo '[{ "name": "postgres-local", "url": "postgresql://postgres:postgres@localhost:5432/postgres" }]' | tee ~/workspace/db-connections/connections.json &>/dev/null
	fi

	# increase inotify watchers
	echo "=> Configuring inotify watchers"
	local current_watches_limit
	current_watches_limit="$(sudo sysctl -a | grep -e "^fs.inotify.max_user_watches" | cut -d "=" -f 2 | xargs)"
	if [[ "${current_watches_limit}" != "999999" ]]; then
		echo fs.inotify.max_user_watches=999999 | sudo tee /etc/sysctl.d/00-max-user-watches.conf &>/dev/null
		sudo sysctl -p /etc/sysctl.d/00-max-user-watches.conf
	fi

	# increase open files soft limit
	echo "=> Increasing open files limit"
	if ! grep -q -e "softnofile" /etc/security/limits.d/00-open-files.conf; then
		echo "*    soft    nofile    4096" | sudo tee /etc/security/limits.d/50-open-files.conf &>/dev/null
	fi

	echo "=> running base server config"
	/bin/bash -c "$(
		curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/server-configs/setup.sh
	)"

	# clone essential repos
	echo "=> Cloning dotfiles repository"
	if [[ -d ~/workspace/dotfiles ]]; then
		echo "=> Dotfiles repository already exists. updating..."

		(cd ~/workspace/dotfiles && git fetch --all --prune && git pull --rebase || true)
	else
		git clone https://github.com/abuelwafa/dotfiles.git ~/workspace/dotfiles
	fi
	if [[ -d ~/workspace/tpm ]]; then
		(cd ~/workspace/tpm && git pull --rebase)
	else
		git clone https://github.com/tmux-plugins/tpm ~/workspace/tpm
	fi

	# generate ssh key
	echo "=> generating an SSH key"
	if [[ ! -f ~/.ssh/id_ed25519 ]]; then
		echo "   SSH key already exists. skiping..."
		ssh-keygen -t ed25519 -C "mohamed.abuelwafa"
	fi

	# install homebrew
	setup_homebrew

	# install essential homebrew packages
	# DB CLIs
	brew tap dbcli/tap
	brew tap hashicorp/tap

	local brew_packages_list
	brew_packages_list=(
		bash
		bash-completion@2
		vim
		neovim
		lua
		luarocks
		git
		tmux
		gcc
		cmake
		tree
		htop
		git-delta
		node@24
		gnupg
		sops
		doggo
		bat
		ripgrep
		fzf
		jq
		lazygit
		libpq
		kubernetes-cli
		helm
		fluxcd/tap/flux
		kind
		derailed/k9s/k9s
		kubectx
		kustomize
		trivy
		go
		ansible
		python@3
		sst/tap/opencode
		opentofu
		hashicorp/tap/terraform
		pgcli
		litecli
		mycli
		iredis
		lnav
		goaccess
		hcloud
		gh
		dust
		fx
		superfile
		cmatrix
		pre-commit
		yarn
		# watchman
		# fd
		# rbenv
		# ruby-build
	)

	local batchsize=8
	local len_packages=${#brew_packages_list[@]}
	for ((i = 0; i < len_packages; i += 8)); do
		brew install "${brew_packages_list[@]:i:batchsize}"
	done

	# linking config files
	ln --force -s ~/workspace/dotfiles/bash/bashrc-full ~/.bash_aliases
	ln --force -s ~/workspace/dotfiles/tmux/tmux.conf ~/.tmux.conf
	ln --force -s ~/workspace/dotfiles/vim/.vimrc ~/.vimrc
	ln --force -s ~/workspace/dotfiles/.gitconfig ~/.gitconfig

	if ! grep -q -e "export GIT_COMMITTER_EMAIL" ~/.machine-config; then
		echo 'export GIT_COMMITTER_EMAIL="mohamed.abuelwafa@gmail.com"' | tee -a ~/.machine-config &>/dev/null
		echo 'export GIT_AUTHOR_EMAIL="mohamed.abuelwafa@gmail.com"' | tee -a ~/.machine-config &>/dev/null
	fi

	if ! grep -q -e "export OPENAI_API_KEY" ~/.machine-config; then
		echo 'export OPENAI_API_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"' | tee -a ~/.machine-config &>/dev/null
	fi

	mkdir -p ~/.config/pgcli
	ln --force -s ~/workspace/dotfiles/pgcli.config ~/.config/pgcli/config
	ln --force -s ~/workspace/dotfiles/yamlfmt.yml ~/yamlfmt.yml
	ln --force -s ~/workspace/dotfiles/.shellcheckrc ~/.shellcheckrc
	ln --force -s ~/workspace/dotfiles/.editorconfig ~/.editorconfig
	mkdir -p ~/.config/lazydocker
	ln --force -s ~/workspace/dotfiles/lazydocker-config.yml ~/.config/lazydocker/config.yml

	# install sdkman
	setup_sdkman

	# install/update rust tools
	echo "=> Setting up Rust tools"
	if command -v rustup; then
		echo "   Rust tools already exist. Updating..."
		rustup update
	else
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
		source "${HOME}/.cargo/env"
	fi

	# install tclock
	echo "=> Installing tclock"
	cargo install clock-tui

	# install lazytrivy
	echo "=> Installing lazytrivy"
	# go install github.com/owenrumney/lazytrivy@latest

	# configure opencode
	echo "=> Configuring Opencode."
	echo "   ESC to cancel. to do it later, run opencode auth login"
	opencode auth login || true

	# setup neovim
	echo "=> Configuring Neovim"
	setup_neovim

	check_system_reboot

	echo -e "\n\e[90;102;2m INFO \e[m Review the values in ~/.machine-config."
	echo -e "\n\e[90;102;2m INFO \e[m Logout and login again for all configuration changes to take effect."
}

main "$@"
