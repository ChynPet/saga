FROM elixir:1.9.1-alpine

ENV LANG C.UTF-8 \
  REFRESHED_AT 2019-09-14-1 \
  TERM xterm \
  DEBIAN_FRONTEND noninteractive
ENV ELIXIR_VERSION v1.9.1
ENV VERSION 0.1.0

RUN apk add --update \
  git \
  build-base \
  wget \
  bash

WORKDIR /opt/saga-builder/
COPY . /opt/saga-builder/

RUN mix local.hex --force && mix local.rebar --force
RUN MIX_ENV=prod mix do deps.get --only prod, deps.compile --force
RUN mix deps.clean mime --build 
RUN MIX_ENV=prod mix distillery.release --env=prod

RUN mkdir /opt/saga \
  && tar xvzf ./_build/prod/rel/saga/releases/${VERSION}/saga.tar.gz -C /opt/saga
  
RUN rm -rf /opt/saga-builder

RUN cp -avr /opt/saga /usr/local/bin/saga
WORKDIR /usr/local/bin/saga/bin

ENV PATH=${PATH}:/usr/local/bin/saga/bin

EXPOSE 9092 50051

CMD ["saga","foreground"]