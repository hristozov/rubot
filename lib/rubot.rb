require 'slack-ruby-bot'
require 'yaml'

class Array
  def deep_freeze
    map do |element|
      if element.respond_to? :deep_freeze
        element.deep_freeze
      else
        element.freeze
      end
    end.freeze
  end
end

require 'rubot/version'

require 'rubot/bot'
require 'rubot/memory'

require 'rubot/listener'
require 'rubot/command'
require 'rubot/response'

require 'rubot/listeners/when_did_you_come'

require 'rubot/commands/alias'
require 'rubot/commands/ping_pong'
require 'rubot/commands/unknown'

module SlackRubyBot
  module Hooks
    module Message
      # Monkey-patch to ensure that our unknown command class is called last
      def command_classes
        (Rubot::Listener.descendants -
          Rubot::Command.descendants +
          Rubot::Command.descendants
        ).uniq -
          [Rubot::Commands::Unknown] +
          [Rubot::Commands::Unknown]
      end
    end
  end
end

module Rubot
  def self.root
    File.join(File.dirname(__FILE__), '..')
  end

  def self.memory
    @memory ||= Memory.new(File.join(root, 'config', 'memory.yml'))
  end

  def self.remember(channel = nil)
    if channel
      yield memory.for_channel(channel)
    else
      yield memory
    end

    memory.save
  end

  SECRETS = YAML.load_file(File.join(root, 'config', 'secrets.yml'))
  CONFIG = YAML.load_file(File.join(root, 'config', 'rubot.yml'))
end

ENV['SLACK_API_TOKEN'] = Rubot::SECRETS['slack']['token']
