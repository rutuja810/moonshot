# frozen_string_literal: true

require 'aws-sdk'
require_relative 'rotate_worker_lib/asg'

module Moonshot
  module Plugins
    # Rotate ASG instances after update.
    class RotateWorkerInstances
      def post_update(resources)
        @asg = ASG.new(resources)
        @asg.rotate_asg_instances
        @asg.teardown_outdated_instances
      end
    end
  end
end
