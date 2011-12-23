# When asked for help, responds with a list of commands supported by
# all loaded plugins
class Robut::Plugin::Help
  include Robut::Plugin

  desc "help - displays this message"
  match /^help$/, :sent_to_me => true do
    reply("Supported commands:")
    Robut::Plugin.plugins.each do |plugin|
      plugin_instance = plugin.new(reply_to, private_sender)
      Array(plugin_instance.usage).each do |command_usage|
        reply(command_usage)
      end
    end
  end
end
