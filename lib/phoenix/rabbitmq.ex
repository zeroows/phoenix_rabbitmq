defmodule Phoenix.RabbitMQ do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Phoenix.RabbitMQ.Supervisor
      alias Phoenix.RabbitMQ.Server
  #     # alias Phoenix.RabbitMQ.Conn
  #     # alias Phoenix.RabbitMQ.Consumer
  #     # alias Phoenix.RabbitMQ.Publisher
  #     # unquote(config(opts))
    end
  end

  # defp config(opts) do
  #   quote do
  #     @otp_app unquote(opts)[:otp_app] || raise "endpoint expects :otp_app to be given"
  #   end
  # end
end
