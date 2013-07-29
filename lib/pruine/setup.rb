module Pruine
  extend self

  # Public: Proxy server defaults
  DEFAULTS = {
    nodes: {},
    redis: {host: "127.0.0.1", port: 6379},
    balancer: Balancer
  }.freeze

  # Public: The settings of the balancer server
  #
  # Returns Hash
  def settings
    @settings
  end

  # Public: The redis client
  #
  # Returns Redis
  def redis
    @redis ||= Redis.new(settings[:redis])
  end

  # Public: The proxy balancer
  #
  # Returns [Module|Class]
  def balancer
    @balancer ||= settings[:balancer]
  end

  # Public: Setup user-defined or default options for redis & fallback servers
  #
  # options - Hash the config for all (default: empty hash)
  #
  # Returns nothing
  def setup(options = {})
    @settings ||= DEFAULTS.dup
    @settings.merge!(options)
  end

  # Public: Setup redis server options
  #
  # options - Hash the redis connection options
  #           :host - String the redis server host
  #           :port - [String|Fixnum] the redis server port
  #
  # Returns nothing
  def setup_redis(options)
    setup(redis: options)
  end

  # Public: Setup nodes for cluster
  #
  # options - Hash the nodes list ({node_name => node_options})
  #           Available node options are
  #           :host - String the node host
  #           :port - [String|Fixnum] the node port
  #           :relay_client - boolean the flag not to process response from node
  #
  # Returns nothing
  def setup_nodes(options)
    setup(nodes: options)
  end

  # Public: Setup balancer class/module
  #
  # balancer - [Class|Module] the balancer for vines
  #
  # Returns nothing
  def setup_balancer(balancer)
    raise TypeError,
      "The balancer class/module should respond to select method" unless balancer.respond_to?(:select)

    setup(balancer: balancer)
  end
end
