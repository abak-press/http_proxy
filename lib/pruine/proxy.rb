# coding: utf-8
require "em-synchrony"

module Pruine
  class Proxy
    def self.start(options, &block)
      puts "Starting Fallbac & Proxy server"

      Pruine.setup
      Cluster.init

      EM.epoll
      EM.synchrony do
        trap("TERM") { stop }
        trap("INT")  { stop }

        EventMachine::start_server(options[:host],
                                   options[:port], Connection, options) do |proxy|

          proxy.process_headers do |headers|
            if headers.has_key?("Vines-User")
              node_uid, node_settings = Pruine.balancer.select(headers["Vines-User"])

              proxy.server(node_uid, node_settings)
              proxy.relay_to_servers(proxy.headers.buffer)
            else
              proxy.close_connection
            end
          end

          proxy.on_data do |data|
            proxy.headers << data

            data
          end

          proxy.instance_eval(&block) if block
        end
      end
    end

    def self.stop
      puts "Terminating Fallbac & Proxy server"

      EM.stop
    end
  end
end