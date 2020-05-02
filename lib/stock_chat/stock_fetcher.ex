defmodule StockChat.StockFetcher do
  @moduledoc false
  require Logger

  @spec get_share_data(String.t()) :: {:ok, map} | {:error, String.t()}
  def get_share_data(stock_code) do
    url = "https://stooq.com/q/l/?s=#{stock_code}.us&f=sd2t2ohlcv&h&e=csv"
    Logger.info("Requesting data: #{url}")

    with {:ok, %{status_code: 200, body: body}} <- Mojito.get(url) do
      case String.split(body, "\n") do
        [headers, content, _] ->
          headers =
            headers
            |> String.trim()
            |> String.replace("\r", "")
            |> String.split(",")

          content =
            content
            |> String.trim()
            |> String.replace("\r", "")
            |> String.split(",")

          {:ok, Map.new(Enum.zip(headers, content))}

        _ ->
          {:error, "Can't fetch data for #{stock_code}"}
      end
    else
      error ->
        Logger.error("Error while fetching data for #{stock_code}: #{inspect(error)}")
        {:error, "Can't fetch data for #{stock_code}"}
    end
  end
end
