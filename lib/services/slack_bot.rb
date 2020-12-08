module Services
  class SlackBot
    HOST = 'https://slack.com/api/'
    TOKEN = ENV['SLACK_TOKEN']
    DELIVERY_REQUESTS_CHANNEL = ENV['SLACK_CHANNEL_DELIVERY_REQUESTS']
    APPLICATION_ERRORS_CHANNEL = ENV['SLACK_CHANNEL_APPLICATION_ERRORS']

    CHANNELS = {
      'delivery-request-notifications' => DELIVERY_REQUESTS_CHANNEL,
      'application-errors' => APPLICATION_ERRORS_CHANNEL
    }

    def self.notify_delivery_request(pickup_location:, pdf_path:)
      res = new.notify_delivery_request(pickup_location)
      response = JSON.parse(res.body)

      if response['ok']
        new.add_delivery_request_pdf(pdf_path, response)
      end
    end

    # NOTE: error is only used in mock for development
    def self.notify_error(message:, backtrace:, error:)
      new.notify_error(message, backtrace)
    end

    def notify_delivery_request(pickup_location)
      Faraday.post(HOST + 'chat.postMessage') do |f|
        f.headers['Content-Type'] = 'application/json'
        f.headers['Authorization'] = "Bearer #{TOKEN}"
        f.body = {
          channel: CHANNELS['delivery-request-notifications'],
          text: "#{pickup_location} has requested a delivery! :tada:"
        }.to_json
      end
    end

    def notify_error(message, backtrace)
      Faraday.post(HOST + 'chat.postMessage') do |f|
        f.headers['Content-Type'] = 'application/json'
        f.headers['Authorization'] = "Bearer #{TOKEN}"
        f.body = {
          channel: CHANNELS['application-errors'],
          blocks: [
            {
              type: "header",
              text: {
                type: "plain_text",
                text: message
              }
            },
            {
              type: "section",
              text: {
                type: "mrkdwn",
                text: "```#{backtrace}```"
              }
            }
          ]
        }.to_json
      end
    end

    def add_delivery_request_pdf(pdf_path, parent_msg)
      filename = pdf_path.split('/').last

      conn = Faraday.new(HOST) do |f|
        f.request :multipart
        f.request :url_encoded
        f.adapter Faraday.default_adapter
      end

      conn.post('files.upload') do |f|
        f.headers['Authorization'] = "Bearer #{TOKEN}"
        f.body = {
          file: Faraday::UploadIO.new(pdf_path, 'application/pdf', filename),
          thread_ts: parent_msg['ts'],
          channels: CHANNELS['delivery-request-notifications'],
          filetype: 'pdf',
          filename: filename
        }
      end
    end
  end
end
