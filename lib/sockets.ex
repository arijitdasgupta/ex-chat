defmodule Sockets do
    require Logger
    @behaviour :cowboy_websocket_handler

    @timeout 10000000

    def init(_, _req, _opts) do
        {:upgrade, :protocol, :cowboy_websocket}
    end

    def websocket_init(_type, req, _opts) do
        state = %{}

        ChatProcs.addProc(self())

        createMessage("Somebody joined the chat") |> broadcast(:notself)
        {:ok, req, state, @timeout}
    end

    def websocket_handle({:text, message}, req, state) do
        broadcast(message)

        {:ok, req, state}
    end

    def websocket_info({:broadcast, message}, req, state) do
        {:reply, {:text, message}, req, state}
    end

    def websocket_terminate(_reason, _req, _state) do
        ChatProcs.removeProc(self())
        createMessage("Somebody left the chat") |> broadcast()
        :ok
    end

    defp broadcast(messageJsonEncoded, :notself) do
        ChatProcs.getAllProcs()
            |> Enum.filter((fn(pid) -> pid != self() end))
            |> call_broadcast(messageJsonEncoded)
    end

    defp broadcast(messageJsonEncoded) do
        ChatProcs.getAllProcs()
            |> call_broadcast(messageJsonEncoded)
    end

    defp createMessage(message) do
        {:ok, encodedJson} = Poison.encode(%{
            sender: "admin",
            message: message
        })

        encodedJson
    end

    defp call_broadcast(pids, messageJsonEncoded) do
        pids |> Enum.each((fn(pid) -> 
            send(pid, {:broadcast, messageJsonEncoded})
        end))
    end
end