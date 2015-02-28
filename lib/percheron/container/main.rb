module Percheron
  module Container
    class Main

      extend Forwardable
      extend ConfigDelegator

      def_delegators :container_config, :name, :version

      def_config_item_with_default :container_config, [], :env, :ports, :volumes, :dependant_container_names

      def initialize(config, stack, container_name)
        @config = config
        @stack = stack
        @container_name = container_name
        valid?
        self
      end

      def stop!
        Container::Actions::Stop.new(self).execute!
      rescue Errors::ContainerNotRunning
        $logger.debug "Container '#{name}' is not running"
      end

      def start!
        Container::Actions::Create.new(self).execute! unless exists?
        Container::Actions::Start.new(self).execute!
      end

      def id
        exists? ? info.id[0...12] : 'N/A'
      end

      def image
        '%s:%s' % [ name, version ]
      end

      def dockerfile
        container_config.dockerfile ? Pathname.new(File.expand_path(container_config.dockerfile, config.file_base_path)): nil
      end

      def exposed_ports
        ports.inject({}) do |all, p|
          all[p.split(':')[1]] = {}
          all
        end
      end

      def links
        dependant_container_names.map do |container_name|
          '%s:%s' % [ container_name, container_name ]
        end
      end

      def docker_container
        Docker::Container.get(name)
      rescue Docker::Error::NotFoundError, Excon::Errors::SocketError
        Container::Null.new
      end

      def running?
        exists? && info.State.Running
      end

      def exists?
        !info.empty?
      end

      def valid?
        Validators::Container.new(self).valid?
      end

      protected

        attr_reader :config, :stack, :container_name

        def info
          Hashie::Mash.new(docker_container.info)
        end

        def container_config
          @container_config ||= stack.container_configs[container_name] || Hashie::Mash.new({})
        end

    end
  end
end