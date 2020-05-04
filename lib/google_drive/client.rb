module GoogleDrive
  class Client
    CLIENT_ID = ENV['GOOGLE_CLIENT_ID']
    CLIENT_SECRET = ENV['GOOGLE_CLIENT_SECRET']
    CLIENT_TOKEN = ENV['GOOGLE_CLIENT_TOKEN']

    # NOTE: This needs to be set manually when creating a new client app.
    # 1/1. create new app in google console and ad client_id/secret
    # 1/2. run session with blank './config.json' as first arg
    # 1/3. get the link in terminal and authorize in brower
    # 1/4. copy confirmation code into terminal
    # 1/5. client token is removed from created config.js file and used as CLIENT_TOKEN
    # 1/6. replace './config.json' with config method as first argument
    #
    # 2/1. create a new spreadsheet manually
    # 2/2. for the sake of christ, give it name that corresponds to the client
    # 2/3. add the file id as ENV['xxx']
    # 2/4. add headers as required for form data
    def initialize
      print "[GOOGLE DRIVE] Restoring session...\n"
      @session = GoogleDrive::saved_session(config, nil, CLIENT_ID, CLIENT_SECRET)
    end

    private
    attr_reader :session

    def config
      OpenStruct.new(
        scope: [
          "https://www.googleapis.com/auth/drive",
          "https://spreadsheets.google.com/feeds/"
        ],
        refresh_token: CLIENT_TOKEN
      )
    end
  end
end
