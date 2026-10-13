function setup_gcloud_cli() {
	read -p "Setup and configure Google Cloud CLI? (y/n): " -r install_gcloud_cli
	echo
	if [[ ${install_gcloud_cli} =~ ^[Yy]$ ]]; then
		if command -v gcloud &> /dev/null; then
			echo "=> Google Cloud CLI is already installed. update"
		else
			echo "=> installing Google Cloud CLI"
			curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
			local repo
			repo="deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main"
			echo "${repo}" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
			sudo apt-get update && sudo apt-get install -y google-cloud-cli
			echo "=> Google cloud cli has been installed successfully."
			echo "=> run \`gcloud init\` to configure it"
		fi
	else
		echo "Skipping install of Google Cloud CLI"
	fi
	echo
}
