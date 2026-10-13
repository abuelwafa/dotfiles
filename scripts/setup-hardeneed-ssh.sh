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

function harden_ssh() {
	read -p "Harden SSH? (y/n): " -r harden_ssh
	echo
	if [[ ${harden_ssh} =~ ^[Yy]$ ]]; then
		echo "=> hardening SSH"

		local ssh_allowed_users
		read -p "Enter usernames allowed to SSH (space separated list): " -r ssh_allowed_users

		local ssh_listen_address_rule
		ssh_listen_address_rule=""
		local ssh_listen_address
		PS3="Select listen address (choose Ignore to keep the default behaviour which is listening on any address): "
		local hostnames
		hostnames=$(hostname -I)
		local options=(${hostnames[@]} "Ignore")

		select opt in "${options[@]}"; do
			if [[ "$(_in_array "${opt}" "${hostnames[@]}")" == "1" ]]; then
				ssh_listen_address_rule="ListenAddress ${opt}"
				ssh_listen_address=${opt}
				break
			elif [[ "${opt}" == "Ignore" ]]; then
				break
			else
				echo "Invalid option! Please select properly."
			fi
		done

		local ssh_listen_port
		read -p "SSH listen port: " -r ssh_listen_port

		cat <<- EOF | sudo tee /etc/ssh/sshd_config.d/99-override.conf &> /dev/null
			# disable root login
			PermitRootLogin no

			# disable password authentication
			PasswordAuthentication no

			# restrict users allowed to use SSH
			AllowUsers ${ssh_allowed_users}

			# change the SSH port
			Port ${ssh_listen_port}

			# change listen address of the server
			${ssh_listen_address_rule}
		EOF

		# enable the ssh port for ssh in firewall
		if [[ -z "${ssh_listen_address}" ]]; then
			command -v ufw > /dev/null 2>&1 && sudo ufw allow "${ssh_listen_port}"/tcp
		else
			command -v ufw > /dev/null 2>&1 && sudo ufw limit in proto tcp to "${ssh_listen_address}" port "${ssh_listen_port}" from 0.0.0.0/0 comment "allow ssh over vpn"
		fi

		# restart the ssh service
		echo -e "\n\e[90;103;2m WARNING \e[m Restarting SSH service. Check that your SSH connection still works in another terminal.\n"
		sudo systemctl restart ssh
	else
		echo "Skipping SSH hardening"
	fi
	echo
}
