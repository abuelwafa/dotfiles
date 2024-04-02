#!/usr/bin/env bash

# =============================================
# this script is still a WIP (Work in Progress)
# =============================================

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

cd "$(dirname "$0")"

main() {
    echo

    echo "=> Installing essential apt packages"
    apt install curl git build-essential zsh

    echo
    echo "===================================="
    echo

    read -p "Change default shell to ZSH? " -n 1 -r change_shell
    echo
    if [[ $change_shell =~ ^[Yy]$ ]]; then
        echo "=> Changing default shell to ZSH"
        chsh -s $(which zsh)
    fi

    echo
    echo "===================================="
    echo

    echo "=> Cloning repositories"
    git clone git@github.com:ohmyzsh/ohmyzsh.git ~/projects/ohmyzsh
    git clone git@github.com:bigH/git-fuzzy.git ~/projects/git-fuzzy
    git clone git@github.com:tinted-theming/base16-shell.git ~/projects/base16-shell

    echo
    echo "===================================="
    echo

    echo "=> Installing Homebrew"

    echo
    echo "===================================="
    echo

    echo "=> Installing Git"
    brew install git
    ln -s ~/projects/dotfiles/.gitconfig ~/.gitconfig

    echo
    echo "===================================="
    echo

    echo "=> Installing Neovim"
    brew install neovim
    mkdir -p ~/.config/nvim
    ln -s ~/projects/dotfiles/nvim/init.vim ~/.config/nvim/init.vim
    mkdir -p ~/.nvim/_temp
    mkdir -p ~/.nvim/_backup
    ln -s ~/projects/dotfiles/coc-settings.json ~/.config/nvim/coc-settings.json
    ln -s ~/projects/dotfiles/vim/.vimrc_background ~/.vimrc_background

    echo
    echo "===================================="
    echo

    echo "=> Installing tmux"
    brew install tmux
    ln -s ~/projects/dotfiles/tmux.conf ~/.tmux.conf

    echo
    echo "===================================="
    echo

    echo "=> Installing gcc"
    brew install gcc

    echo
    echo "===================================="
    echo

    echo "=> Installing cmake"
    brew install cmake

    echo
    echo "===================================="
    echo

    echo "=> Installing tree"
    brew install tree

    echo
    echo "===================================="
    echo

    echo "=> Installing btop"
    brew install btop

    echo
    echo "===================================="
    echo

    echo "=> Installing git-delta"
    brew install git-delta

    echo
    echo "===================================="
    echo

    echo "=> Installing bat"
    brew install bat

    echo
    echo "===================================="
    echo

    echo "=> Installing MC (Midnight Commander)"
    brew install mc

    echo
    echo "===================================="
    echo

    echo "=> Installing ripgrep"
    brew install ripgrep

    echo
    echo "===================================="
    echo

    echo "=> Installing fd"
    brew install fd

    echo
    echo "===================================="
    echo

    read -p "Install Watchman? " -n 1 -r install_watchman
    echo
    if [[ $install_watchman =~ ^[Yy]$ ]]; then
        echo "=> Installing watchman"
        brew install watchman
        echo
    fi

    read -p "Install Go? " -n 1 -r install_go
    echo
    if [[ $install_go =~ ^[Yy]$ ]]; then
        echo "=> Installing Go"
        brew install go
    fi

    read -p "Install Docker and Colima through Homebrew? " -n 1 -r install_docker
    echo
    if [[ $install_docker =~ ^[Yy]$ ]]; then
        echo "=> Installing docker"
        brew install docker

        echo "=> Installing colima"
        brew install colima
    fi

    read -p "Install Kubernetes CLI? " -n 1 -r install_k8s_cli
    echo
    if [[ $install_k8s_cli =~ ^[Yy]$ ]]; then
        echo "=> Installing k8s cli"
        brew install kubernetes-cli
    fi
    # echo "=> Installing helm"
    # brew install helm

    # echo "=> Installing youtube-dl"
    # brew install youtube-dl

    echo "=> Installing lazygit"
    brew install lazygit

    echo "=> Wiring up configurations"
    ln -s ~/projects/dotfiles/.zshrc.ubuntu ~/.zshrc
    mkdir -p ~/.config/base16-project
    ln -s ~/projects/base16-shell/scripts/base16-seti.sh ~/.config/base16-project/base16_shell_theme

    echo "=> Setting up Neovim config"

    echo "=> Installing Node"
    brew install node@18
    echo 'export PATH="/home/linuxbrew/.linuxbrew/opt/node@18/bin:$PATH"' >> ~/.profile

    echo "=> Installing yarn"
    brew install yarn

    echo "=> Installing SDKMAN"
    curl -s "https://get.sdkman.io" | bash

    echo "=> Installing JDK"
    sdk install java

    echo "=> Installing Gradle"
    sdk install gradle

    echo "=> Installing Kotlin"
    sdk install kotlin

    echo "=> Installing Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    echo "=> Installing AWS CLI"
}

main "$@"
