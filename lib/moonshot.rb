require 'English'
require 'aws-sdk-cloudformation'
require 'aws-sdk-codedeploy'
require 'aws-sdk-ec2'
require 'aws-sdk-iam'
require 'aws-sdk-autoscaling'
require 'aws-sdk-s3'
require 'logger'
require 'thor'
require 'interactive-logger'

module Moonshot
  class << self
    attr_writer :config
  end

  def self.config
    @config ||= Moonshot::ControllerConfig.new
    block_given? ? yield(@config) : @config
  end

  module ArtifactRepository
  end
  module BuildMechanism
  end
  module DeploymentMechanism
  end
  module Plugins
  end
end

require 'require_all'
require_rel 'moonshot'
require_rel 'plugins'
