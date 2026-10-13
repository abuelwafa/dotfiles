function setup_hetzner_cli() {
	read -p "Setup and configure Hetzner cloud CLI (release binary)? (y/n): " -r install_hcloud_cli
	echo
	if [[ ${install_hcloud_cli} =~ ^[Yy]$ ]]; then
		echo "=> installing Hetzner cloud CLL"
		curl -sSL https://github.com/hetznercloud/cli/releases/latest/download/hcloud-linux-amd64.tar.gz --output-dir /tmp
		sudo tar -C /usr/local/bin --no-same-owner -xzf /tmp/hcloud-linux-amd64.tar.gz hcloud
		rm /tmp/hcloud-linux-amd64.tar.gz
	else
		echo "Skipping install of Hetzner cloud CLI"
	fi
	echo
}
