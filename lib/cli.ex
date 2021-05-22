defmodule TradeEventWatcher.CLI do
  def main(args) do
    IO.puts("Trade Event Watcher CLI - v0.1")

    args
    |> parse_args()
    |> execute_command()
  end

  defp parse_args(args) do
    parsed_args =
      OptionParser.parse(args,
        switches: [help: :boolean, output: :string],
        aliases: [h: :help, o: :output]
      )

    case parsed_args do
      {[help: true], _, _} -> :help
      {_, [], _} -> :help
      args_list -> args_list
    end
  end

  defp execute_command({_, ["start", first_coin, second_coin], _}) do
    stream = TradeEventWatcher.start(first_coin, second_coin)

    case stream do
      {:ok, :new_stream_started} ->
        IO.puts("""
          New stream started:
        """)

        IO.gets("")

      {:error, :symbol_not_found} ->
        IO.puts("Symbol not found. Please use valid coin symbols. Ex: start btc eth")
    end
  end

  defp execute_command(:help) do
    IO.puts("""
    \ntrade_event_watcher <first_coin> <second_coin>

    To monitor BTC_USDT events, run:
      trade_event_watcher start btc usdt
    """)
  end
end
