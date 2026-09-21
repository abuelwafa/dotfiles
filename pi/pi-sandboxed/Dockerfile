# ===========================================
# run pi-build after any change to this file
# ===========================================

FROM debian:trixie AS locale-base
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends locales \
    && localedef -i en_US -c -f UTF-8 en_US.UTF-8

FROM node:26.8-trixie-slim

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    git \
    ripgrep \
    fd-find \
    gnupg \
    vim \
    curl \
    jq \
    python3 \
    python3-venv \
    python3-pip \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY --from=locale-base /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive

RUN npm install -g npm@latest

# hadolint ignore=DL3059
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent@0.86.1

# install Go
COPY --from=golang:1.27-trixie /usr/local/go /usr/local/go
ENV PATH=/usr/local/go/bin:$PATH

RUN ln -s /usr/bin/fdfind /usr/bin/fd

# switch to the node user
USER 1000:1000

ENV npm_config_ignore_scripts='true'
ENV PAGER='cat'
ENV GIT_PAGER='cat'
ENV EDITOR='vim'
ENV LANG='en_US.UTF-8'

RUN curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/vim/.vimrc > /home/node/.vimrc

WORKDIR /home/node/workspace

ENTRYPOINT ["pi"]
