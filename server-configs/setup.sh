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
    read -p "Harden SSH? (y/n) " -r harden_ssh
    echo
    if [[ $harden_ssh =~ ^[Yy]$ ]]; then
        # TODO: change to sed instead of appending to the config file
        # backing up current sshd_config file
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config-bak-"$(date +%s)"
        
        echo "=> hardening SSH"
        # disable root login
        sudo echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
        
        # disable password authentication
        sudo echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
    
        # restrict users allowed to use SSH
        read -p "Enter usernames allowed to SSH (space separated list): " -r ssh_allowed_users
        sudo echo 'AllowUsers $ssh_allowed_users' >> /etc/ssh/sshd_config
        
        # change the SSH port
        read -p "SSH listen port: " -r ssh_listen_port
        sudo echo 'Port $ssh_listen_port' >> /etc/ssh/sshd_config
        command -v ufw >/dev/null 2>&1 && sudo ufw allow $ssh_listen_port/tcp
    
        # change listen address of the server
        read -p "SSH listen address: " -r ssh_listen_address
        sudo echo 'ListenAddress $ssh_listen_address' >> /etc/ssh/sshd_config
        
        # restart the ssh service
        echo -e "\n\e[90;103;2m WARNING \e[m Restarting SSH service. Check that your SSH connection still works in another terminal.\n"
        sudo systemctl restart ssh
    else
        echo "Skipping SSH hardening"
    fi
    echo
}

function setup_nginx() {
    read -p "Setup and configure Nginx? (y/n) " -r install_nginx
    echo
    if [[ $install_nginx =~ ^[Yy]$ ]]; then
        echo "=> installing Nginx"
        sudo apt-get install -y nginx nginx-extras
        command -v ufw >/dev/null 2>&1 && sudo ufw allow www
    else
        echo "Skipping install of Nginx"
    fi
    echo
}

function setup_docker() {
    read -p "Setup and configure Docker? (y/n) " -r install_docker
    echo
    if [[ $install_docker =~ ^[Yy]$ ]]; then
        echo "=> installing Docker"
    else
        echo "Skipping install of Docker"
    fi
    echo
}

function setup_wireguard() {
    read -p "Setup and configure Wireguard? (y/n) " -r install_wireguard
    echo
    if [[ $install_wireguard =~ ^[Yy]$ ]]; then
        echo "=> installing Wireguard"
        sudo apt-get install -y wireguard wireguard-tools
        wg genkey > /etc/wireguard/wg0.key
        wg pubkey < /etc/wireguard/wg0.key > /etc/wireguard/wg0.key.pub

        read -p "VPN server host: " -r vpn_server_host
        read -p "VPN server port: " -r vpn_server_port
        read -p "VPN server public key: " -r vpn_server_public_key
        read -p "Client assigned IP: " -r vpn_client_ip
        read -p "Client allowed IPs: " -r vpn_client_allowed_ips
        cat >/etc/wireguard/wg0.conf <<EOL
[Interface]
Address = $vpn_client_ip/32
PrivateKey = $(cat /etc/wireguard/wg0.key)

[Peer]
Endpoint = $vpn_server_host:$vpn_server_port
AllowedIPs = $vpn_client_allowed_ips
PersistentKeepalive = 25
PublicKey = $vpn_server_public_key
EOL
        sudo systemctl enable wg-quick@wg0
        sudo systemctl start wg-quick@wg0
        wg-quick down wg0
        wg-quick up wg0
    else
        echo "Skipping Wireguard setup"
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
        sudo ufw default deny outgoing
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
    echo -e "Install build essential?\n[no] for a production webserver. [yes] for a development machine. (y/n)\nInstall build-essential?: "
    read -r install_build_essential
    echo
    if [[ $install_build_essential =~ ^[Yy]$ ]]; then
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
    if [ -f /var/run/reboot-required ]; then
        echo -e "\n\e[90;103;2m WARNING \e[m System restart required. Consider rebooting by running:\n\e[90;43;2m \e[m         sudo shutdown -r now\n"
    fi
    echo
}

main() {
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y vim curl jq htop locales locales-all bash-completion python3 python3-venv

    echo
    
    check_system_reboot

    # backup .bashrc file if it already exists
    if [[ -f "$HOME/.bash_aliases" ]]; then
        cp ~/.bash_aliases ~/.bash_aliases-bak-"$(date +%s)"
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
    setup_wireguard
    setup_ufw
    harden_ssh
    setup_nginx
    setup_fail2ban
    setup_containerd
    setup_docker
    setup_prometheus_node_exporter
}

main "$@"
