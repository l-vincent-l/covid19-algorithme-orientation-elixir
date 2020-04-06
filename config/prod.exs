use Mix.Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :covid19_questionnaire, Covid19QuestionnaireWeb.Endpoint,
  http: [
    port: {:system, "PORT"},
    transport_options: [
      {:num_acceptors, 2500},
      {:max_connections, :infinity}
    ],
    protocol_options: [{:max_keepalive, 20_000_000}, {:timeout, 2000}]
  ],
  url: [scheme: "https", host: System.get_env("PROXY_HOST"), port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure PostgreSQL
config :covid19_questionnaire, Covid19Questionnaire.Data.Repo,
  hostname: System.get_env("PG_HOSTNAME"),
  port: System.get_env("PG_PORT"),
  username: System.get_env("PG_USER"),
  password: System.get_env("PG_PASSWORD"),
  database: System.get_env("PG_DATABASE"),
  pool_size: System.get_env("PG_POOL_SIZE") |> String.to_integer(),
  ssl: true

# Configure CORS
config :cors_plug,
  origin: ["http://localhost:3000"],
  headers: ["Accept", "Content-Type", "Origin", "X-CSRF-Token", "X-Token"],
  methods: ["POST", "OPTIONS"]

# Configure Connive
config :covid19_questionnaire, Covid19QuestionnaireWeb.Plugs.Connive,
  whitelist: ["127.0.0.0/8" | System.get_env("WHITELIST") |> String.split(",")]

# Do not print debug messages in production
config :logger,
  level: :error,
  compile_time_purge_matching: [[application: :remote_ip], [level_lower_than: :error]]

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :covid19_questionnaire, Covid19QuestionnaireWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [
#         port: 443,
#         cipher_suite: :strong,
#         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#         certfile: System.get_env("SOME_APP_SSL_CERT_PATH"),
#         transport_options: [socket_opts: [:inet6]]
#       ]
#
# The `cipher_suite` is set to `:strong` to support only the
# latest and more secure SSL ciphers. This means old browsers
# and clients may not be supported. You can set it to
# `:compatible` for wider support.
#
# `:keyfile` and `:certfile` expect an absolute path to the key
# and cert in disk or a relative path inside priv, for example
# "priv/ssl/server.key". For all supported SSL configuration
# options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
#
# We also recommend setting `force_ssl` in your endpoint, ensuring
# no data is ever sent via http, always redirecting to https:
#
#     config :covid19_questionnaire, Covid19QuestionnaireWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# Finally import the config/prod.secret.exs which loads secrets
# and configuration from environment variables.
# import_config "prod.secret.exs"
