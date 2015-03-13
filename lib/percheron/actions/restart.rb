module Percheron
  module Actions
    class Restart

      include Base

      def initialize(container)
        @container = container
      end

      def execute!
        stop!
        start!
        container
      end

      private

        attr_reader :container

        def stop!
          Stop.new(container).execute!
        end

        def start!
          Start.new(container, container.dependant_containers.values).execute!
        end

    end
  end
end