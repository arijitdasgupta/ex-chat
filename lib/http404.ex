defmodule Http404 do
    use Plug.Router

    plug :match
    plug :dispatch

    def init(options) do
      options
    end

    match(_, do: send_resp(conn, 404, "Oops!"))
end