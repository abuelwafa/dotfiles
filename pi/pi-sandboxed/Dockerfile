FROM node:24-bookworm-slim

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    git \
    ripgrep \
    fd-find \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent@0.84.3

# switch to the node user
USER 1000:1000

ENV npm_config_ignore_scripts="true"

WORKDIR /home/node/workspace

ENTRYPOINT ["pi"]
