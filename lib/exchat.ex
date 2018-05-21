defmodule ExChat do
    require Logger

    defp dispatch() do
        basePath = case System.get_env("BASE_PATH") do
          nil -> Application.get_env(:exchat, :basePath)
          path -> path
        end

        [
            {:_, [
              {"#{basePath}/ws", Sockets, []},
              {"#{basePath}/", :cowboy_static, {:file, "./assets/index.html"}},
              {"#{basePath}/[...]", :cowboy_static, {:dir, "./assets"}},
              {:_, Plug.Adapters.Cowboy.Handler, {Http404, []}}
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
        port = case System.get_env("BASE_PATH") do
          nil -> Application.get_env(:exchat, :defaultPort)
          port -> Integer.parse(port)
        end
        
        start(type, args, port)
    end

    def start(port) do
        start([], [], port)
    end

    def start do
        start([], [])
    end
end
