#!/bin/bash
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

function harden_ssh() {
    echo "=> hardening SSH"
    # disable root login
    # disable password authentication
    # restrict users allowed to use SSH
    # change listen address of the server
    # change the SSH port

    # restart the ssh service
    sudo systemctl restart ssh
    echo
}

function setup_nginx() {
    read -p "Setup and configure Nginx? (y/n) " -r install_nginx
    echo
    if [[ $install_nginx =~ ^[Yy]$ ]]; then
        echo "=> installing Nginx"
        sudo apt-get install -y nginx nginx-extras
    else
        echo "Skipping install of Nginx"
    fi
    echo
}

function setup_docker() {
    read -p "Setup and configure Docker? (y/n) " -r install_docker
    echo
    if [[ $install_node_exporter =~ ^[Yy]$ ]]; then
        echo "=> installing Docker"
    else
        echo "Skipping install of Docker"
    fi
    echo
}

function setup_prometheus_node_exporter() {
    read -p "Setup and configure Prometheus Node Exporter? (y/n) " -r install_node_exporter
    echo
    if [[ $install_node_exporter =~ ^[Yy]$ ]]; then
        echo "=> installing Prometheus Node Exporter"

        # tar xvfz node_exporter-*.*-amd64.tar.gz
        # cd node_exporter-*.*-amd64
        # ./node_exporter

        local hardware_name
        hardware_name="$(uname --machine)"

        local cpu_arch
        if [[ "$hardware_name" == "arm64" ]]; then
            cpu_arch="arm64"
        else
            cpu_arch="amd64"
        fi

        local tag_name # v2.0.3
        tag_name="$(curl -fsSL https://api.github.com/repos/prometheus/node_exporter/releases/latest | jq -r '.tag_name')"

        local node_exporter_version # 2.0.3
        node_exporter_version="$(echo $tag_name | cut -d 'v' -f 2)"

        local file_name
        file_name="node_exporter-${node_exporter_version}.linux-${cpu_arch}.tar.gz"

        local download_url
        download_url="https://github.com/prometheus/node_exporter/releases/download/${tag_name}/${file_name}"

        curl -fSLO "$download_url" --output-dir /usr/local/bin
        sudo tar Cxzvvf -f "$file_name"

        echo "=> Setting up systemd service"
    else
        echo "Skipping install of Prometheus Node Exporter"
    fi
    echo
}

function setup_git() {
    local install_git
    read -p "Setup and configure git? (y/n) " -r install_git
    echo
    if [[ $install_git =~ ^[Yy]$ ]]; then
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
    read -p "Setup and configure tmux? (y/n) " -r install_tmux
    echo
    if [[ $install_tmux =~ ^[Yy]$ ]]; then
        echo "=> installing tmux"
        sudo apt-get install -y tmux
        echo "=> configuring tmux"
        # backup .tmux.conf file if it already exists
        if [[ -f "$HOME/.tmux.conf" ]]; then
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
    read -p "Setup and configure ufw? (y/n) " -r install_ufw
    echo
    if [[ $install_ufw =~ ^[Yy]$ ]]; then
        echo "=> installing and configuring ufw"
        sudo apt-get install -y ufw
        sudo ufw default deny incoming
        sudo ufw allow ssh
        sudo ufw enable
        echo
        sudo ufw status verbose
    else
        echo "Skipping UFW firewall setup"
    fi
    echo
}

function setup_fail2ban() {
    read -p "Setup and configure fail2ban? (y/n) " -r install_fail2ban
    echo
    if [[ $install_fail2ban =~ ^[Yy]$ ]]; then
        echo "=> installing fail2ban"
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
    read -p "Setup and configure containerd and nerdctl? (y/n) " -r install_containerd
    echo
    if [[ $install_containerd =~ ^[Yy]$ ]]; then
        echo '=> Installing nerdctl (full version)'

        local hardware_name
        hardware_name="$(uname --machine)"

        local cpu_arch
        if [[ "$hardware_name" == "arm64" ]]; then
            cpu_arch="arm64"
        else
            cpu_arch="amd64"
        fi

        local tag_name # v2.0.3
        tag_name="$(curl -fsSL https://api.github.com/repos/containerd/nerdctl/releases/latest | jq -r '.tag_name')"

        local nerdctl_version # 2.0.3
        nerdctl_version="$(echo $tag_name | cut -d 'v' -f 2)"

        local file_name
        file_name="nerdctl-full-${nerdctl_version}-linux-${cpu_arch}.tar.gz"

        local download_url
        download_url="https://github.com/containerd/nerdctl/releases/download/${tag_name}/${file_name}"

        curl -fSLO "$download_url"
        sudo tar Cxzvvf /usr/local "$file_name"
        sudo systemctl enable --now containerd
    else
        echo "Skipping install of containerd/nerdctl"
    fi
    echo
}

function install_build_essential() {
    read -p "Install build essential?\n[no] for a production webserver. [yes] for a development machine. (y/n) " -r install_build_essential
    echo
    if [[ $install_build_essential =~ ^[Yy]$ ]]; then
        sudo apt-get install -y build-essential
    fi
    echo
}

main() {
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y vim curl jq locales locales-all bash-completion python3 python3-venv

    # backup .bashrc file if it already exists
    if [[ -f "$HOME/.bash_aliases" ]]; then
        cp ~/.bashrc ~/.bash_aliases-bak-"$(date +%s)"
        echo '=> old ~/.bash_aliases have been backed up'
    fi
    curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/bash/bashrc > ~/.bash_aliases

    # backup .vimrc file if it already exists
    if [[ -f "$HOME/.vimrc" ]]; then
        cp ~/.vimrc ~/.vimrc-bak-"$(date +%s)"
        echo '=> old ~/.vimrc have been backed up'
    fi
    curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/vim/.vimrc > ~/.vimrc

    echo

    install_build_essential
    setup_git
    setup_tmux
    setup_ufw
    setup_fail2ban
    setup_containerd
    setup_docker
    setup_nginx
    setup_prometheus_node_exporter
}

main "$@"
