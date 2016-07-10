defmodule RabbitMQ do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Phoenix.RabbitMQ.RabbitMQ
      alias Phoenix.RabbitMQ.Conn
      alias Phoenix.RabbitMQ.Consumer
      alias Phoenix.RabbitMQ.Publisher
      alias Phoenix.RabbitMQ.Server
    end
  end
end
