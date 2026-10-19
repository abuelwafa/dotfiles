#!/usr/bin/env bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# Installs Nerdctl the full version (nerdctl + containerd + CNI)
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/setup-nerdctl-full.sh)"

set -euo pipefail
shopt -s globstar nullglob
# Debug script by setting TRACE=1
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

function main() {
	local start_time
	start_time=$(date +%s)

	echo "================================================================="
	echo "=> Installing nerdctl full version. (nerdctl + containerd + CNI)"
	echo "================================================================="

	local hardware_name
	hardware_name="$(uname --machine)"

	local cpu_arch
	if [[ "${hardware_name}" == "aarch64" ]] || [[ "${hardware_name}" == "arm64" ]]; then
		cpu_arch="arm64"
	elif [[ "${hardware_name}" == "amd64" ]] || [[ "${hardware_name}" == "x86_64" ]]; then
		cpu_arch="amd64"
	else
		echo "=> ERROR: Unknown CPU architecture: ${hardware_name}" >&2
		exit 1
	fi

	local tag_name # v2.0.3
	tag_name="$(curl -fsSL https://api.github.com/repos/containerd/nerdctl/releases/latest | jq -r '.tag_name')"
	echo "=> found nerdctl version ${tag_name}"

	local file_name
	file_name="nerdctl-full-${tag_name#v}-linux-${cpu_arch}.tar.gz"

	local download_url
	download_url="https://github.com/containerd/nerdctl/releases/download/${tag_name}/${file_name}"

	curl -fSLO "${download_url}" --output-dir /tmp
	sudo tar --extract -C /usr/local -zvv -f /tmp/"${file_name}"
	sudo systemctl enable --now containerd

	echo "=> cleaning up"
	rm /tmp/"${file_name}"
	echo "=> nerdctl has been successfully installed"
	echo
	echo
	echo -e "=> \e[90;102;2m INFO \e[m Finished running script."
	echo "=> Done in $(($(date +%s) - start_time)) seconds"
}

main "$@"
