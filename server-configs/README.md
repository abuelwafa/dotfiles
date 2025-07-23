# Server config

Personal minimal server configs for use on jump servers or development machines. Configs doesn't rely on external plugins/dependencies.

## Installation

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/server-configs/setup.sh)"
```

# Development config

Setup script for configuring debian machine for development. based on the above server config.

## Installation

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/server-configs/dev-vm-setup.sh)"
```

## What's included

### Server Config
- Update apt dependencies and install essential packages (vim, curl, jq, htop, locales, bash-completion, ca-certificates, gnupg, python3, python3-venv)
- Simple Vim config without any plugins
- Simple tmux config without any plugins
- Simple `.bashrc` with a bunch of aliases
- Optional installations with prompts:
  - **Git** - Installation and configuration with user settings
  - **Tmux** - Terminal multiplexer with custom config
  - **UFW** - Uncomplicated Firewall setup and configuration
  - **Fail2ban** - Intrusion prevention system
  - **SSH Hardening** - Disable root login, password auth, restrict users, custom port/address
  - **Nginx** - Web server with nginx-extras
  - **Wireguard** - VPN client configuration
  - **Docker** - Container runtime (placeholder)
  - **Containerd** - Container runtime with systemd service
  - **Nerdctl** - Docker-compatible CLI for containerd (minimal and full versions)
  - **AWS CLI** - Amazon Web Services command line interface
  - **Google Cloud CLI** - Google Cloud Platform command line interface
  - **Hetzner CLI** - Hetzner Cloud command line interface (placeholder)
  - **Prometheus Node Exporter** - System metrics exporter with systemd service
  - **Grafana Alloy** - Telemetry collector (placeholder)
  - **Build Essential** - Compilation tools for development
  - **Hostname Update** - Change machine hostname

### Development Config
Includes everything from server config plus:
- **Homebrew** - Package manager for Linux with extensive package list including:
  - Development tools: neovim, git-delta, gcc, cmake, tree, bat, ripgrep, fzf, lazygit
  - Cloud/DevOps tools: kubernetes-cli, helm, flux, kind, k9s, kubectx, kustomize, ansible, opentofu, hcloud, gh
  - Database CLIs: pgcli, litecli, mycli, iredis
  - Programming languages: node@24, go, python@3
  - Utilities: doggo, sops, gnupg, dust, fx, lnav, goaccess, cmatrix, opencode
- **SDKMAN** - Java ecosystem manager with Java, Kotlin, Gradle, Groovy, Maven
- **Rust toolchain** - Rust programming language with cargo
- **SSH key generation** - ED25519 key pair creation
- **Dotfiles integration** - Symlinked configuration files for bash, tmux, vim, git
- **Neovim setup** - Advanced text editor with plugin installation
- **System optimizations** - Increased inotify watchers for development
- **Additional tools**: tclock (terminal clock), enhanced configs for pgcli and yamlfmt

## Note
This config is highly personalized to fit my workflows with my custom mappings. Feel free to adjust it to your needs
