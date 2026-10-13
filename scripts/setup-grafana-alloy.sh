function setup_grafana_alloy() {
	read -p "Setup and configure Grafana Alloy? (y/n): " -r install_alloy
	echo
	if [[ ${install_alloy} =~ ^[Yy]$ ]]; then
		echo "=> setting up Grafana alloy"

		if command -v alloy &> /dev/null; then
			echo "=> Grafana alloy is already installed. update through apt."
		else
			sudo mkdir -p /etc/apt/keyrings/
			curl -fsSL https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
			local grafana_repo="deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main"
			echo "${grafana_repo}" | sudo tee /etc/apt/sources.list.d/grafana.list

			sudo apt-get update && sudo apt-get install -y alloy
		fi
	else
		echo "Skipping install of Grafana Alloy"
	fi
	echo
}
