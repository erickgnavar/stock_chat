defmodule StockChat.ChatTest do
  use StockChat.DataCase

  alias StockChat.Chat

  describe "messages" do
    alias StockChat.Chat.Message

    @valid_attrs %{content: "some content"}
    @update_attrs %{content: "some updated content"}
    @invalid_attrs %{content: nil}

    setup do
      {:ok, user: user_fixture()}
    end

    def user_fixture do
      user_attrs = %{
        name: "test user",
        username: "test",
        image: "http://localhost/image.png"
      }

      {:ok, user} = StockChat.Auth.create_user(user_attrs)
      user
    end

    def message_fixture(attrs \\ %{}) do
      user = user_fixture()

      {:ok, message} =
        attrs
        |> Map.put(:user_id, user.id)
        |> Enum.into(@valid_attrs)
        |> Chat.create_message()

      message
    end

    test "list_messages/0 returns all messages" do
      message_id = message_fixture().id
      assert [%{id: ^message_id}] = Chat.list_messages()
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Chat.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message", %{user: user} do
      attrs = Map.put(@valid_attrs, :user_id, user.id)
      assert {:ok, %Message{} = message} = Chat.create_message(attrs)
      assert message.content == "some content"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, %Message{} = message} = Chat.update_message(message, @update_attrs)
      assert message.content == "some updated content"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_message(message, @invalid_attrs)
      assert message == Chat.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chat.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chat.change_message(message)
    end
  end
end
