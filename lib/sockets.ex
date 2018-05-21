defmodule Sockets do
    require Logger
    @behaviour :cowboy_websocket_handler

    @timeout 10000000

    def init(_, _req, _opts) do
        {:upgrade, :protocol, :cowboy_websocket}
    end

    def websocket_init(_type, req, _opts) do
        ChatProcs.addProc(self())

        {:ok, req, %{}, @timeout}
    end

    def websocket_handle({:text, message}, req, state) do
        {:ok, messageMap} = Poison.decode(message)

        case messageMap do
            %{"user" => user} -> # Registers user
                ChatProcs.setUser(self(), user)
                Mappers.createAdminMessage("#{user} joined the chat") |> broadcast(:notself)
            %{"sender" => sender, "message" => message} -> # Sends message to everyone
                sender = case ChatProcs.getUser(self()) do
                    nil -> sender
                    user -> user
                end
                Mappers.createMessage(message, sender) |> broadcast()
        end

        {:ok, req, state}
    end

    def websocket_info({:broadcast, message}, req, state) do
        {:reply, {:text, message}, req, state}
    end

    def websocket_terminate(_reason, _req, _state) do
        # Decides who is leaving the chat
        user = case ChatProcs.getUser(self()) do
            nil -> "Somebody"
            u -> u
        end
        Mappers.createAdminMessage("#{user} left the chat") |> broadcast()

        ChatProcs.removeProc(self())
        :ok
    end

    def broadcast(messageJsonEncoded, :notself) do
        ChatProcs.getAllProcs()
            |> Enum.filter((fn(pid) -> pid != self() end))
            |> Broadcast.call_broadcast(messageJsonEncoded)
    end

    def broadcast(messageJsonEncoded) do
        ChatProcs.getAllProcs()
            |> Broadcast.call_broadcast(messageJsonEncoded)
    end
end