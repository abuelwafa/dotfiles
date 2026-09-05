# run pi-build after any change to this file
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
    locales \
    locales-all \
    tzdata \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g npm@latest

# hadolint ignore=DL3059
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent@0.85.0

# install Go
COPY --from=golang:1.27-trixie /usr/local/go /usr/local/go
ENV PATH=/usr/local/go/bin:$PATH

# switch to the node user
USER 1000:1000

ENV npm_config_ignore_scripts='true'
ENV PAGER='cat'
ENV GIT_PAGER='cat'
ENV EDITOR='vim'
ENV NO_COLOR=1
ENV TERM='dumb'

RUN curl -fsSL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/vim/.vimrc > /home/node/.vimrc

WORKDIR /home/node/workspace

ENTRYPOINT ["pi"]
