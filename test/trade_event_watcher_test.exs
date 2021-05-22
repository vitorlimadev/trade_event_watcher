defmodule TradeEventWatcherTest do
  use ExUnit.Case

  describe "start/3" do
    test "starts watcher given correct coin symbols" do
      assert {:ok, :new_stream_started} = TradeEventWatcher.start("btc", "brl")
    end

    test "fails if invalid coin symbols are given" do
      assert {:error, :symbol_not_found} = TradeEventWatcher.start("its", "invalid")
    end

    test "updates an already started stream" do
      TradeEventWatcher.start("btc", "brl")

      assert {:ok, :stream_updated} = TradeEventWatcher.start("eth", "brl")
    end

    test "starts a new stream after stopping one" do
      TradeEventWatcher.start("btc", "brl")

      TradeEventWatcher.stop()

      assert {:ok, :stream_updated} = TradeEventWatcher.start("eth", "brl")
    end
  end

  describe "stop/0" do
    test "stops a running stream" do
      TradeEventWatcher.start("btc", "brl")

      assert {:ok, :stream_stopped} = TradeEventWatcher.stop()
    end
  end
end
