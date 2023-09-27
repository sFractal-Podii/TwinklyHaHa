# heavily borrowed from https://elixirforum.com/t/cannot-find-libtinfo-so-6-when-launching-elixir-app/24101/11?u=sigu
FROM hexpm/elixir:1.15.6-erlang-26.1-debian-bookworm-20230612 AS app_builder

ARG env=prod
ARG cyclonedx_cli_version=v0.24.0
ARG NODE_MAJOR=20

ENV LANG=C.UTF-8 \
   TERM=xterm \
   MIX_ENV=$env

RUN mkdir /opt/release
WORKDIR /opt/release

RUN mix local.hex --force && mix local.rebar --force
RUN apt-get update -y && apt-get install curl git make  -y

RUN curl -L  https://github.com/CycloneDX/cyclonedx-cli/releases/download/$cyclonedx_cli_version/cyclonedx-linux-x64 --output cyclonedx-cli \
   && chmod a+x cyclonedx-cli \
   && curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin \
   && syft debian:bookworm-slim -o spdx > debian.bookworm_slim-spdx-bom.spdx \
   && syft debian:bookworm-slim -o spdx-json > debian.bookworm_slim-spdx-bom.json \
   && syft debian:bookworm-slim -o cyclonedx-json > debian.bookworm_slim-cyclonedx-bom.json \
   && syft debian:bookworm-slim -o cyclonedx > debian.bookworm_slim-cyclonedx-bom.xml 
RUN apt install ca-certificates gnupg -y \
      && mkdir -p /etc/apt/keyrings \
      && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
      && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
      && apt-get update -y \
      && apt-get install nodejs -y

COPY mix.exs .
COPY mix.lock .
RUN mix deps.get && mix deps.compile

COPY assets ./assets
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY Makefile ./Makefile

RUN make sbom && cp *bom* ./priv/static/.well-known/sbom/

RUN mix assets.deploy && mix release

FROM debian:bookworm-slim AS app


ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y openssl

RUN useradd --create-home app
WORKDIR /home/app
COPY --from=app_builder /opt/release/_build .
RUN chown -R app: ./prod
USER app

CMD ["./prod/rel/twinklyhaha/bin/twinklyhaha", "start"]
