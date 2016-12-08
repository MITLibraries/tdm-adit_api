## AditApi

A simple REST API server implementing the Adit TDM spec,
currently in [early draft](https://app.swaggerhub.com/api/rrodgers/adit/0.2)
It consumes and produces JSON-formatted messages.

## Requirements
  * AditApi is written in the Phoenix/Elixir framework, which itself is built upon
    the Erlang language and BEAM virtual machine. Install Erlang, then Elixir, then Phoenix.
  * The server needs a PostgreSQL database.

## Deployment

The server may be launched from the command-line, as a simple mix task:

    POSTGRES_SERVICE_HOST=localhost mix phoenix.server

Alternatively, a Dockerfile is included for container-based deployment:

    docker build --tag aditapi .

    docker run --name aditsvc --rm -p 4000:4000 -e POSTGRES_SERVICE_HOST='localhost' aditapi

if a PG server is running locally at the default port.
