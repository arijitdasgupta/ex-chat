defmodule Broadcast do
    def call_broadcast(pids, messageJsonEncoded) do
        History.addToHistory(messageJsonEncoded)
        pids |> Enum.each((fn(pid) -> 
            ChatProcs.addMessage(pid, messageJsonEncoded)
            send(pid, {:broadcast, messageJsonEncoded})
        end))
    end
end