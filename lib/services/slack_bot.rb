module Services
  class SlackBot
    HOST = 'https://slack.com/api/'
    TOKEN = ENV['SLACK_TOKEN']
    DELIVERY_REQUESTS_CHANNEL = ENV['SLACK_CHANNEL_DELIVERY_REQUESTS']

    CHANNELS = {
      'delivery-request-notifications' => DELIVERY_REQUESTS_CHANNEL
    }

    def self.notify_delivery_request(business_name)
      new.notify_delivery_request(delivery_request)
    end

    def notify_delivery_request(delivery_request)
      url = HOST + 'chat.postMessage'
      data = {
        channel: CHANNELS['delivery-request-notifications'],
        text: "Request for Delivery from #{business_name}"
      }

      Faraday.post(url, data.to_json, headers)
    end

    private

    def headers
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{TOKEN}"
      }
    end
  end
end

