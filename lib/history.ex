defmodule History do
    require Logger

    def start do
        {:ok, procsAgent} = Agent.start_link(fn -> %{history: []} end, name: __MODULE__)
        Logger.info "#{__MODULE__} Agent started #{inspect(procsAgent)}"
    
        procsAgent
    end

    def addToHistory(message) do
        Agent.update(__MODULE__, fn(d) -> d end)
    end

    def getHistory do
        Agent.get(__MODULE__, fn(d) -> d.history end)
    end
end