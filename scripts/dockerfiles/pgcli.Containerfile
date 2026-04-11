# build with
# docker build -f pgcli.Containerfile -t pgcli .

# run examples:
# docker run --network host --rm -it --name db-client --help
# docker run --network host --rm -it --name db-client {pgcli_options}
# docker run --network host --rm -it --name db-client {connection_url}
# docker run --network host --rm -it --name db-client postgresql://postgres:postgres@localhost:5432/postgres
FROM python:3.14-slim-trixie

# hadolint ignore=DL3008
RUN set -ex && apt-get update && apt-get install -y --no-install-recommends libpq5 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/pgcli && \
    /opt/pgcli/bin/pip install --upgrade pip && \
    /opt/pgcli/bin/pip install pgcli

ENTRYPOINT ["/opt/pgcli/bin/pgcli"]
