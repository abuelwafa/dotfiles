#!/bin/bash
#
#   ▄▄   █                    ▀▀█                    ▄▀▀
#   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
#  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
#  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
# █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
#
# description goes here

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

function setup_sdkman() {
    read -p "Setup and configure SDKMAN with java, kotlin and gradle? (y/n): " -r install_sdkman
    echo
    if [[ $install_sdkman =~ ^[Yy]$ ]]; then
        echo "=> Installing SDKMAN"
        curl -s "https://get.sdkman.io" | bash
        sdk install java
        sdk install gradle
        sdk install kotlin
        sdk install groovy
        sdk install maven
    else
        echo "Skipping install of SDKMAN"
    fi
    echo
}

function setup_neovim() {
    rm ~/.vimrc || true
    mkdir -p ~/.config/nvim
    ln -s ~/workspace/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
    ln -s ~/workspace/dotfiles/vim/.vimrc ~/.vimrc
    mkdir -p ~/.nvim/_temp
    mkdir -p ~/.nvim/_backup
    echo "=> Openning neovim to install plugins and language servers. Exit when finished."
    sleep 2
    echo "=> Openning in 5 seconds."
    sleep 1
    echo "=> Openning in 4 seconds."
    sleep 1
    echo "=> Openning in 3 seconds."
    sleep 1
    echo "=> Openning in 2 seconds."
    sleep 1
    echo "=> Openning in 1 seconds."
    sleep 1
    nvim
}

main() {

    rm ~/.vimrc || true
    rm ~/.bash_aliases || true
    rm ~/.tmux.conf || true
    rm ~/.gitconfig.conf || true

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/server-configs/setup.sh)"

    sudo apt install \
        git \
        tmux \
        build-essential \
        ufw \
        unzip \
        python3-pip \
        python3-dev

    mkdir -p ~/workspace
    touch ~/.machine-config

    if [ ! grep -e "export GIT_COMMITTER_EMAIL" ~/.machine-config ]; then
        echo 'export GIT_COMMITTER_EMAIL="mohamed.abuelwafa@gmail.com"' | tee -a ~/.machine-config
        echo 'export GIT_AUTHOR_EMAIL="mohamed.abuelwafa@gmail.com"' | tee -a ~/.machine-config
    fi

    if [ ! grep -e "brew shellenv" ~/.machine-config ]; then
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' | tee -a ~/.machine-config
    fi

    # increase ubuntu inotify watchers for dropbox sync and for projects file watching
    echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

    # clone essential repos
    if [ -d ~/workspace/dotfiles ]; then
        (cd ~/workspace/dotfiles && git fetch --all --prune && git pull --rebase)
    else
        git clone https://github.com/abuelwafa/dotfiles.git ~/workspace/dotfiles
    fi
    if [ -d ~/workspace/tpm ]; then
        (cd ~/workspace/tpm && git pull --rebase)
    else
        git clone https://github.com/tmux-plugins/tpm ~/workspace/tpm
    fi

    # generate ssh key
    if [ ! -f ~/.ssh/id_ed25519 ]; then
        ssh-keygen -t ed25519 -C "mohamed.abuelwafa"
    fi

    # install homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # install essential homebrew packages
    # DB CLIs
    brew tap dbcli/tap

    brew install \
        vim \
        neovim \
        git \
        tmux \
        gcc \
        cmake \
        tree \
        htop \
        git-delta \
        node@24 \
        gnupg \
        sops \
        doggo \
        bat \
        ripgrep \
        fzf \
        jq \
        lazygit \
        libpq \
        kubernetes-cli \
        helm \
        fluxcd/tap/flux \
        kind \
        derailed/k9s/k9s \
        kubectx \
        kustomize \
        go \
        ansible \
        python@3 \
        sst/tap/opencode \
        opentofu \
        pgcli \
        litecli \
        mycli \
        iredis \
        lnav \
        goaccess \
        hcloud \
        gh \
        dust \
        fx \
        # yarn \
        # watchman \
        # fd \
        # eza \
        # rbenv \
        # ruby-build \
        cmatrix

    # linking config files
    rm ~/.bash_aliases || true
    rm ~/.tmux.conf || true
    ln -s ~/workspace/dotfiles/bash/bashrc-full ~/.bash_aliases
    ln -s ~/workspace/dotfiles/tmux/tmux.conf ~/.tmux.conf
    ln -s ~/workspace/dotfiles/pgcli.config ~/.config/pgcli/config
    ln -s ~/workspace/dotfiles/yamlfmt.yml ~/yamlfmt.yml
    ln -s ~/workspace/dotfiles/.gitconfig ~/.gitconfig

    # install sdkman
    install_sdkman

    # install rust tools
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    # install tclock
    cargo install tclock

    # setup neovim
    setup_neovim

    check_system_reboot
}

main "$@"
