defmodule StockChatWeb.PageLive do
  use StockChatWeb, :live_view
  alias StockChat.Chat
  alias StockChat.Auth

  @topic "chat"

  @impl true
  def mount(_params, session, socket) do
    current_user_id = Map.get(session, "current_user_id")
    if connected?(socket), do: subscribe()

    user =
      if current_user_id do
        Auth.get_user!(current_user_id)
      end

    {:ok, assign(socket, current_user: user, message_text: "", messages: Chat.list_messages())}
  end

  @impl true
  def handle_event("post_message", %{"message_text" => message_text}, socket) do
    if String.length(message_text) == 0 do
      {:noreply,
       socket
       |> put_flash(:error, "blank message")}
    else
      message = create_message(socket.assigns.current_user.id, message_text)
      broadcast(message, socket.assigns.current_user)

      {:noreply,
       socket
       |> put_flash(:info, "Post created")
       |> assign(message_text: "")}
    end
  end

  @impl true
  def handle_info({:message_created, message}, socket) do
    {:noreply, update(socket, :messages, fn messages -> [message | messages] end)}
  end

  defp create_message(user_id, content) do
    {:ok, message} =
      Chat.create_message(%{
        user_id: user_id,
        content: content
      })

    message
  end

  defp subscribe do
    Phoenix.PubSub.subscribe(StockChat.PubSub, @topic)
  end

  defp broadcast(message, user) do
    Phoenix.PubSub.broadcast(
      StockChat.PubSub,
      @topic,
      {:message_created, Map.put(message, :user, user)}
    )
  end
end
