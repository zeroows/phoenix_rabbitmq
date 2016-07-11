defmodule Phoenix.RabbitMQ.Server do
  use GenServer
  use AMQP
  alias Phoenix.RabbitMQ.Supervisor
  require Logger

  ## ------- API

  def publish(exchange, routing_key, payload, options \\ []) do
    GenServer.call({:publish, exchange, routing_key, payload}, state)
  end

  ## ------- Server

  @moduledoc """
  See `Phoenix.RabbitMQ.Supervisor` for details and configuration options.
  """

  def start_link(server_name, conn_pool_name, pub_pool_name, opts) do
    GenServer.start_link(__MODULE__, [server_name, conn_pool_name, pub_pool_name, opts], name: server_name)
  end

  @doc """
  Initializes the server.

  """
  def init([server_name, conn_pool_name, pub_pool_name, opts]) do
    Process.flag(:trap_exit, true)
    {:ok, %{cons: HashDict.new,
            subs: HashDict.new,
            conn_pool_name: conn_pool_name,
            pub_pool_name: pub_pool_name,
            exchange: rabbitmq_namespace(server_name),
            node_ref: :crypto.strong_rand_bytes(16),
            opts: opts}}
  end
  
  def handle_call({:publish, exchange, routing_key, msg}, state) do
    case Supervisor.publish(state.pub_pool_name,
                          exchange,
                          routing_key,
                          :erlang.term_to_binary({state.node_ref, msg}),
                          content_type: "application/x-erlang-binary") do
      :ok              -> {:reply, :ok, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:DOWN, _ref, :process, pid,  _reason}, state) do
    state =
      case Dict.fetch(state.cons, pid) do
        {:ok, {topic, sub_pid}} ->
          %{state | cons: Dict.delete(state.cons, pid),
                    subs: delete_subscriber(state.subs, sub_pid, topic)}
        :error ->
          state
      end
    {:noreply, state}
  end

  def handle_info({:EXIT, _pid, _reason}, state) do
    # Ignore subscriber exiting; the Consumer will monitor it
    {:noreply, state}
  end

  defp rabbitmq_namespace(server_name) do
    case Atom.to_string(server_name) do
      "Elixir." <> name -> name
      name              -> name
    end
  end

end