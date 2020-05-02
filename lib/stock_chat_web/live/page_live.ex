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
      capture = Regex.named_captures(~r/\/stock=(?<code>\w+)/, message_text)

      unless is_nil(capture) do
        Task.Supervisor.start_child(
          StockChat.StockFetcherSupervisor,
          __MODULE__,
          :process_stock_request,
          [Map.get(capture, "code")]
        )
      end

      create_message(socket.assigns.current_user, message_text)

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

  def process_stock_request(code) do
    text =
      case StockChat.StockFetcher.get_share_data(code) do
        {:ok, data} ->
          %{
            "High" => value,
            "Symbol" => symbol
          } = data

          "#{symbol} quote $#{value} per share"

        {:error, reason} ->
          reason
      end

    bot = get_bot_user()
    create_message(bot, text)
  end

  defp get_bot_user do
    case Auth.get_user_by_username("bot") do
      nil ->
        attrs = %{
          username: "bot",
          name: "Bot",
          image:
            "https://cdn2.iconfinder.com/data/icons/botcons/100/android-bot-round-mag-ghost-virus-light-512.png"
        }

        {:ok, user} = Auth.create_user(attrs)
        user

      user ->
        user
    end
  end

  defp create_message(user, content) do
    {:ok, message} =
      Chat.create_message(%{
        user_id: user.id,
        content: content
      })

    broadcast(message, user)
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
