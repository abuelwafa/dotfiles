#!/usr/bin/env bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# installs nginx webserver.
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/scripts/setup-nginx.sh)"

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
	echo "=> Installing Nginx"
	echo "======================================="
	echo "=> installing apt packages"
	sudo apt-get install -y nginx nginx-extras
	command -v ufw > /dev/null 2>&1 && sudo ufw allow http && sudo ufw reload

	# generate a strong diffie-hellman group
	mkdir -p /etc/nginx/dhparam
	if [[ ! -f "/etc/nginx/dhparam/dhparam.pem" ]]; then
		openssl dhparam -out /etc/nginx/dhparam/dhparam.pem 4096
	fi

	cat <<- 'EOF' | tee /etc/nginx/sites-available/main_site.nginx &> /dev/null
		upstream my_site {
			server 127.0.0.1:3000;
			keepalive 32;
		}

		server {
			listen 443 ssl;
			listen [::]:443 ssl;
			http2 on;

			server_name example.com;

			ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
			ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

			ssl_dhparam /etc/nginx/dhparam/dhparam.pem;

			ssl_protocols TLSv1.2 TLSv1.3;
			ssl_prefer_server_ciphers off;
			ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

			ssl_session_cache shared:SSL:10m;
			ssl_session_timeout 1d;
			ssl_session_tickets off;

			add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;

			server_tokens off;
			more_clear_headers Server;

			access_log /var/log/nginx/example.com.access.log;
			error_log /var/log/nginx/example.com.error.log;

			client_max_body_size 2m;

			location / {
				proxy_redirect off;
				proxy_pass http://my_site;
				proxy_http_version 1.1;

				proxy_set_header Host $host;
				proxy_set_header X-Real-IP $remote_addr;
				proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
				proxy_set_header X-Forwarded-Proto $scheme;
				proxy_set_header Connection "";

				proxy_connect_timeout 60s;
				proxy_send_timeout 60s;
				proxy_read_timeout 60s;
			}
		}

		# redirect HTTP -> HTTPS
		server {
			listen 80;
			listen [::]:80;
			server_name example.com;
			return 301 https://$server_name$request_uri;
		}

		# catch all other hosts on 443
		server {
			listen 443 ssl default_server;
			listen [::]:443 ssl default_server;
			ssl_reject_handshake on;
		}
	EOF

	rm /etc/nginx/sites-enabled/default || true
	ln --force -s /etc/nginx/sites-available/main_site.nginx /etc/nginx/sites-enabled/
	echo "=> make sure to rename and revise the nginx config at /etc/nginx/sites-available/main_site.nginx"

	systemctl enable nginx
	systemctl restart nginx

	echo
	echo -e "=> \e[90;102;2m INFO \e[m Finished running script."
	echo "=> Done in $(($(date +%s) - start_time)) seconds"
}

main "$@"
