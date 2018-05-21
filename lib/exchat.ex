defmodule ExChat do
    require Logger

    defp dispatch() do
        [
            {:_, [
              {"/ws", Sockets, []},
              {"/", :cowboy_static, {:file, "./assets/index.html"}},
              {"/[...]", :cowboy_static, {:dir, "./assets"}},
              {:_, Plug.Adapters.Cowboy.Handler, {HttpApp, []}}
            ]}
        ]
    end

    def start(_type, _args, port) do
        ChatProcs.start()
        children = [Plug.Adapters.Cowboy.child_spec(:http, HttpApp, [], [
            port: port,
            dispatch: dispatch()
        ])]
        Logger.info "Starting application on PORT #{port}"
        Supervisor.start_link(children, strategy: :one_for_one)
    end

    def start(type, args) do
        start(type, args, Application.get_env(:exchat, :defaultPort))
    end

    def start(port) do
        start([], [], port)
    end

    def start do
        start([], [], Application.get_env(:exchat, :defaultPort))
    end
end
