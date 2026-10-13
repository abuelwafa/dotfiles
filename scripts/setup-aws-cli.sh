function setup_aws_cli() {
	read -p "Setup and configure AWS CLI? (y/n): " -r install_aws_cli
	echo
	if [[ ${install_aws_cli} =~ ^[Yy]$ ]]; then
		echo "=> installing AWS CLL"
		curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" --output-dir /tmp -o "awscliv2.zip"
		unzip -u awscliv2.zip
		if command -v aws &> /dev/null; then
			sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
		else
			sudo ./aws/install
		fi
	else
		echo "Skipping install of AWS CLI"
	fi
	echo
}
