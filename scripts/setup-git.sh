function setup_git() {
	local install_git
	read -p "Setup and configure git? (y/n): " -r install_git
	echo
	if [[ ${install_git} =~ ^[Yy]$ ]]; then
		echo "=> installing git"
		sudo apt-get install -y git
		echo "=> configuring git"

		local git_email
		local git_name
		read -p "Enter git config email: " -r git_email
		echo
		read -p "Enter git config name: " -r git_name
		echo
		git config --global user.email "${git_email}"
		git config --global user.name "${git_name}"
		git config --global user.useConfigOnly true
		git config --global color.ui true
		git config --global core.editor vim
		git config --global core.autocrlf input
		git config --global status.showUntrackedFiles all
	else
		echo "Skipping setup of Git"
	fi
	echo
}
