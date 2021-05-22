defmodule TradeEventWatcher.StartedStreamsWatcher do
  @initial_state %{
    watcher_pid: nil
  }

  @doc """
  Starts the agent that whatches the started streams of the TradeWatcher.
  It requires the PID of the process streaming the trade events.
  It is crucial the streaming event process is not linked to the main process, otherwise when the process is killed, it can crash the application.

  This module is only responsible to track the PIDs of the started streams.
  """
  def start(pid) do
    Agent.start_link(fn -> %{watcher_pid: pid} end, name: __MODULE__)
  end

  @doc """
  Returns the current agent state.
  """
  def get do
    try do
      pid = Agent.get(__MODULE__, & &1.watcher_pid)

      case pid do
        nil -> :no_stream_started
        pid -> pid
      end
    catch
      :exit, _ -> {:error, :agent_not_started}
    end
  end

  @doc """
  Updates the current stream.
  """
  def update(pid) do
    Agent.update(__MODULE__, fn state ->
      %{state | watcher_pid: pid}
    end)
  end

  @doc """
  Clears the agent state.
  """
  def clear do
    Agent.update(__MODULE__, fn _state -> @initial_state end)
  end
end
