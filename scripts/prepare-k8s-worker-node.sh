#!/usr/bin/env bash
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
shopt -s globstar nullglob
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

function create_kubeadm_config() {
    cat <<-EOF | sudo tee /etc/kubernetes/kubeadm-config.yaml &>/dev/null
		apiVersion: kubeadm.k8s.io/v1beta4
		kind: ClusterConfiguration
		esVersion: v1.33.1
		---
		apiVersion: kubelet.config.k8s.io/v1beta1
		kind: KubeletConfiguration
		cgroupDriver: systemd
    EOF
}

function setup_hostname() {
	echo
}

function harden_ssh() {
	echo
}

function setup_ufw() {
	sudo apt-get install -y ufw
	sudo ufw default deny incoming
	sudo ufw default deny outgouing
	sudo ufw allow ssh
	sudo ufw allow 6443
	sudo ufw enable
}

function setup_fail2ban() {
	echo
}

function enable_packet_forwarding() {
	local value="$(sysctl net.ipv4.ip_forward)"
	if [[ ! "$value" == "net.ipv4.ip_forward = 1" ]]; then
		cat <<-EOF | sudo tee /etc/sysctl.d/k8s.conf
			net.ipv4.ip_forward = 1
		EOF
		# Apply sysctl params without reboot
		sudo sysctl --system
	fi
}

function setup_containerd() {
    echo '=> Installing Containerd'

    local hardware_name
    hardware_name="$(uname --machine)"

    local cpu_arch
    if [[ "${hardware_name}" == "arm64" ]]; then
        cpu_arch="arm64"
    else
        cpu_arch="amd64"
    fi

    local tag_name # v2.0.3
    tag_name="$(curl -fsSL https://api.github.com/repos/containerd/containerd/releases/latest | jq -r '.tag_name')"
    echo "=> found containerd version ${tag_name}"

    local containerd_version # 2.0.3
    containerd_version="$(echo "${tag_name}" | cut -d 'v' -f 2)"

    local file_name
    file_name="containerd-${containerd_version}-linux-${cpu_arch}.tar.gz"

    local download_url
    download_url="https://github.com/containerd/containerd/releases/download/${tag_name}/${file_name}"

    curl -fSLO "${download_url}" --output-dir /tmp
    sudo tar --extract -C /usr/local -zvv -f /tmp/"${file_name}"

    echo "=> setting up containerd systemd service"
    # download containerd systemd service file
    sudo mkdir -p /usr/local/lib/systemd/system
    curl -fsSL https://raw.githubusercontent.com/containerd/containerd/main/containerd.service | sudo tee /usr/local/lib/systemd/system/containerd.service &>/dev/null
    sudo systemctl daemon-reload
    sudo systemctl enable --now containerd

    echo "=> cleaning up"
    rm /tmp/"${file_name}"

    echo "=> containerd has been successfully installed"
}

function disable_swap() {
    if [[ ! "$(cat /etc/fstab | grep -i swap | wc -l)" == "0" ]]; then
        sudo swapoff -a
    fi
}

function install_kubelet() {
    if ! command -v kubadm &>/dev/null; then
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
    fi
}

function setup_nerdctl_minimal() {
    read -p "Setup and configure nerdctl (minimal)? (y/n): " -r install_nerdctl_minimal
    echo
    if [[ ${install_nerdctl_minimal} =~ ^[Yy]$ ]]; then
        echo '=> Installing nerdctl (minimal version)'

        local hardware_name
        hardware_name="$(uname --machine)"

        local cpu_arch
        if [[ "${hardware_name}" == "arm64" ]]; then
            cpu_arch="arm64"
        else
            cpu_arch="amd64"
        fi

        local tag_name # v2.0.3
        tag_name="$(curl -fsSL https://api.github.com/repos/containerd/nerdctl/releases/latest | jq -r '.tag_name')"
        echo "=> found nerdctl version ${tag_name}"

        local nerdctl_version # 2.0.3
        nerdctl_version="$(echo "${tag_name}" | cut -d 'v' -f 2)"

        local file_name
        file_name="nerdctl-${nerdctl_version}-linux-${cpu_arch}.tar.gz"

        local download_url
        download_url="https://github.com/containerd/nerdctl/releases/download/${tag_name}/${file_name}"

        curl -fSLO "${download_url}" --output-dir /tmp
        # sudo tar --extract -C /usr/local -zvv -f "$file_name"
        # sudo systemctl enable --now containerd

        echo "=> cleaning up"
        rm /tmp/"${file_name}"
        echo "=> nerdctl has been successfully installed"
    else
        echo "Skipping install of nerdctl"
    fi
    echo
}

function validate_node_setup() {
    sudo nerdctl run -it --rm --privileged --net=host \
        -v /:/rootfs -v $CONFIG_DIR:$CONFIG_DIR -v $LOG_DIR:/var/result \
        registry.k8s.io/node-test:0.2
    # TODO: print the test result
    # TODO: clean the images
}

function check_system_reboot() {
    echo "=> Checking if system reboot is required..."
    if [ -f /var/run/reboot-required ]; then
        echo "=> WARNING: System restart required. Consider rebooting by running: sudo shutdown -r now"
    fi
    echo
}

function main() {
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

    setup_hostname # pending
    harden_ssh     # pending
    setup_ufw      # pending
    setup_fail2ban # pending
    enable_packet_forwarding
    setup_containerd
    setup_nerdctl_minimal
    disable_swap # pending
    install_kubelet

    echo "=> pulling required images"
    sudo kubeadm images pull

    validate_node_setup # pending
    check_system_reboot # pending

    echo
    echo "=> Node is ready to join a cluster."
    echo "Done."
}

main "$@"
