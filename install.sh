#!/usr/bin/env bash

# =============================================
# this script is still a WIP (Work in Progress)
# and not tested yet
# =============================================

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

cd "$(dirname "$0")"

main() {
    echo "creating projects folder"
    mkdir -p ~/projects

    echo "=> Installing essential apt packages"
    sudo apt install --assume-yes curl git build-essential

    read -p "Enter your email address: " -r private_email_address
    echo
    echo "generating SSH key"
    ssh-keygen -t ed25519 -C "$private_email_address"

    echo "=> Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo "=> installing essential software using homebrew"
    brew install \
        zsh \
        vim \
        neovim \
        git \
        tmux \
        gcc \
        cmake \
        tree \
        btop \
        git-delta \
        node@20 \
        yarn \
        dog \
        bat \
        ripgrep \
        fzf \
        fd \
        fx \
        jq \
        yh \
        lazygit \
        mc \
        libpq \
        gh \
        act \
        cmatrix \
        dust \
        eza \
        kubernetes-cli \
        minikube \
        helm \
        python \
        watchman \
        go \
        qemu \
        lima \
        colima \
        docker \
        ansible \
        rbenv \
        ruby-build

    ln -s ~/projects/dotfiles/.gitconfig ~/.gitconfig

    echo "=> changing default shell to ZSH"
    chsh -s $(which zsh)

    echo "=> Cloning repositories"
    git clone git@github.com:ohmyzsh/ohmyzsh.git ~/projects/ohmyzsh
    git clone git@github.com:bigH/git-fuzzy.git ~/projects/git-fuzzy
    git clone git@github.com:tinted-theming/base16-shell.git ~/projects/base16-shell
    git clone git@github.com:tmux-plugins/tpm.git ~/projects/tpm

    echo "=> Setting up Neovim config"
    mkdir -p ~/.config/nvim
    mkdir -p ~/.nvim/_temp
    mkdir -p ~/.nvim/_backup
    ln -s ~/projects/dotfiles/nvim/init.vim ~/.config/nvim/init.lua
    ln -s ~/projects/dotfiles/vim/.vimrc_background ~/.vimrc_background

    # -n return after n characters, useful for yes/no questions with a value of 1
    # read -p "your prompt question here? (y/n) " -n 1 -r install_docker
    # read -p "your prompt message here? (y/n) " -r install_docker
    # echo
    # if [[ $install_docker =~ ^[Yy]$ ]]; then
    #     echo "=> do something"
    # fi

    echo "=> Wiring up configurations"
    ln -s ~/projects/dotfiles/.zshrc.ubuntu ~/.zshrc
    mkdir -p ~/.config/base16-project
    ln -s ~/projects/base16-shell/scripts/base16-seti.sh ~/.config/base16-project/base16_shell_theme

    echo "=> Installing SDKMAN"
    curl -s "https://get.sdkman.io" | bash
    sdk install java
    sdk install gradle
    sdk install kotlin
    sdk install groovy

    echo "=> Installing Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    echo "=> Installing AWS CLI"
}

main "$@"



# ===============================================================
sudo apt install build-essential git curl python3-pip python3-venv python3-dev
# brew install command



