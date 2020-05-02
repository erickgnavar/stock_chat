defmodule StockChatWeb.AuthController do
  @moduledoc """
  Controller for authentication process and to handle callbacks for google auth provider.
  """
  use StockChatWeb, :controller

  alias StockChat.Auth

  plug(Ueberauth)

  @doc """
  Receive info about the logged user after the google login is made.
  This handles both cases success and failure.
  """
  @spec callback(Plug.Conn.t(), map) :: Plug.Conn.t()
  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    error_message =
      failure.errors
      |> Enum.map(&Map.get(&1, :message))
      |> Enum.join(",")

    conn
    |> put_flash(:error, error_message)
    |> redirect(to: Routes.auth_path(conn, :login))
  end

  def callback(conn, _params) do
    info = conn.assigns.ueberauth_auth.info

    {:ok, user} = create_or_get_from_auth_info(info)

    conn
    |> put_flash(:info, "You have been logged in!")
    |> put_session(:current_user_id, user.id)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  @spec logout(Plug.Conn.t(), map) :: Plug.Conn.t()
  def logout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "You have been logged out!")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  @spec create_or_get_from_auth_info(map) :: {:ok, map}
  defp create_or_get_from_auth_info(%{nickname: username} = info) do
    case Auth.get_user_by_username(username) do
      nil ->
        create_user(info)

      user ->
        {:ok, user}
    end
  end

  @spec create_user(map) :: {:ok, struct}
  defp create_user(info) do
    attrs = %{
      name: info.name,
      image: info.image,
      username: info.nickname
    }

    Auth.create_user(attrs)
  end
end
