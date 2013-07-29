module Pruine
  # Public: The cluster with nodes
  module Cluster
    extend self

    # Public: The cluster capacity by nodes key
    CAPACITY = "pruine:cluster:capacity".freeze

    # Public: Get list of the nodes
    #
    # Examples
    #
    # Pruine::Cluster.nodes # => {node_0: <Pruine::Node>, node_1: <Pruine::Node>}
    #
    # Returns Hash
    def nodes
      @nodes ||= Hash[nodes_from_settings]
    end

    # Public: Get capacity of the nodes
    #
    # Examples
    #
    # Pruine::Cluster.capacity # => {node_0: 21, node_1: 999}
    #
    # Returns Hash
    def capacity
      Hash[Pruine.redis.hgetall(CAPACITY).map { |n, c| [n.to_sym, c.to_i] }]
    end

    # Public: Increase node capacity by 1
    #
    # node_uid - String the node unique identifier
    #
    # Returns Fixnum
    def touch(node_uid)
      Pruine.redis.hincrby(CAPACITY, node_uid, 1)
    end

    # Public: Prepare cluster balancing information about nodes capacity
    #
    # Returns nothing
    def init
      nodes.each { |node_uid, _| Pruine.redis.hsetnx(CAPACITY, node_uid, 0) }
    end

    private
    def nodes_from_settings
      Pruine.settings.fetch(:nodes).map do |n, settings|
        node_uid = n.to_sym

        [node_uid, settings]
      end
    end
  end
end
