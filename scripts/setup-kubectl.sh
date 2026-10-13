function setup_kubectl() {
	read -p "Setup and configure Kubernetes CLI (kubectl)? (y/n): " -r install_kubectl
	echo
	if [[ ${install_kubectl} =~ ^[Yy]$ ]]; then
		echo "=> installing Kubernetes CLL"

		sudo mkdir -p /etc/apt/keyrings
		curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key \
			| sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
		sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

		if [[ -f "/etc/apt/sources.list.d/kubernetes.list" ]]; then
			echo -e "\n\e[90;103;2m WARNING \e[m file /etc/apt/sources.list.d/kubernetes.list already exists. \n\e[90;43;2m \e[m         Overwriting with latest version.\n"
			sudo cp /etc/apt/sources.list.d/kubernetes.list \
				/etc/apt/sources.list.d/kubernetes.list.bak-"$(date +%s)"
		fi
		echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
		sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

		sudo apt-get update
		sudo apt-get install -y kubectl
	else
		echo "Skipping install of Kubernetes CLI"
	fi
	echo
}
