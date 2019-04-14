require 'sysmoon/ipc/client'
require 'sysmoon/log'
require 'sysmoon/config'

module Sysmoon
  class Discover

    DISCOVERY_REQ = 'SYSMOON'.freeze
    DISCOVERY_ANS = 'DISCOVERED'.freeze

    def initialize
      # Starting thread that sends and accepts UDP-packages.
      # This is how a node can say that it's online
      @sysmoon = IPC::Client.new(
        port: :sysmoond
      )
      @port = Config[:sync]['port']
      @listen_sock = UDPSocket.new
      @listen_sock.bind('0.0.0.0', @port)
      @listen_thread = Thread.new { listen_discovery }
    end

    # Sending UDP message on broadcast
    # Discovering our nodes
    def send_discovery_message(ip='<broadcast>', message=DISCOVERY_REQ)
      udp_sock = UDPSocket.new
      if ip == '<broadcast>'
        udp_sock.setsockopt(
          Socket::SOL_SOCKET, Socket::SO_BROADCAST, true
        )
      end
      udp_sock.send(message, 0, ip, @port)
      udp_sock.close
    end

    private

    def listen_discovery
      loop do
        data, recvdata = @listen_sock.recvfrom(1024)
        node_ip = recvdata[-1]

        next if Utils::local_ip?(node_ip)

        if [DISCOVERY_REQ, DISCOVERY_ANS].include? data
          # Push new node_ip to trigger
          @sysmoon.add_remote_node(node_ip)
        end

        case data
        when DISCOVERY_REQ
          Log.info("Discovery host found: #{node_ip}")
          send_discovery_message(node_ip, DISCOVERY_ANS)
        when DISCOVERY_ANS
          Log.info("Discovery host answered: #{node_ip}")
        end
      end
    end
  end

end
