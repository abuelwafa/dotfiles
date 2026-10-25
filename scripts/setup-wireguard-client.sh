#!/usr/bin/env bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# Interactive script that installs and configures wireguard peer (client).
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/setup-wireguard-client.sh)"

set -euo pipefail
shopt -s globstar nullglob
# Debug script by setting TRACE=1
if [[ "${TRACE-0}" == "1" ]]; then
	set -o xtrace
fi

function main() {
	local start_time
	start_time=$(date +%s)

	echo "======================================="
	echo "=> Setting up Wireguard VPN"
	echo "======================================="
	echo "=> installing Wireguard"
	sudo apt-get install -y wireguard wireguard-tools

	# generate wireguard private key only if it doesn't exist
	if [[ ! -f "/etc/wireguard/wg0.key" ]]; then
		wg genkey | sudo tee /etc/wireguard/wg0.key &> /dev/null
	fi

	sudo cat /etc/wireguard/wg0.key | wg pubkey | sudo tee /etc/wireguard/wg0.key.pub &> /dev/null

	echo
	echo "==> The public key for wireguard is:"
	sudo cat /etc/wireguard/wg0.key.pub
	echo
	read -p "Press Enter to continue..." -r

	echo
	read -p "VPN server host(hostname only): " -r vpn_server_host
	read -p "VPN server port: " -r vpn_server_port
	read -p "VPN server public key: " -r vpn_server_public_key
	read -p "Client assigned IP: " -r vpn_client_ip
	read -p "Client allowed IPs: " -r vpn_client_allowed_ips
	cat <<- EOF | sudo tee /etc/wireguard/wg0.conf &> /dev/null
		[Interface]
		Address = ${vpn_client_ip}/32
		PrivateKey = $(sudo cat /etc/wireguard/wg0.key)

		[Peer]
		Endpoint = ${vpn_server_host}:${vpn_server_port}
		AllowedIPs = ${vpn_client_allowed_ips}
		PersistentKeepalive = 25
		PublicKey = ${vpn_server_public_key}
	EOF
	sudo systemctl enable wg-quick@wg0
	sudo systemctl start wg-quick@wg0
	wg-quick down wg0
	wg-quick up wg0

	# override the ssh service to start after the wireguard one
	# to fix ssh service error after restarts
	sudo mkdir -p /etc/systemd/system/ssh.service.d
	sudo touch /etc/systemd/system/ssh.service.d/override.conf
	cat <<- 'EOF' | sudo tee /etc/systemd/system/ssh.service.d/override.conf &> /dev/null
		[Unit]
		After=network.target auditd.service wg-quick@wg0.service
		Requires=wg-quick@wg0.service
	EOF
	sudo systemctl daemon-reload
	sudo systemctl restart ssh

	echo

	echo
	echo -e "=> \e[90;102;2m INFO \e[m Finished running script."
	echo "=> Done in $(($(date +%s) - start_time)) seconds"
}

main "$@"
