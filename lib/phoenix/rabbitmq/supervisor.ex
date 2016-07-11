defmodule Phoenix.RabbitMQ.Supervisor do
  use Supervisor
  use AMQP
  require Logger

  @host Application.get_env(:phoenix_rabbitmq, :host)
  @port Application.get_env(:phoenix_rabbitmq, :port)
  @username Application.get_env(:phoenix_rabbitmq, :username)
  @password Application.get_env(:phoenix_rabbitmq, :password)
  @virtual_host Application.get_env(:phoenix_rabbitmq, :virtual_host)
  @pool_size Application.get_env(:phoenix_rabbitmq, :pool_size)

  @moduledoc """
  The Supervisor for the RabbitMQ Client

  To use RabbitMQ, simply add it to your Endpoint's config:

  next, add `:phoenix_rabbitmq` to your deps:

      defp deps do
        [
         {:phoenix_rabbitmq, git: "git://github.com/zeroows/phoenix_rabbitmq.git"},
        ...]
      end

  finally, add `:phoenix_rabbitmq` to your applications:

      def application do
        [mod: {MyApp, []},
         applications: [..., :phoenix, :phoenix_rabbitmq],
         ...]
      end

    * `name` - The required name to register the PubSub processes, ie: `MyApp.PubSub`
    * `options` - The optional RabbitMQ options:
      * `host` - The hostname of the broker (defaults to \"localhost\");
      * `port` - The port the broker is listening on (defaults to `5672`);
      * `username` - The name of a user registered with the broker (defaults to \"guest\");
      * `password` - The password of user (defaults to \"guest\");
      * `virtual_host` - The name of a virtual host in the broker (defaults to \"/\");
      * `heartbeat` - The hearbeat interval in seconds (defaults to `0` - turned off);
      * `connection_timeout` - The connection timeout in milliseconds (defaults to `infinity`);
      * `pool_size` - Number of active connections to the broker

  To Test it in iex:

      Phoenix.RabbitMQ.start_link(:test, [username: "rabbitmq", password: "rabbitmq", pool_size: 1])
      Phoenix.RabbitMQ.publish :"Elixir.Phoenix.RabbitMQ.PubPool.test", "test", "", "testing plugin"
  """

  def start_link(name, opts \\ []) do
    supervisor_name = Module.concat(__MODULE__, name)

    config_opts = [
      host: opts[:host] || @host,
      port: opts[:port] || @port,
      username: opts[:username] || @username,
      password: opts[:password] || @password,
      virtual_host: opts[:virtual_host] || @virtual_host,
      pool_size: opts[:pool_size] || @pool_size
    ]

    connection_opts = opts || config_opts
    Supervisor.start_link(__MODULE__, [name, connection_opts], name: supervisor_name)
  end

  def init([name, opts]) do
    conn_pool_name = Module.concat(__MODULE__, ConnPool) |> Module.concat(name)
    pub_pool_name  = Module.concat(__MODULE__, PubPool)  |> Module.concat(name)

    conn_pool_opts = [
      name: {:local, conn_pool_name},
      worker_module: Phoenix.RabbitMQ.Conn,
      size: opts[:pool_size] || 10,
      strategy: :fifo,
      max_overflow: 0
    ]

    pub_pool_opts = [
      name: {:local, pub_pool_name},
      worker_module: Phoenix.RabbitMQ.Publisher,
      size: opts[:pool_size] || @pool_size,
      max_overflow: 0
    ]

    children = [
      :poolboy.child_spec(conn_pool_name, conn_pool_opts, [opts]),
      :poolboy.child_spec(pub_pool_name, pub_pool_opts, conn_pool_name),
      worker(Phoenix.RabbitMQ.Server, [name, conn_pool_name, pub_pool_name, opts])
    ]
    supervise children, strategy: :one_for_one
  end

  def with_conn(pool_name, fun) when is_function(fun, 1) do
    case get_conn(pool_name, 0, @pool_size) do
      {:ok, conn}      -> fun.(conn)
      {:error, reason} -> {:error, reason}
    end
  end

  def publish(pool_name, exchange, routing_key, payload, options \\ []) do
    case get_chan(pool_name, 0, @pool_size) do
      {:ok, chan}      -> Basic.publish(chan, exchange, routing_key, payload, options)
      {:error, reason} -> {:error, reason}
    end
  end

  ## Private 

  defp get_conn(pool_name, retry_count, max_retry_count) do
    case :poolboy.transaction(pool_name, &GenServer.call(&1, :conn)) do
      {:ok, conn}      -> {:ok, conn}
      {:error, _reason} when retry_count < max_retry_count ->
        get_conn(pool_name, retry_count + 1, max_retry_count)
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_chan(pool_name, retry_count, max_retry_count) do
    case :poolboy.transaction(pool_name, &GenServer.call(&1, :chan)) do
      {:ok, chan}      -> {:ok, chan}
      {:error, _reason} when retry_count < max_retry_count ->
        get_chan(pool_name, retry_count + 1, max_retry_count)
      {:error, reason} -> {:error, reason}
    end
  end

end
