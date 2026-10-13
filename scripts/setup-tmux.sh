function setup_tmux() {
	echo "=> Setting up tmux"
	sudo apt-get install -y tmux
	# backup .tmux.conf file if it already exists
	if [[ -f "${HOME}/.tmux.conf" ]]; then
		cp ~/.tmux.conf ~/.tmux.conf-bak-"$(date +%s)"
		echo '=> old ~/.tmux.conf have been backed up'
	fi
	curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/tmux/tmux-minimal.conf > ~/.tmux.conf
	echo
}
