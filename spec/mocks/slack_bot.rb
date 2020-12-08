module Services
  class SlackBot
    def self.notify_error(message:, backtrace:, error:)
      print "\nERROR: #{message} \n\n"
      raise error
    end

    def self.method_missing(*args)
      print "stubbing slackbot method ##{args.first.to_s}\n"
    end
  end
end
