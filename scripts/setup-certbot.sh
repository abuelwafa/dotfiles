#!/usr/bin/env bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# small description on what this script does.
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/setup-certbot.sh)"

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
	echo "=> Setting up Certbot and LetsEncrypt"
	echo "======================================="

	sudo apt-get install -y libaugeas-dev gcc
	sudo apt-get remove -y certbot

	sudo rm -rf /opt/certbot || true
	sudo rm /usr/bin/certbot || true

	sudo python3 -m venv /opt/certbot/
	sudo /opt/certbot/bin/pip install certbot
	sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot

	echo

	read -p "Install a DNS plugin for renewing certificates using a DNS challenge? (y/n):" -r setup_dns_plugin

	if [[ "${setup_dns_plugin}" =~ ^[Yy]$ ]]; then
		echo "=> Installing DNS plugin"
		PS3="Select the DNS plugin you want to install: "
		local plugins=("cloudflare" "dnsimple" "linode" "digitalocean" "route53")
		select plugin in "${plugins[@]}"; do
			sudo /opt/certbot/bin/pip install certbot-dns-"${plugin}"

			echo
			echo "=> If you plan to obtain certifcates now, Please setup the needed"
			echo "   credentials for your DNS plugin as per its respective documentation."
			echo "   Otherwise, you can use the Manual plugin to obtain certificates by"
			echo "   manually changing DNS records through instructions."
			echo
			read -p "Press Enter to continue..." -r

		done
	else
		echo "=> You can still obtain certificates using the manual mode."
		echo "   Note that automatic renewal doesn't work with manual mode."
	fi

	echo "=> Obtaining Certificates"
	echo "==> Make sure to run the following once to obtain a valid certificate."
	echo "    Adjust the command according to your setup and plugin choice."
	cat <<- 'EOF'
		sudo certbot certonly \
			--manual \                                                                # use only if you did not setup a DNS plugin
			--dns-{plugin_name} \                                                     # replace {plugin_name}
			--dns-cloudflare-credentials /etc/letsencrypt/certbot/cloudflare.ini \    # You will be interactively asked if ommited
			--preferred-challenges dns \
			--non-interactive \                                                       # omit when running interactively
			--agree-tos \
			-d example.com                                                            # replace with your actual domain. can be specified multiple times
	EOF

	echo

	echo "==> Setting up automatic certificate renewal"
	echo "0 0,12 * * * root /opt/certbot/bin/python -c 'import random; import time; time.sleep(random.random() * 3600)' && sudo certbot renew -q" \
		| sudo tee -a /etc/crontab > /dev/null

	echo -e "=> \e[90;102;2m INFO \e[m Finished running script."
	echo "=> Done in $(($(date +%s) - start_time)) seconds"
}

main "$@"
