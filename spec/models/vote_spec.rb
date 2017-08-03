require 'rails_helper'

RSpec.describe Vote, type: :model do

	it 'validates presence of fields' do
		should validate_presence_of(:candidate_id)
		should validate_presence_of(:campaign_id)
    should validate_presence_of(:received_timestamp)
	end
end