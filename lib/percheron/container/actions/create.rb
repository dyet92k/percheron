module Percheron
  module Container
    module Actions
      class Create

        def initialize(container)
          @container = container
        end

        def execute!
          Container::Actions::Build.new(container).execute! unless image_exists?
          $logger.debug "Creating '#{container.name}'"
          Docker::Container.create(create_opts)
        end

        private

          attr_reader :container

          def create_opts
            {
              'name'          => container.name,
              'Image'         => container.image,
              'Hostname'      => container.name,
              'Env'           => container.env,
              'ExposedPorts'  => container.exposed_ports,
              'VolumesFrom'   => container.volumes
            }
          end

          def image_exists?
            Docker::Image.exist?(container.image)
          end

      end
    end
  end
end