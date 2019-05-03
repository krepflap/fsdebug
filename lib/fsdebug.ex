defmodule Fsdebug do
  @moduledoc """
  Documentation for Fsdebug.
  """

  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(_args) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: ["/tmp"])
    FileSystem.subscribe(watcher_pid)
    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid}=state) do
    IO.puts "Live reload: #{Path.relative_to_cwd(path)}"
    {:noreply, state}
  end
end
