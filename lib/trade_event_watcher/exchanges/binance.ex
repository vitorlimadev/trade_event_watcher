defmodule TradeEventWatcher.Exchanges.Binance do
  @moduledoc """
  Binance's Exchange entity.
  This module encapsulates one function to be used: stream_trade_events/2.
  """
  use WebSockex

  alias Binance, as: BinanceAPI

  @stream_endpoint "wss://stream.binance.com:9443/ws/"

  @doc """
  Starts Binance's Websocket trade event streamer.
  """
  @spec stream_trade_events(first_coin :: String.t(), second_coin :: String.t()) ::
          {:ok, pid} | {:error, :symbol_not_found}
  def stream_trade_events(first_coin, second_coin) do
    with {:ok, uppercase_symbol} <-
           BinanceAPI.find_symbol(%BinanceAPI.TradePair{
             from: first_coin,
             to: second_coin
           }),
         symbol <- String.downcase(uppercase_symbol) do
      WebSockex.start(
        "#{@stream_endpoint}#{symbol}@trade",
        __MODULE__,
        []
      )
    else
      err ->
        err
    end
  end

  @doc """
  Used internally by WebSockex to display data.
  Maps Binance's trade events to a readable console log.
  """
  def handle_frame({_type, msg}, state) do
    case Jason.decode(msg) do
      {:ok, event} -> handle_event(event, state)
      {:error, _} -> throw("Unable to parse message.")
    end

    {:ok, state}
  end

  defp handle_event(%{"e" => "trade"} = event, _state) do
    trade_event = %TradeEventWatcher.Binance.TradeEvent{
      # event_type: event["e"],
      # event_time: event["E"],
      symbol: event["s"],
      # trade_id: event["t"],
      price: event["p"],
      quantity: event["q"],
      # buyer_order_id: event["b"],
      # seller_order_id: event["a"],
      trade_time: event["T"]
      # buyer_market_maker: event["m"]
    }

    IO.inspect(trade_event)
  end
end
