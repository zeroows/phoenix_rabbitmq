defmodule RabbitMQ do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Phoenix.RabbitMQ
      alias Phoenix.RabbitMQConn
      alias Phoenix.RabbitMQConsumer
      alias Phoenix.RabbitMQPub
      alias Phoenix.RabbitMQServer
    end
  end
end
