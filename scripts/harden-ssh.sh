#!/usr/bin/env bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# harden ssh on a linux server.
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/harden-ssh.sh)"

set -euo pipefail
shopt -s globstar nullglob
# Debug script by setting TRACE=1
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

function _in_array() {
	# example:
	# echo $(_in_array "target" "${arr[@]}")
	local target=$1
	# disabling variable quoting as we are passing an array here
	# shellcheck disable=SC2206
	local arr=($2)
	local found=0
	for item in "${arr[@]}"; do
		if [[ "${target}" == "${item}" ]]; then
			found=1
			break
		fi
	done
	echo "${found}"
}

function main() {
	local start_time
	start_time=$(date +%s)

	echo "======================================="
	echo "=> Hardening SSH"
	echo "======================================="
	# make sure we the script is not run as root
	if [[ "$(whoami)" == "root" ]]; then
		echo "ERROR: => This script must be run as non-root with sudo priviliges"
		exit 1
	fi

	local ssh_listen_port
	ssh_listen_port=$(python -c "import random; print random.randint(32000, 65535)")

	echo
	echo "==> The new listen port for SSH is: ${ssh_listen_port}"
	read -p "Press Enter to continue..." -r
	echo

	cat <<- EOF | sudo tee /etc/ssh/sshd_config.d/99-override.conf &> /dev/null
		# disable root login
		PermitRootLogin no

		# disable password authentication
		PasswordAuthentication no

		# restrict users allowed to use SSH. space separated list of users/groups
		AllowUsers $(whoami)
		# AllowGroups mygroup

		# change the SSH port
		Port ${ssh_listen_port}

		# change listen address of the server. (0.0.0.0 means listen on all IPv4 addressess)
		# if unspecified, SSH listens on all interfaces. can be specified multiple times
		ListenAddress 0.0.0.0
	EOF

	# enable the ssh port for ssh in firewall
	if [[ -z "${ssh_listen_address}" ]]; then
		command -v ufw > /dev/null 2>&1 && sudo ufw allow "${ssh_listen_port}"/tcp
	else
		command -v ufw > /dev/null 2>&1 && sudo ufw limit in proto tcp to "${ssh_listen_address}" port "${ssh_listen_port}" from 0.0.0.0/0 comment "allow ssh over vpn"
	fi

	# restart the ssh service
	echo -e "\n\e[90;103;2m WARNING \e[m Restarting SSH service. Check that your SSH connection still works in another terminal session.\n"
	sudo systemctl restart ssh
	echo

	echo "=> Revise/Adjust the values in the configuration file /etc/ssh/sshd_config.d/99-override.conf"
	echo

	echo
	echo -e "=> \e[90;102;2m INFO \e[m Finished running script."
	echo "=> Done in $(($(date +%s) - start_time)) seconds"
}

main "$@"
