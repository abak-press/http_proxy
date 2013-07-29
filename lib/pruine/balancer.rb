# coding: utf-8

module Pruine
  # Public: The balancer of incoming requests
  module Balancer
    extend self

    # Public: Select a vacant node for entry attaching
    #
    # entry - String the entry key (given from HTTP-headers)
    #
    # Examples
    #
    # Pruine::Balancer.select("registered@examples.com") # => <Node ...>
    # Pruine::Balancer.select("unregistered@examples.com") do |node|
    #   p node
    # end
    #
    # Returns Node
    def select(entry)
      entry_uid = Mapper.entry_uid(entry)

      unless_found(entry_uid) do
        node_uid = vacant_node_uid

        Mapper.attach(entry_uid, node_uid)
        Cluster.touch(node_uid)

        [node_uid, Cluster.nodes[node_uid]]
      end
    end

    # Public: Find vacant node unique identifier
    # Uses node capacity as vacant mark
    #
    # Returns String
    def vacant_node_uid
      Cluster.capacity.min_by { |_, cap| cap }.first
    end

    # Public: Return node for entry or yield given block
    # The block of code SHOULD return node as execution result
    #
    # entry_uid - String the entry unique identifier
    #
    # Yields
    # Returns Node
    def unless_found(entry_uid)
      node_uid = Mapper.locate(entry_uid)

      return yield if node_uid.nil?

      [node_uid, Cluster.nodes[node_uid]]
    end
  end
end
