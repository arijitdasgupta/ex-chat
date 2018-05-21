defmodule Mappers do
    def createMessage(messageText, username) do
        {:ok, encodedJson} = Poison.encode(%{
            sender: username,
            message: messageText
        })

        encodedJson
    end

    def createAdminMessage(message) do
        createMessage(message, "admin")
    end
end