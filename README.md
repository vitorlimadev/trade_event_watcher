# TradeEventWatcher

An application to retrieve trade events in real time from exchanges. Currently only supporting Binance.

## Installation

Inside of the  project's folder, run:

```sh
mix deps.get
```

```sh
iex -S mix
```

Inside iex, you can start the application with:

```elixir
TradeEventWatcher.start("btc", "usdt") # To watch BTC/USDT events within Binance.
```
