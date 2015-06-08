module Percheron
  module Commands
    class Shell < Abstract

      parameter('STACK_NAME', 'stack name', required: true)
      parameter('UNIT_NAME', 'unit name', required: true)
      option('--command', 'COMMAND', 'command', default: '/bin/sh')

      def execute
        super
        stack.run!(unit_name, interactive: true, command: command)
      rescue Errors::DockerClientInvalid => e
        signal_usage_error(e.message)
      end
    end
  end
end
