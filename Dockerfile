FROM elixir
MAINTAINER Richard Rodgers <rrodgers@mit.edu>
RUN apt-get update && apt-get install --yes postgresql-client
ADD . /app
RUN mix local.hex --force
WORKDIR /app
EXPOSE 4000
CMD ["mix", "do", "ecto.migrate,", "phoenix.server"]
