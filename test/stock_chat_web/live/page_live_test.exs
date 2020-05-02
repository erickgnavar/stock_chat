defmodule StockChatWeb.PageLiveTest do
  use StockChatWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, _page_live, _disconnected_html} = live(conn, "/")
  end
end
