#!/bin/bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# Interactive bash script for configuring servers
# curl -fL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/server-configs/setup.sh | bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

function setup_git() {
    local install_git
    read -p "Setup and configure git? (y/n) " -n 1 -r install_git
    echo
    if [[ $install_git =~ ^[Yy]$ ]]; then
        echo "=> installing git"
        sudo apt install git
        echo "=> configuring git"
        git config --global user.email "${git_email}"
        git config --global user.name "${git_name}"
    fi
}

function setup_tmux() {
    read -p "Setup and configure tmux? (y/n) " -n 1 -r install_tmux
    echo
    if [[ $install_tmux =~ ^[Yy]$ ]]; then
        echo "=> installing tmux"
        sudo apt install tmux
        echo "=> configuring tmux"
        curl -fL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/tmux/tmux-minimal.conf > ~/.tmux.conf
    fi
    echo
}

function setup_ufw() {
    read -p "Setup and configure ufw? (y/n) " -n 1 -r install_ufw
    echo
    if [[ $install_ufw =~ ^[Yy]$ ]]; then
        echo "=> installing and configuring ufw"
        sudo apt install ufw
        sudo ufw default deny incoming
        sudo ufw allow ssh
        sudo ufw enable
        echo
        sudo ufw status verbose
    fi
    echo
}

function setup_fail2ban() {
    read -p "Setup and configure fail2ban? (y/n) " -n 1 -r install_fail2ban
    echo
    if [[ $install_fail2ban =~ ^[Yy]$ ]]; then
        echo "=> installing fail2ban"
        sudo apt install fail2ban

        echo "=> configuring fail2ban"
        echo
        systemctl status fail2ban.service
    fi
    echo
}

function setup_containerd() {
    read -p "Setup and configure containerd and nerdctl? (y/n) " -n 1 -r install_containerd
    echo
    if [[ $install_containerd =~ ^[Yy]$ ]]; then
        local containerd_version
        containerd_version = "$(curl https://api.github.com/repos/containerd/containerd/releases/latest | jq -r '.tag_name')"

        local cpu_arch
        cpu_arch = "$(uname --machine)"

        echo "=> installing containerd"

        echo "installing nerdctl"
    fi
    echo
}

main() {
    sudo apt update
    sudo apt upgrade
    sudo apt install vim curl jq

    curl -fL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/bash/bashrc > ~/.bashrc
    curl -fL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/vim/.vimrc > ~/.vimrc

    setup_git
    setup_tmux
    setup_ufw
    setup_fail2ban
    setup_containerd
}

main "$@"
