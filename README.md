Phoenix - RabbitMQ Adapter
=================================

RabbitMQ client for the Phoenix framework. The Supervisor for the RabbitMQ Client. To use RabbitMQ, simply add it to your Endpoint's config:
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

###### `name` - The required name to register the PoolName processes, ie: `PoolName`
###### `options` - The optional RabbitMQ options:
  * `host` - The hostname of the broker (defaults to \"localhost\");
  * `port` - The port the broker is listening on (defaults to `5672`);
  * `username` - The name of a user registered with the broker (defaults to \"guest\");
  * `password` - The password of user (defaults to \"guest\");
  * `virtual_host` - The name of a virtual host in the broker (defaults to \"/\");
  * `heartbeat` - The hearbeat interval in seconds (defaults to `0` - turned off);
  * `connection_timeout` - The connection timeout in milliseconds (defaults to `infinity`);
  * `pool_size` - Number of active connections to the broker

To Test it in iex:

      {:ok, pid} = PhoenixRabbitmq.start_link(:test, [username: "rabbitmq", password: "rabbitmq", pool_size: 1])
      PhoenixRabbitmq.Server.publish "test", "", "testing plugin"   
