defmodule ChatProcs do
    require Logger

    def start do
        {:ok, procsAgent} = Agent.start_link(fn -> %{processes: []} end, name: __MODULE__)
        Logger.info "#{__MODULE__} Agent started #{inspect(procsAgent)}"
    
        procsAgent
    end 

    def addProc(pid) do
        Agent.update(__MODULE__, fn(d) -> 
            %{processes: d.processes ++ [pid]}
        end)
    end

    def removeProc(pid) do
        Agent.update(__MODULE__, fn(d) -> 
            newProcs = Enum.filter(d.processes, fn(p) -> p != pid end)
            %{processes: newProcs}
        end)
    end

    def getAllProcs() do
        Agent.get(__MODULE__, fn(d) -> 
            d.processes
        end)
    end
end