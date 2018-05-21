defmodule ChatProcs do
    require Logger

    def start do
        {:ok, procsAgent} = Agent.start_link(fn -> %{processes: []} end, name: __MODULE__)
        Logger.info "#{__MODULE__} Agent started #{inspect(procsAgent)}"
    
        procsAgent
    end 

    def addProc(pid) do
        Agent.update(__MODULE__, fn(d) -> 
            %{processes: d.processes ++ [%{
                pid: pid,
                username: nil
            }]}
        end)
    end

    def getUser(pid) do
        Agent.get(__MODULE__, fn(d) -> 
            case Enum.filter(d.processes, (&(&1.pid == pid))) do
                [procObj | _] -> 
                    %{username: user} = procObj
                    user
                [] ->
                    nil
            end
        end)
    end

    def setUser(pid, username) do
        Agent.update(__MODULE__, fn(d) ->
            [procObj | _] = Enum.filter(d.processes, (&(&1.pid == pid)))
            remainingProcs = Enum.filter(d.processes, (&(&1.pid != pid)))
            totalProcs = remainingProcs ++ [%{
                pid: procObj.pid,
                username: username
            }]

            %{processes: totalProcs}
        end)
    end

    def removeProc(pid) do
        Agent.update(__MODULE__, fn(d) -> 
            newProcs = Enum.filter(d.processes, (&(&1.pid != pid)))
            %{processes: newProcs}
        end)
    end

    def getAllProcs() do
        Agent.get(__MODULE__, fn(d) -> 
            Enum.map(d.processes, (&(&1.pid)))
        end)
    end
end