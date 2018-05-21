FROM elixir

COPY . .
RUN rm -rf _build deps .git
RUN mix local.rebar --force
RUN yes | mix deps.get
RUN mix compile

EXPOSE 7000

CMD ["mix", "run", "--no-halt"]