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

setup_rootles_containerd() {
    local container_user="wafa"

    sudo useradd --create-home --shell $(which bash) --user-group --groups sudo $container_user

    cat <<EOF | sudo tee -a /etc/subuid
    $container_user:100000:65536
    EOF
    cat <<EOF | sudo tee -a /etc/subgid
    $container_user:100000:65536
    EOF

    sudo apt-get install -y uidmap dbus-user-session

    sudo loginctl enable-linger $container_user

    cat <<EOF | sudo tee /etc/sysctl.d/98-rootless.conf
    # Allowing listening on TCP & UDP ports below 1024
    net.ipv4.ip_unprivileged_port_start=0
    # allow ping
    net.ipv4.ping_group_range = 0 2147483647
    EOF

    # generate containerd default config file
    sudo mkdir -p /etc/containerd
    containerd config default | sudo tee /etc/containerd/config.toml &>/dev/null
}


create_kubeadm_config() {
    cat <<EOF | sudo tee /etc/kubernetes/kubeadm-config.yaml
    apiVersion: kubeadm.k8s.io/v1beta4
    kind: ClusterConfiguration
    kubernetesVersion: v1.33.1
    ---
    apiVersion: kubelet.config.k8s.io/v1beta1
    kind: KubeletConfiguration
    cgroupDriver: systemd
    EOF
}

setup_hostname() {
    echo
}

harden_ssh() {
    echo
}

setup_ufw() {
    sudo apt-get install -y ufw
    sudo ufw default deny incoming
    sudo ufw default deny outgouing
    sudo ufw allow ssh
    sudo ufw allow 6443
    sudo ufw enable
}

setup_fail2ban() {
    echo
}

enable_packet_forwarding() {
    local value="$(sysctl net.ipv4.ip_forward)"
    if [[ ! "$value" == "net.ipv4.ip_forward = 1" ]]
        cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
        net.ipv4.ip_forward = 1
        EOF

        # Apply sysctl params without reboot
        sudo sysctl --system
    fi
}

setup_containerd() {
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

    # nerdctl bash completion
    sudo mkdir /etc/bash_completion.d
    /usr/local/bin/nerdctl completion bash | sudo tee /etc/bash_completion.d/nerdctl &>/dev/null

    echo
}

disable_swap() {
    if [[ ! "$(cat /etc/fstab | grep -i swap | wc -l)" == "0" ]]; then
        sudo swapoff -a
    fi
}

install_kubelet() {
    # download the public signing key for the Kubernetes package repositories
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    # add the Kubernetes apt repository
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm
    sudo apt-mark hold kubelet kubeadm

    # enable the kubelet
    # the kubelet will restart every few seconds. waiting for instructions from kubeadm
    sudo systemctl enable --now kubelet
}

validate_node_setup() {
    sudo nerdctl run -it --rm --privileged --net=host \
        -v /:/rootfs -v $CONFIG_DIR:$CONFIG_DIR -v $LOG_DIR:/var/result \
        registry.k8s.io/node-test:0.2
    # TODO: print the test result
    # TODO: clean the images
}

check_system_reboot() {
    echo "=> Checking if system reboot is required..."
    if [ -f /var/run/reboot-required ]; then
        echo "=> WARNING: System restart required. Consider rebooting by running: sudo shutdown -r now"
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
        ufw \
        htop \
        locales \
        locales-all \
        bash-completion \
        python3 \
        python3-venv \
        apt-transport-https \
        ca-certificates \
        gpg

    echo

    curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/bash/bashrc >~/.bash_aliases
    curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/vim/.vimrc >~/.vimrc
    sudo update-alternatives --set editor $(which vim.basic)

    echo

    # setup_rootles_containerd
    # create_kubeadm_config

    setup_hostname                  # pending
    harden_ssh                      # pending
    setup_ufw                       # pending
    setup_fail2ban                  # pending
    enable_packet_forwarding
    setup_containerd                # pending
    disable_swap                    # pending
    install_kubelet
    echo "=> pulling required images"
    sudo kubeadm images pull
    validate_node_setup             # pending
    check_system_reboot             # pending

    echo
    echo "=> Node is ready to join a cluster."
    echo "Done."
}

main "$@"
