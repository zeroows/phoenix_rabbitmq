defmodule PhoenixRabbitmq.Mixfile do
  use Mix.Project

  def project do
    [app: :phoenix_rabbitmq,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package,
     description: description,
     source_url: "https://github.com/zeroows/phoenix_rabbitmq",
     docs: [readme: "README.md", main: "README"]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :amqp, :poolboy],
     mod: {PhoenixRabbitmq, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
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
