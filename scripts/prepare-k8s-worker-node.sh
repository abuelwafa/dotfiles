#!/bin/bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# bash script for setting up k8s worker node on Debian servers
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/prepare-k8s-worker-node.sh)"

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

function setup_containerd() {
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

    curl -fSLO "$download_url"
    sudo tar --extract -C /usr/local -zvv -f "$file_name"
    sudo systemctl enable --now containerd

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
        python3 \
        python3-venv

    echo

    check_system_reboot

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

    echo

    # setup_hostname
    # setup_wireguard
    # setup_ufw
    # harden_ssh
    # setup_fail2ban
    setup_containerd
    # setup_aws_cli
    # setup_prometheus_node_exporter

    enable_packet_forwarding
}

function install_kubelet() {
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg

    # download the public signing key for the Kubernetes package repositories
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    # add the appropriate Kubernetes apt repository
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl

    sudo systemctl enable --now kubelet
}

function enable_packet_forwarding() {
    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
    net.ipv4.ip_forward = 1
    EOF

    # Apply sysctl params without reboot
    sudo sysctl --system
}

main "$@"
