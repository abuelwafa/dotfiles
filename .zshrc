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
    git
    git-prompt
    node
    npm
    urltools
    encode64
    web-search
    cp
    colored-man-pages
    docker
    docker-compose
    themes
    yarn
    kubectl
    helm
    terraform
    gradle
)

source $ZSH/oh-my-zsh.sh

PROMPT='$(rule)
%{$fg_bold[green]%}%~%{$reset_color%}$(git_prompt_info) %{$fg_bold[red]%}%*%{$reset_color%}
-> '

export EDITOR='vim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# My aliases
alias cls='clear'
alias l='ls -lahp'
alias ll='ls -lahp --color | less -R'
unalias ll
function ll() { ls -lahp --color  $1 | less -R; }
alias la='ls -ahp'
alias md='mkdir -vp'
alias p='popd'
alias tree='tree -a -h -f --du'
function drop() { pushd ~/Dropbox/$1; }
function dtop() { pushd ~/Desktop/$1; }
function dtemp() { pushd ~/Desktop/temp/$1; }
function doc() { pushd ~/Documents/$1; }

function ..() { cd ../$1; }
function ...() { cd ../../$1; }
function ....() { cd ../../../$1; }
function .....() { cd ../../../../$1; }
function ......() { cd ../../../../../$1; }

alias yarn-upgrade='yarn upgrade-interactive --latest'
# alias npm-upgrade='npm --depth 9999 update && npm outdated'
alias npm-upgrade='npm outdated && npx npm-upgrade check'
function newreactnative() { npx react-native init $1 --template react-native-template-typescript }

rule() {
    printf "%$(tput cols)s\n"|tr " " "-"
}

# to make sudo work with aliases
alias sudo='sudo '

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
# alias gbranch='git branch --all | less -R'
alias gbranch='git branch --all'
alias gnewbranch='git checkout -b'
alias gdelbranch='git branch -d'
alias gswitchbranch='git checkout'
alias greset='git checkout --'
alias gunstage='git reset HEAD --'
alias gclean='git clean -ifd'
unalias gsta
unalias gstaa
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
alias gsavestash='git stash save'

# show file contents
# function show(){ less -R -x4 "$1"; }
# function show(){ bat "$1"; }
alias show=bat

alias shutdown='sudo shutdown'
alias restart='sudo shutdown -r'
alias reboot='sudo shutdown -r'

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

# remember when copying directories, adding a slash to the directory name like directory/
# makes the copying action to perform on the contents of the directory and not the directory itself
# function remove() { rm -rf $1 $2 $3 $4 $5 $6 $7 $8 $9; echo "Removed $1"; }
function remove() { rm -rf "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"; }
# function clone() { cp -iR $1 $2; echo "Done copying $1 -> $2"; }
function clone() { cp -iR $1 $2; }
# function rename() { mv -i $1 $2; echo "Renamed $1 -> $2"; }
# function move() { mv -i $1 $2; echo "Done moving $1 -> $2"; }
function move() { mv -i $1 $2; }

# Base16 Shell
BASE16_SHELL_PATH="$HOME/projects/base16-shell"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL_PATH/profile_helper.sh" ] && \
        source "$BASE16_SHELL_PATH/profile_helper.sh"


# company specific config
[[ -s "$HOME/projects/.work-company-config" ]] && source "$HOME/projects/.work-company-config"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
