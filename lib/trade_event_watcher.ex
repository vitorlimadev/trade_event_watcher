defmodule TradeEventWatcher do
  @moduledoc """
  TradeEventWatcher allows you to see trade events in real time, currently only within Binance.

  You can start streaming trade events with start/3.
  To stop the stream, use stop/0.
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
  @spec start(first_coin :: binary(), second_coin :: binary(), exchange :: atom()) ::
          {:ok, :new_stream_started} | {:error, :symbol_not_found}
  def start(first_coin, second_coin, exchange \\ :binance) do
    streaming_server = stream_trade_events(first_coin, second_coin, exchange)

    case streaming_server do
      {:ok, pid} -> start_or_update_agent(pid)
      error -> error
    end
  end

  @doc """
  Stops the current trade events stream.
  """
  @spec stop() :: {:ok, :stream_stopped} | :no_stream_started
  def stop do
    pid = get_current_stream_process()

    case pid do
      {:error, :agent_not_started} ->
        :no_stream_started

      :no_stream_started ->
        :no_stream_started

      pid ->
        Process.exit(pid, :kill)
        TradeEventWatcher.StartedStreamsWatcher.clear()

        {:ok, :stream_stopped}
    end
  end

  @spec get_current_stream_process() :: pid() | :no_stream_started | {:error, :agent_not_started}
  defp get_current_stream_process do
    TradeEventWatcher.StartedStreamsWatcher.get()
  end

  @spec stream_trade_events(first_coin :: binary(), second_coin :: binary(), exchange :: atom()) ::
          {:ok, pid} | {:error, :symbol_not_found}
  defp stream_trade_events(first_coin, second_coin, :binance) do
    Exchanges.Binance.stream_trade_events(first_coin, second_coin)
  end

  @spec start_or_update_agent(pid()) :: {:ok, :new_stream_started} | {:ok, :stream_updated}
  defp start_or_update_agent(new_stream_pid) when is_pid(new_stream_pid) do
    possible_agent_pid = get_current_stream_process()

    case possible_agent_pid do
      {:error, :agent_not_started} ->
        TradeEventWatcher.StartedStreamsWatcher.start(new_stream_pid)

        {:ok, :new_stream_started}

      _pid ->
        TradeEventWatcher.StartedStreamsWatcher.update(new_stream_pid)

        {:ok, :stream_updated}
    end
  end
end
