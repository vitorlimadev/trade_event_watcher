defmodule TradeEventWatcher do
  @moduledoc """
  TradeEventWatcher allows you to see trade events in real time, currently only within Binance.
  """

  alias TradeEventWatcher.Exchanges

  @doc """
  Returns trade events in real time.

  ## Examples
      iex> TradeEventWatcher.start("btc", "BRL")
      Returns BTC/BRL trade events from binance by default.

      iex> TradeEventWatcher.start("DOGE", "usdt", :binance)
      Returns DOGE/USDT trade events from binance explicitly, other exchanges will be implemented in the future.
  """
  @spec start(first_coin :: binary(), second_coin :: binary(), exchange :: atom()) :: any()
  def start(first_coin, second_coin, exchange \\ :binance) do
    stream_trade_events(first_coin, second_coin, exchange)
  end

  defp stream_trade_events(first_coin, second_coin, :binance) do
    Exchanges.Binance.stream_trade_events(first_coin, second_coin)
  end
end
