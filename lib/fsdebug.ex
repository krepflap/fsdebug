defmodule Fsdebug do
  @moduledoc """
  Documentation for Fsdebug.
  """
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(_args) do
    bash_args = ['-c', '#{executable_path()} $0 $@ & PID=$!; read a; kill -KILL $PID']
    port_args = ['-e', 'modify', '--quiet', '-m', '-r', '/tmp']
    port = Port.open(
      {:spawn_executable, '/bin/sh'},
      [:stream, :exit_status, {:line, 16384}, {:args, bash_args ++ port_args}, {:cd, System.tmp_dir!()}]
    )
    worker_pid = Process.link(port)
    Process.flag(:trap_exit, true)
    {:ok, %{port: port, worker_pid: worker_pid}}
  end

  def handle_info({port, event}, %{port: port}=state) do
    IO.inspect(event)
    {:noreply, state}
  end

  defp executable_path() do
    System.find_executable("inotifywait")
  end
end
