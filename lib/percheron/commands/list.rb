module Percheron
  module Commands
    class List < Abstract

      parameter('STACK_NAMES', 'stack names', required: false) { |s| s.split(/[, ]/) }

      def execute
        super
        stack.list!
      end
    end
  end
end
