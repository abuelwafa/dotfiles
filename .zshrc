#!/bin/zsh

# Path to your oh-my-zsh installation.
export ZSH="$HOME/projects/ohmyzsh"

# If you come from bash you might have to change your $PATH.
export PATH="$HOME/bin:/usr/local/bin:$PATH"
export PATH="$HOME/projects/git-fuzzy/bin:$PATH"

export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

ZSH_THEME="amuse"
# ZSH_THEME="frontcube"
# ZSH_THEME="macovsky"
# ZSH_THEME="tjkirch"

# display red dots while waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(
    adb
    aws
    git-prompt
    colored-man-pages
    docker
    docker-compose
)

export EDITOR='nvim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export FX_THEME=4

source $ZSH/oh-my-zsh.sh

# My aliases
alias cls='clear'
alias l='ls -lahp'
alias la='ls -lahp'
unalias ll
alias ll='ls -lahp --color | less -R'
alias md='mkdir -vp'
alias p='popd'
alias tree='tree -a -h -f --du'
alias vim='nvim'
alias vi='nvim'
alias vimdiff='nvim -d'

function ..() { cd ../$1; }
function ...() { cd ../../$1; }
function ....() { cd ../../../$1; }
function .....() { cd ../../../../$1; }
function ......() { cd ../../../../../$1; }
function .......() { cd ../../../../../../$1; }
function ........() { cd ../../../../../../../$1; }

alias y='yarn'
alias yarn-clean='yarn cache clean'
alias yarn-upgrade='yarn upgrade-interactive --latest'
alias npm-upgrade='npx npm-upgrade check && npm update --save'
alias npm-clean='npm cache clean --force'

rule() {
    printf "%$(tput cols)s\n"|tr " " "-"
}

# to make sudo work with aliases
alias sudo='sudo '

alias podinstall="npx pod-install"
alias watchman-clean='watchman watch-del-all'
alias pod-clean='pod cache clean --all'

# git aliases
alias gcm='git commit'
alias glog='git log --graph --all --decorate --format=medium --date-order'
alias glogp='git log --graph --all --decorate --format=medium --stat --summary --date-order'
alias glogpp='git log --graph --all --decorate --format=medium --stat --summary --patch --date-order'

alias glog1='git log --graph --decorate --format=medium --date-order'
alias glog1p='git log --graph --decorate --format=medium --stat --summary --date-order'
alias glog1pp='git log --graph --decorate --format=medium --stat --summary --patch --date-order'
alias gst='git status'
alias gs='git status -sb'
alias gdif='git diff --minimal --color --patch --stat'
alias gdiftool='git difftool'
alias gpush='git push'
alias ga='git add'
alias gremote='git remote -v'
alias gaa='git add .'
alias gpull='git fetch --all --prune && git pull --rebase'
alias gshow='git show'
alias gfetch='git fetch --all --prune'
alias gbranch='git branch --all'
alias gnewbranch='git checkout -b'
alias gdelbranch='git branch -d'
alias gswitchbranch='git checkout'
alias greset='git checkout --'
alias gunstage='git reset HEAD --'
alias gclean='git clean -ifd'

function gstash() {
    if [ -z $1 ]; then
        git stash list;
    else
        git stash show stash@{$1} -p;
    fi
}

function gdropstash() {
    if [ -z $1 ]; then
        echo "Specify the id of the stash you want to drop."
    else
        git stash drop stash@{$1};
    fi
}

function gpopstash() {
    if [ -z $1 ]; then
        echo "Specify the id of the stash you want to apply."
    else
        git stash pop stash@{$1};
    fi
}
alias gsavestash='git stash push'

# show file contents
# function show(){ less -R -x4 "$1"; }
# function show(){ bat "$1"; }
alias show=bat

function serve() {
    docker run --rm -p $1:80/tcp -v $(pwd):/usr/share/nginx/html:ro nginx:stable-alpine;
}

# make an alias for compressing and extracting zip files
# new alternative: just use zip and unzip
# function extract() { echo "Extracting $1"; tar -xzf $1; echo "Done extracting $1..."; }
# function compress() { echo "Compressing $1"; tar -cvzf $1; echo "Done compressing..."; }

# function for downloading files from urls
function download(){
    if [ -n "$2" ]; then
      curl -# $1 -o $2;
    else
      curl -O -# $1;
    fi
}

# parses jwt token and passes the output to fx
function jwtparse(){
    echo -n "Enter JWT token: "

    read token

    local payload="$(echo -n $token | cut -d "." -f 2)"
    local result="$payload"

    # pad the end of string by appending = to make
    # the encoded string length equals to multiples of 4
    local padlen=$(( ${#payload} % 4 ))
    if [ $padlen -eq 2 ]; then result="$payload"'=='
    elif [ $padlen -eq 3 ]; then result="$payload"'='
    fi

    echo -n $result | base64 -d | fx
}

function pg_connect(){
    echo -n "Enter DB host: "
    read db_host

    echo -n "Enter DB name: "
    read db_name

    echo -n "Enter DB user: "
    read db_user

    echo -n "Enter DB password: "
    read -s db_password
    echo

    echo -n "Enter DB port(5432): "
    read db_port

    echo -n "Enter SSH host: "
    read ssh_host

    echo -n "Enter SSH username: "
    read ssh_username

    echo -n "Enter SSH password: "
    read -s ssh_pwd
    echo

    echo -n "Enter SSH port(22): "
    read ssh_port

    local cmd="pgcli postgresql://$db_user:$db_password@$db_host:$db_port/$db_name --ssh-tunnel $ssh_username:$ssh_pwd@$ssh_host:$ssh_port"

    eval $cmd
}

# remember when copying directories, adding a slash to the directory name like directory/
# makes the copying action to perform on the contents of the directory and not the directory itself
alias cp='cp -iR'
alias mv='mv -i'
alias remove='rm -rf'

export BAT_THEME="base16-256"

# Base16 Shell
BASE16_SHELL_PATH="$HOME/projects/base16-shell"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL_PATH/profile_helper.sh" ] && \
        source "$BASE16_SHELL_PATH/profile_helper.sh"

# setting up correct paths and variables from homebrew
export PATH="$(brew --prefix python)/libexec/bin:$PATH"
export PATH="$(brew --prefix node)/bin:$PATH"
export LDFLAGS="-L$(brew --prefix node)/lib"
export CPPFLAGS="-I$(brew --prefix node)/include"
export NODE_BINARY="$(which node)"

PROMPT='$(rule)
%{$fg_bold[green]%}%~%{$reset_color%}$(git_prompt_info) %{$fg_bold[red]%}%*%{$reset_color%} %{$bg_bold[green]%}%{$fg_bold[black]%} node: $(node -v) %{$reset_color%}
-> '

if command -v rbenv &> /dev/null
then
    eval "$(rbenv init - zsh)"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# company specific config
[[ -s "$HOME/projects/.work-company-config" ]] && source "$HOME/projects/.work-company-config"
