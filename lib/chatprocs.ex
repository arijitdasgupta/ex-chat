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
                username: nil,
                messages: []
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

    defp findAndPluck(pid, dataObj) do
        [procObj | _] = Enum.filter(dataObj.processes, (&(&1.pid == pid)))
        remainingProcs = Enum.filter(dataObj.processes, (&(&1.pid != pid)))

        {procObj, remainingProcs}
    end

    defp setProcObjects(pid, cb) do
        Agent.update(__MODULE__, fn(d) -> 
            {procObj, remainingProcs} = findAndPluck(pid, d)
            procObj = cb.(procObj)
            allProcs = remainingProcs ++ [procObj]

            %{processes: allProcs}
        end)
    end

    def addMessage(pid, message) do
        setProcObjects(pid, fn (procObj) -> 
            messages = procObj.messages ++ [message]
            %{procObj | messages: messages}
        end)
    end

    def addMessages(pid, messages) do
        setProcObjects(pid, fn(procObj) ->
            messages = procObj.messages ++ messages
            %{procObj | messages: messages}
        end)
    end

    def setUser(pid, username) do
        setProcObjects(pid, fn(procObj) -> 
            %{procObj | username: username}
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