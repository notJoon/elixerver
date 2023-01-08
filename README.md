# elixerver

basic web server with elixir

## How to run

### Start the server

''' plain
(in terminal 1)

iex -S mix

{:ok, pid} = Elixerver.start_link [port: {port}, message: "{message}"]
'''

### Send a request

''' plain
(in terminal 2)

case 1: send echo massage

echo "{message}" | nc localhost {port}

case 2: just see the response

nc localhost {port}
'''

## TODO

- [ ] basic echo server
- [ ] application server
- [ ] apply REST api and gRPC with Phoenix
- [ ] basic CRUD things
