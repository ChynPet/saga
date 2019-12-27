FROM elixir:latest

ENV VERSION 0.1.0

WORKDIR /opt/sagas-signin-signup/
COPY . /opt/sagas-signin-signup/

EXPOSE 50051 9092

RUN mix local.hex --force && mix local.rebar --force
RUN MIX_ENV=prod mix do deps.get --only prod, deps.compile --force
RUN mix deps.clean mime --build 
RUN iex -S mix
# CMD ["iex", "-S", "mix"]