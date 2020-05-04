require_relative 'spec_helper'

class AppSpec < ConfAdminAppSpec
  describe '/' do
    let(:result) { get '/' }

    it 'handles the request' do
      assert_equal 200, result.status
    end
  end
end
