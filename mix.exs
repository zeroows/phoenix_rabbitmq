defmodule Phoenix.RabbitMQ.Mixfile do
  use Mix.Project

  def project do
    [app: :phoenix_rabbitmq,
     version: "0.0.1",
     elixir: "~> 1.0",
     description: description,
     package: package,
     source_url: "https://github.com/zeroows/phoenix_rabbitmq",
     deps: deps,
     docs: [readme: "README.md", main: "README"]]
  end

  def application do
    [applications: [:logger, :amqp, :poolboy]]
  end

  defp deps do
    [{:poolboy, "~> 1.5"},
     {:amqp, "~> 0.1.4"}]
  end

  defp description do
    """
    RabbitMQ client for the Phoenix framework.
    """
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     contributors: ["Abdulrhman Alkhodiry"],
     maintainers: ["Abdulrhman Alkhodiry <zeroows@gmail.com>"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/zeroows/phoenix_rabbitmq"}]
  end
end
