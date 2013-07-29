# coding: utf-8

module Pruine
  # Public: The entrys to nodes mapper
  module Mapper
    extend self

    # Public: Redis key for mapping entrys to nodes
    MAP = "pruine:mapping".freeze

    # Public: Get unique identifier for entry
    #
    # entry - String the entry name
    #
    # Returns String
    def entry_uid(entry)
      Digest::SHA1.hexdigest(entry)
    end

    # Public: Attach entry to node
    #
    # entry_uid - String the entry unique identifier
    # node_uid - String the node unique identifier
    #
    # Returns boolean
    def attach(entry_uid, node_uid)
      Pruine.redis.hsetnx(MAP, entry_uid, node_uid)
    end

    # Public: Find node unique identifier where entry is attached
    #
    # entry_uid - String the entry unique identifier
    #
    # Returns Symbol
    # Returns NilClass
    def locate(entry_uid)
      node_uid = Pruine.redis.hget(MAP, entry_uid)
      node_uid.nil? ? nil : node_uid.to_sym
    end
  end
end
