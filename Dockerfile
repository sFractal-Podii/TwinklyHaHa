# heavily borrowed from https://elixirforum.com/t/cannot-find-libtinfo-so-6-when-launching-elixir-app/24101/11?u=sigu
FROM elixir:1.11.2 AS app_builder

ARG env=prod
ARG cyclonedx_cli_version=v0.24.0

ENV LANG=C.UTF-8 \
   TERM=xterm \
   MIX_ENV=$env

RUN mkdir /opt/release
WORKDIR /opt/release

RUN mix local.hex --force && mix local.rebar --force
RUN curl -L  https://github.com/CycloneDX/cyclonedx-cli/releases/download/$cyclonedx_cli_version/cyclonedx-linux-x64 --output cyclonedx-cli && chmod a+x cyclonedx-cli

COPY mix.exs .
COPY mix.lock .
RUN mix deps.get && mix deps.compile

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs make

COPY assets ./assets
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY Makefile ./Makefile

RUN make sbom
# make sbom for the production docker image
RUN syft debian:buster-slim -o spdx > debian.buster_slim-spdx-bom.spdx
RUN syft debian:buster-slim -o spdx-json > debian.buster_slim-spdx-bom.json
RUN syft debian:buster-slim -o cyclonedx-json > debian.buster_slim-cyclonedx-bom.json
RUN syft debian:buster-slim -o cyclonedx > debian.buster_slim-cyclonedx-bom.xml

RUN cp *bom* ./priv/static/.well-known/sbom/
RUN mix assets.deploy
RUN mix release

FROM debian:buster-slim AS app


ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y openssl

RUN useradd --create-home app
WORKDIR /home/app
COPY --from=app_builder /opt/release/_build .
RUN chown -R app: ./prod
USER app

CMD ["./prod/rel/twinklyhaha/bin/twinklyhaha", "start"]
