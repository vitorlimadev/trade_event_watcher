defmodule TradeEventWatcher.Exchanges.Binance do
  @doc """
  Binance's Websocket trade event streamer.
  """

  use WebSockex

  alias Binance, as: BinanceAPI

  @stream_endpoint "wss://stream.binance.com:9443/ws/"

  def stream_trade_events(first_coin, second_coin) do
    with {:ok, uppercase_symbol} <-
           BinanceAPI.find_symbol(%BinanceAPI.TradePair{
             from: first_coin,
             to: second_coin
           }),
         symbol <- String.downcase(uppercase_symbol) do
      WebSockex.start_link(
        "#{@stream_endpoint}#{symbol}@trade",
        __MODULE__,
        []
      )
    else
      {:error, :symbol_not_found} ->
        IO.puts("Invalid coin symbols. Please use valid coin symbols. Ex: \"BTC\" and \"USDT\".")

        {:error, :symbol_not_found}

      err ->
        err
    end
  end

  def handle_frame({_type, msg}, state) do
    case Jason.decode(msg) do
      {:ok, event} -> handle_event(event, state)
      {:error, _} -> throw("Unable to parse message.")
    end

    {:ok, state}
  end

  defp handle_event(%{"e" => "trade"} = event, _state) do
    trade_event = %TradeEventWatcher.Binance.TradeEvent{
      event_type: event["e"],
      event_time: event["E"],
      symbol: event["s"],
      trade_id: event["t"],
      price: event["p"],
      quantity: event["q"],
      buyer_order_id: event["b"],
      seller_order_id: event["a"],
      trade_time: event["T"],
      buyer_market_maker: event["m"]
    }

    IO.inspect(trade_event, label: "Trade event recieved")
  end
end
