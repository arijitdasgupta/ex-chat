# ExChat

A self contained chat server running on Elixir + Cowboy, Plug. Communcation based on pure WebSocket. A port from [node_chat](https://github.com/arijitdasgupta/node_chat)

How to run
----------
In order to run this server, you will need Elixir/Mix installed in your system. 

```bash
mix deps.get
mix run --no-halt
```

To make a docker image tagged `exchat`
```bash
./build.sh
```

Environment variables
---------------------

| Name  | Description | Default Value |
| ------------- | ------------- | ---------- |
| BASE_PATH  | The base path from where the websocket and the statics files will be served, i.e. `//<hostname>:<port>/<BASE_PATH>/` should give you a webpage  | / |
| PORT  | The port where the app will run  | 7000 |