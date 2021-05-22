defmodule TradeEventWatcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :trade_event_watcher,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def escript do
    [main_module: TradeEventWatcher.CLI, embed_elixir: true]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {TradeEventWatcher.Application, []}
    ]
  end

  defp deps do
    [
      {:websockex, "~> 0.4.3"},
      {:jason, "~> 1.2"},
      {:binance, "~> 0.9.0"}
    ]
  end
end
