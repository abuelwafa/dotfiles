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

function setup_aws_cli() {
    read -p "Setup and configure AWS CLI? (y/n): " -r install_aws_cli
    echo
    if [[ $install_aws_cli =~ ^[Yy]$ ]]; then
        echo "=> installing AWS CLL"
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" --output-dir /tmp -o "awscliv2.zip"
        unzip -u awscliv2.zip
        if command -v aws &>/dev/null; then
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
    read -p "Setup and configure Hetzner cloud CLI? (y/n): " -r install_hcloud_cli
    echo
    if [[ $install_hcloud_cli =~ ^[Yy]$ ]]; then
        echo "=> installing Hetzner cloud CLL"
    else
        echo "Skipping install of Hetzner cloud CLI"
    fi
    echo
}

function setup_gcloud_cli() {
    read -p "Setup and configure Google Cloud CLI? (y/n): " -r install_gcloud_cli
    echo
    if [[ $install_gcloud_cli =~ ^[Yy]$ ]]; then
        echo "=> installing Google Cloud CLL"
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

        sudo apt-get update && sudo apt-get install -y google-cloud-cli

        echo "=> Google cloud cli has been installed successfully."
        echo "=> run \`gcloud init\` to configure it"
    else
        echo "Skipping install of Google Cloud CLI"
    fi
    echo
}

function harden_ssh() {
    read -p "Harden SSH? (y/n): " -r harden_ssh
    echo
    if [[ $harden_ssh =~ ^[Yy]$ ]]; then
        echo "=> hardening SSH"

        local ssh_allowed_users
        read -p "Enter usernames allowed to SSH (space separated list): " -r ssh_allowed_users

        local ssh_listen_address
        read -p "SSH listen address: " -r ssh_listen_address

        local ssh_listen_port
        read -p "SSH listen port: " -r ssh_listen_port

        cat <<EOF | sudo tee /etc/ssh/sshd_config.d/99-override.conf &>/dev/null
# disable root login
PermitRootLogin no

# disable password authentication
PasswordAuthentication no

# restrict users allowed to use SSH
AllowUsers $ssh_allowed_users

# change the SSH port
Port $ssh_listen_port

# change listen address of the server
ListenAddress $ssh_listen_address
EOF

        # enable the ssh port for ssh in firewall
        command -v ufw >/dev/null 2>&1 && sudo ufw allow "$ssh_listen_port"/tcp

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
    read -p "Setup and configure Docker? (y/n): " -r install_docker
    echo
    if [[ $install_docker =~ ^[Yy]$ ]]; then
        echo "=> installing Docker"
    else
        echo "Skipping install of Docker"
    fi
    echo
}

function setup_wireguard() {
    read -p "Setup and configure Wireguard? (y/n): " -r install_wireguard
    echo
    if [[ $install_wireguard =~ ^[Yy]$ ]]; then
        echo "=> installing Wireguard"
        sudo apt-get install -y wireguard wireguard-tools

        # generate wireguard private key only if it doesn't exist
        if [[ ! -f "/etc/wireguard/wg0.key" ]]; then
            wg genkey | sudo tee /etc/wireguard/wg0.key &>/dev/null
        fi

        sudo cat /etc/wireguard/wg0.key | wg pubkey | sudo tee /etc/wireguard/wg0.key.pub &>/dev/null

        read -p "VPN server host: " -r vpn_server_host
        read -p "VPN server port: " -r vpn_server_port
        read -p "VPN server public key: " -r vpn_server_public_key
        read -p "Client assigned IP: " -r vpn_client_ip
        read -p "Client allowed IPs: " -r vpn_client_allowed_ips
        cat <<EOF | sudo tee /etc/wireguard/wg0.conf &>/dev/null
[Interface]
Address = $vpn_client_ip/32
PrivateKey = $(cat /etc/wireguard/wg0.key)

[Peer]
Endpoint = $vpn_server_host:$vpn_server_port
AllowedIPs = $vpn_client_allowed_ips
PersistentKeepalive = 25
PublicKey = $vpn_server_public_key
EOF
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
    read -p "Setup and configure Prometheus Node Exporter? (y/n): " -r install_node_exporter
    echo
    if [[ $install_node_exporter =~ ^[Yy]$ ]]; then
        echo "=> setting up user account/group for monitoring"
        # create group and user account if they doesn't exist
        getent group monitoring &>/dev/null || sudo groupadd monitoring
        id -u node_exporter &>/dev/null || sudo useradd \
            --no-create-home \
            --no-user-group \
            --shell /usr/sbin/nologin \
            --groups monitoring \
            node_exporter

        echo "=> installing Prometheus Node Exporter"
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
        echo "=> found Prometheus Node Exporter version ${tag_name}"

        local node_exporter_version # 2.0.3
        node_exporter_version="$(echo "$tag_name" | cut -d 'v' -f 2)"

        local file_name
        file_name="node_exporter-${node_exporter_version}.linux-${cpu_arch}"

        local download_url
        download_url="https://github.com/prometheus/node_exporter/releases/download/${tag_name}/${file_name}.tar.gz"

        curl -fSLO "$download_url" --output-dir /tmp
        tar --extract -C /tmp -zvv -f "/tmp/${file_name}.tar.gz"
        sudo mv "/tmp/${file_name}/node_exporter" /usr/local/bin/node_exporter
        sudo chmod ug+x /usr/local/bin/node_exporter
        sudo chown node_exporter:monitoring /usr/local/bin/node_exporter

        # cleaning up
        rm -rf "/tmp/${file_name}"
        rm -rf "/tmp/${file_name}.tar.gz"

        echo "=> Setting up systemd service"
        sudo mkdir -p /etc/prometheus/exporters/node-exporter

        sudo touch /etc/prometheus/exporters/node-exporter/web-config.yml
        sudo tee -a /etc/prometheus/exporters/node-exporter/web-config.yml &>/dev/null <<EOL
EOL

        local node_exporter_listen_address
        read -p "Node Exporter listen address (127.0.0.1:9100): " -r node_exporter_listen_address
        if [[ -z "${node_exporter_listen_address}" ]]; then
            node_exporter_listen_address="127.0.0.1:9100"
        fi

        sudo touch /etc/systemd/system/prometheus-node-exporter.service
        sudo tee -a /etc/systemd/system/prometheus-node-exporter.service &>/dev/null <<EOL
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
ExecStart=/usr/local/bin/node_exporter \
    --web.listen-address=$node_exporter_listen_address \
    # --web.config.file=/etc/prometheus/web.config.yml \

[Install]
WantedBy=multi-user.target
EOL
        local edit_prom_node_exporter_service_file
        read -p "Would you like to edit the systemd service before running? (y/n): " -r edit_prom_node_exporter_service_file
        if [[ $edit_prom_node_exporter_service_file =~ ^[Yy]$ ]]; then
            sudoedit /etc/systemd/system/prometheus-node-exporter.service
        fi

        # adjust ownership and permissions
        sudo chmod 664 /etc/systemd/system/prometheus-node-exporter.service
        sudo chown --recursive node_exporter:monitoring /etc/prometheus

        sudo systemctl daemon-reload
        sudo systemctl enable prometheus-node-exporter
        sudo systemctl start prometheus-node-exporter
        echo -e "\n\e[90;102;2m INFO \e[m Prometheus Node exporter has been setup successfully."
    else
        echo "Skipping install of Prometheus Node Exporter"
    fi
    echo
}

function setup_grafana_alloy() {
    read -p "Setup and configure Grafana Alloy? (y/n): " -r install_alloy
    echo
    if [[ $install_alloy =~ ^[Yy]$ ]]; then
        echo "=> setting up Grafana alloy"
    else
        echo "Skipping install of Grafana Alloy"
    fi
    echo
}

function setup_git() {
    local install_git
    read -p "Setup and configure git? (y/n): " -r install_git
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
    read -p "Setup and configure tmux? (y/n): " -r install_tmux
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
        curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/tmux/tmux-minimal.conf >~/.tmux.conf
    else
        echo "Skipping setup of TMUX"
    fi
    echo
}

function setup_ufw() {
    read -p "Setup and configure ufw? (y/n): " -r install_ufw
    echo
    if [[ $install_ufw =~ ^[Yy]$ ]]; then
        echo "=> installing and configuring ufw"
        sudo apt-get install -y ufw
        sudo ufw default deny incoming
        # sudo ufw default deny outgoing
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
    read -p "Setup and configure fail2ban? (y/n): " -r install_fail2ban
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
    read -p "Setup and configure containerd? (y/n): " -r install_containerd
    echo
    if [[ $install_containerd =~ ^[Yy]$ ]]; then
        echo '=> Installing Containerd'

        local hardware_name
        hardware_name="$(uname --machine)"

        local cpu_arch
        if [[ "$hardware_name" == "arm64" ]]; then
            cpu_arch="arm64"
        else
            cpu_arch="amd64"
        fi

        local tag_name # v2.0.3
        tag_name="$(curl -fsSL https://api.github.com/repos/containerd/containerd/releases/latest | jq -r '.tag_name')"

        local containerd_version # 2.0.3
        containerd_version="$(echo "$tag_name" | cut -d 'v' -f 2)"

        local file_name
        file_name="containerd-${containerd_version}-linux-${cpu_arch}.tar.gz"

        local download_url
        download_url="https://github.com/containerd/containerd/releases/download/${tag_name}/${file_name}"

        curl -fSLO "$download_url" --output-dir /tmp
        sudo tar --extract -C /usr/local -zvv -f /tmp/"$file_name"

        # download containerd systemd service file
        curl -fsSL https://raw.githubusercontent.com/containerd/containerd/main/containerd.service \
            -O --output-dir /usr/local/lib/systemd/system
        sudo systemctl daemon-reload
        sudo systemctl enable --now containerd

        rm /tmp/"$file_name"
    else
        echo "Skipping install of containerd"
    fi
    echo
}

function setup_nerdctl_minimal() {
    read -p "Setup and configure nerdctl (minimal)? (y/n): " -r install_nerdctl_minimal
    echo
    if [[ $install_nerdctl_minimal =~ ^[Yy]$ ]]; then
        echo '=> Installing nerdctl (minimal version)'

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
        nerdctl_version="$(echo "$tag_name" | cut -d 'v' -f 2)"

        local file_name
        file_name="nerdctl-${nerdctl_version}-linux-${cpu_arch}.tar.gz"

        local download_url
        download_url="https://github.com/containerd/nerdctl/releases/download/${tag_name}/${file_name}"

        curl -fSLO "$download_url" --output-dir /tmp
        # sudo tar --extract -C /usr/local -zvv -f "$file_name"
        # sudo systemctl enable --now containerd

        rm /tmp/"$file_name"
    else
        echo "Skipping install of nerdctl"
    fi
    echo
}

function setup_nerdctl_full() {
    read -p "Setup and configure full nerdctl (nerdctl + containerd + CNI)? (y/n): " -r install_containerd
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
        nerdctl_version="$(echo "$tag_name" | cut -d 'v' -f 2)"

        local file_name
        file_name="nerdctl-full-${nerdctl_version}-linux-${cpu_arch}.tar.gz"

        local download_url
        download_url="https://github.com/containerd/nerdctl/releases/download/${tag_name}/${file_name}"

        curl -fSLO "$download_url" --output-dir /tmp
        sudo tar --extract -C /usr/local -zvv -f /tmp/"$file_name"
        sudo systemctl enable --now containerd

        rm /tmp/"$file_name"
    else
        echo "Skipping install of containerd/nerdctl"
    fi
    echo
}

function install_build_essential() {
    echo -ne "Install build essential?\n[no] for a production webserver. [yes] for a development machine. (y/n)\nInstall build-essential?: "
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

function setup_hostname() {
    read -p "Update machine hostname? (y/n): " -r update_hostname
    echo
    if [[ $update_hostname =~ ^[Yy]$ ]]; then
        echo "=> changing hostname "

        echo -e "\n\e[90;103;2m WARNING \e[m System restart is required after chaning hostname. Consider rebooting by running:\n\e[90;43;2m \e[m         sudo shutdown -r now\n"
    else
        echo "Skipping setting hostname"
    fi
    echo
}

main() {
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y \
        vim \
        curl \
        jq \
        htop \
        locales \
        locales-all \
        bash-completion \
        apt-transport-https \
        ca-certificates \
        gnupg \
        python3 \
        python3-venv

    echo

    sudo apt-get autoremove -y

    # backup .bash_aliases file if it already exists
    if [[ -f "$HOME/.bash_aliases" ]]; then
        cp ~/.bash_aliases ~/.bash_aliases-bak-"$(date +%s)"
        echo '=> old ~/.bash_aliases have been backed up'
    fi
    curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/bash/bashrc >~/.bash_aliases

    # backup .vimrc file if it already exists
    if [[ -f "$HOME/.vimrc" ]]; then
        cp ~/.vimrc ~/.vimrc-bak-"$(date +%s)"
        echo '=> old ~/.vimrc have been backed up'
    fi
    curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/vim/.vimrc >~/.vimrc
    sudo update-alternatives --set editor "$(which vim.basic)"

    echo

    install_build_essential
    setup_git
    setup_tmux
    setup_hostname
    setup_wireguard
    setup_ufw
    harden_ssh
    setup_nginx
    setup_fail2ban

    setup_containerd
    setup_docker
    setup_nerdctl_minimal
    setup_nerdctl_full

    setup_aws_cli
    setup_gcloud_cli
    setup_hetzner_cli
    setup_prometheus_node_exporter
    setup_grafana_alloy

    check_system_reboot
}

main "$@"
