defmodule Broadcast do
    def call_broadcast(pids, messageJsonEncoded) do
        pids |> Enum.each((fn(pid) -> 
            send(pid, {:broadcast, messageJsonEncoded})
        end))
    end 
end